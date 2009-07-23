{
  :en => {
  
    :date => {
      :formats => {
        :default => "%m/%e/%Y",
        :short => "%e. %b",
        :long => "%e. %B %Y",
        :day_abbr => "%a",
        :month_abbr => "%b"
      },
        
      :day_names => %w{Sunday Monday Tuesday Wednesday Thursday Friday Saturday},
      :abbr_day_names => %w{So Mo Tue Wed Thu Fr Sa},
      :month_names => %w{~ January February March April May June July August September October November December},
      :abbr_month_names => %w{~ Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec},
      :order => [ :day,  :month,  :year]
    },
  
    :time => {
      :am => "",
      :pm => "",
      :formats => {
        :default => "%d.%m.%Y %H:%M",
        :time => "%H:%M h",
        :day_month => "%m/%d",
        :day_month_year => "%m/%d/%Y",
        :day_abbr => "%a",
        :month_abbr => "%b",
        :short => "%e.%m. %H:%M",
        :long => "%A, %e. %B %Y, %H:%M",      
        :long_verbal => "%A, %B %d %Y at %H:%M h",
        :nice => lambda do |time|
          now = Time.now
          if time.to_date == now.to_date
            "%H:%M"
          elsif time.to_date.eql?(now.to_date - 1)
            "Yesterday"
          elsif time.year == now.year
            "%d.%b."
          else
            "%d.%m.%Y"
          end
        end
      }
    }
  } 
}
