

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Mail::Builder',
    VERSION_FROM => 'lib/Mail/Builder.pm', # finds \$VERSION
    AUTHOR       => 'Maros Kollar (maros [at] k-1.com)',
    ABSTRACT     => 'Easily create e-mails with attachments, html and inline images',
    PREREQ_PM    => {
                    'Test::More' => 0,
                    'Test::Pod::Coverage' => 0,
                    'Test::Pod' => 0,
    				'MIME::Tools' => 0,
    				'Email::Valid' => 0,
    				'Email::Valid' => 0,
    				'Class::Accessor' => 0,
    				'HTML::TreeBuilder' => 0,
                    },
);
