module EventsHelper

  def event_owner_class
    ((current_user.owns? @event) ? "owner":"admin")
  end
  
  def event_comment_owner_class( id ) 
    ((current_user.owns? @event.comments.find(id)) ? "owner":"admin")
  end
  
  def startdate_thisyear event
    if event.startdate.to_date == Time.now.to_date
      "<div class='today'>" + t("datetime.distance_in_words.today") + "<br/>" + l(event.startdate.to_time,:format => t("time.formats.time")) + "</div>"
    elsif event.startdate.to_date == Time.now.to_date - 1
      "<div class='yesterday'>" + t("datetime.distance_in_words.yesterday") + "</div>"
    elsif event.startdate.to_date == Time.now.to_date + 1
      "<div class='tomorrow'>" + t("datetime.distance_in_words.tomorrow") + "<br/>" + l(event.startdate.to_time,:format => t("time.formats.time")) + "</div>"
    elsif event.startdate <= Time.now && event.startdate > 6.hours.ago
      "<div class='now'>" + t("datetime.distance_in_words.now") + "<br/>" + l(event.startdate.to_time,:format => t("time.formats.time")) + "</div>"
    elsif event.startdate.year == Time.now.year
      event.startdate && l(event.startdate, :format => :day_month)
    else
      event.startdate && l(event.startdate.to_date)
    end
  end
  
  def startdate_nice event
    if event.startdate <= 6.hours.ago
      t(".venue.startdate.past", :startdate => l(event.startdate,:format => "long_verbal") )
    elsif event.startdate.to_date.eql?(Time.now.to_date-1)
      t(".venue.startdate.yesterday", :startdate => l(event.startdate,:format => "long_verbal"))
    elsif event.startdate <= Time.now
      t(".venue.startdate.now", :startdate => l(event.startdate,:format => "long_verbal"))
    elsif event.startdate.to_date.eql?(Time.now.to_date+1)
      t(".venue.startdate.tomorrow", :startdate => l(event.startdate,:format => "long_verbal"))
    elsif event.startdate <= 7.9.days.from_now
      t(".venue.startdate.soon", :timespan => time_ago_in_words(event.startdate), :startdate => l(event.startdate,:format => "long_verbal"))
    else
      t(".venue.startdate.future", :timespan => time_ago_in_words(event.startdate), :startdate => l(event.startdate,:format => "long_verbal"))
    end
  end

  def index_with_year events 
    events.map{|e| e.startdate.to_date.year}.uniq
  end

  def index_with_month events
    events.map{|e| l(e.startdate.to_date,:format=>"%B" + ((e.startdate.to_date.year != Time.now.year) ? " %Y" : ""))}.uniq
  end
  
  def index_with_literals organisations
    organisations.map{|o| o.title.upcase.split(//).first}.uniq
  end
  
  def type_image event
    "type_demo.gif" if event.event_type_id == Event::DemoEvent
  end
  
  def age_opacity time, max_hours
    "opacity:#{'%.1f' % (1.0-(Time.now-time)/60/60/max_hours)}"
  end 

  def events_coordinates events
    events.map{|e| e.coordinates}
  end
  
  def events_bounds events
    la =  events.map{|e| e.latitude}
    lo = events.map{|e| e.longitude}
    [[la.min, lo.min], [la.max, lo.max]]
  end
  
  def events_markers events
    result = []
    events.each do |event|
      result << Marker.new(event.coordinates,:label => event.title, :info_bubble => link_to("<b>" + event.title + "</b>",event_path(event)) + "<br><br>" + l(event.startdate) + "<br>" + h(event.city))
    end
    result
  end
end
