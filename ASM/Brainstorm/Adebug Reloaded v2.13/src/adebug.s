;
; Copyright 1990-2006 Alexandre Lemaresquier, Raphael Lemoine
;                     Laurent Chemla (Serial support), Daniel Verite (AmigaOS support)
;
; This file is part of Adebug.
;
; Adebug is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; Adebug is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with Adebug; if not, write to the Free Software
; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
;

;  #[ Intro:
;
; A-Debug: Debugger 68000/68008/68010/68012/68020/68030/68881/68882
;                     pour ATARI ST, STE, TT, Falcon
;                               et AMIGA
;
;                             Version 2.12
;
;
;--- ALEX ---
;U [,brk type]
;Ctl_Alt_V [,@]
;Compare memory
;mettre labels C dans desassemblage
;mettre les eq en relatif sur un registre
; VOIR LABELS EX

;rajouter ds les preferences:
;stack size / stack checking
;context switching #
;register equate

;prinfo:
;retraiter les fenetres

;fenetre watch
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PLUS TARD;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;kill de variable (pas oublier de retrier)
;mettre les var de debug en ex
;stocker (et afficher) les noms de bl
;gerer les erreurs disks avec les messages correspondants
;entree chez nous avec un trap
;ctl_l <f>,[cmd line],[@ de run until][,@ de debut d'execution]
;charger binaire <f>,[@],[longueur][,offset]
;sauver binaire <f,@,longueur>[,offset]-> si le fichier existe deja
;gerer ascii dans les prefs
;[Alt_F1~10] macro 1~10
;ligne de commande premiere partie
;trier les breaks
;chargement de blocks (" ou ' au debut d'un fichier)

;mettre en form_do:
;preferences
;ctl_e
;liste des symboles de l'eval
;liste des symboles du desass

;ro_struct:
;repasser les tableaux en pointeurs
;fenetre courante
;@ de sauvegarde des exceptions
;pointer sur toutes les var du prog en cours
;pointer sur la ligne pc desassemblee
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;--- RAPH ---
; DEBUGGER LE SEARCH
; PRINT BLOCK (FINIR LABELS)
; ',->,. DANS L'EVALUATEUR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; a merger:
;
; a ecrire:
; reecrire le temps reel
; tester btst d2,#$10
; assembler btst d2,#$10
; gestion des macros dans l'assemblage en ligne
; rajouter ' dans copy et fill
; bug du lock PC sur W2 sur decodage en mode trace
; subi.l d0,#$
; move from ccr.
; $42ef = clr.? 0(sp)
; movem.l d0-d5,rel(pc)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
			;RDEBUG residant
;faire un keep en additionnant
;-toutes les tailles de buffer
;-end_of_offset_base
;-la taille de TEXT+DATA
;faire un ctrl_r
;ne pas tenir compte de la deuxieme partie de la ligne de cmd
;-->_ctrl_l
;ne pas oublier de passer en no debug
;virer ctrl_c en partie
;virer ctrl_l en totalite
;virer messages dans data et variables dans bss
;
			;ADEBUG bride
;virer:
;alt_v
;-tous les chargements et sauvegardes sauf adebug.var
;save_file
;create_file
;write_file
;-- form_do
;-- save_binary
;-- load_binary
;-- ctrl_l
;-- ctrl_c
;virer messages dans data et variables dans bss
;
			;AADEBUG acc
;pas de mshrink
;boucle en user|acc_stack|event_multi
;ctrl_c:
;remonter dans la boucle en user par le systeme|acc_stack|bra waitforevent
;
			;DDEBUG diagnostic cartridge:
;a initialiser:
;la pile! (la mettre ou on veut)
;memconf! (faisable)
;tout prg init,soit:
;fontes: a chercher
;tables de scan: a avoir en datas (differentes selon le pays)

;a enlever:
;le passage en super->le supexec (y'a plus de pile user d'ailleurs)
;
			;version 25:
;assemblage en ligne 68030
;cyclage (uniquement sur 68000)
;lock memory bloc
;interpretation totale du code ( pour fonction 'UNDO' )
;
;  #] Intro:
;  #[ Equs:
;	 #[ Text language equs:
english_text	EQU	1
french_text	EQU	0
german_text	EQU	0
;	 #] Text language equs:
;	 #[ Internal versions equs:
in_line_asm	EQU	1
			IFND	residant
residant		EQU	0
			ENDC
residant_debug	EQU	0
accessoire	EQU	0
bridos		EQU	0
cartouche		EQU	0
mmanager		EQU	0
diagnostic	EQU	0
switching_debug	EQU	0
sourcedebug	EQU	1
turbodebug	EQU	1
bsddebug		EQU	0
latticedebug	EQU	0
laserdebug	EQU	0
stmag		EQU	0
amigarevue	EQU	0
daniel_version	EQU	0
amiga_avbl	EQU	0
atarifrance	EQU	0
catchgen		EQU	0

;	IFNE	residant|bridos|accessoire|stmag	;|cartouche
;debug	EQU	0
;	ELSEIF
;debug	EQU	1
;	ENDC

	IFNE	english_text

	IFNE	residant
	IFNE	debug
	LIST
	output	c:\auto\rdebug.prg
	NOLIST
	ELSEIF
	LIST
	output	rdebug.prg
	NOLIST
	ENDC
	ENDC

	IFNE	accessoire
	IFNE	debug
	LIST
	output	c:\aadebug.acc
	NOLIST
	ELSEIF
	LIST
	output	aadebug.acc
	NOLIST
	ENDC
	ENDC

	IFNE	cartouche
	LIST
	output	cdebug.prg
	NOLIST
	ENDC

	IFNE	bridos
	LIST
	output	bridos.prg
	NOLIST
	ENDC

	IFEQ	residant|accessoire|bridos|cartouche
	LIST
;	output	adebug.prg
	NOLIST
	ENDC

	ENDC	; de english_text

	IFNE	french_text

	IFNE	residant
	IFNE	debug
	LIST
	output	c:\auto\rdebugf.prg
	NOLIST
	ELSEIF
	LIST
	output	rdebugf.prg
	NOLIST
	ENDC
	ENDC

	IFNE	accessoire
	IFNE	debug
	LIST
	output	c:\aadebugf.acc
	NOLIST
	ELSEIF
	LIST
	output	aadebugf.acc
	NOLIST
	ENDC
	ENDC

	IFNE	cartouche
	LIST
	output	cdebugf.prg
	NOLIST
	ENDC

	IFNE	bridos
	LIST
	output	bridosf.prg
	NOLIST
	ENDC

	IFEQ	residant|accessoire|bridos|cartouche
	LIST
	output	adebugf.prg
	NOLIST
	ENDC

	ENDC	; de french_text

;	 #] Internal versions equs:
;	 #[ Machine equs:
ATARIST	EQU	1
ATARITT	EQU	1
ATARI	EQU	1
MTOS	EQU	1	;pas en meme temps que cartouche
AMIGA	EQU	0
A3000	EQU	0
MAC	EQU	0

	IFNE	ATARIST
VERSION	EQU	$213
	ENDC
	IFNE	AMIGA
VERSION	EQU	$102
	ENDC
_ST	EQU	0	;Atari ST, Mega ST
_STE	EQU	2	;Atari STE
_TT	EQU	4	;Atari TT
_FALC	EQU	6	;Atari Falcon
_NB	EQU	8	;Atari STBook
_UNKN	EQU	10	;Atari Unknown
_MSTE	EQU	12	;Atari Mega STe
;	 #] Machine equs:
;	 #[ Microproc equs:
_68000	EQU	1
_68010	EQU	0
_68020	EQU	0
	IFNE	ATARITT|A3000
_68030	EQU	1
	ELSEIF
_68030	EQU	0
	ENDC	; d'ATARITT
_68040	EQU	0
_CPU32	EQU	0
;	IFNE	_68030
;	IFEQ	A3000
;	opt	p=68030,p=68882
;	ENDC
;	ENDC
;	 #] Microproc equs:
;	 #[ Keyboards equs:
french_kbd	EQU	1
english_kbd	EQU	0
german_kbd	EQU	0
;	 #] Keyboards equs:
;	 #[ Miscellaneous equs:
;		#[ Windows equs:
REGWIND_TYPE	equ	0
DISWIND_TYPE	equ	1
HEXWIND_TYPE	equ	2
ASCWIND_TYPE	equ	3
WATWIND_TYPE	equ	4
SRCWIND_TYPE	equ	5
VARWIND_TYPE	equ	6
INSWIND_TYPE	equ	7
;LOG
ZOMWIND_TYPE	equ	8

_GENWIND_X	equ	0
_GENWIND_Y	equ	2
_GENWIND_W	equ	4
_GENWIND_H	equ	6
_GENWIND_ON	equ	8
_GENWIND_CUR	equ	9
_GENWIND_PTR	equ	10
_GENWIND_TYPE	equ	14

_GENWIND_SIZEOF	equ	16
_SRCWIND_SIZEOF	equ	16
_VARWIND_SIZEOF	equ	26
_INSWIND_SIZEOF	equ	18*2	;for old inspect storage
;WINDOWS_PREFS_SIZE	equ	6*_GENWIND_SIZEOF*3+2*6+1*6+_SRCWIND_SIZEOF*6+_VARWIND_SIZEOF*6+2+($10+6)*2+3
;		#] Windows equs:
;		#[ Pascal equs:
SAVE_SIZE equ	$6200-8
;		#] Pascal equs:
;		#[ Pages equs:
story_lines_nb	equ	4
	IFNE	ATARIST
breaks_page_nb	equ	2
variables_page_nb	equ	2
	ENDC
	IFNE	AMIGA
variables_page_nb	equ	3
breaks_page_nb		equ	3
	ENDC
;		#] Pages equs:
;		#[ Magic equs:
BRAINSTORM_MAGIC	equ	'BRST'
ADEBUG_MAGIC	equ	'ADBG'
RDEBUG_MAGIC	equ	'RDBG'
CDEBUG_MAGIC	equ	'CDBG'
VBL_MAGIC	equ	'VBLQ'
PREF_MAGIC	equ	'PREF'
RESTART_MAGIC	equ	'RTRT'
KEYS_MAGIC	equ	'KEYS'
SWIM_MAGIC	equ	'SWIM'
FILES_MAGIC	equ	'FILS'
CMDLINE_MAGIC	equ	'CMDL'
RESIDANT_TRAP1_MAGIC	equ	'RTR1'
EXCEPTION_MAGIC	equ	'EXCP'
RESET_MAGIC	equ	'RSET'
PRINFO_MAGIC	equ	'PRIN'
;		#] Magic equs:
;		#[ Sizes equs:
STACK_SIZE	equ	16*1204
;typedef struct {
;	union {
;		char	*break_addr;
;		char	*save_trap;
;	} addr;
;	char	*eval;
;	uint	number;
;	struct {
;		uchar	is_rom:1;
;		uchar	is_permanent:1;
;		uchar	is_system:1;
;		uchar	is_on:1;
;		uchar is_internal:1;
;	} flags;
;	uchar	vector;
;	union {
;		ulong	oldinstr;
;		ulong	oldpc;
;		union {
;			struct {
;				uint	is_aes:1;
;				uint	is_vdi:1;
;				uint	not_used:6;
;				uint	secno:8;
;			} sysflags;
;			uint	funcno;
;		} system;
;	} spec;
;}BREAK;

;simple
BREAK_SIZE	equ	16
BREAK_ADDR	equ	0
BREAK_EVAL	equ	4
BREAK_NUMBER	equ	8
BREAK_VECTOR	equ	10
BREAK_OLDINSTR	equ	12

;system
BREAK_SAVETRAP	equ	0
BREAK_SYSFLAGS	equ	12
BREAK_SYSSECNO	equ	13
BREAK_FUNCNO	equ	14
;system bitfield
BREAK_SYSALLFUNCS	equ	31
BREAK_SYSAES	equ	30
BREAK_SYSVDI	equ	29
BREAK_SYSSEC	equ	28
;rom/internal
BREAK_OLDPC	equ	12

;source breaks
BREAK_SRC_PTR	equ	0
BREAK_SRC_LNB	equ	4
BREAK_SRC_MDL	equ	8

;breaks bitfield
BREAK_IS_ROM	equ	15
BREAK_IS_PERMANENT	equ	14
BREAK_IS_SYSTEM	equ	13
BREAK_IS_ON	equ	12
BREAK_IS_INTERNAL	equ	11
BREAK_IN_SOURCE	equ	10
;BREAK_IS_	equ	9
;BREAK_IS_	equ	8

;typedef struct {
;	uint	type;
;	char	*start;
;	char	*end;
;} BLOCK;

;typedef struct {
;	char	*name;
;	uint	type;
;	union {
;		ulong	value;
;		BLOCK	*blptr;
;	} spec;
;} VAR;

VAR_NAME	equ	0
VAR_TYPE	equ	4
VAR_VALUE	equ	6
VAR_BLPTR	equ	6
VAR_SIZE	equ	10

BLPTR_START	equ	0
BLPTR_END	equ	4
BLPTR_TYPE	equ	8
BLPTR_SIZE	equ	10

VAR_TREE_VALUE	equ	0
VAR_TREE_COUNT	equ	4
VAR_TREE_VAR	equ	8
VAR_TREE_SIZE	equ	12

STO_REC_SIZE	equ	118
;INITIAL_SIZE	equ	3*2+16*2+4*3+4
EXTERNAL_CONTEXT_SIZE	set	(16+16+4+1+4)*2
	;d0-d7=16W
	;a0-a7=16W
	;ssp-pc=4W
	;sr=1W
	;timers1=4W
	IFNE	_68030
EXTERNAL_CONTEXT_SIZE	set	EXTERNAL_CONTEXT_SIZE+27*2
	ENDC
INTERNAL_CONTEXT_SIZE	equ	5*4
;		#] Sizes equs:
;		#[ Keywords equs:
LAWORD	equ	'la'
LRWORD	equ	'lr'
BLWORD	equ	'bl'
ROWORD	equ	'ro'
EXWORD	equ	'ex'
LMWORD	equ	'lm'
EQWORD	equ	'eq'
TCWORD	equ	'tc'
VIRTUAL_OUTPUT	equ	0
SCREEN_OUTPUT	equ	1
RS232_OUTPUT	equ	2
PRINTER_OUTPUT	equ	3
;		#] Keywords equs:
;		#[ Source types equs:
EXEC_NO		equ	0
EXEC_LINK equ	1
EXEC_PRG	equ	2
EXEC_ACC	equ	3
EXEC_RES	equ	4

RELOC_NO	equ	0
RELOC_GEMDOS	equ	1
RELOC_DRI	equ	2
RELOC_GST	equ	3
RELOC_TC	equ	4
RELOC_LC	equ	5
RELOC_MWC	equ	6
RELOC_MLC	equ	7

SOURCE_NO	equ	0
SOURCE_DRIH	equ	0
SOURCE_S	equ	1
SOURCE_PC	equ	2
SOURCE_BSD	equ	3
SOURCE_LC	equ	4
SOURCE_MOD	equ	5

	IFNE	sourcedebug
_SRCWIND_PTR	equ	0
_SRCWIND_LINENB	equ	4
_SRCWIND_ENDPTR	equ	8
_SRCWIND_OFF	equ	12
_SRCWIND_OFFMAX	equ	14

_VARWIND_PTR	equ	0
_VARWIND_STARTPTR	equ	4
_VARWIND_NB	equ	8
_VARWIND_NBMAX	equ	12
_VARWIND_STARTVAR	equ	16
_VARWIND_TYPE	equ	20
_VARWIND_OFF	equ	22
_VARWIND_OFFMAX	equ	24

_VARWIND_GLOBAL_TYPE	equ	1
_VARWIND_STATIC_TYPE	equ	2
_VARWIND_LOCAL_TYPE	equ	3

_INSWIND_PTR	equ	0
_INSWIND_ELNB	equ	4
_INSWIND_ELMAX	equ	8
_INSWIND_OFF	equ	12
_INSWIND_OFFMAX	equ	14
_INSWIND_OLDTYPE	equ	16	;0=no old type
_INSWIND_OLDINS	equ	18

TCVARS_SIZEOF	equ	4
	ENDC	;de sourcedebug
;		#] Source types equs:
;	 #] Miscellaneous equs:
;  #] Equs:
;  #[ Macros:
	IFNE	ATARIST|AMIGA
SWITCHA6	MACRO
	IFNE	cartouche
	move.l	a6,CARTRIDGE_SAVE-4.w
	move.l	CARTRIDGE_SAVE.w,a6
	move.l	CARTRIDGE_SAVE-4.w,(a6)
	ELSEIF
	move.l	a6,external_a6
	move.l	internal_a6,a6
	ENDC
	ENDM

RESTOREA6 MACRO
	IFNE	cartouche
	move.l	(a6),a6
	ELSEIF
	move.l	external_a6,a6
	ENDC
	ENDM

GETA6	MACRO
	IFNE	cartouche
	move.l	CARTRIDGE_SAVE.w,a6
	ELSEIF
	move.l	internal_a6,a6
	ENDC
	ENDM

SET_ID	MACRO
	even
	dc.l	BRAINSTORM_MAGIC
	dc.l	ADEBUG_MAGIC
	dc.l	\1
	ENDM

_JMP	MACRO
	jmp	\1
	ENDM

_JSR	MACRO
	jsr	\1
	ENDM

_OPTI	MACRO
	IFEQ	debug
	opt	o1+
	ENDC
	ENDM

_NOOPTI	MACRO
	opt	o1-
	ENDM

_00	MACRO
	opt	p=68000
	ENDM

_20	MACRO
	opt	p=68020,p=68882
	ENDM

_30	MACRO
	opt	p=68030,p=68882
	ENDM

	ENDC	;d'ATARI|AMIGA

	IFNE	MAC
SWITCHA6	MACRO
	move.l	a6,$40.w
	move.l	$44.w,a6
	ENDM

RESTOREA6	MACRO
	move.l	$40.w,a6
	ENDM

GETA6	MACRO
	move.l	$44.w,a6
	ENDM

SET_ID	MACRO
	even
	dc.l	BRAINSTORM_MAGIC
	dc.l	ADEBUG_MAGIC
	dc.l	\1
	ENDM

_JMP	MACRO
	jmp	\1
	ENDM
_JSR	MACRO
	jsr	\1
	ENDM

	ENDC	;de MAC
;  #] Macros:
	opt	ow-,w-,o+,o10-
	IFNE	debug
	opt	x+,o1-
	ENDC

	section text
A_Debug:
	bra.s	main
	dc.b	"--Arf.--"
;  #[ Main:
main:
	IFNE ATARIST
	IFNE accessoire
	include	"accessor.s"
	ELSEIF	; de accessoire
	IFNE	cartouche&mmanager
	include	"mmanager.s"
	ENDC	; de cartouche&manager
	 ;#[ Mshrink:
	move.l	4(sp),a5
	IFNE	MTOS
	move.l	sp,sys_stack
	lea	mtos_stack,sp
	ENDC	;MTOS
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	$c(sp),sp
	IFNE	cartouche
	tst.l	d0
	beq.s	real_start_of_adebug
	_JMP	exit_in_user
	lea	.ici(pc),a0
	move.l	a0,d0
	andi.l	#$ffffff,d0
	move.l	d0,a0
	jmp	(a0)
.ici:	moveq	#1,d3
	bra.s	Magic_start
	ELSEIF
	move.w	d0,exit_error_number
	beq.s	real_start_of_adebug
	_JMP	exit_in_user
	ENDC
	 ;#] Mshrink:
	ENDC	; de accessoire
	ENDC	; de ATARIST
	 ;#[ Real_start_of_Adebug:
real_start_of_adebug:
	IFNE	AMIGA
	movem.l	d0-a6,-(sp)
	ENDC
	moveq	#0,d3
Magic_start:
	move.l	#end_of_offset_base,d0
	;first time
	moveq	#1,d1
	moveq	#3,d2
	cmp.l	#BRAINSTORM_MAGIC,d4
	bne.s	not_reserved
	cmp.l	#ADEBUG_MAGIC,d5
	bne.s	not_reserved
	cmp.l	#RESTART_MAGIC,d6
	bne.s	not_reserved
Restart_adebug:
	move.l	d7,a0
	moveq	#-1,d2
not_reserved:
	bsr	reserve_memory
	bne.s	.good
	IFEQ	cartouche
	move.w	#MEMORY_EXIT_ERROR_NUMBER,exit_error_number
	ENDC
	IFNE	AMIGA
	movem.l	(sp)+,d0-a6
	jsr	amiga_start
	ENDC
	_JMP	exit_in_user
.good:	move.l	d0,a6

	IFNE	AMIGA
	jsr	amiga_start
	lea	initial_regs(a6),a0
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,(a0)
	lea	8*4(a0),a0
	movem.l	(sp)+,d0-d6
	movem.l	d0-d6,(a0)
	clr.b	crdebug_flag(a6)
	move.l	#AMIGA_NB_LINES*LINE_SIZE,d0
	moveq	#2,d1
	move.l	a6,-(sp)
	move.l	4.w,a6
	jsr	AllocMem(a6)
	move.l	(sp)+,a6
	tst.l	d0
	bne.s	.good2
	IFEQ	cartouche
	move.w	#MEMORY_EXIT_ERROR_NUMBER,exit_error_number
	ENDC
	jmp	exit_in_user
.good2:	move.l	d0,initial_physbase(a6)
	move.l	d0,physbase(a6)
	lea	amiga_sup_stack+am_stack_len(a6),a0
	move.l	a0,internal_am_ssp(a6)
	ENDC	;AMIGA

	IFNE	ATARIST
	_JSR	get_machine_type
	move.l	screen_size(a6),d0
	moveq	#-1,d1			;no clear
	moveq	#0,d2			;slow ram
	bsr	reserve_memory
	bne.s	.good2
	IFEQ	cartouche
	move.w	#MEMORY_EXIT_ERROR_NUMBER,exit_error_number
	ENDC
	_JMP	exit_in_user
.good2:	move.l	d0,initial_physbase(a6)
	clr.b	d0
	add.l	#1024,d0
	move.l	d0,physbase(a6)
	IFNE	residant
	st	crdebug_flag(a6)
	ELSEIF
	IFNE	cartouche
	move.b	d3,crdebug_flag(a6)
	beq.s	.suite
	move.l	sp,initial_ssp(a6)
	move.l	sp,ssp_buf(a6)
	bsr	check_chip
	bra.s	.already_in_super
.suite:
	ENDC	;cartouche
	ENDC	;residant
	ENDC	;ATARIST
;--------------- USER
	bsr	check_chip
	IFEQ	_68000
	tst.b	chip_type(a6)
	bne.s	.no_bleme
	lea	adebug_68030_only_text,a0
	_JSR	system_print
	_JSR	system_getkey
	IFEQ	cartouche
	move.w	#-1,exit_error_number
	ENDC
	IFNE	AMIGA
	jsr	amiga_fast_desinit
	ENDC
	_JMP	real_exit_in_user
.no_bleme:
	ENDC	; de _68000
	IFEQ	_68030
	tst.b	chip_type(a6)
	beq.s	.no_bleme
	lea	adebug_68000_only_text,a0
	_JSR	system_print
	_JSR	system_getkey
	IFEQ	cartouche
	move.w	#-1,exit_error_number
	ENDC
	IFNE	AMIGA
	jsr	amiga_fast_desinit
	ENDC
	_JMP	real_exit_in_user
.no_bleme:
	ENDC	; de _68030

	IFNE	MTOS
	move.l	sys_stack,internal_usp(a6)
	ELSEIF
	move.l	sp,internal_usp(a6)
	ENDC	;MTOS
	jsr	super_on
	move.l	d0,initial_ssp(a6)
	move.w	sr,d0
	bclr	#13,d0
	move.w	d0,initial_sr(a6)
	IFNE	_68030
	tst.b	chip_type(a6)
	beq.s	.68000
	_30
	movec	vbr,d0
	_00
	move.l	d0,initial_vbr(a6)
.68000:	ENDC	;_68030
	IFNE	AMIGA
	move.l	internal_am_ssp(a6),a0
	jsr	super_off
	ENDC	;d'AMIGA
;--------------- USER
	IFNE	ATARIST&residant	; pas cartouche
	bsr	check_for_residant
	ENDC
.already_in_super:
	move.l	#STACK_SIZE,d0
	move.l	d0,stack_size(a6)
	moveq	#-1,d1
	moveq	#3,d2
	bsr	reserve_memory
	bne.s	.good_stack_reserved
	IFEQ	cartouche
	move.w	#MEMORY_EXIT_ERROR_NUMBER,exit_error_number
	ENDC
	_JMP	exit_in_user
.good_stack_reserved:
	move.l	d0,reserved_stack_addr(a6)
	move.l	d0,check_stack_addr(a6)
	add.l	#100,check_stack_addr(a6)
	add.l	stack_size(a6),d0
	subq.l	#4,d0
	move.l	d0,sp
	move.l	sp,top_stack_addr(a6)
	bsr	init
	lea	initial_path(a6),a0		;macro default
	_JSR	set_drivepath
	_JSR	execute_def_mac
	 ;#] Real_start_of_Adebug:
	 ;#[ Residant start:
	IFNE	ATARIST&(residant|cartouche)
	bsr	install_fork
	tst.b	crdebug_flag(a6)
	bne	be_residant
	ENDC	; d'ATARIST&(residant|cartouche)
	 ;#] Residant start:
	 ;#[ Maybe residant:
maybe_resident:
	IFEQ	accessoire
;tester la ligne de commande
	IFNE	cartouche
	tst.b	crdebug_flag(a6)
	bne.s	.no_load_requested
	ENDC	;cartouche
	IFEQ	residant|bridos
	tst.l	p1_basepage_addr(a6)
	bne.s	.no_load_requested
	tst.b	exec_name_buf(a6)
	beq.s	.no_load_requested
	_JSR	load_executable
	ENDC	;residant|bridos
.no_load_requested:
	ENDC	;accessoire
	 ;#] Maybe residant:
	 ;#[ Waiting:
waiting:
 sf c_line(a6)
 sf m_line(a6)
 IFNE	sourcedebug
 _JSR	update_vars_array
 ENDC	;de sourcedebug
 tst.b real_time_flag(a6)
 bne.s .inkey
 _JSR get_char
 bra.s .cool
.inkey:
 _JSR inkey
 tst.l d0
 beq.s .redraw
.cool:
 bsr treat_instruction5
 bra.s waiting
.redraw:
 moveq #5,d7
 lea buffer_lock_pointers(a6),a4
 lea 24(a4),a4
.new:
 subq.w #4,a4
 subq.w #1,d7
 bmi .end
 tst.b real_time_window_flag(a6)
 beq.s .real_time_on_all_windows
 movem.w d0,-(sp)
 move.w window_selected(a6),d0
 subq.w #1,d0
 cmp.w d0,d7
 movem.w (sp)+,d0
 bne.s .new
.real_time_on_all_windows:
 move.l a4,-(sp)
 move.w d7,d0
 _JSR get_noaddr_wind
 add.w d0,a0
 st relock_flag(a6)
 _JSR _lock
 move.l (sp)+,a4
 tst.b relock_flag(a6)
 bne.s .it_was_locked
 move.l -4(a4),a5
 move.l (a4),d3
 sub.l a5,d3
 subq.w #1,d3
 bmi.s .new
 move.w d7,d0
 _JSR get_wind
 move.l a5,a0
.0:
 bsr test_if_readable5
 tst.b readable_buffer(a6)
 bne.s .more_loop_0
 cmp.b (a0)+,(a1)+
 bne.s .yes_redraw
.after_yes_redraw:
 dbf d3,.0
 _JSR build_lock2
 bra.s .new
.more_loop_0:
 addq.w #1,a0
 addq.w #1,a1
 dbf d3,.0
 _JSR build_lock2
 bra.s .new
.yes_redraw:
 move.w d7,d0
 _JSR little_redraw_inside_window
 bra.s .after_yes_redraw
.end:
 bra waiting
.it_was_locked:
 move.w d7,d0
 move.l a4,-(sp)
 _JSR build_lock2
 _JSR redraw_inside_window
 move.l (sp)+,a4
 bra .new

	 ;#] Waiting:
	 ;#[ Check chip:

check_chip:
 IFEQ cartouche
 movem.l d0-d2/a0-a2,-(sp)
 lea .CheckChip(pc),a0
 _JSR supexec
 movem.l (sp)+,d0-d2/a0-a2
 rts
 ENDC

.CheckChip:
 movem.l d0-d3/a0-a2,-(sp)
 move.l sp,a1
 sub.l a2,a2
 move.l $10(a2),d1
 move.l $2c(a2),d2
 move.l $38(a2),d3
 lea .end_CPU(pc),a0
 move.l a0,$10(a2)
 moveq #0,d0
 pea .rtd(pc)				; test CPU
 dc.w $4e74,$0000			; rtd #0
.rtd:
 dc.w $4e7a,$a801			; movec vbr,a2
 moveq #2,d0
 lea .68020_ferror(pc),a0
 move.l a0,$38(a2)
 lea .68030_68040(pc),a0
 move.l a0,$10(a2)
 lea .module(pc),a0
 dc.w $06d0,$0000			; callm #0,(a0)
.68020_ferror:
 bra.s .end_CPU
.module:
 dc.l -1				; invalid 'CALLM' decriptor
.68030_68040:
 moveq #3,d0
 lea .end_CPU(pc),a0
 move.l a0,$10(a2)
 move.l a0,$2c(a2)
 dc.w $f4d0				; cinva
 moveq #4,d0
 nop
.end_CPU:
 move.b d0,chip_type(a6)
 moveq #0,d0
 lea .no_FPU(pc),a0			; test FPU
 move.l a0,$2c(a2)
 dc.w $f200,$0000			; fnop
 moveq #1,d0
 dc.w $f327				; fsave -(sp)
 cmp.w #$1f18,(sp)			; 68881 Stack Frame
 beq.s .end_FPU
 cmp.w #$3f18,(sp)			; 68881 Stack Frame
 beq.s .end_FPU
 moveq #2,d0
 cmp.w #$1f38,(sp)			; 68882 Stack Frame
 beq.s .end_FPU
 moveq #3,d0
.end_FPU:
 dc.w $f35f				; frestore (sp)+
.no_FPU:
 move.b d0,fpu_type(a6)
 move.b d0,fpu_disassembly(a6)
; moveq #0,d0
; lea .68040_MMU(pc),a0
; move.l a0,$2c(a2)
; dc.w $f000,$2400			; pflusha (68851, 68030)
; move.w Chip_type(a6),d0
; bra.s .end_MMU
;.68040_MMU:
; lea .end_MMU(pc),a0
; move.l a0,$2c(a2)
; dc.w $f518				; pflusha (68040)
; moveq #3,d0
;.end_MMU:
; move.w d0,MMU_type(a6)
 move.l d3,$38(a2)
 move.l d2,$2c(a2)
 sub.l a2,a2
 move.l d1,$10(a2)
 move.l a1,sp
 IFNE cartouche
 tst.b crdebug_flag(a6)
 bne.s .init
 cmp.w #6,$454.w
 bne.s .init
 move.l CARTRIDGE_SAVE.w,a1		;sauver le a6 de la cartouche
 move.l a1,external_cart_a6(a6)
 bsr get_vbr				;remettre l'adresse originelle du trap1
 move.l resident_external_trap1(a1),$84(a0)
.init:
 lea $454.w,a0
 move.w (a0),external_vblq_nb(a6)
 subq.w #2,(a0)				;moins 2 entrees
 move.l a6,CARTRIDGE_SAVE.w
 ELSEIF
 move.l a6,internal_a6
 ENDC
 bsr get_main_clock
 movem.l (sp)+,d0-d3/a0-a2
 rts

get_main_clock:
	IFNE	ATARIST
	move	sr,-(sp)
	move	#$2500,sr
	;1s d'attente a 8 MHz
	move.w	#32000-1,d0
	lea	$4ba.w,a0
	move.l	(a0),d1
	addq.l	#1,d1
.l1:	cmp.l	(a0),d1
	blt.s	.l1
.l2:
	REPT	10
	nop
	ENDR
	dbf	d0,.l2
	move.l	(a0),d0
	sub.l	d1,d0
	;32000(tours)*50(cycles)*200(Hz)
	move.l	#3200,d1
	divu	d0,d1
	move	(sp)+,sr	
	ENDC	; d'ATARIST

	IFNE	AMIGA
	move.w	#$4000,$dff09a
	lea	$bfd800,a0
	move.w	#32000-1,d3
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
; attendre une valeur sure
.l1:	move.b	$200(a0),d2
.l2:	move.b	$100(a0),d1
	move.b	(a0),d0
	cmp.b	$100(a0),d1
	bne.s	.l2
	cmp.b	$200(a0),d2
	bne.s	.l1
.l3:
	REPT	10
	nop
	ENDR
	dbf	d3,.l3

; attendre une valeur sure
.l4:	move.b	$200(a0),d6
.l5:	move.b	$100(a0),d5
	move.b	(a0),d4
	cmp.b	$100(a0),d5
	bne.s	.l5
	cmp.b	$200(a0),d6
	bne.s	.l4

	lsl.w	#8,d1
	or.w	d1,d0
	swap	d2
	or.l	d2,d0
	
	lsl.w	#8,d5
	or.w	d5,d4
	swap	d6
	or.l	d6,d4
	
	sub.l	d0,d4
	divu	#10,d4
	move.l	#25000,d1
	divu	d4,d1
	move.w	#$c000,$dff09a
	ENDC ; de AMIGA
	move.w	d1,main_clock(a6)
	rts

	 ;#] Check chip:
;  #] Main:
;  #[ System user functions:
	IFNE	ATARIST
DTA_TYPE	EQU	21
DTA_TIME	EQU	22
DTA_SIZE	EQU	26
DTA_NAME	EQU	30
DTA_BUFFER_SIZE	EQU	44
MEMORY_EXIT_ERROR_NUMBER	EQU	-39
DIRECTORY_SEPARATOR EQU	'\'
CARTRIDGE_SAVE	EQU	$4ea
MAX_KBD_IPL	equ	6
;	 #[ Super on:
super_on:
	suba.l	a0,a0
	;bra.s	super_off
;	 #] Super on:
;	 #[ Super off:
super_off:
	move.l	a0,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	rts
;	 #] Super off:
;	 #[ Supexec:
;a0=@ de la routine
supexec:
	move.l	a0,-(sp)
	move.w	#$26,-(sp)
	trap	#14
	addq.w	#6,sp
	rts
;	 #] Supexec:
	IFNE	residant|cartouche
	include	"residant.s"
	ENDC	; de residant|cartouche
	ENDC	; de ATARIST
	IFNE	AMIGA
MAX_KBD_IPL	equ	2
	include	"amlabel.s"
	ENDC	; de AMIGA
	IFNE	MAC
DTA_TYPE	EQU	21
DTA_SIZE	EQU	26
DTA_NAME	EQU	30
DTA_BUFFER_SIZE	EQU	44
MEMORY_EXIT_ERROR_NUMBER	EQU	-39
DIRECTORY_SEPARATOR EQU	'\'
MAX_KBD_IPL	equ	2
super_on:	rts
	include	sysequ.a
	include	traps.a
	ENDC	;de MAC
;  #] System user functions:
;  #[ Memory functions:
;	 #[ Reserve memory:
;reserve la taille (optionnellement) et vide le buffer (optionnellement)
;d0=taille (negative ou nulle=erreur)
;d1=flag:
;-1=reserve in ram but don't clear
;0=reserve in ram and clear
;1=first time
;d2=flag
;-1=no ram (already allocated, so just clear)
;0=slow ram
;1=fast ram
;2=either ram, better is slow ram
;3=either ram, better is fast ram
;a0=@ if d1==1

;--- OUTPUT ---
;d0=@ !!!!!!!!!!!! et pas a0
reserve_memory:
	;si taille reservee negative ou nulle
	tst.l	d0
	ble.s	.abort
	cmp.w	#1,d1
	beq.s	.first
	lea	internal_memory_base(a6),a1
	tst.l	(a1)
	beq.s	.normal_reserve	
	move.l	(a1),a0
	addq.l	#1,a0
	add.l	d0,a0
	;tester si inscriptible
	move.l	a0,(a1)
	bra.s	.reserved_done
.first:
	tst.l	d2
	bmi.s	.reserved_done
	IFNE	ATARIST
	;y-a-t-il de la ram rapide?
	lea	check_fast_ram(pc),a0
	movem.l	d0-d2,-(sp)
	clr.w	-(sp)
	bsr	supexec
	tst.w	(sp)+
	movem.l	(sp)+,d0-d2
	bne.s	.normal_reserve
	;slow ram
	moveq	#0,d2
	ENDC	;d'ATARIST
.normal_reserve:
	movem.l	d0-d1,-(sp)
	IFEQ	AMIGA
	addq.l	#1,d0		;a cause du ptr impair
	ENDC
	IFNE	ATARITT
	cmp.w	#1,d1
	bne.s	.not_first
	move.w	d2,d1
	bsr.s	__reserve_memory
	bra.s	.after_reserve
.not_first:
	ENDC	; d'ATARITT
	move.w	d2,d1
	bsr.s	_reserve_memory
.after_reserve:
	move.l	d0,a0
	tst.l	d0
	movem.l	(sp)+,d0-d1
	ble.s	.abort
.reserved_done:
	move.l	a0,d2
	;comparer avec le debut de tpa ?

	;forcer a pair
	bclr	#0,d2
	beq.s	.good
	bclr	#1,d2
.good:
	;flag non clear
	tst.b	d1
	bmi.s	.end

	;pas clearer si @=0 ni negatif
	tst.l	d2
	ble.s	.abort

	;si 0 octets demandes
;	tst.l	d0
;	beq.s	.end
	move.l	d2,a1
	asr.l	#1,d0
	scs	d1
.l1:	clr.w	(a1)+
	subq.l	#1,d0
	bne.s	.l1
	tst.b	d1
	beq.s	.end
	clr.b	(a1)+
.end:	move.l	a0,d0
	rts
.abort:	moveq	#0,d0
	rts

check_fast_ram:
	IFEQ	cartouche
	move.l	usp,a0
	move.w	$59e.w,10(a0)
	ENDC	; de cartouche
	rts
;	 #] Reserve memory:
	IFNE	ATARIST
;	 #[ _reserve_memory:
;d0=size.l
;d1=
;0->slow memory (ST ram)
;1->fast memory (TT ram)
;2->either, better is slow
;3->either, better is fast
_reserve_memory:
	cmp.w	#_TT,machine_type(a6)
	bne.s	_reserve_as_st
__reserve_memory:
	;si slow, malloc normal!!!!!!
	tst.b	d1
	beq.s	_reserve_as_st
	move.w	d1,-(sp)
	move.l	d0,-(sp)
	move.w	#$44,-(sp)
	trap	#1
	addq.w	#8,sp
	rts
_reserve_as_st:
	move.l	d0,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.w	#6,sp
	rts
;	 #] _reserve_memory:
;	 #[ Get free memory:
;d0=0->slow memory (ST ram)
;d0=1->fast memory (TT ram)
get_free_memory:
	move.l	a2,-(sp)
	cmp.w	#_TT,machine_type(a6)
	bne.s	.st
	move.w	d0,-(sp)
	pea	-1.w
	move.w	#$44,-(sp)
	trap	#1
	addq.w	#8,sp
	bra.s	.end
.st:	pea	-1.w
	move.w	#$48,-(sp)
	trap	#1
	addq.w	#6,sp
.end:	move.l	(sp)+,a2
	rts
;	 #] Get free memory:
;	 #[ Free memory:
free_memory:
	move.l	a0,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.w	#6,sp
;	tst.l	d0
	rts
;	 #] Free memory:
	ENDC	; de ATARIST
	IFNE	AMIGA
;	 #[ _reserve_memory:
;d1=
;0->slow memory (chip ram)
;1->fast memory (fast ram)
;2->either, better is slow
;3->either, better is fast
_reserve_memory:
	subq.w	#1,d1
	bmi.s	.slow
	beq.s	.fast
	moveq	#0,d1
	bra.s	.reserve
.fast:
	moveq	#4,d1
	bra.s	.reserve
.slow:
	moveq	#2,d1
.reserve:
	CALLEXEC	AllocMem
	tst.l	d0
	rts
;	 #] _reserve_memory:
;	 #[ Get free memory:
get_free_memory:
	move.l	a2,-(sp)
	moveq	#0,d1
	CALLEXEC	AvailMem
	move.l	(sp)+,a2
	rts
;	 #] Get free memory:
;	 #[ Free memory:
;a0=@
;d0=taille
free_memory:
	move.l	a0,a1
	CALLEXEC	FreeMem
	tst.l	d0
	rts
;	 #] Free memory:
	ENDC	; de AMIGA
	IFNE	MAC
;	 #[ _reserve_memory:
;d1=
;0->slow memory
;1->fast memory
;2->either, better is slow
;3->either, better is fast
_reserve_memory:
	rts
;	 #] _reserve_memory:
;	 #[ Get free memory:
;d0=0->slow memory
;d0=1->fast memory
get_free_memory:
	rts
;	 #] Get free memory:
;	 #[ Free memory:
free_memory:
	rts
;	 #] Free memory:
	ENDC	; de MAC
;  #] Memory functions:
;  #[ Init:
init:	_JSR	machine_init
	bsr.s	prg_init
	tst.b	rs232_output_flag(a6)
	beq.s	.end
	_JSR	terminal_init
.end:	rts
;	 #[ Prg init:
prg_init:
	move.w	#200-1,line_buffer_size(a6)	;diverses init de buffer
	lea	empty_string(a6),a0
	moveq	#(200-2)/4,d0
	move.l	#'    ',d1
.l1:	move.l	d1,(a0)+
	dbf	d0,.l1
	lea	exception_routine_text,a0
	lea	exception_routine_buffer(a6),a1
.l11:	move.b	(a0)+,(a1)+
	bne.s	.l11
	lea	breaks,a0
	lea	exceptions_caught_buffer(a6),a1
	moveq	#64-1,d0
.l12:	move.l	(a0)+,(a1)+
	dbf	d0,.l12
	move.w	#2,window_selected(a6)		;quelques valeurs par defaut
	move.w	#1,memory_loop_value(a6)
	move.l	big_window_coords(a6),x_pos(a6)
	move.b	#1,old_p_number(a6)
	lea	A_Debug(pc),a0
	move.l	a0,start_adb_addr(a6)
	move.w	#VERSION,v_number(a6)
;	st	src_checkmodtime_flag(a6)	;pour test
;	st	src_checkcode_flag(a6)
	IFNE	debug
	move.l	a0,text_buf(a6)
	ELSEIF
	move.l	4.w,text_buf(a6)
	ENDC
	_JSR	clr_c_line
;	IFNE	cartouche			;Path initial
;	tst.b	crdebug_flag(a6)
;	beq.s	.normal_path
;	move.w	$446.w,d0
;	add.w	#'A',d0
;	lea	initial_path(a6),a3
;	move.b	d0,(a3)+
;	move.b	#':',(a3)+
;	move.b	#DIRECTORY_SEPARATOR,(a3)+
;	clr.b	(a3)
;	bra.s	.after_get_path
;.normal_path:
;	ENDC	;de cartouche
	lea	initial_path(a6),a0
	_JSR	get_drivepath
;.after_get_path:
	_JSR	build_lock		;Ici, on doit pouvoir afficher
	bsr	draw_all_windows
;Cmd line devrait etre la aussi
;	_JSR	treat_cmd_line
	_JSR	p1_registers_init		;Registres de depart
	_JSR	load_preferences		;Preferences
	tst.b	rs232_output_flag(a6)
	bne.s	.noscr
	_JSR	sbase1_sbase0		;Ecran d'Adebug
.noscr:	_JSR	save_exceptions		;Exceptions
	IFEQ	debug
	_JSR	put_exceptions
	ENDC

	lea	initial_path(a6),a0
	_JSR	set_drivepath

	_JSR	create_sizes		;Divers buffers
	beq.s	.ok
	IFEQ	cartouche
	move.w	#MEMORY_EXIT_ERROR_NUMBER,exit_error_number
	ENDC
	jmp	exit_in_super
.ok:	moveq	#0,d0			;Variables externes
	IFNE	AMIGA
;chercher les ros internes
	lea	A_Debug-4(pc),a0
	move.l	(a0),a0
	add.l	a0,a0
	add.l	a0,a0
	move.l	(a0),d0
	beq.s	.no_ros
	add.l	d0,d0
	add.l	d0,d0
	st	internal_ros_flag(a6)
	jsr	extract_ros
	sf	internal_ros_flag(a6)
.no_ros:
	ENDC	;AMIGA
	_JSR	internal_keyboard_management
	_JSR	test_shift_shift
	bne.s	.no_vars
	tst.l	table_var_max(a6)
	beq.s	.no_vars
	tst.l	table_la_size(a6)
	beq.s	.no_vars
	lea	fichier_var,a0
	_JSR	load_variables
	lea	initial_path(a6),a0
	_JSR	set_drivepath
.no_vars:
	move.l	def_ipl_level(a6),d0	;Default ipl
	andi.l	#%111,d0
	move.l	d0,def_ipl_level(a6)
	moveq	#-1,d1
	_JSR	put_internal_sr
	_JSR	redraw_relock_all		;relock and redraw all windows
	_JSR	treat_cmd_line			;Cmd line
	rts

draw_all_windows:
	lea	windows_to_redraw(a6),a0
	moveq	#-1,d0
	move.l	d0,(a0)
	move.w	d0,4(a0)
	jmp	windows_init

;	 #] Prg init:
;  #] Init:
;  #[ Miscellaneous routines:
	; #[ Sscanf:
;--- INPUT ---
;a0=@ de l'expression ASCII
;a1=@ du format:sbwl|

;--- IN ---
;d7.w=nb d'entrees
;d6.b=type de l'entree
;d5.b=fin de l'input (fin de la chaine)
;d4.l=pointeur sur le debut de l'expression en cours de traitement (pour '|')

;a5=sscanf_outbuf
;a4=ptr sur chaine d'entree
;a3=sscanf_intbuf
;a2=ptr sur chaine de format
;--- OUTPUT ---
;a0=@ du tableau de valeurs:
;1 w=flag:
;0=arg rempli
;-1=arg nul
;1 l,w,s=value

;d0.w=nb d'args (ou -1)
__sscanf:
	movem.l	d5-d7/a2-a5,-(sp)
	moveq	#0,d7
	;histoire de nettoyer l'octet haut du word bas
	moveq	#0,d6
	moveq	#0,d5
	move.l	a0,a4
	move.l	a1,a2
	lea	sscanf_outbuffer(a6),a5
	lea	sscanf_intbuffer(a6),a3

	;si rien tape abort ?
	tst.b	(a4)
	beq	.abort
.more_var:
	;plus rien a interpreter
	tst.b	d5
	bne	.end
	tst.b	(a4)
	beq	.end
	;trop de trucs a interpreter
	tst.b	(a2)
	beq	.abort
	move.l	a3,a1
	move.l	a4,d4
.more_char:
	move.b	(a4)+,d0
	beq.s	.no_more_entry
	cmp.b	#',',d0
	beq.s	.comma
	move.b	d0,(a1)+
	bra.s	.more_char
.no_more_entry:
	st	d5
.comma:
	clr.b	(a1)

	move.b	(a2)+,d6
	clr.w	(a5)
	tst.b	(a3)
	bne.s	.ya_kekchose
	move.w	#-1,(a5)+
	tst.b	d6
	beq.s	.end
	bra.s	.more_char
.ya_kekchose:
	addq.w	#1,d7
	move.w	d6,(a5)+
	;faut-il evaluer ?
	lea	sscanf_no_eval_symbols,a0
.scan_string:
	move.b	(a0)+,d1
	beq.s	.no_string
	cmp.b	d6,d1
	bne.s	.scan_string
;.string:
	move.l	a3,a1
.l1:
	move.b	(a1)+,(a5)+
	bne.s	.l1
	move.l	a5,d0
	btst	#0,d0
	beq.s	.even
	clr.b	(a5)+
.even:
	bra.s	.more_var
.no_string:
	move.l	a3,a0
	_JSR	evaluate
	cmp.b	#'|',(a2)
	bne.s	.not_pipe
	;passer le pipe
	addq.w	#1,a2
	tst.w	d1
	bmi.s	.retry_for_pipe
	;passer l'autre possibilite
	addq.w	#1,a2
	bra.s	.komsi
.retry_for_pipe:
	;repointer sur le debut de l'expression
	move.l	d4,a4
	;c'est plus la derniere entree
	moveq	#0,d5
	;remonter sur le dernier type
	subq.w	#2,a5
	bra	.more_var
.not_pipe:
	tst.w	d1
	bmi.s	.abort
.komsi:
	cmp.b	#'l',d6
	bne.s	.not_long
	move.l	d0,(a5)+
	bra	.more_var
.not_long:
	cmp.b	#'b',d6
	bne.s	.not_byte
	andi.w	#$ff,d0
.not_byte:
	move.w	d0,(a5)+
	bra	.more_var
.abort:
	moveq	#-1,d7
.end:
	tst.b	(a2)+
	beq.s	.real_end
	move.w	#-1,(a5)+
	bra.s	.end
.real_end:
	lea	sscanf_outbuffer(a6),a0
	move.l	d7,d0
	movem.l	(sp)+,d5-d7/a2-a5
	rts
	; #] Sscanf:
	; #[ Strclr:
__strclr:
	move.l	a0,-(sp)
	;je clear la chaine
.l1:
	tst.b	(a0)
	beq.s	.end
	clr.b	(a0)+
	bra.s	.l1
.end:
	move.l	(sp)+,a0
	rts
	; #] Strclr:
	; #[ Strlen:
__strlen:
	move.l	a0,-(sp)
	moveq	#-1,d0
.l1:
	tst.b	(a0)+
	dbeq	d0,.l1
	not.l	d0
	move.l	(sp)+,a0
	rts
	; #] Strlen:
	; #[ Strcpy:
;a0=@source
;a1=@dest
;OUT:
;d0=nb de car copies (y compris 0)
__strcpy:
	movem.l	a0-a1,-(sp)
	moveq	#0,d0
.l1:
	REPT	9
	addq.w	#1,d0
	move.b	(a0)+,(a1)+
	beq.s	.end
	ENDR
	addq.w	#1,d0
	move.b	(a0)+,(a1)+
	bne.s	.l1
;.l1:
;	addq.w	#1,d0
;	move.b	(a0)+,(a1)+
;	bne.s	.l1
.end:
	movem.l	(sp)+,a0-a1
	rts
	; #] Strcpy:
	; #[ Strcat:
;a0=@source
;a1=@dest
__strcat:
	exg	a0,a1
	bsr.s	__strlen
	exg	a0,a1
	bra.s	__strcpy
	; #] Strcat:
	; #[ build_one_string:
;a0=string
;a1=format
;a2=buffer
__build_one_string:
	move.l	a0,-(sp)
	move.l	a1,-(sp)
	move.l	a2,a0
	bsr	__sprintf
	addq.w	#8,sp
	rts
	; #] build_one_string:
	; #[ Init Buffer:

__init_buffer:
	move.l	a0,-(sp)
	move.w	line_len(a6),d0
	addq.w	#1,d0
	lsr.w	#2,d0
	subq.w	#1,d0
.1:
	clr.l	(a0)+
	dbf	d0,.1
	move.l	(sp)+,a0
	rts

	; #] Init Buffer:
	; #[ sprintf:
SPRINTF_MAX_CHARS	equ	36
;--- INPUT ---
;tout dans la pile
;sf a0=@ dest

;--- IN ---
;a5=ptr dest
;a4=ptr incremental dest
;a3=@ source =(sp)
;a2=ptr incremental sur les arguments dans la pile

;(d4='%')
;d5='0'
;d6=caractere de remplissage ('0',' ')
;d7=compteur de taille du nombre
;>0 -> compteur
	;-no optimise -> complete par des 0 ou espaces
	;-optimise
;-1 -> pas de limite (format maximum)

;--- OUTPUT ---
;ds a0 l'@ dest

__sprintf:
	link	a2,#0
	movem.l	d3-d7/a2-a5,-(sp)
	addq.w	#8,a2

	move.l	a0,a5

	move.l	a5,a4
	move.l	(a2)+,a3
	sf	sprintf_pack_count(a6)
	moveq	#'0',d5
;	moveq	#'%',d4
.more_char:
	move.b	(a3)+,d0
	beq	.fini
	cmp.b	#'%',d0
	beq.s	.pourcent
.poke_dest
	move.b	d0,(a4)+
	bra.s	.more_char
.pourcent:
	move.b	(a3),d0

	;echappement du %
	cmp.b	#'%',d0
	bne.s	.not_percent
	tst.b	(a3)+
	bra.s	.poke_dest
.not_percent:

	moveq	#SPRINTF_MAX_CHARS,d7
	;default is '0'
	move.l	d5,d6
	sf	sprintf_hex_flag(a6)
	sf	sprintf_dec_flag(a6)
	sf	sprintf_bin_flag(a6)
	sf	sprintf_float_flag(a6)
;	sf	sprintf_char_flag(a6)
	sf	sprintf_ptr_flag(a6)
	sf	sprintf_vdec_flag(a6)

	;--- PRE-PRE-PREMIERE COUCHE (ptr sur donnees :%{...%}) ---
	cmp.b	#'{',d0
	bne.s	.not_start_of_ptr
;	st	sprintf_ppack_flag(a6)
	move.l	a2,sprintf_ppack_ptr(a6)
	move.l	(a2),a2
	tst.b	(a3)+
	bra.s	.more_char
.not_start_of_ptr:
	cmp.b	#'}',d0
	bne.s	.not_end_of_ptr
	move.l	sprintf_ppack_ptr(a6),a2
	tst.b	(a3)+
	bra.s	.more_char
.not_end_of_ptr:
	;--- PRE-PREMIERE COUCHE (paquets :%[#...%]) ---
	cmp.b	#'[',d0
	bne.s	.not_start_of_pack
	tst.b	(a3)+
	move.b	(a3),d0
	bsr	get_2d_number
	bmi.s	.not_start_of_pack
	;ds d0 le nb de repetitions
	subq.b	#1,d0
	move.b	d0,sprintf_pack_count(a6)
	move.l	a3,sprintf_pack_ptr(a6)
	bra	.more_char
.not_start_of_pack:
	cmp.b	#']',d0
	bne.s	.not_end_of_pack
	lea	sprintf_pack_count(a6),a0
	tst.b	(a0)
	bne.s	.do_pack
	tst.b	(a3)+
	bra	.more_char
.do_pack:
	subq.b	#1,(a0)
	move.l	sprintf_pack_ptr(a6),a3
	bra	.more_char
.not_end_of_pack:
	;--- PREMIERE COUCHE (format d'optimisation:0,' ',=) ---
	;tester '0' pour non optimise_address
	cmp.b	d5,d0
	bne.s	.not_zero
	sf	optimise_address(a6)
	bra.s	.inc_one_0
.not_zero:
	;tester ' ' pour non optimise_address
	cmp.b	#' ',d0
	bne.s	.not_space
	sf	optimise_address(a6)
	bra.s	.inc_one_0
.not_space:
	;tester '=' pour optimise address
	cmp.b	#'=',d0
	bne.s	.not_egal
	st	optimise_address(a6)
	move.l	d5,d0
.inc_one_0:
	move.b	d0,d6
	tst.b	(a3)+
	move.b	(a3),d0
.not_egal:
	;--- DEUXIEME COUCHE (taille du nombre:dd) ---
	bsr	get_2d_number
	bmi.s	.not_digit
	move.b	d0,d7
.not_digit:
	move.b	(a3),d0
	;--- TROISIEME COUCHE (format du nombre:spDlbw) ---
	;chaine
	cmp.b	#'s',d0
	beq	.sprint_string

	;flottant packe
	cmp.b	#'p',d0
	beq	.sprint_packed

	;double (en fait extended)
	cmp.b	#'D',d0
	beq	.sprint_double

	cmp.b	#'l',d0
	seq	sprintf_long_flag(a6)
	cmp.b	#'b',d0
	seq	sprintf_byte_flag(a6)

	; default case
	cmp.b	#'w',d0
	beq.s	.inc_one

	tst.b	sprintf_byte_flag(a6)
	bne.s	.inc_one
	tst.b	sprintf_long_flag(a6)
	beq.s	.dont_inc
.inc_one:
	tst.b	(a3)+
.dont_inc:
	;--- QUATRIEME COUCHE (signe du nombre:S) ---
	move.b	(a3)+,d0
	cmp.b	#'S',d0
	seq	sprintf_signed_flag(a6)
	bne.s	.not_signed
	move.b	(a3)+,d0
.not_signed:
	;--- CINQUIEME COUCHE (base du nombre:dxbcC) ---
	move.l	a4,-(sp)
	lea	sprintf_line(a6),a4

	lea	hex_table(pc),a0
	moveq	#0,d4
	moveq	#0,d3
	moveq	#0,d2

	cmp.b	#'d',d0
	beq	.sprint_dec

	cmp.b	#'x',d0
	seq	sprintf_hex_flag(a6)
	cmp.b	#'b',d0
	seq	sprintf_bin_flag(a6)
	cmp.b	#'C',d0
	seq	sprintf_zchar_flag(a6)
;	cmp.b	#'c',d0
;	seq	sprintf_char_flag(a6)

	;tester @ pour @
	bsr	.test_arobace
	tst.b	sprintf_long_flag(a6)
	beq.s	.not_long2
	tst.b	sprintf_ptr_flag(a6)
	bne.s	.dont_destack_long
	move.l	(a2)+,d0
.dont_destack_long:
	bsr	l_to_asc
	bra.s	.copy_number
.not_long2:
	tst.b	sprintf_ptr_flag(a6)
	bne.s	.dont_destack_word
	move.w	(a2)+,d0
.dont_destack_word:
	tst.b	sprintf_byte_flag(a6)
	beq.s	.not_byte2
	bsr	b_to_asc
	bra.s	.copy_number
.not_byte2:
	bsr	w_to_asc
;	bra.s	.copy_number
.copy_number:
	clr.b	(a4)
	move.l	a4,d0
	lea	sprintf_line(a6),a0
	;que le nombre,que ouais
	sub.l	a0,d0
	sub.b	d7,d0
	bmi.s	.ok
	sub.w	d7,a4
	move.l	a4,a0
.ok:
	move.l	(sp)+,a4
	tst.b	optimise_address(a6)
	bne.s	.no_zero
	;tester si espace ou 0
.l50:
	move.b	(a0)+,d0
	beq.s	.poke_zero
	cmp.b	d5,d0
	bne.s	.same
	move.b	d6,(a4)+
	bra.s	.l50
.same:
	move.b	d0,(a4)+
	bra.s	.poke_all
.no_zero:
	move.b	(a0)+,d0
	beq.s	.poke_one_zero
	cmp.b	d5,d0
	beq.s	.no_zero
	tst.b	sprintf_dec_flag(a6)
	beq.s	.not_minus
	cmp.b	#'-',d0
	bne.s	.not_minus
	move.b	d0,(a4)+
	bra.s	.no_zero
.not_minus:	
	move.b	d0,(a4)+
.poke_all:
.l60:
	move.b	(a0)+,(a4)+
	beq.s	.out60
	dbf	d7,.l60
;	bra.s	.go_more_char
.out60:
	tst.b	-(a4)
.go_more_char:
	tst.b	sprintf_ptr_flag(a6)
	beq	.more_char
	tst.l	(a2)+
	bra	.more_char
.poke_one_zero:
	;si char zero, pas poker
	tst.b	sprintf_zchar_flag(a6)
	bne.s	.go_more_char
	move.b	d5,(a4)+
	bra.s	.go_more_char
.poke_zero:
	move.b	-2(a0),d0
	cmp.b	d5,d0
	bne.s	.go_more_char
	move.b	d5,-1(a4)
	bra.s	.go_more_char
	;--- DECIMAL ---
.sprint_dec:
	st	sprintf_dec_flag(a6)
	bsr	.test_arobace
	tst.b	sprintf_ptr_flag(a6)
	beq.s	.normal_dec	
	move.l	a0,-(sp)
;	move.l	(a2),a1
	move.l	(a2)+,a0
	_JSR	read_baderr
	move.l	(sp)+,a0
	bne.s	.unreadable_dec
;	addq.w	#4,a2
	move.l	-4(a2),a1
	move.l	(a1),d0
	tst.b	sprintf_long_flag(a6)
	bne.s	.dec_long
	clr.w	d0
	swap	d0
	tst.b	sprintf_byte_flag(a6)
	beq.s	.dec_word
	andi.w	#$ff,d0
	bra.s	.dec_byte
.normal_dec:
	move.l	(a2),d0
	;long decimal
	tst.b	sprintf_long_flag(a6)
	beq.s	.not_long
	addq.w	#4,a2
	bra.s	.dec_long
.not_long:
	addq.w	#2,a2
	clr.w	d0
	swap	d0
	;word decimal
	tst.b	sprintf_byte_flag(a6)
	beq.s	.dec_word
	;byte decimal
	andi.w	#$ff,d0
.dec_byte:
	tst.b	sprintf_signed_flag(a6)
	beq.s	.all_dec
	tst.b	d0
	bpl.s	.all_dec
	move.b	#'-',(a4)+
	neg.b	d0
	bra.s	.all_dec
.dec_word:
	tst.b	sprintf_signed_flag(a6)
	beq.s	.all_dec
	tst.w	d0
	bpl.s	.all_dec
	move.b	#'-',(a4)+
	neg.w	d0
	bra.s	.all_dec
.dec_long:
	tst.b	sprintf_signed_flag(a6)
	beq.s	.all_dec
	tst.l	d0
	bpl.s	.all_dec
	move.b	#'-',(a4)+
	neg.l	d0
.all_dec:
	;sinon ca va delirer
	sf	sprintf_ptr_flag(a6)
	;provisoirement ne sera traite qu'en word
	bsr	lw_to_hex
.unreadable_dec:
	bsr	l_to_asc
	bra	.copy_number
.sprint_double:
	addq.w	#1,a3
	cmp.b	#'@',(a3)
	bne.s	.no_double_ptr
	addq.w	#1,a3
	move.l	(a2)+,a0
;	bsr	test_baderr
;	bmi.s	.string_baderr
	movem.l	(a0),d0-d2
	bsr	get_double
	bra.s	.poke_any_string
.no_double_ptr:
	movem.l	(a2)+,d0-d2
	bsr	get_double
	bra.s	.poke_any_string
.sprint_packed:
	addq.w	#1,a3
	movem.l	(a2)+,d0-d2
	bsr	get_packed
	bra.s	.poke_any_string
.sprint_string:
	addq.w	#1,a3
	bsr	.test_arobace
	move.l	(a2)+,a0
.poke_any_string:
	move.w	#200,d0
	cmp.b	#SPRINTF_MAX_CHARS,d7
	beq.s	.dont_touch
	move.w	d7,d0
.dont_touch:
.l1:
	tst.b	sprintf_ptr_flag(a6)
	beq.s	.normal
	movem.l	d0/a0,-(sp)
	move.l	a0,a1
	bsr	test_if_readable5
	movem.l	(sp)+,d0/a0
	tst.b	readable_buffer(a6)
	beq.s	.normal
	move.b	#'*',(a4)+
	bra	.more_char
.normal:
	move.b	(a0)+,(a4)+
	beq.s	.out1
	dbf	d0,.l1
	bra.s	.dont_touch2
.out1:
	cmp.b	#SPRINTF_MAX_CHARS,d7
	beq.s	.dont_touch2
	tst.b	-(a4)
	moveq	#' ',d1
.l2:
	move.b	d1,(a4)+
	dbf	d0,.l2
.dont_touch2:
	tst.b	-(a4)
	bra	.more_char
.fini:
	;zero final obligatoire
	clr.b	(a4)
	;nb de chars
	move.l	a4,d0
	sub.l	a5,d0
	move.l	a5,a0
	movem.l	(sp)+,d3-d7/a2-a5
	unlk	a2
	rts

.test_arobace:
	cmp.b	#'@',(a3)
	bne.s	.not_arobace
	tst.b	(a3)+
	st	sprintf_ptr_flag(a6)
.not_arobace:
	rts
hex_table:	dc.b	"0123456789ABCDEF"
	even

get_double:
	lea	.no_text(pc),a0
	and.w	#$3f,d0
	rts
	
;	lea	_fmovecr_comment_table,a1
.l1:
	move.w	(a1)+,d1
	bmi.s	.not_found
	cmp.w	d0,d1
	beq.s	.found
	addq.w	#4,a1
	bra.s	.l1
.found:
	move.l	(a1),a0
.not_found:
	rts
.no_text:	dc.b	"xx",0
	even

;--- IN ---
;d0=premier digit potentiel
;a3 pointe sur le buffer

;--- OUT ---
;d0 contient le nb
;d5 contient '0'
get_2d_number:
	moveq	#0,d1
	;tester un nb entre 1 et 9
	cmp.b	#'1',d0
	blt.s	.abort
	cmp.b	#'9',d0
	bgt.s	.abort
	move.b	d0,d1
	sub.b	d5,d1
	tst.b	(a3)+
	move.b	(a3),d0
	cmp.b	#'1',d0
	blt.s	.one_digit
	cmp.b	#'9',d0
	bgt.s	.one_digit
	mulu	#10,d1
	sub.b	d5,d0
	add.b	d0,d1
	tst.b	(a3)+
.one_digit:
	move.b	d1,d0
	rts
.abort:
	moveq	#-1,d0
	rts
;-- INTERNAL ---
;d3:
;d4:calcul decimal
lw_to_hex:
	movem.l	d3-d7,-(sp)
	move.l	d0,d5
	;8 premiers digits
	moveq	#0,d7
	;4 digits suivants
	moveq	#0,d6

	;4 premiers digits
	bsr.s	get_4dd
	move.w	d0,d7
	cmp.l	#9999,d5
	bls.s	.end
	;test _div
	move.l	#10000,d0
	move.l	d5,d1
	_JSR	_div
	move.l	d1,d5

	;old:
;	divu	#10000,d5
;	andi.l	#$ffff,d5

	;4 digits suivants
	move.l	d5,d0
	bsr.s	get_4dd
	swap	d7
	move.w	d0,d7
	swap	d7
	;ds d7 8 digits
	cmp.l	#9999,d5
	ble.s	.end
	st	sprintf_vdec_flag(a6)

	move.l	#10000,d0
	move.l	d5,d1
	_JSR	_div
	move.l	d1,d5

;	divu	#10000,d5
;	andi.l	#$ffff,d5
	move.l	d5,d0
	bsr.s	get_4dd
	;d6 contient 4 digits
	move.w	d0,d6
.end:
	;8 digits
	move.l	d7,d0
	;4 digits
	move.l	d6,d1
	movem.l	(sp)+,d3-d7
	rts

;d0=valeur a traduire
get_4dd:
	movem.l	d3-d4,-(sp)
	moveq	#0,d3
	moveq	#0,d4
	moveq	#1,d1
	moveq	#SPRINTF_MAX_CHARS-1,d2
.boucl_calci:
	btst	#0,d0
	beq.s	.pas_ca

	andi	#%1111,ccr
	abcd	d1,d3

	swap	d1
	abcd	d1,d4
	swap	d1
.pas_ca:
	andi	#%1111,ccr
	abcd	d1,d1

	swap	d1
	abcd	d1,d1		; add juste la decimal
	swap	d1

	lsr.l	#1,d0

	dbf	d2,.boucl_calci

	move.l	d3,d0
	lsl.l	#8,d4
	add.l	d4,d0

	;d0.w contient 4 digits decimaux
	movem.l	(sp)+,d3-d4
	rts
l_to_asc:
	move.l	d0,d4
	;si dec,d1 contient le reste des digits
	tst.b	sprintf_dec_flag(a6)
	beq.s	.normal
	tst.b	sprintf_vdec_flag(a6)
	beq.s	.normal
;	tst.b	sprintf_signed_flag(a6)
;	beq.s	.not_negative
;	move.b	#'-',(a4)+
;.not_negative:
	move.l	d1,d0
	bsr.s	w_to_asc
.normal:
	move.l	d4,d0
	swap	d0
	bsr.s	w_to_asc
	move.w	d4,d0
;	bsr.s	w_to_asc
;	rts
w_to_asc:
	move.w	d0,d3
	lsr.w	#8,d0
	bsr.s	b_to_asc
	move.w	d3,d0
;	bsr.s	b_to_asc
;	rts
b_to_asc:
	;@
	tst.b	sprintf_ptr_flag(a6)
	beq.s	.normal
	move.l	(a2),a1
	bsr	test_if_readable5
	addq.l	#1,(a2)
	tst.b	readable_buffer(a6)
	beq.s	.readable
	move.b	#'*',(a4)+
	move.b	#'*',(a4)+
	bra.s	.end
.readable:
	move.b	(a1),d0
.normal:
	;dec
	tst.b	sprintf_dec_flag(a6)
	bne.s	.hexa
	;hexa
	tst.b	sprintf_hex_flag(a6)
	beq.s	.not_hex
.hexa:
	move.w	d0,d1
	lsr.w	#4,d0
	andi.w	#$f,d0
	move.b	(a0,d0.w),(a4)+
	move.w	d1,d0
	andi.w	#$f,d0
	move.b	(a0,d0.w),(a4)+
	tst.b	sprintf_dec_flag(a6)
	beq.s	.end
	;
	;
	;
	bra.s	.end
.not_hex:
	;binaire
	tst.b	sprintf_bin_flag(a6)
	beq.s	.not_bin
	movem.l	d5-d6,-(sp)
	bsr.s	b_inv_reg
	move.w	d0,d5
	moveq	#8-1,d6
.l1:
	move.w	d5,d0
	andi.w	#%00000001,d0
	move.b	(a0,d0.w),(a4)+
	lsr.w	#1,d5
	dbf	d6,.l1
	move.b	#'.',(a4)+
	movem.l	(sp)+,d5-d6
	bra.s	.end
.not_bin:
	;zchar
	tst.b	sprintf_zchar_flag(a6)
	beq.s	.no_zero
	move.b	d0,(a4)+
	bne.s	.end
	subq.w	#1,a4
	bra.s	.end
.no_zero:
	;char=type par defaut
	move.b	d0,(a4)+
	bne.s	.end
	move.b	#' ',-1(a4)
.end:
	rts
b_inv_reg:
	movem.w	d1-d3,-(sp)
	moveq	#8-1,d1
	moveq	#0,d2
	moveq	#0,d3
.l1:
	btst	d2,d0
	beq.s	.clear
	bset	d1,d3
.clear:
	addq.w	#1,d2
	dbf	d1,.l1
	move.w	d3,d0
	movem.w	(sp)+,d1-d3
	rts
	; #] sprintf:
	; #[ Ask menu:
;-- Input --
;a2=chaine menu
;-- In --
;a5=a2
;-- Output --
;d0.l=
;-1 = Esc
;>0 = # de l'option choisie
__ask_menu:
	movem.l	d3/a3-a5,-(sp)
	move.l	a2,a5

	;construire la table des touches
	lea	menu_legal(a6),a4
	move.l	a4,a1
.l1:
	move.b	(a2)+,d0
	beq.s	.out1
	cmp.b	#')',d0
	bne.s	.l1
	move.b	-2(a2),(a1)+
	bra.s	.l1
.out1:
	clr.b	(a1)
	;afficher le menu avec un signe de demande
	move.l	a5,a2
	lea	menu_format_text,a0
	_JSR	print_question

	;play mac ?
	tst.b	play_mac_flag(a6)
	beq.s	.new_char
	move.l	cur_play_mac_addr(a6),a0
	_JSR	pskip
	moveq	#0,d3
	move.b	(a0)+,d3
	sub.w	#'0',d3
	move.l	a0,cur_play_mac_addr(a6)
	bra.s	.end
.flash:
	_JSR	flash
	;boucler
.new_char:
	moveq	#0,d3
	_JSR	get_char
	cmp.b	#$1b,d0
	beq.s	.abort
	cmp.l	#$01610000,d0
	beq.s	.abort
	cmpi.w	#'a',d0
	blt.s	.majuscule
	subi.w	#'a'-'A',d0
.majuscule:
	move.l	a4,a1
.l2:
	addq.l	#1,d3
	move.b	(a1)+,d1
	beq.s	.flash
	cmp.b	d1,d0
	bne.s	.l2
	bra.s	.end
.abort:
	moveq	#0,d3
.end:
	move.w	x_pos(a6),-(sp)
	clr.w	x_pos(a6)
	_JSR	clr_c_line
	move.w (sp)+,x_pos(a6)
	;enregistrer
	tst.b	rec_mac_flag(a6)
	beq.s	.real_end
	move.l	cur_rec_mac_addr(a6),a0
	move.b	d3,d0
	add.b	#'0',d0
	move.b	d0,(a0)+
	move.b	#' ',(a0)+
	move.l	a0,cur_rec_mac_addr(a6)
	addq.l	#2,cur_rec_mac_size(a6)
.real_end:
	move.l	d3,d0
	bne.s	.real_end2
	moveq	#-1,d0
.real_end2:
	movem.l	(sp)+,d3/a3-a5
	rts

	; #] Ask menu:
	; #[ Tri:
;Input:
;d0=nb d'elements du tableau
;d1=ptr vers tableau
;a0=ptr sur routine de comparaison
;a1=ptr sur routine d'inversion
__tri:	movem.l	d3-d7/a2-a5,-(sp)
	move.l	a0,a4
	move.l	a1,a5
	moveq	#0,d2
	move.l	d0,d3
	beq.s	.end
	subq.l	#1,d3
	beq.s	.end
	move.l	d1,a0
	pea	.end(pc)
	move.l	sp,tri_sp(a6)
	bra.s	___tri
.end:	movem.l	(sp)+,d3-d7/a2-a5
	rts

___tri:				; d2.l=debut, d3.l=fin
	cmp.l	check_stack_addr(a6),sp
	ble.s	.skip
	move.l	d2,d4		; d4=pivot
	move.l	d2,d5		; d5=indice1
	move.l	d3,d6		; d6=indice2
.boucle:
	jsr	(a4)
	bhi.s	.inf
	jsr	(a5)
	move.l	d5,d0
	add.l	d6,d0
	sub.l	d4,d0
	move.l	d0,d4
.inf:	cmp.l	d4,d5
	beq.s	.dec
	addq.l	#1,d5
	bra.s	.l1
.dec:	subq.l	#1,d6
.l1:	cmp.l	d5,d6
	bne.s	.boucle

	move.l	d5,d0
	subq.l	#1,d0
	cmp.l	d0,d2
	bge.s	.sup
	movem.l	d2-d6,-(sp)
	move.l	d0,d3
	bsr.s	___tri
	movem.l	(sp)+,d2-d6
.sup:	move.l	d6,d0
	addq.l	#1,d0
	cmp.l	d3,d0
	bge.s	.end
	movem.l	d2-d6,-(sp)
	move.l	d0,d2
	bsr.s	___tri
	movem.l	(sp)+,d2-d6
.end:	rts
.skip:	move.l	tri_sp(a6),sp
	;error
	rts

;d0=nb d'elements du tableau
;d1=ptr vers tableau
;a0=ptr sur routine de comparaison
;a1=long a comparer
__trouve:
	movem.l	d3-d7/a2-a5,-(sp)
	move.l	d0,d7
	beq.s	.not_found

	move.l	a0,a4
	move.l	a1,d3
	move.l	d1,a0

	subq.l	#1,d0
	bne.s	.plus_dun
	jsr	(a4)
	beq.s	.found
	bra.s	.not_found	; pas exact mais effet identique
.plus_dun:
	moveq	#0,d0
	jsr	(a4)
	bhi.s	.not_found
.check_end:
	move.l	d7,d0
	subq.l	#1,d0
	jsr	(a4)
	beq.s	.found
	bls.s	.not_found
.in_tree:
	moveq	#0,d5
.l1:
	cmp.l	d7,d5
	bhi.s	.just_upper
	move.l	d5,d4
	add.l	d7,d4
	lsr.l	#1,d4
	move.l	d4,d0
	jsr	(a4)	
	bhi.s	.plus
	beq.s	.found
	move.l	d4,d5
	addq.l	#1,d5
	bra.s	.l1
.plus:	move.l	d4,d7
	subq.l	#1,d7
	bmi.s	.not_found
;	bmi.s	.just_upper
	bra.s	.l1
.found:
	add.l	d0,a0
	moveq	#0,d0
	bra.s	.end
;pas exact, mais la plus proche:
.just_upper:
	move.l	d4,d0
	jsr	(a4)
	bls.s	.almost_found
	subq.l	#1,d4
	bpl.s	.just_upper
	bra.s	.not_found
.almost_found:
	add.l	d0,a0
	moveq	#1,d0
	bra.s	.end
;hors de la table ou pas d'elements
.not_found:
	moveq	#-1,d0
.end:	movem.l	(sp)+,d3-d7/a2-a5
	rts

;comp_breaks:		*en test
;	;tri par ordre de pc croissant
;	movem.l	d0-d1,-(sp)
;	move.l	breaks_addr(a6),a0
;	asl.w	#4,d0
;	asl.w	#4,d1
;	lea	(a0,d0.w),a1
;	lea	(a0,d1.w),a2
;	cmpm.l	(a1)+,(a2)+
;	movem.l	(sp)+,d0-d1
;	rts
;
;inv_breaks:		*en test
;	movem.l	d0-d1,-(sp)
;	move.l	breaks_addr(a6),a0
;	asl.w	#4,d0
;	asl.w	#4,d1
;	lea	0(a0,d0.w),a1
;	lea	0(a0,d1.w),a2
;
;	lea	sprintf_line(a6),a3
;	REPT	4
;	move.l	(a1)+,(a3)+
;	ENDR
;
;	lea	0(a0,d0.w),a1
;	REPT	4
;	move.l	(a2)+,(a1)+
;	ENDR
;
;	lea	0(a0,d1.w),a2
;	lea	sprintf_line(a6),a3
;	REPT	4
;	move.l	(a3)+,(a2)+
;	ENDR
;
;	movem.l	(sp)+,d0-d1
;	rts
	; #] Tri:
	; #[ Form_do:
FORMDO_DRAW_OFF	equ	0
FORMDO_UP_OFF	equ	4
FORMDO_DN_OFF	equ	8
FORMDO_PGUP_OFF	equ	12
FORMDO_PGDN_OFF	equ	16
FORMDO_HOME_OFF	equ	20
FORMDO_SFTHOME_OFF	equ	24
FORMDO_INIT_OFF	equ	28
FORMDO_TTL_OFF	equ	32
;FORM_DO_HOME	MACRO
;	move.l	2(sp),a0
;	add.l	20(a0),a0
;	jsr	(a0)
;	ENDM
__form_do:
	move.l	a0,-(sp)
	add.l	FORMDO_TTL_OFF(a0),a0
	move.l	a0,big_title_addr(a6)
	_JSR	open_big_window
	move.l	big_window_coords(a6),x_pos(a6)
	;init
	move.l	(sp),a0
	add.l	28(a0),a0
	jsr	(a0)

.redraw_one_page:
	;draw page
	move.l	(sp),a0
	add.l	(a0),a0
	jsr	(a0)
.get_char:
	_JSR	get_char
	move.l	(sp),a0
	cmp.b	#$1b,d0
	beq.s	.end
	bclr	#5,d0
	IFEQ	bridos
	cmp.b	#'S',d0
	beq	.print_to_disk
	cmp.b	#'P',d0
	beq	.print_to_prt
	ENDC	;de bridos
	cmp.b	#'E',d0
	beq.s	.eval

	swap	d0
	IFNE	AMIGA
	cmp.w	#$0862,d0
	bne.s	.noscrsave
	movem.l	d0-a6,-(sp)
	jsr	screen_dump
	movem.l	(sp)+,d0-a6
	bra.s	.get_char
.noscrsave:
	ENDC	;AMIGA
	cmp.w	#$0039,d0
	beq.s	.shift_down
	cmp.w	#$0139,d0
	beq.s	.shift_up
	cmp.w	#$0060,d0
	beq.s	.up
	cmp.w	#$0160,d0
	beq.s	.down
	cmp.w	#$0048,d0
	beq.s	.up
	cmp.w	#$0050,d0
	beq.s	.down
	cmp.w	#$0148,d0
	beq.s	.shift_up
	cmp.w	#$0150,d0
	beq.s	.shift_down
	cmp.w	#$0047,d0
	beq.s	.home
	cmp.w	#$0147,d0
	beq.s	.shift_home
	;sft undo
	cmp.w	#$0161,d0
	beq.s	.end
	bra	.get_char
.end:
	_JSR	close_big_window
	;juste pour depiler
	move.l	(sp)+,a0
	rts
.eval:
	_JSR	_ask_expression
	bra	.get_char
.up:
	add.l	4(a0),a0
	bra.s	.execute
.down:
	add.l	8(a0),a0
	bra.s	.execute
.shift_up:
	add.l	12(a0),a0
	bra.s	.execute
.shift_down:
	add.l	16(a0),a0
	bra.s	.execute
.home:
	add.l	20(a0),a0
	bra.s	.execute
.shift_home:
	add.l	24(a0),a0
;	bra.s	.execute
.execute:
	jsr	(a0)
	bmi	.get_char
	bra	.redraw_one_page
	IFEQ	bridos
.print_to_disk:
	suba.l	a0,a0
	st	no_eval_flag(a6)
	lea	ask_save_text,a2
	_JSR	get_expression
	bmi	.get_char
	bgt	.get_char
	move.l	a0,a2
	_JSR	create_file
	bmi	.create_error

	move.l	d0,output_stream(a6)

	move.l	a2,a0
	lea	piped_file(a6),a1
	bsr	strcpy

	;save pour le pipe
	move.l	device_number(a6),-(sp)

	pea	piped_file(a6)
	pea	saving_file_text
	lea	line_buffer(a6),a2
	move.l	a2,a0
	bsr	__sprintf
	_JSR	print_result
	addq.w	#8,sp

	;pipe
	move.l	output_stream(a6),device_number(a6)

	;premiere ligne = ; filename
	pea	piped_file(a6)
	pea	form_do_filename_format
	lea	line_buffer(a6),a2
	move.l	a2,a0
	bsr	__sprintf
	addq.w	#8,sp
	_JSR	print_instruction

	;home
	move.l	4(sp),a0
	add.l	20(a0),a0
	jsr	(a0)
.again2:
	move.l	4(sp),a0
	add.l	(a0),a0
	jsr	(a0)
	tst.l	device_number(a6)
	beq.s	.write_error
	tst.l	d0
	bmi.s	.finish2
	move.l	4(sp),a0
	add.l	16(a0),a0
	jsr	(a0)
	bpl.s	.again2
.finish2:
	move.l	output_stream(a6),d0
	_JSR	close_file
	move.l	(sp)+,device_number(a6)
	pea	piped_file(a6)
	pea	file_saved2_text
	lea	line_buffer(a6),a2
	move.l	a2,a0
	bsr	__sprintf
	addq.w	#8,sp
	_JSR	print_result
	bra.s	.home2
.create_error:
	lea	create_error_text,a2
	_JSR	print_error
	bra	.get_char
.write_error:
	move.l	output_stream(a6),d0
	_JSR	close_file
	move.l	(sp)+,device_number(a6)
	lea	write_error2_text,a2
	_JSR	print_error
	;home
.home2:
	move.l	big_window_coords(a6),x_pos(a6)
	move.l	(sp),a0
	add.l	20(a0),a0
	jsr	(a0)
	;draw
	move.l	(sp),a0
	add.l	(a0),a0
	jsr	(a0)
	bra	.get_char
.print_to_prt:
	move.l	device_number(a6),-(sp)
	move.l	#PRINTER_OUTPUT,device_number(a6)
	;home
	move.l	4(sp),a0
	add.l	20(a0),a0
	jsr	(a0)
.again3:
	;draw page
	move.l	4(sp),a0
	add.l	(a0),a0
	jsr	(a0)
	tst.l	device_number(a6)
	beq.s	.prt_error
	tst.l	d0
	bmi.s	.finish3
	;pgdn
	move.l	4(sp),a0
	add.l	16(a0),a0
	jsr	(a0)
	tst.l	device_number(a6)
	beq.s	.prt_error
	tst.l	d0
	bpl.s	.again3
.finish3:
	move.l	(sp)+,device_number(a6)
	lea	prt_finished_text,a2
	_JSR	print_result
	bra.s	.home2
.prt_error:
	move.l	(sp)+,device_number(a6)
	lea	prt_not_ready_text,a2
	_JSR	print_error
	bra.s	.home2
	ENDC	;de bridos
	; #] Form_do:
;  #] Miscellaneous routines:
;----------------desassemblage d'une ligne de code----------------
;  #[ Display break:
display_break:
;	sf	operande_flag(a6)
	tst.b	dont_remove_break_flag(a6)
	beq.s	.end
	move.l	dont_remove_break_long(a6),a1
	bsr.s	_display_break
	sf	dont_remove_break_flag(a6)
.end:	rts

;P pour permanent
;Input:
;a0=ascii buffer
;a1=break struct
;Output:
;a0=new end of ascii buffer
_display_break:
	movem.l	d0-d2,-(sp)
	move.l	a0,-(sp)

	move.l	BREAK_EVAL(a1),-(sp)
	move.w	BREAK_NUMBER(a1),-(sp)
	move.w	BREAK_VECTOR(a1),d0
	moveq	#0,d1
	btst	#BREAK_IS_PERMANENT,d0
	beq.s	.not_permanent
	moveq	#'P',d1
.not_permanent:
	move.w	d1,-(sp)
	pea	.display_break_format(pc)
	bsr	_sprintf	
	lea	12(sp),sp

	move.l	(sp)+,a0
	bsr	__strlen
	add.w	d0,a0
	movem.l	(sp)+,d0-d2
	rts
.display_break_format:	dc.b	" [%=bC%=x:%s]",0
	even
;  #] Display break:

treat_instruction5:	bra	treat_instruction4
_sprintf:	bra	__sprintf
_form_do:	bra	__form_do
_tri:	bra	__tri
_trouve:	bra	__trouve
_strclr:	bra	__strclr
_strcpy:	bra	__strcpy
_strlen:	bra	__strlen
_strcat:	bra	__strcat
_sscanf:	bra	__sscanf
_build_one_string:	bra	__build_one_string
_init_buffer:	bra	__init_buffer
_ask_menu:	bra	__ask_menu
;  #[ Disasm:
	include	"disasmxx.s"
;disassemble_line:
;	_JMP	_disassemble_line
;  #] Disasm:
sprintf:	bra	_sprintf
form_do:	bra	_form_do
tri:	bra	_tri
trouve:	bra	_trouve
strclr:	bra	_strclr
strcpy:	bra	_strcpy
strlen:	bra	_strlen
strcat:	bra	_strcat
sscanf:	bra	_sscanf
build_one_string:	bra	_build_one_string
init_buffer:	bra	_init_buffer
treat_instruction4:	bra	treat_instruction3
ask_menu:	bra	_ask_menu
;  #[ Watch subroutine:[W] dis src ins

watch_subroutine:
 bsr get_noaddr_curwind
 beq.s .dis
 IFNE sourcedebug
 cmp.w #SRCWIND_TYPE,d1
 beq.s .dis
 cmp.w #VARWIND_TYPE,d1
 beq watch_var
 cmp.w #INSWIND_TYPE,d1
 beq watch_inspect
 ENDC ;de sourcedebug
 bra.s .end
.dis:
 not.b watch_subroutine_flag(a6)
 beq.s .return
 move.l device_number(a6),-(sp)
 clr.l device_number(a6)
 move.l pc_buf(a6),a1
	IFNE	sourcedebug
	move.l	a1,a0
	_JSR	get_next_code_addr
	;pas d'erreur de CCR
	move.l	d1,a1
	bgt.s	.in_source
	move.l	pc_buf(a6),a1
.in_source:
	ENDC	;de sourcedebug
 move.l a1,test_instruction(a6)
 lea line_buffer(a6),a0
 bsr disassemble_line
 lea instruction_descriptor(a6),a5
 tst.w _I_branchf(a5)
 beq.s .no_watch
 bsr get_curwind
 move.w d2,watch_subroutine_window(a6)
 move.l a1,watch_subroutine_old_value(a6)
 move.l _I_branchaddr(a5),a0
 bsr put_curwind_addr
 move.l (sp)+,device_number(a6)
 bra redraw_curwind
.no_watch:
 not.b watch_subroutine_flag(a6)
 move.l (sp)+,device_number(a6)
.end:
 rts
.return:
 move.w watch_subroutine_window(a6),d0
 move.w d0,-(sp)
 move.l watch_subroutine_old_value(a6),a0
 bsr put_wind_addr
 move.w (sp)+,d0
 bra redraw_inside_window

	IFNE	sourcedebug
;si type sauve=var, alors repasser en var
watch_inspect:
	lea	ins_wind_buf(a6),a1
	mulu	#_INSWIND_SIZEOF,d2
	add.w	d2,a1
	move.w	_INSWIND_OLDTYPE(a1),d1
	beq.s	.push
	cmp.w	#VARWIND_TYPE,d1
	beq.s	.pop_var
	bra.s	.pop_inspect
.push:	_JSR	src_watch_inspect
	bmi.s	.end

	move.w	#INSWIND_TYPE,_INSWIND_OLDTYPE(a2)
	move.l	a2,a0
	lea	_INSWIND_OLDINS(a2),a1
	moveq	#_INSWIND_SIZEOF/2-1,d0
.l1:	move.b	(a0)+,(a1)+
	dbf	d0,.l1

	move.l	d1,a0
	bsr	put_curinswind_addr
	bra	redraw_curwind
.end:	rts

.pop_inspect:
	;revenir a l'ancienne fenetre
	;type ins
	move.l	a1,a2
	lea	_INSWIND_OLDINS(a1),a0
	moveq	#_INSWIND_SIZEOF/2-1,d0
.l2:	move.b	(a0)+,(a1)+
	dbf	d0,.l2
	clr.w	_INSWIND_OLDTYPE(a2)
	bra	redraw_curwind_ttl

.pop_var:	move.w	d1,_GENWIND_TYPE(a0,d0.w)	;repasser en type var
	clr.w	_INSWIND_OLDTYPE(a2)	;plus de watch en inspect
	bra	redraw_curwind_ttl

;trouver la variable, setter l'@
;changer la fenetre en type inspect
;stocker ds old_inspect le type var
watch_var:
	movem.l	d7/a2-a5,-(sp)
	move.w	d2,d7
	lea	0(a0,d0.w),a5
	lea	var_wind_buf(a6),a4
	mulu	#_VARWIND_SIZEOF,d2
	add.w	d2,a4

	move.l	(a4),a0
	_JSR	src_watch_var
	bmi.s	.end
	move.w	#INSWIND_TYPE,_GENWIND_TYPE(a5)	;passer la fenetre en mode inspect
	lea	ins_wind_buf(a6),a4
	mulu	#_INSWIND_SIZEOF,d7
	add.w	d7,a4
	move.w	#VARWIND_TYPE,_INSWIND_OLDTYPE(a4)	;c'etait avant un type var
	move.l	d0,(a4)				;@ a inspecter
	clr.l	_INSWIND_ELNB(a4)			;element 0
	bsr	redraw_curwind_ttl
.end:	movem.l	(sp)+,d7/a2-a5
	rts

	ENDC	;de sourcedebug
;  #] Watch subroutine:
;  #[ Sft Watch: [Sft_W] dis src ins

sft_watch:
 bsr get_curwind
 beq.s .dis
 IFNE sourcedebug
 cmp.w #SRCWIND_TYPE,d1
 beq.s .dis
 cmp.w #INSWIND_TYPE,d1
 beq .ins
 ENDC ;de sourcedebug
 bra.s .end
.dis:
 move.l device_number(a6),-(sp)
 clr.l device_number(a6)
	IFNE	sourcedebug
	move.l	a1,-(sp)
	move.l	a1,a0
	_JSR	get_next_code_addr
	;pas d'erreur de CCR
	move.l	(sp)+,a0
	move.l	d1,a1
	bgt.s	.in_source
	move.l	a0,a1
.in_source:
	ENDC	;de sourcedebug
 move.l a1,test_instruction(a6)
 lea line_buffer(a6),a0
 bsr disassemble_line
 lea instruction_descriptor(a6),a5
 tst.w _I_branchf(a5)
 beq.s .no_watch
 move.l _I_branchaddr(a5),a0
 bsr put_curwind_addr
 move.l (sp)+,device_number(a6)
 bra redraw_curwind
.no_watch:
 move.l (sp)+,device_number(a6)
.end:
 rts
	IFNE	sourcedebug
.ins:
	lea	ins_wind_buf(a6),a1
	mulu	#_INSWIND_SIZEOF,d2
	add.w	d2,a1
	_JSR	src_watch_inspect
	bmi.s	.end
	move.l	d1,a0
	bsr	put_curinswind_addr
	bra	redraw_curwind
	ENDC	;de sourcedebug
;  #] Sft Watch:
;  #[ Disassemble:
	; #[ Disassemble:

disassemble:
	sf	pc_pointer_flag(a6)
	move.l	a0,a5
	move.w	d0,-(sp)
	lea	line_buffer(a6),a0
	bsr	init_buffer
	lea	test_instruction(a6),a1

	sf	optimise_address(a6)
	bsr	dat_to_asc_l_3	;8 cars/22
	move.b	#' ',(a0)+	;1 car
; 	sf	operande_flag(a6)
	move.l	(a1),d0
	_JSR	find_in_table2
	move.w	d0,-(sp)
	bne.s	.nf
	move.l	VAR_NAME(a2),a2
	bra.s	.copy
.nf:	lea	.dumvar(pc),a2
.copy:	moveq	#11-1,d0
	move.w	d0,d1
.l1:	move.b	(a2)+,(a0)+
	dbeq	d0,.l1
	bne.s	.notend
	subq.w	#1,a0
.notend:	sub.w	d0,d1
	moveq	#13-1,d0
	sub.w	d1,d0
	moveq	#' ',d1
.l2:	move.b	d1,(a0)+
	dbf	d0,.l2
	move.w	4(a5),d0
	sub.w	(a5),d0
	cmp.w	#38,d0
	beq.s	.12
	cmp.w	#50,d0
	blt.s	.20
	tst.b	symbols_flag(a6)
	bne.s	.4
	lea	-10(a0),a0
	bra.s	.4
.12:	lea	-14(a0),a0
	tst.w	(sp)
	bne.s	.41
	addq.w	#1,a0
	moveq	#7,d0
.40:	move.b	(a0)+,-$a(a0)
	dbf	d0,.40
	lea	-9(a0),a0
.41:	move.w	#'  ',(a0)+
	clr.l	(a0)
	clr.l	4(a0)
	clr.l	8(a0)
	bra.s	.4
.20:	lea	-$14(a0),a0
	move.w	4(a0),-2(a0)
	move.w	#'  ',(a0)+
	clr.l	(a0)
	clr.l	4(a0)
	clr.l	8(a0)
	clr.l	$c(a0)
	clr.w	$10(a0)
.4:	addq.w	#2,sp
	move.l	(a1),d0
	cmp.l	pc_buf(a6),d0
	bne.s	.3
	moveq	#3,d0
	move.b	d0,-2(a0)
	move.b	d0,pc_marker(a6)
	move.l	a0,arrow_addr(a6)
	st	pc_pointer_flag(a6)
.3:	lea	line_buffer(a6),a1
	move.l	a0,a2
	sub.l	a1,a2
	move.w	window_redrawed(a6),d0
	lea	window_tab_table(a6),a1
	add	d0,d0
	move.w	a2,0(a1,d0)
	lea	disassemble_datas(a6),a1
;	move.l	test_instruction(a6),a2
	move.l	test_instruction(a6),a1	; *
;	move.l	a2,d0
;	bclr	#0,d0
;	move.l	d0,a2
	move.l	a1,d0			; *
	bclr	#0,d0			; *
	move.l	d0,a1			; *
;	move.l	a0,dc_w_line_buffer(a6)
;	bsr	test_if_readable4
;	tst.l	readable_buffer(a6)
;	bne.s	.5
;	tst.l	readable_buffer+4(a6)
;	bne.s	.5
;	tst.w	readable_buffer+8(a6)
;	bne.s	.5
;	move.l	(a2)+,(a1)
;	move.l	(a2)+,4(a1)
;	move.w	(a2)+,8(a1)
;	sf	extended_mode(a6)
	st	optimise_address(a6)
;	lea	instruction_size(a6),a5
;	clr.w	(a5)
	jsr	disassemble_line
	lea	instruction_descriptor(a6),a5
	tst.l	_I_Comment(a5)
	beq.s	.display_break
	move.l	_I_Comment(a5),a1
	move.b	#' ',(a0)+
.comment_loop:
	move.b	(a1)+,(a0)+
	bne.s	.comment_loop
	subq.w	#1,a0
.display_break:
	jsr	display_break
.7:	clr.b	(a0)
	_JSR	print_instruction
	move.w	instruction_size(a6),d0
	ext.l	d0
	add.l	d0,test_instruction(a6)
	tst.b	pc_pointer_flag(a6)
	beq.s	.8
	move.b	internal_trap_line_af(a6),trap_line_af_flag(a6)
	move.b	internal_trapv_chk_flag(a6),trapv_chk_flag(a6)
.8:	move.w	(sp)+,d0
	rts
.5:	move.w	#2,instruction_size(a6)
	lea	line_buffer(a6),a1
	bra.s	.7
.dumvar:	dcb.b	11,' '
	even
	; #] Disassemble:
;  #] Disassemble:
;  -------------- FONCTIONS CLAVIER -------------
	IFNE	_68030
;  #[ Show_frame:[Ctl_Alt_F]
show_frame:
	tst.b	chip_type(a6)
	beq.s	.end
	lea	frame_form_table(pc),a0
	bra	form_do
.end:	rts
frame_form_table:
	dc.l	draw_page_frame-frame_form_table
	dc.l	line_up_frame-frame_form_table
	dc.l	line_down_frame-frame_form_table
	dc.l	page_up_frame-frame_form_table
	dc.l	page_down_frame-frame_form_table
	dc.l	home_frame-frame_form_table
	dc.l	shift_home_frame-frame_form_table
	dc.l	init_frame-frame_form_table
	dc.l	frame_title_text-frame_form_table

draw_page_frame:
	movem.l	d7/a5,-(sp)
	move.w	big_window_coords+2(a6),y_pos(a6)
	addq.w	#4,y_pos(a6)
.l1:
	tst.b	(a5)
	beq	.end
	move.w	column_len(a6),d0
;	subq.w	#3,d0
	cmp.w	y_pos(a6),d0
	ble	.end

	move.b	(a5)+,d7
	moveq	#0,d0
	move.b	(a5)+,d0
	cmpi.b	#'i',d0
	beq.s	.internal
	cmpi.b	#'@',d0
	beq.s	.print_address
	cmpi.b	#'s',d0
	beq.s	.ssr
	cmpi.b	#'v',d0
	beq.s	.version
	cmpi.b	#'C',d0
	beq.s	.stage
	cmpi.b	#'B',d0
	beq.s	.stage
	bra.s	.l1
.stage:
	bsr	print_stage_frame
	addq.w	#2,d6
	bra.s	.l1
.version:
	lea	version_stack_text,a0
	move.w	0(a4,d6.w),d0
	moveq	#12,d2
	lsr.w	d2,d0
	andi.w	#$f,d0
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	move.l	a3,a0
	bsr	sprintf
	addq.w	#6,sp
	bsr	print_frame_line
	addq.w	#2,d6
	bra.s	.l1
.ssr:
	move.w	0(a4,d6.w),d0
	bsr	print_ssr_frame
	addq.w	#2,d6
	bra.s	.l1
.internal:
	cmpi.b	#'w',d7
	beq.s	.print_word
;	bra.s	.print_long
.print_long:
	bsr	print_linternal_frame
	addq.w	#4,d6
	addq.w	#1,d5
	bra	.l1
.print_word:
	bsr	print_winternal_frame
	addq.w	#2,d6
	addq.w	#1,d5
	bra	.l1
.print_address:
	move.l	(a5)+,a0
	bsr	print_long_frame
	addq.w	#4,d6
	bra	.l1
.end:
	movem.l	(sp)+,d7/a5
	rts

print_winternal_frame:
	move.w	0(a4,d6.w),-(sp)
	move.w	d5,-(sp)
	pea	internal_reg_stack_text
	move.l	a3,a0
	bsr	sprintf
	addq.w	#8,sp
	bsr.s	print_frame_line
	rts

;a0=text @
;d1=frame offset
print_linternal_frame:
	move.l	0(a4,d6.w),-(sp)
	move.w	d5,-(sp)
	pea	long_internal_reg_stack_text
	move.l	a3,a0
	bsr	sprintf
	lea	10(sp),sp
	bsr.s	print_frame_line
	rts

;d0=stage letter
;d1=frame offset
print_stage_frame:
	move.w	0(a4,d6.w),-(sp)
	move.w	d0,-(sp)
	pea	stage_pipe_stack_text
	move.l	a3,a0
	bsr	sprintf
	addq.w	#8,sp
	bsr.s	print_frame_line
	rts

;a0=text @
print_long_frame:
	move.l	0(a4,d6.w),-(sp)
	move.l	a0,-(sp)
	move.l	a3,a0
	bsr	sprintf
	addq.w	#8,sp
	bsr.s	print_frame_line
	rts

print_frame_line:
	bsr.s	print_offset_frame
	move.l	a3,a2
	_JSR	print_instruction
	addq.w	#1,y_pos(a6)
	rts

print_offset_frame:
	move.w	#1,x_pos(a6)
	lea	lower_level_buffer(a6),a0
	move.l	a0,-(sp)
	move.w	d6,-(sp)
	pea	offset_stack_text
	bsr	sprintf
	addq.w	#6,sp
	move.l	(sp)+,a2
	bsr	print_m_line
	add.w	#13,x_pos(a6)
	rts

;d0=ssr
print_ssr_frame:
	movem.l	d7,-(sp)
	move.w	d0,d7

	move.w	d7,-(sp)
	move.w	d7,d0
	_JSR	build_fcx
	move.w	d0,-(sp)

	;0=long,1=byte,2=word
	;%00
	moveq	#'L',d0
	btst	#4,d7
	bne.s	.byte_quad
	btst	#5,d7
	beq.s	.poke1
	;%10
	moveq	#'W',d0
	bra.s	.poke1
	;%?1
.byte_quad:
	;%01
	moveq	#'B',d0
	btst	#5,d7
	beq.s	.poke1
	;%11
	moveq	#'Q',d0
.poke1:
	move.w	d0,-(sp)

	move.w	d7,d0
	lsr.w	#6,d0
	bsr	build_up_ssr
	move.l	d0,-(sp)
	pea	ssr_stack_text
	move.l	a3,a0
	bsr	sprintf
	lea	14(sp),sp
	bsr	print_frame_line

	movem.l	(sp)+,d7
	rts

;In:d0=up of ssr (ssr>>6)
;Out:d0.l=ASCII explanation
build_up_ssr:
	moveq	#'C',d1
	btst	#9,d0
	bne.s	.rerun
	moveq	#'B',d1
	btst	#8,d0
	bne.s	.rerun
	moveq	#'-',d1
.rerun:
	lsl.w	#8,d1
	move.b	#'C',d1
	btst	#7,d0
	bne.s	.faulty
	move.b	#'B',d1
	btst	#6,d0
	bne.s	.faulty
	move.b	#'-',d1
.faulty:
	lsl.l	#8,d1
	move.b	#'F',d1
	btst	#2,d0
	beq.s	.not_run
	move.b	#'R',d1
.not_run:
	lsl.l	#8,d1
	move.b	#'M',d1
	btst	#1,d0
	bne.s	.modify
	move.b	#'W',d1
	btst	#0,d0
	beq.s	.modify
	move.b	#'R',d1
.modify:
	move.l	d1,d0
	rts

build_ascii_mmusr:
 moveq #0,d0
 move.l d0,d1
 move.w d2,-(sp)
 and.w #7,d2
 add.w #'0',d2
 or.w d2,d1
 move.w (sp)+,d2
 btst #6,d2
 beq.s .not_t
._t:
 or.w #$5400,d1
.not_t:
 btst #9,d2
 beq.s .not_m
._m:
 or.l #$4D0000,d1
.not_m:
 btst #10,d2
 beq.s .not_i
._i:
 or.l #$49000000,d1
.not_i:
 btst #11,d2
 beq.s .not_w
._w:
 or.b #$57,d0
.not_w:
 btst #13,d2
 beq.s .not_s
._s:
 or.w #$5300,d0
.not_s:
 btst #14,d2
 beq.s .not_l
._l:
 or.l #$4C0000,d2
.not_l:
 btst #15,d2
 beq.s .not_b
._b:
 or.l #$42000000,d0
.not_b:
 rts

build_ascii_tc:
 lea tmp_buffer(a6),a0
 move.l #'    ',d1
 moveq #9,d0
.1:
 move.l d1,(a0)+
 dbf d0,.1
 sub.w #40,a0
 btst #31,d2
 beq.s .not_e
 move.b #'E',(a0)+
 move.b #',',(a0)+
.not_e:
 btst #25,d2
 beq.s .not_sre
 move.b #'S',(a0)+
 move.b #'R',(a0)+
 move.b #'E',(a0)+
 move.b #',',(a0)+
.not_sre:
 btst #24,d2
 beq.s .not_fcl
 move.b #'F',(a0)+
 move.b #'C',(a0)+
 move.b #'L',(a0)+
 move.b #',',(a0)+
.not_fcl:
 move.b #'P',(a0)+
 move.b #'S',(a0)+
 move.b #':',(a0)+
 move.l d2,d3
 swap d3
 lsr.b #4,d3
 bsr .little_convert
 move.b #',',(a0)+
 move.b #'I',(a0)+
 move.b #'S',(a0)+
 move.b #':',(a0)+
 move.l d2,d3
 swap d3
 bsr.s .little_convert
 move.b #',',(a0)+
 move.b #'T',(a0)+
 move.b #'I',(a0)+
 move.b #'A',(a0)+
 move.b #':',(a0)+
 move.l d2,d3
 rol.w #4,d3
 bsr.s .little_convert
 move.b #',',(a0)+
 move.b #'T',(a0)+
 move.b #'I',(a0)+
 move.b #'B',(a0)+
 move.b #':',(a0)+
 move.l d2,d3
 lsr.w #8,d3
 bsr.s .little_convert
 move.b #',',(a0)+
 move.b #'T',(a0)+
 move.b #'I',(a0)+
 move.b #'C',(a0)+
 move.b #':',(a0)+
 move.l d2,d3
 lsr.w #4,d3
 bsr.s .little_convert
 move.b #',',(a0)+
 move.b #'T',(a0)+
 move.b #'I',(a0)+
 move.b #'D',(a0)+
 move.b #':',(a0)+
 move.l d2,d3
 bsr.s .little_convert
 clr.b (a0)
 rts

.little_convert:
 and.w #$f,d3
 add.b #'0',d3
 cmp.b #'9',d3
 ble.s .end
 move.b #'$',(a0)+
 addq.w #7,d3
.end:
 move.b d3,(a0)+
 rts

build_ascii_cacr:
 lea tmp_buffer(a6),a0
 move.l #'    ',d1
 moveq #9,d0
.1:
 move.l d1,(a0)+
 dbf d0,.1
 sub.w #40,a0
 btst #13,d2
 beq.s .not_wa
 move.b #'W',(a0)+
 move.b #'A',(a0)+
 move.b #',',(a0)+
.not_wa:
 btst #12,d2
 beq.s .not_dbe
 move.b #'D',(a0)+
 move.b #'B',(a0)+
 move.b #'E',(a0)+
 move.b #',',(a0)+
.not_dbe:
 btst #11,d2
 beq.s .not_cd
 move.b #'C',(a0)+
 move.b #'D',(a0)+
 move.b #',',(a0)+
.not_cd:
 btst #10,d2
 beq.s .not_ced
 move.b #'C',(a0)+
 move.b #'E',(a0)+
 move.b #'D',(a0)+
 move.b #',',(a0)+
.not_ced:
 btst #9,d2
 beq.s .not_fd
 move.b #'F',(a0)+
 move.b #'D',(a0)+
 move.b #',',(a0)+
.not_fd:
 btst #8,d2
 beq.s .not_ed
 move.b #'E',(a0)+
 move.b #'D',(a0)+
 move.b #',',(a0)+
.not_ed:
 btst #4,d2
 beq.s .not_ibe
 move.b #'I',(a0)+
 move.b #'B',(a0)+
 move.b #'E',(a0)+
 move.b #',',(a0)+
.not_ibe:
 btst #3,d2
 beq.s .not_ci
 move.b #'C',(a0)+
 move.b #'I',(a0)+
 move.b #',',(a0)+
.not_ci:
 btst #2,d2
 beq.s .not_cei
 move.b #'C',(a0)+
 move.b #'E',(a0)+
 move.b #'I',(a0)+
 move.b #',',(a0)+
.not_cei:
 btst #1,d2
 beq.s .not_fi
 move.b #'F',(a0)+
 move.b #'I',(a0)+
 move.b #',',(a0)+
.not_fi:
 btst #0,d2
 beq.s .not_ei
 move.b #'E',(a0)+
 move.b #'I',(a0)+
.not_ei:
 clr.b (a0)
 rts

line_up_frame:
line_down_frame:
page_up_frame:
page_down_frame:
home_frame:
shift_home_frame:
	moveq	#-1,d0
	rts

;d7=frame frame type
;d6=stack frame current offset
;d5=internal register count
;a5=stack frame format table
;a4=external stack frame buffer
init_frame:
	lea	line_buffer(a6),a3
	moveq	#0,d1
	move.b	exception(a6),d1
	move.w	d1,d0
	lsl.w	#2,d0
	lea	exception_message_table,a0
	move.l	0(a0,d0.w),a1
	move.w	d1,d0
	cmpi.w	#25,d1
	blt.s	.ok
	cmpi.w	#47,d1
	bgt.s	.ok
	cmpi.w	#32,d1
	blt.s	.ipl
	subi.w	#32,d0
	bra.s	.sprint
.ipl:
	subi.w	#24,d0
.sprint:
	lea	lower_level_buffer(a6),a0
	movem.l	d1/a0,-(sp)

	move.w	d0,-(sp)
	move.l	a1,-(sp)
	bsr	sprintf
	addq.w	#6,sp

	movem.l	(sp)+,d1/a1
.ok:
	move.l	a1,-(sp)
	move.w	d1,-(sp)
	move.w	sf_type(a6),d7
	move.w	d7,-(sp)
	pea	present_frame_text
	move.l	a3,a0
	bsr	sprintf
	lea	12(sp),sp
	move.l	a3,a2
	bsr	print_m_line
	addq.w	#2,y_pos(a6)

	moveq	#0,d6
	;print sr
	move.w	sf_sr(a6),d0
	
	lea	tmp_buffer(a6),a0
	move.l	a0,-(sp)
	bsr	build_ascii_sr
	move.w	sf_sr(a6),-(sp)
	pea	sr_stack_text
	move.l	a3,a0
	bsr	sprintf
	lea	10(sp),sp
	bsr	print_frame_line
	addq.w	#2,d6

	move.l	sf_pc(a6),a0
	_JSR	dis_tmp
	lea	tmp_buffer(a6),a0
	move.l	a0,-(sp)
	move.l	sf_pc(a6),-(sp)
	pea	pc_stack_text
	move.l	a3,a0
	bsr	sprintf
	lea	12(sp),sp
	bsr	print_frame_line
	addq.w	#4,d6

	;for vbr
	addq.w	#2,d6
	addq.w	#1,y_pos(a6)
	lea	stacks_table,a5
	move.w	d7,d0
	asl.w	#2,d0
	move.l	0(a5,d0.w),a5
	lea	external_stack_frame(a6),a4
	moveq	#0,d5
	rts

;  #] Show_frame:
	ENDC	;de _68030
	; #[ build_ascii_sr:
;Input:
;d0=sr
;a0=buffer d'output
;Output:
build_ascii_sr:
 move.l #'    ',d1
 move.l d1,(a0)
 move.l d1,4(a0)
 move.l d1,8(a0)
 tst.b chip_type(a6)
 beq .68000_sr
.68030_sr:
 btst #15,d0
 beq.s .not_T
 move.b #'T',(a0)
.not_T:
 addq.w #1,a0
 btst #14,d0
 beq.s .not_t
 move.b #'t',(a0)
.not_t:
 addq.w #1,a0
 btst #13,d0
 beq.s .not_s
 move.b #'S',(a0)
.not_s:
 addq.w #1,a0
 btst #12,d0
 beq.s .not_m
 move.b #'M',(a0)
.not_m:
 addq.w #1,a0
 btst #4,d0
 beq.s .not_x
 move.b #'X',(a0)
.not_x:
 addq.w #1,a0
 btst #3,d0
 beq.s .not_n
 move.b #'N',(a0)
.not_n:
 addq.w #1,a0
 btst #2,d0
 beq.s .not_z
 move.b #'Z',(a0)
.not_z:
 addq.w #1,a0
 btst #1,d0
 beq.s .not_v
 move.b #'V',(a0)
.not_v:
 addq.w #1,a0
 btst #0,d0
 beq.s .not_c
 move.b #'C',(a0)
.not_c:
 addq.w #1,a0
 clr.b (a0)
 rts

.68000_sr:
 btst #15,d0
 beq.s .not_t2
 move.b #'T',(a0)
.not_t2:
 addq.w #1,a0
 btst #13,d0
 beq.s .not_s2
 move.b #'S',(a0)
.not_s2:
 addq.w #1,a0
 move.w d0,d2
 lsr.w #8,d2
 and.w #7,d2
 add.b #'0',d2
 move.b d2,(a0)+
 btst #4,d0
 beq.s .not_x2
 move.b #'X',(a0)
.not_x2:
 addq.w #1,a0
 btst #3,d0
 beq.s .not_n2
 move.b #'N',(a0)
.not_n2:
 addq.w #1,a0
 btst #2,d0
 beq.s .not_z2
 move.b #'Z',(a0)
.not_z2:
 addq.w #1,a0
 btst #1,d0
 beq.s .not_v2
 move.b #'V',(a0)
.not_v2:
 addq.w #1,a0
 btst #0,d0
 beq.s .not_c2
 move.b #'C',(a0)
.not_c2:
 addq.w #1,a0
 move.b #' ',(a0)+
 clr.b (a0)
 rts
	; #] build_ascii_sr:
;  #[ Help:[Help]
help:
	lea	help_form_table(pc),a0
	bra	form_do

help_form_table:
	dc.l	draw_page_help-help_form_table
	dc.l	line_up_help-help_form_table
	dc.l	line_down_help-help_form_table
	dc.l	page_up_help-help_form_table
	dc.l	page_down_help-help_form_table
	dc.l	home_help-help_form_table
	dc.l	shift_home_help-help_form_table
	dc.l	init_help-help_form_table
	dc.l	help_title_text-help_form_table

	IFNE	ATARIST|MAC
line_up_help:
line_down_help:
page_up_help:
page_down_help:
shift_home_help:
	ENDC	;d'ATARIST|MAC
dont_redraw_help:
	moveq	#-1,d0
	rts

redraw_help:
	moveq	#0,d0
	rts

draw_page_help:
	tst.b	exec_name_buf(a6)
	beq.s	dont_redraw_help
	IFNE	AMIGA
	jsr	print_sections
	ELSEIF
	bsr	print_sections
	ENDC	;d'AMIGA
	rts

	IFNE	debug|bridos|stmag|atarifrance|amigarevue
;a0=last string
;a1=buffer
build_present_string:
	move.l	a1,a2
	lea	present_adebug_format,a1
	bra	build_one_string
	ELSEIF
;a0=last string
;a1=buffer
build_present_string:
	moveq	#0,d0
	move.w	v_number(a6),d0
	lsl.l	#8,d0
	lsr.w	#8,d0
	move.l	a0,-(sp)
	move.l	d0,-(sp)
	pea	present_adebug_format
	move.l	a1,a0
	bsr	sprintf
	lea	12(sp),sp
	rts
	ENDC

init_help:
	lea	line_buffer(a6),a3
	IFNE	AMIGA
	moveq	#0,d7
	moveq	#1,d0
	move.w	d0,cur_text_section(a6)
	move.w	d0,cur_data_section(a6)
	move.w	d0,cur_bss_section(a6)
	ENDC	;d'AMIGA
;	rts

home_help:
	move.l	big_window_coords(a6),x_pos(a6)
	lea	auteurs_text,a0
	move.l	a3,a1
	bsr.s	build_present_string
	move.l	a3,a0
	_JSR	print_center
	IFNE	AMIGA
	lea	daniel_text,a0
	move.l	a0,a2
	lea	line_buffer(a6),a1
	bsr	strcpy
	move.l	a2,a0
	_JSR	print_center
	addq.w	#1,y_pos(a6)
	ENDC	;d'AMIGA
	lea	present_internal_text,a0
	lea	present_infos_text,a1
	move.l	a3,a2
	bsr	build_one_string
	move.l	a3,a0
	_JSR	print_center
	bsr	print_buffers
	IFNE	AMIGA
	move.l	physbase(a6),d0
	move.l	d0,-(sp)
	add.l	#AMIGA_NB_LINES*LINE_SIZE,(sp)
	move.l	d0,-(sp)
	move.l	internal_copperlist(a6),d0
	move.l	d0,-(sp)
	add.l	#taille_copperlist,(sp)
	move.l	d0,-(sp)
	pea	present_screen_copper_text
	move.l	a2,a0
	bsr	sprintf
	lea	20(sp),sp
	jsr	print_instruction
	addq.w	#1,y_pos(a6)
	ENDC

	lea	present_sys_text,a0
	lea	present_infos_text,a1
	move.l	a3,a2
	bsr	build_one_string
	move.l	a3,a0
	_JSR	print_center
	bsr	print_hard

	lea	present_soft_text,a0
	lea	present_infos_text,a1
	move.l	a3,a2
	bsr	build_one_string
	move.l	a3,a0
	_JSR	print_center
	bsr	print_soft
	rts

print_buffers:
;a5=cur size table
;a4=values
;a3=chaines
	movem.l	d3-d7/a2-a5,-(sp)
	move.w	x_pos(a6),-(sp)

	moveq	#0,d7

	lea	name_text,a2
	bsr	print_m_line

	move.l	a2,a0
	bsr	strlen
	add.w	d0,x_pos(a6)
	move.w	x_pos(a6),d6

	lea	help_vars_table,a5
.l1:
	move.l	(a5)+,d0
	beq.s	.end_of_text
	addq.l	#1,d7
	move.l	d0,a2
	_JSR	print_m_line
	addq.w	#7,x_pos(a6)
	bra.s	.l1
.end_of_text:
	subq.l	#1,d7
	beq.s	.end
	addq.w	#1,y_pos(a6)

	lea	maximum_text,a2
	lea	create_sizes_table(a6),a5
	bsr	.print_line

	lea	current_text,a2
	lea	cur_size_table(a6),a5
	bsr	.print_line
.end:
	move.w	#1,x_pos(a6)
	pea	end_of_data
	pea	A_Debug
	pea	start_end_format
	move.l	a2,a0
	bsr	sprintf
	lea	12(sp),sp
	_JSR	print_instruction
	addq.w	#1,y_pos(a6)
	
	move.w	(sp)+,x_pos(a6)
	movem.l	(sp)+,d3-d7/a2-a5
	rts

.print_line:
	move.w	#1,x_pos(a6)
	bsr	print_m_line
	move.w	d6,x_pos(a6)
	move.l	d7,d3
	move.l	a3,a2
.l2:
	move.l	(a5)+,-(sp)
	pea	static_number_format
	move.l	a3,a0
	bsr	sprintf
	addq.w	#8,sp
	_JSR	print_m_line
	addq.w	#7,x_pos(a6)
	dbf	d3,.l2
	addq.w	#1,y_pos(a6)
	rts

print_hard:
	move.w	x_pos(a6),-(sp)
	move.l	a3,a2
	;machine name
	lea	mch_name_buf(a6),a0
	move.l	a2,a1
	bsr	strcpy
	_JSR	print_instruction
	move.l	a2,a0
	bsr	strlen
	add.w	d0,x_pos(a6)
	;MPU
	moveq	#0,d0		;clock
	move.w	main_clock(a6),d0
	divu	#10,d0
	swap	d0
	move.l	d0,-(sp)
	moveq	#0,d0
	move.b	chip_type(a6),d0	;CPU
	lsl.w	#4,d0
	add.l	#$68000,d0
	move.l	d0,-(sp)
	pea	mpu_format_text
	move.l	a2,a0
	bsr	sprintf
	lea	12(sp),sp
	_JSR	print_instruction
	addq.w	#1,y_pos(a6)
	move.l	a2,a0
	bsr	strlen
	add.w	d0,x_pos(a6)
	;arithmetic coprocessor
	moveq	#0,d0
	move.b	fpu_type(a6),d0
	beq.s	.no_fpu
	add.l	#$68880,d0
	subq.w	#1,y_pos(a6)
	lea	fpu_format_text,a0
	bsr.s	print_long
.no_fpu:	move.w	(sp)+,x_pos(a6)
	rts

;d0=long
;a0=format
print_long:
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	move.l	a2,a0
	bsr	sprintf
	addq.w	#8,sp
	_JSR	print_instruction
	addq.w	#1,y_pos(a6)
	rts

print_soft:
	;nom de l'exec
	;nom du source
	lea	exec_name_buf(a6),a0
	tst.b	(a0)
	beq.s	.end
	pea	argv_buffer(a6)
	move.l	exec_sym_nb(a6),-(sp)
	move.l	a0,-(sp)
	pea	present_exec_name_text
	move.l	a2,a0
	bsr	sprintf
	lea	16(sp),sp
	_JSR	print_instruction
	addq.w	#1,y_pos(a6)
	IFNE	sourcedebug
	tst.w	source_type(a6)
	beq.s	.end
	move.l	source_name_addr(a6),d0
	beq.s	.no_module
	move.l	source_len(a6),-(sp)
	move.l	source_lines_nb(a6),-(sp)
	move.l	d0,-(sp)
	pea	present_source_name_text
	move.l	a2,a0
	bsr	sprintf
	lea	16(sp),sp
	_JSR	print_instruction
	addq.w	#1,y_pos(a6)
.no_module:
	ENDC	;de sourcedebug
.end:
	rts

	IFNE	ATARIST|MAC
print_sections:
	movem.l	d7/a2-a5,-(sp)
	lea	present_reloc_text,a2
	bsr	print_m_line
	addq.w	#1,y_pos(a6)
	moveq	#3-1,d7
	lea	text_text,a5
	lea	text_buf(a6),a4
	lea	text_size(a6),a3
	lea	line_buffer(a6),a2
.l1:
	move.l	(a3)+,-(sp)
	move.l	(sp),-(sp)
	move.l	(a4)+,-(sp)
	move.l	a5,-(sp)
	pea	header_format_text
	move.l	a2,a0
	bsr	sprintf
	lea	20(sp),sp
	_JSR	print_instruction

	move.l	a5,a0
	bsr	strlen
	addq.w	#1,d0
	adda.w	d0,a5

	addq.w	#1,y_pos(a6)
	dbf	d7,.l1
	movem.l	(sp)+,d7/a2-a5
	rts
	ENDC	;de ATARIST|MAC
;  #] Help:
;  #[ Show_breaks:[Ctl_Alt_B]
show_breaks:
	tst.l	current_breaks_nb(a6)
	beq.s	.no_breaks
	lea	breaks_form_table(pc),a0
	bra	form_do
.no_breaks:
	lea	no_breaks_error_text,a2
	_JMP	print_error

breaks_form_table:
	dc.l	draw_page_breaks-breaks_form_table
	dc.l	line_up_breaks-breaks_form_table
	dc.l	line_down_breaks-breaks_form_table
	dc.l	page_up_breaks-breaks_form_table
	dc.l	page_down_breaks-breaks_form_table
	dc.l	home_breaks-breaks_form_table
	dc.l	shift_home_breaks-breaks_form_table
	dc.l	init_breaks-breaks_form_table
	dc.l	breaks_title_text-breaks_form_table

;d6=@ courante de haut de page
;d5=nb de breaks de haut de page
;d7=nb de breaks courant

line_up_breaks:
	move.l	d6,a0
	_JSR	_get_prev_break
	bmi.s	dont_redraw_breaks
	move.l	a0,a5
	move.l	d5,d7
	subq.l	#1,d7
	bra.s	redraw_breaks

line_down_breaks:
	move.l	d6,a0
	_JSR	_get_next_break
	bmi.s	dont_redraw_breaks
	move.l	a0,a5
	move.l	d5,d7
	addq.l	#1,d7
	bra.s	redraw_breaks

page_up_breaks:
	cmp.l	breaks_addr(a6),d6
	ble.s	dont_redraw_breaks
	move.l	d6,a0
	_JSR	_get_prev_break
	bmi.s	dont_redraw_breaks

	move.w	d3,d2
	move.l	d6,a0
	move.l	d5,d7
.l1:
	_JSR	_get_prev_break
	bmi.s	redraw_breaks
	move.l	a0,a5
	subq.l	#1,d7
	dbf	d2,.l1
	bra.s	redraw_breaks

page_down_breaks:
	;rien
	bra.s	redraw_breaks

home_breaks:
	moveq	#0,d7
	move.l	breaks_addr(a6),a5
	tst.l	(a5)
	bne.s	.ok	
	tst.l	4(a5)
	bne.s	.ok	
	move.l	a5,a0
	_JSR	_get_next_break
	;?
	bmi.s	.ok
	move.l	a0,a5
.ok:
;	cmp.l	a5,d6
;	beq.s	dont_redraw_breaks
	move.l	a5,d6
	bra.s	redraw_breaks

shift_home_breaks:
	move.l	a4,a0
	tst.l	(a0)+
	_JSR	_get_prev_break
	bmi.s	dont_redraw_breaks
;	cmp.l	a0,a5
;	beq.s	dont_redraw_breaks
	move.l	a0,a5
	bra.s	redraw_breaks

dont_redraw_breaks:
	moveq	#-1,d0
	rts

redraw_breaks:
	moveq	#0,d0
	rts

;a5=Ptr courant sur table breaks
;a4=Ptr sur fin table breaks
;a3=Ptr sur line buffer

;d3=iteration de boucle (column_len-breaks_page_nb+1)
;d4=compteur de lignes
;d5=nb de breaks en haut de pages
;d6=ptr de haut de page
;d7=compteur de breaks affichees
draw_page_breaks:
	moveq	#0,d7
.more_page:
	cmp.l	a4,a5
	bge	.abort
	move.w	big_window_coords+2(a6),y_pos(a6)
	addq.w	#1,y_pos(a6)
	;ptr de haut de page
	move.l	a5,d6
	;compteur de haut de page
	move.l	d7,d5
	;compteur de lignes
	move.w	d3,d4
.more_break:
	cmp.l	current_breaks_nb(a6),d7
	bge	.test_if_finish
	cmp.l	a4,a5
	bge	.test_if_finish
	tst.l	(a5)
	beq	.next_break

	bsr.s	print_break_info_line
	move.l	a5,a0
	_JSR	_get_next_break
	bmi.s	.no_more_break
	move.l	a0,a5
	addq.l	#1,d7
	addq.w	#1,y_pos(a6)
	dbf	d4,.more_break
	moveq	#0,d0
	bra.s	.end
.next_break:
	move.l	a5,a0
	_JSR	_get_next_break
	bmi.s	.test_if_finish
	move.l	a0,a5
	bra	.more_break
.no_more_break:
	subq.w	#1,d4
	bmi.s	.abort
	addq.w	#1,y_pos(a6)
.test_if_finish:
	clr.b	(a3)
.l20:
	_JSR	print_instruction
	addq.w	#1,y_pos(a6)
	dbf	d4,.l20
.abort:
	moveq	#-1,d0
.end:
	rts

print_break_info_line:
	move.w	x_pos(a6),-(sp)
	;afficher type
	move.w	BREAK_VECTOR(a5),d0
	move.w	d0,-(sp)
	;type par defaut simple
	moveq	#'S',d1
	btst	#BREAK_IS_ROM,d0
	beq.s	.not_rom2
	moveq	#'R',d1
	bra.s	.type
.not_rom2:
	btst	#BREAK_IS_PERMANENT,d0
	beq.s	.not_perm
	moveq	#'P',d1
	bra.s	.type
.not_perm:
	btst	#BREAK_IS_SYSTEM,d0
	beq.s	.not_system_break
	moveq	#'T',d1
.not_system_break:
.type:
	move.w	d1,-(sp)
	;# de break:
	move.w	BREAK_NUMBER(a5),-(sp)
	pea	break_format_text
	move.l	a3,a0
	bsr	sprintf
	lea	10(sp),sp

	move.l	a3,a2
	_JSR	print_instruction

	;puis le reste
	add.w	#10,x_pos(a6)

	move.w	BREAK_VECTOR(a5),d0
	btst	#BREAK_IS_SYSTEM,d0
	bne.s	.system_break
	IFNE	sourcedebug
	btst	#BREAK_IN_SOURCE,d0
	bne.s	.in_source
	ENDC	;de sourcedebug
.not_this_source:
	;@ du break
	move.l	(a5),a2
	;# de vecteur
	tst.w	d0
	bge.s	.not_rom1
	move.l	BREAK_OLDPC(a5),a2
.not_rom1:
	move.l	a2,a0
	_JSR	dis_tmp
	pea	tmp_buffer(a6)
	move.l	a2,-(sp)
	pea	general_break_format_text
	move.l	a3,a0
	bsr	sprintf
	lea	12(sp),sp
	bra.s	.print
	IFNE	sourcedebug
.in_source:
	;recuperer le ptr sur le source(module,ptr,# de ligne)
	move.l	a5,a0
	sub.l	breaks_addr(a6),a0
	add.l	source_breaks_addr(a6),a0
	move.l	a0,-(sp)
	;checker si bon module
	move.l	BREAK_SRC_MDL(a0),a0
	_JSR	get_mod_name
	cmp.l	source_name_addr(a6),a0
	beq.s	.this_source
	addq.w	#4,sp
	bra.s	.not_this_source
.this_source:
	move.l	(sp),a0
	move.l	(a0),a0
	move.l	source_ptr(a6),a1
	add.l	source_len(a6),a1
	subq.w	#1,a1
	bsr	down_line_source
	move.l	a0,a2
	move.l	a3,a0
	move.l	(sp)+,a1
	move.l	BREAK_SRC_LNB(a1),d0
	move.l	(a1),a1
	move.w	line_len(a6),d1
	_JSR	print_line_source_ascii
	bra.s	.print
	ENDC	;de sourcedebug
.system_break:
	move.l	a5,a0
	move.l	a3,a1
	_JSR	get_system_break_name
.print:
	move.l	a3,a2
	_JSR	print_instruction
.end:
	move.w	(sp)+,x_pos(a6)
	rts

init_breaks:
	lea	present_breaks_text,a2
	bsr	print_m_line
	bsr	home_breaks
	move.l	eval_breaks_addr(a6),d0
	move.l	d0,a4
	beq.s	.no_tst
	tst.l	-(a4)
.no_tst:
	lea	line_buffer(a6),a3
	move.w	column_len(a6),d3
	subq.w	#breaks_page_nb+1,d3
	rts

;  #] Show_breaks:
;  #[ _28:

_28:
 move.w window_selected(a6),d2
 subq.w #1,d2
 tst.w d1
 beq.s	.reg
 cmp.w	#DISWIND_TYPE,d1
 beq.s	_disassemble
 cmp.w	#HEXWIND_TYPE,d1
 beq.s	_memory_dump
 rts

.reg:
 tst.b up_down_flag(a6)
 bne.s .reg_sft_down
.reg_sft_up:
 lsl.w #2,d2
 lea reg_wind_buf(a6),a0
 clr.w 2(a0,d2.w)
 bra redraw_curwind

.reg_sft_down:
 lsl.w #2,d2
 lea reg_wind_buf(a6),a1
 IFNE _68030
 move.w #22,2(a1,d2.w)
 ELSEIF
 move.w #9,2(a1,d2.w)
 ENDC
 bra redraw_curwind

_memory_dump:
 move.w 4(a0),d1
 sub.w (a0),d1
 bsr get_m_l_v
 move.w d6,d3
 addq.w #1,d3
 add.w d3,d3
 tst.b up_down_flag(a6)
 bne.s .2
 neg.w d3
.2:
 tst.b shift_flag(a6)
 beq.s _29
 move.w 6(a0),d1
 subq.w #1,d1
 muls d1,d3

;  #[ _29:
_29:
 ext.l d3
 add.l d3,$a(a0)
; subq.w #1,d2
 move.w d2,d0
 bsr build_lock
 bra redraw_curwind
;  #] _29:

_disassemble:
 tst.b shift_flag(a6)
 beq.s ._42
 lea shift_up_down_table(a6),a1
 move.w d2,d0
; subq.w #1,d0
 lsl.w #4,d0
 moveq #4,d1
 tst.b up_down_flag(a6)
 bne.s ._51
 subq.w #4,d1
._51:
 add.w d1,d0
 move.l 0(a1,d0.w),d3
 move.l d3,$a(a0)
 bra ._50
._42:
 lea shift_up_down_table(a6),a1
 move.w d2,d0
; subq.w #1,d0
 lsl.w #4,d0
 moveq #$c,d1
 tst.b up_down_flag(a6)
 bne.s ._51
 move.l a0,-(sp)
 move.l $a(a0),a2
 clr.w d1
 moveq #4,d0
.1:
 subq.w #2,a2
 addq.w #2,d1
 lea line_buffer(a6),a0
 move.l d0,-(sp)
 move.l a2,a1
 move.l a1,d0
 bclr #0,d0
 move.l d0,a1
 move.l a1,a2
 move.l (sp)+,d0
 st optimise_address(a6)
 movem.l d0-d2/a0-a2,-(sp)
 _JSR disassemble_line
 _JSR display_break
 movem.l (sp)+,d0-d2/a0-a2
 tst.b illegal_instruction_flag(a6)
 bne.s .3
 cmp.w instruction_size(a6),d1
 beq.s .found
.4:
 dbf d0,.1
.found:
 move.l (sp)+,a0
 tst.b alt_e_flag(a6)
 beq.s .2
 rts
.3:
 tst.b trap_line_af_flag(a6)
 bne.s .found
 bra.s .4
.2:
 move.l a2,$a(a0)
; bra.s ._50
._50:
 subq.w #1,d2
 move.w d2,d0
 bra redraw_curwind

;  #] _28:
;  #[ Up:[Up]

up:
	bsr	get_noaddr_curwind
	add.w	d0,a0
	moveq	#-1,d3
	tst.w	d1
	beq.s	.reg
	cmp.w	#DISWIND_TYPE,d1
	beq.s	.dis
	cmp.w	#HEXWIND_TYPE,d1
	beq.s	.hex
	cmp.w	#ASCWIND_TYPE,d1
	beq.s	.asc
	IFNE	sourcedebug
	cmp.w	#SRCWIND_TYPE,d1
	beq.s	.src
	cmp.w	#VARWIND_TYPE,d1
	beq.s	.up_var
	cmp.w	#INSWIND_TYPE,d1
	beq	.ins
	ENDC	;de sourcedebug
.end:
	rts
.set_redraw:
	bsr	put_curwind_addr
.redraw:
	bra	redraw_curwind

.reg:
	lsl.w	#2,d2
	lea	reg_wind_buf(a6),a0
	subq.w	#1,2(a0,d2.w)
	bpl	redraw_curwind
	clr.w	2(a0,d2.w)
	bra.s	.redraw

.dis:
.hex:
	sf	shift_flag(a6)
	sf	up_down_flag(a6)
	bra	_28
.asc:
	bsr	get_curwind
	add.w	d0,a0
	;deja ds a1 et a0
	bsr	up_line_ascii
	move.l	a1,a0
	bra.s	.set_redraw

	IFNE	sourcedebug
.src:
	bsr	get_cursrcwind
	move.l	a0,a2
	move.l	a1,a0
	move.l	source_ptr(a6),a1
	cmp.l	a1,a0
	ble.s	.end
	bsr	up_line_source
	move.l	a0,(a2)
	sub.l	d1,_SRCWIND_LINENB(a2)
	bra.s	.redraw
.up_var:
	lea	var_wind_buf(a6),a0
	mulu	#_VARWIND_SIZEOF,d2
	add.w	d2,a0
	tst.l	_VARWIND_NB(a0)
	ble.s	.end
	subq.l	#TCVARS_SIZEOF,(a0)
	subq.l	#1,_VARWIND_NB(a0)
	bra	redraw_curwind
.ins:
	move.l	a0,a2
	lea	ins_wind_buf(a6),a0
	mulu	#_INSWIND_SIZEOF,d2
	add.w	d2,a0
	tst.l	_INSWIND_ELNB(a0)
	ble.s	.end
	subq.l	#1,_INSWIND_ELNB(a0)
	bra	redraw_curwind
	ENDC	;de sourcedebug
;  #] Up:
;  #[ up_line_ascii:
;ds a1 l'@ a faire scroller
;le but est de scanner la ligne jusqu'a plus eol,puis jusqu'a eol (non compris!)
up_line_ascii:
	movem.l	d2/a2,-(sp)
	;fin de la ligne precedente
	subq.w	#1,a1
	move.l	line_len_max(a6),d2
.l1:
	lea	ascii_eol_chars,a2
	subq.w	#1,a1
	bsr	test_if_readable5
	tst.b	readable_buffer(a6)
	bne.s	.plus_eol
	addq.w	#1,a1
	move.b	-(a1),d0
.l2:
	move.b	(a2)+,d1
	bmi.s	.plus_eol
	cmp.b	d1,d0
	bne.s	.l2
.ddbbff:
	dbf	d2,.l1
.plus_eol:
	move.l	line_len_max(a6),d2
.l3:
	lea	ascii_eol_chars,a2
	subq.w	#1,a1
	bsr	test_if_readable5
	tst.b	readable_buffer(a6)
	bne.s	.ddbbff2
	addq.w	#1,a1
	move.b	-(a1),d0
.l4:
	move.b	(a2)+,d1
	bmi.s	.ddbbff2
	cmp.b	d1,d0
	beq.s	.end
	bra.s	.l4
.ddbbff2:
	dbf	d2,.l3
.end:
	addq.w	#1,a1
	movem.l	(sp)+,d2/a2
	rts
;  #] up_line_ascii:
;  #[ Down:[Down]
down:
	bsr	get_noaddr_curwind
	add.w	d0,a0
	moveq	#-1,d3
	tst.w	d1
	beq.s	.reg
	cmp.w	#DISWIND_TYPE,d1
	beq.s	.dis
	cmp.w	#HEXWIND_TYPE,d1
	beq.s	.hex
	cmp.w	#ASCWIND_TYPE,d1
	beq.s	.asc
	IFNE	sourcedebug
	cmp.w	#SRCWIND_TYPE,d1
	beq.s	.src
	cmp.w	#VARWIND_TYPE,d1
	beq.s	.var
	cmp.w	#INSWIND_TYPE,d1
	beq	.ins
	ENDC	;de sourcedebug
.end:
	rts
.set_redraw:
	bsr	put_curwind_addr
.redraw:
	bra	redraw_curwind

.reg:
	lsl.w	#2,d2
	lea	reg_wind_buf(a6),a1
	move.w	2(a1,d2.w),d0
	IFNE	_68030
	cmp.w	#22,d0
	ELSEIF
	cmp.w	#9,d0
	ENDC
	beq.s	.end
	addq.w	#1,2(a1,d2.w)
	bra.s	.redraw

.dis:
.hex:
	sf	shift_flag(a6)
	st	up_down_flag(a6)
	bra	_28

.asc:
	bsr	get_curwind
	add.w	d0,a0
	;deja ds a1 et a0
	moveq	#1,d0
	bsr	down_line_ascii
	move.l	a1,a0
	bra.s	.set_redraw

	IFNE	sourcedebug
.src:
	lea	src_wind_buf(a6),a2
	mulu	#_SRCWIND_SIZEOF,d2
	add.w	d2,a2
;	moveq	#0,d0
;	move.w	6(a0),d0
	moveq	#1,d0
	move.l	(a2),a0
	move.l	source_ptr(a6),d1
	add.l	source_len(a6),d1
	sub.l	a0,d1
	_JSR	get_source_line
	beq.s	.end
	move.l	(a2),a0
	move.l	source_ptr(a6),a1
	add.l	source_len(a6),a1
	subq.w	#1,a1
	bsr	down_line_source
	move.l	a0,(a2)
	add.l	d1,_SRCWIND_LINENB(a2)
	bra.s	.redraw
.var:
	move.l	a0,a2
	lea	var_wind_buf(a6),a0
	mulu	#_VARWIND_SIZEOF,d2
	add.w	d2,a0
	move.l	_VARWIND_NB(a0),d2
	moveq	#0,d0
	move.w	6(a2),d0
	add.l	d0,d2
	cmp.l	_VARWIND_NBMAX(a0),d2
	bgt	.end
	addq.l	#TCVARS_SIZEOF,(a0)
	addq.l	#1,_VARWIND_NB(a0)
	bra	redraw_curwind
.ins:
	move.l	a0,a2
	lea	ins_wind_buf(a6),a0
	mulu	#_INSWIND_SIZEOF,d2
	add.w	d2,a0
	move.l	_INSWIND_ELNB(a0),d0
	addq.l	#1,d0
	cmp.l	_INSWIND_ELMAX(a0),d0
	bge	.end
	move.l	d0,_INSWIND_ELNB(a0)
	bra	redraw_curwind
	ENDC	;de sourcedebug
;  #] Down:
;  #[ down_line_ascii:
;d0:flag skip eol
;a0:liste de separateurs
;a1:@ a faire scroller
;le but est de scanner la ligne jusqu'a eol
;si flag, puis jusqu'a plus eol
down_line_ascii:
	lea	ascii_eol_chars,a0
_down_line_ascii:
	movem.l	d2-d3/a2-a3,-(sp)
	move.w	d0,d3
	move.l	a0,a3
	move.l	line_len_max(a6),d2
.l1:
	addq.w	#1,a1
	bsr	test_if_readable5
	tst.b	readable_buffer(a6)
	bne.s	.eol
	move.b	(a1),d0
	move.l	a3,a2
.l2:
	move.b	(a2)+,d1
	bmi.s	.ddbbff
	cmp.b	d1,d0
	beq.s	.eol
	bra.s	.l2
.ddbbff:
	dbf	d2,.l1
.eol:
	tst.w	d3
	beq.s	.end
	move.l	line_len_max(a6),d2
.l3:
	bsr	test_if_readable5
	tst.b	readable_buffer(a6)
	bne.s	.ddbbff2
	move.b	(a1),d0
	move.l	a3,a2
.l4:
	move.b	(a2)+,d1
	bmi.s	.end
	cmp.b	d1,d0
	bne.s	.l4
.ddbbff2:
	addq.w	#1,a1
	dbf	d2,.l3
.end:
	movem.l	(sp)+,d2-d3/a2-a3
	rts
;  #] down_line_ascii:
;  #[ Left:[Left]

left:
 bsr get_noaddr_curwind
 add.w d0,a0
 moveq	#-1,d3
 tst.w d1
 beq.s	.reg
 cmp.w	#DISWIND_TYPE,d1
 beq.s	.dis
 cmp.w	#HEXWIND_TYPE,d1
 beq.s	.hex
 cmp.w	#ASCWIND_TYPE,d1
 beq.s	.asc
 IFNE	sourcedebug
 cmp.w	#SRCWIND_TYPE,d1
 beq.s	.src
 cmp.w	#VARWIND_TYPE,d1
 beq.s	.var
 cmp.w	#INSWIND_TYPE,d1
 beq.s	.ins
 ENDC	;de sourcedebug
.end:
 rts

.reg:
 lsl.w #2,d2
 lea reg_wind_buf(a6),a1
 add.w d2,a1
 tst.w (a1)
 ble.s .end
 subq.w #1,(a1)
 bra redraw_curwind

.dis:
 add.w d3,d3
.hex:
 bra _29

.asc:
	lea	asc_wind_buf(a6),a0
	add.w	d2,d2
	add.w	d2,a0
	tst.w	(a0)
	ble.s	.end
	subq.w	#1,(a0)
	bra	redraw_curwind

	IFNE	sourcedebug
.src:
	lea	src_wind_buf(a6),a0
	mulu.w	#_SRCWIND_SIZEOF,d2
	lea	_SRCWIND_OFF(a0,d2.w),a0
	tst.w	(a0)
	ble.s	.end
	subq.w	#1,(a0)
	bra	redraw_curwind
.var:
	lea	var_wind_buf(a6),a0
	mulu	#_VARWIND_SIZEOF,d2
	add.w	d2,a0
	tst.w	_VARWIND_OFF(a0)
	ble.s	.end
	subq.w	#1,_VARWIND_OFF(a0)
	bra	redraw_curwind
.ins:
	lea	ins_wind_buf(a6),a0
	mulu	#_INSWIND_SIZEOF,d2
	add.w	d2,a0
	tst.w	_INSWIND_OFF(a0)
	ble.s	.end
	subq.w	#1,_INSWIND_OFF(a0)
	bra	redraw_curwind
	ENDC	;de sourcedebug

;  #] Left:
;  #[ Right:[Right]

right:
 bsr get_noaddr_curwind
 add.w d0,a0
 tst.w d1
 beq.s	.reg
 cmp.w	#DISWIND_TYPE,d1
 beq.s	.dis
 cmp.w	#HEXWIND_TYPE,d1
 beq.s	.hex
 cmp.w	#ASCWIND_TYPE,d1
 beq.s	.asc
 IFNE	sourcedebug
 cmp.w	#SRCWIND_TYPE,d1
 beq.s	.src
 cmp.w	#VARWIND_TYPE,d1
 beq.s	.var
 cmp.w	#INSWIND_TYPE,d1
 beq	.ins
 ENDC	;de sourcedebug
.end:
 rts

.reg:
 lsl.w #2,d2
 lea reg_wind_buf(a6),a1
 add.w d2,a1
 move.w (a1),d0
 add.w 4(a0),d0
 sub.w (a0),d0
 cmp.w #78,d0
 bge.s .end
 addq.w #1,(a1)
 bra redraw_curwind

.dis:
 moveq	#2,d3
 bra	_29
.hex:
 moveq	#1,d3
 bra	_29

.asc:
	lea	asc_wind_buf(a6),a0
	add.w	d2,d2
	add.w	d2,a0
	move.l	line_len_max(a6),d0
	cmp.w	(a0),d0
	blt.s	.end
	move.w	line_buffer_size(a6),d0
	cmp.w	(a0),d0
	ble.s	.end
	addq.w	#1,(a0)
	bra	redraw_curwind

	IFNE	sourcedebug
.src:
	lea	src_wind_buf(a6),a1
	mulu.w	#_SRCWIND_SIZEOF,d2
	lea	_SRCWIND_OFF(a1,d2.w),a1
	move.w	(a1),d0
	add.w	4(a0),d0
	sub.w	(a0),d0
	cmp.w	2(a1),d0
	bge.s	.end
	addq.w	#1,(a1)
	bra	redraw_curwind
.var:
	lea	var_wind_buf(a6),a1
	mulu	#_VARWIND_SIZEOF,d2
	add.w	d2,a1
	move.w	_VARWIND_OFF(a1),d0
	add.w	4(a0),d0
	sub.w	(a0),d0
	cmp.w	_VARWIND_OFFMAX(a1),d0
	bge	.end
	addq.w	#1,_VARWIND_OFF(a1)
	bra	redraw_curwind
.ins:
	lea	ins_wind_buf(a6),a1
	mulu	#_INSWIND_SIZEOF,d2
	add.w	d2,a1
	move.w	_INSWIND_OFF(a1),d0
	add.w	4(a0),d0
	sub.w	(a0),d0
	cmp.w	_INSWIND_OFFMAX(a1),d0
	bge	.end
	addq.w	#1,_INSWIND_OFF(a1)
	bra	redraw_curwind
	ENDC	;de sourcedebug

;  #] Right:
;  #[ Shift Up:[Sft_Up]

shift_up:
	bsr	get_noaddr_curwind
	add.w	d0,a0
	beq.s	.reg
	cmp.w	#DISWIND_TYPE,d1
	beq.s	.dis
	cmp.w	#HEXWIND_TYPE,d1
	beq.s	.hex
	cmp.w	#ASCWIND_TYPE,d1
	beq.s	.asc
	IFNE	turbodebug
	cmp.w	#SRCWIND_TYPE,d1
	beq.s	.src
	cmp.w	#VARWIND_TYPE,d1
	beq.s	.var
	cmp.w	#INSWIND_TYPE,d1
	beq	.ins
	ENDC	;de turbodebug
.end:
	rts
.reg:
.dis:
.hex:
	st shift_flag(a6)
	sf up_down_flag(a6)
	bra _28
.asc:
	bsr	get_curwind
	add.w	d0,a0
	move.w	6(a0),d0
	subq.w	#2,d0
	bsr	up_page_ascii
	move.l	a1,a0
	bsr	put_curwind_addr
	bra	redraw_curwind

	IFNE	sourcedebug
.src:
	lea	src_wind_buf(a6),a2
	mulu.w	#_SRCWIND_SIZEOF,d2
	add.w	d2,a2
	move.w	6(a0),d0
	subq.w	#2,d0
	move.l	(a2),a0
	move.l	source_ptr(a6),a1	
.l1:
	move.w	d0,-(sp)
	bsr	up_line_source
	sub.l	d1,_SRCWIND_LINENB(a2)
	move.w	(sp)+,d0
	dbf	d0,.l1
	move.l	a0,(a2)
	bra	redraw_curwind
.var:
	lea	var_wind_buf(a6),a2
	mulu	#_VARWIND_SIZEOF,d2
	add.w	d2,a2
	move.l	_VARWIND_NB(a2),d0
	ble.s	.end
	moveq	#0,d1
	move.w	_GENWIND_H(a0),d1
	subq.l	#1,d1
	sub.l	d1,d0
	bmi.s	.start_var
	sub.l	d1,_VARWIND_NB(a2)
	mulu	#TCVARS_SIZEOF,d1
	sub.l	d1,(a2)
	bra	redraw_curwind
.start_var:
	clr.l	_VARWIND_NB(a2)
	move.l	_VARWIND_STARTPTR(a2),(a2)
	bra	redraw_curwind
.ins:
	lea	ins_wind_buf(a6),a2
	mulu	#_INSWIND_SIZEOF,d2
	add.w	d2,a2
	move.l	_INSWIND_ELNB(a2),d0
	ble	.end
	moveq	#0,d1
	move.w	_GENWIND_H(a0),d1
	subq.l	#1,d1
	sub.l	d1,d0
	bmi.s	.start_ins
	sub.l	d1,_INSWIND_ELNB(a2)
	bra	redraw_curwind
.start_ins:
	clr.l	_INSWIND_ELNB(a2)
	bra	redraw_curwind
	ENDC	;de sourcedebug

;  #] Shift Up:
;  #[ up_page_ascii:
;ds d0 le nb de lignes par page a faire scroller
;ds a1 l'@ a faire scroller
up_page_ascii:
	move.w	d3,-(sp)
	move.w	d0,d3
	subq.w	#1,a1
.l0:
	bsr	up_line_ascii
	dbf	d3,.l0
;	addq.w	#1,a1
	move.w	(sp)+,d3
	rts
;  #] up_page_ascii:
;  #[ Shift Down:[Sft_Down]

shift_down:
	bsr	get_noaddr_curwind
	add.w	d0,a0
	beq.s	.reg
	cmp.w	#DISWIND_TYPE,d1
	beq.s	.dis
	cmp.w	#HEXWIND_TYPE,d1
	beq.s	.hex
	cmp.w	#ASCWIND_TYPE,d1
	beq	.asc
	IFNE	sourcedebug
	cmp.w	#SRCWIND_TYPE,d1
	beq.s	.src
	cmp.w	#VARWIND_TYPE,d1
	beq.s	.var
	cmp.w	#INSWIND_TYPE,d1
	beq	.ins
	ENDC	;de sourcedebug
.end:
	rts
.reg:
.dis:
.hex:
	st	shift_flag(a6)
	st	up_down_flag(a6)
	bra	_28
.asc:
	bsr	get_curwind
	add.w	d0,a0
	move.w	6(a0),d0
	subq.w	#2,d0
	bsr	down_page_ascii
	move.l	a1,a0
	bsr	put_curwind_addr
	bra	redraw_curwind

	IFNE	sourcedebug
.src:
	lea	src_wind_buf(a6),a2
	mulu.w	#_SRCWIND_SIZEOF,d2
	add.w	d2,a2

	move.l	a0,-(sp)
	move.l	source_ptr(a6),a0
	move.l	a0,a1
	add.l	source_len(a6),a0
	subq.w	#1,a0
	bsr	up_line_source
	move.l	a0,a1
	move.l	(sp)+,a0

	move.w	6(a0),d0
	subq.w	#2,d0
	move.l	(a2),a0
.l1:
	move.w	d0,-(sp)
	bsr	down_line_source
	add.l	d1,_SRCWIND_LINENB(a2)
	move.w	(sp)+,d0
	dbf	d0,.l1
	move.l	a0,(a2)
	bra	redraw_curwind
.var:
	move.l	a0,a2
	lea	var_wind_buf(a6),a0
	mulu	#_VARWIND_SIZEOF,d2
	add.w	d2,a0
	move.l	_VARWIND_NB(a0),d2
	moveq	#0,d0
	move.w	_GENWIND_H(a2),d0
	subq.l	#1,d0
	add.l	d0,d2
;	cmp.l	_VARWIND_NBMAX(a0),d2
;	beq	.end
	add.l	d0,d2
	cmp.l	_VARWIND_NBMAX(a0),d2
	bgt	.end_of_var
	add.l	d0,_VARWIND_NB(a0)
	mulu	#TCVARS_SIZEOF,d0
	add.l	d0,(a0)
	bra	redraw_curwind
.end_of_var:
	move.l	_VARWIND_NBMAX(a0),d0
	moveq	#0,d1
	move.w	_GENWIND_H(a2),d1
	subq.l	#1,d1
	sub.l	d1,d0
	bmi	.end
	move.l	d0,_VARWIND_NB(a0)
	mulu	#TCVARS_SIZEOF,d0
	add.l	_VARWIND_STARTPTR(a0),d0
	move.l	d0,(a0)
	bra	redraw_curwind
.ins:
	move.l	a0,a2
	lea	ins_wind_buf(a6),a0
	mulu	#_INSWIND_SIZEOF,d2
	add.w	d2,a0
	move.l	_INSWIND_ELNB(a0),d2
	moveq	#0,d0
	move.w	_GENWIND_H(a2),d0
	subq.l	#1,d0
	add.l	d0,d2
;	cmp.l	_INSWIND_ELMAX(a0),d2
;	beq	.end
	add.l	d0,d2
	cmp.l	_INSWIND_ELMAX(a0),d2
	bgt	.end_of_ins
	add.l	d0,_INSWIND_ELNB(a0)
	bra	redraw_curwind
.end_of_ins:
	move.l	_INSWIND_ELMAX(a0),d0
	moveq	#0,d1
	move.w	_GENWIND_H(a2),d1
	subq.l	#1,d1
	sub.l	d1,d0
	bmi	.end
	move.l	d0,_INSWIND_ELNB(a0)
	bra	redraw_curwind
	ENDC	;de sourcedebug
;  #] Shift Down:
;  #[ down_page_ascii:
;ds d0 le nb de lignes par page a faire sroller
;ds a1 l'@ a faire scroller
down_page_ascii:
	move.w	d3,-(sp)
	move.w	d0,d3
.l1:
	moveq	#1,d0
	bsr	down_line_ascii
	dbf	d3,.l1
	move.w	(sp)+,d3
	rts
;  #] down_page_ascii:
;  #[ Shift Left:[Sft_Left]

shift_left:
 bsr	get_noaddr_curwind
 add.w	d0,a0
 tst.w	d1
 beq.s	.reg
 cmp.w	#ASCWIND_TYPE,d1
 beq.s	.asc
 IFNE	sourcedebug
 cmp.w	#SRCWIND_TYPE,d1
 beq.s	.src
 cmp.w	#VARWIND_TYPE,d1
 beq	.var
 cmp.w	#INSWIND_TYPE,d1
 beq	.ins
 ENDC
.end:
 rts
.reg:
 lsl.w	#2,d2
 lea	reg_wind_buf(a6),a0
 add.w	d2,a0
 tst.w	(a0)
 beq.s	.end
 clr.w	(a0)
 bra	redraw_curwind
.asc:
 add.w	d2,d2
 lea	asc_wind_buf(a6),a0
 add.w	d2,a0
 tst.w	(a0)
 beq.s	.end
 clr.w	(a0)
 bra	redraw_curwind
	IFNE	sourcedebug
.src:
	lea	src_wind_buf(a6),a0
	mulu.w	#_SRCWIND_SIZEOF,d2
	lea	_SRCWIND_OFF(a0,d2.w),a0
	tst.w	(a0)
	ble.s	.end
	clr.w	(a0)
	bra	redraw_curwind
.var:
	mulu	#_VARWIND_SIZEOF,d2
	lea	var_wind_buf(a6),a0
	add.w	d2,a0
	tst.w	_VARWIND_OFF(a0)
	beq.s	.end
	clr.w	_VARWIND_OFF(a0)
	bra	redraw_curwind
.ins:
	mulu	#_INSWIND_SIZEOF,d2
	lea	ins_wind_buf(a6),a0
	add.w	d2,a0
	tst.w	_INSWIND_OFF(a0)
	beq.s	.end
	clr.w	_INSWIND_OFF(a0)
	bra	redraw_curwind
	ENDC	;de sourcedebug
;  #] Shift Left:
;  #[ Shift Right:[Sft_Right]

shift_right:
 bsr	get_noaddr_curwind
 add.w	d0,a0
 tst.w	d1
 beq.s	.reg
 IFNE	sourcedebug
 cmp.w	#SRCWIND_TYPE,d1
 beq.s	.src
 cmp.w	#VARWIND_TYPE,d1
 beq.s	.var
 cmp.w	#INSWIND_TYPE,d1
 beq	.ins
 ENDC
.end:
 rts

.reg:
 move.w	4(a0),d1
 sub.w	(a0),d1
 sub.w	#78,d1
 neg.w	d1
 lsl.w	#2,d2
 lea	reg_wind_buf(a6),a0
 add.w	d2,a0
 move.w	d1,(a0)
 bra	redraw_curwind

	IFNE	sourcedebug
.src:
	lea	src_wind_buf(a6),a1
	mulu.w	#_SRCWIND_SIZEOF,d2
	lea	_SRCWIND_OFF(a1,d2.w),a1
	move.w	2(a1),d1
	cmp.w	(a1),d1
	ble.s	.end
	move.w	_GENWIND_W(a0),d0
	sub.w	(a0),d0
	sub.w	d0,d1
	bmi.s	.end
	move.w	d1,(a1)
	bra	redraw_curwind
.var:
	mulu	#_VARWIND_SIZEOF,d2
	lea	var_wind_buf(a6),a1
	add.w	d2,a1
;	move.w	_VARWIND_OFFMAX(a1),d1
;	cmp.w	_VARWIND_OFF(a1),d1
;	ble.s	.end
;	move.w	_GENWIND_W(a0),d0
;	sub.w	(a0),d0
;	sub.w	d0,d1
;	bmi.s	.end
;	move.w	d1,_VARWIND_OFF(a1)
;	bra	redraw_curwind
	move.w	_GENWIND_W(a0),d2
	sub.w	(a0),d2

	move.w	_VARWIND_OFF(a1),d1
	add.w	d2,d1
	add.w	d2,d1
	cmp.w	_VARWIND_OFFMAX(a1),d1
	bgt.s	.end_var
	sub.w	d2,d1
	move.w	d1,_VARWIND_OFF(a1)
	bra	redraw_curwind
.end_var:
	move.w	_VARWIND_OFFMAX(a1),d1
	cmp.w	_VARWIND_OFF(a1),d1
	ble.s	.end
	move.w	_GENWIND_W(a0),d0
	sub.w	(a0),d0
	sub.w	d0,d1
	bmi.s	.end
	move.w	d1,_VARWIND_OFF(a1)
	bra	redraw_curwind

.ins:
	mulu	#_INSWIND_SIZEOF,d2
	lea	ins_wind_buf(a6),a1
	add.w	d2,a1
	move.w	_INSWIND_OFFMAX(a1),d1
	cmp.w	_INSWIND_OFF(a1),d1
	ble	.end
	move.w	_GENWIND_W(a0),d0
	sub.w	(a0),d0
	sub.w	d0,d1
	bmi	.end
	move.w	d1,_INSWIND_OFF(a1)
	bra	redraw_curwind
	ENDC	;de sourcedebug

;  #] Shift Right:
;  #[ Ctrl Up:[Ctl_Up]

ctrl_up:
 lea w1_db(a6),a0
 move.w window_selected(a6),d0
 move.w d0,d2
 cmp.w #1,d0
 beq.s .reg
.notreg:
 btst #2,d0	;4/5
 beq little_updn
 bra.s big_updn
.end:
 rts
.reg:
 lsl.w #4,d0
 add.w d0,a0
 tst.b -8(a0)	;ON?
 beq.s .end
 cmp.w #2,_GENWIND_H-_GENWIND_SIZEOF(a0)	;height>=2
 beq.s .end
 subq.w #1,_GENWIND_H-_GENWIND_SIZEOF(a0)	;w1.h--
 subq.w #1,_GENWIND_Y(a0)			;w2.y--
 addq.w #1,_GENWIND_H(a0)			;w2.h++
 subq.w #1,_GENWIND_Y+_GENWIND_SIZEOF(a0)	;w3.y--
 addq.w #1,_GENWIND_H+_GENWIND_SIZEOF(a0)	;w3.h++
 lea	windows_to_redraw(a6),a0
 move.l	#$ffffff00,(a0)			;w1+w2+w3
 clr.w	4(a0)
 bra	windows_init

big_updn:
 move.w d0,d1
 eor.w #6,d1
 lsl.w #4,d0
 lsl.w #4,d1
 cmp.w #2,-10(a0,d1.w)
 beq.s .end
 tst.b -8(a0,d0.w)
 beq.s .end
 tst.b -8(a0,d1.w)
 beq.s .end
 subq.w #1,-10(a0,d1.w)
 addq.w #1,-10(a0,d0.w)
 btst #1,window_selected+1(a6)
 bne.s .1
 subq.w #1,-14(a0,d0.w)
 bra.s .2
.1:
 addq.w #1,-14(a0,d1.w)
.2:
 bra clr_updn
.end:
 rts

little_updn:
 move.w d0,d1
 eor.w #6,d1
 lsl.w #4,d0
 lsl.w #4,d1
 cmp.w #2,-10(a0,d0.w)
 beq.s .end
 tst.b -8(a0,d0.w)
 beq.s .end
 tst.b -8(a0,d1.w)
 beq.s .end
 subq.w #1,-10(a0,d0.w)
 addq.w #1,-10(a0,d1.w)
 btst #1,window_selected+1(a6)
 beq.s .1
 subq.w #1,-14(a0,d1.w)
 bra.s .2
.1:
 addq.w #1,-14(a0,d0.w)
.2:
 bra clr_updn
.end:
 rts

;  #] Ctrl Up:
;  #[ Ctrl Down:[Ctl_down]

ctrl_down:
 lea w1_db(a6),a0
 move.w window_selected(a6),d0
 move.w d0,d2
 cmp.w #1,d0
 beq.s .reg
 btst #2,d0
 beq big_updn
 bra.s little_updn
.end:
 rts

.reg:
 lsl.w	#4,d0
 add.w	d0,a0
 tst.b	_GENWIND_ON-_GENWIND_SIZEOF(a0)	;ON?
 beq.s	.end
 cmp.w	#23,_GENWIND_H-_GENWIND_SIZEOF(a0)	;height<=23
 beq.s	.end
 lea	windows_to_redraw(a6),a1
 move.l	#$ffffff00,(a1)
 clr.w	4(a1)
 moveq	#0,d0
 add.w	_GENWIND_H(a0),d0			;w2.h>=2
 add.w	_GENWIND_H+_GENWIND_SIZEOF(a0),d0	;w3.h>=2
 move.b	_GENWIND_ON+_GENWIND_SIZEOF*2(a0),d1	;w4 on?
 add.b	_GENWIND_ON+_GENWIND_SIZEOF*3(a0),d1	;w5 on?
 bne.s	.w4orw5on
 subq.w	#4,d0				;no space
 bne.s	.resize
 bra.s	.end
.w4orw5on:
 tst.b	_GENWIND_ON+_GENWIND_SIZEOF*2(a0)	;w4 on?
 beq.s	.now4
 add.w	_GENWIND_H+_GENWIND_SIZEOF*2(a0),d0	;w4.h>=2
.now4:
 tst.b	_GENWIND_ON+_GENWIND_SIZEOF*3(a0)	;w5 on?
 beq.s	.now5
 add.w	_GENWIND_H+_GENWIND_SIZEOF*3(a0),d0	;w5.h>=2
.now5:
 subq.w	#8,d0				;no space
 beq.s	.end
.resize:
 moveq	#2,d0
 addq.w	#1,_GENWIND_H-_GENWIND_SIZEOF(a0)	;w1.h++
 addq.w	#1,_GENWIND_Y(a0)			;w2.y++
 addq.w	#1,_GENWIND_Y+_GENWIND_SIZEOF(a0)	;w3.y++
 cmp.w	_GENWIND_H(a0),d0			;w2.h>=2
 beq.s	.incw4
 subq.w	#1,_GENWIND_H(a0)			;w2.h--
 bra.s	.w3w5
.incw4:
 st	3(a1)
 addq.w	#1,_GENWIND_Y+_GENWIND_SIZEOF*2(a0)	;w4.y++
 subq.w	#1,_GENWIND_H+_GENWIND_SIZEOF*2(a0)	;w4.h--
.w3w5:
 cmp.w	_GENWIND_H+_GENWIND_SIZEOF(a0),d0	;w3.h>=2
 beq.s	.incw5
 subq.w	#1,_GENWIND_H+_GENWIND_SIZEOF(a0)	;w3.h++
 bra	windows_init
.incw5:
 st	4(a1)
 addq.w	#1,_GENWIND_Y+_GENWIND_SIZEOF*3(a0)	;w5.y++
 subq.w	#1,_GENWIND_H+_GENWIND_SIZEOF*3(a0)	;w5.h--
 bra	windows_init

clr_updn:
 bset #1,d2
 bclr #2,d2
 subq.w #1,d2
 lea windows_to_redraw(a6),a0
 clr.l (a0)
 clr.w 4(a0)
 st 0(a0,d2.w)
 st 2(a0,d2.w)
 bra windows_init

;  #] Ctrl Down:
;  #[ Ctrl Left:[Ctl_Left]

ctrl_left:
 tst.b low_rez(a6)
 bne.s .end
 tst.b window_magnified(a6)
 bne.s .end
 lea w1_db(a6),a0
 move.w window_selected(a6),d0
 move.w d0,d2
 subq.w #1,d2
 lsl.w #4,d2
 cmp.w #1,d0
 bne.s .shift
.end:
 rts
.shift:
 tst.b meta_rez(a6)
 bne.s .2
 cmp.w #$1b,$14(a0)
 beq.s .delete_window
 tst.b $28(a0)
 beq.s .reopen_window
 move.w #$1b,$14(a0)
 move.w #$1d,$20(a0)
 move.w #$1b,$34(a0)
 move.w #$1d,$40(a0)
.redraw_all:
 moveq #-1,d0
 lea windows_to_redraw(a6),a0
 move.l d0,(a0)+
 move.w d0,(a0)
 st relock_vars_flag(a6)
 bra windows_init
.2:
 cmp.w #$33,$14(a0)
 beq.s .end
 move.w #$33,$14(a0)
 move.w #$35,$20(a0)
 move.w #$33,$34(a0)
 move.w #$35,$40(a0)
 bra.s .redraw_all
.delete_window:
 cmp.w #1,$20(a0)
 beq.s .end
 sf $18(a0)
 move.w #1,$20(a0)
 sf $38(a0)
 move.w #1,$40(a0)
 bsr get_noaddr_curwind
 btst #0,d2
 beq.s .redraw_all
 bsr alt_3
 bra.s .redraw_all
.reopen_window:
 st $28(a0)
 move.w $22(a0),d0
 add.w $26(a0),d0
 move.w big_window_coords+2(a6),d1
 add.w big_window_coords+6(a6),d1
 cmp.w d1,d0
 beq.s .no_w5_open
 st $48(a0)
.no_w5_open:
 move.w #$33,$14(a0)
 move.w #$35,$20(a0)
 move.w #$33,$34(a0)
 move.w #$35,$40(a0)
 bra .redraw_all
  
;  #] Ctrl Left:(ctrl_left)
;  #[ Ctrl Right:[Ctl_Right]

ctrl_right:
 tst.b low_rez(a6)
 bne.s .end
 tst.b window_magnified(a6)
 bne.s .end
 lea w1_db(a6),a0
 move.w window_selected(a6),d0
 move.w d0,d2
 subq.w #1,d2
 lsl.w #4,d2
 cmp.w #1,d0
 bne.s .shift
.end:
 rts
.shift:
 tst.b meta_rez(a6)
 bne.s .2
 cmp.w #$33,$14(a0)
 beq.s .delete_window
 tst.b $18(a0)
 beq .reopen_window
 cmp.w #79,$14(a0)
 beq.s .end
 move.w #$33,$14(a0)
 move.w #$35,$20(a0)
 move.w #$33,$34(a0)
 move.w #$35,$40(a0)
.redraw_all:
 st relock_vars_flag(a6)
 moveq #-1,d0
 lea windows_to_redraw(a6),a0
 move.l d0,(a0)+
 move.w d0,(a0)
 bra windows_init
.2:
 cmp.w #$6b,$14(a0)
 beq.s .end
 move.w #$6b,$14(a0)
 move.w #$6d,$20(a0)
 move.w #$6b,$34(a0)
 move.w #$6d,$40(a0)
 bra.s .redraw_all
.delete_window:
 cmp.w #79,$14(a0)
 beq.s .end
 move.w #79,$14(a0)
 sf $28(a0)
 move.w #79,$34(a0)
 sf $48(a0)
 bsr get_noaddr_curwind
 btst #0,d2
 bne.s .redraw_all
 bsr alt_2
 bra.s .redraw_all
.reopen_window:
 st $18(a0)
 move.w $12(a0),d0
 add.w $16(a0),d0
 move.w big_window_coords+2(a6),d1
 add.w big_window_coords+6(a6),d1
 cmp.w d1,d0
 beq.s .no_w4_open
 st $38(a0)
.no_w4_open:
 move.w #$1b,$14(a0)
 move.w #$1d,$20(a0)
 move.w #$1b,$34(a0)
 move.w #$1d,$40(a0)
 bra .redraw_all
  
;  #] Ctrl Right:(ctrl_right)
;  #[ Lock_Window:[Alt_L]

lock_window:
 lea lock_buffer(a6),a0
 move.w window_selected(a6),d0
 subq.w #2,d0
 beq.s .0
 addq.w #1,d0
 mulu #200,d0
 add.l d0,a0
 move.l a0,-(sp)
 lea ask_lock_window_text,a2
 _JSR get_expression
 move.l a0,a1
 move.l (sp)+,a0
 bmi.s .0
 bgt.s .1
.3:
 move.b (a1)+,d0
 beq.s .1
 move.b d0,(a0)+
 bra.s .3
.1:
 clr.b (a0)+
.2:
 st relock_flag(a6)
 move.b real_time_lock_flag(a6),-(sp)
 st real_time_lock_flag(a6)
 bsr redraw_all_windows
 move.b (sp)+,real_time_lock_flag(a6)
 sf relock_flag(a6)
 bra update_curwind_ttl
.0:
 rts

_lock:
 tst.b relock_pc_flag(a6)
 bne.s .force
 tst.b relock_flag(a6)
 beq.s .1
 tst.b real_time_lock_flag(a6)
 beq.s .1
.force:
 lea lock_buffer(a6),a1
 move.w d0,d1
 lsr.w #4,d1
 move.w d1,d2
 mulu #200,d1
 add.w d1,a1
 tst.b (a1)
 beq.s .1
 movem.l d2-d7/a0-a6,-(sp)
 move.l a1,a0
 bsr evaluate
 movem.l (sp)+,d2-d7/a0-a6
 tst.w d1
 bmi.s .1
 move.l d0,$a(a0)
	IFNE	sourcedebug
	cmp.w	#SRCWIND_TYPE,$e(a0)
	bne.s	.nosrc
	_JSR	eval_get_source_addr
	move.l	d0,a0
	beq.s	.nosrc
	move.w	d2,d0
	bsr	put_srcwind_addrnb
.nosrc:
	ENDC
 move.w d2,d0
 rts
.1:
 sf relock_flag(a6)
 rts

;  #] Lock_Window:
;  #[ Print_Window:[Alt_P]
print_window:
 clr.w	x_pos(a6)
 bsr	clr_c_line
 move.l	device_number(a6),-(sp)
 move.l	#PRINTER_OUTPUT,device_number(a6)
 _JSR	init_printer_display
 bmi.s	.1
 bsr	redraw_curwind
 cmp.l	#PRINTER_OUTPUT,device_number(a6)
 bne.s	.1
 move.l	(sp)+,device_number(a6)
 lea	prt_finished_text,a2
 _JSR	print_result
 bra.s	.2
.1:
 move.l	(sp)+,device_number(a6)
 lea	prt_not_ready_text,a2
 _JSR	print_result
.2:
 move.l	kbshift_addr(a6),a0
 clr.b	(a0)
 rts
;  #] Print_Window:
;  #[ Keep registers:[K]

keep_registers:
.again:
 lea registers_kept(a6),a0
 lea keep_registers_text,a2
 _JSR yesno
 beq.s .no
 subq.b #1,d0
 beq.s .yes
 subq.b #1,d0
 beq.s .no
 _JSR flash
 bra.s .again
.yes:
 lea d0_buf(a6),a0
 lea keep_d0_buf(a6),a1
 moveq #$f,d0
.1:
 move.l (a0)+,(a1)+
 dbf d0,.1
 move.l pc_buf(a6),keep_pc_buf(a6)
 move.w sr_buf(a6),keep_sr_buf(a6)
 move.l ssp_buf(a6),keep_ssp_buf(a6)
 st registers_kept(a6)
 lea registers_kept_text,a2
 _JSR print_result
 moveq #-1,d0
 bra.s .end
.no:
 moveq #0,d0
.end:
 rts

;  #] Keep registers:
;  #[ Restore registers:[R]

restore_registers:
 tst.b registers_kept(a6)
 beq.s .error
.again:
 suba.l a0,a0
 lea restore_registers_text,a2
 _JSR yesno
 beq.s .no
 subq.b #1,d0
 beq.s .yes
 subq.b #1,d0
 beq.s .no
 _JSR flash
 bra.s .again
.yes:
 lea keep_d0_buf(a6),a0
 lea d0_buf(a6),a1
 moveq #$f,d0
.1:
 move.l (a0)+,(a1)+
 dbf d0,.1
 move.l keep_pc_buf(a6),pc_buf(a6)
 move.w keep_sr_buf(a6),sr_buf(a6)
 move.l keep_ssp_buf(a6),ssp_buf(a6)
; sf registers_kept(a6)
 lea windows_to_redraw(a6),a0
 move.l #-1,(a0)
 move.w #-1,4(a0)
 st relock_flag(a6)
 bsr windows_init
 sf relock_flag(a6)
 lea registers_restored_text,a2
 _JSR print_result
 moveq #-1,d0
.end:
 rts
.error:
 lea restore_registers_error_text,a2
 _JSR print_error
.no:
 moveq #0,d0
 bra.s .end

;  #] Restore registers:
;  #[ Ctrl C:[Ctl_C]

ctrl_c:
	IFEQ	bridos
	tst.b	crdebug_flag(a6)
	beq.s	.not_resident
	IFNE	residant|cartouche
	IFEQ	atarifrance
	bsr	uninstall_adebug	;remettre initial et exceptions
	_JSR	put_exceptions	;redetourner exceptions
	_JSR	install_my_vbl	;redetourner vbl
	move.w	initial_ipl(a6),d0
	moveq	#-1,d1
	_JSR	put_internal_sr
	_JSR	kbd0_set
	_JSR	get_vbr
	move.l	#resident_trap1,$84(a0)
	ENDC	;atarifrance
	ENDC	;residant|cartouche
	bra.s	.resident
.not_resident:
	IFNE	AMIGA
	tst.b	multitask_access_flag(a6)
	beq.s	.multi_ok
	lea	multi_twice_error_text,a2
	jmp	print_error
.multi_ok:
	ENDC	;d'AMIGA
	tst.l	p1_basepage_addr(a6)
	beq.s	exit_in_super
	tst.b	save_prinfo_flag(a6)
	beq.s	.no_prinfo_save
	_JSR	save_prinfo
.no_prinfo_save:
	IFNE	ATARIST
;	_JSR	get_vbr
;	move.l	initial_trap1(a6),$84(a0)	;reinstaller le trap #1 par mesure de precaution
	lea	hidecur_vt52_string,a0	;effacer le curseur et l'ecran
	_JSR	system_print
	dc.w	$a009			;montrer la souris
	ENDC
.resident:
	IFNE	AMIGA
	jmp	do_amiga_pterm1
	ENDC
	lea	pterm1,a0
	move.l	a0,pc_buf(a6)
	move.l	internal_usp(a6),a0
	move.l	a0,a7_buf(a6)
;	ori.w	#$700,sr_buf(a6)
	move.w	initial_sr(a6),sr_buf(a6)
	IFNE	_68030
	move.l	initial_vbr(a6),vbr_buf(a6)
	ENDC	;_68030
	st	run_flag(a6)
	_JMP	p0p1
	ENDC	;de bridos
;pour sortir vraiment meme en version residante
exit_in_super:
	;clearer les variables
	move.l	table_var_addr(a6),a0
	_JSR	clr_table_end
	;clearer les breaks
	_JSR	_kill_all_breaks
	;freeer tous les buffers
	lea	create_addrs_table(a6),a5
	lea	create_routines_table(pc),a4
	lea	create_ends_table(a6),a3
.l1
	tst.l	(a4)+
	bmi.s	.end_free
	tst.l	(a5)+
	move.l	(a5)+,a0
	tst.l	(a3)+
	move.l	(a3)+,d0
	beq.s	.l1
	_JSR	free_memory
	bra.s	.l1
.end_free:
	bsr	uninstall_adebug
	move.w	initial_ipl(a6),d0
	moveq	#-1,d1
	_JSR	put_internal_sr
	_JSR	kbd0_set
	;resetter le path du debut
	lea	initial_path(a6),a0
	_JSR	set_drivepath
	;freeer l'ecran
	move.l	initial_physbase(a6),a0
	IFNE	AMIGA
	tst.b	screen_allocation_flag(a6)
	beq.s	.dont_free_screen
	move.l	#AMIGA_NB_LINES*LINE_SIZE,d0
	ENDC
	_JSR	free_memory

	IFNE	AMIGA
.dont_free_screen:
	; la copperlist
	tst.b	coplist_allocation_flag(a6)
	beq.s	.dont_free_copper
	move.l	#taille_copperlist,d0
	move.l	internal_copperlist(a6),a0
	jsr	free_memory
.dont_free_copper:
	move.l	Adebug_task(a6),a0
	jsr	reput_task_struct
	move.l	amiga_printer_file(a6),d0
	beq.s	.no_printer
	jsr	close_file
.no_printer:
	jsr	amiga_desinit
	ENDC	;d'AMIGA

	; le bss
	move.l	a6,a0
	move.l	reserve_from_addr(a6),d7
	move.l	reserved_stack_addr(a6),d6
	move.l	stack_size(a6),d5
	move.l	internal_usp(a6),a3

	IFNE	AMIGA
	move.l	dosbase(a6),a5
	move.l	gfxbase(a6),a4
	move.l	intuibase(a6),d4
	move.l	internal_return_addr(a6),(a3)
	move.l	a0,-(sp)
	_JSR	super_on
	move.l	initial_ssp(a6),a0
	_JSR	super_off
	move.l	(sp)+,a0
	ENDC	; d'AMIGA

	IFNE	ATARIST
	move.l	initial_ssp(a6),a6
	ENDC	;d'ATARIST

	move.l	#end_of_offset_base,d0
	_JSR	free_memory

	IFNE	ATARIST
	IFNE	catchgen
	tst.l	genst2_ssp_addr
	bne	return_to_genst2
	ENDC	;de catchgen
	move.l	a3,usp
	move.w	#$2300,sr
	move.l	a6,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	;liberer la pile
	move.l	d6,a0
	_JSR	free_memory
	ENDC	;d'ATARIST

	IFNE	AMIGA
	CLOSELIB	d4
	CLOSELIB	a5
	CLOSELIB	a4
	move.l	a3,sp
	move.l	d6,a0
	move.l	d5,d0
	jsr	free_memory
	ENDC	; d'AMIGA
	tst.l	d7
	beq.s	real_exit_in_user
	move.l	#BRAINSTORM_MAGIC,d4
	move.l	#ADEBUG_MAGIC,d5
	move.l	#RESTART_MAGIC,d6
	_JMP	real_start_of_adebug
exit_in_user:
	IFNE	ATARIST
	IFNE	accessoire
	IFNE	catchgen
	tst.l	genst2_ssp_addr
	bne	return_to_genst2
.no_return:
	ENDC	;de catchgen
	move.w	#1,Int_in
	move.l	#form_alert_text,Addr_in
	lea	Gem_form_alert,a0
	_JSR	Aes_Call
	ELSEIF
	lea	form_alert_text,a0
	_JSR	system_print
	_JSR	system_getkey
	ENDC	;d'accessoire
	ENDC	;d'ATARIST
	IFNE	AMIGA
	lea	form_alert_text,a0
	_JSR	system_print
	ENDC	;d'AMIGA
	_JMP	pterm0
real_exit_in_user:
	_JMP	pterm0
uninstall_adebug:
	;check for fpu
	IFNE	_68030
	tst.b	fpu_type(a6)
	beq.s	.no_fpu
	lea	fpu_frame_end(a6),a1
	tst.l	(a1)
	beq.s	.no_fpu
;	frestore	([a1])
	move.l	(a1),a0
	IFNE	AMIGA
	jsr	super_on
	move.l	d0,-(sp)
	ENDC
	dc.w	$f350	;	frestore	(a0)
	clr.l	(a1)
	IFNE	AMIGA
	move.l	(sp)+,d0
	beq.s	.no_fpu
	move.l	d0,a0
	jsr	super_off
	ENDC
.no_fpu:
	ENDC
	IFNE	ATARIST
	move	sr,-(sp)
	ori	#$700,sr
	; reinstall kbd
	bclr	#6,$fffa11
;	lea	$ffff8260.w,a0
;	IFNE	ATARITT
;	tst.w	machine_type(a6)
;	beq.s	.st
;	lea	$ffff8262.w,a0
;.st:
;	ENDC
;	cmp.b	#2,(a0)
;	beq.s	.s3
;	cmp.w	#2,initial_rez(a6)
;	bne.s	.s3
;	bsr	f10
;.s3:
	_JSR	reput_exceptions
	move	(sp)+,sr
	lea	initial_buffer(a6),a0
	_JSR	ram_exit
	_JSR	deinstall_my_vbl
	_JSR	timers_exit
	_JSR	sbase0_sbase1
	rts
	ENDC	;d'ATARIST
	IFNE	AMIGA
; remettre Alert
	move.l	4.w,a1
	move.w	#-$6c,a0
	move.l	initial_alert_addr(a6),d0
	CALLEXEC	SetFunction

	move.l	server_vbl(a6),d0
	beq.s	.no_vbl
	move.l	d0,a1
	moveq	#5,d0
	CALLEXEC	RemIntServer
	move.l	server_vbl(a6),a0
	move.l	#300,d0
	_JSR	free_memory
.no_vbl:
	move.l	gfxbase(a6),a0
	move.l	$26(a0),external_copperlist(a6)
	lea	custom,a0
; remettre interruptions 
	move.w	initial_intena(a6),d0
	move.w	d0,external_intena(a6)
	bset	#15,d0
	move.w	d0,intena(a0)
	not.w	d0
	move.w	d0,intena(a0)
; remettre DMA
	move.w	initial_dmacon(a6),d0
	move.w	d0,external_dmacon(a6) ; a suivre par sbase0_sbase1
	_JSR	reput_exceptions
	_JSR	timers_exit
	_JSR	sbase0_sbase1
	move.l	initial_cia_kbd(a6),initial_kbdvec(a6)
	rts
	ENDC	;d'AMIGA
;  #] Ctrl C:
;  #[ Trace:[T] U)ntil I)nstruction S)low 6)8020
trace:
.again:
	_JSR	unselect_trace
	lea	menu_trace_text,a2
	bsr	ask_menu
	bmi	.no_run
	subq.w	#1,d0
	beq.s	.until_mode
	subq.w	#1,d0
	beq.s	.instruct_mode
	subq.w	#1,d0
	beq.s	.slow_mode
	subq.w	#1,d0
	beq.s	.t1_mode
.flash:
	_JSR	flash
	bra.s	.again
.instruct_mode:
	lea	trace_instruc_buffer(a6),a0
	lea	trace_instruc_text,a2
	st	no_eval_flag(a6)
	_JSR	get_expression
	tst.w	d1
	bmi.s	.again
	bgt.s	.flash
	lea	trace_instruc_buffer(a6),a1
	bsr	strcpy
	st	trace_instruct_flag(a6)
	bra.s	.modes

.until_mode:
	lea	trace_until_buffer(a6),a0
	lea	trace_until_text,a2
	st	no_eval_flag(a6)
	_JSR	get_expression
	tst.w	d1
	bmi.s	.again
	bgt.s	.flash
	lea	trace_until_buffer(a6),a1
	bsr	strcpy
	st	trace_until_flag(a6)
	bra.s	.modes
.t1_mode:
	st	trace_t1_flag(a6)
	bra.s	.modes
.slow_mode:
	st	trace_slow_flag(a6)

.modes:
; watch ?
	lea	nowatch_flag(a6),a0
	lea	watch_text,a2
	_JSR	yesno
	beq	.again
	subq.w	#1,d0
	beq.s	.watch_mode
	subq.w	#1,d0
	beq.s	.no_watch_mode
	_JSR	flash
	bra.s	.modes
.watch_mode:
	sf	nowatch_flag(a6)
	bra.s	.run
.no_watch_mode:
	st	nowatch_flag(a6)
.run:
; on passe en mode trace
	st	trace_flag(a6)
; pas s'arreter
	st	nostop_flag(a6)
	st	permanent_trace_flag(a6)
	;pour gestion future:
;	IFNE	sourcedebug
;	tst.w	source_type(a6)
;	beq.s	.normal
;	_JSR	get_curwind_type
;	beq.s	.normal
;	_JSR	set_trace_source
;.normal:
;	ENDC	;de sourcedebug
	_JMP	p0p1
.no_run:
	rts
;  #] Trace:
;  #[ List Variables:[L]
show_variables:
	tst.l	table_var_addr(a6)
	beq.s	.abort
	tst.l	current_var_nb(a6)
	beq.s	.abort
	lea	vars_form_table(pc),a0
	bra	form_do
.abort:
	lea	no_vars_error_text,a2
	_JMP	print_error

vars_form_table:
	dc.l	draw_page_vars-vars_form_table
	dc.l	line_up_vars-vars_form_table
	dc.l	line_down_vars-vars_form_table
	dc.l	page_up_vars-vars_form_table
	dc.l	page_down_vars-vars_form_table
	dc.l	home_vars-vars_form_table
	dc.l	shift_home_vars-vars_form_table
	dc.l	init_vars-vars_form_table
	dc.l	vars_title_text-vars_form_table

;--- INPUT ---
;a0=ptr sur le nom (s'il y en a un)
;--- IN ---
;a5=Ptr courant sur table var
;a4=Ptr sur fin table var
;a3=Ptr sur line buffer

;d4=compteur de lignes
;d5=nb de var en haut de pages
;d6=ptr de haut de page
;d7=compteur de variables affichees
draw_page_vars:
	movem.l	d3,-(sp)
	cmp.l	a4,a5
	bge	.abort
	move.w	big_window_coords+2(a6),y_pos(a6)
	move.l	d7,d0			;ecrire page #
	move.w	column_len(a6),d1
	subq.w	#variables_page_nb,d1
	divu	d1,d0
	and.l	#$ffff,d0
	addq.l	#1,d0
	move.l	d0,-(sp)
	pea	page_nb_text
	move.l	a3,a0
	bsr	sprintf
	addq.w	#8,sp

	move.l	a3,a2
	_JSR	print_instruction
	addq.w	#1,y_pos(a6)
	move.l	a5,d6			;ptr de haut de page
	move.l	d7,d5			;compteur de haut de page
	move.w	column_len(a6),d4		;compteur de lignes
	subq.w	#variables_page_nb+1,d4
.more_line:
	cmp.l	a4,a5
	bge.s	.test_if_finish1
	bsr	sprint_var_line
.write:	lea	w6_db(a6),a0		;ecrire la ligne
	move.l	a3,a1
	_JSR	write_line_ascii

	move.l	a5,a0			;prochaine variable
	_JSR	get_next_var
	bmi.s	.test_if_finish1
	move.l	a0,a5
	addq.l	#1,d7

	addq.w	#1,y_pos(a6)
	dbf	d4,.more_line
	moveq	#0,d0
	bra.s	.end
.test_if_finish1:
	clr.b	(a3)
.l40:	lea	w6_db(a6),a0
	move.l	a3,a1
	_JSR	write_line_ascii
	addq.w	#1,y_pos(a6)
	dbf	d4,.l40
.abort:	moveq	#-1,d0
.end:	movem.l	(sp)+,d3
	rts

sprint_var_line:
	move.l	a3,-(sp)
	lea	lower_level_buffer(a6),a3

	move.w	VAR_TYPE(a5),d0
	cmp.w	#BLWORD,d0
	beq.s	.bl
	cmp.w	#ROWORD,d0
	beq.s	.bl

	;la par defaut
	;ptr
	move.l	VAR_VALUE(a5),d1
	cmp.w	#EXWORD,d0
	beq.s	.ex
	move.l	d1,-(sp)
	;type
	move.w	d0,-(sp)
	;nom
	move.l	VAR_NAME(a5),-(sp)
	cmp.w	#LRWORD,d0
	beq.s	.lr
	pea	la_format_text
	bra.s	.suite
.ex:
	IFNE	ATARIST
	move.l	text_buf(a6),-(sp)
	add.l	d1,(sp)

	moveq	#'+',d3
	move.l	d1,-(sp)
	bpl.s	.positive
	neg.l	d1
	move.l	d1,(sp)
	moveq	#'-',d3
.positive:
	move.w	d3,-(sp)
	move.w	d0,-(sp)		;type
	move.l	VAR_NAME(a5),-(sp)	;nom
	pea	ex_format_text
	move.l	a3,a0
	bsr	sprintf
	lea	20(sp),sp
	ENDC	; d'ATARIST
	IFNE	AMIGA
	jsr	print_amiga_ex
	ENDC
	bra.s	.end
.lr:
	pea	lr_format_text
.suite:
	move.l	a3,a0
	bsr	sprintf
	lea	14(sp),sp
	bra.s	.end
.bl:
	move.l	VAR_BLPTR(a5),a0
	;longueur
	moveq	#1,d0
	add.l	BLPTR_END(a0),d0
	sub.l	BLPTR_START(a0),d0
	move.l	d0,-(sp)
	;ptr2
	move.l	BLPTR_END(a0),-(sp)
	;ptr1
	move.l	BLPTR_START(a0),-(sp)
	;type
	move.w	BLPTR_TYPE(a0),d0
	andi.w	#$7f7f,d0
	move.w	d0,-(sp)
	;nom
	move.l	VAR_NAME(a5),-(sp)
	pea	bl_format_text
	move.l	a3,a0
	bsr	sprintf
	lea	22(sp),sp
.end:
	move.l	a3,a2
	move.l	(sp)+,a3

	;rechercher la variable dans l'arbre
	move.l	VAR_VALUE(a5),a1
	tst.b	profiler_flag(a6)
	beq.s	.not_in_clip
	tst.b	unclip_profile_flag(a6)
	bne.s	.no_clip
	IFNE	ATARIST
	cmp.l	text_buf(a6),a1
	blt.s	.not_in_clip
	cmp.l	end_buf(a6),a1
	bge.s	.not_in_clip
	ENDC
	IFNE	AMIGA
	jsr	test_if_in_prg
	bne.s	.not_in_clip
	ENDC
.no_clip:
	move.l	var_tree_nb(a6),d0
	beq.s	.not_in_tree
	move.l	var_tree_addr(a6),d1
	lea	comp_var_tree_2,a0
	bsr	trouve
	bne.s	.not_in_tree
	move.l	VAR_TREE_COUNT(a0),d0
	move.l	a3,a0
	bsr	sprint_profile_info
	lea	0(a3,d0.w),a1
	bra.s	.copy_string
.not_in_clip:
.not_in_tree:
	move.l	a3,a1
.copy_string:
	move.l	a2,a0
	bsr	strcpy
	rts

;a0=buffer
;d0=ticks
sprint_profile_info:
	move.l	d0,-(sp)
	;0 ticks
	beq.s	.zero

	move.l	var_tree_count(a6),d2
	;0 count
	beq.s	.zero

	move.l	#10000,d1
	_JSR	lmul
	move.l	d0,d1
	move.l	d2,d0
	jsr	_div
	divu	#100,d1
.sprint:
	swap	d1
	move.l	d1,-(sp)
	pea	.profile_info_text(pc)
	bsr	sprintf
	lea	12(sp),sp
	rts
.zero:
	moveq	#0,d1
	bra.s	.sprint
;.profile_info_text:	dc.b	"% lx ",0
.profile_info_text:	dc.b	"% 3d.%02d%% % lx ",0
	even

calc_var_tree_count:
	moveq	#0,d0
	move.l	var_tree_nb(a6),d1
	beq.s	.end
	move.l	var_tree_addr(a6),a0
.l1:
	add.l	VAR_TREE_COUNT(a0),d0
	lea	VAR_TREE_SIZE(a0),a0
	subq.l	#1,d1
	bgt.s	.l1
.end:
	rts

init_vars:
	bsr	calc_var_tree_count
	move.l	d0,var_tree_count(a6)
	move.l	table_var_addr(a6),a5
	move.l	current_var_addr(a6),a4
	moveq	#0,d7
	lea	line_buffer(a6),a3
	moveq	#0,d0
	rts

line_up_vars:
	move.l	d6,a0
	_JSR	get_prev_var
	bmi.s	dont_redraw_vars
	move.l	a0,a5
	move.l	d5,d7
	subq.l	#1,d7
	bra.s	redraw_vars

line_down_vars:
	move.l	d6,a0
	_JSR	get_next_var
	bmi.s	dont_redraw_vars
	move.l	a0,a5
	move.l	d5,d7
	addq.l	#1,d7
	bra.s	redraw_vars

page_up_vars:
	move.l	d6,a0
	_JSR	get_prev_var
	bmi.s	dont_redraw_vars
	move.l	d6,a0
	move.w	column_len(a6),d2
	subq.w	#variables_page_nb+1,d2
.l1:
	_JSR	get_prev_var
;	bmi.s	dont_redraw_vars
	dbmi	d2,.l1
	move.l	a0,a5
	move.l	d5,d7
	moveq	#0,d0
	move.w	column_len(a6),d0
	subq.w	#variables_page_nb+1,d0
	sub.w	d2,d0
	sub.l	d0,d7
	bra.s	redraw_vars

page_down_vars:
	bra.s	redraw_vars

home_vars:
	move.l	table_var_addr(a6),a5
	moveq	#0,d7
	bra.s	redraw_vars

shift_home_vars:
	move.l	current_var_addr(a6),a0
	_JSR	get_prev_var
	bmi.s	dont_redraw_vars
	move.l	a0,a5
	move.l	current_var_nb(a6),d7
;	bra.s	redraw_vars

redraw_vars:
	moveq	#0,d0
	rts

dont_redraw_vars:
	moveq	#-1,d0
	rts

;  #] List Variables:
;  #[ set_new_address:[A] dis src

set_new_address:
 bsr	get_curwind_type
 bmi.s	.end
.again:
 suba.l a0,a0
 lea ask_new_addr_text,a2
 _JSR get_expression
 bmi.s .end
 beq.s .3
 _JSR flash
 bra.s .again
.3:
 move.l d0,a0
 bsr put_curwind_addr
 bsr redraw_all_windows
 bra build_lock
.end:
 rts

;  #] set_new_address:
;  #[ Alt S:[Alt_S]
alt_s:
 tst.b	window_magnified(a6)
 beq.s	.split
.end:
 rts
.split
 move.w	big_window_coords+2(a6),d2	;screen.y
 add.w	big_window_coords+6(a6),d2	;+screen.h
 lea	w1_db(a6),a0
 lea	windows_to_redraw(a6),a1
 move.w	window_selected(a6),d0
 cmp.w	#1,d0
 beq	.w1
 btst	#0,d0
 beq	.w2w4
 tst.b	$48(a0)
 beq	.createw5
.deletew5:
 move.l	#$0000ff00,(a1)
 clr.w	4(a1)
 clr.w	$48(a0)
 sub.w	$22(a0),d2
 move.w	d2,$26(a0)
 move.w	#-1,$28(a0)
 move.w	#3,window_selected(a6)
 bra	windows_init
.createw5:
 cmp.w	#3,$26(a0)		;w3.h>=3
 ble.s	.end
 move.l	#$0000ff00,(a1)
 move.w	#$ff00,4(a1)
 move.w	#-1,$48(a0)
 move.w	$22(a0),d0		;w3.y
 addq.w	#2,d0			;+2
 cmp.w	$42(a0),d0		;<w5.y?
 bgt.s	.resetw5			;oui, garder y
 move.w	$42(a0),d0		;w5.y
 move.w	d0,d1
 sub.w	$22(a0),d1		;w3.y
 move.w	d1,$26(a0)		;w3.h
 bra.s	.setw5
.resetw5:
 move.w	$26(a0),d0		;w3.h
 addq.w	#1,d0			;for odd size
 lsr	#1,d0			;/2
 move.w	d0,$26(a0)		;w3.h
 add.w	$22(a0),d0		;w3.y
 move.w	d0,$42(a0)		;w5.y
.setw5:
 move.w	d2,d1
 sub.w	d0,d1
 move.w	d1,$46(a0)		;w5.h
 IFNE	AMIGA
 tst.b	rs232_output_flag(a6)
 bne.s	.rs1
 subq.w	#1,$26(a0)		;w3.h--???
.rs1:
 ENDC
 sf	$29(a0)
 move.w	#5,window_selected(a6)
.relock:
 st	relock_vars_flag(a6)
 bra	windows_init
.w1:
 moveq	#-1,d0
 move.l	d0,(a1)
 move.w	d0,4(a1)
 tst.b	8(a0)
 beq.s	.createw1
.deletew1:
 clr.w	8(a0)			;off
 move.w	big_window_coords+2(a6),d0	;new y = y top
 move.w	$12(a0),d1		;old y
 move.w	d0,$12(a0)		;w2.y
 move.w	d0,$22(a0)		;w3.y
 sub.w	d0,d1			;offset h
 add.w	d1,$16(a0)
 add.w	d1,$26(a0)
 st	$19(a0)			;w2=cur
 move.w	#2,window_selected(a6)	;cur=w2
 bra	windows_init
.createw1:			;en cas de alt_1
 move.w	_GENWIND_Y(a0),d0		;w1.y
 add.w	_GENWIND_H(a0),d0		;+w1.h
 move.w	d0,$12(a0)		;w2.y
 move.w	d0,$22(a0)		;w3.y
 move.w	d2,d1
 sub.w	d0,d1
 move.w	d1,$16(a0)		;w2.h
 move.w	d1,$26(a0)		;w3.h
 tst.b	_GENWIND_ON+_GENWIND_SIZEOF*3(a0)	;w4 on?
 beq.s	.now4
 move.w	$12(a0),d1
 add.w	$16(a0),d1
 addq.w	#2,d1
 cmp.w	d2,d1			;w2.y+w2.h+2>screen.h?
 ble.s	.okw4
 subq.w	#2,_GENWIND_H+_GENWIND_SIZEOF(a0)	;w2.h-=2
.okw4:
 move.w	_GENWIND_Y+_GENWIND_SIZEOF(a0),d0
 add.w	_GENWIND_H+_GENWIND_SIZEOF(a0),d0
 move.w	d0,_GENWIND_Y+_GENWIND_SIZEOF*3(a0)	;w4.y
 move.w	d2,d1
 sub.w	d0,d1
 move.w	d1,_GENWIND_H+_GENWIND_SIZEOF*3(a0)	;w4.h
.now4:
 tst.b	_GENWIND_ON+_GENWIND_SIZEOF*4(a0)	;w5 on?
 beq.s	.now5
 move.w	$22(a0),d1
 add.w	$26(a0),d1
 addq.w	#2,d1
 cmp.w	d2,d1				;w3.y+w3.h+2>screen.h?
 ble.s	.okw5
 subq.w	#2,_GENWIND_H+_GENWIND_SIZEOF*2(a0)	;w3.h-=2
.okw5:
 move.w	_GENWIND_Y+_GENWIND_SIZEOF*2(a0),d0
 add.w	_GENWIND_H+_GENWIND_SIZEOF*2(a0),d0
 move.w	d0,_GENWIND_Y+_GENWIND_SIZEOF*4(a0)	;w5.y
 move.w	d2,d1
 sub.w	d0,d1
 move.w	d1,_GENWIND_H+_GENWIND_SIZEOF*4(a0)	;w5.h
.now5:
 st	8(a0)
 st	9(a0)
 move.w	#1,window_selected(a6)
 bra	.relock

.w2w4:
 tst.b	$38(a0)
 beq.s	.createw4
.deletew4:
 move.l	#$00ff0000,(a1)
 clr.w	4(a1)
 clr.w	$38(a0)
 sub.w	$12(a0),d2
 move.w	d2,$16(a0)
 move.w	#-1,$18(a0)
 move.w	#2,window_selected(a6)
 bra	windows_init
.createw4:
 cmp.w	#3,$16(a0)		;w2.h>=3
 ble	.end
 move.l	#$00ff00ff,(a1)
 clr.w	4(a1)
 move.w	#-1,$38(a0)
 move.w	$12(a0),d0		;w2.y
 addq.w	#2,d0
 cmp.w	$32(a0),d0		;w4.y
 bgt.s	.resetw4
 move.w	$32(a0),d0
 move.w	d0,d1
 sub.w	$12(a0),d1		;w2.y
 move.w	d1,$16(a0)		;w2.h
 bra.s	.setw4
.resetw4:
 move.w	$16(a0),d0		;w2.h
 addq.w	#1,d0			;for odd size
 lsr	#1,d0			;/2
 move.w	d0,$16(a0)
 add.w	$12(a0),d0		;w2.y
 move.w	d0,$32(a0)		;w4.y
.setw4:
 move.w	d2,d1
 sub.w	d0,d1
 move.w	d1,$36(a0)		;w4.h
 IFNE	AMIGA
 tst.b	rs232_output_flag(a6)
 bne.s	.rs2
 subq.w	#1,$16(a0)
.rs2:
 ENDC
 sf	$19(a0)
 move.w	#4,window_selected(a6)
 bra	.relock

;  #] Alt S:
;  #[ Alt T:[Alt_T]
alt_t:
 bsr	get_curwind_type
 move.w d1,d0
 addq.w #1,d0
 cmp.w #ASCWIND_TYPE,d0				; source
 ble.s set_wind_type
 moveq #REGWIND_TYPE,d0
set_wind_type:
 move.w d0,-(sp)
 bsr get_noaddr_curwind
 move.w (sp)+,d1
 move.w d1,$e(a0,d0.w)
 ;offset
 move.w d0,d7
 ;# fenetre
 move.l a0,a4
 lea windows_to_redraw(a6),a5
 clr.l (a5)
 clr.w 4(a5)
 st 0(a5,d2.w)
 move.w d2,-(sp)
 move.w d1,window_buffer+$e(a6)
 move.w (sp),d0
 bsr build_lock
 bsr redraw_inside_window
 move.w (sp)+,d0
 bra update_title

;  #] Alt T:
;  #[ Set_wind_type:[0~7]
set_wind_type_0:			;reg
	moveq	#REGWIND_TYPE,d0
	bra.s	set_wind_type
set_wind_type_1:			;dis
	moveq	#DISWIND_TYPE,d0
	bra.s	set_wind_type
set_wind_type_2:			;hex
	moveq	#HEXWIND_TYPE,d0
	bra.s	set_wind_type
set_wind_type_3:			;asc
	moveq	#ASCWIND_TYPE,d0
	bra.s	set_wind_type
set_wind_type_4:			;log
	moveq	#WATWIND_TYPE,d0
	bra.s	set_wind_type

	IFNE	sourcedebug
set_wind_type_5:			;src
	tst.w	source_type(a6)
	beq.s	.end
	_JSR	update_source_pc_ptr
	moveq	#SRCWIND_TYPE,d0
	bra.s	set_wind_type
.end:
	rts
set_wind_type_6:			;var
	tst.w	source_type(a6)
	beq.s	.end
	_JSR	update_curwind_tcvars
	moveq	#VARWIND_TYPE,d0
	bra.s	set_wind_type
.end:
	rts
set_wind_type_7:			;inspect
	tst.w	source_type(a6)
	beq.s	.end
	moveq	#INSWIND_TYPE,d0
	bra.s	set_wind_type
.end:
	rts
	ENDC	;de sourcedebug
;  #] Set_wind_type:[0~4]
	IFNE	sourcedebug
;  #[ Set_local_type:[Ctl_Alt_L]
set_local_type:
	moveq	#_VARWIND_LOCAL_TYPE,d0
	bra.s	_set_lsg_type
;  #] Set_local_type:
;  #[ Set_static_type:[Ctl_Alt_S]
set_static_type:
	moveq	#_VARWIND_STATIC_TYPE,d0
	bra.s	_set_lsg_type
;  #] Set_static_type:
;  #[ Set_global_type:[Ctl_Alt_G]
set_global_type:
	moveq	#_VARWIND_GLOBAL_TYPE,d0
;	bra.s	_set_lsg_type
_set_lsg_type:
	move.w	d0,-(sp)
	bsr	get_curwind_type
	move.w	(sp)+,d0
	cmp.w	#VARWIND_TYPE,d1
	bne.s	.end
	bsr	put_curvarwind_type
	bra	redraw_curwind
.end:
	rts
;  #] Set_global_type:
	ENDC
;  #[ Alt Z:[Alt_Z]

alt_z:
 tst.b	window_magnified(a6)
 bne	esc
 bsr	get_noaddr_curwind
 move.l	a0,a2
 add.w	d0,a0
 lea	windows_to_redraw(a6),a1
 clr.l	(a1)
 clr.w	4(a1)
 st	0(a1,d2.w)
 lea window_buffer(a6),a1
 move.l (a0),(a1)+
 move.l 4(a0),(a1)+
 move.l 8(a0),(a1)+
 move.l $c(a0),(a1)+
 moveq #4,d0
.1:
 move.b 8(a2),(a1)+
 sf 8(a2)
 add.w #$10,a2
 dbf d0,.1
 st 8(a0)
 move.l	big_window_coords(a6),(a0)+
 move.w line_len(a6),(a0)+
 move.w column_len(a6),(a0)+
 IFNE	AMIGA
; patch a virer a la 1ere occasion
 cmp.w	#31,-2(a0)
 blt.s	.no_rs232
 subq.w	#1,-2(a0)	;pour le titre
.no_rs232:
 ENDC
 move.w #7,memory_loop_value(a6)
 st window_magnified(a6)
 bsr build_lock
 _JSR little_clear_screen
 bra windows_init

;  #] Alt Z:
;  #[ Ask break:[Alt_B] dis src
;--- IN --
;d4=option
;d5=eval @
;d6=vector #
;d7=@

;a5=ptr sur @
;a4=ptr sur type
;a3=ptr sur eval
ask_break:
	suba.l	a4,a4
.again:
	move.l	a4,a0
	st	no_eval_flag(a6)
	lea	ask_break_text,a2
	_JSR	get_expression
	tst.w	d1
	bmi.s	.end
	bgt.s	.flash
	move.l	a0,a4
	lea	askbreak_sscanform,a1
	bsr	sscanf
	bmi.s	.flash
	move.l	a0,a5
	;--- ADDRESS ---
	;si on tape rien:
	;breakpoint permanent (pour l'instant simple)
	;de type default
	;a l'@ courante
	tst.w	(a5)+
	bmi.s	.def_addr
	move.l	(a5)+,d7
	bra.s	.eval_eval
.def_addr:
	;default tout
	bsr	get_curwind
	beq.s	.dis
	IFNE	sourcedebug
	cmp.w	#SRCWIND_TYPE,d1
	beq.s	.dis
	ENDC	;de sourcedebug
	bra.s	.flash
.dis:
	move.l	a1,d7
	;--- EVAL ---
.eval_eval:
	tst.w	(a5)+
	bmi.s	.def_eval
	move.l	a5,d5
	;depiler la chaine
	move.l	a5,a0
	bsr	strlen
	addq.w	#1,d0
	add.w	d0,a5
;-------
	btst	#0,d0
	beq.s	.no_add
	tst.b	(a5)+
.no_add:
;-------
	bra.s	.eval_option
	;si rien,break permanent (pour l'instant simple)
.def_eval:
;	lea	one_text(pc),a3
	move.l	def_break_eval_addr(a6),d5
	;--- OPTION ---
.eval_option:
	tst.w	(a5)+
	bmi.s	.def_option
	move.w	(a5)+,d4
	bra.s	.eval_vector
.def_option:
	move.l	def_break_perm(a6),d4
	;--- VECTEUR ---
.eval_vector:
	tst.w	(a5)+
	bmi.s	.def_vector
	move.w	(a5)+,d6
	bra.s	.set_the_break
.def_vector:
	move.l	def_break_vec(a6),d6
.set_the_break:
	move.l	d7,a0
	move.l	d4,d0
	move.l	d5,a1
	move.l	d6,d1
	_JSR	toggle_break
.end:
	rts
.flash:
	_JSR	flash
	bra	.again
;  #] Ask break:
;  #[ Ctrl B:[Ctl_B] dis src
ctrl_b:
	bsr	get_curwind
	beq.s	.dis
	IFNE	sourcedebug
	cmp.w	#SRCWIND_TYPE,d1
	beq.s	.dis
	ENDC	;de sourcedebug
	moveq	#0,d0
	rts
.dis:
	move.l	a1,d0
	IFNE	_68030
	tst.b	chip_type(a6)
	bne.s	.no_and
	ENDC
	andi.l	#$ffffff,d0
.no_and:
	move.l	d0,a0
	move.l	def_break_perm(a6),d0
	move.l	def_break_vec(a6),d1
	move.l	def_break_eval_addr(a6),a1
	_JSR	toggle_break
	moveq	#-1,d0
	rts
;  #] Ctrl B:
;  #[ Kill_All_Breaks:[Ctl_K]
kill_all_breaks:
	tst.l	current_breaks_nb(a6)
	beq.s	.cant_kill
	tst.l	breaks_addr(a6)
	beq.s	.cant_kill
.again:
	suba.l	a0,a0
	lea	kill_all_text,a2
	_JSR	yesno
	beq.s	.no_kill
	subq.w	#1,d0
	beq.s	.kill
	subq.w	#1,d0
	beq.s	.kill_one
.flash:
	_JSR	flash
	bra.s	.again
.kill_one:
.again_2:
	suba.l	a0,a0
	lea	ask_kill_break_text,a2
	_JSR	get_expression
	bmi.s	.no_kill
	beq.s	.good
	_JSR	flash
	bra.s	.again_2
.good:
	_JSR	_kill_break_nb
	bra.s	.redraw
.kill:
	_JSR	_kill_all_breaks
.redraw:
	bsr	redraw_all_windows
	moveq	#-1,d0
.end:
	rts
.cant_kill:
	lea	no_breaks_error_text,a2
	_JSR	print_error
.no_kill:
	moveq	#0,d0
	bra.s	.end
;  #] Kill_All_Breaks:
;  #[ cd: change directory [D]
;a5=ptr sur chaine
cd:
.again:
	suba.l	a0,a0
	lea	ask_cd_text,a2
	st	no_eval_flag(a6)
	_JSR	get_expression
	bmi.s	.error
	beq.s	.good
	_JSR	flash
	bra.s	.again
.good:
	_JSR	set_drivepath
	bmi.s	.error
	lea	dsetpath_done_text,a2
	_JSR	print_result
	moveq	#0,d0
	bra.s	.end
.error:
	moveq	#-1,d0
.end:
	rts
;  #] cd:
;  #[ Print memory free:[Alt_M]
print_memfree:
	IFNE	ATARIST
	lea	line_buffer(a6),a2
	cmp.w	#_TT,machine_type(a6)
	bne.s	.st
	moveq	#1,d0
	_JSR	get_free_memory
	move.l	d0,-(sp)

	moveq	#0,d0
	_JSR	get_free_memory
	move.l	d0,-(sp)
	add.l	4(sp),d0
	move.l	d0,-(sp)

	pea	free_memory_text
	pea	free_2_memory_text
	move.l	a2,a0
	bsr	sprintf
	lea	20(sp),sp
	bra.s	.print
.st:	moveq	#0,d0
	_JSR	get_free_memory
	move.l	d0,-(sp)
	pea	free_memory_text
	pea	free_1_memory_text
	move.l	a2,a0
	bsr	sprintf
	lea	12(sp),sp
.print:	_JMP	print_result
	ENDC	; d'ATARIST

	IFNE	AMIGA
	lea	line_buffer(a6),a2
	subq.w	#4,sp
	moveq	#4,d1
	CALLEXEC	AvailMem
	move.l	d0,-(sp)
	moveq	#2,d1
	CALLEXEC	AvailMem
	move.l	d0,-(sp)
	add.l	4(sp),d0
	move.l	d0,8(sp)
	pea	present_freemem_text
	move.l	a2,a0
	bsr	sprintf
	lea	16(sp),sp
	_JMP	print_result
	ENDC	;d'AMIGA
;  #] Print memory free:
;  #[ Alt E:[Alt_E]
	include	"alt_e.s"
;  #] Alt E:
;  #[ Tab:[Tab]
tab:
 bsr get_noaddr_curwind
 sf 9(a0,d0.w)
 move.w window_selected(a6),d0
 move.w d0,d1
 mulu #$12,d0
 move.w d1,d7
 swap d7
 lsl.w #4,d1
 adda.w d1,a0
 jmp .another_time(pc,d0.w)
.another_time:
 moveq #1,d2
 tst.b 8(a0)
 beq.s .2
 tst.b 9(a0)
 beq.s .this
.2:
 lea $10(a0),a0
 moveq #2,d2
 tst.b 8(a0)
 beq.s .3
 tst.b 9(a0)
 beq.s .this
.3:
 lea $10(a0),a0
 moveq #3,d2
 tst.b 8(a0)
 beq.s .4
 tst.b 9(a0)
 beq.s .this
.4:
 add.w #$10,a0
 moveq #4,d2
 tst.b 8(a0)
 beq.s .5
 tst.b 9(a0)
 beq.s .this
.5:
 add.w #$10,a0
 moveq #5,d2
 tst.b 8(a0)
 beq.s .1
 tst.b 9(a0)
 beq.s .this
.1:
 nop
 nop
 lea w1_db(a6),a0
 bra.s .another_time
.this:
 st dont_redraw_all(a6)
 st 9(a0)
 move.w d2,d7
 move.w d2,window_selected(a6)
 lsl.w #4,d7
 lea w1_db(a6),a0
 move.b -7(a0,d7.w),current_window_flag(a6)
 move.w -$10(a0,d7.w),upper_x(a6)
 move.w -$e(a0,d7.w),upper_y(a6)
 move.w -$c(a0,d7.w),lower_x(a6)
 move.w -$a(a0,d7.w),lower_y(a6)
; swap d7
 move.w d7,-(sp)
 _JSR draw_window
 move.w (sp)+,d7
 move.w d7,d0
 lsr.w #4,d0
 subq.w #1,d0
 _JSR update_title
 swap d7
 lsl.w #4,d7
 lea w1_db(a6),a0
 move.b -7(a0,d7.w),current_window_flag(a6)
 move.w -$10(a0,d7.w),upper_x(a6)
 move.w -$e(a0,d7.w),upper_y(a6)
 move.w -$c(a0,d7.w),lower_x(a6)
 move.w -$a(a0,d7.w),lower_y(a6)
 _JSR draw_window
 move.w d7,d0
 lsr.w #4,d0
 subq.w #1,d0
 _JSR update_title
 sf dont_redraw_all(a6)
.not_allowed:
 rts

;  #] Tab:
;  #[ Esc:[Esc]

esc:
 tst.b window_magnified(a6)
 beq.s .1
 bsr get_noaddr_curwind
 lea window_buffer(a6),a1
 add.w d0,a0
 move.l (a1)+,(a0)+
 move.l (a1)+,(a0)+
 move.l (a1)+,(a0)+
 move.l (a1)+,(a0)+
 lea w1_db(a6),a0
 moveq #4,d0
.2:
 move.b (a1)+,8(a0)
 lea $10(a0),a0
 dbf d0,.2
 sf window_magnified(a6)
 lea windows_to_redraw(a6),a0
 move.l #-1,(a0)
 move.w #-1,4(a0)
 bsr build_lock
 st relock_vars_flag(a6)
 bsr windows_init
.1:
 rts

;  #] Esc:
;  #[ Update SR: [I]

update_sr:
 suba.l	a5,a5
.again:
 sf	keys_byte(a6)
 move.l	kbshift_addr(a6),a0
 clr.b	(a0)
 move.l	a5,a0
 lea	update_sr_text,a2
 _JSR	get_expression
 bmi.s	.end
 beq.s	.good
 _JSR	flash
 bra.s	.again
.good:
 move.l	a0,a5
 move.w	d0,d3
	moveq	#-1,d1
	_JSR	put_internal_sr
 bpl.s	.good2
 _JSR	flash
 bra.s	.again
.good2:
 move.w	d3,-(sp)
 pea	sr_updated_text
 lea	line_buffer(a6),a2
 move.l	a2,a0
 bsr	sprintf
 addq.w	#6,sp
 _JSR	print_result
 bra redraw_all_windows
.end:
 rts

;  #] Update SR:
;  #[ Ctrl S:[Ctl_S] dis src
ctrl_s:
	move.l	pc_buf(a6),a0
	IFNE	sourcedebug
	_JSR	get_next_code_addr
	bgt.s	.set_pc
	move.l	pc_buf(a6),a0
	ENDC	;de sourcedebug
	bsr	get_next_instruction
.set_pc:
	move.l	a0,pc_buf(a6)
	bsr	redraw_relock_all
	lea	skipped_text,a2
	_JMP	print_result
;  #] Ctrl S:
;  #[ Ctrl 0:[Ctl_0]
ctrl_0:
	move.l	a0_buf(a6),a0
	moveq	#0,d0
	bra	ctrl_areg
;  #] Ctrl 0:]
;  #[ Ctrl 1:[Ctl_1]
ctrl_1:
	move.l	a1_buf(a6),a0
	moveq	#1,d0
	bra	ctrl_areg
;  #] Ctrl 1:]
;  #[ Ctrl 2:[Ctl_2]
ctrl_2:
	move.l	a2_buf(a6),a0
	moveq	#2,d0
	bra	ctrl_areg
;  #] Ctrl 2:]
;  #[ Ctrl 3:[Ctl_3]
ctrl_3:
	move.l	a3_buf(a6),a0
	moveq	#3,d0
	bra	ctrl_areg
;  #] Ctrl 3:]
;  #[ Ctrl 4:[Ctl_4]
ctrl_4:
	move.l	a4_buf(a6),a0
	moveq	#4,d0
	bra.s	ctrl_areg
;  #] Ctrl 4:]
;  #[ Ctrl 5:[Ctl_5]
ctrl_5:
	move.l	a5_buf(a6),a0
	moveq	#5,d0
	bra.s	ctrl_areg
;  #] Ctrl 5:]
;  #[ Ctrl 6:[Ctl_6]
ctrl_6:
	move.l	a6_buf(a6),a0
	moveq	#6,d0
	bra.s	ctrl_areg
;  #] Ctrl 6:]
;  #[ Ctrl 7:[Ctl_7]
ctrl_7:
	move.l	a7_buf(a6),a0
	moveq	#-1,d0
	bra.s	ctrl_areg
;  #] Ctrl 7:]
;  #[ Ctrl 8:[Ctl_8]
ctrl_8:
	move.l	ssp_buf(a6),a0
	moveq	#-1,d0
	bra.s	ctrl_areg
;  #] Ctrl 8:]
;  #[ Ctrl 9:[Ctl_9]
ctrl_9:
	move.l	pc_buf(a6),a0
	moveq	#-1,d0
	bra.s	ctrl_areg
;  #] Ctrl 9:]
;  #[ SCtrl Areg: @ ds a0 dis src

sctrl_areg:
	move.l	a0,a2
	move.l	d0,-(sp)
	_JSR	read_baderr
	movem.l	(sp)+,d0
	bne.s	.end
	move.l	(a2),a0
	bra.s	ctrl_areg
.end:
	lea	sctrl_areg_error_text,a2
	_JMP	print_error

;  #] SCtrl Areg:* @ ds a0
;  #[ Ctrl Areg: @ ds a0 dis src

ctrl_areg:
	movem.l	d0/a0,-(sp)
	bsr	get_curwind_type
	movem.l	(sp)+,d0/a0
	bmi.s	.reg
	bsr	put_curwind_addr
	bsr	build_lock
	bra	redraw_curwind
.end:
	rts
.reg:
	tst.w	d0
	bmi.s	.2
	lea	a0_asc_flag(a6),a0
	not.b	0(a0,d0.w)
.2:
	bra	redraw_curwind
;  #] Ctrl Areg:
;  #[ SCtrl 0:[SftCtl_0]
sctrl_0:

	move.l	a0_buf(a6),a0
	moveq	#8,d0				; fp0
	bra.s	sctrl_areg
;  #] SCtrl 0:]
;  #[ SCtrl 1:[SftCtl_1]
sctrl_1:
	move.l	a1_buf(a6),a0
	moveq	#9,d0				; fp1
	bra.s	sctrl_areg
;  #] SCtrl 1:]
;  #[ SCtrl 2:[SftCtl_2]
sctrl_2:
	move.l	a2_buf(a6),a0
	moveq	#$a,d0				; fp2
	bra.s	sctrl_areg
;  #] SCtrl 2:]
;  #[ SCtrl 3:[SftCtl_3]
sctrl_3:
	move.l	a3_buf(a6),a0
	moveq	#$b,d0				; fp3
	bra.s	sctrl_areg
;  #] SCtrl 3:]
;  #[ SCtrl 4:[SftCtl_4]
sctrl_4:
	move.l	a4_buf(a6),a0
	moveq	#$c,d0				; fp4
	bra	sctrl_areg
;  #] SCtrl 4:]
;  #[ SCtrl 5:[SftCtl_5]
sctrl_5:
	move.l	a5_buf(a6),a0
	moveq	#$d,d0				; fp5
	bra	sctrl_areg
;  #] SCtrl 5:]
;  #[ SCtrl 6:[SftCtl_6]
sctrl_6:
	move.l	a6_buf(a6),a0
	moveq	#$e,d0				; fp6
	bra	sctrl_areg
;  #] SCtrl 6:]
;  #[ SCtrl 7:[SftCtl_7]
sctrl_7:
	move.l	a7_buf(a6),a0
	moveq	#$f,d0				; fp7
	bra	sctrl_areg
;  #] SCtrl 7:]
;  #[ SCtrl 8:[SftCtl_8]
sctrl_8:
	move.l	ssp_buf(a6),a0
	moveq	#-1,d0
	bra	sctrl_areg
;  #] SCtrl 8:]
;  #[ SCtrl 9:[SftCtl_9]
sctrl_9:
	move.l	pc_buf(a6),a0
	moveq	#-1,d0
	bra	sctrl_areg
;  #] SCtrl 9:]
;  #[ Alt 1:[Alt_1]
alt_1:	moveq	#1,d0
	bra.s	alt_numero
;  #] Alt 1:
;  #[ Alt 2:[Alt_2]
alt_2:	moveq	#2,d0
	bra.s	alt_24
;  #] Alt 2:
;  #[ Alt 4:[Alt_4]
alt_4:	moveq	#4,d0
alt_24:	move.w	w3_db+_GENWIND_X(a6),d1
	cmp.w	big_window_coords(a6),d1
	beq.s	.end
	bra.s	alt_numero
.end:	rts
;  #] Alt 4:
;  #[ Alt 3:[Alt_3]
alt_3:	moveq	#3,d0
	bra.s	alt_35
;  #] Alt 3:
;  #[ Alt 5:[Alt_5]
alt_5:	moveq	#5,d0
alt_35:	move.w	w2_db+_GENWIND_W(a6),d1
	cmp.w	big_window_coords+4(a6),d1
	beq.s	.end
	bra.s	alt_numero
.end:	rts
;  #] Alt 5:
;  #[ Alt numero de fenetre:
alt_numero:
 tst.b low_rez(a6)
 beq.s .go
 cmp.w #4,d0
 blt.s .go
.end:
 rts
.go:
 tst.b window_magnified(a6)
 bne.s .end
 move.w window_selected(a6),d1
 cmp.w d0,d1
 beq.s .end
 lea windows_to_redraw(a6),a0
 moveq #-1,d2
 move.l d2,(a0)
 move.w d2,4(a0)
 lea w1_db(a6),a1
 move.w d1,d2
 lsl.w #4,d1
 sf -7(a1,d1.w)
 subq.w #1,d2
 exg d0,d2
 movem.l d2/a1,-(sp)
 move.b -7(a1,d1.w),current_window_flag(a6)
 move.w -$10(a1,d1.w),upper_x(a6)
 move.w -$e(a1,d1.w),upper_y(a6)
 move.w -$c(a1,d1.w),lower_x(a6)
 move.w -$a(a1,d1.w),lower_y(a6)
 st dont_redraw_all(a6)
 move.w d1,-(sp)
 _JSR draw_window
;
 move.w (sp)+,d0
 sub.w #$10,d0
 lsr.w #4,d0
 movem.l d0-d2/a0-a2,-(sp)
 bsr update_title
 movem.l (sp)+,d0-d2/a0-a2
;
 movem.l (sp)+,d2/a1
 move.w d2,window_selected(a6)
 lsl.w #4,d2
 st -7(a1,d2.w)
 tst.b -8(a1,d2.w)
 beq.s	.create
 st current_window_flag(a6)
 move.w -$10(a1,d2.w),upper_x(a6)
 move.w -$e(a1,d2.w),upper_y(a6)
 move.w -$c(a1,d2.w),lower_x(a6)
 move.w -$a(a1,d2.w),lower_y(a6)
 move.w d2,-(sp)
 _JSR draw_window
;
 move.w (sp)+,d0
 sub.w #$10,d0
 lsr.w #4,d0
 movem.l d0-d2/a0-a2,-(sp)
 bsr update_title
 movem.l (sp)+,d0-d2/a0-a2
;
 sf dont_redraw_all(a6)
 rts
.create:
 sf dont_redraw_all(a6)
 bra alt_s
;  #] Alt numero de fenetre:
;  #[ Ctl_alt 1:[Ctl_Alt_1]
ctl_alt_1:
	moveq	#0,d0
	bra.s	ctl_alt_numero
;  #] Ctl_alt 1:
;  #[ Ctl_alt 2:[Ctl_Alt_2]
ctl_alt_2:
	moveq	#1,d0
	bra.s	ctl_alt_numero
;  #] Ctl_alt 2:
;  #[ Ctl_alt 3:[Ctl_Alt_3]
ctl_alt_3:
	moveq	#2,d0
	bra.s	ctl_alt_numero
;  #] Ctl_alt 3:
;  #[ Ctl_alt 4:[Ctl_Alt_4]
ctl_alt_4:
	moveq	#3,d0
	bra.s	ctl_alt_numero
;  #] Ctl_alt 4:
;  #[ Ctl_alt 5:[Ctl_Alt_5]
ctl_alt_5:
	moveq	#4,d0
;	bra.s	ctl_alt_numero
;  #] Ctl_alt 5:
;  #[ Ctl_alt numero de fenetre: dis src
ctl_alt_numero:
	bsr	get_wind
	move.l	a1,a0
	bsr	put_curwind_addr
	bsr	redraw_curwind
	bra	build_lock
.end:
	rts
;  #] Ctl_alt numero de fenetre:
	IFEQ	bridos
;  #[ Load ascii:[Alt_A]
load_ascii:
	suba.l	a5,a5
.flash:
	move.l	a5,a0
	lea	ask_load_source_text,a2
	st	no_eval_flag(a6)
	_JSR	get_expression
	bmi.s	.fin
	bgt.s	.flash
	move.l	a0,a5
	tst.b	(a0)
	beq.s	.flash

	suba.l	a1,a1
	moveq	#-1,d0
	moveq	#-1,d1
	moveq	#0,d2
	_JSR	load_file
	tst.l	d0
	bmi.s	.fin
	move.l	a0,a2
	move.l	a0,a4
	add.l	d0,a2
	move.l	a1,a5
	bsr	put_curwind_addr

	move.l	a5,a0
	move.l	a4,a1
	;a2 deja initialise
	move.w	#BLWORD,d0
	bsr	put_in_table
	moveq	#3,d0
	bsr	put_curwind_type
	bsr	redraw_all_windows
.fin:
	rts

;  #] Load ascii:
;  #[ Load binary:[B]
load_binary:
	suba.l	a4,a4
again_binary:
	lea	ask_load_binary_text,a2
	st	no_eval_flag(a6)
	move.l	a4,a0
	_JSR	get_expression
	beq.s	_load_binary
	bgt.s	flash_binary
	rts
flash_binary:
	_JSR	flash
	bra.s	again_binary
_load_binary:
	move.l	a0,a4
	tst.b	(a0)
	beq.s	flash_binary
	;par defaut pas d'@
	moveq	#-1,d7
	lea	loadbin_sscanform,a1
	bsr	sscanf
	bmi.s	flash_binary
	move.l	a0,a5
	tst.w	(a5)+
	bmi.s	flash_binary
	;nom de fichier
	move.l	a5,a0
	bsr	strlen
	addq.w	#1,d0
	add.w	d0,a5
;-------
	btst	#0,d0
	beq.s	.no_add
	tst.b	(a5)+
.no_add:
;-------
	tst.w	(a5)+
	bmi.s	.no_addr
	move.l	(a5),d7
.no_addr:
	;a0 deja charge
	;@ de chargement
	move.l	d7,a1
	moveq	#-1,d0
	moveq	#-1,d1
	moveq	#0,d2
	_JSR	load_file
	bmi.s	.fin
	move.l	a0,a2
	move.l	a0,a4
	add.l	d0,a2
	subq.l	#1,a2
	move.l	a1,a5
	bsr	put_curwind_addr

	move.l	a5,a0
	move.w	#BLWORD,d0
	move.l	a4,a1
	;a2 deja initialise
	bsr	put_var_and_tree
	bsr	redraw_all_windows
.fin:
	rts

;  #] Load binary:
	IFEQ	residant
;  #[ load_prg:[Ctl_L]
;d3=longueur text+data
;d4=handle

;a3=ptr sur dta
;a4=ptr incremental sur a5
;a5=ptr sur ma ligne de commande (nom du fichier+parametres)
load_prg:
	movem.l	d3-d7/a2-a5,-(sp)
	tst.l	p1_basepage_addr(a6)
	bne.s	.already
.again:
	suba.l	a0,a0
	st	no_eval_flag(a6)
	lea	ask_load_reloc_text,a2
	_JSR	get_expression
	bmi.s	.end2
	bgt.s	.flash
	lea	load_reloc_sscanform,a1
	bsr	sscanf
	bmi.s	.flash
	beq.s	.flash
	tst.w	(a0)+
	bmi.s	.flash

	;recopier le nom de fichier dans exec_name_buf
	lea	exec_name_buf(a6),a1
	bsr	strcpy
	lea	(a0,d0.w),a0
	btst	#0,d0
	beq.s	.no_add
	tst.b	(a0)+
.no_add:
	tst.w	(a0)+
	bpl.s	.ligne_com
;	bmi.s	.load_exec
	clr.w	argc(a6)
	bra.s	.load_exec
.ligne_com:
	;recopier la ligne de commande
	lea	argv_buffer(a6),a1
	bsr	strcpy
	;nb de car ds la ligne de commande
	subq.w	#1,d0
	move.w	d0,argc(a6)
.load_exec:
	bsr.s	load_executable
	bra.s	.end
.already:
	lea	reload_prg_error_text,a2
	_JSR	print_error
.end2:
	moveq	#-1,d0
.end:
	movem.l	(sp)+,d3-d7/a2-a5
	rts
.flash:
	_JSR	flash
	bra.s	.again

load_executable:
	movem.l	d3-d7/a2-a5,-(sp)
	;nom de l'executable
	lea	exec_name_buf(a6),a5
	move.l	a5,a0
	_JSR	_load_prg
	bmi	.error
	tst.b	(a5)
	beq	.end

	IFNE	AMIGA
	;recreer l'arbre des variables
	bsr	create_var_tree
	ENDC	;d'AMIGA
	tst.b	save_prinfo_flag(a6)
	beq.s	.no_load_prinfo
	bsr	load_prinfo
.no_load_prinfo:
	;setter les w 2 et 3
	moveq	#1,d0
	move.l	pc_buf(a6),a0
	_JSR	put_wind_addr
	moveq	#2,d0
	_JSR	put_wind_addr
	;redessiner
	st	relock_pc_flag(a6)
	moveq	#-1,d0
	lea	windows_to_redraw(a6),a0
	move.l	d0,(a0)+
	move.w	d0,(a0)
	_JSR	windows_init
	sf	relock_pc_flag(a6)

	;chercher la macro correspondant au nom de l'executable
	lea	exec_name_buf(a6),a0
	lea	misc_name_buf(a6),a1
	lea	mac_ext_text,a2
	bsr	get_new_ext
	move.l	a1,a0
	_JSR	execute_mac

	lea	higher_level_buffer(a6),a2
	move.l	p1_disk_len(a6),-(sp)
	move.l	a5,-(sp)
	pea	file_loaded_text
	move.l	a2,a0
	bsr	sprintf
	lea	12(sp),sp
	_JSR	print_result
	bra.s	.end
.error:	clr.b	(a5)
.end:	movem.l	(sp)+,d3-d7/a2-a5
	rts
;  #] load_prg:
	ENDC	;de residant
;  #[ Save binary:[S]
save_binary:
	suba.l	a4,a4
.again:
	move.l	a4,a0
	lea	ask_save_binary_text,a2
	st	no_eval_flag(a6)
	_JSR	get_expression
	bmi.s	.fin
	bgt.s	.flash
	move.l	a0,a4
	lea	savebin_sscanform,a1
	bsr	sscanf
	bmi.s	.flash
	beq.s	.flash
	cmp.w	#1,d0
	beq.s	.flash

	move.l	a0,a5
	tst.w	(a5)+
	bmi.s	.flash
	;nom de fichier
	move.l	a5,a0
	move.l	a5,a3
	bsr	strlen
	addq.w	#1,d0
	add.w	d0,a5
	btst	#0,d0
	beq.s	.no_add
	tst.b	(a5)+
.no_add:
	tst.w	(a5)+
	bmi.s	.no_addr
	move.l	(a5)+,d7
	bra.s	.length
.flash:
	_JSR	flash
	bra.s	.again
.no_addr:
	bsr	get_curwind
	move.l	a1,d7
.length:
	tst.w	(a5)+
	bmi.s	.flash
	move.l	(a5),d0
	beq.s	.flash
	bmi.s	.flash
	move.l	a3,a0
	move.l	d7,a1
	_JSR	save_file
.fin:
	rts
;  #] Save binary:
;  #[ Print bloc: [P]

print_bloc:
	suba.l	a4,a4
.again:	move.l	a4,a0
	lea	print_bloc_address_text,a2
	st	no_eval_flag(a6)
	_JSR	get_expression
	bmi	.end2
	bgt.s	.flash
	move.l	a0,a4
	lea	print_bloc_address_sscanform,a1
	bsr	sscanf
	bmi.s	.flash
	cmp.w	#2,d0
	blt.s	.flash
	move.l	a0,a5
	tst.w	(a5)+
	bmi	.flash
	move.l	(a5)+,d7
	tst.w	(a5)+
	bmi.s	.flash
	move.l	(a5)+,d6
	tst.l	d6
	bmi.s	.flash
	lea	print_bloc_labels_text,a2			;labels @
	_JSR	get_expression
	bmi.s	.again
	bgt.s	.nolab1
	move.l	d0,pb_buffer_address(a6)
	bra.s	.again2
.nolab1:	clr.l	pb_buffer_address(a6)
.again2:	lea	menu_print_bloc_text,a2
	bsr	ask_menu
	bmi.s	.again
	subq.w	#1,d0
	beq.s	.disk
	subq.w	#1,d0
	beq.s	.prt
	_JSR	flash
	bra.s	.again2
.flash:	_JSR	flash
	bra.s	.again
.prt:	move.l	d7,pb_beg_address(a6)
	move.l	d7,d0
	add.l	d6,d0
	move.l	d0,pb_end_address(a6)
	move.l	device_number(a6),-(sp)
	move.l	#PRINTER_OUTPUT,device_number(a6)
	_JSR	init_printer_display
	tst.w	d0
	bmi	.prtnotready
	bra.s	.begin
.disk:	move.l	d7,pb_beg_address(a6)
	move.l	d7,d0
	add.l	d6,d0
	move.l	d0,pb_end_address(a6)
.again3:suba.l	a0,a0
	lea	ask_save_text,a2
	st	no_eval_flag(a6)
	_JSR	get_expression
	bmi.s	.again2
	beq.s	.good
	_JSR	flash
	bra.s	.again3
.good:	_JSR	create_file
	tst.l	d0
	bmi	.pberr
	move.l	device_number(a6),-(sp)
	move.l	d0,device_number(a6)
.begin:	clr.l	pb_labels_number(a6)
	st	print_bloc_flag(a6)
	move.l	pb_buffer_address(a6),a5
	move.l	pb_beg_address(a6),a4
	cmp.l	pb_end_address(a6),a4
	bge	.end
	bsr	.chkbad
	bmi	.storerr
	move.l	pb_beg_address(a6),(a5)+
	addq.l	#1,pb_labels_number(a6)
	bsr	.update_buffer
.pass1:	cmp.l	pb_end_address(a6),a4
	bge.s	.pass2
	movem.l	d3-d7/a3-a4,-(sp)
	lea	tmp_buffer(a6),a0
	bsr	.disln
	tst.l	pb_buffer_address(a6)
	beq.s	.1
	cmp.w	#1,instruction_descriptor+_I_sourceformat(a6)
	bne.s	.1
	bsr	.chkbad
	bmi	.storerr
	move.l	instruction_descriptor+_I_sourceaddr(a6),(a5)+
	addq.l	#1,pb_labels_number(a6)
	bsr	.update_buffer
	cmp.w	#1,instruction_descriptor+_I_destformat(a6)
	bne.s	.1
	bsr	.chkbad
	bmi	.storerr
	move.l	instruction_descriptor+_I_destaddr(a6),(a5)+
	addq.l	#1,pb_labels_number(a6)
	bsr	.update_buffer
.1:
	movem.l	(sp)+,d3-d7/a3-a4
	add.w	instruction_size(a6),a4
	bra.s	.pass1
.pass2:	tst.l	pb_buffer_address(a6)
	beq.s	.before_pass3
	clr.l	(a5)
	move.l	pb_buffer_address(a6),a5
	move.l	pb_labels_number(a6),d0
	beq.s	.pass3
.4:	subq.l	#1,d0
	bmi.s	.pass3
	move.l	(a5),d1
	cmp.l	pb_beg_address(a6),d1
	blt	.putequ
	cmp.l	pb_end_address(a6),d1
	bgt	.putequ
	addq.w	#4,a5
	bra.s	.4
.before_pass3:
	sf	print_bloc_flag(a6)
.pass3:	lea	line_buffer(a6),a0
	move.b	#' ',(a0)+
	move.l	pb_beg_address(a6),a4
.6:	clr.b	(a0)
	bsr	.spc2tab
	_JSR	print_instruction
	lea	line_buffer(a6),a0
	cmp.l	pb_end_address(a6),a4
	bge.s	.end
	bsr	.see_if_label
	movem.l	d3-d7/a3-a4,-(sp)
	bsr	.disln
	movem.l	(sp)+,d3-d7/a3-a4
	add.w	instruction_size(a6),a4
	bra.s	.6
.end:	sf	print_bloc_flag(a6)
	move.l	device_number(a6),d0
	cmp.l	#5,d0
	blt.s	.noerr
	_JSR	close_file
.noerr:	move.l	(sp)+,device_number(a6)
	lea	prt_finished_text,a2
	_JMP	print_result
.prtnotready:
	move.l	(sp)+,device_number(a6)
	lea	prt_not_ready_text,a2
	_JMP	print_error

.chkbad:
	movem.l	d0/a0/a5,-(sp)
	move.l	a5,a0
	bsr	write_baderr
	tst.b	d0
	movem.l	(sp)+,d0/a0/a5
	rts

.update_buffer:
	movem.l	d0-d1/a5,-(sp)
	move.l	-4(a5),d1
	move.l	pb_buffer_address(a6),a5
	move.l	pb_labels_number(a6),d0
.8:	subq.l	#1,d0
	beq.s	.7
	cmp.l	(a5)+,d1
	bne.s	.8
	movem.l	(sp)+,d0-d1/a5
	clr.l	-(a5)
	subq.l	#1,pb_labels_number(a6)
	rts
.7:	movem.l	(sp)+,d0-d1/a5
.end2:	rts

.pberr:	sf	print_bloc_flag(a6)
	lea	print_bloc_text,a2
	_JMP	print_error

.storerr:
	movem.l	(sp)+,d3-d7/a3-a4
	move.l	device_number(a6),-(sp)
	move.l	4(sp),device_number(a6)
	lea	print_bloc_error_text,a2
	_JSR	print_error
	move.l	(sp),d0
	cmp.l	#5,d0
	blt.s	.wasprt
	move.l	d0,device_number(a6)
	_JSR	close_file
.wasprt:addq.w	#4,sp
	move.l	(sp)+,device_number(a6)
	rts

.disln:	st	optimise_address(a6)
	move.l	a4,test_instruction(a6)
	move.l	a4,d0
	bclr	#0,d0
	move.l	d0,a4
	move.b	#' ',(a0)+
	move.l	a4,a1
	st	dont_remove_break_flag(a6)
	_JSR	disassemble_line
;	sf	operande_flag(a6)			;display_break
	sf	dont_remove_break_flag(a6)		;display_break
	clr.b	(a0)
	rts

.putequ:	movem.l	d0-d1/a1-a5,-(sp)
	sf	print_bloc_flag(a6)
	lea	line_buffer(a6),a0
	lea	pb_label_buffer(a6),a1
	move.l	(a5),d0
	bsr	find_in_table2
	bne.s	.noequ
	move.l	VAR_NAME(a2),a2
.l1:	move.b	(a2)+,(a0)+
	bne.s	.l1
	subq.w	#1,a0
	bra.s	.5
.noequ:	move.b	#'L',(a0)+
	move.l	a5,a1
	bsr	dat_to_asc_l_3
.5:	move.b	#' ',(a0)+
	move.b	#'E',(a0)+
	move.b	#'Q',(a0)+
	move.b	#'U',(a0)+
	move.b	#' ',(a0)+
	move.b	#'$',(a0)+
	move.l	a5,a1
	bsr	dat_to_asc_l_3
	st	print_bloc_flag(a6)
	clr.b	(a0)
	bsr.s	.spc2tab
	_JSR	print_instruction
	movem.l	(sp)+,d0-d1/a1-a5
	addq.w	#4,a5
	bra	.4

.see_if_label:
	movem.l	d0-a5,-(sp)
	tst.l	pb_buffer_address(a6)
	beq.s	.3
	move.l	pb_buffer_address(a6),a5
	move.l	a4,d1
	move.l	pb_labels_number(a6),d0
.2:	subq.l	#1,d0
	bmi.s	.3
	cmp.l	(a5)+,d1
	bne.s	.2
	move.l	a5,a1
	subq.w	#4,a1
	move.l	d1,d0
	bsr	find_in_table2
	bne.s	.nolab2
	move.l	VAR_NAME(a2),a2
.l2:	move.b	(a2)+,(a0)+
	bne.s	.l2
	subq.w	#1,a0
	bra.s	.9
.nolab2:	move.b	#'L',(a0)+
	bsr	dat_to_asc_l_3
.9:	move.b	#':',(a0)+
	clr.b	(a0)
	_JSR	print_instruction
.3:	movem.l	(sp)+,d0-a5
	rts

.spc2tab:	movem.l	d0-d1/a0-a1,-(sp)
	lea	line_buffer(a6),a0
	cmp.l	#PRINTER_OUTPUT,device_number(a6)
	beq.s	.prt2tab
.disk_change_space:
	move.b	(a0)+,d0
	beq.s	.end_change
	cmp.b	#' ',d0
	bne.s	.disk_change_space
	move.b	#9,-1(a0)
	bra.s	.disk_change_space
.end_change:
	movem.l	(sp)+,d0-d1/a0-a1
	rts

.prt2tab:
	move.l	tab_value(a6),d1
	beq.s	.end_change
	subq.l	#1,d1
.continue_change:
	move.b	(a0)+,d0
	beq.s	.end_change
	cmp.b	#' ',d0
	bne.s	.continue_change
	bsr	strlen
	lea	1(a0,d0.w),a1
.shift_line:
	move.b	-(a1),0(a1,d1.l)
	dbf	d0,.shift_line
	lea	-1(a0),a1
.put_space:
	move.b	#' ',(a1)+
	dbf	d1,.put_space
	move.l	a1,a0
	bra.s	.prt2tab


;  #] Print bloc:
;  #[ New variable:[Alt_V]
; separer le nom de la variable pour l'utiliser dans:
;le verify d'existence
;l'affichage de l'existence
;l'affichage du set

;--- IN ---
;a3=line_buffer (pour sprintf)
;a4=buffer de traitement
;a5=ptr sur le nom termine par un 0 (var line)
new_variable:
	suba.l	a4,a4
.again:
	st	no_eval_flag(a6)
	lea	new_variable_text,a2
	move.l	a4,a0
	_JSR	get_expression
	bmi	.end
	bgt.s	.flash
	move.l	a0,a4

	lea	var_line(a6),a5
	lea	line_buffer(a6),a3
	move.l	a5,a1
.l1:
	move.b	(a0)+,d0
	beq.s	.check_destroy
	cmp.b	#',',d0
	beq.s	.done
	move.b	d0,(a1)+
	bra.s	.l1
.flash:
	_JSR	flash
	bra.s	.again
.check_destroy:
	cmp.b	#$bb,(a5)
	bne.s	.flash
	tst.b	(a5)+
	move.l	a5,a0
	bsr	rm_in_table
	bmi.s	.flash
	move.l	a5,-(sp)
	pea	rm_var_text
	move.l	a3,a0
	bsr	sprintf
	addq.w	#8,sp
	move.l	a3,a2
	_JSR	print_result
	bra.s	.end
.done:
	clr.b	(a1)
	move.l	a5,a2
	moveq	#-1,d0
	moveq	#0,d1
	moveq	#0,d2
	bsr	find_in_table
	bmi.s	.create
.yes_no:
	move.l	a5,-(sp)
	pea	new_var_reset_text
	move.l	a3,a0
	bsr	sprintf
	addq.w	#8,sp
	suba.l	a0,a0
	move.l	a3,a2
	_JSR	yesno
	beq.s	.end
	subq.w	#1,d0
	beq.s	.create
	move.l	a4,a0
	subq.w	#1,d0
	beq.s	.flash
	_JSR	flash
	bra.s	.yes_no
.create:
	move.l	a4,a0
	bsr	create_one_var
	bmi.s	.flash
	move.l	a5,-(sp)
	pea	new_var_set_text
	move.l	a3,a0
	bsr	sprintf
	addq.w	#8,sp
	move.l	a3,a2
	_JSR	print_result
	bsr	create_var_tree
.end:
	bra	redraw_all_windows
;  #] New variable:
;  #[ Load_play_mac:[Ctl_`]
load_play_mac:
	bsr	clear_mac
	_JSR	load_mac
	bmi.s	.end
	_JMP	play_mac
.end:
	rts
;  #] Load_play_mac:
	ENDC	;de bridos
;  #[ Ask preferences:[Ctl_P]
;--- INPUT ---
;rien

;--- IN ---
;a5=ptr sur les textes
;a4=ptr sur les buffers
;a3=ptr sur buffer de ligne
ask_preferences:
	lea	pref_yesno_buf(a6),a4
	lea	ask_yesno_table,a5
	move.l	a5,page_values_addr(a6)
	move.l	a4,page_values2_addr(a6)
.beginning:
.more_flag:
	move.l	(a5),d0
	beq.s	.ask_values
	move.l	d0,a2
	move.l	a4,a0
	_JSR	yesno
	beq	.end
	subq.w	#1,d0
	beq.s	.true
	subq.w	#1,d0
	beq.s	.false
	subq.w	#1,d0
	beq.s	.fleche_haut2
	subq.w	#1,d0
	beq.s	.fleche_bas2
.flash_flag:
	_JSR	flash
	bra.s	.more_flag
.fleche_haut2:
	tst.l	-4(a5)
	bmi.s	.flash_flag
	tst.l	-(a5)
	tst.b	-(a4)
	bra.s	.more_flag
.true:
	st	(a4)
	bra.s	.remore_flag
.false:
	sf	(a4)
.fleche_bas2:
.remore_flag:
	tst.l	4(a5)
	beq.s	.ask_values
	addq.w	#1,a4
	tst.l	(a5)+
	bra.s	.more_flag

.ask_values:
	move.l	a5,page_values_addr(a6)
	move.l	a4,page_values2_addr(a6)
	lea	pref_value_buf(a6),a4
	lea	ask_value_table,a5
	st	c_line(a6)
	lea	my_line(a6),a3
.more_value:
	move.l	(a5),d7
	lea	x_pos(a6),a0
	clr.w	(a0)+
	move.w	column_len(a6),y_pos(a6)
	move.l	d7,a2
	lea	get_expression_format_text,a0
	_JSR	print_question
	move.l	a0,d7

	lea	higher_level_buffer(a6),a0
	move.w	4(a5),d0
	move.w	d0,-(sp)
	moveq	#'\',d1
	cmp.b	#'d',d0
	beq.s	.put_base
	moveq	#'$',d1
	cmp.b	#'x',d0
	beq.s	.put_base
	moveq	#'%',d1
.put_base:
	move.w	d1,-(sp)
	pea	ask_values_format
	bsr	sprintf
	addq.w	#8,sp

	move.l	(a4),-(sp)
	pea	higher_level_buffer(a6)
	movea.l	a3,a0
	bsr	sprintf
	addq.w	#8,sp
.reask_value:
	move.l	a3,a0
	bsr	strlen
	move.w	d0,d1

	move.l	d7,a0
	bsr	strlen

	add.w	d0,x_pos(a6)

	movea.l	a3,a0
	move.l	a0,a1
	add.w	d1,a0
	move.l	d7,a2
	move.w	line_len(a6),d1
	subq.w	#1,d1
	_JSR	edit_ascii_line
	move.l	a1,a0
	bmi.s	.abort
	beq.s	.cr
	subq.w	#1,d0
	beq.s	.enter
	subq.w	#1,d0
	beq.s	.fleche_haut
	subq.w	#1,d0
	bne.s	.flash_value
.fleche_bas:
;	tst.l	4(a5)
	tst.l	6(a5)
	beq.s	.flash_value
.coup_bas:
	tst.l	(a4)+
.remore_value:
	addq.w	#6,a5
;	tst.l	(a5)+
	bra	.more_value
.cr:
.enter:
	bsr	evaluate
	tst.w	d1
	bmi.s	.flash_value
	move.l	d0,(a4)
	tst.l	6(a5)
;	tst.l	4(a5)
	bne.s	.coup_bas
	bra	.more_value
.fleche_haut:
	tst.l	-6(a5)
	bpl.s	.ok
	move.l	page_values_addr(a6),a5
	move.l	page_values2_addr(a6),a4
	bra	.beginning
.ok:
;	tst.l	-(a5)
	subq.w	#6,a5
	tst.l	-(a4)
	bra	.more_value
.flash_value:
	_JSR	flash
	bra.s	.reask_value
.abort:
	clr.w	x_pos(a6)
	bsr	clr_c_line
.end:
	sf	c_line(a6)
	IFEQ	bridos
	suba.l	a0,a0
	lea	ask_savep_text,a2
	_JSR	yesno
	beq.s	.return
	subq.w	#1,d0
	bne.s	.return
	bsr	save_preferences
.return:
	IFNE	AMIGA
	jsr	update_for_prefs
	ENDC	;AMIGA
	ENDC
	bra	redraw_all_windows
;  #] Ask preferences:
;  #[ Ask catch exceptions:[Ctl_E]
ask_catch_exceptions:
.again:
	suba.l	a0,a0
	lea	catch_exceptions_text,a2
	_JSR	yesno
	beq.s	.end
	subq.w	#1,d0
	beq.s	.all
	subq.w	#1,d0
	beq.s	.ask_one_by_one
	_JSR	flash
	bra.s	.again
.all:
	;toutes les reinstaller
	bsr	put_exceptions
	lea	exceptions_catched_text,a2
	_JSR	print_result
	bra.s	.end
.ask_one_by_one:
	suba.l	a0,a0
	lea	ask_catch_exceptions2_text,a2
	_JSR	get_expression
	bmi.s	.end
	beq.s	.good
	_JSR	flash
	bra.s	.ask_one_by_one
.good:
	IFNE	A3000
	move.l	d0,d1
	jsr	super_on
	move.l	d0,-(sp)
	move.l	d1,d0
	ENDC
	bsr	put_exception
	IFNE	A3000
	move.l	(sp)+,d0
	beq.s	.super
	move.l	d0,a0
	jsr	super_off
.super:
	ENDC
	bra.s	.ask_one_by_one
.end:
	rts
;  #] Ask catch exceptions:
;  #[ Ask expression:[E]
ask_expression:
	bsr.s	_ask_expression
	bra	redraw_all_windows
_ask_expression:
	movem.l	a0-a3/d0-d3,-(sp)
.again:
	suba.l	a0,a0
	lea	ask_expression_text,a2
	_JSR	get_expression
	bmi	.abort
	beq.s	.good
	_JSR	flash
	bra.s	.again
.good:
	lea	no_print_ro_eval_flag(a6),a0
	tst.b	(a0)
	beq.s	.nothing
	sf	(a0)
	bra	.abort
.nothing:
	move.l	d0,d3
	IFNE	sourcedebug
	tst.w	source_type(a6)
	beq.s	.no_source
	bsr	get_curwind_type
	beq.s	.no_source
	lea	line_buffer(a6),a0
	move.l	d3,d0
	_JSR	sprint_var_name_info
	bmi.s	.no_source
	bra.s	.print
.no_source:
	ENDC	;de sourcedebug
	lea	line_buffer(a6),a2
	move.l	a2,a0
	move.l	d3,-(sp)
	move.l	d3,-(sp)
	tst.b	low_rez(a6)
	beq.s	.not_low_res
	;en charactere
	move.l	d3,-(sp)
	pea	expression_low_format_text
	bsr	sprintf
	lea	16(sp),sp
	bra.s	.print
.not_low_res:
	;en binaire
	move.l	d3,-(sp)
	;en charactere
	move.l	d3,-(sp)
	pea	expression_format_text
	bsr	sprintf
	lea	20(sp),sp
.print:
	lea	line_buffer(a6),a2
	_JSR	print_result
.abort:
	movem.l	(sp)+,a0-a3/d0-d3
	rts
;  #] Ask expression:
;  #[ Ask timers:
;a5=@ du descripteur de timer
;a4=@ de la chaine
;ask_timers:
;.flash
;	lea	menu_timer_text(pc),a2
;	bsr	ask_menu
;	bmi	.abort
	;(M)ode:C. (I)cr: YYYY. (T)cr: $00|$00->$0000 Hz. (S)et (C)alc frequency.
;	lea	timers_buf(a6),a0
;	lea	(a0,d0.w),a5
;	lea	menu_frequency_text(pc),a4
;.flash2:
;	;enable
;	tst.b	(a5)
;	bne.s	.enable1
	;.disable
;	move.b	#'N',8(a4)
;	bra.s	.s1
;.enable1:
;	move.b	#'Y',8(a4)
;.s1:
	;mode
;	move.b	1(a5),d0
;	btst	#3,d0
;	bne.s	.not_delay
;	tst.b	d0
;	bne.s	.not_stop
;	move.b	#'S',15(a4)
;	bra.s	.s2
;.not_stop:
;	move.b	#'D',15(a4)
;	bra.s	.s2
;.not_delay:
;	andi.b	#%111,d0
;	tst.b	d0
;	bne.s	.not_event_count
;	move.b	#'E',15(a4)
;	bra.s	.s2
;.not_event_count:
;	move.b	#'P',15(a4)
;.s2:
;	move.l	a4,a2
;	bsr	ask_menu
;	bmi.s	.abort
;	subq.w	#1,d0
;	beq.s	.calc
;	subq.w	#1,d0
;	beq.s	.enable2
;	subq.w	#1,d0
;	beq.s	.get
;	subq.w	#1,d0
;	beq.s	.mode
;	subq.w	#1,d0
;	beq.s	.set
;	bra	.flash2
;.calc:
;.enable2:
;	not.b	(a5)
;	bra	.flash2
;.get:
;.mode:
;.set:
;.abort:
;	bsr	clr_c_line
;	rts
;  #] Ask timers:
;  #[ Show_story:[H]
show_story:
	bsr	home_story
	bmi.s	.end
	lea	story_form_table(pc),a0
	bra	form_do
.end:
	lea	no_story_error_text,a2
	_JMP	print_error

story_form_table:
	dc.l	draw_page_story-story_form_table
	dc.l	line_up_story-story_form_table
	dc.l	line_down_story-story_form_table
	dc.l	page_up_story-story_form_table
	dc.l	page_down_story-story_form_table
	dc.l	home_story-story_form_table
	dc.l	shift_home_story-story_form_table
	dc.l	init_show_story-story_form_table
	dc.l	story_title_text-story_form_table

init_show_story:
	addq.w	#1,y_pos(a6)
	lea	present_story_text,a2
	bra	print_m_line

draw_page_story:
	movem.l	d3-d7/a3-a5,-(sp)
	cmp.l	#PRINTER_OUTPUT,device_number(a6)
	blt.s	.dont_print
	move.w	big_window_coords+2(a6),y_pos(a6)
	IFNE	ATARIST
	addq.w	#1,y_pos(a6)
	ENDC
	lea	present_story_text,a2
	bsr	print_m_line
.dont_print:
	lea	line_buffer(a6),a3
	move.l	page_h_addr(a6),a5
	move.w	big_window_coords+2(a6),y_pos(a6)
	IFNE	ATARIST
	addq.w	#2,y_pos(a6)
	ENDC
	IFNE	AMIGA
	addq.w	#1,y_pos(a6)
	ENDC
	;nombre de lignes d'historique possibles
	move.w	column_len(a6),d7
	;pour le titre
	IFNE	ATARIST
	subq.w	#1,d7
	ENDC
	IFNE	AMIGA
	subq.w	#2,d7
	ENDC
	;4 lignes par champ
	lsr.w	#2,d7
	;-1 du dbf
	subq.w	#1,d7
;	moveq	#5-1,d7
.more_one:
	;fin physique atteinte ?
	cmp.l	end_story_addr(a6),a5
	bne.s	.not_end
	;oui alors remettre au debut physique
	move.l	story_addr(a6),a5
	moveq	#1,d0
	move.l	d0,draw_story_count(a6)
.not_end:
	;debut physique atteint ?
	cmp.l	story_addr(a6),a5
	bge.s	.not_beginning
	;oui alors remettre au debut physique
	move.l	story_addr(a6),a5
	moveq	#1,d0
	move.l	d0,draw_story_count(a6)
.not_beginning:
	bsr.s	draw_line_story
	addq.w	#1,y_pos(a6)
	addq.l	#1,draw_story_count(a6)
	dbf	d7,.more_one
	;fin logique en cas d'impression ?
	cmp.l	#PRINTER_OUTPUT,device_number(a6)
	blt.s	.ok
	cmp.l	end_story_addr(a6),a5
	beq.s	.abort
.ok:
	moveq	#0,d0
	bra.s	.end
.abort:
	moveq	#-1,d0
.end:
	movem.l	(sp)+,d3-d7/a3-a5
	rts

draw_line_story:
	move.w	x_pos(a6),-(sp)
	;ecrire le # du story
	move.w	#37,x_pos(a6)

	move.l	STO_REC_SIZE-4(a5),d0
	move.l	story_max(a6),d1
	;faire une modif suivant le numero courant
	add.l	d1,d0
	sub.l	cur_sto_nb(a6),d0
	cmp.l	d1,d0
	ble.s	.ok
	sub.l	story_max(a6),d0
.ok:
	move.l	d0,-(sp)
	pea	story_number_format
	move.l	a3,a0
	bsr	sprintf
	addq.w	#8,sp
	_JSR	print_instruction
	moveq	#1,d3
	move.w	d3,x_pos(a6)
.l1:
	addq.w	#1,y_pos(a6)

;	move.l	28(a5),-(sp)
;	move.l	24(a5),-(sp)
;	move.l	20(a5),-(sp)
;	move.l	16(a5),-(sp)
;	move.l	12(a5),-(sp)
;	move.l	8(a5),-(sp)
;	move.l	4(a5),-(sp)
;	move.l	(a5),-(sp)

	move.l	a5,-(sp)

	moveq	#'A',d0
	btst	#0,d3
	beq.s	.areg
	moveq	#'D',d0
.areg:
	move.w	d0,-(sp)
	pea	story_format_reg_text
	move.l	a3,a0
	bsr	sprintf
;	lea	9*4+2(sp),sp
	lea	10(sp),sp
	_JSR	print_instruction
	;plus 8 registres
	lea	8*4(a5),a5
	dbf	d3,.l1

	addq.w	#1,y_pos(a6)
	;ligne sr-ssp-pc
	st	optimise_address(a6)
	movem.l	d0-d7/a0-a5,-(sp)
	move.l	6(a5),test_instruction(a6)
	lea	10(a5),a2
	lea	instruction_size(a6),a5
;	clr.w	(a5)
	lea	tmp_buffer(a6),a0
	move.l	a2,d0
	bclr	#0,d0
;	move.l	d0,a2
	move.l	d0,a1
;	move.l	a0,dc_w_line_buffer(a6)
;	lea	disassemble_datas(a6),a1
;	move.l	(a2),(a1)
;	move.l	4(a2),4(a1)
;	move.w	8(a2),8(a1)
	st	dont_remove_break_flag(a6)
	_JSR	disassemble_line
	_JSR	display_break
	clr.b	(a0)
	movem.l	(sp)+,d0-d7/a0-a5
	pea	tmp_buffer(a6)
	move.l	6(a5),-(sp)
	move.l	(a5),-(sp)
	move.w	4(a5),-(sp)
	pea	story_format_srssppc_text
	move.l	a3,a0
	bsr	sprintf
	lea	18(sp),sp
	_JSR	print_instruction
	;plus ssp pc sr
	lea	2*4+2(a5),a5
	;22 words sauves
	lea	22*2(a5),a5
	move.w	(sp)+,x_pos(a6)
	rts

page_up_story:
	moveq	#7-1,d2
.l1:
	bsr.s	line_up_story
	dbf	d2,.l1
	bra.s	redraw_story
page_down_story:
	moveq	#7-1,d2
.l1:
	bsr.s	line_down_story
	dbf	d2,.l1
	bra.s	redraw_story
line_up_story:
	move.l	page_h_addr(a6),a0
	cmp.l	story_addr(a6),a0
	bgt.s	.ok
	move.l	end_story_addr(a6),a0
;	bra.s	redraw_story
.ok:
	lea	-STO_REC_SIZE(a0),a0
	bra.s	redraw_story
line_down_story:
	move.l	page_h_addr(a6),a0
	cmp.l	end_story_addr(a6),a0
	blt.s	.ok
	move.l	story_addr(a6),a0
;	bra.s	redraw_story
.ok:
	lea	STO_REC_SIZE(a0),a0
	bra.s	redraw_story

home_story:
	move.l	story_addr(a6),a0
	;@ de debut d'affichage = derniere instruction tracee
	move.l	cur_sto_nb(a6),d0
	subq.l	#1,d0
	bmi.s	no_redraw_story
	and.l	#$ffff,d0
	mulu	#STO_REC_SIZE,d0
	lea	(a0,d0.l),a0
	move.l	#1,draw_story_count(a6)
	cmp.l	#PRINTER_OUTPUT,device_number(a6)
	blt.s	.ok
	move.l	story_addr(a6),a0
.ok:
	move.l	a0,cur_h_addr(a6)
;	bra.s	redraw_story
redraw_story:
	move.l	a0,page_h_addr(a6)
	moveq	#0,d0
	rts
no_redraw_story:
	moveq	#-1,d0
	rts
shift_home_story:
	;pour l'instant
	bra.s	no_redraw_story

;  #] Show_story:
;  #[ Fill memory:[F]

fill_memory:
 move.l 8.w,d6
.syntax_error:
 st no_eval_flag(a6)
 lea fill_memory_buffer(a6),a0
 lea ask_fill_memory_text,a2
 move.l a0,-(sp)
 _JSR get_expression
 move.l (sp)+,a1
 bmi .end
 beq.s .ok
 _JSR flash
 bra.s .syntax_error
.ok:
 move.l a0,-(sp)
.copying:
 move.b (a0)+,(a1)+
 bne.s .copying
 move.l (sp)+,a0
 moveq #1,d7
 bsr internal_copy_fill
 beq.s .syntax_error
 moveq #-1,d7
 move.b (a0),d0
 cmp.b #'"',d0
 beq.s .4
 moveq #3,d7
 bsr evaluate
 tst.w d1
 bmi.s .syntax_error
 move.b d0,3(a0)
 lsr.l #8,d0
 move.b d0,2(a0)
 lsr.l #8,d0
 move.b d0,1(a0)
 lsr.w #8,d0
 move.b d0,(a0)
 bra.s .5
.4:
 addq.w #1,a0
	bsr	strlen
 move.l d0,d7
 subq.l #2,d7
 cmp.b #'"',1(a0,d7.w)
 bne.s .syntax_error
.5:
 tst.l d7
 bmi.s .syntax_error
 lea .my_berror(pc),a2
 move.l a2,d0
 bsr set_berr
 move.l d0,d6
 moveq #0,d4
 move.l -(a5),d0
 move.l -(a5),a2
 subq.l #1,d0
 tst.l d0
 bmi .syntax_error
.8:
 move.l a0,a1
 move.l d7,d5
.7:
 move.b (a1)+,(a2)+
 subq.l #1,d0
 bmi.s .fill_done
 subq.l #1,d5
 bpl.s .7
 bra.s .8
.fill_done:
 move.l d6,d0
 bsr set_berr
 lea fill_done_2_text,a2
 tst.l d4
 bne.s .9
 lea fill_done_text,a2
.9:
 _JSR print_result
 bra redraw_all_windows
.end:
 rts
.my_berror:
 moveq #-1,d4
 addq.w #1,a2
 IFNE _68030
 tst.b	chip_type(a6)
 beq.s	.68000
 bclr #0,$a(sp)
 rte
.68000:
 ENDC
 addq.w #8,sp
 subq.l #2,2(sp)
 rte

internal_copy_fill:
 lea start_address(a6),a5
.0:
 move.l a0,a1
.1:
 move.b (a1)+,d0
 beq.s .syntax_error
 cmp.b #",",d0
 bne.s .1
 clr.b -1(a1)
 bsr evaluate
 tst.l d1
 bmi.s .syntax_error
 move.l a1,a0
 move.l d0,(a5)+
 dbf d7,.0
 rts
.syntax_error:
 moveq #0,d7
 tst.w d7
 rts

;  #] Fill memory:
;  #[ Copy memory:[C]

copy_memory:
.syntax_error:
 st no_eval_flag(a6)
 lea copy_memory_buffer(a6),a0
 lea ask_copy_memory_text,a2
 move.l a0,-(sp)
 _JSR get_expression
 move.l (sp)+,a1
 bmi .end
 beq.s .ok
 _JSR flash
 bra.s .syntax_error
.ok:
 move.l a0,-(sp)
.copying:
 move.b (a0)+,(a1)+
 bne.s .copying
 move.l (sp)+,a0
 moveq #2,d7
 lea copyfill_form,a1
	bsr	sscanf
 cmp.w #3,d0
 bne.s .syntax_error
 lea .my_berror(pc),a2
 move.l a2,d0
 bsr set_berr
 move.l d0,d6
 moveq #0,d4
 move.l $e(a0),d2
 move.l 8(a0),d1
 move.l 2(a0),d0
 subq.l #1,d1
 tst.l d1
 bmi.s .syntax_error
 moveq #1,d7
 move.l d1,d3
 move.l d0,a0
 move.l d2,a1
 cmp.l d2,d0
 bgt.s .beg_to_end
.end_to_beg:
 add.l d3,a1
 moveq #-1,d7
 add.l d3,a0
.beg_to_end:
 move.b (a0),(a1)
 add.w d7,a0
 add.w d7,a1
 subq.l #1,d3
 bpl.s .beg_to_end
 lea copy_done_2_text,a2
 tst.l d4
 bne.s .2
 lea copy_done_text,a2
.2:
 move.l d6,d0
 bsr set_berr
 _JSR print_result
 bra redraw_all_windows
.end:
 rts
.my_berror:
 moveq #-1,d4
 IFNE _68030
 tst.b chip_type(a6)
 beq.s .68000
 bclr #0,$a(sp)
 rte
.68000:
 ENDC
 btst #4,1(sp)
 bne.s .3
 subq.l #2,$a(sp)
.3:
 addq.w #8,sp
 rte

;  #] Copy memory:
;  #[ Search:[G] B)yte W)ord L)ong A)scii I)nstruction dis hex asc src

search:
 bsr get_curwind
 bmi .end
 cmp.w #SRCWIND_TYPE,d1
 IFNE sourcedebug
 beq.s .src
 ENDC
 bgt.s .end
 move.l a1,search_base(a6)
;B)yte W)ord L)ong A)scii I)nst
.again:
 lea menu_search_text,a2
	bsr	ask_menu
 bmi.s .end
 move.w d0,d3
 moveq #0,d7
 lea search_byte_buffer(a6),a0
 subq.w #1,d0
 beq.s .byte_word_long
 addq.w #1,d7
 lea search_word_buffer(a6),a0
 subq.w #1,d0
 beq.s .byte_word_long
 addq.w #2,d7
 lea search_long_buffer(a6),a0
 subq.w #1,d0
 beq.s .byte_word_long
 lea search_ascii_buffer(a6),a0
 subq.w #1,d0
 beq.s .ascii
 lea search_instruction_buffer(a6),a0
 subq.w #1,d0
 bne.s .flash
;.instr:
 st search_instruction_flag(a6)
 st no_eval_flag(a6)
 sf word_aligned_flag(a6)
 bra.s .ask_search_value
 IFNE sourcedebug
.src:
 lea src_wind_buf(a6),a0
 mulu.w #_SRCWIND_SIZEOF,d2
 add.w d2,a0
 tst.l (a0)
 beq.s .end
 move.l (a0),search_base(a6)
 lea search_ascii_buffer(a6),a0
 st search_source_flag(a6)
 ENDC ;de sourcedebug
.ascii:
 st search_string_flag(a6)
 st no_eval_flag(a6)
 sf word_aligned_flag(a6)
 bra.s .ask_search_value
.end:
 rts
.flash:
 _JSR flash
 bra.s .again
.byte_word_long:
 move.w d7,search_length(a6)
 sf search_string_flag(a6)
 sf search_instruction_flag(a6)
.ask_search_value:
 lea ask_search2_text,a2
 move.l a0,-(sp)
 _JSR get_expression
 move.l (sp)+,a1
 bmi.s .end
 beq.s .test_even_odd
 _JSR flash
 bra.s .ask_search_value
.test_even_odd:
 cmp.w #2,d3
 beq.s .even_odd
 cmp.w #3,d3
 bne.s .good
.even_odd:
 movem.l d0/a0-a1,-(sp)
 lea word_aligned_flag(a6),a0
 lea ask_even_aligned_search,a2
 _JSR yesno
 move.w d0,d1
 movem.l (sp)+,d0/a0-a1
 tst.w d1
 beq search				; ESC
 st word_aligned_flag(a6)
 subq.w #1,d1
 beq.s .good				; word aligned
 sf word_aligned_flag(a6)
 subq.w #1,d1
 beq.s .good				; not aligned
 _JSR flash
 bra.s .even_odd
.good:
 move.l d0,-(sp)
	bsr	strcpy
 move.l (sp)+,d0
 st search_set_flag(a6)
 lea search_buffer(a6),a1
 moveq #1,d3
 tst.b search_instruction_flag(a6)
 bne.s .ascii_2
 tst.b search_string_flag(a6)
 beq.s .bwl_2
.ascii_2:
	bsr	strlen
 subq.w #1,d0
 bmi .flash
 move.w d0,search_length(a6)
	bsr	strcpy
 bra.s internal_search
.bwl_2:
 clr.l (a1)					; *
 lsl.w #2,d7
 jmp .10(pc,d7.w)
.10:
 move.b d0,(a1)
 bra.s internal_search
 move.w d0,(a1)
 bra.s internal_search
 nop
 nop
 move.l d0,(a1)
; bra.s internal_search

internal_search:
 move.w #$ff,d2
 lea search_berror(pc),a1
 move.l a1,d0
 bsr set_berr
 move.l d0,d5
 lea search_text,a2
 _JSR print_result
 move.w search_length(a6),d6
 tst.b search_instruction_flag(a6)
 bne search_instruction
 lea search_buffer(a6),a4
.1:
 bsr search_inkey
 tst.w d0
 beq.s .3
 cmp.l #$0001001b,d0
 beq.s search_not_found
.3:
 move.l search_base(a6),a3
 add.l d3,a3
 IFNE sourcedebug
 tst.b search_source_flag(a6)
 beq.s .no_src
 move.l source_ptr(a6),a0
 cmp.l a0,a3
 ble search_not_found
 add.l source_len(a6),a0
 cmp.l a0,a3
 bge search_not_found
.no_src:
 ENDC ;de sourcedebug
 tst.b word_aligned_flag(a6)
 beq.s .search_all
 move.w a3,d0
 btst #0,d0
 beq.s .search_all
 move.l a4,a5
 move.w d6,d7
 addq.w #1,a3 
 addq.w #1,a5
 bra.s .not_this
.search_all:
 move.l a4,a5
 move.w d6,d7
.loop:
 IFNE	ATARIST
 move.b (a3)+,d0
 nop
 ENDC
 IFNE	AMIGA
 jsr	safe_getbyte_a3
 ENDC
 tst.b readable_buffer(a6)
 sf readable_buffer(a6)
 bne.s .not_this
 cmp.b (a5)+,d0
 bne.s .not_this
 dbf d7,.loop
.found:
 sub.w d6,a3
 subq.w #1,a3
 bra.s search_found
.not_this:
 add.l d3,search_base(a6)
 bra.s .1
search_found:
 lea search_found_text,a2
 _JSR print_result
 bra.s search_completed
search_not_found:
 lea search_not_found_text,a2
 _JSR print_result
 IFNE sourcedebug
 tst.b search_source_flag(a6)
 beq.s search_completed
 move.l d5,d0
 bsr set_berr
 bra redraw_curwind
 ENDC ;de sourcedebug
search_completed:
 IFNE sourcedebug
 tst.b search_source_flag(a6)
 beq.s .no_src
 move.l a3,a0
 bsr put_cursrcwind_addrnb
 bra.s .set_base
.no_src:
 ENDC ;de sourcedebug
 move.l a3,a0
 bsr put_curwind_addr
.set_base:
 move.l a3,search_base(a6)
.dont_set_base:
 move.l d5,d0
 bsr set_berr
 bra redraw_curwind

search_berror:
 st readable_buffer(a6)
 IFNE _68020|_68030
 tst.b chip_type(a6)
 beq.s .68000
 addq.l #2,2(sp)
 bclr #0,$a(sp)
 rte
.68000:
 ENDC
 addq.w #8,sp
 rte

search_inkey:
 dbf d2,.end
 move.w #$ff,d2
 _JMP inkey
.end:
 rts

search_instruction:
 move.l search_base(a6),a3
 add.l d3,d3
 add.l d3,a3
 move.l a3,d0
 bclr #0,d0
 move.l d0,a3
 move.l a3,test_instruction(a6)
.3:
 lea instruction_size(a6),a5
 clr.w (a5)
 lea line_buffer(a6),a0
 bsr init_buffer
 move.l a3,a1
 movem.l d0/d2-d3/a0-a5,-(sp)
 _JSR disassemble_line
 tst.w d0
 bne.s .5
; sf operande_flag(a6)
 movem.l (sp)+,d0/d2-d3/a0-a5
 lea search_buffer(a6),a1
 bsr.s cmp_instruc
 beq.s .1
.5:
 add.l d3,test_instruction(a6)
 add.l d3,a3
 bsr.s search_inkey
 tst.w d0
 beq.s .3
 cmp.l #$0001001b,d0
 bne.s .3
 move.l a3,d7
 bra search_not_found
.1:
 move.l a3,d7
 bra search_found

;a0=a tester
;a1=a comparer
cmp_instruc:
	move.l	a2,-(sp)
.0:
	move.l	a1,a2
.2:
	move.b (a2),d0
	beq.s .found
	cmp.b (a0)+,d0
	beq.s .4
	tst.b -1(a0)
	beq.s .not_found
	bra.s .0
.4:
	addq.w #1,a2
	bra.s .2
.found:
	moveq	#0,d0
	bra.s	.end
.not_found:
	moveq	#-1,d0
.end:
	move.l	(sp)+,a2
	rts

;  #] Search:
;  #[ Next Previous:[N][Alt_N] dis hex asc src

previous:
 moveq #-1,d3
 bra.s _next

next:
 moveq #1,d3
_next:
 tst.b search_set_flag(a6)
 beq.s .end
 bsr get_curwind
 bmi.s .no
 cmp.w #SRCWIND_TYPE,d1
 IFNE sourcedebug
 bne.s .not_src
 mulu #_SRCWIND_SIZEOF,d2
 lea src_wind_buf(a6),a0
 add.w d2,a0
 tst.l (a0)
 beq.s .no
 move.l (a0),a1
 move.l a1,search_base(a6)
 bra internal_search
.not_src:
 ENDC ;de sourcedebug
 bgt.s .no
 move.l a1,search_base(a6)
 bra internal_search
.no:
 rts
.end:
 lea no_next_text,a2
 _JMP print_error

;  #] Next Previous:(N/ALT-N)
;  #[ Set mark:[F1]
set_mark:
	bsr	get_curwind
	move.l	a1,first_mark(a6)
	lea	mark_set_text,a2
	_JMP	print_result
;  #] Set mark:
;  #[ Exchange cursor & mark:[F2]
exchange_mark:
	bsr	get_curwind
	move.l	first_mark(a6),a0
	move.l	a1,first_mark(a6)
	bsr	put_curwind_addr
	bsr	redraw_curwind
	lea	mark_exchanged_text,a2
	_JMP	print_result
;  #] Exchange cursor & mark:(F2)
;  #[ Jump to:[J]
jump_to:
	suba.l	a0,a0
	lea	jump_to_text,a2
	_JSR	get_expression
	bmi.s	.end
	beq.s	.good
	_JSR	flash
	bra.s	jump_to
.good:
	move.l	d0,pc_buf(a6)
	bsr	redraw_relock_all
.end:
	rts
;  #] Jump to:
;  #[ Jump to curwind:[Ctl_J] dis src
jump_to_curwind:
	bsr	get_curwind
	beq.s	.dis
	IFNE	sourcedebug
	cmp.w	#SRCWIND_TYPE,d1
	beq.s	.chk_dis
	ENDC
.end:
	_JSR	flash
	rts
.chk_dis:
	move.l	a1,d0
	beq.s	.end
.dis:
	move.l	a1,pc_buf(a6)
	bra	redraw_relock_all
;  #] Jump to curwind:
;  #[ Output_to:[O]
output_to:
.again:
	lea	menu_output_to_text,a2
	bsr	ask_menu
	bmi.s	.abort
	cmp.l	#2,d0
	ble.s	_output_to
	_JSR	flash
	bra.s	.again
.abort:
	rts

;d0=1 -> screen
;d0=2 -> rs232
_output_to:
	;si deja sur le bon device
	cmp.l	device_number(a6),d0
	beq.s	.good
	subq.l	#1,d0
	beq.s	.screen
	subq.l	#1,d0
	bne.s	.abort
.rs232:
	st	rs232_output_flag(a6)
	_JSR	terminal_init
	bra.s	.good
.screen:
	sf	rs232_output_flag(a6)
	move.l	#SCREEN_OUTPUT,device_number(a6)
	IFNE	AMIGA
	move.w	#31,column_len(a6)
	move.w	#32,big_window_coords+6(a6)
	jsr	wind_term_to_screen
	ENDC
	_JSR	sbase1_sbase0
	lea	output_to_screen_text,a2
	_JSR	print_result
	bsr	windows_init
	jsr	draw_all_windows
.good:
	moveq	#0,d0
	bra.s	.end
.abort:
	moveq	#-1,d0
.end:
	rts
;  #] Output_to:
;  #[ Run until:[U]
run_until:
.again:
	suba.l	a0,a0
	lea	run_until_text,a2
	_JSR	get_expression
	bmi.s	.end
	beq.s	.good
	_JSR	flash
	bra.s	.again
.good:
	move.l	d0,a0
	st	runandbreak_flag(a6)
	bsr.s	__ctrl_a
	beq	p0p1
.end:
	rts
;  #] Run until:
;  #[ Run until curwind:[Ctl_U] dis src
run_until_curwind:
	bsr	get_curwind
	beq.s	.dis
	IFNE	sourcedebug
	cmp.w	#SRCWIND_TYPE,d1
	beq.s	.dis
	ENDC	;de sourcedebug
.end:
	rts
.dis:
	move.l	a1,a0
	st	runandbreak_flag(a6)
	bsr.s	__ctrl_a
	beq	p0p1
	bra.s	.end
;  #] Run until curwind:
;  #[ Ctrl A:[Ctl_A] dis src
ctrl_a:
	IFNE	sourcedebug
	tst.w	source_type(a6)
	beq.s	.normal
	_JSR	get_curwind_type
	beq.s	.normal
	st	step_over_flag(a6)
	_JSR	set_trace_source
	bra	p0p1
.normal:
	ENDC	;de sourcedebug
;break a l'instruction suivante
	st	nowatch_flag(a6)
	bsr.s	_ctrl_a
	beq	p0p1
.end:
	sf	nowatch_flag(a6)
	rts
_ctrl_a:
	st	runandbreak_flag(a6)
	move.l	pc_buf(a6),a0
	bsr	get_next_instruction
	bmi.s	__ctrla_error
	;bra	__ctrl_a
__ctrl_a:
	;ds a0 l'@ du break
	move.l	a0,d0
	IFNE	_68030
	tst.b	chip_type(a6)
	bne.s	.no_and
	ENDC
	andi.l	#$ffffff,d0
.no_and:
	move.l	d0,a0
	moveq	#0,d0
	move.l	def_break_vec(a6),d1
	move.l	def_break_eval_addr(a6),a1
	bsr	set_break
	bmi.s	__ctrla_error
	moveq	#0,d0
	rts
__ctrla_error:
	sf	runandbreak_flag(a6)
	bsr	_print_break_error
	moveq	#-1,d0
	rts
;  #] Ctrl A:
;  #[ Ctrl R:[Ctl_R]
ctrl_r:
	st	run_flag(a6)
	st	nowatch_flag(a6)
	lea	ctrl_r_text,a2
	_JSR	print_result
	bra	p0p1
;  #] Ctrl R:
;  #[ Ctrl Z:[Ctl_Z] dis src
ctrl_z:
	IFNE	sourcedebug
	tst.w	source_type(a6)
	beq.s	.normal
	_JSR	get_curwind_type
	beq.s	.normal
	_JSR	set_trace_source
	bra	p0p1
.normal:
	ENDC	;de sourcedebug
	st	trace_flag(a6)
;	st	nowatch_flag(a6)
	st	ctlz_flag(a6)
	bra	p0p1
;  #] Ctrl Z:
;  #[ Trace_t1: [Ctl_Alt_Z]
trace_t1:
	st	trace_t1_flag(a6)
	st	nowatch_flag(a6)
	st	trace_flag(a6)
	st	nostop_flag(a6)
	st	permanent_trace_flag(a6)
	bra	p0p1
;  #] Trace_t1:
;  #[ Fly_on:[Ctl_T] dis src
fly_on:
	IFNE	sourcedebug
	bsr	get_curwind_type
	bne	ctrl_a
	ENDC	;de sourcedebug
	move.l	pc_buf(a6),a0
	bsr	get_instr_type
	;normal=nofly
	beq.s	.no_break
	;trap lineaf bsr jsr = fly
	subq.w	#6,d0
	bmi.s	.break
	;bcc dbcc jmp = nofly
	subq.w	#3,d0
	bmi.s	.no_break
	;trapv chk = fly
	;rts rte rtr = nofly
	subq.w	#2,d0
	bge.s	.no_break
.break:
	bra	ctrl_a
.no_break:
	bra	ctrl_z
;  #] Fly_on:
;  #[ Copyright:[Alt_@]
copyright:
	lea	editeur_text,a0
	lea	line_buffer(a6),a2
	move.l	a2,a1
	bsr	build_present_string
	_JMP	print_result
;  #] Copyright:
;  #[ Force_branch:[Ctl_F]
force_branch:
	bsr	get_curwind_type
	bne.s	.end
	move.l	pc_buf(a6),a0
	_JSR	get_instr_type
;	beq.s	.end
	;bsr,jsr,bcc,dbcc,jmp
	subq.w	#4,d0
	bmi.s	.end
	subq.w	#5,d0
	bgt.s	.end
	move.l	a0,pc_buf(a6)
	bsr	redraw_relock_all
.end:
	rts
;  #] Force_branch:
;  #[ Break_end:[Ctl_X]
break_end:
	move.l	def_break_perm(a6),d0
	move.l	def_break_vec(a6),d1
	move.l	old_watch_pc_value(a6),a0
	move.l	def_break_eval_addr(a6),a1
	bsr	toggle_break
	bra	redraw_all_windows
;  #] Break_end:
;  #[ Return_fast:[Alt_X]
return_fast:
	move.l	old_watch_pc_value(a6),pc_buf(a6)
	move.l	old_watch_a7_value(a6),a7_buf(a6)
	move.l	old_watch_ssp_value(a6),ssp_buf(a6)
	move.w	old_watch_sr_value(a6),sr_buf(a6)
	bra	redraw_relock_all
;  #] Return_fast:
;  #[ Call_subroutine:[Ctl_Alt_J],[Sft_Clt_Alt_J]
call_user_subroutine:
	st	ro_child_struct+17(a6)
	bra.s	_call_subroutine
call_super_subroutine:
	sf	ro_child_struct+17(a6)
_call_subroutine:
	suba.l	a0,a0
	lea	call_subroutine_text,a2
	_JSR	get_expression
	bne.s	.end
	lea	ro_child_struct(a6),a0
	move.l	a0,a1
	move.l	d0,(a1)+
	move.l	a0_buf(a6),(a1)+
	move.l	a1_buf(a6),(a1)+
	move.l	d0_buf(a6),(a1)+
	st	(a1)
	bsr	call_child
.end:
	rts
;  #] Call_subroutine:
;  #[ Manual_prinfo:[Ctl_Alt_P]
manual_prinfo:
.again:
	lea	menu_manual_prinfo_text,a2
	bsr	ask_menu
	bmi.s	.abort
	subq.l	#1,d0
	beq.s	.load
	subq.l	#1,d0
	beq.s	.save
	_JSR	flash
	bra.s	.again
.load:
	_JSR	load_prinfo
	;redessiner
	st	relock_pc_flag(a6)
	moveq	#-1,d0
	lea	windows_to_redraw(a6),a0
	move.l	d0,(a0)+
	move.w	d0,(a0)
	_JSR	windows_init
	sf	relock_pc_flag(a6)
	bra.s	.end
.save:
	_JSR	save_prinfo
;	bra.s	.end
.abort:
.end:
	rts	
;  #] Manual_prinfo:
;  #[ Reserve from:[Ctl_Alt_R]
reserve_from:
	;tester si un prg charge
	tst.l	p1_basepage_addr(a6)
	bne.s	.end
.again:
	suba.l	a0,a0
	lea	reserve_from_text,a2
	_JSR	get_expression
	bmi.s	.end
	beq.s	.ok
	_JSR	flash
	bra.s	.again
.ok:
	move.l	d0,reserve_from_addr(a6)
	bra	ctrl_c
.end:
	rts
;  #] Reserve from:
;  #[ Load_all_vars:[Ctl_V]
load_all_vars:
	tst.l	table_var_addr(a6)
	beq.s	.end
	tst.l	table_la_size(a6)
	beq.s	.end
	tst.l	current_var_nb(a6)
	beq.s	.no_kill
.l1:  	suba.l	a0,a0
	lea	kill_all_var_text,a2
	_JSR	yesno
	beq.s	.end
	subq.w	#1,d0
	beq.s	.kill
	subq.w	#1,d0
	beq.s	.no_kill
	_JSR	flash
	bra.s	.l1
.kill:	move.l	table_var_addr(a6),a0
	bsr	clr_table_end
	move.l	table_var_addr(a6),before_ctrll_addr(a6)
	move.l	table_la_addr(a6),d0
	move.l	d0,current_la_addr(a6)
	move.l	d0,before_ctrll_la_addr(a6)
	bsr	create_var_tree
	bsr	redraw_all_windows
.no_kill:	st	no_eval_flag(a6)
	suba.l	a0,a0
	lea	ask_var_file_text,a2
	_JSR	get_expression
	bmi.s	.end
	bsr	load_variables
.end:	rts
;  #] Load_all_vars:
;  #[ Load_prg_vars:[Ctl_Alt_V]
load_prg_vars:
	IFNE	AMIGA
	jmp	_load_prg_vars
	ENDC
	IFNE	ATARIST
.again:	suba.l	a0,a0
	lea	load_prg_vars_text,a2
	st	no_eval_flag(a6)
	_JSR	get_expression
	bmi.s	.end
	beq.s	.good
.flash:	_JSR	flash
	bra.s	.again
.good:	lea	load_prg_vars_sscanform,a1
	bsr	sscanf
	bmi.s	.flash
	beq.s	.flash
	tst.w	(a0)+
	bmi.s	.flash

	;recopier le nom de fichier dans exec_name_buf
	lea	exec_name_buf(a6),a1
	bsr	strcpy
	lea	(a0,d0.w),a0
	btst	#0,d0
	beq.s	.no_add
	tst.b	(a0)+
.no_add:	tst.w	(a0)+
	bmi.s	.flash
	move.l	(a0)+,a0
	_JSR	_load_prg_vars
.end:	rts
	ENDC	;d'ATARIST
;  #] Load_prg_vars:
	IFNE	debug
;  #[ Monkey_test:[Ins]
monkey_test:
	lea	line_buffer_size(a6),a0
	move.w	(a0),-(sp)
	move.w	#20,(a0)
.l1:
	suba.l	a0,a0
	lea	monkeytest_text,a2
	_JSR	get_expression
;	bge.s	.l1
	move.w	(sp)+,line_buffer_size(a6)
	rts
;  #] Monkey_test:
	ENDC	;de debug
	IFNE	sourcedebug
;  #[ Begin_of_source:[Ctl_Home]
begin_of_source:
	tst.w	source_type(a6)
	beq.s	.end
	bsr	get_noaddr_curwind
;	add.w	d0,a0
	cmp.w	#SRCWIND_TYPE,d1
	beq.s	.src
	cmp.w	#VARWIND_TYPE,d1
	beq.s	.var
	cmp.w	#INSWIND_TYPE,d1
	beq.s	.ins
.end:
	rts
.src:
	lea	src_wind_buf(a6),a0
	mulu	#_SRCWIND_SIZEOF,d2
	add.w	d2,a0
	move.l	source_ptr(a6),a2
	cmp.l	(a0),a2
	beq.s	.end
	move.l	a2,(a0)
	clr.l	_SRCWIND_LINENB(a0)
	clr.w	_SRCWIND_OFF(a0)
	bra	redraw_curwind
.var:
	mulu	#_VARWIND_SIZEOF,d2
	lea	var_wind_buf(a6),a0
	add.w	d2,a0
	tst.l	_VARWIND_NB(a0)
	beq.s	.end
	move.l	_VARWIND_STARTPTR(a0),(a0)
	clr.l	_VARWIND_NB(a0)
	clr.w	_VARWIND_OFF(a0)
	bra	redraw_curwind
.ins:
	mulu	#_INSWIND_SIZEOF,d2
	lea	ins_wind_buf(a6),a0
	add.w	d2,a0
	tst.l	_INSWIND_ELNB(a0)
	beq.s	.end
	clr.l	_INSWIND_ELNB(a0)
	clr.w	_INSWIND_OFF(a0)
	bra	redraw_curwind
;  #] Begin_of_source:
;  #[ End_of_source:[Sft_Ctl_Home]
end_of_source:
	tst.w	source_type(a6)
	beq.s	.end
	bsr	get_noaddr_curwind
	add.w	d0,a0
	cmp.w	#SRCWIND_TYPE,d1
	beq.s	.src
	cmp.w	#VARWIND_TYPE,d1
	beq.s	.var
	cmp.w	#INSWIND_TYPE,d1
	beq.s	.ins
.end:
	rts
.src:
	move.w	6(a0),d0
	subq.w	#2,d0

	lea	src_wind_buf(a6),a2
	mulu	#_SRCWIND_SIZEOF,d2
	add.w	d2,a2
	move.l	source_lines_nb(a6),_SRCWIND_LINENB(a2)
	move.l	source_ptr(a6),a0
	move.l	a0,a1
	add.l	source_len(a6),a0
	subq.w	#1,a0
.l1:
	move.w	d0,-(sp)
	bsr	up_line_source
	sub.l	d1,_SRCWIND_LINENB(a2)
	move.w	(sp)+,d0
	dbf	d0,.l1
	move.l	a0,(a2)
	clr.w	_SRCWIND_OFF(a2)
	bra	redraw_curwind
.var:
	mulu	#_VARWIND_SIZEOF,d2
	lea	var_wind_buf(a6),a2
	add.w	d2,a2
	move.l	_VARWIND_NBMAX(a2),d0
	moveq	#0,d1
	move.w	_GENWIND_H(a0),d1
	subq.l	#1,d1
	sub.l	d1,d0
	bmi.s	.end
	move.l	d0,_VARWIND_NB(a2)
	move.l	_VARWIND_STARTPTR(a2),a0
	mulu	#TCVARS_SIZEOF,d0
	add.l	d0,a0
	move.l	a0,(a2)
	clr.w	_VARWIND_OFF(a2)
	bra	redraw_curwind
.ins:
	mulu	#_INSWIND_SIZEOF,d2
	lea	ins_wind_buf(a6),a2
	add.w	d2,a2
	clr.w	_INSWIND_OFF(a2)
	move.l	_INSWIND_ELMAX(a2),d0
	subq.l	#1,d0
	move.l	d0,_INSWIND_ELNB(a2)
	bra	redraw_curwind
;  #] End_of_source:
;  #[ Ask source line nb:[#]
ask_source_line_nb:
	move.l	a4,-(sp)
	tst.w	source_type(a6)
	beq.s	.end
	tst.l	source_ptr(a6)
	beq.s	.end
	suba.l	a4,a4
.again:
	move.l	a4,a0
	lea	ask_source_line_nb_text,a2
	st	evaluate_decimal_flag(a6)
	_JSR	get_expression
	move.l	a0,a4
	bmi.s	.end
	beq.s	.good
.flash:
	_JSR	flash
	bra.s	.again
.good:
	subq.l	#1,d0
	move.l	source_ptr(a6),a0
	move.l	source_len(a6),d1
	_JSR	get_source_line
	beq	.flash
	move.l	d0,a0
	bsr	put_cursrcwind_addrnb
	bsr	redraw_curwind
.end:
	sf	evaluate_decimal_flag(a6)
	move.l	(sp)+,a4
	rts
;  #] Ask source line nb:
;  #[ Show_stack:[Sft_Alt_S]
show_stack:
	tst.w	source_type(a6)
	beq.s	.end
	lea	stack_form_table(pc),a0
	bra	form_do
.end:	rts

stack_form_table:
	dc.l	draw_page_stack-stack_form_table
	dc.l	line_up_stack-stack_form_table
	dc.l	line_down_stack-stack_form_table
	dc.l	page_up_stack-stack_form_table
	dc.l	page_down_stack-stack_form_table
	dc.l	home_stack-stack_form_table
	dc.l	shift_home_stack-stack_form_table
	dc.l	init_stack-stack_form_table
	dc.l	stack_title_text-stack_form_table

draw_page_stack:
	movem.l	d5-d7,-(sp)
	move.w	big_window_coords+2(a6),y_pos(a6)
	move.w	column_len(a6),d7

.l1:	cmp.l	a5,a4
	bge.s	.end_of_stack
	move.l	(a4),d6
	addq.w	#2,a4
	btst	#0,d6
	bne.s	.l1
	sub.l	text_buf(a6),d6
	bmi.s	.l1
	cmp.l	text_size(a6),d6
	bhi.s	.l1

	move.l	d6,d0
	move.l	a3,a0
	_JSR	sprint_stack
	bmi.s	.end_of_stack
	move.l	a3,a2
	_JSR	print_instruction
	addq.w	#2,a4
	addq.w	#1,y_pos(a6)
	dbf	d7,.l1
	bra.s	.end
.end_of_stack:
	clr.b	(a3)
.clr:	_JSR	print_instruction
	dbf	d7,.clr
.end:	movem.l	(sp)+,d5-d7
	rts

line_up_stack:
line_down_stack:
page_up_stack:
page_down_stack:
home_stack:
shift_home_stack:
	moveq	#-1,d0
	rts

init_stack:
	lea	line_buffer(a6),a3
	move.w	sr_buf(a6),d0
	move.l	start_debug_usp(a6),a5
	move.l	a7_buf(a6),a4
	btst	#13,d0
	beq.s	.ok
	move.l	start_debug_ssp(a6),a5
	move.l	ssp_buf(a6),a4
.ok:	move.l	big_window_coords(a6),x_pos(a6)
	rts
;  #] Show_stack:
;  #[ Set_inspect:[Ctl_I]
set_inspect:
	movem.l	a2-a3,-(sp)
	bsr	get_curwind_type
	cmp.w	#INSWIND_TYPE,d1
	bne.s	.end
	suba.l	a3,a3
.again:
	lea	ask_inspect_text,a2
	move.l	a3,a0
	_JSR	get_expression
	move.l	a0,a3
	bmi.s	.end
	beq.s	.ok
	_JSR	flash
	bra.s	.again
.ok:
	move.l	d0,a0
	bsr	put_curinswind_addr
	bsr	redraw_curwind
.end:
	movem.l	(sp)+,a2-a3
	rts
;  #] Set_inspect:
	ENDC	;de sourcedebug
;  #[ Reset Profiler:
reset_profiler:
	movem.l	d2/a2,-(sp)
	move.l	var_tree_nb(a6),d0
	beq.s	.end
	move.l	var_tree_addr(a6),a0
	moveq	#0,d1
	moveq	#VAR_TREE_SIZE,d2
.l1:	move.l	d1,VAR_TREE_COUNT(a0)
	add.w	d2,a0
	subq.l	#1,d0
	bne.s	.l1
.end:	lea	profiler_reset_text,a2
	_JSR	print_result
	movem.l	(sp)+,d2/a2
	rts
;  #] Reset Profiler:
	include	"adebug2.s"

