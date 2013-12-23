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
    zipcode => {
        is_nullable         => 0,
    },
    url => {
        is_nullable         => 1,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint([ qw/name address zipcode/] );

1;
