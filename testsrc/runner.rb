STDOUT.sync = true
$KCODE = "utf8"

require 'test/unit'
Test::Unit::AutoRunner.run(true, './testsrc/')
