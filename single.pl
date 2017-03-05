

use 5.010;
use warnings;
use strict;
use hashmod qw/hashOne hashXX/;

my $in = $ARGV[0];
my $size = -s $in;
say $size;
say hashOne($in);
say hashXX($in);
