	rsreset		; Structure du tableau 'global' du GEM
_AESversion:	rs.w 1
_AESnumapps:	rs.w 1
_AESapid:		rs.w 1
_AESappglobal:	rs.l 1
_AESrscfile:	rs.l 1	; debut ressource
		rs.l 1	; debut fichier rsc
		rs.w 1	; longueur fichier ressource
		rs.w 1
_AESmaxchar:	rs.w 1
_AESminchar:	rs.w 1

	rsreset		; Structure OBJECT
ob_next:		rs.w 1
ob_head:		rs.w 1
ob_tail:		rs.w 1
ob_type:		rs.w 1
ob_flags:		rs.w 1
ob_state:		rs.w 1
ob_spec:		rs.l 1	; pointe TEDINFO ou BITBLK ou ...
ob_x:		rs.w 1
ob_y:		rs.w 1
ob_width:		rs.w 1
ob_height:		rs.w 1
L_OBJECT:		rs.w 0

	rsreset		; Structure TEDINFO
te_ptext:		rs.l 1
te_ptmplt:		rs.l 1
te_pvalid:		rs.l 1
te_font:		rs.w 1
te_junkl:		rs.w 1
te_just:		rs.w 1
te_color:		rs.w 1
te_junk2:		rs.w 1
te_thickness:	rs.w 1
te_txtlen:		rs.w 1
te_tmplen:		rs.w 1
L_TEDINFO:		rs.w 0

	rsreset		; Structure BITBLK
bi_pdata:		rs.l 1
bi_wb:		rs.w 1
bi_hl:		rs.w 1
bi_x:		rs.w 1
bi_y:		rs.w 1
bi_color:		rs.w 1
L_BITBLK:		rs.w 0

	rsreset		; Structure ICONBLK
ib_pmask:		rs.l 1
ib_pdata:		rs.l 1
ib_ptext:		rs.l 1
ib_char:		rs.w 1
ib_xchar:		rs.w 1
ib_ychar:		rs.w 1
ib_xicon:		rs.w 1
ib_yicon:		rs.w 1
ib_wicon:		rs.w 1
ib_hicon:		rs.w 1
ib_xtext:		rs.w 1
ib_ytext:		rs.w 1
ib_wtext:		rs.w 1
ib_htext:		rs.w 1
L_ICONBLK:		rs.w 0

	rsreset		; Structure CICONBLK
monoblk:		rs.b L_ICONBLK
mainlist:		rs.l 1	; *CICON
L_CICONBLK:		rs.w 0

	rsreset		; Structure CICON
num_planes:		rs.w 1
col_data:		rs.l 1
col_mask:		rs.l 1
sel_data:		rs.l 1
sel_mask:		rs.l 1
next_res:		rs.l 1	; *CICON suivante
L_CICON:		rs.w 0

	rsreset		; Structure APPLBLK
ab_code:		rs.l 1
ab_param:		rs.l 1
L_APPLBLK:		rs.w 0

	rsreset		; Structure MENU
mn_tree:		rs.l 1
mn_menu:		rs.w 1
mn_item:		rs.w 1
mn_scroll:		rs.w 1
mn_keystate:	rs.w 1
LONG_STRUC_MENU:	rs.w 0

	rsreset		; Structure RSC-FILE
rsh_vrsn:		rs.w 1
rsh_object:		rs.w 1
rsh_tedinfo:	rs.w 1	; 1
rsh_iconblk:	rs.w 1	: 2
rsh_bitblk:		rs.w 1	; 3
rsh_frstr:		rs.w 1	;
rsh_string:		rs.w 1
rsh_imdata:		rs.w 1
rsh_frimg:		rs.w 1	;
rsh_trindex:	rs.w 1	;
rsh_nobs:		rs.w 1
rsh_ntree:		rs.w 1	;
rsh_nted:		rs.w 1	; 1
rsh_nib:		rs.w 1	; 2
rsh_nbb:		rs.w 1	; 3
rsh_nstring:	rs.w 1
rsh_nimages:	rs.w 1
rsh_rssize:		rs.w 1	;
L_RSC_HEADER:	rs.w 0
