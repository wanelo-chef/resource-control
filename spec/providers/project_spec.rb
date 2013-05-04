require 'spec_helper'

describe 'resource-control::project' do
  before do
    double_cmd('projects -l name-only')
    double_cmd('projadd')
    double_cmd('projmod')
  end

  context 'project does not exist' do
    before do
      double_cmd('grep name-only /etc/project', exit: 1)
    end

    it "creates a project with only name attribute" do
      expect {
        converge_recipe %{
            resource_control_project 'name-only'
        }
      }.to shellout('projadd -c "" name-only')
    end

    it "sets a comment" do
      expect {
        converge_recipe %{
            resource_control_project 'project' do
              comment "project comment"
            end
        }
      }.to shellout('projadd -c "project comment" project')
    end
  end

  context 'project already exists' do
    before do
      double_cmd('grep name-only /etc/project', exit: 0)
    end

    it "creates a project with only name attribute" do
      expect {
        converge_recipe %{
            resource_control_project 'name-only'
        }
      }.to shellout('projmod -c "" name-only')
    end
  end
end
