
package hashmod;

use strict;
use 5.010;
use warnings;
use base qw/Exporter/;
use Digest::MD5 qw/md5 md5_hex/;
use Digest::xxHash qw[xxhash xxhash_hex];
use Digest::xxHash qw[xxhash32 xxhash32_hex];
our @EXPORT_OK = qw/hashOne hashXX/;

sub hashOne{
	my $full = shift // die 'no input file';
	open my $fin, '<', $full or die "cannot open $full\n";
    binmode($fin);
	my $ctx = Digest::MD5->new;
	$ctx->addfile($fin);
	my $hash = $ctx->hexdigest;
	close $fin;
	$hash;
}


#################
### The old OO interface is deprecated.(In the very recent date.)
### 
#sub hashXX {
#    my $full = shift // die 'no input file specified';
#    my $seed = "10241024";  # Good seed.
#    my $digest = Digest::xxHash->new($seed);
#    open my $fin, '<', $full or die "Cannot open $full\n";
#    binmode($fin);
#    while(my $buf=<$fin>){
#        $digest->add($buf);
#    }
#    close $fin;
#    my $xxhex = $digest->digest_hex(); # ->digest for oct.
#    $xxhex;
#}

sub hashXX {
   my $full = shift // die 'no input file specified';
   my $seed = "10241024";  # Good seed.
   open my $fin, '<', $full or die "Cannot open $full\n";
   binmode($fin);
   read($fin, my $data, -s $full);
   close $fin;
   xxhash32_hex($data, $seed);
}


1;

