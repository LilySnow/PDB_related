#!/usr/bin/perl -w
#===============================================================================
#
#        Li Xue (me.lixue@gmail.com)
#        04/12/2016 04:39:56 PM
#
#  DESCRIPTION:
#        INPUT: A pdb file
#       OUTPUT: Extract all the residues from the input pdb file and write them into seperate zone files (one chain one file)
#
#        USAGE: ./zone.pl pdb_file
#
#        NOTES: This script prepares zone files for ProFit (http://www.bioinf.org.uk/programs/profit/)
#===============================================================================

use strict;
use warnings;
use utf8;
use File::Basename;


my $targetPDBfl = shift @ARGV;


if ( ! defined $targetPDBfl ){
    print "\n\tUsage: perl zone.pl pdbFL\n\n";
    exit;
}

my $dirname = dirname ($targetPDBfl);
my $name = basename ($targetPDBfl);
my $atomResNumFL = "$dirname/$name.atomResNum";
system("PDB2AtomResNum.pl $targetPDBfl > $atomResNumFL ") ==0 or die ("Cannot create atomResNum file:$!");

my $atomResNums = &readAtomResNumFL($atomResNumFL); # $atomResNums->{chainID} = (atomResNum1, atomResNum2, ...)

#-- write zone files
foreach my $chainID (keys %$atomResNums){
    my $zoneFL = "$dirname/$chainID.zone";

    unlink $zoneFL if (-e $zoneFL);

    open(OUTPUT,">>$zoneFL") or die ("Cannot open $zoneFL:$!");

    foreach my $atomResNum (@{$atomResNums->{$chainID}}){

         print OUTPUT "zone $chainID$atomResNum-$chainID$atomResNum\n";
    }

    close OUTPUT;
}


#- clean up
unlink $atomResNumFL if (-e $atomResNumFL);


#--------------------------

sub readAtomResNumFL{
    #chainID,seqnum,aa,atomResnum
    #A,1,E,21
    #A,2,R,22
    #A,3,V,23


    my $atomResNumFL = shift @_;
    my $atomResNums;
    open(INPUT, "<$atomResNumFL") or die ("Cannot open $atomResNumFL:$!");
    while(<INPUT>){
        s/[\n\r]//gm;
        if (/^\w{1},/){
            my ($chainID, $seqResNum, $aa, $atomResNum) = split(/,/,$_);
            push @{$atomResNums->{$chainID}}, $atomResNum;
        }
    }
    close INPUT;

    if (! defined $atomResNums){
        die ("Nothing read from $atomResNumFL:$!");
    }

    return $atomResNums;
}








