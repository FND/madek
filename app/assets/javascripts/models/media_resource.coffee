class MediaResource

  constructor: (data)->
    for k,v of data
      @[k] = v
    @type = _.str.dasherize(@type).replace(/^-/,"") if @type?
    @meta_data = new App.MetaData @meta_data if @meta_data?
    @title = @meta_data.title if @meta_data? and @meta_data.title?
    @author = @meta_data.author if @meta_data? and @meta_data.author?
    @is_shared = !@is_public and !@is_private if @is_private? and @is_public?
    @

  delete: ->
    $.ajax
      url: "/media_resources/#{@id}.json"
      type: "DELETE"

  favor: ->
    $.ajax
      url: "/media_resources/#{@id}/favor.json"
      type: "PUT"

  disfavor: ->
    $.ajax
      url: "/media_resources/#{@id}/disfavor.json"
      type: "PUT"

  totalChildren: -> @children.pagination.total
  totalChildEntries: -> @children.pagination.total_media_entries
  totalChildSets: -> @children.pagination.total_media_sets

  fetchOutArcs: (callback)=>
    $.ajax
      url: "/media_resource_arcs.json"
      data:
        child_id: @id
      success: (response)=>
        @parentIds = _.map response.media_resource_arcs, (arc)-> arc.parent_id
        callback(response) if callback?

  getMetaDatumByMetaKeyName: (metaKeyName)-> new App.MetaDatum _.find @meta_data.raw(), (metaDatum)-> metaDatum.name is metaKeyName 

  @fetch: (data, callback)=>
    $.ajax
      url: "/media_resources.json"
      data: data
      success: (response)=>
        if response.media_resources?
          media_resources = _.map response.media_resources, (mr)-> new MediaResource mr
        callback(media_resources, response) if callback?

window.App.MediaResource = MediaResource