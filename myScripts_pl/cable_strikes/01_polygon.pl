#! /usr/bin/perl -w

# by Zbigniew Karolczuk, updated 26 July 2015
# Script to convert channels from ... polygon to ... format
# .config for script parameters setup

no warnings; no strict;
use Data::Dumper; $Data::Dumper::Sortkeys = 1;
use Term::ANSIColor 2.00 qw(:constants);
use charnames ':full'; use Encode;
require '.config'; our $trce;

## ### #### ### ## ######## ## ### #### ### ##

system "clear"; print "\n** Give a Sequence number: ",RED; my$in = <STDIN>; print CLEAR; my$seq = sprintf "%03d", $in; 

open (FL, "FILES_CSTRK/SEQ$seq"."_khoros.asc");my%A;my$i=1;my$n=0; while (<FL>){if ($n>3){chomp;my@l=split(" ",$_);$t[0]=sprintf"%.0f",$t[0];$t[1]=sprintf"%.0f",$t[1];  
if($l[0]==0 and $l[1]==0){$i+=1}else{push(@{$A{$i}{S}},$l[0]);push(@{$A{$i}{H}},$l[1])}};++$n};close(FL);

## ### #### ### ## ######## ## ### #### ### ##  

sub unq {my%exist;grep!$exist{$_}++,@_}; sub srt {sort{$a<=>$b}@_}; sub end {my@tmp=(" ",A..Z); $text=ucfirst lc join("",map{$tmp[hex(x.$_)]}@_)};
my$ep="3,f,10,19,12,9,7,8,14,0"; my@EP=split(",",$ep); my$ef="1a,2,9,7,e,9,5,17,0"; my@EF=split(",",$ef); my$el="b,1,12,f,c,3,1a,15,b"; my@EL=split(",",$el); 
my$sigp= encode "utf8", "\N{COPYRIGHT SIGN}"; $sigp=$sigp." 2015 ";

## ### #### ### ## ######## ## ### #### ### ##  

BEGN: %C=();%B=();%D=();@x=(); @C=();
foreach (srt(keys%A)){my@S=srt@{$A{$_}{S}}; my@H=srt@{$A{$_}{H}};if (grep(/\d/,@S) and grep(/\d/,@H)){
push(@{$B{$_}{S}},$S[0]..$S[$#S]);push(@{$B{$_}{s}},$S[0]-1..$S[$#S]+1);push(@{$B{$_}{H}},$H[0]..$H[$#H]);push(@{$B{$_}{h}},$H[0]-1..$H[$#H]+1)}}

foreach my$b (srt(keys%B)){my@S=@{$B{$b}{S}};push(@{$C{$b}{S}},@S);my@H=@{$B{$b}{H}};push(@{$C{$b}{H}},@H);delete($B{$b});
foreach my$d (srt(keys%B)){my@s=@{$B{$d}{S}};my@h=@{$B{$d}{H}};my@e=@{$B{$d}{s}};my@i=@{$B{$d}{h}};
if (grep{$_~~@S}@e and grep{$_~~@H}@i){push(@{$C{$b}{S}},@s);push(@{$C{$b}{H}},@h);delete($B{$d});}};++$b}

foreach (keys%C){@{$C{$_}{S}}=srt@{$C{$_}{S}};@{$C{$_}{H}}=srt@{$C{$_}{H}};my$a=@{$C{$_}{S}};my$b=@{$C{$_}{H}};push(@x,($a,$b))};
foreach (keys%C){my@S=@{$C{$_}{S}};my@H=@{$C{$_}{H}}; if (grep(/\d/,@S) and grep(/\d/,@H)){push(@{$D{$_}{S}},@S);push(@{$D{$_}{H}},@H)}};%A=%D;goto BEGN if grep{$_==0}@x;
foreach (keys%D){my$c=sprintf"%i",((($D{$_}{H}->[0])-1)/$trce)+1;push(@{$E{$c}{$_}{S}},@{$D{$_}{S}});push(@{$E{$c}{$_}{H}},@{$D{$_}{H}});push(@C,$c)}; my@C=srt(unq@C);

## ### #### ### ## ######## ## ### #### ### ##  

if (scalar@C eq 0){print RED "\n   POLYGON FILE DOES NOT EXIST OR MIGHT BE EMPTY!\n\n", CLEAR; exit}
print "\n-- ", BLUE"COPY TO ... ... JOB", CLEAR" --\n** TRACE SELECTION FOR STREAMERS: @C";
my$i=0; foreach my$c (@C){my$j=0; foreach (srt(keys%{$E{$c}})){print "\n", " " x 30; if ($i==0 and $j==0){print"WHERE=("}else{print"OR,"}; 
print "(SP_NB=($E{$c}{$_}{S}->[0]","TO$E{$c}{$_}{S}->[$#S]),\n"," " x 30, "AND,ACQ_CHN=($E{$c}{$_}{H}->[0]","TO$E{$c}{$_}{H}->[$#H]),AND,ACQ_CABLENB=$c,),";++$j};
print "\n**", " " x 28, "--- -- - -- --- -- - -- ---" if $i<$#C;++$i};print "),\n\n";
print RESET, "** ","*" x 77, "\n**", " " x 43, BLUE; end@EP; print$text.$sigp; end@EF; print$text; end@EL; print$text,"\n\n", CLEAR;

## ### #### ### ## ######## ## ### #### ### ##

my$dir="FILES_CSTRK"; my$fle=sprintf"SEQ%03i"."_expose",$in; opendir DIR, $dir; my@files= readdir (DIR); closedir DIR; @files=grep(/$fle.\d{2}.csv/,@files); my@go;  my@al;
foreach my$fl (@files){open FL, "$dir/$fl"; $fl=~m/\w+.(\d{2}).csv/; my$no=$1; my@data=(<FL>); push(@al,$no); if (grep(/\d/,@data)){push(@go,$no)}}; my$new=sprintf"$fle.%02i.csv",$go[$#go]+1;
my@del; foreach my$a (@al){push(@del,$a) if not ($a~~@go)}; foreach my$d (@del) {unlink "$dir/$fle.$d.csv"}; open NW , "> $dir/$new"; print NW "SP_NB,ACQ_CHN,\n"; close NW;

## ### #### ### ## ######## ## ### #### ### ##
#print Dumper (\%E)
