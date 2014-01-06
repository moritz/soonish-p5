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

sub details {
    my $self   = shift;
    my $artist = $self->model->artist->find({ id => $self->param('id') });
    unless ($artist) {
        $self->render(status => 404, message => 'Künstler nicht gefunden');
        return;
    }
    $self->stash( artist => $artist );
    $self->render;
}

1;
