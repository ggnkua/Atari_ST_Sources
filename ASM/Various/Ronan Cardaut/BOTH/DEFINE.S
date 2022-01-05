

;------------------------------


PHENIX		EQU	1		; pour le PHENIX


;------------------------------




DSP56001	equ	0
DSP56301	equ	1
DSP		equ	DSP56001



debug_var		equ	1		; mode debug on=1



;------------------------------------------------------------------------------
;d‚finitions de langues
;------------------------------------------------------------------------------
ANGLAIS		equ	0
FRANCAIS	equ	1	
GERMAN		equ	2
;------------------------------------------------------------------------------
;Quelques no de s‚rie
;------------------------------------------------------------------------------
thomas			equ	$359F78BA
rodolphe_mechant	equ	$74529632
centek			equ	$73563541
salon_en_allemagne	equ	$59467854	


;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
PROTECT_ACTIVE	equ	0
nom		equ	centek
FPU_PRES	equ 	1		; 0 y a pas
DEMO_MODE	equ 	0		; 1 demo
LANGUAGE	equ	FRANCAIS
size_font	equ	16
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
max_src		equ	256

;------------------------------------------------------------------------------
; QUELQUES EQU POUR LE DSP
nb_dsp_bkp	equ	64	;nb BKPT au max
;------------------------------------------------------------------------------



;------------------------------------------------------------------------------
; quelques equ pour le 040
;------------------------------------------------------------------------------
system_start	equ	$e00030
;------------------------------------------------------------------------------



;------------------------------------------------------------------------------
;STRUCTURE FENETRE
;------------------------------------------------------------------------------
		rsreset
type		rs.w	1
W_X1		rs.w	1
W_Y1		rs.w	1
Largeur		rs.w	1
Hauteur		rs.w	1
ptr_expr	rs.l	1
mem_type	rs.w	1	;X ou Y ou L
adr_debut	rs.l	1	;adr en haut de la fenetre
adr_fin		rs.l	1	;adr apres la derniere ligne
nb_colonnes	rs.w	1	
start_col	rs.w	1	;pour les scrolls ds fenetre
start_ligne	rs.w	1
flag_aff	rs.w	1
Src_adr		rs.l	1	;adresse de la structure source
Line_nb		rs.w	1	;no de ligne courant du source
max_ligne	rs.w	1	;nb de lignes total
max_col		rs.w	1	;le + grand nb col du source
Tab_Value	rs.w	1	
Tab_adr_debut	rs.l	2	;sauve l'adr debut du 68 et du dsp
Size_win	rs.w	1
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
;STRUCTURE SOURCE pour le tableau des sources charg‚s
;------------------------------------------------------------------------------
		rsreset
ptr		rs.l	1		;ptr sur le source en RAM
ligne_ptr	rs.l	1		;ptr sur la table des lignes
nb_ligne	rs	1
nb_col		rs	1
ptr_name	rs.l	1
ptr_conv	rs.l	1
Size_src	rs.w	1

;**************************************
;*** types:
;	0:reserved
;030:	1:registres
;	2:disas
;	3:HEXA 16
;	4:HEXASCII 16
;	5:ASCII
;	6:DIVERS ( ASCII COLOR )
;	7 … 10 r‚serv‚ pour le 30	
;DSP:
;	11:registers
;	12:disas
;	13:HEXA 24
;	14:HEXASCII 24
;	15:FRAC 24
;	16:HEXA 48
;	17:SS
;**************************************
		rsreset
		rs.b	1	;reserved		
T_reg_68	rs.b	1	
T_disas_68	rs.b	1
T_H16		rs.b	1
T_HEXASCII16	rs.b	1
T_ASCII		rs.b	1
T_INFO		rs.b	1
T_IO		rs.b	1
T_M40_SRC	rs.b	1		
T_dernier	rs.b	1
		rsset	10
		rs.b	1	;reserved
T_reg		rs.b	1	
T_disas		rs.b	1
T_H24		rs.b	1
T_HEXASCII24	rs.b	1
T_FRAC24	rs.b	1
T_H48		rs.b	1
T_SS		rs.b	1
T_DSP_SRC	rs.b	1
T_dsp_dernier	rs.b	1
;**************************************


;*------------------------------------------------------------------------------
;***************************
;format du mot 'ASCII'
;F I N 0 CCCC . xxxxxxxx     	
;F= flag de FIN (en fait $8000)
;I= inverse video
;N= affichage binaire (tab,cr,lf... ne sont pas g‚r‚s)
;***************************


;***************************
;definition des couleurs 	
;***************************

	rsreset
fond		rs.b	1
noir		rs.b	1
vert		rs.b	1
jaune		rs.b	1
bleu		rs.b	1
magenta		rs.b	1
cyan		rs.b	1
gris		rs.b	1
grisF		rs.b	1
rouge		rs.b	1
vertF		rs.b	1
jauneF		rs.b	1
bleuF		rs.b	1
magentaF	rs.b	1
cyanF		rs.b	1
blanc		rs.b	1
;***************************


****************************************
** definition des types de processeur **
****************************************
	rsreset
cpu_bad	rs.b	1
cpu_30	rs.b	1
cpu_40	rs.b	1
cpu_60	rs.b	1


*****************************************************
** definnition des registres internes au debogueur **
*****************************************************

	rsreset

r_w0	rs.l	1		; les registres des fenetres
r_w1	rs.l	1
r_w2	rs.l	1
r_w3	rs.l	1
r_w4	rs.l	1
r_w5	rs.l	1
r_w6	rs.l	1
r_w7	rs.l	1
r_w8	rs.l	1
r_w9	rs.l	1
r_w10	rs.l	1
r_w11	rs.l	1
r_w12	rs.l	1
r_w13	rs.l	1
r_w14	rs.l	1
r_w15	rs.l	1
r_w16	rs.l	1
r_w17	rs.l	1
r_w18	rs.l	1
r_w19	rs.l	1
r_w20	rs.l	1
r_w21	rs.l	1
r_w22	rs.l	1
r_w23	rs.l	1
r_w24	rs.l	1
r_w25	rs.l	1
r_w26	rs.l	1
r_w27	rs.l	1
r_w28	rs.l	1
r_w29	rs.l	1
r_w30	rs.l	1
r_w31	rs.l	1

r_i0	rs.l	1		; les registres internes
r_i1	rs.l	1
r_i2	rs.l	1
r_i3	rs.l	1
r_i4	rs.l	1
r_i5	rs.l	1
r_i6	rs.l	1
r_i7	rs.l	1

	**** bien placer le r_e ici...

r_e	rs.l	1		; registre de retour de l'‚valuateur
	rs.l	1		; c'est un double.... normalement

r_text	rs.l	1		; pour le programme
r_data	rs.l	1
r_bss	rs.l	1

**************************************
** definition des registre du 68040 **
**************************************

	rsreset
r_d0	rs.l	1
r_d1	rs.l	1
r_d2	rs.l	1
r_d3	rs.l	1
r_d4	rs.l	1
r_d5	rs.l	1
r_d6	rs.l	1
r_d7	rs.l	1
r_a0	rs.l	1
r_a1	rs.l	1
r_a2	rs.l	1
r_a3	rs.l	1
r_a4	rs.l	1
r_a5	rs.l	1
r_a6	rs.l	1
r_a7	rs.l	1
r_sr	rs.l	1
r_pc	rs.l	1
r_ssp	rs.l	1		;sauvegarde de isp
r_msp	rs.l	1
r_vrb	rs.l	1
r_usp	rs.l	1
r_isp	rs.l	1
;r_sp	rs.l	1		; registre qui va contenir une copie de la valeur de usp ou ssp




r_fp0	rs.l	1	
	rs.l	1
	rs.l	1
r_fp1	rs.l	1	
	rs.l	1
	rs.l	1
r_fp2	rs.l	1	
	rs.l	1
	rs.l	1
r_fp3	rs.l	1	
	rs.l	1
	rs.l	1
r_fp4	rs.l	1	
	rs.l	1
	rs.l	1
r_fp5	rs.l	1	
	rs.l	1
	rs.l	1
r_fp6	rs.l	1	
	rs.l	1
	rs.l	1
r_fp7	rs.l	1	
	rs.l	1
	rs.l	1
r_fpcr	rs.l	1
r_fpsr	rs.l	1
r_fpiar	rs.l	1

r_mmusr	rs.l	1
r_crp	rs.l	2
r_srp	rs.l	2
r_sfc	rs.l	1
r_dfc	rs.l	1
r_tt0	rs.l	1
r_tt1	rs.l	1
r_tc	rs.l	1

r_dttr0	rs.l	1
r_dttr1	rs.l	1
r_ittr0	rs.l	1
r_ittr1	rs.l	1

r_cacr	rs.l	1
r_caar	rs.l	1

r_pcr	rs.l	1
r_buscr	rs.l	1


*****************************************
** definition des registre du DSP56301 **
*****************************************
	rsreset
;REG_AGU	rs.l	0
REG_R0	rs.l	1
REG_N0	rs.l	1
REG_M0	rs.l	1
REG_R1	rs.l	1
REG_N1	rs.l	1
REG_M1	rs.l	1
REG_R2	rs.l	1
REG_N2	rs.l	1
REG_M2	rs.l	1
REG_R3	rs.l	1
REG_N3	rs.l	1
REG_M3	rs.l	1
REG_R4	rs.l	1
REG_N4	rs.l	1
REG_M4	rs.l	1
REG_R5	rs.l	1
REG_N5	rs.l	1
REG_M5	rs.l	1
REG_R6	rs.l	1
REG_N6	rs.l	1
REG_M6	rs.l	1
REG_R7	rs.l	1
REG_N7	rs.l	1
REG_M7	rs.l	1		;AGU
;REG_ALU rs.l	0
REG_A2	rs.l	1
REG_A1	rs.l	1
REG_A0	rs.l	1
REG_B2	rs.l	1
REG_B1	rs.l	1
REG_B0	rs.l	1
REG_X1	rs.l	1
REG_X0	rs.l	1
REG_Y1	rs.l	1
REG_Y0	rs.l	1		;ALU
REG_LA	rs.l	1
REG_LC	rs.l	1

REG_SR	rs.l	0
REG_SSL	rs.l	1

REG_PC	rs.l	0
REG_SSH	rs.l	1

REG_SP	rs.l	1		;SP
REG_Long	rs.l	1




;------------------------------------------------------------------------------
; LES MACROS POUR LA COMMUNICATION DSP
;------------------------------------------------------------------------------

	
	;-------------------------------------
	; LE VIEUX 56001
	;-------------------------------------
	ifne	(DSP=DSP56001)
env	macro
	btst	#1,$ffffa202.w
	beq.s	*-6
	endm
rec	macro
	btst	#0,$ffffa202.w
	beq.s	*-6
	endm
envl	macro
	btst	#1,$ffffa202.w
	beq.s	*-6
	move.l	\1,$ffffa204.w
	endm
recl	macro
	btst	#0,$ffffa202.w
	beq.s	*-6
	move.l	$ffffa204.w,\1
	endm

	endc

	;-------------------------------------
	; LE ZOULI 56301
	;-------------------------------------
	ifne	(DSP=DSP56301)

dsp_base	equ	$f0000000
HCTR		equ	dsp_base+4*4
HSTR		equ	dsp_base+5*4
HCVR		equ	dsp_base+6*4
HTXR		equ	dsp_base+7*4
HRXS		equ	dsp_base+7*4

env	MACRO
	btst	#1,HSTR+3
	beq.S	*-8
	ENDM

rec	MACRO
	btst	#2,HSTR+3
	beq.S	*-8
	ENDM
	
envl	MACRO
	env
	move.l	\1,HTXR
	nop
	ENDM

recl	MACRO
	rec
	move.l	HRXS,\1
	ENDM

	endc




cpy	macro
;\1=chaine 
;\2=ptr dest
	move.l	a0,-(sp)
	move	d0,-(sp)
	move	ATTRIBUTE,d0
	lea	.CPY\@,a0
.LOOP\@	move.b	(a0)+,d0
	beq.s	.COA\@
	move.\0	d0,(\2)+
	bra.s	.LOOP\@
.CPY\@	dc.b	\1,0
	even
.COA\@	
	move	(sp)+,d0
	move.l	(sp)+,a0
	endm

col_cpy	macro
;\1=source
;\2=dest
	move	d0,-(sp)
	move	ATTRIBUTE,d0
.LOOP\@	move.b	(\1)+,d0
	beq.s	.COA\@
	move	d0,(\2)+
	bra.s	.LOOP\@
.COA\@	move	(sp)+,d0
	endm

copy	macro
;\1=chaine 
;\2=ptr dest
	move.l	a1,-(sp)
	move	d0,-(sp)
	move	ATTRIBUTE,d0
	lea	.CPY\@,a1
.LOOP\@	move.b	(a1)+,d0
	beq.s	.COA\@
	move.\0	d0,(\2)+
	bra.s	.LOOP\@
.CPY\@	dc.b	\1,0
	even
.COA\@	
	move	(sp)+,d0
	move.l	(sp)+,a1
	endm

RON_ALLOC	MACRO
	xref	OLD_PRUN
	move.l	a6,-(sp)
	move.l	([$4f2.w],$28.w),a6
	move.l	(a6),OLD_PRUN	
	
	move.l	4(sp),-(sp)
	GEM	Malloc
	
	
	move.l	OLD_PRUN,(a6)
	
	move.l	(sp)+,a6
	lea	4(sp),sp
	ENDM

;RON_XALLOC	MACRO
;	xref	OLD_PRUN
;	
;	move.l	a6,-(sp)
;	move.l	([$4f2.w],$28.w),a6
;	move.l	(a6),OLD_PRUN	
;	move.l	(sp)+,a6
;
;	GEM	Mxalloc
;	
;	move.l	a6,-(sp)
;	move.l	([$4f2.w],$28.w),a6
;	move.l	OLD_PRUN,(a6)
;	move.l	(sp)+,a6
;	
;	ENDM
	
			
RON_XALLOC2	MACRO
	xref	BASE_PAGE
	;xref	OLD_PRUN
	
	move.l	a0,-(sp)
	move.l	([$4f2.w],$28.w),a0
	move.l	(a0),-(sp)

	move.l	BASE_PAGE,(a0)





	move.w	\1,-(sp)
	move.l	\2,-(sp)
	GEM	Mxalloc
	
	move.l	([$4f2.w],$28.w),a0
	move.l	(sp)+,(a0)
	move.l	(sp)+,a0
	
	ENDM
			


CENT_PROS	MACRO
	move.l	a0,-(sp)
	
	move.l	([$4f2.w],$28.w),a0
	move.l	(a0),SAVE_OLD_PROS
	move.l	BASE_PAGE,(a0)
	
	move.l	(sp)+,a0

		ENDM




REST_PROS	MACRO

	move.l	a0,-(sp)
	move.l	([$4f2.w],$28.w),a0
	move.l	SAVE_OLD_PROS,(a0)
	move.l	(sp)+,a0
		
		ENDM
	
;***************************

			
;**************************************
;commandes DSP
;**************************************
		rsreset
DSP_PDUMP	rs.b	1
DSP_XDUMP	rs.b	1
DSP_YDUMP	rs.b	1
DSP_LDUMP	rs.b	1
DSP_RUN	rs.b	1
DSP_P2DSP	rs.b	1
DSP_X2DSP	rs.b	1
DSP_Y2DSP	rs.b	1
DSP_L2DSP	rs.b	1


;**************************************
	rsreset	
MEM_P	rs.b	1
MEM_X	rs.b	1
MEM_Y	rs.b	1
MEM_L	rs.b	1
;**************************************


***************************************
		rsreset
		rs.b	1
ADR_BUS_L	rs.b	1		; bus error
ADR_INT_L	rs.b	1		; interdit en lecture


;------------------------------------------------------------------------------
; structure break point ds TAB_BKPT
;------------------------------------------------------------------------------
		rsreset
Actif		rs.w	1		;$ffff (normal) $fffe (permanent)
Adresse		rs.l	1
Sauve		rs.l	1
Ptr_expr	rs.l	1
Exeption	rs.l	1
BKP_Long	rs.l	1