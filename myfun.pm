use strict;

sub readLstFL {

    my $FL = shift @_;
    my @caseIDs;

    open( INPUT, "<$FL" ) || die("Cannot open $FL:$!");
    while (<INPUT>) {
        s/[\n\r]//gm;
        if (/^(\w+[\S]+)/) {
            push @caseIDs, $1;
        }

    }
    if ( !@caseIDs ) {
        die("Nothing read from $FL:$!");
    }

    my $num = scalar @caseIDs;
    print "$num cases are read from $FL.\n";

    return \@caseIDs;
}

sub isEmpty {
    my $fl  = shift @_;
    my $ans = 1;

    open( INPUT, "<$fl" ) || die("Cannot open $fl:$!");
    while (<INPUT>) {
        if (/[\S]+/) {
            $ans = 0;
            last;
        }
    }
    close INPUT;

    return $ans;
}

sub PDB2seq_old {

#read the pdb file of a haddock decoy into two hashes, one for sequences and one for atomResNum
#-- $seqs->{A} = 'JIONONVE'
#-- @{$atomResNum->{A}} = (1,2,3...)

#Note: When any non 20-types of amino acids are ignored and not included into the output $seqs and $atomResNum
#Note: Amino acids with insertion code are ignored and not included into the output $seqs and 4atomResNum.
#Note: AtomResNums are sorted.

    #For example,
    #ATOM      1  C   CYS     1       5.204  -2.385  14.536  1.00 10.00      A
    #ATOM      2  O   CYS     1       4.669  -2.445  15.671  1.00 10.00      A
    #ATOM      7  HT2 CYS     1       7.442  -4.834  15.131  1.00 10.00      A

    my $pdbFL = shift @_;

    #    print "Reading $pdbFL for seqs and atomResNum \n";

    my %three2one = (
        'ALA' => 'A',
        'ASX' => 'B',
        'CYS' => 'C',
        'ASP' => 'D',
        'GLU' => 'E',
        'PHE' => 'F',
        'GLY' => 'G',
        'HIS' => 'H',
        'ILE' => 'I',
        'XLE' => 'J',
        'LYS' => 'K',
        'LEU' => 'L',
        'MET' => 'M',
        'ASN' => 'N',
        'PYL' => 'O',
        'PRO' => 'P',
        'GLN' => 'Q',
        'ARG' => 'R',
        'SER' => 'S',
        'THR' => 'T',
        'SEC' => 'U',
        'VAL' => 'V',
        'TRP' => 'W',
        'XAA' => 'X',
        'TYR' => 'Y',
        'GLX' => 'Z',
    );

    my $seqs;
    my $atomResiNums;

    my @chnIDs;
    my $seqAAs;

    #-- read the pdf file

    open( INPUT, "<$pdbFL" ) || die("Cannot open $pdbFL:$!");

    while (<INPUT>) {
        s/[\n\r]//gm;

        if (/^ATOM/) {

            my $aa = substr( $_, 17, 3 );
            $aa =~
              s/\s+//g;   #- for nuclotide, there is only one letter code in pdb
            my $atomResiNum =
              substr( $_, 22, 4 );    #NOT including the insertion code
            $atomResiNum =~ s/[\s]+//g;
            my $chnID = substr( $_, 21, 1 );

            #-- extract seq info
            if ( length($aa) == 3 ) {

                #$aa is an amino acid
                if ( !defined $three2one{$aa} ) {
                    print(
"# WARNING: aa $aa does not belong to 20 types of amino acids. It is excluded from the output. Check this line in $pdbFL:\n # $_\n"
                    );
                    next;
                }

                $seqAAs->{$chnID}->{$atomResiNum} = $three2one{$aa};
            }
            else {

                $seqAAs->{$chnID}->{$atomResiNum} = $aa;
            }

        }

        if (/^ENDMDL/) {

            # for NMR pdb, only extract the first model

            print "\nWarning: only the first model is extracted !!\n\n";
            last;

        }

    }
    close INPUT;

    @chnIDs = keys %$seqAAs;

    if ( !@chnIDs ) {
        die("Nothing read from $pdbFL:$!");
    }

    #--- get the seq of each chain

    foreach my $chnID (@chnIDs) {

        #        print "Extract seq for chn $chnID ...\n";

        $seqs->{$chnID} = '';

        #        my @atomResNums_chn = @{ $atomResNums->{$chnID} };
        my @atomResNums_chn = keys %{ $seqAAs->{$chnID} };

        foreach my $atomResiNum ( sort { $a <=> $b } @atomResNums_chn ) {

            push @{ $atomResiNums->{$chnID} },
              $atomResiNum;    #-- record atomResNum

            if ( !$seqAAs->{$chnID}->{$atomResiNum} ) {
                die(
"aa not defined for chain $chnID and atomResiNum $atomResiNum:$!"
                );
            }

            $seqs->{$chnID} =
              $seqs->{$chnID} . $seqAAs->{$chnID}->{$atomResiNum};
        }

    }
    return ( $seqs, $atomResiNums );

}

#------------
sub writeSeqFL {

    my $header   = shift @_;
    my $seq      = shift @_;
    my $outputFL = shift @_;

    unlink $outputFL if ( -e $outputFL );
    open( OUTPUT, ">>$outputFL" ) or die("Cannot open $outputFL:$!");
    print OUTPUT ">$header\n";
    print OUTPUT "$seq\n";
    close OUTPUT;

    print "$outputFL generated.\n";

}

sub PDB2seq {

    #read the pdb file into two hashes, one for sequences and one for atomResNum
    #-- $seqs->{A} = 'JIONONVE'
    #-- @{$atomResNum->{A}} = (9001,1,2,3A,3B...)

#Note: When any non 20-types of amino acids are ignored and not included into the output $seqs and $atomResNum
#NOTE: atomResNums are NOT sorted.

    #For example,
    #ATOM      1  C   CYS     1       5.204  -2.385  14.536  1.00 10.00      A
    #ATOM      2  O   CYS     1       4.669  -2.445  15.671  1.00 10.00      A
    #ATOM      3  CB  CYS     1       5.408  -4.577  13.350  1.00 10.00      A
    #ATOM      4  SG  CYS     1       4.115  -5.477  14.237  1.00 10.00      A

    my $pdbFL = shift @_;

    #    print "Reading $pdbFL for seqs and atomResNum \n";

    my %three2one = (
        'ALA' => 'A',
        'ASX' => 'B',
        'CYS' => 'C',
        'ASP' => 'D',
        'GLU' => 'E',
        'PHE' => 'F',
        'GLY' => 'G',
        'HIS' => 'H',
        'ILE' => 'I',
        'XLE' => 'J',
        'LYS' => 'K',
        'LEU' => 'L',
        'MET' => 'M',
        'ASN' => 'N',
        'PYL' => 'O',
        'PRO' => 'P',
        'GLN' => 'Q',
        'ARG' => 'R',
        'SER' => 'S',
        'THR' => 'T',
        'SEC' => 'U',
        'VAL' => 'V',
        'TRP' => 'W',
        'XAA' => 'X',
        'TYR' => 'Y',
        'GLX' => 'Z',
        'CYM' => 'C',
        'CSP' => 'C',
        'CYF' => 'C',
        'CFE' => 'C',
        'NEP' => 'H',
        'ALY' => 'K',
        'M3L' => 'K',
        'SEP' => 'S',
        'TOP' => 'T',
        'TYP' => 'Y',
        'PTR' => 'Y',
        'TYS' => 'Y',
        'HYP' => 'P',
        'PTR' => 'Y',
    );

    my $seqs;
    my $atomResiNums;
    my $atomResiNum_prev;

    my @chnIDs;
    my $seqAAs;

    #-- read the pdf file

    open( INPUT, "<$pdbFL" ) || die("Cannot open $pdbFL:$!");

    while (<INPUT>) {
        s/[\n\r]//gm;

        if (/^ATOM/) {

            my $aa = substr( $_, 17, 3 );
            $aa =~
              s/\s+//g;   #- for nuclotide, there is only one letter code in pdb
            my $atomResiNum =
              substr( $_, 22, 5 );    # including the insertion code
            $atomResiNum =~ s/\s+//g;
            my $chnID = substr( $_, 21, 1 );

            if ( !defined $atomResiNum_prev ) {
                $atomResiNum_prev = $atomResiNum;
                push @{ $atomResiNums->{$chnID} },
                  $atomResiNum;       #-- record atomResNum
            }

            if ( $atomResiNum ne $atomResiNum_prev ) {
                push @{ $atomResiNums->{$chnID} },
                  $atomResiNum;       #-- record atomResNum
                $atomResiNum_prev = $atomResiNum;
            }

            #-- extract seq info
            if ( length($aa) == 3 ) {

                #$aa is possibly an amino acid

                if ( !defined $three2one{$aa} ) {
                    # $aa is not an amino acid
                    print(
"# WARNING: aa $aa does not belong to 20 types of amino acids. It is represented as a DOT. Check this line in $pdbFL:\n# $_\n"
                    );
                    $aa='.';
                    $seqAAs->{$chnID}->{$atomResiNum} = $aa;
                    next;
                }

                $seqAAs->{$chnID}->{$atomResiNum} = $three2one{$aa};
            }
            else {

                $seqAAs->{$chnID}->{$atomResiNum} = $aa;
            }

        }

        if (/^ENDMDL/) {

            # for NMR pdb, only extract the first model

            print "\n# Warning: only the first model is extracted !!\n\n";
            last;

        }

    }
    close INPUT;

    @chnIDs = keys %$seqAAs;

    if ( !@chnIDs ) {
        die("Nothing read from $pdbFL:$!");
    }

    #--- get the seq of each chain

    foreach my $chnID (@chnIDs) {

        #        print "Extract seq for chn $chnID ...\n";

        $seqs->{$chnID} = '';

        my @atomResNums_chn = @{ $atomResiNums->{$chnID} };

        foreach my $atomResiNum (@atomResNums_chn) {
            if ( !defined $seqAAs->{$chnID}->{$atomResiNum} ) {
                print(
"# WARNING: aa not defined for chain $chnID and atomResiNum $atomResiNum. This position may be not an amino acid!\n"
                );

                next;
            }

            $seqs->{$chnID} =
              $seqs->{$chnID} . $seqAAs->{$chnID}->{$atomResiNum};

        }

    }
    return ( $seqs, $atomResiNums );

}

#------------
sub unique {
    my @a = @_;
    my %seen;
    @seen{@a} = 1 x scalar(@a);
    @a = keys(%seen);
    return @a;

}

sub belong {

    my $a = shift @_;
    my @b = @{ shift @_ };
    my $ans;

    my %seen;
    @seen{@b} = (1) x scalar @b;

    if ( !defined $seen{$a} ) {
        $ans = 0;
    }
    else {
        $ans = 1;
    }

    return $ans;

}

sub changeSegID {
    my $pdbFL_ori = shift @_;
    my $new_segID = shift @_;
    my $pdbFL_new = shift @_;

    unlink $pdbFL_new if ( -e $pdbFL_new );
    open( INPUT,  "<$pdbFL_ori" )  or die("Cannot open $pdbFL_ori:$!");
    open( OUTPUT, ">>$pdbFL_new" ) or die("Cannot open $pdbFL_new:$!");
    while (<INPUT>) {
        s/[\n\r]//gm;

        if (/^ATOM[\s\t]+/) {
            substr( $_, 72, 1, $new_segID );
        }
        print OUTPUT "$_\n";

    }
    close INPUT;
    close OUTPUT;

    print "$pdbFL_new (with new segID $new_segID) generated. \n";
}

1;
