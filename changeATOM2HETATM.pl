#!/usr/bin/perl -w
#Li Xue
#Aug. 7th, 2014
#
#-- change non-aa (such as, GDP) in ATOM section to HETATM in pdb file (haddock cannot process it, 1GRN, 1F6M)
#
use strict;

my $pdbFL = shift @ARGV;

&changeATOM2HETATM($pdbFL);

sub changeATOM2HETATM {
    use File::Copy;

    my @aa = qw(Ala
      Arg
      Asn
      Asp
      Cys
      Glu
      Gln
      Gly
      His
      Ile
      Leu
      Lys
      Met
      Phe
      Pro
      Ser
      Thr
      Trp
      Tyr
      Val
      CYM
      CSP
      CYF
      NEP
      ALY
      MLZ
      MLY
      M3L
      HYP
      PTR
      SEP
      TOP
      TYP
      TYS);
    @aa = map { uc($_) } @aa;

    my $pdbFL = shift @_;

    my @HETATMresi;
    my $flag      = 0;              #$flag =1 meaning there is cofactor in ATM
    my $pdbFL_tmp = "$pdbFL.tmp";
    unlink $pdbFL_tmp if ( -e $pdbFL_tmp );
    open( OUTPUT, ">>$pdbFL_tmp" ) or die("Cannot open $pdbFL_tmp:$!");

    open( INPUT, "<$pdbFL" ) || die("Cannot open $pdbFL:$!");
    while (<INPUT>) {
        s/[\n\r]//gm;

        if (/^ATOM.+/) {
            my $resi = substr( $_, 17, 3 );
            my $line = $_;

            if ( !( $resi ~~ @aa ) ) {
                $flag = 1;
                substr( $line, 0, 6, 'HETATM' );
                push @HETATMresi, $resi;
            }
            print OUTPUT "$line\n";
        }
    }
    close INPUT;
    close OUTPUT;

    unlink $pdbFL;
    move( $pdbFL_tmp, $pdbFL ) or die("Cannot rename $pdbFL_tmp to $pdbFL:$!");

    if ( $flag == 1 ) {
        @HETATMresi = &unique(@HETATMresi);
        print
"$pdbFL had non-amino acid (@HETATMresi)in ATOM section. They are moved to HETATM section.\n";
    }
    else {

        print "$pdbFL has no cofactors. No atoms need to be moved to HETATM.\n";
    }

    #    my $command = "sed -r -i 's/^ATOM(.+$resi.+\$)/HETATM\\1/g' $pdbFL";
    #    print "$command\n";
    #    system($command) == 0
    #      or die("Cannot change GDP in ATOM to HETATM from $pdbFL:$!");
}

sub unique {
    my @a = @_;
    my %seen;
    @seen{@a} = 1 x scalar(@a);
    @a = keys(%seen);
    return @a;

}

