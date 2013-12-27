package Soonish::Web::Feed;

use Mojo::Base 'Mojolicious::Controller';
use XML::Atom::SimpleFeed;
use Data::UUID;

sub atom {
    my $self        = shift;
    my @artists     = grep /^\d+\z/, split /\,/, $self->param('a') // '';
    my $url         = $self->req->url;
    my $zipcode     = $self->param('z');
    my $distance    = $self->param('d') // 50;

    my $canonical = join('/',
        $zipcode // '',
        $distance // '',
        join(',', sort { $a <=> $b } @artists),
    );
    my $duid = Data::UUID->new();
    my $feed_id = $duid->to_string($duid->create_from_name('https://github.com/moritz/soonish-p5/', $canonical));

    my $link = $url->clone;
    $link->path('/');
    $link->query(
        artist      => \@artists,
        plz         => $zipcode // '',
        distance    => $distance,
    );

    my $title;
    if ($zipcode && (my $geo = $self->model->geo->find({plz99 => $zipcode}))) {
        $title = sprintf 'Veranstaltungen bei %05d %s (%d km)',
            $zipcode, $geo->city, $distance;
    }
    else {
        $title = 'Veranstaltungen';
    }

    my $feed = XML::Atom::SimpleFeed->new(
        title   => $title,
        author  => 'Moritz Lenz',
        id      => $feed_id,
        link    => $link->to_abs,
    );

    my @events = $self->model->event->close_to(
        zipcode     => $zipcode,
        distance    => $distance,
        artists     => \@artists,
    );
    for my $e (@events) {
        my @name_chunks = ($e->artist->name);
        if (defined(my $n = $e->name)) {
            push @name_chunks, qq["$n"];
        }
        push @name_chunks, $e->formatted_date;
        push @name_chunks, 'am', $e->location->zipcode, $e->location->city;

        $feed->add_entry(
            title => join(' ', @name_chunks),
            link  => $e->url // $e->buy_url // 'http://example.org/',
            category => $e->artist->name,
        );
    }
    $self->render(text => $feed->as_string, format => 'atom');
}

1;
