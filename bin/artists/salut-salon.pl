#!/usr/bin/env perl
use 5.014;
use warnings;
use utf8;
#binmode STDOUT, ':encoding(UTF-8)';

use Encode qw/decode_utf8/;
use lib 'lib';
use Soonish qw/model/;
use Mojo::URL;

my $schema = model();

my $provider = $schema->provider->find_or_create({ name => 'Salut Salon Crawler' });

my $artist = $schema->artist->find({ name => 'Salut Salon' });
unless ($artist) {
    $artist = $schema->artist->create({
        name    => 'Salut Salon',
        url     => 'http://www.salutsalon.de/',
    });
}

my $country = $schema->country->find({cc2 => 'de'});

use Mojo::UserAgent;
my $ua = Mojo::UserAgent->new;
my $url = 'http://www.salutsalon.de/05-tour-1.php';
my $uri = Mojo::URL->new($url);
my $dom = $ua->get($url)->res->dom;
$dom->at('td.inhalt')->find('table')->each(sub {
    my $d = shift;
    my $date = $d->at('h4')->text();
    my ($day, $month, $year) = split /\./, $date;
    my $isodate = join '-', $year, $month, $day;
    use Data::Dumper;
    $Data::Dumper::Useqq = 1;
    my $rest = $d->at('td[width="390"]');
    $rest =~ s{</?td.*?>}{}g;
    my ($time, $loc_name, $address, $city) = map decode_utf8($_),
                                             split m{<br />}, $rest;
    $time =~ s/ Uhr//;
    $time =~ s/\./:/g;
    $isodate .= " $time";
    my $buy_url = $d->at('a.shapelinks')->attr->{href};
    (my $zipcode, $city) = split ' ', $city, 2;
    my $internal_id = "salutsalon-$isodate";
    my $event = $schema->event->find({
        provider    => $provider->id,
        internal_id => $internal_id,
    });
    return if $event;
    my $location = $schema->location->find_or_create({
        name    => $loc_name,
        address => $address,
        zipcode => $zipcode,
        city    => $city,
        country => $country->id,
    });
    $event = $schema->event->create({
        provider    => $provider->id,
        location    => $location->id,
        artist      => $artist->id,
        start_date  => $isodate,
        url         => 'http://www.salutsalon.de/05-tour-1.php',
        buy_url     => $buy_url,
    });
});
