#!/usr/bin/env perl
use 5.014;
use warnings;
use utf8;
binmode STDOUT, ':encoding(UTF-8)';

use Encode qw/decode_utf8/;
use lib 'lib';
use Soonish qw/model/;
use Mojo::URL;

my $schema = model();

my $provider = $schema->provider->find_or_create({ name => 'Reinhard Mey Crawler' });

my $artist = $schema->artist->find_or_create({
    name    => 'Reinhard Mey',
    url     => 'http://www.reinhard-mey.de/start/',
});

use Mojo::UserAgent;
my $ua = Mojo::UserAgent->new;

my %seen;

for my $page (1..3) {
    my $url = "http://www.mey-tickets.de/index.php?view=list_tours&id=4&page=$page";
    my $uri = Mojo::URL->new($url);
    my $dom = $ua->get($url)->res->dom;
    $dom->find('a.button')->each(sub {
        my $d = shift;
        my $url = Mojo::URL->new($d->attr('href'))->to_abs($uri);
        scrape($url) unless $seen{$url}++;
    });
};

sub scrape {
    my $url = shift;
    state $ua = Mojo::UserAgent->new;
    my $dom  = $ua->get($url)->res->dom->at('div.carousel-caption');
    my (undef, $p)  = $dom->find('p')->each;
    my $addr = $p->all_text();
    $addr =~ s/^[^:]+:\s*//;
    my @addr_chunk = split /,\s*/, $addr;
    splice(@addr_chunk, 1, 1) if @addr_chunk > 3;
    my ($loc_name, $address, $city) = @addr_chunk;
    (my $zipcode, $city) = split ' ', $city, 2;
    return unless $dom->at('h4')->text() =~ /(\d{1,2})\.(\d{1,2})\.(\d{4}) (\d\d:\d\d)/;
    my $date = sprintf '%04d-%02d-%02d %s', $3, $2, $1, $4;
    my $internal_id = join '/', $city, $date;

    my $event = $schema->event->find({
        provider    => $provider->id,
        internal_id => $internal_id,
    });
    return if $event;
#    use Data::Dumper; print Dumper {
#        name    => $loc_name,
#        address => $address,
#        zipcode => $zipcode,
#        city    => $city,
#        url     => "$url",
#    };
    my $location = $schema->location->find_or_create({
        name    => $loc_name,
        address => $address,
        zipcode => $zipcode,
        city    => $city,
    });
    $event = $schema->event->create({
        provider    => $provider->id,
        location    => $location->id,
        artist      => $artist->id,
        start_date  => $date,
        url         => $url,
        internal_id => $internal_id,
    });
    say $internal_id;
}
