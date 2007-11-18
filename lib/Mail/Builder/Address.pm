# ================================================================
package Mail::Builder::Address;
# ================================================================
use strict;
use warnings;

use Carp;
use Email::Valid;

use vars qw($VERSION);
$VERSION = $Mail::Builder::VERSION;

# -------------------------------------------------------------
sub new
# Type: Constructor
# Parameters: EMAIL[,NAME]
# Returnvalue: Object
# -------------------------------------------------------------
{
	my $class = shift;
	my $obj = bless {
		email	=> undef,
		name	=> undef,
	},$class;
	
	$obj->email(shift);
	$obj->name(shift) if (@_);
	
	return $obj;
}

# -------------------------------------------------------------
sub name
# Type: Accessor
# Parameters: NAME
# Returnvalue: Name
# -------------------------------------------------------------
{
	my $obj = shift;
 	if(@_) {
		$obj->{'name'} = shift;
		return unless $obj->{'name'};
		$obj->{'name'} =~ s/\\/\\\\/g;
		$obj->{'name'} =~ s/"/\\"/g;
	}
	return $obj->{'name'};
}
	
# -------------------------------------------------------------
sub email
# Type: Accessor
# Parameters: EMAIL
# Returnvalue: Name
# -------------------------------------------------------------
{
	my $obj = shift;
 	if(@_) {
		my $email_address = shift;
		croak(q[e-mail adress missing]) unless ($email_address);
		croak(q[e-mail adress is not valid]) unless (Email::Valid->address($email_address));
		$obj->{'email'} = $email_address;
	}
	return $obj->{'email'};
}

# -------------------------------------------------------------
sub serialize
# Type: Method
# Parameters: -
# Returnvalue: e-mail adress as needed for MIME::Tools
# -------------------------------------------------------------
{
	my $obj = shift;
	my $return_value = qq[<$obj->{'email'}>];
	$return_value = qq["$obj->{'name'}" ].$return_value if $obj->{'name'};
	return $return_value;
}

1;

__END__
=pod

=head1 NAME

Mail::Builder::Address - Helper module for handling e-mail addresses

=head1 SYNOPSIS

  use Mail::Builder;
  
  my $mail = Mail::Builder::Address->new('mightypirate@meele-island.mq','Gaybrush Thweedwood');
  $mail->name('Guybrush Threepwood');
  $mail->email('verymightypirate@meele-island.mq');
  print $mail->serialize;
  
=head1 DESCRIPTION

This is a simple module for handling e-mail addresses. It can store the address
and an optional name.

=head1 USAGE

=head2 new

 Mail::Builder::Address->new(EMAIL[,NAME]);

Simple constructor

=head2 name

Simple accessor

=head2 email

Simple accessor

=head2 serialize

Prints the address as needed for creating the e-mail header.

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    http://www.k-1.com

=cut
