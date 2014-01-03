package Soonish::Web::Channel;

use Mojo::Base 'Mojolicious::Controller';
use 5.014;
use utf8;
use warnings;

sub save {
    my $self  = shift;
    my $login = $self->stash('login');
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
    $ch{name} = $name if length $name;

    my $channel_rs = $self->model->channel;
    my $channel;
    if (my $id = $self->param('channel')) {
        $channel = $channel_rs->find({id => $id});
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
    $channel->set_artists([$self->param('artist')]);
    $self->render(json => {
        name    => $channel->name,
        nonce   => $channel->nonce,
    });
}

1;
