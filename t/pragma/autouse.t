#!./perl

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
}

use Test;
BEGIN { plan tests => 9; }

BEGIN {
    require autouse;
    eval {
        "autouse"->import('List::Util' => 'List::Util::first');
    };
    ok( $@, qr/^autouse into different package attempted/ );

    "autouse"->import('List::Util' => qw(max first(&@)));
}

my @a = (1,2,3,4,5.5);
ok( max(@a), 5.5);


# first() has a prototype of &@.  Make sure that's preserved.
ok( (first { $_ > 3 } @a), 4);


# Example from the docs.
use autouse 'Carp' => qw(carp croak);

{
    my @warning;
    local $SIG{__WARN__} = sub { push @warning, @_ };
    carp "this carp was predeclared and autoused\n";
    ok( scalar @warning, 1 );
    ok( $warning[0], "this carp was predeclared and autoused\n" );

    eval { croak "It is but a scratch!" };
    ok( $@, qr/^It is but a scratch!/);
}


# Test that autouse's lazy module loading works.  We assume that nothing
# involved in this test uses Test::Soundex, which is pretty safe.
use File::Spec;
use autouse 'Text::Soundex' => qw(soundex);

my $mod_file = File::Spec->catfile(qw(Text Soundex.pm));
ok( !exists $INC{$mod_file} );
ok( soundex('Basset'), 'B230' );
ok( exists $INC{$mod_file} );

