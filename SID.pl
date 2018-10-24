#!/usr/bin/perl -w
#===============================================================================
#
#        Li Xue (), me.lixue@gmail.com
#        10/13/2016 05:57:22 PM
#
#  DESCRIPTION: calculate SID between two strings
#        INPUT:
#       OUTPUT:
#
#        USAGE: ./SID.pl
#
#        NOTES: ---
#===============================================================================

use strict;
use warnings;
use utf8;

my $a= shift @ARGV;
my $b= shift @ARGV;

if (length($a) ne length($b)){
    print("two strings have to have the same length!\n");
    exit;
}

my @a_tmp = split(//, $a);
my @b_tmp = split(//, $b);

my $num_sameAA=0;


for (my $i=0;$i<scalar @a_tmp; $i++){

    if ($a_tmp[$i] eq $b_tmp[$i]){
        $num_sameAA++;
    }
}

my $SID = $num_sameAA/length($a);
print "SID = $SID\n";
