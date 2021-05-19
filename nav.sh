#!/bin/bash
#____________________________________________________________________
#
#                               SETUP
#____________________________________________________________________
my_dir=`dirname $0`
source $my_dir/.config
sites="$my_dir/sites.csv"
nav1prompt="$pcolor$boldcolor$nav1h$rcolor"
nav2prompt="$pcolor$boldcolor$nav2h$rcolor"
nav4prompt="$pcolor$boldcolor$nav4h$rcolor"
PS3="$pcolor$boldcolor$blinkcolor$hash$rcolor"
#____________________________________________________________________
#
#                               DEFINE VARIABLES
#____________________________________________________________________
main_sites=$(cut -d "," -f 1 $sites )

selected_main_site(){
    cut -d "," -f 1 $sites | sed "${1}q;d"
    }

column_2_row_selected(){ 
    cut -d "," -f 2 $sites | sed "${1}q;d" 
    }

subsites_of_selected_main_site(){ 
    awk -F, -v x=$1 '$2 == x' $sites | cut -d "," -f 3 
    }

folders(){ 
    awk -F, -v x=folder '$2 == x' $sites | cut -d "," -f 1 
    }

selected_subsite_url(){ 
awk -F, -v x=$1 '$2 == x' $sites | cut -d "," -f 4 | sed "${2}q;d" 
}

smc(){
    awk -F, -v x=$1 '$2 == x' $sites | cut -d "," -f 3
}

#____________________________________________________________________
#
#                               NAV
#____________________________________________________________________
nav(){
    printf %"$(tput cols)"s |tr " " "-"
    echo ""
    printf "%*s\n" $(((${#nav1prompt}+$COLUMNS)/2)) "$nav1prompt"
    select nav_dest in $main_sites
    do 
        MAIN_SITE=$(selected_main_site "$REPLY")
        SUBSITE_CK=$(smc "$MAIN_SITE")
        subsites=$(subsites_of_selected_main_site "$MAIN_SITE") 
        prompt="$pcolor$boldcolor which $MAIN_SITE site do you wish to open...$rcolor"
        printf %"$(tput cols)"s |tr " " "-"
        echo ""
        printf "%*s\n" $(((${#prompt}+$COLUMNS)/2)) "$prompt"
        if [[ $SUBSITE_CK == "" ]]
        then
            new=$(column_2_row_selected "$REPLY")
            xdg-open ${new}
            echo "${new}"
            break
        else
            select subsite in $subsites
            do
                subnew=$(selected_subsite_url "$MAIN_SITE" "$REPLY")
                echo $subnew
                xdg-open ${subnew}
                break
            done
        fi
        break
    done
}

#____________________________________________________________________
#
#                               FAV
#____________________________________________________________________
fav(){
    printf %"$(tput cols)"s |tr " " "-"
    echo ""
    printf "%*s\n" $(((${#nav4prompt}+$COLUMNS)/2)) "$nav4prompt"
    select type in "${bmt[@]}"
    do
    printf $pcolor$boldcolor"%*s\n" $(((${#bmth[$REPLY -1]}+$COLUMNS)/2)) "${bmth[$REPLY -1]}"$rcolor
    printf %"$(tput cols)"s |tr " " "-"
    echo ""
    case $type in
        "${bmt[0]}")
            read -p "name your bookmark$blinkcolor:$rcolor " title
            read -p "url for bookmark$blinkcolor:$rcolor " url
            echo -e "$title,$url\n$(cat $sites)" > $sites
            echo ""
            for i in "$pcolor$title,$url$rcolor" "$pcolor$hba$rcolor"
            do
                printf "%*s\n" $(((${#i}+$COLUMNS)/2)) "$i"
            done
            echo ""
            printf %"$(tput cols)"s |tr " " "-"
            exit
        ;;
        "${bmt[1]}")
            read -p "name your folder$colorblink:$rcolor " title
            echo -e "$title,folder" > $sites
            for i in "$pcolor$title,$rcolor" "$pcolor$hba$rcolor"
            do
                printf "%*s\n" $(((${#i}+$COLUMNS)/2)) "$i"
            done
            echo ""
            printf %"$(tput cols)"s |tr " " "-"
            exit
        ;;
        "${bmt[2]}")
            x=$(folders)
            PS3="$pcolor$nav3h$rcolor"
            select folder in $x
            do
            read -p "name for favorite$colorblink:$rcolor " title
            read -p "url for favorite $colorblink:$rcolor " url
            echo ",$folder,$title,$url" >> $sites
            echo "$title has been added to the $site folder with and addresss of:"
            for i in "$pcolor$folder,$title,$url$rcolor" "$pcolor$hba$rcolor"
                do
                    printf "%*s\n" $(((${#i}+$COLUMNS)/2)) "$i"
                done
            echo ""
            printf %"$(tput cols)"s |tr " " "-"
            exit
            done
        ;;
        esac
    done
}
#____________________________________________________________________
#
#                               MAIN
#____________________________________________________________________
case $1 in
    "")
        nav
    ;;
    "-h")
        $my_dir/help.sh  
    ;;
    "h")
        $my_dir/help.sh 
    ;;
    "-help")
        $my_dir/help.sh   
    ;;
    "help")
        $my_dir/help.sh 
    ;;
    "add")
        fav
    ;;
    "fav")
        fav
    ;;
    "-fav")
        fav
    ;;
    *)
        echo "$scolor$boldcolor$blinkcolor Invalid Option Pleaase Refer to Help$rcolor"
        $my_dir/help.sh 
    ;;
esac