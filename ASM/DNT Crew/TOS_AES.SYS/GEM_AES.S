*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;                          Mini-bibliothŠque GEM                          ;
;                                                                         ;
;                    (C)oderigth Nullos//DNT-Crew 1992                    ;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	SECTION	TEXT

	RSRESET		;structure OBJECT
ob_next	rs.W	1
ob_head	rs.W	1
ob_tail	rs.W	1
ob_type	rs.W	1
ob_flags	rs.W	1
ob_state	rs.W	1
ob_spec	rs.L	1
ob_x	rs.W	1
ob_y	rs.W	1
ob_w	rs.W	1
ob_h	rs.W	1
ob_size	rs.B	0

	RSRESET		;structure TEDINFO
te_ptext	rs.L	1
te_ptmplt	rs.L	1
te_pvalid	rs.L	1
te_font	rs.W	1
te_junk1	rs.W	1
te_just	rs.W	1
te_color	rs.W	1
te_junk2	rs.W	1
te_thickness rs.W	1
te_txtlen	rs.W	1
te_tmplen	rs.W	1
te_size	rs.B	0

	RSRESET		;structure BITBLK
bi_pdata	rs.L	1
bi_wb	rs.W	1
bi_hl	rs.W	1
bi_x	rs.W	1
bi_y	rs.W	1
bi_color	rs.W	1
bi_size	rs.B	0

	RSRESET		;structure ICONBLK
ib_pmask	rs.L	1
ib_pdata	rs.L	1
ib_ptext	rs.L	1
ib_char	rs.W	1
ib_xchar	rs.W	1
ib_ychar	rs.W	1
ib_xicon	rs.W	1
ib_yicon	rs.W	1
ib_wicon	rs.W	1
ib_hicon	rs.W	1
ib_xtext	rs.W	1
ib_ytext	rs.W	1
ib_wtext	rs.W	1
ib_htext	rs.W	1
ib_resvd	rs.W	1
ib_size	rs.B	0

	RSRESET		;structure USERBLK
ub_code	rs.L	1
ub_param	rs.L	1

	RSRESET		;structure PARAMBLK
pb_tree	rs.L	1
pb_obj	rs.W	1
pb_prevstate rs.W	1
pb_currstate rs.W	1
pb_x	rs.W	1
pb_y	rs.W	1
pb_w	rs.W	1
pb_h	rs.W	1
pb_xc	rs.W	1
pb_yc	rs.W	1
pb_wc	rs.W	1
pb_hc	rs.W	1
pb_param	rs.L	1

	RSRESET		;structure GRECT
g_x	rs.W	1
g_y	rs.W	1
g_w	rs.W	1
g_h	rs.W	1
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	;event_multi definitions;

MU_KEYBD	equ	$01	;masque d'‚vŠnement pour evnt_multi
MU_BUTTON	equ	$02
MU_M1	equ	$04
MU_M2	equ	$08
MU_MESAG	equ	$10
MU_TIMER	equ	$20

MN_SELECTED equ	10	;types de message retourn‚s
WM_REDRAW	equ	20
WM_TOPPED	equ	21
WM_CLOSED	equ	22
WM_FULLED	equ	23
WM_ARROWED	equ	24
WM_HSLID	equ	25
WM_VSLID	equ	26
WM_SIZED	equ	27
WM_MOVED	equ	28
WM_NEWTOP	equ	29
AC_OPEN	equ	40
AC_CLOSE	equ	41
CT_UPDATE	equ	50
CT_MOVE	equ	51
CT_NEWTOP	equ	52


K_RSHIFT	equ	1	;touches sp‚ciales
K_LSHIFT	equ	2
K_CTRL	equ	4
K_ALT	equ	8
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	;Object definitions;

G_BOX	equ	20	;diff‚rents ob_type
G_TEXT	equ	21
G_BOXTEXT	equ	22
G_IMAGE	equ	23
G_USERDEF	equ	24
G_IBOX	equ	25
G_BUTTON	equ	26
G_BOXCHAR	equ	27
G_STRING	equ	28
G_FTEXT	equ	29
G_FBOXTEXT	equ	30
G_ICON	equ	31
G_TITLE	equ	32



NONE	equ	$000	;diff‚rents ob_flags
SELECTABLE	equ	$001
DEFAULT	equ	$002
EXIT	equ	$004
EDITABLE	equ	$008
RBUTTON	equ	$010
LASTOB	equ	$020
TOUCHEXIT	equ	$040
HIDETREE	equ	$080
INDIRECT	equ	$100



NORMAL	equ	$00	;ob_state
SELECTED	equ	$01
CROSSED	equ	$02
CHECKED	equ	$04
DISABLED	equ	$08
OUTLINED	equ	$10
SHADOWED	equ	$20


WHITE	equ	0	;couleurs standards
BLACK	equ	1
RED	equ	2
GREEN	equ	3
BLUE	equ	4
CYAN	equ	5
YELLOW	equ	6
MAGENTA	equ	7
LWHITE	equ	8
LBLACK	equ	9
LRED	equ	10
LGREEN	equ	11
LBLUE	equ	12
LCYAN	equ	13
LYELLOW	equ	14
LMAGENTA	equ	15


ROOT	equ	0
MAX_LEN	equ	81
MAX_DEPTH	equ	8


IBM	equ	3	;fonte normal
SMALL	equ	5	;petite fonte


ED_START	equ	0	;pour objc_edit
ED_INIT	equ	1
ED_CHAR	equ	2
ED_END	equ	3

TE_LEFT	equ	0	;centrage (pour TEDINFO)
TE_RIGHT	equ	1
TE_CNTR	equ	2
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	;Form_dial options;

FMD_START	equ	0
FMD_GROW	equ	1
FMD_SHRINK	equ	2
FMD_FINISH	equ	3
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	;Mouse forms;

ARROW	equ	0
TEXT_CRSR	equ	1
HOURGLASS	equ	2
BUSYBEE	equ	2
POINT_HAND	equ	3
FLAT_HAND	equ	4
THIN_CROSS	equ	5
THICK_CROSS equ	6
OUTLN_CROSS equ	7
USER_DEF	equ	255
M_OFF	equ	256
M_ON	equ	257

	;Mouse form definition block;

	RSRESET		;structure MFORM
mf_xhot	rs.W	1
mf_yhot	rs.W	1
mf_nplanes	rs.W	1
mf_fg	rs.W	1
mf_bg	rs.W	1
mf_mask	rs.W	16
mf_data	rs.W	16
mf_size	rs.B	0
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	;Windows definitions;

NAME	equ	$0001
CLOSER	equ	$0002
FULLER	equ	$0004
MOVER	equ	$0008
INFO	equ	$0010
SIZER	equ	$0020
UPARROW	equ	$0040
DNARROW	equ	$0080
VSLIDE	equ	$0100
LFARROW	equ	$0200
RTARROW	equ	$0400
HSLIDE	equ	$0800

WF_KIND	equ	1
WF_NAME	equ	2
WF_INFO	equ	3
WF_WORKXYWH equ	4
WF_CURRXYWH equ	5
WF_PREVXYWH equ	6
WF_FULLXYWH equ	7
WF_HSLIDE	equ	8
WF_VSLIDE	equ	9
WF_TOP	equ	10
WF_FIRSTXYWH equ	11
WF_NEXTXYWH equ	12
WF_RESVD	equ	13
WF_NEWDESK	equ	14
WF_HSLSIZE	equ	15
WF_VSLSIZE	equ	16
WF_SCREEN	equ	17

WA_UPPAGE	equ	0
WA_DNPAGE	equ	1
WA_UPLINE	equ	2
WA_DNLINE	equ	3
WA_LFPAGE	equ	4
WA_RTPAGE	equ	5
WA_LFLINE	equ	6
WA_RTLINE	equ	7

WC_BORDER	equ	0
WC_WORK	equ	1

END_UPDATE	equ	0
BEG_UPDATE	equ	1
END_MCTRL	equ	2
BEG_MCTRL	equ	3
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	;Ressource definitions;

R_TREE	equ	0
R_OBJECT	equ	1
R_TEDINFO	equ	2
R_ICONBLK	equ	3
R_BITBLK	equ	4
R_STRING	equ	5
R_IMAGEDATA equ	6
R_OBSPEC	equ	7
R_TEPTEXT	equ	8
R_TEPTMPLT	equ	9
R_TEPVALID	equ	10
R_IBPMASK	equ	11
R_IBPDATA	equ	12
R_IPBTEXT	equ	13
R_BIPDATA	equ	14
R_FRSTR	equ	15
R_FRIMG	equ	16

	RSRESET		;Structure RSHDR
rsh_vrsn	rs.W	1
rsh_object	rs.W	1
rsh_tedinfo rs.W	1
rsh_iconblk rs.W	1
rsh_bitblk	rs.W	1
rsh_frstr	rs.W	1
rsh_string	rs.W	1
rsh_imdata	rs.W	1
rsh_frimg	rs.W	1
rsh_trindex rs.W	1
rsh_nobs	rs.W	1
rsh_ntree	rs.W	1
rsh_nted	rs.W	1
rsh_nib	rs.W	1
rsh_nbb	rs.W	1
rsh_nstring rs.W	1
rsh_nimages rs.W	1
rsh_rssize	rs.W	1
rsh_size	rs.B	0
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
appl_init		equ	$0A000100
appl_read		equ	$0B020101
appl_write		equ	$0C020101
appl_find		equ	$0D000101
appl_tplay		equ	$0E020101
appl_trecord	equ	$0F010101
appl_bvset		equ	$10020100		;GEM 2.0
appl_yield		equ	$11000100		;GEM 2.0
appl_exit		equ	$13000100

evnt_keybd		equ	$14000100
evnt_button	equ	$15030500
evnt_mouse		equ	$16050500
evnt_mesag		equ	$17000101
evnt_timer		equ	$18020100
evnt_multi		equ	$19100701
evnt_dclick	equ	$1A020100

menu_bar		equ	$1E010101
menu_icheck	equ	$1F020101
menu_ienable	equ	$20020101
menu_tnormal	equ	$21020101
menu_text		equ	$22010102
menu_register	equ	$23010101
menu_unregister	equ	$24010100		;GEM 2.0

objc_add		equ	$28020101
objc_delete	equ	$29010101
objc_draw		equ	$2A060101
objc_find		equ	$2B040101
objc_offset	equ	$2C010301
objc_order		equ	$2D020101
objc_edit		equ	$2E040201
objc_change	equ	$2F080101

form_do	 	equ	$32010101
form_dial		equ	$33090100
form_alert		equ	$34010101
form_error		equ	$35010100
form_center	equ	$36000501
form_keybd		equ	$37030301
form_button	equ	$38020201

graf_rubberbox	equ	$46040300
graf_dragbox	equ	$47080300
graf_movebox	equ	$48060100
graf_growbox	equ	$49080100
graf_shrinkbox	equ	$4A080100
graf_watchbox	equ	$4B030101
graf_slidebox	equ	$4C030101
graf_handle	equ	$4D000500
graf_mouse		equ	$4E010101
graf_mkstate	equ	$4F000500

srcp_read		equ	$50000101
srcp_write		equ	$51000101
scrp_clear		equ	$52000100		;GEM 2.0

fsel_input		equ	$5A000202
fsel_exinput	equ	$5B000203		;TOS 1.4

wind_create	equ	$64050100
wind_open		equ	$65050100
wind_close		equ	$66010100
wind_delete	equ	$67010100
wind_get		equ	$68020500
wind_set		equ	$69060100
wind_find		equ	$6A020100
wind_update	equ	$6B010100
wind_calc		equ	$6C060500
wind_new		equ	$6D000000		;TOS 1.4

rsrc_load		equ	$6E000101
rsrc_free		equ	$6F000100
rsrc_gaddr		equ	$70020100
rsrc_saddr		equ	$71020101
rsrc_obfix		equ	$72010101

shel_read		equ	$78000102
shel_write		equ	$79030102
shel_get		equ	$7A010101
shel_put		equ	$7B010101
shel_find		equ	$7C000101
shel_envrn		equ	$7D000102
shel_rdef		equ	$7E000102		;GEM 2.0
shel_wdef		equ	$7F000002		;GEM 2.0

xgrf_stepcalc	equ	$82060600		;GEM 2.0
xgrf_2box		equ	$83090100		;GEM 2.0
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;En entr‚e D0=struct	{
;		le num‚ro de fonction voulu.b
;		nb d'entr‚es int_in.b
;		nb de sortie int_out.b
;		nb d'entr‚es addr_in.b
;		}
;En sortie: D0=int_out[0] r‚sultat de fonction
;	CCR selon D0
;
AES	movem.l	d1-a6,-(sp)	;
	lea	control,a0		;
	clr.l	(a0)+		;S‚curit‚: clear le tableau
	clr.l	(a0)+		;avant usage
	clr.w	(a0)		;
	movep.l	d0,-7(a0)		;Remplie avec le descripteur
	rol.l	#8,d0		;r‚cupŠre No de fonction
	cmpi.b	#112,d0		;rsrc_gaddr ?
	beq.s	.aes_out		;oui
	cmpi.b	#125,d0		;shel_envrn ?
	bne.s	.aes_go		;non
.aes_out	addq.w	#1,(a0)		;addr_out contient 1 pointeur
.aes_go	move.w	#$c8,d0		;
	move.l	#AESPB,d1		;
	trap	#2		;hop
	moveq	#0,d0		;
	movea.l	AESPB+12(pc),a0	;
	move.w	(a0)+,d0		;valeur de sortie
	movem.l	(sp)+,d1-a6	;
	rts

Call_AES	MACRO
	move.l	#\1,d0
	bsr	AES
	ENDM

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;Boite d'alerte. A0 doit contenir son texte au format:
;	dc.b	bouton_par_d‚faut
;	dc.b	"[1]...",0
;D0 contient le bouton cliqu‚ … la sortie
Form_Alert	move.l	a0,-(sp)		;
	moveq	#0,d0		;R‚cupŠre bouton par d‚faut
	move.b	(a0)+,d0		;
	move.w	d0,int_in		;passe le … l'AES
	move.l	a0,addr_in		;et l'adresse du message
	move.l	#form_alert,d0	;fonction Form_Alert
	bsr.s	AES		;go!
	movea.l	(sp)+,a0		;
	rts			;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;Selecteur de fichiers.
;En entr‚e:	.A0: doit contenir le chemin (+ place du masque)
;		.A1: le masque de recherche pr‚selectionn‚
;		.A2: le nom preselectionn‚ (ou nul)
;		.A3: chaine qui contiendra le nom du fichier complet
;                     .D0: bit 0: 1=actualise Drive&Path / 0=laisser
;		     bit 1: 1=actualise le masque  / 0=laisser
;En sortie:	.Z=1 (BEQ) si erreur ou pas de choix
;
;Attention: faut que les chaines path et mask soient assez longues pour
;que la fonction fonctionne (path est toujours agrandi avec le mask
;fourni en entr‚e, et mask doit supporter son actualisation).
;
FS_SETPATH	equ	1
FS_SETMASK	equ	2
FileSelect	movem.l	d0-d1/a0-a3,-(sp)	;
	tst.b	(a0)+		;Cherche fin du chemin
	bne.s	*-2		;
	subq.l	#1,a0		;
	cmpi.b	#'\',-1(a0)	;Fin de chemin correcte ?
	beq.s	.FSi_0		;
	move.b	#'\',(a0)+		;Non, rajoute l'anti-slash
.FSi_0	move.b	(a1)+,(a0)+	;copie le masque … la suite.
	bne.s	.FSi_0		;

	move.w	#BEG_UPDATE,int_in	;
	move.l	#wind_update,d0	;Important, sinon problŠmes
	bsr	AES		;avec le TOS 4.0x, bcp plus
	move.w	#BEG_MCTRL,int_in	;apparents qu'avec les TOS
	move.l	#wind_update,d0	;pr‚c‚dents.
	bsr	AES		;

	move.l	8(sp),a0		;Reprend chemin, pass‚ avec
	movem.l	a0/a2,addr_in	;le nom par d‚faut.
	move.l	#fsel_input,d0	;
	bsr	AES		;
	move.w	d0,d1		;conserve r‚sultat

	move.w	#END_MCTRL,int_in	;
	move.l	#wind_update,d0	;
	bsr	AES		;
	move.w	#END_UPDATE,int_in	;
	move.l	#wind_update,d0	;
	bsr	AES		;

	move.w	d1,d0		;R‚sultat du fsel_input
	beq	.FSe_end		;Erreur?

.FSe_0	tst.b	(a0)+		;Cherche fin du chemin
	bne.s	.FSe_0		;
.FSe_1	cmpi.b	#'\',-(a0)		;Puis cherche slash de fin
	beq.s	.FSe_2		;de chemin.
	cmpa.l	8(sp),a0		;On a remont‚ la chaine?
	bgt.s	.FSe_1		;Pas encore..
	btst	#1,3(sp)		;Si, masque uniquement.
	beq.s	.FSe_4		;Faut le fixer ?
	movea.l	a0,a2		;
	bra.s	.FSe_3		;Oui, alors vazyraoul.

.FSe_2	btst	#1,3(sp)		;Fixer le nouveau masque ?
	beq.s	.FSe_4		;non..
	movea.l	12(sp),a1		;
	lea	1(a0),a2		;Si, alors recopie-le
.FSe_3	move.b	(a2)+,(a1)+	;
	bne.s	.FSe_3		;

.FSe_4	cmpa.l	8(sp),a0		;Y'avait un chemin ?
	ble.s	*+4		;
	addq.l	#1,a0		;oui, saute le '\'
	clr.b	(a0)		;Marque fin de chemin.

	movea.l	8(sp),a0		;Puis construit le nom complet
	move.b	(a0)+,(a3)+	;
	bne.s	*-2		;
	subq.l	#1,a3		;revient sur le \0
	btst	#0,3(sp)		;Fixer le chemin ?
	beq.s	.FSe_6		;
	movea.l	8(sp),a0		;
	cmpi.b	#':',1(a0)		;Drive pr‚cis‚ ?
	bne.s	.FSe_5		;
	move.b	(a0),d0		;
	andi.b	#~('a'-'A'),d0	;Passe en majuscule,
	subi.b	#'A',d0		;calcul le No de drive,
	ext.w	d0		;
	move.w	d0,-(sp)		;
	move.w	#$0e,-(sp)		;et on le fixe.
	trap	#1		;
	addq.l	#4,sp		;
.FSe_5	move.l	8(sp),-(sp)	;R‚-empile le chemin.
	move.w	#$3b,-(sp)		;
	trap	#1		;et Desetpath
	addq.l	#6,sp		;

.FSe_6	movea.l	16(sp),a1		;maintenant,copie le nom
.FSe_7	move.b	(a1)+,(a3)+	;du fichier … la suite
	bne.s	.FSe_7		;pour composer le tout

.FSe_end	tst.w	int_out+2		;Bouton Cancel?
	movem.l	(sp)+,d0-d1/a0-a3	;finito.C'est simple,
	rts			;non?
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
AESPB	dc.l	control,global,int_in,int_out,addr_in,addr_out
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	SECTION	BSS
;Tableaux du GEM.
control	ds.w	5
global	ds.w	15
int_in	ds.w	16
int_out	ds.w	7
addr_in	ds.l	2
addr_out	ds.l	1
ap_id	ds.w	1
