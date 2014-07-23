#= require_self
#= require_tree ./test
#
window.Test=
  Visualization: {}

$ -> 
  # enable autocomplete in browsers wo focus, i.e. headless ones
  # you need to trigger change manually
  $(document).on "change", "input.ui-autocomplete-input", ->
    $(this).autocomplete("search",$(this).val())


# **downloadChecker**
# give it a selector to find an element with a link on it
# the values of your 'expected' object keys are compared against
# the jqXHR response object <http://api.jquery.com/Types/#jqXHR>
# 
# Examples:
# - `page.execute_script("window.Test.downloadChecker('a:first', {status: 200})")`
# - `page.execute_script("window.Test.downloadChecker('a:first', {responseText: 'OK'})")`

window.Test.downloadChecker= (selector, expected) =>
  # grab link from DOM
  element = $(selector)
  link = element.prop('href')

  unless link then throw 'No download link found on element'
  
  # download the link
  $.ajax link, {
    url: link,
    async: false,
    complete: (jqXHR, textStatus )->
      # abort if download failed
      unless textStatus is 'success' then throw 'Download failed'
      
      # compare all keys of 'expected' object with answer
      Object.keys(expected).forEach (key) ->
        unless expected[key] is jqXHR[key]
          throw "key #{key} is #{jqXHR[key]}, not #{expected[key]}"
    }