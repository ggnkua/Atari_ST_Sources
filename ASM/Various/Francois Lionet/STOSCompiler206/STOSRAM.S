
*********************************************************************
*
*		STOS RAM DISK / AVEC AUTO COPY
*
*********************************************************************

Start:          bra.w Debut

DiskLong:       dc.l 164,(164+9)*1024
Path:           dc.b 0,0,0
Path1:		ds.b 17


hdv_bpb         equ $472
hdv_rw          equ $476
hdv_med         equ $47e
drvbits         equ $4c2
membot          equ $432
gemdos          equ $1
xbios           equ 14
super           equ 38

******* Debut du programme
Debut:  

*       passe en superviseur
        clr.l -(sp)
        move.w #$20,-(sp)
        trap #1
        addq.l #6,sp

*       Installe le RAM-DISK
        move.l DiskLong(pc),d7          ;Nombre de K
        move.l #mstart,d6
        add.l DiskLong+4(pc),d6         ;Longueur reelle
        move.l $42e,d0                  ;Assez de RAM?
        sub.l #$10000,d0
        cmp.l d0,d6
        bhi PaRam
        
*       Va installer
        bsr Installe
	move.w DrvNumb(pc),d0
	add.b #"A",d0
	move.b d0,Ndrive
	lea Mes1(pc),a0
	bsr Print

*       Va copier les fichiers
        bsr AutoCopy

*	Boucle d'attente 1 sec
	moveq #60,d7
Att	move.w #37,-(sp)
	trap #14
	addq.l #2,sp
	dbra d7,Att

*       Fin / Garde la memoire
        clr -(sp)                       *keep process
	sub.l #Start,d6
	sub.l #$100,d6
        move.l d6,-(sp)
        move #$31,-(sp)
        trap #1

*       Pas de ram disk: revient
PaRam   clr.w -(sp)
        trap #1

Mes1:	dc.b 13,10
	dc.b "------------------------------------",13,10
	dc.b "  Stos ram-disk created as drive "
ndrive:	dc.b 0,13,10
	dc.b "------------------------------------",13,10,10,0
	even
 
***********************< COPIE AUTOMATIQUE DU DOSSIER >*******************
AutoCopy:

*       Y a t il un dossier a copier?
        tst.b Path
        beq FinCopy

*       SET DTA
        bsr SetDta

*       Poke le numero du RAM DISK
        move.w drvnumb(pc),d0
        add.b #"A",d0
        move.b d0,PathD

*       Trouve la fin du Path
        lea Path(pc),a0
Cop1:   tst.b (a0)+
        bne.s Cop1
        lea -1(a0),a6           ;Adresse de FIN

*	Cree le dossier dans le RAM-DISK
	lea CopT0(pc),a0
	bsr Print
	lea Path1(pc),a0
	lea PathD1(pc),a1
Cop2:	move.b (a0)+,(a1)+
	bne.s Cop2
	lea -1(a1),a5
	lea PathD(pc),a0
	bsr Print
	pea PathD(pc)
      	move.w #$39,-(sp)
	trap #1
	addq.l #6,sp
	tst.w d0
	bne FinCopy
	lea CopT3(pc),a0
	bsr Print
	move.b #"\",(a5)+

*       Poke *.* ---> SFIRST
        move.b #"\",(a6)+
        move.b #"*",(a6)
        move.b #".",1(a6)
	move.b #"*",2(a6)
        clr.b 3(a6)
        lea Path(pc),a0
        bsr SFirst
        bra DoitCop

*       Recopie le nom
Copie:  lea Dta+30(pc),a0
        move.l a6,a1
        move.l a5,a2
        lea CopT2(pc),a3
B1:     move.b (a0)+,d0
        move.b d0,(a1)+
        move.b d0,(a2)+
        move.b d0,(a3)+
        bne.s B1

*       Affiche la copie
        lea CopT1(pc),a0
        bsr Print
        lea CopT2(pc),a0
        bsr Print

*       Charge le fichier
        lea Path(pc),a0         ;Ouvre
        bsr Open
        bsr Load                ;Charge (Ad ---> Longueur)
        bsr Close               ;Ferme

*       Sauve le fichier
        lea PathD(pc),a0
        bsr Create
        bsr Save
        bsr Close

*       Done
        lea CopT3(pc),a0
        bsr Print

*       Un Autre?
ReEss   bsr SNext
DoitCop bne.s FinCopy
        move.b dta+21(pc),d0
        beq.s Copie
        cmp.b #1,d0 
        beq.s Copie
	bra.s ReEss

*       Fini! 
FinCopy rts
       
*       Erreur disque!
Erreur: addq.l #4,sp
        bsr Close
	lea MErr(pc),a0
	bsr Print
        rts

*****************************************************************

; Print
Print:  move.l a0,-(sp)
        move.w #$09,-(sp)
        trap #1
        addq.l #6,sp
        rts

; Set Dta
SetDta: pea dta(pc)
        move.w #$1a,-(sp)
        trap #1     
        addq.l #6,sp
        rts

; SFirst
SFirst: clr.w -(sp)
        move.l a0,-(sp)
        move.w #$4e,-(sp)             ;SFIRST
        trap #1
        addq.l #8,sp
        tst.w d0
        rts

; SNext
SNext:  move.w #$4f,-(sp)
        trap #1
        addq.w #2,sp
        tst.w d0
        rts

; Create
Create: clr.w -(sp)
        move.l a0,-(sp)
        move.w #$3c,-(sp)
        trap #1   
        addq.l #8,sp
        move.w d0,Handle
        bmi Erreur
        rts

; Open
Open:   clr.w -(sp)
        move.l a0,-(sp)
        move.w #$3d,-(sp)
        trap #1                       ;OPEN
        addq.l #8,sp
        move.w d0,Handle
        bmi Erreur
        rts

; Load
Load:   move.l Longueur(pc),d0              ;Verifie la longueur
        add.l d6,d0
        move.l $42e,d1
        sub.l #$10000,d1
        cmp.l d1,d0
        bcc erreur
        move.l d6,-(sp)                     ;adresse de chargement
        move.l Longueur(pc),-(sp)           ;taille du fichier
        move.w Handle(pc),-(sp)
        move.w #$3f,-(sp)
        trap #1
        lea 12(sp),sp
        cmp.l Longueur(pc),d0
        bne Erreur
        rts
        
; Save
Save:   move.l d6,-(sp)               ;adresse de debut
        move.l Longueur(pc),-(sp)         ;taille du fichier
        move.w Handle(pc),-(sp)
        move.w #$40,-(sp)
        trap #1
        lea 12(sp),sp
        cmp.l Longueur(pc),d0
        bne Erreur
        rts
 
; Close
Close:  move.w Handle(pc),-(sp)
        move.w #$3e,-(sp)
        trap #1                       ;close
        addq.l #4,sp
        rts

Dta:            ds.b 48
Longueur:       equ Dta+26
Handle:         dc.w 0
PathD:          dc.b "C:\"
PathD1:         ds.b 16
		ds.b 16
CopT0:	      dc.b "Creating folder ",0
CopT1:          dc.b "Copying ",0
CopT2:          ds.b 16
CopT3:          dc.b " ...done",13,10,0
Merr:	      dc.b 13,10,13,10,7,7,7,7,7,7
	      dc.b ">>>>>>>> DISC ERROR <<<<<<<<",13,10,0
	even

***********************< KOSTA'S RAM DISK >*******************************
Installe:
        move.l hdv_bpb,bpbsav
        move.l #bpb,hdv_bpb

        move.l hdv_rw,rwsav
        move.l #rw,hdv_rw

        move.l hdv_med,medsav
        move.l #med,hdv_med

        move.l #0,d1
        lea mstart(pc),a0
        move #2303,d0
iloop1  move.l d1,(a0)+
        dbra d0,iloop1
        lea  mstart+11,a0
        lea boottab(pc),a1
        move #tabend-boottab-1,d0
bloop   move.b (a1)+,(a0)+
        dbra d0,bloop
        move d7,numcl
        lsl #1,d7
        add #18,d7
        lea mstart+19(pc),a0
        move.b d7,(a0)+
        lsl #8,d7
        move.b d7,(a0)
        move.l drvbits,d0
        move.w #-1,d1
getd:   addq.w #1,d1
        btst d1,d0
        bne.s getd
        bset d1,d0
        move.l d0,drvbits
        move.w d1,drvnumb
        rts

******* Routines RAM DISK
bpb     move.w drvnumb(pc),d0
        cmp.w 4(sp),d0
        beq.s bpb1
        move.l bpbsav(pc),a0
        jmp (a0)
bpb1    move.l #bpbtab,d0
        rts
rw      move.w drvnumb(pc),d0
        cmp.w 14(sp),d0
        beq.s rw1
        move.l rwsav(pc),a0
        jmp (a0)
rw1     move 12(sp),d0
        ext.l d0
        lsl.l #8,d0
        lsl.l #1,d0
        move.l 6(sp),a0
        move 10(sp),d1
        subq #1,d1
        lea mstart(pc),a1
        add.l d0,a1
        move 4(sp),d0
        btst #0,d0
        beq.s rloop0
        exg a0,a1
rloop0  move #511,d0
rloop   move.b (a1)+,(a0)+
        dbra d0,rloop
        dbra d1,rloop0
        moveq #0,d0
        rts
med     move.w drvnumb(pc),d0
        cmp.w 4(sp),d0
        beq.s med1
        move.l medsav(pc),a0
        jmp (a0)
med1    moveq #0,d0
        rts

drvnumb dc.w 0
ramtab1 dc.l 64,84,104,124,144,164
ramtab2 dc.l 73000,93000,113000,133000,153000,173000
bpbtab:
recsiz  dc.w $200
clsiz   dc.w $2
clsizb  dc.w $400
rdlen   dc.w 7
fsiz    dc.w 5
fatrec  dc.w 6
datrec  dc.w 18
numcl   ds.w 1
flags   dc.w 0,0,0,0,0,0,0,0

boottab:
        dc.b 0,2
        dc.b 2
        dc.b 1,0
        dc.b 2
        dc.b 112,0
        ds.b 2
        dc.b 0
        dc.b 5,0
        dc.b 9,0
        dc.b 1,0
        dc.b 0
tabend  equ *
bpbsav  ds.l 1
rwsav   ds.l 1
medsav  ds.l 1
mstart  equ *

************************************************************************


