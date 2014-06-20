

# Test utility

use 5.010;
use strict;
use warnings;
use File::Copy;

my $G_DEPLOY_HASH = 'E:/node/svr/events/hashv';
my $G_VER = '0.0.0';
my $G_VER_SVR_FILE= 'E:/node/svr/events/version.cfg';


open my $fin, '<', $G_VER_SVR_FILE or die "no";
my $line = <$fin>;
close $fin;

die "error format for version cfg" if $line !~ /(\d+)\.(\d+)\.(\d+)/;

my $c = $3 + 1;
my $newV = "$1.$2.$c";
my $thisV = "$1.$2.$3";

my $old_hf = $G_DEPLOY_HASH . '/' . $thisV . '.hash';
die "no .hash for $newV" if not -f $old_hf;

my $hf = $G_DEPLOY_HASH . '/' . $newV . '.hash';
#print("copy $old_hf $hf");
copy($old_hf, $hf);

die "copy error" if not -f $hf;

open my $fout, '>', $G_VER_SVR_FILE or die "no";
print {$fout} $newV;
close $fout;


print "update to $newV\n";







