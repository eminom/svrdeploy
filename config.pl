
# Global config
my $_SvrRoot;

if('linux' eq $^O || 'darwin' eq $^O){
	$_SvrRoot = "$ENV{HOME}/Major/events/";
} else {
 	$_SvrRoot = 'F:/JokerStuff/AppX/events/';
 }

 my $interm = '/resfolder/';

our $G_VER = '0.0.0';
our $G_DEPLOY_ROOT = $_SvrRoot . $interm . 'res';
our $G_DEPLOY_HASH = $_SvrRoot . $interm . 'hashv';
our $G_VER_SVR_FILE_PATH = $_SvrRoot . $interm;
our $G_VER_VER_HAS_FILE_PATH = $_SvrRoot . $interm;

#die "no such directory $G_DEPLOY_HASH\n" if not -d $G_DEPLOY_HASH;

1;
