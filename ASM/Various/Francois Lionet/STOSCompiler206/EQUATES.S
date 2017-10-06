
*************************************************************************
* EQUIVALENTS DES VARIABLES SYSTEME DIVERSES

;TABLE DES DIX FICHIERS OUVERTS SUR LA DISQUETTE
fha:      equ 2     ;numero de handle.w
fhl:      equ 4     ;taille du fichier.l
fht:      equ 8     ;taille totale du champ.w
fhc:      equ 10    ;taille des champs.w
fhs:      equ 42    ;adresse des variables des champs.l
tfiche:   equ 106   ;106 octets par fichier

; Variables normales
vecteurs:       equ 0                   ;blk.l 8,0
anc400:         equ 8*4                 ;dc.l 0
runonly:        equ anc400+4            ;dc.w 0     
ronom:          equ runonly+2           ;dc.l 0
roold:          equ ronom+4             ;dc.l 0 
ada:            equ roold+4             ;dc.l 0
adm:            equ ada+4               ;dc.l 0 
adk:            equ adm+4               ;dc.l 0 
ads:            equ adk+4               ;dc.l 0
adc:            equ ads+4               ;dc.l 0 
runflg:         equ adc+4               ;dc.w 0
langue:         equ runflg+2            ;dc.w 0
foncon:         equ langue+2            ;dc.w 0
fonction:       equ foncon+2            ;dc.w 0
ins:            equ fonction+2          ;dc.w 0
oldi:           equ ins+2               ;dc.w 0
undoflg:        equ oldi+2              ;dc.w 0
remflg:         equ undoflg+2           ;dc.w 0
interflg:       equ remflg+2            ;dc.w 0
ancdb8:         equ interflg+2          ;dc.w 0
bip:            equ ancdb8+2            ;dc.w 0
waitcpt:        equ bip+2               ;dc.l 0
timer:          equ waitcpt+4           ;dc.l 0
coldflg:        equ timer+4             ;dc.w 0
shift:          equ coldflg+2           ;dc.w 0
ipflg:          equ shift+2             ;dc.w 0
lbkflg:         equ ipflg+2            ;dc.w 0
handle:         equ lbkflg+2            ;dc.w 0
upperflg:       equ handle+2            ;dc.w 0
unewpos:        equ upperflg+2          ;dc.l 0
unewbank:       equ unewpos+4           ;blk.l 16,0 
unewhi:         equ 16*4+unewbank       ;dc.l 0
searchd:        equ unewhi+4            ;dc.w 0
searchf:        equ searchd+2           ;dc.w 0
mousflg:        equ searchf+2           ;dc.w 0 
inputflg:       equ mousflg+2           ;dc.w 0
inputype:       equ inputflg+2          ;dc.w 0
orinput:        equ inputype+2          ;dc.w 0
oradinp:        equ orinput+2           ;dc.l 0
flginp:         equ oradinp+4           ;dc.w 0
chrinp:         equ flginp+2            ;dc.w 0
autoflg:        equ chrinp+2            ;dc.w 0
autostep:       equ autoflg+2           ;dc.w 0
lastline:       equ autostep+2          ;dc.w 0
paranth:        equ lastline+2          ;dc.w 0
gotovar:        equ paranth+2           ;dc.w 0

; Variable du print, un peu modifiees...
printflg:       equ gotovar+2
usingflg:       equ printflg
impflg:         equ printflg+1
printype:       equ printflg+2
printpos:       equ printflg+4
printfile:      equ printflg+8

*printflg:       equ gotovar+2           ;dc.w 0
*printpos:       equ printflg+2          ;dc.l 0
*printype:       equ printpos+4          ;dc.w 0
*printfile:      equ printype+2          ;dc.l 0
*usingflg:       equ printfile+4         ;dc.w 0

sortflg:        equ printflg+2+4+2+4+2  ;dc.w 0
*tokvar:         equ sortflg+2           ;dc.l 0
*varlong:        equ tokvar+4            ;dc.w 0
*tokch:          equ varlong+2           ;dc.l 0
*chlong:         equ tokch+4             ;dc.w 0
*nboucle:        equ chlong+2            ;dc.w 0
*tstnbcle:       equ nboucle+2           ;dc.w 0
*posbcle:        equ tstnbcle+2          ;dc.l 0
*tstbcle:        equ posbcle+4           ;dc.l 0
*posgsb:         equ tstbcle+4           ;dc.l 0
*cptnext:        equ posgsb+4            ;dc.w 0
*oldfind:        equ cptnext+2           ;dc.l 0
*nbdim:          equ oldfind+4           ;dc.w 0
scankey:        equ sortflg+2+4+2+4+2+2+2+4+4+4+2+4+2     ;dc.w 0
datastart:      equ scankey+2           ;dc.l 0
dataline:       equ datastart+4         ;dc.l 0
datad:          equ dataline+4          ;dc.l 0
folflg:         equ datad+4             ;dc.w 0
erroron:        equ folflg+2            ;dc.w 0
onerrline:      equ erroron+2           ;dc.l 0
errornb:        equ onerrline+4         ;dc.w 0
errorline:      equ errornb+2           ;dc.l 0
errorchr:       equ errorline+4         ;dc.l 0
contflg:        equ errorchr+4          ;dc.w 0
contchr:        equ contflg+2           ;dc.l 0
contline:       equ contchr+4           ;dc.l 0
brkinhib:       equ contline+4          ;dc.w 0
foldeb:         equ brkinhib+2          ;dc.w 0
folend:         equ foldeb+2            ;dc.w 0
ancrnd1:        equ folend+2            ;dc.w 0
ancrnd2:        equ ancrnd1+2           ;dc.l 0
ancrnd3:        equ ancrnd2+4           ;dc.l 0
fixflg:         equ ancrnd3+4           ;dc.w 0
expflg:         equ fixflg+2            ;dc.w 0
callreg:        equ expflg+2            ;blk.l 8+7,0
trahpile:       equ 15*4+callreg        ;dc.l 0
cursflg:        equ trahpile+4          ;dc.l 0 
dirsize:        equ cursflg+4           ;dc.l 0
;-----------------------------Graphique
mode:           equ dirsize+4           ;dc.w 0
deflog:         equ mode+2              ;dc.l 0
defback:        equ deflog+4            ;dc.l 0
adback:         equ defback+4           ;dc.l 0
adphysic:       equ adback+4            ;dc.l 0 
adlogic:        equ adphysic+4          ;dc.l 0
ambia:          equ adlogic+4           ;dc.w 0
laad:           equ ambia+2             ;dc.l 0
laintin:        equ laad+4              ;dc.l 0
laptsin:        equ laintin+4           ;dc.l 0
xmax:           equ laptsin+4           ;dc.l 0
ymax:           equ xmax+4              ;dc.l 0
colmax:         equ ymax+4              ;dc.l 0
ink:            equ colmax+4            ;dc.w 0
inkvdi:         equ ink+2               ;dc.w 0
plan0:          equ inkvdi+2            ;dc.w 0,0,0,0
autoback:       equ plan0+8             ;dc.w 0
xgraph:         equ autoback+2          ;dc.w 0
ygraph:         equ xgraph+2            ;dc.w 0
grwrite:        equ ygraph+2            ;dc.w 0
grh:            equ grwrite+2           ;dc.w 0
actualise:      equ grh+2               ;dc.w 0
valpen:         equ actualise+2         ;dc.w 0
valpaper:       equ valpen+2            ;dc.w 0
nbjeux:         equ valpaper+2          ;dc.w 0
defmod:         equ nbjeux+2            ;dc.w 0
;-----------------------------sons
volumes:        equ defmod+2            ;dc.l 0
        even
;-----------------------------Gestionneur de memoire
;programme edite
dbufprg:        equ volumes+4           ;dc.l 0
lbufprg:        equ dbufprg+4           ;dc.l 0
program:        equ lbufprg+4           ;dc.w 0
adatabank:      equ program+2           ;dc.l 0
adataprg:       equ adatabank+4         ;dc.l 0
dsource:        equ adataprg+4          ;dc.l 0
fsource:        equ dsource+4           ;dc.l 0
hichaine:       equ fsource+4           ;dc.l 0
lowvar:         equ hichaine+4          ;dc.l 0
himem:          equ lowvar+4            ;dc.l 0
topmem:         equ himem+4             ;dc.l 0
acldflg:        equ topmem+4            ;dc.w 0
posacc:         equ acldflg+2           ;dc.w 0
accflg:         equ posacc+2            ;dc.w 0
reactive:       equ accflg+2            ;dc.w 0
avanthelp:      equ reactive+2          ;dc.w 0
;autres PROGRAMMES: 16 en tout
dataprg:        equ avanthelp+2         ;blk.l 16*2,0
fbufprg:        equ 16*2*4+dataprg      ;dc.l 0
;BANKS de memoire dans les programmes: 16/PROGRAMMES
databank:       equ fbufprg+4           ;blk.l 16*16,0
;Multifenetrage
fenetre:        equ 16*16*4+databank    ;dc.w 0
typecran:       equ fenetre+2           ;dc.w 0
;table de repartition des programmes dans les fenetres
reparti:        equ typecran+2          ;blk.l 16,0
;-----------------------------MENUS DEROULANTS
mnd:            equ 16*4+reparti        ;0 menuflg
                                        ;2 oldmnflg
                                        ;4 menuchg
                                        ;6 menukey
                                        ;8 menuhaut
                                        ;10 menuline
                                        ;12 menubar
                                        ;14 menubank
                                        ;16 menutemp
                                        ;18 menuchoix
                                        ;20 menusschx
                                        ;22 menutx
                                        ;24 menunb
                                        ;26 menutour
                                        ;28 menupen
                                        ;30 menupaper
                                        ;32 menuold
                                        ;34 menutext  
                                        ;34+32=66 menumous
                                        ;34+32+32=98 onmnflg
                                        ;100 onmnjmp
                                        ;100+40=140 Taille totale MND
;-----------------------------FILE SELECTOR
fsd:            equ mnd+140             ;DATAS FILE SELECTOR
                                        ;+0: fsnb
                                        ;+2: 
                                        ;+4
                                        ;+6
                                        ;+8
                                        ;+10
                                        ;+14
                                        ;+16
                                        ;+18
                                        ;+20
                                        ;+22
                                        ;+24
                                        ;+26
;fsname:   equ buffer+256      ;nom recherche
;fsbuff:   equ buffer+256+32
;-----------------------------EXTENSIONS BASIC
adext:          equ fsd+28              ;dc.l 0
datext:         equ adext+4             ;blk.l 26*2,0
extchr:         equ 26*2*4+datext       ;dc.l 0
;-----------------------------PILE DES BOUCLES
;bufbcle:        equ 38*11+4+extchr
;-----------------------------PILE DES GOSUBS
;bufgsb:         equ 14*15+bufbcle

**************************************************************************
*       Adresses disponibles pour stocker des donnees compilees
*       Dans le debut de la pile des boucles
Libre:          equ extchr+4+208        ;Sauter le BUG du basic!            

Debut:          equ Libre               ;Adresse debut du programme             
SPile:          equ Libre+4             ;Sauvegarde de la pile
Table:          equ Libre+8             ;Adresse de la table des adresses
Buffer:         equ Libre+12            ;Adresse du buffer
Error:          equ Libre+16            ;Traitement des erreurs
Defloat:        equ Libre+20            ;Buffer ecriture float
LoChaine:       equ Libre+24            ;Debut du buffer des chaines
ChVide:         equ Libre+28            ;Adresse de la chaine vide
BufPar:         equ Libre+32            ;Buffer des parametres
LiAd:           equ Libre+36            ;Table #LIGNE----> ADRESSE
LowPile:        equ Libre+40            ;Niveau ZERO de la pile
AdStr:          equ Libre+44            ;Table Ad-Strings

intin:          equ libre+48
contrl:         equ libre+52
ptsin:          equ libre+56
vdipb:          equ libre+60
fichiers:       equ libre+64
dta:            equ libre+68
buffonc:        equ libre+72
deffonc:        equ libre+76
foncnom:        equ libre+80
Work:           equ libre+84
Dfst:           equ libre+88
Amb:            equ libre+92
name1:          equ libre+96
name2:          equ libre+100
fsbuff:         equ libre+104
fsname:         equ libre+108
AdMenu:         equ libre+112
FlaGem:         equ libre+116
OEnd:           equ libre+120
FloLa:          equ Libre+124
FlgRun:         equ Libre+126
ZeroFl:		equ Libre+128
SVect:          equ libre+128+8

