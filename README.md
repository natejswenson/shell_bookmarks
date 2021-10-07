### setup on yoru machine:
```bash
cd
git clone git@https://github.com/natejswenson/shell_favorites.git
chmod u+x nav.sh
# for use with bash
echo 'alias nav=~/bash-browser-favorites/nav.sh' >> ~/.bashrc 
. ~/.bashrc
### for use with zsh
echo 'alias nav=~/bash-browser-favorites/nav.sh' >> ~/.zshrc
. ~/.zshrc
```

### nav function
```sh
 nav
```
![](/img/nav.png)

### understading the code:
1. sites.csv: 
   Contains the data for your favorits and is in the following format:
   1. Top Level Sites (think navigation links that are not in folders
    *site_name,site_url*
   1. favorite folders
    *folder_name,*
   1. sites in favorites folder:
    *,folder_name,site_name,site_url*
2. nav.sh
   Main code broken down into a few key sections:
   1. Basic Setup
   2. Variable Creation from sites.csv
   3. Navigation
   4. Add Favorites
   5. Main
3. help.sh
   Need help type nav -h nav -help or any incorrect syntax will take you here. From help you can:
   1. go to main navigation
   2. go and add a favorite
   3. open sites.csv in vim
   4. exit
4. .config
   a bunch of vars if you are not satisfied with colors try changing pcolor or scolor which are set using tput setaf
### fav function
```sh
nav -fav
```
####  add a favorite to sites.csv:
![](/img/addtoplevelsite.png)

#### to add a favorites folder:

![](/img/addfolder.png)

#### add a favorite to a folder:
![](/img/addtofolder.png)

### Help file 
```sh
nav -h
```
