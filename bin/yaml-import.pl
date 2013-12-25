#!/usr/bin/env perl
use 5.014;
use warnings;
use utf8;
binmode STDOUT, ':encoding(UTF-8)';

use lib 'lib';
use Soonish qw/model/;
use YAML qw/LoadFile/;
use Encode qw/decode_utf8/;

my $schema = model();

my $data = LoadFile shift(@ARGV) // 'import.yaml';

my $provider = $schema->provider->find_or_create( { name => 'YAML import' });

my %artists;
while (my ($k, $a) = each %{ $data->{artists} }) {
    $artists{$k} = $schema->artist->find_or_create({
        name    => decode_utf8($a->{name}),
        url     => decode_utf8($a->{url}),
    });
}

for my $c (@{ $data->{concerts} }) {
    my $internal_id = decode_utf8($c->{internal_id} // die 'Missing internal_id');
    my $event = $schema->event->find({
        provider    => $provider->id,
        internal_id => $internal_id,
    });
    next if $event;
    my $l = $c->{location};
    use Data::Dumper;
    $Data::Dumper::Useqq = 1;
    print Dumper $l;
    my $location = $schema->location->find_or_create($l);
    $event = $schema->event->create(
        {
            provider    => $provider->id,
            internal_id => $internal_id,
            location    => $location->id,
            artist      => $artists{ $c->{artist} }->id,
            start_date  => $c->{start_date},
            url         => $c->{url},
            buy_url     => $c->{buy_url},
            name        => $c->{name},
        },
    );
    say $event;
};

