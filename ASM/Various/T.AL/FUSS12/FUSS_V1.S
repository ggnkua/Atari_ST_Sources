
;	universal F030 screensaver 
;	version 1
;	T.AL 93


	output .ttp
	text

	move.l 4(sp),a3		;base page pointer
	move.l $c(a3),d0	;p_tlen
	add.l $14(a3),d0	;+p_dlen
	add.l $1c(a3),d0	;+p_blen
	add.l #256,d0
	move.l d0,d3		;sauve taille prog

	pea prompt
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp

	clr.l -(sp)		;super
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	move.l d0,-(sp)		;sauve oldstack


;-----------------------------------------------
;teste la presence d'une option sur la ligne de commande
 
	move.b $80(a3),d0
	beq.s nocmdline
	
;recupere le path sur la ligne de commande et le termine par un nul

	lea $81(a3),a3
	clr.b (a3,d0.w)		;nul … la fin du path
	move.l a3,FileName

;teste si FUSS est deja installe

	move.l $502.w,a4
	lea sign-dump(a4),a1	;a1.l adresse de la signature
	cmp.l #'FUSS',(a1)
	bne install

;deja installe, on donne le path … la version deja installee et on quitte	

	pea oldfname		; affiche nom precedent
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	
	move.l FileName-dump(a4),-(sp)
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	
	pea cr
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp

	lea defaultfile-dump(a4),a1
	move.l a1,FileName-dump(a1)
	
filencpy	move.b (a3)+,(a1)+
	bne.s filencpy
	
;affiche la situation
	pea newfname		; nouveau nom
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	
	move.l FileName,-(sp)
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	
	bra pterm
		
;-----------------------------------------------
;pas de ligne de commande

nocmdline	lea defaultfile,a0
	move.l a0,FileName
	
;teste si FUSS est deja installe

	move.l $502.w,a0
	lea sign-dump(a0),a1	;a1.l adresse de la signature
	cmp.l #'FUSS',(a1)
	bne.s install

;si oui on restaure l'ancien vecteur et on quitte

	move.l olddump-dump(a0),$502.w	;restaure ancien vecteur dump
	
;affiche la situation

	pea wipe
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	
	bra.s pterm

;-----------------------------------------------
;on installe FUSS
				
install	pea waiting
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp 

	move.l FileName,-(sp)
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp

	pea cr
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp

	move.l $502.w,olddump

	lea dump,a0		;dump vector
	move.l a0,$502.w

	move.w #$20,-(sp)	;user
	trap #1
	addq.l #6,sp

	move.w #1,-(sp)
	trap #1
	addq.l #2,sp

	clr.w -(sp)		;keep process
	move.l d3,-(sp)
	move.w #$31,-(sp)
	trap #1


;-----------------------------------------------
pterm	pea cr
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp

	move.w #1,-(sp)
	trap #1
	addq.l #2,sp

	move.w #$20,-(sp)	;user
	trap #1
	addq.l #6,sp
	
	clr.w -(sp)
	trap #1


;-----------------------------------------------
dump	pea screensave
	move.w #$26,-(sp)
	trap #14
	addq.w #6,sp
	
	rts
	
;-----------------------------------------------
;acces variables Aline
MAX_X	equ -12
MAX_Y	equ -4

screensave	movem.l d0-a6,-(sp)

;recupere l'adresse, le mode et la taille de l'ecran

	move.w #2,-(sp)		;Physbase
	trap #14
	addq.l #2,sp
	move.l d0,a3		;a3.l screenbase

	move.w #-1,-(sp)
	move.w #88,-(sp)	;VsetMode(-1)
	trap #14
	addq.l #4,sp
	move.w d0,d3		;d3.w screenmode

	move.w d0,-(sp)		;mode courant
	move.w #91,-(sp)	;Vgetsize
	trap #14
	addq.l #4,sp
	move.l d0,d4		;d4.l screensize

;sauve la DTA du programme interrompu

	move.w #$2f,-(sp)
	trap #1
	addq.l #2,sp
	
	move.l d0,savDTA
	
;sauve le lecteur et le path courant

	move.w #$19,-(sp)
	trap #1
	addq.l #2,sp
	
	move.b d0,savPath
	move.b #':',savPath+1
	
	clr.w -(sp)
	pea savPath+2
	move.w #$47,-(sp)
	trap #1
	addq.l #8,sp
	
;installe DTA pour la sauvegarde

	pea DTA
	move.w #$1a,-(sp)
	trap #1
	addq.l #6,sp
	
;ouvre le fichier F30 et sauve le handle

	clr.w -(sp)
	move.l FileName,-(sp)
	move.w #$3c,-(sp)
	trap #1
	addq.l #8,sp

	moveq.l #1,d1 
	move.w d0,d5		;d5.w handle
	bmi diskerror
	

	dc.w $a000
	move.l d0,a2		;a2.l: Aline base
	
;determine la structure du fichier, truecolor ou bitmap
; screenmode.bit2 on -> truecolor mode, off -> bitmap mode

	btst #2,d3
	bne.s savescrmode

;mode bitmap, determine l'adresse et la taille de la palette
; screenmode.bit7 on -> ST comptatible mode (palette $8240.w)
;                 off -> Falcon mode (palette $9800.w)

	btst #7,d3	
	beq.s F30pal
	
	lea $ffff8240.w,a0	;adresse palette
	move.w #32,d0		;taille
	bra.s savepalette	
	
F30pal	lea $ffff9800.w,a0
	move.w #256*4,d0

;copie screenmode, max_x, max_y, et la palette dans un buffer
savepalette	lea savbuf,a1
	moveq.l #0,d1
	move.w d0,d1		;bytecount pour la sauvegarde
	addq.w #6,d1	;on sauve aussi mode, max_x, max_y
	
	lsr.w #2,d0
	subq.w #1,d0
	
	move.w d3,(a1)+		;sauve screenmode
	move.w MAX_X(a2),(a1)+
	move.w MAX_Y(a2),(a1)+

palcpy	move.l (a0)+,(a1)+	;sauve la palette
	dbf d0,palcpy
	bra.s savebuf
	
;sauve screenmode en truecolor, max_x, max_y
savescrmode	lea savbuf,a1
	move.w d3,(a1)+
	move.w MAX_X(a2),(a1)+
	move.w MAX_Y(a2),(a1)+
	moveq.l #6,d1
	
;sauve le buffer sur disque

savebuf	pea savbuf
	move.l d1,-(sp)
	move.w d5,-(sp)
	move.w #$40,-(sp)
	trap #1
	add.l #12,sp

	moveq.l #2,d1 
	tst.w d0
	bmi diskerror
	
;sauve l'ecran sur disque

saverawdata	pea (a3)
	move.l d4,-(sp)
	move.w d5,-(sp)
	move.w #$40,-(sp)
	trap #1
	add.l #12,sp
	
	moveq.l #3,d1 
	cmp.l d4,d0
	blt diskerror
	
;ferme le fichier

	move.w d5,-(sp)
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp
	
	moveq.l #4,d1 
	tst.w d0
	bmi diskerror

;affiche le nom de sauvegarde
	pea prompt
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp

	pea work
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp

	move.l FileName,-(sp)
	move.w #9,-(sp)
	trap #1
	addq.w #6,sp

	pea cr
	move.w #9,-(sp)
	trap #1
	addq.w #6,sp
	
;restaure DTA et path
restit	move.l savDTA,-(sp)
	move.w #$1a,-(sp)
	trap #1
	addq.l #6,sp
	
	moveq #0,d0
	move.b savPath,d0
	move.w d0,-(sp)		;setdrive
	move.w #14,-(sp)
	trap #1
	addq.w #4,sp 
	
	pea savPath		;setpath
	move.w #$3b,-(sp)
	trap #1
	addq.l #6,sp

;nouveau nom de sauvegarde ?
	pea another
	move.w #9,-(sp)
	trap #1
	addq.w #6,sp
	
	move.b #80,inputfname
	pea inputfname
	move.w #$a,-(sp)
	trap #1
	addq.w #6,sp

	lea inputfname+2,a0
	move.b -1(a0),d0
	beq.s endsave		;pas de nouveau nom
	
	move.l a0,FileName
	clr.b (a0,d0.w)		;null terminated
	
	pea newfname
	move.w #9,-(sp)
	trap #1
	addq.w #6,sp

	move.l FileName,-(sp)
	move.w #9,-(sp)
	trap #1
	addq.w #6,sp
	
	pea cr
	move.w #9,-(sp)
	trap #1
	addq.w #6,sp
		 	
endsave	movem.l (sp)+,d0-a6
	rts

diskerror	add.b d1,errnb
	
	pea fataldsk
	move.w #9,-(sp)
	trap #1
	addq.w #6,sp
	
	pea prompt
	move.w #9,-(sp)
	trap #1
	addq.w #6,sp
	
	pea fataldsk
	move.w #9,-(sp)
	trap #1
	addq.w #6,sp

	pea dskerr
	move.w #9,-(sp)
	trap #1
	addq.w #6,sp

	move.l FileName,-(sp)
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp

	bra restit
	
;-----------------------------------------------
	data

olddump	ds.l 1
FileName	ds.l 1

sign	dc.b 'FUSS'

prompt	dc.b $1b,'E'
	dc.b 'FUSS v1.2:',$a,$d,$a,$d
	dc.b 'Universal Falcon030 Screen Saver',$a,$d
	dc.b 'by T.AL 94',$a,$d,$a,$d
	dc.b 0

waiting	dc.b 'Installed',$a,$d

newfname	dc.b 'Save image as: ',0

oldfname	dc.b 'Old filename: ',0

wipe	dc.b 'Removed from memory',0

another	dc.b $a,$d
	dc.b 'enter new filename:',$a,$d,0

oknewfn	dc.b $a,$d
	dc.b 'new filename:',$a,$d,0

inputfname	dc.b 80		;taille max lors de la saisie
	dc.b 0
defaultfile	dc.b '\SAVER.F30',0	;nom par defaut
	ds.b 200	;un peu de place pour un autre nom de fichier
	
cr	dc.b $a,$d,0

work	dc.b 'FUSS is working for you ?!',$a,$d
	dc.b '(what a beautiful screen clearer)',$a,$d,$a,$d
	dc.b 'image saved as: ',$a,$d,0

fataldsk	dc.b 'Fatal disk I/O at 0',$a,$d,0
errnb	equ *-4

dskerr	dc.b 'FUSS can''t save image as: `',0

;-----------------------------------------------
 	bss

DTA	ds.b 44

	
savDTA	ds.l 1
savPath	ds.b 256

savbuf	ds.b 2048

;-----------------------------------------------
	end

