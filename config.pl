
# Global config
my $_SvrRoot;

if('linux' eq $^O){
	$_SvrRoot = '/rsvr/events/';
} else {
 	$_SvrRoot = 'E:/node/svr/events/';
 }

 my $interm = '/resfolder/';

our $G_VER = '0.0.0';
our $G_DEPLOY_ROOT = $_SvrRoot . $interm . 'res';
our $G_DEPLOY_HASH = $_SvrRoot . $interm . 'hashv';
our $G_VER_SVR_FILE_PATH = $_SvrRoot . $interm;
our $G_VER_VER_HAS_FILE_PATH = $_SvrRoot . $interm;

#die "no such directory $G_DEPLOY_HASH\n" if not -d $G_DEPLOY_HASH;

1;