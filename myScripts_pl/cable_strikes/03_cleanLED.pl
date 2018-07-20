#! /usr/bin/perl -w

# by Zbigniew Karolczuk, updated 26 July 2015
# Script for cleaning LED - search, rearrange, sort, remove duplicates, apply processing conditions 
# .config for script parameters setup

no warnings; no strict;
use Data::Dumper; $Data::Dumper::Sortkeys = 1;
use Term::ANSIColor 2.00 qw(:constants);
use charnames ':full'; use Encode;
require '.config'; our ($trce,$led,$begn,$fnsh,$rngc,$okld,$badc);
use Text::Wrap;

## ### #### ### ## ######## ## ### #### ### ##
my(@LED,@T,@t,%R,%V,@C_AR,@r,@s,$lead,$last,$blnk,$wrap,$text); my($c_tr,$c_sp,$c_al)=(0,0,0);
## ### #### ### ## ######## ## ### #### ### ##

system "clear"; print "\n** Give a Sequence number: ",RED; my$in = <STDIN>; print CLEAR; my$seq = sprintf "%03d", $in;
$led=~s/XXX/$seq/; open (LED, "$led") or die "\n   Sorry, I can't find LED file...\n   Try again!\n\n";

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

while(<LED>){chomp;push(@LED,$_)}; my $M=join(' ',@LED); $M=~/($begn)(.+)($fnsh)/; $M=$2; $M=~s/\s//g; $M=~s/(F\d\.\d+),?/$1,\n/g;
foreach my $ln (split('\n',$M)){$ln=~/\((.+)\).+\((.+)\)/; my@CH=split(',',$2); my@SP; if($1=~/(TO)/){@SP=($`..$')}else {@SP=split(',',$1)}; 
foreach my $sp (grep{$_>0}@SP){my@AR; foreach my$chn (@CH){if($chn=~m/(\w+)TO(\w+)/){push(@AR,($1..$2))}else{push(@AR,$chn)}} 
foreach my $ar (@AR){my$cb=int((($ar-1)/$trce)+1); push(@{$STRK{$cb}{$sp}},$ar);}}};

## ### #### ### ## ######## ## ### #### ### ##

print "\n"; foreach my$cb (srt(keys%STRK)){print "** HIT NOISE STREAMER $cb\n"; foreach my$sp (srt(keys%{$STRK{$cb}})){my@ch=@{$STRK{$cb}{$sp}}; @ch=unq(srt@ch); push(@ch,$cb); rng@ch; 
my$long=80; $lead=""; $last="),F1.0,"; $blnk=" " x (11+length($sp)); $wrap=($long-1)-length($sp)-11; 
if($#s ge 0){wrp@s; print "   ($sp),AND,($text\n"}; foreach (@r){print "   ($sp),AND,($_),F1.0,\n"; }};print"\n";};

my$long=67+length($c_al)+length($c_sp)+length($c_tr);
print "** Summary: Picked ",RED"$c_al",CLEAR" locations (",RED"$c_sp SP",CLEAR" on single cable, ",RED"$c_tr",CLEAR" single traces)\n";
print "** ", "*" x ($long-3); print "\n** ", " " x ($long-3-35); end@EP; print BLUE $text.$sigp; end@EF; print $text; end@EL; print $text,"\n\n", CLEAR;

## ### #### ### ## ######## ## ### #### ### ##
#print Dumper (\%STRK)
