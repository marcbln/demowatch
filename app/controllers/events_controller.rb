class EventsController < ApplicationController


  before_filter :login_required, :except => [:index, :show, :archive, :maps_on, :maps_off]
  before_filter :find_event, :only => [:show, :edit, :update, :destroy]
  allow :edit, :update, :destroy, :user => [:owns?, :is_admin?]
  
  skip_before_filter :verify_authenticity_token, :only => 'auto_complete_for_tag_name'

  def auto_complete_for_tag_name
    @tags = Tag.find(:all, :conditions => [ 'LOWER(name) LIKE ?', params[:event][:tag_list] + '%' ])
    render :inline => "<%= auto_complete_result(@tags, 'name') %>"
  end
  
  # GET /events
  # GET /events.xml
  def index
    @tags = params[:tags] 
    @with_distance = !current_user.nil? && !current_user.zip.nil?
    options = {:order => 'startdate ASC', :conditions => "startdate > '#{1.day.ago.to_formatted_s(:db)}'"}
    if @with_distance	  
      options[:origin] = GeoKit::LatLng.new(current_user.zip.latitude, current_user.zip.longitude)
      # options[:within] = distance_in_km # Fuer umkreissuche
      @zip = current_user.zip.zip
    end
    options = Event.find_options_for_find_tagged_with(@tags, options) if @tags
    
    respond_to do |format|
      format.html { @events = Event.all(options) }
      format.xml  { render :xml => Event.all(options) }
      format.rss  { @events = Event.all(options); render :layout => false }
      format.ics  { render :inline => ical(Event.all(options)) }
    end
  end
  
  def archive
    @tags = params[:tags] 
    @with_distance = !current_user.nil? && !current_user.zip.nil?
    options = {:order => 'startdate DESC', :conditions => "startdate < '#{1.day.ago.to_formatted_s(:db)}'"}
    if @with_distance   
      options[:origin] = GeoKit::LatLng.new(current_user.zip.latitude, current_user.zip.longitude)
      # options[:within] = distance_in_km # Fuer umkreissuche
      @zip = current_user.zip.zip
    end
    options = Event.find_options_for_find_tagged_with(@tags, options) if @tags
    
    respond_to do |format|
      format.html { @events = Event.all(options) }
      format.xml  { render :xml => Event.all(options) }
      format.rss  { @events = Event.all(options); render :layout => false }
      format.ics  { render :inline => ical(Event.all(options)) }
    end
  end  
  
  # GET /events/1
  # GET /events/1.xml
  def show
    # 301 falls nicht die richtige url ...
    # urls sind verschieden fuer versch. sprachen aber selben event
    if params[:id] != @event.to_param
      redirect_to event_url( @event), :status=>:moved_permanently
      return
    end
      
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
      format.ics  { render :inline => ical([@event]) }




# (opt.) parameter fuer marker_init:
#        :info_bubble => render_to_string(:partial => 'bubble')
#        :label => ''CGI.escapeHTML( @event.title), 
#        :icon => "/img/marker.png"
      if cookies[:google_maps]
        @map = Mapstraction.new("map_div",:google)
        @map.center_zoom_init([@event.latitude, @event.longitude],15)
        @map.control_init(:small => true)
        @map.marker_init(Marker.new([@event.latitude, @event.longitude]))
      end
      if cookies[:yahoo_maps]
        @map = Mapstraction.new("map_div",:yahoo)
        @map.center_zoom_init([@event.latitude, @event.longitude],15)
        @map.control_init(:small => true)
        @map.marker_init(Marker.new([@event.latitude, @event.longitude]))
      end
      if cookies[:openlayers_maps]
        @map = Mapstraction.new("map_div",:openlayers)
        @map.center_zoom_init([@event.latitude, @event.longitude],15)
        @map.control_init(:small => true)
        @map.marker_init(Marker.new([@event.latitude, @event.longitude]))
      end
#@map.polyline_init( 
#  Polyline.new(
#    [
#      LatLonPoint.new([@event.latitude, @event.longitude]), 
#      LatLonPoint.new([@event.latitude, @event.longitude+0.02])
#    ]
#  )
#)
      
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new(:startdate => Time.now, :event_type_id => Event::DemoEvent)
    @organisations = Organisation.find(:all, :order => 'title')
# two letter codes
@languages = I18N_ALL_LANGUAGES

    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    @organisations = Organisation.find(:all, :order => 'title')
    @event.event_translations.collect
    
    @languages = []
    @event.event_translations.each do |tr|
      @languages.push tr.locale
    end
    @current_language = @languages.first
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])
    @event.user = current_user
    respond_to do |format|
      if @event.save
        flash[:notice] = t("events.flash.create.success")
        format.html { redirect_to(@event) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        @organisations = Organisation.find(:all, :order => 'title')
# two letter codes
@languages = I18N_ALL_LANGUAGES         
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    respond_to do |format|
      if @event.update_attributes(params[:event])
        flash[:notice] = t("events.flash.update.success")
        format.html { redirect_to(@event) }
        format.xml  { head :ok }
      else
    @languages = []
    @event.event_translations.each do |tr|
      @languages.push tr.locale
    end
@current_language = params[:current_language]
        @organisations = Organisation.find(:all, :order => 'title')
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
  end
  
  def add_comment
    respond_to do |format|
      @event = Event.find(params[:comment][:commentable_id])
      c = Comment.create(params[:comment])
      if c.update_attributes(params[:comment])
        @event.comments << c
        CommentMailer::deliver_mail(current_user, @event, c)
        flash[:notice] = t("events.flash.add_comment.success")
        format.html { redirect_to(@event) }
        format.xml  { head :ok }
      else
        format.html { redirect_to(@event) }
        format.xml  { render :xml => c.errors, :status => :unprocessable_entity }
      end
            
    end
  end

  def delete_comment
    respond_to do |format|
      @event = Event.find(params[:id])
      Comment.delete params[:comment_id]

      flash[:notice] = t("events.flash.delete_comment.success")

      format.html { redirect_to(@event) }
      format.xml  { head :ok }
    end
  end
  
  def maps_on
    respond_to do |format|
      @event = Event.find(params[:id])
      delete_maps_cookies()
      cookies[params[:type] + '_maps'] = { :value => true, :expires => 10.years.from_now }
      format.html { redirect_to(@event) }
    end
  end
  
  def maps_off
    respond_to do |format|
      delete_maps_cookies()
      @event = Event.find(params[:id])
      format.html { redirect_to(@event) }
    end
  end
  
protected
  def find_event
    @event = Event.find(params[:id])
  end

  def delete_maps_cookies
    map_suppliers = %w{google yahoo openlayers}
    map_suppliers.each do |supplier|
      cookies.delete( supplier + '_maps')
    end
  end
  
  def ical events
    cal = Vpim::Icalendar.create2
    
    events.each do |event|
      cal.add_event do |e|
        e.dtstart       event.startdate
        e.dtend         event.enddate || event.startdate + 4.hours
        e.summary       event.title
        e.description   event.description.gsub(/<[^>]+>|/m, '').to_a.join(' ').gsub(/\s+/, ' ')
        e.categories    event.tags.map{|t| t.name}
        e.url           event.link || ''
        e.transparency  'OPAQUE'
        e.sequence      0
        e.created       event.created_at
        e.lastmod       event.updated_at
        
    #    e.organizer do |o|
    #      o.cn = event.organisation.title
    #      o.uri = event.organisation.link
    #    end
      end
    end
    
    cal.encode
  end  
end
