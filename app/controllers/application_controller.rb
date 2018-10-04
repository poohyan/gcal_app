# frozen_string_literal: true

require 'googleauth'
require 'google/apis/calendar_v3'

class ApplicationController < ActionController::Base
  protect_from_forgery
  include ActiveModel::Validations
  before_action :oauth2

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

  def oauth2
    if nil != params[:auth_type]
      auth_type = params[:auth_type]
    end

    client_id = Google::Auth::ClientId.new(
      ENV['GOOGLE_CLIENT_ID'],
      ENV['GOOGLED_CLIENT_SECRET']
    )
    token_store = SqliteTokenStore.new.load(session[:token_id])
    scope = []
    scope << 'https://www.googleapis.com/auth/calendar.readonly'
    scope << ' https://www.googleapis.com/auth/calendar'
    puts "@auth_type:" + auth_type
    if ("2" == auth_type)
      puts "2@auth_type:" + auth_type.to_s
      scope << ' https://spreadsheets.google.com/feeds'
      scope << ' https://docs.google.com/feeds'
      scope << ' https://www.googleapis.com/auth/drive'
      scope << ' https://www.googleapis.com/auth/drive.file'
      scope << ' https://www.googleapis.com/auth/drive.appdata'
      scope << ' https://www.googleapis.com/auth/drive.scripts'
      scope << ' https://www.googleapis.com/auth/drive.apps.readonly'
    end

    authorizer = Google::Auth::UserAuthorizer.new(client_id, scope, token_store)

    user_id = 'default'
    @credentials = authorizer.get_credentials(user_id)
    if @credentials.nil?
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      puts 'Open the following URL in the browser and enter the ' \
         "resulting code after authorization:\n" + url
      code = params[:code] if params[:code]
      @credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
      redirect_to url
    end

    @credentials.code = params[:code] if params[:code]

    if session[:token_id]
      # Load the access token here if it's available
      token_pair = TokenPair.find_by_id(session[:token_id])
      if token_pair
        @credentials.authorization.update_token!(token_pair.to_hash)
      end
    end  
    if @credentials.refresh_token && @credentials.expired?
      @credentials.fetch_access_token!
    end  
    unless @credentials.access_token || request.path_info =~ /^\/oauth2/
      redirect_to @credentials.oauth2authorize_url
    end
  end
end
