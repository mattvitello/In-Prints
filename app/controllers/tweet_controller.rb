class TweetController < ApplicationController
  require 'json'
  require 'rmagick'
  include Magick


  def random_top

    count = TopItem.count()

    @tweetArray

    k = rand(1..count + 1)

    item = TopItem.all
    @tweets = item[k].tweets
    @tweets = @tweets.split('|ENDTWEET|')
    @tweetArray = Array.new

    i = 0
    @tweets.each do |tweet|
      @tweetArray[i] = tweet.split('|ENDSECTION|')
      @tweetArray[i] = [item[k].name] + @tweetArray[i]


      i = i + 1
    end

    j = 0

    loop do
      j = rand(1..@tweetArray.count())
      break if @tweetArray[j][1] != ''
    end
    respond_to do |format|
      format.html
      format.json{ render json: @tweetArray[j].to_json }
    end

  end

end
