package Soonish::Web::Location;

use Mojo::Base 'Mojolicious::Controller';
use 5.014;
use utf8;
use warnings;

sub list {
    my $self = shift;
    $self->stash(
        location => [$self->model->location->search(undef, { order_by => 'me.name', prefetch => 'country' })->all],
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

sub merge {
    my $self   = shift;
    my $source = $self->model->location->find({ id => $self->param('source') });
    my $dest   = $self->model->location->find({ id => $self->param('dest') });
    if ($source && $dest) {
        $source->merge_into($dest);
    }
    $self->redirect_to('location_list');
}

1;
