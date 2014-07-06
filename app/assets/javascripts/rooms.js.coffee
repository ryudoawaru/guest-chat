@.granted = false
loaded = false
$(document).on 'ready', () ->
  Notification.requestPermission (status) ->
    @.granted = true

$(document).on 'page:change', () ->
  # send message
  $('#new_message').on 'ajax:success', (event, message) ->
    $('#message_content').val('')
  .on 'ajax:error', () ->
    alert('出錯了')
  $("#message_content").keypress (e) ->
    $(this.form).submit() if e.which == 13 && !e.shiftKey
  .focus()
  # max height
  set_height = () ->
    $('#messages').height window.innerHeight-150
  set_height()
  window.addEventListener('resize', set_height)
  # pulling
  pull_messages = () ->
    $.ajax
      url: '/rooms/' + $('#room').data('slug') + '/messages.json'
      data:
        last_read_message_id: $('.message:last-child').data('message-id')
    .done (messages) ->
      scroll_flag = false
      is_btm = $('#messages').height() + $('#messages').scrollTop() >= $('#messages')[0].scrollHeight - 10
      for message in messages
        scroll_flag = true
        color = if message.guest.id == $('#current_guest').data('id') then 'warning' else 'primary'
        $('#messages').append('<div class="row message" data-message-id="'+message.id+'"> <div class="col-sm-2"> <span class="label label-'+color+'">'+message.guest.name+'</span> </div> <div class="col-sm-10">'+message.content+'</div> </div>')
        code_block = $('[data-message-id="'+message.id+'"] pre code')[0]
        hljs.highlightBlock code_block if code_block
      $('#messages').scrollTop($('#messages')[0].scrollHeight) if scroll_flag && is_btm
      console.log "messages.length = #{messages.length}; granted = #{granted}; loaded = #{loaded}"
      new Notification("有 #{messages.length} 條新訊息") if messages.length > 0 && granted == true && loaded == true
      loaded = true
    .always () ->
      setTimeout(pull_messages, 2000)
  pull_messages()
