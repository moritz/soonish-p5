use 5.014;
use strict;
use warnings;
use utf8;

use lib 'lib';

use Soonish qw(config model);
use Net::LastFM;
use Encode qw(decode_utf8);
use Data::Dumper;

binmode STDOUT, ':encoding(UTF-8)';

@ARGV or die "Usage: $0 <artist>\n";


my $model = model();
my $lastfm = Net::LastFM->new(
    api_key    => config(lastfm => 'key'),
    api_secret => config(lastfm => 'secret'),
);

use JSON qw(encode_json);

for my $artist (@ARGV) {
    $artist = decode_utf8 $artist;
    say "Artist: $artist";

    my $result = eval {
        $lastfm->request(
            method      => 'artist.GetEvents',
            artist      => $artist,
            autocorrect => 1,
            limit       => 200,
        );
    };
    unless ($result) {
        warn "Error from the LastFM API: $@";
        next;
    }

    if ($result &&  $result->{events}) {
        my $events = $result->{events}{event};
        if (ref($events) eq 'HASH') {
            $events = [ $events ];
        }
        for my $ev ( @$events ) {
            my $event = $model->event->autovivify_from_lastfm($ev);
            say $event->id if $event;
        }
    }
}
