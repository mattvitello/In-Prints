class TrendController < ApplicationController
  def trend
    item = NewItem.where(id: params[:id])
    if params[:cat] == "top"
      item = TopItem.where(id: params[:id])
    end
    @id = params[:id]
    @name = item[0].name.to_s
    @folder = item[0].name.to_s
    @type = params[:type].to_s
    temp = item[0].name.to_s
    if (temp.include? "#")
      @folder = @folder.tr('#', '').to_s
    end
  end
end
