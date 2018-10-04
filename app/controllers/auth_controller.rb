class AuthController < ApplicationController     
         
  def oauth2authorize        
    redirect_to @credentials.authorization_uri.to_s
  end    
         
  def oauth2callback


    begin

      @credentials.fetch_access_token!

      # Persist the token here 
      token_pair =   
        if session[:token_id]  
          TokenPair.find_by_id(session[:token_id])  || TokenPair.new     
        else         
          TokenPair.new        
        end
      token_pair.update_token!(@credentials.authorization)
      p @credentials
      session[:token_id] = token_pair.id
      # redirect_to '/calender/callist'
      redirect_to "/calendar/index"
    rescue Exception => e
      puts e.message
      redirect_to '/401.html'
        
    end
  end    
         
  def result

    result = @credentials.execute(:uri => 'https://www.googleapis.com/oauth2/v1/userinfo')
    response = result.response.to_s
    # render :json => {:token_id => session[:token_id], :response => response}   
    redirect_to "/calendar/index"
  end    
end