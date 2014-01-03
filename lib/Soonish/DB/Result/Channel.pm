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
__PACKAGE__->add_unique_constraint(login_name => ['login', 'name']);
__PACKAGE__->has_many(artist_channel => 'Soonish::DB::Result::ArtistChannel', 'channel');
#__PACKAGE__->has_many(artist_login => 'Soonish::DB::Result::ArtistLogin', 'login');
#__PACKAGE__->many_to_many(artists => artist_login => 'artist');

sub set_artists {
    my ($self, $new) = @_;
    unless (@$new) {
        $self->search_related('artist_channel')->delete;
        return;
    }
    my %exists;
    my @to_add;
    for ($self->search_related('artist_channel')->all) {
        $exists{ $_->get_column('artist') } = 1;
    }
    for (@$new) {
        if (delete $exists{$_}) {
            # nothing to be done
        }
        else {
            push @to_add, $_;
        }
    }
    if (keys %exists) {
        $self->search_related('artist_channel', {
            artist  => { IN => [keys %exists] },
        });
    }
    for (@to_add) {
        $self->create_related('artist_channel', {
            artist  => $_,
        });
    }
    return 1;
}

1;