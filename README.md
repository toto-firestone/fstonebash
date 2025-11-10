# fstonebash
## Automation and tools for Firestone idle RGP using Bash, xdotool, imagemagick 6 and Julia

The code has been implemented on Linux PC, with Firestone running on Armor Games and Firefox.

### DISCLAIMER :
No doc, no tuto, no support... Help yourself and brew your own.
* Using this program will require skills in Bash Shell Programming Language.
* Reading it may provide ideas for your own bot, adapted to your playstyle, device, system and platform.

The best I can do right now is a description of all features

* Native single platform and multi server architecture
* Enable remote control of bot with SSH and Unix command line
* Alchemy experiments
* Accept guild applications
* Daily/Weekly quests
* Research tree
* Map missions
* Slow climb back with guardian
* WM Liberation and dungeon missions, arena fight
* Math tool that shows optimal blueprint spending for WM defense improvement
* Brute force WM mission (try again and again)
* Claim lot of free stuffs (pickaxes, tools, campaign loots, ...)
* Simple database for coordinates management
* Spend and collect free stuffs in scarab game and chaos rift
* Start quit and restart game
* Claim friday gift
* Setting for reducing activity
* Map mission coordinates management tools
* Enable interactive command line usage
* Standard view setting
* Holy damage maximization tool
* Keep track of expedtion tokens invested in WM, ptree and scarab game
* Screen sampling using ImageMagick
* Robustess and failsafe
* Basic example for guild expeditions only (basic-exped.sh)
* Non-commercial license

### Author's Note :
Writing my own automation bot and tools provided me as much fun as playing the game itself, and even more actually.
Another reason to encourage players to build their own softwares is the maintenance issues.
Tools have to be updated each time a major change occurs in the game.
Furthermore, firestone tools can't survive long time after their authors quit the game.

### imagemagick6 build Notes :
Imagemagick 7 will not work. Imagemagick 6 is no more supported in some ubuntu repositories, including mine actually. Recompile it from source requires delegate libraries :
* libx11 dev package
* libpng dev package
* libfftw3 dev package and force ./configure --with-fftw=yes
* appending --enable-hdri may help but not enough
* libperl dev package (no effect on ./configure output)
* libtld dev package and appending --enable-shared --with-modules
* libjpeg and libtiff dev packages
* libxml dev package
* libomp dev package... but ./configure still has error message about it so we append --disable-openmp
* libghc-bzlib dev package
* libdjvu dev package
* make dynamic libraries available with sudo ldconfig /usr/local/lib
* after all those attempts, ncc metric is still broken on ImageMagick 6.9.13-34 (Beta). Now rolling back to 6.9.10-23 which was the version that worked
* git checkout 6.9.10-23 worked for NCC bugfix. x11, png look like mandatory. All the rest may be optional. Next compile attempt will be easier with these informations.
