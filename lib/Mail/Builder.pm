# ================================================================
package Mail::Builder;
# ================================================================
use strict;
use warnings;

use base qw(Class::Accessor);

use Carp;

use MIME::Entity;
use HTML::TreeBuilder;
use Email::MessageID;

use Mail::Builder::List;
use Mail::Builder::Address;
use Mail::Builder::Attachment;
use Mail::Builder::Attachment::File;
use Mail::Builder::Attachment::Data;
use Mail::Builder::Image;

__PACKAGE__->mk_accessors(qw(plaintext htmltext subject organization priority charset));
__PACKAGE__->mk_ro_accessors(qw(messageid));

use vars qw($VERSION);
$VERSION = '1.06';

=head1 NAME

Mail::Builder - Easily create e-mails with attachments, html and inline images 

=head1 SYNOPSIS

  use Mail::Builder;
  
  my $mail = Mail::Builder->new();
  
  $mail->from('mightypirate@meele-island.mq','Guybrush Threepwood');
  $mail->to->add('manuel.calavera@dod.mx','Manuel Calavera');
  $mail->cc->add('glotis@dod.mx');
  $mail->subject('Party at Sam\'s place');
  $mail->htmltext('<h1>Party invitation</h1> ... ');
  $mail->attachment->add('direction_samandmax.pdf');

  # Send it with your favourite module (e.g. Email::Send)
  my $mailer = Email::Send->new({mailer => 'Sendmail'})->send($mail->stringify);
  
  # Or mess with MIME::Entity objects
  my $mime = $mail->build_message; 

=head1 DESCRIPTION

This module helps you to build e-mails with attachments, inline images, 
multiple recipients, ... without having to worry about the underlying MIME
stuff. Mail::Builder relies heavily on the L<MIME::Entity> module from
the L<MIME::Tools> distribution. 

The module will create the correct MIME bodies, headers and containers 
(multipart/mixed, multipart/related, multipart/alternative) depending on if
you use attachments, HTML text and inline images.

Addresses, attachments and inline images are handled as objects by helper
classes:

=over

=item * L<Address: Mail::Builder::Address>

Stores an e-mail address and a display name.

=item * Attachments: L<Mail::Builder::Attachment::File> and L<Mail::Builder::Attachment::Data>

This classes manages attachments which can be created either from files on the
filesystem or from data in memory.

=item * Inline images:L<Mail::Builder::Image>

The Address: Mail::Builder::Image class manages images that should be 
displayed in the e-mail body.

=item * L<Address: Mail::Builder::List>

Helper class for handling list of varoius items (recipient lists, attachment
lists, ...)

=back

=head1 METHODS

=head2 Constructors

=head3 new

This is a simple constructor. It does not expect any parameters.

=cut

sub new {
	my $class = shift;
	
	my $obj = bless {
		boundary	=> 0,
		from		=> undef,
		reply		=> undef,
		organization=> undef,
		returnpath	=> undef,
		to			=> Mail::Builder::List->new('Mail::Builder::Address'),
		cc			=> Mail::Builder::List->new('Mail::Builder::Address'),
		bcc			=> Mail::Builder::List->new('Mail::Builder::Address'),
		priority	=> 3,
		subject		=> '',
		charset     => 'utf8',
		plaintext	=> undef,
		htmltext	=> undef,
		attachment	=> Mail::Builder::List->new('Mail::Builder::Attachment'),
		image		=> Mail::Builder::List->new('Mail::Builder::Image'),
		messageid   => undef,
	},$class;
	bless $obj,$class;
	return $obj;
}

=head2 Public methods 

=head3 stringify

Returns the e-mail message as a string. This string can be passed to modules
like L<Email::Send>.

This method is just a shortcut to C<$mb-&gt;build_message-&gt;stringify>

=cut

sub stringify {
    my $obj = shift;
    return $obj->build_message->stringify;
}

=head3 build_message

Returns the e-mail message as a MIME::Entity object. You can mess arround with
the object, change parts, ... as you wish. 

Every time you call build_message the MIME::Entity object will be created, 
which can take some time if you are sending bulk e-mails. In 
order to increase the processing speed Mail::Builder::Attachment and
Mail::Builder::Image entities will be cached and only rebuilt if something 
has changed.

=cut

sub build_message {
    my $obj = shift;
    
    croak(q[Recipient address missing]) unless ($obj->{'to'}->length());
    croak(q[Sender address missing]) unless (defined $obj->{'from'});
    croak(q[e-mail subject missing]) unless ($obj->{'subject'});
    croak(q[e-mail content missing]) unless ($obj->{'plaintext'} || $obj->{'htmltext'});
    croak(q[Invalid priority (only 1-5)]) unless (defined($obj->{'priority'}) && $obj->{'priority'} =~ /^[1-5]$/);
    
    # Set message ID
    $obj->{'messageid'} = Email::MessageID->new();
    
    # Set header fields
    my %email_header = (
        'Top'           => 1,
        'From'          => $obj->{'from'}->serialize,
        'To'            => $obj->{'to'}->join,
        'Cc'            => $obj->{'cc'}->join,
        'Bcc'           => $obj->{'bcc'}->join,
        'Subject'       => $obj->{'subject'},
        'Message-ID'    => $obj->{'messageid'},
        'X-Priority'    => $obj->{'priority'},
        'X-Mailer'      => "Mail::Builder with MIME::Tools",
    );
    
    # Set reply
    if (defined $obj->{'reply'}) {
        $email_header{'Reply-To'} = $obj->{'reply'}->serialize();
    }
    
    # Set return path
    if (defined $obj->{'returnpath'}) {
        $obj->{'returnpath'}->name(undef);
        $email_header{'Return-Path'} = $obj->{'returnpath'}->serialize();
    } elsif (defined $obj->{'reply'}) {
        $email_header{'Return-Path'} = $obj->{'reply'}->serialize();
    } else {
        $email_header{'Return-Path'} = $obj->{'from'}->serialize();
    } 
    
    # Set organizsation
    $email_header{'Organization'} = $obj->{'organization'} if ($obj->{'organization'});
    
    # Build e-mail entity
    my $mime_entity;
    if ($obj->{'attachment'}->length()) {
        $mime_entity = build MIME::Entity(
            %email_header,
            Type        => 'multipart/mixed',
            Boundary    => $obj->_get_boundary(),
        );
        foreach ($obj->{'attachment'}->list()) {
            $mime_entity->add_part($_->serialize());
        }
        $mime_entity->add_part($obj->_build_text(Top => 0));
    } else {
        $mime_entity = $obj->_build_text(%email_header);
    }
    return $mime_entity;
}


=head2 Accessors 

=head3 from, returnpath, reply

These accessors set/return the from and reply address as well as the
returnpath for bounced messages.

 $obj->from(EMAIL[,NAME])
 OR
 $obj->from(Mail::Builder::Address)

This accessor always returns a Mail::Builder::Address object. 
If parameters are provided the object will be replaced. You can either
suppy a Mail::Builder::Address object, or an e-mail address with an optional 
name.

=cut

sub from {
    my $obj = shift;
    return $obj->_address('from',@_);
}

sub returnpath {
    my $obj = shift;
    return $obj->_address('returnpath',@_);
}

sub reply {
    my $obj = shift;
    return $obj->_address('reply',@_);
}

=head3 to, cc, bcc

 $obj->to(Mail::Builder::List)
 OR
 $obj->to(Mail::Builder::Address)
 OR
 $obj->to(EMAIL[,NAME])

This accessor always returns a Mail::Builder::List object. If you supply
a L<Mail::Builder::List> the list will be replaced.

If you supply a Mail::Builder::Address object or an e-mail address 
(with an optional name),the current list will be reset and the new address 
will be added. 

The L<Mail::Builder::List> package provides some basic methods for 
manipulating the list of recipients.

If you want to append an additional address to the list use

 $obj->to->add(EMAIL[,NAME])
 OR
 $obj->to->add(Mail::Builder::Address)

=cut

sub to {
    my $obj = shift;
    return $obj->_list('to',@_);
}

sub cc {
    my $obj = shift;
    return $obj->_list('cc',@_);
}

sub bcc {
    my $obj = shift;
    return $obj->_list('bcc',@_);
}

=head3 messageid

Message ID of the e-mail. Read only and only available after the 
C<build_message> or C<stingify> methods have been called.

=head3 organization
 
Accessor for the name of the senders organisation.

=head3 prioriy

Priority accessor. Accepts values from 1 to 5. The default priority is 3.

=head3 subject

e-mail subject accessor. Must be specified.

=head3 charset

Charset accessor. Defaults to utf8.

=head3 htmltext

HTML mail body accessor.

=head3 plaintext

Plaintext mail body accessor. This text will be autogenerated from htmltext
if not provided by the user. Simple formating (e.g. <strong>, <em>) will
be converted to pseudo formating.

The following html tags will be transformed:

=over

=item * I, EM

Italic text will be surounded by underscores. (_)

=item * H1, H2, H3, ...

Headlines will be replaced by two equal signs (=)

=item * STRONG, B

Bold text will be marked by stars (*)

=item * HR

A horizontal rule is replaced by 60 dashes.

=item * BR

Single linebreak

=item * P, DIV

Double linebreak

=item * UL, OL

All list items will be indented and prefixed with a start (*) or an index 
number.

=back

=head3 attachment

 $obj->attachment(Mail::Builder::List)
 OR
 $obj->attachment(Mail::Builder::Attachment)
 OR
 $obj->attachment(PATH[,NAME,MIME])
 
This accessor always returns a Mail::Builder::List object. If you supply
a L<Mail::Builder::List> the list will be replaced.

If you pass a Mail::Builder::Attachment object or a scalar path (with an
optional name an mime type) the current list will be reset and the new 
attachment will be added. 

The L<Mail::Builder::List> package provides some basic methods for 
manipulating the list of recipients.

If you want to append an additional attachment to the list use

 $obj->attachment->add(PATH[,NAME,MIME])
 OR
 $obj->attachment->add(Mail::Builder::Attachment)

=cut

sub attachment {
    my $obj = shift;
    return $obj->_list('attachment',@_);
}

=head3 image

 $obj->image(Mail::Builder::List)
 OR
 $obj->image(Mail::Builder::Image)
 OR
 $obj->image(PATH[,ID])
 
This accessor always returns a Mail::Builder::List object. If you supply
a L<Mail::Builder::List> the list will be replaced.

If you pass a Mail::Builder::Image object or a scalar path (with an
optional id) the current list will be reset and the new image will be added. 

The L<Mail::Builder::List> package provides some basic methods for 
manipulating the list of recipients.

If you want to append an additional attachment to the list use

 $obj->image->add(PATH[,ID])
 OR
 $obj->image->add(Mail::Builder::Image)

You can embed the image into the html mail body code by referencing the ID. If 
you don't provide an ID the lowercase filename without the extension will be 
used as the ID.

 <img src="cid:logo"/>

Only jpg, gif and png images may be added as inline images.

=cut

sub image {
    my $obj = shift;
    return $obj->_list('image',@_);
}


# -------------------------------------------------------------
sub _address
# Type: Private accessor
# Parameters: FIELD,[Mail::Builder::Address OR EMAIL[,NAME]
# Returnvalue: Mail::Builder::Address OR UNDEF
# -------------------------------------------------------------
{
	my $obj = shift;
	my $field = shift;
	
	if (@_) {
		my $param = shift;
		if (ref($param)
			&& $param->isa('Mail::Builder::Address')) {
			$obj->{$field} = $param;		
		} else {
			$obj->{$field} = Mail::Builder::Address->new($param,@_);
		}
	}
	return $obj->{$field};
}

# -------------------------------------------------------------
sub _list
# Type: Private accessor
# Parameters: FIELD,[Mail::Builder::List OR PARAMS]
# Returnvalue: Mail::Builder::Address OR UNDEF
# -------------------------------------------------------------
{
	my $obj = shift;
	my $field = shift;
	
	if (@_) {
	    # Replace list object
		if (ref($_[0])
			&& $_[0]->isa('Mail::Builder::List')) {
			croak('List types do not match') unless ($_[0]->type eq $obj->{$field}->type);				
			$obj->{$field} = $_[0];
		# Reset list and add new value
	    } else {
	        $obj->{$field}->reset();
			$obj->{$field}->add(@_);
		}
	}
	return $obj->{$field};
}

# -------------------------------------------------------------
sub _get_boundary
# Type: Private method
# Parameters: -
# Returnvalue: Boundary string
# -------------------------------------------------------------
{
	my $obj = shift;
	$obj->{'boundary'} ++;
	return qq[----_=_NextPart_00$obj->{'boundary'}_].(sprintf '%lx',time);
}

# -------------------------------------------------------------
sub _convert_text
# Type: Private class method
# Parameters: HTML::Element[,LIST OPTION]
# Returnvalue: Text
# -------------------------------------------------------------
{
	my $html_element = shift;
	my $count_param = shift;
	my $plain_text = q[];
	
	# Loop all children of the HTML element  
	foreach my $html_content ($html_element->content_list) {
	    # HTML element
		if (ref($html_content) 
			&& $html_content->isa('HTML::Element')) {
			my $html_tagname = $html_content->tag;
			if ($html_tagname eq 'i' || $html_tagname eq 'em') {
				$plain_text .= '_'._convert_text($html_content,$count_param).'_';
			} elsif ($html_tagname =~ m/^h\d$/) {
				$plain_text .= '=='._convert_text($html_content,$count_param).qq[\n];
			} elsif ($html_tagname eq 'strong' || $html_tagname eq 'b') {
				$plain_text .= '*'._convert_text($html_content,$count_param).'*';
			} elsif ($html_tagname eq 'hr') {
				$plain_text .= qq[\n---------------------------------------------------------\n];
			} elsif ($html_tagname eq 'br') {
				$plain_text .= qq[\n];
			} elsif ($html_tagname eq 'ul') {
				$plain_text .= qq[\n]._convert_text($html_content,'*').qq[\n\n];
			} elsif ($html_tagname eq 'ol') {
				$plain_text .= qq[\n]._convert_text($html_content,'1').qq[\n\n];
			} elsif ($html_tagname eq 'div' || $html_tagname eq 'p') {
				$plain_text .= _convert_text($html_content,$count_param).qq[\n\n];	
			} elsif ($html_tagname eq 'li') {
				$plain_text .= qq[\n\t];
				$count_param ||= '*';
				if ($count_param eq '*') {
					$plain_text .= '*';
				} elsif ($count_param =~ /^\d+$/) {
					$plain_text .= $count_param.'.';
					$count_param ++;
				}
				$plain_text .= q[ ]._convert_text($html_content);
			} else {
				$plain_text .= _convert_text($html_content,$count_param);
			}
	    # CDATA
		} else {
			$html_element =~ s/(\n|\n)//g;
			$html_element =~ s/(\t|\n)/ /g;
			$plain_text .= $html_content;
		}
	}
	
	return $plain_text;
}

# -------------------------------------------------------------
sub _build_text
# Type: Private method
# Parameters: MIME::Entity Parameters
# Returnvalue: MIME::Entity
# -------------------------------------------------------------
{
	my $obj = shift;
	my %mime_params = @_;
    
    # Build plaintext message from HTML
	if (defined $obj->{'htmltext'}
		&& ! defined($obj->{'plaintext'})) {
		# Parse HTML tree
		my $html_tree = HTML::TreeBuilder->new_from_content($obj->{'htmltext'});
		# Only use the body
		my $html_body = $html_tree->find('body');
		# And now convert all elements
		$obj->{'plaintext'} = _convert_text($html_body);
	}
	
	my $mime_part;
	
	# We have HTML and plaintext
	if (defined $obj->{'htmltext'}
		&& defined $obj->{'plaintext'}) {
		
		# Build multipart/alternative envelope for HTML and plaintext
		$mime_part = build MIME::Entity(
			%mime_params,
			Type		=> q[multipart/alternative],
			Boundary	=> $obj->_get_boundary(),
		);
		
		# Add the plaintext entity first
		$mime_part->add_part(build MIME::Entity (
			Top 		=> 0,
			Type		=> qq[text/plain; charset="$obj->{'charset'}"],
			Data		=> $obj->{'plaintext'},
			Encoding	=> 'quoted-printable',
		));
		
		# Add the html entity (the last entity is prefered in multipart/alternative context)
		$mime_part->add_part($obj->_build_html(Top => 0));
    # We only have plaintext
	} else {
		$mime_part = build MIME::Entity (
			%mime_params,
			Type		=> qq[text/plain; charset="$obj->{'charset'}"],
			Data		=> $obj->{'plaintext'},
			Encoding	=> 'quoted-printable',
		);
	}
	
	return $mime_part;
}


# -------------------------------------------------------------
sub _build_html
# Type: Private method
# Parameters: MIME::Entity Parameters
# Returnvalue: MIME::Entity
# -------------------------------------------------------------
{
	my $obj = shift;
	my %mime_params = @_;
	
	my $mime_part;
	
	# We have inline images
	if ($obj->{'image'}->length()) {
	    # So we need a multipart/related envelope first
		$mime_part = build MIME::Entity(
			%mime_params,
			Type		=> q[multipart/related],
			Boundary	=> $obj->_get_boundary(),
		);
		# Add the html body
		$mime_part->add_part(build MIME::Entity (
			Top 		=> 0,
			Type		=> qq[text/html; charset="$obj->{'charset'}"],
			Data		=> $obj->{'htmltext'},
			Encoding	=> 'quoted-printable',
		));
		# And now all the inline images
		foreach ($obj->{'image'}->list) {
			$mime_part->add_part($_->serialize);
		}
    # We don't have any inline images
	} else {
		$mime_part = build MIME::Entity (
			%mime_params,
			Type		=> qq[text/html; charset="$obj->{'charset'}"],
			Data		=> $obj->{'htmltext'},
			Encoding	=> 'quoted-printable',
		);
	}	
	return $mime_part;
}



1;

=head1 SUPPORT

Please report any bugs or feature requests to 
C<bug-mail-builder@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be 
notified of progress on your bug as I make changes.

=head1 AUTHOR

    Maros Kollar
    CPAN ID: MAROS
    maros [at] k-1.com
    http://www.k-1.com

=head1 COPYRIGHT

Mail::Builder is Copyright (c) 2007,2008 Maroš Kollár.
All rights reserved.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

The L<Mime::Entity> module in the L<Mime::Tools> distribution.

=cut

1;
