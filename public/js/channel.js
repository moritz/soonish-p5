$(document).ready(function() {
    function really_delete(id) {
        $.ajax('/channel/delete', {
            type: 'post',
            accepts: 'json',
            data:  { id: id },
            success: function(res) {
                $('.channel-' + id).remove();
            }
        });
    }
    $('.remove-channel').click(function() {
        var id      = $(this).attr('data-id');
        var $dialog = $('#delete-dialog').children().clone();
        $('.channel-' + id + ' .remove-channel').after($dialog);
        $dialog.find('.yes').click(function() { really_delete(id) });
        $dialog.find('.no').click(function() {
            $dialog.remove();
        });
    });
});
