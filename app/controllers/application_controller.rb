# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.


# todo ... die aus dem helper benutzen
I18N_ALL_LANGUAGES = %w{de en es fr} # alphabetical order
DEFAULT_LANGUAGE = 'en'


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
  
  
  before_filter :redirect_to_demowatch_org_or_set_locale
#  before_filter :set_locale
  before_filter :save_count

#  def set_locale
#    I18n.default_locale = 'en' # default fallback
#    if request.host.include?('localhost') # local werden cookies verwendet
#      I18n.locale = cookies[:language] ? cookies[:language] : 'de'
#    else
#      logger.debug "* Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
#      if request.host.match( /^www\.demowatch\.de/i)
#        I18n.locale = 'de'
#      else
#        I18n.locale = 'en'
#      end
#    end
#    logger.debug "* Locale set to '#{I18n.locale}'"
#  end

  def redirect_to_demowatch_org_or_set_locale
    @rh = request.host
#    @rh = 'de.demowatch.org'

    # LOCALHOST
    if @rh.include?('localhost')
      I18n.locale = cookies[:language] ? cookies[:language] : 'de'
      return
    end

    # RELEASE SERVER
    # www.demowatch.de / demowatch.de
    if !@rh.match( /demowatch\.de$/i).nil?
      _301_to_domain 'de.demowatch.org'
    else if !@rh.match( /.+\.demowatch\.eu$/i).nil? ||  !@rh.match( /.+\.demowatch\.net$/i).nil?
      locale = get_locale_from_subdomain
      if locale.nil?
        _301_to_domain( get_locale_from_http_header + '.demowatch.org')
      else
        _301_to_domain( locale + '.demowatch.org')
      end
    # so sollen die domains aussehen:
    # www.demowatch.org, en.demowatch.org, de.demowatch.org, ...
    else if !@rh.match( /.+\.demowatch\.org$/i).nil?
      locale = get_locale_from_subdomain
      if locale.nil?
        _301_to_domain( get_locale_from_http_header + '.demowatch.org')
      else
        # hier ist er richtig, z.b. de.demowatch.org
        I18n.locale = locale
        p "=== locale: #{I18n.locale} ==="
      end
    else
      # demowatch.eu, demowatch.org, demowatch.net + unbekannte
      _301_to_domain( get_locale_from_http_header + '.demowatch.org')
    end
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


  # return language code from HTTP_ACCEPT_LANGUAGE or nil if failed
  # some browsers (eg epiphany) don't send HTTP_ACCEPT_LANGUAGE ...
  def get_locale_from_http_header
    return DEFAULT_LANGUAGE if request.env['HTTP_ACCEPT_LANGUAGE'].nil?
    locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    return locale if I18N_ALL_LANGUAGES.include?( locale)
    return DEFAULT_LANGUAGE
  end
  # gibt die sprache aus der subdomain zurueck, wenn die gueltig ist, sonst nil
  def get_locale_from_subdomain
    locale = @rh.match( /(.+)\.demowatch\.[a-z]{2,3}$/i)[1]
    return locale if ( I18N_ALL_LANGUAGES.include?( locale))
    return nil
  end


  def _301_to_domain( new_domain)
    p "#{@rh} -> #{new_domain}"
    redirect_to 'http://' + new_domain + request.path, :status=>:moved_permanently
  end

end
