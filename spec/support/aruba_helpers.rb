module ArubaHelpers
  def self.history
    @history ||= ArubaDoubles::History.new(File.join(ArubaDoubles::Double.bindir, ArubaDoubles::HISTORY_FILE))
  end
end

RSpec::Matchers.define :shellout do |cmd|
  match do |convergence|
    raise ArgumentError, "expected should be a Proc" unless convergence.is_a?(Proc)
    @convergence = convergence.call
    ArubaHelpers.history.include?(cmd.shellsplit)
  end

  failure_message_for_should do |convergence|
    "expected that #{@convergence} would run command #{cmd}\nfound: #{ArubaHelpers.history.map(&:shelljoin)}"
  end

  failure_message_for_should_not do |convergence|
    "expected that #{@convergence} would NOT run command #{cmd}"
  end

  description do
    "run command #{cmd}"
  end
end
