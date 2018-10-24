#!/usr/bin/perl -w
#===============================================================================
#
#        Li Xue (), me.lixue@gmail.com
#        07/02/2014 09:47:28 PM
#
#  DESCRIPTION: Given an atom-atom contact file for a pdb file, calculate the min distance for each residue pair.
#        INPUT:
#          55 A NH1 91 B O 4.477514
#          55 A CZ 92 B O 4.837903
#          55 A NH1 92 B CB 4.827626
#          55 A NH1 92 B C 4.705795
#       OUTPUT:
#
#
#
#===============================================================================

use strict;
use warnings;
use utf8;

my $contactFL_ori = shift @ARGV;


if (!defined $contactFL_ori){
    print "\n\tPlease input an atom-atom contact file. \n\n";
    print "\tThe contact file example:\n";
    print "\n\t55 A NH1 91 B O 4.477514\n\t55 A CZ 92 B O 4.837903\n\t55 A NH1 92 B CB 4.827626\n\n";

    exit;
}

open( INPUT, "<$contactFL_ori" ) or die("Cannot open $contactFL_ori:$!");
my $min_contact;

my $record;    #record the line with min distance

while (<INPUT>) {
    s/[\n\r]//gm;
    if (/^\d+/) {
        my ( $resiNum1, $chnA, $atom1, $resiNum2, $chnB, $atom2, $dist ) =
          split( /\s+/, $_ );

        if ( !defined $min_contact->{"$resiNum1$chnA$resiNum2$chnB"} ) {

            $min_contact->{"$resiNum1$chnA$resiNum2$chnB"} = $dist;
            $record->{"$resiNum1$chnA$resiNum2$chnB"} = $_;
        }
        if ( $min_contact->{"$resiNum1$chnA$resiNum2$chnB"} > $dist ) {

            $min_contact->{"$resiNum1$chnA$resiNum2$chnB"} = $dist;
            $record->{"$resiNum1$chnA$resiNum2$chnB"}      = $_;
        }

    }
}
close INPUT;

my @final_lines = values %$record;
my $final= join("\n", @final_lines);

print $final;
