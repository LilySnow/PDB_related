#!/usr/bin/perl -w
# LI Xue
# Dec. 2013

use strict;
use File::Basename;
use lib dirname (__FILE__);
#use lib '/home/lixue/tools/PDB_related';
use myfun;

if (scalar @ARGV ==0){
	print "\nUsage:\n\tPDB2SEQ.pl pdbFL chain_ID (chain_ID is optional)\n\n";
	exit;
}



my $pdbFL = shift @ARGV;
my $chnID_user = shift @ARGV;




my ($seqs, $atomsResNums)=&PDB2seq($pdbFL);

if (defined $chnID_user){

    if (! defined $seqs->{$chnID_user}){
		die("chain ID $chnID_user does not exist in this pdb file:$!");
	}

	print ">$chnID_user\n";
	print "$seqs->{$chnID_user}\n";
	exit 0;

}

foreach my $chnID (keys %$seqs){

	print ">$chnID\n";
	print "$seqs->{$chnID}\n";
}
