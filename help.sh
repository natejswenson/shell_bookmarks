#!/bin/bash
#____________________________________________________________________
#
#                               SETUP
#____________________________________________________________________
my_dir=`dirname $0`
source $my_dir/.config
sites="$my_dir/sites.csv"

printf %"$(tput cols)"s |tr " " "-"
echo ""
for i in "${array[@]}"
do
printf "%*s\n" $(((${#i}+$COLUMNS)/2)) "$i"
done
printf %"$(tput cols)"s |tr " " "-"
select option in 'add a favorite' 'open a bookmarked site' 'edit sites.csv' 'leave'
do
     case $option in
    "add a favorite")
       $HOME/local_repo/shell_favorites/nav.sh -fav
        ;;
    "open a bookmarked site")
        $HOME/local_repo/shell_favorites/nav.sh
        ;;
    "edit sites.csv")
        vi $my_dir/sites.csv
    ;;
    ".leave")
        exit
    ;;
    esac
    break
done