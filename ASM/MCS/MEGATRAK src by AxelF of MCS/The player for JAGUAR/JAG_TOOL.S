**************** Load a GPU program into GPU RAM
*
*  ->	a0.L = address of GPU program
*	a1.L = destination address
*	d0.L = size of program in byte
*

gpuload:	movem.l	d1/a2,-(sp)
		move.l	#B_CMD,a2
.waitblit:	move.l	(a2),d1			; Wait for BLITTER Idle
		btst	#0,d1
		beq.s	.waitblit
		bsr.s	gpuwait
		move.l	#PITCH1|PIXEL16|WID256|XADDPHR,d1
		move.l	d1,A2_FLAGS
		move.l	d1,A1_FLAGS
		move.l	a0,A2_BASE		; Source
		move.l	a1,A1_BASE		; Destination
		asr.l	#1,d0			; Convert to words for inner loop
		or.l	#$10000,d0	
		move.l	d0,B_COUNT		; Set 1 outer loop
		moveq	#0,d0
		move.l	d0,A1_PIXEL		; Set the pixel pointer
		move.l	d0,A2_PIXEL
		move.l	#SRCEN|LFU_REPLACE,d0	; Destination=Source
		move.l	d0,(a2)			; Blitter go... 
.waitblit2:	move.l	(a2),d1			; Wait for BLTTER Idle
		lsr.w	#1,d1
		bcc.s	.waitblit2
		movem.l	(sp)+,d1/a2
		rts

*************** Wait for the GPU to finish executing

gpuwait:	movem.l	d0/a0,-(sp)
		lea	G_CTRL,a0
.gpuwt:		move.l	(a0),d0			; wait for GPU to finish
		asr.w	#1,d0
		bcs.s	.gpuwt
		movem.l	(sp)+,d0/a0
		rts


*************** Tell the GPU to begin execution
*
*  ->	a0 = Start address of GPU program
*

gpurun:		move.l	a0,G_PC
		move.l	#RISCGO,G_CTRL		; Turn on the GPU
		rts



**************** set up the VI (Vertical Interrupt)
*
*  ->	a0 = address vertical interrupt routine
*

vblinit:	move.l	a0,LEVEL0.w
		move.w	a_vde(pc),d0
		or.w	#1,d0
		move.w  d0,VI
		ori.w	#1,INT1
		and.w   #$f8ff,sr	; mask all interrupts
		rts
		

**************** Initialize Video to 320x(256|200)

vidinit:	move.w	CONFIG,d0	
		and.w	#VIDTYPE,d0	; 0 = PAL, 1 = NTSC
		beq.s	palvals
		move.w	#NTSC_HMID,d2
		move.w	#NTSC_WIDTH,d0
		move.w	#NTSC_HEIGHT,d4
		move.w	#NTSC_VMID,d6
		bra.s	calc_vals
palvals:	move.w	#PAL_HMID,d2
		move.w	#PAL_WIDTH,d0
		move.w	#PAL_HEIGHT,d4
		move.w	#PAL_VMID,d6
calc_vals:	move.w	d0,vid_width
		move.w	d4,vid_height
		move.w	d0,d1
		asr.w	#1,d1		; Width/2
		sub.w	d1,d2		; Mid - Width/2
		addq.w	#4,d2		; (Mid - Width/2)+4
		subq.w	#1,d1		; Width/2 - 1
		or.w	#$400,d1	; (Width/2 - 1)|$400
		move.w	d1,a_hde
		move.w	d1,HDE
		move.w	d2,a_hdb
		move.w	d2,HDB1
		move.w	d2,HDB2
		move.w	d6,d5
		sub.w	d4,d5
		move.w	d5,a_vdb
		add.w	d4,d6
		move.w	d6,a_vde
		move.w	a_vdb,VDB
		move.w	#-1,VDE
		move.l	#0,BORD1	; Black border
		move.w	#0,BG		; Init line buffer to black
		rts

a_hdb:		dc.w 0
a_hde:		dc.w 0
a_vdb:		dc.w 0 
a_vde:		dc.w 0
vid_width:	dc.w 0
vid_height:	dc.w 0



**************** Generateur d'object-list (v3)
*
*   ->	a0 : Structures d‚finissant les objets
*	a1 : Adresse o— doit etre gener‚e l'object-list   
*	a2 : Liste des adresses des objets 
*


Lister:		movem.l	d0-d7/a0-a6,-(sp)
		movea.l	a0,a3			; a3 = script
		move.l	a1,d0
		and.l	#31,d0
		beq.s	.ok_quad
		move.l	a1,d0
		and.l	#$ffffffe0,d0
		add.l	#32,d0
		move.l	d0,a1
.ok_quad:	move.l	a1,a4			; a4 = objets
		move.l	a2,a5			; a5 = adr objets

;  premiŠre passe : 	construction complŠte de la liste avec la taille 
;			de chaque structure.

.prems:		move.l	(a3),a6
		move.l	a6,(a5)+	
		cmp.l	#-1,a6
		beq	seconde_passe		; fin de la liste ?

		move.w	o_id(a6),d0		; lecture TYPE
		moveq.l	#0,d1			; Long de poids fort de la Phrase
		moveq.l	#0,d2			; Long de poids faible de la Phrase

		cmpi.b	#BRANCHOBJ,d0
		bne.s	.pasbranch
		move.b	d0,d1			; écriture TYPE
		move.w	obr_ypos(a6),d0		; lecture YPOS
		andi.l	#$7FF,d0
		lsl.l	#3,d0			; aligne 3ème bit
		or.l	d0,d1			; écriture YPOS
		or.l	obr_cc(a6),d1		; lecture CC
		move.l	a4,(a3)+		; écriture adresse réelle
		move.l	d2,(a4)+		; écriture dans la structure hi
		move.l	d1,(a4)+		; lo
		bra.s	.prems			; BRANCHOBJ complet

.pasbranch:	cmpi.b	#GPUOBJ,d0
		bne.s	.pasgpu
		move.b	d0,d1			; écriture TYPE
		move.l	ogpu_data_l0(a6),d0
		swap	d0
		andi.w	#$FFF8,d0		; coupe les 3 bits faibles
		or.l	d0,d1			; écriture DATA lo
		move.l	a4,(a3)+		; écriture adresse réelle
		move.l	ogpu_data_hi(a6),d0	; lecture de DATA hi
		swap	d0			; échange pour lecture directe OB2
		move.l	d0,(a4)+		; écriture dans la structure DATA hi
		move.l	d1,(a4)+		; lo
		bra.s	.prems

.pasgpu:	cmpi.b	#STOPOBJ,d0
		bne.s	.passtop
		move.b	d0,d1			; écriture TYPE
		move.w	ost_flag(a6),d0		; lecture INTFLAG 
		or.w	d0,d1			; écriture INTFLAG
		move.l	ost_data_lo(a6),d0	; lecture DATA lo
		andi.l	#$FFFFFFF0,d0		; coupe les 4 bits faibles
		or.l	d0,d1			; écriture DATA lo
		move.l	a4,(a3)+		; écriture adresse r‚elle
		move.l	ost_data_hi(a6),(a4)+	; écriture dans la structure DATA hi
		move.l	d1,(a4)+		; lo
		bra	.prems

.passtop:	move.b	d0,d1			; alors c'est BITOBJ ou SCBITOBJ	
		cmpi.b	#SCBITOBJ,d0
		beq.s	.alig32B
		st	d3
		move.l	a4,d4
		andi.l	#15,d4			; déjà align‚ sur 16 octets ?
		beq.s	.premiere_phrase
		bra.s	.insert_nop
.alig32B:	sf	d3
		move.l	a4,d4
		andi.l	#31,d4			; déjà align‚ sur 32 octets ?
		beq.s	.premiere_phrase
.insert_nop:	lsr.l	#3,d4
		subq.w	#1,d4
.next:		move.l	#O_BRLT|($7ff<<3)|BRANCHOBJ,d2
		move.l	#0,0(a4)		; écriture dans la structure hi
		move.l	d2,4(a4)		; lo
		move.l	a4,d2
		addq.l	#8,d2
		lsr.l	#3,d2			
		andi.l	#$7FFFF,d2		; LINK convertie en phrase
		ror.l	#8,d2
		or.w	d2,2(a4)		; Champ LINK bit 32 à 42
		swap	d2
		or.w	d2,4(a4)		; Champ LINK bit 24 à 31
		addq.l	#8,a4
		dbf	d4,.next
		moveq	#0,d2
.premiere_phrase:move.w	obt_ypos(a6),d0		; lecture YPOS
		andi.l	#$7FF,d0
		lsl.l	#3,d0			; aligne 3éme bit
		or.l	d0,d1			; écriture YPOS
		move.w	obt_height(a6),d0	; lecture HEIGHT
		andi.l	#$3FF,d0
		swap	d0
		lsr.l	#2,d0			; aligne 14ème bit
		or.l	d0,d1			; écriture HEIGHT
		move.l	obt_data(a6),d0		; lecture DATA
		lsl.l	#11-3,d0		; alignement 43ème bit
		or.l	d0,d2
		move.l	a4,(a3)+		; écriture adresse réelle
		move.l	d2,(a4)+		; écriture dans la structure hi
		move.l	d1,(a4)+		; lo
.seconde_phrase:move.l	obt_depth(a6),d1	; lecture écriture DEPTH|PITCH
		move.l	obt_flags(a6),d2	; lecture écriture flags
		move.w	obt_xpos(a6),d0		; lecture XPOS
		andi.l	#$FFF,d0
		or.w	d0,d1			; écriture XPOS
		move.w	obt_dwidth(a6),d0	; lecture DWIDTH
		;lsr.w	#2,d0			; valeur en phrase
		andi.l	#$3FF,d0
		swap	d0
		lsl.l	#2,d0			; aligne 18ème bit
		or.l	d0,d1			; écriture DWIDTH
		move.w	obt_firstpix(a6),d0	; lecture FIRSTPIX
		andi.l	#$3F,d0
		swap	d0
		lsl.l	#1,d0			; aligne 49ème bit
		or.l	d0,d2			; écriture FIRSTPIX
		move.w	obt_iwidth(a6),d0	; lecture IWIDTH
		;lsr.w	#2,d0			; valeur en phrase
		andi.l	#$3FF,d0
		ror.l	#4,d0
		or.w	d0,d2
		and.l	#$f0000000,d0
		or.l	d0,d1
		move.l	d2,(a4)+		; écriture dans la structure hi
		move.l	d1,(a4)+		; lo
		tst.b	d3			; y-a-t-il une troisième phrase ?
		bne	.prems
		moveq.l	#0,d0
		move.l	d0,(a4)+		; efface la structure hi
		move.w	obt_vscale(a6),d0	; lecture de HSCALE et VSCALE
		move.l	d0,(a4)+		; lo
		bra	.prems

fin_passe:	movem.l	(sp)+,d0-d7/a0-a6
		rts

; edition des LINKs et des adresses.

seconde_passe:	
.pass:		move.l	(a0)+,a3		; adr objet actuel 
		move.l	(a2)+,d0
		bmi.s	fin_passe
		move.l	d0,a1
		move.w	o_id(a1),d0
		cmpi.b	#STOPOBJ,d0		; 
		beq.s	.pass			; \
		cmpi.b	#GPUOBJ,d0		;  > pas de champ LINK
		beq.s	.pass			; /
		cmpi.b	#BRANCHOBJ,d0
		bne.s 	.bitmap
		moveq	#8,d2
		move.l	obr_link(a1),d0
		bra.s	.link
.bitmap:	moveq	#8*2,d2
		cmpi.b	#BITOBJ,d0
		beq.s	.ok
		moveq	#8*3,d2
.ok:		move.l	obt_link(a1),d0		; d0 = label
.link:		bne.s	.label
		move.l	a3,d0
		add.l	d2,d0
		bra.s	.sset
.label:		move.l	d0,a1
		move.l	(a1),d0			; a1 = adr de l'objet
.sset:		and.w	#~$7ff,2(a3)	
		and.w	#~$ff00,4(a3)
		lsr.l	#3,d0			
		andi.l	#$7FFFF,d0		; LINK convertie en phrase
		ror.l	#8,d0
		or.w	d0,2(a3)		; Champ LINK bit 32 … 42
		swap	d0
		or.w	d0,4(a3)		; Champ LINK bit 24 … 31
		bra.s	.pass

