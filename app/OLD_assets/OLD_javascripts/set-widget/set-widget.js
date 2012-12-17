/*
 * Set Widget
 *
 * This script provides functionalities for a set organizing widget
 * Dependencies:
 * - jQuery
 * - jQuery Template
 * - Underscore
 * 
*/

$(document).ready(function(){
  SetWidget.setup();
});

var SetWidget = new SetWidget();

function SetWidget() {
  
  this.setup = function() {
    $(window).bind("click", SetWidget.handle_click_on_window);
  }
  
  this.load = function(target) {
    // fetch index of media sets
    $(target).data("items", []);
    new App.MediaResourceCollection({
      parameters: {
        type: "media_sets",
        accessible_action: "edit",
        with: {
          created_at: true,
          meta_data: {
            meta_key_names: ["title", "owner"]
          },
        },
      },
      onPageLoaded: function(data) {
        $(target).data("items", $(target).data("items").concat(data.media_resources));
      },
      afterCompletlyLoaded: function(data){
        $(target).data("items_loaded", true);
        SetWidget.setup_widget(target);
      }
    });
    
    // fetch media sets that are linkes with the selection
    $(target).data("linked_items", []);
    new App.MediaResourceCollection({
      ids: $(target).data("selected_ids"),
      relation: "parents",
      parameters: {
        accessible_action: "edit",
        type: "media_sets",
        with: {
          children: true
        }
      },
      onPageLoaded: function(data){
        $(target).data("linked_items", $(target).data("linked_items").concat(data.media_resources))
      },
      afterCompletlyLoaded: function(data){
        $(target).data("linked_items_loaded", true);
        SetWidget.setup_widget(target);
      } 
    });
  }
  
  this.create_widget = function(target){
    var widget = $.tmpl("tmpl/widgets/set_widget", {title: target.attr("title")}).data("target", target);
    
    // add identifier to target and add to dom
    $(target).data("widget", widget);
    SetWidget.align_widget(target);
    $("body").append(widget);
    
    // prepare stacks
    $(target)
      .data("create_stack", [])
      .data("link_stack", [])
      .data("unlink_stack", []);
    
    SetWidget.setup_widget(target);
    
    // bind window events resize and scroll to align widget method
    $(window).bind("resize scroll",function(){
      SetWidget.align_widget(target);
    });
  }
  
  this.setup_selection_actions = function(target, elements) {
    $(elements).each(function(i, element){
      $(element).bind("change", function(){
        var item_data = $(this).closest("li").tmplItem().data;
        
        if($(this).closest("li").is(".intermediate")) { // clicked on an element which was in intermediate state
          $(this).closest("li").addClass("selected").removeClass("intermediate");
          $(this).data("intermediate", true);
          $(target).data("link_stack").push(item_data);
        } else if($(this).is(":checked")) { // clicked on an element which is now linked
          $(this).closest("li").addClass("selected").removeClass("intermediate");
          if($(this).data("intermediate")) { // clicked on an element which was initaly intermediate
            SetWidget.remove_from_unlink_stack($(this),target);
            SetWidget.remove_from_link_stack($(this),target);
            $(this).removeAttr("checked");
            $(this).closest("li").addClass("intermediate").removeClass("selected");
          } else if($(this).data("unlinked")) { // clicked on an element which was initaly unlinked
            $(this).removeData("unlinked");
            SetWidget.remove_from_unlink_stack($(this),target);
          } else { // clicked on an element which was initaly linked
            $(this).data("linked", true);
            $(target).data("link_stack").push(item_data);
          }
        } else { // clicked on a element which is now unlinked
          $(this).closest("li").removeClass("selected");
          if($(this).data("intermediate")) { // clicked on an element which was initaly intermediate
            SetWidget.remove_from_link_stack($(this),target);
            $(target).data("unlink_stack").push(item_data);
          } else if($(this).data("linked")) { // clicked on an element which was initaly linked
            $(this).removeData("linked");
            SetWidget.remove_from_link_stack($(this),target);
          } else { // clicked on an element which was initaly unlinked
            $(this).data("unlinked", true);
            $(target).data("unlink_stack").push(item_data);
          }
        }
        SetWidget.check_stack_state(target);
      });
    });
  }
  
  this.remove_from_unlink_stack = function(item, target) {
    var item_data = $(item).closest("li").tmplItem().data;
    for(var i = 0; i < $(target).data("unlink_stack").length; i++) {
      var link = $(target).data("unlink_stack")[i];
      if(link.id == item_data.id) {
        $(target).data("unlink_stack").splice(i, 1);
        break;
      }
    }
  }
  
  this.remove_from_link_stack = function(item, target) {
    var item_data = $(item).closest("li").tmplItem().data;
    for(var i = 0; i < $(target).data("link_stack").length; i++) {
      var link = $(target).data("link_stack")[i];
      // check id and uid for items not yet created
      if((link.uid == undefined && link.id == item_data.id) || link.uid == item_data.uid) {
    $(target).data("link_stack").splice(i, 1);
    break;
      }
    }
  }
  
  this.setup_widget = function(target) {
    // check if data is already there
    if($(target).data("linked_items_loaded") == undefined || $(target).data("items_loaded") == undefined || $(target).data("widget") == undefined) {
      return false;
    }
    // remove start loading indicator
    $(target).data("widget").find(".loading").remove();
    // data
    var items = _.map($(target).data("items"), function(item){
      item.meta_data = MetaDatum.flatten(item.meta_data);
      return item;
    });
    var widget = $(target).data("widget");
    // templating
    $(widget).append($.tmpl("tmpl/widgets/_search"));
    $(widget).append($.tmpl("tmpl/widgets/_list", {items: items}));
    $(widget).append($.tmpl("tmpl/widgets/_new"));
    $(widget).append($.tmpl("tmpl/widgets/_actions"));
    
    // setup the rest
    SetWidget.setup_list(target);
    SetWidget.focus_input(target);
    SetWidget.setup_search_field(target);
    SetWidget.setup_search_hint(target);
    SetWidget.setup_cancel(target);
    SetWidget.setup_create_new(target);
    SetWidget.setup_create_hint(target);
    SetWidget.setup_selection_actions(target, $(".list ul li input[type=checkbox]"));
    SetWidget.setup_submit(target);
  }
  
  this.setup_list = function(target) {
    // sort list alphabeticaly
    SetWidget.sort_list(target);
    
    $(target).data("widget").find(".list li").each(function(i_item, item){
      
      // detach the element of the list if the element is the current opened one
      if($(target).data("selected_ids").indexOf($(this).tmplItem().data.id) > -1 && $(target).data("detach_selected") == true) {
        $(this).detach();
      }
      
      // check if there are already connected items
      $.each($(target).data("linked_items"), function(i_link, linked_item){
        // check if the ellement is already linked
        if(linked_item.id == $(item).tmplItem().data.id) {
          
          var all_possible_linked_ids = _.map(linked_item.children.media_resources, function(resource){ return resource.id; });
          
          var all_selected_items_are_linked = true;
          if(all_possible_linked_ids.length > 0) {
            $.each($(target).data("selected_ids"), function(i_selected_id, selected_id){
              if(all_possible_linked_ids.indexOf(selected_id) == -1) {
                all_selected_items_are_linked = false;
              }
            });
          }
          
          // if not all selected items are linked the linke element is INTERMEDIATE linked
          if(all_selected_items_are_linked == false) {
            // setup up intermidiate checkbox
            $(item).addClass("intermediate");
            $(item).find("input").after("<div class='intermediate_pipe'></div>");
          } else {
            $(item).addClass("selected");
            $(item).find("input").attr("checked", "checked");
          }
        }
      });
    });
  }
  
  this.setup_submit = function(target) {
    $(target).data("widget").find(".submit").click(function(){
      // show loading indicator
      $(this).data("text", $(this).html());
      $(this).css("width", $(this).outerWidth()).css("height", $(this).outerHeight()).html("").append($.tmpl("tmpl/loading_img"));
      
      // disable click binding
      $(this).unbind("click");
      
      // hide cancle button
      $(this).next(".cancel").hide();
      
      // disable search
      $(target).data("widget").find("#widget_search").attr("disabled", true);
      $(target).data("widget").find(".search").addClass("disabled");
      
      // hide create new
      $(target).data("widget").find(".create_new").hide();
      
      // disable all checkboxes
      $(target).data("widget").find("input[type=checkbox]").attr("disabled", true);
      
      // start submitting
      SetWidget.submit_create_stack(target);
    });
  }
  
  this.disable_search = function(target) {
    $(target).data("widget").find(".search").attr("disabled", true);
    $(target).data("widget").find(".search input").attr("disabled", true);
    $(target).data("widget").find(".search .hint").hide();
  }
  
  this.submit_create_stack = function(target) {
    
    // if create stack is empty go on with submiting the link stack
    if($(target).data("create_stack").length == 0){
      SetWidget.submit_link_stack(target);
      return false;
    }
    
    var created_items = [];
    $.each($(target).data("create_stack"), function(i, element){
      var created_item_as_string = JSON.stringify($(target).data("create").created_item);
      created_item_as_string = created_item_as_string.replace(/:title/g, $(target).data("create_stack")[i].title);
      created_items.push(JSON.parse(created_item_as_string));
    });
    
    var data_as_string = JSON.stringify($(target).data("create").data);
    data_as_string = data_as_string.replace(/":created_items"/g, JSON.stringify(created_items));
    var data = JSON.parse(data_as_string);
    
    $.ajax({
      url: $(target).data("create").path,
      success: function(returned_items, status, request) {
        for(var i_returned = 0; i_returned < returned_items.media_resources.length; i_returned++) {
          // add id to linked items in the link_stack which where created with the widget, because these just got ids after they are created on the server
          for(var i_linked = 0; i_linked < $(target).data("link_stack").length; i_linked++) {
            if($(target).data("link_stack")[i_linked].uid != undefined && $(target).data("link_stack")[i_linked].uid == i_returned) {
              $(target).data("link_stack")[i_linked].id = returned_items.media_resources[i_returned].id;
            }
          }
          
          // add id to the created item, which is also inside of the dom
          for(var i_item = 0; i_item < $(target).data("widget").find(".list li").length; i_item++) {
            if($($(target).data("widget").find(".list li")[i_item]).tmplItem().data.uid ==  i_returned) {
              $($(target).data("widget").find(".list li")[i_item]).tmplItem().data.id = returned_items.media_resources[i_returned].id;
              delete $($(target).data("widget").find(".list li")[i_item]).tmplItem().data.uid;
            }
          }
        }
        
        // clear stack
        $(target).data("create_stack", []);
        
        // clear all created items
        $(target).data("widget").find(".list li").each(function(){
          $(this).find("input").removeData("created");
          $(this).removeClass("created");
        });
        
        // go on with submit link stack
        SetWidget.submit_link_stack(target);
      },
      error: function(request, status, error){
      },
      data: data,
      type: $(target).data("create").method
    }); 
  }
  
  this.submit_link_stack = function(target) {
    // if link stack is empty go on with submiting the unlink stack
    if($(target).data("link_stack").length == 0){
      SetWidget.submit_unlink_stack(target); 
      return false;
    }     
    
    var linked_items = _.map($(target).data("link_stack"), function(el){return el.id;});
    
    $.ajax({
      url: $(target).data("link").path,
      beforeSend: function(request, settings){
      },
      success: function(data, status, request) {
        // clear stack
        $(target).data("link_stack", []);
        
        // clear all linked items
        $(target).data("widget").find(".list li").each(function(){
          $(this).find("input").removeData("linked");
        });
        
        // go on
        SetWidget.submit_unlink_stack(target);
      },
      error: function(request, status, error){
      },
      data: SetWidget.get_data(target, "link", linked_items),
      type: $(target).data("link").method,
      dataType: 'json'
    }); 
  }
  
  this.get_data = function(target, source, items) {
    var target = $(target);
    var data_as_string = JSON.stringify(target.data(source).data)
    .replace(/":parent_media_set_ids"/g, JSON.stringify(items))
    .replace(/":media_set_ids"/g, JSON.stringify(target.data("selected_ids")))
    .replace(/":media_resource_ids"/g, JSON.stringify(target.data("selected_ids")))
    .replace(/":media_entry_ids"/g, JSON.stringify(target.data("selected_ids")));
    return JSON.parse(data_as_string);
  }
  
  this.submit_unlink_stack = function(target) {
    
    // if unlink stack is empty go on with submiting the finish submiting
    if($(target).data("unlink_stack").length == 0) {
      SetWidget.finish_submitting(target);
      return false;
    }
    
    var unlinked_items = _.map($(target).data("unlink_stack"), function(el){return el.id;});
                
    $.ajax({
      url: $(target).data("unlink").path,
      beforeSend: function(request, settings){
      },
      success: function(data, status, request) {
        // clear stack
        $(target).data("unlink_stack", []);
        
        // clear all unlinked items
        $(target).data("widget").find(".list li").each(function(){
          $(this).find("input").removeData("unlinked");
        });
        
        // go on
        SetWidget.finish_submitting(target);
      },
      error: function(request, status, error){
      },
      data: SetWidget.get_data(target, "unlink", unlinked_items),
      type: $(target).data("unlink").method,
      dataType: 'json'
    }); 
  }
  
  this.finish_submitting = function(target) {
    // replace loading indicator with green submitted button
    $(target).data("widget").find(".loading img").remove();
    $(target).data("widget").find(".loading").append("<div class='success icon'></div>");
    
    // eval target after-submit
    eval($(target).data("after_submit"));
  }
  
  this.setup_create_new = function(target) {
    $(target).data("widget").find(".create_new a").click(function(event){
      event.preventDefault();
      SetWidget.show_create_input(target, $(target).data("widget").find(".search input").val());
    });
    
    $(target).data("widget").find(".create_new input").bind("blur", function(event) {
      if($(this).val() == "") {
        window.setTimeout(function(){
          if($(target).data("widget").find(".create_new input:focus").length < 1) {
            SetWidget.reset_create_new(target);
          }
        },200);
      }
    });
    
    $(target).data("widget").find(".create_new input").bind("keyup keydown", function(event) {
      // hide or show depending on val
      if($(this).val() == "") {
        $(this).siblings(".create.button").hide();
      } else {
        $(this).siblings(".create.button").show();
      } 
      
      // create new on enter
      if(event.keyCode == 13) {
        SetWidget.create_new(target, $(this).val());
      }
      
      // connect create new field with search
      $(target).data("widget").find("input#widget_search").val($(this).val()).change();
    });
    
    $(target).data("widget").find(".create_new .create.button").bind("click", function(event) {
       SetWidget.create_new(target, $(target).data("widget").find(".create_new input").val());
       
       // connect create new field with search
      $(target).data("widget").find("input#widget_search").val($(this).val()).change();
    });
  }
  
  this.create_new = function(target, val) {
    var new_item = $.tmpl("tmpl/widgets/_line", {meta_data: {title: val, owner: $(target).data("user").name}, created_at: new Date()});
    $(new_item).addClass("created");
    $(new_item).css("background-color", "#CCC");
    $(target).data("widget").find(".list ul").append(new_item);
    SetWidget.reset_create_new(target);
    
    // sort list
    SetWidget.sort_list(target);
    
    // new is activated per default
    $(new_item).find("input").attr("checked", true);
    $(new_item).find("input").data("linked", true);
    $(new_item).addClass("selected").removeClass("intermediate");
    SetWidget.setup_selection_actions(target, $(new_item).find("input"));
    
    // add new created to stack
    $(target).data("create_stack").push({title: val});
    
    // add new created to link stack
    $(target).data("link_stack").push({title: val, uid: ($(target).data("create_stack").length-1)}); // the uid is representing the create_stack id of the linked stack item. This item was created inside the widget
    
    // add uid to the item itselves for identifying this element, when the server responds with a valid id
    $(new_item).tmplItem().data.uid = ($(target).data("create_stack").length-1);
    
    // check stack state
    SetWidget.check_stack_state(target);
    
    // scroll to new entry which is append to list
    // with a delay, because the create is coupled to the search, first the search has to be resetted
    window.setTimeout(function(){
      $(target).data("widget").find(".list").animate({
        scrollTop: ($(new_item).offset().top-$(target).data("widget").find(".list li:first").offset().top)
      }, function(){
        $(new_item).animate({
          "background-color": "#EEE"
        }, function(){
          $(this).removeAttr("css");
        });
      });      
    }, 150);
  }
  
  this.setup_create_hint = function(target) {
    $(target).data("widget").find(".create_new input").bind("keydown click", function(){
      $(target).data("widget").find(".create_new .hint").hide();
    });
    $(target).data("widget").find(".create_new .hint").bind("click", function(){
      SetWidget.show_create_input(target, "");
      $(target).data("widget").find(".create_new .hint").hide();
      $(target).data("widget").find(".create_new input").focus();
    });
  }
  
  this.check_stack_state = function(target) {
    var empty = true;
    
    if($(target).data("create_stack") != undefined && $(target).data("create_stack").length > 0) empty = false;
    if($(target).data("link_stack") != undefined && $(target).data("link_stack").length > 0) empty = false;
    if($(target).data("unlink_stack") != undefined && $(target).data("unlink_stack").length > 0) empty = false;
    
    if(empty == false) {
      SetWidget.activate_submit(target);
      SetWidget.enable_modal(target);
    } else {
      SetWidget.deactivate_submit(target);
      if($(target).data("widget").find(".search input").val() == "") SetWidget.disable_modal(target);
    }
  }
  
  this.show_create_input = function(target, val) {
    SetWidget.enable_modal(target);
    $(target).data("widget").find(".create_new a").hide();
    if(val != "") {
      $(target).data("widget").find(".create_new .hint").hide();
    } else {
      $(target).data("widget").find(".create_new .hint").show();
    }
    $(target).data("widget").find(".create_new input").show().val(val).select().focus();
    if(val != "") {
      $(target).data("widget").find(".create_new .create.button").show();      
    }
  }
  
  this.sort_list = function(target) {
    var items = $(target).data("widget").find(".list li");
        items = items.sort(SetWidget.sort_title_alphabeticaly);
        
    $(target).data("widget").find(".list ul").append(items);
  }
  
  this.sort_title_alphabeticaly = function(a,b){
    if($(a).tmplItem().data.meta_data.title == undefined) {
      return -1;
    } else if ($(b).tmplItem().data.meta_data.title == undefined) {
      return 1;
    } else {
      return $(a).tmplItem().data.meta_data.title.toUpperCase() > $(b).tmplItem().data.meta_data.title.toUpperCase() ? 1 : -1;
    }
  }
  
  this.reset_create_new = function(target) {
    $(target).data("widget").find(".create_new a").show();
    $(target).data("widget").find(".create_new .hint").hide();
    $(target).data("widget").find(".create_new input").hide().val("");
    $(target).data("widget").find(".create_new .create.button").hide();
  }
  
  this.setup_cancel = function(target) {
    $(target).data("widget").find(".actions .cancel").click(function(){
      SetWidget.destroy_modal_overlay(target);
      $(target).data("widget").removeClass("modal");
      SetWidget.deactivate_submit(target);
      SetWidget.close_widget(target);
    });
  }
  
  this.setup_search_field = function(target) {
    $(target).data("widget").find(".search input").bind("keyup keydown change", function() {
      if($(this).val().length != 0) {
        SetWidget.enable_modal(target);
      } 
      
      SetWidget.search(target, $(this).val());
    });
    
    $(target).data("widget").find(".search input").bind("blur change", function(event) {
      if($(this).val() == "") {
        $(this).siblings(".hint").show();
        SetWidget.check_stack_state(target);
      } else {
        $(this).siblings(".hint").hide();
      }
    });
  }
  
  this.search = function(target, val) {
    if (val.replace(/\s+/g, "").length > 0) {
      val = val.replace(/\s+$/, "");
      val = val.replace(/^\s+/, "");
      var search_elements = val.split(/[\s+]/g);
      // each list element
      $(target).data("widget").find(".list li").each(function(i, element){
        var found = false;
        // each search element
        $.each(search_elements, function(i_search_element, search_element){
          var regexp = new RegExp("\(\^\|\\s\)"+search_element, 'i');
          var meta_data = $(element).tmplItem().data.meta_data; 
          if( (meta_data.title && meta_data.title.search(regexp) != -1) ||
              (meta_data.owner && meta_data.owner.search(regexp) != -1) ||
              ($(element).find(".created_at").data("search") && $(element).find(".created_at").data("search").search(regexp) != -1) ){
            found = true;
          } else {
            found = false;
            return false;
          }
        });
      if(found) {
        $(this).show();
        // remove old highlights first
        $(element).removeHighlights();
        // highlight all matches
        $(element).find(".title").highlight(search_elements);
        $(element).find(".owner").highlight(search_elements);
        $(element).find(".created_at").highlight(search_elements);
      } else {
        $(this).hide();
        $(element).removeHighlights();
      }
    });
    } else { // clear search results
      $(target).data("widget").find(".list li").show();
      $(target).data("widget").find(".list li").removeHighlights();
    }
  }
  
  this.setup_search_hint = function(target) {
    $(target).data("widget").find(".search input").bind("keydown click", function(){
      if(! $(this).closest(".search").hasClass("disabled")) {
        $(target).data("widget").find(".search .hint").hide();
      }
    });
    $(target).data("widget").find(".search .hint").bind("click", function(){
      if(! $(this).closest(".search").hasClass("disabled")) {
        $(target).data("widget").find(".search .hint").hide();
        $(target).data("widget").find(".search input").focus();
      }
    });
  }
  
  this.enable_modal = function(target) {
    if($("#modal_overlay").length == 0) {
      SetWidget.create_modal_overlay(target);
    } else {
      $("#modal_overlay").stop(true,true).fadeIn(); 
    }
    $(target).data("widget").addClass("modal");
  }
  
  this.disable_modal = function(target) {
    $(target).data("widget").removeClass("modal");
    $("#modal_overlay").stop(true,true).fadeOut();
  }
  
  this.create_modal_overlay = function(target) {
    var modal_container = $("<div id='modal_overlay'></div>")
    $(modal_container).hide();
    $(target).data("widget").before(modal_container);
    SetWidget.enable_modal(target);
  }
  
  this.destroy_modal_overlay = function(target) {
    $("#modal_overlay").remove();
  }
  
  this.activate_submit = function(target) {
    $(target).data("widget").find(".actions .submit").removeAttr("disabled");
  }
  
  this.deactivate_submit = function(target) {
    $(target).data("widget").find(".actions .submit").attr("disabled", true);
  }
  
  this.focus_input = function(target) {
    $(target).data("widget").find("input.autofocus").val("");
    $(target).data("widget").find("input.autofocus").focus();
  }
  
  this.open_widget = function(target) {
    $(target).data("widget").show();
    SetWidget.align_widget(target);
    $(target).addClass("open");
    SetWidget.focus_input(target);
    $(target).data("widget").find(".search .hint").show();
  }
  
  this.align_widget = function(target) {
    var widget = $(target).data("widget");
    $(widget).position({
      of: ($(target).closest(".action_menu").length) ? $(target).closest(".action_menu") : $(target),
      my: "center top",
      at: ($(target).closest(".action_menu").length) ? "center top" : "center top",
      collision: "fit fit"
    });
  }
  
  this.close_widget = function(target) {
    if($(target).data("widget").hasClass("modal")) return false;
    
    // hide and close
    $(target).data("widget").hide();
    $(target).removeClass("open");
    
    // reset create new 
    SetWidget.reset_create_new(target);
    
    // remove all unsaved new items
    // unlink all elements from the link stack
    // link all elements from the unlink stack
    $(target).data("widget").find(".list li").each(function(i, line){
      if($(line).hasClass("created")) $(line).remove();
      if($(line).find("input").data("linked")) {
        $(line).find("input").removeData("linked");
        $(line).find("input").attr("checked", false);
        $(line).removeClass("selected");  
      }
      if($(line).find("input").data("unlinked")) {
        $(line).find("input").removeData("unlinked");
        $(line).find("input").attr("checked", true);
        $(line).addClass("selected").removeClass("intermediate"); 
      }
      if($(line).find("input").data("intermediate")) {
        $(line).addClass("intermediate").removeClass("selected"); 
        $(line).find("input").removeAttr("checked");
      }
    });
    
    // show all items of the list again
    $(target).data("widget").find(".list li").show();
    
    // clear the stack
    $(target)
      .data("create_stack", [])
      .data("link_stack", [])
      .data("unlink_stack", []);
    
    // show submit button text again
    if($(target).data("widget").find(".submit").data("text") != undefined) $(target).data("widget").find(".submit").html($(target).data("widget").find(".submit").data("text"));
    
    // show cancle button again
    $(target).data("widget").find(".actions .cancel").show();
    
    // remove action based classes from submit button
    if($(target).data("widget").find(".actions .submit").hasClass("loading")) {
      $(target).data("widget").find(".actions .submit").removeClass("loading");
      // setup submit button again
      SetWidget.setup_submit(target);
    }
    
    // check stack state to disable button
    SetWidget.check_stack_state(target);
    
    // scrolltop
    $(target).data("widget").find(".list").scrollTop(0);
    
    // enable search
    $(target).data("widget").find("#widget_search").removeAttr("disabled");
    $(target).data("widget").find(".search").removeClass("disabled");
    
    // show create new
    $(target).data("widget").find(".create_new").show();
    
    // enable all checkboxes
    $(target).data("widget").find("input[type=checkbox]").removeAttr("disabled");
  }
  
  this.handle_click_on_window = function(event) {
    var trigger = event.target;
    
    // hide all set widgets if target was not the set widget or any childs
    if($(trigger).hasClass("has-set-widget") || $(trigger).parents(".has-set-widget").length) {
      var target = ($(trigger).hasClass("has-set-widget")) ? $(trigger) : $(trigger).parents(".has-set-widget");
      if($(target).hasClass("open")) {
        // prevent default click 
        event.preventDefault();
        
        SetWidget.close_widget(target);
      } else {
        // prevent default click 
        event.preventDefault();
        
        // create or open widget
        if($(target).hasClass("created")) {
          SetWidget.open_widget(target);
        } else {
          SetWidget.load(target);
          SetWidget.create_widget(target);
          $(target).addClass("created");
          $(target).addClass("open");
          SetWidget.align_widget(target);
        }
      }
      
    } else if(($(trigger).hasClass("widget") && $(trigger).hasClass("set")) || $(trigger).parents(".set.widget").length) {
      // click on widget
    } else {
      // click on window (not widget not button wich has widget)
      $(".set.widget:not(.modal)").each(function(){
        SetWidget.close_widget($(this).data("target"));        
      });
    }
  }
}