
	Include "Equ.S"

******* Ouvre le DOS
IDos	
	move.l	$4,a6
* Ouvre le DOS
	moveq	#0,d0
	lea	DosName(pc),a1
	jsr	OpenLib(a6)		OpenOldLibrary
	move.l	d0,a5
* Adresse Dl_Node
	move.l	Dl_Root(a5),d0
* Boucle d'exploration
DExp1	move.l	d0,a4
	lea	40(a4),a1
	move.l	4(a4),d1
	move.l	(a4),d0
	bne.s	DExp1
* Fini! 
	illegal

***********************************************************
Dl_Root	equ 	34
DosName	dc.b 	"dos.library",0

