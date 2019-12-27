#!/usr/bin/perl -w
#===============================================================================
#
#        Li Xue (), me.lixue@gmail.com
#        05/18/2015 04:16:22 PM
#
#  DESCRIPTION: split a pdb file at a specified atomResNum
#        INPUT:
#       OUTPUT:
#
#        USAGE: ./splitpdb_at_loop.pl
#
#        NOTES: ---
#===============================================================================

use strict;
use warnings;
use utf8;

my $pdbFL= shift @ARGV;
my $atomResNum_split = shift @ARGV;
my $flag =0;

unlink "$pdbFL.1" if (-e "$pdbFL.1");
unlink "$pdbFL.2" if (-e "$pdbFL.2");

open(OUTPUT1, ">>$pdbFL.1") or die ("Cannot open $pdbFL.1:$!");
open(OUTPUT2, ">>$pdbFL.2") or die ("Cannot open $pdbFL.2:$!");

open (INPUT, "<$pdbFL")or die ("cannot open $pdbFL:$!");
while(<INPUT>){
    s/[\n\r]//mg;
    if (/^(ATOM|HETATM)/){
        my $atomResiNum =substr( $_, 22, 5 );    # including the insertion code
        $atomResiNum =~ s/\s+//g;

        if ($atomResiNum =~ /$atomResNum_split/){
            $flag = 1;
        }

        if ($flag ==1){
            print  OUTPUT2  "$_\n" ;
        }
        else{
            print OUTPUT1 "$_\n" ;
        }
    }
}
close INPUT;
close OUTPUT1;
close OUTPUT2;

print "$pdbFL splited at atomResNum $atomResNum_split. $pdbFL.1 and $pdbFL.2 generated.\n";



