
package fileutils;

use strict;
use 5.010;
use warnings;
use base qw/Exporter/;

our @EXPORT_OK   = qw/getCopyFileCmd getDeleteFileCmd/;

#############################
# Platform dependent !!!
# Two parameter:  $source-path $target-path
sub getCopyFileCmd{
    my $full    = shift // die "No full";
    my $newFull = shift // die"No new full";
    my $rv;
    if ( $^O eq 'linux') {
        $rv = "cp -f \"$full\" \"$newFull\"";
    } else {
        $full    =~ s/\//\\/g;
        $newFull =~ s/\//\\/g;
        my $A = 'F';
        $A = 'Y' if -f $newFull;
        $rv = "echo $A | xcopy \"$full\" \"$newFull\""
    }
    $rv;
}


# Platform dependent !!!
# One parameter: $target-file-path
sub getDeleteFileCmd{
    my $fileName = shift // die "no input name";
    my $rv = '';
    if( $^O eq 'linux' ){
        $rv = "rm -rf \"$fileName\"";
    } else {
        $fileName =~ s/\//\\/g;
        if(-f $fileName){
            $rv = "del \"$fileName\" /f";
        } else {
            $rv = "rmdir \"$fileName\" /q/s";
        }
    }
    $rv;
}


1;

