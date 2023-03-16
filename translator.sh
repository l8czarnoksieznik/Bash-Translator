#!/bin/bash


czyLiczba(){
    l='^[+-]?[0-9]+$'
    if  [[ $1 =~ $l ]]
    then
        return 0
    else
        return 1
    fi
}

jakiZnak(){
    if [[ $1 == "-gt" ]]; then echo ">";
    elif [[ $1 == "-lt" ]]; then echo "<";
    elif [[ $1 == "-eq" ]]; then echo "==";
    elif [[ $1 == "-ne" ]]; then echo "!=";
    elif [[ $1 == "-ge" ]]; then echo ">=";
    elif [[ $1 == "-le" ]]; then echo "<=";
    fi

}

input=$1
output=$2

>$output 

echo "#include <stdio.h>" >> $output
echo "int main() {" >> $output



while read linia
do
    echo $linia

    if [[ $linia == "echo"* ]]
    then
        c=`echo $linia | awk -F "echo " '{print $NF}'`
        if czyLiczba $c
        then
            echo "printf("\%\d", $c);" >> $output
        else
            echo "printf("\%\s", $c);" >> $output
        fi
        # naprawic co jesli echo $x
        #x=`echo $linia | awk -F "$" '{print $NF}'`

    fi


    if [[ $linia == *"="* ]]
    then
        x=`echo $linia | awk -F "=" '{print $1}'`
        y=`echo $linia | awk -F "=" '{print $NF}'`

        if czyLiczba $y 
        then
            x="int $x"

        elif [[ ${y:0:1} == "$" ]]
        then
            y=${y:1}

        else
            x="char $x[]"
        fi

        echo "$x = $y;" >> $output
  
    fi
#   WHILE POCZATEK
    if [[ $linia == "while"* ]]
    then
        IFS=' ' read -a arr <<<"$linia" #slowa z linii gdzie bylo while napisane
        a=${arr[2]:1}
        if [[ $a == "$" ]]
        then    
            a=${a:1}
        fi

        znak=${arr[3]}
        znak=`jakiZnak $znak`

        b=${arr[4]}

        echo "while( $a $znak $b ) {" >>$output
    fi

    if [[ $linia == "done" ]]
    then
        echo "}" >> $output
    fi
#   WHILE KONIEC

#   FOR POCZATEK
    if [[ $linia == "for"* ]]
    then
        IFS=' ' read -a arr <<<"$linia" #slowa z linii gdzie bylo for napisane
        m=${arr[1]}
        if [[ $m == "$" ]]
        then    
            m=${m}
        fi

        IFS='..' read -a arr2 <<<"$linia" #parametry for 

        pierwszy=${arr2[0]:10}
        drugi=${arr2[2]}
        krok=${arr2[4]:0:-1}
        
        
        if [ $krok ] #jesli istnieje krok
        then
            if [[ $pierwszy < $drugi ]]
            then
                #inkrementacja
                echo "for( int $m=$pierwszy; $m<=$drugi; $m+=$krok ) {" >>$output
            else
                #dekrementacja
                echo "for( int $m=$pierwszy; $m>=$drugi; $m-=$krok ) {" >>$output
            fi
            

        else
            if [[ $pierwszy < $drugi ]]
            then
                #inkrementacja
                echo "for( int $m=$pierwszy; $m<=$drugi; $m++ ) {" >>$output
            else
                #dekrementacja
                echo "for( int $m=$pierwszy; $m>=$drugi; $m-- ) {" >>$output
            fi
        fi

    fi
    if [[ $linia == "done" ]]
    then
        echo "}" >> $output
    fi

#   FOR KONIEC
        #c=`echo $linia | awk -F "echo " '{print $NF}'`
        #if czyLiczba $c
        #then
        #    echo "printf("\%\d", $c);" >> $output
        #else
        #    echo "printf("\%\s", $c);" >> $output
        #fi


    


done < $input


