# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.copy_dataset = (href, defval) ->
  name = prompt("New Dataset Name", defval)
  if name
    location.href = href + '?name=' + escape(name.trim())
