package Soonish::Web::Zipcode;

use Mojo::Base 'Mojolicious::Controller';
use 5.014;
use utf8;
use warnings;

sub query {
    my $self = shift;
    my $zipcode = $self->param('zipcode');
    unless ($zipcode =~ /^\d{5}/) {
        $self->render(status => 404, json => { error => 'Ungültige Postleitzahl' });
        return;
    }
    my $z = $self->model->resultset('Geo')->find({plz99 => $zipcode});
    if ($z) {
        $self->render(
            json => { zipcode => $zipcode, city => $z->city },
        );
    }
    else {
        $self->render(status => 404, json => { error => 'Postleitzahl unbekannt' });
    }
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
                    country => {
                        id      => $country_id,
                        name    => $country_name,
                    },
                    zipcode     => $zipcode,
                    city        => $city,
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
