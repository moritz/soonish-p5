package Soonish::DB::Result::Country;

use 5.014;
use warnings;
use utf8;

use parent qw/DBIx::Class::Core/;

__PACKAGE__->table('country');
__PACKAGE__->add_columns(
    id  => {
        data_type           => 'integer',
        is_nullable         => 0,
        is_numeric          => 1,
        retrieve_on_insert  => 1,
    },
    'cc2', 'cc3',
    name    => {
        is_nullable         => 0,
    },
    name_english => {
        is_nullable         => 0,
    },
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(name => ['name']);
__PACKAGE__->add_unique_constraint(cc2 => ['cc2']);
__PACKAGE__->add_unique_constraint(cc3 => ['cc3']);

1;
