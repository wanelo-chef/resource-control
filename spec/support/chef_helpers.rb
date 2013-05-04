require 'fileutils'

module ChefHelpers
  def setup_chef
    @checksum_path = Chef::Config[:checksum_path]
    Chef::Config[:checksum_path] = "#{File.expand_path(Dir.pwd)}/tmp/checksums"
  end

  def reset_chef
    Chef::Config[:checksum_path] = @checksum_path
  end

  def install_fixtures
    FileUtils.mkdir_p('tmp/fixtures/recipes')
    File.open('tmp/fixtures/metadata.rb', 'w') do |md|
      md.puts 'name "fixtures"'
      md.puts 'version "1.0.0"'
      md.puts 'depends "resource-control"'
    end
  end

  def reset_fixtures
    FileUtils.rm_rf('tmp')
  end

  def converge_recipe recipe_name, recipe_code
    install_fixtures
    File.open("tmp/fixtures/recipes/#{recipe_name}.rb", 'w+') do |f|
      f.puts "include_recipe 'resource-control'"
      f.puts recipe_code
    end
    runner.converge "fixtures::#{recipe_name}"
    recipe_code
  ensure
    reset_fixtures
  end

  def runner
    ChefSpec::ChefRunner.new(
      platform: 'smartos',
      step_into: ['resource-control_project'],
      cookbook_path: %W(#{File.expand_path(Dir.pwd)}/tmp #{File.expand_path("..", Dir.pwd)})
    )
  end
end
