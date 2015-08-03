
package hashmod;

use strict;
use 5.010;
use warnings;
use base qw/Exporter/;
use Digest::MD5 qw/md5 md5_hex/;

our @EXPORT_OK = qw/hashOne/;

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

1;

