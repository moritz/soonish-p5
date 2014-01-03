package Soonish::Web::Event;
use Mojo::Base 'Mojolicious::Controller';
use utf8;
use 5.014;
use warnings;
use Data::Dumper;

sub list {
    my $self = shift;

    my $zipcode  = $self->param('zipcode');
    my $distance = $self->param('distance') // 50;
    $self->stash(distance => $distance);
    $self->stash(ajax => 1) if $self->param('ajax');
    $self->stash(zipcode => $zipcode);
    my @artists = $self->param('artist');
    my @events = $self->model->event->close_to(
        zipcode     => $zipcode,
        distance    => $distance,
        artists     => \@artists,
    );
    $self->stash(events => \@events);
    $self->_artist_sel();
    $self->render();
};

sub _artist_sel {
    my $self = shift;
    my @a;
    my @artists = $self->model->artist->search(undef, { order_by => 'name'})->all;
    for (@artists) {
        push @a, [$_->name, $_->id];
    }
    $self->stash(artists_sel => \@a);
}

1;
