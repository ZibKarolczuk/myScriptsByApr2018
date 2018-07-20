#!/bin/csh 
#by Zbigniew Karolczuk, 01 Mar 2017

set ARG1 = $argv[1]
set frst_shot_blk6 = $argv[2]
set last_shot_blk6 = $argv[3]

set segdBKP = "/directory/LINE"
set glk = "/directory/Block2"
set sequence = `echo $ARG1 | awk '{printf "%03d", $1}'`
set folder = `find ${segdBKP}/*${sequence} -type d -printf "%f\n"`

find $segdBKP/*$sequence -type d -printf "%f\n"

mkdir -p $glk/$folder

  if ($frst_shot_blk6 < $last_shot_blk6) then
  
    set i = $frst_shot_blk6
  
    while ($i <= $last_shot_blk6)
      set SHOT06 = `echo $i | awk '{printf "%06d",$1}'`
      cp -np $segdBKP/$folder/*.$SHOT06.segd $glk/$folder/
      @ i++
    end

  else if ($frst_shot_blk6 > $last_shot_blk6) then

    set i = $frst_shot_blk6
  
    while ($i >= $last_shot_blk6)
      set SHOT06 = `echo $i | awk '{printf "%06d",$1}'`
      cp -np $segdBKP/$folder/*.$SHOT06.segd $glk/$folder/
      @ i--
    end

  endif

