package Soonish::Web::Event;
use Mojo::Base 'Mojolicious::Controller';
use utf8;
use 5.014;
use warnings;

sub list {
    my $self = shift;
    my $zipcode  = $self->param('plz');
    my $distance = $self->param('d') // 50;
    $self->stash(distance => $distance);
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
    $self->render();
};

1;
