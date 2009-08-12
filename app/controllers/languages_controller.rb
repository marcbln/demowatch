class LanguagesController < ApplicationController
  # die sprache in einem cookie abzulegene ist nur zum lokalen testen
  # auf produktivsystem wird die subdomain verwendet
  def switch
    cookies[:language] = { :value => params[:language], :expires => 10.years.from_now }
    redirect_to '/'
  end
end
