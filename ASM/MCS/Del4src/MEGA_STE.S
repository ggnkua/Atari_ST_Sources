* Detection vitesse processeur pour MEGA STE uniquement
* et d‚tection pr‚sence du DMA sonore
* sans utiliser la Cookie Jar
* by STILL from New Generation Crew
* si tu veux me contacter 56.32.78.03 aprŠs 20h30
********************************************************

	opt x+
	
Debut
	pea	Main(pc)
	move.w	#$26,-(sp)
	trap	#14		
	addq.l	#6,sp			

* Pour d‚connecter le Cache du MEGA STE et passer … 8 Mhz, il suffit
* d'effacer le registre hardware $ffff8e21

	btst	#1,d0
	beq.s	Not_16Mhz
	nop				* la vitesse est de 16 Mhz
	btst	#0,d0
	beq.s	Not_Cache
	nop				* le cache est actif
Not_Cache
	nop
Not_16Mhz
	btst	#8,d0
	beq.s	Not_Dma
	nop				* le circuit DMA est absent
Not_Dma
	rts

Main
	move.l	a3,-(sp)		
	move.w	sr,d1
	moveq	#0,d0
	move.l	d0,a0
	move.l	a7,a2			
	or.w	#$700,sr		* plus d'interruptions
	move.l	8(a0),a1		* routine Erreur Bus SystŠme
	lea	New_Errbus(PC),a3
	move.l	a3,8(a0)		* nouvelle routine Erreur Bus
	move.b	$ffff8924.w,d0		* lecture registre Mask du MicroWire

* ce registre est utile car il contient toujours … l'initialisation
* la valeur $07ff

	lsl.w	#8,d0
	move.b	$ffff8e21.w,d0		* lecture registre cache du MEGA STE

* si une Erreur Bus survient alors, le registre d0
* n'est pas initialis‚, il contient donc la valeur 0
* … la sortie de la routine
* sinon l'octet fort du mot contient la valeur du registre DMA
* et l'octet faible du mot contient la valeur du registre Cache

New_Errbus
	move.l	a1,8(a0)		
	move.w	d1,sr			* remet l'ancien etat du STATUS
	move.l	a2,a7
	move.l	(sp)+,a3
	rts
