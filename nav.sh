#!/bin/bash
#...................................................................
#.......................Setup........................................
#.....................................................................
export grey=$'\e[30m'
export cyan=$'\e[36m'
export white=$'\e[1;37m'
my_dir=`dirname $0`
sites="$my_dir/sites.csv"
helptxt="$my_dir/help.txt"
browser="Google Chrome"
#........................................................................
#...............................defineRows................................
#.........................................................................
#r1 returns ALL values in column 1 of csv files
r1=$(cut -d "," -f 1 $sites )

#r1s returns a SINGLE value in r1:$1
r1s(){
    cut -d "," -f 1 $sites | sed "${1}q;d"
    }

#returns the a SINGLE value in r2:$1 
r2s(){ 
    cut -d "," -f 2 $sites | sed "${1}q;d" 
    }

#returns ALL values that mach $1 in colum 2 and filters those to show only column 3
r3(){ 
    awk -F, -v x=$1 '$2 == x' $sites | cut -d "," -f 3 
    }
#returns url for subsites that from selection 1
r4s(){ 
awk -F, -v x=$1 '$2 == x' $sites | cut -d "," -f 4 | sed "${2}q;d" 
}
#submenu check deterimines if there is anything in column 3 for the selected site
smc(){
    awk -F, -v x=$1 '$2 == x' $sites | cut -d "," -f 3
}


#...................................................................
#.......................Main Functions..............................
#...................................................................
navmain(){
    PS3="$cyan ENTER SITE(#):$white"
    select uno in $r1 
    do 
    REPLYA=$REPLY
    select3=$(r1s "$REPLYA")
    test=$(smc "$select3")
    old=$(r1s "$REPLY")
    big=tr
    array2=$(r3 "$old")
    PS3="$cyan ENTER $old SUBSITE(#):$white"
        if [[ $test == "" ]]
        then
            new=$(r2s "$REPLY")
            open -a "$browser" https://${new}
            echo "https://${new}"
            break
        else
            select subsite in $array2
            do
                subnew=$(r4s "$old" "$REPLY")
                echo $subnew
                open -a "$browser" https://${subnew}
                break
            done
        fi
        break
    done
}
favmain(){
    echo "$cyan NAME FOR BOOKMARK:$white"
    read "title"
    echo "$cyan IS $title A SUBSITE (y/n)?:$white"
    read subsite
    if [[ $subsite == "y" ]] 
    then
        select bingo in $r1 
        do
            site=$(r1s "$REPLY")
            url="$(osascript -e 'tell application "Google Chrome" to return URL of active tab of front window')"
            shorturl=${url#*//}
            echo ",$site,$title,$shorturl" >> $sites
            echo "$title,$shorturl"
            echo "has been added as a subsite of $site sites.csv"
        done
        else 
        url="$(osascript -e 'tell application "Google Chrome" to return URL of active tab of front window')"
        shorturl=${url#*//}
        echo -e "$title,$shorturl\n$(cat $sites)" > $sites
        echo "$cyan$title,$shorturl$white"
        echo "has been added to sites.csv"
    fi
}

#................................................................................
#...................................Main..........................................
#.................................................................................
if [[ $@ == "" ]] 
then
   navmain
elif [[ $1 == "-fav" ]]
then
   favmain
elif [[ $1 == "-h" ]]
then
cat $helptxt
else
    echo "invalid command please enter $cyan nav -h$white for help"
fi
