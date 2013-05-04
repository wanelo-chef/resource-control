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
    double_cmd('projects -l name-only')
  end

  context 'project does not exist' do
    before do
      double_cmd('grep name-only /etc/project', exit: 1)
    end

    it "creates a project with only name attribute" do
      double_cmd('projadd -c "" name-only')
      runner.converge 'fixtures::create'
      expect(history).to include('projadd -c "" name-only'.shellsplit)
    end
  end

  context 'project already exists' do
    before do
      double_cmd('grep name-only /etc/project', exit: 0)
    end

    it "creates a project with only name attribute" do
      double_cmd('projmod -c "" name-only')
      runner.converge 'fixtures::create'
      expect(history).to include('projmod -c "" name-only'.shellsplit)
    end
  end
end
