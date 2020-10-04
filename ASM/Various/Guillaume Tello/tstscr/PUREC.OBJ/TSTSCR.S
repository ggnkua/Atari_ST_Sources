; d‚marrage TOS

		OPT L1,Y+,P=68000
		output "H:\PUREC\LIB\TSTSCR.O"

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

GEM_AES2 MACRO
   move.l #\1,a0
   move.l a0,d1
   move.l a4,4(a0)	; fills global
   move.l #$c8,d0
   trap #2
   ENDM

GEM_VDI MACRO
   move.l #\1,a0
   move.l a0,d1
   move.l (a0),a0
   move i_handle(pc),12(a0)
   moveq #$73,d0
   trap #2
   ENDM

	EXPORT ScreenEncoding
	
;	LONG ScreenEncoding(pointeur global, int flag);
;	Renvoit un LONG:
; HighWord = bits/pixel, low word = encoding
; UNKNOWN if bit 31 set, then high word = bits/pixel, low word undefined
; MONO: 00010000
; 4 colors: 0002 + 0000 (mode Atari plans entrelac‚s)
;					  + 0001 (mode PC plans s‚par‚s)
;					  + 0002 (mode ancien 2 bits par pixel, 4 pixels par byte)
; 16 couleurs: 0004 + 0000 (mode Atari plans entrelac‚s)
;						  + 0001 (mode PC plans s‚par‚s)
;						  + 0002 (mode ancien 4 bits/pixel, 2 pixels/octet)
; 256 couleurs: 0008 + 0000 (mode Atari, plans entrelac‚s)
;							+ 0001 (mode PC, plans s‚par‚s)
;							+ 0002 (un octet par pixel)
;							+ 0003 (idem pour Matrix)
; High Color	0010  + 0000 (mode Atari rrrrrvvv vvvbbbbb)
;							+ 0001 (mode PC vvvbbbbb rrrrrvvv)
;							+ 0002 (mode PC xrrrrrvv vvvbbbbb)
;							+ 0003 (mode PC vvvbbbbb xrrrrrvv)
; here if bit15 set in low word = VDI error but direct access ok
; TC 24			0018  + 0000 (RVB, 3 octets)
;							+ 0001 (BVR, 3 octets)
; TC 32			0020  + 0000 (xRVB, 4 octets)
;							+ 0001 (xBVR, 4 octets)
;							+ 0002 (BVRx, 4 octets)
;							+ 0003 (RVBx, 4 octets)

ScreenEncoding:
	movem.l a2-a6/d2-d7,-(sp)
	move.l a0,a4			; global
	lea once(pc),a0
	tst.l d0
	sne (a0)+					; if flag<>0 then direct access allowed
	sne (a0)
	lea intout(pc),a3
	lea i_handle(pc),a5
	lea ow_int(pc),a6
	GEM_AES2 graf_handle
	XBIOS 4,2				
	addq #2,d0
	move d0,(a6)
	move (a3),(a5)		; graf handle	to i_handle
	GEM_VDI open_work
	lea ow_cont(pc),a6
	move 12(a6),(a5)	; VDI handle
	beq.s .error_open

	GEM_VDI vq_extnd
	move 8(a3),d7		; nombre de bits/pixel
	lea dest(pc),a0
	move d7,12(a0)		; pour le bloc
	lea bits(pc),a0
	lea table(pc),a1
	move d7,-2(a1)
.cherche:
	cmp (a0)+,d7
	beq.s .ok
	addq.l #4,a1	
	bra.s .cherche
.ok:
	move.l (a1),a0
	jsr (a0)	
	move.l d0,d7
	GEM_VDI close_work
	move.l d7,d0
.out:
	movem.l (sp)+,a2-a6/d2-d7
	rts
.error_open:			; can't open workstation !
	moveq.l #0,d0
	bset #31,d0
	bra.s .out

bits: dc.w 1,2,4,8,16,24,32
fatal: dc.w 0
table: dc.l mono,coul4,coul16,coul256,highcol,truecol24,truecol32,gloups

mono:
	lea palmono(pc),a6
	bsr dessin
	move.l #$00010000,d0
	move.l (a0),d1
	cmp.l #$11111111,d1
	beq.s .ok
	bset #31,d0		; unknown
.ok:
	rts
		
coul4:
	lea pal4(pc),a6
	bsr dessin
	movem.l (a0),d1-d2
	move.l #$00020000,d0		; interlaced planes, 2 bits/pixel
	cmp.l #$66665555,d1
	bne.s .autre
	cmp.l d2,d1
	beq.s .ok
.autre:
	addq.l #1,d0				; non interlaced
	cmp.l #$66666666,d1
	bne.s .gloups
	cmp.l #$55555555,d2
	beq.s .ok
.gloups:
	bset #31,d0					; unknown
.ok:
	rts

coul16:
	lea pal16(pc),a6
	bsr dessin
	movem.l (a0),d1-d4
	move.l #$00040000,d0		; interlaced, 4 bits/pixel
	cmp.l #$DDDD4444,d1
	bne.s .autre
	cmp.l #$CCCC3333,d2
	bne.s .autre
	cmp.l d4,d2
	bne.s .autre
	cmp.l d1,d3
	beq.s .ok
.autre:
	addq.l #1,d0				; non interlaced
	cmp.l #$DDDDDDDD,d1
	bne.s .dernier
	cmp.l #$44444444,d2
	bne.s .dernier
	cmp.l #$CCCCCCCC,d3
	bne.s .dernier
	cmp.l #$33333333,d4
	beq.s .ok
.dernier:
	addq.l #1,d0				; packed 2 pixels = 1 byte
	cmp.l #$57895789,d1
	bne.s .gloups
	cmp.l d4,d1
	bne.s .gloups
	cmp.l d4,d2
	bne.s .gloups
	cmp.l d4,d3
	beq.s .ok
.gloups:
	bset #31,d0		; unknown
.ok:
	rts	

coul256:
	lea pal256(pc),a6
	bsr dessin
	move.l a0,a1
	moveq #7,d1
	move.l a1,a2
	move.l #$00080002,d0		; 1byte = 1pixel
.lb0:
	cmp.l #$10111213,(a2)+
	bne.s .autre
	dbf d1,.lb0
	bra.s .ok
.autre:
	move.l a0,a1
	addq.l #1,d0				; 1byte=1pixel matrix
	moveq #7,d1
	move.l a1,a2
.lb1:
	cmp.l #$0F101112,(a2)+
	bne.s .lb2
	dbf d1,.lb1
	bra.s .ok
.lb2:
	moveq #1,d1
	subq.l #3,d0				; interlaced
.verif:
	cmp.l #$55553333,(a1)+
	bne.s .gloups
	tst.l (a1)+
	bne.s .gloups
	cmp.l #$ffff0000,(a1)+
	bne.s .gloups
	tst.l (a1)+
	bne.s .gloups
	dbf d1,.verif
	bra.s .ok
.gloups:
	bset #31,d0		; unknown
.ok:
	rts	

highcol:
	lea palplus(pc),a6
	bsr dessin
	movem.l (a0),d1-d2	; 4 premiers pixels
	move.l a0,a1
	move.l #$00100000,d0	; rrrrrvvv vvvbbbbb
	bset #21,d2
	bset #21,d1
	cmp.l #$FFFFF800,d1
	bne.s .autre
	cmp.l #$07E0001F,d2
	beq.s .ok
.autre:
	movem.l (a1),d1-d2
	addq.l #1,d0			; vvvbbbbb rrrrrvvv
	bset #29,d1
	bset #29,d2
	cmp.l #$FFFF00F8,d1
	bne.s .zotr
	cmp.l #$E0071F00,d2
	beq.s .ok
.zotr:
	addq.l #1,d0			; xrrrrrvv vvvbbbbb
	movem.l (a1),d1-d2
	and.l #$7FFF7FFF,d1
	and.l #$7FFF7FFF,d2
	cmp.l #$7FFF7C00,d1
	bne.s .dernier
	cmp.l #$03E0001F,d2
	beq.s .ok	
.dernier:
	addq.l #1,d0			; vvvbbbbb xrrrrrvv
	movem.l (a1),d1-d2
	and.l #$FF7FFF7F,d1
	and.l #$FF7FFF7F,d2
	cmp.l #$FF7F007C,d1
	bne.s .gloups
	cmp.l #$E0031F00,d2
	beq.s .ok
.gloups:
	bset #31,d0				; unknown
.ok:
	rts

truecol24:
	lea palplus(pc),a6
	bsr dessin
.retour:
	movem.l (a0),d1-d3	; 4 premiers pixels
	move.l #$00180000,d0	; RVB
	cmp.l #-1,d1
	bne.s .autre
	cmp.l #255,d2
	bne.s .autre
	cmp.l #255,d3
	beq.s .ok
.autre:
	addq.l #1,d0			; BVR
	cmp.l #$FFFFFF00,d1
	bne.s .gloups
	cmp.l #$00FF00FF,d2
	bne.s .gloups
	cmp.l #$00FF0000,d3
	beq.s .ok
.gloups:
	tst.b once
	beq.s .fini
	bsr direct
	bra.s .retour
.fini:
	bset #31,d0			; unknown
	rts	
.ok:
	lea once(pc),a0
	tst.b (a0)+			; first pass?
	bne.s .ok2			; yes !
	tst.b (a0)
	beq.s .ok2			; yes too
	bset #15,d0			; else set bit for direct access required
.ok2:
	rts

truecol32:	
	lea palplus(pc),a6
	bsr dessin
.retour:	
	movem.l (a0),d1-d4
	move.l #$00FFFFFF,d5
	move.l #$00200000,d0	; xRVB
	and.l d5,d1
	and.l d5,d2
	and.l d5,d3
	and.l d5,d4
	cmp.l d5,d1
	bne.s .autre
	cmp.l #$FF0000,d2
	bne.s .autre_sens
	cmp.l #$FF00,d3
	bne.s .autre_sens
	cmp.l #255,d4
	beq .ok
.autre_sens:
	cmp.l #$ff,d2
	bne.s .autre
	cmp.l #$ff00,d3
	bne.s .autre
	cmp.l #$ff0000,d4
	bne.s .autre
	bra.s .ok
	addq.l #1,d0		; xBVR
.autre:
	lea bloc(pc),a0
	movem.l (a0),d1-d4
	lsl.l #8,d5
	addq.l #2,d0		; BVRx
	and.l d5,d1
	and.l d5,d2
	and.l d5,d3
	and.l d5,d4
	cmp.l d5,d1
	bne.s .gloups
	cmp.l #$FF00,d2
	bne.s .autre_sens2
	cmp.l #$FF0000,d3
	bne.s .autre_sens2
	cmp.l #$FF000000,d4
	beq.s .ok
.autre_sens2:
	addq.l #1,d0			; RVBx
	cmp.l #$FF000000,d2
	bne.s .gloups
	cmp.l #$ff0000,d3
	bne.s .gloups
	cmp.l #$ff00,d4
	beq.s .ok
.gloups:
	tst.b once
	beq.s .fini
	bsr direct
	bra .retour
.fini:
	bset #31,d0			; unknown
	rts	
.ok:
	lea once(pc),a0
	tst.b (a0)+			; first pass?
	bne.s .ok2			; yes !
	tst.b (a0)
	beq.s .ok2			; yes too
	bset #15,d0			; else set bit for direct access required
.ok2:
	rts
	
gloups:
	moveq #0,d0
	move d7,d0			; unknow number of bits/pixel
	bset #15,d0			; unknown
	swap d0			   ; in high word
	rts	

; a6=palette

dessin:
	GEM_VDI hide_mouse
	GEM_AES2 wind_create
	GEM_AES2 form_dial
	GEM_AES2 wind_open
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
	GEM_AES2 wind_close
	GEM_AES2 wind_delete
	move #3,fd_int
	GEM_AES2 form_dial
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
	sf once
	rts

open_work: dc.l ow_cont,ow_int,dum,work_out,ptsout
ow_cont: dc.w 100,0,0,11,0,0,0,0,0,0,0,0
ow_int: dc.w 2,1,1,1,1,1,1,0,1,0,2

close_work: dc.l cw_cont,dum,dum,dum,dum
cw_cont: dc.w 101,0,0,0,0,0,0,0,0,0,0,0

graf_handle: dc.l gh_cont,0,dum,intout,dum,dum
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

wind_create: dc.l wc_cont,0,wc_int,whand,dum,dum
wc_cont: dc.w 100,5,1,0,0
whand:
wc_int: dc.w 0,0,0,16,2

wind_open: dc.l wo_cont,0,wc_int,dum,dum,dum
wo_cont: dc.w 101,5,1,0,0

wind_close: dc.l wcl_cont,0,wc_int,dum,dum,dum
wcl_cont: dc.w 102,1,1,0,0

wind_delete: dc.l wd_cont,0,wc_int,dum,dum,dum
wd_cont: dc.w 103,1,1,0,0

form_dial: dc.l fd_cont,0,fd_int,dum,dum,dum
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

dum: dc.l 0,0,0,0
work_out:
intout: dcb.w 128,0
ptsout: dcb.w 128,0
i_handle: dc.w 0
bloc: dcb.l 32,0		; au pire pour un bloc 16x2 en 32 bits

	end