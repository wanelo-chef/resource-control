require 'spec_helper'

describe 'resource-control::project' do
  before do
    double_cmd('projects -l name-only')
  end

  context 'project does not exist' do
    before do
      double_cmd('grep name-only /etc/project', exit: 1)
    end

    it "creates a project with only name attribute" do
      double_cmd('projadd -c "" name-only')
      converge_recipe <<-END
        resource_control_project 'name-only'
      END
      expect(history).to include('projadd -c "" name-only'.shellsplit)
    end
  end

  context 'project already exists' do
    before do
      double_cmd('grep name-only /etc/project', exit: 0)
    end

    it "creates a project with only name attribute" do
      double_cmd('projmod -c "" name-only')
      converge_recipe <<-END
        resource_control_project 'name-only'
      END
      expect(history).to include('projmod -c "" name-only'.shellsplit)
    end
  end
end
