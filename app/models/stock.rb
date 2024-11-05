require 'httparty'

class Stock < ApplicationRecord
  def self.new_lookup(ticker_symbol)
    response = HTTParty.get("https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=#{ticker_symbol}&apikey=#{Rails.application.credentials.alpha_vantage[:api_key]}&format=json")
    if response.code == 200 && response.parsed_response['Global Quote']
      response.parsed_response['Global Quote']['05. price'].to_f
    else
      nil
    end
  end
end
