new_ringer = (data) ->
  $("#campaign-ringers .total_count").text(
    data.ring_count + " Total Ring" + (if data.ring_count != 1 then "s" else ""))
  $("#campaign-ringers .unique_count").text(
    data.ringer_count + " Unique Ringer" + (if data.ringer_count != 1 then "s" else ""))
  $("#campaign-ringers .counts").effect("highlight", {color: '#63DB00'}, 500)
  $(".all-label .ui-button-text").text('All ' + data.ringer_count)
  
  delete_last = -> 
    if $('#ringers-numbers li').length > 10
      $('#ringers-numbers li').last().remove()
  
  $("<li>#{data.number}</li>").hide()
                              .css('opacity', 0.0)
                              .prependTo("ul.ringers")
                              .slideDown(250)
                              .animate({opacity: 1.0}, 250, delete_last)

  $('#progress-inner').css('width', "#{5 + (data.ringer_count / data.goal )* 100}%")
  $('#progress-inner .count').html(data.ringer_count)

setupBroadcastTextArea = ->
  character_limit = 160
  $('#broadcast-text-area').bind('input', -> 
    if $.trim($(this).val()) == "" || $(this).val().length > character_limit
      $('#broadcastbutton').attr('disabled', 'disabled')
    else
      $('#broadcastbutton').removeAttr('disabled'))
  $('#broadcast-text-area').charCount({
    allowed: character_limit,
    warning: 20,
  })

setupTabs = ->
  $( "#tabs" ).tabs()

setupFilters = (buttons) ->
  $(buttons).buttonset()
  $("#{buttons} :radio").change ->
    context = $(buttons).parent().parent()
    $("#filter-options", context).slideUp()
    clicked = $(this)
    id = $(this).attr('id')
    id = id.substr(0, id.length-1)
    if $("##{id}-options").length == 1
      $("#filter-options", context).html($("##{id}-options").html()).slideDown()

      $("#filter-options :checkbox", context).change(->
        str = 'country:' + $("#filter-options :checked", context).map((_, c) -> c.value).toArray().join('|')
        clicked.val(str)
      )

loadCampaign = (pusher, campaign, prev_channel) ->
  if prev_channel?
    pusher.unsubscribe(prev_channel)

  $("#campaign").empty()
  $("select.campaign-select").val(campaign)
  $("select").trigger("liszt:updated")

  channel_name = null
  if campaign != ""
    $.get("/campaign/#{campaign}",
      (data) ->
        $("#campaign").hide()
                      .html(data)
                      .slideDown(200)
        setupBroadcastTextArea()
        setupFilters('#broadcast-filter')
        setupFilters('#export-filter')
        setupTabs()
    ).error(-> window.location.replace '/')

    channel_name = campaign
    channel = pusher.subscribe(channel_name)
    channel.bind 'new', new_ringer
  window.onhashchange = -> loadCampaign(pusher, document.location.hash[1..], channel_name)


tagFor = (tagItem, id) ->
  $("<div>#{tagItem.label} <input type='hidden' name='campaign[message][filtered_messages][#{id}]constraints[]' value='#{tagItem.value}' /> <button type='button'>Remove</button></div>")
removeFilter = (btn) ->
  btn.parent().remove()

removeTag = (btn) ->
  btn.parent().remove()

addTag = (parent, item, id) ->
  newTag = tagFor(item, id)
  $('button', newTag).click ->
    removeTag($(this))
  newTag.appendTo($('#tag-filters', parent))
  $('.tag-name', parent).val('')

newFilterMessage = ->
  id = $('.filtered-message-template').length
  newDiv = $('#original-filtered-message-template-container div:first-child').clone()
  $('textarea[name="MESSAGE"]', newDiv).attr('name', "campaign[message][filtered_messages][#{id}][message_text]")
  $('input[name="CONSTRAINT_TYPE"]', newDiv).attr('name', "constraint_type#{id}")

  $('input[id="HAS_ID"]', newDiv).attr('id', "has_#{id}")
  $('input[id="HAS_NOT_ID"]', newDiv).attr('id', "has_not_#{id}")
  $('label[for="HAS_ID"]', newDiv).attr('for', "has_#{id}")
  $('label[for="HAS_NOT_ID"]', newDiv).attr('for', "has_not_#{id}")
  $('#filtered-messages').append(newDiv)
      
  $('#remove-filter-button', newDiv).click ->
    removeFilter($(this))

  $.getJSON '/tags/grouped_tags.json', (data) ->
    $.each data, (key, value) ->
      $('.tag-name', newDiv)
        .append($("<optgroup></optgroup>")
          .attr("label", key))
      $.each value, (_, item) ->
        $('.tag-name optgroup:last', newDiv)
          .append($("<option></option>")
            .attr("value", item.value)
            .text(item.visible_label))
    $('.tag-name', newDiv).chosen()
    $('.tag-name', newDiv).change (evt) ->
      selected = $(':selected', $(this))
      constraints = $("input[name='constraint_type#{id}']:checked").val()
      label = (if constraints == 'has' then '' else 'Has not ') + selected.parent().attr('label')
      value = (if constraints == 'has' then '' else '!') + $(this).val()
      addTag $(this).parent(), {label: "#{label} : #{selected.text()}", value: "#{value}"}, id
  $('.counter', newDiv).remove()
  $('.msg-text-area', newDiv).charCount({
    allowed: 160,
    warning: 20,
  })



$ ->
  $('select.campaign-select').chosen()
  setTimeout((->$('.notice').slideUp('medium')), 3000)

  pusher = new Pusher(window.pusher_key)
  $("#campaign").empty()
  window.onhashchange = -> loadCampaign(pusher, document.location.hash[1..], null)
  window.onhashchange()
  $("select.campaign-select").change (evt) ->
    document.location.hash = $(this).val()

  $('.msg-text-area').charCount({
    allowed: 160,
    warning: 20,
  })
  
  window.removeTag = (btn) -> removeTag(btn)
  window.removeFilter = (btn) -> removeFilter(btn)
  window.addFilter = -> newFilterMessage()

