module Concerns
  module Image
    extend ActiveSupport::Concern

    def get_preview_and_send_image(media_entry, size)
      # TODO: review/cleanup

      if media_entry.media_file.represantable_as_image?

        preview = media_entry.media_file.preview(size)
        file_path = preview.file_path
        content_type = preview.content_type

      else

        file_path = ::DOCUMENT_UNKNOWN_THUMBNAIL_FILE_PATH
        content_type = ::DOCUMENT_UNKNOWN_THUMBNAIL_CONTENT_TYPE

      end

      begin
        send_file file_path,
                  type: content_type,
                  disposition: 'inline'
      rescue
        Rails.logger.warn 'image not found!'
        render nothing: true, status: 404
      end
    end

  end
end
