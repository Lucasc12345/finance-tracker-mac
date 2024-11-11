class StocksController < ApplicationController
  def search
    if params[:stock].present?
      @stock = Stock.new_lookup(params[:stock])
      if @stock
        respond_to do |format|
          format.js { render partial: 'users/result' }
        end
      else
        respond_to do |format|
          flash.now[:alert] = "Please enter a valid symbol to search"
          format.js { render partial: 'users/result' }
        end
      end
    else
      respond_to do |format|
        flash.now[:alert] = "Please enter a symbol to search"
        format.js { render partial: 'users/result' }
      end
    end
  end
  def refresh_stocks
    user = User.find(params[:user])
    stocks = user.stocks
    failed_updates = []
    stocks.each do |stock|
      stock_new = Stock.new_lookup(stock.ticker)
      if stock_new
        stock.update(last_price: stock_new.last_price)
      else
        failed_updates << stock.ticker
      end
    end
    if failed_updates.any?
      flash[:alert] = "Le seguenti azioni non sono state aggiornate: #{failed_updates.join(', ')}"
    elsif stocks.none?
      flash[:alert] = "Non c'è nulla da aggiornare"
    else
      flash[:notice] = "Tutte le azioni sono state aggiornate con successo."
    end
    if request.referer == user_url(user)
      redirect_to user_path(user)
    elsif request.referer == my_portfolio_url
      redirect_to my_portfolio_path
    end
  end
  def refresh_stock
    user = User.find(params[:user])
    stock = Stock.find(params[:stock])
    stock_new = Stock.new_lookup(stock.ticker)
    if stock_new
      stock.update(last_price: stock_new.last_price)
      flash[:notice] = "L'azione è stata correttamente aggiornata"
    else
      flash[:alert] = "L'azione selezionata non è stata aggiornata"
    end
    if request.referer == user_url(user)
      redirect_to user_path(user)
    elsif request.referer == my_portfolio_url
      redirect_to my_portfolio_path
    end
  end
end