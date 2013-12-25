package Soonish::Web::Feed;

use Mojo::Base 'Mojolicious::Controller';
use XML::Atom::SimpleFeed;
use Data::UUID;

sub atom {
    my $self        = shift;
    my @artists     = grep /^\d+\z/, split /\,/, $self->param('a') // '';
    my $zipcode     = $self->param('z');
    my $distance    = $self->param('d');

    my $canonical = join('/',
        $zipcode // '',
        $distance // '',
        join(',', sort { $a <=> $b } @artists),
    );
    my $duid = Data::UUID->new();
    my $feed_id = $duid->to_string($duid->create_from_name('https://github.com/moritz/soonish-p5/', $canonical));

    my $feed = XML::Atom::SimpleFeed->new(
        title   => "Umkreissuche nach Events",
        author  => 'Moritz Lenz',
        id      => $feed_id,
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
