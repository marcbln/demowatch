module EventsHelper
  def event_owner_class
    ((current_user.owns? @event) ? "owner":"admin")
  end
  
  def event_comment_owner_class( id ) 
    ((current_user.owns? @event.comments.find(id)) ? "owner":"admin")
  end
  
  def startdate_thisyear event
    if event.startdate.to_date == Time.now.to_date
      "<div class='today'>" + t("datetime.distance_in_words.today") + "</div>"
    elsif event.startdate.to_date == Time.now.to_date - 1
      "<div class='yesterday'>" + t("datetime.distance_in_words.yesterday") + "</div>"
    elsif event.startdate.to_date == Time.now.to_date + 1
      "<div class='tomorrow'>" + t("datetime.distance_in_words.tomorrow") + "</div>"
    elsif event.startdate <= Time.now && event.startdate > 6.hours.ago
      "<div class='now'>" + t("datetime.distance_in_words.now") + "</div>"
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
    result = []
    events.reverse.each_with_index do |event, index|
      if index == 0 || event.startdate.to_date.year != @events[-index].startdate.to_date.year
        result << event.startdate.to_date.year
      end
    end
    result
  end

  def index_with_month events
    result = []
    events.each_with_index do |event, index|
      if index == 0 || event.startdate.to_date.month != events[index-1].startdate.to_date.month
        result << l(event.startdate.to_date,:format=>"%B" + ((event.startdate.to_date.year != Time.now.year) ? " %Y" : ""))
      end
    end
    result
  end
  
  def index_with_literals organisations
    result = []
    organisations.each_with_index do |organisation, index|
      if index == 0 || organisation.title.upcase[0] != @organisations[index-1].title.upcase[0]
        result << organisation.title.upcase.split(//).first.tr('äöü','ÄÖÜ')
      end
    end
    result
  end
  
end
