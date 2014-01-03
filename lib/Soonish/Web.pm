package Soonish::Web;
use Mojo::Base 'Mojolicious';

use 5.014;
use strict;
use warnings;
use utf8;

use Soonish qw/model/;

# This method will run once at server start
sub startup {
    my $self = shift;

    $self->plugin(
        moz_persona => {
            audience => Soonish::config('site_url'),
            siteName => 'Umkreissuche nach Events',
            autoHook => {
                css     => 1,
                persona => 1,
                local   => 1,
                uid     => 1,
                jquery  => 0,
            },
        }
    );

    $self->helper(model => sub {
        state $model = model();
    });

    $self->secrets([Soonish::config('secret')]);

    # Router
    my $r = $self->routes->under(sub {
        my $c = shift;
        if ($c->session('_persona') && $c->session('_persona')->{status} eq 'okay') {
            my $login_rs = $c->model->login;
            my $email    = $c->session('_persona')->{email};
            my $login    = $login_rs->find_or_create(
                { email => $email },
            );
            $c->stash(login => $login);
        }
        return 1;
    });

    $r->get('/')->to('event#list');
    $r->get('/zipcode')->to('zipcode#query');
    $r->get('/proximity')->to('zipcode#proximity');
    $r->get('/feed/atom')->to('feed#atom');
}

1;
