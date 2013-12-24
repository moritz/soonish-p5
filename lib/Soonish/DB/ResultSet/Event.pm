package Soonish::DB::ResultSet::Event;

use parent 'DBIx::Class::ResultSet';

use 5.014;
use utf8;
use warnings;

sub close_to {
    my ($self, %param) = @_;
    # conversion from km to m:
    $param{distance} //= 50;
    $param{distance} *= 1000;

    my $subsel = $self->result_source->schema->resultset('GeoProximity')->search(
        undef,
        {
            bind => [$param{zipcode}, $param{distance}],
        }
    )->as_query;


    $self->search(
        {
            'location.zipcode' => {
                IN =>  $subsel,
            },
            start_date => {
                '>='    => \'NOW()',
            },
        },
        {
            prefetch => [
                'artist',
                {location => 'geo'},
            ],
            order_by => {
                -asc => 'start_date',
            }
        }
    );

}


1;
