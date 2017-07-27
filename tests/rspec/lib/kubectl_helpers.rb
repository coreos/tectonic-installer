require 'json'
require 'English'

def kubectl(kubeconfig, args)
  out = `KUBECONFIG=#{kubeconfig} kubectl #{args}`
  raise KubectlCmdFailed if $CHILD_STATUS.exitstatus != 0
  out
end

def parsed_kubectl(kubeconfig, args)
  out = kubectl(kubeconfig, args + ' -ojson')
  JSON.parse(out)
end

# KubectlCmdFailed is raised whenever the shell command 'kubectl' fails
class KubectlCmdFailed < StandardError
  def initialize(msg = 'failed to call kubectl')
    super
  end
end
