###

  Item Box

  This script setups interactivity for "item boxes" (set or entries) which are displayed as
  represantive of a set or entry in lists and pages
 
###

jQuery ->
  setup_deletion()

setup_deletion = ->
  $('a.delete_me[data-method="delete"]').live 'ajax:success', (e, data, textStatus, jqXHR) ->
    item_box = $(e.target).closest ".item_box"
    
    if not item_box.tmplItem().data.is_set # remove also from batch edit (selection & sessionStorage)
      selected_media_resources = get_media_resources_json()
      selected_media_resource_ids = selected_media_resources.map (entry) -> entry.id
      found_selected_entry_index = selected_media_resource_ids.indexOf(data.id)
      if found_selected_entry_index > -1
        selected_media_resources.splice found_selected_entry_index, 1
        $('#selected_items [rel="'+data.id+'"]').remove()
        if media_entries_in_set?
          removeItems media_entries_in_set, data.id
        set_media_resources_json selected_media_resources
        displayCount()
        
    item_box.remove() # finaly remove item box from dom