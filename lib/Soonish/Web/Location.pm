package Soonish::Web::Location;

use Mojo::Base 'Mojolicious::Controller';
use 5.014;
use utf8;
use warnings;

sub list {
    my $self = shift;
    $self->stash(
        location => [$self->model->location->search(undef, { order_by => 'name' }, { prefetch => 'country' })->all],
    );
    $self->render();
}

sub details {
    my $self   = shift;
    my $location = $self->model->location->find(
        { id => $self->param('id') },
        { prefetch => 'country' },
    );
    unless ($location) {
        $self->render(status => 404, message => 'Veranstaltungsort nicht gefunden');
        return;
    }
    $self->stash( location => $location );
    $self->render;
}

1;
