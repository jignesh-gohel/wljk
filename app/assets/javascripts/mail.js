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

  datetTimePicker = jQuery('.datetimepicker').datetimepicker();
  datetTimePicker.on('changeDate', function(e) {
    var currentTargetParentContainer = jQuery(e.target).closest('.control-group');
    if(currentTargetParentContainer.length > 0 && currentTargetParentContainer.hasClass('error')) {
      currentTargetParentContainer.removeClass('error').addClass('success');
      currentTargetParentContainer.find('span.help-inline').hide();
    }
  });

  jQuery('#recurring_schedule_cbox').change(function() {
    var checked = $(this).is(':checked');
    var recurringScheduleDetailsContainer = $('#recurringScheduleDetailsContainer');
    if(checked) {
      recurringScheduleDetailsContainer.show();
    } else {
      recurringScheduleDetailsContainer.hide();
    }
  });

  validateScheduleMailForm();

});

function emptyString(string) {
  if((string == undefined) || (string == null) || (jQuery.trim(string) == '') ) {
    return true;
  }

  return false;
}

// Reference: http://stackoverflow.com/questions/8022926/jquery-validate-plugin-test-value-for-email-pattern
function isEmail(value){
  return jQuery.validator.methods.email.call(
    { optional: function() {return false } },
    value
   );
};

function addCustomMethodToFormValidationPlugin() {
  // Reference: http://stackoverflow.com/questions/13352626/dynamic-jquery-validate-error-messages-with-addmethod-based-on-the-element
  jQuery.validator.addMethod("emailList", function(value, element) {
    var validator = this;
    var flag = true;
    var msg = '';
    var recipients = value.split(',');
    var invalidRecipients = new Array();
    for (var cnt = 0; cnt < recipients.length; cnt++) {
      var recipient = jQuery.trim(recipients[cnt]);
      if(!emptyString(recipient) && !isEmail(recipient)) {
        invalidRecipients.push(recipient);
      }
    }

    var invalidRecipientsCnt = invalidRecipients.length
    if (invalidRecipientsCnt > 0) {
      flag =  false;
      msg = 'Following recipients are invalid:'
      for (var cnt = 0; cnt < invalidRecipientsCnt; cnt++) {
        msg = msg.concat(invalidRecipients[cnt]);
        if(cnt < invalidRecipientsCnt) {
          msg = msg.concat(', ');
        }
      }
    }

    if(!flag) {
      jQuery(element).data('recipientsErrorMessage', msg);
    }

    return flag;
  }, function(params, element) {
    return jQuery(element).data('recipientsErrorMessage');
  });
}

function validateScheduleMailForm() {
  var form = $('#scheduleMailForm');
  if(form.length > 0) {
    addCustomMethodToFormValidationPlugin();

    form.validate({
      debug: true,
      // Reference: http://stackoverflow.com/questions/8466643/jquery-validate-enable-validation-for-hidden-fields
      ignore: ".ignore",
      rules: {
        mail_content : {
           required: {
             depends: function(element) {
               jqElement = jQuery(element);
               var text = jQuery('#textarea').text();
               var flag = true;
               if (!emptyString(text)) {
                 flag = false;
                 jqElement.val(text);
                 jqElement.closest('.control-group').removeClass('error').addClass('success');
               } else {
                 jqElement.val('');
                 jqElement.closest('.control-group').removeClass('success').addClass('error');
               }
               return flag;
             }
           }
        },
        recipients : {
          required: true,
          emailList: true
        },
        recurring_interval: {
          required: {
             depends: function(element) {
               return $('#recurring_schedule_cbox').is(':checked');
             }
           }
        }
      },
      // Inline with Twitter Bootstrap theme
      errorElement: 'span',
      errorClass: 'help-inline',
      errorPlacement: function(error, element) {
        element.closest('.control-group').addClass('error');

        if(element.is('input[name="scheduleDateTime"]')) {
          error.appendTo(element.closest('.well'));
        } else {
          error.appendTo(element.closest('.control-group'));
        }
      },
      success: function(errorElement) {
        errorElement.closest('.control-group').removeClass('error').addClass('success');
      },
      submitHandler: function(form) {

      }
    });
  }
}

