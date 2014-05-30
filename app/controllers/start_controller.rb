class StartController < ApplicationController

  require 'net/http'
  require 'uri'

skip_filter :oauth2

  def index
    @auth_type = ""
  	# tokenのクリーニング
    if Rails.env == 'development'
      TokenPair.delete_all("datetime(expires_in + issued_at)  < datetime('now', 'utc')")
  	else
      TokenPair.delete_all("expires_in + issued_at  < date_part('epoch',CURRENT_TIMESTAMP) ")
    end
  end

  def signout

    token_pair = TokenPair.find_by_id(session[:token_id]).access_token
    url = 'https://accounts.google.com/o/oauth2/revoke?token=' + token_pair

    puts "access_token:" + token_pair
    puts url

    response = Net::HTTP.get_print URI.parse(url)
    puts response

    TokenPair.find_by_id(session[:token_id]).delete

    redirect_to('/')

    end
end
