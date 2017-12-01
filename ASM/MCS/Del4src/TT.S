* Detection processeur 68030 pour la version TT
* sans utiliser la Cookie Jar
* by STILL from New Generation Crew
* si tu veux me contacter 56.32.78.03 apräs 20h30
************************************************************
* ATTENTION: Assemblage de ce code en mode processeur 68030
************************************************************
	opt x+
	
Debut
	pea	Main(pc)
	move.w	#$26,-(sp)
	trap	#14		
	addq.l	#6,sp			

* Tester d0 pour connaitre la prÇsence du processeur
* si d0 nÇgatif alors 68030
	tst.l	d0
	bmi.s	Not_68030
	nop				* il y a un MC 68030
Not_68030
	nop
	rts

Main
	move.l	a3,-(sp)		
	move.w	sr,d1
	move.l	#$ffffffff,d0
	sub.l	a0,a0			* Base Systäme 0
	move.l	a7,a2			
	or.w	#$700,sr		* plus d'interruptions
	move.l	$10(a0),a1		* routine Instruction Illegal Systäme
	lea	New_Illegal(PC),a3
	move.l	a3,$10(a0)		* nouvelle routine Illegal
	movec	cacr,d0			* lecture du cache register du 68030	

* Si tu ne posädes pas Devpac Asm version Dev
* voici le CodeOp de l'instruction 68030
* 4e7a 0002   	movec	cacr,d0
*

New_Illegal
	move.l	a1,$10(a0)		
	move.w	d1,sr			* remet l'ancien etat du STATUS
	move.l	a2,a7
	move.l	(sp)+,a3
	rts
