********************************************************
*           EXTRAIT DE LA BIBLIOTHEQUE TUBE GEM        *
*                  FICHIER "ACC_BSS.S"                 *
*              VERSION 3.00 (22 mars 1991)             *
********************************************************
	SECTION	BSS
* Variables pour le protocole GEM pour un accessoire.
X_TUBE:	DS.W	1     coordonn‚es pour le
Y_TUBE:	DS.W	1     formulaire de choix
W_TUBE:	DS.W	1     du destinataire
H_TUBE:	DS.W	1
DIAL_TUBE:	DS.W	1
MONO_FLAG:	DS.W	1     pour indiquer si je suis seul compatible
ADR_FORM:	DS.L	1     adr du formulaire (pas assez de registres)
* Tableau et pointeur utilis‚s dans la routine CHOICE
TAB_OKAPID:	DS.W	10    stocker les ap_id compatibles
PTN_OKAPID:	DS.L	1     ptn sur ce tableau 
* Tableau pour les APP_ID. Un identificateur sur 4 octets
* (PROT), un word indiquant le nombre d'APP_ID que l'on
* peut mettre dans ce tableau (dans nos exemples 10), l'emplacement
* pour ces APP_ID, puis celui pour le flag de fin ($FFFF) soit 
* ici 14 mots.
TAB_TUBE:	DS.W	14   stockage prot_appid
JY_SUIS:   DS.W       1
