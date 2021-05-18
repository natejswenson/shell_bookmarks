#!/bin/bash
#____________________________________________________________________
#
#                               SETUP
#____________________________________________________________________
my_dir=`dirname $0`
source $my_dir/.config
sites="$my_dir/sites.csv"
navprompt="$pcolor$boldcolor$pr$rcolor"
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
    printf "%*s\n" $(((${#prompt}+$COLUMNS)/2)) "$prompt"
    printf %"$(tput cols)"s |tr " " "-"
    select nav_dest in $main_sites
    do 
        MAIN_SITE=$(selected_main_site "$REPLY")
        SUBSITE_CK=$(smc "$MAIN_SITE")
        subsites=$(subsites_of_selected_main_site "$MAIN_SITE") 
        prompt="$pcolor$boldcolor CHOOSE SPECIFIC $MAIN_SITE SITE$rcolor"
        printf %"$(tput cols)"s |tr " " "-"
        echo ""
        printf "%*s\n" $(((${#prompt}+$COLUMNS)/2)) "$prompt"
        printf %"$(tput cols)"s |tr " " "-"
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
    select type in "${bmt[@]}"
    do
    printf $pcolor$boldcolor"%*s\n" $(((${#bmth[$REPLY -1]}+$COLUMNS)/2)) "${bmth[$REPLY -1]}"$rcolor
    printf %"$(tput cols)"s |tr " " "-"
    echo ""
    case $type in
        "${bmt[0]}")
            read -p "name yuour bookmark:" title
            read -p "full url for your bookmark" url
            echo -e "$title,$url\n$(cat $sites)" > $sites
            echo "$pcolor $boldcolor$title,$url$rcolor"
            echo "has been added to sites.csv"
        ;;
        "${bmt[1]}")
            echo "Name your folder"
            read title
            echo "Enter full url for your bookmark"
            read url
            echo -e "$title,$shorturl\n$(cat $sites)" > $sites
            echo "$pcolor $boldcolor$title,$shorturl$rcolor"
            echo "has been added to sites.csv"
        ;;
        "${bmt[2]}")
            site=$(selected_main_site "$REPLY")
            echo "Enter full url in the formate https://www.$site.com/subsite"
            read url
            echo ",$site,$title,$url" >> $sites
            echo "$title has been added to the $site folder with and addresss of:"
            printf "%*s\n" $(((${#url}+$COLUMNS)/2)) "$url"
            echo "has been added as a subsite of $site sites.csv"
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