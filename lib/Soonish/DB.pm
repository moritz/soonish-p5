package Soonish::DB;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces();

sub event    { $_[0]->resultset('Event'   ) }
sub artist   { $_[0]->resultset('Artist'  ) }
sub provider { $_[0]->resultset('Provider') }
sub location { $_[0]->resultset('Location') }
sub geo      { $_[0]->resultset('Geo'     ) }
sub login    { $_[0]->resultset('Login'   ) }
sub country  { $_[0]->resultset('Country' ) }

1;
