#!/usr/bin/perl -w
#===============================================================================
#
#        Li Xue (), me.lixue@gmail.com
#        06/18/2016 12:23:24 PM
#
#  DESCRIPTION: Convert hhpred alignment to modeller alignment
#        INPUT 1 (hhpred alignement between Qry and whole seq of homolog):
#
#  Q T119              1 PSSDIIFGSGTLEKIGEETKKWG-DKAILVTGKSNMKKLGFLADAIDYLESAGVETVHYGEIEPNPTTTVVDEGAEIVLE   79 (393)
#  T 1vlj_A           20 NPTKIVFGRGTIPKIGEEIKNAGIRKVLFLYGGGSIKKNGVYDQVVDSLKKHGIEWVEVSGVKPNPVLSKVHEAVEVAKK   99 (407)
#
#
#  Q T119             80 EGCDVVVALGGGSSMDAAKGIAMVAGHSAEERDISVWDFAPEGDKETKPITEKTLPVIAATSTSGTGSHVTPYAVITNPE  159 (393)
#  T 1vlj_A          100 EKVEAVLGVGGGSVVDSAKAVAAGALY-----EGDIWDAFIG-----KYQIEKALPIFDVLTISATGTEMNGNAVITNEK  169 (407)
#
#
#
#        INPUT 2 (blast  alignement between whole seq of homolog and structual seq of this homolog):
#
#   Query  1    LPQKVMFGYGKSSAFLKQEVERRGSAKVMVIAGEREMSIAHKVASEIEVAIWHDEVVMHV  60
#               LPQKV FGYGKSSAFLKQEVERRGSAKV VIAGERE SIAHKVASEIEVAIWHDEVV HV
#   Sbjct  10   LPQKV-FGYGKSSAFLKQEVERRGSAKV-VIAGERE-SIAHKVASEIEVAIWHDEVV-HV  65
#
#   Query  61   PIEVAERARAVATDNEIDLLVCVGGGSTIGLAKAIAMTTALPIVAIPTTYAGSEATNVWG  120
#               PIEVAERARAVATDNEIDLLVCVGGGSTIGLAKAIA TTALPIVAIPTTYAGSEATNVWG
#   Sbjct  66   PIEVAERARAVATDNEIDLLVCVGGGSTIGLAKAIA-TTALPIVAIPTTYAGSEATNVWG  124
#
#       OUTPUT (alignment between the Qry and structual seq of this homolog):
#
#        USAGE: ./convert_hhpredAln_modellerAln.pl
#
#===============================================================================

use strict;
use warnings;
use utf8;

my $hhpred_alnFL = shift @ARGV;
my $blast_alnFL  = shift @ARGV;

my ( $qrySeq_aligned, $Homolog_wholeSeq_aligned_hhpred, $Homolog_wholeSeq_aligned_noGap_hhpred ) =
  &readHHpredAlnFL($hhpred_alnFL);

my ( $Homolog_wholeSeq_aligned_blast, $Homolog_pdbSeq_aligned_blast ) = &readBlastAlnFL($blast_alnFL);


#insert gaps in $Homolog_wholeSeq_aligned_hhpred to $homolog_pdbSeq_aligned_blast
while ($Homolog_wholeSeq_aligned_hhpred =~/-/g){
    substr($Homolog_wholeSeq_aligned_blast,$-[0],0, '-');
    substr($Homolog_pdbSeq_aligned_blast,$-[0],0, '-');
}
print ">qrySeq_aligned_in_hhpred\n$qrySeq_aligned\n";
print ">Homolog_aligned_in_hhpred (i.e., whole seq)\n$Homolog_wholeSeq_aligned_hhpred\n";
print ">Homolog_aligned_pdbSeq\n$Homolog_pdbSeq_aligned_blast\n";


#-------------------------------------------
sub readHHpredAlnFL {

#        INPUT 1 (hhpred alignement between Qry and whole seq of homolog):
#
#  Q T119              1 PSSDIIFGSGTLEKIGEETKKWG-DKAILVTGKSNMKKLGFLADAIDYLESAGVETVHYGEIEPNPTTTVVDEGAEIVLE   79 (393)
#  T 1vlj_A           20 NPTKIVFGRGTIPKIGEEIKNAGIRKVLFLYGGGSIKKNGVYDQVVDSLKKHGIEWVEVSGVKPNPVLSKVHEAVEVAKK   99 (407)
#
#
#  Q T119             80 EGCDVVVALGGGSSMDAAKGIAMVAGHSAEERDISVWDFAPEGDKETKPITEKTLPVIAATSTSGTGSHVTPYAVITNPE  159 (393)
#  T 1vlj_A          100 EKVEAVLGVGGGSVVDSAKAVAAGALY-----EGDIWDAFIG-----KYQIEKALPIFDVLTISATGTEMNGNAVITNEK  169 (407)
#
#
#
#        INPUT 2 (blast  alignement between whole seq of homolog and structual seq of this homolog):
#
#       OUTPUT (alignment between the Qry and structual seq of this homolog):
#
#        USAGE: ./convert_hhpredAln_modellerAln.pl
#
#===============================================================================

    use strict;
    use warnings;
    use utf8;

    my $hhpred_alnFL = shift @_;

    my $alignedSeq_Qry     = '';
    my $alignedSeq_Homolog = '';

    open( INPUT, "<$hhpred_alnFL" ) or die("Cannot open $hhpred_alnFL:$!");
    while (<INPUT>) {
        s/[\n\r]//mg;

        if (/(ss_pred|Consensus|ss_dssp|ss_pred)/i) {
            next;
        }

        if (/^\s*(Q.+$)/) {
            my @tmp = split( /\s+/, $1 );
            $alignedSeq_Qry = $alignedSeq_Qry . $tmp[3];
        }
        if (/^\s*(T.+$)/) {
            my @tmp = split( /\s+/, $1 );
            $alignedSeq_Homolog = $alignedSeq_Homolog . $tmp[3];
        }

    }
    close INPUT;

    #-- remove gaps
    my $alignedSeq_Homolog_noGap = $alignedSeq_Homolog;
    $alignedSeq_Homolog_noGap =~ s/\-//g;

    if (   !defined $alignedSeq_Homolog
        || !defined $alignedSeq_Qry
        || !defined $alignedSeq_Homolog_noGap )
    {
        die("Nothing read from $hhpred_alnFL:$!");
    }

    return ( $alignedSeq_Qry, $alignedSeq_Homolog, $alignedSeq_Homolog_noGap );
}

sub readBlastAlnFL {

#        INPUT  (blast  alignement between whole seq of homolog and structual seq of this homolog):
#   Query  1    LPQKVMFGYGKSSAFLKQEVERRGSAKVMVIAGEREMSIAHKVASEIEVAIWHDEVVMHV  60
#               LPQKV FGYGKSSAFLKQEVERRGSAKV VIAGERE SIAHKVASEIEVAIWHDEVV HV
#   Sbjct  10   LPQKV-FGYGKSSAFLKQEVERRGSAKV-VIAGERE-SIAHKVASEIEVAIWHDEVV-HV  65
#
#   Query  61   PIEVAERARAVATDNEIDLLVCVGGGSTIGLAKAIAMTTALPIVAIPTTYAGSEATNVWG  120
#               PIEVAERARAVATDNEIDLLVCVGGGSTIGLAKAIA TTALPIVAIPTTYAGSEATNVWG
#   Sbjct  66   PIEVAERARAVATDNEIDLLVCVGGGSTIGLAKAIA-TTALPIVAIPTTYAGSEATNVWG  124
#
#
#
#       OUTPUT (alignment between the Qry and structual seq of this homolog):
#
#        USAGE: ./convert_hhpredAln_modellerAln.pl
#
#===============================================================================

    use strict;
    use warnings;
    use utf8;

    my $blast_alnFL = shift @_;

    my $alignedSeq_Qry     = '';
    my $alignedSeq_Homolog = '';

    open( INPUT, "<$blast_alnFL" ) or die("Cannot open $blast_alnFL:$!");
    while (<INPUT>) {
        s/[\n\r]//mg;

        if (/^\s*(Query.+$)/) {
            my @tmp = split( /\s+/, $1 );
            $alignedSeq_Qry = $alignedSeq_Qry . $tmp[2];
        }
        if (/^\s*(Sbjct.+$)/) {
            my @tmp = split( /\s+/, $1 );
            $alignedSeq_Homolog = $alignedSeq_Homolog . $tmp[2];
        }

    }
    close INPUT;

    if (   !defined $alignedSeq_Homolog
        || !defined $alignedSeq_Qry )
    {
        die("Nothing read from $blast_alnFL:$!");
    }

    return ( $alignedSeq_Qry, $alignedSeq_Homolog );
}
