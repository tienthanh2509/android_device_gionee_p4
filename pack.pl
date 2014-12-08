#!/usr/bin/perl

#
# script from Android-DLS WiKi
#
# changes by Bruno Martins:
#   - modified to work with MT6516 boot and recovery images (17-03-2011)
#   - included support for MT65x3 and eliminated the need of header files (16-10-2011)
#   - added cygwin mkbootimg binary and propper fix (17-05-2012)
#   - included support for MT65xx logo images (31-07-2012)
#   - added colored screen output (04-01-2013)
#   - included support for logo images containing uncompressed raw files (06-01-2013)
#   - re-written check of needed binaries (13-01-2013)
#   - added rgb565 <=> png images conversion (27-01-2013)
#

use v5.14;
use warnings;
use Cwd;
use Compress::Zlib;
use Term::ANSIColor;
use FindBin qw($Bin);
use File::Basename;

my $dir = getcwd;

repack_boot();

sub repack_boot {
	my ($signature, $ramdiskfile) = @ARGV;

	open (RAMDISKFILE, $ramdiskfile) or die colored ("Error: could not open ramdisk file 'ramdisk'", 'red') . "\n";
	my $ramdisk;
	while (<RAMDISKFILE>) {
		$ramdisk .= $_;
	}
	close (RAMDISKFILE);

	# generate the header according to the ramdisk size
	my $sizeramdisk = length($ramdisk);
	my $header = gen_header($signature, $sizeramdisk);

	# attach the header to ramdisk
	my $newramdisk = $header . $ramdisk;

	open (RAMDISKFILE, ">$ramdiskfile");
	binmode (RAMDISKFILE);
	print RAMDISKFILE $newramdisk or die;
	close (RAMDISKFILE);
}

sub gen_header {
	my ($header_type, $length) = @_;

	return pack('a4 L a32 a472', "\x88\x16\x88\x58", $length, $header_type, "\xFF"x472);
}

