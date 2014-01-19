package Soonish::Web::Channel;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::URL;
use 5.014;
use utf8;
use warnings;

sub save {
    my $self  = shift;
    my $login = $self->stash('login');
    my $id    = $self->param('channel_id');
    my $name  = $self->param('channel-name');

    unless ($login) {
        $self->render(
            status  => 401,
            json    => { error => 'Bitte zuerst einloggen' },
        );
        return;
    }

    my %ch;
    for (qw/country zipcode distance/) {
        $ch{$_} = $self->param($_);
    }
    if (my $loc = $self->param('location')) {
        @ch{'country', 'zipcode'} = split /-/, $loc;
    }
    $ch{name} = $name if length $name;

    my $channel;
    if ($id) {
        $channel = $login->channels->find({ id => $id});
        unless ($channel) {
            return $self->_error('Suche nicht gefunden');
        }
        $channel->update(\%ch);
    }
    else {
        my $channel_rs = $self->model->channel;
        if (my $id = $self->param('channel')) {
            $channel = $channel_rs->find({id => $id, login => $login->id});
            $channel->update(\%ch);
        }
        elsif (length(my $name = $self->param('channel-name'))) {
            if ($channel_rs->find({ login => $login->id, name => $name })) {
                $self->render(
                    status  => 500,
                    json    => { error => 'Eine Suche dieses Namens gibt es bereits' },

                );
                return;
            }
            # TODO: auto-generate better channel name
            $ch{name} ||= 'unbenannte Suche ' . int(10_000 * rand);
            $channel = $channel_rs->create({
                    login   => $login->id,
                    %ch,
            });
        }
    }
    $channel->set_artist_ids([$self->param('artist')]);
    $self->render(json => {
        id      => $channel->id,
        name    => $channel->name,
        nonce   => $channel->nonce,
    });
}

sub list {
    my $self  = shift;
    my $login = $self->stash('login');
    return $self->_error('Bitte zuerst einloggen') unless $login;
    my $feed_url = $self->req->url->clone->path('/feed/atom');
    $self->stash(
        channels => [$login->search_related('channels', undef,
            {
                order_by => 'me.name',
                prefetch => { artist_channel => 'artist' },
            },
        )],
        extra_js => '/js/channel.js',
        feed_url => $feed_url,
    );
}

sub delete {
    my $self  = shift;

    my $login = $self->stash('login');
    return $self->_error('Bitte zuerst einloggen') unless $login;

    my $id      = $self->param('id');
    my $channel = $self->model->channel->find({ id => $id});
    return $self->_error('Objekt nicht gefunden', 404) unless $channel;

    if ($channel->get_column('login') != $login->id) {
        return $self->_error('ts ts ts.');
    }

    $channel->search_related('artist_channel')->delete;
    $channel->delete;
    $self->render(json => { ok => 1 });
}

sub _error {
    my ($self, $error, $status) = @_;
    $status //= 400;
    $self->render(
        status  => $status,
        json    => { error => $error },
    );
}

1;
