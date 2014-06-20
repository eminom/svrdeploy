
#
# Generate hash for all resource files
# March 28th. 2o14

BEGIN { do './config.pl'; }

use 5.010;
use strict;
use warnings;

use Cwd qw/getcwd/;
use File::Path qw/mkpath/;
use hashmod qw/hashOne/;

# Global configuration

our $G_VER;
our $G_DEPLOY_ROOT;
our $G_DEPLOY_HASH;
our $G_VER_SVR_FILE_PATH;
our $G_VER_VER_HAS_FILE_PATH;


# Platform dependent !!!
sub getCopyCmd{
    my $full = shift // die "No full";
    my $newFull = shift//die"No new full";

    my $rv = '';
    if( $^O eq 'linux'){
        $rv = "cp -f \"$full\" \"$newFull\"";
    } else {
        $full    =~ s/\//\\/g;
        $newFull =~ s/\//\\/g;
        my $A = 'F';
        $A = 'Y' if -f $newFull;
        $rv = "echo $A | xcopy \"$full\" \"$newFull\""
    }

    ## 
    $rv;
}

# Platform dependent !!!
sub getDeleteFileCmd{
    my $fileName = shift // die "no input name";
    my $rv = '';
    if( $^O eq 'linux' ){
        $rv = "rm -rf \"$fileName\"";
    } else {
        $fileName =~ s/\//\\/g;
        $rv = "rmdir \"$fileName\" /q/s";
    }

    $rv;
}


# Parameters
# 
sub walkNow{
    my $baseNow = shift // die "no base";
    my $dirNow = shift // die "no dir for now";
    my $pro_ref = shift // \&dummm;

    my @nextD;
    opendir my $cd, $dirNow or die "no open for \"$dirNow\"";

    while( my $f = readdir $cd )
    {
        next if $f eq '.' or $f eq '..';
        next if $f eq '.git';
        next if $f eq '.gitignore';

        my $now = $dirNow . '/'. $f;

        if(-d $now)
        {
            push @nextD, $now;
            next;
        }

        # Filter some files out
        if( $f !~ /\.pl$/imxs &&
            $f !~ /\.pm$/imxs)
        {
            #print $now,"\n";
            my $sub = substr($now, length($baseNow));
            $pro_ref->($sub, $now);
        }
    }
    closedir $cd;

    #print "Site 100\n";
    for(@nextD)
    {
        walkNow($baseNow, $_, $pro_ref);
    }
}

my $gc = 0;

sub getMd5Name{
    my $name = shift // die 'no origin name';
    my $hashv = shift // die 'no hash string';

    my $suffix = '';
    my $lpos = rindex($name, '.');
    my $slpos = rindex($name, '/');
    if($slpos < 0){
        $slpos = rindex($name, '\\');
    }

    $suffix = substr($name, $lpos) if $lpos>=0 and ($slpos < 0 or $slpos < $lpos);
    return $hashv . $suffix;
}

sub processOneRes{
	my $name = shift // die 'no file name';
	my $full = shift // die 'no full path name';
	my $hashv = hashOne $full;
	my $size = -s $full;
	#print "$name\t$hashv\t$size\n";
	$gc++;

    # 
    my $newName = getMd5Name $name, $hashv;
    #my $newFull = $G_DEPLOY_ROOT . '/' . $G_VER . '/' . $newName;
    my $newFull = $G_DEPLOY_ROOT . '/' . $newName;	#No more version file. 

    #Platform dependent
    my $cmd = getCopyCmd($full, $newFull);
    `$cmd`;
    die "cannot copy $full" if $?;

    print "$name\t$newName\t$size\n";
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


sub main {
    # Entry
    my $pat = '^([\w\d]+)\.([\w\d]+)\.([\w\d]+)$';
    if ( $#ARGV >= 1 && $ARGV[1] =~ qr/$pat/imxs ){
        $G_VER = $ARGV[1];
    } else {
    	print $#ARGV,"\n";
        printf STDERR "You need to specify a version to deploy\n";
        exit -1;
    }

    die "target folder do not exist !\n" if not -d $ARGV[0];
    my $startRoot = $ARGV[0];
    cleanMd5ResFolder;
    deployMd5Resources($startRoot);
}

# The only entry>>
main;

__END__

This file is used to deploy resource server.
Bubble, bubble, bubble
