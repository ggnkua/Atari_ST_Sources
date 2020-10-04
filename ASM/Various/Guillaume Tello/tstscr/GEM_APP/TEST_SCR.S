; d‚marrage TOS

FRA = 1	; 1 francais, 0 anglais

	if FRA=1
		output "TSTSCR_F.PRG"
	else
		output "TSTSCR_E.PRG"
	endif

XBIOS MACRO   ; fn,pile
   move #\1,-(sp)
   trap #14
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

BIOS MACRO   ; fn,pile
   move #\1,-(sp)
   trap #13
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

GEMDOS MACRO    ; fn,pile
   move #\1,-(sp)
   trap #1
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

GEM_AES MACRO
   move.l #\1,d1
   move.l #$c8,d0
   trap #2
   ENDM

GEM_VDI MACRO
   move.l #\1,a0
   move.l a0,d1
   move.l (a0),a0
   move i_handle,12(a0)
   moveq #$73,d0
   trap #2
   ENDM

	text

	move.l 4(sp),a0
	move.l $18(a0),a1
	add.l $1c(a0),a1
	add.l #$200,a1
	move.l a1,sp
	sub.l a0,a1
	move.l a1,-(sp)
	move.l a0,-(sp)
	clr.w -(sp)
	GEMDOS $4a,12
		
	GEM_AES appl_init
	GEM_AES graf_handle
	XBIOS 4,2				
	addq #2,d0
	move d0,ow_int      
	move intout,i_handle
	GEM_VDI open_work
	move ow_cont+12,i_handle
	lea intout(pc),a3
	lea alert(pc),a4
	lea T1(pc),a0
	bsr add_string
	moveq #0,d0
	move (a3),d0
	addq #1,d0
	bsr add_int
	move.b #'x',(a4)+
	moveq #0,d0
	move 2(a3),d0
	addq #1,d0
	bsr add_int
	lea T2(pc),a0
	bsr add_string
	GEM_VDI vq_extnd
	move 8(a3),d7		; nombre de bits/pixel
	moveq #0,d0
	move d7,d0
	bsr add_int
	lea T3(pc),a0
	bsr add_string
	lea bits(pc),a0
	lea table(pc),a1
	move d7,-2(a1)
	move d7,dest+12	; pour le bloc!
.cherche:
	cmp (a0)+,d7
	beq.s .ok
	addq.l #4,a1	
	bra.s .cherche
.ok:
	move.l (a1),a0
	jsr (a0)	
	bra.s suite
bits: dc.w 1,2,4,8,16,24,32
fatal: dc.w 0
table: dc.l mono,coul4,coul16,coul256,highcol,truecol24,truecol32,gloups

suite: 
	beq.s .ok
	lea T0(pc),a0
	move #1,ab_int		; SAUVE par defaut.
.ok:
	tst.b once+1		; 24 ou 32 bits?
	beq.s .autre
	subq.l #2,a4
.copy:
	move.b (a6)+,(a4)+
	bne.s .copy
	subq.l #1,a4
.autre:
	bsr add_string
	lea TFIN(pc),a0
	bsr add_string
	GEM_AES form_alert
	move (a3),d0		; bouton
	cmp #2,d0
	beq fin
	bsr sauver	
fin:
	GEM_VDI close_work
	GEM_AES appl_exit
	GEMDOS 0,2

mono:
	lea palmono(pc),a6
	bsr dessin
	move.l (a0),d0
	lea T4(pc),a0
	cmp.l #$11111111,d0
	beq.s .ok
	moveq #-1,d0
	rts
.ok:
	moveq #0,d0
	rts
		
coul4:
	lea pal4(pc),a6
	bsr dessin
	movem.l (a0),d0-d1
	lea T5(pc),a0
	cmp.l #$66665555,d0
	bne.s .autre
	cmp.l d0,d1
	beq.s .ok
.autre:
	lea T6(pc),a0
	cmp.l #$66666666,d0
	bne.s .gloups
	cmp.l #$55555555,d1
	beq.s .ok
.gloups:
	moveq #-1,d0
	rts
.ok:
	moveq #0,d0
	rts	

coul16:
	lea pal16(pc),a6
	bsr dessin
	movem.l (a0),d0-d3
	lea T5(pc),a0
	cmp.l #$DDDD4444,d0
	bne.s .autre
	cmp.l #$CCCC3333,d1
	bne.s .autre
	cmp.l d0,d2
	bne.s .autre
	cmp.l d1,d3
	beq.s .ok
.autre:
	lea T6(pc),a0
	cmp.l #$DDDDDDDD,d0
	bne.s .dernier
	cmp.l #$44444444,d1
	bne.s .dernier
	cmp.l #$CCCCCCCC,d2
	bne.s .dernier
	cmp.l #$33333333,d3
	beq.s .ok
.dernier:
	lea TF(pc),a0
	cmp.l #$57895789,d0
	bne.s .gloups
	cmp.l d0,d1
	bne.s .gloups
	cmp.l d0,d2
	bne.s .gloups
	cmp.l d0,d3
	beq.s .ok
.gloups:
	moveq #-1,d0
	rts	
.ok:
	moveq #0,d0
	rts

coul256:
	lea pal256(pc),a6
	bsr dessin
	move.l a0,a1
	moveq #7,d0
	move.l a1,a2
.lb0:
	cmp.l #$10111213,(a2)+
	bne.s .autre
	dbf d0,.lb0
	lea T7(pc),a0
	bra.s .ok
.autre:
	move.l a0,a1
	lea T71(pc),a0
	moveq #7,d0
	move.l a1,a2
.lb1:
	cmp.l #$0F101112,(a2)+
	bne.s .lb2
	dbf d0,.lb1
	bra.s .ok
.lb2:
	moveq #1,d0
	lea T5(pc),a0
.verif:
	cmp.l #$55553333,(a1)+
	bne.s .gloups
	tst.l (a1)+
	bne.s .gloups
	cmp.l #$ffff0000,(a1)+
	bne.s .gloups
	tst.l (a1)+
	bne.s .gloups
	dbf d0,.verif
	bra.s .ok
.gloups:
	moveq #-1,d0
	rts	
.ok:
	moveq #0,d0
	rts

highcol:
	lea palplus(pc),a6
	bsr dessin
	movem.l (a0),d0-d1	; 4 premiers pixels
	move.l a0,a1
	lea T8(pc),a0
	bset #21,d0
	bset #21,d1
	cmp.l #$FFFFF800,d0
	bne.s .autre
	cmp.l #$07E0001F,d1
	beq.s .ok
.autre:
	movem.l (a1),d0-d1
	lea T9(pc),a0
	bset #29,d0
	bset #29,d1
	cmp.l #$FFFF00F8,d0
	bne.s .zotr
	cmp.l #$E0071F00,d1
	beq.s .ok
.zotr:
	lea TG(pc),a0
	movem.l (a1),d0-d1
	and.l #$7FFF7FFF,d0
	and.l #$7FFF7FFF,d1
	cmp.l #$7FFF7C00,d0
	bne.s .dernier
	cmp.l #$03E0001F,d1
	beq.s .ok	
.dernier:
	lea TA(pc),a0
	movem.l (a1),d0-d1
	and.l #$FF7FFF7F,d0
	and.l #$FF7FFF7F,d1
	cmp.l #$FF7F007C,d0
	bne.s .gloups
	cmp.l #$E0031F00,d1
	beq.s .ok
.gloups:
	moveq #-1,d0
	rts	
.ok: moveq #0,d0
	rts

truecol24:
	move #-1,once
	lea palplus(pc),a6
	bsr dessin
	lea VDI(pc),a6
.retour:
	movem.l (a0),d0-d2	; 4 premiers pixels
	lea TB(pc),a0
	cmp.l #-1,d0
	bne.s .autre
	cmp.l #255,d1
	bne.s .autre
	cmp.l #255,d2
	beq.s .ok
.autre:
	lea TC(pc),a0
	cmp.l #$FFFFFF00,d0
	bne.s .gloups
	cmp.l #$00FF00FF,d1
	bne.s .gloups
	cmp.l #$00FF0000,d2
	beq.s .ok
.gloups:
	tst.b once
	beq.s .fini
	bsr direct
	bra.s .retour
.fini:
	lea ARG(pc),a6	
	moveq #-1,d0
	rts
.ok: moveq #0,d0
	rts
		
truecol32:	
	move #-1,once
	lea palplus(pc),a6
	bsr dessin
	lea VDI(pc),a6
.retour:	
	movem.l (a0),d0-d3
	move.l #$00FFFFFF,d4
	lea TD(pc),a0
	and.l d4,d0
	and.l d4,d1
	and.l d4,d2
	and.l d4,d3
	cmp.l d4,d0
	bne.s .autre
	cmp.l #$FF0000,d1
	bne.s .autre_sens
	cmp.l #$FF00,d2
	bne.s .autre_sens
	cmp.l #255,d3
	beq .ok
.autre_sens:
	lea TH(pc),a0
	cmp.l #$ff,d1
	bne.s .autre
	cmp.l #$ff00,d2
	bne.s .autre
	cmp.l #$ff0000,d3
	beq.s .ok
.autre:
	lea bloc(pc),a0
	movem.l (a0),d0-d3
	lsl.l #8,d4
	lea TE(pc),a0
	and.l d4,d0
	and.l d4,d1
	and.l d4,d2
	and.l d4,d3
	cmp.l d4,d0
	bne.s .gloups
	cmp.l #$FF00,d1
	bne.s .autre_sens2
	cmp.l #$FF0000,d2
	bne.s .autre_sens2
	cmp.l #$FF000000,d3
	beq.s .ok
.autre_sens2:
	lea TI(pc),a0
	cmp.l #$FF000000,d1
	bne.s .gloups
	cmp.l #$ff0000,d2
	bne.s .gloups
	cmp.l #$ff00,d3
	beq.s .ok
.gloups:
	tst.b once
	beq.s .fini
	bsr direct
	bra .retour
.fini:
	lea ARG(pc),a6	
	moveq #-1,d0
	rts	
.ok:
	moveq #0,d0
	rts
	
gloups:
	moveq #-1,d0
	rts	

add_int:
	move.l a7,a0
	clr.b -(a0)
.encore:
	divs #10,d0
	swap d0
	add.b #'0',d0
	move.b d0,-(a0)	
	clr d0
	swap d0
	bne.s .encore	
	
add_string:
	move.b (a0)+,(a4)+
	bne.s add_string
	subq.l #1,a4
	rts
	
; a6=palette

dessin:
	GEM_VDI hide_mouse
	GEM_AES wind_create
	GEM_AES form_dial
	GEM_AES wind_open
	lea vc_int(pc),a5
	move (a6)+,(a5)
	move (a6)+,d4		; nombre
	bra.s .fin_coul
.coul:
	move (a6)+,2(a5)
	move (a6)+,4(a5)
	move (a6)+,6(a5)
	GEM_VDI vs_color
	addq #1,(a5)
.fin_coul:
	dbf d4,.coul	
	moveq #3,d6
	lea vm_int(pc),a5
.points:
	move (a6)+,(a5)		; couleur!
	GEM_VDI vsm_color
	GEM_VDI v_pmarker
	lea vp_int(pc),a0
	moveq #7,d0
.trans:
	addq #1,(a0)
	addq.l #4,a0
	dbf d0,.trans
	dbf d6,.points	
	GEM_VDI vro_cpyfm		; remplit le bloc!!!	
	GEM_AES wind_close
	GEM_AES wind_delete
	move #3,fd_int
	GEM_AES form_dial
	GEM_VDI show_mouse
	lea bloc(pc),a0		; le bloc!!!
	rts

direct:
	XBIOS 3,2				; physbase
	move.l d0,a1
	lea bloc(pc),a2
	move.l a2,a0
	move table-2(pc),d0	; 24 octets ou 32 a lire
	subq #1,d0
.copy:
	move.b (a1)+,(a2)+
	dbf d0,.copy
	lea DIR(pc),a6
	sf once
	rts
	
sauver:
	move.l a4,-(sp)
	lea intout(pc),a4
	moveq #0,d0
	move d7,d0
	bsr add_int
	lea fich(pc),a0
	bsr add_string
	clr.b (a4)
	move.l (sp)+,a4
	move d7,d4
	lea bloc(pc),a2
	bra.s .boucle
.encore:
	lea ligne(pc),a0
	bsr add_string
	move.l (a2)+,d0
	moveq #0,d2
	moveq #7,d1
.digit:
	rol.l #4,d0
	move.b d0,d2
	and #$0F,d2
	cmp #10,d2
	bpl.s .lettre
	add.b #"0",d2
	bra.s .commun
.lettre:
	add.b #"A"-10,d2
.commun:
	move.b d2,(a4)+
	dbf d1,.digit
.boucle:
	dbf d4,.encore	
	clr -(sp)
	pea intout(pc)
	GEMDOS 60,8		; fcreate
	move d0,d6		; handle
	lea alert(pc),a0
	move.l a4,d0
	sub.l a0,d0		; taille
	move.l a0,-(sp)
	move.l d0,-(sp)
	move d6,-(sp)
	GEMDOS 64,12	; fwrite
	move d6,-(sp)
	GEMDOS 62,4		; fclose
	rts
	
	
	data	

	if FRA=1
	
T0: dc.b "INCONNU",0	
T1: dc.b "[1][ R‚solution: ",0
T2: dc.b   " | Bits/pixel: ",0
T3: dc.b   " | Codage    : | ",0
T4: dc.b   "1 pixel = 1 bit",0
T5: dc.b "plans entrelac‚s",0
T6: dc.b "plans NON-entrelac‚s",0
T7: dc.b "1 octet = 1 pixel",0
T71: dc.b "1 octet = 1 pixel (Matrix)",0
T8: dc.b "1 pixel = rrrrrvvv vvvbbbbb",0
T9: dc.b "1 pixel = vvvbbbbb rrrrrvvv",0
TA: dc.b "1 pixel = vvvbbbbb xrrrrrvv",0
TB: dc.b "1 pixel = 3 octets RVB",0
TC: dc.b "1 pixel = 3 octets BVR",0
TD: dc.b "1 pixel = 4 octets xRVB",0
TE: dc.b "1 pixel = 4 octets BVRx",0
TF: dc.b "2 pixels = 1 octet",0
TG: dc.b "1 pixel = xrrrrrvv vvvbbbbb",0
TH: dc.b "1 pixel = 4 octets xBVR",0
TI: dc.b "1 pixel = 4 octets RVBx",0
TFIN: dc.b " ][Sauver|Quitter]",0
fich: dc.b "_bit.txt",0
ligne: dc.b 13,10,"$",0

	else
	
T0: dc.b "UNKNOWN",0	
T1: dc.b "[1][ Resolution: ",0
T2: dc.b   " | Bits/pixel: ",0
T3: dc.b   " | Encoding  : | ",0
T4: dc.b   "1 pixel = 1 bit",0
T5: dc.b "interleaved planes",0
T6: dc.b "NON-interleaved planes",0
T7: dc.b "1 byte = 1 pixel",0
T71: dc.b "1 byte = 1 pixel (Matrix)",0
T8: dc.b "1 pixel = rrrrrggg gggbbbbb",0
T9: dc.b "1 pixel = gggbbbbb rrrrrggg",0
TA: dc.b "1 pixel = gggbbbbb xrrrrrgg",0
TB: dc.b "1 pixel = 3 bytes RVB",0
TC: dc.b "1 pixel = 3 bytes BVR",0
TD: dc.b "1 pixel = 4 bytes xRVB",0
TE: dc.b "1 pixel = 4 bytes BVRx",0
TF: dc.b "2 pixels = 1 byte",0
TG: dc.b "1 pixel = xrrrrrvv vvvbbbbb",0
TH: dc.b "1 pixel = 4 bytes xBVR",0
TI: dc.b "1 pixel = 4 bytes RVBx",0
TFIN: dc.b " ][Save|Quit]",0
fich: dc.b "_bit.txt",0
ligne: dc.b 13,10,"$",0

	endif	

VDI: dc.b "(VDI Ok) | ",0
DIR: dc.b "(VDI Err) | ",0
ARG: dc.b "(VDI+Direct Err) | ",0

	even

appl_exit: dc.l ae_cont,global,dum,intout,dum,dum
ae_cont: dc.w 19,0,1,0,0

appl_init: dc.l ai_cont,global,dum,appl_id,dum,dum
ai_cont: dc.w 10,0,1,0,0
appl_id: dc.w 0

open_work: dc.l ow_cont,ow_int,dum,work_out,ptsout
ow_cont: dc.w 100,0,0,11,0,0,0,0,0,0,0,0
ow_int: dc.w 2,1,1,1,1,1,1,0,1,0,2

close_work: dc.l cw_cont,dum,dum,dum,dum
cw_cont: dc.w 101,0,0,0,0,0,0,0,0,0,0,0

form_alert: dc.l ab_cont,global,ab_int,intout,ab_addrin,dum
ab_cont: dc.w 52,1,1,1,0
ab_int: dc.w 2
ab_addrin: dc.l alert

graf_handle: dc.l gh_cont,global,dum,intout,dum,dum
gh_cont: dc.w 77,0,5,0,0

vq_extnd: dc.l ve_cont,ve_int,dum,intout,ptsout
ve_cont: dc.w 102,0,0,1,0,0,0,0,0,0,0,0
ve_int: dc.w 1

vsm_color: dc.l vm_cont,vm_int,dum,dum,dum
vm_cont: dc.w 20,0,0,1,0,0,0,0,0,0,0,0
vm_int: dc.w 0

v_pmarker: dc.l vp_cont,dum,vp_int,dum,dum
vp_cont: dc.w 7,8,0,0,0,0,0,0,0,0,0,0
;vp_cont: dc.w 7,1,0,0,0,0,0,0,0,0,0,0
vp_int: dc.w 0,0,4,0,8,0,12,0,0,1,4,1,8,1,12,1

hide_mouse: dc.l vh_cont,dum,dum,dum,dum
vh_cont: dc.w 123,0,0,0,0,0,0,0,0,0,0,0

show_mouse: dc.l sm_cont,sm_int,dum,dum,dum
sm_cont: dc.w 122,0,0,1,0,0,0,0,0,0,0,0
sm_int: dc.w 1

wind_create: dc.l wc_cont,global,wc_int,whand,dum,dum
wc_cont: dc.w 100,5,1,0,0
whand:
wc_int: dc.w 0,0,0,16,2

wind_open: dc.l wo_cont,global,wc_int,dum,dum,dum
wo_cont: dc.w 101,5,1,0,0

wind_close: dc.l wcl_cont,global,wc_int,dum,dum,dum
wcl_cont: dc.w 102,1,1,0,0

wind_delete: dc.l wd_cont,global,wc_int,dum,dum,dum
wd_cont: dc.w 103,1,1,0,0

form_dial: dc.l fd_cont,global,fd_int,dum,dum,dum
fd_cont: dc.w 51,9,1,0,0
fd_int: dc.w 0,0,0,16,2,0,0,16,2

vs_color: dc.l vc_cont,vc_int,dum,dum,dum
vc_cont: dc.w 14,0,0,4,0,0,0,0,0,0,0,0
vc_int: dc.w 0,0,0,0

vro_cpyfm: dc.l cp_cont,cp_int,cp_ptsin,dum,dum
cp_cont: dc.w 109,4,0,1,0,0,0
	dc.l source,dest
cp_int: dc.w 3
cp_ptsin: dc.w 0,0,15,1,0,0,15,1
source: dc.l 0,0,0,0,0
dest: dc.l bloc
		dc.w 16,2,1,0,0,0,0,0

palplus: dc.w 16,4
	dc.w 1000,1000,1000,1000,0,0,0,1000,0,0,0,1000
	dc.w 16,17,18,19
	
pal256: dc.w 0,0
	dc.w 16,17,18,19
	
pal16: dc.w 0,0
	dc.w 7,8,9,10

pal4: dc.w 0,0
	dc.w 0,1,2,3

palmono: dc.w 0,0
	dc.w 0,0,0,1	
	
once: dc.w 0

	bss

alert: ds.b 600
dum: ds.l 4
work_out:
intout: ds.w 128
ptsout: ds.w 128
global: ds.w 30
i_handle: ds.w 1
bloc: ds.l 32		; au pire pour un bloc 16x2 en 32 bits

	end