package Soonish::DB::Result::ArtistChannel;

use 5.014;
use warnings;
use utf8;

use parent qw/DBIx::Class::Core/;

__PACKAGE__->table('artist_channel');
__PACKAGE__->add_columns(
    id => {
        data_type           => 'integer',
        is_nullable         => 0,
        is_numeric          => 1,
        retrieve_on_insert  => 1,
    },
    artist   => {
        is_nullable         => 0,
    },
    channel   => {
        is_nullable         => 0,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(artist_channel => ['artist', 'channel']);
__PACKAGE__->belongs_to(artist  => 'Soonish::DB::Result::Artist',  'artist');
__PACKAGE__->belongs_to(channel => 'Soonish::DB::Result::Channel', 'channel');

1;
