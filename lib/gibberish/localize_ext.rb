module Gibberish #:nodoc:

    module Localize #:nodoc:

      # Use the languages hash to determine if a language has a definition file
			# 
      def supported?(language)
        language = language.to_sym if language.respond_to? :to_sym
        language ==  @@default_language || @@languages[language] != nil
      end

    end
end
