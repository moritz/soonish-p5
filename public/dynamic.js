function update_list() {
    var $plz = $('#plz');
    var plz  = $plz.val();
    var valid = true;
    if (plz.length != 5) {
        valid = false;
        $plz.addClass('invalid');
    }

    var $distance = $('#distance');
    var distance  = $distance.val();
    if (!distance.match(/^\d+(?:\.\d*)?$/)) {
        valid = false;
        $distance.addClass('invalid');
    }
    var url = '/?ajax=1;' + $('#param-select-form').serialize();
    $.get(url, function(res) {
        $('#eventlist').html(res);
        $('.show-distance').html(distance);
    });
}
$(document).ready(function() {
    $('.select2').select2();
    $('#plz').change(update_list);
    $('#distance').change(update_list);
    $('#artist').change(update_list);
    $('#sbmt').click(update_list);
});
