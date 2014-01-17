package Soonish::Web::Feed;

use Mojo::Base 'Mojolicious::Controller';
use XML::Atom::SimpleFeed;
use Data::UUID;
use Mojo::Parameters;

sub uuid {
    my ($ns, $val) = @_;
    state $duid = Data::UUID->new();

    return $duid->to_string(
        $duid->to_string(
            $duid->create_from_name(
                'https://github.com/moritz/soonish-p5/' . ($ns // ''),
                $val,
            ),
        ),
    );
}

sub atom {
    my $self        = shift;
    my $url         = $self->req->url;
    my %params;
    my $name;
    if (my $nonce = $self->param('nonce')) {
        my $channel = $self->model->channel->find({ nonce => $nonce });
        %params     = (
            country     => $channel->country_id,
            zipcode     => $channel->zipcode,
            distance    => $channel->distance,
        );
        $params{artist} = [ $channel->artist_ids ];
        $name = $channel->name;
    }
    else {
        $params{artist}  = [grep /^\d+\z/, split /\,/, $self->param('a') // ''];
        $params{country} = $self->param('c') // 1;
        $params{zipcode} = $self->param('z') // '';
        $params{distance}= $self->param('d') // 50;
    };
    my $canonical = join('/',
        @params{qw/country zipcode distance/},
        join(',', sort { $a <=> $b } @{ $params{artist} }),
    );
    my $feed_id = uuid('', $canonical);

    my $link = $url->clone;
    $link->path('/');
    $link->query(Mojo::Parameters->new);

    my $title;
    if ($params{zipcode} && (my $geo = $self->model->geo->find({plz99 => $params{zipcode}}))) {
        $title = sprintf 'Veranstaltungen bei %05d %s (%d km)',
            $params{zipcode}, $geo->city, $params{distance};
        $title = "$name - $title" if $name;
    }
    else {
        $title = $name // 'Veranstaltungen';
    }

    my $feed = XML::Atom::SimpleFeed->new(
        title   => $title,
        author  => 'Moritz Lenz',
        id      => $feed_id,
        link    => $link->to_abs,
    );

    my @events = $self->model->event->close_to( %params );
    for my $e (@events) {
        my @name_chunks = ($e->artist->name);
        if (defined(my $n = $e->name)) {
            push @name_chunks, qq["$n"];
        }
        push @name_chunks, 'am', $e->formatted_date;
        push @name_chunks, 'in', $e->location->zipcode, $e->location->city;

        my $l = $link->clone();
        $l->path('/event/' . $e->id);
        $l->query(Mojo::Parameters->new);

        $feed->add_entry(
            title => join(' ', @name_chunks),
            link  => $l->to_abs,
            category => $e->artist->name,
            id    => uuid('event', $e->id),
        );
    }
    $self->render(text => $feed->as_string, format => 'atom');
}

1;
