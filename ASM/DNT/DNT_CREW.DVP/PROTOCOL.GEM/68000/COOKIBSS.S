*--------------------------------------------------------------------------*
* Fichier "COOKIBSS.S"
* Section BSS pour l'utilisation de la routine COOKIE_JAR
* Cette section est pr‚vue pour placer une boite … gateaux
* de 16 emplacements. Pour pr‚voir plus gros il faut penser
* … modifier aussi la routine COOKIE_JAR
OLD_RESETV:	DS.L	1
OLD_RESETR:	DS.L	1
COOKIE1:	DS.L	1
COOKIE2:	DS.L	1
COOKIE3:	DS.L	1
COOKIE4:	DS.W	1
NEW_JAR:	DS.L	32
*--------------------------------------------------------------------------*
