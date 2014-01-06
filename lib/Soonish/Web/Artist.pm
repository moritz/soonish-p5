package Soonish::Web::Artist;

use Mojo::Base 'Mojolicious::Controller';
use 5.014;
use utf8;
use warnings;

sub list {
    my $self = shift;
    $self->stash(
        artist => [$self->model->artist->search(undef, { order_by => 'name' })->all],
    );
    $self->render();
}

1;
