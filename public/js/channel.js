$(document).ready(function() {
    $('.remove-channel').click(function() {
        var id = $(this).attr('data-id');
        $.ajax('/channel/delete', {
            type: 'post',
            accepts: 'json',
            data:  { id: id },
            success: function(res) {
                $('.channel-' + id).remove();
            }
        });
    });
});
