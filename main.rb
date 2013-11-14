require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

get '/' do
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
  erb :game
  # initiate deck
  session[:deck] = []
  ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'].each do |value|
    ['Hearts', 'Spades', 'Clubs', 'Diamonds'].each do |suit|
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

  # show flop


  # player turn


  # dealer turn


  # who won?




  binding.pry
end

get '/game_over' do

end