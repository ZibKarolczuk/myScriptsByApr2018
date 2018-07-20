#! /bin/bash
#by Zib Karolczuk, EDV 30/10/2016

##### #### ### ## # ## ### #### #####
#Functions

function MakePNG {
FILE_IN=$plot/$fldr/$SEQ$core.pdf
FILE_OU=$finl$SEQ/$SEQ$apnd$core.png
convert -verbose -density 300 $FILE_IN -quality 100 $FILE_OU
}

function ExtractPDF {
FILE_IN=/share/data/$proj/QC/LINE_REPORT/$SEQ\_NAV.pdf
FILE_OU=$finl$SEQ/$SEQ\P$page\_SeisNAV
pdftk $FILE_IN cat $page output $FILE_OU.pdf
convert -verbose -density 300 $FILE_OU.pdf -quality 100 $FILE_OU.png
rm -f $FILE_OU.pdf
}

function AppendPNGS {
declare -a shots
shots=(`find $plot/CLIENT/$fldr/*,$SEQ,KF_SD*PNG | awk -F'[_.]' '{print $3}' | sort -hu`)
for shot in "${shots[@]}"
do
 sht6=`echo $shot | awk '{printf "%06i",$1}'` && FILE_SP=$plot/CLIENT/$fldr/SEIS,$core,$SEQ,ANY$sht6.PNG
 sht4=`echo $shot | awk '{printf "%04i",$1}'` && FILE_FK=$plot/CLIENT/$fldr/FK,$SEQ,$core\_$sht4.PNG
 FILE_OU=$finl$SEQ/$sht4\_$SEQ\_$core.png
 convert -verbose +append $FILE_SP $FILE_FK $FILE_OU
done
}

##### #### ### ## # ## ### #### #####
#Project variables

proj=BG16SIL

finl=/array/proj/$proj/QC_REPORT/
plot=/share/data/$proj/PLOTS

##### #### ### ## # ## ### #### #####
#Terminal printing

echo "" && echo "CONVERTING PDF GRAPHS TO PNG FORMATS FOR EOL REPORT" && echo ""
echo "For single sequence just insert a value"
echo "For range of sequences insert: FSQ - LSQ"
echo "" && echo "Please provide sequence number: "

##### #### ### ## # ## ### #### #####
#Checking insert

read INPUT

fsq=`echo $INPUT | cut -d "-" -f 1 | awk '{printf "%i",$1}'`
lsq=`echo $INPUT | cut -d "-" -f 2 | awk '{printf "%i",$1}'`

if [ "$fsq" -eq "0" -o "$lsq" -lt "$fsq" ]; then
  echo "" && echo " Houston, we have a problem" && echo " inserting err, quit now!" && echo "" && exit $?
fi

i=$fsq
  while [ $i -le $lsq ]; do
  SEQ=`echo $i | awk '{printf "%03i",$1}'`
  cd $finl && mkdir -p $SEQ
  echo "" && echo "=== = CONVERTING SEQ$SEQ = ===" && echo ""

##### #### ### ## # ## ### #### #####
#Main

core=_nav_diff_to_profile_map
fldr=P190
MakePNG

core=_nav_compare_depth
fldr=P190
MakePNG

page=1
ExtractPDF

page=2
ExtractPDF

##### #### ### ## # ## ### #### #####
  
  i=$[$i+1]
done

echo "" && echo "=== == CONVERTING DONE! == ===" && echo ""

##### #### ### ## # ## ### #### #####
#Done!
