class NewController < ApplicationController
  def new
    @names = Array.new
    @id = Array.new
    @parsedName = Array.new
    @folderNames = Array.new


    i = 0
    trends = NewItem.all   #query latest trends
    trends.each do |trend|
      @names[i] = trend.name.to_s
      @folderNames[i] = trend.name.to_s
      temp = trend.name.to_s
      if (temp.include? "#")
        @folderNames[i] = @names[i].tr('#', '').to_s
      end
      @parsedName[i] = trend.parsedname.to_s
      @id[i] = trend.id.to_s
      i = i + 1
    end
  end

  def sweatshirts
    @names = Array.new
    @id = Array.new
    @parsedName = Array.new
    @folderNames = Array.new
    i = 0
    trends = NewItem.all   #query latest trends
    trends.each do |trend|
      @names[i] = trend.name.to_s
      @folderNames[i] = trend.name.to_s
      temp = trend.name.to_s
      if (temp.include? "#")
        @folderNames[i] = @names[i].tr('#', '').to_s
      end
      @parsedName[i] = trend.parsedname.to_s
      @id[i] = trend.id.to_s
      i = i + 1
    end
  end

  def wallart

  end

  def hats

  end

end
