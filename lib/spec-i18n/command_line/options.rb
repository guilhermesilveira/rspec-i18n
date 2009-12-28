require 'spec-i18n/command_line/language_help_formatter'

module SpecI18n
  module CommandLine
    class Options
      
      attr_reader :options
      def initialize(output_stream = STDOUT, error_stream = STDERR, options = {})
        @output_stream = output_stream
        @error_stream = error_stream
        @options = options
      end
      
      def parse!(args)
        @args = args
        @args.extend(::OptionParser::Arguable)
        
        @args.options do |opts|
          opts.banner = [ "Usage: rspec-i18n [options] [LANGUAGE]", "",
            "Examples:",
            "rspec-i18n --language help",
            "rspec-i18n -l help",
            "rspec-i18n --language pt",
            "rspec-i18n -l pt"].join("\n")
            
          opts.on("--language LANGUAGE", 
            "List keywords for a particular language",
            %{Run with "--language help" to see all languages}) do |language|
            if language == 'help'
              LanguageHelpFormatter.list_languages_and_exit(@output_stream)
            else
              #list_keywords_and_exit(language)
            end
          end  
            opts.on("--i18n LANG",
              "List keywords for in a particular language",
              %{Run with "--i18n help" to see all languages}) do |lang|
              if lang == 'help'
                list_languages_and_exit
              else
                list_keywords_and_exit(lang)
              end
            end
          opts.on_tail("--version", "Show version.") do
            @output_stream.puts SpecI18n::VERSION
            Kernel.exit(0)
          end
          opts.on_tail("-h", "--help", "You're looking at it.") do
            @output_stream.puts opts.help
            Kernel.exit(0)
          end
        end.parse!
      end
      
    end
  end
end