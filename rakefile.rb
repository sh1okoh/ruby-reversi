require 'rake'
require 'spec/rake/spectask'

task :default => [:game]
task :test    => [:unittest_coverage, :spectest_coverage]

task :unittest do
  ruby "testsrc/runner.rb"
end

task :unittest_coverage do
  sh "cmd /C rcov testsrc/runner.rb -o etc/testsrc_coverage"
  sh "cmd /C perl scripts/coverage.pm etc/testsrc_coverage"
end

Spec::Rake::SpecTask.new(:spectest) do |t|
  t.spec_files = FileList['specsrc/*.rb']
  t.rcov = true
  t.rcov_dir = "etc/specsrc_coverage"
end

task :spectest_coverage => [:spectest] do
  sh "cmd /C perl scripts/coverage.pm etc/specsrc_coverage"
end

task :game do
  ruby "-I src reversi.rb"
end
