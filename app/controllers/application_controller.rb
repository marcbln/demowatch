# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper :all # include all helpers, all the time


  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '3a5df53b34706fb7a4b7c45303d16813'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  rescue_from Authorization::PermissionDenied, :with => :permission_denied
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  
  
  before_filter :redirect_to_www_demowatch_de
  before_filter :set_locale
  before_filter :save_count

  def set_locale
    I18n.default_locale = 'en' # default fallback
    if request.host.include?('localhost') # local werden cookies verwendet
      I18n.locale = cookies[:language] ? cookies[:language] : 'de'
    else
      #logger.debug "* Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
      if request.host.match( /^www\.demowatch\.de/i) 
        I18n.locale = 'de'
      else
        I18n.locale = 'en'
      end
    end
    #logger.debug "* Locale set to '#{I18n.locale}'"
  end

  def redirect_to_www_demowatch_de
    if !request.host.include?('localhost') 
      if request.host.match( /^www\.demowatch\.de/i).nil? && request.host.match( /^www\.demowatch\.eu/i).nil?
        matches = request.host.match(/.*\.([a-z]+)$/i)
        if matches.nil?
          redirect_to "http://www.demowatch.eu" + request.path, :status=>:moved_permanently
        end
        redirect_to "http://www.demowatch." + matches[1] + request.path, :status=>:moved_permanently
      end
    end
  end  
  def save_count
    pv = PageView.find_or_create_by_url_and_date(request.path, Date.today)
    PageView.increment_counter(:count, pv)
  end

protected
  def permission_denied(exception)
    flash[:notice] = t("layouts.application.flash.no_permission")
    redirect_to :front
  end
  
  def not_found(exception)
    flash[:notice] = t("layouts.application.flash.not_found")
    redirect_to :front
  end
private
  def extract_locale_from_accept_language_header
    # some browsers (eg epiphany) don't send HTTP_ACCEPT_LANGUAGE ... so we use domain as language indicator
    if request.env['HTTP_ACCEPT_LANGUAGE'].nil?
      matches = request.host.match(/.*\.([a-z]+)$/i)
      domain2language = { :de=>:de, :eu=>:en }
      if matches.nil? || domain2language[matches[1]].nil?
        return 'en' #default language if everything fails
      end
      return domain2language[matches[1]]
    else
      request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    end
  end
end
