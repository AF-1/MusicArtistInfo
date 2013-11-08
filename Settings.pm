package Plugins::MusicArtistInfo::Settings;

use strict;
use base qw(Slim::Web::Settings);

use Slim::Utils::Prefs;

use constant CAN_IMAGEPROXY => (Slim::Utils::Versions->compareVersions($::VERSION, '7.8.0') >= 0);

my $prefs = preferences('plugin.musicartistinfo');
my $serverprefs = preferences('server');

sub name {
	return 'PLUGIN_MUSICARTISTINFO';
}

sub prefs {
	return ($prefs, 'browseArtistPictures', 'runImporter', 'lookupArtistPictures', 'lookupCoverArt', 'artistImageFolder', 'saveArtistPictures', 'saveCoverArt');
}

sub page {
	return 'plugins/MusicArtistInfo/settings.html';
}

sub handler {
	my ($class, $client, $paramRef, $pageSetup) = @_;

	# artfolder is a server setting - need to handle it manually
	if ($paramRef->{'saveSettings'}) {
		$serverprefs->set('artfolder', $paramRef->{artfolder});

		# XXX - what's wrong here? We should not need to do this!
		my (undef, @prefs) = $class->prefs();
		foreach (@prefs) {
			$paramRef->{"pref_$_"} ||= '';
		}
	}
	
	my $imageFolder = $paramRef->{pref_artistImageFolder} || $prefs->get('artistImageFolder');
	
	# disable saving to image folder if it isn't writeable
	if ( !($imageFolder && -d $imageFolder && -w $imageFolder) ) {
		$paramRef->{savePicturesDisabled} = 1;
	}
	
	$paramRef->{limited}   = !CAN_IMAGEPROXY;
	$paramRef->{artfolder} = $serverprefs->get('artfolder');
	
	if ( !($paramRef->{artfolder} && -d $paramRef->{artfolder} && -w $paramRef->{artfolder}) ) {
		$paramRef->{saveAlbumCoversDisabled} = 1;
	}
	
	$class->SUPER::handler($client, $paramRef, $pageSetup)
}

1;