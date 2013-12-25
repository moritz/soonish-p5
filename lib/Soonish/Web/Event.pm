package Soonish::Web::Event;
use Mojo::Base 'Mojolicious::Controller';
use utf8;
use 5.014;
use warnings;

sub list {
    my $self = shift;
    my $zipcode  = $self->param('plz');
    my $distance = $self->param('distance') // 50;
    $self->stash(distance => $distance);
    $self->stash(ajax => 1) if $self->param('ajax');
    my @events;
    if ($zipcode) {
        @events = $self->model->event->close_to(
            zipcode     => $zipcode,
            distance    => $distance,
        );
        $self->stash(close_to => $self->model->resultset('Geo')->find($zipcode));
    }
    else {
        @events   = $self->model->event->search(
            {
                start_date => {
                    '>='    => \'NOW()',
                },
            },
            {
                limit => 100,
                prefetch => [
                    'artist',
                    'location',
                ],
                order_by => {
                    -asc => 'start_date',
                },
            },
        )->all;
    }
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
