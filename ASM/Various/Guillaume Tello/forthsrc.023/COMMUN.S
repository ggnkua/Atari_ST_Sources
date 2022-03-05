; >> version 0.1.6 du 30 oct 2021
; adaptation setplay/play au systŠme son SAGA sur Vampire
; -1 play -> attente san superviseur pour l'AES..
; >> version 0.1.7 du 28 jan 2022
; correction des temps evnt_timer et evnt_multi



V1 MACRO
   if \1<128
   	moveq #\1,d0
   else
   	move #\1,d0
   endif
	moveq #\2,d1
	moveq #\3,d2
   if \4<128
   	moveq #\4,d3
   else
   	move #\4,d3
   endif
	bra vdiun
	ENDM

V2 MACRO
	if \1<128
		moveq #\1,d0
	else
		move #\1,d0
	endif
	moveq #\2,d1
	moveq #\3,d2
	moveq #\4,d3
	bra vdideux
	ENDM

V3 MACRO
	if \1<128
		moveq #\1,d0
	else
		move #\1,d0
	endif
	moveq #\2,d3
	bra vditrois
	ENDM

V4 MACRO
	moveq #\1,d0
	tst.b xy_flag
	beq vdiquatre
	ENDM

V5 MACRO
	if \1<128
   	moveq #\1,d0
   else
   	move #\1,d0
   endif
	moveq #\2,d1
	moveq #\3,d3
	bra vdicinq
	ENDM

A1 MACRO
	if \1<128
		moveq #\1,d0
	else
		move #\1,d0
	endif
	moveq #\2,d1
	moveq #\3,d2
	moveq #\4,d3
	bra aesun
	ENDM

A2 MACRO
	if \1<128
		moveq #\1,d0
	else
		move #\1,d0
	endif
	moveq #\2,d2
	bra aesdeux
	ENDM

 text
 even

kbshift: dc.l $E1B	; adresse kbshift pour TOS 1.00, chang‚e au d‚marrage sinon.

read_cookies:
	pea .find(pc)
	XBIOS 38,6
	rts
.find:
	move.l $5a0.w,d0
	beq.s .out
	move.l d0,a0
.lb0:
	move.l (a0)+,d0
	beq.s .out
	cmp.l #'_MCH',d0
	bne.s .lb1
	move.l (a0),mch_value
.lb1:
	cmp.l #'_SND',d0
	bne.s .lb2
	move.l (a0),snd_value
.lb2:
	cmp.l #'_CPU',d0
	bne.s .lb3
	move.l (a0),cpu_value
.lb3:
	addq.l #4,a0
	bra.s .lb0
.out:
	rts

; d0<>0 si mode direct autoris‚
; d5<>0 si AES autoris‚

ScreenEncoding:
	lea once(pc),a0
	tst.l d0
	sne (a0)+					; if flag<>0 then direct access allowed
	sne (a0)
	GEM_VDI vq_extnd2
	move intout+8,d7		; nombre de bits/pixel
	lea mf_dest(pc),a0
	move d7,12(a0)		; pour le bloc
	lea .bits(pc),a0
	lea .table(pc),a1
	move d7,-2(a1)
.cherche:
	cmp (a0)+,d7
	beq.s .ok
	addq.l #4,a1
	bra.s .cherche
.ok:
	move.l (a1),a0
	jsr (a0)
.out:
	rts

.bits: dc.w 1,2,4,8,16,24,32
.fatal: dc.w 0
.table: dc.l mono,coul4,coul16,coul256,highcol,truecol24,truecol32,gloups

mono:
	lea .palmono(pc),a6
	bsr dessin
	move.l #$00010000,d0
	move.l (a0),d1
	cmp.l #$11111111,d1
	beq.s .ok
	bset #31,d0		; unknown
.ok:
	rts
.palmono: dc.w 0,0
	dc.w 0,0,0,1

coul4:
	lea .pal4(pc),a6
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
.pal4: dc.w 0,0
	dc.w 0,1,2,3

coul16:
	lea .pal16(pc),a6
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
.pal16: dc.w 0,0
	dc.w 7,8,9,10

coul256:
	lea .pal256(pc),a6
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
.pal256: dc.w 0,0
	dc.w 16,17,18,19

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

palplus: dc.w 16,4
	dc.w 1000,1000,1000,1000,0,0,0,1000,0,0,0,1000
	dc.w 16,17,18,19

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
	lea pile,a0
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
	ifd LIB
		tst.b aes_flag
		beq.s .no_aes1
	endif
	move w_hand,w_hand_sav
	GEM_AES wind_create
	GEM_AES form_dial2
	move w_hand,wg_out
	GEM_AES wind_open
.no_aes1:
	lea vc_int(pc),a5
	move (a6)+,(a5)
	move (a6)+,d4		; nombre
	bra.s .fin_coul
.coul:
	move (a6)+,2(a5)
	move (a6)+,4(a5)
	move (a6)+,6(a5)
	GEM_VDI vs_color2
	addq #1,(a5)
.fin_coul:
	dbf d4,.coul
	moveq #3,d6
	lea vm_int(pc),a5
.points:
	move (a6)+,(a5)		; couleur!
	GEM_VDI vsm_color2
	GEM_VDI v_pmarker2
	lea vp_int(pc),a0
	moveq #7,d0
.trans:
	addq #1,(a0)
	addq.l #4,a0
	dbf d0,.trans
	dbf d6,.points
	GEM_VDI vro_cpyfm2		; remplit le bloc!!!
	ifd LIB
		tst.b aes_flag
		beq.s .no_aes2
	endif
	GEM_AES wind_close
	GEM_AES wind_del
	move w_hand_sav,w_hand
	move #3,fd_int
	GEM_AES form_dial2
.no_aes2:
	lea pile,a0		; le bloc!!!
	rts

direct:
	XBIOS 3,2				; physbase
	move.l d0,a1
	lea pile,a2
	move.l a2,a0
	move table-2(pc),d0	; 24 octets ou 32 a lire
	subq #1,d0
.copy:
	move.b (a1)+,(a2)+
	dbf d0,.copy
	sf once
	rts

vq_extnd2: dc.l ve_cont,ve_int,dum,intout,ptsout
ve_cont: dc.w 102,0,0,1,0,0,0,0,0,0,0,0
ve_int: dc.w 1

vsm_color2: dc.l vm_cont,vm_int,dum,dum,dum
vm_cont: dc.w 20,0,0,1,0,0,0,0,0,0,0,0
vm_int: dc.w 0

v_pmarker2: dc.l vp_cont,dum,vp_int,dum,dum
vp_cont: dc.w 7,8,0,0,0,0,0,0,0,0,0,0
;vp_cont: dc.w 7,1,0,0,0,0,0,0,0,0,0,0
vp_int: dc.w 0,0,4,0,8,0,12,0,0,1,4,1,8,1,12,1

form_dial2: dc.l fd_cont,global,fd_int,dum,dum,dum
fd_int: dc.w 0,0,0,16,2,0,0,16,2

vs_color2: dc.l vc_cont,vc_int,dum,dum,dum
vc_cont: dc.w 14,0,0,4,0,0,0,0,0,0,0,0
vc_int: dc.w 0,0,0,0

vro_cpyfm2: dc.l cp_cont,cp_int,cp_ptsin,dum,dum
cp_cont: dc.w 109,4,0,1,0,0,0
	dc.l mf_source,mf_dest
cp_int: dc.w 3
cp_ptsin: dc.w 0,0,15,1,0,0,15,1
mf_source: dc.l 0,0,0,0,0
mf_dest: dc.l pile
		dc.w 16,2,1,0,0,0,0,0

code_ecran:
once: dc.w 0,0

	SAUT
screen_info:
	move.l code_ecran(pc),-(a6)
	rts

test_mxalloc:
	GEMDOS 48,2			; sversion
	cmp.l #$1900,d0
	spl is_mxal			; FF if mxalloc exists
	rts
is_mxal: dc.w 0

le_menu:
   move.l pilptr,a6
	move.l #menu_chaine,-(a6)
	bsr menu
	move.l (a6)+,menu_adresse
	move.l topprg,program      ; avance le d‚but du dicco, partie r‚serv‚e
	rts

	dc.w 9
menu_chaine: dc.b "  FORTH  ",0
   dc.w 9
   dc.b 0,0,0,0,0,0,0,0,0,0
   dc.w 9
   if LANG=0
   	dc.b "  Retour",0,0
   else
   	dc.b "  Return",0,0
   endif
   dc.w 9
   dc.b 0,0,0,0,0,0,0,0,0,0

menu_adresse: dc.l 0

control: dcb.w 13,0
; edb: dc.l edbuf

; edition d'une chaine en A0
; d6 = nombre maxi de caractŠres accept‚s
; si d6 est n‚gatif, c'est qu'il faut tenir compte de la position D4/D7
; de la fenetre ouverte sur le texte
; les donn‚es de la fenetre sont dans (fenetre)
; la liste des touches de sortie est dans [end_keys]
; utilise a0,a1,a3 et d0,d1,d3,d4,d5,d7
; d6 non modifi‚
; renvoit D0 code ‚tendu de la touche de sortie
; et d4 position du curseur lors de la sortie

edition:
	move #10,copy_int          ; mode NOT DEST ( pour le curseur )
   move.l a0,a3
   tst.l d6
   bpl.s .lb_0
   move d7,d0                 ; si d6 n‚gatif, d4 et d7 d‚j… charg‚s
   add d4,d0
   neg.l d6                   ; laisser une instruction NE avant le bra
   bra.s .lb_x
.lb_z:
   tst.b (a0)+
.lb_x: dbeq d0,.lb_z           ; v‚rifie la validit‚ de D4 et D7
   bne.s .lb_1
.lb_0:                        ; si D6 positif, curseur au d‚but
   moveq #0,d7                ; d‚but de la fenetre dans la chaine
   moveq #0,d4	               ; offset du curseur dans la fenetre
.lb_1:
	clr.b 0(a0,d6.w)           ; s'assure de d6 caractŠres au maximum
	addq #1,d6                 ; tenir compte du curseur en bout de ligne
	if STE=0
		lea ([fenetre,pc],8),a0    ; pointe sur x,y,l,h
	else
		move.l fenetre(pc),a0
		addq.l #8,a0
	endif
	move.l (a0)+,d1
	move.l (a0),d3             ; l et h
	move.l fenetre(pc),a1      ; pointe sur X,Y,L,H
	add.l (a1)+,d1
	move.l d1,vt_pts           ; coordonn‚es pour le texte
	move (a1),d5               ; L
	sub -4(a0),d5              ; L-x
	ext.l d5
	swap d3
	divs d3,d5                 ; nombre de caractŠres dans la fenˆtre
	cmp d5,d4                  ; curseur dans fenetre ?
	bmi.s .lb_y
	moveq #0,d4                ; non, on annule tout !
	moveq #0,d7
.lb_y:
	cmp d5,d6
   bpl.s .lb0
   move d6,d5                 ; fenˆtre impos‚e plus petite que l'‚cran
.lb0: move d5,vt_cont+6       ; nombre de caractŠres … afficher
   subq #1,d6
.aff:
   lea 0(a3,d7.w),a0
	move d5,d0
	lea vt_int,a1
	moveq #0,d1
.lb1: subq #1,d0              ; la fenetre jusqu'au bout
   bmi.s .lb3
	move.b (a0)+,d1            ; ou jusqu'au caractŠre nul
	beq.s .lb2
	move d1,(a1)+
	bra.s .lb1
.lb2: move #32,(a1)+          ; on comble avec des espaces si il le faut
   dbf d0,.lb2
.lb3: GEM_VDI vdi_text
   clr.l mf1
   clr.l mf2
   move d4,d0
   muls d3,d0                 ; offset curseur en points
   swap d0
   add.l vt_pts,d0
   lea copy_pts,a1
   move.l d0,(a1)+
   move.l d3,d1
   swap d1
   sub.l #$10001,d1
   add.l d0,d1
   move.l d1,(a1)+
   move.l d0,(a1)+
   move.l d1,(a1)
   GEM_VDI copy_tab
.touche:
	ifd LIB					; pour forth.lib
		tst.b aes_flag
		bne.s .touche0
		.touche1:
			move #255,-(sp)
			GEMDOS 6,4		; touche?
			move.l d0,d1
			beq.s .touche1
		swap d1
		lsl.w #8,d1			; code clavier dans octet fort
		or d1,d0				; clavier+ASCII
	   bra.s .touche2
	   .touche0:
	endif
	GEM_AES event_key
   move i_intout,d0
   cmp.b #$1b,d0
   bne.s .touche2
   move.w #$11b,d0
.touche2
   move.l end_keys,a0
   move (a0)+,a1       ; reaction pour BACKSPACE
.is_fin:
   move (a0)+,d1
   beq.s .pasfin
   cmp d0,d1
   bne.s .is_fin
   beq .fin
.pasfin:
   cmp #$4b00,d0       ; gauche
   bne.s .k0
      subq #1,d4
      bpl .lb3            ; encore dans la fenetre
      moveq #0,d4
      subq #1,d7          ; sinon, d‚cale la fenetre
      bpl .aff
      moveq #0,d7         ; on ‚tait d‚j… au d‚but !
      bra.s .touche
.k0:
   cmp #$4b34,d0     ; shift gauche
   bne.s .k1
      moveq #0,d7
      moveq #0,d4
      move.l a3,a0
   .k01:
      cmp.b #32,(a0)+ ; avance au premier caractŠre non balnc
      bne .aff        ; trouv‚!
      addq #1,d4      ; sinon avance
      cmp d5,d4       ; fenetre d‚pass‚e?
      bmi.s .k01
      subq #1,d4      ; oui, on revient dedans
      addq #1,d7      ; et on avance le fenetre
      bra .k01
.k1:
	cmp #$4d00,d0     ; droite
	bne.s .k2
	   move d7,d0
	   add d4,d0      ; l… ou on en est dans la chaine
	   tst.b 0(a3,d0.w)
	   beq .touche  ; d‚j… sur le z‚ro terminal
	   addq #1,d4     ; sinon on peut avancer
	   cmp d5,d4
	   bmi .lb3       ; encore dans la fenetre
	   move d5,d4
	   subq #1,d4
	   addq #1,d7     ; on d‚cale la fenetre
	   bra .aff
.k2:
   cmp #$4d36,d0     ; shift droite
   bne.s .k3
      move d7,d0
      add d4,d0      ; on en est l…
      lea 0(a3,d0.w),a0
      moveq #0,d1		; ‚vite l'espace au d‚part
   .k21:
   	cmp.b #32,d1	; si espace on ne retien pas d4/d7
   	beq.s .k20
   	move d4,d0		; sinon, garde d4/d7 derniŠre position non vide
   	swap d0
   	move d7,d0
   .k20:
   	move.b (a0)+,d1
   	beq .k22
   	addq #1,d4     ; sinon on se d‚cale
   	cmp d5,d4
   	bmi.s .k21     ; toujours dans la fenetre
   	subq #1,d4
   	addq #1,d7     ; sinon, c'est la fenetre qu'on d‚cale
   	bra.s .k21
   .k22:
   	move d0,d7
   	swap d0
   	move d0,d4
   	bra .aff
.k3:
	cmp.b #$1b,d0     ; escape
	bne.s .k4
	   moveq #0,d4
	   moveq #0,d7
	   clr.b (a3)
	   bra .aff
.k4:
	cmp #$537f,d0     ; delete
	bne.s .k5
	.k41:
   	move d7,d0
   	add d4,d0
   	lea 0(a3,d0.w),a0
   	tst.b (a0)     ; d‚j… la fin?
   	beq .touche
   .k40:
   	move.b 1(a0),(a0)+
   	bne.s .k40
   	bra .aff
.k5:
	cmp #$0e08,d0     ; backspace
	bne.s .k6
      subq #1,d4
      bpl.s .k41     ; comme pour delete
      moveq #0,d4
      subq #1,d7
      bpl.s .k41
      moveq #0,d7    ; on est sur la premiŠre colonne
      cmp #0,a1
      beq .touche    ; mode direct, pas de sortie
      bra .fin
.k6:
	cmp.b #13,d0      ; enter
	bne.s .k7
		bra .fin
.k7:
	cmp #$0f09,d0     ; TAB
	bne.s .k8
		move d7,d0
		add d4,d0      ; on en est l…
		addq #3,d0     ; plus la tabulation
		cmp d6,d0
	   bpl .touche    ; impossible, c'est complet!
	   lea -3(a3,d0.w),a0
	   moveq #0,d0    ; encore dans la fenetre
	   moveq #2,d1    ; boucle
	.k71:
		tst.b (a0)     ; y avait-il d‚j… des caractŠres?
		bne.s .k72
		move.b #32,(a0); si non, on met des espaces
		clr.b 1(a0)
   .k72:
      addq.l #1,a0
   	addq #1,d4     ; avance
	   cmp d5,d4
	   bmi.s .k73     ; encore dans la fenetre
	   moveq #1,d0    ; plus dans la fenetre
	   move d5,d4
	   subq #1,d4
	   addq #1,d7     ; on d‚cale la fenetre
	.k73:
	   dbf d1,.k71
	   tst d0
	   beq .lb3
	   bra .aff
.k8:
   and #$ff,d0       ; ne garde que le code ASCI
	cmp #32,d0
	bmi .touche       ; code en dessous de l'espace
      move d7,d1
      add d4,d1
      cmp d6,d1
      bpl .touche    ; c'est complet !
      lea 0(a3,d1.w),a0
   .k80:
      move.b (a0),d1
      move.b d0,(a0)+
      beq .k81       ; fini? on va … droite
      move.b d1,d0
      bra.s .k80
   .k81:
      addq #1,d4     ; avancer
	   cmp d5,d4
	   bmi .aff       ; encore dans la fenetre
	   move d5,d4
	   subq #1,d4
	   addq #1,d7     ; on d‚cale la fenetre
	   bra .aff
.fin:
   ; garde d4,d7 intacts: position du curseur!
   move d0,-(sp)
   move.l a3,a0      ; la chaine au d‚but
	move d5,d0        ; taille de la fenetre
	lea vt_int,a1
	moveq #0,d1
.f1: subq #1,d0              ; la fenetre jusqu'au bout
   bmi.s .f3
	move.b (a0)+,d1            ; ou jusqu'au caractŠre nul
	beq.s .f2
	move d1,(a1)+
	bra.s .f1
.f2: move #32,(a1)+          ; on comble avec des espaces si il le faut
   dbf d0,.f2
.f3: GEM_VDI vdi_text  ; pour virer le curseur
	move (sp)+,d0
	rts

nova_init:                   ; doit conserver D0.l intact
	move.l $5a0.w,a0
	cmp.l #0,a0
	beq.s .non
.boucle:
   tst.l (a0)
   beq.s .non
   cmp.l #"MiNT",(a0)
   bne.s .lb0
   move #1,mint_flag
   addq.l #8,a0
   bra.s .boucle
.lb0:
	cmp.l #"IMNE",(a0)+
	beq.s .oui
	addq.l #4,a0
	bra.s .boucle
.oui: move #1,nova_flag
   move.l (a0)+,nova_icb
   bra.s .boucle
.non: rts

nova_flag: dc.w 0
nova_icb: dc.l 0
nova_plot: dc.w $ffff
mint_flag: dc.w 0

cookie_flag: dc.w 0
cookie_val: dc.l 0

	NON
cookie:
	move #0,cookie_flag  ; par d‚faut, il n'existe pas
   move (a5),d1
	lea ordres,a0
	moveq #0,d2
	bra.s .lb1
.lb0:
	move.b (a0)+,d2      ; longueur du mot
	add.w d2,a0          ; saute le mot
.lb1:
	dbf d1,.lb0
	cmp.b #4,(a0)+       ; le cookie doit avoir 4 lettres
	bne.s .non
	lea mot,a1
	move.b (a0)+,(a1)+
	move.b (a0)+,(a1)+
	move.b (a0)+,(a1)+
	move.b (a0),(a1)     ; copie les 4 lettres dans mot
	pea _cookie
	XBIOS 38,6           ; remplit cookie_flag et cookie_val
.non:
	move.l topprg,a2
   move (a5)+,d0
   if STE=0
   	move.l a2,(adresse,d0.w*4)
   else
   	lea adresse,a0
   	asl #2,d0
   	add d0,a0
   	move.l a2,(a0)
   endif
	move #437,(a2)+
	tst cookie_flag
	bne.s .oui
	move.l .nul,(a2)+
	bra.s .fin
.oui:
	lea .ddd(pc),a0
	move (a0),(a2)+    ; move.l #...,-(a6)
	addq.l #6,a0
	move.l cookie_val,(a2)+
	move.l (a0)+,(a2)+
	move (a0),(a2)+
.fin:
	move.l a2,topprg
	bsr cache_off
	rts
.nul: clr.l -(a6)
	rts
.ddd: move.l #"COOK",-(a6)
	moveq #1,d0
	move.l d0,-(a6)
	rts

_cookie:
	move.l $5a0.w,a0
	cmp.l #0,a0
	beq.s .non
   move.l mot,d0       ; le mot sur 4 octets
.boucle:
   tst.l (a0)
   beq.s .non
   cmp.l (a0)+,d0
   beq.s .lb0          ; trouv‚!
   addq.l #4,a0        ; saute la valeur
   bra.s .boucle
.lb0:
	move #1,cookie_flag
	move.l (a0),cookie_val
.non: rts

   ASS 0
empile: move.l (a5)+,-(a6)
   rts

   NON
vayab: bsr ttt
   bne.s .lb0
   move #140,(a2)+
   clr.l (a2)+
   move.l a2,(a0)
   rts
.lb0: clr.l (a3)+
   move.l a3,(a1)
   bra spass
spvar: move.l (a6),a0
   move.l (a0),a0
   dc.w $d1fc
   move.l a0,(a6)
   rts

_appl_getinfo: dc.l agi_cont,global,agi_int,dum,addrin,dum
agi_cont: dc.w 130,1,1,4,0
agi_int: dc.w 96

appl_init: dc.l ai_cont,global,dum,appl_id,dum,dum
ai_cont: dc.w 10,0,1,0,0
appl_id: dc.w 0

appl_exit: dc.l ae_cont,global,dum,intout,dum,dum
ae_cont: dc.w 19,0,1,0,0

graf_hand: dc.l gh_cont,global,dum,intout,dum,dum
gh_cont: dc.w 77,0,5,0,0

mouse_form: dc.l mf_cont,global,mf_int,intout,dum,dum
mf_cont: dc.w 78,1,1,1,0
mf_int: dc.w 0

hide_mouse: dc.l hm_cont,dum,dum,dum,dum
hm_cont: dc.w 123,0,0,0,0,0,0,0,0,0,0,0

show_mouse: dc.l sm_cont,sm_int,dum,dum,dum
sm_cont: dc.w 122,0,0,1,0,0,0,0,0,0,0,0
sm_int: dc.w 1

vq_mouse: dc.l vq_cont,dum,dum,vq_out,vq_out+2
vq_cont: dc.w 124,0,0,0,0,0,0,0,0,0,0,0
vq_out: dc.w 0,0,0

open_work: dc.l ow_cont,ow_int,dum,work_out,ptsout
ow_cont: dc.w 100,0,0,11,0,0,0,0,0,0,0,0
ow_int: dc.w 2,1,1,1,1,1,1,0,1,0,2

close_work: dc.l cw_cont,dum,dum,dum,dum
cw_cont: dc.w 101,0,0,0,0,0,0,0,0,0,0,0

menu_reg: dc.l mr_cont,global,appl_id,dum,menu_nom,dum
mr_cont: dc.w 35,1,1,1,0
menu_nom: dc.l _menu_nom

wind_get0: dc.l wg_cont,global,wg_int,wg_out,dum,dum
wg_cont: dc.w 104,2,5,0,0
wg_int: dc.w 0,4
wg_out: dc.w 0,0,0,16,2		; valeurs pour ScreenEncoding au d‚marrage
maxi_xylh: dc.w 0,0,0,0

wind_get1: dc.l wg_cont,global,wg_int,w_travail,dum,dum
w_travail: dc.w 0,0,0,0,0

wind_set: dc.l ws_cont,global,ws_int,dum,dum,dum
ws_cont: dc.w 105,6,1,0,0
ws_int: dc.w 0,0,0,0,0,0

wind_calc: dc.l wca_cont,global,vt_int+16,vt_int+28,dum,dum
wca_cont: dc.w 108,6,5,0,0

wind_update: dc.l wu_cont,global,wu_int,dum,dum,dum
wu_cont: dc.w 107,1,1,0,0
wu_int: dc.w 0

wind_mask: dc.w $29

wind_create: dc.l wc_cont,global,wg_out,w_hand,dum,dum
wc_cont: dc.w 100,5,1,0,0
w_hand: dc.w -1            ; n‚gatif tant qu'aucune n'est ouverte...
w_hand_sav: dc.w 0

wind_open: dc.l wo_cont,global,wg_out,dum,dum,dum
wo_cont: dc.w 101,5,1,0,0

wind_close: dc.l wl_cont,global,w_hand,dum,dum,dum
wl_cont: dc.w 102,1,1,0,0

wind_del: dc.l wd_cont,global,w_hand,dum,dum,dum
wd_cont: dc.w 103,1,1,0,0

wind_set_title: dc.l wst_cont,global,wst_in,dum,dum,dum
wst_cont: dc.w 105,6,1,0,0
wst_in: dc.l 2,w_titre,0

copy_tab: dc.l copy_cont,copy_int,copy_pts,dum,dum
copy_cont: dc.w 109,4,0,1,0,0,0
           dc.l mf1,mf2
copy_int: dc.w 3

fill_rect: dc.l fr_cont,dum,copy_pts,dum,dum
fr_cont: dc.w 114,2,0,0,0,0,0,0,0,0,0,0

event_key: dc.l ek_cont,global,dum,i_intout,dum,dum
ek_cont: dc.w 20,0,1,0,0

event_mesag: dc.l em_cont,global,dum,dum,em_addr,dum
em_cont: dc.w 23,0,1,1,0
em_addr: dc.l vt_int

text_align: dc.l ta_cont,ta_int,dum,intout,dum
ta_cont: dc.w 39,0,0,2,0,0,0,0,0,0,0,0
ta_int: dc.w 0,5

text_attributes: dc.l tat_con,dum,dum,ta_intout,ta_ptsout
tat_con:	dc.w 38,0,0,0,0,0,0,0,0,0,0,0
ta_intout: dc.w 0,0,0,0,0,0
ta_ptsout: dc.w 0,0,0,0

vdi_text: dc.l vt_cont,vt_int,vt_pts,dum,dum
vt_cont: dc.w 8,1,0,256,0,0,0,0,0,0,0,0
vt_pts: dc.w 0,0

fenetre: dc.l fenetre0

; X,Y,L,H puis x,y ( curseur ) l,h ( caractŠre )

fenetre0: dc.w 0,0,0,0,0,0,0,0

_menu_nom: dc.b "  FORTH "
	VERSION
	dc.b 0,0
   even

	ifnd LIB					; seulement dans l'interpr‚teur
souris_visible:
	tst.b mouse_on
	beq.s .exit
	GEM_VDI show_mouse
.exit:
	rts

	SAUT
ver: move.l #.chaine,a0
	bra write_str
.chaine:
	IF STE=1
		dc.b "STE "
	else
		dc.b "TT "
	endif
	VERSION
	dc.b " ("
	DATE
	dc.b ")",0
	even

	else

	SAUT
ver: rts

	endif

fastopen:
	ifd LIB
		tst.b aes_flag						  ; seulement dans FORTH.LIB
		beq .auto
	endif
   clr wg_int
	GEM_AES wind_get0
	lea wg_out,a0
	move wind_mask,(a0)+					; nom+mover+sizer
	lea maxi_xylh,a1						; taille max pour ma fenetre
	move.l (a0)+,d0						; x,y
	move.l (a0),d1							; l,h
	move.l d0,(a1)+						; conserve la taille max
	move.l d1,(a1)
	ifnd LIB									; seulement dans l'interpr‚teur
		move screen_percent,d7
		moveq #100,d6
		cmp d6,d7
		bpl.s .full								; 100 or more = full screen
		move d1,d2								; h
		muls d7,d2
		divs d6,d2								; new h*n%
		sub d2,d1
		lsr #1,d1								; (H-h)/2
		add d1,d0								; new Y = y + (H-h)/2
		move d2,d1								; replace new h
		swap d1
		swap d0
		move d1,d2								; l
		muls d7,d2
		divs d6,d2								; new l*n%
		sub d2,d1
		lsr #1,d1								; (L-l)/2
		add d1,d0								; new X = x + (L-l)/2
		move d2,d1								; replace new l
		swap d0
		swap d1
		move.l d1,(a0)						; l,h
		move.l d0,-(a0)					; x,y
	.full:
	endif
	GEM_AES wind_create
	move w_hand,d7
   move d7,wst_in
   move d7,ws_int
   GEM_AES wind_set_title
	move d7,wg_out
	GEM_AES wind_open
   move d7,wg_int
	GEM_AES wind_get1
   move.l #fenetre0,a0
   move.l a0,-(a6)
   lea w_travail+2,a1
   move.l (a1)+,(a0)+
   move.l (a1)+,(a0)+
	bsr cls
   bsr setp
	GEM_VDI text_align         ; point en haut … gauche
	rts

	ifd LIB
.auto:
	bsr ouvre_vdi
	move #1,w_hand					; handle fictif
	GEM_VDI text_attributes
	lea fenetre0,a0
	move.l a0,-(a6)
	clr.l (a0)+						; X=Y=0 d‚part de l'‚cran
	move.l work_out,(a0)			; L-1, H-1
	add.l #$10001,(a0)+			; L H
	clr.l (a0)+						; x=y=0, curseur en haut
	move.l ta_ptsout+4,(a0)		; l,h d'un caractŠre
	bsr setp
	bsr cls
	GEM_VDI text_align
	rts
	endif

fastclose:
	ifd LIB
		tst.b aes_flag
		beq.s .fin
	endif
   GEM_AES wind_close
   GEM_AES wind_del
.fin:
   rts

; a0 pointe sur la chaine se terminant par 0
; les coordonn‚es du curseur sont dans la structure fenetre
; utilise d0,d1,d2,d3,d4, a0,a1,a2

write_str:
   moveq #0,d1                ; nombre de caractŠres
	lea vt_int,a1
	moveq #0,d0
	if STE=0
		lea ([fenetre,pc],8.w),a2
	else
		move.l fenetre(pc),a2
		addq.l #8,a2
	endif
	move.l (a2)+,d2              ; x et y
	move.l d2,vt_pts
	swap d2                      ; reprend x
	move (a2),d3                 ; l
	move.l fenetre(pc),a2
   move.l (a2)+,d4
	add.l d4,vt_pts
	move (a2),d4                 ; L
.autre:
   add d3,d2
   cmp d2,d4
   bpl.s .place
   tst.b (a0)                   ; mais, sommes nous … la fin?
   beq.s .fin
   move d1,vt_cont+6            ; nombre de caractŠres
   move.l a0,-(sp)
   GEM_VDI vdi_text
   bsr cr
   move.l (sp)+,a0
   bra.s write_str
.place:
   move.b (a0)+,d0              ; caractŠre suivant
   beq.s .fin
   addq #1,d1
   move d0,(a1)+
   bra.s .autre
.fin:
	move d1,vt_cont+6
   sub d3,d2
	if STE=0
		move d2,([fenetre],8.w)     ; actualise x
	else
		move.l fenetre,a0
		move d2,8(a0)
	endif
	GEM_VDI vdi_text
	rts

   NON
page: bsr ttt
   bne.s .lb0
   move #140,(a2)+
   add.w #16,a2
   move.l a2,(a0)
   rts
.lb0: add.w #16,a3
   move.l a3,(a1)
   bra spass

   NON
const: bsr.s ttt
   bne.s .lb0
   move #141,(a2)+
   move.l (a6)+,(a2)+
   move.l a2,(a0)
   rts
.lb0: move.l (a6)+,(a3)+
   move.l a3,(a1)
   move.l #.lb1,a1
   move.l (a1)+,(a2)+
   move (a1)+,(a2)+
   move.l d4,(a2)+
   move.l (a1)+,(a2)+
   move.l a2,(a0)
   rts
.lb1: move.l (a6),a0
   move.l (a0),a0
   dc.w $d1fc
   move.l (a0),(a6)
   rts

   NON
array: bsr.s ttt
   bne.s .lb2
   move #142,(a2)+
   move.l (a6)+,d1
   subq.l #1,d1
.lb1: clr.l (a2)+
   dbf d1,.lb1
   move.l a2,(a0)
   rts
.lb2: move.l (a6)+,d1
   subq.l #1,d1
.lb3: clr.l (a3)+
   dbf d1,.lb3
   move.l a3,(a1)
   move.l #.lb4,a1
   move.l (a1)+,(a2)+
   move (a1)+,(a2)+
   subq.l #4,d4
   move.l d4,(a2)+
   move.l (a1)+,(a2)+
   move.l (a1)+,(a2)+
   move (a1),(a2)+
   move.l a2,(a0)
   rts
.lb4: move.l (a6)+,a0
   move.l (a0),a0
   dc.w $d1fc
   move.l (a6),d1
   lsl.l #2,d1
   add.l d1,a0
   move.l a0,(a6)
   rts


ttt: move (a5)+,d4
   ext.l d4
   lsl.l #2,d4
   lea adresse,a3
   add.l d4,a3
   move.l #topprg,a0
   move.l (a0),a2
   move.l a2,(a3)
   tst stt
   beq.s .fin
   move #437,(a2)+
   move.l #sttptr,a1
   move.l (a1),d4
   move.l d4,a3
   sub.l #sttdata,d4
.fin: tst stt
   rts

   NON
table: bsr.s ttt
   move #145,(a2)+
   move.l a2,(a0)
   rts

   NON
string: bsr.s ttt
   bne.s .lb0
   move #143,(a2)+
   move.l (a6)+,d4
   move d4,(a2)+
   clr.b (a2)
   addq #2,d4
   bclr #0,d4
   add.w d4,a2
   move.l a2,(a0)
   rts
.lb0: move.l (a6)+,d0
   move d0,(a3)+
   clr.b (a3)
   addq #2,d0
   bclr #0,d0
   add.w d0,a3
   move.l a3,(a1)
   addq.l #2,d4
spass: move.l #spvar,a1
   move.l (a1)+,(a2)+
   move (a1)+,(a2)+
   move.l d4,(a2)+
   move.l (a1),(a2)+
   move.l a2,(a0)
   rts

   NON
charray: bsr ttt
   bne.s .lb2
   move #144,(a2)+
   move.l (a6)+,d4
   move.l (a6)+,d2
   move d2,d1
   addq #2,d2
   bclr #0,d2
   subq.l #1,d4
.lb1: move d1,(a2)+
   clr.b (a2)
   add.w d2,a2
   dbf d4,.lb1
   move.l a2,(a0)
   rts
.lb2: move.l (a6)+,d0
   move.l (a6)+,d1
   move.l d1,d2
   addq #2,d1
   bclr #0,d1
   subq.l #1,d0
.lb3: move d2,(a3)+
   clr.b (a3)
   add.w d1,a3
   dbf d0,.lb3
   move.l a3,(a1)
   move.l #.lb4,a1
   move.l (a1)+,(a2)+
   move (a1)+,(a2)+
   move.l d4,(a2)+
   rept 5
   move.l (a1)+,(a2)+
   endr
   move.l a2,(a0)
   rts
.lb4: move.l (a6)+,a0
   move.l (a0),a0
   dc.w $d1fc
   move (a0)+,d0
   move.l (a6),d1
   subq.l #1,d1
   addq.l #4,d0
   bclr #0,d0
   muls d0,d1
   add.l d1,a0
   move.l a0,(a6)
   rts

   NON
ouvert: bsr ttt
   move #1,setnbr
   move -2(a5),setdeb
   move #628,(a2)+
   move -2(a5),(a2)+
   move.l a2,(a0)
   rts

   NON
et: bsr ttt
   addq #1,setnbr
   move #628,(a2)+
   move -2(a5),(a2)+
   move.l a2,(a0)
   rts

   NON
ferme: bsr ttt
   move #140,(a2)+
   move setdeb,(a2)+
   move setnbr,(a2)+
   move.l a2,(a0)
   rts

   NON
setof: bsr ttt
   bne.s .lb2
   move #140,(a2)+
   move.l (a6)+,a1
   move (a1)+,(a2)+
   move (a1),d0
   move d0,(a2)+
   move d0,d1
   lsr.l #4,d0
   and #$f,d1
   bne.s .lb1
   subq #1,d0
.lb1: clr (a2)+
   dbf d0,.lb1
   move.l a2,(a0)
   rts
.lb2: move.l a4,-(sp)
   move.l (a6)+,a4
   move (a4)+,(a3)+
   move (a4),d0
   move d0,(a3)+
   move d0,d1
   move.l (sp)+,a4
   lsr.l #4,d0
   and #$f,d1
   bne.s .lb3
   subq #1,d0
.lb3: clr (a3)+
   dbf d0,.lb3
   move.l a3,(a1)
   bra spass

   NON
segment: bsr ttt
   move.l (a6)+,d1
   move.l (a6)+,d0
   tst stt
   bne.s .lb2
   move #140,(a2)+
   move d1,(a2)+
   subq #1,d1
   sub d1,d0
   move d0,(a2)+
   move d0,d1
   lsr #4,d0
   and #$f,d1
   bne.s .lb1
   subq #1,d0
.lb1: clr (a2)+
   dbf d0,.lb1
   move.l a2,(a0)
   rts
.lb2: move d1,(a3)+
   subq #1,d1
   sub d1,d0
   move d0,(a3)+
   move d0,d1
   lsr #4,d0
   and #$f,d1
   bne.s .lb3
   subq #1,d0
.lb3: clr (a3)+
   dbf d0,.lb3
   move.l a3,(a1)
   bra spass

   NON
float: bsr ttt
   bne.s .lb0
   move #140,(a2)+
   clr.l (a2)+
   clr.l (a2)+
   move.l a2,(a0)
   rts
.lb0: clr.l (a3)+
   clr.l (a3)+
   move.l a3,(a1)
   bra spass

   NON
stack: bsr ttt
   move.l (a6)+,d0
   lsl.l #2,d0
   tst stt
   bne.s .lb0
   move #141,(a2)+
   lea 4(a2,d0),a1
   move.l a1,(a2)
   clr.l (a1)+
   move.l a1,(a0)
   rts
.lb0: add.l d0,d4
   add.l d0,a3
   clr.l (a3)+
   move.l a3,(a1)
   bra spass

   SAUT
appl_search:
	A1 18,1,1,3

   SAUT
appl_tplay:
	A1 14,2,1,1

   NON
pointer: bsr ttt
   bne.s .lb0
   move.l (a6)+,a1
   move #140,(a2)+
   clr.l (a2)+
   move.l 4(a1),(a2)+
   move.l a2,(a0)
   rts
.lb0: clr.l (a3)+
   move.l a4,-(sp)
   move.l (a6)+,a4
   move.l 4(a4),(a3)+
   move.l a3,(a1)
   move.l (sp)+,a4
   bra spass

   NON
wvar: bsr ttt
   bne.s .lb0
   move #140,(a2)+
   clr (a2)+
   move.l a2,(a0)
   rts
.lb0: clr (a3)+
   move.l a3,(a1)
   bra spass

   NON
warray: bsr ttt
   bne.s .lb2
   move #706,(a2)+
   move.l (a6)+,d1
   subq.l #1,d1
.lb1: clr (a2)+
   dbf d1,.lb1
   move.l a2,(a0)
   rts
.lb2: move.l (a6)+,d1
   subq.l #1,d1
.lb3: clr (a3)+
   dbf d1,.lb3
   move.l a3,(a1)
   move.l #.lb4,a1
   move.l (a1)+,(a2)+
   move (a1)+,(a2)+
   subq.l #2,d4
   move.l d4,(a2)+
   move.l (a1)+,(a2)+
   move.l (a1)+,(a2)+
   move (a1),(a2)+
   move.l a2,(a0)
   rts
.lb4: move.l (a6)+,a0
   move.l (a0),a0
   dc.w $d1fc
   move.l (a6),d1
   add.l d1,d1
   add.l d1,a0
   move.l a0,(a6)
   rts

   COPIE ret1,y1
ret1: move.l (a6)+,-(a4)
y1:   rts

   COPIE ret2,y2
ret2: move.l (a4)+,-(a6)
y2:   rts

   COPIE raff,y3
raff: move.l (a4),-(a6)
y3:   rts

   COPIE dup2,y4
dup2: move.l (a6),-(a6)
   bne.s y4
   addq.l #4,a6
y4: rts

   COPIE depth,y5,1
depth: move.l pilbase,d1
   sub.l a6,d1
   asr.l #2,d1
   move.l d1,-(a6)
y5:  rts

   COPIE drop,y6
drop: UP
y6:  rts

   COPIE dup,y7
dup: move.l (a6),-(a6)
y7:  rts

   COPIE over,y8
over: move.l 4(a6),-(a6)
y8:  rts

   COPIE pick,y9
pick: move.l (a6)+,d1
   if STE=0
   	move.l (a6,d1.l*4),-(a6)
   else
   	asl.l #2,d1
   	move.l 0(a6,d1.l),-(a6)
   endif
y9: rts

   COPIE rzer,y10,1
rzer: move.l #retour+4100,d1
	and.b #$fc,d1
	move.l d1,-(a6)
y10:  rts

   COPIE roll,y11
roll: move.l (a6)+,d1
   move.l (a6),d2
   move.l a6,d3
   subq #2,d1
   bmi.s y11
.lb1: move.l 4(a6),(a6)+
   dbf d1,.lb1
   move.l d2,(a6)
   move.l d3,a6
y11: rts

   COPIE rot,y12
rot: movem.l (a6)+,d1-d3
   exg.l d1,d2
   exg.l d2,d3
   movem.l d1-d3,-(a6)
y12: rts

   COPIE rpinit,y13,1
rpinit: move.l #retour+4100,d0
	and.b #$fc,d0
	move.l d0,a4
y13: rts

   COPIE wdmod,y14
wdmod: move.l (a6)+,d1
   move.l (a6),d2
   divs d1,d2
   move.l d2,d1
   ext.l d2
   move.l d2,(a6)
   swap d1
   ext.l d1
   move.l d1,-(a6)
y14: rts

   COPIE rpaff,y15
rpaff: move.l a4,-(a6)
y15:  rts

   COPIE s0,y16,1
s0: move.l pilbase,-(a6)
y16:   rts

   COPIE spinit,y17,1
spinit: move.l pilbase,a6
y17:   rts

   COPIE wmod,y18
wmod: move.l (a6)+,d1
   move.l (a6)+,d2
   divs d1,d2
   swap d2
   ext.l d2
   move.l d2,(a6)
y18: rts

   COPIE spaff,y19
spaff: move.l a6,-(a6)
y19:   rts

   COPIE swap,y20
swap: move.l (a6)+,d0
   move.l (a6),d1
   move.l d0,(a6)
   move.l d1,-(a6)
y20: rts

   COPIE mulw,y22
mulw: move.l (a6)+,d1
   muls 2(a6),d1
   move.l d1,(a6)
y22: rts

   COPIE wdiv,y23
wdiv: move.l (a6)+,d1
   move.l (a6),d2
   divs d1,d2
   ext.l d2
   move.l d2,(a6)
y23: rts

   COPIE_OPT5 plus,y24,$0696
plus: move.l (a6)+,d1
   add.l d1,(a6)
y24: rts

   COPIE plm,y25
plm: tst.l (a6)+
   bge.s y25
   neg.l (a6)
y25: rts

   COPIE_OPT5 moins,y26,$0496
moins: move.l (a6)+,d1
   sub.l d1,(a6)
y26: rts

	if STE=0

   COPIE div,y27
div: move.l (a6)+,d0
   move.l (a6)+,d1
   divsl.l d0,d2:d1      ; reste et quotient
   move.l d1,-(a6)
y27: rts

   COPIE mod,y28
mod: move.l (a6)+,d0
   move.l (a6)+,d2
   divsl.l d0,d1:d2      ; reste et quotient
   move.l d1,-(a6)
y28: rts

   COPIE divm,y29
divm: move.l (a6)+,d0
   move.l (a6)+,d2
   divsl.l d0,d1:d2
   movem.l d1-d2,-(a6)
y29: rts

   COPIE mul,y21
mul:   move.l (a6)+,d1
   muls.l (a6)+,d1
   move.l d1,-(a6)
y21: rts

	else

	SAUT
div: bsr.s spdiv
   move.l d2,(a6)
   rts

	SAUT
mod: bsr.s spdiv
   move.l d1,(a6)
   rts

	SAUT
divm: bsr.s spdiv
   move.l d2,(a6)
   move.l d1,-(a6)
   rts

spdiv: moveq.l #1,d7
   move.l d7,d6
   move.l (a6)+,d4
   bpl.s .lb1
   neg.l d4
   neg.l d7
.lb1: move.l (a6),d3
   bpl.s .lb2
   neg.l d3
   neg.l d7
   neg.l d6
.lb2: move.l #$80000000,d0
   moveq #0,d1
   moveq #0,d2
.lb3: lsl.l #1,d1
   move.l d0,d5
   and.l d3,d5
   beq.s .lb4
   addq.l #1,d1
.lb4: lsl.l #1,d2
   cmp.l d4,d1
   bmi.s .lb5
   sub.l d4,d1
   addq.l #1,d2
.lb5: lsr.l #1,d0
   bne.s .lb3
   tst.l d7
   bpl.s .lb6
   neg.l d2
.lb6: tst.l d6
   bpl.s .lb7
   neg.l d1
.lb7: rts

	SAUT
mul: clr d2
   tst.l (a6)+
   bge.s .lb1
   neg.l -4(a6)
   moveq #1,d2
.lb1: tst.l (a6)
   bge.s .lb2
   neg.l (a6)
   addq #1,d2
.lb2: move -2(a6),d0
   mulu 2(a6),d0
   move -4(a6),d1
   mulu 2(a6),d1
   move (a6),d3
   mulu -2(a6),d3
   add d3,d1
   move.l d0,(a6)
   add d1,(a6)
   btst #0,d2
   beq.s .lb3
   neg.l (a6)
.lb3: rts

	endif

   COPIE inf0,y30
inf0: moveq #0,d1
   tst.l (a6)+
   smi d1
   neg.b d1
   move.l d1,-(a6)
y30: rts

   COPIE eg0,y31
eg0: moveq #0,d1
   tst.l (a6)+
   seq d1
   neg.b d1
   move.l d1,-(a6)
y31: rts

   COPIE sup0,y32
sup0: moveq #0,d1
   tst.l (a6)+
   sgt d1
   neg.b d1
   move.l d1,-(a6)
y32: rts

   COPIE_OPT6 sup,y33
sup:
   move.l (a6)+,d1
	moveq #0,d0
   cmp.l (a6),d1
   smi d0
   neg.b d0
   move.l d0,(a6)
y33: rts

   COPIE_OPT6 inf,y34
inf:
   move.l (a6)+,d1
	moveq #0,d0
   cmp.l (a6),d1
   sgt d0
   neg.b d0
   move.l d0,(a6)
y34: rts

   COPIE_OPT6 egal,y35
egal:
   move.l (a6)+,d1
	moveq #0,d0
   cmp.l (a6),d1
   seq d0
   neg.b d0
   move.l d0,(a6)
y35: rts

   COPIE plus1,y36
plus1: addq.l #1,(a6)
y36: rts

   COPIE moins1,y37
moins1: subq.l #1,(a6)
y37: rts

   COPIE plus2,y38
plus2: addq.l #2,(a6)
y38: rts

   COPIE moins2,y39
moins2: subq.l #2,(a6)
y39: rts

   COPIE mul2,y40
mul2: move.l (a6)+,d1
   asl.l #1,d1
   move.l d1,-(a6)
y40: rts

   COPIE div2,y41
div2: move.l (a6)+,d1
   asr.l #1,d1
   move.l d1,-(a6)
y41: rts

   COPIE abs,y42
abs: tst.l (a6)
   bpl.s y42
   neg.l (a6)
y42: rts

   COPIE_OPT4 and,y43,$0296
and: move.l (a6)+,d1
   and.l d1,(a6)
y43: rts

   COPIE max,y44
max: move.l (a6)+,d1
   cmp.l (a6)+,d1
   bmi.s y44
   move.l d1,-(a6)
y44: rts

   COPIE min,y45
min: move.l (a6)+,d1
   cmp.l (a6)+,d1
   bpl.s y45
   move.l d1,-(a6)
y45: rts

   COPIE neg,y46
neg: neg.l (a6)
y46: rts

   COPIE not,y47
not: not.l (a6)
y47: rts

   COPIE_OPT4 or,y48,$0096
or: move.l (a6)+,d1
   or.l d1,(a6)
y48: rts

   COPIE_OPT4 xor,y49,$0A96
xor: move.l (a6)+,d1
   eor.l d1,(a6)
y49: rts

   ASS 4
loop: addq.l #1,(a4)
   move.l (a4),d1
   cmp.l 4(a4),d1
   bpl.s .lb1
   move.l 8(a4),a5
   rts
.lb1: add.w #12,a4
   subq.l #4,indptr
   rts

   ASS 5
looppls: move.l (a6)+,d1
   ble.s .lb2
   add.l d1,(a4)
   move.l (a4),d1
   cmp.l 4(a4),d1
   bmi.s .lb1
.lb0: add.w #12,a4
   subq.l #4,indptr
   rts
.lb1: move.l 8(a4),a5
   rts
.lb2: add.l d1,(a4)
   move.l (a4),d1
   cmp.l 4(a4),d1
   bpl.s .lb1
   bra.s .lb0

   ASS 6
do: move.l a5,-(a4)
   move.l (a6)+,d1
   move.l (a6)+,-(a4)
   move.l d1,-(a4)
   move.l #indptr,a1
   addq.l #4,(a1)
   move.l (a1),a2
   move.l a4,(a2)
   rts

   ASS 8
again: move.l (a4),a5
   rts

   ASS 7
begin: move.l a5,-(a4)
   rts

   ASS 9
until: tst.l (a6)+
   bne.s .lb1
   move.l (a4),a5
   rts
.lb1: addq.l #4,a4
   rts

   ASS 25
of: move.l (a6)+,d1
   cmp.l (a6),d1
   beq.s .lb1
   add.w (a5)+,a5
   rts
.lb1: addq.l #2,a5
   UP
   rts

   ASS 33
difof: move.l (a6)+,d1
   cmp.l (a6),d1
   bne.s .lb1
   add.w (a5)+,a5
   rts
.lb1: addq.l #2,a5
   UP
   rts

   ASS 34
supof: move.l (a6)+,d1
   cmp.l (a6),d1
   bmi.s .lb1
   add.w (a5)+,a5
   rts
.lb1: addq.l #2,a5
   UP
   rts

   ASS 35
infof: move.l (a6)+,d1
   cmp.l (a6),d1
   bgt.s .lb1
   add.w (a5)+,a5
   rts
.lb1:  addq.l #2,a5
   UP
   rts

   ASS 13
if: tst.l (a6)+
   bne.s .lb1
   add.w (a5)+,a5
   rts
.lb1: addq.l #2,a5
   rts

   ASS 10
while: tst.l (a6)+
   bne.s .lb1
   add.w (a5)+,a5
   addq.l #4,a4
   rts
.lb1: addq.l #2,a5
   rts

   ASS 11
repeat: move.l (a4),a5
   rts

   ASS 14
else: add.w (a5)+,a5
   rts

   ASS 15
then: rts

   ASS 24
endcase: rts

   ASS 23
case: rts

   SAUT
appl_find:
	A1 13,0,1,1

   COPIE i,y50,1
i: move.l indptr,a1
	if STE=0
	   move.l ([a1]),-(a6)
	else
		move.l (a1),a1
		move.l (a1),-(a6)
	endif
y50: rts

   COPIE j,y51,1
j: move.l indptr,a1
	if STE=0
	   move.l ([-4.w,a1]),-(a6)
	else
		move.l -4(a1),a1
		move.l (a1),-(a6)
	endif
y51: rts

   COPIE k,y52,1
k: move.l indptr,a1
	if STE=0
	   move.l ([-8.w,a1]),-(a6)
	else
		move.l -8(a1),a1
		move.l (a1),-(a6)
	endif
y52: rts

   COPIE leave,y53,1
leave:
	if STE=0
		move.l ([indptr]),a0
	else
		move.l indptr,a0
		move.l (a0),a0
	endif
	move.l 4(a0),(a0)
y53: rts

   COPIE virg,y54,1
virg: move.l topprg,a0
   move.l (a6)+,(a0)+
   move.l a0,topprg
y54: rts

   ASS 12
exit: move.l (a4)+,a5
   rts

   ASS -1
pvirg: move.l (a4)+,a5
   rts

   COPIE allot,y55,1
allot: move.l (a6)+,d1
   addq.l #1,d1
   bclr #0,d1
   move.l topprg,-(a6)
   add.l d1,topprg
y55: rts

   SAUT
allot0: move.l (a6),d1
   addq.l #1,d1
   bclr #0,d1
   move.l topprg,a2
   add.l d1,topprg
   move.l a2,(a6)
   move d1,d0
   and #$3f,d0
   lsr.l #6,d1
   subq #1,d1
   bmi.s .lb1
.lb0:
   rept 16
   clr.l (a2)+
   endr
   dbf d1,.lb0
.lb1: subq #1,d0
   bmi.s .lb3
.lb2: clr.b (a2)+
   dbf d0,.lb2
.lb3: rts

   SAUT
chsto: move.l (a6)+,a3
   move.l (a6)+,a2
   move -2(a2),d1
   move -2(a3),d2
   move d1,d3
   cmp d1,d2
   bgt.s .lb1
   move d2,d3
   bra.s .lb1
.lb2: move.b (a2)+,(a3)+
.lb1: dbeq d3,.lb2
;   beq.s .lb3
;   cmp.l d1,d2
;   ble.s .lb3
   clr.b (a3)
.lb3: rts

   SAUT
chplus: move.l (a6)+,a1
   move.l (a6)+,a2
   move -2(a1),d1
   move -2(a2),d2
   bra.s .lb0
.lb1: tst.b (a1)+
.lb0: dbeq d1,.lb1
   bne.s .fin
   subq.l #1,a1
   addq #1,d1
   subq #1,d2
   cmp d2,d1
   bpl.s .lb2
   move d1,d2
.lb2: move.b (a2)+,(a1)+
   dbeq d2,.lb2
.fin: rts

   SAUT
chegal: bsr.s strcomp
   bne.s .lb1
   moveq #1,d0
.lb1: move.l d0,(a6)
   rts

   SAUT
chsup: bsr.s strcomp
   bpl.s .lb1
   moveq #1,d0
.lb1: move.l d0,(a6)
   rts

   SAUT
chinf: bsr.s strcomp
   ble.s .lb1
   moveq #1,d0
.lb1: move.l d0,(a6)
   rts

strcomp: move.l (a6)+,a0
   move.l (a6),a1
.lb1: move.b (a0)+,d1
   sub.b (a1),d1
   bne.s .lb2
   tst.b (a1)+
   bne.s .lb1
.lb2: moveq #0,d0
   tst.b d1
   rts

   COPIE asc,y56
carrcl:
asc: moveq #0,d1
	if STE=0
	   move.b ([a6]),d1
	else
		move.l (a6),a0
		move.b (a0),d1
	endif
   move.l d1,(a6)
y56: rts

   COPIE bbase,y57,1
bbase: move.l #base,-(a6)
y57: rts

   COPIE chr,y58,1
chr: move.l (a6)+,d1
   move.l #pad+2,a0
   move.l a0,-(a6)
   lsl #8,d1
   move d1,(a0)
y58: rts

   COPIE decimal,y59,1
decimal: moveq #10,d1
   move.l d1,base
y59: rts

   COPIE hex,y60,1
hex: moveq #16,d1
   move.l d1,base
y60: rts

   SAUT
instr: move.l (a6)+,d0
   move.l d0,d4
   move.l (a6)+,a2
   moveq #-2,d2
.lb1: addq #1,d2
   tst.b (a2)+
   bne.s .lb1
   tst d2
   bpl.s  .lb11
   move.l d0,(a6)
   rts
.lb11: move.l -4(a6),a2
   move.l (a6),a1
   moveq #-2,d1
.lb2: addq #1,d1
   tst.b (a1)+
   bne.s .lb2
   move.l (a6),a1
   clr.l (a6)
   subq #1,d0
   sub.w d0,d1
   add.w d0,a1
   sub.w d2,d1
   bpl.s .lb3
   rts
.lb3: move d2,d3
   move.l a2,a0
   move.l a1,a3
.lb4: cmp.b (a3)+,(a0)+
   dbne d3,.lb4
   beq.s .lb5
   addq #1,d4
   addq.l #1,a1
   dbf d1,.lb3
   rts
.lb5: move.l d4,(a6)
   rts

   COPIE len,y61
len: move.l (a6)+,a3
   move.l a3,d0
.lb1: tst.b (a3)+
   bne.s .lb1
   sub.l d0,a3
   subq.l #1,a3
   move.l a3,-(a6)
y61: rts

   COPIE left,y62,1
left: move.l (a6)+,d1
   move.l (a6),a1
   move.l #pad,a2
   move (a2)+,d2
   move.l a2,(a6)
   move -2(a1),d3
   cmp d1,d2
   bpl.s .lb1
   move d2,d1
.lb1: cmp d1,d3
   bgt.s .lb4
   move d3,d1
	bra.s .lb4
.lb3: move.b (a1)+,(a2)+
.lb4: dbeq d1,.lb3
   clr.b (a2)
y62: rts

   SAUT
mid: move.l #pad+2,a1
   move.l (a6)+,d1
   move.l (a6)+,d2
   move.l (a6),a0
   move.l a1,(a6)
   subq #1,d1
   bmi.s .fin
   subq #2,d2
   bmi.s .lb2
.lb1: tst.b (a0)+
   dbeq d2,.lb1
   beq.s .fin
.lb2: move.b (a0)+,(a1)+
   dbeq d1,.lb2
.fin: clr.b (a1)
   rts

   COPIE mlen,y63
mlen: if STE=0
		move.w ([a6],-2.w),2(a6)
	else
		move.l (a6),a0
		move -2(a0),2(a6)
	endif
	clr (a6)
y63: rts

   COPIE ppad,y64,1
ppad: move.l #pad+2,-(a6)
y64: rts

   SAUT
right: move.l (a6)+,d1
   move.l (a6),a0
   move.l #pad+2,a1
   tst.l d1
   bgt.s .lb1
   move.l a1,(a6)
   clr.b (a1)
   rts
.lb1: tst.b (a0)+
   bne.s .lb1
   subq.l #1,a0
   sub.w d1,a0
   cmp.l (a6),a0
   bpl.s .lb2
   move.l (a6),a0
.lb2: move.l a1,(a6)
.lb3: move.b (a0)+,(a1)+
   bne.s .lb3
   rts

   COPIE str,y65,1
str: move #1,ecran
   jsr point
   move.l #pad+2,a2
   move.l a2,-(a6)
   clr ecran
.lb1: move.b (a1)+,(a2)+
   bne.s .lb1
y65: rts

   ASS 29
xplus: move.l (a6)+,d0
   add.l (a6)+,d0
   bra.s xcut1

   ASS 30
xcut: move.l (a6)+,d0
xcut1: move d0,d1
   asl #2,d1
   lea adresse,a1
   move.l 0(a1,d1.w),a1
   cmp #diko,d0
   bpl.s .lb1
   jmp (a1)
.lb1: move.l a5,-(a4)
   move.l a1,a5
   rts

   SAUT
val: move.l (a6),a0
   move -2(a0),d4
   clr d7
   clr.l (a6)
   move.l base,-(sp)
   move.b (a0),d0
   cmp.b #"%",d0
   bne.s .lba
   move.l (a7),d1
   addq.l #1,a0
   move.b (a0)+,d0
   cmp.b #"d",d0
   bne.s .lbb
   moveq #10,d1
   bra.s .lbc
.lbb: cmp.b #"h",d0
   bne.s .lbd
   moveq #16,d1
   bra.s .lbc
.lbd: cmp.b #"b",d0
   bne.s .lbe
   moveq #2,d1
   bra.s .lbc
.lbe: cmp.b #"o",d0
   bne.s .lbc
   moveq #8,d1
.lbc: move.l d1,base
   move.l (a0),d0
.lba: cmp.b #"-",d0
   bne.s .lb1
   move #1,d7
.lb0: addq.l #1,a0
   subq #1,d4
   bra.s .lb2
.lb1: cmp.b #"+",d0
   beq.s .lb0
.lb2: move.b (a0)+,d5
   beq.s .fin
   sub.b #"0",d5
   bmi.s .fin
   cmp.b #10,d5
   bmi.s .lb4
   subq.b #7,d5
   cmp.b #36,d5
   bmi.s .lb4
   sub.b #32,d5
.lb4: ext.w d5
   ext.l d5
   cmp.l base,d5
   bpl.s .fin
   subq #1,d4
   bmi.s .fin
	if STE=0
	   move.l base,d0
   	muls.l (a6),d0
   	move.l d0,(a6)
   else
   	move.l base,-(a6)
   	bsr mul
	endif
   add.l d5,(a6)
   bra.s .lb2
.fin: tst d7
   beq.s .lb5
   neg.l (a6)
.lb5: move.l (sp)+,base
   rts

   COPIE sto,y66
sto: move.l (a6)+,a2
   move.l (a6)+,(a2)
y66: rts

	COPIE isto,y666
isto:
	move.l (a6)+,a2
	move.l (a6)+,d0
	ror #8,d0
	swap d0
	ror #8,d0
	move.l d0,(a2)
y666:	rts

   COPIE stop,y67
stop: move.l (a6)+,a2
   move.l (a6)+,d1
   add.l d1,(a2)
y67: rts

   COPIE stom,y68
stom: move.l (a6)+,a2
   move.l (a6)+,d1
   sub.l d1,(a2)
y68: rts

   COPIE stop1,y69
stop1: move.l (a6)+,a2
   addq.l #1,(a2)
y69: rts

   COPIE stom1,y70
stom1: move.l (a6)+,a2
   subq.l #1,(a2)
y70: rts

	SAUT
ircl:
	if STE=0
		move.l ([a6]),d0
	else
		move.l (a6),a0
		move.l (a0),d0
	endif
	ror #8,d0
	swap d0
	ror #8,d0
	move.l d0,(a6)
	rts

   COPIE rcl,y71
rcl: if STE=0
		move.l ([a6]),(a6)
	else
		move.l (a6),a0
		move.l (a0),(a6)
	endif
y71: rts

   COPIE carsto,y72
carsto: move.l (a6)+,a2
   move.l (a6)+,d1
   move.b d1,(a2)
y72: rts

   SAUT
cls:
   lea copy_pts,a0
  	move.l fenetre,a1
  	clr.l 8(a1)				; curseur en haut … droite
   move.l (a1)+,d0
   move.l d0,(a0)+     ; x et y
   add.l (a1),d0
   sub.l #$10001,d0     ; x' et y' ( ‚gaux … x,y + l,h -1,1 )
   move.l d0,(a0)
   GEM_VDI fill_rect
   rts

   COPIE bin,y74,1
bin: moveq #2,d1
   move.l d1,base
y74:  rts

   COPIE here,y75,1
here: move.l topprg,-(a6)
y75: rts

   COPIE dupm,y76
dupm: move.l (a6)+,d1
	if STE=0
   	lea (a6,d1.w*4),a2
   else
   	lea 0(a6,d1.w),a2
   	add d1,a2
   	add d1,a2
   	add d1,a2
   endif
   bra.s .lb2
.lb1: move.l -(a2),-(a6)
.lb2: dbf d1,.lb1
y76: rts

   COPIE dropm,y77
dropm: move.l (a6)+,d1
	if STE=0
	   lea (a6,d1.l*4),a6
	else
		asl.l #2,d1
		lea 0(a6,d1.l),a6
	endif
y77: rts

   SAUT
bpt: moveq #2,d4
   bra.s pt

   SAUT
dpt: moveq #10,d4
   bra.s pt

   SAUT
opt: moveq #8,d4
   bra.s pt

   SAUT
hpt: moveq #16,d4
   bra.s pt

   SAUT
aff: move.l (a6),a2
   move.l (a2),(a6)
   bra.s point

   SAUT
point: move.l base,d4
pt: move.l (a6)+,d3
   moveq #0,d6
   tst.l d3
   bpl.s .lb1
   neg.l d3
   move.b #$2d,d6
.lb1: move.l #tamp+40,a1
   clr.b -(a1)
.lb2: move.l #$80000000,d0
   moveq #0,d1
   moveq #0,d2
.lb3: lsl.l #1,d1
   move.l d0,d5
   and.l d3,d5
   beq.s .lb4
   addq.l #1,d1
.lb4: lsl.l #1,d2
   cmp.l d4,d1
   bmi.s .lb5
   sub.l d4,d1
   addq.l #1,d2
.lb5: lsr.l #1,d0
   bne.s .lb3
   add.b #48,d1
   cmp #$3a,d1
   bmi.s .lb6
   addq.b #7,d1
.lb6: move.b d1,-(a1)
   move.l d2,d3
   bne.s .lb2
   tst d6
   beq.s .lb7
   move.b d6,-(a1)
.lb7: tst ecran
   bne.s .lb8
   move.l a1,a0
   bsr write_str
.lb8: rts

   COPIE term,y78
term: move #2,-(sp)
	BIOS 1,4
   move.l d0,-(a6)
y78: rts

   COPIE bl,y79
bl: moveq #32,d1
   move.l d1,-(a6)
y79: rts

   SAUT
cr:
	if STE=0
		lea ([fenetre,pc],8.w),a0
   	lea ([fenetre,pc]),a1
   else
   	move.l fenetre,a1
   	lea 8(a1),a0
   endif
   clr (a0)+          ; x=0, 1ø colonne
   move (a0),d0      ; y
   add 4(a0),d0      ; plus une colonne
   move 6(a1),d1     ; H
   sub 4(a0),d1      ; moins la hauteur de la ligne
   cmp d0,d1
   bmi.s .lb0        ; il faut scroller
   move d0,(a0)      ; sinon, colonne valable
   rts
.lb0:
	move 4(a0),d7     ; hauteur d'un caractŠre
	ext.l d7
	move (a0),d6      ; y du curseur
	ext.l d6
	lea copy_pts,a0
	move.l (a1)+,d5
	move.l d5,(a0)
	add.l d7,(a0)+
	sub.l #$10001,d5  ; pour l'angle oppos‚
	move.l (a1),(a0)
	add.l d5,(a0)+
	move.l -(a1),(a0)+
	move.l -8(a0),(a0)
	sub.l d7,(a0)
	move #3,copy_int
	clr.l mf1
	clr.l mf2
	GEM_VDI copy_tab
	lea copy_pts,a0
	move.l fenetre,a1
	add.l (a1)+,d6
	move.l d6,(a0)+
	add.l (a1),d5
	move.l d5,(a0)
	GEM_VDI fill_rect
   rts

   SAUT
emit: addq.l #2,a6
   move.l a6,a0
   move (a6),d0
   lsl #8,d0
   move d0,(a6)
   bsr write_str
   addq.l #2,a6
   rts

   SAUT
expect: move.l (a6)+,a0   ; chaine
   move -2(a0),d6        ; taille maxi
   ext.l d6
   move.l user_list,end_keys
   bsr edition
   rts

   COPIE inkey,y82
inkey: move #$ff,-(sp)
   GEMDOS 6,4
   move.l d0,-(a6)
y82: rts

   SAUT
input: bsr.s inputc
   bra val

   SAUT
inputc: lea pad,a0
   move (a0)+,d6    ; chaine pad+2, et taille maxi dans d6
   ext.l d6
   clr.b (a0)       ; vide la chaine
   move.l a0,-(a6)  ; pad sur la pile
   move.l user_list,end_keys
   bsr edition
   rts

user_list: dc.l user_keys
user_keys: dc.w 0,$1c0d,$720d,0

   SAUT
key:
	moveq #0,d3
	ifd LIB					; pour forth.lib
		tst.b aes_flag
		bne.s .touche0
		.touche1:
			move #255,-(sp)
			GEMDOS 6,4		; touche?
			move.l d0,d1
			beq.s .touche1
		swap d1
		lsl.w #8,d1			; code clavier dans octet fort
		or d1,d0				; clavier+ASCII
		move d0,d3
	   bra.s .touche2
	   .touche0:
	endif
   GEM_AES event_key
   move i_intout,d3   ; caractŠre+code
.touche2:
   move.l d3,-(a6)
   rts

   SAUT
spc: move #$2000,-(a6)
   move.l a6,a0
   bsr write_str
   addq.l #2,a6
   rts

   SAUT
spcs: move.l (a6)+,d5
   move #$2000,-(a6)
   bra.s .lb2
.lb1: move.l a6,a0
   bsr write_str
.lb2: dbf d5,.lb1
   addq.l #2,a6
   rts

   SAUT
type: move.l (a6)+,a0
   bsr write_str
   rts

	dc.l write_str			; cas d'assemblage, besoin de cette r‚f‚rence.
   ASS 19
disply: move (a5)+,d0	; taille … sauter
	move.l a5,a0         ; chaine
	add.w d0,a5          ; saute la chaine
	bsr write_str
   rts

   ASS 20
chain: move (a5)+,d1		; taille
   move.l a5,-(a6)      ; d‚pose l'adresse de la chaine
   add.w d1,a5          ; instruction suivante
   rts

   NON
var1: move.l a5,-(a6)
   move.l (a4)+,a5
   rts

   NON
cons1: move.l (a5),-(a6)
   move.l (a4)+,a5
   rts

   NON
arr1: move.l (a6),d1
	if STE=0
	   lea (a5,d1.l*4),a5
	else
		asl.l #2,d1
		lea 0(a5,d1.l),a5
	endif
   move.l a5,(a6)
   move.l (a4)+,a5
   rts

   NON
war: move.l (a6),d1
	if STE=0
	   lea (a5,d1.l*2),a5
	else
		add.l d1,d1
		lea 0(a5,d1.l),a5
	endif
   move.l a5,(a6)
   move.l (a4)+,a5
   rts

   NON
str1: addq.l #2,a5
   move.l a5,-(a6)
   move.l (a4)+,a5
   rts

   NON
char1: move.l (a6),d1
   move (a5)+,d2
   addq #4,d2
   bclr #0,d2
   mulu d2,d1
   add.l a5,d1
   move.l d1,(a6)
   move.l (a4)+,a5
   rts

   NON
tab1: move.l (a6),d1
   if STE=0
	   move.l (a5,d1.l*4),(a6)
	else
		asl.l #2,d1
		move.l 0(a5,d1.l),(a6)
	endif
   move.l (a4)+,a5
   rts

   COPIE timer,y86
timer: clr.l -(sp)
   GEMDOS 32,6
   move.l $4ba.w,-(a6)
   move.l d0,-(sp)
   GEMDOS 32,6
y86: rts

   COPIE_OPT6 dif,y87
dif:
   move.l (a6)+,d1
	moveq #0,d0
   cmp.l (a6),d1
   sne d0
   neg.b d0
   move.l d0,(a6)
y87: rts

   COPIE free,y88,1
free: move.l botmem,d1
   sub.l topprg,d1
   move.l d1,-(a6)
y88: rts

   COPIE full,y89,1
full: move.l topprg,d1
   sub.l program,d1
   add.l topmem,d1
   sub.l botmem,d1
   move.l d1,-(a6)
y89: rts

   SAUT
pilaf: movem.l a4-a6,regist
   move.l pilbase,d7
   sub.l a6,d7
   bpl.s .lb1
   move.l #'*',-(a6)
   bra emit
.lb1: asr #2,d7
.lb2: subq #1,d7
   bmi.s .lb3
   bsr point
   move -2(a6),d6
   bsr spc
   move d6,-2(a6)
   bra.s .lb2
.lb3: movem.l regist,a4-a6
   rts

   NON
doesa: move #1,ass
   bra.s does

   NON
does: move.l topprg,a2
   move.l (a4),a0
   move (a0)+,d1
   move.l a0,(a4)
   ext.l d1
   asl.l #2,d1
   lea adresse,a1
   move.l a2,0(a1,d1)
   movem.l a4/a6,doesreg
   move.l a5,a0
   tst ass
   beq.s .lba
   move #437,(a2)+
.lba: tst.l (a6)
   beq.s .lb2
   tst ass
   beq.s .lb0
   moveq #0,d4
   move.l (a6),d5
   bsr assemblons
   bra.s .lb2
.lb0: clr (a2)+
   move.l (a6),(a2)+
.lb2: move (a0)+,d4
   bne.s .lb5
   tst ass
   beq.s .lb1
   move.l (a0)+,d5
   bsr assemblons
   bra.s .lb2
.lb1: clr (a2)+            ; empl
   move.l (a0)+,(a2)+
   bra.s .lb2
.lb5: cmp #637,d4       ; empl float
   bne.s .lb55
   tst ass
   beq.s .lb4
   move #$2d3c,(a2)+
   move.l (a0)+,(a2)+
   move #$2d3c,(a2)+
   move.l (a0)+,(a2)+
   bra.s .lb2
.lb4: move d4,(a2)+
   move.l (a0)+,(a2)+
   move.l (a0)+,(a2)+
   bra.s .lb2
.lb55: cmp #154,d4      ; ;end
   beq.s .lb3
   bsr.s .lb9
   tst ass
   beq.s .lb6
   bsr assemblons
   bra.s .lb2
.lb6: move d4,(a2)+        ; autre
   tst d0
   bmi.s .lb2
   move d0,(a2)+
   bra.s .lb2
.lb3: tst ass
   beq.s .lb7
   move #$4e75,(a2)+
   bra.s .lb8
.lb7: move #79,(a2)+
.lb8: move.l a2,topprg
   movem.l doesreg,a4/a6
   UP
   move.l a0,a5
   clr ass
   rts
.lb9: moveq #-1,d0
   cmp #66,d4
   beq.s .lb10
   cmp #700,d4
   beq.s .lb10
   cmp #701,d4
   beq.s .lb10
   cmp #702,d4
   beq.s .lb10
   cmp #712,d4
   beq.s .lb10
   cmp #714,d4
   beq.s .lb10
   cmp #69,d4
   beq.s .lb10
   cmp #62,d4
   beq.s .lb10
   cmp #70,d4
   beq.s .lb10
   cmp #67,d4
   beq.s .lb10
   rts
.lb10: move (a0)+,d0
   rts

   ASS 16
ifloop: tst.l (a6)+
   beq.s .lb1
   addq.l #1,(a4)
   move.l (a4),d1
   cmp.l 4(a4),d1
   bpl.s .lb1
   move.l 8(a4),a5
   rts
.lb1: move.l (a4),-(a6)
   add.w #12,a4
   subq.l #4,indptr
   rts

   COPIE stform,y90,1
stform: move.l #form+79,formptr
   move.l formptr,a1
   clr.b (a1)
y90: rts

	if STE=0
	   	SAUT
		diese: move.l (a6),d2
			beq.s .nul_char
	   	divsl.l base,d1:d2
	   	move.l d2,(a6)
   else
	   	SAUT
   	diese: tst.l (a6)
   		beq.s .nul_char
   		move.l base,-(a6)
   		bsr spdiv
   		move.l d2,(a6)
   endif
   tst.l d1
   bpl.s .lb1
   neg.l d1
.lb1: cmp.b #10,d1
   bmi.s .lb2
   addq #7,d1
.lb2: add #48,d1
.lb3:
   move.l formptr,a1
   move.b d1,-(a1)
   move.l a1,formptr
   rts
.nul_char:
	move.l nul_ch,d1
	bra.s .lb3

   COPIE hold,y92,1
hold: subq.l #1,formptr
   move.l formptr,a1
   addq.l #3,a6
   move.b (a6)+,(a1)
y92: rts

   SAUT
dieses: move #1,ecran
   bsr point
   clr ecran
   moveq #-2,d1
.lb1: addq #1,d1
   tst.b (a1)+
   bne.s .lb1
   subq.l #1,a1
   move.l formptr,a2
.lb2: move.b -(a1),-(a2)
   dbf d1,.lb2
   move.l a2,formptr
   moveq #0,d0
   move.l d0,-(a6)
   rts

   COPIE edform,y93,1
edform: move.l formptr,a1
   move.l #pad+2,a2
   move.l a2,(a6)
.lb1: move.b (a1)+,(a2)+
   bne.s .lb1
y93: rts

   SAUT
call: move.l (a6)+,a0
   jmp (a0)

   COPIE top,y94,1
top: move.l #topprg,-(a6)
y94: rts

   COPIE wrcl,y95
wrcl: moveq #0,d1
   if STE=0
   	move.w ([a6]),d1
   	move.l d1,(a6)
   else
   	move.l (a6)+,a0
   	move.w (a0),d1
   	move.l d1,-(a6)
   endif
y95: rts

   COPIE wsto,y96
wsto: move.l (a6)+,a3
   addq.l #2,a6
   move (a6)+,(a3)
y96:  rts


   COPIE iwrcl,y95a
iwrcl: moveq #0,d1
   if STE=0
   	move.w ([a6]),d1
      ror #8,d1
      move.l d1,(a6)
   else
   	move.l (a6)+,a0
   	move.w (a0),d1
      ror #8,d1
      move.l d1,-(a6)
   endif
y95a: rts

   COPIE iwsto,y96a
iwsto: move.l (a6)+,a3
   addq.l #2,a6
   move (a6)+,d1
   ror #8,d1
   move d1,(a3)
y96a:  rts

   SAUT
seizeb: move.l (a6)+,a1
   move.l (a6),a2
   move.l a2,d0
   moveq #0,d2
.lb1: move.b (a2)+,d2
   beq.s .lb2
   move d2,(a1)+
   bra.s .lb1
.lb2: sub.l d0,a2
   subq.l #1,a2
   move.l a2,(a6)
	rts

   COPIE gmds,y97,1
gmds: move.l (a6)+,d1
   move.l topprg,a3
   move.l -(a3),d0
   move.l a7,d5
.lb1: move -(a3),-(a7)
   cmp.l a3,d1
   bmi.s .lb1
   move.l d1,topprg
   trap #1
   move.l d5,a7
   move.l d0,-(a6)
y97: rts

   COPIE bioss,y98,1
bioss: move.l (a6)+,d1
   move.l topprg,a3
   move.l -(a3),d0
   move.l a7,d5
.lb1: move -(a3),-(a7)
   cmp.l a3,d1
   bmi.s .lb1
   move.l d1,topprg
   trap #13
   move.l d5,a7
   move.l d0,-(a6)
y98: rts

   COPIE xbioss,y99,1
xbioss: move.l (a6)+,d1
   move.l topprg,a3
   move.l -(a3),d0
   move.l a7,d5
.lb1: move -(a3),-(a7)
   cmp.l a3,d1
   bmi.s .lb1
   move.l d1,topprg
   trap #14
   move.l d5,a7
   move.l d0,-(a6)
y99: rts

   COPIE wvirg,y100,1
wvirg: move.l topprg,a0
   addq.l #2,a6
   move (a6)+,(a0)+
   move.l a0,topprg
y100: rts

   COPIE ebw,y101
ebw: move.l (a6)+,d1
   ext.w d1
   move.l d1,-(a6)
y101: rts

   COPIE ebl,y102
ebl: move.l (a6)+,d1
	if STE=0
	   extb.l d1
	else
		ext.w d1
		ext.l d1
	endif
   move.l d1,-(a6)
y102: rts

   COPIE ewl,y103
ewl: move.l (a6)+,d1
   ext.l d1
   move.l d1,-(a6)
y103: rts

   COPIE puts,y104
puts: move.l (a6)+,a2
   move.l (a6)+,a3
.lb1: move.b (a3)+,(a2)+
   bne.s .lb1
y104: rts

   COPIE gets,y105
gets: move.l (a6)+,a2
   move.l (a6)+,a3
   move -2(a2),d1
.lb1: move.b (a3)+,(a2)+
   dbeq d1,.lb1
   clr.b -(a2)
y105: rts

   COPIE fcr,y106
fcr: addq.l #2,a6
   move (a6)+,-(sp)
   move.l (a6)+,-(sp)
   GEMDOS 60,8
   move.l d0,-(a6)
y106: rts

   COPIE fop,y107
fop: addq.l #2,a6
   move (a6)+,-(sp)
   move.l (a6)+,-(sp)
   GEMDOS 61,8
   move.l d0,-(a6)
y107: rts

   COPIE ffs,y108
ffs: move.l (a6)+,d1
   move d1,-(sp)
   move.l (a6)+,-(sp)
   GEMDOS 78,8
   move.l d0,-(a6)
y108: rts

   COPIE fcl,y109
fcl: move 2(a6),-(sp)
   GEMDOS 62,4
   move.l d0,(a6)
y109: rts

   COPIE frd,y110
frd: move.l (a6)+,-(sp)
   move.l (a6)+,-(sp)
   move.l (a6)+,d1
   move d1,-(sp)
   GEMDOS 63,12
   move.l d0,-(a6)
y110: rts

   COPIE fwr,y111
fwr: move.l (a6)+,-(sp)
   move.l (a6)+,-(sp)
   move.l (a6)+,d1
   move d1,-(sp)
   GEMDOS 64,12
   move.l d0,-(a6)
y111: rts

   COPIE fgd,y112
fgd: GEMDOS 47,2
   move.l d0,-(a6)
y112: rts

   COPIE fdl,y113
fdl: move.l (a6)+,-(sp)
   GEMDOS 65,6
   move.l d0,-(a6)
y113: rts

   COPIE fnx,y114
fnx: GEMDOS 79,2
   move.l d0,-(a6)
y114: rts

   COPIE dta,y115,1
dta: move.l #dtabuf,-(a6)
y115: rts

   COPIE fsd,y116
fsd: move.l (a6)+,-(sp)
   GEMDOS 26,6
y116: rts

   COPIE fsk,y117
fsk: move #1,-(sp)
   addq.l #2,a6
   move (a6)+,-(sp)
   move.l (a6)+,-(sp)
   GEMDOS 66,10
   move.l d0,-(a6)
y117: rts

   COPIE fsk1,y118
fsk1: move #0,-(sp)
   addq.l #2,a6
   move (a6)+,-(sp)
   move.l (a6)+,-(sp)
   GEMDOS 66,10
   move.l d0,-(a6)
y118: rts

   COPIE fsk2,y119
fsk2: move #2,-(sp)
   addq.l #2,a6
   move (a6)+,-(sp)
   move.l (a6),-(sp)
   neg.l (sp)
   GEMDOS 66,10
   move.l d0,(a6)
y119: rts

   SAUT
xv_opnwk:
	moveq #1,d0
	moveq #1,d1		; un couple de plus
	bra ouvrir2

   SAUT
xv_updwk:
	move.l (a6)+,intin	; l'adresse du buffer
   moveq #2,d2
   V5 4,1,0

	COPIE _global,y120,1
_global:
	move.l #global,-(a6)
y120: rts

	COPIE vq_aes,y121,1
vq_aes:
	moveq #0,d1
	ifd LIB
		tst.b aes_flag
		bne.s .lb0
		moveq #-1,d1
		.lb0:
	endif
	move.l d1,-(a6)
y121: rts

   COPIE vsync,y124
vsync: XBIOS 37,2
y124: rts

   COPIE joyst,y125
joyst: move.l #$40014,-(sp)
   BIOS 3,6
y125: rts

   COPIE mouse,y126
mouse: move.l #$40008,-(sp)
   BIOS 3,6
y126: rts

joystick: dc.l 3592

   SAUT
jx0: moveq #0,d0
   move.l joystick(pc),a0
   move.b (a0),d1
   and.b #$c,d1
   beq.s .lb1
   moveq #1,d0
   and.b #8,d1
   bne.s .lb1
   neg.l d0
.lb1: move.l d0,-(a6)
   rts

   SAUT
jx1: moveq #0,d0
   move.l joystick(pc),a0
   move.b 1(a0),d1
   and.b #$c,d1
   beq.s .lb1
   moveq #1,d0
   and.b #8,d1
   bne.s .lb1
   neg.l d0
.lb1: move.l d0,-(a6)
   rts

   SAUT
jy0: moveq #0,d0
   move.l joystick(pc),a0
   move.b (a0),d1
   and.b #3,d1
   beq.s .lb1
   moveq #1,d0
   and.b #2,d1
   bne.s .lb1
   neg.l d0
.lb1: move.l d0,-(a6)
   rts

   SAUT
jy1: moveq #0,d0
   move.l joystick(pc),a0
   move.b 1(a0),d1
   and.b #3,d1
   beq.s .lb1
   moveq #1,d0
   and.b #2,d1
   bne.s .lb1
   neg.l d0
.lb1: move.l d0,-(a6)
   rts

   SAUT
fire0: moveq #0,d0
   move.l joystick(pc),a0
   move.b (a0),d1
   and.b #$80,d1
   beq.s .lb1
   moveq #1,d0
.lb1: move.l d0,-(a6)
   rts

   SAUT
fire1: moveq #0,d0
   move.l joystick(pc),a0
   move.b 1(a0),d1
   and.b #$80,d1
   beq.s .lb1
   moveq #1,d0
.lb1: move.l d0,-(a6)
   rts

   COPIE mousx,y127,1
mousx:
   GEM_VDI vq_mouse
   moveq #0,d1
   move vq_out+2,d1
   move.l d1,-(a6)
y127: rts

   COPIE mousy,y128,1
mousy:
	GEM_VDI vq_mouse
	moveq #0,d1
	move vq_out+4,d1
   move.l d1,-(a6)
y128: rts

   COPIE mousk,y129,1
mousk:
   GEM_VDI vq_mouse
   move vq_out,d1
   and.l #3,d1
   move.l d1,-(a6)
y129: rts

   COPIE hadr,y130,1
hadr: move.l (a6)+,d1
	if STE=0
   	lea (adresse,d1.l*4),a0
   else
   	lea adresse,a0
   	asl.l #2,d1
   	add.l d1,a0
   endif
   move.l a0,-(a6)
y130: rts

   COPIE super,y131,1
super: clr.l -(sp)
   GEMDOS 32,6
   move.l d0,savpil
y131: rts

   COPIE user,y132,1
user: move.l savpil,-(sp)
   GEMDOS 32,6
y132: rts

   ASS 1
blockgds: move.l a7,topsave
   moveq #0,d2
   if STE=0
   	lea (gblk-1476,pc,d1.w*4),a3
   else
   	add d1,d1
   	add d1,d1
   	lea gblk-1476,a3
   	add d1,a3
   endif
   move.b (a3)+,d3
   move.b (a3)+,d2
   bmi.s .lb4
.lb1: move.l (a6)+,d0
   btst d2,d3
   bne.s .lb2
   move d0,-(sp)
   bra.s .lb3
.lb2: move.l d0,-(sp)
.lb3: dbf d2,.lb1
.lb4: move.b (a3)+,d2
   ext.w d2
   move d2,-(sp)
   trap #1
   move.l topsave,a7
   tst.b (a3)
   beq.s .lb5
   move.l d0,-(a6)
.lb5: rts

   ASS 21
blockbs: move.l a7,topsave
   moveq #0,d2
   if STE=0
	   lea (bblk-1588,pc,d1.w*4),a3
	else
		add d1,d1
		add d1,d1
		lea bblk-1588,a3
		add d1,a3
	endif
   move.b (a3)+,d3
   move.b (a3)+,d2
   bmi.s .lb4
.lb1: move.l (a6)+,d0
   btst d2,d3
   bne.s .lb2
   move d0,-(sp)
   bra.s .lb3
.lb2: move.l d0,-(sp)
.lb3: dbf d2,.lb1
.lb4: move.b (a3)+,d2
   ext.w d2
   move d2,-(sp)
   trap #13
   move.l topsave,a7
   tst.b (a3)
   beq.s .lb5
   move.l d0,-(a6)
.lb5: rts

   ASS 22
blockxbs: move.l a7,topsave
   moveq #0,d2
   if STE=0
	   lea (xblk-1632,pc,d1.w*4),a3
	else
		add d1,d1
		add d1,d1
		lea xblk-1632,a3
		add d1,a3
	endif
   move.b (a3)+,d3
   move.b (a3)+,d2
   bmi.s .lb4
.lb1: move.l (a6)+,d0
   btst d2,d3
   bne.s .lb2
   move d0,-(sp)
   bra.s .lb3
.lb2: move.l d0,-(sp)
.lb3: dbf d2,.lb1
.lb4: move.b (a3)+,d2
   ext.w d2
   move d2,-(sp)
   trap #14
   move.l topsave,a7
   tst.b (a3)
   beq.s .lb5
   move.l d0,-(a6)
.lb5: rts

   NON
ass1: move.l a5,a0
   move.l (a4)+,a5
   jmp (a0)

   COPIE pair,y133,1
pair: move.l topprg,d1
   addq.l #1,d1
   bclr #0,d1
   move.l d1,topprg
y133: rts

	SAUT
aligne: move.l topprg,d1
	move.l (a6)+,d0
	add.l d0,d1
	neg.l d0
	subq.l #1,d1
	and.l d0,d1
	move.l d1,topprg
	rts

	COPIE sizeb,y134
sizeb: moveq #0,d1
   move.l d1,-(a6)
y134: rts

   COPIE sizew,y135
sizew: moveq #1,d1
   move.l d1,-(a6)
y135: rts

   COPIE sizel,y136
sizel: moveq #2,d1
   move.l d1,-(a6)
y136: rts

   COPIE siz,y139,1
siz: move.l (a6)+,d1
   move d1,sizeptr
y139: rts

   SAUT
pre1: move.l (a6),a1
   moveq #0,d1
   move.l (a1),a2
   move sizeptr,d0
   bne.s .lb1
   move.b -(a2),d1
   bra.s .fin
.lb1: cmp #1,d0
   bne.s .lb2
   move -(a2),d1
   bra.s .fin
.lb2: move.l -(a2),d1
.fin: move.l a2,(a1)
   move.l d1,(a6)
   rts

   SAUT
pre2: move.l (a6)+,a1
   move.l (a6)+,d1
   move.l (a1),a2
   move sizeptr,d0
   bne.s .lb1
   move.b d1,-(a2)
   bra.s .fin
.lb1: cmp #1,d0
   bne.s .lb2
   move d1,-(a2)
   bra.s .fin
.lb2: move.l d1,-(a2)
.fin: move.l a2,(a1)
   rts

   SAUT
pre3: move.l (a6),a1
   moveq #0,d1
   move.l (a1),a2
   move sizeptr,d0
   bne.s .lb1
   addq.l #1,a2
   move.b (a2),d1
   bra.s .fin
.lb1: cmp #1,d0
   bne.s .lb2
   addq.l #2,a2
   move (a2),d1
   bra.s .fin
.lb2: addq.l #4,a2
   move.l (a2),d1
.fin: move.l a2,(a1)
   move.l d1,(a6)
   rts

   SAUT
pre4: move.l (a6)+,a1
   move.l (a6)+,d1
   move.l (a1),a2
   move sizeptr,d0
   bne.s .lb1
   addq.l #1,a2
   move.b d1,(a2)
   bra.s .fin
.lb1: cmp #1,d0
   bne.s .lb2
   addq.l #2,a2
   move d1,(a2)
   bra.s .fin
.lb2: addq.l #4,a2
   move.l d1,(a2)
.fin: move.l a2,(a1)
   rts

   SAUT
post1: move.l (a6),a1
   move.l (a1),a2
   moveq #0,d1
   move sizeptr,d0
   bne.s .lb1
   move.b (a2),d1
   subq.l #1,a2
   bra.s .fin
.lb1: cmp #1,d0
   bne.s .lb2
   move (a2),d1
   subq.l #2,a2
   bra.s .fin
.lb2: move.l (a2),d1
   subq.l #4,a2
.fin: move.l a2,(a1)
   move.l d1,(a6)
   rts

   SAUT
post2: move.l (a6)+,a1
   move.l (a6)+,d1
   move.l (a1),a2
   move sizeptr,d0
   bne.s .lb1
   move.b d1,(a2)
   subq.l #1,a2
   bra.s .fin
.lb1: cmp #1,d0
   bne.s .lb2
   move d1,(a2)
   subq.l #2,a2
   bra.s .fin
.lb2: move.l d1,(a2)
   subq.l #4,a2
.fin: move.l a2,(a1)
   rts

   SAUT
rcl_ind: move.l (a6),a1
   move.l (a1),a2
   moveq #0,d1
   move sizeptr,d0
   bne.s .lb1
   move.b (a2),d1
   bra.s .fin
.lb1: subq #1,d0
   bne.s .lb2
   move (a2),d1
   bra.s .fin
.lb2: move.l (a2),d1
.fin: 
   move.l d1,(a6)
   rts

   SAUT
sto_ind: move.l (a6)+,a1
   move.l (a6)+,d1
   move.l (a1),a2
   move sizeptr,d0
   bne.s .lb1
   move.b d1,(a2)
   rts
.lb1: subq #1,d0
   bne.s .lb2
   move d1,(a2)
   rts
.lb2: move.l d1,(a2)
   rts

   SAUT
post3: move.l (a6),a1
   move.l (a1),a2
   moveq #0,d1
   move sizeptr,d0
   bne.s .lb1
   move.b (a2)+,d1
   bra.s .fin
.lb1: cmp #1,d0
   bne.s .lb2
   move (a2)+,d1
   bra.s .fin
.lb2: move.l (a2)+,d1
.fin: move.l a2,(a1)
   move.l d1,(a6)
   rts

   SAUT
post4: move.l (a6)+,a1
   move.l (a6)+,d1
   move.l (a1),a2
   move sizeptr,d0
   bne.s .lb1
   move.b d1,(a2)+
   bra.s .fin
.lb1: cmp #1,d0
   bne.s .lb2
   move d1,(a2)+
   bra.s .fin
.lb2: move.l d1,(a2)+
.fin: move.l a2,(a1)
   rts

   COPIE cvirg,y140,1
cvirg: move.l (a6)+,d1
   move.l topprg,a2
   move.b d1,(a2)+
   move.l a2,topprg
y140:  rts

   COPIE wmulsto,y141
wmulsto: move.l (a6)+,a1
   move.l (a1),d0
   move.l (a6)+,d1
   muls d1,d0
   move.l d0,(a1)
y141: rts

   COPIE wdivsto,y142
wdivsto: move.l (a6)+,a1
   move.l (a1),d0
   move.l (a6),d1
   divs d1,d0
   ext.l d0
   move.l d0,(a1)
y142: rts

   COPIE mulsto2,y143
mulsto2: move.l (a6)+,a1
   move.l (a1),d1
   asl.l #1,d1
   move.l d1,(a1)
y143: rts

   COPIE divsto2,y144
divsto2: move.l (a6)+,a1
   move.l (a1),d1
   asr.l #1,d1
   move.l d1,(a1)
y144: rts

   COPIE deces,y145,1
deces: move.l (a6)+,a1
   move.l topprg,a3
.lb1: move.b (a1)+,(a3)+
   bne.s .lb1
   move.l a3,topprg
y145: rts

   SAUT
segferme: move.l (a6)+,d0
   move.l (a6)+,d1
   move.l (a6),d2
   moveq #0,d3
   sub.l d2,d1
   beq.s .lb0
   bpl.s .lb1
   sub.l d2,d0
   bmi.s .fin
.lb0: moveq #1,d3
.fin: move.l d3,(a6)
   rts
.lb1: sub.l d2,d0
   ble.s .lb0
   bra.s .fin

   SAUT
segouvert: move.l (a6)+,d0
   move.l (a6)+,d1
   move.l (a6),d2
   moveq #0,d3
   sub.l d2,d1
   beq.s .fin
   bpl.s .lb1
   sub.l d0,d2
   bpl.s .fin
.lb0: moveq #1,d3
.fin: move.l d3,(a6)
   rts
.lb1: sub.l d2,d0
   bmi.s .lb0
   bra.s .fin

   COPIE list,y146,1
list: move.l a6,lst
y146: rts

   ASS 26
ndo: move.l a5,-(a4)
   moveq #0,d0
   move.l d0,-(a4)
   move.l (a6)+,d0
   subq.l #1,d0
   swap d0
   move.l d0,-(a4)
   rts

   ASS 27
nloop: subq #1,(a4)
   bcs.s .lb1
   move.l 8(a4),a5
   rts
.lb1: subq #1,2(a4)
   bcs.s .lb2
   move.l 8(a4),a5
   rts
.lb2: add.w #12,a4
   rts

   ASS 32
dolist: move.l a5,-(a4)
   moveq #1,d0
   move.l d0,-(a4)
   move.l #indptr,a1
   addq.l #4,(a1)
   move.l (a1),a1
   move.l lstptr,a0
   move.l lst,d1
   bne.s .lb0
   addq.l #4,lstptr
   move.l -4(a0),(a0)
   move.l (a6)+,-(a4)
   move.l (a6)+,(a1)
   rts
.lb0: clr.l lst
   move.l d1,d2
   sub.l a6,d2
   asr.l #2,d2
   move.l d1,a6
   move.l d2,-(a4)
   subq #1,d2
   move.l -4(a0),(a1)
   move.l (a1),a1
   move.l d1,a2
.lb1: move.l -(a2),(a1)+
   dbf d2,.lb1
   move.l a1,(a0)
   addq.l #4,lstptr
   rts

   ASS 31
lloop: subq.l #1,(a4)
   beq.s .lb1
   move.l indptr,a1
   addq.l #4,(a1)
   move.l 8(a4),a5
   rts
.lb1: add.w #12,a4
   subq.l #4,lstptr
   subq.l #4,indptr
   rts

dlcomp: moveq #1,d0
   move.l d0,-(a4)
   move.l #indptr,a1
   addq.l #4,(a1)
   move.l (a1),a1
   move.l lstptr,a0
   move.l lst,d1
   bne.s .lb0
   addq.l #4,lstptr
   move.l -4(a0),(a0)
   move.l (a6)+,-(a4)
   move.l (a6)+,(a1)
   rts
.lb0: clr.l lst
   move.l d1,d2
   sub.l a6,d2
   asr.l #2,d2
   move.l d1,a6
   move.l d2,-(a4)
   subq #1,d2
   move.l -4(a0),(a1)
   move.l (a1),a1
   move.l d1,a2
.lb1: move.l -(a2),(a1)+
   dbf d2,.lb1
   move.l a1,(a0)
   addq.l #4,lstptr
   rts

   COPIE remember,y147,1
remember: addq.l #4,remb
   move.l remb,a1
   move.l topprg,(a1)
y147: rts

   COPIE restore,y148,1
restore: move.l remb,a1
   tst.l (a1)
   bne.s .lb1
   move.l program,topprg
   bra.s y148
.lb1: move.l (a1),topprg
   subq.l #4,remb
y148: rts

   NON
struct: move #1,stt
   move.l #sttdata,sttptr
   rts

alloc: move.l szone,a0    ; d0:taille  --> d0:adresse
   move.l topmem,a1       ; utilise d0,a0,d1,a1,d2
.lb0: move.l (a0)+,d1
   bmi.s .lb6
   cmp.l d0,d1
   bpl.s .lb1
   sub.l d1,a1
   sub.l (a0)+,a1
   bra.s .lb0
.lb1: beq.s .lb3
.lb2: sub.l d1,a1
   add.l d0,(a0)
   sub.l d0,-(a0)
   move.l a1,d0
.lb5: rts
.lb3: move.l szone,d2
   addq.l #4,d2
   cmp.l d2,a0
   beq.s .lb2
   sub.l d1,a1
   add.l (a0)+,d1
   move.l a1,d0
   move.l a0,a1
   sub.w #12,a1
   add.l d1,(a1)+
.lb4: move.l (a0)+,(a1)+
   bmi.s .lb5
   move.l (a0)+,(a1)+
   bra.s .lb4
.lb6: sub.l d0,botmem
   add.l d0,-8(a0)
   move.l botmem,d0
   rts

libere: move.l (a2),d0
   sub.l a2,d0
   add.l 4(a2),d0
   move.l szone,a0    ; d0:taille et a2:adresse
   move.l topmem,a1
.lb0: move.l (a0)+,d1
   bmi.s .lb3
   sub.l d1,a1
   sub.l (a0)+,a1
   cmp.l a1,a2
   bmi.s .lb0
   beq.s .lb4
   move.l -(a0),d1
   add.l d1,a1
   add.l d0,a2
   cmp.l a1,a2
   bne.s .lb1
   sub.l d0,(a0)
   add.l d0,-(a0)
   rts
.lb1: sub.l a2,a1
   move.l a1,(a0)+
   sub.l a1,d1
   sub.l d0,d1
.lb2: move.l (a0),a2
   move.l d0,(a0)+
   bmi.s .lb3
   move.l d1,d0
   move.l a2,d1
   bra.s .lb2
.lb3: rts
.lb4: move.l -(a0),d1
   add.l d1,a1
   add.l d0,a2
   cmp.l a1,a2
   beq.s .lb6
   sub.l d0,(a0)+
   tst.l (a0)
   bmi.s .lb5
   add.l d0,(a0)
   rts
.lb5: add.l d0,botmem
   rts
.lb6: add.l -(a0),d0
   move.l a0,a1
   addq.l #8,a1
   tst.l (a1)
   bmi.s .lb8
   add.l d0,(a1)
.lb7: move.l (a1)+,(a0)+
   bmi.s .lb3
   move.l (a1)+,(a0)+
   bra.s .lb7
.lb8: add.l d0,botmem
   cmp.l szone,a0
   bne.s .lb9
   clr.l (a0)+
   clr.l (a0)
   rts
.lb9: move.l (a1),(a0)
   rts

   NON
name: lea adresse(pc),a1
   move (a5)+,d1
   move.l topprg,a2
   if STE=0
   	move.l a2,0(a1,d1.w*4)
   else
   	add d1,d1
   	add d1,d1
   	add d1,a1
   	move.l a2,(a1)
   endif
   move.l sttptr,d1
   move.l #sttdata,a0
   sub.l a0,d1
   move #140,(a2)+
   clr.l (a2)+
   move.l d1,(a2)+
   clr.l (a2)+
   move.l a2,-12(a2)
   lsr.l d1
   subq.l #1,d1
.lb1: move (a0)+,(a2)+
   dbf d1,.lb1
   move.l a2,topprg
   clr stt
   rts

   COPIE sizeof,y149
sizeof: if STE=0
		move.l ([a6],4.w),(a6)
	else
		move.l (a6),a0
		move.l 4(a0),(a6)
	endif
y149: rts

   SAUT
schain: move.l (a6),a3
   move.l 4(a3),d4
   add.l #12,d4
   move.l d4,d0
   bsr alloc
   move.l d0,(a6)
   move.l d0,a0
   addq.l #4,a0
   sub.l #12,d4
   move.l d4,(a0)+
   move.l 8(a3),(a0)+
   move.l a0,-12(a0)
   move.l d0,8(a3)
   move.l (a3),a3
   lsr.l d4
   subq.l #1,d4
.lb2: move (a3)+,(a0)+
   dbf d4,.lb2
   rts

   SAUT
screate: move.l (a6),a3
   move.l 4(a3),d4
   addq.l #8,d4
   move.l d4,d0
   bsr alloc
   move.l d0,(a6)
   move.l d0,a0
   addq.l #4,a0
   subq.l #8,d4
   move.l d4,(a0)+
   move.l a0,-8(a0)
   lsr.l d4
   subq.l #1,d4
   move.l (a3),a3
.lb2: move (a3)+,(a0)+
   dbf d4,.lb2
   rts

   SAUT
unchain: bsr.s previous
   UP
   move.l d1,a1
   move.l 8(a1),8(a0)
   move.l d1,a2
   bra libere

   COPIE next,y150
next: if STE=0
			move.l ([a6],8.w),(a6)
		else
			move.l (a6),a0
			move.l 8(a0),(a6)
		endif
y150: rts

   COPIE previous,y151
previous: move.l (a6)+,d1
.lb1: move.l (a6),a0
   move.l 8(a0),(a6)
   beq.s y151
   cmp.l (a6),d1
   bne.s .lb1
   move.l a0,(a6)
y151: rts

   COPIE sdel,y152,1
sdel: move.l (a6)+,a2
   jsr libere
y152: rts

   COPIE view,y153,1
view: move.l (a6),-(a6)
   jsr point
y153: rts

   SAUT
empty: move.l (a6),a3
.lb1: move.l 8(a3),d0
   beq.s .fin
   move.l d0,a3
   move.l d0,a2
   bsr libere
   bra.s .lb1
.fin: move.l (a6)+,a3
   clr.l 8(a3)
   rts

   COPIE inchain,y154
inchain: move.l (a6)+,a2
   move.l (a6)+,a1
   move.l 8(a1),8(a2)
   move.l a2,8(a1)
y154: rts

   SAUT
pchain: move.l (a6)+,a3
   move.l 4(a3),d4
   add.l #12,d4
   move.l d4,d0
   bsr alloc
   move.l (a6)+,a1
   move.l d0,a0
   addq.l #4,a0
   sub.l #12,d4
   move.l d4,(a0)+
   move.l (a1),(a0)+
   move.l a0,-12(a0)
   move.l d0,(a1)
   lsr.l d4
   subq.l #1,d4
   move.l (a3),a3
.lb2: move (a3)+,(a0)+
   dbf d4,.lb2
   rts

   SAUT
punchain: move.l (a6),a3
   move.l 4(a6),a1
   cmp.l (a1),a3
   beq.s .lb1
   move.l (a1),4(a6)
   bra unchain
.lb1: move.l 8(a3),(a1)
   move.l a3,a2
   bsr libere
   addq.l #8,a6
   rts

   COPIE pinchain,y155
pinchain: move.l (a6)+,a2
   move.l (a6),a1
   move.l (a1),8(a2)
   move.l a2,(a1)
y155: rts

   COPIE ssto,y156
ssto: move.l (a6)+,a2
   move.l (a6),a1
   move.l 2(a1),d1
   move.l d1,2(a2)
   move.l (a1),a1
   move.l (a2),a2
   lsr.l d1
   subq.l #1,d1
.lb1: move (a1)+,(a2)+
   dbf d1,.lb1
y156: rts

   ASS 28
fast: move.l #fastexe,(sp)
   move.w #1,isfast
   rts

   ASS 28
slow: move.l #slowexe,(sp)
   clr.w isfast
   rts

   COPIE start,y157,1
start: move.l #accudat,a0
   clr.b (a0)
   move.l a0,accuptr
y157: rts

   COPIE pushs,y158,1
pushs: move.l (a6)+,a0
   move.l accuptr,a2
.lb1: move.b (a0)+,(a2)+
   bne.s .lb1
   subq.l #1,a2
   move.l a2,accuptr
y158: rts

   COPIE pushv,y159,1
pushv: move #1,ecran
   jsr point
   clr ecran
   move.l accuptr,a2
.lb1: move.b (a1)+,(a2)+
   bne.s .lb1
   subq.l #1,a2
   move.l a2,accuptr
y159: rts

   COPIE pushc,y160,1
pushc: move.l accuptr,a0
   addq.l #3,a6
   move.b (a6)+,(a0)+
   clr.b (a0)
   move.l a0,accuptr
y160: rts

   SAUT
display: lea accudat,a0
	bsr write_str
   rts

   COPIE getfmt,y162,1
getfmt: move.l #accudat,a0
   if STE=0
   	clr.b ([accuptr])
   else
   	move.l accuptr,a1
   	clr.b (a1)
   endif
   move.l #pad+2,a1
   move.l a1,-(a6)
.lb0: move.b (a0)+,(a1)+
   bne.s .lb0
y162: rts

   SAUT
dir: move #-1,-(sp)
   move.l (a6)+,a3
   move.l a3,-(sp)
   GEMDOS 78,8
.lb1: tst.l d0
   bne.s .fin
   bsr cr
   GEMDOS $2f,2
   move.l d0,a3
   add.w #28,a3
   move.l a3,a0
   move.l -2(a3),-(a6)
   move #$2020,(a3)+
   moveq #14,d1
.lb2: tst.b (a3)+
   dbeq d1,.lb2
   bne.s .lb4
   subq.l #1,a3
.lb3: move.b #32,(a3)+
   dbf d1,.lb3
   clr.b (a3)
.lb4: bsr write_str
   bsr spc
   bsr point
   GEMDOS 79,2
   bra.s .lb1
.fin: rts

   SAUT
setplus: move.l (a6)+,a0
   move.l (a6),a1
   move.l #setdat,a2
   move.l a2,(a6)
   move.l (a0)+,(a2)+
   addq.l #2,a1
   move (a1)+,d0
   move d0,d1
   lsr #4,d0
   and #$f,d1
   bne.s .lb1
   subq #1,d0
.lb1: move (a0)+,d1
   or (a1)+,d1
   move d1,(a2)+
   dbf d0,.lb1
   rts

   SAUT
setfois: move.l (a6)+,a0
   move.l (a6),a1
   move.l #setdat,a2
   move.l a2,(a6)
   move.l (a0)+,(a2)+
   addq.l #2,a1
   move (a1)+,d0
   move d0,d1
   lsr #4,d0
   and #$f,d1
   bne.s .lb1
   subq #1,d0
.lb1: move (a0)+,d1
   and (a1)+,d1
   move d1,(a2)+
   dbf d0,.lb1
   rts

   SAUT
setmoins: move.l (a6)+,a0
   move.l (a6),a1
   move.l #setdat,a2
   move.l a2,(a6)
   move.l (a0)+,(a2)+
   addq.l #2,a1
   move (a1)+,d0
   move d0,d1
   lsr #4,d0
   and #$f,d1
   bne.s .lb1
   subq #1,d0
.lb1: move (a0)+,d1
   not d1
   and (a1)+,d1
   move d1,(a2)+
   dbf d0,.lb1
   rts

   SAUT
card: move.l (a6),a0
   moveq #0,d3
   addq.l #2,a0
   move (a0)+,d0
   move d0,d1
   lsr #4,d0
   and #$f,d1
   bne.s .lb1
   subq.l #1,d0
.lb1: move (a0)+,d4
   beq.s .lb4
   moveq #15,d5
.lb2: btst d5,d4
   beq.s .lb3
   addq.l #1,d3
.lb3: dbf d5,.lb2
.lb4: dbf d0,.lb1
   move.l d3,(a6)
   rts

   SAUT
setegal: move.l (a6)+,a0
   move.l (a6),a1
   moveq #0,d2
   addq.l #4,a0
   addq.l #2,a1
   move (a1)+,d0
   move d0,d1
   lsr #4,d0
   and #$f,d1
   bne.s .lb1
   subq #1,d0
.lb1: cmp (a1)+,(a0)+
   dbne d0,.lb1
   bne.s .lb2
   moveq #1,d2
.lb2: move.l d2,(a6)
   rts

   SAUT
setin: move.l (a6)+,a1
   move.l (a6),a0
   moveq #0,d2
   addq.l #4,a0
   addq.l #2,a1
   move (a1)+,d0
   move d0,d1
   lsr #4,d0
   and #$f,d1
   bne.s .lb1
   subq #1,d0
.lb1: move (a0),d1
   and (a1)+,d1
   cmp (a0)+,d1
   dbne d0,.lb1
   bne.s .lb2
   moveq #1,d2
.lb2: move.l d2,(a6)
   rts

   SAUT
elmtrcl: move.l (a6)+,a0
   move.l (a6),d6
   moveq #0,d3
   moveq #0,d7
   move (a0)+,d7
   move.l d7,(a6)
   move (a0)+,d0
   move d0,d1
   lsr #3,d0
   and #7,d1
   bne.s .lb1
   subq.l #1,d0
.lb1: move.b (a0)+,d4
   beq.s .lb4b
   moveq #7,d5
   moveq #-1,d2
.lb2: addq #1,d2
   btst d2,d4
   bne.s .lb3
   and #0,ccr
   bra.s .lb4
.lb3: addq.l #1,d3
   cmp d6,d3
.lb4: dbeq d5,.lb2
   beq.s .lb5
.lb4b: addq.l #8,d7
   dbf d0,.lb1
   subq.l #1,(a6)
   rts
.lb5: add d2,d7
   move.l d7,(a6)
   rts

   COPIE elmtplus,y163
elmtplus: move.l (a6)+,a0
   move.l (a6)+,d1
   sub (a0),d1
   move d1,d0
   lsr #3,d0
   and #7,d1
   bset d1,4(a0,d0.w)
y163: rts

   COPIE elmtmoins,y164
elmtmoins: move.l (a6)+,a0
   move.l (a6)+,d1
   sub (a0),d1
   move d1,d0
   lsr #3,d0
   and #7,d1
   bclr d1,4(a0,d0.w)
y164: rts

   COPIE elmtin,y165
elmtin: move.l (a6)+,a0
   move.l (a6),d1
   moveq #0,d2
   sub (a0),d1
   move d1,d0
   lsr #3,d0
   and #7,d1
   btst d1,4(a0,d0.w)
   beq.s .lb1
   moveq #1,d2
.lb1: move.l d2,(a6)
y165: rts

   COPIE initset,y166,1
initset: move.l (a6)+,a1
   move.l #setdat,a2
   move (a1)+,(a2)+
   move (a1),d0
   move d0,(a2)+
   move d0,d1
   lsr #4,d0
   and #$f,d1
   bne.s .lb1
   subq #1,d0
.lb1: clr (a2)+
   dbf d0,.lb1
y166: rts

   COPIE setsto,y167
setsto: move.l (a6)+,a2
   move.l (a6)+,a1
   move (a1)+,(a2)+
   move (a1)+,d0
   move d0,(a2)+
   move d0,d1
   lsr #4,d0
   and #$f,d1
   bne.s .lb1
   subq.l #1,d0
.lb1: move (a1)+,(a2)+
   dbf d0,.lb1
y167: rts

   COPIE pads,y168,1
pads: move.l #setdat,-(a6)
y168: rts

   NON
et1: move (a5),d1
   move.l (a4)+,a5
   ext.l d1
   move.l d1,-(a6)
   rts

edb: dc.l edbuf

; ****************** nombres r‚els **************************
	if STE=0

is_fpu: dc.w $FF00	; FF if 68881/2 detected

   COPIE flint,y400
flint: fmove.d (a6)+,fp0
   fmove.l fp0,-(a6)
y400: rts

   COPIE intfl,y401
intfl: fmove.l (a6)+,fp0
   fmove.d fp0,-(a6)
y401: rts

   COPIE int,y402
int: fintrz.d (a6),fp0
   fmove.d fp0,(a6)
y402: rts

   COPIE sincos,y403
sincos:
   fsincos.d (a6),fp0:fp1
   fmove.d fp0,(a6)
   fmove.d fp1,-(a6)
y403: rts

   COPIE sin,y404
sin:
   fsin.d (a6),fp0
   fmove.d fp0,(a6)
y404: rts

   COPIE cos,y405
cos:
   fcos.d (a6),fp0
   fmove.d fp0,(a6)
y405: rts

   COPIE tan,y406
tan:
   ftan.d (a6),fp0
   fmove.d fp0,(a6)
y406: rts

   COPIE atn,y407
atn:
   fatan.d (a6),fp0
   fmove.d fp0,(a6)
y407: rts

   COPIE carre,y408
carre:
   fmove.d (a6),fp0
   fmul.x fp0,fp0
   fmove.d fp0,(a6)
y408: rts

   COPIE expo,y409
expo:
   fetox.d (a6),fp0
   fmove.d fp0,(a6)
y409: rts

   COPIE loga,y410
loga:
   flogn.d (a6),fp0
   fmove.d fp0,(a6)
y410: rts

   COPIE sqr,y411
sqr:
   fsqrt.d (a6),fp0
   fmove.d fp0,(a6)
y411: rts

   COPIE fdiv,y412
fdiv:
   fmove.d 8(a6),fp0
   fdiv.d  (a6)+,fp0
   fmove.d fp0,(a6)
y412: rts

   COPIE ffois,y413
ffois:
   fmove.d (a6)+,fp0
   fmul.d  (a6) ,fp0
   fmove.d fp0  ,(a6)
y413: rts

   COPIE fplus,y414
fplus:
   fmove.d (a6)+,fp0
   fadd.d  (a6) ,fp0
   fmove.d fp0  ,(a6)
y414: rts

   COPIE fmoins,y415
fmoins:
   fmove.d 8(a6),fp0
   fsub.d  (a6)+,fp0
   fmove.d fp0,(a6)
y415: rts

   COPIE inv,y416
inv:
   fmovecr #50,fp0          ; 1
   fdiv.d (a6),fp0
   fmove.d fp0,(a6)
y416: rts

   COPIE round,y417
round:
   fint.d (a6),fp0
   fmove.d fp0,(a6)
y417: rts

   COPIE frac,y418
frac:
   fmove.d (a6),fp0
   fintrz.x fp0,fp1
   fsub.x fp1,fp0
   fmove.d fp0,(a6)
y418: rts

copro: dc.l 0,0,0,0

subplus: movem.l d0-d3,copro
   fmove.d copro,fp0
   fadd.d  copro+8 ,fp0
   fmove.d fp0,copro
   movem.l copro,d0-d1
   rts

submul: movem.l d0-d3,copro
   fmove.d copro,fp0
   fmul.d  copro+8,fp0
   fmove.d fp0,copro
   movem.l copro,d0-d1
   rts

subdiv: movem.l d0-d3,copro
   fmove.d copro,fp0
   fdiv.d  copro+8,fp0
   fmove.d fp0,copro
   movem.l copro,d0-d1
   rts

; ************************ fin *****************
	else
; *************Calcul r‚el sans coprocesseur


FPCIR equ $fffffa40
FPCTL equ $fffffa42
FPCMD equ $fffffa4a
FPOP  equ $fffffa50

test_fpu:
	sf is_fpu
	move #0,cookie_flag
	move.l #'_FPU',mot
	pea _cookie(pc)
	XBIOS 38,6
	tst cookie_flag
	beq.s .fin
	cmp #1,cookie_val
	bne.s .fin
	st is_fpu
.fin:
	rts

;
;	pea _test_fpu(pc),
;	XBIOS 38,6
;	rts
;
;_test_fpu:
;	sf is_fpu
;	rts
;
;	move.l $8.w,a1
;	move.l #.my_bus,$8.w
;	st is_fpu
;	tst.w FPCIR.w		; provoque erreur bus si FPU absent
;	clr.w FPCTL.w
;	move #$9000,FPCMD.w
;.lb0:
;	move FPCIR.w,d0
;	and #$BFFF,d0
;	cmp #$9504,d0
;	bne.s .lb0
;	move.l #$00000000,FPOP.w
;.fin:
;	move.l a1,$8.w
;	rts
;.my_bus:
;	sf is_fpu
;	move.l #.fin,2(sp)	; adresse retour
;	rte

is_fpu: dc.w 0	; FF si 68881/2

   SAUT
round: moveq #0,d4
   moveq #0,d5
   move.l (a6)+,d0
   smi d7
   move.l (a6),d1
   swap d0
   move d0,d2
   and #$f,d0
   bset #4,d0
   swap d0
   moveq #0,d6
   move d2,d6
   and #$fff0,d6
   bclr #15,d2
   lsr #4,d2
   sub #$3ff,d2
   bpl.s .lb0
   moveq #0,d0
   move.l d0,(a6)
   cmp #-1,d2
   bne.s .zero
   move.l #$3ff00000,-(a6)
   tst.b d7
   beq.s .glup
   bchg #7,(a6)
.glup: rts
.zero: move.l d0,-(a6)
   rts
.lb0: cmp #52,d2
   bmi.s .lb1
   subq.l #4,a6
   rts
.lb1: moveq #-1,d7
   cmp #20,d2
   bpl.s .lb2
   moveq #0,d1
   sub #20,d2
   neg d2
   move d2,d3
   subq #1,d3
   lsl.l d2,d7
   btst d3,d0
   beq.s .lb10
   bset d3,d4
.lb10: and.l d7,d0
   bra.s .fin
.lb2: sub #52,d2
   neg d2
   lsl.l d2,d7
   move d2,d3
   subq #1,d3
   btst d3,d1
   beq.s .lb3
   bset d3,d5
.lb3: and.l d7,d1
.fin: lsl.l d5
   roxl.l d4
   add.l d5,d1
   addx.l d4,d0
   btst #21,d0
   beq.s .lb4
   lsr.l d0
   roxr.l d1
   add #$10,d6
.lb4: bclr #20,d0
   swap d6
   or.l d6,d0
   move.l d1,(a6)
   move.l d0,-(a6)
   rts

; d0/d1 un r‚el
; d2/d3 l'autre
; en sortie d0/d1 leur somme
; d0-d7 modifi‚s
; a0-a7 intacts

subplus: moveq #31,d7         ; pour acc‚der au bit de signe
   moveq #20,d6               ; pour acc‚der au bit implicite
   bclr d7,d0
   bne .n1                    ; si le premier est n‚gatif
   bclr #31,d2
   bne .p1n2                  ; 2 n‚gatif et 1 positif
.p1p2:  move.l d0,d4          ; ici les deux sont positifs
   lsr.l d6,d4                ; exposant de 1
   move.l d2,d5
   lsr.l d6,d5                ; exposant de 2
   sub.w d5,d4                ; nbr de d‚calages
   bpl.s .lb0                 ; 1 > 2
   exg.l d0,d2                ; sinon on ‚change
   exg.l d1,d3
   neg d4
.lb0: move.l d0,d5            ; conserve l'exposant du plus grand
   cmp #53,d4
   bpl .endpos                ; trop de d‚calages
   and.l #$fffff,d0           ; on ote les exposants
   and.l #$fffff,d2
   bset d6,d0                 ; on ajoute le bit implicite
   bset d6,d2
   cmp #32,d4
   bpl.s .lb1
   move.l d2,d6               ; moins de 32 d‚calages
   lsr.l d4,d2
   lsr.l d4,d3
   sub #32,d4
   neg d4
   lsl.l d4,d6
   or.l d6,d3
   bra.s .lb2
.lb1: move.l d2,d3            ; plus de 32 d‚calages, d3 inutile
   moveq #0,d2
   sub #32,d4
   lsr.l d4,d3
.lb2: add.l d3,d1             ; addition
   addx.l d2,d0
   moveq #21,d6
   btst d6,d0                 ; une retenue?
   beq.s .lb4
   add.l #$100000,d5          ; si oui on augmente l'exposant
   lsr.l d0                   ; et on d‚cale … droite
   roxr.l d1
.lb4: moveq #20,d6            ; sinon on enlŠve le bit implicite
   bclr d6,d0
   and.l #$fff00000,d5        ; on garde l'exposant seul
   or.l d5,d0                 ; qu'on ajoute … la mantisse
.endpos: rts
.n1: bclr d7,d2
   beq.s .n1p2
   bsr .p1p2                  ; meme chose si deux n‚gatifs
   bset d7,d0                 ; mais signe -
   rts
.n1p2: bset d7,d7
.p1n2: move.l d0,d4           ; l'un positif l'autre n‚gatif
   lsr.l d6,d4                ; exposant de 1
   move.l d2,d5
   lsr.l d6,d5                ; exposant de 2
   sub.w d5,d4                ; nbr de d‚calages
   bpl.s .lb5                 ; 1 > 2
   exg.l d0,d2                ; sinon on ‚change
   exg.l d1,d3
   neg d4
   bchg d7,d7
.lb5: move.l d0,d5            ; conserve l'exposant du plus grand
   cmp #53,d4
   bpl .lb12                  ; trop de d‚calages
   and.l #$fffff,d0
   and.l #$fffff,d2
   bset d6,d0
   bset d6,d2
   cmp #32,d4
   bpl.s .lb6
   move.l d2,d6
   lsr.l d4,d2
   lsr.l d4,d3
   sub #32,d4
   neg d4
   lsl.l d4,d6
   or.l d6,d3
   bra.s .lb7
.lb6: move.l d2,d3
   moveq #0,d2
   sub #32,d4
   lsr.l d4,d3
.lb7: sub.l d3,d1
   subx.l d2,d0
   bne.s .lb8
   tst.l d1
   bne.s .lb8
   rts                               ; c'est z‚ro !
.lb8: bpl.s .lb9
   neg.l d1                          ; si c'est n‚gatif, le plus grand n'‚tait
   negx.l d0                         ; pas d0/d1, on oppose
   bchg d7,d7                        ; modifie le signe du r‚sultat
.lb9: moveq #20,d6
   lsr.l d6,d5                       ; ramŠne l'exposant au bit0
   bra.s .lb11
.lb10: lsl.l d1                      ; d‚calage … gauche
   roxl.l d0
   subq.w #1,d5                      ; ajuste l'exposant
.lb11: btst d6,d0                    ; tant que le bit20 n'est pas mis
   beq.s .lb10                       ; on remonte d‚caler … gauche
   bclr d6,d0                        ; sinon on ote le bit implicite
   lsl.l d6,d5                       ; on recale l'exposant au bit20
   or.l d5,d0                        ; qu'on ajoute … d0
.lb12: tst.l d7
   bpl.s .lb13
   bset d7,d0                        ; r‚sultat n‚gatif si bit31 de d7 = 1
.lb13: rts

   SAUT
frac: move.l (a6)+,d0
   smi d7
   bclr #31,d0
   move.l (a6),d1
   move.l d0,d2
   swap d2
   lsr #4,d2
   sub #$3ff,d2
   bpl.s .lb0
   subq.l #4,a6
   rts
.lb0: cmp #52,d2
   bmi.s .lb1
.zero: moveq #0,d0
   move.l d0,(a6)
   move.l d0,-(a6)
   rts
.lb1: addq #1,d2
   cmp #32,d2
   bpl.s .lb2
   lsl.l d2,d0
   move.l d1,d3
   lsl.l d2,d1
   sub #32,d2
   neg d2
   lsr.l d2,d3
   or.l d3,d0
   bra.s .lb3
.lb2: move.l d1,d0
   moveq #0,d1
   sub #32,d2
   lsl.l d2,d0
.lb3: move #$3fe0,d2
   and.l #$001fffff,d0
   bne.s .lb4
   tst.l d1
   beq.s .zero
.lb4: bclr #20,d0
   bne.s .lb5
   sub #$10,d2
   lsl.l d1
   roxl.l d0
   bra.s .lb4
.lb5: swap d0
   or d2,d0
   swap d0
   tst.b d7
   beq.s .fin
   bset #31,d0
.fin: move.l d1,(a6)
   move.l d0,-(a6)
   rts

; d0/d1 d2/d3 les deux termes
; d0/d1 le r‚sultat
; d0-d7 tous utilis‚s.
; on d‚coupe d0/d1  en 4 fois 16 bits : d0' d0  d1' d1
; de meme pour d2/d3                  ; d2' d2  d3' d3
; on multiplie alors comme dans une op‚ration … 4 chiffres, d6/d7 servant
; d'accumulateurs qui se d‚calent … mesure que la multiplication avance
; en effet la moiti‚ des bits seront tronqu‚s et n'ont pas besoin d'etre
; conserv‚s.
; d5 sert aux multiplications interm‚diaires, d4 conserve l'exposant.
; A cause du format IEEE, d6/d7 contiennent … la fin 4 ou 5 bits de trop
; qu'on enlŠvera par d‚calages.
; le d‚but de la routine est ‚quivalente … subdiv.

submul: move.l d0,d4
   swap d4
   move d4,d7
   and.l #$7ff0,d4
   beq .zero
   move.l d2,d5
   swap d5
   move d5,d6
   and #$7ff0,d5
   beq .zero
   add d5,d4
   sub #$3ff0,d4
   swap d4
   eor d6,d7
   bpl.s .lb0
   moveq #31,d6
   bset d6,d4
.lb0: and.l #$fffff,d0
   and.l #$fffff,d2
   moveq #20,d6
   bset d6,d0
   bset d6,d2
.lb1: moveq #0,d6
   move d3,d7
   mulu d1,d7
   clr d7
   swap d7
   swap d3
   move d3,d5
   mulu d1,d5
   add.l d5,d7
   bcc.s .x1
   moveq #1,d6
.x1: swap d1
   swap d3
   move d3,d5
   mulu d1,d5
   add.l d5,d7
   bcc.s .x2
   addq #1,d6
.x2: move d6,d7
   swap d7
   moveq #0,d6
   move d0,d5
   mulu d3,d5
   add.l d5,d7
   bcc.s .x3
   moveq #1,d6
.x3: swap d3
   move d1,d5
   mulu d3,d5
   add.l d5,d7
   bcc.s .x4
   addq #1,d6
.x4: swap d1
   move d1,d5
   mulu d2,d5
   add.l d5,d7
   bcc.s .x5
   addq #1,d6
.x5: move d6,d7
   swap d7
   moveq #0,d6
   move d3,d5
   mulu d0,d5
   add.l d5,d7
   bcc.s .x6
   moveq #1,d6
.x6: swap d2
   move d1,d5
   mulu d2,d5
   add.l d5,d7
   bcc.s .x7
   addq #1,d6
.x7: swap d1
   swap d2
   move d1,d5
   mulu d2,d5
   add.l d5,d7
   bcc.s .x8
   addq #1,d6
.x8: swap d3
   swap d0
   move d0,d5
   mulu d3,d5
   add.l d5,d7
   bcc.s .x9
   addq #1,d6
.x9: swap d6
   swap d3
   mulu d0,d3
   move d2,d5
   swap d0
   mulu d0,d5
   add.l d5,d3
   bcc.s .x10
   addq #1,d6
.x10: swap d2
   mulu d2,d1
   add.l d1,d3
   bcc.s .x11
   addq #1,d6
.x11: swap d6
   swap d3
   moveq #0,d1
   move d3,d1
   clr d3
   add.l d3,d7
   addx.l d1,d6
   move d0,d5
   mulu d2,d5
   add.l d5,d6
   swap d0
   move d0,d5
   mulu d2,d5
   swap d5
   clr d5
   add.l d5,d6
   swap d2
   mulu d2,d0
   add.l d0,d6
   moveq #25,d1
   btst d1,d6
   bne.s .cinq
   moveq #24,d1
   bne.s .katr
.zero: moveq #0,d0
   moveq #0,d1
   rts
.cinq: moveq #5,d2
   moveq #27,d3
   add.l #$00100000,d4
   bra.s .suite
.katr: moveq #4,d2
   moveq #28,d3
.suite: move d6,d1
   lsl.l d3,d1
   lsr.l d2,d7
   lsr.l d2,d6
   or.l d7,d1
   moveq #20,d2
   bclr d2,d6
   move.l d6,d0
   or.l d4,d0
   rts

; d0/d1 le dividende
; d2/d3 le diviseur
; d0/d1 le quotient
; d0-d7 tous utilis‚s

subdiv: move.l d0,d4
   swap d4
   move d4,d7
   and.l #$7ff0,d4               ; l'exposant est isol‚
   beq .zero                     ; si nul c'est zero
   move.l d2,d5
   swap d5
   move d5,d6
   and #$7ff0,d5                 ; isole l'exposant de 2
   beq .infini                   ; si nul division infinie
   sub d5,d4                     ; par division on soustrait les exposants
   add #$3ff0,d4                 ; on ajoute 3ff0 pour le codage IEEE
   swap d4                       ; ramŠne l'exposant au bit20
   eor d6,d7                     ; si <0 pas de meme signe donc r‚sultat<0
   bpl.s .lb0
   moveq #31,d6
   bset d6,d4
.lb0: and.l #$fffff,d0           ; conserve les mantisses
   and.l #$fffff,d2
   moveq #20,d7
   bset d7,d0                    ; ajoute le bit implicite
   bset d7,d2
   moveq #0,d5                   ; partie haute du quotient … zero
.lb1: cmp.l d2,d0
   bmi.s .lb3
   bne.s .lb2
   cmp.l d3,d1
   bcs.s .lb3
.lb2: sub.l d3,d1                ; si divd>divs on ote et on place
   subx.l d2,d0
   bset d7,d5                    ; 1 dans le quotient
.lb3: lsl.l d1                   ; divd est ensuite d‚cal‚ ( abaisser un 0 )
   roxl.l d0
   dbf d7,.lb1                   ; on boucle 21 fois
   moveq #31,d7                  ; meme boucle mais 32 fois pour la
   moveq #0,d6                   ; partie basse du quotient ( d6 )
.lb4: cmp.l d2,d0
   bmi.s .lb6
   bne.s .lb5
   cmp.l d3,d1
   bcs.s .lb6
.lb5: sub.l d3,d1
   subx.l d2,d0
   bset d7,d6
.lb6: lsl.l d1
   roxl.l d0
   dbf d7,.lb4
   moveq #20,d7
   btst d7,d5
   bne.s .lb7
   lsl.l d6                      ; si le bit20 n'est pas mis on d‚cale …
   roxl.l d5                     ; gauche et on ajuste l'exposant
   sub.l #$00100000,d4
.lb7: bclr d7,d5                 ; ote le bit implicite
   move.l d5,d0
   or.l d4,d0
   move.l d6,d1
   rts
.zero: moveq #0,d0
   moveq #0,d1
   rts
.infini: moveq #-1,d0
   moveq #-1,d1
   rts

	SAUT
flint: move.l (a6)+,d0
   smi d3
   bclr #31,d0
   swap d0
   move d0,d2
   lsr #4,d2
   sub #$3ff,d2
   bmi.s .zero
   and #$f,d0
   bset #4,d0
   swap d0
   sub #20,d2
   bgt.s .lb0
   neg d2
   lsr.l d2,d0
   bra.s .fin
.lb0: cmp #31,d2
   bpl.s .max
   move (a6),d1
   subq #1,d2
.lb1: lsl d1
   roxl.l d0
   dbf d2,.lb1
   bra.s .fin
.zero: moveq #0,d0
   bra.s .fin
.max: move.l #$7fffffff,d0
.fin: tst.b d3
   beq.s .lb2
   neg.l d0
.lb2: move.l d0,(a6)
   rts

	SAUT
intfl: moveq #0,d1
   moveq #30,d7
   moveq #0,d2
   move.l (a6),d0
   beq.s .zero
   bpl.s .lb0
   move #$800,d2
   neg.l d0
.lb0: btst d7,d0
   dbne d7,.lb0
   moveq #0,d4
   move d7,d4
   add.w #$3ff,d4
   add.w d2,d4
   lsl.w #4,d4
   swap d4
   moveq #20,d6
   sub d6,d7
   beq.s .fin
   bmi.s .gauche
   move.l d0,d1
   lsr.l d7,d0
   sub #32,d7
   neg d7
   lsl.l d7,d1
.fin: bclr d6,d0
   or.l d4,d0
   move.l d1,(a6)
   move.l d0,-(a6)
   rts
.gauche: neg d7
   lsl.l d7,d0
   bra.s .fin
.zero: move.l d1,-(a6)
   rts

	SAUT
int: move.l (a6)+,d0
   move.l (a6),d1
   move.l d0,d2
   swap d2
   bclr #15,d2
   lsr #4,d2
   sub #$3ff,d2
   bpl.s .lb0
   moveq #0,d0
   move.l d0,(a6)
   move.l d0,-(a6)
   rts
.lb0: cmp #52,d2
   bmi.s .lb1
   subq.l #4,a6
   rts
.lb1: moveq #-1,d7
   cmp #21,d2
   bpl.s .lb2
   moveq #0,d1
   sub #20,d2
   neg d2
   lsl.l d2,d7
   and.l d7,d0
   bra.s .fin
.lb2: sub #52,d2
   neg d2
   lsl.l d2,d7
   and.l d7,d1
.fin: move.l d1,(a6)
   move.l d0,-(a6)
   rts

	SAUT
sincos: bsr trigo1
   btst #0,modulo
   bne.s .lb0
   move.l a3,(a6)
   move.l a2,-(a6)
   bra.s .lb1
.lb0: move.l a1,(a6)
   move.l a0,-(a6)
.lb1: btst #1,modulo
   beq.s .lb2
   bset #7,(a6)
.lb2: tst.b signe
   beq.s .lb4
   bchg #7,(a6)
.lb4: btst #0,modulo
   beq.s .lb3
   move.l a3,-(a6)
   move.l a2,-(a6)
   btst #1,modulo
   bne.s .fin
   bset #7,(a6)
   bra.s .fin
.lb3: move.l a1,-(a6)
   move.l a0,-(a6)
   btst #1,modulo
   beq.s .fin
   bset #7,(a6)
.fin: rts

; en entr‚e d0-1 l'angle entre 0 et pi/2
; utilise a0-1 : x et cos   a2-3 : y et sin    a4-5 : z   a6 : n
; d0-d7 pour subplus
; a4-a6 sauvegard‚s.

; Algorithme :
; x=k ( constante )   y=0    z=angle   n=0
;
;          si z<0                         si z>=0
;        x'=x+y/2^n                     x'=x-y/2^n
;        y'=y-x/2^n                     y'=y+x/2^n
;        z'=z+Cn                        z'=z-Cn      ( Cn=atn(2^-n) )
;
;                      n = n + 1     et on boucle !
;  en sortie x tend vers cosinus, et y vers sinus
;  pour x<2^-26 on prend cos=1, sin=angle

trigo: movem.l a4-a6,-(sp)
   clr .boucle
   cmp.l #$3e500000,d0       ; x<2^-26
   bpl.s .lb
   move.l #$3ff00000,a0      ; cos(x)=1
   sub.l a1,a1
   move.l d0,a2              ; sin(x)=x
   move.l d1,a3
   bra .fin
.lb: move.l d0,a4
   move.l d1,a5
   sub.l a2,a2
   sub.l a3,a3
   move.l cordk,a0
   move.l cordk+4,a1
   move.l #cordic1,a6
.lb0: move.l (a6)+,d2
   move.l (a6)+,d3
   move.l a5,d1
   move.l a4,d0
   bmi .lb4
   bchg #31,d2
   bsr subplus
   move.l d0,a4
   move.l d1,a5
   move.l a2,d0
   move.l d0,d2
   smi d5
   move.l a3,d1
   move .boucle,d7
   lsl #4,d7
   swap d7
   clr d7
   sub.l d7,d2
   smi d6
   cmp.b d6,d5
   beq.s .lb1
   sub.l a2,a2
   sub.l a3,a3
   bra.s .lb2
.lb1: bchg #31,d2
   move.l d2,a2
   move.l d1,a3
.lb2: move.l a0,d2
   smi d5
   move.l a1,d3
   sub.l d7,d2
   smi d6
   cmp.b d6,d5
   bne.s .lb7
   bsr subplus
   bra.s .lb7
.lb4: bsr subplus
   move.l d0,a4
   move.l d1,a5
   move.l a2,d0
   move.l d0,d2
   smi d5
   move.l a3,d1
   move .boucle,d7
   lsl #4,d7
   swap d7
   clr d7
   sub.l d7,d2
   smi d6
   cmp.b d6,d5
   beq.s .lb5
   sub.l a2,a2
   sub.l a3,a3
   bra.s .lb6
.lb5: move.l d2,a2
   move.l d1,a3
.lb6: move.l a0,d2
   smi d5
   move.l a1,d3
   sub.l d7,d2
   smi d6
   cmp.b d6,d5
   bne.s .lb7
   bchg #31,d2
   bsr subplus
.lb7: exg.l d0,a2
   exg.l d1,a3
   move.l a0,d2
   move.l a1,d3
   bsr subplus
   move.l d0,a0
   move.l d1,a1
   addq #1,.boucle
   move dpth,d2      ; profondeur de calcul
   cmp .boucle,d2
   bne .lb0
.fin: movem.l (sp)+,a4-a6
   rts
.boucle: dc.w 0

; en entr‚e : l'angle sur la pile

trigo1: clr.b modulo        ; 0, 1, 2 ou 3 fois pi/2
   move.l (a6)+,d0
   smi signe
   bclr #31,d0
   move.l (a6),d1
   move.l #pisur2,a0
   move.l (a0)+,d2
   move.l (a0),d3
   bsr subdiv             ; calcule x/(pi/2)
   swap d0
   move d0,d2
   and #$f,d0
   bset #4,d0
   swap d0
   lsr #4,d2
   sub #$3ff,d2
   bpl.s .lb0
   move.l -4(a6),d0       ; si n‚gatif alors, x<pi/2
   move.l (a6),d1
   bclr #31,d0
   bra .suite
.lb0: cmp #51,d2
   bpl .trop
.lb1: lsl.l d1
   roxl.l d0
   dbf d2,.lb1
   btst #21,d0
   beq.s .lb2
   addq.b #1,modulo
.lb2: btst #22,d0
   beq.s .lb3
   addq.b #2,modulo
.lb3: and.l #$001fffff,d0
   bne.s .lb4
   tst.l d1
   beq.s .lb6
   moveq #20,d7
.lb4: bclr d7,d0
   bne.s .lb5
   lsl.l d1
   roxl.l d0
   subq #1,d2
   bra.s .lb4
.lb5: add #$3ff,d2
   lsl #4,d2
   bclr #16,d2
   swap d2
   clr d2
   add.l d2,d0
.lb6: move.l (a0),d3
   move.l -(a0),d2
   bsr submul
.suite: bsr trigo
   rts
.trop: subq.l #4,a6
   rts

	SAUT
sin: tst.b is_fpu
   beq.s .emul
   move #$540E,FPCMD.w
   bra _commun_1op
.emul:
   bsr trigo1
   btst #0,modulo
   bne.s .lb0
   move.l a3,(a6)
   move.l a2,-(a6)
   bra.s .lb1
.lb0: move.l a1,(a6)
   move.l a0,-(a6)
.lb1: btst #1,modulo
   beq.s .lb2
   bset #7,(a6)
.lb2: tst.b signe
   beq.s .fin
   bchg #7,(a6)
.fin: rts

	SAUT
cos: tst.b is_fpu
   beq.s .emul
   move #$541D,FPCMD.w
   bra _commun_1op
.emul:
   bsr trigo1
   btst #0,modulo
   beq.s .lb0
   move.l a3,(a6)
   move.l a2,-(a6)
   btst #1,modulo
   bne.s .fin
   bset #7,(a6)
   bra.s .fin
.lb0: move.l a1,(a6)
   move.l a0,-(a6)
   btst #1,modulo
   beq.s .fin
   bset #7,(a6)
.fin: rts

	SAUT
tan: tst.b is_fpu
   beq.s .emul
   move #$540F,FPCMD.w
   bra.s _commun_1op
.emul:
   bsr trigo1
   btst #0,modulo
   beq.s .lb0
   move.l a0,d0
   move.l a1,d1
   move.l a2,d2
   move.l a3,d3
   bset #31,d0
   bra.s .suite
.lb0: move.l a2,d0
   move.l a3,d1
   move.l a0,d2
   move.l a1,d3
.suite: bsr subdiv
   tst.b signe
   beq.s .fin
   bchg #31,d0
.fin: move.l d1,(a6)
   move.l d0,-(a6)
   rts

; Algorithme :
; x=1   y=angle    z=0   n=0
;
;          si y>=0                         si y<0
;        x'=x+y/2^n                     x'=x-y/2^n
;        y'=y-x/2^n                     y'=y+x/2^n
;        z'=z+Cn                        z'=z-Cn      ( Cn=atn(2^-n) )
;
;                      n = n + 1     et on boucle !
;  en sortie z tend vers atn
;  pour x<2^-26 on prend atn(x)=x

   SAUT
atn: tst.b is_fpu
   beq.s _emul2
   move #$540A,FPCMD.w
_commun_1op:
   lea FPOP.w,a0
   tst.w FPCIR.w
   move.l (a6)+,(a0)
   move.l (a6),(a0)
   move #$7400,FPCMD.w
   subq.l #4,a6
.wait: move FPCIR-FPOP(a0),d0
   cmp #$8900,d0
   beq.s .wait
   move.l (a0),(a6)
   move.l (a0),4(a6)
   rts
_emul2:
   movem.l a4-a6,-(sp)
   clr .boucle
   move.l (a6)+,d0
   smi signe
   bclr #31,d0
   move.l d0,a2
   move.l (a6),a3
   cmp.l #$3e500000,a2       ; x<2^-26
   bpl.s .lb
   movem.l (sp)+,a4-a6       ; atn(x)=x
   rts
.lb: sub.l a4,a4
   sub.l a5,a5
   move.l #cordic1,a6
   move.l #$3ff00000,a0
   sub.l a1,a1
.lb0: move.l (a6)+,d2
   move.l (a6)+,d3
   move.l a5,d1
   move.l a4,d0
   cmp.l #0,a2
   bpl .lb4
   bchg #31,d2
   bsr subplus
   move.l d0,a4
   move.l d1,a5
   move.l a2,d0
   move.l d0,d2
   smi d5
   move.l a3,d1
   move .boucle,d7
   lsl #4,d7
   swap d7
   clr d7
   sub.l d7,d2
   smi d6
   cmp.b d6,d5
   beq.s .lb1
   sub.l a2,a2
   sub.l a3,a3
   bra.s .lb2
.lb1: bchg #31,d2
   move.l d2,a2
   move.l d1,a3
.lb2: move.l a0,d2
   smi d5
   move.l a1,d3
   sub.l d7,d2
   smi d6
   cmp.b d6,d5
   bne.s .lb7
   bsr subplus
   bra.s .lb7
.lb4: bsr subplus
   move.l d0,a4
   move.l d1,a5
   move.l a2,d0
   move.l d0,d2
   smi d5
   move.l a3,d1
   move .boucle,d7
   lsl #4,d7
   swap d7
   clr d7
   sub.l d7,d2
   smi d6
   cmp.b d6,d5
   beq.s .lb5
   sub.l a2,a2
   sub.l a3,a3
   bra.s .lb6
.lb5: move.l d2,a2
   move.l d1,a3
.lb6: move.l a0,d2
   smi d5
   move.l a1,d3
   sub.l d7,d2
   smi d6
   cmp.b d6,d5
   bne.s .lb7
   bchg #31,d2
   bsr subplus
.lb7: exg.l d0,a2
   exg.l d1,a3
   move.l a0,d2
   move.l a1,d3
   bsr subplus
   move.l d0,a0
   move.l d1,a1
   addq #1,.boucle
   move dpth,d0
   cmp .boucle,d0
   bne .lb0
   move.l a4,d0
   move.l a5,d1
   movem.l (sp)+,a4-a6
   tst.b signe
   beq.s .fin
   bset #31,d0
.fin: move.l d0,(a6)
   move.l d1,4(a6)
   rts
.boucle: dc.w 0

	SAUT
carre: tst.b is_fpu
   beq.s .emul
   lea FPOP.w,a0
   move #$5400,FPCMD-FPOP(a0)
   tst.w FPCIR-FPOP(a0)
   move.l (a6)+,(a0)
   move.l (a6),(a0)
   move #$0023,FPCMD-FPOP(a0)	; fmul fp0,fp0
   tst.w FPCIR-FPOP(a0)
   move #$7400,FPCMD-FPOP(a0)
   subq.l #4,a6
.wait: move FPCIR-FPOP(a0),d0
   cmp #$8900,d0
   beq.s .wait
   move.l (a0),(a6)
   move.l (a0),4(a6)
   rts
.emul:
   move.l (a6)+,d0
   move.l (a6),d1
   move.l d0,d2
   move.l d1,d3
   bsr submul
   move.l d1,(a6)
   move.l d0,-(a6)
   rts

; algorithme : X=m*2^n. On sait calculer l'exponentielle d'une valeur
; inf‚rieure … 1. Si X<2^-26 on utilise un DL : exp(X)=1+X
;                 Si X<1     alors x=X      et e=0
;                 Si X>1     alors x=m*2^-1 et e=n+1
; Pour calculer l'exponentielle de x:
;    on d‚compose x en une somme de Ci, avec Ci=ln(1+2^-i)
;    ensuite exp(x)= produit de (1+2^-i), ce qui se fait par d‚calages et somme
; Pour calculer ensuite exp(X) :
;    exp(X)=exp(x)^(2^e), c'est … dire au carr‚ e fois.
; ( Note : si X ‚tait n‚gatif, on calcule ensuite 1/exp(X) )
	SAUT
expo: tst.b is_fpu
   beq.s .emul
   move #$5410,FPCMD.w
   bra _commun_1op
.emul:
   moveq #0,d3
   move.l #$00100000,d2      ; d2-d3 est l'exponentielle, au d‚but 1.
   move.l (a6)+,d0
   smi signe
   bclr #31,d0
   cmp.l #$408633ce,d0
   bmi.s .lb
   move.l #$7fffffff,d0
   moveq #0,d1
   bra .sortie
.lb: cmp.l #$3e500000,d0
   bpl.s .lb0
   subq.l #4,a6          ; si x<2^-26 alors
   move.l d3,-(a6)     ; exp(x)=1+x
   move.l #$3ff00000,-(a6)
   bra fplus
.lb0: move.l (a6),d1
   swap d0
   move d0,d4
   and #$f,d0
   bset #4,d0
   swap d0               ; d0 ne contient plus que la mantisse
   lsr #4,d4
   sub #$3ff,d4          ; d4 est l'exposant
   bmi.s .lb1            ; si n‚gatif exp est direct
   addq #1,d4            ; sinon m*2^n est calcul‚ avec m*2^-1 d'abord
   swap d4               ; puis par mise au carr‚ on tient compte de 2^(n+1)
   move #-1,d4
   bra.s .lb2
.lb1: swap d4
   clr d4
   swap d4
.lb2: neg d4             ; ici d4 contient [n+1 ou 0].w pour les mises au carr‚
   move.l #logexp,a0     ;                 [ e ].w      exposant de la mantisse
.lb3: cmp dpthex,d4      ; a t-on fini?
   bpl .fin
   move d4,d6
   asl #3,d6
   move d4,d5
   lea -8(a0,d6),a1      ; a1 pointe sur la donn‚e ayant le meme expos que x
   move.l (a1)+,d6
   move.l (a1)+,d7
   sub.l d7,d1
   subx.l d6,d0          ; calcule x-Ci
   bpl.s .lb4            ; positif, c'est bon
   add.l d7,d1
   addx.l d6,d0          ; sinon restaure x
   addq #1,d5            ; prend Ci+1, un eposant en dessous
   move.l (a1)+,d6
   move.l (a1),d7
   lsr.l d6              ; d‚calage oblig‚
   roxr.l d7
   sub.l d7,d1
   subx.l d6,d0          ; calcule le nouveau x-Ci
.lb4: bne.s .lb6         ; si le r‚sulat est nul
   tst.l d1
   beq .lb5              ; on saute
.lb6: btst #20,d0        ; sinon on v‚rifie que x contient toujours le bit 20
   bne.s .lb5
   addq #1,d4            ; cas contraire on d‚cale d'une position
   lsl.l d1
   roxl.l d0
   bra.s .lb6            ; nouvelle v‚rification
.lb5: move d5,d6
   swap d5
   move d6,d5            ; d5 contient deux fois l'exposant de x
   move.l d2,d6
   move.l d3,d7          ; dans d6-d7 on calcule d2-d3 / 2^i
   subq #1,d5
   beq.s .lb8
   cmp #32,d5
   bpl.s .lb7
   move.l d0,a1               ; moins de 32 d‚calages
   move.l d6,d0
   lsr.l d5,d6
   lsr.l d5,d7
   sub #32,d5
   neg d5
   lsl.l d5,d0
   or.l d0,d7
   move.l a1,d0
   bra.s .lb8
.lb7: move.l d6,d7            ; plus de 32 d‚calages, d7 inutile
   moveq #0,d6
   sub #32,d5
   lsr.l d5,d7
.lb8: swap d5
   add.l d7,d3
   addx.l d6,d2               ; d2-d3 = d2-d3 *(1+2^-i)
   move.l d0,d7
   or.l d1,d7                 ; si la mantisse est nulle
   bne .lb3                   ; on ne reviendra pas en arriŠre
.fin: swap d4
   move.l #$3ff00000,d6       ; exposant normal, si e^x < 2
   btst #21,d2                ; si e^x d‚passe 2, bit 21 mis
   beq.s .lb10
   move.l #$40000000,d6       ; alors 1 pour exposant
   lsr.l d2                   ; et on d‚cale
   roxr.l d3
.lb10: bclr #20,d2            ; ote le bit implicite
   or.l d6,d2                 ; ajoute l'exposant
   move.l d2,d0
   move.l d3,d1               ; colle le tout dans d0-d1
   move d4,a0
.lb9: cmp #0,a0               ; eposant de d‚part nul?
   beq.s .sortie              ; si oui pas de mise au carr‚
   subq #1,a0                 ; sinon
   move.l d0,d2
   move.l d1,d3
   bsr submul                 ; au carr‚
   bra.s .lb9                 ; on boucle
.sortie: tst.b signe          ; signe moins?
   beq.s .out
   move.l d0,d2
   move.l d1,d3
   move.l #$3ff00000,d0
   moveq #0,d1
   bsr subdiv                 ; si oui alors exp(-x)=1/exp(x)
.out: move.l d1,(a6)          ; ouf...
   move.l d0,-(a6)
   rts

; algorithme : X=m*2^e
; donc ln(X)= ln(m) + e * ln(2)
; pour le calcul de ln(m) :
;   on ‚crit m sous la forme d'un produit de (1+2^-i)
;   puis ln(m) = somme ( ln(1+2^-i) ), valeurs en m‚moire.
; [ plutot que de diviser m par 1+2^-i ( ce qui est long )
; on part de k=1, puis on calcule k'=k*(1+2^-i) ( par d‚calage et somme )
; ceci tant qu'on ne d‚passe pas m. ]
; [ si X<0, on prend la valeur absolue
;   si m<1+2^-26, on utilise un DL ln(1+x)=x-x^2/2 ]

	SAUT
loga: tst.b is_fpu
   beq.s .emul
   move #$5414,FPCMD.w
   bra _commun_1op
.emul:
   move.l (a6)+,d0
   bclr #31,d0
   move.l (a6),d1             ; d0-d1 = abs(x)
   swap d0
   move d0,d2
   and #$f,d0
   bset #4,d0
   swap d0                    ; d0 ne contient plus que la mantisse
   lsr #4,d2
   bne.s .lb0
   moveq #-1,d0               ; si x=0
   move.l d0,(a6)             ; ln(x)= -infini
   move.l d0,-(a6)
   rts
.lb0: move.l #logexp+8,a1     ; pointe sur ln(1.5)
   sub.l a0,a0
   sub #$3ff,d2               ; d2 est l'exposant
   bne.s .lb1
   moveq #0,d2                ; si l'exp est nul, la partie e*ln(2)
   move.l d2,(a6)             ; est nulle aussi
   move.l d2,-(a6)
   bra.s .lb5
.lb1: bpl.s .lb2
   move #1,a0                 ; a0=1 si l'exp est n‚gatif
   neg d2
.lb2: movem.l d0-d1,-(sp)     ; sauve d0-d1
   moveq #10,d5
.lb3: bclr d5,d2              ; convertit e ( entre 1 et 1024 ) en r‚el
   dbne d5,.lb3
   moveq #0,d3
   moveq #20,d6
   sub d5,d6
   lsl.l d6,d2
   add #$3ff,d5
   lsl #4,d5
   swap d5
   or.l d5,d2                 ; dans d2-d3
   move.l #$3fe62e42,d0       ; ln(2) dans d0-d1
   move.l #-$105c611,d1
   cmp #0,a0
   beq.s .lb4
   bset #31,d0                ; ajuste le signe
.lb4: bsr submul
   move.l d1,(a6)
   move.l d0,-(a6)            ; conserve e*ln(2) sur la pile
   movem.l (sp)+,d0-d1        ; r‚cupŠre d0-d1
.lb5: move.l d0,a2            ; a2-a3 est la mantisse
   move.l d1,a3
   moveq #1,d6                ; nombre de d‚calages ( 1 pour 1.5 )
   moveq #0,d2
   moveq #0,d3
   moveq #0,d1                ; d0-d1 est l'accumulateur 0 au d‚part
   moveq #0,d0
   bset #20,d2                ; d2-d3 est l'approche de la mantisse, 1 au d‚part
.lb6: move.l d2,d4
   move.l d3,d5               ; d4-d5 va etre d2-d3/2^i
   move d6,a0
   cmp #32,d6
   bpl.s .lb7
   move.l d4,d7               ; moins de 32 d‚calages
   lsr.l d6,d4
   lsr.l d6,d5
   sub #32,d6
   neg d6
   lsl.l d6,d7
   or.l d7,d5
   bra.s .lb8
.lb7: move.l d4,d5            ; plus de 32 d‚calages, d5 inutile
   moveq #0,d4
   sub #32,d6
   lsr.l d6,d5
.lb8: move a0,d6
   add.l d3,d5                ; d4-d5= d2-d3+d4-d5, donc d4-d5=d2-d3*(1+2^-i)
   addx.l d2,d4
   cmp.l a2,d4
   bmi.s .ok                  ; ne d‚passe pas la mantisse, ok
   bne.s .autre               ; sinon au suivant
   cmp.l a3,d5                ; meme chose si ‚galit‚ des 21 bits sup‚rieurs
   beq.s .ok
   bcc.s .autre
.ok: move.l d4,d2             ; d2-d3 devient d4-d5
   move.l d5,d3
   tst.l d0
   bne.s .lb9
   move.l (a1)+,d0            ; si d0=0, premier calcul
   move.l (a1)+,d1
   move d6,d7
   swap d6
   move d7,d6                 ; on initialise d6.w (fort)
   swap d6
   bra.s .suite
.lb9: move.l (a1)+,d4         ; sinon on ajoute … d0-d1 ln(1+2^-i)
   move.l (a1)+,d5
   move.l d6,a0
   swap d6
   sub a0,d6
   neg d6                     ; pour cela il faut d‚caler !
   cmp #32,d6
   bpl.s .lb10
   move.l d4,d7               ; moins de 32 d‚calages
   lsr.l d6,d4
   lsr.l d6,d5
   sub #32,d6
   neg d6
   lsl.l d6,d7
   or.l d7,d5
   bra.s .lb11
.lb10: move.l d4,d5            ; plus de 32 d‚calages, d5 inutile
   moveq #0,d4
   sub #32,d6
   lsr.l d6,d5
.lb11: move.l a0,d6
   add.l d5,d1
   addx.l d4,d0                ; mise … jour de l'accumulateur
   btst #21,d0
   beq.s .suite
   lsr.l d0                    ; d‚passe 2, on ajuste
   roxr.l d1
   sub.l #$10000,d6            ; l'exposant aussi
   bra.s .suite
.autre: addq.l #8,a1           ; si pas ok, on passe … i+1
.suite: addq #1,d6
   cmp dpthln,d6               ; a t-on fini?
   bne .lb6
   tst.l d0                    ; si accu nul, alors e*ln(2) suffit
   beq.s .fin
   swap d6                     ; sinon on reforme l'accu avec son exposant
   moveq #-1,d7
   sub d6,d7
   add #$3ff,d7
   lsl #4,d7
   swap d7
   clr d7
   bclr #20,d0
   or.l d7,d0
   move.l (a6)+,d2
   move.l (a6),d3             ; r‚cupŠre e*ln(2)
   bsr subplus                ; additionne ln(m) avec e*ln(2)
   move.l d1,(a6)             ; c'est fini...
   move.l d0,-(a6)
.fin: rts

; sqr(A) utilise l'algorithme de newton appliqu‚ … f(x)=x^2-A
; ce qui donne : x'=(x+A/x)/2, qui est ex‚cut‚ 6 fois avec pour valeur
; de d‚part ( A = m * 2^e ) x = m * 2^(e/2), ce qui assure une erreur
; de d‚part d'un facteur racine de 2 au plus !

	SAUT
sqr:
   bclr #7,(a6)                 ; signe non pris en compte
   tst.b is_fpu
   beq.s .emul
   move #$5404,FPCMD.w
   bra _commun_1op
.emul:
   lea .boucle(pc),a1         ; zone servant de compteur de boucle
   move #6,(a1)                 ; 6 boucles
   move.l a6,a0                 ; on recopie A dans la pile un cran en dessous
   move.l 4(a6),d1              ; A est en plus dans D0/D1
   move.l d1,-(a0)
   move.l (a6),d0
   swap d0
   move d0,d2
   and #$7ff0,d2
   beq .zero
   sub #$3ff0,d2
   asr d2                       ; pour le x de d‚part on divise l'exposant
   add #$3ff0,d2                ; par 2.
   and #$7ff0,d2
   and #$f,d0
   or d2,d0
   swap d0
   move.l d0,-4(a0)
.lb0: move.l d0,d2              ; copie x dans d2/d3
   move.l d1,d3
   move.l (a6),d0               ; A dans d0/d1
   move.l 4(a6),d1
   bsr subdiv                   ; A/x
   move.l (a0),d3               ; x dans d2/d3
   move.l -(a0),d2
   bsr subplus                  ; x+A/x
   sub.l #$00100000,d0          ; (x+A/x)/2
   move.l d0,(a0)+              ; copie le nouveau x dans la pile
   move.l d1,(a0)
   subq #1,(a1)                 ; boucle finie?
   bne.s .lb0
   move.l d0,(a6)               ; si oui d0/d1 sur la pile
   move.l d1,4(a6)
   rts
.boucle: dc.w 0
.zero: clr.l (a6)
   clr.l 4(a6)
   rts

	SAUT
fdiv: tst.b is_fpu
   beq.s .emul
   move #$5420,d0	; code f/
   bra.s _commun_2op
.emul:
   move.l (a6)+,d2
   move.l (a6)+,d3
   move.l (a6)+,d0
   move.l (a6),d1
   bsr subdiv
   move.l d1,(a6)
   move.l d0,-(a6)
   rts

	SAUT
ffois: tst.b is_fpu
   beq.s .emul
   move #$5423,d0	; code f*
   bra.s _commun_2op
.emul:
   move.l (a6)+,d0
   move.l (a6)+,d1
   move.l (a6)+,d2
   move.l (a6),d3
   bsr submul
   move.l d1,(a6)
   move.l d0,-(a6)
   rts

	SAUT
fplus: tst.b is_fpu
   beq.s _emul
   move #$5422,d0	; code f+
_commun_2op:
   lea FPOP.w,a0
   move #$5400,FPCMD-FPOP(a0)
   lea 8(a6),a1
   tst.w FPCIR-FPOP(a0)
   move.l (a1)+,(a0)
   move.l (a1),(a0)
   move d0,FPCMD-FPOP(a0)
   tst.w FPCIR-FPOP(a0)
   move.l (a6)+,(a0)
   move.l (a6)+,(a0)
   move #$7400,FPCMD-FPOP(a0)
.wait: move FPCIR-FPOP(a0),d0
   cmp #$8900,d0
   beq.s .wait
   move.l (a0),(a6)
   move.l (a0),4(a6)
   rts
_emul:
   move.l (a6)+,d0
   move.l (a6)+,d1
   move.l (a6)+,d2
   move.l (a6),d3
   bsr subplus
   move.l d1,(a6)
   move.l d0,-(a6)
   rts

	SAUT
fmoins: tst.b is_fpu
   beq.s .emul
   move #$5428,d0	; code f-
   bra.s _commun_2op
.emul:
   move.l (a6)+,d0
   moveq #31,d7
   bchg d7,d0
   move.l (a6)+,d1
   move.l (a6)+,d2
   move.l (a6),d3
   bsr subplus
   move.l d1,(a6)
   move.l d0,-(a6)
   rts

	SAUT
inv: tst.b is_fpu
   beq.s .emul
   move #$5C32,FPCMD.w	; fmovecr #50,fp0 (1.0 dans fp0)
   tst FPCIR.w
   move #$5420,FPCMD.w	; fdiv
   bra _commun_1op
.emul:
   move.l #$3ff00000,d0
   moveq #0,d1
   move.l (a6)+,d2
   move.l (a6),d3
   bsr subdiv
   move.l d1,(a6)
   move.l d0,-(a6)
   rts

; pour logarithme et exponentielle
; log(1+2^-n) n partant de 0.
; seule la mantisse est pr‚sente ( le bit implicite est mis )
; les exposants commencent … -1 puis descendent de 1 en 1.

logexp:

   dc.l $162E42,-$105C611
   dc.l $19F323,-$134067B4
   dc.l $1C8FF7,-$386565DE
   dc.l $1E2707,$6E2AF2E6
   dc.l $1F0A30,-$3FEE9D5A
   dc.l $1F829B,$E783300
   dc.l $1FC0A8,-$4F03FC1C
   dc.l $1FE02A,$6B106789
   dc.l $1FF00A,-$5D4EF440
   dc.l $1FF802,-$5654EF1A
   dc.l $1FFC00,-$55754EF0
   dc.l $1FFE00,$2AA6AB11
   dc.l $1FFF00,$AAA2AB1
   dc.l $1FFF80,$2AA9AAB
   dc.l $1FFFC0,$AAA8AB
   dc.l $1FFFE0,$2AAA6B
   dc.l $1FFFF0,$AAAA3
   dc.l $1FFFF8,$2AAAA
   dc.l $1FFFFC,$AAAB
   dc.l $1FFFFE,$2AAB
   dc.l $1FFFFF,$AAB
   dc.l $1FFFFF,-$7FFFFD55
   dc.l $1FFFFF,-$3FFFFF55
   dc.l $1FFFFF,-$1FFFFFD5
   dc.l $1FFFFF,-$FFFFFF5
   dc.l $1FFFFF,-$7FFFFFD
   dc.l $1FFFFF,-$3FFFFFF
   dc.l $1FFFFF,-$2000000
   dc.l $1FFFFF,-$1000000
   dc.l $1FFFFF,-$800000
   dc.l $1FFFFF,-$400000
   dc.l $1FFFFF,-$200000
   dc.l $1FFFFF,-$100000
   dc.l $1FFFFF,-$80000
   dc.l $1FFFFF,-$40000
   dc.l $1FFFFF,-$20000
   dc.l $1FFFFF,-$10000
   dc.l $1FFFFF,-$8000
   dc.l $1FFFFF,-$4000
   dc.l $1FFFFF,-$2000
   dc.l $1FFFFF,-$1000
   dc.l $1FFFFF,-$800
   dc.l $1FFFFF,-$400
   dc.l $1FFFFF,-$200
   dc.l $1FFFFF,-$100
   dc.l $1FFFFF,-$80
   dc.l $1FFFFF,-$40
   dc.l $1FFFFF,-$20
   dc.l $1FFFFF,-$10
   dc.l $1FFFFF,-$8
   dc.l $1FFFFF,-$4
   dc.l $1FFFFF,-$2
   dc.l $1FFFFF,-$1

; donn‚es pour les fonctions trigo
; chaque ligne repr‚sente atn(2^-n), en commen‡ant avec n=0.

cordic1:
   dc.l $3FE921FB,$54442D18
   dc.l $3FDDAC67,$561BB4F
   dc.l $3FCF5B75,-$6D37F23
   dc.l $3FBFD5BA,-$6553D092
   dc.l $3FAFF55B,-$48D30216
   dc.l $3F9FFD55,-$445689DB
   dc.l $3F8FFF55,$5BBB729B
   dc.l $3F7FFFD5,$55BBBA97
   dc.l $3F6FFFF5,$555BBBB7
   dc.l $3F5FFFFD,$5555BBBC
   dc.l $3F4FFFFF,$55555BBC
   dc.l $3F3FFFFF,-$2AAAAA44
   dc.l $3F2FFFFF,-$AAAAAA4
   dc.l $3F1FFFFF,-$2AAAAAA
   dc.l $3F0FFFFF,-$AAAAAB
   dc.l $3EFFFFFF,-$2AAAAB
   dc.l $3EEFFFFF,-$AAAAB
   dc.l $3EDFFFFF,-$2AAAB
   dc.l $3ECFFFFF,-$AAAB
   dc.l $3EBFFFFF,-$2AAB
   dc.l $3EAFFFFF,-$AAB
   dc.l $3E9FFFFF,-$2AB
   dc.l $3E8FFFFF,-$AB
   dc.l $3E7FFFFF,-$2B
   dc.l $3E6FFFFF,-$B
   dc.l $3E5FFFFF,-$3
   dc.l $3E4FFFFF,-$1
   dc.l $3E400000,$0
   dc.l $3E300000,$0
   dc.l $3E200000,$0
   dc.l $3E100000,$0
   dc.l $3E000000,$0
   dc.l $3DF00000,$0
   dc.l $3DE00000,$0
   dc.l $3DD00000,$0
   dc.l $3DC00000,$0
   dc.l $3DB00000,$0
   dc.l $3DA00000,$0
   dc.l $3D900000,$0
   dc.l $3D800000,$0
   dc.l $3D700000,$0
   dc.l $3D600000,$0
   dc.l $3D500000,$0
   dc.l $3D400000,$0
   dc.l $3D300000,$0
   dc.l $3D200000,$0
   dc.l $3D100000,$0
   dc.l $3D000000,$0
   dc.l $3CF00000,$0
   dc.l $3CE00000,$0
   dc.l $3CD00000,$0
   dc.l $3CC00000,$0
   dc.l $3CB00000,$0

	endif

; ***********
; fin distinction copro ou pas



; sur la pile (a6) contient le r‚el
; en sortie dans #affbuf se trouve la chaine
; utilise d0-d7 et a0-a3

subaff: lea affbuf,a3
   move.l (a6)+,d0
   bpl.s .lb0
   move.b #'-',(a3)+
   bclr #31,d0
   bra.s .lbb
.lb0: move.b #' ',(a3)+
.lbb: move.l (a6)+,d1
   bne.s .lba
   tst.l d0
   bne.s .lba
   move.l #$20300000,affbuf ; espace, z‚ro, fin
   rts
.lba: moveq #8,d7          ; 9 boucles de 10^+-256 … 10^+-1
   moveq #0,d5          ; puissance de 10
   btst #30,d0          ; si il est mis l'exposant est au moins $400 donc >0
   beq .negatif
   lea posdata+72,a2
.lb1: move.l -(a2),d3
   move.l -(a2),d2
   cmp.l d0,d2
   bmi.s .non
   bne.s .oui
   cmp.l d3,d1
   bcs.s .oui
.non: move d5,a0
   move d7,a1
   bsr subdiv
   move a1,d7
   move a0,d5
   bset d7,d5
.oui: dbf d7,.lb1
   moveq #1,d7
   cmp #8,d5
   bpl .suite
   move d5,d7
   addq #1,d7
   moveq #0,d5
   bra .suite
.negatif: lea negdata+72,a2
 .lb2: move.l -(a2),d3
   move.l -(a2),d2
   cmp.l d2,d0
   bmi.s .non2
   bne.s .oui2
   cmp.l d1,d3
   bcs.s .oui2
.non2: move d5,a0
   move d7,a1
   bsr subdiv
   move a1,d7
   move a0,d5
   bset d7,d5
.oui2: dbf d7,.lb2
   cmp.l #$3ff00000,d0
   bpl.s .lbe
.lbd: move.l (a2)+,d2
   move.l (a2),d3
   move d5,a0
   bsr subdiv
   move a0,d5
   addq #1,d5
.lbe: moveq #1,d7     ; normalement virgule aprŠs le premier chiffre
   cmp #5,d5
   bpl.s .lb5
   tst d5
   beq.s .lb5
   moveq #0,d7     ; sinon pas de virgule !, elle y est d‚j….
   move.b #'0',(a3)+
   move.b #'.',(a3)+ ; puisque je la mets !
   subq #1,d5
   bra.s .lb3
.lb4: move.b #'0',(a3)+
.lb3: dbf d5,.lb4
   moveq #0,d5
.lb5: neg d5
.suite: moveq #10,d6       ; 11 chiffres
   move.l d0,d2
   swap d2
   lsr #4,d2
   sub #$3ff,d2           ; d2 est l'exposant
   and.l #$000fffff,d0    ; on vire l'exposant
   bset #20,d0            ; ajout du bit implicite
   subq #3,d2
   neg d2
.lb6: lsr.l d0
   roxr.l d1
   dbf d2,.lb6               ; now la partie entiŠre de la mantisse est dans le
.lb8: swap d0                ; mot sup‚rieur de d0
   add.b #'0',d0
   move.b d0,(a3)+
   subq #1,d7
   bne.s .lb7
   move.b #'.',(a3)+
.lb7: clr d0
   swap d0
   lsl.l d1
   roxl.l d0
   move.l d1,d3
   move.l d0,d2
   lsl.l d1
   roxl.l d0
   lsl.l d1
   roxl.l d0
   add.l d3,d1
   addx.l d2,d0
   dbf d6,.lb8
   cmp.b #'5',-(a3)
   bmi.s .lb9
   move.l a3,a2
.la0: cmp.b #".",-(a2)
   beq.s .la1
   addq.b #1,(a2)
   cmp.b #'9'+1,(a2)
   bne.s .lb9
   move.b #'0',(a2)
   bra.s .la0
.la1: move.l a2,a0
.la2: cmp.l #affbuf+2,a2
   bmi.s .la3
   addq.b #1,-(a2)
   cmp.b #'9'+1,(a2)
   bne.s .lb9
   move.b #'0',(a2)
   bra.s .la2
.la3: move.b #'1',(a2)
   tst d5
   beq.s .la4
   addq #1,d5
   bra.s .lb9
.la4: move.b #'0',(a0)+
   move.b #'.',(a0)
.lb9: cmp.b #'0',-(a3)
   beq.s .lb9
   cmp.b #'.',(a3)
   beq.s .lb10
   addq.l #1,a3
.lb10: tst d5
   beq.s .fin
   bpl.s .lb11
   move.b #'e',(a3)+
   move.b #'-',(a3)+
   neg d5
   bra.s .lb12
.lb11: move.b #'e',(a3)+
.lb12: addq.l #1,a3
   cmp #10,d5
   bmi.s .lb13
   addq.l #1,a3
   cmp #100,d5
   bmi.s .lb13
   addq.l #1,a3
.lb13: move.l a3,a0
   ext.l d5
.lb14: divs #10,d5
   swap d5
   add.b #'0',d5
   move.b d5,-(a0)
   swap d5
   ext.l d5
   bne.s .lb14
.fin: clr.b (a3)
   rts
; a0 pointe sur la chaine : [+/-][xxxx][./,xxxx][e/E[+/-][xxxx]]
; en sortie d0/d1 le r‚el. erreur=1 si erreur...
; a1 conserve les signes (mantisse puis exposant)
; a2 pointe sur les donn‚es ( chiffres puis puissances de 10 )
; a3 sert … d‚caler l'exposant si il y a des chiffres aprŠs la virgule
; d0-d7,a0-a3 utilis‚s

subval: sub.l a1,a1
   move #1,a3
   cmp.b #'-',(a0)
   bne.s .lb0
   move #1,a1
   addq.l #1,a0
   bra.s .lb1
.lb0: cmp.b #'+',(a0)
   bne.s .lb1
   addq.l #1,a0
.lb1: moveq #0,d0
   moveq #0,d1
.lb2: move.b (a0),d7
   beq .fin
   cmp.b #".",d7
   beq.s .virg
   cmp.b #',',d7
   bne.s .lb20
.virg: sub.l a3,a3
   addq.l #1,a0
   bra.s .lb2
.lb20: cmp.b #"e",d7
   beq.s .exp
   cmp.b #'E',d7
   beq.s .exp
   cmp.w #1,a3
   beq.s .lb21
   subq #1,a3
.lb21: tst.l d0
   beq.s .lb3
   add.l #$100000,d0
   move.l d0,d2
   move.l d1,d3
   add.l #$200000,d2
   bsr subplus
.lb3: moveq #0,d7
   move.b (a0)+,d7
   sub.b #'0',d7
   beq.s .lb2
   cmp.b #10,d7
   bmi.s .lb31
   move #1,erreur
   rts
.lb31: lea chdata,a2
   add d7,d7
   move -2(a2,d7.w),d2
   swap d2
   clr d2
   moveq #0,d3
   bsr subplus
   bra.s .lb2
.exp: addq.l #1,a0
   cmp #1,a1
   bne.s .lb4
   moveq #31,d7
   bset d7,d0
.lb4: sub.l a1,a1
   moveq #0,d4
   cmp.b #'-',(a0)
   bne.s .lb5
   move #1,a1
   addq.l #1,a0
   bra.s .lb6
.lb5: cmp.b #'+',(a0)
   bne.s .lb6
   addq.l #1,a0
.lb6: move.b (a0)+,d7
   beq.s .lb7
   ext.w d7
   sub.w #'0',d7
   muls #10,d4
   add d7,d4
   bra.s .lb6
.fin: moveq #0,d4
   cmp #1,a1
   bne.s .lb71
   moveq #31,d7
   bset d7,d0
.lb7: cmp #1,a1
   bne.s .lb71
   neg d4
.lb71: cmp #1,a3
   beq.s .lb8
   add a3,d4
.lb8: lea posdata,a2
   tst d4
   bpl.s .lb81
   neg d4
   lea negdata,a2
.lb81: move d4,a3
.lb9: move a3,d4
   beq.s .sortie
   lsr d4
   bcc.s .lb10
   move d4,a3
   move.l (a2)+,d2
   move.l (a2)+,d3
   bsr submul
   bra.s .lb9
.lb10: addq.l #8,a2
   move d4,a3
   bra.s .lb9
.sortie: rts

   COPIE fdup,y201
fdup: move.l 4(a6),-(a6)
   move.l 4(a6),-(a6)
y201: rts

   COPIE fdrop,y169
fdrop: addq.l #8,a6
y169: rts

   SAUT
fpt: bsr subaff
   lea affbuf,a0
   cmp.b #' ',(a0)+
   beq.s .areu
   subq.l #1,a0
.areu:
   bsr write_str
   rts

   SAUT
fval: move.l (a6),a0
   bsr subval
   move.l d1,(a6)
   move.l d0,-(a6)
   rts

   ASS 0
empilfl: move.l (a5)+,-(a6)
   move.l (a5)+,-(a6)
   rts

   COPIE fptpt,y170,1
fptpt: jsr fdup
   jsr fpt
y170: rts

   COPIE fswap,y202
fswap: move.l a6,a0
   lea 8(a6),a1
   move.l (a1),d1
   move.l (a0),(a1)+
   move.l d1,(a0)+
   move.l (a1),d1
   move.l (a0),(a1)
   move.l d1,(a0)
y202: rts

   COPIE fover,y171
fover: move.l 12(a6),-(a6)
   move.l 12(a6),-(a6)
y171: rts

   COPIE frcl,y172
frcl: move.l (a6),a0
   move.l 4(a0),(a6)
   move.l (a0),-(a6)
y172: rts

	SAUT
ifrcl:
	move.l (a6),a0
	movem.l (a0),d0-d1
	ror #8,d0
	ror #8,d1
	swap d0
	swap d1
	ror #8,d0
	ror #8,d1
	move.l d0,(a6)
	move.l d1,-(a6)
	rts

   COPIE fsto,y173
fsto: move.l (a6)+,a0
   move.l (a6)+,(a0)+
   move.l (a6)+,(a0)
y173: rts

	SAUT
ifsto: move.l (a6)+,a0
	movem.l (a6)+,d0-d1
	ror #8,d0
	ror #8,d1
	swap d0
	swap d1
	ror #8,d0
	ror #8,d1
	move.l d1,(a0)+
	move.l d0,(a0)
	rts

   COPIE fegal,y174
fegal: moveq #0,d1
   move.l a6,a0
   lea 8(a6),a1
   add.w #16,a6
   cmp.l (a0)+,(a1)+
   bne.s .fin
   cmp.l (a0)+,(a1)+
   bne.s .fin
   moveq #1,d1
.fin: move.l d1,-(a6)
y174: rts

   SAUT
fsup: move.l (a6)+,d0
   bmi.s .lb0
   move.l (a6)+,d1
   move.l (a6)+,d2
   bmi.s .non
   cmp.l d0,d2
   bmi.s .non
   bne.s .oui
   cmp.l (a6),d1
   bcc.s .non
.oui: moveq #1,d0
   move.l d0,(a6)
   rts
.non: moveq #0,d0
   move.l d0,(a6)
   rts
.lb0: moveq #31,d7
   bclr d7,d0
   move.l (a6)+,d1
   move.l (a6)+,d2
   bpl.s .oui
   bclr d7,d2
   cmp.l d0,d2
   bmi.s .oui
   bne.s .non
   cmp.l (a6),d1
   bcs.s .non
   beq.s .non
   bra.s .oui

   SAUT
appl_getinfo:
	A1 130,1,4,0

   COPIE fabs,y200
fabs: bclr #7,(a6)
y200: rts

   COPIE pee,y175,1
pee: move.l #pi+4,a0
   move.l (a0),-(a6)
   move.l -(a0),-(a6)
y175: rts

   COPIE fneg,y176
fneg: bchg #7,(a6)
y176: rts

   SAUT
power: bsr fswap
   bsr loga
   bsr ffois
   bra expo

   SAUT
appl_trecord:
	A1 15,1,1,1

   COPIE ffois2,y177
ffois2: move.l (a6)+,d2
   move.l (a6),d0
   beq.s y177
   swap d0
   cmp #8000,d0
   beq.s y177
   lsl #4,d2
   add d2,d0
   move d0,(a6)
y177: rts

   COPIE sign,y178
sign: moveq #0,d0
   move.l (a6)+,d1
   beq.s .fin
   bclr #31,d1
   beq.s .un
   tst.l d1
   beq.s .fin
   moveq #-1,d0
   bra.s .fin
.un: moveq #1,d0
.fin: move.l d0,(a6)
y178: rts

   COPIE fsurr,y179
fsurr: move.l (a6)+,-(a4)
   move.l (a6)+,-(a4)
y179: rts

   COPIE rsurf,y180
rsurf: move.l (a4)+,-(a6)
   move.l (a4)+,-(a6)
y180: rts

   COPIE frot,y181
frot: lea 8(a6),a1
   lea 16(a6),a0
   move.l (a6),d0
   move.l (a1),(a6)+
   move.l (a0),(a1)+
   move.l d0,(a0)+
   move.l (a6),d0
   move.l (a1),(a6)
   move.l (a0),(a1)
   move.l d0,(a0)
   subq.l #4,a6
y181: rts

   COPIE fpick,y182
fpick: move.l (a6),d0
   if STE=0
   	lea 0(a6,d0*8),a0
   else
   	asl.l #3,d0
   	lea 0(a6,d0),a0
   endif
   move.l (a0),(a6)
   move.l -(a0),-(a6)
y182: rts

   COPIE islast,y183
islast: move.l (a6)+,a0
   clr.l 8(a0)
y183: rts

   COPIE pempty,y184,1
pempty: move.l (a6)+,a0
   move.l (a0),a2
   move.l a2,d7
   clr.l (a0)
.lb1: tst.l d7
   beq.s y184
   move.l 8(a2),d7
   jsr libere
   move.l d7,a2
   bra.s .lb1
y184: rts

   SAUT
compset: move.l (a6),a1
   move.l #setdat,a2
   move.l a2,(a6)
   move (a1)+,(a2)+
   move (a1)+,d0
   move d0,(a2)+
   move d0,d1
   lsr #3,d0
   and #$7,d1
   bne.s .lb1
   subq #1,d0
.lb1: move.b (a1)+,(a2)
   not.b (a2)+
   dbf d0,.lb1
   clr.b (a2)
   tst d1
   beq.s .lb2
   moveq #8,d2
   sub d1,d2
   lsr.b d2,d0
   and.b d0,-(a2)
.lb2: rts

   COPIE pint,y185
pint: move.l (a6)+,d0
   move.l a6,-(sp)
   moveq #4,d1
   move.l d1,-(sp)
   move d0,-(sp)
   UP
   GEMDOS 64,12
y185: rts

   COPIE pflt,y186
pflt: move.l (a6)+,d0
   move.l a6,-(sp)
   moveq #8,d1
   move.l d1,-(sp)
   move d0,-(sp)
   addq.l #8,a6
   GEMDOS 64,12
y186: rts

   SAUT
pstr: move.l (a6)+,d0
   move.l (a6)+,a3
   move.l a3,a0
   move -2(a3),d7
.lb1: tst.b (a0)+
   bne.s .lb1
   move.l a0,d5
   sub.l a3,a0
   move a0,-(a3)
   addq #2,a0
   move.l a3,-(sp)
   move.l a0,-(sp)
   move d0,-(sp)
   GEMDOS 64,12
   move d7,(a3)+
   rts

   COPIE pset,y187
pset: move.l (a6)+,d0
   move.l (a6)+,a3
   addq.l #2,a3
   moveq #0,d7
   move (a3)+,d7
   move d7,d6
   lsr #4,d7
   and #$f,d6
   beq.s .lb1
   addq #1,d7
.lb1: add d7,d7
   move.l a3,-(sp)
   move.l d7,-(sp)
   move d0,-(sp)
   GEMDOS 64,12
y187: rts

   COPIE pstruc,y188
pstruc: move.l (a6)+,d0
   move.l (a6)+,a3
   move.l 4(a3),d6
   move.l (a3),-(sp)
   move.l d6,-(sp)
   move d0,-(sp)
   GEMDOS 64,12
y188: rts

   COPIE rint,y189
rint: move.l a6,-(sp)
   moveq #4,d6
   move.l d6,-(sp)
   move 2(a6),-(sp)
   GEMDOS 63,12
   cmp d6,d0
   bne.s .lb1
   moveq #1,d1
   move.l d1,-(a6)
   bra.s y189
.lb1: clr.l (a6)
y189: rts


   SAUT
rstr: move.l (a6)+,d5
   move.l (a6),a3
   move.l a6,-(sp)
   moveq #2,d0
   move.l d0,-(sp)
   move d5,-(sp)
   GEMDOS 63,12
   cmp #2,d0
   bne.s .ach
   move.l a3,-(sp)
   moveq #0,d7
   move (a6),d7
	move.l d7,-(sp)
   move d5,-(sp)
   GEMDOS 63,12
   cmp.l d7,d0
   bne.s .ach
   moveq #1,d0
   move.l d0,(a6)
   rts
.ach: clr.l (a6)
   rts

   COPIE rflt,y190
rflt: subq.l #4,a6
   move.l a6,-(sp)
   moveq #8,d6
   move.l d6,-(sp)
   move 6(a6),-(sp)
   GEMDOS 63,12
   cmp d6,d0
   bne.s .ach
   moveq #1,d1
   move.l d1,-(a6)
   bra.s y190
.ach: addq.l #4,a6
   clr.l (a6)
y190: rts

   SAUT
rset: move.l (a6)+,d0
   move.l (a6),a3
   addq.w #2,a3
   move (a3)+,d7
   move d7,d6
   lsr #4,d7
   and #$f,d6
   beq.s .lb1
   addq #1,d7
.lb1: add d7,d7
   move.l a3,-(sp)
   move.l d7,-(sp)
   move d0,-(sp)
   GEMDOS 63,12
   clr.l (a6)
   cmp d0,d7
   bne.s .ach
   moveq #1,d1
   move.l d1,(a6)
.ach: rts

   COPIE rstruc,y191
rstruc: move.l (a6)+,d0
   move.l (a6),a3
   move.l (a3)+,-(sp)
   move.l (a3),d7
   move.l d7,-(sp)
   move d0,-(sp)
   GEMDOS 63,12
   clr.l (a6)
   cmp.l d7,d0
   bne.s y191
   moveq #1,d1
   move.l d1,(a6)
y191: rts

   SAUT
cmove: move.l (a6)+,d0
   move.l (a6)+,a0
   move.l (a6)+,a1
   moveq #0,d1
   move sizeptr,d1
   asl.l d1,d0
   move.l d0,d1
   move.l d0,d7
   and #$f,d1
   asr.l #4,d0
   tst sizeptr
   beq.s .oct
   cmp.l a0,a1
   bmi.s .lb4
   bra.s .lba
.lb1:
   rept 4
   move.l (a1)+,(a0)+
   endr
.lba:
	subq.l #1,d0
	bpl.s .lb1
	bra.s .lbb
.lb3: move.b (a1)+,(a0)+
.lbb: dbf d1,.lb3
.fin: rts
.lb4: add.l d7,a0
   add.l d7,a1
   bra.s .lbc
.lb5:
   rept 4
   move.l  -(a1),-(a0)
   endr
.lbc:
   subq.l #1,d0
   bpl.s .lb5
   bra.s .lbd
.lb7: move.b -(a1),-(a0)
.lbd: dbf d1,.lb7
   rts
.oct: cmp.l a0,a1
   bmi.s .lb9
   bra.s .lbe
.lb8:
   rept 16
   move.b (a1)+,(a0)+
   endr
.lbe:
	subq.l #1,d0
	bpl.s .lb8
   bra.s .lbb
.lb9: add.l d7,a0
   add.l d7,a1
   bra.s .lbf
.lb10:
   rept 16
   move.b -(a1),-(a0)
   endr
.lbf:
	subq.l #1,d0
	bpl.s .lb10
   bra.s .lbd

   SAUT
vqt_devinfo:
	V1 248,0,1,0

   SAUT
vm_filename:
	bsr _intin_str
	V5 5,0,100

   SAUT
v_meta_extents:
	V1 5,2,0,98

   SAUT
vm_pagesize:
	moveq #0,d0
	move.l a6,a0
	lea -4(a6),a6
	move.l a6,a1
	move.l (a0)+,(a1)+
	move.l (a0),(a1)
	move.l d0,(a0)
	V1 5,0,3,99

   SAUT
setable: move.l (a6)+,d7
   bmi.s .lb0
   move.l szone,-(sp)
   GEMDOS $49,6
   move.l d7,-(sp)
   GEMDOS $48,6
   move.l d0,szone
.lb0: move.l szone,a0
   clr.l (a0)+
   clr.l (a0)+
   moveq #-1,d0
   move.l d0,(a0)
   move.l topmem,botmem
   rts

   SAUT
setdigits: move.l (a6)+,d0
   bgt.s .lb0
   moveq #1,d0
.lb0: cmp #18,d0
   bmi.s .lb1
   moveq #17,d0
.lb1: move d0,fixn
   rts

   NON
fleche: rts

   NON
andfl: tst.l (a6)
   beq.s .lb0
   UP
   addq.l #2,a5
   rts
.lb0: add.w (a5)+,a5
   rts

   NON
andorpt: tst.l (a6)
   beq.s .lb0
   moveq #-1,d0
   move.l d0,(a6)
.lb0: rts

   NON
orfl: tst.l (a6)
   beq.s .lb0
   add.w (a5)+,a5
   moveq #-1,d0
   move.l d0,(a6)
   rts
.lb0: addq.l #2,a5
   UP
   rts

   COPIE pageclip,y192,1
pageclip:
   move.l fenetre,a0
   lea c_pts,a1
   move.l (a0)+,d0
   move.l d0,(a1)+
   add.l (a0),d0
   sub.l #$10001,d0
   move.l d0,(a1)
   move handle,c_cont+12
   move.l #clip_tab,d1
   moveq #$73,d0
   trap #2
y192: rts
clip_tab: dc.l c_cont,c_int,c_pts,dum,dum
c_cont: dc.w 129,2,0,1,0,0,0,0,0,0,0,0,0
c_int: dc.w 1
c_pts: dc.w 0,0,0,0

   SAUT
v_ftext:
	move #241,d7
	moveq #0,d6
	bra _text

   SAUT
v_clear_disp_list:
	V3 5,22

   SAUT
v_updwk:
	V3 4,0

   COPIE st1,y195
st1: move.l (a6)+,a0
   move.l (a6)+,d0
   subq.l #4,(a0)
   move.l (a0),d1
   move.l d0,0(a0,d1.l)
y195: rts

   COPIE st2,y196
st2: move.l (a6),a0
   move.l (a0),d1
   move.l 0(a0,d1.l),(a6)
   addq.l #4,(a0)
y196: rts

   COPIE current,y197,1
current: move.l (a6)+,a0
   move.l #pilbase,a1
   move.l (a1),a2
   sub.l a2,a6
   move.l a6,(a2)
   move.l a0,(a1)
   move.l (a0),a6
   add.l a0,a6
y197: rts

   COPIE stack0,y203,1
stack0: move.l #pile+4100,d0
	and.b #$fc,d0
	move.l d0,-(a6)
y203:   rts

   SAUT
cache: move.l (a6)+,.lb1
	if STE=0
	   move.l #.lb0,-(sp)
  		XBIOS 38,6
   	rts
		.lb0: move.l .lb1,d0
   	movec d0,cacr
   endif
   rts
.lb1: dc.l 0

cache_off:
	if STE=0
		pea .off(pc)
		XBIOS 38,6
		rts
		.off:
		cmp #40,cpu_value+2
		bpl.s .lb0
		movec cacr,d0
		or #$808,d0
		movec d0,cacr			  ; vide le cache
		rts
	.lb0:
		dc.w $F4F8		; flush instruction cache
	endif
	rts

   COPIE set_redraw,wds,1
set_redraw:
	lea redrawdat+12,a0
	rept 5
		move.l (a6)+,d0
		move d0,-(a0)
	endr
	clr -(a0)        ; first rectangle pas encore appel‚
wds:	rts

   COPIE get_xywh,wsd
get_xywh:
	move.l (a6)+,a0
	moveq #0,d0
	rept 4
   	move (a0)+,d0
	   move.l d0,-(a6)
	endr
wsd:	rts

   SAUT
get_xyxy:
	move.l (a6)+,a0
	moveq #0,d4
	moveq #0,d5
	moveq #0,d0
	moveq #0,d1
	moveq #0,d2
	moveq #0,d3
	tst.b xy_flag
	beq.s .lb0
	move.l fenetre,a1
	move (a1)+,d4
	move (a1),d5
.lb0:
	movem.w (a0)+,d0-d3
   sub d4,d0
   add d0,d2
   subq #1,d2
   sub d5,d1
   add d1,d3
   subq #1,d3
   move.l d0,-(a6)
   move.l d1,-(a6)
   move.l d2,-(a6)
   move.l d3,-(a6)
   rts

   COPIE _work_out,sqw,1
_work_out:
	move.l #work_out,-(a6)
sqw: rts

	SAUT
vqt_f_extent:
	bsr _intin_str		; renvoit la longueur dans d2
	V5 240,0,0

; pour les fonctions ayant d2 (taille intin) d‚j… initilalis‚e
; et aucun paramŠtre … passer
; V5 opcode,ptsin,sub_code

vdicinq:
   lea control(pc),a0
	move d0,(a0)+
	move d1,(a0)+
	move.l d2,(a0)+
	move.l d3,(a0)+
	move handle,(a0)
	VDI
	rts

_intin_str:
	lea intin,a1
_intin_str2:
	move.l (a6)+,a0
	moveq #0,d0
	move.l a0,d2
.lb0:
	move.b (a0)+,d0
	beq.s .fin
	move d0,(a1)+
	bra.s .lb0
.fin:
	sub.l a0,d2
	neg.l d2
	subq.l #1,d2      ; taille dans d2
	rts

_intin_str16:
	lea intin,a1
	move.l (a6)+,a0
	move.l a0,d2
.lb0:
	move (a0)+,(a1)+
	bne.s .lb0
	sub.l a0,d2
	neg.l d2
	subq.l #1,d2
	rts

   SAUT
_redraw:
   moveq #12,d7      ; next par d‚faut
   moveq #0,d4
   moveq #0,d5       ; offset nul par d‚faut
   tst.b xy_flag
   beq.s .pas_off
  	move.l fenetre,a0
   move.w (a0)+,d4
   move.w (a0),d5
.pas_off:
	lea redrawdat,a3
	tst (a3)+
	beq .premier      ; premier appel
	bpl .suivant      ; appel normal
	clr.l -(a6)       ; si c'est n‚gatif, il n'y a d‚j… plus de rectangles!
	rts
.premier:
	move #1,wu_int
	GEM_AES wind_update
	GEM_VDI hide_mouse
	move #1,-2(a3)    ; ce n'est plus le premier appel
	addq.l #2,a3
	move.l (a3)+,d0   ; x et y
	sub.l #$10001,d0  ; pour faire joli
	add.l d0,(a3)     ; remplace l et h par x' et y' (fastoche)
	lea -6(a3),a3     ; revient sur handle
	lea wg_int,a0
	move (a3)+,(a0)+
	move #4,(a0)
	GEM_AES wind_get0 ; work_area pour limiter les valeurs de set_redraw
	lea wg_out+2,a0
	movem.w (a0)+,d0-d3
	cmp (a3)+,d0
	bmi.s .g0
	move d0,-2(a3)
.g0:
	cmp (a3)+,d1
	bmi.s .g1
	move d1,-2(a3)
.g1:
	subq #1,d0
	add d0,d2
	cmp (a3)+,d2
	bpl.s .g2
	move d2,-2(a3)
.g2:
	subq #1,d1
	add d1,d3
	cmp (a3),d3
	bpl.s .g3
	move d3,(a3)
.g3:
	lea -8(a3),a3     ; retour sur le handle
	moveq #11,d7      ; premier rectangle
.suivant:
	lea wg_int,a0
	move (a3)+,(a0)+  ; le handle
	move d7,(a0)      ; first ou next
	GEM_AES wind_get0 ; le rectangle
	moveq #12,d7      ; si il y en a un autre, plus le premier
   lea wg_out,a0
   tst (a0)+
   beq .dernier      ; si 0, une erreur, on arrˆte l…!
   tst.l 4(a0)       ; l et h
   beq .dernier      ; si nuls, il n'y a plus de rectangles
   moveq #0,d3
   move (a0)+,d3     ; x
   add d3,2(a0)      ; l+x
   cmp (a3)+,d3
   bpl.s .lb0
   move -2(a3),d3
.lb0:
	moveq #0,d2
	move (a0)+,d2     ; y
	add d2,2(a0)      ; h+y
	cmp (a3)+,d2
	bpl.s .lb1
	move -2(a3),d2
.lb1
	sub.l #$10001,(a0)
	moveq #0,d1
	move (a0)+,d1     ; x'
	cmp (a3)+,d1
	bmi.s .lb2
	move -2(a3),d1
.lb2:
	moveq #0,d0
	move (a0)+,d0
	cmp (a3)+,d0
	bmi.s .lb3
	move -2(a3),d0
.lb3:
	lea -10(a3),a3    ; revient sur la handle
	cmp d3,d1
	bmi .suivant      ; pas d'intersection car x'<x
	cmp d2,d0
	bmi .suivant      ; meme chose, y'<y
	sub.l d4,d3
	sub.l d4,d1
	sub.l d5,d2
	sub.l d5,d0       ; d‚cale les coordonn‚es en mode relatif
	movem.l d0-d3,-(a6)  ; sinon donne x y x' y'
	moveq #1,d0
	move.l d0,-(a6)   ; et le flag 1, rectangle correct
   bra.s .fin
.dernier:
	clr wu_int
	GEM_AES wind_update  ; libŠre l'‚cran
	GEM_VDI show_mouse
	move #-1,redrawdat   ; c'est fini
	clr.l -(a6)
.fin:
	moveq #4,d0
	move.l d0,wg_int     ; wind_get normal pour fastopen
	rts

   SAUT
vst_arbpt:
	V1 246,0,1,0

   SAUT
vst_setsize:
	V1 252,0,1,0

   SAUT
vst_skew:
	V1 253,0,1,0


playdata: dc.b $81       ; $80 mono, 0-1-2-3 pour 6, 12, 25, 50 kHz
          dc.b $01       ; 8 bits, pas de r‚p‚tition; 3 si r‚p‚tition, et $8x si 16 bits SAGA
          dc.l 0			 ; timer de fin d'un son SAGA ou z‚ro si le son est fini

   SAUT
play: cmp #6,mch_value
	beq.s _saga
	tst.l (a6)				; si -1, attendre fin du son
	bmi.s .wait
	move.l #_play,-(sp)	; sinon stopper (0) ou lancer.
   move #38,-(sp)
   trap #14
   addq.l #6,sp
   add.w d0,a6
   rts
.wait:
	pea .test_dma(pc)			; octet de controle
	XBIOS 38,6
	btst #0,d0					; ‡a joue encore !
	bne.s .wait
	addq.l #4,a6
	rts
.test_dma:
	move.b $FFFF8901.w,d0		; bit 0 … 1 tant que le son est jou‚
	rts


_play:
	lea $FFFF8900.w,a0   ; sound system
   move.b #0,1(a0)          ; stoppe le DMA
   move.l (a6)+,d0          ; longueur ou option
   beq.s .fin4              ; si z‚ro, arrˆt demand‚ seulement
   move.b 1(a6),3(a0)       ; adresse, high byte
   move.b 2(a6),5(a0)       ; medium
   move.b 3(a6),7(a0)       ; low
   add.l d0,(a6)            ; adresse de fin
   addq.l #1,a6
   move.b (a6)+,$f(a0)
   move.b (a6)+,$11(a0)
   move.b (a6)+,$13(a0)
   move.b playdata,$21(a0)  ; fr‚quence et mono/st‚r‚o
   move.b playdata+1,1(a0)  ; DMA lanc‚, et r‚p‚tition (on/off)
   moveq #8,d0              ; deux longs … restaurer
   rts
.fin4:
	moveq #4,d0
	rts

	if STE=1
		MC68030
	endif

_saga:
	lea $DFF400,a0
	lea playdata(pc),a3
	move.l (a6)+,d0			; taille ou 0/-1
	bmi .wait
	move #1,$DFF096			; stoppe le son
	clr.l 2(a3)					; remet le timer … z‚ro
	tst.l d0
	beq .fin4					; zero, juste arrˆter
	move.l (a6)+,(a0)			; start
	move #$FFFF,8(a0)			; volumes
	lsr.l #1,d0					; pairs
	moveq #2,d1					; 8 bits mono one-shot
	tst.b (a3)
	bmi.s .lb1					; if<0 then mono
	lsr.l #1,d0
	addq #4,d1					; mark stereo
.lb1:
	tst.b 1(a3)
	bpl.s .lb2					; if>0 then 8 bits
	lsr.l #1,d0
	addq #1,d1					; mark 16 bits
.lb2:
	btst #1,1(a3)				; repeat?
	beq.s .lb3
	bclr #1,d1					; one shot
.lb3:
	move d1,10(a0)				; control word
	move.l d0,4(a0)			; pairs
	muls #400,d1:d0
	moveq #3,d2
	move.b (a3),d3
	and.l d2,d3					; frequency 0-1-2-3
	move.w .tab(pc,d3.l*2),d2	; SAGA value
	move d2,12(a0)
	move.l #3546326,d3
	divs d2,d3					; real fequency
	swap d3
	clr d3
	swap d3
	divs.l d3,d1:d0			; d0 = duration in 1/200
	move.l d0,d3
	pea .test_time(pc)
	XBIOS 38,6
	add.l d0,d3
	move.l d3,2(a3)
	move #$8201,$DFF096
	rts
.tab: dc.w 567,283,141,70
.wait:
	move.l 2(a3),d3			; timer de fin
	clr.l 2(a3)					; reset timer
.wait1:
	pea .test_time(pc)		; prend l'heure
	XBIOS 38,6
	cmp.l d0,d3					; d3 atteint?
	bpl.s .wait1
.fin4:
	rts
.test_time:
	move.l $4ba.w,d0
	rts

	if STE=1
		MC68000
	endif


	SAUT
setplay: lea playdata,a0
   move.l (a6)+,d0          ; frequence (0 … 3 )
   bmi.s .lb2					 ; si -1 renvoie la disponibilit‚
   and.b #3,d0
   btst #0,3(a6)            ; mono : 0, 1 st‚r‚o
   bne.s .lb0
   bset #7,d0               ; le bit 7 est le contraire
.lb0: move.b d0,(a0)+
   moveq #1,d0              ; le bit : son allum‚
	cmp #6,mch_value
	bne.s .lb3					 ; not saga
	btst #1,3(a6)				 ; set for 16 bits
	beq.s .lb3
	bset #7,d0					 ; $8x for 16 bits
.lb3:
	addq.l #4,a6
   tst.l (a6)+              ; 0 une fois, 1 repeat
   beq.s .lb1
   addq #2,d0
.lb1: move.b d0,(a0)        ; voil… !
   rts
   								 ; -1 setplay renvoie 0 (pas de DMA), 1 DMA Atari, 2 DMA SAGA
.lb2:
	moveq #0,d0
	btst #1,snd_value+3
	beq.s .end					; no DMA
	moveq #1,d0
	cmp #6,mch_value
	bne.s .end					; DMA but no Saga
	moveq #2,d0					; Saga!
.end:
	move.l d0,-(a6)
	rts

replay_flag: dc.w 0         ; mis … 1 par l'interruption pour stopper
replaydat: dc.l .inter      ; routine d'interruption
           dc.l .init       ; initialisation
           dc.b 31          ; data pour timer A
           dc.b 1           ; control pour timer A

.inter:
   move $fb0000,d0
   if STE=0
	   tst.w ($fa8000,d0.w)
	else
		lea $fa8000,a0
		tst.w 0(a0,d0.w)
	endif
   rte

.init:  rts

   SAUT
setreplay:
   lea replaydat,a0
	move.l (a6)+,(a0)+       ; interruption
	move.l (a6)+,(a0)+       ; initialisation
	move.l (a6)+,d0          ; fr‚quence souhait‚e
	bsr.s data_control		 ; place dans (a0) et 1(a0) data et control
									 ; selon la fr‚quence en d0
	rts

; utilise d0 … d5, a0 et a1 et les piles a6 et sp

data_control:
	if STE=1
		movem.l d6-d7,-(sp)
	endif
	move.l d0,d5
	asr.l #1,d5              ; freq/2 pour les restes
	lea .freq,a1
	moveq #7,d1
	move.l #$7fffffff,d2     ; ‚cart au maximum
.lb0:
	if STE=0
		move.l (a1),d3
	   divsl.l d0,d4:d3         ; calcule le data
	else
		move.l (a1),-(a6)
		move.l d0,-(a6)
		movem.l d0-d2/d5,-(sp)
		bsr spdiv
		move.l d2,d3
		move.l d1,d4
		addq.l #4,a6
		movem.l (sp)+,d0-d2/d5
	endif
   cmp.l d4,d5
   bpl.s .lb1
   addq.l #1,d3             ; arrondit au dessus si le reste > freq/2
.lb1: move.l (a1)+,d4
   tst.l d3                 ; data nul?
   beq.s .lb4               ; si oui, il faut passer !
   cmp.l #256,d3
   bpl.s .lb4               ; il faut que data tienne dans un octet
   if STE=0
	   divsl.l d3,d4:d4         ; recalcule la fr‚quence
	else
		move.l d4,-(a6)
		move.l d3,-(a6)
		movem.l d0-d3/d5,-(sp)
		bsr spdiv
		move.l d2,d4
		addq.l #4,a6
		movem.l (sp)+,d0-d3/d5
	endif
   sub.l d0,d4              ; ‚cart avec la fr‚quence demand‚e
   bpl.s .lb2
   neg.l d4                 ; ‚cart en valeur absolue
.lb2: cmp.l d4,d2
   bmi.s .lb4               ; l'‚cart pr‚c‚dent ‚tait moindre
   move.l d4,d2             ; change le maxi
   move.b d3,(a0)           ; data
   move.b d1,1(a0)          ; control
.lb4: subq #1,d1            ; control suivant
   bne.s .lb0
   if STE=1
   	movem.l (sp)+,d6-d7
   endif
   rts
.freq: dc.l 12288,24576,38400,49152,153600,245760,614400

	SAUT
replay_in: move.l (a6)+,d0  ; nø du r‚gistre de donn‚es
   and.w #7,d0
   lsl #8,d0
   lsl #1,d0
   add.w #$3039,d0
   move.l topprg,a0
   move d0,(a0)+
   move.l #$fb0000,(a0)+    ; fabrique move $fb0000,dn
   move.l a0,topprg
   rts

	SAUT
replay_out: move.l (a6)+,d0  ; nø du r‚gistre
   and.w #7,d0
   lsl #8,d0
   lsl #4,d0
   move.l topprg,a0
   if STE=0
	   add #$01b0,d0
	   move #$4a70,(a0)+
	   move d0,(a0)+
   	move.l #$fa8000,(a0)+     ; fabrique tst ($fa8000,dn.w)
	else
		move.w #$41f9,(a0)+
		move.l #$00fa8000,(a0)+			; lea $fa8000,a0
		move #$4a70,(a0)+
		move d0,(a0)+						; tst 0(a0,dn.w)
	endif
   move.l a0,topprg
   rts

	SAUT
replay_end: move.l topprg,a0
   lea .r_end,a1
   move.l (a1)+,(a0)+
   move.l (a1)+,(a0)+
   move.l (a1)+,(a0)+
   move (a1),(a0)+
   move.l topprg,a0
.r_end: move.l #.nul,$184.w
   st replay_flag
.nul: rte

   SAUT
replay:
   move #$ff,-(sp)
   GEMDOS 6,4
   tst d0
   bne.s replay
   moveq #10,d7
.vbl:
   XBIOS 37,2
   dbf d7,.vbl
   clr.l   -(SP)
   move   #32,-(SP)       ; superviseur
   trap   #1
   addq.l   #6,SP
   move.l d0,.stk
   move.b $484.w,.clic       ; plus de clic, ni de r‚p‚tition, ni de souris
   clr.b $484.w
	lea .mouseoff,a1
	bsr .ikbd
.vide:	tst.b $108e.w
	bne.s .vide
	move sr,d0
	or #$700,sr
	tst.b $108e.w
	beq.s .ouf
	move d0,sr
	bra.s .vide
.ouf: move.b $fffa07,.mfp
   move.b $fffa09,.mfp+1
   move.b #$20,$fffa07
   move.b #0,$fffa09
   bclr #3,$fffa17
   sf replay_flag
   lea replaydat,a3
   move.l (a3)+,-(sp)   ; routine d'interruption
   move.l (a3)+,-(a6)   ; routine d'initialisation
   moveq #0,d0
   move.b (a3)+,d0
   move d0,-(sp)                  ; data
   move.b (a3),d0
   move d0,-(sp)                  ; control
   clr -(sp)                        ; timer a
   move #31,-(sp)
   trap #14                         ; xbtimer
   add.w #12,sp
   move.l (a6)+,a2
   jsr (a2)
   move $fb0000,d0
   move #$2500,sr                   ; on active
.wait: tst.b replay_flag
   bne .fin                       ; l'interruption elle meme demande la fin
   btst #0,$fffc04                ; midi
   beq.s .rien
   move.b $fffc06,d0
.rien:
	btst #0,$fffc00                ; clavier/souris/joystick
	beq.s .wait
	move.b $fffc02,d0              ; code envoy‚
	cmp.b #$f5,d0
	bcs.s .wait                      ; pas au dessus de F6...
	cmp.b #$f8,d0
	beq.s .souris_nul
	cmp.b #$fb,d0
	beq.s .souris_nul
	cmp.b #$fa,d0
	beq.s .souris_fin
	cmp.b #$f9,d0
	beq.s .souris_fin
	cmp.b #$fe,d0
	beq.s .joystick
	cmp.b #$ff,d0
	bne.s .wait
.joystick: btst #0,$fffc00
   beq.s .joystick
   move.b $fffc02,d0
   btst #7,d0
   beq .wait
   bra .fin
.souris_nul: btst #0,$fffc00
   beq.s .souris_nul
   move.b $fffc02,d0
.lb0: btst #0,$fffc00
   beq.s .lb0
   move.b $fffc02,d0
   bra .wait
.souris_fin: btst #0,$fffc00
   beq.s .souris_fin
   move.b $fffc02,d0
.lb1: btst #0,$fffc00
   beq.s .lb1
   move.b $fffc02,d0
.fin:
	move #$2700,sr
	move.b .mfp,$fffa07
	move.b .mfp+1,$fffa09
	bclr #5,$fffa07
	bclr #5,$fffa0b
	bclr #5,$fffa0f
	bclr #5,$fffa13
	bset #3,$fffa17
   move #$2000,sr
   lea .mouseon,a1
   bsr .ikbd
.vide2: move #$ff,-(sp)
   GEMDOS 6,4
   tst d0
   bne.s .vide2
   move.b .clic,$484.w
   move.l .stk,-(SP)
   move.w   #32,-(SP)            ; mode utilisateur
   trap   #1
   addq.l   #6,SP
   rts
.ikbd: move.l a1,-(sp)
   clr -(sp)
   move #25,-(sp)            ; mouse on ou off
   trap #14
   addq.l #8,sp
   move #37,-(sp)            ; attend deux vbl
   trap #14
   addq.l #2,sp
   move #37,-(sp)
   trap #14
   addq.l #2,sp
   rts

.mouseoff: dc.b $12
.mouseon:  dc.b $8
.stk: dc.l 0
.mfp: dc.b 0,0
.clic: dc.w 1

	SAUT
stallot: btst #0,topprg
	bne.s .mall
	move.l (a6),d0			; d‚j… en st ram, on use le dicco
	addq.l #1,d0
	bclr #0,d0
	move.l topprg,(a6)
	add.l d0,topprg
	rts
.mall: clr -(sp)			; force la st ram
	move.l (a6),-(sp)
	GEMDOS $44,8
	move.l d0,(a6)
	rts

	SAUT
ttallot: btst #0,topprg
	beq.s .mall
	move.l (a6),d0			; d‚j… en tt ram, on use le DICCO
	addq.l #1,d0
	bclr #0,d0
	move.l topprg,(a6)
	add.l d0,topprg
	rts
.mall: move #1,-(sp)   ; tt ram
	move.l (a6),-(sp)
	GEMDOS $44,8
	move.l d0,(a6)
	rts

	SAUT
topsur: move.l topprg,d0
   move.l (a6),topprg
   move.l d0,(a6)
   rts

   SAUT
surtop: move.l (a6)+,topprg
   rts

   SAUT
path: move.l (a6)+,a3        ; chaine fichier
   move.l (a6),a0            ; chaine chemin\masque
   lea pad+2,a1              ; chaine r‚sultat
   move.l a1,(a6)
	bsr.s _copy_path			  ; copie chemin jusqu'au dernier "\"
.lb3: move.b (a3)+,(a2)+     ; ajoute le nom du fichier aprŠs le dernier \
   bne.s .lb3
   rts

	; a0 pointe sur le chemin
	; a1 sur la zone destination
	; en sortie a2 pointe juste aprŠs le dernier "\"
_copy_path:
   move.l a1,a2              ; pointe sur le dernier \, ou le d‚but
.lb1: move.b (a0)+,d0        ; caractŠre suivant
   beq.s .lb3                ; fin de chaine, on saute
   cmp.b #"\",d0             ; est ce un \ ?
   bne.s .lb2
   lea 1(a1),a2              ; si oui, on d‚place a2
.lb2: move.b d0,(a1)+        ; remplit dest
   bra.s .lb1
.lb3:
	rts

   SAUT
loadbin:
   move.l (a6)+,a3           ; adresse de d‚part
   clr -(sp)                 ; lecture
   move.l (a6)+,-(sp)        ; nom du fichier
   move.l (a6)+,d6           ; size
   bclr #31,d6               ; si c'est -1, alors ‡a devient 2 Go
   move.l (a6),d5            ; start
   GEMDOS 61,8               ; fopen
   move.l d0,d7
   bmi.s .gloups
   clr -(sp)                 ; au d‚but
   move d7,-(sp)
   move.l d5,-(sp)
   GEMDOS 66,10              ; fseek
   tst.l d0
   bmi.s .gloups
   move.l a3,-(sp)           ; buffer
   move.l d6,-(sp)           ; taille
   move d7,-(sp)
   GEMDOS 63,12              ; fread
   tst.l d0
   bmi.s .gloups
   move.l d0,(a6)             ; taille effectivement lue
   move d7,-(sp)
   GEMDOS 62,4
   tst.l d0
   bmi.s .gloups
   rts
.gloups: move.l d0,(a6)
	rts

   SAUT
savebin:
   move.l (a6)+,a3           ; adresse de d‚part
   clr -(sp)                 ; attribut normal
   move.l (a6)+,-(sp)        ; nom du fichier
   move.l (a6),d6            ; size
   GEMDOS 60,8               ; fcreate
   move.l d0,d7
   bmi.s .gloups
   move.l a3,-(sp)           ; buffer
   move.l d6,-(sp)           ; taille
   move d7,-(sp)
   GEMDOS 64,12              ; write
   tst.l d0
   bmi.s .gloups
   move.l d0,(a6)            ; taille effectivement ‚crite
   move d7,-(sp)
   GEMDOS 62,4
   tst.l d0
   bmi.s .gloups
   rts
.gloups: move.l d0,(a6)
	rts

   SAUT
addrsto: move control+6(pc),d1
   move.l #addrin,a2
   move d1,d2
   subq #1,d2
   asl #2,d1
   add.w d1,a2
.lb1: move.l (a6)+,-(a2)
   dbf d2,.lb1
   rts

   COPIE aess,y204,1
aess: AES
y204: rts

   COPIE vdii,y205,1
vdii: VDI
y205: rts

   SAUT
ctrl: lea control(pc),a0
   move.l a0,-(a6)
   rts

   COPIE iin,y206,1
iin: move.l #intin,-(a6)
y206: rts

   COPIE pin,y207,1
pin: move.l #ptsin,-(a6)
y207: rts

   COPIE iout,y208,1
iout: move.l #intout,-(a6)
y208: rts

   COPIE pout,y209,1
pout: move.l #ptsout,-(a6)
y209: rts

   COPIE ain,y210,1
ain: move.l #addrin,-(a6)
y210: rts

   COPIE aout,y211,1
aout: move.l #addrout,-(a6)
y211: rts

   COPIE hdl,y212,1
hdl: move.l #handle,-(a6)
y212: rts

   COPIE vctrl,y213,1
vctrl: lea control+12,a0
   move handle,(a0)
   move.l (a6)+,-(a0)
   move.l (a6)+,-(a0)
   move.l (a6)+,-(a0)
   addq.l #2,a6
   move (a6)+,(a0)
y213: rts

   COPIE actrl,y214,1
actrl: lea control+8,a0
   clr (a0)
   move.l (a6)+,-(a0)
   addq.l #2,a6
   move (a6)+,(a0)
   move.l (a6)+,-(a0)
   addq.l #2,a6
   move (a6)+,(a0)
y214: rts

   SAUT
vint: moveq #0,d1
   move control+6(pc),d1
   lea intin,a2
   bra.s spint

   SAUT
ptinsto: moveq #0,d1
   move control+2(pc),d1
   lsl #1,d1
   lea ptsin,a2
   bra.s spint

   SAUT
aint: moveq #0,d1
   move control+2(pc),d1
   lea intin,a2

spint: add.l d1,a2
   add.l d1,a2
   subq #1,d1
.lb1: move.l (a6)+,d2
   move d2,-(a2)
   dbf d1,.lb1
   rts

	SAUT
v_opnvwk:
	tst.l 40(a6)		; le onziŠme paramŠtre est id
	bne.s .externe		; si non nul, ce n'est pas l'‚cran qui est voulu
	XBIOS 4,2			; get_rez
	addq.l #2,d0
	move.l d0,40(a6)  ; id=getrez+2
	ifd LIB
		tst.b aes_flag
		bne.s .aes
		move i_handle,handle		; dans le dossier AUTO, handle physique=i_handle
		bra.s .externe
		.aes:
	endif
	GEM_AES graf_hand
	move intout,handle
.externe:
	moveq #100,d0
ouvrir:
	moveq #0,d1			; pas d'‚l‚ments ptsin
ouvrir2:
	moveq #11,d2
	moveq #0,d3
	bsr vdiun
	move control+12,handle
	rts

	SAUT
vswr_mode:
	V1 32,0,1,0

	SAUT
vs_color:
	V1 14,0,4,0

	SAUT
vq_color:
	V1 26,0,2,0

	SAUT
vst_point:
	V1 107,0,1,0

	SAUT
vst_rotation:
	V1 13,0,1,0

	SAUT
vst_font:
	V1 21,0,1,0

	SAUT
vst_color:
	V1 22,0,1,0

	SAUT
vst_effects:
	V1 106,0,1,0

	SAUT
vst_alignment:
	V1 39,0,2,0

	SAUT
vqt_width:
	V1 117,0,1,0

	SAUT
vqt_name:
	move #130,d0
	moveq #0,d1
	moveq #1,d2
	moveq #0,d3
	bsr vdiun
	lea pad+2,a0
	move.l a0,-(a6)    ; laisse pad sur la pile
	lea intout+2,a1
	moveq #31,d0
.lb0:
	move (a1)+,d1      ; tansvase 32 caractŠres
	move.b d1,(a0)+
	dbf d0,.lb0
	clr.b (a0)         ; termine par un z‚ro.
	rts

	SAUT
vsl_type:
	V1 15,0,1,0

	SAUT
vsl_udsty:
	V1 113,0,1,0

	SAUT
vsl_color:
	V1 17,0,1,0

	SAUT
vsl_ends:
	V1 108,0,2,0

	SAUT
vsm_type:
	V1 18,0,1,0

	SAUT
vsm_color:
	V1 20,0,1,0

	SAUT
vsf_interior:
	V1 23,0,1,0

	SAUT
vsf_style:
	V1 24,0,1,0

	SAUT
vsf_color:
	V1 25,0,1,0

	SAUT
vsf_perimeter:
	V1 104,0,1,0

	SAUT
v_show_c:
	V1 122,0,1,0

; vdi 1: ceux qui ont des paramŠtres intin et ptsin mais sans offset
; d0=opcode,d1=ptsin,d2=intin,d3=subcode

vdiun: lea control(pc),a0
	move d0,(a0)+
	move d1,(a0)+
	move.l d2,(a0)+
	move.l d3,(a0)+
	move handle,(a0)
	if STE=0
		lea (ptsin,d1*4),a0
	else
		lea ptsin,a0
		add.l d1,a0
		add.l d1,a0
		add.l d1,a0
		add.l d1,a0
	endif
	bra.s .lb1
.lb0:
	move.l (a6)+,d0      ; deux coordonn‚es … la fois
	move d0,-(a0)
	move.l (a6)+,d0
	move d0,-(a0)
.lb1:
	dbf d1,.lb0
	if STE=0
		lea (intin,d2*2),a0
	else
		lea intin,a0
		add.l d2,a0
		add.l d2,a0
	endif
	bra.s .lb3
.lb2:
	move.l (a6)+,d0      ; un ‚l‚ment intin … la fois
	move d0,-(a0)
.lb3:
	dbf d2,.lb2
	VDI
	rts

	SAUT
vs_clip:
	tst.l (a6)
	bne.s .lb0
	lea -16(a6),a6       ; simule les 4 coordonn‚es
   bra.s .lb1
.lb0:
	movem.l (a6)+,d0-d4
	move.l d0,d5
	movem.l d1-d5,-(a6)  ; inverse intin et ptsin
.lb1:
	V2 129,2,1,0

	SAUT
v_pline:
	moveq #6,d0
	move.l (a6)+,d1
	moveq #0,d2
	moveq #0,d3
	bra vdideux

	SAUT
v_pmarker:
	moveq #7,d0
	move.l (a6)+,d1
	moveq #0,d2
	moveq #0,d3
	bra vdideux

	SAUT
v_contourfill:
	V2 103,1,1,0

	SAUT
v_recfl:
	V2 114,2,0,0

	SAUT
v_fillarea:
	moveq #9,d0
	move.l (a6)+,d1
	moveq #0,d2
	moveq #0,d3
	bra vdideux

	SAUT
v_bar:
	V2 11,2,0,1

	SAUT
v_rfbox:
	V2 11,2,0,9

	SAUT
v_rbox:
	V2 11,2,0,8

; vdi 2: idem mais avec offset sur tout le tableau ptsin
; d0=opcode,d1=ptsin,d2=intin,d3=subcode

vdideux: lea control(pc),a0
	move d0,(a0)+
	move d1,(a0)+
	move.l d2,(a0)+
	move.l d3,(a0)+
	move handle,(a0)
	move.l fenetre,a0
	move (a0)+,d3        ; offsets du coin de la fenetre
	move (a0),d4
	tst.b xy_flag
	bne.s .off
	moveq #0,d3
	moveq #0,d4          ; sinon, pas d'offset
.off:
	if STE=0
		lea (ptsin,d1*4),a0
	else
		lea ptsin,a0
		add.l d1,a0
		add.l d1,a0
		add.l d1,a0
		add.l d1,a0
	endif
	bra.s .lb1
.lb0:
	move.l (a6)+,d0      ; deux coordonn‚es … la fois
	add d4,d0
	move d0,-(a0)
	move.l (a6)+,d0
	add d3,d0
	move d0,-(a0)
.lb1:
	dbf d1,.lb0
	if STE=0
		lea (intin,d2*2),a0
	else
		lea intin,a0
		add.l d2,a0
		add.l d2,a0
	endif
	bra.s .lb3
.lb2:
	move.l (a6)+,d0      ; un ‚l‚ment intin … la fois
	move d0,-(a0)
.lb3:
	dbf d2,.lb2
	VDI
	rts

	SAUT
v_clsvwk:
	V3 101,0

	SAUT
v_clrwk:
	V3 3,0

	SAUT
vq_key_s:
   V3 128,0

	SAUT
vqt_attributes:
	V3 38,0

	SAUT
vqt_fontinfo:
	V3 131,0

	SAUT
vql_attributes:
	V3 35,0

	SAUT
vqm_attributes:
	V3 36,0

	SAUT
vqf_attributes:
	V3 37,0

	SAUT
v_hide_c:
	V3 123,0

; vdi 3: pas de paramŠtres
; d0=opcode,d3=subcode

vditrois:
	lea control(pc),a0
	move d0,(a0)+
	clr.l (a0)+
	clr.l (a0)+
	move d3,(a0)+
	move handle,(a0)
	VDI
	rts

	SAUT
vq_chcells:
	V4 1
	lea intout,a0
	move.l fenetre,a1
	moveq #0,d0
	move 6(a1),d0      ; H
	divs 14(a1),d0     ; divis‚ par h
	move d0,(a0)+      ; nombre de lignes
	moveq #0,d0
	move 4(a1),d0      ; L
	divs 12(a1),d0     ; divis‚ par l
	move d0,(a0)       ; nombre de colonnes
	rts

	SAUT
v_exit_cur:
	V4 2
	clr.l -(a6)
	bra v_show_c

	SAUT
v_enter_cur:
	V4 3
	bra v_hide_c

	SAUT
v_curup:
	V4 4
	move.l fenetre,a0
	move 14(a0),d0     ; h d'un caractŠre
	sub d0,10(a0)      ; l'ote … la ligne du curseur
	bpl.s .lb0
	clr 10(a0)         ; si <0, on ‚tait d‚j… en haut
.lb0: rts

	SAUT
v_curdown:
	V4 5
	move.l fenetre,a0
	move 10(a0),d0     ; y du curseur
	move 6(a0),d1
	add 14(a0),d0      ; y+h
	sub 14(a0),d1      ; H-h
	cmp d0,d1
	bmi.s .lb0
	move d0,10(a0)     ; modifi‚ si H-h>=y+h
.lb0: rts

	SAUT
v_curright:
	V4 6
	move.l fenetre,a0
	move 8(a0),d0     ; x du curseur
	move 4(a0),d1
	add 12(a0),d0      ; x+l
	sub 12(a0),d1      ; L-l
	cmp d0,d1
	bmi.s .lb0
	move d0,8(a0)     ; modifi‚ si L-l>=x+l
.lb0: rts

	SAUT
v_curleft:
	V4 7
	move.l fenetre,a0
	move 12(a0),d0     ; l d'un caractŠre
	sub d0,8(a0)       ; l'ote … la colonne du curseur
	bpl.s .lb0
	clr 8(a0)          ; si <0, on ‚tait d‚j… … gauche
.lb0: rts

	SAUT
v_curhome:
	V4 8
	if STE=0
		clr.l ([fenetre],8) ; efface x et y
	else
		move.l fenetre,a0
		clr.l 8(a0)
	endif
	rts

	SAUT
v_eeos:
	V4 9
	rts

	SAUT
v_eeol:
	V4 10
	rts

	SAUT
vs_curaddress:
   movem.l (a6)+,d0-d1  ; d0=colonne, d1=ligne
	tst.b xy_flag
	beq.s .vdi
	move.l fenetre,a0
	subq #1,d0
	muls 12(a0),d0       ; x voulu
	move 4(a0),d2
	sub 12(a0),d2        ; L-l
	cmp d0,d2
	bpl.s .lb0           ; ‡a rentre!
	moveq #0,d0
	move 4(a0),d0
	divs 12(a0),d0
	subq #1,d0
	muls 12(a0),d0       ; calcule la colonne maxi
.lb0:
	move d0,8(a0)
	subq #1,d1
	muls 14(a0),d1       ; y voulu
	move 6(a0),d2
	sub 14(a0),d2        ; H-h
	cmp d1,d2
	bpl.s .lb1           ; ‡a rentre!
	moveq #0,d1
	move 6(a0),d1
	divs 14(a0),d1
	subq #1,d1
	muls 14(a0),d1       ; calcule la colonne maxi
.lb1:
	move d1,10(a0)
	rts
.vdi:
	lea control(pc),a0
	move #5,(a0)+
	clr.l (a0)+
	move #2,(a0)+
	move.l #11,(a0)+
	move handle,(a0)
   exg.l d0,d1
   movem.w d0-d1,intin
   VDI
   rts

   SAUT
v_curtext:
	tst.b xy_flag
	bne type
   lea control(pc),a2
   move.l #intin,a3
   move.l (a6)+,a0
   move.l a0,a1
   add.l -4(a0),a1
   move.b (a1),d1
   clr.b (a1)
   clr d0
   clr d3
.lb1: move.b (a0)+,d3
   beq.s .lb2
   addq #1,d0
   move d3,(a3)+
   bra.s .lb1
.lb2: move.b d1,(a1)
   move #5,(a2)+
   clr.l (a2)+
   move d0,(a2)+
   moveq #12,d0
   move.l d0,(a2)+
   move handle,(a2)
   VDI
   rts

   SAUT
v_rvon:
	V4 13
	rts

	SAUT
v_rvoff:
	V4 14
	rts

	SAUT
vq_curaddress:
	V4 15
	lea intout,a1
	move.l fenetre,a0
	moveq #0,d0
	move 10(a0),d0
	divs 14(a0),d0
	addq #1,d0     ; y/h+1, ligne du curseur (1 … maxi)
	move d0,(a1)+
	moveq #0,d0
	move 8(a0),d0
	divs 12(a0),d0
	addq #1,d0     ; x/l+1, colonne
	move d0,(a1)
	rts

	SAUT
vq_tabstatus:
	moveq #16,d0
	bra vdiquatre

	SAUT
v_hardcopy:
	moveq #17,d0
vdiquatre:		; fonctions ESC VDI
   lea control(pc),a0
   move #5,(a0)+
   clr.l (a0)+
   clr.l (a0)+
   move d0,(a0)+
   move handle,(a0)
   VDI
	rts

	SAUT
vex_timv:
	lea control(pc),a0
	move #118,(a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr (a0)+
	move handle,(a0)+
	move.l (a6)+,(a0)
	VDI
	rts

	SAUT
vst_load_fonts:
	lea control(pc),a0
	move #119,(a0)+
	clr.l (a0)+
	move #1,(a0)+
	clr.l (a0)+
	move handle,(a0)
	clr intin
	VDI
	rts

	SAUT
vst_unload_fonts:
	lea control(pc),a0
	move #120,(a0)+
	clr.l (a0)+
	move #1,(a0)+
	clr.l (a0)+
	move handle,(a0)
	clr intin
	VDI
	rts

	SAUT
v_gtext:
	moveq #8,d7
   moveq #0,d6

; d7 contient op code (>0 pour 8 bits et <0 pour 16 bits)
; d6 contient 0 (pas d'offsets) ou 1 (tableau d'offsets pr‚sent

_text:
   move.l (a6)+,a0        ; adresse chaine
   lea intin,a1
	tst d7
	bpl.s	.bit8    			; si >0, c'est un texte 8 bits
	neg d7					; sinon, texte 16 bits
.lb00:
	move (a0)+,(a1)+
	bne.s .lb00
	bra.s .lb01
.bit8:
   moveq #0,d0
.lb0:
	move.b (a0)+,d0
	move d0,(a1)+
	bne.s .lb0
.lb01:
	move.l a1,d0
	sub.l #intin+2,d0
	lsr.l #1,d0            ; nombre de caractŠres
	lea control(pc),a0
	move d7,(a0)+          ; d7 contient 8 (gtext) ou 241 (ftext)
	muls d0,d6				  ; fois 1 ou 0
	addq #1,d6				  ; plus x,y de toutes fa‡ons
	move d6,(a0)+
	move.l d0,(a0)+
	clr.l (a0)+
	move handle,(a0)
	movem.l (a6)+,d0-d1
	exg.l d0,d1
	lea ptsin,a0
	movem.w d0-d1,(a0)
	tst.b xy_flag
	beq.s .fin
	if STE=0
		move.l ([fenetre]),d0
	else
		move.l a0,d1
		move.l fenetre,a0
		move.l (a0),d0
		move.l d1,a0
	endif
	add.l d0,(a0)
.fin:
	cmp #1,d6
	beq.s .vdi				; pas de tableau d'offsets
	move.l (a6)+,a1		; adresse du tableau
	addq.l #4,a0			; vers ptsin+4
	subq #1,d6
	bra.s .lb2
.lb3:
	move.l (a1)+,(a0)+	; couple de x,y
.lb2:
	dbf d6,.lb3
.vdi:
	VDI
	rts

	SAUT
v_justified:
   lea intin,a1
   lea ptsin,a2
   movem.l (a6)+,d0-d2
   move d1,(a1)+   ; inter word
   move d0,(a1)+   ; inter char
   move d2,4(a2)   ; len
   move.l (a6)+,a0
   moveq #0,d0
.lb0:
	move.b (a0)+,d0
	move d0,(a1)+
	bne.s .lb0
	move.l a1,d0
	sub.l #intin+2,d0
	lsr.l #1,d0            ; nombre de caractŠres+2
	lea control(pc),a0
	move #11,(a0)+
	move #2,(a0)+
	move.l d0,(a0)+
	clr.l (a0)+
	move handle,(a0)
	movem.l (a6)+,d0-d1
	exg.l d0,d1
	movem.w d0-d1,(a2)
	tst.b xy_flag
	beq.s .fin
	if STE=0
		move.l ([fenetre]),d0
	else
		move.l fenetre,a1
		move.l (a1),d0
	endif
	add.l d0,(a2)
.fin:
	VDI
	rts

	SAUT
vqt_extent:
   move.l (a6)+,a0        ; adresse chaine
   lea intin,a1
   moveq #0,d0
.lb0:
	move.b (a0)+,d0
	move d0,(a1)+
	bne.s .lb0
	move.l a1,d0
	sub.l #intin+2,d0
	lsr.l #1,d0            ; nombre de caractŠres
	lea control(pc),a0
	move #116,(a0)+
   clr.l (a0)+
	move d0,(a0)+
	clr.l (a0)+
	move handle,(a0)
	VDI
	rts

	SAUT
vst_height:
	lea control(pc),a0
	move #12,(a0)+
	move #1,(a0)+
	clr.l (a0)+
	clr.l (a0)+
	move handle,(a0)
	move.l (a6)+,ptsin    ; hauteur dans ptsin+2
	VDI
	rts

	SAUT
vsl_width:
	lea control(pc),a0
	move #16,(a0)+
	move #1,(a0)+
	clr.l (a0)+
	clr.l (a0)+
	move handle,(a0)
	move.l (a6)+,d0
	swap d0
	move.l d0,ptsin   ; ‚paisseur en ptsin et 0 en ptsin+2
	VDI
	rts

	SAUT
vsm_height:
	lea control(pc),a0
	move #19,(a0)+
	move #1,(a0)+
	clr.l (a0)+
	clr.l (a0)+
	move handle,(a0)
	move.l (a6)+,ptsin    ; hauteur dans ptsin+2
	VDI
	rts

	SAUT
vsf_udpat:
	lea control(pc),a0
	move #112,(a0)+
	clr.l (a0)+
	move.l (a6)+,d0
	move d0,d1
	asl #4,d1
	move d1,(a0)+         ; 16*nombre de plans
	clr.l (a0)+
	move handle,(a0)
	move.l (a6)+,a0
	lea intin,a1
	add d0,d0				 ; 1=32 octets
	bra.s .lb1
.lb0:
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
.lb1:
	dbf d0,.lb0
	VDI
	rts

	SAUT
v_arc:
	moveq #2,d0
	bra.s arc

	SAUT
v_pieslice:
	moveq #3,d0
arc:
	lea control(pc),a0
	move #11,(a0)+
	move #4,(a0)+
	move.l #2,(a0)+
	move.l d0,(a0)+
	move handle,(a0)
	lea ptsin+14,a0
	clr (a0)
	movem.l (a6)+,d0-d4 ; d0=a1,a0,r,y,x=d4
	move d2,-(a0)
	clr.l -(a0)
	clr.l -(a0)
	move d3,-(a0)
	move d4,-(a0)
	tst.b xy_flag
	beq.s .lb0
	if STE=0
		move.l ([fenetre]),d4
	else
		move.l fenetre,a1
		move.l (a1),d4
	endif
	add.l d4,(a0)
.lb0:
	exg d0,d1
	movem.w d0-d1,intin
	VDI
	rts

	SAUT
v_circle:
	lea control(pc),a0
	move #11,(a0)+
	move #3,(a0)+
	clr.l (a0)+
	move.l #4,(a0)+
	move handle,(a0)
	lea ptsin+10,a0
	clr (a0)
	movem.l (a6)+,d0-d2 ; d0=r,y,x=d2
	move d0,-(a0)
	clr.l -(a0)
	move d1,-(a0)
	move d2,-(a0)
	tst.b xy_flag
	beq.s .lb0
	if STE=0
		move.l ([fenetre]),d0
	else
		move.l fenetre,a1
		move.l (a1),d0
	endif
	add.l d0,(a0)
.lb0:
	VDI
	rts

	SAUT
v_ellarc:
	moveq #6,d0
	bra.s ellarc

	SAUT
v_ellpie:
	moveq #7,d0
ellarc:
	lea control(pc),a0
	move #11,(a0)+
	move #2,(a0)+
	move.l #2,(a0)+
	move.l d0,(a0)+
	move handle,(a0)
	movem.l (a6)+,d0-d5 ; d0=a1,a0,ry,rx,y,x=d5
	lea ptsin,a0
	move d5,(a0)+
	move d4,(a0)+
	move d3,(a0)+
	move d2,(a0)
	tst.b xy_flag
	beq.s .lb0
	if STE=0
		move.l ([fenetre]),d4
	else
		move.l fenetre,a1
		move.l (a1),d4
	endif
	add.l d4,-6(a0)
.lb0:
	exg d0,d1
	movem.w d0-d1,intin
	VDI
	rts

	SAUT
v_ellipse:
	lea control(pc),a0
	move #11,(a0)+
	move #2,(a0)+
	clr.l (a0)+
	move.l #5,(a0)+
	move handle,(a0)
	movem.l (a6)+,d0-d3 ; d0=ry,rx,y,x=d3
	lea ptsin,a0
	move d3,(a0)+
	move d2,(a0)+
	move d1,(a0)+
	move d0,(a0)
	tst.b xy_flag
	beq.s .lb0
	if STE=0
		move.l ([fenetre]),d0
	else
		move.l fenetre,a1
		move.l (a1),d0
	endif
	add.l d0,-6(a0)
.lb0:
	VDI
	rts

	SAUT
vsc_form:
	lea control(pc),a0
	move #111,(a0)+
	clr.l (a0)+
	move #37,(a0)+
	clr.l (a0)+
	move handle,(a0)
	lea intin,a0
	move.l (a6)+,a1
	moveq #8,d0
.lb0:
	move.l (a1)+,(a0)+
	dbf d0,.lb0
	move (a1),(a0)
	VDI
	rts

	SAUT
v_alpha_text:
   bsr _intin_str
   V5 5,0,25

	SAUT
v_bez:
	moveq #6,d0
_bez:	move.l (a6)+,d1	; count
	move.l d1,d2
	moveq #13,d3
	bra vdideux

	SAUT
v_bez_fill:
	moveq #9,d0
   bra.s _bez

	SAUT
v_bez_off:
   V3 11,13

   SAUT
v_bez_on:
	subq.l #8,a6		; simule 2 entiers
	V1 11,1,0,13

	SAUT
v_bez_qual:
	move.l (a6)+,d0
	move.l #32,-(a6)
	move.l #1,-(a6)
	move.l d0,-(a6)
	V1 5,0,3,99

	SAUT
v_bit_image:
	movem.l (a6)+,d0-d3
	exg d0,d3
	exg d1,d2
	movem d0-d3,ptsin
	lea intin+10,a1
	bsr _intin_str2
	addq #5,d2
	movem.l (a6)+,d0-d1/d3-d5
	exg d0,d5
	exg d1,d4
	movem d0-d1/d3-d5,intin
	V5 5,2,23

	SAUT
v_fulshcache:
	V3 251,0

	SAUT
v_fontinit:
	move.l (a6),d0			; header
	swap d0
	move.l d0,(a6)			; le high en word
	swap d0
	move.l d0,-(a6)		; le low en word
	V1 5,0,2,102

	SAUT
v_form_adv:
	V4 20

	SAUT
v_ftext16:
	move #-241,d7
	moveq #0,d6
	bra _text

	SAUT
v_ftext_offset:
	move #241,d7
	moveq #1,d6
	bra _text

	SAUT
v_ftext_offset16:
	move #-241,d7
	moveq #1,d6
	rts

	SAUT
v_getbitmap_info:
	V1 239,0,1,0

	SAUT
v_getoutline:
	V1 243,0,6,0

	SAUT
v_get_pixel:
	V2 105,1,0,0

	SAUT
v_loadcache:
	lea intin,a1
	move.l (a6)+,d0
	move d0,(a1)+
	bsr _intin_str2
	addq #1,d2		; plus le mot de mode
	V5 250,0,0

	SAUT
v_output_window:
	V1 5,2,0,21

	SAUT
v_pgcount:
	V1 5,0,1,2000

	SAUT
v_savecache:
	bsr _intin_str
	V5 249,0,0

	SAUT
v_set_app_buff:
	lea intin,a1
	addq.l #2,a6
	move (a6)+,4(a1)	; nparag
	move (a6)+,(a1)+
	move (a6),(a1)
	moveq #3,d2
	V5 -1,0,6

	SAUT
v_write_meta:
	move.l (a6)+,d1
	move.l (a6)+,d2
	moveq #5,d0
	moveq #99,d3
	bra vdiun

	SAUT
vex_butv:
	move.l (a6)+,control+14
	V3 125,0

	SAUT
vex_curv:
	move.l (a6)+,control+14
	V3 127,0

	SAUT
vex_motv:
	move.l (a6)+,control+14
	V3 126,0

	SAUT
vq_extnd:
	V1 102,0,1,0

	COPIE vq_gdos,vvv
vq_gdos:
	moveq #-2,d0
	trap #2
	move.l d0,-(a6)
vvv: rts

	SAUT
_vq_mouse:
	V3 124,0

	SAUT
vq_scan:
	V4 24

	SAUT
vqt_advance32:
vqt_advance:
	V1 247,0,1,0

	SAUT
vqt_cachesize:
	V1 255,0,1,0

	SAUT
vqt_f_extent16:
	bsr _intin_str16
	V5 240,0,0

	SAUT
vqt_fontheader:
	move #234,d0
	moveq #0,d1
	moveq #0,d2
	moveq #0,d3
	move.l (a6)+,intin
	bsr vdicinq
	lea pad+2,a0
	move.l a0,-(a6)
	lea intout,a1
	moveq #127,d0
.lb0:
	move.b (a1)+,(a0)+
	dbeq d0,.lb0
	clr.b (a0)
	rts

	SAUT
vqt_get_table:
	V3 254,0

	SAUT
vqt_pairkern:
	V1 235,0,2,0

	SAUT
vqt_trackkern:
	V3 234,0

	SAUT
vst_arbpt32:
	V1 246,0,2,0

	SAUT
vst_charmap:
	V1 236,0,1,0

	SAUT
vst_error:
	lea intin,a1
	move.l (a6)+,d0		; le mode
	move d0,(a1)+
	bne.s .lb0
	move.l (a6)+,(a1)		; si nul, il faut l'adresse
.lb0:
	moveq #3,d2
	V5 245,0,0

	SAUT
vst_kern:
	V1 237,0,2,0

	SAUT
vst_scratch:
	V1 244,0,1,0

	SAUT
vst_setsize32:
	V1 252,0,2,0

	SAUT
_wind_create:
	A1 100,5,1,0

	SAUT
_wind_open:
	A1 101,5,1,0

	SAUT
_wind_close:
	A1 102,1,1,0

	SAUT
wind_delete:
	A1 103,1,1,0

	SAUT
_wind_set:
	movem.l (a6)+,d0-d1   ; d0=flag
	cmp #1,d0             ; mot de d‚finition
	bne.s .lb0
.lb1:
	move.l d0,-(a6)       ; flag
	move.l d1,-(a6)       ; param 1
.lb5:
	lea -12(a6),a6        ; param2 … 4 fictifs
.aes:
	A1 105,6,1,0
.lb0:
	cmp #8,d0             ; position
	beq.s .lb1
	cmp #9,d0             ; position
	beq.s .lb1
	cmp #15,d0            ; taille
	beq.s .lb1
	cmp #16,d0            ; taille
	beq.s .lb1
	cmp #2,d0             ; titre
	bne.s .lb2
.lb3:
	move.l d0,-(a6)       ; flag
	swap d1
	move d1,-(a6)         ; high de l'adresse (param1)
	clr -(a6)
	swap d1
	move d1,-(a6)         ; low de l'adresse (param2)
	lea -10(a6),a6        ; param3 et 4 fictifs
	bra .aes
.lb2:
	cmp #3,d0             ; info
	beq.s .lb3
   cmp #10,d0            ; activer
   bne.s .lb4
	subq.l #8,a6          ; revient dur hdl et flg
	move.l d1,-(a6)       ; param1=hdl
	bra .lb5              ; autres paramŠtres
.lb4:
	cmp #14,d0            ; fond du bureau
	bne.s .lb6            ; vers autre mode
	moveq #0,d2
	moveq #0,d3
	move (a6)+,d2         ; high adr
	move (a6)+,d3         ; low adr
	clr.l -(a6)           ; hdl fictif
	move.l d0,-(a6)       ; flag
	move.l d2,-(a6)       ; param1
	move.l d3,-(a6)       ; param2
	move.l d1,-(a6)       ; param3
	clr.l -(a6)           ; param4 fictif
	bra .aes
.lb6:
	movem.l (a6)+,d2-d4
	move.l d0,d5
	movem.l d1-d5,-(a6)
	bra .aes

	SAUT
wind_get:
	A1 104,2,5,0

	SAUT
wind_find:
	A1 106,2,1,0

	SAUT
_wind_update:
	A1 107,1,1,0

	SAUT
_wind_calc:
	bclr #1,23(a6)			; flag +2 for center facility !
	sne d5
	bsr.s .calc
	tst.b d5
	beq.s .out
	movem.w maxi_xylh,d0-d3	; taille fenˆtre 0
	movem.w intout+6,d4-d5  ; w,h fenetre en cours
	sub d4,d2
	sub d5,d3
	lsr #1,d2
	lsr #1,d3
	add d2,d0				; x centr‚ = x0 + (w0-w)/2
	add d3,d1				; y centr‚ = y0+ (h0-h)/2
	movem.w d0-d1,intout+2
.out:
	rts
.calc:
	A1 108,6,5,0

   SAUT
menu_bar:
	A1 30,1,1,1

	SAUT
menu_icheck:
	A1 31,2,1,1

	SAUT
menu_ienable:
	A1 32,2,1,1

	SAUT
menu_tnormal:
	A1 33,2,1,1

	SAUT
menu_register:
	A1 35,1,1,1

	SAUT
menu_text:
	A1 34,1,1,2

	SAUT
evnt_button:
	A1 21,3,5,0

	SAUT
evnt_mouse:
	A1 22,5,5,0

	SAUT
evnt_timer:
	move.l (a6),d0			; ici laisse LOW en place
	swap d0					; ramŠne HIGH
	move.l d0,-(a6)		; et met HIGh en place
	A1 24,2,1,0

	SAUT
evnt_dclick:
	A1 26,2,1,0

	SAUT
evnt_mesag:
	A1 23,0,1,1

	SAUT
evnt_multi:
	movem.l (a6),d0-d1  ; d0=adr, d1=temps
	swap d1
	move.l d1,(a6)      ; high du temps
	move.l d0,-(a6)  	  ; adr
	A1 25,16,7,1

	SAUT
appl_read:
	A1 11,2,1,1

	SAUT
appl_write:
	A1 12,2,1,1

	SAUT
rsrc_load:
	A1 110,0,1,1

	SAUT
rsrc_gaddr:
	moveq #112,d0
	moveq #2,d1
	moveq #1,d2
	moveq #0,d3
	moveq #1,d4
	bra _aesun

	SAUT
rsrc_saddr:
	A1 113,2,1,1

	SAUT
form_center:
	A1 54,0,5,1

	SAUT
form_dial:
	A1 51,9,1,0

	SAUT
form_do:
	A1 50,1,1,1

	SAUT
objc_draw:
	A1 42,6,1,1

	SAUT
objc_find:
	A1 43,4,1,1

	SAUT
objc_offset:
	A1 44,1,3,1

	SAUT
objc_edit:
	A1 46,4,2,1

	SAUT
objc_change:
	A1 47,8,1,1

	SAUT
graf_rubberbox:
	A1 70,4,3,0

	SAUT
graf_dragbox:
	A1 71,8,3,0

	SAUT
graf_movebox:
	A1 72,6,1,0

	SAUT
graf_growbox:
	A1 73,8,1,0

	SAUT
graf_shrinkbox:
	A1 74,8,1,0

	SAUT
graf_watchbox:
	A1 75,4,1,1

	SAUT
graf_slidebox:
	A1 76,3,1,1

	SAUT
form_alert:
	A1 52,1,1,1

	SAUT
form_error:
	A1 53,1,1,0

	SAUT
fsel_input:
	A1 90,0,2,2

	SAUT
graf_mouse:
   tst (a6)           ; parite haute du paramŠtre
   beq.s .lb0         ; si 0, c'est un code pas une adresse
   move.l (a6),-(a6)  ; d‚place l'adresse
   move.l #255,4(a6)  ; code pour d‚finir la souris
   bra.s .lb1
.lb0:
   clr.l -(a6)        ; adresse nulle
.lb1:
	A1 78,1,1,1

	SAUT
scrp_write:
	A1 81,0,1,1

	SAUT
scrp_read:
	A1 80,0,1,1

	SAUT
shel_get:
	A1 122,1,1,1

	SAUT
shel_put:
	A1 123,1,1,1

	SAUT
shel_envrn:
	A1 125,0,1,2

	SAUT
shel_write:
	A1 121,3,1,2

	SAUT
shel_read:
	A1 120,0,1,2

	SAUT
shel_find:
	A1 124,0,1,1

; d0=code, d1=intin, d2=intout, d3=addrin, d4=addrout (si _aesun, 0 sinon)

aesun:
   moveq #0,d4
_aesun:
   movem.w d0-d4,control
   if STE=0
   	lea (addrin,d3.w*4),a0
   else
      lea addrin,a0
      add d3,a0
      add d3,a0
      add d3,a0
      add d3,a0
   endif
   bra.s .lb1
.lb0:
	move.l (a6)+,-(a0)   ; les ‚l‚ments de addrin
.lb1:
	dbf d3,.lb0
	if STE=0
		lea (intin,d1.w*2),a0
	else
		lea intin,a0
		add d1,a0
		add d1,a0
	endif
	bra.s .lb3
.lb2:
	move.l (a6)+,d0      ; les ‚l‚ments de intin
	move d0,-(a0)
.lb3:
	dbf d1,.lb2
   AES
   rts

	COPIE _appl_init,w1,1
_appl_init:
	move appl_id,intout
w1: rts

	SAUT
graf_handle:
	A2 77,5

	SAUT
evnt_keybd:
	A2 20,1

	SAUT
graf_mkstate:
	A2 79,5

	SAUT
rsrc_free:
	A2 111,1

; d0=code, d2=intout, pas de paramŠtres

aesdeux:
   moveq #0,d1
   moveq #0,d3
   moveq #0,d4
   movem.w d0-d4,control
   AES
   rts

   SAUT
vdisto: lea control(pc),a0
   move (a0)+,d2            ; code fonction
   move (a0)+,d1            ; points de ptsin
   move.l #ptsin,a2
   if STE=0
	   lea 0(a2,d1.w*4),a2
	else
		add d1,a2
		add d1,a2
		add d1,a2
		add d1,a2
	endif
   moveq #0,d0              ; pas d'offset
   tst.b xy_flag
   beq.s .absolu
   cmp #19,d2
   beq.s .absolu
   cmp #12,d2
   beq.s .absolu            ; les fonctions 12 et 19 sans offset
   move.l fenetre,a1
   move.l (a1),d0           ; X et Y dans les deux mots
   cmp #11,d2
   bne.s .k1                ; c'est forc‚ment du relatif
   move 6(a0),d2            ; sous fonction
   cmp #10,d2
   beq.s .absolu            ; en fait, relatif que sur les deux premiers
   cmp #2,d2
   bmi.s .abs0
   cmp #8,d2
   bpl.s .abs0
   bra.s .absolu            ; en fait, relatif pour les 2 premiers
.k0: move.l (a6)+,d2
   move d2,-(a2)
   move.l (a6)+,d2
   move d2,-(a2)
   add.l d0,(a2)            ; ajoute l'offset
.k1:
   dbf d1,.k0
   bra.s .k3
.abs0: moveq #0,d0
.absolu:
   asl #1,d1
   bra.s .lb2
.lb1: move.l (a6)+,d2
   move d2,-(a2)
.lb2: dbf d1,.lb1
   add.l d0,(a2)
.k3:
   move 2(a0),d1
   move.l #intin,a2
   if STE=0
   	lea 0(a2,d1.w*2),a2
   else
   	add d1,a2
   	add d1,a2
   endif
   bra.s .lb4
.lb3: move.l (a6)+,d2
   move d2,-(a2)
.lb4: dbf d1,.lb3
   VDI
   rts

   SAUT
aessto: move control+6(pc),d1
   move.l #addrin,a2
	if STE=0
	   lea 0(a2,d1.w*4),a2
	else
		add d1,a2
		add d1,a2
		add d1,a2
		add d1,a2
	endif
   bra.s .lb2
.lb1: move.l (a6)+,-(a2)
.lb2: dbf d1,.lb1
   move control+2(pc),d1
   move.l #intin,a2
	if STE=0
	   lea 0(a2,d1.w*2),a2
	else
		add d1,a2
		add d1,a2
	endif
   bra.s .lb4
.lb3: move.l (a6)+,d2
   move d2,-(a2)
.lb4: dbf d1,.lb3
   AES
   rts

   SAUT
ltype: move.l (a6)+,a3
.lb0: move #0,-(sp)
   BIOS 8,4
   tst.l d0
   bne.s .lb1
   ACONTROL 52,1,1,1
   move #2,intin
   move.l #avert1,addrin
   AES
   move intout,d0
   cmp #2,d0
   beq.s .lb0
   rts
.lb1: moveq #0,d5
.lb2: move.b (a3)+,d5
   beq.s .lb3
   move.l d5,-(sp) ; remplace move.w et clr.w -(sp)
   BIOS 3,6
   bra.s .lb2
.lb3: rts

   SAUT
defp: move.l (a6)+,a3
   lea 12(a3),a3
   move.l fenetre0+12,(a3)  ; hauteur et largeur d'un caractŠre
   clr.l -(a3)              ; curseur … z‚ro
   move.l (a6)+,d0
   move d0,-(a3)            ; H
   move.l (a6)+,d0
   move d0,-(a3)            ; L
   move.l (a6)+,d0
   move d0,-(a3)            ; Y
   move.l (a6)+,d0
   move d0,-(a3)            ; X
   rts

   SAUT
setp: move.l (a6)+,a0
_setp:
   move.l a0,fenetre
   move.l (a0)+,d0
   lea c_pts,a1
   move.l d0,(a1)+
   add.l (a0),d0
   sub.l #$10001,d0
   move.l d0,(a1)+
   GEM_VDI clip_tab
   rts

   COPIE absolute,y223,1
absolute: sf xy_flag
y223: rts

   SAUT
desk:
	GEM_VDI show_mouse
	move.l menu_adresse,-(a6)
	bsr setmenu
	moveq #1,d0
	move.l d0,-(a6)
	move.l menu_adresse,-(a6)
	bsr menu_bar
.lb0:
	GEM_AES event_mesag
   lea vt_int,a0        ; la o— sont les donn‚es du message
   move (a0),d0         ; le type de message
   cmp #21,d0
   bne.s .k0
   	move 6(a0),d0
   	cmp w_hand,d0
   	bne.s .lb0        ; pas notre fenetre
   	move #10,ws_int+2 ; wind topped
   	GEM_AES wind_set
   	bra .fin          ; on ressort
.k0:
   cmp #27,d0
   beq.s .k1
   cmp #28,d0
   bne.s .k2
.k1:
      move 6(a0),d0
      cmp w_hand,d0
      bne.s .lb0        ; pas notre fenetre
      addq.l #8,a0
      bsr taille_verif  ; (a0) modifi‚ si necessaire (xylh)
      lea ws_int+2,a1
      move #5,(a1)+       ; redessine la fenetre
      move.l (a0)+,(a1)+
      move.l (a0),(a1)+
      GEM_AES wind_set
      move w_hand,wg_int
      GEM_AES wind_get1
      move.l #fenetre0,a1 ; si ‡a bouge, on remet la page 0, c'est plus sur
		move.l a1,-(a6)
      lea w_travail+2,a0
      move.l (a0)+,(a1)+
      move.l (a0),(a1)+
      clr.l (a1)          ; curseur Home
      bsr setp            ; fixe la nouvelle page, avec clipping
      bra .lb0
.k2:
   cmp #20,d0             ; redraw ?
   bne.s .k3
      move w_hand,d0
      cmp 6(a0),d0       ; notre fenetre?
      bne .lb0           ; ben non..
      lea 8(a0),a0       ; pointe sur x,y,l,h … redessiner
      bsr redraw         ; avec d0= handle!
      bra .lb0
.k3:
   cmp #10,d0             ; menu s‚lectionn‚ ?
   bne .lb0
.fin:
   GEM_VDI hide_mouse
   move.l #3,-(a6)			; titre
   move.l #1,-(a6)			; en vid‚o normale
   move.l menu_adresse,-(a6)
   bsr menu_tnormal			; titre en blanc
   clr.l -(a6)					; annule la barre de menu
   move.l menu_adresse,-(a6)
   bsr menu_bar
   move.l fenetre,-(a6)
   bsr setp
	bsr cls
	ifnd LIB
		jsr souris_visible
	endif
   rts

; a0 pointe sur xylh voulus
; fenetre0 contient lh d'un caractŠre ( mini 23 * 5 caractŠres )
; maxi_xylh contient la taille de la fenetre 0


taille_verif:
   move.l a0,-(sp)
   lea fenetre0+12,a0
   moveq #30,d0
   muls (a0)+,d0      ; largeur ( 23 caractŠres )
   moveq #5,d1
   muls (a0),d1       ; hauteur ( 5 lignes )
   lea vt_int+16,a0
   clr (a0)+          ; travail -> esp total
   move wind_mask,(a0)+
   clr.l (a0)+        ; x et y on s'en fout
   move d0,(a0)+
   move d1,(a0)       ; l et h int‚rieurs voulus
   GEM_AES wind_calc
   lea vt_int+34,a1   ; r‚cupŠre les donn‚es ( l et h )
   move.l (sp)+,a0
   move.w (a0)+,d0    ; x voulu
   move (a0)+,d1      ; y
   move (a0)+,d2      ; l
   move (a0),d3       ; h
   cmp (a1),d2        ; longueur suffisante?
   bpl.s .lb0
   move (a1),d2       ; non, alors on prend le minimum
.lb0:
	addq.l #2,a1
	cmp (a1),d3        ; hauteur suffisante ?
	bpl.s .lb1
	move (a1),d3       ; non, on prend le minimum
.lb1:
   lea maxi_xylh,a1
   cmp (a1),d0        ; pas trop … gauche de l'‚cran ?
   bpl.s .k0
   move (a1),d0       ; … droite
.k0:
	cmp 2(a1),d1       ; pas au dessus de l'‚cran ?
	bpl.s .k1
	move 2(a1),d1      ; redescend
.k1:
   cmp 4(a1),d2       ; longueur sup‚rieure … l'‚cran ?
   bmi.s .lb2
   move 4(a1),d2      ; oui!, on r‚tr‚cit alors.
.lb2:
   cmp 6(a1),d3       ; hauteur sup‚rieure … l'‚cran ?
   bmi.s .lb3
   move 6(a1),d3      ; oui, on r‚tr‚cit.
.lb3:
   move d3,(a0)       ; la hauteur est maintenant ok
   move d2,-(a0)      ; la largeur aussi
   neg d2
   neg d3
   add (a1)+,d2
   add (a1)+,d3
   add (a1)+,d2       ; X + L - l
   add (a1),d3        ; Y + H - h
   cmp d3,d1          ; y pas trop bas ?
   bmi.s .lb4
   move d3,d1         ; si, on le remonte
.lb4:
   cmp d2,d0          ; x pas trop … droite ?
   bmi.s .lb5
   move d2,d0         ; si, on recale … gauche
.lb5:
   move d1,-(a0)      ; y parfait
   move d0,-(a0)      ; x fabuleux
   rts

; d0 contient le handle de la fenetre
; a0 pointe sur xylh … reconstituer

redraw:
   move.l (a0)+,d6    ; x et y
   move.l (a0),d7     ; l et h
   add.l d6,d7
   sub.l #$10001,d7   ; d7 contient x+l-1 et y+h-1
   lea wg_int,a3
   move.l (a3),-(sp)  ; sauvegarde les anciennes donn‚es
   move d0,(a3)+      ; le handle
   move #11,(a3)      ; premier rectangle
      GEM_VDI hide_mouse
      move #1,wu_int
      GEM_AES wind_update
   GEM_AES wind_get0
   move #12,(a3)      ; pour le rectangle suivant
.boucle:
   lea wg_out+2,a0    ; le rectangle
   move.l (a0)+,d0    ; x et y
   move.l (a0),d1     ; l et h
   beq .fin           ; se termine si l et h sont nuls
   add.l d0,d1
   sub.l #$10001,d1   ; d1 contient les coordonn‚es du point inf‚rieur
   cmp d6,d0
   bpl.s .k0
   move d6,d0         ; d0 contient le max de y1 et y2
.k0:
   swap d6
   swap d0
   cmp d6,d0
   bpl.s .k1
   move d6,d0         ; d0 contient le max de x1 et x2
.k1:
   swap d6
   swap d0
   cmp d7,d1
   bmi.s .k2
   move d7,d1         ; le plus petit de y1' et y2'
.k2:
   swap d7
   swap d1
   cmp d7,d1
   bmi.s .k3
   move d7,d1         ; le plus petit de x1' et x2'
.k3:
   swap d7
   swap d1
   cmp d1,d0
   bpl .pas_inter
   cmp.l d1,d0
   bpl .pas_inter
   lea copy_pts,a0
   move.l d0,(a0)+
   move.l d1,(a0)     ; coordonn‚es du rectangle
   lea c_pts,a0
   move.l d0,(a0)+
   move.l d1,(a0)     ; pour le clipping
   GEM_VDI clip_tab
   GEM_VDI fill_rect  ; efface la zone
.pas_inter:
   GEM_AES wind_get0  ; rectangle suivant
   bra .boucle
.fin:
      clr wu_int
      GEM_AES wind_update
      GEM_VDI show_mouse
   move.l (sp)+,wg_int ; restaure
   rts

   SAUT
fastop: tst w_hand
   bpl.s .lb0            ; d‚j… ouvert
   bsr fastopen
.lb0:
	moveq #0,d0
	move w_hand,d0
	move.l d0,-(a6)       ; renvoit le handle
   rts

xy_flag: dc.w $ff00      ; par d‚faut, mode relatif

   COPIE relative,y215,1
relative: st xy_flag
y215:
   rts

   SAUT
fastcl: tst w_hand
   bmi.s .lb0            ; d‚j… ferm‚
   bsr fastclose
   move #-1,w_hand
.lb0:
	ifd LIB
		tst.b aes_flag
		bne.s .lb1				 ; aes install‚, pas de fermeture VDI
		bsr ferme_vdi
		move #-1,i_handle
		.lb1:
	endif
   rts

   COPIE page0,y216,1
page0: move.l #fenetre0,-(a6)
y216: rts


separe: dc.b "--------------------"
nulle: dc.b 0

 even
menudat:
 dc.w 0,40,40,40,40,0,40,40,0,36
 dc.w 0,1,0,0,0,0,0,0                   ; nombre d'objets , ... , taille totale

 dc.w -1,1,3,25,0,0,0,0,0,0,0,0         ; ROOT
 dc.w 3,2,2,20,0,0,0,$1100,0,0,0,0      ; BAR
 dc.w 1,3,3,25,0,0,0,0,0,0,0,0          ; ACTIVE

 dc.w 0,0,0,25,0,0,0,0,0,0,0,0          ; SCREEN

isfirst: dc.w 0

   SAUT
menu: move.l #indextab,indexadr   ; pour la table de conversion
  movem.l a4-a6,-(a7)
  move.l #fenetre0+12,a0
  move.w (a0)+,d0       ; largeur cellule
  move.w (a0),d1        ; hauteur cellule
  move.l #work_out,a0
  move.w (a0)+,d2     ; resolution horizontale
  addq #1,d2
  move.w (a0),d3      ; resolution verticale
  addq #1,d3
  move.l #menudat,a0
  move.l topprg,a1
  move.l a1,global+14   ; adresse du header
  rept 5
  move.l (a0)+,(a1)+
  endr
  move.l a1,a5          ; garde l'adresse du nombre d'objets
  rept 4
  move.l (a0)+,(a1)+
  endr
  move.l a1,global+10   ; adresse de la table
  addq.l #4,a1
  move.l a1,-4(a1)      ; table des arbres, un seul qui pointe sur la suite
  move.l (a6),a4        ; adresse des chaines
  move.l a1,(a6)        ; adresse de l'arbre sur la pile
  move.w d2,20(a0)      ; L de ROOT
  move.w d3,22(a0)      ; H
  move.w d2,44(a0)      ; L de BAR
  move.w d2,92(a0)      ; L de SCREEN
  sub.w d1,d3
  sub.w d1,d3
  move.w d3,94(a0)      ; H de SCREEN ( ymax-2lignes )
  moveq #2,d2
  add d1,d2             ; hauteur de BAR
  move d2,46(a0)
  addq #1,d2            ; hauteur des titres
  move d2,70(a0)        ; hauteur de ACTIVE
  move d2,90(a0)        ; y de SCREEN
  move d0,d3
  add d0,d3
  move d3,64(a0)        ; x de ACTIVE

  move.l a1,a6          ; garde le debut de l'arbre
  moveq #17,d4
.lb0: move.l (a0)+,(a1)+
  dbf d4,.lb0           ; transvase ROOT, BAR, ACTIVE

  move -2(a4),d4      ; mlen
  addq #4,d4
  bclr #0,d4            ; d4=offset pour chaine suivante
  moveq #3,d5           ; num‚ro de l'objet libre
  moveq #0,d6           ; largeur de ACTIVE, et x du titre en cours

.titreloop:
  move.l indexadr,a2
  move.b d5,(a2)+       ; table de conversion
  move.l a2,indexadr
  tst.b (a4)
  beq.s .dropdown       ; chaine vide = fin des titres
  move.l a4,a2
.lb1: tst.b (a2)+
  bne.s .lb1
  sub.l a4,a2
  subq.l #1,a2          ; longueur du titre
  move a2,d7            ; L en caractŠres
  muls d0,d7            ; L en points

         ; objet titre

  addq #1,d5            ; un objet de plus
  move d5,(a1)+         ; pointe sur le suivant
  move.l #-1,(a1)+      ; pas d'enfants
  move #32,(a1)+        ; G_TITLE
  clr.l (a1)+           ; flag et state
  move.l a4,(a1)+       ; adr chaine
  move d6,(a1)+         ; X
  clr (a1)+             ; Y
  move d7,(a1)+         ; L
  move d2,(a1)+         ; H

  add d7,d6             ; ACTIVE s'‚largit
  add.w d4,a4           ; chaine suivante
  bra.s .titreloop

.dropdown: move #1,isfirst  ; c'est le premier drop down
  move d6,68(a6)        ; L de ACTIVE
  move d5,24(a6)        ; BAR pointe sur SCREEN
  move d5,4(a6)         ; ROOT pointe sur SCREEN
  subq #1,d5
  move d5,52(a6)        ; ACTIVE pointe sur le dernier titre
  addq #1,d5
  move #2,-24(a1)       ; le dernier titre pointe sur ACTIVE
  lea 72(a6),a3         ; a3 pointe sur la suite des titres

        ; objet SCREEN

  addq #1,d5
  move d5,2(a0)         ; SCREEN pointe sur son premier enfant
  moveq #5,d6
.lb2: move.l (a0)+,(a1)+
  dbf d6,.lb2
  moveq #20,d7          ; premier BOX, large de 20 au minimum

        ; objet drop-down

  move.l a1,a6          ; conserve l'adresse du drop-down

.loopbox: addq #1,d5
  clr (a1)+             ; suivant inconnu
  move d5,(a1)+         ; 1ø enfant
  clr (a1)+             ; dernier inconnu
  move #20,(a1)+        ; G_BOX
  clr.l (a1)+           ; flag et state
  move.l #$FF1100,(a1)+ ; obspec
  move 16(a3),d6        ; x du titre
  add d0,d6
  add d0,d6             ; plus deux colonnes de d‚calage
  move d6,(a1)+         ; x du BOX
  clr (a1)+             ; y
  clr.l (a1)+           ; l et h inconnus

  moveq #0,d3           ; hauteur du BOX

.loopstr:
  move.l indexadr,a2
  move.b d5,(a2)+       ; table de conversion
  move.l a2,indexadr
  add.w d4,a4   ; chaine suivante
  tst.b (a4)
  beq.s .finboite       ; chaine nulle pour la fin d'un DROP-DOWN
  move.l a4,a2
.lb3: tst.b (a2)+
  bne.s .lb3
  sub.l a4,a2
  subq.l #1,a2
  cmp a2,d7             ; compare avec taille maxi
  bpl.s .lb4
  move a2,d7            ; ‚change si plus
.lb4:
       ; objet STRING

  addq #1,d5
  move d5,(a1)+         ; pointe sur suivant
  move.l #-1,(a1)+      ; pas d'enfants
  move #28,(a1)+        ; G_STRING
  clr.l (a1)+           ; flag et state
  move.l a4,(a1)+       ; chaine
  clr (a1)+             ; x
  move d3,(a1)+         ; y
  clr (a1)+             ; l inconnu
  move d1,(a1)+         ; h=1 caractŠre

  add d1,d3             ; BOX augmente de taille
  bra.s .loopstr        ; entr‚e suivante

.finboite: muls d0,d7   ; largeur BOX
  tst isfirst  ; est-ce le premier menu?
  beq.s .autre ; 0 si c'est un autre

        ; objet separateur

  addq #1,d5
  move d5,(a1)+
  move.l #-1,(a1)+
  move #28,(a1)+
  move.l #8,(a1)+
  move.l #separe,(a1)+
  clr (a1)+
  move d3,(a1)+
  add d1,d3
  clr (a1)+
  move d1,(a1)+

       ; les accessoires

  moveq #5,d6
.loopacc: addq #1,d5
  move d5,(a1)+
  move.l #-1,(a1)+
  move #28,(a1)+
  clr.l (a1)+
  move.l #nulle,(a1)+
  clr (a1)+
  move d3,(a1)+
  add d1,d3
  clr (a1)+
  move d1,(a1)+
  dbf d6,.loopacc

  clr isfirst

.autre: move d5,(a6)   ; lie les drop downs
  subq #1,d5
  move d5,4(a6)        ; BOX pointe sur le dernier enfant
  addq #1,d5
  move 24(a6),d6       ; sur qui pointe le premier enfant...
  subq #2,d6           ; ... donc -2 = index du BOX
  move d6,-24(a1)      ; le dernier enfant pointe sur BOX
  move d3,22(a6)       ; H du BOX
.lb5: move d7,20(a6)   ; L du BOX et des STRINGs
  add.w #24,a6         ; objet suivant
  cmp.l a6,a1          ; fini?
  bne.s .lb5           ; ben non

  cmp #2,(a3)
  beq.s .fin           ; c'‚tait le dernier titre ( il pointe sur ACTIVE )
  add.w #24,a3         ; titre suivant
  clr d7               ; largeur du BOX
  bra .loopbox

.fin: move d5,(a5)     ; nombre d'objets dans header
  move d5,d3
  muls #24,d3
  add.w #40,d3         ; taille totale
  move d3,14(a5)       ; dans header
  move d3,global+18

  move.l a1,topprg     ; actualise le dicco
  add.w #24,a3         ; aprŠs les titres on pointe sur SCREEN !
  move d5,d3

.lb6: sub.w #24,a1     ; objet pr‚c‚dent
  subq #1,d3
  cmp (a1),d5
  bne.s .lb6           ; lorqu'il pointera sur d5, ce sera le dernier dropdown

  move d3,4(a3)        ; SCREEN pointe sur son dernier enfant
  move 2(a3),d3        ; sur qui pointe SCREEN...
  subq #1,d3           ; ...donc - 1 c'est son index
  move d3,(a1)         ; le dernier BOX pointe sur SCREEN.

  move.l topprg,a1
  move.l a1,global+6   ; adresse de la table de conversion
  move.l #indextab,a0
  move.l indexadr,d0

.lb7: move (a0)+,(a1)+
  cmp.l d0,a0
  bmi.s .lb7           ; transvase la table de conversion
  move #127,(a1)+       ; pour fin de table
  move.l a1,topprg
  movem.l (sp)+,a4-a6
  rts

   COPIE setmenu,y217,1
setmenu: lea global+6,a0
  move.l (a6)+,a1
  lea -4(a1),a2        ; adresse de la table des arbres
  sub.w #40,a1         ; adresse du header
  move 34(a1),d0       ; taille.w
  move.l a1,a3
  add.w d0,a3          ; debut de la table de conversion
  move.l a3,(a0)+
  move.l a2,(a0)+
  move.l a1,(a0)+
  move d0,(a0)
y217: rts

   COPIE gemindex,y218,1
gemindex: move.l (a6),d0
  move.l global+6,a0
  move.b (a0,d0),3(a6)
y218: rts

   COPIE strindex,y219,1
strindex: move.l (a6),d0
  move.l global+6,a0
  lea 1(a0),a2
.lb0: cmp.b (a0)+,d0
  beq.s .fin
  bpl.s .lb0
.fin: sub.l a2,a0
  move.l a0,(a6)
y219: rts

obdata: dc.l 0
obptr:  dc.l 0
tedata: dc.l 0
imagedat: dc.l 0
obindex: dc.w 0
pereindex: dc.w 0
pereadr: dc.l 0
large: dc.w 1
haut: dc.w 1

   SAUT
dialogue: VCONTROL 38,0,0,0
   VDI
   move.l ptsout+4,large
   move.l (a6)+,imagedat
   move.l (a6)+,tedata
   move.l (a6),obdata
   move.l (a6)+,obptr
   clr obindex
   rts

   COPIE lastobj,y220,1
lastobj: move.l obptr,a0
   or.w #32,-16(a0)
y220: rts

   COPIE child,y221,1
child: move.l (a6)+,d0
   move d0,pereindex
   muls #24,d0
   move.l obdata,a0
   lea 2(a0,d0),a0
   move obindex,(a0)+
   move.l a0,pereadr
y221: rts

   COPIE parent,y222,1
parent: move.l obptr,a0
   move pereindex,-24(a0)
   move.l pereadr,a0
   move obindex,d0
   subq #1,d0
   move d0,(a0)
y222: rts

   NON
objets:
	if STE=0
		move (.data-1484,pc,d1.w*2),d1
	else
		lea .data-1484,a1
		add d1,d1
		move 0(a1,d1.w),d1
	endif
   moveq #0,d7
   bra.s xylh
.data: dc.w 20,25,27,26,28,32

; dans d1 : obtype
; dans d7 : 0 obspec est sur la pile
;          -1 obspec dans d4
;           1 image ou icone, obspec dans d4, d2:largeur, d3:hauteur

xylh: addq #1,obindex
   move obindex,d0
   cmp #1,d0
   bne.s .lb0                    ; ce n'est pas le d‚but
   moveq #-1,d0                  ; sinon l'objet pointe sur -1
.lb0: move.l obptr,a1
   move d0,(a1)+                 ; pointe sur le suivant
   move.l #-1,(a1)+              ; pas encore d'enfants
   move d1,(a1)+                 ; obtype
   cmp #1,d7                     ; est-ce une image? ou une icone?
   beq.s .lb2                    ; si oui, h et l d‚j… calcul‚s
   addq.l #2,a6
   move.b (a6)+,d6
   move.b (a6)+,d3
   ext.w d3
   muls haut,d3
   ext.w d6
   add d6,d3                     ; hauteur
   addq.l #2,a6
   move.b (a6)+,d6
   move.b (a6)+,d2
   ext.w d2
   muls large,d2
   ext.w d6
   add d6,d2                     ; largeur
.lb2: addq.l #2,a6
   move.b (a6)+,d6
   move.b (a6)+,d0
   ext.w d0
   muls haut,d0
   ext.w d6
   add d6,d0                     ; y
   addq.l #2,a6
   move.b (a6)+,d6
   move.b (a6)+,d1
   ext.w d1
   muls large,d1
   ext.w d6
   add d6,d1                     ; x
   tst d7                        ; tedinfo d‚j… dans d4?
   bne.s .lb1
   move.l (a6)+,d4               ; spec
.lb1: move.l (a6)+,d5            ; state
   move.l (a6)+,d6               ; flag
   move d6,(a1)+
   move d5,(a1)+
   move.l d4,(a1)+
   move d1,(a1)+
   move d0,(a1)+
   move d2,(a1)+
   move d3,(a1)+
   move.l a1,obptr
   rts

   NON
boxtext:
	if STE=0
		move (.data-1496,pc,d1.w*2),d1   ; obtype
	else
		lea .data-1496,a0
		add d1,d1
		move 0(a0,d1.w),d1
	endif
.lb1: add.l #28,tedata  ; tedinfo suivante
   move.l tedata,a0
   clr.l -(a0)           ; longueurs nulles en attendant
   move (a6)+,-(a0)      ; largeur cadre dans la partie sup de couleur
   clr -(a0)
   move (a6)+,-(a0)      ; couleur , partie inf‚rieure
   move.l (a6)+,d0
   move d0,-(a0)         ; justification
   clr -(a0)
   cmp #25,d1
   bpl.s .masque         ; on saute si FTEXT ou FBOXTEXT
   move.l (a6)+,d0
   move d0,-(a0)         ; fonte
   move.l #nulle,-(a0)
   move.l (a0),-(a0)
   move.l (a6)+,a1       ; chaine
   move.l a1,-(a0)       ; adr texte
   move #1,26(a0)        ; len de mask
   bra.s .fin
.masque: move #3,-(a0)   ; toujours fonte normale
   move.l (a6)+,a1
   move.l a1,-(a0)       ; valid
   move.l (a6)+,a2
   move.l a2,-(a0)       ; mask
   move.l (a6)+,-(a0)    ; text
   move.l a2,a3
.lb2: tst.b (a3)+
   bne.s .lb2
   sub.l a2,a3
   move a3,26(a0)        ; len de mask
.fin: move.l a1,a2
.lb3: tst.b (a2)+
   bne.s .lb3
   sub.l a1,a2
   move a2,24(a0)        ; longueur+1
   moveq #-1,d7          ; tedinfo pr‚sente
   move.l a0,d4          ; son adresse dans d4
   bra xylh
.data: dc.w 21,22,29,30

   SAUT
image: add.l #14,imagedat
   move.l imagedat,a0
   move.l (a6)+,d0
   move d0,-(a0)         ; couleur
   clr.l -(a0)           ; X et Y toujours nuls, l'image est aussi son cadre
   move.l (a6)+,a1       ; adresse des donn‚es
   move.l (a6)+,d3       ; hauteur
   move d3,-(a0)
   move.l (a6)+,d2       ; largeur en mots
   move d2,-(a0)
   asl #3,d2             ; *8 = largeur en points!
   move.l a1,-(a0)
   move.l a0,d4          ; adresse structure
   moveq #1,d7           ; image
   moveq #23,d1          ; G_IMAGE
   bra xylh

   SAUT
userdef:
   move.l imagedat,a0
   move.l a0,d4          ; obspec dans d4
   move.l (a6)+,4(a0)    ; paramŠtre user
   lea 8(a0),a1          ; le 'boot' de la routine
   move.l a1,(a0)
   move.l a1,a0
   move.l (a6)+,d0       ; code du mot ::
   lsl #2,d0             ; fois 4
   lea adresse,a1
   move.l 0(a1,d0),a1    ; adresse de ce mot
   addq.l #2,a1          ; on saute le code 437 ( [ass] )
   lea .userdat,a2
   move.l a1,16(a2)      ; fixe la bonne adresse
   moveq #6,d0
.lb0: move.l (a2)+,(a0)+
   dbf d0,.lb0           ; transfŠre le boot
   move.l a0,imagedat
   moveq #24,d1          ; G_USERDEF
   moveq #-1,d7          ; obspec dans d4
   bra xylh
.userdat:                ; boot des userdefs
   movem.l d1-a6,-(sp)
   move.l botmem,a6      ; pile provisoire
   move.l 60(sp),-(a6)   ; adresse des infos sur l'objet
   jsr userdef           ; saute … la routine
   move.l (a6)+,d0       ; paramŠtre de retour
   movem.l (sp)+,d1-a6
   rts

   SAUT
icon: move.l imagedat,a0
   move.l a0,d4          ; obspec
   moveq #31,d1          ; G_ICON
   moveq #1,d7           ; pour xylh
   moveq #84,d2          ; largeur ( 14 caractŠres * 6 points )
   moveq #40,d3          ; hauteur ( 32 image + 8 texte )
   move.l (a6)+,a1
   move.l a1,(a0)+       ; masque
   lea 128(a1),a1
   move.l a1,(a0)+       ; donn‚es
   move.l (a6)+,(a0)+    ; chaine
   move.l (a6)+,d0
   move d0,(a0)+         ; couleurs + caractŠre
   move.l (a6)+,d0
   move d0,(a0)+         ; x du caractŠre
   move.l (a6)+,d0
   move d0,(a0)+         ; y
   move.l #$1a0000,(a0)+   ; (26,0) = (x,y) de l'icone
   move.l #$200020,(a0)+   ; (32,32) = (l,h) de l'icone
   move.l #$000020,(a0)+   ; (0,32) = (x,y) du texte
   move.l #$540008,(a0)+   ; (84,8) = (l,h) du texte ( 14 caractŠres maximum )
   move.l a0,imagedat
   bra xylh

   SAUT
mfdbs: lea mfdb_s,a0
   bra.s mfdb

	SAUT
mfdbd: lea mfdb_d,a0

mfdb: moveq #2,d1
	move.l (a6)+,d0
   bpl.s .lb0
   neg.l d0						; revient … positif
   cmp.l d0,d1
   bne.s .lb3
   move.l a0,-(a6)			; si -2, alors renvoyer l'adresse !
	rts
.lb3:
   clr.l (a0)             ; premier paramŠtre -1 : c'est l'‚cran
   rts
.lb0: cmp.l d1,d0
   bmi.s .lb1             ; si c'est 0 ou 1, les paramŠtres sont sur la pile
   move.l d0,a1           ; sinon, c'est l'adresse d'un MFDB en RAM
   move.l (a1)+,(a0)+     ; adresse du dessin
   move (a1)+,d0          ; largeur
   move d0,(a0)+
   move (a1)+,(a0)+       ; hauteur
   add.w #15,d0
   lsr #4,d0              ; largeur en mots
   move d0,(a0)+
   move.l 2(a1),(a0)+     ; format et plans
.fin: clr.l (a0)+
   clr (a0)               ; trois mots r‚serv‚s
   rts
.lb1: move.l (a6)+,d1     ; paramŠtres sur la pile
   move.l (a6)+,d2
   move.l (a6)+,d3
   move.l (a6)+,(a0)+     ; l'adresse
   move d3,(a0)+          ; L
   move d2,(a0)+          ; H
   add.w #15,d3
   lsr #4,d3
   move d3,(a0)+          ; L en words
   move d0,(a0)+          ; format
   move d1,(a0)+          ; plans
   bra.s .fin

   SAUT
vr_trnfm: lea control,a0
   move #110,(a0)+
   clr.l (a0)+
   clr.l (a0)+
   clr (a0)+
   move handle,(a0)+
   move.l #mfdb_s,(a0)+
   move.l #mfdb_d,(a0)
   VDI
   rts

   SAUT
vrt_cpyfm: lea control,a0
   move.l #$790004,(a0)+      ; fonction 121 et 4
   moveq #3,d0
   move.l d0,(a0)+
   clr.l (a0)+
   move handle,(a0)+
   move.l #mfdb_s,(a0)+
   move.l #mfdb_d,(a0)
   move.l (a6)+,d2            ; couleur fond
   move.l (a6)+,d1            ; couleur 1øplan
   move.l (a6)+,d0            ; mode
   movem.w d0-d2,intin        ; dans intin
deuxblocs: movem.l (a6)+,d0-d5        ; d0 = H, L, Yd, Xd, Ys, Xs = d5
   lea ptsin,a0
   move d5,(a0)+              ; coin sup
   move d4,(a0)+
   subq #1,d1
   subq #1,d0                 ; L-1 et H-1
   add d1,d5
   add d0,d4
   move d5,(a0)+              ; coin inf = Xs+L-1 et Ys+H-1
   move d4,(a0)+
   move d3,(a0)+              ; coin sup dest
   move d2,(a0)+
   add d1,d3
   add d0,d2
   move d3,(a0)+              ; coin inf = Xd+L-1 et Yd+H-1
   move d2,(a0)
   tst.b xy_flag
   beq.s .fin                 ; pas d'offset
   if STE=0
	   move.l ([fenetre]),d0      ; x y de la fenetre active
	else
		move.l fenetre,a0
		move.l (a0),d0
	endif
   tst.l mfdb_d
   bne.s .source              ; si <>0, ce n'est pas l'‚cran
   lea ptsin+8,a0
   add.l d0,(a0)+
   add.l d0,(a0)              ; ajoute l'offset
.source:
	tst.l mfdb_s
	bne.s .fin                 ; si <>0, pas l'‚cran
	lea ptsin,a0
	add.l d0,(a0)+
	add.l d0,(a0)              ; ajoute l'offset
.fin:
   VDI
   rts

   SAUT
vro_cpyfm: lea control(pc),a0
   move.l #$6D0004,(a0)+      ; fonction 109 et 4
   moveq #1,d0
   move.l d0,(a0)+
   clr.l (a0)+
   move handle,(a0)+
   move.l #mfdb_s,(a0)+
   move.l #mfdb_d,(a0)
   move.l (a6)+,d0
   move d0,intin              ; le mode
   bra deuxblocs

	SAUT
vm_coords:
	moveq #1,d0
	move.l a6,a0
	lea -4(a6),a6
	move.l a6,a1
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0),(a1)
	move.l d0,(a0)
	V1 5,0,5,99

	SAUT
v_opnwk:
	moveq #1,d0
	bra ouvrir

	SAUT
v_clswk:
	V3 2,0

	COPIE _page,hgf,1
_page: move.l fenetre,-(a6)
hgf: rts

	COPIE _fpu,fpuend,1
_fpu: move.l #is_fpu,-(a6)
fpuend:	rts

	SAUT
form_button:
	A1 56,2,2,1

	SAUT
form_keybd:
	A1 55,3,3,1

	SAUT
fsel_exinput:
	A1 91,0,2,3

	SAUT
menu_attach:
	A1 37,2,1,2

	SAUT
menu_istart:
	A1 38,3,1,1

	SAUT
menu_popup:
	A1 36,2,1,2

	SAUT
menu_settings:
	A1 39,1,1,1

	SAUT
objc_add:
	A1 40,2,1,1

	SAUT
objc_delete:
	A1 41,1,1,1

	SAUT
objc_order:
	A1 45,2,1,1

	SAUT
objc_sysvar:
	A1 48,4,3,0

	SAUT
rsrc_obfix:
	A1 114,1,1,1

	SAUT
rsrc_rcfix:
	A1 115,0,1,1

	SAUT
wind_new:
	A1 109,0,1,0

	COPIE basepage,y123,1
basepage:
	move.l bspage,-(a6)
y123:rts

	COPIE _app,y122,1
_app:
	move.l _app_flag,-(a6)
y122: rts

	SAUT
reserve:
	move.l szone,-(sp)
	GEMDOS $49,6			; libŠre la table d'allocation dynamique

	ifnd LIB					; seulement sous l'‚diteur

	move.l debut_prog,d0
	move.l program,d1
	cmp.l d0,d1
	beq.s .deuxieme		; d‚j… utilis‚, le menu est sauv‚
	sub.l d0,d1				; taille … garder
	move.l d1,-(sp)
	move.l d0,-(sp)
	clr.w -(sp)
	GEMDOS $4a,12			; r‚duit au seul menu
	bra.s .suite
.deuxieme:
	move.l debut_prog,-(sp)
	GEMDOS $49,6			; libŠre la m‚moire
.suite:

	else

	move.l program,-(sp)
	GEMDOS $49,6			; libŠre la m‚moire

	endif

	move.l  #-1,-(sp)
   GEMDOS $48,6
	move.l d0,-(a6)
	moveq #100,d0
	move.l d0,-(a6)
	bsr div					; divis‚ par cent
	bsr mul					; taille fois x (pour cent)
	move.l (a6)+,d7
	move.l (a6),d0			; taille absolue en Ko
	moveq #10,d1
	asl.l d1,d0				; en octets
	add.l d0,d7  			; plus la taille absolue
   move.l  d7,-(sp)
   GEMDOS $48,6			; r‚serve
   bmi.s .erreur
   move.l d0,d1
   move.l d0,program
   ifnd LIB
   move.l d0,debut_prog
   endif
   move.l d0,topprg
   add.l d0,d7
   subq.l #4,d7
   move.l  d7,topmem
   move.l  d7,botmem
   move.l  #1028,-(sp)	; table d'allocation
   GEMDOS $48,6
   move.l  d0,a0
   move.l  d0,szone
   bmi.s .erreur
   clr.l (a0)+
   clr.l (a0)+
   moveq #-1,d0
   move.l  d0,(a0)
	move.l d7,(a6)
	rts
.erreur:
	move.l d0,(a6)
	rts

	SAUT
nvmaccess:
	move.l (a6)+,-(sp)
	movem.l (a6)+,d0-d2
	move d0,-(sp)
	move d1,-(sp)
	move d2,-(sp)
	XBIOS 46,12
	move.l d0,-(a6)
	rts

	SAUT
wdial_create:
   jsr ttt
   bne.s .lb0
   move #140,(a2)+
   lea 26(a2),a1
   move.l a1,(a0)
   move.l a2,a3
   bsr.s .lb1
   rts
.lb0: pea 26(a3)
   move.l (sp)+,(a1)
   bsr spass
   bsr.s .lb1
	rts
.lb1:
	move.l (a6)+,a0		; adresse de l'arbre
	moveq #0,d7				; pas d'offset
	move.l a0,(a3)+		; range l'adresse
;	btst #4,11(a0)			; bit OUTLINED
;	beq.s .lb2
;	move.l #$30003,d7		; taille de la bordure
.lb2:
	move.l a0,fc_addrin
	GEM_AES wd_form_center
	lea fc_out+2,a0
	move.l (a0)+,(a3)+
	move.l (a0),(a3)+		; les coordonn‚es internes
	lea wc_in,a0
	clr (a0)+				; calculer l'ext‚rieur
	move #11,(a0)+			; TITLE, MOVER, CLOSER
	sub.l d7,(a0)+			; oter la bordure … X et Y
	add.l d7,d7				; la doubler en largeur et hauteur
	add.l d7,(a0)
	GEM_AES wd_wind_calc
	lea fc_out2+2,a0
	move.l (a0)+,(a3)+
	move.l (a0),(a3)+		; taille totale de la fenˆtre
	clr (a3)+				; handle … 0
	clr.l (a3)				; les pointeur du champ d'‚dition … 0
	rts

	SAUT
wdial_open:
	move.l (a6)+,a3
	move 20(a3),d7
	beq.s .premier
	lea wc_in,a0
	move d7,(a0)+
	move #10,(a0)+
	move d7,(a0)
	GEM_AES wd_wind_set
	ext.l d7
.fin:
	addq.l #8,a6			; ignore le titre et l'index edit
	move.l d7,-(a6)		; le handle est renvoy‚
	rts
.premier:
	lea fc_out,a0
	move #11,(a0)+		; mover, closer, title
	move.l 12(a3),(a0)+
	move.l 16(a3),(a0)	; x,y,l,h
	GEM_AES wd_wind_create
	move wc_in,d7
	ext.l d7
	bmi.s .fin
.table:
	lea wd_table,a0
.lb1:
	tst.l (a0)+			; cherche une place libre
	bne.s .lb1
	move.l a3,-(a0)	; ajoute cette structure dans la table
	move d7,20(a3)		; sauve le handle
	move.l (a6)+,d0	; chaine de titre
	move.l (a6)+,d1	; index edit
	move d1,22(a3)
	move.l (a3),a0		; arbre
	muls #24,d1
	add.l d1,a0
	btst #3,9(a0)		; objet ‚ditable?
	bne.s .oui
	clr.l 22(a3)
	bra .suite
.oui:
	move.l 12(a0),a0	; tedinfo
	move.l (a0),a0			; chaine saisie
	move.l a0,a1
.lb0:
	tst.b (a0)+
	bne.s .lb0
	sub.l a1,a0
	subq.l #1,a0
;	move a0,24(a3)			; position pour l'‚dition
	clr 24(a3)
.suite:
	lea wc_in,a0
	move d7,(a0)+			; handle
	move #2,(a0)+			; set TITLE
	move.l d0,(a0)			; adresse
	GEM_AES wd_wind_set
	lea fc_out,a0
	move d7,(a0)+
	move.l 12(a3),(a0)+
	move.l 16(a3),(a0)	; x,y,l,h
	GEM_AES wd_wind_open
	move.l d7,-(a6)
	rts

	SAUT
wdial_close:
	move.l (a6)+,a3
	move 20(a3),d7			; le handle
	beq.s .fin				; si nul, pas ouvert
	clr 20(a3)				; si on referme, handle nul
	move d7,wc_in
	GEM_AES wd_wind_close
	move d7,wc_in
	GEM_AES wd_wind_delete
	lea wd_table,a0
.lb1:
	cmp.l (a0)+,a3			; recherche dans la table
	bne.s .lb1
	clr.l -(a0)				; et ensuite efface cette adresse
.fin:
   rts

; renvoit 		0: rien … faire
; 			i	XXXX 1 : i=index du bouton exit ou i=-1 fermer fenetre

   SAUT
wdial_formdo:
	movem.l a4-a5,-(sp)
	move.l (a6)+,a5		; intout
	move.l (a6),a4	   	; le buffer de event-mesag
	movem.l a4-a5,.sauve	; pour un deuxiŠme appel cons‚cutif
.encore:
	clr.l (a6)				; renvoit 0 par d‚faut
	moveq #0,d6
	and #$13,(a5)			; ne garde que MESAG/BUTTON/KEYB
	move (a5)+,d6			; l'‚vŠnement
	bclr #4,d6				; teste si MESAG
	beq .k0
	move d6,-2(a5)			; range l'‚vŠnement avec MESAG en moins
	lea wd_table,a0
	move 6(a4),d7			; handle de la fenˆtre concern‚e
	moveq #19,d1			; pour boucler
.lb0:
	tst.l (a0)				; emplacement vide
	beq.s .lb1
	move.l (a0),a3
	cmp 20(a3),d7			; le bon handle?
	beq.s .lb2
.lb1:
	addq.l #4,a0
	dbf d1,.lb0
	bra .k0				; aucun handle ne convient, autre ‚vŠnement
.lb2:
	cmp #20,(a4)			; REDRAW?
	bne .z0
	clr .init_field		; pour le curseur
	tst 22(a3)				; champ ‚ditable?
	beq.s .r0
; a virer????
	lea wc_in,a0
	move d7,(a0)+
	move #10,(a0)
	GEM_AES wd_wind_get	; fenˆtre au top
	cmp fc_out+2,d7
	bne.s .r0
; ???
	lea 4(a3),a0			; si editable et fenetre au top, tout redessiner
	move #3,.init_field	; ED_END
	bra.s .r1
.r0:
	lea 8(a4),a0			; sinon, prendre les coordonn‚es de event-mesag
.r1:
	move.l d7,-(a6)
	moveq #0,d0
	rept 4
		move (a0)+,d0
		move.l d0,-(a6)	; copie les 4 coordonn‚es
	endr
	move.b xy_flag,xy_flag+1
	sf xy_flag				; mode absolu
	bsr set_redraw			; initialise
	move.l (a3),fc_addrin	; arbre pour object_draw
	move.l a3,-(sp)		; utilis‚ dans _redraw!
.r2:
	bsr _redraw
	tst.l (a6)+				; flag renvoy‚
	beq .r3					; si 0, c'est la fin
	lea fc_out,a0
	move.l #8,(a0)+
	move.l (a6)+,d0
	move.l (a6)+,d1
	move.l (a6)+,d2
	sub.l d2,d0
	addq #1,d0
	move.l (a6)+,d3
	sub.l d3,d1
	addq #1,d1
	move.w d3,(a0)+
	move.w d2,(a0)+
	move d1,(a0)+
	move d0,(a0)
	GEM_AES wd_object_draw
	bra.s .r2
.init_field: dc.w 0
.r3:
	move.l (sp)+,a3		; _redraw l'a ‚cras‚!
	tst 22(a3)				; champ ‚ditable?
	beq.s .non
	tst .init_field		; s'occuper du curseur?
	beq.s .non
	move.l (a3),fc_addrin	; l'arbre
	lea fc_out,a0
	move 22(a3),(a0)+			; index ‚ditable
	clr (a0)+					; touche inutile
	move 24(a3),(a0)+			; position
	move .init_field,(a0)	; ED_END
	GEM_AES wd_objc_edit
	move fc_out+2,24(a3)		; nouvelle position
.non:
	move.b xy_flag+1,xy_flag		; restaure le mode pr‚c‚dent.
					; renvoit 0, rien … faire!
	bra .fin
.z0:
	cmp #21,(a4)			; WM TOPPED?
	bne.s .z1
	lea wc_in,a0
	move d7,(a0)+
	move #10,(a0)+
	move d7,(a0)
	GEM_AES wd_wind_set	; top la fenetre D7
	tst 22(a3)				; un champ ‚ditable?
	beq .fin					; renvoit 0
; a virer ????
;	cmp #-1,global+2		; et multitos?
;	bne .fin
; ???
	lea fc_out,a0
	move #3,(a0)+			; FDM_FINISH
	clr.l (a0)+
	clr.l (a0)+
	move.l 4(a3),(a0)+
	move.l 8(a3),(a0)		; coordonn‚es int‚rieures
	GEM_AES wd_form_dial
	bra .fin					; renvoit 0
.z1:
	cmp #22,(a4)			; WM CLOSED?
	bne.s .z2
	moveq #-1,d0
	move.l d0,(a6)			; -1 pour fermer
	move.l a3,-(a6)		; renvoit XXXX
	moveq #1,d0
	move.l d0,-(a6)		; et 1, agir!
	bra .fin
.z2:
	cmp #28,(a4)			; WM MOVED?
	bne.s .k0
	lea wc_in,a0
	move d7,(a0)+			; le handle
	move #5,(a0)+			; deplace WF_CURRXYWH
	move.l 8(a4),(a0)+
	move.l 12(a4),(a0)	; x,y,w,h
	GEM_AES wd_wind_set
	move.l 4(a3),d0		; x,y internes
	sub.l 12(a3),d0		; offset interne/externe
	move.l 8(a4),d1		; nouvelles externes
	move.l d1,12(a3)		; dans la structure
	add.l d0,d1				; nouvelles internes
	move.l d1,4(a3)		; dans la structure...
	move.l (a3),a0			; (l'arbre)
	move.l d1,16(a0)		; ...et comme coordonn‚es du rectangle de l'arbre
	bra .fin					; renvoit 0
.k0:
	bclr #0,d6				; teste si KEYBD
	beq .k1
	move d6,-2(a5)
	tst 8(a5)
	beq .k1					; si touche=0, erreur!
	lea wc_in,a0
	move.l #10,(a0)
	GEM_AES wd_wind_get	; fenˆtre au top
	move fc_out+2,d7		; son handle
	lea wd_table,a0
	moveq #19,d1			; pour boucler
.lb8:
	tst.l (a0)				; emplacement vide
	beq.s .lb9
	move.l (a0),a3
	cmp 20(a3),d7			; le bon handle?
	beq.s .lb10
.lb9:
	addq.l #4,a0
	dbf d1,.lb8
					; fenetre pas … nous
	bra .fin
.lb10:
	move.l (a3),fc_addrin	; l'arbre
	lea fc_out,a0
	move 22(a3),(a0)+		; l'index (ou 0 si pas de FTEXT mais un DEFAULT)
	move 8(a5),(a0)+		; touche press‚e (dans intout de event multi)
	move 22(a3),(a0)+		; pour XaAES
	GEM_AES wd_form_keybd
	lea fc_out2,a0
	tst (a0)+				; 0 si bouton DEFAULT ou 1 autrement
	bne.s .lb11
	move (a0),d7			; index du bouton default
	bra .lb12				; sortie comme pour FORM BUTTON avec un EXIT
.lb11:
	move (a0)+,d6			; new_obj
	move (a0),d7			; key_out
	cmp 22(a3),d6
	beq.s .lb13
.new_obj:
	moveq #24,d0
	muls d6,d0
	move.l (a3),a0
	move.l 12(a0,d0.l),a0	; adresse tedinfo
	move.l (a0),a0			; texte
	move.l a0,d0
.lb14:
	tst.b (a0)+
	bne.s .lb14
	sub.l d0,a0
	subq.l #1,a0
	move a0,d5				; d6 contient new_objc et d5 contient new_pos
	move.l (a3),fc_addrin	; l'arbre
	lea fc_out,a0
	move 22(a3),(a0)+		; objet actuel
	clr (a0)+
	move 24(a3),(a0)+		; position
	move #3,(a0)			; ED_END
	GEM_AES wd_objc_edit
	move d6,22(a3)			; nouvel objet
	lea fc_out,a0
	move d6,(a0)+			; nouveau
	clr (a0)+
	move d5,(a0)+			; nouvelle position
	move #1,(a0)			; ED_INIT
	GEM_AES wd_objc_edit
	move fc_out2+2,24(a3)	; nouvelle position
.lb13:
	tst d7					; keyout=0??
	beq .fin
	lea fc_out,a0			; passer par objc_edit
	move 22(a3),d6			; new_obj
	move d6,(a0)+			; objet
	move d7,(a0)+			; touche
	move 24(a3),(a0)+		; position
	move #2,(a0)			; mode ED_CHAR
	GEM_AES wd_objc_edit
	swap d6
	move fc_out2+2,d6		; new_pos
	move d6,24(a3)			; mise … jour
					; rien … faire
	bra .fin
.k1:
	bclr #1,d6				; teste si BUTTON
	beq .fin
	move d6,-2(a5)
	lea wc_in,a0
	move.l #10,(a0)
	GEM_AES wd_wind_get	; fenˆtre au top
	move fc_out+2,d7		; son handle
	lea wd_table,a0
	moveq #19,d1			; pour boucler
.lb3:
	tst.l (a0)				; emplacement vide
	beq.s .lb4
	move.l (a0),a3
	cmp 20(a3),d7			; le bon handle?
	beq.s .lb5
.lb4:
	addq.l #4,a0
	dbf d1,.lb3
.lb7:
					; la fenetre au top n'est pas … nous
	bra .fin
.lb5:
	lea fc_out,a0
	move.l #8,(a0)+		; de l'objet 0 … 8 de profondeur
	move.l (a5),(a0)		; mousex et mousey (de evnt_multi)
	move.l (a3),fc_addrin	; l'arbre
	GEM_AES wd_objc_find
	moveq #0,d7
	move fc_out,d7
	bmi.s .lb7				; si <0, rien trouv‚
	move 12(a5),fc_out+2	; nombre de clicks
	GEM_AES wd_form_button
	tst fc_out
	beq.s .lb12
	moveq #0,d7		; pas de Keyout si newobj
	move fc_out+2,d6		; new_obj?
	bgt .new_obj			; oui, on s'occupe de d‚placer le curseur
	lsl d6
	lsr d6
	move d6,d7		; sinon objet EXIT (sans bit 15)
	; renvoit 0
	beq.s .fin		; peut pas etre nul! sinon on evite
.lb12:
	move.l d7,(a6)			; si un EXIT, renvoit l'index
	move.l a3,-(a6)		; et la structure
	moveq #1,d0
	move.l d0,-(a6)		; et 1
.fin:
	movem.l .sauve,a4-a5
	tst.l (a6)				; renvoit 0?
	bne.s .sortie			; non, traitement compl‚mentaire par utilisateur
	tst (a5)					; un ‚vŠnement reste encore?
	bne .encore				; oui, traiter!
.sortie:
	movem.l (sp)+,a4-a5
   rts
.sauve: dc.l 0,0

	SAUT
wdial_change:
	move.l (a6)+,a3		; la stucture
	move.l (a6)+,d6		; l'index de l'objet … modifier
	move.l (a3),a2
	moveq #24,d0
	muls d6,d0
	lea 10(a2,d0.l),a2	; adresse STATE
	move (a2),d5			; STATE
	bclr #0,d5				; sans son SELECTED
	move 20(a3),d7			; handle de la fenˆtre
	lea wc_in,a0
	move d7,(a0)+
	move #10,(a0)
	GEM_AES wd_wind_get	; fenˆtre au top
	cmp fc_out+2,d7      ; est-ce la bonne?
	beq.s .oui
	move d5,(a2)			; sinon, on modifie simplement le STATE
	rts
.oui:
	move.l (a3),fc_addrin	; l'arbre!
	lea fc_out,a0
	move d6,(a0)+			; l'objet
	clr (a0)+				; reserv‚
	move.l 4(a3),(a0)+	; x et y int‚rieurs
	move.l 8(a3),(a0)+	; h et l
	move d5,(a0)+			; nouvel ‚tat
	move #1,(a0)			; REDRAW
	GEM_AES wd_objc_change	; modifie l'objet et le redessine
	rts

	SAUT
wdial_evnt:
	move.l (a6)+,wd_evnt_multi+12		; intout
	move.l (a6)+,fc_addrin				; buffer pour mesag
	GEM_AES wd_evnt_multi
	rts										; valeurs retourn‚es dans les tableaux

	SAUT
vq_margin:
	move #2100,d0
	bra vdiquatre

	SAUT
vq_driver_info:
	move #2101,d0
	bsr vdiquatre
	lea intout+11,a0
	lea pad+2,a1
	move.l a1,-(a6)		; renvoit pad
	moveq #25,d0
.lb0:
   move.b (a0),(a1)+
   addq.l #2,a0
   dbf d0,.lb0
   clr.b	(a1)
	rts

	SAUT
vq_bit_image:
	move #2102,d0
	bra vdiquatre

	SAUT
vs_page_info:
	move.l (a6)+,a0			; texte
	move.l (a6)+,d0			; type
	lea intin,a1
	move d0,(a1)+
	move.l a0,d0
	moveq #0,d1
.lb0:
	move.b (a0)+,d1
	move d1,(a1)+
	bne.s .lb0
	sub.l d0,a0					; taille chaine
	addq.l #1,a0
	lea control,a1
	move.l #$50000,(a1)+
	move.l a0,(a1)+
	move.l #2103,(a1)+
	move handle,(a1)
	VDI
	rts

	SAUT
vs_crop:
	V1 5,0,6,2104

	SAUT
vq_image_type:
	move.l (a6)+,ptsin		; adresse bit-image
	move.l (a6)+,a0			; nom fichier
	lea intin,a1
	move.l a0,d0
	moveq #0,d1
.lb0:
	move.b (a0)+,d1
	move d1,(a1)+
	bne.s .lb0
	sub.l d0,a0					; taille chaine
	lea control,a1
	move.l #$50001,(a1)+
	move.l a0,(a1)+
	move.l #2105,(a1)+
	move handle,(a1)
	VDI
	rts

nul_ch: dc.l 48	; c'est le z‚ro par d‚faut

	SAUT
nul_char:
	move.l (a6)+,nul_ch
	rts

; fonctions AES pour les dialogues en fenˆtres

wd_form_center: dc.l fc_cont,global,dum,fc_out,fc_addrin,dum
fc_cont: dc.w 54,0,5,1,0
	dc.b "LALA"
fc_addrin: dc.l 0
wc_in: dc.w 0
fc_out: dc.w 0,0,0,0,0,0,0,0,0
fc_out2: dc.w 0,0,0,0,0,0,0,0,0

wd_wind_calc: dc.l wca_cont,global,wc_in,fc_out2,dum,dum

wd_wind_set: dc.l ws_cont,global,wc_in,fc_out,dum,dum

wd_wind_get: dc.l wg_cont,global,wc_in,fc_out,dum,dum

wd_wind_create: dc.l wc_cont,global,fc_out,wc_in,dum,dum

wd_wind_open: dc.l wo_cont,global,fc_out,wc_in,dum,dum

wd_wind_close: dc.l wl_cont,global,wc_in,wc_in,dum,dum

wd_wind_delete: dc.l wd_cont,global,wc_in,wc_in,dum,dum

wd_form_dial: dc.l fd_cont,global,fc_out,wc_in,dum,dum
fd_cont: dc.w 51,9,1,0,0

wd_object_draw: dc.l od_cont,global,fc_out,wc_in,fc_addrin,dum
od_cont: dc.w 42,6,1,1,0

wd_objc_find: dc.l of_cont,global,fc_out,fc_out,fc_addrin,dum
of_cont: dc.w 43,4,1,1,0

wd_form_button: dc.l fb_cont,global,fc_out,fc_out,fc_addrin,dum
fb_cont: dc.w 56,2,2,1,0

wd_form_keybd: dc.l fk_cont,global,fc_out,fc_out2,fc_addrin,dum
fk_cont: dc.w 55,3,3,1,0

wd_objc_edit: dc.l oe_cont,global,fc_out,fc_out2,fc_addrin,dum
oe_cont: dc.w 46,4,2,1,0

wd_objc_change: dc.l oc_cont,global,fc_out,fc_out2,fc_addrin,dum
oc_cont: dc.w 47,8,1,1,0

wd_evnt_multi: dc.l wem_cont,global,event_in,0,fc_addrin,dum
wem_cont: dc.w 25,16,7,1,0
event_in: dc.w 19,2,1,1,0,0,0,0,0,0,0,0,0,0,0,0

	COPIE st,tim1
st: move.l #$fffa00,-(a6)
tim1: rts

	COPIE tt,tim2
tt: move.l #$fffa80,-(a6)
tim2: rts

   COPIE count,tim3
count: moveq #8,d1
	move.l d1,-(a6)
tim3:	rts

	SAUT
timera:
	moveq #0,d6
	bra.s _timer

	SAUT
timerb:
	moveq #1,d6
	bra.s _timer

	SAUT
timerc:
	moveq #2,d6
	bra.s _timer

	SAUT
timerd:
	moveq #3,d6

_timer:
	move.l (a6)+,d7		; auto ou software end of interrupt ou  timer stop
	cmp #2,d7
	beq .stop
	move.l (a6)+,d0		; fr‚quence voulue
	lea .dat_cont(pc),a0	; l… ou ranger data et control
	bsr data_control
	move.l (a6)+,d0		; delay (0) ou count (8)
	add.b d0,1(a0)			; ajoute le bit 3 si count
	clr.l -(sp)
	GEMDOS 32,6				; superviseur
	move.l d0,-(sp)		; pr‚pare le retour
	move sr,-(sp)			; conserve
	or #$700,sr				; plus d'interruptions

	move d6,d0
	muls #12,d0
	lea .table(pc,d0.w),a0	; donn‚es pour chaque timer
	move.l (a6)+,a3		; base des registres TT ou ST pour le MFP

	move.w (a0)+,d0		; offset enable/disable
	move.w (a0)+,d1		; num‚ro de bit
	bclr d1,0(a3,d0.w)	; invalide le timer
	bclr d1,12(a3,d0.w)
	lea .dat_cont,a1
	move.w (a0)+,d2		; offset data
	move.b (a1)+,0(a3,d2.w)
	move.w (a0)+,d2		; offset control
	cmp #2,d6
	bmi.s .ab
	move.b 0(a3,d2.w),d3	; ancienne valeur
	move.b (a1),d4			; le control … ajouter
	cmp #2,d6
	bne.s .d
	lsl.b #4,d4				; vers bits 4-6
	and.b #$F,d3			; garde bits 0-3
	bra.s .cd
.d:
	and.b #$F0,d3			; garde bits 4-7
.cd:
	or.b d4,d3
	move.b d3,0(a3,d2.w)	; nouveau control C ou D
	bra.s .suite
.ab:
	move.b (a1),0(a3,d2.w) ; control A ou B
.suite:
	move.l (a0)+,a1		; l'adresse de la routine
	cmp.l #$FFFA00,a3		; ST MFP?
	beq.s .stmfp
	add.w #$40,a1			; sinon d‚calage de $40 pour les adresses TT
.stmfp:
	move.l (a6)+,(a1)		; adresse de la routine
	tst d7					; sei ou aei
	beq.s .aei
	bset #3,$17(a3)		; soft end of inter
	bra.s .fin

.table: dc.w 7,5,$1f,$19
		  dc.l $134
		  dc.w 7,0,$21,$1b
		  dc.l $120
		  dc.w 9,5,$23,$1d
		  dc.l $114
		  dc.w 9,4,$25,$1d
		  dc.l $110
.aei:
	bclr #3,$17(a3)
.fin:
	bset d1,0(a3,d0.w)	; autorise l'interruption
	bset d1,12(a3,d0.w)
	move (sp)+,sr			; r‚cupŠre le registre d'‚tat
	GEMDOS 32,6				; mode utilisateur
	rts						; c'est parti mon kiki
.dat_cont: dc.b 0,0		; data et control
	; pour chaque timer: offset enable, nøbit, offset data, offset control
	; et pour finir adresse vecteur (st mfp)
	; 12 octets par timer


.stop:
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,-(sp)
	move sr,-(sp)
	or #$700,sr
	move d6,d0
	muls #12,d0
	lea .table(pc,d0.w),a0	; donn‚es pour chaque timer
	move.l (a6)+,a3		; base des registres TT ou ST pour le MFP
	move (a0)+,d0			; offset enable
	move (a0)+,d1			; nøbit
	bclr d1,0(a3,d0.w)	; disabled
	bclr d1,4(a3,d0.w)	; pending
	bclr d1,8(a3,d0.w)	; out service
	bclr d1,12(a3,d0.w)
	move (sp)+,sr
	GEMDOS 32,6
	rts

	SAUT
timer_calc:
	move.l (a6),d0
	move.l a6,a0
	bsr data_control
	moveq #0,d0
	moveq #0,d1
	move.b (a6),d0
	move.b 1(a6),d1
	move.l d0,(a6)
	move.l d1,-(a6)
	rts

	SAUT
solve:
	move.l (a6)+,d0
	move.l (a6)+,-(sp)
	move.l d0,-(sp)
	move.l (a6)+,-(sp)
	bsr get_function
	move.l a1,-(sp)
.encore:
	lea .petit(pc),a0		; 10^-4
	move.l (a0)+,-(a6)
	move.l (a0)+,-(a6)
	move.l 4(sp),a0		; x
	movem.l (a0),d0-d1
	tst.l d0
	bne.s .pasnul
	tst.l d1
	beq.s .xestnul			; si x est nul, h vaut 10^-4
.pasnul:
	movem.l d0-d1,-(a6)
	bsr ffois					; x*10^-4 = h
.xestnul:
	move.l (a6),-(sp)
	move.l 4(a6),-(sp)		; pile = h(inverse), *fonct, *x, epsilon
	move.l 12(sp),a0		; x
	move.l 4(a0),-(a6)
	move.l (a0),-(a6)
	move.l 4(a0),-(sp)
	move.l (a0),-(sp)		; pile = x, h, *fonct, *x, epsilon
	bsr fplus				; x+h
	move.l 20(sp),a0		; x
	move.l (a6)+,(a0)+
	move.l (a6),(a0)		; x=x+h
	move.l 16(sp),a0
	jsr (a0)					; f(x+h)
	bsr fneg
	move.l 20(sp),a0		; x
	move.l (sp)+,(a0)+
	move.l (sp)+,(a0)		; x redevient x, pile = h, *fonct, *x, epsilon
	move.l 8(sp),a0
	jsr (a0)					; f(x)
	bsr fswap				; fx -fx+h
	bsr fover				; fx -fx+h fx
	bsr fplus				; fx fx-fx+h
	move.l (sp)+,-(a6)
	move.l (sp)+,-(a6)	; h dans le bon ordre, pile = *fonct, *x, epsilon
	bsr fdiv					; fx -f'x
	bsr fdiv					; -fx/f'x
	bsr fdup
	move.l 4(sp),a0		; x
	move.l 4(a0),-(a6)
	move.l (a0),-(a6)
	bsr fplus				; x - fx/f'x, nouvel x
	move.l 4(sp),a0
	move.l (a6)+,(a0)+
	move.l (a6)+,(a0)+	; range dans x
	bclr #7,(a6)			; valeur absolue de dx
	movem.l (a6),d3-d4	; a conserver en cas de fin!
	lea 8(sp),a0
	move.l 4(a0),-(a6)
	move.l (a0),-(a6)		; epsilon
	bsr fsup
	tst.l (a6)+
	bne .encore
	lea 16(sp),sp			; vide tout
	movem.l d3-d4,-(a6)	; renvoit la precision
	rts
.petit: dc.l $eb1c432c,$3f1a36e2	; 10^-4 invers‚

get_function:
	move.l (a6)+,d0
	lea adresse,a1
	add.l d0,d0
	add.l d0,d0
	move.l 0(a1,d0.l),a1	; adresse fonction
	addq.l #2,a1			; saute code [ASS]
	rts

	SAUT
gauss:
	move.l (a6)+,-(sp)	; n
	bsr fover
	bsr fmoins				; b-a
	move.l (sp),-(a6)		; n entier
	bsr intfl				; n r‚el
	bsr fdiv					; h=(b-a)/n
	move.l (a6)+,-(sp)
	move.l (a6)+,-(sp)	; pile= h inv, n
	movem.l (a6)+,d0-d1	; a
	move.l (a6)+,a0		; pointeur sur x
	movem.l d0-d1,(a0)	; x=a
	move.l a0,-(sp)
	bsr.s get_function
	move.l a1,-(sp)		; pile = *f, *x, h inv, n
	clr.l -(sp)
	clr.l -(sp)				; l'int‚grale = 0, pile = S, *f, *x, h inv, n
	move.l 16(sp),-(a6)
	move.l 20(sp),-(a6)	; h
	lea .k3k2k1inverses(pc),a3	; inutilis‚ dans ffois
	move.l (a3)+,-(a6)
	move.l (a3)+,-(a6)
	bsr ffois				; h.k3
	move.l (a6)+,-(sp)
	move.l (a6)+,-(sp)
	move.l 24(sp),-(a6)
	move.l 28(sp),-(a6)	; h
	move.l (a3)+,-(a6)
	move.l (a3)+,-(a6)
	bsr ffois				; h.k2
	move.l (a6)+,-(sp)
	move.l (a6)+,-(sp)
	move.l 32(sp),-(a6)
	move.l 36(sp),-(a6)	; h
	move.l (a3)+,-(a6)
	move.l (a3)+,-(a6)
	bsr ffois				; h.k1
	move.l (a6)+,-(sp)
	move.l (a6)+,-(sp)	; pile = h.k1, hk2, hk3, S, *f, *x, h, n
.encore:
	subq.l #1,48(sp)		; decremente n
	bmi .terminus		; si n<0, integrale calculee
	moveq #16,d0			; k3
	moveq #0,d1				; m3
	bsr.s .un_point
	moveq #8,d0
	moveq #8,d1				; k2,m2
	bsr.s .un_point
	moveq #0,d0
	moveq #16,d1			; k1,m1
	bsr.s .un_point
	moveq #0,d0
	moveq #8,d1				; k1,m2
	bsr.s .un_point
	moveq #8,d0
	moveq #0,d1				; k2,m3
	bsr.s .un_point
	move.l 16(sp),-(a6)
	move.l 20(sp),-(a6)	; hk3
	move.l 36(sp),a0			; *x
	movem.l (a0),d0-d1
	movem.l d0-d1,-(a6)		; x
	bsr fplus					; x+k
	move.l 36(sp),a0			; *x
	move.l (a6)+,(a0)+
	move.l (a6)+,(a0)+		; x=x+k
	bra.s .encore
.un_point:
	lea .m3m2m1inverses(pc,d1.l),a0	; le bon m(1,2,3)
	move.l (a0)+,-(a6)
	move.l (a0)+,-(a6)		; sur la pile
	lea 4(sp,d0.l),a0			; le bon k
	move.l (a0)+,-(a6)
	move.l (a0)+,-(a6)		; sur la pile
	move.l 40(sp),a0			; *x
	movem.l (a0),d0-d1
	movem.l d0-d1,-(a6)		; x
	bsr fplus					; x+k
	move.l 40(sp),a0
	move.l (a6)+,(a0)+
	move.l (a6)+,(a0)+		; x=x+k
	move.l 36(sp),a0			; *f
	jsr (a0)
	bsr ffois					; f(x)*m
	lea 28(sp),a0				; pointeur sur S
	movem.l (a0),d0-d1
	movem.l d0-d1,-(a6)
	bsr fplus					; S+f(x)*m
	lea 28(sp),a0
	move.l (a6)+,(a0)+
	move.l (a6)+,(a0)+		; S=S+f(x)*m
	rts
.terminus:
	lea 24(sp),sp				; vire les hk
	movem.l (sp)+,d0-d1		; S
	movem.l d0-d1,-(a6)		; sur la pile
	addq.l #8,sp				; saute *f et *x
	move.l (sp)+,-(a6)
	move.l (sp)+,-(a6)		; h sur la pile
	bsr ffois					; Integrale = h*S
	addq.l #4,sp				; vire n
	rts
.k3k2k1inverses: dc.l $fd662cb0,$3fa80498
	dc.l $c57306ca,$3fc78891
	dc.l $fd99b705,$3fd13b23
.m3m2m1inverses: dc.l $c36e038c,$3fbe539e
	dc.l $25ae415b,$3fcea1da
	dc.l $789abcdf,$3fd23456

	if 0
; 'fonc a b epsilon maximum

	SAUT
maximum:
minimum:
	bsr fsurr					; conserve epsilon
	bsr fover					; ramŠne a
	bsr fmoins					; b-a
;	moveq #-2,-(a6)
;	bsr ffois2n					; h = (b-a)/4
	bsr fswap					; a devant et h dessous
	bsr fover					; ramŠne h
	bsr fplus					; x = a+h
	move.l 16(a6),-(a6)		; num‚ro de fonction
	bsr get_function			; a1 = adresse fonction
	move.l a1,16(a6)			; stock‚
	bsr rsurf					; ramŠne epsilon
	lea -24(a6),a6
	move.l a6,a0				; a0 = quarter
	lea 8(a6),a1				; a1 = middle
	lea 16(a6),a2				; a2 = temp
	; 24(a6)=epsilon  32(a6)=x   40(a6)=h   48(a6)=adresse fonction
	movem.l a0-a2,-(sp)
	lea 36+4(a6),a0		; x
	lea 40+4(a6),a1		; h
	move.l (a0),-(a6)
	move.l -(a0),-(a6)	; x
	move.l (a1),-(a6)
	move.l -(a1),-(a6)	; h
	bsr fplus				; x+h
	move.l 48+8(a6),a0	; adresse fonc
	jsr (a0)					; f(x+h)
	movem.l (sp)+,a0-a2
	move.l (a6)+,(a1)
	move.l (a6)+,4(a1)	; middle = f(x+h)
.again:
	lea 36+4(a6),a3		; x
	move.l (a3),-(a6)
	move.l -(a3),-(a6)
	move.l 48+8(a6),a3
	movem.l a0-a2,-(sp)
	jsr (a3)					; f(x)
	movem.l (sp)+,a0-a2
	move.l (a6),(a0)
	move.l 4(a6),4(a0)	; quarter = f(x)
	movem.l a0-a2,-(sp)
	lea 36+8+4(a6),a0	; x
	lea 40+8+4(a6),a1	; h
	move.l (a0),-(a6)
	move.l -(a0),-(a6)	; x
	move.l (a1),-(a6)
	move.l -(a1),-(a6)	; h
	bsr fplus				; x+h
	movem.l (sp)+,a0-a2
	lea 36+16(a6),a3
	move.l (a6)+,(a3)+
	move.l (a6)+,(a3)		; x=x+h
	exg.l a0,a1				; echange quarter et middle
	move.l 4(a0),-(a6)
	move.l (a0),-(a6)
	bsr fsup
	tst.l (a6)+
;	bne .x=x-h
	movem.l a0-a2,-(sp)
	lea 36+4(a6),a0		; x
	lea 40+4(a6),a1		; h
	move.l (a0),-(a6)
	move.l -(a0),-(a6)	; x
	move.l (a1),-(a6)
	move.l -(a1),-(a6)	; h
	bsr fplus				; x+h
	move.l 48+8(a6),a0	; adresse fonc
	jsr (a0)					; f(x+h)
	movem.l (sp)+,a0-a2

	endif

; renvoit 0 (ok) et la version en dessous
; renvoit n‚gatif sinon et pas de version

	SAUT
sc_check:
	move.l    #-1,-(sp)
   move.w    #36,-(sp)           ; Get Trap 4 Vektor
   BIOS 5,8
   move.l    d0,a0               ; trap 4 vector in d0 and a0
   cmp.l     #'XBRA',-12(a0)     ; Check XBRA ID
   bne.s       .not_inst
   cmp.l     #'SCTB',-8(a0)      ; Check SCTB ID
   bne.s       .not_inst
   move.l    -16(a0),-(a6)       ; Version Number
   moveq     #0,d0               ; Result Code
	bra.s .exit
.not_inst:
   moveq     #-1,d0              ; Result Code -1
.exit:
   move.l d0,-(a6)
   rts

	; " chemin\tool_box.bin" SC_load : installe les routines sur trap#4
	; renvoit 0: tout est ok
	; n‚gatif<-32: erreur GEMDOS (m‚moire insufisante ou fichier introuvable)
	; -32<negatif<0: erreur TOOLBOX

	SAUT
sc_load:
	move.l (a6)+,a3	; filename
	tst.l _sc_adr
	beq.s .lb0
	moveq #-12,d0			; fichier d‚j… charg‚
.exit:
	move.l d0,-(a6)
	rts
.lb0:
	move.l #18000,d0	; size
	tst.b is_mxal
	bne.s .lb1
	move.l d0,-(sp)
	GEMDOS 72,6			; old Gemdos, only ST Ram exists
	bra.s .lb2
.lb1:
	clr -(sp)			; new TOS,force ST RAM
	move.l d0,-(sp)
	GEMDOS 68,8
.lb2:
	tst.l d0
	bmi.s .exit			; erreur d'allocation
	move.l d0,_sc_adr	; sinon, sauve l'adresse
	clr -(sp)
	move.l a3,-(sp)	; file name
	move #$3d,-(sp)		; FOPEN, ouvre le fichier
	trap #1
	addq.l #8,sp

	move d0,d7
	bmi.s .exit			; erreur d'ouverture

	move.l _sc_adr(pc),-(sp)	; adresse
	move.l #18000,-(sp)	; taille maxi
	move d7,-(sp)
	move #$3f,-(sp)		; FREAD avec un maxi de D3 octets
	trap #1
	add.w #12,sp

	move d7,-(sp)
	move #$3E,-(sp)		; FCLOSE, referme le fichier lu
	trap #1
	addq.l #4,sp

	move.l _sc_adr(pc),a0
	move #-1,2(a0)		; ID fonction INSTALLE
	jsr (a0)				; ex‚cution
	move.l _sc_adr(pc),a0
	move.l 18(a0),d0	; valeur retourn‚e
	bra.s .exit

   COPIE sc_adr,y999,1
sc_adr: move.l _sc_adr,-(a6)
y999: rts
_sc_adr:	dc.l 0			; par d‚faut, rien de charg‚

	; renvoit 0 tout est ok
	; positif, erreur TOOLBOX

	SAUT
sc_unload:
	move.l _sc_adr(pc),d0
	bne.s .ok
	moveq #-1,d0		; erreur, rien de charg‚! routines absentes
.exit:
	move.l d0,-(a6)
	rts
.ok:
	move.l d0,a0
	move #-2,2(a0)		; ID fonction d‚sinstalle trap#4
	jsr (a0)
	move.l 18(a0),d0	; code retour
	bmi.s .exit
	move.l _sc_adr(pc),-(sp)
	GEMDOS 73,6			; free memory
	moveq #0,d0
	move.l d0,_sc_adr	; efface adresse m‚moire
	move.l d0,-(a6)	; renvoit 0: ok
	rts

; n SC_dma : fixe le numero de DMA du Supercharger
; d‚faut = 3

DMA: dc.w 3

	SAUT
sc_dma:
	move.l (a6)+,d0
	move d0,DMA
	rts

; pas de paramŠtre
; renvoit l'‚tat de la toolbox

	SAUT
sc_status:
	moveq #2,d0
	bra.s _sc_comm


; pas de paramŠtre
;	lance le mode esclave cot‚ Supercharger

	SAUT
sc_boot:
   moveq #3,d0
	bra.s _sc_comm

; srcatari destpc size sc_sendm (mode esclave)
; envoit size octets (max 64k) depuis srcatari vers destpc

	SAUT
sc_sendm:
   move.l (a6)+,d2
   move.l (a6)+,d3
   move.l (a6)+,a0
   moveq #6,d0
	bra.s _sc_comm

; srcpc destatari size sc_getm (mode esclave)
; recoit size octets (max 64k) de srcpc vers destatari

	SAUT
sc_getm:
   move.l (a6)+,d2
   move.l (a6)+,a0
   move.l (a6)+,d3
   moveq #7,d0
_sc_comm:				; comon end for routines
	move DMA(pc),d1
   trap #4
   move.l d0,-(a6)
   rts

; adrpc sc_exec (passe du mode esclave … coop‚ratif)
; ex‚cute le programme PC … l'adresse adrpc
; c'est le PC qui choisit quand il revient en mode esclave

	SAUT
sc_exec:
   move.l (a6)+,d3
   moveq #8,d0
	bra.s _sc_comm

; n sc_xsendb (mode coop‚ratif)
; envoie un octet au PC

	SAUT
sc_xsendb:
   move.l (a6)+,d2
   moveq #9,d0
	bra.s _sc_comm

; sc_xgetb (mode coop‚ratif)
; re‡oit un octet du PC

	SAUT
sc_xgetb:
	move DMA(pc),d1
   moveq #10,d0
   trap #4
   ext.w d2
   ext.l d2
   move.l d2,-(a6)
   move.l d0,-(a6)
   rts

; srcatari size sc_xsendm (mode coop‚ratif)
; envoie size octets (max 64k) depuis srcatari

	SAUT
sc_xsendm:
	move.l (a6)+,d2
	moveq #4,d0
	move.l (a6)+,a0
	bra.s _sc_comm

; destatari size sc_xgetm (mode coop‚ratif)
; re‡oit size octets (max 64k) vers destatari

	SAUT
sc_xgetm:
	move.l (a6)+,d2
	moveq #5,d0
	move.l (a6)+,a0
	bra.s _sc_comm

	end

detect_aes:
   lea global,a0
   moveq #0,d0
   move (a0),d1
   cmp #$400,d1
   bmi.s .finaes					; AES<4.00, donc pas d'autre appel
	GEM_AES _appl_getinfo
	lea addrin,a0
	move.l (a0),a0					; adresse de l'identifiant
	cmp.l #$400,a0
	bmi.s .finaes					; pas l'air d'etre une adresse valide
	moveq #1,d0
	movem.l (a0)+,d1-d2
	cmp.l #'   X',d1
	bne.s .autreaes
	cmp.l #'aAES',d2
	beq.s .finaes
.rate:
	moveq #0,d0
	bra.s .finaes
.autreaes:
	moveq #2,d0
	cmp.l #'   M',d1
	bne.s .rate
	cmp.l #'yAES',d2
	bne.s .rate
.finaes:
	move.l d0,global+32
	rts

   END
