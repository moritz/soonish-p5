package Soonish::DB::Result::Geo;

use 5.014;
use warnings;
use utf8;

use parent qw/DBIx::Class::Core/;

__PACKAGE__->table('post_code_areas');
__PACKAGE__->add_columns(
    gid => {
        data_type           => 'integer',
        is_nullable         => 0,
        is_numeric          => 1,
        retrieve_on_insert  => 1,
        accessor            => 'id',
    },
    plz99   => {
        is_nullable         => 0,
        accessor            => 'zipcode',
    },
    plz99_n => {
        is_nullable         => 0,
        accessor            => 'zipcode_numeric',
    },
    plzort99 => {
        accessor            => 'city',
    },
);

__PACKAGE__->set_primary_key('plz99');

1;
