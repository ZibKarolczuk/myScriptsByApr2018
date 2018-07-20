#!/bin/tcsh
# by Zbigniew Karolczuk, 08 November 2017

set mainDir = "/directory/edits/"
set subDir = "workboatCSV"
set channels = 684

cd $mainDir

set edits_all = "$SEQN_edits.csv"
set edits_wb = "$subDir/SEQ$SEQN_wbedits.csv"
set polygons = "$subDir/polygons_SEQ$SEQN.ssv"

set pre_adste = "$SEQN_proc.adste"
set fnl_adste = `awk '/^H Line/{print $4".adste"}' $pre_adste`

### CREATING CSV g2 EDITS LIBRARY FOR BAD DEPTHS ONLY:

awk 'BEGIN{print "#seq spmin spmax chmin chmax flag"} \
		NR==FNR{a[NR]=$0;next}{for(i in a){split(a[i],x," "); \
		{if($1>$2){loSP=$2; $2=$1; $1=loSP}}; {if($3>$4){loCH=$4; $4=$3; $3=loCH}}; \
		if(x[2]>$1){spMin=x[2]}else{spMin=$1}; if(x[3]>$2){spMax=$2}else{spMax=x[3]}; \
		if(x[4]>$3){chanMin=x[4]}else{chanMin=$3}; if(x[5]>$4){chanMax=$4}else{chanMax=x[5]}; \
		if (x[6]==4 && x[2]<=$2 && x[3]>=$1 && x[4]<=$4 && x[5]>=$3) \
		print x[1] , spMin , spMax, chanMin , chanMax , 8 \
		}}' $edits_all $polygons > $edits_wb

echo " "
echo " Edits due to workboat cleaning were successfully isolated into separate CSV file: $mainDir$edits_wb"

### CREATING MERGED ADSTE:

awk '$1~/[VHCX]/{print $0}' $pre_adste > $subDir/$fnl_adste
sort -nk 4 -nk 5 -nk 2 -nk 3 $edits_wb | awk -v ch=$channels '$0!~/^#/{s=($4-1)/ch+1; \
		printf "C Bad Traces : BAD DEPTH STREAMER %i\nX (%i-%i; %i-%i)\n",s,$2,$3,$4,$5}' >> $subDir/$fnl_adste
awk '$1!~/[VHCX]/{print $0}' $pre_adste >> $subDir/$fnl_adste

echo " Created concatenated ADSTE file: $mainDir/$subDir/$fnl_adste"
echo " "
