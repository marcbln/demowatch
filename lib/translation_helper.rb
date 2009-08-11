module TranslationHelper

  @@fallback_languages = ['de', 'en', 'es', 'fr']


  def self.get_translation( translations, column)
    @@fallback_languages.each do |l|
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
    return '--------------------' # no translation found
  end

end
