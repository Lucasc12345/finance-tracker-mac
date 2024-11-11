require 'httparty'

class Stock < ApplicationRecord
  has_many :user_stocks
  has_many :users, through: :user_stocks

  validates :name, :ticker, presence: true
  def self.new_lookup(ticker_symbol)
    begin
      response = HTTParty.get("https://financialmodelingprep.com/api/v3/quote/#{ticker_symbol}?apikey=#{Rails.application.credentials.fmp_api[:api_key]}")
      if response.code == 200
        name = response.parsed_response[0]['name']
        price = response.parsed_response[0]['price']
        new(ticker: ticker_symbol, name: name, last_price: price)
      else
        nil
      end
    rescue => exception
      nil
    end
  end
  def self.check_db(ticker_symbol)
    where(ticker: ticker_symbol).first
  end
end



