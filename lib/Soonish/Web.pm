package Soonish::Web;
use Mojo::Base 'Mojolicious';
use Soonish qw/model/;

# This method will run once at server start
sub startup {
    my $self = shift;

    $self->helper(model => sub {
        state $model = model();
    });

    # Router
    my $r = $self->routes;

    $r->get('/')->to('event#list');
    $r->get('/zipcode')->to('zipcode#query');
}

1;
