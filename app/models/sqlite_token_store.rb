require 'googleauth/token_store'

class SqliteTokenStore < Google::Auth::TokenStore
  def initialize()
    @cache = {}
  end

  def load(id)
    @cache[id] ||= begin
      object(id).access_token
    end
  end

  def store(id, token)
    object(id).access_token = token
    token_pair.save!
    @cache[id] = token
  end

  def delete(id)
    object(id).delete
    @cache.delete(id)
  end

  private
  def object(key)
    TokenPair.find_by_id(key) || TokenPair.new
  end
end