require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

# methods/things defined in helpers are availible to all main.rb
helpers do
  def calculate_cards(cards) # cards is nested array
    # calculate_cards(session[:dealer_hand]) => 20
    array = cards.map { |x| x[1] }

    total = 0
    array.each do |card|
      if card == 'A'
        total += 11
      elsif card.to_i == 0
        total += 10
      else
        total += card.to_i
      end
    end

    # needs ace part of formula
    array.select { |x| x == 'A'}.count.times do
      break if total <= 21
      total -= 10
    end

    total
  end
end

# things in before block run before every single action
before do
  @show_buttons = true
end


get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/game_start'
  end
end

get '/game_start' do
  erb :game_start
end

post '/game_start' do
  session[:player_name] = params[:player_name]
  erb :bet
end

post '/bet' do
  session[:loot] = 500
  session[:current_bet] = params[:current_bet]
  redirect '/game'
end

get '/game' do
  # initiate deck
  session[:deck] = []
  ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'].each do |value|
    ['H', 'S', 'C', 'D'].each do |suit|
      session[:deck] << [suit, value]
    end
  end
  session[:deck].shuffle!

  # initiate player/dealer hand
  session[:player_hand] = []
  session[:dealer_hand] = []

  # deal cards
  session[:player_hand] << session[:deck].pop
  session[:dealer_hand] << session[:deck].pop
  session[:player_hand] << session[:deck].pop
  session[:dealer_hand] << session[:deck].pop

  erb :game
  # show flop
  # player turn
  # dealer turn
  # who won?
end

post '/game/player/hit' do
  session[:player_hand] << session[:deck].pop
  if calculate_cards(session[:player_hand]) > 21
    @error = "Sorry, you busted."
    @show_buttons = false
  end
  erb :game
end

post '/game/player/stay' do
  @success = "You've chosen to stay"
  @show_buttons = false
  erb :game
end
























get '/game_over' do

end

















