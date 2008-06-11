
module GibberishRails
  module Helper

    # Gets the "best guess" locale, a parameter is the first prioirity,
    # then the HTTP_ACCEPT_LANGUAGE, finally the default.   If some one 
    # has a very specific locale, like es-mx, use it if we have it. Otherwise,
    # if we don't have es-mx, check for es before giving up...
		#
    def best_guess_locale(locale, accept_header)

      # first try es-mx
      return locale if locale && Gibberish.supported?(locale)

      # now try es
      locale = locale[/[^-]+/] if locale
      return locale if locale && Gibberish.supported?(locale)

      found_locale = nil

      accept_header.split(',').each do |locale|
        locale = locale[/[^,;]+/]
        if ( Gibberish.supported?(locale) ) # First try es-mx
          found_locale = locale.to_sym
          break
        end
        locale = locale[/[^-]+/]
        if ( Gibberish.supported?(locale) ) # Then try es
          found_locale = locale.to_sym
          break
        end
      end
      if ( ! found_locale )
        found_locale = Gibberish.languages.first
      end
      found_locale
    end

  end
end
