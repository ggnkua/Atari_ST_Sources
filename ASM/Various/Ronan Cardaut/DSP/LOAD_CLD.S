;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;chargement et extraction des infos d'un .CLD
; et chargement automatique au d‚marrage
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------


	output	d:\centinel\dsp\load_cld.o
	include	d:\centinel\both\define.s
	include	d:\Centinel\both\GEM.EQU

;------------------------------------------------------------------------------
;file header
;------------------------------------------------------------------------------
		rsreset
f_magic		rs.l	1	;=$2c5
f_nscns		rs.l	1	;nb sections
f_timdat	rs.l	1	;
f_symptr	rs.l	1	;ptr symbol header
f_nsyms		rs.l	1	;symbol header size
f_opthdr	rs.l	1	;optional header length
f_flags		rs.l	1
f_header_size	rs.l	1
;------------------------------------------------------------------------------
;optional RUN-TIME header
;------------------------------------------------------------------------------
		rsreset
magic		rs.l	1
vstamp		rs.l	1	;version
tsize		rs.l	1	;text size
dsize		rs.l	1	;data size
bsize		rs.l	1	;bss size
entry		rs.l	2	;program entry point
text_start	rs.l	2
data_start	rs.l	2
text_end	rs.l	2
data_end	rs.l	2
opt_header_size	rs.l	1

;------------------------------------------------------------------------------
;section header
;------------------------------------------------------------------------------
		rsreset
s_name		rs.b	8
s_paddr		rs.l	2	;Physical address
s_vaddr		rs.l	2	;Virtual address
s_size		rs.l	1	;section size in words
s_scnptr	rs.l	1	;Filepointer to raw data
s_relptr	rs.l	1	;File pointer to relocation entries
s_lnnoptr	rs.l	1	;File pointer to line number entries
s_nreloc	rs.l	1	;nb relocation entries
s_nlnno		rs.l	1	;nb line entries
s_flags		rs.l	1	;section flags
section_size	rs.l	1

;------------------------------------------------------------------------------
; Symbol table entry
;------------------------------------------------------------------------------
		rsreset
n_name		rs.l	0
n_zeroes	rs.l	1
n_offset	rs.l	1
n_address	rs.l	0
n_val		rs.l	2
n_scnum		rs.l	1
n_type		rs.l	1
n_sclass	rs.l	1
n_numaux	rs.l	1


;------------------------------------------------------------------------------
; EQU pour les type de STORAGE CLASS
;------------------------------------------------------------------------------
C_EFCN=-1	; physical end of function 

C_NrrULL=0
C_AUTO=1	; automatic variable 
C_EXT=2		; external symbol 
C_STAT=3	; static 
C_REG=4		; register variable 
C_EXTDEF=5  	; external definition 
C_LABEL=6	; label 
C_ULABEL=7	; undefined label 
C_MOS=8		; member of structure 
C_ARG=9		; function argument 
C_STRTAG=10	; structure tag 
C_MOU=11	; member of union 
C_UNTAG=12	; union tag 
C_TPDEF=13	; type definition 
C_USTATIC=14	; undefined static 
C_ENTAG=15	; enumeration tag 
C_MOE=16	; member of enumeration 
C_REGPARM=17	; register parameter 
C_FIELD=18	; bit field 
C_MEMREG=19	; memory locations used as registers 
C_OPTIMIZED=20	; objects optimized away 
C_BLOCK=100	; ".bb" or ".eb" 
C_FCN=101	; ".bf" or ".ef" 
C_EOS=102	; end of structure 
C_FILE=103	; file name 


; The following storage class is a "dummy" used only by STS
; for line number entries reformatted as symbol table entries
C_LINE=104
C_ALIAS=105	; duplicate tag 
C_HIDDEN=106	; special storage class for external 


; The following storage classes support Motorola DSP assembly
; language symbolic debugging.
A_FILE=200	; assembly language source file name 
A_SECT=201	; logical section start/end symbol 
A_BLOCK=202	; COFF section debug symbol 
A_MACRO=203	; macro debug symbol 
A_GLOBAL=210	; global assembly language symbol 
A_XDEF=211	; XDEFed assembly language symbol 
A_XREF=212	; XREFed assembly language symbol 
A_SLOCAL=213	; section local label 
A_ULOCAL=214	; underscore local label 
A_MLOCAL=215	; macro local label 
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
; chargement de .CLD
; et chargement automatique au d‚marrage
;------------------------------------------------------------------------------
LOAD_CLD::
	xref	dsp_name
	xref	ACTIF_DSP
	tst	ACTIF_DSP
	bne.S	.ACT		;d‚gage si le DSP n'est pas la
	rts
.ACT
	lea	.txt,a0
	lea	.mask,a1
	lea	dsp_name,a2
	
	xref	FILE_SELECTOR	
	bsr.l	FILE_SELECTOR	
	
	tst	d0
	beq	GO_FILE
	rts
	
		
.mask	dc.b	'*.CLD',0
	ifne	(LANGUAGE=FRANCAIS)
.txt	dc.b	'choisissez un fichier CLD',0
	endc
	
	ifne	(LANGUAGE=ANGLAIS)
.txt	dc.b	'select a CLD file',0
	endc
		

AUTO_LOAD_CLD::

GO_FILE
	move	#0,-(sp)
	pea	dsp_name
	GEM	Fopen
	move.l	d0,d7
	bmi	.ERREUR
	
	
	*----------------------------------*
	*libere l'ancien buffer de symboles
	*----------------------------------*
	xref	SYMBOLS_PTR
	move.l	SYMBOLS_PTR,d0
	beq.s	.NOFREE
	move.l	d0,-(sp)
	GEM	Mfree				
	clr.l	SYMBOLS_PTR	
.NOFREE

	
	*-------------------*
	* Calcul de la taille
	* du fichier....
	* par 2 FSEEK
	*-------------------*

	move	#2,-(sp)
	move	d7,-(sp)
	clr.l	-(sp)	
	GEM	Fseek		;va … la fin

	move.l	d0,d6
		
	move	#0,-(sp)
	move	d7,-(sp)
	clr.l	-(sp)
	GEM	Fseek		;retourne au debut
	

	*-------------------*
	* MALLOC...
	*-------------------*
	move.l	d6,-(sp)
	GEM	Malloc		;Malloc(size)
	tst.l	d0
	beq	.ERREUR	
	bmi	.ERREUR	
	move.l	d0,a6


	*-------------------*
	* Lecture du fichier
	*-------------------*
	
	move.l	d0,-(sp)
	move.l	d6,-(sp)	
	move	d7,-(sp)
	GEM	Fread		;FREAD(size)
	

	move	d7,-(sp)
	GEM	Fclose
	
	move.l	a6,a0
		

	*--------------------*
	* ici on traite le .CLD
	* point‚ par a0
	*--------------------*

	cmp.l	#$2c5,f_magic(a0)	;56001
	bne	.ERREUR
	
	*--------------------*
	* on calcule quelques pointeurs
	* bien utiles
	*--------------------*

	move.l	a0,a1
	add.l	f_symptr(a0),a1
	move.l	f_nsyms(a0),d0
	asl.l	#5,d0
	add.l	d0,a1
	move.l	a1,string_ptr		;STRING TABLE
	
	move.l	a0,a1
	add.l	f_symptr(a0),a1
	move.l	a1,symbol_ptr		;SYMBOL TABLE


	
	lea	f_header_size(a0),a1	;fin du header
	add.l	f_opthdr(a0),a1		;saute header optionnel

	move.l	f_nscns(a0),d0
	mulu	#section_size,d0
	add.l	a1,d0
	move.l	d0,raw_data_ptr

	

	*---------------*
	* on parse les sections symbols
	*---------------*
	bsr	LOAD_SYM




	*---------------*
	* on parse les sections "normales"
	*---------------*
	bsr	LOAD_SEC

	
.ERREUR	rts


*------------------------------------------------------------------------------
* saute … la routine qui convient pour la section..
*------------------------------------------------------------------------------
LOAD_SEC
;	a0	ptr .CLD
;	a1	ptr current section

	lea	ASCII_BUF,a5		;pour les lignes, efface le buffer
	move	#20000/4-1,d7
.CLR	clr.l	(a5)+
	dbra	d7,.CLR


	lea	ASCII_BUF,a5		;pour les lignes
	move.l	f_nscns(a0),d0
	beq	FIN_SEC
	move.l	d0,-(sp)
	
LOOP_SECTION	
	move.l	s_flags(a1),d0
	beq	REGULAR_SECTION
	cmp.l	#$1,d0
	beq	DUMMY_SECTION
	cmp.l	#$2,d0
	beq	NOLOAD_SECTION

	cmp.l	#$4,d0
	beq	GROUPED_SECTION
	cmp.l	#$8,d0
	beq	PADDING_SECTION
	cmp.l	#$10,d0
	beq	COPY_SECTION
	cmp.l	#$20,d0
	beq	EXEC_SECTION
	cmp.l	#$40,d0
	beq	DATA_SECTION
	cmp.l	#$80,d0
	beq	BSS_SECTION
	cmp.l	#$400,d0
	beq	BLOCK_SECTION
	cmp.l	#$40,d0
	beq	OVERLAY_SECTION
	cmp.l	#$40,d0
	beq	MACRO_SECTION



DATA_SECTION
EXEC_SECTION
	*----------------------*
	* la partie commune aux sections DATA et TEXT
	*----------------------*

	move.l	s_size(a1),d7		;section size
	beq	NEXT_SECTION

	move.l	s_scnptr(a1),d0
	beq	NEXT_SECTION		;certaines sections on un offset 
					;vers les data nul... en particulier
					;les sections .text 
					;je ne connait pas d'autre moyen de les ‚liminer
	lea	(a0,d0.l),a2

	envl	#'CMD'
	
	move.l	s_paddr+4(a1),d0	;type de RAM
	add.l	#DSP_P2DSP,d0		;envoie vers DSP
	envl	d0
	envl	s_paddr(a1)		;adresse
	envl	d7			;nbr	
.SEND	envl	(a2)+
	subq.l	#1,d7
	bne.s	.SEND

	
	
	*---------------------------------------*
	* on essaye de r‚cup‚rer des no de lignes
	* partie propre a la section TEXT je pense
	*---------------------------------------*
	
	
	move.l	s_nlnno(a1),d7
	beq	NEXT_SECTION			;pas de no de ligne => out
	subq	#1,d7
	move.l	a0,a2
	add.l	s_lnnoptr(a1),a2

	tst.l	8(a2)
	beq.s	.skip

	*---------------------------------------*
	* la premiere entr‚e a line_nb=0
	* on la skippe c'est le nom de la function
	*---------------------------------------*
.LOOP_LNO
	move.l	8(a2),d0
	move.l	(a2),(a5,d0.l*4)
.skip	add	#12,a2
	dbra	d7,.LOOP_LNO





	*----------------*
	* je ne gere pas tout ca !
	*----------------*
	
REGULAR_SECTION
DUMMY_SECTION
NOLOAD_SECTION
GROUPED_SECTION
PADDING_SECTION
COPY_SECTION
BSS_SECTION
BLOCK_SECTION
OVERLAY_SECTION
MACRO_SECTION
NEXT_SECTION
	add.w	#section_size,a1		;section suivante
	subq.l	#1,(sp)
	bne	LOOP_SECTION
	addq.w	#4,sp
FIN_SEC	

	*---------------*
	* on recopie la table des lignes
	* quand on a trou, on recopie la pr‚c‚dente ligne valide
	*---------------*

	
	xref	DSP_SOURCE_TABLE
	lea	DSP_SOURCE_TABLE,a0
	move.l	ptr_conv(a0),a1
	move	nb_ligne(a0),d7
	beq	.FIN
	subq	#1,d7
	xref	ASCII_BUF
	lea	ASCII_BUF,a2
	
	moveq	#0,d0
.RECOPIE
	move.l	(a2)+,(a1)+
	;tst.l	(a2)+
	;beq.s	.OK0
	;move.l	-4(a2),d0
.OK0
	;move.l	d0,(a1)+
	dbra	d7,.RECOPIE
.FIN

	rts
	

*------------------------------------------------------------------------------
* chargement des section de symbols
*------------------------------------------------------------------------------
LOAD_SYM
	movem.l	d0-a6,-(sp)
	
	clr	nb_symbols		;init...

	lea	WORK_BUF,a6		;on va placer le type de RAM + ptr sur symbolci
	lea	ASCII_BUF,a5		;on palce les symbols ici

	move.l	a0,a1
	add.l	f_symptr(a0),a1
	lea	(a0,d6.l),a3		;pointe … la fin...
	move.l	f_nsyms(a0),d0
	beq	SUITE_SYM
	move.l	d0,-(sp)

*------------------------------------------------------------------------------
* On va traiter les sections qui parlent de symbols puisqu'il y a l'air 
* d'en avoir plusieurs...
* mais on ne va garder que celles qui nous interessent
*-----------------------------------------------------------------------------
LOOP_SYMBOL
	
	move.l	n_sclass(a1),d0

	
	cmp.l	#C_EXT,d0
	beq.s	symbol
	;cmp.l	#C_STAT,d0
	;beq.s	symbol		;d‚gag‚ car ya 15 symbols '.txt' / source
	cmp.l	#C_EXTDEF,d0
	beq.s	symbol
	cmp.l	#C_LABEL,d0
	beq.s	symbol
	cmp.l	#A_XDEF,d0
	beq.s	symbol
	cmp.l	#A_XREF,d0
	beq.s	symbol
	cmp.l	#A_SLOCAL,d0
	beq.s	symbol
	cmp.l	#A_ULOCAL,d0
	beq.s	symbol
	cmp.l	#A_GLOBAL,d0
	beq.s	symbol

	cmp.l	#C_FILE,d0
	beq.s	source
	cmp.l	#A_FILE,d0
	beq.s	source

	bra	NEXT_SYMBOL
symbol
	*--------------------*
	* on a pech‚ un symbol valable !
	* on le stocke
	*--------------------*


	*--------------------*
	* d'abord son type de RAM
	*--------------------*
	move	#'P'*256,d0
	move.l	n_address+4(a1),d1
	beq.s	.OK0			;P?
	move	#'X'*256,d0
	subq	#1,d1
	beq.s	.OK0			;X?
	move	#'Y'*256,d0
	subq	#1,d1
	beq.s	.OK0			;Y?
	move	#'L'*256,d0
	subq	#1,d1
	beq.s	.OK0			;L?
	bra	NEXT_SYMBOL		;pas un type valide	
.OK0	
	*--------------------*
	* le nom est-il en string table ?
	*--------------------*
	addq	#1,nb_symbols
	lea	n_name(a1),a2	
	moveq	#8-1,d7		;le nom fait 8 char … la base
	tst.l	n_name(a1)
	bne.s	.OK1		;le nom est-il ds la string table ?
	move.l	string_ptr,a2	;string_table
	add.l	n_name+4(a1),a2	;+offset du nom
	moveq	#-1,d7		;taille ind‚termin‚e
.OK1
	move	d0,(a6)+	;RAM type
	move.l	8(a1),(a6)+	;adresse
	clr.l	(a6)+		;dummy
		
.COP	move.b	(a2)+,(a5)+
	dbeq	d7,.COP
	beq	.NO_Z
	clr.b	(a5)+
.NO_Z	bra	NEXT_SYMBOL


	*--------------------*
	* on a pech‚ un source
	*--------------------*
source
	movem.l	d0-a6,-(sp)

	move.l	n_numaux(a1),d0	;nb entr‚e auxiliaire
	beq.s	.ffile		
	
	lea	32(a1),a0
	xref	dsp_load_source		
	bsr	dsp_load_source		

.ffile	movem.l	(sp)+,d0-a6


NEXT_SYMBOL
	move.l	n_numaux(a1),d0
	beq.s	.OK10
	lsl.l	#5,d0
	add.l	d0,a1
	subq.l	#1,(sp)

.OK10	add	#32,a1		
	subq.l	#1,(sp)
	bne	LOOP_SYMBOL
	addq	#4,sp
SUITE_SYM
	*---------------*
	* on a fini toute les sections symbol
	* on compte les symbols
	* on fait le malloc qui va bien
	* et on recopie dedans
	*---------------*

	move.l	a6,d0
	xref	WORK_BUF
	sub.l	#WORK_BUF,d0
	move.l	d0,d7
	beq	.RIEN_SYM
	move.l	d0,d1
	divu	#10,d1
	move	d1,nb_symbols	

		
	move.l	a5,d1
	xref	ASCII_BUF
	sub.l	#ASCII_BUF,d1
	add.l	d0,d1		;ascii
	addq	#4,d1		;nb 
	
	move.l	d1,-(sp)
	GEM	Malloc
	
	lea	WORK_BUF,a5
	lea	ASCII_BUF,a6

	move.l	d0,a0
	move.l	d0,SYMBOLS_PTR
	
	lea	(4,a0,d7.l),a1
	moveq	#0,d7
	move	nb_symbols,d7
	move.l	d7,(a0)+
	subq	#1,d7
	bmi.s	.RIEN_SYM
				
.RECOPIE
	move.w	(a5)+,(a0)+	;type RAM
	move.l	(a5)+,(a0)+	;adresse
	addq	#4,a5
	move.l	a1,(a0)+	;ptr_symbol

.COP12	move.b	(a6)+,(a1)+
	bne.S	.COP12	

	dbra	d7,.RECOPIE


.RIEN_SYM
	movem.l	(sp)+,d0-a6
	rts
	
*------------------------------------------------------------------------------
string_ptr	ds.l	1
symbol_ptr	ds.l	1
raw_data_ptr	ds.l	1
nb_symbols	ds	1