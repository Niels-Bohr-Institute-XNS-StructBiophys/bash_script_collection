#!/bin/bash
# Alireza Haghdoost pdf2eps converter
# need xpdf and sam2p package to work on Linux OS
# http://ce.sharif.edu/~haghdoost/mypages/pdf2eps.html

function timer()
{
    if [[ $# -eq 0 ]]; then
        echo $(date '+%s')
    else
        local  stime=$1
        etime=$(date '+%s')

        if [[ -z "$stime" ]]; then stime=$etime; fi

        dt=$((etime - stime))
        ds=$((dt % 60))
        dm=$(((dt / 60) % 60))
        dh=$((dt / 3600))
        printf '%d:%02d:%02d' $dh $dm $ds
    fi
}

for i in $@
do
    t=$(timer)
    echo -e "$i" | sed 's/\(.*\)\..*/\1/' >temp.out
    read NAME <temp.out
    echo -e "$i"|awk -F . '{print $NF}' >temp.out
    read EXT <temp.out

    if [ "$EXT" = 'pdf' -o "$EXT" = 'PDF' ]
      then
           echo "Converting $i to eps format"
        pdftops $i
        ps2eps $NAME.ps 1>temp.out 2>temp.out
        rm $NAME.ps   
        eps2eps $NAME.eps $NAME.2.eps 1>temp.out 2>temp.out
        rm $NAME.eps
        gs -r300 -dEPSCrop -dTextAlphaBits=4 -sDEVICE=png16m -sOutputFile=$NAME.png -dBATCH -dNOPAUSE $NAME.2.eps >temp.out 2>temp.out
        rm $NAME.2.eps
        sam2p $NAME.png EPS: $NAME.eps >temp.out 2>temp.out
        if [ $? -eq 0 ]
            then
            echo -e "$NAME.pdf converted to $NAME.eps"
            printf 'Elapsed time: %s\n' $(timer $t)
        fi
        rm $NAME.png
       
        echo "----------------------"
   
      else
        echo " $i is not a pdf file "
        echo "----------------------"   
    fi
done
rm temp.out
