var plz_cache = {};
function auto_show_plz() {
    var plz = $('#plz').val();
    if (plz.length == 0) {
        $('#loc-head1').show();
        $('#loc-head2').hide();
        return;
    }
    if (plz_cache[plz]) {
        show_plz(plz, plz_cache[plz]);
        return;
    }
    $.get('/zipcode?zipcode=' + plz, function (res) {
        plz_cache[plz] = res.city;
        show_plz(plz, res.city);
    }, 'json');
};
function show_plz(plz, city) {
    $('.show-plz').html(plz);
    $('.show-city').html(city);
    $('#loc-head2').show();
    $('#loc-head1').hide();
}
function show_feed_url() {
    var loc = document.location;
    var url = loc.protocol + '//' + loc.host + '/feed/atom?';
    var artists = $('#artist').val().sort(function (a, b) { return a - b }).join(',');
    if (artists.length > 0) {
        url = url + 'a=' + artists + ';'
    }
    var plz = $('#plz').val();
    if (plz.length == 5) {
        url = url + 'z=' + plz + ';'
    }
    var distance = $('#distance').val();
    if (distance.length > 0) {
        url = url + 'd=' + distance;
    }
    $('a.show-feed-url').attr('href', url);
    $('a.show-feed-url').html(url);
}
function update_list() {
    var $plz = $('#plz');
    var plz  = $plz.val();
    var valid = true;
    if (plz.length == 0 || plz.length == 5) {
        $plz.removeClass('invalid');
        auto_show_plz();
    }
    else {
        valid = false;
        $plz.addClass('invalid');
    }

    var $distance = $('#distance');
    var distance  = $distance.val();
    if (!distance.match(/^\d+(?:\.\d*)?$/)) {
        valid = false;
        $distance.addClass('invalid');
    }
    else {
        $distance.removeClass('invalid');
    }
    if (!valid)
        return;

    var url = '/?ajax=1;' + $('#param-select-form').serialize();
    $.get(url, function(res) {
        $('#eventlist').html(res);
        $('.show-distance').html(distance);
        show_feed_url();
    });
}
$(document).ready(function() {
    $('.select2').select2();
    $('#plz').change(update_list);
    $('#distance').change(update_list);
    $('#artist').change(update_list);
    $('#sbmt').click(update_list);
    auto_show_plz();
    $('.show-distance').html($('#distance').val());
    show_feed_url();
});
