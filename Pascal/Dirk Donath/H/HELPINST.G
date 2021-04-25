# Installation des Hilfesystems auf einer Ramdisk.
#
echo ' '
echo 'Gulam Interactive Help System'
echo '(c) D.Donath 1988'
#
# **** WICHTIG: ****
# Hier den Aufruf eines Ramdisk-Programms eintragen, das eine Ramdisk
# mit Laufwerksbuchstabe H: von mind. 35 KB Groesse erstellt.
# 
cp h.ttp h:
cp gulam.hlp h:
#
# Der H-Befehl nimmt dann das Hilfesystem von der Ramdisk, ohne das
# momentan gesetzte Laufwerk/Verzeichnis zu veraendern:
#
alias h 'pushd h:; h.ttp $1; popd' 
#
echo ' '
echo 'Help System installed.'
echo 'Usage: h <command>'
echo ' '
