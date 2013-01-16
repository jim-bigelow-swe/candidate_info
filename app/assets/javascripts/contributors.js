
CONTRIBUTORS = {
    setup: function() {
        // construct new DOM elements
        $('<label for="filter" class="explanation">' +
          'Show only contributors marked as Company' +
          '</label>' +
          '<input type="checkbox" id="filter"/>'
         ).insertBefore('#contributors').change(CONTRIBUTORS.filter_not_company);
	$('#contributors input.contrib_kind_submit').click(CONTRIBUTORS.putContributorKind);
    },

    putContributorKind: function() {
	var val = $("form input[type=radio]:checked").val();
	var href = $(this).find('td:nth-child(3)').href();
        $.ajax({type: 'PUT',
                url: $(this).attr('href'),
                timeout: 5000,
                success: CONTRIBUTORS.showContributionList,
                error: function() { alert('Error!'); }
               });
        return(false);
    },
    receiveContributorKindUpdate: function() {

    },
    filter_not_company: function () {
        // 'this' is element that received event (checkbox)
        if ($(this).is(':checked')) {
            $('#contributors tbody tr').each(CONTRIBUTORS.hide_if_not_company_row);
        } else {
            $('#contributors tbody tr').show();
        };
    },
    hide_if_not_company_row: function() {
        $('#contributors tr.Person').hide();
        $('#contributors tr.PAC').hide();
    }
}
$(CONTRIBUTORS.setup);       // when document ready, run setup code