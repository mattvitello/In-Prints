class HomeController < ApplicationController
  require 'twitter'
  require 'json'
  require 'rmagick'
  include Magick


#twitter api keys
  def index
    client = Twitter::REST::Client.new do |config|
      config.consumer_key = '**'
      config.consumer_secret = '**'
      config.access_token = '**'
      config.access_token_secret = '**'
    end




###########################################################################################
#adding items to 'new_items' & 'top_items' databases
#this entire code section will need to be moved to tasks so that it isn't called every time the page is loaded but rather on a timer (cron-job)

#depreciate trends in top_items db based on their creation date
    TopItem.where('created_at < ?', 10.days.ago).each do |trend|
      trend.destroy
    end

    NewItem.delete_all                                              #clear everything in new table
    ActiveRecord::Base.connection.reset_pk_sequence!('new_items')   #reset id's

    #TopItem.delete_all                                              #clear everything in top table
    #ActiveRecord::Base.connection.reset_pk_sequence!('top_items')   #reset id's

    response = client.trends(id=23424977)   #USA Location ID

    i = 0
    response.each do |trend|              #loop through elements in table
      name = trend['name']
      tweets = client.search(q= name, count: 15, result_type: 'popular')
      statuses = ''

      tweets.each do |tweet|
        statuses = statuses + tweet['text'].to_s
        statuses = statuses + '|ENDSECTION|'
        statuses = statuses + tweet['user']['name'].to_s
        statuses = statuses + '|ENDSECTION|'
        statuses = statuses + tweet['user']['screen_name'].to_s
        statuses = statuses + '|ENDSECTION|'
        statuses = statuses + tweet['user']['profile_image_url'].to_s
        statuses = statuses + '|ENDSECTION|'
        statuses = statuses + tweet['retweet_count'].to_s
        statuses = statuses + '|ENDSECTION|'
        statuses = statuses + tweet['favorite_count'].to_s
        statuses = statuses + '|ENDSECTION|'
        statuses = statuses + tweet['created_at'].to_s

        # statuses = statuses + '|ENDSECTION|'
        # statuses = statuses + tweet['entities']['media']['type'].to_s
        # statuses = statuses + '|ENDSECTION|'
        # statuses = statuses + tweet['entities']['media']['media_url'].to_s


        statuses = statuses + '|ENDTWEET|'
      end

      volume = trend['tweet_volume']
      if (volume.nil?)                      #set volume to 0 if it is nil i.e. < 10000
          volume = 0
      end

      #add 30 items to new db
      if (i < 30)
        #add new trends to db
        newTrend = NewItem.new
        newTrend.name = name
        newTrend.volume = volume
        newTrend.tweets = statuses
        if (name.include? "#")
          parsedName = name.tr('#', '').downcase
          parsedName = `python text-split.py #{parsedName.to_s}`
          if (parsedName.valid_encoding?)
            newTrend.parsedname = parsedName.to_s
          else
            newTrend.parsedname = name.tr('#', '').to_s
          end
        else
          newTrend.parsedname = name
        end

        #create pngs of shirts
        folder = newTrend.name.to_s
        if (folder.include? "#")
          folder = folder.tr('#', '').to_s
        end

        if File.exists?("public/images/#{folder}")
        else
          FileUtils.mkpath("public/images/#{folder}/shirts")
          FileUtils.mkpath("public/images/#{folder}/crewnecks")
          FileUtils.mkpath("public/images/#{folder}/hoodies")

          #split apart text with new lines if it can't fit as is on shirt
          width = 480
          text = newTrend.parsedname.upcase
          separator = ' '
          line = ''
          if not text_fit?(text, width) and text.include? separator
            i = 0
            text.split(separator).each do |word|
              if i == 0
                tmp_line = line + word
              else
                tmp_line = line + separator + word
              end

              if text_fit?(tmp_line, width)
                unless i == 0
                  line += separator
                end
                line += word
              else
                unless i == 0
                  line +=  '\n'
                end
                line += word
              end
              i += 1
            end
            text = line
          end

          # create images
          tees(folder, text)
          crewnecks(folder, text)
          hoodies(folder, text)

        end

        newTrend.save
      end
      i = i + 1;

      #add trends to top_trends db
      updateItem = TopItem.find_by(name: name)
      if (!(updateItem.nil?))                     #if trend is already in top list, update its volume
        updateItem.update(volume: volume)
      else
        if (TopItem.all.size < 30)                #fill any empty spots in db (set to 30 max)
          topTrend = TopItem.new
          topTrend.name = name
          topTrend.volume = volume
          topTrend.tweets = statuses

          if (name.include? "#")
            parsedName = name.tr('#', '').downcase
            parsedName = `python text-split.py #{parsedName.to_s}`
            if (parsedName.valid_encoding?)
              topTrend.parsedname = parsedName.to_s
            else
              topTrend.parsedname = name.tr('#', '').to_s
            end
          else
            topTrend.parsedname = name
          end

          #create pngs of shirts
          folder = topTrend.name.to_s
          if (folder.include? "#")
            folder = folder.tr('#', '').to_s
          end

          if File.exists?("public/images/#{folder}")
          else
            FileUtils.mkpath("public/images/#{folder}/shirts")

            #split apart text with new lines if it can't fit as is on shirt
            width = 480
            text = topTrend.parsedname.upcase

            separator = ' '
            line = ''
            if not text_fit?(text, width) and text.include? separator
              i = 0
              text.split(separator).each do |word|
                if i == 0
                  tmp_line = line + word
                else
                  tmp_line = line + separator + word
                end

                if text_fit?(tmp_line, width)
                  unless i == 0
                    line += separator
                  end
                  line += word
                else
                  unless i == 0
                    line +=  '\n'
                  end
                  line += word
                end
                i += 1
              end
              text = line
            end

            # create images
            tees(folder, text)
            crewnecks(folder, text)
            hoodies(folder, text)

          end

          topTrend.save

        else
          item = TopItem.all.order(:volume)       #if volume is greater than smallest volume in db, replace that item
          if (volume > item[0].volume)
              item[0].destroy
              topTrend = TopItem.new
              topTrend.name = name
              topTrend.volume = volume
              topTrend.tweets = statuses

              if (name.include? "#")
                parsedName = name.tr('#', '').downcase
                parsedName = `python text-split.py #{parsedName.to_s}`
                if (parsedName.valid_encoding?)
                  topTrend.parsedname = parsedName.to_s
                else
                  topTrend.parsedname = name.tr('#', '').to_s
                end
              else
                topTrend.parsedname = name
              end

              #create pngs of shirts
              folder = topTrend.name.to_s
              if (folder.include? "#")
                folder = folder.tr('#', '').to_s
              end
              if File.exists?("public/images/#{folder}")
              else
                FileUtils.mkpath("public/images/#{folder}/shirts")

                #split apart text with new lines if it can't fit as is on shirt
                width = 480
                text = topTrend.parsedname.upcase

                separator = ' '
                line = ''
                if not text_fit?(text, width) and text.include? separator
                  i = 0
                  text.split(separator).each do |word|
                    if i == 0
                      tmp_line = line + word
                    else
                      tmp_line = line + separator + word
                    end

                    if text_fit?(tmp_line, width)
                      unless i == 0
                        line += separator
                      end
                      line += word
                    else
                      unless i == 0
                        line +=  '\n'
                      end
                      line += word
                    end
                    i += 1
                  end
                  text = line
                end

                # create images
                tees(folder, text)
                crewnecks(folder, text)
                hoodies(folder, text)
              end

              topTrend.save
          end
        end
      end
    end

    ################## Not needed for cron job, but needed to make random shirts##########################

    @hotname = String.new
    @newname = String.new
    @topname = String.new

    newcount = NewItem.count()
    topcount = TopItem.count()
    hotcount = topcount

    newi = rand(1...newcount)
    topi = rand(1...topcount)
    hoti = rand(1...hotcount)

    newitem = NewItem.all
    @newname = newitem[newi].name.tr('#', '').to_s

    count = 0

    loop do
      count += 1
      topitem = TopItem.all
      @topname = topitem[topi].name.tr('#', '').to_s
      break if @topname != @newname or count = 10
    end

    count = 0

    loop do
      count += 1
      hotitem = TopItem.all
      @hotname = hotitem[hoti].name.tr('#', '').to_s
      break if (@hotname != @newname and @hotname != @topname) or count = 10
    end

    ##############################################################################################

  end

  def text_fit?(text, width)
    tmp_image = Image.new(width, 500)
    drawing = Draw.new
    drawing.annotate(tmp_image, 0, 0, 0, 0, text) { |txt|
      txt.font_family = 'Helvetica Neue'
      txt.gravity = Magick::NorthGravity
      txt.pointsize = 67
      #txt.stroke = 'rgba(255,255,255,0.1)'
      txt.fill = 'rgba(255,255,255,0.83)'
      txt.font_weight = 300
    }
    metrics = drawing.get_multiline_type_metrics(tmp_image, text)
    (metrics.width < width)
  end

  def tees(folder, text)
    img = ImageList.new('app/assets/images/shop/shirts/white_tee.png')
    txt = Draw.new
    img.annotate(txt, 0,0,0,300, text){
      txt.font_family = 'Helvetica Neue'
      txt.gravity = Magick::NorthGravity
      txt.pointsize = 67
      #txt.stroke = 'rgba(0,255,255,0.1)'
      txt.fill = 'rgba(0,0,0,0.83)'
      txt.font_weight = 300
    }
    img.format = 'png'
    img.write("public/images/#{folder}/shirts/w1.png")

    #make black tee image
    img = ImageList.new('app/assets/images/shop/shirts/black_tee.png')
    txt = Draw.new
    img.annotate(txt, 0,0,0,300, text){
      txt.font_family = 'Helvetica Neue'
      txt.gravity = Magick::NorthGravity
      txt.pointsize = 67
      #txt.stroke = 'rgba(0,255,255,0.1)'
      txt.fill = 'rgba(255,255,255,0.83)'
      txt.font_weight = 300
    }
    img.format = 'png'
    img.write("public/images/#{folder}/shirts/b1.png")

    #make grey tee image
    img = ImageList.new('app/assets/images/shop/shirts/athletic_heather_tee.png')
    txt = Draw.new
    img.annotate(txt, 0,0,0,300, text){
      txt.font_family = 'Helvetica Neue'
      txt.gravity = Magick::NorthGravity
      txt.pointsize = 67
      #txt.stroke = 'rgba(0,255,255,0.1)'
      txt.fill = 'rgba(0,0,0,0.83)'
      txt.font_weight = 300
    }
    img.format = 'png'
    img.write("public/images/#{folder}/shirts/g1.png")
  end

  def crewnecks(folder, text)
    img = ImageList.new('app/assets/images/shop/sweatshirts/crewnecks/white_crew.png')
    txt = Draw.new
    img.annotate(txt, 0,0,-14,280, text){
      txt.font_family = 'Helvetica Neue'
      txt.gravity = Magick::NorthGravity
      txt.pointsize = 67
      #txt.stroke = 'rgba(255,255,255,0.1)'
      txt.fill = 'rgba(0,0,0,0.83)'
      txt.font_weight = 200
    }

    img.format = 'png'
    img.write("public/images/#{folder}/crewnecks/w1.png")

    img = ImageList.new('app/assets/images/shop/sweatshirts/crewnecks/black_crew.png')
    txt = Draw.new
    img.annotate(txt, 0,0,-14,280, text){
      txt.font_family = 'Helvetica Neue'
      txt.gravity = Magick::NorthGravity
      txt.pointsize = 67
      #txt.stroke = 'rgba(255,255,255,0.1)'
      txt.fill = 'rgba(255,255,255,0.83)'
      txt.font_weight = 200
    }

    img.format = 'png'
    img.write("public/images/#{folder}/crewnecks/b1.png")

    img = ImageList.new('app/assets/images/shop/sweatshirts/crewnecks/sport_grey_crew.png')
    txt = Draw.new
    img.annotate(txt, 0,0,-14,280, text){
      txt.font_family = 'Helvetica Neue'
      txt.gravity = Magick::NorthGravity
      txt.pointsize = 67
      #txt.stroke = 'rgba(255,255,255,0.1)'
      txt.fill = 'rgba(0,0,0,0.83)'
      txt.font_weight = 200
    }

    img.format = 'png'
    img.write("public/images/#{folder}/crewnecks/g1.png")
  end

  def hoodies(folder, text)
    img = ImageList.new('app/assets/images/shop/sweatshirts/hoodie/white_hoodie.png')
    txt = Draw.new
    img.annotate(txt, 0,0,0,255, text){
      txt.font_family = 'Helvetica Neue'
      txt.gravity = Magick::NorthGravity
      txt.pointsize = 45
      #txt.stroke = 'rgba(255,255,255,0.1)'
      txt.fill = 'rgba(0,0,0,0.83)'
      txt.font_weight = 200
    }

    img.format = 'png'
    img.write("public/images/#{folder}/hoodies/w1.png")

    img = ImageList.new('app/assets/images/shop/sweatshirts/hoodie/black_hoodie.png')
    txt = Draw.new
    img.annotate(txt, 0,0,0,255, text){
      txt.font_family = 'Helvetica Neue'
      txt.gravity = Magick::NorthGravity
      txt.pointsize = 45
      #txt.stroke = 'rgba(255,255,255,0.1)'
      txt.fill = 'rgba(255,255,255,0.83)'
      txt.font_weight = 200
    }

    img.format = 'png'
    img.write("public/images/#{folder}/hoodies/b1.png")

    img = ImageList.new('app/assets/images/shop/sweatshirts/hoodie/sport_grey_hoodie.png')
    txt = Draw.new
    img.annotate(txt, 0,0,0,255, text){
      txt.font_family = 'Helvetica Neue'
      txt.gravity = Magick::NorthGravity
      txt.pointsize = 45
      #txt.stroke = 'rgba(255,255,255,0.1)'
      txt.fill = 'rgba(0,0,0,0.83)'
      txt.font_weight = 200
    }

    img.format = 'png'
    img.write("public/images/#{folder}/hoodies/g1.png")
   end

end
