package Soonish::DB::Result::ChannelLogin;

use 5.014;
use warnings;
use utf8;

use parent qw/DBIx::Class::Core/;

__PACKAGE__->table('channel_login');
__PACKAGE__->add_columns(
    id => {
        data_type           => 'integer',
        is_nullable         => 0,
        is_numeric          => 1,
        retrieve_on_insert  => 1,
    },
    channel   => {
        is_nullable         => 0,
    },
    login   => {
        is_nullable         => 0,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(artist_login => ['channel', 'login']);
__PACKAGE__->belongs_to(channel => 'Soonish::DB::Result::Channel', 'channel');
__PACKAGE__->belongs_to(login   => 'Soonish::DB::Result::Login',   'login');

1;
