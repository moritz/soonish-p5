package Soonish::DB::Result::GeoProximity;

use 5.014;
use warnings;
use utf8;

use parent 'DBIx::Class::Core';
__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->table('DUMMY');
__PACKAGE__->add_columns(
    zipcode => {
        numeric     => 1,
        nullable    => 0,
    },
);
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(q[
    SELECT geoprox_a.plz99 as zipcode
      FROM post_code_areas geoprox_a, post_code_areas geoprox_b
     WHERE geoprox_b.country = ? AND geoprox_b.plz99 = ?
           AND ST_Distance(geoprox_a.loc_center, geoprox_b.loc_center, True) <= ?
]);

__PACKAGE__->set_primary_key('zipcode');

1;
