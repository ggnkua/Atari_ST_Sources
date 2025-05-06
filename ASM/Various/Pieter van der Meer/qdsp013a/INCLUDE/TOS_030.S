*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*                                                                         *
*           Macros d'appel des fonctions Gemdos, Bios et Xbios            *
*                          Version TOS 4.02                               *
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷(C)oderight NulloS//DNT 1990-94*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
* Macros d‚finies: Gemdos / Bios / Xbios
*
* Mode d'appel:
*	_Empiler les paramŠtres :   pea     message(pc)
*	_Appel de fonction      :   Gemdos  Cconws
* La pile est corrig‚e par la macro.
*
* Si appel par  Gemdos -Cconws alors la pile n'est pas corrig‚e.
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷>GEMDOS      ÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;Dans l'ordre: $ssnn
;ss=correction de pile
;nn=No de fonction
;
Pterm0	equ	$0000
Cconin	equ	$0201
Cconout	equ	$0402
Cauxin	equ	$0203
Cauxout	equ	$0404
Cprnout	equ	$0405
Crawio	equ	$0406
Crawcin	equ	$0207
Cnecin	equ	$0208
Cconws	equ	$0609
Cconrs	equ	$060a
Cconis	equ	$020b
Dsetdrv	equ	$040e
Cconos	equ	$0210
Cprnos	equ	$0211
Cauxis	equ	$0212
Cauxos	equ	$0213
Maddalt	equ	$0a14
Srealloc	equ	$0615
Dgetdrv	equ	$0219
Fsetdta	equ	$061a
Super	equ	$0620
Tgetdate	equ	$022a
Tsetdate	equ	$042b
Tgettime	equ	$022c
Tsettime	equ	$042d
Fgetdta	equ	$022f
Sversion	equ	$0230
Ptermres	equ	$0031
Dfree	equ	$0836
Dcreate	equ	$0639
Ddelete	equ	$063a
Dsetpath	equ	$063b
Fcreate	equ	$083c
Fopen	equ	$083d
Fclose	equ	$043e
Fread	equ	$0c3f
Fwrite	equ	$0c40
Fdelete	equ	$0641
Fseek	equ	$0a42
Fattrib	equ	$0a43
Mxalloc	equ	$0844
Fdup	equ	$0445
Fforce	equ	$0646
Dgetpath	equ	$0847
Malloc	equ	$0648
Mfree	equ	$0649
Mshrink	equ	$0c4a
Pexec	equ	$104b
Pterm	equ	$004c
Fsfirst	equ	$084e
Fsnext	equ	$024f
Frename	equ	$0c56
Fdatime	equ	$0a57

Gemdos	MACRO
	IFGE	\1
	 IFNE	\1
	  move.w	#\1&$ff,-(sp)
	  trap	#1
	  IFNE	\1&$ff00
	   IFEQ	(\1-$100)&$f800
	    addq.l	#\1>>8,sp
	   ELSE
	    lea	\1>>8(sp),sp
	   ENDC
	  ENDC
	 ELSE
	  clr.w	(sp)
	  trap	#1
	 ENDC
	ELSE
	 move.w	#(-(\1))&$ff,-(sp)
	 trap	#1
	ENDC
	ENDM

	rsreset		;structure de la page de base
p_lowtpa	rs.l	1
p_hitpa	rs.l	1
p_tbase	rs.l	1
p_tlen	rs.l	1
p_dbase	rs.l	1
p_dlen	rs.l	1
p_bbase	rs.l	1
p_blen	rs.l	1
p_dta	rs.l	1
p_parent	rs.l	1
	rs.l	1
p_env	rs.l	1
p_hstdin	rs.b	1
p_hstdout	rs.b	1
p_haux	rs.b	1
p_hprn	rs.b	1
	rs.b	3
p_drive	rs.b	1
	rs.b	8
	rs.b	40
p_saveD0	rs.l	1
p_saveA3	rs.l	1
p_saveA4	rs.l	1
p_saveA5	rs.l	1
p_saveA6	rs.l	1
p_saveA7	rs.l	1
p_cmdcnt	rs.b	1
p_cmdlin	rs.b	$7f
p_size	rs.b	0

	rsreset		;Structure DTA
dta_priv	rs.b	21
dta_fattr	rs.b	1
dta_time	rs.w	1
dta_date	rs.w	1
dta_size	rs.l	1
dta_name	rs.b	14
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷>BIOS        ÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	RSRESET
Getmpb	equ	$0600
Bconstat	equ	$0401
Bconin	equ	$0402
Bconout	equ	$0603
Rwabs	equ	$0e04
Setexec	equ	$0805
Tickcal	equ	$0206
Getbpb	equ	$0407
Bcostat	equ	$0408
Mediach	equ	$0409
Drvmap	equ	$020a
Kbshift	equ	$040b

Bios	MACRO
	IFGE	\1
	 IFNE	\1&$ff
	  move.w	#\1&$ff,-(sp)
	 ELSE
	  clr.w	-(sp)
	 ENDC
	 trap	#13
	 IFNE	\1&$ff00
	  IFEQ	(\1-$100)&$f800
	   addq.l	#\1>>8,sp
	  ELSE
	   lea	\1>>8(sp),sp
	  ENDC
	 ENDC
	ELSE
	 move.w	#(-(\1))&$ff,-(sp)
	 trap	#13
	ENDC
	ENDM

	rsreset		;Memory Parameter Block
mpb_mfl	rs.l	1
mpb_mal	rs.l	1
mpb_rover	rs.l	1

	rsreset		;Memory Descriptor
md_link	rs.l	1
md_start	rs.l	1
md_length	rs.l	1
md_own	rs.l	1

	rsreset		;Bios Parameter Block
bpb_recsiz	rs.w	1
bpb_clsiz	rs.w	1
bpb_clsizb	rs.w	1
bpb_rdlen	rs.w	1
bpb_fsiz	rs.w	1
bpb_fatrec	rs.w	1
bpb_datrec	rs.w	1
bpb_numcl	rs.w	1
bpb_bflags	rs.w	1

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷>XBIOS       ÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	RSRESET
Initmous	equ	$0c00
Ssbrk	equ	$0401
Physbase	equ	$0202
Logbase	equ	$0203
Getrez	equ	$0204
Setscreen	equ	$0c05
Setpalette	equ	$0606
Setcolor	equ	$0607
Floprd	equ	$1408
Flopwr	equ	$1409
Flopfmt	equ	$1a0a
Midiws	equ	$080c
Mfpint	equ	$080d
Iorec	equ	$040e
Rsconf	equ	$0e0f
Keytbl	equ	$0e10
Random	equ	$0211
Protobt	equ	$0e12
Flopver	equ	$1013
Scrdmp	equ	$0214
Cursconf	equ	$0615
Settime	equ	$0616
Gettime	equ	$0217
Bioskeys	equ	$0218
Ikbdws	equ	$0819
Jdisint	equ	$041a
Jenabint	equ	$041b
Giaccess	equ	$061c
Offgibit	equ	$041d
Ongibit	equ	$041e
Xbtimer	equ	$0c1f
Dosound	equ	$0620
Setprt	equ	$0421
Kbdvbase	equ	$0222
Kbrate	equ	$0623
Prtblk	equ	$0624
Vsync	equ	$0225
Supexec	equ	$0626
Puntaes	equ	$0227
NVMaccess	equ	$0c2e
Blitmode	equ	$0440

;Vid‚o Falcon 030
Setscreen030	equ	$0e05
Vsetmode		equ	$0458
mon_type		equ	$0259
VsetSync		equ	$045a
VgetSize		equ	$045b
VsetRGB		equ	$0a5d
VgetRGB		equ	$0a5e
VsetMask		equ	$0696

_2c	set	$000	;Du duochrome..
_4c	set	$001	;
_16c	set	$002	;
_256c	set	$003	;
_65kc	set	$004	;..au True-Color
			;-si pr‚sent-|-si absent-
_640x	set	$008	;80 colonnes | 40 colonnes
_vga	set	$010	;monit. VGA  | monit. RGB
_pal	set	$020	;PAL (50Hz)  | NTSC (60Hz)
_ovr	set	$040	;Overscan    | Normal
_ste	set	$080	;Modes STE   | Modes Falcon
_400y	set	$100	;~400 lignes | ~200 lignes   }RGB
_240y	set	$100	; 240 lignes |  480 lignes   }VGA

;SystŠme sonore
Snd_Lock		equ	$0280
Snd_Unlock		equ	$0281
Snd_Cmd		equ	$0682
Snd_SetBuffer	equ	$0c83
Snd_SetMode	equ	$0484
Snd_SetTracks	equ	$0685
Snd_SetMonTracks	equ	$0486
Snd_SetInterrupt	equ	$0687
Snd_BufOper	equ	$0488
Snd_DspTriState	equ	$0689
Snd_Gpio		equ	$068a
Snd_DevConnect	equ	$0c8b
Snd_Status		equ	$048c
Snd_BufPtr		equ	$068d
;Transferts DSP
Dsp_DoBlock	equ	$1260
Dsp_BlkHanShake	equ	$1261
Dsp_BlkUnpacked	equ	$1262
Dsp_BlkWords	equ	$127b
Dsp_BlkBytes	equ	$127c
Dsp_MultBlocks	equ	$127f
Dsp_InStream	equ	$1263
Dsp_OutStream	equ	$1264
Dsp_IOStream	equ	$1a65
Dsp_SetVectors	equ	$0a7e
Dsp_RemoveInterrupts	equ	$0466
Dsp_GetWordSize	equ	$0267
;Controle des programmes DSP
Dsp_Lock		equ	$0268
Dsp_Unlock		equ	$0269
Dsp_Available	equ	$0a6a
Dsp_Reserve	equ	$0a6b
Dsp_LoadProg	equ	$0c6c
Dsp_ExecProg	equ	$0c6d
Dsp_ExecBoot	equ	$0c6e
Dsp_LodToBinary	equ	$0a6f
Dsp_TriggerHC	equ	$0470
Dsp_RequestUniqueAbility equ	$0271
Dsp_GetProgAbility	equ	$0272
Dsp_FlushSubroutines	equ	$0273
Dsp_LoadSubroutine	equ	$0c74
Dsp_InqSubrAbility	equ	$0475
Dsp_RunSubroutine	equ	$0476
Dsp_Hf0		equ	$0477
Dsp_Hf1		equ	$0478
Dsp_Hf2		equ	$0479
Dsp_Hf3		equ	$047a
Dsp_Hstat		equ	$027d

Xbios	MACRO
	IFGE	\1
	 IFNE	\1&$ff
	  move.w	#\1&$ff,-(sp)
	 ELSE
	  clr.w	-(sp)
	 ENDC
	 trap	#14
	 IFNE	\1&$ff00
	  IFEQ	(\1-$100)&$f800
	   addq.l	#\1>>8,sp
	  ELSE
	   lea	\1>>8(sp),sp
	  ENDC
	 ENDC
	ELSE
	 move.w	#(-(\1))&$ff,-(sp)
	 trap	#14
	ENDC
	ENDM

	rsreset		;I/O Record
ibuf	rs.l	1
ibufsiz	rs.w	1
ibufhd	rs.w	1
ibuftl	rs.w	1
ibuflow	rs.w	1
ibufhi	rs.w	1

	rsreset		;Boot Sector
bs_BRA	rs.w	1
bs_NAME	rs.b	6
bs_SERIAL	rs.b	3
bs_BPS	rs.b	2
bs_SPC	rs.b	1
bs_RES	rs.b	2
bs_FAT	rs.b	1
bs_DIR	rs.b	2
bs_SEC	rs.b	2
bs_MEDIA	rs.b	1
bs_SPF	rs.b	2
bs_SPT	rs.b	2
bs_SIDE	rs.b	2
bs_HIDE	rs.b	2
bs_CODE	rs.b	480
bs_CHECK	rs.b	2

	rsreset		;Keyboard Vectors
midivec	rs.l	1
vkbderr	rs.l	1
vmiderr	rs.l	1
statvec	rs.l	1
mousevec	rs.l	1
clockvec	rs.l	1
joyvec	rs.l	1
midisys	rs.l	1
ikbdsys	rs.l	1
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷>START-UP    ÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;Macro d'en-tete de programme, effectue un Mshrink sur le programme si
;ce n'est pas un accessoire. Possibilit‚ de mettre en paramŠtre la taille
;de la pile.
;Renvoie  o D0=D7=0  ; Z=1 si c'est un PRG
;         o D0=D7<>0 ; Z=0 si c'est un ACC
;         o A0=Adresse BasePage
;         o A1=Taille du bloc m‚moire du programme
;         o A7=Pile en fin de ce bloc
;
StartUp	MACRO	stacksize
stup\@	move.l	a0,d7		;Flag ACC/PRG ?
	bne.s	.acc0		;
	movea.l	4(sp),a0		;PRG->r‚cupŠre BasePage
.acc0
	IFLT	32768-(\1+256)	;
	lea	\1+256,a1		;  Taille BasePage&Pile
	ELSE			;
	lea	\1+256.w,a1	;
	ENDC			;
	adda.l	p_tlen(a0),a1	;+ '''''' TEXT
	adda.l	p_dlen(a0),a1	;+ '''''' DATA 
	adda.l	p_blen(a0),a1	;+ '''''' BSS
	lea	(a0,a1.l),sp	;->hop, fixe la pile … la fin
	tst.l	d7		;
	bne.s	.acc1		;ACC ou PRG ?
	moveq	#Mshrink&$ff,d0	;PRG, donc rajoute Mshrink
	swap	d0		;->d0=$004a0000
	movem.l	d0/a0-a1,-(sp)	;->(sp)=$004a0000|BasePage|Size
	trap	#1		;
	movem.l	(sp)+,d0/a0-a1	;
.acc1	move.l	d7,d0		;Retour … l'envoyeur
	ENDM

