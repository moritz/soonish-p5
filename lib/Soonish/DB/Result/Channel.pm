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
__PACKAGE__->belongs_to(country => 'Soonish::DB::Result::Country', 'country');
__PACKAGE__->add_unique_constraint(login_name => ['login', 'name']);
__PACKAGE__->has_many(artist_channel => 'Soonish::DB::Result::ArtistChannel', 'channel');
__PACKAGE__->many_to_many(artists => artist_channel => 'artist');

sub country_id {
    shift->get_column('country');
}

sub artist_ids {
    my $self = shift;
    map $_->get_column('artist'),
        $self->search_related('artist_channel')->all;
}

sub set_artist_ids {
    my ($self, $new) = @_;
    unless (@$new) {
        $self->search_related('artist_channel')->delete;
        return;
    }
    my %exists;
    my @to_add;
    my @artists = $self->artist_ids;
    $exists{@artists} = (1) x @artists;
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
        })->delete_all;
    }
    for (@to_add) {
        $self->create_related('artist_channel', {
            artist  => $_,
        });
    }
    return 1;
}

1;
