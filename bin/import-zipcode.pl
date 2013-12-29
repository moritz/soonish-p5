#!/usr/bin/env perl
#
# import zip code files from http://download.geonames.org/export/
use 5.014;
use warnings;
use autodie;
binmode STDOUT, ':encoding(UTF-8)';

use lib 'lib';

use Soonish qw/model get_dbh/;

my $dbh = get_dbh();

my $sth = $dbh->prepare('INSERT INTO post_code_areas
    (plz99, plz99_n, plzort99, loc_center, country)
    VALUES(?, ?, ?, ST_POINT(?, ?), ?)');

for my $cc ('at', 'ch') {
    my %seen;
    my $fn = uc($cc) . '.txt';
    my $country = $cc eq 'at' ? 2 : 3;
    open my $IN, '<:encoding(UTF-8)', $fn;
    while (my $line = <$IN>) {
        chomp $line;
        my (undef, $zipcode, $name, undef, undef, undef, undef, undef, undef,
            $lat, $lon) = split /\t/, $line;
        next if $seen{$zipcode}++;
        $sth->execute($zipcode, $zipcode, $name, $lon, $lat, $country);
    }
}
$sth->finish;
