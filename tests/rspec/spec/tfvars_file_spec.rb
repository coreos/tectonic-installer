require 'tfvars_file'

TFVARS_FILE_PATH = '../smoke/aws/vars/aws.tfvars.json'.freeze

RSpec.describe 'tfvars_file' do
  before(:all) do
    @tfvars_file = TFVarsFile.new(TFVARS_FILE_PATH)
  end

  it '.new raises exception with wrong file path' do
    expect { TFVarsFile.new('wrong-file-path') }.to raise_error(RuntimeError)
  end

  it '.path returns the file path' do
    expect(@tfvars_file.path).to be(TFVARS_FILE_PATH)
  end

  it '.node_count returns correct #' do
    expect(@tfvars_file.node_count).to eq(7)
  end

  it '.experimental? returns false if not set' do
    expect(@tfvars_file.experimental?).to eq(false)
  end

  it '.calico? returns false if not set' do
    expect(@tfvars_file.experimental?).to eq(false)
  end
end
