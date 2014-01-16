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
    if (my $loc = $self->param('location')) {
        ($country, $zipcode) = split /-/, $loc;
    }
    my @artists = $self->param('artist');
    if (my $nonce = $self->param('nonce')) {
        my $channel = $self->model->channel->find({nonce => $nonce});
        if ($channel) {
            $country  = $channel->country_id if $channel->country_id;
            $zipcode  = $channel->zipcode    if $channel->zipcode;
            $distance = $channel->distance   if $channel->distance;
            my @a     = $channel->artist_ids;
            @artists  = @a if @a;
        }
    }
    $self->stash(country  => $country);
    $self->stash(distance => $distance);
    $self->stash(zipcode => $zipcode);
    my @events = $self->model->event->close_to(
        country     => $country,
        zipcode     => $zipcode,
        distance    => $distance,
        artist      => \@artists,
    );
    $self->stash(events => \@events);
    if ($is_ajax) {
        $self->render('event/list');
    }
    else {
        $self->_artist_sel();
        $self->_country_sel();
        $self->stash(extra_js => '/js/event-list.js');
        $self->render('event/index');
    }
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

sub details {
    my $self = shift;

    my $event = $self->model->event->find(
        { id => $self->param('id') },
        { prefetch => ['artist', { location => 'country' } ] },
    );
    unless ($event) {
        $self->render(status => 404, message => 'Event nicht gefunden');
        return;
    }
    $self->stash(event => $event);
    $self->render();
}

1;
