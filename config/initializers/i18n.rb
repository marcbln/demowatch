require 'globalize/i18n/missing_translations_log_handler'
I18n.missing_translations_logger = Logger.new("#{RAILS_ROOT}/log/missing_translations.log")
I18n.exception_handler = :missing_translations_log_handler


# all possible locales, wird fuer sprachauswahl und default-fallback-reihenfolge verwendet
I18N_ALL_LANGUAGES = %w{de en es fr} # alphabetical order

# das hier ist um sicherzugehen, dass auf jeden fall eine translation gefunden wird (sonst gibt es exception)
I18N_ALL_LANGUAGES.each do |l|
  I18n.fallbacks[l.intern] = I18N_ALL_LANGUAGES
end
# hier kann die fallback-reihenfolge pro sprache individuell angepasst werden

