require 'httparty'

class Stock < ApplicationRecord
  def self.company_lookup(ticker_symbol)
    response = HTTParty.get("https://www.alphavantage.co/query?function=OVERVIEW&symbol=#{ticker_symbol}&apikey=#{Rails.application.credentials.alpha_vantage[:api_key]}")
    if response.code == 200
      response.parsed_response['Name']
    else
      nil
    end
  end

  def self.new_lookup(ticker_symbol)
    begin
      response = HTTParty.get("https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=#{ticker_symbol}&apikey=#{Rails.application.credentials.alpha_vantage[:api_key]}")
      if response.code == 200 && response.parsed_response['Global Quote']
        last_price = response.parsed_response['Global Quote']['05. price']
        name = company_lookup(ticker_symbol)
        new(ticker: ticker_symbol, name: name, last_price: last_price)
      else
        nil
      end
    rescue => exception
      nil
    end
  end
end
