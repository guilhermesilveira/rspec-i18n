require 'spec_helper'

describe "should raise_error" do
  
  before(:each) do
    @expected_matcher = {'matchers' => {'raise_error' => 'mostrar_erro'}}
    portuguese_language(@expected_matcher)
    Spec::Matchers.register_all_matchers
  end
  
  it 'should register the methods for the value equal matcher' do
    values = @expected_matcher['matchers']['raise_error'].split('|') 
    values.each { |method_name| Object.instance_methods.should be_include(method_name) }
  end
  
  it "should pass if anything is raised" do
    lambda {raise}.should mostrar_erro
  end
  
  it "should fail if nothing is raised" do
    lambda {
      lambda {}.should mostrar_erro
    }.should mostrar_erro
  end
end