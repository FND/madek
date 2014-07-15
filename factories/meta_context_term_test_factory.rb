module MetaContextTermTestFactory
  def reload! 
    load Rails.root.join(__FILE__)
  end

  def clean_and_then_build_minimal_vocabulary

    MetaTerm.destroy_all
    Context.where("id NOT in ('core','upload','media_set','media_object','copyright')").destroy_all
    MetaKey.where("NOT EXISTS (SELECT 1 FROM meta_key_definitions WHERE meta_key_id = meta_keys.id)").destroy_all
    MediaResource.destroy_all


    ### Context Color ########################################################
    #
    # one context, two key definitions but just one key
    #
    ##########################################################################

    @context_color= Context.create id: :color, label: :Color
    ContextGroup.find_by(name: "Kontexte").contexts << @context_color


    @meta_key_colors= MetaKey.find_or_create_by \
      meta_datum_object_type: :MetaDatumMetaTerms,
      id: :colors

    meta_key_definition_fg_colors= MetaKeyDefinition.find_or_create_by \
      context_id: @context_color.id,  meta_key_id: @meta_key_colors, 
      label: "Foreground Colors"

    MetaTerm.find_or_create_by(term: :Red, meta_key_definition_id: meta_key_definition_fg_colors)
    MetaTerm.find_or_create_by(term: :Blue, meta_key_definition_id: meta_key_definition_fg_colors)
    MetaTerm.find_or_create_by(term: :Yellow, meta_key_definition_id: meta_key_definition_fg_colors)


    meta_key_definition_bg_colors= MetaKeyDefinition.find_or_create_by \
      context_id: @context_color.id,  meta_key_id: @meta_key_colors, 
      label: "Background Colors"

    MetaTerm.find_or_create_by(term: :Red, meta_key_definition_id: meta_key_definition_bg_colors)
    MetaTerm.find_or_create_by(term: :Blue, meta_key_definition_id: meta_key_definition_bg_colors)
    MetaTerm.find_or_create_by(term: :Yellow, meta_key_definition_id: meta_key_definition_bg_colors)



    ### Context Character ####################################################
    #
    # one context, two key definitions (each with it's own key),
    # a term that is shared between the two keys
    #
    ##########################################################################
     
    @context_character= Context.create id: :character, label: :Character
    ContextGroup.find_by(name: "Kontexte").contexts << @context_character 

    @meta_key_goddess= MetaKey.find_or_create_by! \
      meta_datum_object_type: 'MetaDatumMetaTerms',
      id: :goddess 

    @meta_key_definition_goddess= MetaKeyDefinition.find_or_create_by \
      context_id: @context_character.id,  meta_key_id: @meta_key_goddess, 
      label: "Goddess"

    @meta_term_nike= MetaTerm.find_or_create_by(term: "Nike", meta_key_definition: @meta_key_definition_goddess)
    @meta_term_athena= MetaTerm.find_or_create_by(term: "Athena",meta_key_definition: @meta_key_definition_goddess)


    @meta_key_definition_sponsor = MetaKeyDefinition.find_or_create_by \
      context_id: @context_character.id,  meta_key_id: @meta_key_corporate_sponsor, 
      label: "Corporate Sponsor"


    @meta_key_corporate_sponsor= MetaKey.find_or_create_by \
      meta_datum_object_type: 'MetaDatumMetaTerms',
      id: :corporate_sponsor

    MetaTerm.find_or_create_by(term: "Nike", meta_key_definition: @meta_key_definition_sponsor)
    MetaTerm.find_or_create_by(term: "Swatch", meta_key_definition: @meta_key_definition_sponsor)


  end



  def build_vocabulary_example_media_resources user= User.find_by_login(:adam)

    meta_key_title= MetaKey.find_by_id(:title) \
      || FactoryGirl.create(:meta_key_title)

    @set_for_contex_character= MediaSet.create  user_id: user
    @set_for_contex_character.individual_contexts << @context_character
    @set_for_contex_character.meta_data.create \
      meta_key: meta_key_title, value: "Character"
    @set_for_contex_character.reindex

    @set_for_color_context= MediaSet.create user_id: user 
    @set_for_color_context.individual_contexts << @context_color
    @set_for_color_context.meta_data.create \
      meta_key: meta_key_title, value: "Color"
    @set_for_color_context.reindex

    @empty_character_entry = FactoryGirl.create :media_entry, user: @user

    @nike_entry = FactoryGirl.create :media_entry, user: @user
    @nike_goddess_meta_datum= MetaDatum.create! media_resource: @nike_entry, \
      meta_key: @meta_key_goddess, type: 'MetaDatumMetaTerms'
    @nike_goddess_meta_datum.meta_terms << @meta_term_nike

    @athena_and_nike_entry = FactoryGirl.create :media_entry, user: @user
    @athena_and_nike_goddess_meta_datum= MetaDatum.create! \
      media_resource: @athena_and_nike_entry, meta_key: @meta_key_goddess, \
      type: 'MetaDatumMetaTerms'
    @athena_and_nike_goddess_meta_datum.meta_terms << @meta_term_nike
    @athena_and_nike_goddess_meta_datum.meta_terms << @meta_term_athena

    @set_for_contex_character.child_media_resources << @empty_character_entry
    @set_for_contex_character.child_media_resources << @nike_entry
    @set_for_contex_character.child_media_resources << @athena_and_nike_entry

  end

  extend self

end
