### to use:
```bash
cd
git clone git@https://github.com/natejswenson/shell_favorites.git
chmod u+x nav.sh
echo 'alias nav=~/bash-browser-favorites/nav.sh' >> ~/.bashrc 
. ~/.bashrc
##Use this if you have zsh
echo 'alias nav=~/bash-browser-favorites/nav.sh' >> ~/.zshrc
. ~/.zshrc
nav
```
### to add sites navigatable from main mnenu:
```sh
nav -fav
```
![Alt text](/img/ADDSITE.png)

### to add sites navigatable from sub mnenu:
```sh
nav -fav
```
![Alt text](/img/ADDSUBSITE.png)

### Help file 
```sh
nav -h
```
