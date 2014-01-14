var loc_cache = {};
function get_zipcode () { $('.locfield').val().split('-')[1]; }
function get_country () { $('.locfield').val().split('-')[0]; }

function auto_show_zipcode() {
    var loc = $('.locfield').val();
    if (!loc) {
        $('#loc-head1').show();
        $('#loc-head2').hide();
        return;
    }

    if (loc_cache[loc]) {
        show_zipcode(loc_cache[loc]);
        return;
    }
    var zipcode = loc.split('-')[1];
    $.get(
        '/zipcode/search?q=' + zipcode,
        function (res) {
            for (idx in res.results) {
                var d = res.results[idx];
                loc_cache[d.id] = d;
            }
            if (loc_cache[loc]) {
                show_zipcode(loc_cache[loc]);
                return;
            }
            console.log('Should not happen!');
        },
        'json'
    );
};
function show_zipcode(loc) {
    console.log('show_zipcode');
    console.log(loc);
    $('.show-zipcode').html(loc.zipcode);
    $('.show-city').html(loc.city);
    $('#loc-head2').show();
    $('#loc-head1').hide();
}
function show_feed_url() {
    var doc_loc = document.location;
    var url = doc_loc.protocol + '//' + doc_loc.host + '/feed/atom?';
    var artists = $('#artist').val();
    if (artists && artists.length) {
        artists = artists.sort(function (a, b) { return a - b }).join(',');
        url = url + 'a=' + artists + ';'
    }
    var loc = $('.locfield').val();
    if (loc) {
        loc = loc.split('-');
        url = url + 'c=' + loc[0] + ';';
        url = url + 'z=' + loc[1] + ';';
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
    var $loc = $('.locfield');
    var loc  = $loc.val();
    auto_show_zipcode();

    var $distance = $('#distance');
    var distance  = $distance.val();
    if (!distance.match(/^\d+(?:\.\d*)?$/)) {
        $distance.addClass('invalid');
        return;
    }
    else {
        $distance.removeClass('invalid');
    }

    var url = '/?ajax=1;' + $('#param-select-form').serialize();
    $.get(url, function(res) {
        $('#eventlist').html(res);
        $('.show-distance').html(distance);
        show_feed_url();
    });
}

function save_channel() {
    var url = '/channel/save?' + $('#param-select-form').serialize();
    $.ajax(

        url,
        {
            type: 'POST',
            accepts: 'json',
            success: function (res) {
                $('.channel-save-notify').html('Als Suche "' + res.name + '" gespeichert.');
            }
        }
    );
}

$(document).ready(function() {
    $('.select2').select2();
    $('#save-channel').click(save_channel);
    $('#distance').change(update_list);
    $('#artist').change(update_list);
    $('.locfield').change(update_list);
    $('#sbmt').click(update_list);
    if (!$('.locfield').val() && navigator && navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
            function (loc) {
                var c = loc.coords;
                $.get('/proximity?lat=' + c.latitude + ';lon=' + c.longitude,
                    function (res) {
                        if (res.zipcode) {
/*                            $('#zipcode').val(res.zipcode);
 */
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
    $('.locfield').select2({
        placeholder: "Postleitzahl oder Ort eingeben",
        minimumInputLength: 2,
        width: '50%',
        ajax: {
            url: '/zipcode/search',
            quietMillis: 100,
            data: function (term, page) { return { q: term, page: page } },
            results: function (data, page) {
                for (idx in data.results) {
                    var d = data.results[idx];
                    loc_cache[d.id] = d;
                }
                return data;
            },
        },
        formatResult: function (r) {
            return r.zipcode + ' ' + r.city + ', ' + r.country_name;
        },
        formatSelection: function (r) {
            return r.zipcode + ' ' + r.city + ', ' + r.country_name;
        },
        initSelection: function (r) {
            var id = $(r).val();

            if (id) {
                return {
                    id: id,
                    zipcode: id.split('-')[1],
                    country_id: id.split('-')[0],
                    city: '(unknown)',
                    country_name: '(unknown)'
                };
            }
        }
    });
    show_feed_url();
});
