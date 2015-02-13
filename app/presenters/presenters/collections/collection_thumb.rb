module Presenters
  module Collections
    class CollectionThumb < Presenters::Shared::Resources::ResourcesThumb

      def image_url
        media_entry = \
          @resource.media_entries.cover \
            or @resource.media_entries.first

        if media_entry.media_file.represantable_as_image?
          media_entry_image_path(media_entry, :small)
        else
          generic_thumbnail_url
        end
      end

    end
  end
end
