# ================================================================
package Mail::Builder::Attachment;
# ================================================================
use strict;
use warnings;
use utf8;

use Carp;

use vars qw($MIME);

$MIME = {
		'application/base64' => ['mm','mme'],
		'application/binhex' => ['hqx'],
		'application/book' => ['boo','book'],
		'application/cdf' => ['cdf'],
		'application/drafting' => ['drw'],
		'application/dxf' => ['dxf'],
		'application/excel' => ['xl','xla','xlb','xlc','xld','xlk','xll','xlm','xls','xlt','xlv','xlw'],
		'application/futuresplash' => ['spl'],
		'application/gnutar' => ['tgz'],
		'application/hlp' => ['hlp'],
		'application/hta' => ['hta'],
		'application/inf' => ['inf'],
		'application/java' => ['class'],
		'application/mac-compactpro' => ['cpt'],
		'application/macbinary' => ['bin'],
		'application/mspowerpoint' => ['pot','ppa','pps','ppt','ppz','pwz'],
		'application/msword' => ['doc','dot','w6w','wiz','word'],
		'application/mswrite' => ['wri'],
		'application/octet-stream' => ['a','arc','arj','bin','com','dump','exe','lha','lhx','lzh','lzx','o','psd'],
		'application/pdf' => ['pdf'],
		'application/postscript' => ['ai','eps','ps'],
		'application/powerpoint' => ['ppt'],
		'application/pro_eng' => ['part','prt'],
		'application/ringing-tones' => ['rng'],
		'application/rtf' => ['rtf','rtx'],
		'application/smil' => ['smi','smil'],
		'application/vnd.ms-project' => ['mpp'],
		'application/vnd.nokia.configuration-message' => ['ncm'],
		'application/vnd.nokia.ringing-tone' => ['rng'],
		'application/vnd.rn-realmedia' => ['rm'],
		'application/vnd.rn-realplayer' => ['rnx'],
		'application/vnd.wap.wmlc' => ['wmlc'],
		'application/vnd.wap.wmlscriptc' => ['wmlsc'],
		'application/wordperfect' => ['wp','wp5','wp6','wpd','w60','w61'],
		'application/x-cdf' => ['cdf'],
		'application/x-compressed' => ['gz','tgz','z','zip'],
		'application/x-dvi' => ['dvi'],
		'application/x-gtar' => ['gtar'],
		'application/x-gzip' => ['gz','gzip'],
		'application/x-javascript' => ['js'],
		'application/x-latex' => ['latex','ltx'],
		'application/x-midi' => ['mid','midi'],
		'application/x-nokia-9000-communicator-add-on-software' => ['aos'],
		'application/x-pagemaker' => ['pm4','pm5','pm6'],
		'application/x-shockwave-flash' => ['swf'],
		'application/x-sit' => ['sit'],
		'application/x-tar' => ['tar'],
		'application/x-visio' => ['vsd','vst','vsw'],
		'application/x-zip-compressed' => ['zip'],
		'application/zip' => ['zip'],
		'audio/aiff' => ['aif','aifc','aiff'],
		'audio/basic' => ['au','snd'],
		'audio/mid' => ['rmi'],
		'audio/midi' => ['kar','mid','midi'],
		'audio/mpeg' => ['m2a','mp2','mpa','mpg','mpga'],
		'audio/mpeg3' => ['mp3'],
		'audio/wav' => ['wav'],
		'audio/x-au' => ['au'],
		'audio/x-gsm' => ['gsd','gsm'],,
		'audio/x-pn-realaudio' => ['ra','ram','rm','rmm','rmp'],
		'image/bmp' => ['bm','bmp'],
		'image/gif' => ['gif'],
		'image/jpeg' => ['jfif','jpe','jpeg','jpg'],
		'image/pict' => ['pic','pict'],
		'image/png' => ['png'],
		'image/tiff' => ['tif','tiff'],
		'image/vnd.dwg' => ['dwg','dxf','svf'],
		'image/vnd.rn-realflash' => ['rf'],
		'image/vnd.rn-realpix' => ['rp'],
		'image/vnd.wap.wbmp' => ['wbmp'],
		'image/vnd.xiff' => ['xif'],
		'image/x-icon' => ['ico'],
		'image/x-jg' => ['art'],
		'image/x-pcx' => ['pcx'],
		'image/x-pict' => ['pct'],
		'image/x-quicktime' => ['qif','qti','qtif'],
		'image/x-tiff' => ['tif','tiff'],
		'image/x-xbitmap' => ['xbm'],
		'image/xbm' => ['xbm'],
		'image/xpm' => ['xpm'],
		'multipart/x-gzip' => ['gzip'],
		'multipart/x-ustar' => ['ustar'],
		'multipart/x-zip' => ['zip'],
		'text/css' => ['css'],
		'text/html' => ['acgi','htm','html','htmls','htx','shtml'],
		'text/mcf' => ['mcf'],
		'text/plain' => ['c','cc','com','conf','cxx','def','f','f90','for','g','h','hh','idc','jav','java','list','log','lst','m','mar','pl','sdml','text','txt'],
		'text/richtext' => ['rt','rtf','rtx'],
		'text/sgml' => ['sgm','sgml'],
		'text/tab-separated-values' => ['tsv'],
		'text/vnd.rn-realtext' => ['rt'],
		'text/vnd.wap.wml' => ['wml'],
		'text/vnd.wap.wmlscript' => ['wmls'],
		'text/xml' => ['xml'],
		'video/avi' => ['avi'],
		'video/mpeg' => ['m1v','m2v','mp2','mp3','mpa','mpe','mpeg','mpg'],
		'video/msvideo' => ['avi'],
		'video/quicktime' => ['moov','mov','qt'],
		'video/vivo' => ['viv','vivo'],
		'video/vnd.rn-realvideo' => ['rv'],
		'video/vnd.vivo' => ['viv','vivo'],
		'x-world/x-vrml' => ['vrml','wrl','wrz'],
};

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
			foreach my $element (keys %{$MIME}) {
				if (grep {$_ eq $file_extension} @{$MIME->{$element}}) {
					$obj->{'mime'} = $element;
					last;
				}
			}
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

=head3 name

Accessor which takes/returns the name of the file as displayed in the e-mail
message. If no name is provided the filename will be extracted from the path
attribute.

=head3 mime

Accessor which takes/returns the mime type of the file. If no mime type is 
provided the module tries to determine the correct mime type for the given
filename extension. If this fails 'application/octet-stream' will be used.

The automatic recognition is performed when serialize is executed for the first
time.

=head3 serialize

Returns the attachment as a MIME::Entity object.

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    http://www.k-1.com

=cut

