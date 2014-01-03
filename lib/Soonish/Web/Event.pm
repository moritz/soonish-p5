package Soonish::Web::Event;
use Mojo::Base 'Mojolicious::Controller';
use utf8;
use 5.014;
use warnings;
use Data::Dumper;

sub list {
    my $self = shift;

    my $is_ajax  = $self->param('ajax');

    my $zipcode  = $self->param('zipcode');
    my $distance = $self->param('distance') // 50;
    my $country  = $self->param('country') // 1;
    $self->stash(country  => $country);
    $self->stash(distance => $distance);
    $self->stash(ajax => 1) if $is_ajax;
    $self->stash(zipcode => $zipcode);
    my @artists = $self->param('artist');
    my @events = $self->model->event->close_to(
        country     => $country,
        zipcode     => $zipcode,
        distance    => $distance,
        artists     => \@artists,
    );
    $self->stash(events => \@events);
    if ($is_ajax) {
        $self->stash(
            artists_sel => [],
            country_sel => [],
        );
    }
    else {
        $self->_artist_sel();
        $self->_country_sel();
    }
    $self->stash(extra_js => '/js/event-list.js');
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

sub _country_sel {
    my $self = shift;
    my @c;
    for ($self->model->country->search(undef, { order_by => 'id'})->all) {
        push @c, [$_->name, $_->id];
    }
    $self->stash(country_sel => \@c);
}

1;
