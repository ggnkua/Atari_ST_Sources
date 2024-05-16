****** **     ****  *****  **    **
****** **    ****** ****** **    **
**     **    **  ** **  **  **  **
**     **    **  ** ** **    ****
** *** **    **  ** ****      **
**  ** **    **  ** ** **     **
****** ***** ****** **  **    **
****** *****  ****  **   **   **
 
**  ** ** **    **    ****** *****
**  ** ** **    **    ****** ******
** **  ** **    **    **     **  **
****   ** **    **    ****   ** **
** **  ** **    **    **     ****
**  ** ** ***** ***** ****** ** **
**  ** ** ***** ***** ****** **  **


; (C) KILLER D from FMC-CONNEXION
; ( Full Metal Computers Connexion )
; (C) Killer D Software 90 inc.
; -- le g‚nie, ‡a ne s'invente pas --

* BUT DE LA RUSE:
* APPELLER UNE ROUTINE QUI AFFICHE 
* CORRECTEMENT LE FULLSCREEN
*
* DESCRIPTION DE LA RUSE:
* ON PLANQUE A L'ADRESSE $130AC UN MOT-LONG
* DANS LEQUEL SE TROUVE L'ADRESSE DE L'ECRAN
* EN RAM...
*
* AVANTAGE DE LA RUSE:
* -ON PEUT AVOIR SES FULLSCREENS EN  GFA,
* OMIKRON,C, tout quoi...
* -SOURCES ALLEGEES (PAS EN TAILLE, EN LIGNES).
*
* VARIANTES DE LA RUSE:
* -NE PAS CHARGER LA ROUTINE, MAIS LA METTRE UNE BONNE
*  FOIS POUR TOUTES EN RAM ET L'EXECUTER COMME CA...
*
*			KILLER D, la f‚e de votre ST.

	SECTION TEXT

* BETE MSHRINK, POUR L'EXEC...
* Ceci est la seule partie de ce source que je n'ai pas
* programm‚ moi-meme... C'est Yoda ( v8 ) qui me l'avait
* fil‚ (le mhsrink) quand j'‚tais jeune....

	MOVE.L	4(A7),A0	
	MOVE.L	$C(A0),D0
	ADD.L	$14(A0),D0
	ADD.L	$1C(A0),D0
	ADD.L	#$800,D0
	ANDI.L	#-2,D0
	LEA.L	0(A0,D0),A7
	MOVE.L	D0,-(A7)
	MOVE.L	A0,-(A7)
	CLR.W	-(A7)
	MOVE.W	#$4A,-(A7)  *code mshrink
	TRAP 	#1
	ADD.L 	#12,A7

* On place l'adresse de l'ecran a l'adresse $130AC
* Vu que la routine est appell‚e imm‚diatement aprŠs, le LM
* ne sera pas scratch‚. Et 4 octets avant l'‚cran, il ne
* scratchera rien non plus...

* Si l'adresse ne vous plait pas, allez voir MONST.
	
	LEA PICTURE,A0
	MOVE.L A0,D0
	MOVE.L D0,$130AC 

* APPEL DE FULLROUT.ZZZ

	PEA	0    * pas de passage de paramŠtres, ‡a deconne !
	PEA	0    * charger et executer.
	PEA	NOM  * Fullrout.zzz en l'occurence 
	CLR.W	-(SP)
	MOVE	#$4B,-(SP) *code pexec
	TRAP	#1
	ADDA.L	#16,A7

	CLR.L -(SP)
	TRAP #1           * quitter


	section DATA

	EVEN
NOM:	DC.B "B:\FULLROUT.ZZZ",0
	EVEN

PICTURE INCBIN "B:\A.KID" *mettre ne nom de l'image a charger ici !!

	END
