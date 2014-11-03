package Soonish::DB::ResultSet::Event;

use parent 'DBIx::Class::ResultSet';

use 5.014;
use utf8;
use warnings;

use Date::Parse qw(strptime);
use Data::Dumper;
use POSIX qw(strftime);

sub close_to {
    my ($self, %param) = @_;
    # conversion from km to m:
    $param{distance} //= 50;
    $param{distance} *= 1000;

    my %search = (
        start_date => { '>='    => \'NOW()', },
    );
    if ($param{zipcode}) {
        my $subsel = $self->result_source->schema->resultset('GeoProximity')->search(
            undef,
            {
                bind => [$param{country} // 1, $param{zipcode}, $param{distance}],
            }
        )->as_query;
        $search{'location.zipcode'} = { IN =>  $subsel };
    }

    if ($param{artist} &&  @{ $param{artist} } && $param{artist}[0] ) {
        $search{'artist.id'} = { IN => $param{artist} };
    }

    $self->search(
        \%search,
        {
            prefetch => [
                'artist',
                'location',
            ],
            order_by => {
                -asc => 'start_date',
            }
        }
    );
}

sub autovivify_from_lastfm {
    my ($self, $ev) = @_;
    return if $ev->{cancelled};
    my $internal_id = 'last.fm|' . $ev->{id};
    my $event = $self->find({ internal_id => $internal_id });
    return $event if $event;

    my $model = $self->result_source->schema;
    my $artist_str = $ev->{artists}{headliner} || $ev->{artists}{artist};
    my $artist = $model->artist->find_or_create({ name => $artist_str});
    my $start_date =  strftime '%F %H:%M', map $_ // 0,  strptime $ev->{startDate};

    $event = $self->search({
        artist      => $artist->id,
        start_date  => $start_date,

    })->first;

    return $event if $event;
    my $l = $model->location->autovivify_from_lastfm($ev->{venue});
    return unless $l;
    my $url = $ev->{website} || $ev->{url};
    $url = undef unless length $url;
    my $provider = $model->provider->find_or_create({ name => 'last.fm' });
    return $self->create({
        name        => $ev->{name},
        location    => $l->id,
        artist      => $artist->id,
        start_date  => $start_date,
        internal_id => $internal_id,
        url         => $url,
        provider    => $provider->id,
    });
}


1;
