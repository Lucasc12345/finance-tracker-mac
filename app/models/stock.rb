require 'httparty'

class Stock < ApplicationRecord
  has_many :user_stocks
  has_many :users, through: :user_stocks

  validates :name, :ticker, presence: true
  def self.new_lookup(ticker_symbol)
    begin
      response = HTTParty.get("https://finnhub.io/api/v1/quote?symbol=#{ticker_symbol}&token=#{Rails.application.credentials.finnhub_api[:api_key]}")
      if response.code == 200 && (last_price = response.parsed_response['c']).to_f != 0
        name = company_lookup(ticker_symbol)
        name ? new(ticker: ticker_symbol, name: name, last_price: last_price) : nil
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

  private
  def self.company_lookup(ticker_symbol)
    response = HTTParty.get("https://api.polygon.io/vX/reference/financials?ticker=#{ticker_symbol}&limit=1&apiKey=#{Rails.application.credentials.polygon_api[:api_key]}")
    if response.code == 200 && response.parsed_response.dig("results", 0, "company_name")
      response.parsed_response.dig("results", 0, "company_name")
    else
      nil
    end
  end
end



