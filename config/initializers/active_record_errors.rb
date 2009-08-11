# originally from: http://speakmy.name/2009/01/custom-validation-errors-in-rails-and-activerecord/
# error messages ohne den Namen des Feldes als prefix beginnen mit "^"

class ActiveRecord::Errors
  CUSTOM_PREFIX = '^'

  def full_messages(options = {})
    full_messages = []

    @errors.each_key do |attr|
      @errors[attr].each do |message|
        next unless message

        if attr == "base"
          full_messages << message
        elsif message.mb_chars[0..(CUSTOM_PREFIX.size-1)] == CUSTOM_PREFIX
          full_messages << message.mb_chars[(CUSTOM_PREFIX.size)..-1]
        else
          #key = :"activerecord.att.#{@base.class.name.underscore.to_sym}.#{attr}"
          attr_name = @base.class.human_attribute_name(attr)
          full_messages << attr_name + ' ' + message
        end

      end
    end
    full_messages
  end
end