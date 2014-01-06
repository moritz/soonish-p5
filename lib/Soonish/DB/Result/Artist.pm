package Soonish::DB::Result::Artist;

use 5.014;
use warnings;
use utf8;

use parent qw/DBIx::Class::Core/;

__PACKAGE__->table('artist');
__PACKAGE__->add_columns(
    id  => {
        data_type           => 'integer',
        is_nullable         => 0,
        is_numeric          => 1,
        retrieve_on_insert  => 1,
    },
    name => {
        is_nullable         => 0,
    },
    url => {
        is_nullable         => 1,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many('events', 'Soonish::DB::Result::Event', 'artist');

sub future_events {
    my $self = shift;
    $self->search_related(
        'events',
        { start_date => { '>=', \'NOW()' } },
        {
            order_by => 'start_date',
            prefetch => 'location',
        },
    );
}

1;
