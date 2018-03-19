package terraform

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"

	"github.com/hashicorp/terraform/terraform"
)

const (
	stateFileName  = "terraform.tfstate"
	tfVarsFileName = "terraform.tfvars"
	logsFolderName = "logs"

	logsFileSuffix = ".log"
	failFileSuffix = ".fail"
)

// ErrBinaryNotFound denotes the fact that the TerraForm binary could not be
// found on disk.
var ErrBinaryNotFound = errors.New(
	"TerraForm not in executable's folder, cwd nor PATH",
)

// ExecutionStatus describes whether an execution succeeded, failed or is still
// in progress.
type ExecutionStatus string

const (
	// ExecutionStatusUnknown indicates that the status of execution is unknown.
	ExecutionStatusUnknown ExecutionStatus = "Unknown"
	// ExecutionStatusRunning indicates that the the execution is still in
	// process.
	ExecutionStatusRunning ExecutionStatus = "Running"
	// ExecutionStatusSuccess indicates that the execution succeeded.
	ExecutionStatusSuccess ExecutionStatus = "Success"
	// ExecutionStatusFailure indicates that the execution failed.
	ExecutionStatusFailure ExecutionStatus = "Failure"
)

// Executor enables calling TerraForm from Go, across platforms, with any
// additional providers/provisioners that the currently executing binary
// exposes.
//
// The TerraForm binary is expected to be in the executing binary's folder, in
// the current working directory or in the PATH.
// Each Executor runs in a temporary folder, so each Executor should only be
// used for one TF project.
//
// TODO: Ideally, we would use TerraForm as a Go library, so we can monitor a
// hook and report the current state in real-time when
// Apply/Refresh/Destroy are used. While technically possible today, because
// TerraForm currently hides the providers/provisioners list construction in
// their main package, it would require to reproduce a bunch of their logic,
// which is out of the scope of the first-version of the Executor. With a bit of
// efforts, we could actually even stop requiring having a TerraForm binary
// altogether, by linking the builtin providers/provisioners to this particular
// binary and re-implemeting the routing here. Alternatively, we could
// contribute upstream to add a 'debug' flag that would enable a hook that would
// expose the live state to a file (or else).
type Executor struct {
	executionPath string
	binaryPath    string
	envVariables  map[string]string
}

// NewExecutor initializes a new Executor.
func NewExecutor(executionPath string) (*Executor, error) {
	ex := new(Executor)
	ex.executionPath = executionPath

	// Find the TerraForm binary.
	out, err := tfBinaryPath()
	if err != nil {
		return nil, err
	}

	ex.binaryPath = out
	return ex, nil
}

// AddFile is a convenience function that writes a single file in the Executor's
// working directory using the given content. It may replace an existing file.
func (ex *Executor) AddFile(name string, content []byte) error {
	filePath := filepath.Join(ex.WorkingDirectory(), name)
	return ioutil.WriteFile(filePath, content, 0660)
}

// AddVariables writes the `terraform.tfvars` file in the Executor's working
// directory using the given content. It may replace an existing file.
func (ex *Executor) AddVariables(content []byte) error {
	return ex.AddFile(tfVarsFileName, content)
}

// AddEnvironmentVariables adds extra environment variables that will be set
// during the execution.
// Existing variables are replaced. This function is not thread-safe.
func (ex *Executor) AddEnvironmentVariables(envVars map[string]string) {
	if ex.envVariables == nil {
		ex.envVariables = make(map[string]string)
	}
	for k, v := range envVars {
		ex.envVariables[k] = v
	}
}

// AddCredentials is a convenience function that converts the given Credentials
// into environment variables and add them to the Executor.
//
// If the credentials parameter is nil, nothing is done.
// An error is returned if the credentials are invalid.
func (ex *Executor) AddCredentials(credentials *Credentials) error {
	if credentials == nil {
		return nil
	}

	env, err := credentials.ToEnvironment()
	if err != nil {
		return err
	}
	ex.AddEnvironmentVariables(env)

	return nil
}

// Execute runs the given command and arguments against TerraForm.
//
// An error is returned if the TerraForm binary could not be found, or if the
// TerraForm call itself failed, in which case, details can be found in the
// output.
func (ex *Executor) Execute(clusterDir string, args ...string) error {
	// Prepare TerraForm command by setting up the command, configuration,
	// working directory (so the files such as terraform.tfstate are stored at
	// the right place), extra environment variables and outputs.
	cmd := exec.Command(ex.binaryPath, args...)
	// ssh changes its behavior based on these. pass them through so ssh-agent & stuff works
	cmd.Env = append(cmd.Env, fmt.Sprintf("DISPLAY=%s", os.Getenv("DISPLAY")))
	cmd.Env = append(cmd.Env, fmt.Sprintf("PATH=%s", os.Getenv("PATH")))
	cmd.Env = append(cmd.Env, fmt.Sprintf("HOME=%s", os.Getenv("HOME")))
	for _, v := range os.Environ() {
		if strings.HasPrefix(v, "SSH_") {
			cmd.Env = append(cmd.Env, v)
		}
	}
	for k, v := range ex.envVariables {
		cmd.Env = append(cmd.Env, fmt.Sprintf("%s=%s", strings.ToUpper(k), v))
	}
	if clusterDir != "" {
		cmd.Dir = clusterDir
	} else {
		cmd.Dir = ex.executionPath
	}

	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	// Start TerraForm.
	err := cmd.Run()
	if err != nil {
		// The process failed to start, we can't even save that it started since we
		// don't have a PID yet.
		return err
	}

	return nil
}

// WorkingDirectory returns the directory in which TerraForm runs, which can be
// useful for inspection or to retrieve any generated files.
func (ex *Executor) WorkingDirectory() string {
	return ex.executionPath
}

// Output returns a ReadCloser on the output file of an execution, or an error
// if no output for that execution identifier can be found.
func (ex *Executor) Output(id int) (io.ReadCloser, error) {
	return os.Open(ex.logPath(id))
}

// State returns the current TerraForm State.
//
// The returned value can be nil if there is currently no state held.
func (ex *Executor) State() *terraform.State {
	f, err := os.Open(filepath.Join(ex.executionPath, stateFileName))
	if err != nil {
		return nil
	}
	defer f.Close()

	s, err := terraform.ReadState(bufio.NewReader(f))
	if err != nil {
		return nil
	}

	return s
}

// Ignore certain relative paths in the Terraform data dir. Paths must start at
// the top dir
var pathsToIgnore = map[string]struct{}{
	logsFolderName: {},
}

// Cleanup removes resources that were allocated by the Executor.
func (ex *Executor) Cleanup() {
	if ex.executionPath != "" {
		os.RemoveAll(ex.executionPath)
	}
}

type recursiveFileWalkFunc func(path, relPath string, fi os.FileInfo) error

func recursiveFileWalk(dir, root string, withTopFolder bool, f recursiveFileWalkFunc) error {
	entries, err := ioutil.ReadDir(dir)
	if err != nil {
		return err
	}

	for _, entry := range entries {
		// Get the entry path and its relative path to root.
		entryPath := filepath.Join(dir, entry.Name())
		entryRelPath, err := filepath.Rel(root, entryPath)
		if err != nil {
			return err
		}
		if withTopFolder {
			rootDirS := strings.Split(root, string(os.PathSeparator))
			entryRelPath = filepath.Join(rootDirS[len(rootDirS)-1], entryRelPath)
		}

		// Execute the function we were instructed to run. Continue onto the next
		// entry if error is returned.
		if err := f(entryPath, entryRelPath, entry); err != nil {
			continue
		}

		if entry.IsDir() {
			// That's a folder, recurse into it.
			if err := recursiveFileWalk(entryPath, root, withTopFolder, f); err != nil {
				return err
			}
		}
	}

	return nil
}

// tfBinatyPath searches for a TerraForm binary on disk:
// - in the executing binary's folder,
// - in the current working directory,
// - in the PATH.
// The first to be found is the one returned.
func tfBinaryPath() (string, error) {
	// Depending on the platform, the expected binary name is different.
	binaryFileName := "terraform"
	if runtime.GOOS == "windows" {
		binaryFileName = "terraform.exe"
	}

	// Look into the executable's folder.
	if execFolderPath, err := filepath.Abs(filepath.Dir(os.Args[0])); err == nil {
		path := filepath.Join(execFolderPath, binaryFileName)
		if stat, err := os.Stat(path); err == nil && !stat.IsDir() {
			return path, nil
		}
	}

	// Look into cwd.
	if workingDirectory, err := os.Getwd(); err == nil {
		path := filepath.Join(workingDirectory, binaryFileName)
		if stat, err := os.Stat(path); err == nil && !stat.IsDir() {
			return path, nil
		}
	}

	// If we still haven't found the executable, look for it
	// in the PATH.
	if path, err := exec.LookPath(binaryFileName); err == nil {
		return filepath.Abs(path)
	}

	return "", ErrBinaryNotFound
}

// failPath returns the path to the failure file of a given execution process.
func (ex *Executor) failPath(id int) string {
	failFileName := fmt.Sprintf("%d%s", id, failFileSuffix)
	return filepath.Join(ex.executionPath, logsFolderName, failFileName)
}

// logPath returns the path to the log file of a given execution process.
func (ex *Executor) logPath(id int) string {
	logFileName := fmt.Sprintf("%d%s", id, logsFileSuffix)
	return filepath.Join(ex.executionPath, logsFolderName, logFileName)
}
