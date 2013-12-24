#!/usr/bin/env perl
use 5.014;
use warnings;
use utf8;
binmode STDOUT, ':encoding(UTF-8)';

use lib 'lib';
use Soonish qw/model/;
use Mojo::URL;

my $schema = model();

my $provider = $schema->provider->find({ name => 'Wise Guys Crawler' });
unless ($provider) {
    $provider = $schema->provider->create({
            name        => 'Wise Guys Crawler',
            description => 'Automatically extracts event data from http://wiseguys.de/konzerte',
    });
}

my $artist = $schema->artist->find({ name => 'Wise Guys' });
unless ($artist) {
    $artist = $schema->artist->create({
        name    => 'Wise Guys',
        url     => 'http://wiseguys.de/',
    });
}

use Mojo::UserAgent;
my $ua = Mojo::UserAgent->new;
my $url = 'http://wiseguys.de/konzerte';
my $uri = Mojo::URL->new($url);
my $dom = $ua->get($url)->res->dom;
$dom->find('tr div')->each(sub {
    my $d = shift;
    my $internal_id = $d->attr->{'id'};
    if (defined $internal_id && $internal_id =~ /^konzert/) {
        my $event = $schema->event->find({
            provider    => $provider->id,
            internal_id => $internal_id,
        });
        return if $event;
        $d = $d->at('div.media-body');
        return unless $d;
        my $link = $d->at('a')->attr->{href};
        if ($link) {
            $link = Mojo::URL->new($link)->to_abs($uri);
            say "Link: $link";
        }
        my $rest = $d->at('p');
        my $buy_url = eval {
            $d->at('a[target="_blank"]')->attr->{href};
        };
        warn $@ if $@;
        say $buy_url if $buy_url;
        if ($rest =~ m{<p>(.*)\n(.*?), (\d+) .*?\| \w+, (\d+)\.(\d+).(\d+), (\d+) Uhr}) {
            my ($loc_name, $address, $zip) = ($1, $2, $3);
            my $date = "$6-$5-$4 $7:00";
            return if length($zip) != 5;
            my $location = $schema->location->find_or_create({
                name    => $loc_name,
                address => $address,
                zipcode => $zip,
            });
            $event = $schema->event->create({
                provider    => $provider->id,
                location    => $location->id,
                artist      => $artist->id,
                start_date  => $date,
                url         => $link,
                buy_url     => $buy_url,
            });
        }
    }
});
