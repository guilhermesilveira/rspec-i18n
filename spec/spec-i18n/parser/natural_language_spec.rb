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
      
      context "imcomplete languages" do
        
        it "should return true for the complete language" do
          @pt.incomplete?.should be_true
        end
        
        it "should return false for the imcomplete language" do
          @pt.stub!(:keywords).and_return({ :name => []})
          @pt.incomplete?.should be_false
        end
        
      end
      
      context "list languages" do
        
        before(:each) do
          @portuguese = ["pt", "Portuguese", "português"]
          @spanish = ["es", "Spanish", "español"]
        end
        
        it "should return the three keywords language for portuguese" do
          SpecI18n::SPEC_LANGUAGES.should_receive(:keys).and_return("pt")
          NaturalLanguage.list_languages.should == [@portuguese]
        end
        
        it "should return the three keywords for spanish" do
          SpecI18n::SPEC_LANGUAGES.should_receive(:keys).and_return("es")
          NaturalLanguage.list_languages.should == [@spanish]
        end
        
        it "should return the three keywords for spanish and portuguese" do
          SpecI18n::SPEC_LANGUAGES.should_receive(:keys).and_return(["pt", "es"])
          NaturalLanguage.list_languages.should == [@portuguese, @spanish].sort
        end
      end
      
      context "list all keywords" do
        
        before(:each) do
          @portuguese = NaturalLanguage.get("pt")
        end
        
        # TODO: It's 3 a.m in the morning ... Ugly Specs ... #FIXME
        
        it "should return the name keyword for the portuguese language" do
          name = ["name", "Portuguese"]
          NaturalLanguage.list_keywords("pt").first.should == name
        end
        
        it "should return the example keyword for the portuguese language" do
          keywords = NaturalLanguage.list_keywords('pt')
          example = keywords.map { |array| array if array.include?("it") }.compact.flatten
          example.should == ["it", "exemplo / especificar"]
        end
        
        it "should return all the keywords for the spanish language" do
          native = ["native", "español"]
          NaturalLanguage.list_keywords('es')[1].should == native
        end
        
      end

      %w(describe before after it should name native).each do |keyword|
        it "should have the #{keyword} keyword" do
          @pt.keywords.keys.should be_include(keyword)
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

      context "of all matchers" do
        it "should parse all matchers"
      end

      context "splitting the keys" do
        it "should raise no found key" do
          lambda {
            @pt.spec_keywords("no_found")
          }.should raise_error(RuntimeError)
        end

        it "should split correctly the keys" do
         lang = { "describe" => "descreva|contexto" }
         NaturalLanguage.instance_variable_set(:@keywords, lang["describe"])
         @pt.spec_keywords("describe").should == { "describe" => ["descreva", "contexto"] }
        end
      end
    end
  end
end
