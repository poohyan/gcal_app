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

    if @client
      @client.revokeToken;
    end
    TokenPair.find_by_id(session[:token_id]).delete

    redirect_to('/')

    end
end
