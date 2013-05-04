require 'spec_helper'

describe 'resource-control::project' do
  let!(:runner) {
    ChefSpec::ChefRunner.new(
      platform: 'smartos',
      step_into: ['resource-control_project'],
      cookbook_path: %W(#{File.expand_path(Dir.pwd)}/spec #{File.expand_path("..", Dir.pwd)})
    )
  }

  before do
    Mixlib::ShellOut.should_receive(:new).with('projects -l name-only').and_return(
      mock(run_command: true, stdout: "")
    )
  end

  context 'project does not exist' do
    before do
      project_exists = mock(run_command: true)
      Mixlib::ShellOut.should_receive(:new).with('grep name-only /etc/project').and_return(project_exists)
      project_exists.stub(:error!).and_raise(RuntimeError)
    end

    it "creates a project with only name attribute" do
      shell_mock = mock(run_command: true, error!: false)
      Mixlib::ShellOut.should_receive(:new).with('projadd -c "" name-only').and_return(shell_mock)
      runner.converge 'fixtures::create'
    end
  end
end
