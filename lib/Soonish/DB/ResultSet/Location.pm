package Soonish::DB::ResultSet::Location;

use parent 'DBIx::Class::ResultSet';

use 5.014;
use utf8;
use warnings;


sub autovivify_from_lastfm {
    my ($self, $data) = @_;
    my $l = $data->{location}
        or die "No location data found in Last.fm data";
    my $country_str = $l->{country}
        or die "No country found in Last.fm data";
    my $zipcode     = $l->{postalcode}
        or return;

    my $country = $self->result_source->schema->resultset('Country')
                 ->search({name_english => $country_str})->first;
    return unless $country;

    my $loc = $self->search({
            name    => $data->{name},
            country => $country->id,
            zipcode => $zipcode,
    })->first;
    return $loc if $loc;

    my $url = $data->{website};
    $url    = undef unless length $url;

    $loc = $self->create({
            name    => $data->{name},
            address => $l->{street},
            zipcode => $zipcode,
            city    => $l->{city},
            url     => $url,
            country => $country->id,
    });
    return $loc;
}

1;
