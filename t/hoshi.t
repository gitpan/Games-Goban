use Test::More tests => 1;
use Games::Goban;

use strict;

my @hoshi_19 = sort Games::Goban->new->hoshi; 
my @right_19 = sort qw[dd pd dp pp jd dj jj pj jp];

ok(eq_array(\@hoshi_19,\@right_19), "hoshi on 19");
