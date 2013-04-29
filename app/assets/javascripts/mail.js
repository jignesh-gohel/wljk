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

  var dateTimePicker = jQuery('.datetimepicker').datetimepicker();
  dateTimePicker.on('changeDate', function(e) {
    var eventTarget = jQuery(e.target);

    var currentTargetParentContainer = eventTarget.closest('.control-group');
    if(currentTargetParentContainer.length > 0 && currentTargetParentContainer.hasClass('error')) {
      currentTargetParentContainer.removeClass('error').addClass('success');
      currentTargetParentContainer.find('span.help-inline').hide();
    }

    var datetimeBox = eventTarget.find('input[name="scheduleDateTime"]');
    if (datetimeBox.length > 0) {
      var enableRecurringCbox = false;
      if (!emptyString(datetimeBox.val())) {
        enableRecurringCbox = true;
      }

      toggleRecurringCheckbox(enableRecurringCbox);
    }

  });

  jQuery('#clearDateTime').on('click', function(event) {
    jQuery('#mailScheduleDateTime input[name="scheduleDateTime"]').val('');
    resetRecurringDetails();
    toggleRecurringCheckbox(false);
    if (jQuery(this).is(":visible")) {
      jQuery(this).hide();
    }
    //toggleRecurringCheckbox(enableRecurringCbox);
    // Reference: http://stackoverflow.com/questions/2857007/jquery-toggle-clicking-on-link-jumps-back-to-top-of-the-page
    event.preventDefault();
  });

  jQuery('#recurring_schedule_cbox').on("change", function(event) {
    var checked = jQuery(event.target).is(':checked');
    var recurringScheduleDetailsContainer = jQuery('#recurringScheduleDetailsContainer');
    if(checked) {
      recurringScheduleDetailsContainer.show();
    } else {
      resetRecurringDetails();
    }
  });

  var currentMailContent = jQuery("#currentMailContent");
  if(currentMailContent.length > 0) {
    // Reference: https://github.com/sprucemedia/jQuery.divPlaceholder.js#readme
    // for trigger("change")
    jQuery("#textarea").html(currentMailContent.html()).trigger("change");
  }

  validateScheduleMailForm();

});

function resetRecurringDetails() {
  jQuery("#recurring_interval").val('');
  jQuery("#recurring_interval_type").val('days');
  var recurringScheduleDetailsContainer = jQuery('#recurringScheduleDetailsContainer');
  recurringScheduleDetailsContainer.removeClass('success').removeClass('error');
  recurringScheduleDetailsContainer.find('span.help-inline').remove();
  recurringScheduleDetailsContainer.hide();
}

function toggleRecurringCheckbox(flag) {
  var recurringCbox = jQuery('#recurring_schedule_cbox');
  var clearDateTimeLink = jQuery('#clearDateTime');

  if (flag) {
    clearDateTimeLink.show();
    recurringCbox.removeAttr('disabled');
  } else {
    clearDateTimeLink.hide();
    recurringCbox.attr('disabled', 'disabled');
    if(recurringCbox.is(":checked")) {
      // Reference: http://stackoverflow.com/questions/4996953/how-to-uncheck-checkbox-using-jquery
      recurringCbox.prop("checked", false);
    }
  }
}

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
    var validationPassed = true;
    var msg = '';

    if (emptyString(value)) {
      validationPassed = false;
      msg = 'This field is required.'
    } else {
      var recipients = value.split(',');
      var invalidRecipients = new Array();
      for (var cnt = 0; cnt < recipients.length; cnt++) {
        var recipient = jQuery.trim(recipients[cnt]);
        if(!emptyString(recipient) && !isEmail(recipient)) {
          invalidRecipients.push(recipient);
        }
      }

      var invalidRecipientsCnt = invalidRecipients.length;
      if (invalidRecipientsCnt > 0) {
        validationPassed = false;
        msg = 'Following recipients are invalid: ';
        for (var cnt = 0; cnt < invalidRecipientsCnt; cnt++) {
          if( (cnt > 0) && (cnt < invalidRecipientsCnt) ) {
            msg = msg.concat(';  ');
          }
          msg = msg.concat(invalidRecipients[cnt]);
        }
      }
    }

    if(!validationPassed) {
      jQuery(element).data('recipientsErrorMessage', msg);

      var parent = jQuery(element).closest('.control-group');

      if (parent.hasClass('success')) {
         parent.removeClass('success').addClass('error');
       }
    }
    return validationPassed;
  }, function(params, element) {
    return jQuery(element).data('recipientsErrorMessage');
  });
}

function validateScheduleMailForm() {
  var form = $('#scheduleMailForm');
  if(form.length > 0) {
    addCustomMethodToFormValidationPlugin();

    form.validate({
      // Reference: http://stackoverflow.com/questions/8466643/jquery-validate-enable-validation-for-hidden-fields
      ignore: ".ignore",
      rules: {
        mail_content : {
           required: {
             depends: function(element) {
               jqElement = jQuery(element);
               var html = jQuery('#textarea').html();
               var flag = true;
               if (!emptyString(html)) {
                 flag = false;
                 jqElement.val(html);
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
        jQuery('#mail_content').val(jQuery('#textarea').html());
        form.submit();
      }
    });
  }
}

