#!/bin/bash
export blue=`tput setaf 4`
export black=`tput sgr0`
export bold=`tput bold`
export blink=`tput blink`
array=('BOOKMARK NAVIGATION' 'Created by NateJSwenson' 'github:@natejswenson')
printf %"$(tput cols)"s |tr " " "-"
echo ""
for i in "${array[@]}"
do
printf "%*s\n" $(((${#i}+$COLUMNS)/2)) "$i"
done
printf %"$(tput cols)"s |tr " " "-"
select option in '...add a favorite' '..open a bookmarked site' '.leave'
do
     case $option in
    "...add a favorite")
       $HOME/local_repo/shell_favorites/nav.sh -fav
        ;;
    "..open a bookmarked site")
        $HOME/local_repo/shell_favorites/nav.sh
        ;;
    ".leave")
    exit
    ;;
    esac
    break
done