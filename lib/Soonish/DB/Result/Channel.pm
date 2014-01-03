package Soonish::DB::Result::Channel;

use 5.014;
use warnings;
use utf8;

use parent qw/DBIx::Class::Core/;

__PACKAGE__->table('channel');
__PACKAGE__->add_columns(
    id => {
        data_type           => 'integer',
        is_nullable         => 0,
        is_numeric          => 1,
        retrieve_on_insert  => 1,
    },
    name  => {
        is_nullable         => 0,
    },
    nonce => {
        is_nullable         => 0,
        retrieve_on_insert  => 1,
        data_type           => 'integer',
        is_numeric          => 1,
    },
    'zipcode',
    'country',
    'distance',
    login   => {
        is_nullable         => 0,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(login => 'Soonish::DB::Result::Login', 'login');
#__PACKAGE__->has_many(artist_login => 'Soonish::DB::Result::ArtistLogin', 'login');
#__PACKAGE__->many_to_many(artists => artist_login => 'artist');

1;
