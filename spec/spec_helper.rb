require 'rubygems'
require 'spec'
require 'spec/runner/differs/default'
require 'spec-i18n'

$:.unshift(File.dirname(__FILE__), '../lib')

def with_sandboxed_options
  attr_reader :options
  
  before(:each) do
    @original_rspec_options = ::Spec::Runner.options
    ::Spec::Runner.use(@options = ::Spec::Runner::Options.new(StringIO.new, StringIO.new))
  end

  after(:each) do
    ::Spec::Runner.use(@original_rspec_options)
  end
  
  yield
end

def with_sandboxed_config
  attr_reader :config
  
  before(:each) do
    @config = ::Spec::Runner::Configuration.new
    @original_configuration = ::Spec::Runner.configuration
    spec_configuration = @config
    ::Spec::Runner.instance_eval {@configuration = spec_configuration}
  end
  
  after(:each) do
    original_configuration = @original_configuration
    ::Spec::Runner.instance_eval {@configuration = original_configuration}
    ::Spec::Example::ExampleGroupFactory.reset
  end
  
  yield
end
