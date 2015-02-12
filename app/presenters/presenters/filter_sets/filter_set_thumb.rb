module Presenters
  module FilterSets
    class FilterSetThumb < Presenters::Shared::Resources::ResourcesThumb
      def image_url(size = :small
        binding.pry
        
        asset_path('dev_todo.png')
      end
    end
  end
end
