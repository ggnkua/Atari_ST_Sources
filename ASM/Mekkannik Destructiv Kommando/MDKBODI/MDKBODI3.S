*
*	MFP EQUATES
*
MFP	EQU	$FFFA00
IERA	EQU	$07
IERB	EQU	$09
IPRA	EQU	$0B
ISRA	EQU	$0F
IMRA	EQU	$13
IMRB	EQU	$15
VECTOR	EQU	$17
TACR	EQU	$19
TADR	EQU	$1F
ISRVEC	EQU	$134
*
*	THE SOUND CHIP
*
SND_CHP	EQU	$FF8800 CHIP ADDRESS	
SCREG	EQU	0	CHIP REGISTER SELECT
SCDATA	EQU	2	REGISTER DATA

tinybuf1	equ $60000
tinybuf2	equ $67D00
dessin		equ $67D00+32000

*****************************************
*           THE PROGRAMME               *
*****************************************
*   SET UP STACK, MEMORY & SUPERVISOR   *
*****************************************

start	CLR.L	-(SP)		; a supprimer lors du bootage
	MOVE.W	#$20,-(SP)	
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.L	D0,STACK
   
INTRO	bsr	CONFIG
        
	lea	pic,a0
	lea	$ff8240,a1
	lea	tinybuf1,a2
	lea	tinybuf2,a3
	lea	dessin,a6
	jsr	TINY
	
	BSR	SAVEMFP		SAVE NATURAL MFP CONDITIONS
	
	move.l  #mix,PTGIT
	move.l	#zic,PTDEB
	move.l  #zic1,PTFIN
	move.l	#mix,DEBGIT
	move.l	#endmix,FINGIT
	move.b	#$FF,DEC
	move.l  #int_col,PTCOL
	move.l  #int_col,COLDEB
	move.l  #int_col+2*31,COLFIN

	MOVE.W	#$2700,SR	INTERRUPTS OFF

	BSR	SETFREQ
	BSR	ENABMFP		SET THE MFP RUNNING
	BSR	SETSND		SET UP SOUND REGISTERS
	
	MOVE.W	#$2000,SR	ENABLE LEVEL 6 INTERRUPTS

	LEA	IREPLAY,A0	SET UP THE OUTPUT CODE ADDRES
	move.l  a0,$134
        move.l  $4CE,vbl
        move.l  $452,vbl1
        move.l  #afmdk,$4CE
        move.l  #$00010001,$452	
	
*  Now wait for interrupt to do its business.
*
WAIT    cmp.b   #$39,$FFFC02
        beq     EXIT
	bra     WAIT
*
*  This tidies the system up before leaving back to BASIC.
*
vbl  dc.l 0
vbl1 dc.l 0
EXIT	cmp.l	#tab+6*12,pt_tab
	bne	EXIT
	MOVE.W	#$2700,SR	DISABLE INTS.
        move.l	vbl1,$452
        move.l	vbl,$4CE
	BSR	OLDMFP		RESTORE ORIGINAL MFP DATA
         move.w #$777,$FF8246
*
*  WE MUST NOW FLUSH ANY CHARACTERS OUT OF THE KEY BUFFER BEFORE
*  RE-ENABLING THE INTERRUPTS SINCE THE FLOOD OF DATA WILL CRASH
*  THE COMPUTER. (USERS WITH A MIDI DEVICE CONNECTED MAY NEED TO 
*  FLUSH THE MIDI ACIA IN A SIMILAR WAY).
*
FLUSH	BTST.B	#0,$FFFC00	IS A CHARACTER WAITING ?
	BEQ.S	INTSON		BR. IF NOT
	MOVE.B	$FFFC02,D0	READ CHARACTER (& IGNORE IT)
	BRA.S	FLUSH		CHECK FOR ANOTHER

INTSON	MOVE.W	#$2000,SR	RESTORE INTS FOR O.S.
	MOVE.L	STACK,-(SP)
	MOVE.W	#$20,-(SP)	RETURN TO USER MODE
	TRAP	#1
	ADDQ.L	#6,SP

        clr.w -(sp)
        trap #1


***********************************
*     THE SYSTEM SUB-ROUTINES     *
***********************************
*   PRESERVE THE MFP REGISTERS    *
***********************************

SAVEMFP	MOVE.L	#MFP,A0
	MOVE.L  #MFPMEM,A2
	MOVE.B	IERA(A0),0(A2)
	MOVE.B	IERB(A0),1(A2)
	MOVE.B	IMRA(A0),2(A2)
	MOVE.B	IMRB(A0),3(A2)
	MOVE.B	TADR(A0),4(A2)
	MOVE.B	TACR(A0),5(A2)
	MOVE.B	VECTOR(A0),6(A2)
	RTS

***********************************
*   RESTORE NATURAL RUNNING MFP   *
***********************************

OLDMFP	MOVE.L	#MFP,A0
	MOVE.L  #MFPMEM,A2
	MOVE.B	6(A2),VECTOR(A0)
	MOVE.B	5(A2),TACR(A0)
	MOVE.B	4(A2),TADR(A0)
	MOVE.B	3(A2),IMRB(A0)
	MOVE.B	2(A2),IMRA(A0)
	MOVE.B	1(A2),IERB(A0)
	MOVE.B	0(A2),IERA(A0)
	RTS

***************************************************************************
*          Positionne le timer A a la frequence de 7.5 KHz                *
***************************************************************************

SETFREQ	MOVE.L	#MFP,A1
	MOVE.B	#0,TACR(A1)		ARRET TIMER A
	MOVE.B	#5,TACR(A1)		DIVISEUR PAR 64
 	MOVE.B	#5,TADR(A1)		DONNEE DU TIMER
	RTS

***************************************************************************
*   			Mise en route du timer A			  *
***************************************************************************

ENABMFP	MOVE.L	#MFP,A0
	MOVE.B	#$20,IMRA(A0)		BIT timer A DEMASQUE
	MOVE.B	#0,IMRB(A0)		timer B,C,D MASQUES
	MOVE.B	#$20,IERA(A0)		AUTORISATION INTERRUPTION
	MOVE.B	#0,IERB(A0)		INTERRUPTION BLOQUEES
	BCLR.B	#3,VECTOR(A0)		MODE AUTOMATIQUE
	RTS

*****************************************
*    SET UP THE SOUND CHIP CHANNELS     *
*****************************************

SETSND	MOVE.L	#SND_CHP,A0
	MOVE.B	#0,SCREG(A0)	CHANNEL A
	MOVE.B	#0,SCDATA(A0)
	MOVE.B	#1,SCREG(A0)
	MOVE.B	#0,SCDATA(A0)

	MOVE.B	#2,SCREG(A0)	CHANNEL B
	MOVE.B	#0,SCDATA(A0)
	MOVE.B	#3,SCREG(A0)
	MOVE.B	#0,SCDATA(A0)

	MOVE.B	#4,SCREG(A0)	CHANNEL C
	MOVE.B	#0,SCDATA(A0)
	MOVE.B	#5,SCREG(A0)
	MOVE.B	#0,SCDATA(A0)

	MOVE.B	#7,SCREG(A0)	SET UP CHANNEL MIXING & PORT 'A' I/O
	MOVE.B	#$FF,SCDATA(A0)

	MOVE.B	#8,SCREG(A0)	SET ALL VOLUMES TO ZERO
	MOVE.B	#0,SCDATA(A0)
	MOVE.B	#9,SCREG(A0)
	MOVE.B	#0,SCDATA(A0)
	MOVE.B	#10,SCREG(A0)
	MOVE.B	#0,SCDATA(A0)
	RTS
	
***************************************************************************
**          		  Configuration ecran				 **
***************************************************************************

CONFIG	clr.w	-(sp)			BASSE RESOLUTION
	move.l	#$78000,-(sp)		ADRESSE ECRAN = $F8000
	move.l  #$78000,-(sp)
	move.w	#5,-(sp)
	trap    #14
	lea.l	12(sp),sp
	move.b	#$02,$FF820A		50 Hz
	rts


*----------------------------------
*------   VBL ----------
*---------------------------------

	
afmdk	addq.w  #1,fois
	cmp.w   #6,fois
	bne     afmdk1
	clr.w   fois
afmdk1	tst.w   fois
	bne     afmdk2
        move.l	pt_tab,a0
	adda.l	#12,a0
	cmpa.l  #endtab,a0
	bne	mdk1
	move.l  #tab,a0
mdk1	move.l	a0,pt_tab
	move.l	$00(a0),a2
	move.l	$04(a0),a1
	move.w	$08(a0),d0
	bsr	aff
afmdk2	rts


* A1 : adresse sprite
* A2 : adresse ecran
* d0 : hauteur du sprite-1
* d1 : nbre de long mot de large-1

aff	move.w  $0A(a0),d1
	movem.l a1/a2,-(sp)
aff1    move.l	(a1)+,(a2)+
	dbra	d1,aff1
	movem.l (sp)+,a1/a2
	lea	160(a1),a1
	lea	160(a2),a2
	dbra	d0,aff
	rts
	
pt_tab	dc.l	tab-12
tab	dc.l	$78000+160*93+64+8,dessin+160*158
        dc.w	11-1,6-1
        dc.l	$78000+160*92+56+8,dessin+160*143
        dc.w	15-1,10-1
        dc.l	$78000+160*88+48+8,dessin+160*121
        dc.w	22-1,14-1
        dc.l	$78000+160*83+40+8,dessin+160*88
        dc.w	33-1,18-1
        dc.l	$78000+160*77+40+8,dessin+160*44
        dc.w	44-1,18-1
        dc.l	$78000+160*77+40+8,dessin+160*0
        dc.w	44-1,18-1
        dc.l	$78000+160*77+40+8,dessin+160*44
        dc.w	44-1,18-1
        dc.l	$78000+160*83+40+8,dessin+160*88
        dc.w	33-1,18-1
        dc.l	$78000+160*88+48+8,dessin+160*121
        dc.w	22-1,14-1
        dc.l	$78000+160*91+56+8,dessin+160*143
        dc.w	15-1,10-1
endtab
fois dc.w 0

***********************************
*	BLOCK STORAGE AREA        *

*-------------------------------------------------------------------------*
*              Table des morceaux de music compactes a jouer		  *
*-------------------------------------------------------------------------*
int_col dc.w 0,0,1,2,3,4,5,6,7,6,5,4,3,2,1
	dc.w 0,0,0,0,0,0,1,3,7,3,1,0,0,0,0,0
	
mix     dc.l zic
	dc.l zic1
	
	dc.l zic
	dc.l zic1
	
	dc.l zic
        dc.l zic+1600
        
        dc.l zic
	dc.l zic+1600
        
        dc.l zic
	dc.l zic+1600
     
        dc.l zic+12536
        dc.l zic1

        dc.l zic+12536
        dc.l zic1

        dc.l zic
        dc.l zic1

        dc.l zic
        dc.l zic1
      
        dc.l zic
        dc.l zic1
endmix

**************************************
*	DEFINE PROGRAM STORAGE       *
**************************************
*
*  The RS.x command does not reserve space. It simply acts as
*  a dynamically allocated 'EQU'ate for position independance.
*  The RS.x commands must be followed by at least one suitable
*  DS.x command to allocate the necessary memory for the code.
*  Other assmblers not supporting the RS directive must assign
*  labels with suitable equates or replace the RS.x with DS.x.
*  where appropriate.
*
*  Firstly declare the Offsets..
* 
	EVEN
FREQNUM	DS.W	1	FREQUENCY SELECTED
STATUS	DS.W	1	STATUS REGISTER
MFPMEM	DS.B	8	SAVED MFP DATA
SAMPLE	DS.L	1
LENGTH	DS.L	1
FREQNCY	DS.L	1
STACK	DS.L	1
*
zic incbin a:mdkbodi\bodi.mdk
zic1
 even
pic incbin a:mdkbodi\mdk.tin
	even

*=========================================================================*
*			Include files					  *
*=========================================================================*

IREPLAY incbin	mdkbodi\repltiny.mdk

DIGIDAT equ     IREPLAY+$C0
BUFF    equ     DIGIDAT+$00
DEC	equ	DIGIDAT+$05
PTGIT	equ	DIGIDAT+$06
DEBGIT	equ	DIGIDAT+$0A
FINGIT	equ	DIGIDAT+$0E
PTDEB	equ	DIGIDAT+$12
PTFIN	equ	DIGIDAT+$16
PTCOL	equ	DIGIDAT+$1A
COLDEB	equ	DIGIDAT+$1E
COLFIN	equ	DIGIDAT+$22
TINY	equ	IREPLAY+$916

	END




