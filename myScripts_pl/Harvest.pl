#! /usr/bin/perl -w

# by Zbigniew Karolczuk, updated 09 August 2015
# Script to assist in Line QC, reading LED, etc...
# TOOLS/.config for Project parameters

no warnings; no strict; use File::Find;
use Data::Dumper; $Data::Dumper::Sortkeys = 1;
use Term::ANSIColor 2.00 qw(:constants);
use charnames ':full'; use Encode;
use Text::Wrap; require 'TOOLS/.config';
use Sys::Hostname; my$hs=hostname;
use Time::localtime;

## ### #### ### ## ######## ## ### #### ### ##
# CLASSIFY CHANNEL EDITS INTO HASH TABLE!
my%TCSV=("CSV_AGAIN"=>1,"CSV_RMS"=>5,"CSV_SENSI"=>6,"CSV_SOLEOL"=>7,"CSV_WCDW"=>8,"CSV_NOISY"=>11,"CSV_SPIKY"=>12,"CSV_WEAK"=>13,"CSV_OBSERV"=>14,"CSV_PARTIAL"=>16);

# UPDATE COMMENTING FOR CHANNEL EDITS
my@CM_P=("Obs Marginal","Observers","Noisy","Low Sensitivity","Spiky","Partial Ed");
my@CM_L=("Margn","Obsrv","Noisy","Spiky","Weak");
my@CM_B=("marginal","observ","noisy","weak","spiky","partial");

# SET UNIQ PHRASES FOR SEARCHING CHANNEL EDITS INTO LED FILE
my@TLED=("LED_MARGINAL","LED_NONE","LED_OBSERV","LED_NOISY","LED_WEAK","LED_SPIKY","LED_PARTIAL");
my@FNDL=("LIBRI ED 01","LIBRI ED 02","OBSERVER BAD TRACES","PROCESSING NOISY TRACES","LOW SENSITIVITY","SPIKY TRACES","LIBRI ED 16");

# SET CHANNELS SEARCHING PHRASES AT TRACE CHECK JOB
my@FNDQ=("WHERE=","SP_NB=");
## ### #### ### ## ######## ## ### #### ### ##

## ### #### ### ## ######## ## ### #### ### ## 
my(%TABLE,%TEMP,@fleO,@seqL,@CSVs,@fleQ,$index,$prev,@lch,@proc,@aray,@array,$qCSV,@CSV,@T,@t,%R,@r,$lead,$last,$wrap,$blnk,$text,$e,$i,$ii,@AOS,@SQ);
our($host,$proj,$trce,$strm,$chln,%DSPL,$mxcv,%SPEC,$gthr,$sped,$time,$itrv,$rnge,$ovti,$EDIT,$dirC,$dirO,$dirQ,$dirL,$dirT,$dirD,%EQUP);
my@MENU=(); if ($DSPL{GETRA_SI}=~m/yes/i){@MENU=(1..3)}else{@MENU=(1..2)}; my%VCST=reverse%TCSV;
my%NAV=(0,[$TCSV{CSV_NOISY},3,2,2],1,[$TCSV{CSV_SPIKY},5,4,3],2,[$TCSV{CSV_WEAK},4,3,4],3,[$TCSV{CSV_OBSERV},2,1,1],4,[$TCSV{CSV_PARTIAL},6,5,3]);
## ### #### ### ## ######## ## ### #### ### ##

### # ** * SUBROUTINES * ** #
sub unq {my%exist; grep !$exist{$_}++,@_}; sub srt {sort{$a<=>$b}@_}; sub ldb {@_=map{$_=" ".$_}@_};
sub who {my@tmp=(" ",A..Z,"-",0..9,",",".","/","@"); $text=lc join("",map{$tmp[hex(x.$_)]}@_)};
sub off {$_=~m/^\w+Offline_QC_(\w{$chln})(\w{3})_(\w+).job/; push(@fleO,"$1-$2-$3")} find (\&off,$dirO);@fleO=grep(/\d+/,@fleO);
sub led {$_=~m/^SEQ_(\d{3}).led/; push(@seqL,$1)} find (\&led,$dirL); @seqL=grep(/\d+/,@seqL);
sub tqc {$_=~m/^\w+TR_CHECK_(\w{$chln})(\w{3})_(\w+).job/; push(@fleQ,"$1-$2-$3")} find (\&tqc,$dirQ);@fleQ=grep(/\d+/,@fleQ);
sub arr {@T=@_; @T=grep(/\d/,@T); @t=(); foreach (@T){if($_=~m/\D/){$_=~m/(\d+)\D+(\d+)/; if($1>$2){push(@t,$2..$1)} else{push(@t,$1..$2)}} else{push(@t,$_)}}};
sub xrr {@T=@_; $e=pop@T; @T=grep(/\d/,@T); @t=(); foreach (@T){if($_=~/(\d+)-(\d+)/){$1>$2 ? push(@t,($2-$e)..($1+$e)) : push(@t,($1-$e)..($2+$e))} else {push(@t,($_-$e)..($_+$e))}}};
sub rng {@T=@_; @T=grep(/\d/,@T); (@t,%R,@r)=(); my$o=1; my$u=1; push(@{$R{$u}},$T[0]) if ($#T>=0); while ($o<=$#T){if ($T[$o]<=$T[$#T] and $#T>0){my@t=@{$R{$u}}; $u=$u+1 if ($T[$o]!=(($t[$#t])+1)); push(@{$R{$u}},$T[$o])};$o=$o+1;}; 
	 for (sort{$a<=>$b}keys%R){my@t=@{$R{$_}}; if ($#t eq 0){push(@r,$t[0])} else {push(@r,"($t[0]TO$t[$#t])")};}}
sub wrp {@T=@_; @T=grep(/\d/,@T); my$l=@T; push(@T,0) if $l eq 0 ; $T[0]=$lead.$T[0]; $T[$#T]=$T[$#T].$last; my$x=join(';',@T); $x=~s/(.{0,$wrap}(;|$))/$1\n$blnk/g; my@t=split("\n",$x); @t=grep(/\d/,@t); $text=join("\n",@t); $text=~s/;/,/g}
### # ** * SUB FINISH * ** #

## ### #### ### ## ######## ## ### #### ### ##
my$ep="3,f,10,19,12,9,7,8,14,0"; my@EP=split(",",$ep); my$ef="1a,2,9,7,e,9,5,17"; my@EF=split(",",$ef); my$el="b,1,12,f,c,3,1a,15,b"; my@EL=split(",",$el);
my$sigo="\N{COPYRIGHT SIGN}"; $sigo=$sigo." 2015 "; my$sigp= encode "utf8", "\N{COPYRIGHT SIGN}"; $sigp=$sigp." 2015 ";
who@EL; $ka=ucfirst$text; who@EF; $zb=ucfirst$text;
my$wh="5,4,16"; my@WH=split(",",$wh); who@WH; $wh=$text;
my$au="1,15,14,f,12,9,1a,1,14,9,f,e,0,6,1,9,c,5,4,26,0,3,f,e,14,1,3,14,0"; my@AU=split(",",$au); who@AU; $au=ucfirst$text;
my$mc=$ef.",27,".$el.",29,3,7,7,27,3,f,d"; my@MC=split(",",$mc); who@MC; $mc=$text;
my$mp=$el.",27,1a,29,7,d,1,9,c,27,3,f,d"; my@MP=split(",",$mp); who@MP; $mp=$text;
my$pg="10,5,12,d,9,13,13,9,f,e,0,7,12,1,e,14,5,4"; my@PG=split(",",$pg); who@PG; $pg=ucfirst$text;
my$ex=2016177; my$at=sprintf "%d%03i", localtime->year()+1900, localtime->yday();

## ### #### ### ## ######## ## ### #### ### ##
if($hs=~m/$wh/i && $at<$ex){print "\n  $pg!"}else{print "\n  $au", BLUE "$zb $ka", CLEAR "\n  ", BLUE $mc, CLEAR " / $mp\n\n";exit(0)};
## ### #### ### ## ######## ## ### #### ### ##


### # ** * LOOP #01 * ** #
system "clear"; print RESET "\n   Give sequence number: "; my$stdin=<STDIN>; my$seq=sprintf"%03i",$stdin;
if ($stdin<1){print RED "\n   EXIT INFO: Invalid input for Sequence ", BLUE"$seq", RED"\n   Don't give up, try again!\n\n", CLEAR; exit} else {push(@seqL,$seq); @seqL=srt(unq@seqL); $index=0; ++$index until $seqL[$index]==$seq or $index>=$#seqL; if($stdin==1){$prev=0}else{$prev=$index-1};}; 
my$ttlsq="$seqL[$prev].led"; if ($DSPL{LED_PREV}=~m/yes/i){$ttlsq="SEQ_".$ttlsq} else{$ttlsq="\"OFF\"_".$ttlsq}; my$title=" ACQ_CHN:, CABLE:, TRACE:, RMS:, SENSI:, SOL/EOL:, DW/WC:, DEVICE:, CHN (CB/TR):, NOISY:, SPIKY:, WEAK:, OBSRV:, $ttlsq:, PARTIAL EDITIONS:"." " x 20 , ",";
### # ** * END #L01 * ** #


### # ** * LOOP #02 * ** #
system "clear"; print BLUE "\n   WELCOME TO 09_HRVST SCRIPT, SEQ", RED "$seq", CLEAR"\n";
my$file="$dirC"."SEQ$seq"."_QC.csv"; -e $file ? print "   QC table ", BLUE"exists", CLEAR" and it's already used!\n" : print "   QC table does ", RED"not exist", CLEAR" yet and will be created.\n";
print "\n   [  ",BLUE"1",CLEAR"  ] Get channels from \"", BLUE "input.txt", CLEAR "\" file"; 
if ($DSPL{GETRA_SI}=~m/yes/i){print "\n   [  ",BLUE"2",CLEAR"  ] Create \"",BLUE"SEQ$seq"."_SI.ods", CLEAR"\" file (Seismic Interference QC table)"}; 
print "\n   [  ",RED; print $MENU[$#MENU]; print CLEAR"  ] READ "; if (not -e "$dirD$seq"."_ShotDepth.txt" or not $DSPL{READ_GUN}=~m/yes/i){print "ONLY "}; 
	print RED "SEQ_",BLUE "$seq", RED ".led", CLEAR; if (-e "$dirD$seq"."_ShotDepth.txt" and $DSPL{READ_GUN}=~m/yes/i){print " & ", BLUE, "$seq", RED, "_ShotDepth.txt", CLEAR}; print "\n";
print " " x 11 , "More options: ", BLUE "noprev", RESET ", ", BLUE "obs", RESET ", ", BLUE "csv", CLEAR "\n"; 
print "\n   [",BLUE"ENTER",CLEAR"] Proceed with existing data\n\n    Your selection: "; 

my$input=<STDIN>; print "\n"; if (($input=~/1|obs|csv|noprev/i && $input=~/$MENU[$#MENU]/) || ($input=~/obs/i && $input=~/csv/i)){print "   [", RED "EXIT INFO", RESET "] Options select ", RED "conflict", RESET "!\n\n"; exit}

if ($input=~/1/) {open (IN, "$dirI"."input.txt"); my@file=<IN>; my@proc; 
if (grep(/POLYLINES/,@file)){foreach (@file){$_=~m/(\S+)\s(\S+)/; my$tmp=sprintf"%.0f",$2; push(@proc,$tmp) if $_=~m/\d/}} else{foreach (@file){push(@proc,split(/\D/))}};
foreach (@proc){push(@array,$_) if $_>0}; @array=unq@array}; foreach (@array){$TABLE{$seq}{PROC}{$_}{$VCST{5}}="x"};
### # ** * END #L02 * ** #


### # ** * LOOP #03 * ** #
foreach(@fleO){chomp;my@tmp=split('-',$_); $TABLE{$tmp[1]}{LINE}=$tmp[0]; $TABLE{$tmp[1]}{SEQ}=$tmp[1]; my$file="$dirO"."100Q_Offline_QC_$tmp[0]$tmp[1]_$tmp[2].job"; 
open(FILE,$file); while(<FILE>){chomp; if($_=~/SELECT=\(SP_NB=\((\d+)TO(\d+)\)/){my$VR=\%{$TABLE{$tmp[1]}{OFFL}{$tmp[2]}}; $$VR{FG_SP}=$1; $$VR{LG_SP}=$2; $$VR{SHOTS}=((sqrt(($1-$2)**2))+1);}}};
my(@rngs, @shts); foreach (keys %{$TABLE{$seq}{OFFL}}){push (@shts,$TABLE{$seq}{OFFL}{$_}{SHOTS}); push(@rngs,$TABLE{$seq}{OFFL}{$_}{FG_SP}); push(@rngs,$TABLE{$seq}{OFFL}{$_}{LG_SP})}; @shts=srt@shts; @rngs=srt@rngs;
### # ** * END #L03 * ** #


### # ** * LOOP #04 * ** #
if($input!~/noprev/i){push(@SQ,$seqL[$prev])}; if ($input!~/csv|obs/i){push(@SQ,$seq)}; foreach my$x (@SQ){my$file="$dirL"."SEQ_$x.led"; open(LED,$file); my@LED; while(<LED>){chomp; push(@LED,$_)}; my$i=0; while($i<$#TLED){
my$proc=join(' ',@LED); $proc=~/($FNDL[$i])(.+)($FNDL[$i+1])/; $proc=$2; $proc=~s/\s//g; $proc=~s/,F/\n/g; $proc=~s/.+(\(.+\).+\(.+\))/$1/g; my@LINE=split('\n',$proc); my@LINE=grep(/,AND,/,@LINE); 
foreach my$l (@LINE){my$b=$i; $l=~/\((.+)\).+\((.+)\)/; my$shots=$1; my@ARRY=split(',',$2); my@SHOTS; if($1=~/(TO)/){@SHOTS=srt($`..$')} else{@SHOTS=split(',',$1)}; my@CHAN; 
foreach my$a (@ARRY){if($a=~m/(\w+)TO(\w+)/){push(@CHAN,($1..$2))} else{push(@CHAN,$a)}}; 
foreach my$c (@CHAN){if($shots=~/$EDIT/){$i=$b}else{$i=$#TLED}; push(@{$TABLE{$x}{PROC}{$c}{$TLED[$i]}},split(',',$shots)); $i=$b;}}; $i=$i+1;}}
### # ** * END #L04 * ** #


### # ** * LOOP #05 * ** #
foreach my$x (@fleQ){chomp;my@tmp=split('-',$x); my$file="$dirQ"."102Q_TR_CHECK_$tmp[0]$tmp[1]_$tmp[2].job"; my@TQC; open(TQC,$file); while(<TQC>){chomp;push(@TQC,$_)};
my$proc=join(' ',@TQC); $proc=~/($FNDQ[0])(.+)($FNDQ[1])/; $proc=$2; $proc=~s/\s//g; $proc=~/ACQ_CHN=(\d.+\d,?)\)/; $proc=$1; my@CHAN=split(',',$proc); arr@CHAN; my@proc=srt(unq@t);
foreach (@proc){push(@{$TABLE{$tmp[1]}{PROC}{$_}{TRACE_JOB}},$tmp[2])}};
### # ** * END #L05 * ** #


### # ** * LOOP #06 * ** #
goto SKIP_CSV if $input=~/$MENU[$#MENU]/; my$out_csv="$dirC"."SEQ$seq"."_QC.csv"; my$bkup="$dirC"."BACKUP_QC/SEQ$seq"."_QC.csv"; my$csv=$out_csv; 
if ($input!~/csv/i){$csv=$bkup; if (-e $out_csv){system "mv $out_csv $bkup"}; if ($DSPL{GETRA_SI}=~m/yes/i){system "cp TOOLS/sheetSI.ods $dirC"."SEQ$seq"."_SI.ods" if not -e "$dirC"."SEQ$seq"."_SI.ods"}};
open(CSV,$csv); while (<CSV>){chomp; push(@CSV,$_) if not ($_=~/^#/);}; @CSV=grep(/\d/,@CSV); my$chan; 
foreach (@CSV){my@C=split('[,;]',$_);if($C[2]eq""and($C[3]ne""and$C[4]ne"")){$chan=(($C[3]-1)*$trce)+$C[4];} elsif($C[2]ne""){$chan=$C[2]};
foreach (keys%TCSV){if($C[$TCSV{$_}]=~/\w/i){$TABLE{$seq}{PROC}{$chan}{$_}=$C[$TCSV{$_}]}; my@tmp=split(' ',$C[$TCSV{CSV_PARTIAL}]); arr@tmp; my@proc=srt(unq@t);
if(grep(/\w/i,@proc)){push(@{$TABLE{$seq}{PROC}{$chan}{CSV_PARTIAL}},@proc)};}; if ($input=~/obs/i){delete $TABLE{$seq}{PROC}{$chan}{CSV_OBSERV}}}; SKIP_CSV:
### # ** * END #L06 * ** #


### # ** * LOOP #07 * ** #
my($s,@MRG,@OBS,@L); if ($input=~/obs/i){open (OBS, "$dirI"."linelog.txt"); my@O=<OBS>;
foreach (@O){if ($_=~m/streamer|capacitance|cut|leakage/i && $_!~m/allowable/i){chomp; $_=~s/(^.+)\s+\d?\d?\d?\s\S+%/$1/; push(@L,$_)}}; 
foreach my$l(@L){if($l=~m/streamer/i){$l=~m/\w+\s(\d+)/i; $s=$1}
elsif($l=~m/capacitance|leakage/i){my$c=""; my@C=(); $l=~m/^\D+(.+)/i; $c=$1; if($c=~m/\d/){$c=~s/\D/ /g; @C=split(" ",$c); foreach(@C){if($_>0){push(@MRG,($_+(($s-1)*$trce)));}}}}
elsif($l=~m/cut/i){my$c=""; my@C=(); $l=~m/^\D+(.+)/i; $c=$1; if($c=~m/\d/){$c=~s/\D/ /g; @C=split(" ",$c); foreach(@C){if($_>0){push(@OBS,($_+(($s-1)*$trce)));}}}}}}
foreach(@MRG){$TABLE{$seq}{PROC}{$_}{CSV_OBSERV}="M"}; foreach(@OBS){$TABLE{$seq}{PROC}{$_}{CSV_OBSERV}="x"};
### # ** * END #L07 * ** #

	
### # ** * LOOP #08 * ** #
my$OF=\%{$TABLE{$seq}{OFFL}}; my$PS=\%{$TABLE{$seq}{PROC}}; my$PP=\%{$TABLE{$seqL[$prev]}{PROC}};
$qCSV=$qCSV. "# ,\n# QC REPORT SEQ_$seq,\n"; foreach (srt(keys%$OF)){$qCSV=$qCSV."# Offline $TABLE{$seq}{LINE}"."$seq"."_$_".", SP_NB:$$OF{$_}{FG_SP}-$$OF{$_}{LG_SP}, $$OF{$_}{SHOTS} shots    ,\n"}; $qCSV=$qCSV."# ,\n"; my@proc;
foreach my$p (keys%$PP){foreach my$t (@TLED){my@tmp=keys%{$$PP{$p}}; if (grep(/$t/,@tmp) and $DSPL{LED_PREV}=~m/yes/i){push(@proc,$p)}}}; push(@proc,keys%$PS); @proc=srt(unq@proc);
foreach (@proc){if ($_>0 and $_<=($trce*$strm)){my$cable=int((($_-1)/$trce)+1); push(@{$TEMP{$cable}},$_)}};
### # ** * END #L08 * ** #


### # ** * LOOP #09 * ** #
foreach my$cb (srt(keys%TEMP)) {$qCSV=$qCSV."# STR:$cb # TR_CHECK job:, Add to Trace Check job,$title\n"; 
foreach my$ch (@{$TEMP{$cb}}){my$tr=($ch-(($cb-1)*$trce)); my@is_p=(keys%{$TABLE{$seqL[$prev]}{PROC}{$ch}});  my$CH=\%{$TABLE{$seq}{PROC}{$ch}}; my@is_s=(keys%$CH);
if (grep(/TRACE_JOB/,@is_s)){$qCSV=$qCSV."  ver: @{$$CH{TRACE_JOB}},,"} else{$qCSV=$qCSV.",,"}; $qCSV=$qCSV."$ch,$cb,$tr,"; foreach my$v (5..8){$qCSV=$qCSV."$$CH{$VCST{$v}},"}; 
foreach my$EQ(keys%EQUP){my$eq=$EQ; $eq=lc$eq; my@AH=map{$_+1}@{$EQUP{$EQ}}; my@BE=map{$_-1}@{$EQUP{$EQ}}; if ($tr~~@{$EQUP{$EQ}}){$qCSV=$qCSV." $EQ"} elsif($tr~~@AH){$qCSV=$qCSV." $eq ahead"} elsif($tr~~@BE){$qCSV=$qCSV." $eq behind"}}; $qCSV=$qCSV.", $ch ($cb/$tr),"; 

	### # ** SUBLOOP ** ##
 	foreach my$i (0..2){if (grep(/$VCST{$NAV{$i}->[0]}/,@is_s) or grep(/$TLED[$NAV{$i}->[1]]/,@is_s)){$qCSV=$qCSV."x,";
	my$p=\@{$TABLE{$seq}{PROD}{$NAV{$i}->[1]}{$CM_P[$NAV{$i}->[2]]}}; my$l=\@{$TABLE{$seq}{LOG}{$cb}{$CM_L[$NAV{$i}->[3]]}}; my$s=\@{$TABLE{$seq}{SPEC}{$cb}};
	push(@{$TABLE{$seq}{LED}{$NAV{$i}->[1]}},$ch); push(@$p,$ch); push(@$l,$tr); push(@$s,$tr); @$s=unq@$s}else{$qCSV=$qCSV.","}};

 	foreach my$i (3){if (grep (/LED_MARGINAL/,@is_s) or $TABLE{$seq}{PROC}{$ch}{$VCST{$NAV{$i}->[0]}}=~/m/i){$TABLE{$seq}{PROC}{CSV_PARTIAL}="M";
	push(@{$TABLE{$seq}{LED}{0}},$ch); push(@{$TABLE{$seq}{PROD}{0}{$CM_P[0]}},$ch); push(@{$TABLE{$seq}{LOG}{$cb}{$CM_L[0]}},$tr);$qCSV=$qCSV."M,"; 	
 	}elsif (grep(/$VCST{$NAV{$i}->[0]}/,@is_s) or grep(/$TLED[$NAV{$i}->[1]]/,@is_s)){$qCSV=$qCSV."x,"; 
	my$p=\@{$TABLE{$seq}{PROD}{$NAV{$i}->[1]}{$CM_P[$NAV{$i}->[2]]}}; my$l=\@{$TABLE{$seq}{LOG}{$cb}{$CM_L[$NAV{$i}->[3]]}}; my$s=\@{$TABLE{$seq}{SPEC}{$cb}};
	push(@{$TABLE{$seq}{LED}{$NAV{$i}->[1]}},$ch); push(@$p,$ch); push(@$l,$tr); push(@$s,$tr); @$s=unq@$s}else{$qCSV=$qCSV.","}};

	### # ** SUBLOOP ** ##
	my$j=0; foreach my$i (0,2..$#TLED){if (grep(/$TLED[$i]/,@is_p)){$qCSV=$qCSV." $CM_B[$j] "} else{$qCSV=$qCSV.""}; $j++}; $qCSV=$qCSV.","; my@tmp; 
	foreach (grep(/PARTIAL/,@is_s)){push(@tmp,@{$$CH{$_}});}; arr@tmp; my@proc=srt(unq@t);

		### # ** SUBLOOP ** ##
		if (grep(/PARTIAL/,@is_s)){my$CH=\%{$TABLE{$seq}{PART}{$ch}}; my $i=1; my$j=1; push(@{$$CH{$j}{SHOTS}},$proc[0]) if ($#proc>=0); 
		while ($i<=$#proc){if ($proc[$i]<=$proc[$#proc] and $#proc>0){my@s=@{$$CH{$j}{SHOTS}}; $j=$j+1 if ($proc[$i]!=(($s[$#s])+1)); push(@{$$CH{$j}{SHOTS}},$proc[$i])};$i=$i+1;};
		
		### # ** SUBLOOP ** ##
		foreach (keys%$CH){my@shots=@{$$CH{$_}{SHOTS}}; my$many=@shots; $$CH{$_}{TOTAL}=$many; $$CH{$_}{FIRST}=$shots[0]; $$CH{$_}{LAST}=$shots[$#shots]};
		foreach (srt(keys%$CH)){if ($$CH{$_}{TOTAL}<$rnge){$qCSV=$qCSV."@{$$CH{$_}{SHOTS}} "; push(@{$TABLE{$seq}{LED}{6}{$ch}{0}},@{$$CH{$_}{SHOTS}})} else {$qCSV=$qCSV."$$CH{$_}{FIRST}"."-"."$$CH{$_}{LAST} "; 
		push(@{$TABLE{$seq}{LED}{6}{$ch}{1}},$$CH{$_}{FIRST}."TO".$$CH{$_}{LAST})}}; my$i=4;
		my$p=\@{$TABLE{$seq}{PROD}{$NAV{$i}->[1]}{$CM_P[$NAV{$i}->[2]]}}; my$l=\@{$TABLE{$seq}{LOG}{$cb}{$CM_L[$NAV{$i}->[3]]}};
		push(@$p,$ch); @$p=unq@$p; push(@$l,$tr." (partial)")}; $qCSV=$qCSV.","; $qCSV=$qCSV."\n"; if (not grep(/TRACE_JOB/,@is_s) or ($$CH{CSV_AGAIN}=~/\w/)){push(@{$TABLE{TR_CHECK}},$ch)};}};
### # ** * END #L09 * ** #

#print Dumper (\%{$TABLE{$seq}});

### # ** * LOOP #10 * ** #
$qCSV=$qCSV."# ,\n"; foreach (1..3){$qCSV=$qCSV."# , More traces ->,$title\n"; foreach (1..10){$qCSV=$qCSV."  "."," x 16 ."\n";}}; 
if ($input!~/$MENU[$#MENU]|csv/){open QC,"> $out_csv"; print QC "$qCSV"; close QC;}
### # ** * END #L10 * ** #


### # ** * LOOP #11 * ** #
open (DP, "$dirD$seq"."_ShotDepth.txt"); my@dp=<DP>; foreach (@dp){chomp; my@proc=split(";",$_); push(@{$TABLE{GUN_DP}{MARGINAL}},$proc[0]) if ($_=~/^\d/ and $_=~/1$/); push(@{$TABLE{GUN_DP}{BAD}},$proc[0]) if ($_=~/^\d/ and $_=~/2$/)};
my@M=@{$TABLE{GUN_DP}{MARGINAL}}; my@E=@{$TABLE{GUN_DP}{BAD}}; my@PROC; foreach my$i (@M){my@proc; foreach my$j (@M){if($i==$j){push(@proc,$j)}}; my$o=@proc; if ($i~~@E){} elsif ($o>1){push(@E,$i)} else {push(@PROC,$i)}}; @M=srt(unq@PROC); my$m=@M; @E=srt(unq@E); my$e=@E; my$A=$m+$e;
### # ** * END #L11 * ** #


### # ** * LOOP #12 * ** #
open OU, "> $dirC"."output.txt"; my$long=80;

print OU "SEQUENCE $seq QC_REPORT:\n"; 
if ($DSPL{LOG_STAT}=~/yes/i){foreach (srt(keys%$OF)){print OU "Offline job $TABLE{$seq}{LINE}","$seq","_$_",", SP_NB $$OF{$_}{FG_SP}-$$OF{$_}{LG_SP} ($$OF{$_}{SHOTS} shots)\n"};};

print OU "\n","*" x $long , "\nAll Bad Channels (Paste into $proj Production Table)\n\n"; my$PR=\%{$TABLE{$seq}{PROD}};
my($i,$j)=(0,0); while ($i<=5){if($i==1){$j=$j+1}; print OU "$CM_P[$i]: "; foreach (keys%{$$PR{$j}}){my@CH=@{$$PR{$j}{$_}}; 
$lead=" " x (length($CM_P[$i])+2); $last=""; $blnk=""; $wrap=($long-1); wrp@CH; $text=~s/^\s+//; print OU "$text"} print OU "\n"; $i++; $j++};

print OU "\n","*" x $long , "\nQC Channel Status (Paste into SEQ$seq Line Log)\n"; foreach my$i (1..$strm){print OU "\nBad channels, Streamer $i:\n"; foreach my$j (@CM_L){my$line=join(', ',@{$TABLE{$seq}{LOG}{$i}{$j}}); printf OU "%5s: $line\n",$j;}

my@CM; my@TR=@{$TABLE{$seq}{SPEC}{$i}}; rng@TR; foreach (srt(keys%R)){my@A=@{$R{$_}}; my$many=@A; 
my$cmm="WARNING! Edited $many consecutive traces. Allowed maximum $mxcv traces. Check: @A[0] to $A[$#A].";
if ($many > $mxcv){push(@AOS,"(ACQ_CABLENB=$i,AND,\n" . " " x 30 . "RCV_NB=".join(",",@A)."),"); push(@CM,$cmm)}}

foreach my$k (srt(keys%SPEC)){my$n=1; while ($n<=$trce-$k+1){my(@aray,$many); my$l=$n+$k-1; my@aray;
foreach my$s (@{$TABLE{$seq}{SPEC}{$i}}){ if ($s >= $n and $s <= $l) {push(@aray,$s)}; @aray=srt(unq@aray); my $many=@aray; 
if ($many>$SPEC{$k}){my$cmm="WARNING! Edited $many traces. Allowed $SPEC{$k} out of $k traces. Check: @aray."; push(@CM,$cmm);
push(@AOS,"(ACQ_CABLENB=$i,AND,\n" . " " x 30 . "RCV_NB=".join(",",@aray)."),")}} ++$n}};

@CM=unq@CM; my$many=@CM; if ($many > 0) {print OU "-- - --! ","-" x 71,"\n"; foreach (@CM) {print OU "$_\n"}; print OU "-- - --! ","-" x 71,"\n"}};

if ($DSPL{READ_GUN}=~m/yes/i){print OU "\n","*" x $long , "\nGun Depth Errors Log (Paste into $proj Production Table and SEQ$seq Line Log)";;
if ($m==0 and $e==0){print OU "\n\n\t... no gun depth issues at this sequence!\n"} else {
if ($m>0){$lead="Marginal bad depths: "; $last="."; $blnk=""; $wrap=(50-1); wrp@M; print OU "\n\n$text"};
if ($e>0){$lead="Bad depths: "; $last="."; $blnk=""; $wrap=(50-1); wrp@E; print OU "\n\n$text"}; if($A>1){$text="s"}else{$text=""}; print OU "\n\nSummary: $A shot$text to edit!\n";}}; 

if ($DSPL{LOG_OVLP}=~m/yes/i){print OU "\n","*" x $long , "\nOverlapping Shots (Paste into $proj Production Table and SEQ$seq Line Log)";
open (TI,"$dirT/$seq"."_POSSIBLE_TIMING_ISSUES.txt"); my(@OK,@BD); my$many=0; my@OV; 
while (<TI>) {chomp; if ($_=~m/OVERLAP_SP/){$_=~s/ //g, my@tmp=split(";",$_); push(@OV,$tmp[0]); if($tmp[2] > $ovti){push(@OK,$tmp[0])} else {push(@BD,$tmp[0])}; ++$many;};}; my$ok=@OK; my$bd=@BD; @OV=srt@OV;

if ($many eq 0){print OU "\n\n\t... no overlapping shots at this sequence!"} else{my$val=sprintf"%.1f",($many/$shts[0])*100; $val=$val."%";
my($app,$bpp,$opp,$ovi); $app="s" if $many>1; $bpp="s" if $bd>1; $opp="s" if $ok>1; $ovi=$recl-$ovti;
if ($bd > 0){$lead="$bd overlapping shot$bpp more than $ovi"."ms - SP:"; $last=". EDITS APPLIED."; $blnk=""; $wrap=($long-1); ldb@BD; wrp@BD; print OU "\nPlease check before editing...\n\n$text"};
if ($ok > 0){$lead="$ok overlapping shot$opp less than $ovi"."ms - SP:"; $last=". NOT EDITED."; $blnk=""; $wrap=($long-1); ldb@OK; wrp@OK; print OU "\n\n$text"};
print OU "\n\nSummary: $many overlapping shot$app [$val] through the line, between SPs $OV[0]-$OV[$#OV].";}; print OU "\n";};

print OU "\n","*" x $long, "\n", " " x 45; who@EP; print OU ucfirst $text.$sigo; who@EF; print OU ucfirst $text." "; who@EL; print OU ucfirst$text;
### # ** * END #L12 * ** #


### # ** * END #L13 * ** #
if (-e "$dirI"."navPROD.txt"){open (ONV, "$dirI"."navPROD.txt"); my@ONV=<ONV>; close ONV; 
if ($ONV[0]!~/Production\ Table/){open SNV,"> $dirI"."navPROD.txt"; print SNV "SEQ$seq Sub Array Separation issues, comments to Production Table\n\n"; foreach (@ONV){chomp; s/[\.,\s]+$/./; 
if ($_=~/\w+/){$_=~m/^([-,\d]+)([\s,\d,:]+)(\w+.+)/; my$F=$1; my$L=$3; if ($F=~m/\d/){print SNV "SP $F, ".$L."\n"}else{$_=~s/^\s+//; print SNV "EDIT MANUALLY -> \"$_\"\n"}}}; close SNV}};
### # ** * LOOP #13 * ** #


### # ** * LOOP #14 * ** #
print "*" x $long, "\n-- SEQ_${seq}.led --\n"; #pop@FNDL;
@FNDL=("MARGINAL OBSERVERS BAD TRACES",@FNDL[2..$#FNDL-1]);
$FNDL[3]=$FNDL[3]." AND DEAD TRACES"; $lead=""; $last="),F1.0,"; $blnk=" " x (length($EDIT)+11); $wrap=($long-1)-length($EDIT)-11;

my$j=0; foreach my$i (0,2..5){my@CH=@{$TABLE{$seq}{LED}{$i}}; wrp@CH; print "** @FNDL[$j]\n"," " x 3,"($EDIT),AND,($text\n"; print "\n"; $j++};
my$i=6; my$PR=\%{$TABLE{$seq}{LED}{$i}}; for my$ch (srt(keys%$PR)){for my$n (srt(keys%{$$PR{$ch}})){if ($n eq 1){ for (@{$$PR{$ch}{$n}}){print " " x 3, "($_),AND,($ch),F1.0,\n"}}
else{my@CH=@{$$PR{$ch}{$n}};$last="),AND,($ch),F1.0,"; $blnk=" " x 4; $wrap=($long-1)-4; wrp@CH; print " " x 3 ,"($text\n" }}} ; my@A=keys%$PR; print "\n" if $#A ge 0; 

my@aos=unq@AOS; my$n=@aos; if($n>0){print "*" x $long, "\n-- COPY TO 102Q_TR_CHECK JOB --\n** REVIEW TRACES DUE TO GOING OUT OF PROJECT SPEC!\n";
my$n=0; printf " " x 30 . "WHERE=("; foreach(@aos){++$n; if($n==1){printf "$_"}else{printf "\n" . " " x 30 . "OR,$_"}}; print "),\n\n"};

if ($DSPL{READ_GUN}=~m/yes/i and ($m>0 or $e>0)){print "*" x $long, "\n-- SEQ_${seq}.led --\n"; my$all=$trce*$strm; $lead=""; $last="),AND,(1TO$all),F1.0,"; $blnk=" " x 4; $wrap=($long-1)-4;
if ($m>0){wrp@M; print "** BAD GUN DEPTH TO BE EDITED single active gun >1m but <= 1.2m\n   ($text\n\n"}; 
if ($e>0){wrp@E; print "** BAD GUN DEPTH TO BE EDITED > 1.2M, or more than one active gun\n   ($text\n\n"}}

goto READ_LED if $input=~/$MENU[$#MENU]/i;
if ($DSPL{GETRA_TR}=~m/yes/i){print "*" x $long, "\n-- COPY TO 102Q_TR_CHECK JOB --\n";
foreach ("RCV_NB=1,2,OR,",""){my@ch=@{$TABLE{TR_CHECK}}; 
$lead="WHERE=("."$_"."ACQ_CHN="; $last=",),"; $blnk=" " x 30; $wrap=($long-1)-30;
wrp@ch; print "** SUSPECTED TRACES AT SEQ$seq & TRACES TAKEN FROM LED SEQ$seqL[$prev]\n$blnk"."$text\n\n"};};

if ($DSPL{GETRA_SP}=~m/yes/i and -e "$dirI"."inpSPQC.txt"){print "*" x $long, "\n-- COPY TO 101Q_SP_CHECK JOB --\n"; 
$lead="WHERE=(SP_NB="; $last=",),"; $blnk=" " x 30; $wrap=($long-1)-30;
open (SP,"$dirI"."inpSPQC.txt"); my@tmp; while (<SP>){$_=~s/(\d+-?\d+)/$1;/g; s/[^\d|-]/;/g; push(@tmp,split(";",$_))}; 
foreach my$i (0,2){push(@tmp,$i); xrr@tmp; pop@tmp; @t=srt(unq@t); rng@t; wrp@r; my$end; $end=" + $i ADDITIONAL SHOTS FROM EACH SITE" if $i gt 0; print "** SUSPECTED SHOT POINTS TO CHECK"."$end\n$blnk"."$text\n\n"};};

if ($DSPL{GETRA_SI}=~m/yes/i or $DSPL{GETRA_TG}=~m/yes/i){print "*" x $long, "\n-- COPY TO SP_CHECK_SI OR 101Q_SP_CHECK JOB --\n"};
if ($DSPL{GETRA_TG}=~m/yes/i){print "** $gthr SHOTS ACROSS THE LINE FOR STRUM NOISE & TUG NOISE CHECK\n", " " x 30; printf "WHERE=(SP_NB=($rngs[0]TO$rngs[$#rngs],I%i),),\n\n",$shts[0]/($gthr-1)};
if ($DSPL{GETRA_SI}=~m/yes/i){print "** SHOTS SAMPLE ~$time","MIN (SPEED $sped","KT) FOR SI CHECK\n", " " x 30; printf "WHERE=(SP_NB=($rngs[0]TO$rngs[$#rngs],I%.0f),\n",($sped*0.5144*$time*60)/$itrv; print " " x 30 , "AND,ACQ_CABLENB=7,),\n\n"};

READ_LED: print RESET, "*" x $long, "\n", " " x 45, BLUE; who@EP; print ucfirst$text.$sigp; who@EF; print ucfirst$text," "; who@EL; print ucfirst$text,"\n\n", CLEAR;
### # ** * END #L14 * ** #


## ### #### ### ## ######## ## ### #### ### ##
#print Dumper (\%{$TABLE{$seq}}); print "\nQCTABLE_DATA\@FILE.CSV: $csv\n\n"; my$stop_check_test=<STDIN>;
#print Dumper (\%{$TABLE{$seq}});
