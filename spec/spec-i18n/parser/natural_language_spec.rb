require 'spec_helper'

module SpecI18n
  module Parser
    describe NaturalLanguage do

      before(:each) do
        @pt = NaturalLanguage.get('pt')
        @es = NaturalLanguage.get('es')
        @en = NaturalLanguage.get('en')
      end

      context "get languages" do
        
        it "should get the default language" do
          NaturalLanguage.get("en").should_not be_nil
        end
        
        it "should raise for the non existing language" do
          language = "non_existing"
          lambda {  
            NaturalLanguage.new(language) 
          }.should raise_error(LanguageNotFound, "Language #{language} Not Supported")
        end

      end
      
      context "incomplete languages" do
        
        it "should return false for the complete language" do
          @pt.incomplete?.should be_false
        end
        
        it "should return true for the incomplete language" do
          @pt.stub!(:keywords).and_return({ :name => []})
          @pt.incomplete?.should be_true
        end
        
      end
      
      %w(describe before after it should name native).each do |keyword|
        it "should have the #{keyword} keyword" do
          portuguese_keys = @pt.keywords.keys          
          portuguese_keys.should include(keyword)
        end
      end

      context "of dsl keywords" do
      
        it "should return all the dsl keywords" do
          @pt.dsl_keywords.should == {"describe" => [ "descreva", "contexto"] }
        end

        it "should return the describe dsl keyword" do
          lang = { "describe" => "descreva", :before => "antes" }
          @pt.should_receive(:keywords).and_return(lang)
          @pt.dsl_keywords.should == { "describe" => [ lang["describe"] ] }
        end
      end

      context "of expectations keywords" do
        
        before(:each) do
          @keywords = { "should" => ["deve"], "should_not" => ["nao_deve"] }
        end

        it "should return the expectation keyword of the language" do
          lang = {"describe" => "descreva", "should" => "deve", "should_not" => "nao_deve"}
          @pt.should_receive(:keywords).twice.and_return(lang)
          @pt.expectation_keywords.should == @keywords
        end
        
        it "should return the expectation keywords of the current language" do
          keywords = { "should" => ["deberia"], "should_not" => ["no_debe"]}
          @es.expectation_keywords.should == keywords
        end
      end
      
      context "of before and after keywords" do
        
        it "should return the hooks for the current language" do
          keywords = { "before" => ["before"], "after" => ["after"]}
          @en.before_and_after_keywords.should == keywords
        end
        
        it "should return the hooks for the language" do
          keywords = { "before" => ["antes"], "after" => ["depois"]}
          @pt.before_and_after_keywords.should == keywords
        end
      end
      
      context "of hooks keywords" do
        
        it "should return the hooks parameters for the current language" do
          keywords = { "each" => ["de_cada", "de_cada_exemplo"], 
                       "all" => ["de_todos", "de_todos_exemplos"],
                       "suite" => ["suite"]}
          @pt.hooks_params_keywords.should == keywords                       
        end
      end
      
      context "of example group keywords" do
        
        before(:each) do
          @keywords = { "it" => ["exemplo", "especificar"] }
        end
        
        it "should return the example group keywords for the current language" do
          @pt.example_group_keywords.should == @keywords
        end
        
        it "should return the example group for the portuguese language" do
          @keywords = { "it" => ["it", "specify"]}
          @en.example_group_keywords.should == @keywords
        end
      end

      context 'of example subject keywords' do
        
        before(:each) do
          @keywords = { "subject" => "assunto|tema" }
          @spanish_keywords = { 'subject' => 'asunto|tema'}
        end

        it 'should return the subject keywords' do
          @pt.stub!(:keywords).and_return(@keywords)
          @pt.subject_keywords.should == {'subject' => ["assunto", "tema"]}
        end

        it 'should return the subject keywords for spanish language' do
          @spanish_keywords.stub!(:keywords).and_return(@spanish_keywords)
          @es.subject_keywords.should == { 'subject' => ['asunto', 'tema']}
        end
      end

      context 'of example its keywords' do
        
        before(:each) do
          @keywords = { "its" => "exemplos" }
          @spanish_keywords = { 'its' => 'ejemplos'}
        end

        it 'should return the its keywords' do
          @pt.stub!(:keywords).and_return(@keywords)
          @pt.its_keywords.should == {'its' => ["exemplos"]}
        end

        it 'should return the its keywords for spanish language' do
          @es.stub!(:keywords).and_return(@spanish_keywords)
          @es.its_keywords.should == { 'its' => ['ejemplos']}
        end
      end
      context "splitting the keys" do
        it "should raise no found key" do
          lambda {
            @pt.spec_keywords("no_found")
            @pt.spec_keywords("Oh_MY_this_words_is_not_found!")
          }.should raise_error(RuntimeError)
        end

        it "should split correctly the keys" do
         lang = { "describe" => "descreva|contexto" }
         @pt.stub!(:keywords).and_return(lang)
         @pt.spec_keywords("describe").should == { "describe" => ["descreva", "contexto"] }
        end
      end
    end
  end
end
