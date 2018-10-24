#!/usr/bin/perl -w
# Li Xue
# Dec. 2013

use strict;
use lib '/home/lixue/tools/PDB_related';
use myfun;

if ( scalar @ARGV == 0 ) {
    print
"\nUsage:\n\t./PDB2AtomResNum.pl <pdbFL> [chainID] (chainID is optional)\n\n";
    exit;
}

my $pdbFL      = shift @ARGV;
my $chnID_user = shift @ARGV;
my ( $seqs, $atomResNums ) = &PDB2seq($pdbFL);

#-- $seqs->{A} = 'JIONONVE'
#-- @{$atomResNum->{A}} = (1,2,3A,3B...)
#
print "#generated by PDB2AtomResNum.pl\n\n";
if ( defined $chnID_user ) {

    if ( !defined $seqs->{$chnID_user} ) {
        die("chain ID $chnID_user does not exist in this pdb file:$!");
    }
    my $sequence       = $seqs->{$chnID_user};
    my @atomResNum_chn = @{ $atomResNums->{$chnID_user} };

    print "#chainID,seqnum,aa,atomResnum\n";

    for ( my $i = 0 ; $i < scalar @atomResNum_chn ; $i++ ) {
        my $aa = substr( $sequence, $i, 1 );
        my $seqNum = $i + 1;

        print "$chnID_user,$seqNum,$aa,$atomResNum_chn[$i]\n";
    }

}
else {

    print "#chainID,seqnum,aa,atomResnum\n";
    foreach my $chnID ( keys %$seqs ) {

        my @atomResNum_chn = @{ $atomResNums->{$chnID} };
        my $sequence       = $seqs->{$chnID};
        for ( my $i = 0 ; $i < scalar @atomResNum_chn ; $i++ ) {
            my $aa = substr( $sequence, $i, 1 );
            my $seqNum = $i + 1;
            print "$chnID,$seqNum,$aa,$atomResNum_chn[$i]\n";

        }

    }
}
