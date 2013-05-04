require 'spec_helper'

describe 'resource-control::project', 'validation' do
  before { double_cmd('projects -l project_name') }

  it 'does not allow spaces in name' do
    expect {
      converge_recipe "validate_name", %{
          resource_control_project 'project name'
      }
    }.to raise_error(ArgumentError, /name may not include spaces/)
  end

  it 'does not allow colons or newlines in comments' do
    expect {
      converge_recipe "validate_comment", %{
          resource_control_project 'project_name' do
            comment "some:thing"
          end
      }
    }.to raise_error(ArgumentError, /comment may not include colons or newlines/)

    expect {
      converge_recipe "validate_comment", %{
          resource_control_project 'project_name' do
            comment "some\nthing"
          end
      }
    }.to raise_error(ArgumentError, /comment may not include colons or newlines/)
  end
end

describe 'resource-control::project', 'name' do
  before do
    double_cmd('projects -l project_name')
    double_cmd('projadd')
    double_cmd('projmod')
  end

  context 'when project does not exist' do
    project_does_not_exist('project_name')

    it "creates a project with only name attribute" do
      expect {
        converge_recipe "create", %{
            resource_control_project 'project_name'
        }
      }.to shellout('projadd -c "" project_name')
    end
  end

  context 'when project already exists' do
    project_exists('project_name')

    it "creates a project with only name attribute" do
      expect {
        converge_recipe "update", %{
            resource_control_project 'project_name'
        }
      }.to shellout('projmod -c "" project_name')
    end
  end
end

describe 'resource-control::project', 'comments' do
  before do
    double_cmd('projects -l project_name')
    double_cmd('projadd')
    double_cmd('projmod')
  end

  context 'when project does not exist' do
    project_does_not_exist('project_name')

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

  context 'when project already exists' do
    project_exists('project_name')

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
