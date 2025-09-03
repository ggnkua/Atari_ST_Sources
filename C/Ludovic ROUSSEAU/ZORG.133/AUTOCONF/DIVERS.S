/********************************************************************
*																	*
*		lit un ou plusieurs secteurs du disque dur sans driver		*
*																	*
********************************************************************/

	XDEF hard_read

/* int hard_read( long debut, int nombre, char *buffer, int control ) */
/* les paramŠtres sont dans D0, D1, A0 et D2 dans l'ordre */

hard_read:
	move.l a0,buffer
	move.w d1,nombre
	move.l d0,debut
	move.w d2,control
	pea	read
	move.w #$26,-(a7)	;Supexec
	trap #14
	addq.l #6,a7
	rts

buffer:
	ds.l 1
nombre:
	ds.w 1
debut:
	ds.l 1
control:
	ds.w 1

/* int hard_read */
	
/********************************************************************
*																	*
*					I/O du disque dur sans driver					*
*																	*
********************************************************************/

wdc		= $ffff8604 	;FDC/HDC-Access, DMA-Sector-Count
wdl		= wdc+2			;DMA-Mode/Status
dma		= $ffff8609 	;DMA-Adress HI
flock	= $43E			;Floppy-VBL-Flag
port 	= $fffffa01 	;Parallel-Port, Bit 5=HDC-IRQ

read:			; * Lire secteurs *
	lea wdc,a0
	st flock			;M‚moriser routine Floppy-VBL

	moveq #0,d0			;efface D0
	move.w control,d0	;Num‚ro de contr“le
	lsl #5,d0			;bits 0, 1 et 2 dans 5, 6 et 7
	swap d0
	move.l #$08008a,d1	;Commande READ du controleur 0
	or.l d0,d1

	move.w #$88,2(a0)	;AccŠs HDC, A1=0
	nop
	move.l d1,(a0)		;Commande READ complŠte

	move.l buffer,-(a7)	;buffer-Adress
	bsr	setdma			;Positionner DMA 
	addq.l #4,a7

	bsr set_parameters	;Nombre et num‚ros de secteurs 
	bmi tout			;Timeout	!

	move.w #$190,2(a0)
	nop
	move.w #$90,2(a0)	;Remettre en READ
	nop
	move.w nombre,(a0)	;Envoyer Sector-Count au DMA 
	nop
	move.w #$8a,2(a0)
	nop
	move.l #0,(a0)		;Commencer transfert
	bsr	waitl			;Attendre max. 3 secondes
	bmi	tout			;Timeout !
	move.w #$8a,2(a0)
	bra	exec

write:				; * Ecrire secteurs *
	lea	wdc,a0
	st flock			;M‚moriser Floppy-VBL 
	move.l buffer,-(a7)
	bsr setdma			;Positionner Adresse DMA
	addq.l #4,a7

	move.w control,d0	;Num‚ro de contr“le
	lsl #5,d0			;bits 0, 1 et 2 dans 5, 6 et 7
	swap d0
	move.l #$0a008a,d1	;Commande WRITE du controleur 0
	or.l d0,d1

	move.w #$88,2(a0)	;AccŠs HDC, A1=0
	nop
	move.l d1,(a0);Commande WRITE complŠte

	moveq #0,d0

	bsr	set_parameters	;Nombre et num‚ros de secteurs
	bmi	tout			;Timeout !

	move.w #$90,2(a0)
	nop
	move.w #$190,2(a0)	;Mettre sur WRITE
	nop
	move.w nombre,(a0)	;Envoyer Sector-Count au DMA 
	nop
	move.w #$18a,2(a0)
	nop
	move.l #$100,(a0)	;Commencer transfert
	bsr waitl			;Attendre max. 3 secondes
	bmi tout			;Timeout !
	move.w #$18a,2(a0)

exec:
	nop
	move.l (a0),d6		;Recup‚rer HDC/DMA-Status dans D6 
	and.l #$ff00ff,d6	;HI=HDC, LO=DMA
tout:
	move.w #$80,2(a0)	;Mettre sur FDC 
	nop
	move.l (a0),d7		;R‚cup‚rer Completion-Byte 
	and.l #$ff00ff,d7	;HI=HDC (0), LO=DMA
	clr flock			;Lib‚rer routine Floppy-VBL
	rts					;fini

set_parameters:		;D‚finir nombre de secteurs et Sector-Count 
	move.w #$8a,2(a0)
	bsr wait			;Attendre que HDC-OK
	bmi setpx			;Timeout !

	clr.w d0
	move.b debut+1,d0	;Sectornr. HI
	bsr send_byte
	bmi setpx

	move.b debut+2,d0	;Sectornr. MID
	bsr send_byte
	bmi setpx

	move.b debut+3,d0	;Sectornr. LO
	bsr send_byte
	bmi setpx

	move.w nombre,d0	;Nombre de secteurs
	bsr send_byte
setpx:
	rts				;fin

send_byte:		; * Envoyer 1 octet au HDC *
	swap d0
	move.w #$8a,d0
	move.l d0,(a0)
	bra wait

waitl:		;Attendre OK max. 3 secondes
	move.l #450000,count
	bra wait1
wait:		;Attendre OK max. 100 ms 
	move.l #15000,count
wait1:
	subq.l #1,count
	bmi timeout
	move.b port,d0
	and.b #$20,d0	;HDC-Interrupt ?
	bne wait1		;non
	moveq #0,d0		;oui => OK
	rts

timeout:
	moveq #-1,d0	;Timeout 
	rts

setdma:		; * Positionner adresse DMA *
	move.b 7(a7),dma+4	;LO
	move.b 6(a7),dma+2	;MID
	move.b 5(a7),dma	;HI
	rts

even
count:
	dc.l 1		;Timeout-Counter
