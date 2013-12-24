package Soonish::Web::Event;
use Mojo::Base 'Mojolicious::Controller';
use utf8;
use 5.014;
use warnings;

sub list {
    my $self = shift;
    my $zipcode  = $self->param('plz');
    my $distance = $self->param('d') // 50;
    my @events;
    if ($zipcode) {
        @events = $self->model->event->close_to(
            zipcode     => $zipcode,
            distance    => $distance,
        );
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
                    { location => 'geo', },
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
