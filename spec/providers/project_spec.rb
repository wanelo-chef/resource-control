require 'spec_helper'

describe 'resource-control::project' do
  before do
    double_cmd('projects -l project_name')
    double_cmd('projadd')
    double_cmd('projmod')
  end

  context 'project does not exist' do
    before { double_cmd('grep project_name /etc/project', exit: 1) }

    it "creates a project with only name attribute" do
      expect {
        converge_recipe "create", %{
            resource_control_project 'project_name'
        }
      }.to shellout('projadd -c "" project_name')
    end

    it "sets a comment" do
      expect {
        converge_recipe "create_with_comment", %{
            resource_control_project 'project_name' do
              comment "project comment"
            end
        }
      }.to shellout('projadd -c "project comment" project_name')
    end
  end

  context 'project already exists' do
    before { double_cmd('grep project_name /etc/project', exit: 0) }

    it "creates a project with only name attribute" do
      expect {
        converge_recipe "update", %{
            resource_control_project 'project_name'
        }
      }.to shellout('projmod -c "" project_name')
    end

    it "updates comments" do
      expect {
        converge_recipe "update_comment", %{
            resource_control_project 'project_name' do
              comment "new project comment"
            end
        }
      }.to shellout('projmod -c "new project comment" project_name')
    end
  end
end
