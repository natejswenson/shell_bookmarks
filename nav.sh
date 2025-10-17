#!/bin/bash
#____________________________________________________________________
#
#                               SETUP
#____________________________________________________________________
my_dir="$(dirname "$0")"
source "$my_dir/.config" || { echo "Error: .config file not found"; exit 1; }
sites="$my_dir/sites.csv"

# Check if sites.csv exists
if [[ ! -f "$sites" ]]; then
    echo "Error: sites.csv not found at $sites"
    exit 1
fi

nav1prompt="$pcolor$nav1h$rcolor"
nav2prompt="$pcolor$boldcolor$nav2h$rcolor"
nav4prompt="$pcolor$boldcolor$nav4h$rcolor"
PS3="$pcolor$boldcolor$blinkcolor$hash$rcolor"

#____________________________________________________________________
#
#                               CACHE CSV DATA
#____________________________________________________________________
# Read the entire CSV into memory once to avoid repeated disk I/O
mapfile -t CSV_LINES < "$sites"

# Pre-compute main sites list
main_sites=""
for line in "${CSV_LINES[@]}"; do
    IFS=',' read -r col1 col2 col3 col4 <<< "$line"
    if [[ -n "$col1" ]]; then
        main_sites+="$col1"$'\n'
    fi
done

#____________________________________________________________________
#
#                               OPTIMIZED FUNCTIONS
#____________________________________________________________________
selected_main_site(){
    local idx=$1
    local count=0
    for line in "${CSV_LINES[@]}"; do
        IFS=',' read -r col1 _ <<< "$line"
        ((count++))
        if [[ $count -eq $idx ]]; then
            echo "$col1"
            return
        fi
    done
}

column_2_row_selected(){
    local idx=$1
    local count=0
    for line in "${CSV_LINES[@]}"; do
        IFS=',' read -r _ col2 _ <<< "$line"
        ((count++))
        if [[ $count -eq $idx ]]; then
            echo "$col2"
            return
        fi
    done
}

subsites_of_selected_main_site(){
    local target="$1"
    for line in "${CSV_LINES[@]}"; do
        IFS=',' read -r _ col2 col3 _ <<< "$line"
        if [[ "$col2" == "$target" && -n "$col3" ]]; then
            echo "$col3"
        fi
    done
}

folders(){
    for line in "${CSV_LINES[@]}"; do
        IFS=',' read -r col1 col2 _ <<< "$line"
        if [[ "$col2" == "folder" ]]; then
            echo "$col1"
        fi
    done
}

selected_subsite_url(){
    local target="$1"
    local idx=$2
    local count=0
    for line in "${CSV_LINES[@]}"; do
        IFS=',' read -r _ col2 col3 col4 <<< "$line"
        if [[ "$col2" == "$target" ]]; then
            ((count++))
            if [[ $count -eq $idx ]]; then
                echo "$col4"
                return
            fi
        fi
    done
}

smc(){
    local target="$1"
    for line in "${CSV_LINES[@]}"; do
        IFS=',' read -r _ col2 col3 _ <<< "$line"
        if [[ "$col2" == "$target" ]]; then
            echo "$col3"
            return
        fi
    done
}

#____________________________________________________________________
#
#                               NAV
#____________________________________________________________________
nav(){
    printf %"$nav1prompt$(tput cols)"s |tr " " "_"
    printf "$nav1prompt \n"
    select nav_dest in $main_sites
    do
        MAIN_SITE=$(selected_main_site "$REPLY")
        SUBSITE_CK=$(smc "$MAIN_SITE")
        subsites=$(subsites_of_selected_main_site "$MAIN_SITE")
        prompt="$MAIN_SITE | $nav1prompt$rcolor\n"
        printf %"$(tput cols)"s |tr " " "-"
        echo ""
        printf "$prompt"
        if [[ $SUBSITE_CK == "" ]]
        then
            new=$(column_2_row_selected "$REPLY")
            if [[ -n "$new" ]]; then
                xdg-open "$new" 2>/dev/null || { echo "Error: Could not open $new"; exit 1; }
                echo "$new"
            fi
            break
        else
            select subsite in $subsites
            do
                subnew=$(selected_subsite_url "$MAIN_SITE" "$REPLY")
                if [[ -n "$subnew" ]]; then
                    echo "$subnew"
                    xdg-open "$subnew" 2>/dev/null || { echo "Error: Could not open $subnew"; exit 1; }
                fi
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
            if [[ -z "$title" || -z "$url" ]]; then
                echo "Error: Both name and URL are required"
                exit 1
            fi
            # More efficient file prepending
            printf "%s,%s\n%s" "$title" "$url" "$(cat "$sites")" > "$sites"
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
            if [[ -z "$title" ]]; then
                echo "Error: Folder name is required"
                exit 1
            fi
            printf "📁(%s),folder\n%s" "$title" "$(cat "$sites")" > "$sites"
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
            if [[ -z "$x" ]]; then
                echo "Error: No folders found. Create a folder first."
                exit 1
            fi
            PS3="$pcolor$nav3h$rcolor"
            select folder in $x
            do
            read -p "name for favorite$colorblink:$rcolor " title
            read -p "url for favorite $colorblink:$rcolor " url
            if [[ -z "$title" || -z "$url" ]]; then
                echo "Error: Both name and URL are required"
                exit 1
            fi
            echo ",$folder,$title,$url" >> "$sites"
            echo "$title has been added to the $folder folder with an address of:"
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
    "-h"|"h"|"-help"|"help")
        "$my_dir/help.sh"
    ;;
    "add"|"fav"|"-fav")
        fav
    ;;
    *)
        echo "$scolor$boldcolor$blinkcolor Invalid Option Please Refer to Help$rcolor"
        "$my_dir/help.sh"
    ;;
esac
