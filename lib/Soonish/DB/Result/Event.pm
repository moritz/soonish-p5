package Soonish::DB::Result::Event;

use 5.014;
use warnings;
use utf8;

use parent qw/DBIx::Class::Core/;

__PACKAGE__->table('event');
__PACKAGE__->add_columns(
    id  => {
        data_type           => 'integer',
        is_nullable         => 0,
        is_numeric          => 1,
        retrieve_on_insert  => 1,
    },
    name => {
        is_nullable         => 1,
    },
    location    => {
        is_nullable         => 0,
        is_numeric          => 1,
    },
    artist    => {
        is_nullable         => 0,
        is_numeric          => 1,
    },
    provider  => {
        is_nullable         => 0,
        is_numeric          => 1,
    },
    start_date  => {
        is_nullable         => 0,
    },
    internal_id  => {
        is_nullable         => 1,
    },
    url         => {
        is_nullable         => 1,
    },
    buy_url         => {
        is_nullable         => 1,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['internal_id', 'provider']);
__PACKAGE__->belongs_to(location => 'Soonish::DB::Result::Location', 'location');
__PACKAGE__->belongs_to(artist => 'Soonish::DB::Result::Artist', 'artist');
__PACKAGE__->belongs_to(provider => 'Soonish::DB::Result::Provider', 'provider');

sub formatted_date {
    my $self = shift;
    my $date = $self->start_date;
    1 while $date =~ s/:00$//;
    $date =~ s/\s+$//;
    unless ($date =~ s/ 00$//) {
        $date .= 'h';
    }
    return $date;
}

1;
