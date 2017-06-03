*--------------------------------------------------------------------------*
;	MACROS CUSTOM GEN & WAX

save:		macro
		ifc '\0','W'
		fail ; l'extension en minuscule
			endc
		ifc '\0','L'
		fail ; l'extension en minuscule
		endc
		ifeq \?1-2
		move.\0 \1,-(sp)
		else
		movem.\0 \1,-(sp)
		endc
		endm

load:		macro
		ifc '\0','W'
		fail ; l'extension en minuscule
			endc
		ifc '\0','L'
		fail ; l'extension en minuscule
		endc
		ifeq \?1-2
		move.\0 (sp)+,\1
		else
		movem.\0 (sp)+,\1
		endc
		endm

appel:		macro
		move.w #\2,-(sp)
		trap #\1
		ifle \3-8
		addq.l #\3,sp
		else
		add.l #\3,sp
		endc
		endm

SYNCHRO_GEM:	macro
\@wait_nul:		appel dos,$0b,2	; teste du buffer ...
		tst.w d0
		beq.s \@the_end	; pas de touche en buffer ?
		CRAWCIN
		bra.s \@wait_nul
\@the_end:		VSYNC
		endm

RESOLUT:		macro		; \1=vid‚o mode,\2=0:ST / \2=3:FALC
		move.w \1,-(sp)
		move.w \2,-(sp)
		move.l \3,-(sp)
		move.l \4,-(sp)
		appel xbios,5,14
		VSYNC
		endm

MOUSEOFF:		macro
		pea inhibe
		move.w #1-1,-(sp)
		appel xbios,25,8
		DATA
inhibe:		dc.b $12
		even
		TEXT
		endm

MOUSEON:		macro
		pea default
		move.w #2-1,-(sp)
		appel xbios,25,8
		endm
		DATA
default:		dc.b $80,$01
		TEXT

FILE_OPEN:		macro		; \1=read/write \2=name \3=destination pour le handle
		ifeq \1-1		; 0=lecture,other=write
		clr.w -(sp)
		pea \2
		appel dos,$3c,8	; file create
		move d0,\3
		endc
		ifeq \1
		clr.w -(sp)
		pea \2
		appel dos,$3d,8	; file open
		move d0,\3
		endc
		ifeq \1-2
		move.w #2,-(sp)
		pea \2
		appel dos,$3d,8
		move d0,\3
		endc
		endm

RESERVE_SCREENS:	macro nb_ecrans,resolut
		; + x_max_p,y_max_p,nb_bits_per_pix
		move.l #screens,d0
		and.l #$ffffff00,d0
		add.l #$100,d0
		move.l d0,a0
		lea ecrans,a1

		move #\1-1,d0
.raz_screens:	move.l a0,(a1)+
		move.l #x_max_p*y_max_p*nb_bits_per_pix/8/4,d1
.raz_screen:	clr.l (a0)+
		subq.l #1,d1
		bne.s .raz_screen
		dbf d0,.raz_screens

		move.l ecran,save_ad_ecr
		RESOLUT #-1
		and #$1ff,d0
		move d0,save_mode

		move #\2,d1
		btst #5,d0
		bne.s .pal_modus
		bclr #5,d1

.pal_modus:		btst #4,d0		; tv
		bne.s .vga_modus
		bclr #4,d1		; tv
		bchg #8,d1		; vertical mode
.vga_modus:
		ifne (\2-res32020016)
		RESOLUT d1,#3,ecrans,ecrans
		else
		RESOLUT d1,#0,ecrans,ecrans
		endc

 BSS
save_mode:		ds.w 1
save_ad_ecr:	ds.l 1
ecrans:		ds.l \1
screens:		ds.l \1*x_max_p*y_max_p*nb_bits_per_pix/8/4
		ds.b 256
 TEXT
		endm

CHANGE_RESOLUT:	macro resolut
		move.l ecrans,a0
		move.l #x_max_p*y_max_p*nb_bits_per_pix/8/4,d1
.raz_screen:	clr.l (a0)+
		subq.l #1,d1
		bne.s .raz_screen

		move.l ecran,save_ad_ecr
		RESOLUT #-1
		and #$1ff,d0
		move d0,save_mode

		move #\1,d1
		btst #5,d0
		bne.s .pal_modus
		bclr #5,d1

.pal_modus:		btst #4,d0		; tv
		bne.s .vga_modus
		bclr #4,d1		; tv
		bchg #8,d1		; vertical mode
.vga_modus:
		ifne (\1-res32020016)
		RESOLUT d1,#3,ecrans,ecrans
		else
		RESOLUT d1,#0,ecrans,ecrans
		endc

		endm

RESTORE_SCREENS:	macro
		RESOLUT save_mode,#3,save_ad_ecr,save_ad_ecr
		endm


COLOR256:		macro
		ifnd FLG_INIBE_COLOR
		move.l \1,palette256
		endc
		endm

COLOR:		macro
		ifnd FLG_INIBE_COLOR
		move.w \1,palette
		endc
		endm

ZILOGR:		macro registre,byte,canal
		ifc 'A','\3'
		move.b \1,zilog8530A
		move.b zilog8530A,\2
		else
		move.b \1,zilog8530B
		move.b zilog8530B,\2
		endc
		endm

ZILOGW:		macro registre,byte,canal
		ifc 'A','\3'
		move.b \1,zilog8530A
		move.b \2,zilog8530A
		else
		move.b \1,zilog8530B
		move.b \2,zilog8530B
		endc
		endm

COPY_STRING:	macro	; (\1) source, (\2) dest, d0.b end char
.\@ccp:		move.b (\1)+,(\2)+
		cmp.b -1(\1),d0
		bne.s .\@ccp
		endm

COPY_STRING_0:	macro	; (\1) source, (\2) dest
.\@ccp:		move.b (\1)+,(\2)+
		bne.s .\@ccp
		endm

*--------------------------------------------------------------------------*
;	MACROS SYSTEME

CRAWCIN:		macro
		appel dos,7,2
		endm

SUPEXEC:		macro
		pea \1
		appel xbios,38,6
		endm

VSYNC:		macro
		appel xbios,$25,2
		endm

VSETMODE:		macro mode
		move.w \1,-(sp)
		appel xbios,88,4
		endm

CCONWS:		macro string
		pea \1
		appel dos,9,6
		endm

FATTRIB:		macro attr,flag,fname
		move.w \1,-(sp)
		move.w \2,-(sp)
		pea \3
		appel dos,$43,10
		endm

FDELETE:		macro fname
		pea \1
		appel dos,$41,6
		endm

FREAD:		macro buf,length,handle
		move.l \1,-(sp)
		move.l \2,-(sp)
		move.w \3,-(sp)
		appel dos,$3f,12
		endm

FWRITE:		macro buf,count,handle
		move.l \1,-(sp)
		move.l \2,-(sp)
		move.w \3,-(sp)
		appel dos,$40,12
		endm

FSEEK:		macro mode,handle,offset
		; mode = begining (0), current (1) end (2)
		move.w \1,-(sp)
		move.w \2,-(sp)
		move.l \3,-(sp)
		appel dos,$42,10
		endm

FCLOSE:		macro handle
		move.w \1,-(sp)
		appel dos,$3e,4
		endm

FSFIRST:		macro attribs,fspec
		move.w \1,-(sp)
		pea \2
		appel dos,$4e,8
		endm

FSNEXT:		macro
		appel dos,$4f,2
		endm

DGETDRV:		macro
		appel dos,$19,2
		endm

DSETDRV:		macro drive
		move \1,-(sp)
		appel dos,$e,4
		endm

DGETPATH:		macro drive,buf
		move.w \1,-(sp)
		pea \2
		appel dos,$47,8
		endm

DSETPATH:		macro path
		pea \1
		appel dos,$3b,6
		endm

FSETDTA:		macro ndta
		pea \1
		appel dos,$1a,6
		endm

FGETDTA:		macro
		appel dos,$2f,2
		endm

MALLOC:		macro amount
		move.l \1,-(sp)
		appel dos,$48,6
		endm

MXALLOC:		macro mode,amount (RAM_ST, RAM_TT, RAM_ST_TT, RAM_TT_ST)
		move.w \1,-(sp)
		move.l \2,-(sp)
		appel dos,$44,8
		endm

MFREE:		macro startadr
		move.l \1,-(sp)
		appel dos,$49,6
		endm

*--------------------------------------------------------------------------*
;	MACROS SEMI-SYSTEME

SUPER:		macro mode		; 0=go super ; 1=get current mode
		move.l #\1,-(sp)
		appel dos,$20,6
		ifne \1-1
		move.l d0,GWVA_OLD_SUPERVISOR_STACK
		endc
		endm

USER:		macro
		move.l GWVA_OLD_SUPERVISOR_STACK,-(sp)
		appel dos,$20,6
		endm

