/*
CONTRIBSINFO = {
    setup: function() {
        // construct new DOM elements
        $('<label for="filter" class="explanation">' +
          'Show only contributors marked as Company' +
          '</label>' +
          '<input type="checkbox" id="filter"/>'
         ).insertBefore('#contributions').change(CONTRIBSINFO.filter_not_company);
    },
    filter_not_elected: function () {
        // 'this' is element that received event (checkbox)
        if ($(this).is(':checked')) {
            $('#contributions tbody tr').each(CONTRIBSINFO.hide_if_not_company_row);
        } else {
            $('#contributions tbody tr').show();
        };
    },
    hide_if_not_company_row: function() {
        $('#contributions tr.Person').hide();
        $('#contributions tr.PAC').hide();
    }
}
$(CONTRIBSINFO.setup);       // when document ready, run setup code

*/