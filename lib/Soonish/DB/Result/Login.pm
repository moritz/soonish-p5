package Soonish::DB::Result::Login;

use 5.014;
use warnings;
use utf8;

use parent qw/DBIx::Class::Core/;

__PACKAGE__->table('login');
__PACKAGE__->add_columns(
    id => {
        data_type           => 'integer',
        is_nullable         => 0,
        is_numeric          => 1,
        retrieve_on_insert  => 1,
    },
    email   => {
        is_nullable         => 0,
    },
    nonce => {
        is_nullable         => 0,
        retrieve_on_insert  => 1,
        data_type           => 'integer',
        is_numeric          => 1,
    },
    created => {
        is_nullable         => 0,
        retrieve_on_insert  => 1,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(artist_login => 'Soonish::DB::Result::ArtistLogin', 'login');
__PACKAGE__->many_to_many(artists => artist_login => 'artist');

1;
