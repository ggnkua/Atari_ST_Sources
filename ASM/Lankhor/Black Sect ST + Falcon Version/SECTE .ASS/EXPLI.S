Si pas erreur:          test de bonne execution
**************
routine                                 000
taille des routines conditionnees       word

Si erreur:              test d'erreur
**********
routine                                 001
taille des routines conditionnees       word

Affichage message:      message en partie basse d'ecran
******************
routine                                 002
message                                 word

Deplacement:            changement de lieu
************
routine                                 003
lieu                                    octet
nbre de minutes                         word

Mort:                   fin du jeu -> perdu
*****
routine                                 004
num des pages (fin= -1)                 octet

Assome:                 perte de conscience, les affichages sont suspendus
*******
routine                                 005
num de page (fin= -1)                   octet
lieu ou on se reveille                  octet
nbre de minutes                         word

Augmente temps:         temps qui passe
***************
routine                                 006
nbre de minutes                         word

Parler:                 parler avec un personnage
*******
routine                                 007
tete                                    octet
message                                 word
coox                                    word
cooy                                    word

Valide: F               valide une zone
*******
routine                                 008
num de lieu                             octet
num de zone                             octet

Devalide: F             devalide une zone
*********
routine                                 009
num de lieu                             octet
num de zone                             octet

Test valide: F          test de validite d'une zone
************
routine                                 010
num de lieu                             octet
num de zone                             octet

Affiche val et deval:   Affiche les zones valides ou devalides
*********************
routine                                 011

Ajoute objet: F         Ajoute un objet dans une chaine
*************           (0 a 1000:     chaine lieu,
                         1000 a 32000: chaine objet,
                         -32767:       chaine nulle)
routine                                 012
chaine                                  word
objet                                   octet

Retire objet: F         EnlŠve un objet dans une chaine
*************
routine                                 013
chaine                                  word
objet                                   octet

Appartient: F           Un objet appartient-il a une chaine ?
***********
routine                                 014
chaine                                  word
objet                                   octet

Test lieu: F            Est-on dans un des lieux cites ?
**********
routine                                 015
num des lieux (fin= -1)                 octet

Valdep:                 Rends un deplacement valide
*******
routine                                 016
num de lieu                             octet
num du dep                              octet

Devaldep:               Rends un deplacement invalide
*********
routine                                 017
num de lieu                             octet
num du dep                              octet

Test dep: F             Test la validite d'un deplacement
*********
routine                                 018
num de lieu                             octet
num du dep                              octet

Alerte:                 Message bloquant pour un temps donne
*******
routine                                 019
message                                 word

Addition compteur:      Additionne une valeur a un compteur
*****************
routine                                 020
compteur                                octet
valeur                                  word

Soustraction compteur:  Soustrait une valeur a un compteur
**********************
routine                                 021
compteur                                octet
valeur                                  word

Mets compteur:          Mets une valeur dans un compteur
**************
routine                                 022
compteur                                octet
valeur                                  word

Test compteur egal: F   Test l'egalite du compteur a une valeur
*******************
routine                                 023
compteur                                octet
valeur                                  word

Test compteur sup: F    Test la superiorite du compteur a une valeur
******************
routine                                 024
compteur                                octet
valeur                                  word

Test compteur inf: F    Test l'inferiorite du compteur a une valeur
******************
routine                                 025
compteur                                octet
valeur                                  word

Fouille chaine: F       Fouille une chaine et passe en mode objet
***************
routine                                 026
chaine                                  word
message chaine vide                     word
message chaine pleine                   word
message fin de chaine                   word

Indice:                 Incremente le compteur d'indice
*******
routine                                 027
numero de l'indice                      octet

Lire:                   Affichage d'un document a lire 
*****
routine                                 028
num des textes (fin= -1)                octet

Set palette:            Affecte la palette du dessin
************
routine                                 029
numero du lieu                          octet
numero de palette                       octet

Test palette: F         Teste la palette affect‚e
*************
routine                                 030
numero du lieu                          octet
numero de palette                       octet

Prends: F               Prendre un objet dans sa main
*******
routine                                 031
objet                                   octet

Main joueur: F          Le joueur a-t-il un objet en main ?
************
routine                                 032
objet                                   octet

Appartient joueur: F    Un objet appartient-il au joueur ?
******************
routine                                 033
objet                                   octet

Valide cacher:          Validation de l'action se cacher
**************
routine                                 034

Test cacher: F          Test si le joueur est cache
************
routine                                 035

Loupe:                  Apparition d'une loupe
******
routine                                 036
message                                 word

Disparition objet:      Disparition temporaire d'un objet
******************
routine                                 037
objet                                   octet

Validation d'une zone objet:
****************************
routine                                 038
objet                                   octet
zone                                    octet

Devalidation d'une zone objet:
******************************
routine                                 039
objet                                   octet
zone                                    octet

Test validite d'une zone objet: F
*******************************
routine                                 040
objet                                   octet
zone                                    octet

Mettre:                 Mettre l'objet de la main du joueur dans une chaine
*******
routine                                 041
chaine                                  word
message ok                              word
message main vide                       word
message trop lourd                      word
message trop gros                       word

Nombre objet depose dans un lieu:
*********************************
routine                                 042
val                                     word

Finjeu:                   Fin du jeu -> gagne 
*******
routine                                 047
num des pages (fin= -1)                 octet

Difvar:                   Difference entre deux variables
*******
routine                                 048
compteur resultat                       octet
compteur demarrage                      octet
compteur a soustraire                   octet

Ctemps:                   Mets le nbre de min (deb jeu) dans une variable
*******
routine                                 049
compteur recepteur                      octet

Chasard:                  Mets une valeur au hasard entre 2 bornes
********
routine                                 050
compteur recepteur                      octet
min                                     word
max                                     word

Chanob: F                 Change un objet par un autre
*******
routine                                 051
objet depart                            octet
objet arrivee                           octet

Surimp:                   Surimpression musicale
*******
routine                                 052
parama1                                 word

Bruitage:                 Bruitage sonore
*********
routine                                 053
parama1                                 word
