#!/usr/bin/perl -w
#===============================================================================
#
#        Li Xue (), me.lixue@gmail.com
#        07/07/2014 12:13:08 PM
#
#  DESCRIPTION: split an ensemble file into multiple pdb files
#        INPUT:
#       OUTPUT:
#
#        USAGE: ./pdb_split.pl
#
#        NOTES: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use File::Basename;

my $ensemblePDBfl = shift @ARGV;
my $dir           = dirname($ensemblePDBfl);

my $modelID;
my $outputFL;
my $num_models = 0;
open( INPUT, "<$ensemblePDBfl" ) or die("Cannot open $ensemblePDBfl:$!");
while (<INPUT>) {
    s/[\n\r]//mg;
    if (/^MODEL/) {

        #        MODEL        1
        ( my $model, $modelID ) = split( /\s+/, $_ );
        $outputFL = "$dir/$modelID.pdb";
        unlink $outputFL if ( -e $outputFL );
        $num_models++;
    }
    open( OUTPUT, ">>$outputFL" ) or die("Cannot open $outputFL:$!");
    print OUTPUT "$_\n";
    close OUTPUT;

}
close INPUT;
print "There are totally $num_models models in $ensemblePDBfl\n";
