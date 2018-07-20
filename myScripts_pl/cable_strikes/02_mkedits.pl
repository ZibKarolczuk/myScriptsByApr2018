#! /usr/bin/perl -w

# by Zbigniew Karolczuk, updated 26 July 2015
# Script to create library from cable strikes saved in CSV format
# .config for script parameters setup

no warnings; no strict;
use Data::Dumper; $Data::Dumper::Sortkeys = 1;
use Term::ANSIColor 2.00 qw(:constants);
use charnames ':full'; use Encode;
require '.config'; our ($trce,$rngc,$okld,$badc);
use Text::Wrap;

## ### #### ### ## ######## ## ### #### ### ##
my(%LIST,%DATA,@FILES,@T,@t,%R,%V,@C_AR,@r,@s,$lead,$last,$blnk,$wrap,$text); my($c_tr,$c_sp,$c_al)=(0,0,0);
## ### #### ### ## ######## ## ### #### ### ##

system "clear"; print "\n** Give a Sequence number: ",RED; my$in = <STDIN>; print CLEAR; my$seq = sprintf "%03d", $in; opendir CS, "FILES_CSTRK/"; my@temp= grep(/$seq\_e\w+.\d{2}.\w{3}/, readdir CS); closedir CS;
my@picks; foreach my$fl (@temp){open (FL, "FILES_CSTRK/$fl"); my@cntnt; while (<FL>){chomp; push(@cntnt,$_)}; push(@picks,$fl) if grep(/\d/,@cntnt) and not grep(/POLYLINE/,@cntnt)}; my$many=@picks;

## ### #### ### ## ######## ## ### #### ### ##

sub unq {my%exist; grep !$exist{$_}++,@_}; sub srt {sort{$a<=>$b}@_}; sub end {my@tmp=(" ",A..Z); $text=ucfirst lc join("",map{$tmp[hex(x.$_)]}@_)};
my$ep="3,f,10,19,12,9,7,8,14,0"; my@EP=split(",",$ep); my$ef="1a,2,9,7,e,9,5,17,0"; my@EF=split(",",$ef); my$el="b,1,12,f,c,3,1a,15,b"; my@EL=split(",",$el); 
my$sigp= encode "utf8", "\N{COPYRIGHT SIGN}"; $sigp=$sigp." 2015 ";

sub wrp {@T=@_; @T=grep(/\d/,@T); my$l=@T; push(@T,0) if $l eq 0 ; $T[0]=$lead.$T[0]; $T[$#T]=$T[$#T].$last; my$x=join(';',@T); $x=~s/(.{0,$wrap}(;|$))/$1\n$blnk/g; 
my@t=split("\n",$x); @t=grep(/\d/,@t); $text=join("\n",@t); $text=~s/;/,/g}

sub rng {@T=@_; my$CB=pop@T; @T=grep(/\d/,@T); (%R,%V,@s,@r,@C_AR)=(); my$all=0; my$o=1; my$u=1; push(@{$R{$u}},$T[0]) if ($#T>=0); 
while ($o<=$#T){if ($T[$o]<=$T[$#T] and $#T>0){my@t=@{$R{$u}}; ++$u if($T[$o]!=(($t[$#t])+1)); push(@{$R{$u}},$T[$o])};++$o};
foreach (keys%R){my@t=@{$R{$_}}; @t=grep(/\d/,@t); @t=srt(unq@t); my$n=0+@t; $all+=$n; push(@C_AR,$n); push(@{$V{$_}{$n}},@t)};
   if (($n>$okld)or(grep{$_> $badc}@C_AR)or($all==$trce)){push(@r,((($CB-1)*$trce)+1)."TO".($CB*$trce)); ++$c_sp; $c_al+=$trce}else{
   for my$vc (srt(unq(grep{$_> $rngc}@C_AR))){for my$ck(srt(keys%V)){my@A=@{$V{$ck}{$vc}};push(@r,$A[0]."TO".$A[$#A]); $c_tr+=scalar(@A); $c_al+=scalar(@A)}};
   for my$vs (srt(unq(grep{$_<=$rngc}@C_AR))){for my$sk(srt(keys%V)){my@S=@{$V{$sk}{$vs}};push(@s,@S); $c_tr+=scalar(@S); $c_al+=scalar(@S);}};}}

## ### #### ### ## ######## ## ### #### ### ##

if ($many eq 0){print RED "\n   No Cable Strikes picked yet for sequence ", BLUE"$seq", RED"\n   Quit now!\n\n", CLEAR; exit;} 
elsif ($many eq 1){print BLUE "\n   No need to select file, cable strikes picked once!\n\n", CLEAR; push(@FILES,$picks[0]); goto PROCES;} 
else{print "\n"; my$i=0; while($i<=$many){$j=$i+1; 
if ($i<$many){printf "%2d $picks[$i]\n",$i+1; push(@{$LIST{$j}},$picks[$i])} else{print RED; printf "%2d Combine them all",$i+1; print CLEAR; push(@{$LIST{$j}},@picks)};++$i}}; print "\n\n";

my@keys=sort{$a<=>$b}keys%LIST; SELECT: print BLUE "   Select your picks from the list of CSV files: ", CLEAR; my$in=<STDIN>; my$sel=sprintf "%i", $in;
if (grep{$_ == $sel}(@keys)){foreach my$k (grep{$_==$sel}(@keys)){@FILES=@{$LIST{$k}};}}else{goto SELECT}; print "\n";

## ### #### ### ## ######## ## ### #### ### ##

PROCES: foreach my$cs (@FILES){open (AR,"FILES_CSTRK/$cs"); while (<AR>){chomp; my@tmp=split('[;,]',$_); my($sp,$ch)=($tmp[0],$tmp[1]); if($sp=~/\d/ and $ch=~/\d/){
if ($ch=~/c(\d+)/i){push(@{$DATA{$1}{$sp}},((($1-1)*$trce)+1)..($1*$trce))} 
elsif($ch=~/(\d+)\D(\d+)/){my$cb=int((($1-1)/$trce)+1); if($2 gt $1){push(@{$DATA{$cb}{$sp}},$1..$2)} else{push(@{$DATA{$cb}{$sp}},$2..$1)}} 
else {my$cb=int((($ch-1)/$trce)+1); push(@{$DATA{$cb}{$sp}},$ch)};}}}
## ### #### ### ## ######## ## ### #### ### ##

foreach my$cb (srt(keys%DATA)){print "** HIT NOISE STREAMER $cb\n"; foreach my$sp (srt(keys%{$DATA{$cb}})){my@ch=@{$DATA{$cb}{$sp}}; @ch=unq(srt@ch); push(@ch,$cb); rng@ch; 
my$long=80; $lead=""; $last="),F1.0,"; $blnk=" " x (11+length($sp)); $wrap=($long-1)-length($sp)-11; 
if($#s ge 0){wrp@s; print "   ($sp),AND,($text\n"}; foreach (@r){print "   ($sp),AND,($_),F1.0,\n"; }};print"\n";};

my$long=67+length($c_al)+length($c_sp)+length($c_tr);
print "** Summary: Picked ",RED"$c_al",CLEAR" locations (",RED"$c_sp SP",CLEAR" on single cable, ",RED"$c_tr",CLEAR" single traces)\n";
print "** ", "*" x ($long-3); print "\n** ", " " x ($long-3-35); end@EP; print BLUE $text.$sigp; end@EF; print $text; end@EL; print $text,"\n\n", CLEAR;

## ### #### ### ## ######## ## ### #### ### ##
#print Dumper (\%DATA)
