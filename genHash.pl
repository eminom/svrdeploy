
#
# Generate hash for all resource files
# March 28th. 2o14
# Revisited on August.3rd.2o15
# This script is called by the master script<hash.pl>

BEGIN { do './config.pl'; }

use 5.010;
use strict;
use warnings;

use Cwd qw/getcwd/;
use File::Path qw/mkpath/;
use hashmod qw/hashOne hashXX/;
use fileutils qw/getCopyFileCmd getDeleteFileCmd/;

# Global configuration

our $G_VER;
our $G_DEPLOY_ROOT;
our $G_DEPLOY_HASH;
our $G_VER_SVR_FILE_PATH;
our $G_VER_VER_HAS_FILE_PATH;


# Parameters
# 
sub walkNow{
    my $baseNow = shift // die "no base";   # $baseNow shall always ends with a slash. 
    my $dirNow  = shift // die "no dir for now";
    my $pro_ref = shift // \&dummm;
    my @nextD;
    opendir my $cd, $dirNow or die "no open for \"$dirNow\"";
    while (my $f = readdir $cd)  {
        next if grep{$f eq $_} qw/. .. .git .gitignore/;
        my $now = $dirNow . '/'. $f;
        if(-d $now) {
            push @nextD, $now;
            next;
        }
        # Filter some files out
        if( $f !~ /\.pl$/imxs &&
            $f !~ /\.pm$/imxs) {
            #print $now,"\n";
            my $sub = substr($now, length($baseNow));
            $pro_ref->($sub, $now);
        }
    }
    closedir $cd;
    walkNow($baseNow, $_, $pro_ref) for @nextD;
}

my $gc = 0;

sub getReplacedName{
    my $name      = shift // die 'no origin name';
    my $new_short = shift // die 'no hash string';
    my $suffix = '';
    my $lpos  = rindex($name, '.');
    my $slpos = rindex($name, '/');
    $slpos    = rindex($name, '\\') if $slpos < 0;
    $suffix   = substr($name, $lpos) if $lpos>=0 and ($slpos < 0 or $slpos < $lpos);
    return $new_short . $suffix;
}

sub processOneRes{
	my $name = shift // die 'no file name';
	my $full = shift // die 'no full path name';
	my $hashv = hashOne $full;
    my $xxhash= hashXX $full;
	my $size = -s $full;
    $size = sprintf "%10d", $size;
	$gc++;
    my $newName = getReplacedName $name, $hashv;
    #my $newFull = $G_DEPLOY_ROOT . '/' . $G_VER . '/' . $newName;
    my $newFull = $G_DEPLOY_ROOT . '/' . $newName;	#No more version file. 
    my $cmd = getCopyFileCmd($full, $newFull);
    `$cmd`;
    die "cannot copy $full" if $?;
    print "$newName\t$size\t$xxhash\t$name\n";
}

sub cleanMd5ResFolder {
    my $dest = $G_DEPLOY_ROOT . '/' . $G_VER;
    if( -d $dest){
        my $cmd = getDeleteFileCmd($dest);
        `$cmd`;
        die "Cannot remove $dest" if $?;
        # print("done cleanning $dest");
    } else {
        # print"no $dest, create new one\n";
    }

    #Now the resource are all under one folder. Flat and simple but too many files side-by-side
    mkpath $G_DEPLOY_ROOT;
    die "cannot create $G_DEPLOY_ROOT" if not -d $G_DEPLOY_ROOT;

    #mkpath $dest;
    #die "cannot create $dest" if not -d $dest;
}

sub deployMd5Resources{
	#my $based = getcwd;
	my $based = shift or die "No no no";
	walkNow($based.'/', $based, \&processOneRes);
	# print $gc,"\n";
}

sub checkHelp{
    my ($force) = @_;
    if($force or grep{$_ eq "-help"}@ARGV){
        print "Usage:\n"
         . "genHash.pl <folder-name> <version-code>\n"
         . "<folder-name>: usually a sub folder of current working directory\n"
         . "<version-code>: must fit the regular expression of A.B.C\n";
        exit
    }
}

sub main {
    # Entry
    my $pat = '^([\w\d]+)\.([\w\d]+)\.([\w\d]+)$';
    if ( $#ARGV >= 1 && $ARGV[1] =~ qr/$pat/imxs ){
        $G_VER = $ARGV[1];
    } else {
    	# print $#ARGV,"\n";
        printf STDERR "You need to specify a version to deploy.\n\n";
        checkHelp 1;
    }

    my $startRoot = $ARGV[0];
    die "Target folder do not exist !\n" if not -d $startRoot;
    cleanMd5ResFolder;
    deployMd5Resources $startRoot;
}

# The only entry>>
checkHelp;
main;

__END__

This file is used to deploy resource server.
Bubble, bubble, bubble
