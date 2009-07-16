# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
#  def t_namespace(ns) 
#    @t_ns=ns
#  end
#  def t(id, options = {})
#    if id =~ /^\./
#      I18n.t(@t_ns+id,options)
#    else
#      I18n.t(id,options)
#    end
#  end
#  def t_date(year,month,day)
#    I18n.l(Date.new(year,month,day))
#  end
  def google_maps_key
    if request.host.match( /^www\.demowatch\.de/i)
      "ABQIAAAAbmKt_bX8rXoUBM2tWSorIRTnBMjsH0Y2aRb-_04glZphNt2GURSXRZg8NE723uvkLLIsOlfTgHhmzA"
    else
      "ABQIAAAAbmKt_bX8rXoUBM2tWSorIRRIprxYrvhzIftfk2H1NRSL0ylmFBQNgArCNLV3vVHVwuG4YfMtNHBR8Q"
    end
  end
end
