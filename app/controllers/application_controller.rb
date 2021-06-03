class ApplicationController < ActionController::Base
  protect_from_forgery
  include ActiveModel::Validations
  before_filter :oauth2

  require 'google/api_client'

  def oauth2
    if nil != params[:auth_type]
      $auth_type = params[:auth_type]
    end

    @client = Google::APIClient.new
    @client.authorization.client_id = ENV['GOOGLE_CLIENT_ID']
    @client.authorization.client_secret = ENV['GOOGLED_CLIENT_SECRET']
    @client.authorization.scope = 'https://www.googleapis.com/auth/calendar.readonly'
    @client.authorization.scope << ' https://www.googleapis.com/auth/calendar'
    puts "@auth_type:" + $auth_type
    if ("2" == $auth_type)
      puts "2@auth_type:" + $auth_type.to_s
      @client.authorization.scope << ' https://spreadsheets.google.com/feeds'
      @client.authorization.scope << ' https://docs.google.com/feeds'
      @client.authorization.scope << ' https://www.googleapis.com/auth/drive'
      @client.authorization.scope << ' https://www.googleapis.com/auth/drive.file'
      @client.authorization.scope << ' https://www.googleapis.com/auth/drive.appdata'
      @client.authorization.scope << ' https://www.googleapis.com/auth/drive.scripts'
      @client.authorization.scope << ' https://www.googleapis.com/auth/drive.apps.readonly'
    end

    @client.authorization.redirect_uri = oauth2callback_url
    @client.authorization.code = params[:code] if params[:code]

    @service = @client.discovered_api('calendar', 'v3')

    if session[:token_id]
      # Load the access token here if it's available
      token_pair = TokenPair.find_by_id(session[:token_id])
      if token_pair
        @client.authorization.update_token!(token_pair.to_hash)
      end
    end
    if @client.authorization.refresh_token && @client.authorization.expired?
      @client.authorization.fetch_access_token!
    end
    unless @client.authorization.access_token || request.path_info =~ /^\/oauth2/
      redirect_to oauth2authorize_url
    end
  end
end
