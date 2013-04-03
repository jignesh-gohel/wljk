// Below used statement is the shortcut for jQuery(document).ready(function() {});
jQuery(function() {

  // Reference: https://github.com/bergie/hallo#readme
  jQuery('.richTextEditor')
    .hallo({
        plugins: {
          'halloformat': {},
          'halloheadings': {},
          'hallojustify': {},
          'hallolists': {},
          'halloreundo': {},
          'hallolink': {},
          'halloimage': {},
          'halloblacklist': {}
        }
    });

  jQuery('.datetimepicker').datetimepicker();

  jQuery('#recurring_schedule_cbox').change(function() {
    var checked = $(this).is(':checked');
    var recurringScheduleDetailsContainer = $('#recurringScheduleDetailsContainer');
    if(checked) {
      recurringScheduleDetailsContainer.show();
    } else {
      recurringScheduleDetailsContainer.hide();
    }
  });

});

function emptyString(string) {
  if((string == undefined) || (string == null) || ($.trim(string) == '') ) {
    return true;
  }

  return false;
}

