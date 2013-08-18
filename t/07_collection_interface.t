use strict;
use warnings;
use Test::Most tests => 1;

use lib "t/lib";
use TestData;

my $db = get_db();

my $collections = [ $db->schema->resultset('Collection')->all ];
#use DDP; p $collections;
#my @d = $db->schema->resultset('Collection')->find(3)->collection_items->all;
#use DDP; p $_->itemid->item_datas_rs->fields_for_itemid($_->itemid->itemid) for @d;

my $library = $db->library;
is( $library->name, 'My Library' );
##is( $library->items->count, 11 );

is( $library->trash->name, 'Trash' );
is( $library->trash->items->count, 6 );

my @trash = map { $_->fields } $library->trash->items->all;
  use DDP; p @trash;

is( $library->unfiled->name, 'Unfiled Items' );
is( $library->unfiled->items->count, 7 );

is( $library->collections->count, 3 );

my $collection_count = {
  'Collection with deleted' => 1,
  'Dendritic spines' => 1,
  'Perl' => 2,
};

subtest 'collections items count' => sub {
  for my $collection ($library->collections->all) {
    my $name = $collection->name;
    my $expected_count = $collection_count->{$name};
    is( $collection->items->count, $expected_count, "count for $name" );
  }
};

#  get items at this level
#  get subitems
#  get all 

done_testing;
