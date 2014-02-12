module ProjectHelpers
  def project_exists(name)
    before do
      double_cmd("projects -l #{name}", exit: 0)
    end
  end

  def project_does_not_exist(name)
    before do
      double_cmd("projects -l #{name}", exit: 1)
    end
  end

  def project_has_limits(limits)
    before do
      double_cmd('projects -l project_name', puts: limits.join(','), exit: 0)
    end
  end
end
