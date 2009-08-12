# all possible locales, wird fuer sprachauswahl und default-fallback-reihenfolge verwendet
I18N_ALL_LANGUAGES = %w{de en es fr} # alphabetical order



module TranslationHelper
  # todo: nur einmal generieren (use static var)
  def self.get_fallback_languages
    # das hier ist, damit er alle sprachen mal durchpropiert
    # wenn es sinnvoll ist, kann die reifenfolge pro sprache definiert werden
    return [I18n.locale.to_s] + I18N_ALL_LANGUAGES.reject { |n| n == I18n.locale.to_s }
  end

  def self.get_translation( translations, column)
    self.get_fallback_languages.each do |l|
      translations.each do |tr|
        if tr[:locale] != l
          next
        end
        if tr[column].empty?
          next
        end
        return tr[column]
      end
    end
    return '' # no translation found
  end

  def self.get_languages( translations)
    languages = []
    translations.each do |tr|
      languages.push tr.locale
    end
    languages
  end

end
