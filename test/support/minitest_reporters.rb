unless ENV["CI"]
  require "minitest/reporters"
  MiniTest::Reporters.use! MiniTest::Reporters::ProgressReporter.new
end
