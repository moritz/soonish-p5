package Soonish::DB::Result::Location;

use 5.014;
use warnings;
use utf8;

use parent qw/DBIx::Class::Core/;

__PACKAGE__->table('location');
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
    address => {
        is_nullable         => 0,
    },
    city => {
        is_nullable         => 0,
    },
    zipcode => {
        is_nullable         => 0,
    },
    country => {
        is_nullable         => 0,
    },
    url => {
        is_nullable         => 1,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint([ qw/name address zipcode/] );

__PACKAGE__->belongs_to(geo => 'Soonish::DB::Result::Geo', 'zipcode');
__PACKAGE__->belongs_to(country => 'Soonish::DB::Result::Country', 'country');
__PACKAGE__->has_many(events => 'Soonish::DB::Result::Event', 'location');

sub country_id {
    shift->get_column('country');
}

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

sub merge_into {
    my ($self, $other) = @_;
    $self->events->update_all({ location => $other->id });
    $self->delete;
}

1;
