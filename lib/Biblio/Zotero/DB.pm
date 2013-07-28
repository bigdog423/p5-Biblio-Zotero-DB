package Biblio::Zotero::DB;
{
  $Biblio::Zotero::DB::VERSION = '0.001';
}
# ABSTRACT: helper module to access the Zotero SQLite database

use strict;
use warnings;

use v5.10;
use Moo;
use File::HomeDir;
use Path::Class;
use Path::Iterator::Rule;
use List::AllUtils qw(first);

use Biblio::Zotero::DB::Schema;

has schema => ( is => 'rw', builder => 1, lazy => 1 );

sub _build_schema {
	my ($self) = @_;
	Biblio::Zotero::DB::Schema->connect('dbi:SQLite:dbname='.$self->db_file,
		'', '',
		{
			(zotero_storage_directory => $self->storage_directory)x!! $self->storage_directory
		},
	);
}

has db_file => ( is => 'rw', builder => 1, lazy => 1 );

sub _build_db_file {
	my ($self) = @_;
	dir($self->profile_directory)->file('zotero.sqlite');
}

has storage_directory => ( is => 'rw', builder => 1, lazy => 1 );

sub _build_storage_directory {
	my ($self) = @_;
	dir($self->profile_directory)->subdir('storage');
}


has profile_directory => ( is => 'rw' );

has profile_name => ( is => 'rw', trigger => 1, builder => 1, lazy => 1 );

sub _trigger_profile_name {
	my ($self) = @_;
	$self->profile_directory(
		first { dir($_)->components(-2) eq $self->profile_name }
			@{$self->find_profile_directories});
}

sub _build_profile_name {
	my ($self) = @_;
	dir($self->profile_directory)->components(-2) if $self->profile_directory;
}


# From <http://www.zotero.org/support/zotero_data>
# Zotero for Firefox
#
# OS X                          /Users/<username>/Library/Application Support/Firefox/Profiles/<randomstring>/zotero
# Windows 7/Vista               C:\Users\<User Name>\AppData\Roaming\Mozilla\Firefox\Profiles\<randomstring>\zotero
# Windows XP/2000               C:\Documents and Settings\<username>\Application Data\Mozilla\Firefox\Profiles\<randomstring>\zotero
# Linux (most distributions)    ~/.mozilla/firefox/Profiles/<randomstring>/zotero

# Zotero Standalone
#
# OS X                          /Users/<username>/Library/Application Support/Zotero/Profiles/<randomstring>/zotero
# Windows 7/Vista               C:\Users\<User Name>\AppData\Roaming\Zotero\Profiles\<randomstring>\zotero
# Windows XP/2000               C:\Documents and Settings\<username>\Application Data\Zotero\Profiles\<randomstring>\zotero
# Linux (most distributions)    ~/.zotero/Profiles/<randomstring>/zotero


sub find_profile_directories {
	my ($self) = @_;
	for($^O) {
		return $self->_find_profile_directories_linux when('linux');
		return $self->_find_profile_directories_osx when('darwin');
		return $self->_find_profile_directories_win when('MSWin32');
		default { return [] };
	}
}

sub _find_profile_directories_osx {
	my ($self) = @_;
	my $my_data = dir(File::HomeDir->my_data)->absolute;
	# gives /Users/<username>/Library/Application Support
	my $find = [
		dir($my_data, 'Firefox'),
		dir($my_data, 'Zotero') ];
	return $self->_find_profile_directories_under($find);
}

sub _find_profile_directories_win {
	my ($self) = @_;
	my $my_data = dir(File::HomeDir->my_data)->absolute;
	# gives C:\Users\<User Name>\AppData\Local
	# or C:\Documents and Settings\<User Name>\Local Settings\Application Data
	# depending on OS version
	if( $my_data->components(-1) eq "Local" ) {
		# for Windows 7 / Vista
		# this returns the \Local directory
		# we want the \Roaming directory that is on the same level
		$my_data = $my_data->parent->subdir('Roaming');
	}
	my $find = [
		dir( $my_data, 'Mozilla','Firefox'),
		dir( $my_data, 'Zotero') ];
	return $self->_find_profile_directories_under($find);
}

sub _find_profile_directories_linux {
	my ($self) = @_;
	my $find =  [
		dir(File::HomeDir->my_home , '.mozilla/firefox'),
		dir(File::HomeDir->my_home , '.zotero/zotero') ];
	return $self->_find_profile_directories_under($find);
}

sub _find_profile_directories_under {
	my ($self, $dirs) = @_;
	# finds either
	# dir('Profiles',<randomstring>,'zotero')
	# (actually, currently it doesn't check that it is indeed in the Profiles
	# directory)
	# or
	# dir(<randomstring>, 'zotero')
	return [ Path::Iterator::Rule->new
		->min_depth(1)->max_depth(3)
		->dir->name('zotero')->all( @$dirs ) ];
}

1;

__END__

=pod

=head1 NAME

Biblio::Zotero::DB - helper module to access the Zotero SQLite database

=head1 VERSION

version 0.001

=head1 SYNOPSIS

  my $db = Biblio::Zotero::DB->new( profile_name => 'abc123.default' );
  $db->schema->resultset('Item')->all;

=head1 ATTRIBUTES

=head2 schema

the L<DBIx::Class> schema that is connected to the C<zotero.sqlite> file

=head2 db_file

A string that contains the filename of the C<zotero.sqlite> file
The default is located in the directory of C<L</profile_directory>> attribute.

=head2 storage_directory

A string that contains the directory where the Zotero attachments are located.
The default is the C<storage> subdirectory of the C<L</profile_directory>> directory.

=head2 profile_directory

A string that contains the directory where the C<zotero.sqlite> database is located,

  $db->profile_directory( "$ENV{HOME}/.zotero/zotero/abc123.default/zotero/" );

=head2 profile_name

A string containing the profile name to use. Setting this will set the
C<L</profile_directory>> attribute.

  $db->profile_name( 'abc123.default' );
  # corresponds to a profile directory such as
  # <~/.zotero/zotero/abc123.default/zotero/>

=head1 METHODS

=head2 find_profile_directories()

Returns an arrayref of the possible profile directories that contain a
Zotero SQLite database. This can be used as a class method.

see: L<http://www.zotero.org/support/zotero_data>

  Biblio::Zotero::DB->find_profile_directories()
  # returns:
  # [
  #   "/home/zaki/.zotero/zotero/abc123.default/zotero",
  #   "/home/zaki/.zotero/zotero/def567.default/zotero"
  # ]

=head1 EXAMPLE

  my $newest = ( # find the most recently modified
    map { $_->[0] }
    sort { $a->[1] <=> $b->[1] }
    map { [$_, -M $_ ] }
    @{Biblio::Zotero::DB->find_profile_directories}
  )[0];
  my $db = Biblio::Zotero::DB->new( profile_directory => $newest  );
  $db->schema->resultset('Item')->all;

=head1 AUTHOR

Zakariyya Mughal <zmughal@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Zakariyya Mughal.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
