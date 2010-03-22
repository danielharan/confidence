require 'pathname'
require 'minitest/autorun'
require 'mocha'
require 'crack/xml'

begin require 'ruby-debug'; rescue LoadError; end
begin require 'redgreen'  ; rescue LoadError; end
begin require 'phocus'    ; rescue LoadError; end

require 'lib/confidence'

class MiniTest::Unit::TestCase
  def self.test(name, &block)
    define_method("test_#{name}".gsub(/\s/,'_'), &block)
  end
end
