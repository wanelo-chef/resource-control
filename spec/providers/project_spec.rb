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

describe 'resource-control::project', 'process limits' do
  before do
    double_cmd('projects -l project_name')
    double_cmd('projadd')
    double_cmd('projmod')
  end

  project_exists('project_name')

  context 'with limit as a value' do
    it 'sets value with action none' do
      expect {
        converge_recipe "set_project_as_value", %{
            resource_control_project 'project_name' do
              process_limits "something" => 1234
            end
        }
      }.to shellout('projmod -K "process.something=(privileged,1234,none)" project_name')
    end
  end

  context 'with limit as a hash' do
    it 'allows allows value to be set as a string' do
      expect {
        converge_recipe "set_project_as_hash_string_value", %{
            resource_control_project 'project_name' do
              process_limits "something" => { 'value' => 1234 }
            end
        }
      }.to shellout('projmod -K "process.something=(privileged,1234,none)" project_name')
    end

    it 'allows allows value to be set as a symbol' do
      expect {
        converge_recipe "set_project_as_hash_string_value", %{
            resource_control_project 'project_name' do
              process_limits "something" => { :value => 1234 }
            end
        }
      }.to shellout('projmod -K "process.something=(privileged,1234,none)" project_name')
    end

    it 'can set deny to true' do
      expect {
        converge_recipe "set_project_as_hash_deny", %{
            resource_control_project 'project_name' do
              process_limits "something" => { :value => 1234, :deny => true }
            end
        }
      }.to shellout('projmod -K "process.something=(privileged,1234,deny)" project_name')

      expect {
        converge_recipe "set_project_as_hash_deny_string", %{
            resource_control_project 'project_name' do
              process_limits "something" => { :value => 4567, 'deny' => true }
            end
        }
      }.to shellout('projmod -K "process.something=(privileged,4567,deny)" project_name')
    end

    it 'can set signal action' do
      expect {
        converge_recipe "set_project_as_hash_none", %{
            resource_control_project 'project_name' do
              process_limits "something" => { :value => 1234, :signal => "TERM" }
            end
        }
      }.to shellout('projmod -K "process.something=(privileged,1234,signal=TERM)" project_name')

      expect {
        converge_recipe "set_project_as_hash_none", %{
            resource_control_project 'project_name' do
              process_limits "something" => { :value => 1234, 'signal' => "KILL" }
            end
        }
      }.to shellout('projmod -K "process.something=(privileged,1234,signal=KILL)" project_name')
    end
  end

  context 'with limit as an array of hashes' do
    it "combines hash values" do
      expect {
        converge_recipe "set_project_as_hash_none", %{
            resource_control_project 'project_name' do
              process_limits "something" => [
                      { :value => 1234, :signal => "TERM" },
                      { :value => 4567, :deny => true }
                  ]
            end
        }
      }.to shellout('projmod -K "process.something=(privileged,1234,signal=TERM),(privileged,4567,deny)" project_name')
    end
  end
end
