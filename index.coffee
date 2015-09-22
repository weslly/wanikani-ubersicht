options =
  api_key: "replace this text with your Wanikani API key"

refreshFrequency: 60000 * 10   # Update every 10 minutes

style: """
  bottom: 45px
  right: 15px
  color: #fff
  font-family: Helvetica Neue

  .error
    background: red

  table
    border-collapse: collapse
    table-layout: fixed

    &:after
      content: 'Wanikani'
      position: absolute
      left: 0
      top: -22px
      font-size: 14px

  td
    border: 1px solid #fff
    font-size: 24px
    font-weight: 100
    width: 120px
    max-width: 120px
    overflow: hidden
    text-shadow: 0 0 1px rgba(#000, 0.5)
    text-align: center

  .wrapper
    padding: 4px 6px 4px 6px
    position: relative

  p
    padding: 0
    margin: 0
    font-size: 11px
    font-weight: normal
    max-width: 100%
    color: #ddd
    text-overflow: ellipsis
    text-shadow: none

  .col1
    span
      font-size: 22px

"""

command: "curl --silent https://www.wanikani.com/api/user/#{options.api_key}/study-queue"

render: (_) -> """
<div class="error"></div>
<table>
  <tr>
    <td class='col1'>
      <div class='wrapper'>
        <span></span>
        <p>Next Review</p>
      </div>
    </td>
    <td class='col2'>
      <div class='wrapper'>
        <span></span>
        <p>Next Hour</p>
      </div>
    </td>
    <td class='col3'>
      <div class='wrapper'>
        <span></span>
        <p>Next Day</p>
      </div>
    </td>
  </tr>
  <tr>
    <td class='col4'>
      <div class='wrapper'>
        <span></span>
        <p>Level</p>
      </div>
    </td>
    <td class='col5'>
      <div class='wrapper'>
        <span></span>
        <p>New Lessons</p>
      </div>
    </td>
    <td class='col6'>
      <div class='wrapper'>
        <span></span>
        <p>Reviews</p>
      </div>
    </td>
  </tr>
</table>
"""

update: (output, domEl) ->
  $(domEl).find('.error').hide()
  try
    data = JSON.parse(output)
  catch e
    $(domEl).find('.error').html('Connection error.').show()
    return 0

  ui = data.user_information
  ri = data.requested_information

  if data.error
    $(domEl).html("Invalid or missing API key")
    return 0

  next_review = new Date(ri.next_review_date * 1000).toISOString()
  $(domEl).find('.col1 span').remove()
  $(domEl).find('.col1 .wrapper').prepend('<span></span>')
  $(domEl).find('.col1 span').attr('title', next_review)

  $(domEl).find('.col2 span').text(ri.reviews_available_next_hour)
  $(domEl).find('.col3 span').text(ri.reviews_available_next_day)
  $(domEl).find('.col4 span').text(ui.level)
  $(domEl).find('.col5 span').text(ri.lessons_available)
  $(domEl).find('.col6 span').text(ri.reviews_available)

  $.getScript './wanikani.widget/jquery.timeago.js.lib', ->
    ts = $.timeago.settings
    tss = ts.strings

    ts.allowFuture = true
    ts.allowPast = false
    tss.inPast = "Now";
    tss.prefixAgo = null
    tss.prefixFromNow = null
    tss.suffixAgo = "ago"
    tss.suffixFromNow = ""
    tss.seconds = "< 1 minute"
    tss.minute = "1 minute"
    tss.minutes = "%d minutes"
    tss.hour = "~1 hour"
    tss.hours = "~%d hours"
    tss.day = "a day"
    tss.days = "%d days"
    tss.month = "~1 month"
    tss.months = "%d months"
    tss.year = "~1 year"
    tss.years = "%d years"

    $(domEl).find('.col1 span').timeago()

