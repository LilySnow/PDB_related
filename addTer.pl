#!/usr/bin/env perl
#===============================================================================
#
#        Li Xue (me.lixue@gmail.com)
#        07/24/2017 03:30:47 PM
#        Utrecht University
#
#  DESCRIPTION:
#        INPUT:
#       OUTPUT:
#
#        USAGE: ./addTer.pl
#
#===============================================================================

use strict;
use warnings;
use utf8;

my $pdbfl=shift @ARGV;
open(INPUT, "<$pdbfl") or die ("Cannot open $pdbfl:$!");

my $chnID;
my $chnID_prev;

while(<INPUT>){
    if (/^ATOM/){

        if (defined $chnID){
            $chnID_prev = $chnID;
        }
        $chnID = substr($_,21,1 );

        if (defined $chnID_prev && $chnID  ne $chnID_prev){
            print "TER\n";
        }

    }
    if (/^END/){
        print "TER\n";
    }
    print $_;
}
close INPUT;


