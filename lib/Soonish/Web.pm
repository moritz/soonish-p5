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

    my $debug_email;
    if ($self->mode eq 'development' && $ENV{SOONISH_DEV}) {
        warn "In debug mode, automatically logging in admin";
        $debug_email = Soonish::config('admin_email');
    }
    else {
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
    }

    $self->helper(model => sub {
        state $model = model();
    });

    $self->secrets([Soonish::config('secret')]);
    my $is_dev = $self->mode eq 'development';

    # Router
    my $r = $self->routes->under(sub {
        my $c = shift;
        $c->stash(imprint_url => Soonish::config('imprint_url'));
        $c->stash(is_dev => $is_dev);
        if ($debug_email || ($c->session('_persona') && $c->session('_persona')->{status} eq 'okay')) {
            my $login_rs = $c->model->login;
            my $email    = $debug_email || $c->session('_persona')->{email};
            my $login    = $login_rs->find_or_create(
                { email => $email },
            );
            $c->stash(login => $login);
            $c->stash(is_admin => $login->is_admin);
        }
        return 1;
    });

    $r->get('/')->to('event#list');
    $r->get('/event/:id', [id => qr/\d+/])->to('event#details');
    $r->get('/zipcode')->to('zipcode#query');
    $r->get('/zipcode/search')->to('zipcode#search');
    $r->get('/proximity')->to('zipcode#proximity');
    $r->get('/feed/atom')->to('feed#atom');

    $r->get('/channel/list')->to('channel#list');
    $r->post('/channel/save')->to('channel#save');
    $r->post('/channel/delete')->to('channel#delete');

    $r->get('/artist')->to('artist#list');
    $r->get('/artist/:id', [id => qr/\d+/])->to('artist#details')->name('artist_details');

    $r->get('/location')->to('location#list')->name('location_list');
    $r->get('/location/:id', [id => qr/\d+/])->to('location#details');

    $r->get('/about')->to('static#about');

    my $admin = $r->under('', sub {
        my $c         = shift;
        my $login     = $c->stash('login');
        my $is_admin  = $login->is_admin;
        return 1 if $is_admin;
        return undef;
    });
    $admin->post('/location/merge')->to('location#merge')->name('location_merge');
}

1;
