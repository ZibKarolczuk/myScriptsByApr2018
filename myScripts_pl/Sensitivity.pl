#! /usr/bin/perl -w

no warnings;
use strict;
use Data::Dumper;

my$trc=636;
my$file=$ARGV[0];
my%STR; my%SSC; my@data;

open (FL,$file);

my$name=$file;
$name=~s/(\w+)_(\d+)_(\w+)\.txt/$2.$3./; 

my$i=0; while (<FL>) {chomp; if ($i eq 0){my@tmp=split(";",$_); @data=@tmp[2..5];} elsif ($i>1) { my@tmp=split(";",$_);
my$cab=(int(($tmp[1]-1)/$trc))+1; my$tr=$tmp[1]-(($cab-1)*$trc); 
my$tst=$tmp[0]; my$ssc=(int(($tr-1)/12)+1);
if ($name =~ m/trace/) { @{$STR{$tst}{$tr}{$cab}}=(); push(@{$STR{$tst}{$tr}{$cab}},@tmp[1..5]);}
elsif ($name =~ m/section/) {@{$SSC{$tst}{$ssc}{$cab}}=(); push(@{$SSC{$tst}{$ssc}{$cab}},@tmp[1..5]);} }$i=$i+1}

if ($name =~ m/trace/) {

my$j=1; 
foreach my$type (@data){$type=~s/(.+)_(.+)/$2/; my$nnm=$name.$type.".txt"; open STR,"> $nnm";
foreach my$no (sort{$a<=>$b}keys%STR){print STR "TRACE.NO;";
foreach my$cb (1..10){print STR "STR$cb",".T$no",".$type;"}; print STR "\n";
foreach my$tr (sort{$a<=>$b}keys%{$STR{$no}}){print STR "$tr;";
foreach my$cb (1..10){my$shrt=\@{$STR{$no}{$tr}{$cb}}; my $e=@$shrt;
if ($e eq 5) {print STR "$$shrt[$j];"} else {print STR ";"}
}print STR "\n"}}; close STR; ++$j;}

} elsif ($name =~ m/section/) {

my$j=1; 
foreach my$type (@data){$type=~s/(.+)_(.+)/$2/; my$nnm=$name.$type.".txt"; open SSC,"> $nnm";
foreach my$no (sort{$a<=>$b}keys%SSC){print SSC "SECTION.NO;";
foreach my$cb (1..10){print SSC "STR$cb",".T$no",".$type;"}; print SSC "\n";
foreach my$tr (sort{$a<=>$b}keys%{$SSC{$no}}){print SSC "$tr;";
foreach my$cb (1..10){my$shrt=\@{$SSC{$no}{$tr}{$cb}}; my $e=@$shrt;
if ($e eq 5) {print SSC "$$shrt[$j];"} else {print SSC ";"}
}print SSC "\n"}}; close SSC; ++$j;}

}
