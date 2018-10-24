#!/usr/bin/env perl
#===============================================================================
#
#  Li Xue , me.lixue@gmail.com
#  12/02/2014 06:10:12 AM
#
#  DESCRIPTION: add atomResNums to pssm files
#
#  INPUT 1 (atomResNum file):
#       chainID,seqnum,aa,atomResnum
#       A,1,G,1
#       A,2,D,2
#       A,3,K,3
#  INPUT 2 (pssm file):
#          A  R  N  D  C  Q  E  G  H  I  L  K  M  F  P  S  T  W  Y  V
#    1 G    1 -3 -1 -2 -3 -3 -3  6 -3 -4 -4 -2 -3 -4 -3 -1 -2 -3 -4 -4
#    2 D   -2 -2  3  4 -4 -1  3  2  0 -4 -2 -1 -3 -4 -2  0  0 -4 -3 -3

#  OUTPUT:
#
#  atomResNum seqResNum aa_1L A  R  N  D  C  Q  E  G  H  I  L  K  M  F  P  S  T  W  Y  V
#  9  1 G    1 -3 -1 -2 -3 -3 -3  6 -3 -4 -4 -2 -3 -4 -3 -1 -2 -3 -4 -4
#  10 2 D   -2 -2  3  4 -4 -1  3  2  0 -4 -2 -1 -3 -4 -2  0  0 -4 -3 -3
#
#
#  USAGE: ./addAtomResNum2pssm.pl
#===============================================================================

use strict;
use warnings;
use utf8;


my $pssmFL = shift @ARGV;
my $atomResNumFL = shift @ARGV;

if (!defined $atomResNumFL){
    print "\nUsage: ./addAtomResNum2pssm.pl pssm_file atomResNum_file (note: atomResNum_file is generated by PDB2AtomResNum.pl) \n\n";
    exit;
}
my ($atomResNums, $AA) = &readAtomResNumFL($atomResNumFL);

print "#generated by $0\n";

open(INPUT, "<$pssmFL") or die ("Cannot open $pssmFL:$!");
while(<INPUT>){
    s/[\n\r]//mg;

    if (/Last position-specific/i){
        $_="atomResNum, seqResNum, aa_1L, $_";
    }
    if (/^\s+(\d+)\s+(\w{1})\s+/){

         #  1 G    1 -3 -1 -2 -3 -3 -3  6 -3 -4 -4 -2 -3 -4 -3 -1 -2 -3 -4 -4
         my $seqResNum = $1;
         my $aa_1L = $2;
         my $atomResNum = $atomResNums->{$seqResNum};

         if (!defined $atomResNum){
             die "seqResNum $seqResNum does not have atomResNum in $atomResNumFL:$!";
         }

         if ($aa_1L ne $AA->{$seqResNum}){
             die ("$aa_1L with seqResNum $seqResNum in pssm ($pssmFL) is not consistent with the aa $AA->{$seqResNum} in $atomResNumFL:$!");
         }

         $_="$atomResNum $_\n";
    }
    print "$_\n";

}
close INPUT;

sub readAtomResNumFL{

#  INPUT  (atomResNum file):
#       chainID,seqnum,aa,atomResnum
#       A,1,G,1
#       A,2,D,2

    my $atomResNumFL = shift @_;
    my %atomResNums;
    my %AA;

    open(INPUT, "<$atomResNumFL")or die ("Cannot open $atomResNumFL:$!");
    while(<INPUT>){
        s/[\n\r]//mg;
        if (/^\w{1},\d+,\w{1},[\d\-]+/){
            my ($chnID, $seqResNum, $aa, $atomResNum)=split(/,/,$_);
            $atomResNums{$seqResNum}=$atomResNum;
            $AA{$seqResNum}=$aa;

        }
    }
    close INPUT;


    if (!%atomResNums || !%AA){
        die("Nothing read from $atomResNumFL:$!");

    }
    return (\%atomResNums, \%AA);
}





