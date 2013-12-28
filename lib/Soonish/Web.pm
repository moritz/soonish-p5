package Soonish::Web;
use Mojo::Base 'Mojolicious';

use 5.014;
use strict;
use warnings;
use utf8;

use Soonish qw/model config/;

# This method will run once at server start
sub startup {
    my $self = shift;

    $self->helper(model => sub {
        state $model = model();
    });

    $self->secrets(config 'secret');

    # Router
    my $r = $self->routes;

    $r->get('/')->to('event#list');
    $r->get('/zipcode')->to('zipcode#query');
    $r->get('/feed/atom')->to('feed#atom');
}

1;
