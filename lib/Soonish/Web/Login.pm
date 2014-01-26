package Soonish::Web::Login;

use Mojo::Base qw/Mojolicious::Controller/;

use 5.014;
use warnings;
use utf8;

sub count {
    my $self = shift;
    my $cnt  = $self->model->login->count;
    $self->render(text => $cnt);
}

1;
