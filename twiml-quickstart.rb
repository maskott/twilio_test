require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

points = 0

get '/hello' do
  people = {
    '+14047180928' => 'Corinne Sarah Scott',
    '+14043755575' => 'Mike Scott with a K',
    '+16786405495' => 'Myron Eli Scott with a K',
  }
  name = people[params['From']] || 'Caller'
  Twilio::TwiML::Response.new do |r|
    r.Say "Ahoy hoy #{name}, Welcome to", voice: 'alice'
    r.Play '/sounds/beep14.mp3'
    r.Say "Twilio Test"
    r.Play '/sounds/beep15.mp3'
    r.Gather :numDigits => '1', :action => '/hello/handle-gather', :method => 'get' do |g|
      g.Say 'To call Mikes cell phone, press 1.', voice: 'alice'
      g.Say 'Press 2 to record your own annoying voice.', voice: 'alice'
      g.Say 'Press 3 to play the Simpsons audio game.', voice: 'alice'
      g.Say 'Press any other key to start over.', voice: 'alice'
    end
  end.text
end

get '/hello/handle-gather' do
  redirect '/hello' unless ['1', '2', '3'].include?(params['Digits'])
  if params['Digits'] == '1'
    response = Twilio::TwiML::Response.new do |r|
      r.Dial '+14043755575'
      r.Say 'Mikes phone is no longer available to you at this time. Goodbye.', voice: 'alice'
      r.Play '/sounds/beep14.mp3'
      r.Say "Twilio Test... out"
      r.Play '/sounds/beep15.mp3'
    end
  elsif params['Digits'] == '2'
    response = Twilio::TwiML::Response.new do |r|
      r.Say 'Record your grating voice after the tone, if you must.', voice: 'alice'
      r.Record :maxLength => '30', :action => '/hello/handle-record', :method => 'get'
    end
  elsif params['Digits'] == '3'
    response = Twilio::TwiML::Response.new do |r|
      r.Play '/sounds/simpsons_intro.mp3'
      r.Say 'Get ready to play the Simpsons audio game!', voice: 'alice'
      r.Play '/sounds/hacker.mp3'
      r.Gather :numDigits => '1', :action => '/hello/simps/1', :method => 'get' do |g|
        g.Say 'To skip these instructions and get straight to the game, press 1 at any time. Press any other number to repeat these instructions.', voice: 'alice'
        g.Say 'In a moment, you will hear an audio clip from the Simpsons. You must try to determine the name of the character that you hear in the clip.', voice: 'alice'
        g.Say 'If you hear more than one character, please respond with the first character you hear in the clip.', voice: 'alice'
        g.Say 'You will enter your response by dialing the first three letters of the characters first name.', voice: 'alice'
        g.Say 'There will be three audio quotes in each game. Good luck!', voice: 'alice'
        g.Say 'Press 1 to begin the game, or any other number to repeat these instructions.', voice: 'alice'
      end
    end
  end
  response.text
end

get '/hello/handle-record' do
  Twilio::TwiML::Response.new do |r|
    r.Say 'Seriously, just listen to what you sound like.', voice: 'alice'
    r.Play params['RecordingUrl']
    r.Say "I can't take any more. I just can't... Goodbye.", voice: 'alice'
    r.Play '/sounds/beep14.mp3'
    r.Say "Twilio Test... out"
    r.Play '/sounds/beep15.mp3'
  end.text
end

get '/hello/simps/1' do
  redirect '/hello' unless ['1'].include?(params['Digits'])
  Twilio::TwiML::Response.new do |r|
    r.Say 'This first question is worth 10 points.', voice: 'alice'
    r.Play '/sounds/02-coin.mp3'
    r.Say 'Round one... begin!', voice: 'alice'
    r.Play '/sounds/english.mp3'
    r.Gather :numDigits => '3', :action => '/hello/simps/2', :method => 'get' do |g|
      g.Say '... Dial the first three letters of the characters first name.', voice: 'alice'
    end
  end.text
end

get '/hello/simps/2' do
  if params['Digits'] == '466'
    points += 10
    response = Twilio::TwiML::Response.new do |r|
      r.Play '/sounds/woohoo.mp3'
      r.Say 'That is correct for 10 points!', voice: 'alice'
      r.Say "You now have a total of #{points.to_s} points.", voice: 'alice'
      r.Play '/sounds/44-coin-2.mp3'
      r.Say 'This next question is worth 20 points.', voice: 'alice'
      r.Say 'Round two... begin!', voice: 'alice'
      r.Play '/sounds/surgery.mp3'
      r.Gather :numDigits => '3', :action => '/hello/simps/3', :method => 'get' do |g|
        g.Say '... Dial the first three letters of the characters first name.', voice: 'alice'
      end
    end
  else
    response = Twilio::TwiML::Response.new do |r|
      r.Play '/sounds/doh.mp3'
      r.Say 'That is incorrect. The correct answer was Homer or 4, 6, 6.', voice: 'alice'
      r.Say 'You have points... May god have mercy upon you.', voice: 'alice'
      r.Play '/sounds/44-coin-2.mp3'
      r.Say 'This next question is worth 20 points.', voice: 'alice'
      r.Say 'Round two... begin!', voice: 'alice'
      r.Play '/sounds/surgery.mp3'
      r.Gather :numDigits => '3', :action => '/hello/simps/3', :method => 'get' do |g|
        g.Say '... Dial the first three letters of the characters first name.', voice: 'alice'
      end
    end
  end
  response.text
end

get '/hello/simps/3' do
  if params['Digits'] == '642'
    points += 20
    response = Twilio::TwiML::Response.new do |r|
      r.Play '/sounds/woohoo.mp3'
      r.Say 'That is correct for 20 points!', voice: 'alice'
      r.Say "You now have a total of #{points.to_s} points.", voice: 'alice'
      r.Play '/sounds/45-coin-3.mp3'
      r.Say 'This next question is worth 30 points.', voice: 'alice'
      r.Say 'Round two... begin!', voice: 'alice'
      r.Play '/sounds/game.mp3'
      r.Gather :numDigits => '3', :action => '/hello/simps/end', :method => 'get' do |g|
        g.Say '... Dial the first three letters of the characters first name.', voice: 'alice'
      end
    end
  else
    response = Twilio::TwiML::Response.new do |r|
      r.Play '/sounds/doh.mp3'
      r.Say 'That is incorrect. The correct answer was Nick or 6, 4, 2.', voice: 'alice'
      r.Say "You now have a total of #{points.to_s} points.", voice: 'alice'
      r.Play '/sounds/45-coin-3.mp3'
      r.Say 'This next question is worth 30 points.', voice: 'alice'
      r.Say 'Round two... begin!', voice: 'alice'
      r.Play '/sounds/game.mp3'
      r.Gather :numDigits => '3', :action => '/hello/simps/end', :method => 'get' do |g|
        g.Say '... Dial the first three letters of the characters first name.', voice: 'alice'
      end
    end
  end
  response.text
end

get '/hello/simps/end' do
  if params['Digits'] == '252'
    points += 30
    response = Twilio::TwiML::Response.new do |r|
      r.Play '/sounds/woohoo.mp3'
      r.Say 'That is correct for 30 points!', voice: 'alice'
      r.Say "You finished the game with a total of #{points.to_s} points.", voice: 'alice'
      r.Play '/sounds/43-game-over.mp3'
      r.Gather :numDigits => '1', :action => '/hello/simps/end-menu', :method => 'get' do |g|
        g.Say 'To play again, press 1 now.', voice: 'alice'
        g.Say 'Press 2 to return to the main menu.', voice: 'alice'
        g.Say 'Press any other key to disconnect.', voice: 'alice'
      end
    end
  end
  response.text
end
