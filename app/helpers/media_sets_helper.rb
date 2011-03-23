# -*- encoding : utf-8 -*-
module MediaSetsHelper

  #2001# def media_set_title(media_set, visible_media_entries, with_link = false)

  def media_set_title(media_set, with_link = false, with_main_thumb = false, total_thumbs = 0)
    content = capture_haml do
      haml_tag :div, :class => "set-box", :style => (with_main_thumb ? "min-height: 160px;": nil) do
        haml_tag :div, thumb_for(media_set, :small_125), :class => "thumb_box_set", :style => "margin-right: 20px;" if with_main_thumb
        haml_tag :span, media_set.title, :style => "font-weight: bold; font-size: 1.2em;"
        #2001# " (%d/%d Medieneinträge)" % [visible_media_entries.count, media_set.media_entries.count]
        haml_concat " (%d Medieneinträge)" % [media_set.media_entries.count]
        haml_tag :br
        haml_concat "von #{media_set.user}"
        haml_tag :br
        if total_thumbs > 0
          haml_tag :br
          media_entries = media_set.media_entries.paginate(:page => 1, :per_page => total_thumbs)
          if media_entries.empty?
            haml_tag :small, _("Noch keine Medieneinträge enthalten")
          else
            media_entries.each do |media_entry|
              haml_tag :div, thumb_for(media_entry, :small), :class => "thumb_mini" 
            end
            haml_concat "..." if media_entries.total_pages > media_entries.current_page
          end
        end
      end
    end

    capture_haml do
      if with_link
        haml_tag :a, content, :href => media_set_path(media_set)
      else
        haml_concat content
      end
      haml_tag :div, :class => "clear"
    end
  end

  def media_sets_list(media_sets)
    capture_haml do
      haml_tag :h4, _("In Sets enhalten:"), :style => "margin: 40px 0 1em 0;"
      media_sets.each do |media_set|
        #2001# media_entries = media_set.media_entries.select {|media_entry| Permission.authorized?(current_user, :view, media_entry)}
        #2001# media_set_title(media_set, media_entries, true)
        haml_concat media_set_title(media_set, true)
      end
    end
  end


  def media_sets_setter(form_path, with_cancel_button = false)
    form_tag form_path, :id => "set_media_sets" do
      b = content_tag :h3, :style => "clear: both" do
        _("Zu Set hinzufügen:")
      end

      b += content_tag :span, :style => "margin-right: 1em;" do
        select_tag "media_set_ids[]", options_for_select({_("- Auswählen -") => nil}) + options_from_collection_for_select(current_user.editable_sets, :id, :title_and_user), :style => "width: 100%;"
      end

      b += content_tag :button, :id => "new_button" do
            _("Neues Set erstellen")
      end

      b += content_tag :span, :id => "text_media_set", :style => "display: none;" do
        c = text_field_tag nil, nil, :style => "width: 20em; margin-top: 15px; float: none;"
        c += content_tag :button do
              _("Hinzufügen")
        end
      end

      b += content_tag :p, :style => "margin: 1em 0 0 0", :class => "save" do
        submit_tag _("Gruppierungseinstellungen speichern"), :style => "display: none;"
      end
      
      b += content_tag :p, :style => "margin: 1em 0 0 0" do
        link_to _("Weiter ohne Gruppierung"), root_path, :class => "buttons"
      end if with_cancel_button

      b += javascript_tag do
        begin
        <<-HERECODE
        $(document).ready(function () {
          $("button#new_button").click(function() {
            $(this).hide();
            $(this).closest("form").find("input:submit").hide();
            $("#text_media_set input").val("");
            $("#text_media_set").fadeIn();
            return false;
          });
          $("#text_media_set button").click(function() {
            var v = $("#text_media_set input").val();
            $("#media_set_ids_").append("<option value='"+v+"' selected='selected'>"+v+"</option>");
            $("#text_media_set").hide();
            $("button#new_button").fadeIn();
            $("form#set_media_sets").trigger('change');
            return false;
          });
          $("#text_media_set input").keypress(function(event) {
            if(event.keyCode == 13){ // 13 is Enter
              $("#text_media_set button").trigger('click');
              return false;
            }
          });
          
          $("form#set_media_sets").change(function() {
            $(this).find("input:submit").show();
          });
        });
        HERECODE
        end.html_safe
      end

    end

  end

end
