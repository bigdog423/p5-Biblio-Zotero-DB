use utf8;
package Biblio::Zotero::DB::Schema::Result::BaseFieldMapping;
{
  $Biblio::Zotero::DB::Schema::Result::BaseFieldMapping::VERSION = '0.003';
}

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE


use strict;
use warnings;

use base 'DBIx::Class::Core';


__PACKAGE__->table("baseFieldMappings");


__PACKAGE__->add_columns(
  "itemtypeid",
  { data_type => "int", is_foreign_key => 1, is_nullable => 0 },
  "basefieldid",
  { data_type => "int", is_foreign_key => 1, is_nullable => 0 },
  "fieldid",
  { data_type => "int", is_foreign_key => 1, is_nullable => 0 },
);


__PACKAGE__->set_primary_key("itemtypeid", "basefieldid", "fieldid");


__PACKAGE__->belongs_to(
  "basefieldid",
  "Biblio::Zotero::DB::Schema::Result::Field",
  { fieldid => "basefieldid" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


__PACKAGE__->belongs_to(
  "fieldid",
  "Biblio::Zotero::DB::Schema::Result::Field",
  { fieldid => "fieldid" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


__PACKAGE__->belongs_to(
  "itemtypeid",
  "Biblio::Zotero::DB::Schema::Result::ItemType",
  { itemtypeid => "itemtypeid" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-07-02 23:02:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rtllW6LYLzx6aGyaF9phAw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Biblio::Zotero::DB::Schema::Result::BaseFieldMapping

=head1 VERSION

version 0.003

=head1 NAME

Biblio::Zotero::DB::Schema::Result::BaseFieldMapping

=head1 TABLE: C<baseFieldMappings>

=head1 ACCESSORS

=head2 itemtypeid

  data_type: 'int'
  is_foreign_key: 1
  is_nullable: 0

=head2 basefieldid

  data_type: 'int'
  is_foreign_key: 1
  is_nullable: 0

=head2 fieldid

  data_type: 'int'
  is_foreign_key: 1
  is_nullable: 0

=head1 PRIMARY KEY

=over 4

=item * L</itemtypeid>

=item * L</basefieldid>

=item * L</fieldid>

=back

=head1 RELATIONS

=head2 basefieldid

Type: belongs_to

Related object: L<Biblio::Zotero::DB::Schema::Result::Field>

=head2 fieldid

Type: belongs_to

Related object: L<Biblio::Zotero::DB::Schema::Result::Field>

=head2 itemtypeid

Type: belongs_to

Related object: L<Biblio::Zotero::DB::Schema::Result::ItemType>

=head1 AUTHOR

Zakariyya Mughal <zmughal@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Zakariyya Mughal.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
