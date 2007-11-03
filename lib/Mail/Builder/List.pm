# ================================================================
package Mail::Builder::List;
# ================================================================
use strict;
use warnings;

use Carp;

# -------------------------------------------------------------
sub new
# Type: Constructor
# Parameters: Class name
# Returnvalue: Object
# -------------------------------------------------------------
{
	my $class = shift;
	my $list_type = shift || 'Mail::Builder::Address';
	
	my $obj = bless {
		type	=> $list_type,
		list	=> [],
	},$class;
	bless $obj,$class;
	return $obj;
}

# -------------------------------------------------------------
sub type
# Type: Public Method
# Parameters: -
# Returnvalue: Class Name
# -------------------------------------------------------------
{
	my $obj = shift;
	return $obj->{'type'};
}

# -------------------------------------------------------------
sub length
# Type: Public Method
# Parameters: -
# Returnvalue: Number of elements in list
# -------------------------------------------------------------
{
	my $obj = shift;
	return scalar @{$obj->{'list'}};
}

# -------------------------------------------------------------
sub add
# Type: Public Method
# Parameters: Object
# Returnvalue: 1 OR 0
# -------------------------------------------------------------
{
	my $obj = shift;
	my $value = shift;
	if (ref($value)) {
		croak(qq[Invalid item added to list: Must be of $obj->{'type'}]) unless ($value->isa($obj->{'type'}));
		push @{$obj->{'list'}}, $value;
	} else {
		my $object = $obj->{'type'}->new($value,@_);
		return 0 unless ($object 
			&& ref $object 
			&& $object->isa($obj->{'type'}));
		push @{$obj->{'list'}}, $object;
	}
	
	return 1;
}

# -------------------------------------------------------------
sub reset
# Type: Public Method
# Parameters: -
# Returnvalue: 1
# -------------------------------------------------------------
{
	my $obj = shift;
	$obj->{'list'} = [];
	return 1;
}


# -------------------------------------------------------------
sub list
# Type: Public Method
# Parameters: -
# Returnvalue: List of objects
# -------------------------------------------------------------
{
	my $obj = shift;
	return @{$obj->{'list'}};
}

# -------------------------------------------------------------
sub item
# Type: Public Method
# Parameters: Index
# Returnvalue: Objects
# -------------------------------------------------------------
{
	my $obj = shift;
	my $index = shift || 0;
	return undef unless (defined $obj->{'list'}[$index]);
	return $obj->{'list'}[$index];
}

# -------------------------------------------------------------
sub join
# Type: Public Method
# Parameters: Join string
# Returnvalue: List of objects
# -------------------------------------------------------------
{
	my $obj = shift;
	my $join_string = shift || ','; 
	return join $join_string, map { $_->serialize } @{$obj->{'list'}};
}

1;

__END__
=pod

=head1 NAME

Mail::Builder::List - Helper module for handling various lists 

=head1 SYNOPSIS

  use Mail::Builder;
  
  my $list = Mail::Builder::List->new(Mail::Builder::Address);
  $list->add($address_object);
  $list->add($another_address_object);
  $list->reset;
  $list->add($email,$name);
  print $list->join(',');

=head1 DESCRIPTION

This is a simple module for handling various lists (e.g. recipient lists).  

=head1 USAGE

=head2 new

 Mail::Builder::List->new(CLASS);

This constructor takes the class name of the objects it should hold. It is only
possible to add objects of the selected type.

=head2 type

Returns the class name which was initially passed to the constructor.

=head2 add

 $list->add(OBJECT);
 OR
 $list->add(PARAM1,PARAM2,...,PARAMN)

This method appends a new item to the list. It can either take an object or
an arbitrary number of parameters. The parameters will be passed to the 
constructor of the list type class.
An exception is thrown if the object type and the list type do not match.

=head2 length

Returns the number of items in the list.

=head2 join([STRING])

Serializes all items in the list and joins them with the given string. If no
string is provided then a semicolon is used.  

=head2 reset

Removes all items from the list.

=head2 list

Returns all items in the list as an array.

=head2 item([INDEX])

Returns the item at the given index.

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    http://www.k-1.com

=cut
