#!/bin/bash
source function-lib.sh

# Coordonnées de la position où cliquer :

if [ -n "$1" ] && [ -n "$2" ]; then
# passage de x et y en paramètres > ./basic-exped.sh xx yy
	X=$1
	Y=$2
else
# préparer le script dans un terminal > ./basic-exped.sh
# positionner la souris sur la zone de lancement et de réclamation
# des expéditions (non masquée par le terminal du script)
# exécuter le script (touche return)
	#mouseloc=$(xdotool getmouselocation)
	#X=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
	#Y=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
	set_mouse_coordinates "expedition launch and claim" "X" "Y"
fi
echo "x: $X, y: $Y"

# Boucle infinie
while true; do
	# Déplacer la souris et cliquer 2 fois
	xdotool mousemove $X $Y click 1
	sleep 10
	xdotool mousemove $X $Y click 1

	# Attendre
	sleep 480
done
