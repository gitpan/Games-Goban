# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 5 };
use Games::Goban;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

my $x = new Games::Goban; 
$x->move("pp");
$x->move("pd"); 
$x->move("dp"); 
$x->move("jj"); 
ok($x->as_sgf eq <<EOF);
(;GM[1]FF[4]AP[Games::Goban]SZ[19]
PW[Miss White]PB[Mr. Black]
;B[pp]CR[pp]
;W[pd]CR[pd]
;B[dp]CR[dp]
;W[jj]CR[jj])
EOF

ok($x->as_text eq <<EOF);
. . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . 
. . . + . . . . . + . . . . . O . . . 
. . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . 
. . . + . . . . .(O). . . . . + . . . 
. . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . 
. . . X . . . . . + . . . . . X . . . 
. . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . 
EOF

my $x = new Games::Goban (size=>9); 
eval {$x->move("pp")};
ok($@);
$x->move("ab");
ok($x->as_text eq <<EOF);
. . . . . . . . . 
X). . . . . . . . 
. . + . . . + . . 
. . . . . . . . . 
. . . . . . . . . 
. . . . . . . . . 
. . + . . . + . . 
. . . . . . . . . 
. . . . . . . . . 
EOF
