use Test::More tests => 4;
use Games::Goban;

use strict;

my $x = new Games::Goban; 
$x->move("pp");
$x->move("pd"); 
$x->move("dp"); 
$x->move("jj"); 
ok($x->as_sgf eq <<EOF, "simple SGF file");
(;GM[1]FF[4]AP[Games::Goban]SZ[19]
PW[Miss White]PB[Mr. Black]
;B[pp]CR[pp]
;W[pd]CR[pd]
;B[dp]CR[dp]
;W[jj]CR[jj])
EOF

ok($x->as_text eq <<EOF, "simple text diagram");
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

my $y = new Games::Goban (size=>9); 
eval {$y->move("pp")};
ok($@,"invalid move attempt");
$y->move("ab");
ok($y->as_text eq <<EOF,"small text diagram");
. . . . . . . . . 
X). . . . . . . . 
. . + . . . + . . 
. . . . . . . . . 
. . . . + . . . . 
. . . . . . . . . 
. . + . . . + . . 
. . . . . . . . . 
. . . . . . . . . 
EOF
