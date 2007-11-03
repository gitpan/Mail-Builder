# ================================================================
package Mail::Builder::Image;
# ================================================================
use strict;
use warnings;

use Carp;

# -------------------------------------------------------------
sub new
# Type: Constructor
# Parameters: PATH[,ID]
# Returnvalue: Object
# -------------------------------------------------------------
{
	my $class = shift;
	
	my $obj = bless {
		path	=> undef,
		id		=> undef,
		cache	=> undef,
		type	=> undef,
	},$class;
	
	$obj->path(shift);
	$obj->id(shift) if (@_);
	
	return $obj;
}

# -------------------------------------------------------------
sub id
# Type: Accessor
# Parameters: Filename
# Returnvalue: Mime::Entity
# -------------------------------------------------------------
{
    my $obj = shift;
    if (@_) {
        $obj->{'id'} = shift;
        $obj->{'cache'} = undef;
    }
    return $obj->{'id'};
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
        croak(qq[Invalid file type: $obj->{'path'}]) unless ($obj->{'path'} =~ /.(JPE?G|GIF|PNG)$/i);
        croak(qq[Could not find/open file: $obj->{'path'}]) unless (-r $obj->{'path'});
        $obj->{'cache'} = undef;
        $obj->{'type'} = lc($1);
        $obj->{'type'} =~ s/^jpe?g?$/jpeg/;
    }
    return $obj->{'path'};
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
	
	unless ($obj->{'id'}) {
		$obj->{'id'} = $obj->{'path'};
		$obj->{'id'} =~ s/(^[\/]+)$/$1/;
		$obj->{'id'} =~ s/^(.+)\.(JPE?G|GIF|PNG)$/$1/i;
	}
	
	$obj->{'cache'} = build MIME::Entity(
		Disposition		=> 'inline',
		Type			=> qq[image/$obj->{'type'}],
		Top				=> 0,
		Id				=> qq[<$obj->{'id'}>],
		Encoding		=> 'base64',
		Path			=> $obj->{'path'},
	);
}

1;

__END__
=pod

=head1 NAME

Mail::Builder::Image - Helper module for handling inline images

=head1 SYNOPSIS

  use Mail::Builder;
  
  my $image = Mail::Builder::Image('/home/guybrush/invitation.gif','invitation');
  $image->id('invitation_location');
  print $image->serialize;
  
=head1 DESCRIPTION

This is a simple module for handling inline images. The module needs the path 
to the file and optional an id which can be used to reference the file from
within the e-mail text.

=head1 USAGE

=head2 new

Simple constructor

 Mail::Builder::Image->new(PATH[,ID]);

=head2 path

Accessor which takes/returns the path of the file on the filesystem. The file
must be readable.

=head2 id

Accessor which takes/returns the id of the file. If no id is provided the 
lowercase filename without the extension will be used as an id.

=head2 serialize

Returns the image as a MIME::Entity object.

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    http://www.k-1.com

=cut

