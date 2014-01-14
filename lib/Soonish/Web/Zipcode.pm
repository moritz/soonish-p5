package Soonish::Web::Zipcode;

use Mojo::Base 'Mojolicious::Controller';
use 5.014;
use utf8;
use warnings;
use Mojo::JSON ();

sub query {
    my $self = shift;
    my $zipcode = $self->param('zipcode');
    my $country = $self->param('country') // 1;
    unless ($zipcode =~ /^\d{4,5}$/) {
        $self->render(status => 404, json => { error => 'Ungültige Postleitzahl' });
        return;
    }
    my $z = $self->model->resultset('Geo')->search({plz99 => $zipcode, country => $country})->first;
    if ($z) {
        $self->render(
            json => { zipcode => $zipcode, city => $z->city, country => $country, },
        );
    }
    else {
        $self->render(status => 404, json => { error => 'Postleitzahl unbekannt' });
    }
}

sub search {
    my $self  = shift;
    my $query = $self->param('q');
    my $page  = $self->param('page');
    my @res;
    if (length($query)) {
        for ($self->model->resultset('Geo')->autosearch($query, $page)->all) {
            push @res, {
                id              => join('-', $_->country->id, $_->zipcode),
                zipcode         => $_->zipcode,
                city            => $_->city,
                country_id      => $_->country->id,
                country_name    => $_->country->name,
            };
        }
    }
    my $more = @res < 25 ? Mojo::JSON->false : Mojo::JSON->true;
    $self->render(json => { more => $more, results => \@res });
}

sub proximity {
    my $self = shift;
    my $lat  = $self->param('lat');
    my $lon  = $self->param('lon');
    if (defined($lon) && defined($lat)) {
        $self->model->storage->dbh_do(sub {
            my ($storage, $dbh) = @_;
            my $sth = $dbh->prepare(<<EOF);
    SELECT country.name, country.id, p.plz99, p.plzort99
      FROM post_code_areas AS p
      JOIN country ON p.country = country.id
     WHERE st_distance(p.loc_center, st_point(?, ?), True) < 50000
  ORDER BY st_distance(p.loc_center, st_point(?, ?), True)
     LIMIT 1
EOF
            $sth->execute($lon, $lat, $lon, $lat);
            my ($country_name, $country_id, $zipcode, $city) = $sth->fetchrow_array();
            $sth->finish;
            if ($country_id) {
                $self->render(json => {
                    id           => join('-', $country_id, $zipcode),
                    country_id   => $country_id,
                    country_name => $country_name,
                    zipcode      => $zipcode,
                    city         => $city,
                });
            }
            else {
                $self->render(status => 404, json => { error => 'nothing found' });
            }
        });
    }
    else {
        $self->render(status => 404, json => { error => 'lat or lon missing' });
    }

}

1;
