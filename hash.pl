
# 2o14
# Scripted by eminem

# Update Log
# April. 5th.
# Generate version file with JSON info 
# To give version and the whole pack size.(in bytes)
# {"version":"x.x.x", size:100}


# Usage 
# hash.pl 1.0.2 version.cfg version.hash

BEGIN { do './config.pl';}

our $G_VER;
our $G_DEPLOY_ROOT;
our $G_DEPLOY_HASH;
our $G_VER_SVR_FILE_PATH;
our $G_VER_VER_HAS_FILE_PATH;

use 5.010;
use warnings;
use strict;

use File::Path qw/mkpath/;
use Cwd qw/getcwd/;
use hashmod qw/hashOne/;

# Global configuration
my $_basever = '1.0.0';	# Base version
sub _retrieveLocalIP{
	my @res = `node get_local_ip`;
	die "node execution failed" if $?;
	if(@res){
		chomp($res[0]);
		return $res[0];
	}
	'http://127.0.0.1:12000';
}
my $_cdnuri = _retrieveLocalIP;
#print "Alright<$_cdnuri>\n";

sub getDestHashv{
	my $s = $G_DEPLOY_HASH;
	if( $^O eq 'linux' || $^O eq 'darwin'){
		## Hello
	} else {
		$s =~ s/\//\\/g;
	}
	mkpath $s;
	$s;
}

sub getSlash{
	if($^O eq 'linux'){
		'/';
	} else {
		'\\';
	}
}

sub walkSize{
	my $curdir = shift // die "no parameter";
	my $thisSize = 0;
	opendir my $cd, $curdir or die "no current directory";

	while( my $f = readdir $cd )
	{
		next if $f eq '.' or $f eq '..';
		my $full = $curdir . '/' . $f;
		$thisSize += walkSize($full) if -d $full;
		$thisSize += -s $full if -f $full;
	}
	closedir $cd;
	$thisSize;
}

sub updateVersionCfg{
	my $full = shift // die "no input file path for version-cfg";
	my $verString = shift // die "no version string for me";

	my $ts = walkSize(getcwd());
    open my $fout, '>', $full or die "cannot open version cfg.";
    print {$fout} "{\"version\":\"$verString\", \"size\":$ts,\"basever\":\"$_basever\", \"cdn\":\"$_cdnuri\"}";
    close $fout;
}

sub updateHashVer{
	my $full = shift // die "no input name";
	my $subName = shift // die "hash value file not present.";
	my $outFullPath = $G_VER_VER_HAS_FILE_PATH . $subName;
	my $hv = hashOne $full;
	open my $fout, '>', $outFullPath or die "cannot open $outFullPath for output";
	print {$fout} $hv;
	close $fout;

	$hv;
}

sub main {
	if( $#ARGV < 3 ){
		die "hash [version-string] [version-configure-file-name] [hash-table-file-MD5-file] [resource folder]\n";
	}

	die "no version supplied" if $ARGV[0] !~ /^([\w\d]+)\.([\w\d]+)\.([\w\d]+)$/imxs;
	die "no version configure file" if $ARGV[1] !~ /^[\w\.\d]+$/imxs;

	#
	my $versionString = $ARGV[0];
	my $vfile = $ARGV[1];
	my $hfile = $ARGV[2];
	my $resFolderName = $ARGV[3];

	my $destHashFilePath = getDestHashv() . "/$versionString.txt";
	print "generating table at " . $destHashFilePath, "\n";

	my $sourceDir = getcwd() . '/' . $resFolderName;
	die "Resource folder is not there:$sourceDir\n" if not -d $sourceDir;
	system("perl genHash.pl \"$sourceDir\" $versionString > " . $destHashFilePath);
	#print $?;
	die "error generating table" if $?;

	#print "done generating $out\n";
	updateVersionCfg $G_VER_SVR_FILE_PATH . $vfile, $versionString;
	my $ov = updateHashVer $destHashFilePath, $hfile;

	print "version update to $versionString\n";
	print "$ov\n";
}

main();
