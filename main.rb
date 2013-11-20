require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

BLACKJACK_AMT = 21
DEALER_HIT_MIN = 17

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
      break if total <= BLACKJACK_AMT
      total -= 10
    end

    total
  end

  def card_image(card) # ['S', '2']
    suit = case card[0]
      when 'S' then 'spades'
      when 'C' then 'clubs'
      when 'D' then 'diamonds'
      when 'H' then 'hearts'
    end

    value = card[1]
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end

    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
  end

  def winner!(msg)
    @success = "<strong>#{session[:player_name]} wins!</strong> #{msg}"
    @hit_stay_buttons = false
    @play_again = true
    session[:player_money] += session[:player_bet]
  end

  def loser!(msg)
    @error = "<strong>#{session[:player_name]} loses!</strong> #{msg}"
    @hit_stay_buttons = false
    @play_again = true
    session[:player_money] -= session[:player_bet]
  end

  def tie!(msg)
    @success = "<strong>It's a tie!</strong> #{msg}"
    @play_again = true
    session[:player_bet]
  end

  def difference(player_money, player_bet)
    player_money - player_bet
  end
end

# things in before block run before every single action
before do
  @hit_stay_buttons = true
  @bet_set = false
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
  if params[:player_name].empty?
    @error = "Name field cannot be blank. Please enter your name"
    halt erb(:game_start)
  end

  session[:player_name] = params[:player_name]
  session[:player_money] = 1_000

  redirect '/bet'
end

get '/bet' do
  session[:player_bet] = nil
  erb :bet
end

post '/bet' do
  if params[:player_bet].to_i == 0 || params[:player_bet].nil?
    @error = 'Make a bet'
    halt erb(:bet)
  elsif params[:player_bet].to_i > session[:player_money]
    @error = 'You do not have enough funds to make this bet (#{session[:player_money]})'
  else
    session[:player_bet] = params[:player_bet].to_i
  end 
  
  redirect '/game'
end

get '/game' do
  
  session[:turn] = session[:player_name]
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
end

post '/game/player/hit' do
  session[:player_hand] << session[:deck].pop
  player_total = calculate_cards(session[:player_hand])

  if player_total == BLACKJACK_AMT
    winner!("You hit blackjack!")
  elsif player_total > BLACKJACK_AMT
    loser!("You busted!")
  end

  erb :game, layout: false
end

post '/game/player/stay' do
  @success = "#{session[:player_name]}, you have chosen to stay"
  @hit_stay_buttons = false
  redirect '/game/dealer'
end

get '/game/dealer' do

  session[:turn] = "dealer"
  @hit_stay_buttons = false

  session[:dealer_first] = session[:dealer_hand].last

  dealer_total = calculate_cards(session[:dealer_hand])

  if dealer_total == BLACKJACK_AMT
    loser!("Dealer hit Blackjack")
  elsif dealer_total > BLACKJACK_AMT
    winner!("Dealer busted at #{dealer_total}")   
  elsif dealer_total >= DEALER_HIT_MIN
    redirect '/game/compare_hands'
  else
    @dealer_hit_button = true
  end

  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_hand] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare_hands' do
  @hit_stay_buttons = false

  player_total = calculate_cards(session[:player_hand])
  dealer_total = calculate_cards(session[:dealer_hand])

  if player_total > dealer_total
    winner!("#{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}, you gained #{session[:player_bet]}")
  elsif player_total < dealer_total
    loser!("#{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}, you lost #{session[:player_bet]}")
  else
    tie!("#{session[:player_name]} and the dealer stayed at #{player_total}, you still have #{session[:player_money]}")
  end

  erb :game
end

get '/game_over' do
  erb :game_over
end

















