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

1;
