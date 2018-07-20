#!/bin/tcsh
# by Zbigniew Karolczuk, 26 February 2017

########################################################################

set traces = 636;

set ch_min = 0;
set ch_max = 0;

set tr_min = 0;
set tr_max = 0;

set tr_plot = ();
set streamers = (`seq 1 14`);

set SQLdb = "..._DailyTests.sql"

########################################################################

set cable = `zenity --list --width=150 --height=480 --text="<big>Select streamer:</big>" --column="streamer no" $streamers`

set option = `zenity --list --width=300 --height=250 --text="<big>Select tracs by criteria...</big>" --column="options"\
		"Insert trace (get trace +/-1)" "Traces by Section Serial number" "Choose Trace range"`

########################################################################

if ( `echo $option` == "Insert trace (get trace +/-1)" ) then

  set tr_mid = `zenity --entry --text="Insert single trace on cable ${cable}" | awk '{print $1}'`
  
  if ($tr_mid >= $traces) then
    
    set tr_mid = $traces
    set ch_min = `echo $cable $traces $tr_mid | awk '{printf "%i",(($1-1)*$2)+$3-1}'`
    set ch_max = `echo $cable $traces $tr_mid | awk '{printf "%i",(($1-1)*$2)+$3}'`

  else if ($tr_mid < 2) then
    
    set tr_mid = 1
    set ch_min = `echo $cable $traces $tr_mid | awk '{printf "%i",(($1-1)*$2)+$3}'`
    set ch_max = `echo $cable $traces $tr_mid | awk '{printf "%i",(($1-1)*$2)+$3+1}'`

  else

    set ch_min = `echo $cable $traces $tr_mid | awk '{printf "%i",(($1-1)*$2)+$3-1}'`
    set ch_max = `echo $cable $traces $tr_mid | awk '{printf "%i",(($1-1)*$2)+$3+1}'`

  endif  

else if ( `echo $option` == "Traces by Section Serial number" ) then

  set ch_min = `echo $cable $traces | awk '{printf "%i",(($1-1)*$2)+1}'`
  set ch_max = `echo $cable $traces | awk '{printf "%i",$1*$2}'`

  set serials = (`sqlite3 -separator " " $SQLdb 'SELECT DISTINCT CHAN, SERIAL from obsAttr WHERE CHAN BETWEEN '${ch_min}' AND '${ch_max}' AND CHAN%12=1' | awk -v var=$traces '{printf "%i %i %i\n",(($1-1)%var)+1, (($1-1)%var)+12, $2}'`)
  set section = `zenity --list --width=400 --height=1000 --print-column=3 --text="<big>Select option for traces:</big>" --column="first trace" --column="last trace" --column="section serial" $serials`
  
  set tr_plot = (`sqlite3 $SQLdb 'SELECT DISTINCT CHAN from obsAttr WHERE SERIAL=='$section' GROUP BY CHAN'`)
  
  set ch_min = ${tr_plot[1]}
  set ch_max = ${tr_plot[12]}

else if (`echo $option` == "Choose Trace range") then

  set point = `echo $traces | awk '{printf "%i", $1/2}'`

  set tr_min = `zenity --scale --text="<big>Select first trace to plot:</big>" --min-value=1 --max-value=$traces --value=$point --step=1`
  set ch_min = `echo $cable $traces $tr_min | awk '{printf "%i",(($1-1)*$2)+$3}'`
  
  set point = `echo $tr_min | awk '{printf "%i", $1+2}'`
  
  if ($point > $traces) then
    set tr_max = $traces
    set ch_max = `echo $cable $traces | awk '{printf "%i",$1*$2}'`
    goto SKIP_MAX
  endif

  set tr_max = `zenity --scale --text="<big>Select last trace to plot:</big>" --min-value=$tr_min --max-value=$traces --value=$point --step=1`

  if ($tr_max < 1) then
    set tr_max = $tr_min
  endif
  
  set ch_max = `echo $cable $traces $tr_max | awk '{printf "%i",(($1-1)*$2)+$3}'`

  SKIP_MAX:

endif

########################################################################

set min_julian = `sqlite3 $SQLdb 'SELECT MIN(JULIAN) from obsAttr'`
set max_julian = `sqlite3 $SQLdb 'SELECT MAX(JULIAN) from obsAttr'`

set min_capact = `sqlite3 $SQLdb 'SELECT MIN(CAPAC) from obsAttr WHERE CHAN BETWEEN '${ch_min}' AND '${ch_max}''`
set max_capact = `sqlite3 $SQLdb 'SELECT MAX(CAPAC) from obsAttr WHERE CHAN BETWEEN '${ch_min}' AND '${ch_max}''`

set max_cutoff = `sqlite3 $SQLdb 'SELECT MAX(CUTOF) from obsAttr WHERE CHAN BETWEEN '${ch_min}' AND '${ch_max}''`

set tr_min = `echo $cable $traces $ch_min | awk '{printf "%i", $3-($2*($1-1))}'`
set tr_max = `echo $cable $traces $ch_max | awk '{printf "%i", $3-($2*($1-1))}'`

set lines = `echo ${ch_min} ${ch_max} | awk '{printf "%i", $2-$1+1}'`

########################################################################

set outf = "/directory/OUTPUTS/DailyTests_STR${cable}_RCV${tr_min}-${tr_max}.pdf"

if (-e $outf) then
  rm -f ${outf}
endif

########################################################################

set plot_step = "14"

set plot_scalcap = "1.2"

set plot_stepcap = `echo ${min_capact} ${max_capact} ${plot_step} ${plot_scalcap} | awk '{if(((($2*$4)-($1/$4))%$3)==0){printf "%i", (($2*$4)-($1/$4))/$3} else {printf "%i", ((($2*$4)-($1/$4))/$3)+1}}'`
set plot_mincap = `echo ${min_capact} ${plot_stepcap} ${plot_scalcap} | awk '{if(($1/$3)%$2==0){printf "%i", ($1/$3)-(($1/$3)%$2)} else {printf "%i", (($1/$3)-(($1/$3)%$2))+$2}}'`
set plot_maxcap = `echo ${max_capact} ${plot_stepcap} ${plot_scalcap} | awk '{if(($1*$3)%$2==0){printf "%i", ($1*$3)-(($1*$3)%$2)} else {printf "%i", (($1*$3)-(($1*$3)%$2))+$2}}'`

set plot_scalcut = "1.4"
set plot_stepcut = `echo 0 ${max_cutoff} ${plot_step} ${plot_scalcut} | awk '{printf "%.1f", ((($2*$4)-$1)/$3)+0.1}'`
set plot_mincut = "0"
set plot_maxcut = `echo ${max_cutoff} ${plot_stepcut} ${plot_scalcut} | awk '{if(($1*$3)%$2==0){printf "%.1f", ($1*$3)-(($1*$3)%$2)} else {printf "%.1f", (($1*$3)-(($1*$3)%$2))+$2}}'`

########################################################################

set gnuplot_term = "set term pdfcairo enhanced color solid font 'Helvetica,15' size 29.7cm,21cm"

gnuplot << EOF
$gnuplot_term
set output '${outf}

# Function to get data of cable i from DB
raw_data(i)=sprintf("<(sqlite3 $SQLdb 'SELECT JULIAN, CAPAC from obsAttr WHERE CHAN=%d ORDER BY JULIAN ASC')",i)

set datafile separator '|'
set title "Streamer ${cable}, Traces from ${tr_min} to ${tr_max} - Capacitance history throughout the survey ..."
set xrange [${min_julian}:${max_julian}]
set yrange [${plot_mincap}:${plot_maxcap}]
set xlabel "Julian Date [YearJulianDay]" offset 0,-1.5
set ylabel "Capacitance [nF]"
set xtic out 1 rotate by 90 offset 0,-3
set format x "%.0f"
set ytic out ${plot_stepcap}
set mytics 5
set grid xtic mxtics ytic ls "dashed"

do for [i=${ch_min}:${ch_max}] {set style line i lw 2}
plot for [i=${ch_min}:${ch_max}] raw_data(i) using 1:2 with line ls i title sprintf("STR %i, RCV %i", ${cable}, i-((${cable}-1)*${traces}))

# Function to get data of cable i from DB
raw_data(i)=sprintf("<(sqlite3 $SQLdb 'SELECT JULIAN, CUTOF from obsAttr WHERE CHAN=%d ORDER BY JULIAN ASC')",i)

set title "Streamer ${cable}, Traces from ${tr_min} to ${tr_max} - Cut Off history throughout the survey ....\"
set yrange [${plot_mincut}:${plot_maxcut}]
set ylabel "Cut Off [Hz]"
set ytic out ${plot_stepcut}
set xlabel "Julian Date [YearJulianDay]" offset 0,0

plot for [i=${ch_min}:${ch_max}] raw_data(i) using 1:2 with line ls i title sprintf("STR %i, RCV %i", ${cable}, i-((${cable}-1)*${traces}))

EOF

