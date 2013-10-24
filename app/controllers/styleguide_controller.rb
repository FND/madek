class StyleguideController < ActionController::Base

  layout false

  before_filter do

    @sections = {}
    Dir.entries(Rails.root.join("app", "views", "styleguide")).reject{|p| p.match(/[_\.]/)}.each do |section|
      @sections[section] = Dir.entries(Rails.root.join("app", "views", "styleguide", section)).reject{|p| p.match(/^_/).nil?}.map{|p| p[/(?<=_)\w*?(?=\.)/]}
    end
    @current_section = if params[:section] then params[:section] else "1 Layout" end
  end

end
