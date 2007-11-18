# ================================================================
package Mail::Builder::Attachment;
# ================================================================
use strict;
use warnings;

use Carp;

use vars qw($VERSION);

use MIME::Types;

$VERSION = $Mail::Builder::VERSION;

# -------------------------------------------------------------
sub new
# Type: Constructor
# Parameters: PATH[,NAME,MIMETYPE]
# Returnvalue: Object
# -------------------------------------------------------------
{
	my $class = shift;
	
	my $obj = bless {
		path	=> undef,
		name	=> undef,
		mime	=> undef,
		cache	=> undef,
	},$class;
	
	$obj->path(shift);
	$obj->name(shift) if (@_);
	$obj->mime(shift) if (@_);
	
	return $obj;
}

# -------------------------------------------------------------
sub name
# Type: Accessor
# Parameters: Filename
# Returnvalue: Mime::Entity
# -------------------------------------------------------------
{
    my $obj = shift;
    if (@_) {
        $obj->{'name'} = shift;
        $obj->{'cache'} = undef;
    }
    return $obj->{'name'};
}

# -------------------------------------------------------------
sub path
# Type: Accessor
# Parameters: Filename
# Returnvalue: Mime::Entity
# -------------------------------------------------------------
{
    my $obj = shift;
    if (@_) {
        $obj->{'path'} = shift;
        croak(q[Filename missing]) unless ($obj->{'path'});
        croak(qq[Could not find/open file: $obj->{'path'}]) unless (-r $obj->{'path'});
        $obj->{'cache'} = undef;
    }
    return $obj->{'path'};
}

# -------------------------------------------------------------
sub mime
# Type: Accessor
# Parameters: Filename
# Returnvalue: Mime::Entity
# -------------------------------------------------------------
{
    my $obj = shift;
    if (@_) {
        $obj->{'mime'} = shift;
        croak(q[Invalid mime type]) unless ($obj->{'mime'} =~ /^[a-z]+\/[a-z0-9.-]+$/);
        $obj->{'cache'} = undef;
    }
    return $obj->{'mime'};
}

# -------------------------------------------------------------
sub serialize
# Type: Method
# Parameters: -
# Returnvalue: Mime::Entity
# -------------------------------------------------------------
{
	my $obj = shift;
	return $obj->{'cache'} if (defined $obj->{'cache'});
	croak(q[Filename missing]) unless ($obj->{'path'});
	unless ($obj->{'mime'}) {
		if ($obj->{'path'} =~ m/\.([a-zA-Z0-9]+)$/) {
			my $file_extension = $1;
			my $mimetypes = MIME::Types->new;
			$obj->{'mime'} = $mimetypes->mimeTypeOf($file_extension);
		}
		$obj->{'mime'} ||= 'application/octet-stream';
	}
	
	unless ($obj->{'name'}) {
		$obj->{'name'} = $obj->{'path'};
		$obj->{'name'} = $1 if ($obj->{'name'} =~ m/([^\\\/]+)$/);
	}
	
	$obj->{'cache'} = build MIME::Entity (
		Path		=> $obj->{'path'},
		Type		=> $obj->{'mime'},
		Top			=> 0,
		Filename	=> $obj->{'name'},
		Encoding	=> 'base64',
		Disposition	=> 'attachment',
	);
	return $obj->{'cache'};
}

1;

__END__
=pod

=head1 NAME

Mail::Builder::Attachment - Helper module for handling attachments

=head1 SYNOPSIS

  use Mail::Builder;
  
  my $attachment = Mail::Builder::Attachment('/home/guybrush/2007_10_11_invitation.pdf','invitation.pdf','application/pdf');
  $attachment->name('party_invitation.pdf');
  print $attachment->serialize;
  
=head1 DESCRIPTION

This is a simple module for handling attachments. The module needs the path to 
the file and optional an name which will be used for displaying the file in 
the e-mail and a mime type.

=head1 USAGE

=head2 new

Simple constructor

 Mail::Builder::Attachment->new(PATH[,NAME,MIME]);

=head2 path

Accessor which takes/returns the path of the file on the filesystem. The file
must be readable.

=head2 name

Accessor which takes/returns the name of the file as displayed in the e-mail
message. If no name is provided the filename will be extracted from the path
attribute.

=head2 mime

Accessor which takes/returns the mime type of the file. If no mime type is 
provided the module tries to determine the correct mime type for the given
filename extension. If this fails 'application/octet-stream' will be used.

The automatic recognition is performed when serialize is executed for the first
time.

=head2 serialize

Returns the attachment as a MIME::Entity object.

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    http://www.k-1.com

=cut

