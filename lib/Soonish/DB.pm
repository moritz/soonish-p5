package Soonish::DB;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces();

sub event    { $_[0]->resultset('Event'   ) }
sub artist   { $_[0]->resultset('Artist'  ) }
sub provider { $_[0]->resultset('Provider') }
sub location { $_[0]->resultset('Location') }

1;
