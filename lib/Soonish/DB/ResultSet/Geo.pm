package Soonish::DB::ResultSet::Geo;

use parent 'DBIx::Class::ResultSet';

use 5.014;
use utf8;
use warnings;

sub autosearch {
    my ($self, $term, $page) = @_;
    $page //= 1;
    if ($term =~ /^[0-9]{1,5}\z/) {
        return $self->search(
            { plz99 => { like => "$term%" } },
            {
                order_by => 'plz99',
                rows     => 25,
                page     => $page,
                prefetch => 'country',
            }
        );
    }
    else {
        # TODO: escaping of $term?
        return $self->search(
            { plzort99 => { ilike => "$term%" } },
            {
                order_by => 'plzort99',
                rows     => 25,
                page     => $page,
                prefetch => 'country',
            }
        );
    }

}


1;
