require 'httparty'
class Stock < ApplicationRecord
  def self.new_lookup(ticker_symbol)
    begin
      price = fetch_price(ticker_symbol)
      return 0 if price == 0
      return nil unless price
      name = company_lookup(ticker_symbol)
      return nil unless name
      create_stock(ticker_symbol, name, price)
    rescue => exception
      nil
    end
  end

  private
  def self.fetch_price(ticker_symbol)
    response = HTTParty.get("https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=#{ticker_symbol}&apikey=#{Rails.application.credentials.alpha_vantage[:api_key]}")
    if response.code == 200 && response.parsed_response.dig('Global Quote', '05. price')
      BigDecimal(response.parsed_response['Global Quote']['05. price'])
    elsif response.parsed_response['Information']
      0
    else
      nil
    end
  end
  def self.company_lookup(ticker_symbol)
    response = HTTParty.get("https://www.alphavantage.co/query?function=OVERVIEW&symbol=#{ticker_symbol}&apikey=#{Rails.application.credentials.alpha_vantage[:api_key]}")
    response.parsed_response['Name'] if response.code == 200 && response.parsed_response['Name']
  end
  def self.create_stock(ticker_symbol, name, price)
    new(ticker: ticker_symbol, name: name, last_price: price)
  end
end

