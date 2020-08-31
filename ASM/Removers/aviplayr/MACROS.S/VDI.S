**************
* Macros VDI *
**************


********************************
* Structures de donn‚es

MFDB		rsstruct
fd_addr		rs.l	1	; adresse m‚moire (NULL = ‚cran courant)
fd_width	rs.w	1	; largeur en pixels de la zone
fd_height	rs.w	1	; hauteur en pixels de la zone
fd_wdwidth	rs.w	1	; largeur en mots de la zone (fdwisth +15)/16
fd_stand	rs.w	1	; format (0 = sp‚cifique au p‚riph‚rique, 1 = format VDI)
fd_planes	rs.w	1	; nombre de plans
reserved1	rs.w	1	; \
reserved2	rs.w	1	; | (mettre … 0)
reserved3	rs.w	1	; /
sizeof		rs	0
		rsend

********************************

; Sauf indications contraires, les tableaux pouvant contenir un nombre
; variables de donn‚es ( int_in,PTSIN ) devront ˆtre remplis avant l'appel
; … la macro

* Routine pour appeler le VDI et renvoyer int_out(0) dans D0
	bra.s	end_vdi_call
vdi_call:
	move.l	d1,-(sp)
	move.l	#vdi_table,d1
	moveq	#115,d0
	trap	#2
	move.l	(sp)+,d1
	move.w	int_out,d0
	rts
end_vdi_call
********************************
	DATA
vdi_table
	dc.l	control,int_in,ptsin,int_out,ptsout
********************************
	BSS
control
	ds.w	12
int_in
	ds.w	128
int_out
	ds.w	128
ptsin
	ds.w	512
ptsout
	ds.w	128
********************************
	TEXT

* Macro pour remplir control[] et appeler la VDI
Call_vdi	macro
	IFC	'\1','#0'
	clr.w	control
	ELSE
	move.w	\1,control
	ENDC

	IFC	'\2','#0'
	clr.w	control+2
	ELSE
	move.w	\2,control+2
	ENDC

	IF	\?3
	IFC	'\3','#0'
	clr.w	control+4
	ELSE
	move.w	\3,control+4
	ENDC
	ELSE
	clr.w	control+4
	ENDIF

	IFC	'\4','#0'
	clr.w	control+6
	ELSE
	move.w	\4,control+6
	ENDC

	IF	\?5
	IFC	'\5','#0'
	clr.w	control+8
	ELSE
	move.w	\5,control+8
	ENDC
	ELSE
	clr.w	control+8
	ENDIF

	IF	\?6
	IFC	'\6','#0'
	clr.w	control+10
	ELSE
	move.w	\6,control+10
	ENDC
	ELSE
	clr.w	control+10
	ENDIF

	IF	\?7
	IFC	'\7','#0'
	clr.w	control+12
	ELSE
	move.w	\7,control+12
	ENDC
	ELSE
	clr.w	control+12
	ENDIF

	bsr	vdi_call
	endm

********************************
* Les macros VDI d‚butent ici !!
Vq_vgdos	macro
	move.w	#-2,d0
	trap	#2
	endm
	
V_set_app_buff	macro
	move.l	\1,int_in
	move.w	\2,int_in+4
	Call_vdi	#-1,#0,#0,#3,#0
	endm
	
V_openwk	macro
	move.w	\1,int_in	; id du p‚riph physique
	move.w	\2,int_in+2	; type de ligne
	move.w	\3,int_in+4	; index de couleur Polyline
	move.w	\4,int_in+6	; type de marqueur
	move.w	\5,int_in+8	; index de couleur Polymarker
	move.w	\6,int_in+10	; fonte de caractŠres
	move.w	\7,int_in+12	; index couleur texte
	move.w	\8,int_in+14	; style de remplissage interieur
	move.w	\9,int_in+16	; index de style de remplissage
	move.w	\A,int_in+18	; index couleur de remplissage
	move.w	\B,int_in+20	; coordonn‚es : 0=NDC (normalised), 2=RC (standard)
	Call_vdi	#1,#0,,#11	; 0 ptsin, 11 int_in.
	endm
	
V_clswk	macro	
	Call_vdi	#2,#0,#0,#0,#0,,\1
	endm
	
V_clrwk	macro
	Call_vdi	#3,#0,#0,#0,#0,,\1
	endm
	
V_updwk	macro
	Call_vdi	#4,#0,#0,#0,#0,,\1
	endm
	
Vq_chcells	macro
	Call_vdi	#5,#0,#0,#0,#2,#1,\1
	endm
	
V_exit_cur	macro
	Call_vdi	#5,#0,#0,#0,#0,#2,\1
	endm
	
V_enter_cur	macro
	Call_vdi	#5,#0,#0,#0,#0,#3,\1
	endm
	
V_curup	macro
	Call_vdi	#5,#0,#0,#0,#0,#4,\1
	endm
	
V_curdown	macro
	Call_vdi	#5,#0,#0,#0,#0,#5,\1
	endm
	
V_curright	macro
	Call_vdi	#5,#0,#0,#0,#0,#6,\1
	endm
	
V_curleft	macro
	Call_vdi	#5,#0,#0,#0,#0,#7,\1
	endm
	
V_curhome	macro
	Call_vdi	#5,#0,#0,#0,#0,#8,\1
	endm

V_eeos	macro
	Call_vdi	#5,#0,#0,#0,#0,#9,\1
	endm
	
V_eeol	macro
	Call_vdi	#5,#0,#0,#0,#0,#10,\1
	endm
	
Vs_curaddress	macro
	move.w	\2,int_in
	move.w	\3,int_in+2
	Call_vdi	#5,#0,#0,#2,#0,#11,\1
	endm
	
Vs_curtext	macro
	FAIL
	Call_vdi	#5,#0,#0,,#0,#12,\1
	endm
	
V_rvon	macro
	Call_vdi	#5,#0,#0,#0,#0,#13,\1
	endm
	
V_rvoff	macro
	Call_vdi	#5,#0,#0,#0,#0,#14,\1
	endm
	
Vq_curaddress	macro
	Call_vdi	#5,#0,#0,#0,#2,#15,\1
	endm
	
Vq_tabstatus	macro
	Call_vdi	#5,#0,#0,#0,#1,#16,\1
	endm
	
V_hardcopy	macro
	Call_vdi	#5,#0,#0,#0,#0,#17,\1
	endm
	
V_dspcur	macro
	move.w	\2,ptsin
	move.w	\3,ptsin+2
	Call_vdi	#5,#1,#0,#0,#0,#18,\1
	endm
	
V_rmcur	macro
	Call_vdi	#5,#0,#0,#0,#0,#19,\1
	endm
	
V_form_adv	macro
	Call_vdi	#5,#0,#0,#0,#0,#20,\1
	endm
	
V_output_window	macro
	move.w	\2,ptsin
	move.w	\3,ptsin+2
	move.w	\4,ptsin+4
	move.w	\5,ptsin+6
	Call_vdi	#5,#2,#0,#0,#0,#21,\1
	endm
	
V_clear_disp_list	macro
	Call_vdi	#5,#0,#0,#0,#0,#22,\1
	endm
	
V_bit_image	macro
	move.w	\3,int_in
	move.w	\4,int_in+2
	move.w	\5,int_in+4
	move.w	\6,int_in+6
	move.w	\7,int_in+8
	move.w	\8,ptsin
	move.w	\9,ptsin+2
	move.w	\A,ptsin+4
	move.w	\B,ptsin+6
	FAIL
	Call_vdi	#5,#2,#0,#5+,#0,#23,\1
	endm

Vq_scan	macro
	Call_vdi	#5,#0,#0,#0,#5,#24,\1
	endm
	
	
	
V_pline	macro
	Call_vdi	#6,\2,#0,#0,#0,,\1
	endm
	
V_bez	macro
	FAIL
	Call_vdi	#6,\2,#2,(\2+1)/2,#6,#13,\1
	endm
	
V_pmarker	macro
	Call_vdi	#7,\2,#0,#0,#0,,\1
	endm

V_gtext	macro
	move.w	\2,ptsin
	move.w	\3,ptsin+2
	FAIL
	endm
	
V_fillarea	macro
	Call_vdi	#9,\2,#0,#0,#0,,\1
	endm
	
V_opnvwk	macro
	IFC	'\1','#0'
	clr.w	int_in
	ELSE
	move.w	\1,int_in	; id du p‚riph physique
	ENDC
	IFC	'\2','#0'
	clr.w	int_in+2
	ELSE
	move.w	\2,int_in+2	; type de ligne
	ENDC
	IFC	'\3','#0'
	clr.w	int_in+4
	ELSE
	move.w	\3,int_in+4	; index de couleur Polyline
	ENDC
	IFC	'\4','#0'
	clr.w	int_in+6
	ELSE
	move.w	\4,int_in+6	; type de marqueur
	ENDC
	IFC	'\5','#0'
	clr.w	int_in+8
	ELSE
	move.w	\5,int_in+8	; index de couleur Polymarker
	ENDC
	IFC	'\6','#0'
	clr.w	int_in+10
	ELSE
	move.w	\6,int_in+10	; fonte de caractŠres
	ENDC
	IFC	'\7','#0'
	clr.w	int_in+12
	ELSE
	move.w	\7,int_in+12	; index couleur texte
	ENDC
	IFC	'\8','#0'
	clr.w	int_in+14
	ELSE
	move.w	\8,int_in+14	; style de remplissage interieur
	ENDC
	IFC	'\9','#0'
	clr.w	int_in+16
	ELSE
	move.w	\9,int_in+16	; index de style de remplissage
	ENDC
	IFC	'\A','#0'
	clr.w	int_in+18
	ELSE
	move.w	\A,int_in+18	; index couleur de remplissage
	ENDC
	IFC	'\B','#0'
	clr.w	int_in+20
	ELSE
	move.w	\B,int_in+20	; coordonn‚es : 0=NDC (normalised), 2=RC (standard)
	ENDC
	; \C est le grf_handle (=1 pour ‚cran physique)
	Call_vdi	#100,#0,,#11,,,\C
	endm

V_clsvwk	macro
	Call_vdi	#101,#0,,#0,,,\1
	endm

Vq_extnd	macro
	; grf_handle,info
	IFC	'\2','#0'
	clr.w	int_in		; info=0 : informations Open Workstation
	ELSE
	move.w	\2,int_in	; info=1 : informations Extended Inquire
	ENDC
	Call_vdi	#102,#0,,#1,,#0,\1
	endm

Vq_scrninfo	macro
	; grf_handle
	; (c'est un vq_extend() avec mode=2 en pr‚sence du cookie 'EdDI')
	move.w	#2,int_in	; informations suppl‚mentaires
	Call_vdi	#102,#0,,#1,,#1,\1
	endm
