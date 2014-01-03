var zipcode_cache = {};
function auto_show_zipcode() {
    var zipcode = $('#zipcode').val();
    if (zipcode.length == 0) {
        $('#loc-head1').show();
        $('#loc-head2').hide();
        return;
    }
    if (zipcode_cache[zipcode]) {
        show_zipcode(zipcode, zipcode_cache[zipcode]);
        return;
    }
    $.ajax({
        url: '/zipcode?zipcode=' + zipcode,
        dataType: 'json',
        success:  function (res) {
            zipcode_cache[zipcode] = res.city;
            $('#zipcode').removeClass('invalid');
            $('.zipcode-error').html('');
            show_zipcode(zipcode, res.city);
        },
        error: function (res) {
            $('#zipcode').addClass('invalid');
            $('.zipcode-error').html(res.responseJSON.error);
        }
    });
};
function show_zipcode(zipcode, city) {
    $('.show-zipcode').html(zipcode);
    $('.show-city').html(city);
    $('#loc-head2').show();
    $('#loc-head1').hide();
}
function show_feed_url() {
    var loc = document.location;
    var url = loc.protocol + '//' + loc.host + '/feed/atom?';
    var artists = $('#artist').val();
    if (!artists) {
        artists = []
    }
    artists = artists.sort(function (a, b) { return a - b }).join(',');
    if (artists.length > 0) {
        url = url + 'a=' + artists + ';'
    }
    var zipcode = $('#zipcode').val();
    if (zipcode.length == 5) {
        url = url + 'z=' + zipcode + ';'
    }
    var distance = $('#distance').val();
    if (distance.length > 0) {
        url = url + 'd=' + distance;
    }
    $('a.show-feed-url').attr('href', url);
    $('a.show-feed-url').html(url);
    var $link = $('head [rel="alternate"]');
    if ($link.length) {
        $link.attr('href', url);
    }
    else {
        $('head').append('<link rel="alternate" type="application/atom+xml" href="'
                + url + '" title="Atom 1.0 feed" />');
    }
}
function update_list() {
    var $zipcode = $('#zipcode');
    var zipcode  = $zipcode.val();
    var valid = true;
    if (zipcode.length == 0 || zipcode.length == 5) {
        $zipcode.removeClass('invalid');
        auto_show_zipcode();
    }
    else {
        valid = false;
        $zipcode.addClass('invalid');
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
    $('#zipcode').change(update_list);
    $('#distance').change(update_list);
    $('#artist').change(update_list);
    $('#sbmt').click(update_list);
    if ($('#zipcode').val().length == 0 && navigator && navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
            function (loc) {
                var c = loc.coords;
                $.get('/proximity?lat=' + c.latitude + ';lon=' + c.longitude,
                    function (res) {
                        if (res.zipcode) {
                            $('#zipcode').val(res.zipcode);
                            update_list();
                        }
                    },
                    'json'
                );
            },
            function (e) {
                console.log('Geolocation lookup failed');
            }
        );
    }
    auto_show_zipcode();
    $('.show-distance').html($('#distance').val());
    show_feed_url();
});
