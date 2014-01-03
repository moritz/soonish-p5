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

    my %search = (
        start_date => { '>='    => \'NOW()', },
    );

    if ($param{zipcode}) {
        my $subsel = $self->result_source->schema->resultset('GeoProximity')->search(
            undef,
            {
                bind => [$param{country} // 1, $param{zipcode}, $param{distance}],
            }
        )->as_query;
        $search{'location.zipcode'} = { IN =>  $subsel };
    }

    if ($param{artist} &&  @{ $param{artist} }) {
        $search{'artist.id'} = { IN => $param{artist} };
    }

    $self->search(
        \%search,
        {
            prefetch => [
                'artist',
                'location',
            ],
            order_by => {
                -asc => 'start_date',
            }
        }
    );
}


1;
