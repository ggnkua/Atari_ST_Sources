;----------------------------------------------------------------------------
;File name:	VDIFONT.SH		Revision date:	1996.06.14
;Creator:	Ulf Ronald Andersson	Creation date:	1995.09.25
;Revision:	1.3
;----------------------------------------------------------------------------
;
;	Constant definitions to simplify updates & revisions
;
VF_ver_con	= $2013		;Version & rev of program that makes cookie
VF_ver_con_s	= '_R13'	;Revision constant for dialogs
VF_int_con	= $2011		;Version & rev that defined current interface
VF_cnf_size	= 42		;Size of configuration file (old format)
VF_magic_con	= 'VFnt'	;Magic constant for cookie and XBRA
VF_cnf_con	= 'VF20'	;Magic constant for CNF file header (old format)
;
;The above constants are to be changed by me only (URAn).
;I will only change the first two for normal revision updates,
;but may also add some to cover EG: extended CNF format etc...
;Any cookie changes that causes incompatibility will also update VF_int_con,
;so old tools can recognize that they need to be replaced, and new tools
;can refuse to patch old cookies (since that could bomb system).
;As yet no such update has been made !!!
;
;	Structure definition for VDIFont cookie
;
		rsreset
VF_magic	rs.l	1
VF_version	rs.w	1
VF_interface	rs.w	1
;
VF_inhibit_f	rs.b	1	;flag to disable forcing of system fonts
VF_badcnf_f	rs.b	1	;flags absence of legal CNF data
VF_opnwk_f	rs.b	1	;flags physical workstation initialization
VF_allvwk_f	rs.b	1	;flag to enable forcing of program fonts
VF_MagX_f	rs.b	1	;flags existence of MagX cookie  (set at VDIFONT.PRG start)
VF_partner_f	rs.b	1	;bitmapped flags for presence of div programs
;
VF_MagX_p	rs.l	1	;-> MagX structure, if present, else NULL
;
VF_cnf_buf	rs.b	0	;buffers valid (only) CNF data
VF_cnf_magic	rs.l	1
VF_fnt_id	rs.w	1	;id of font forced upon screen workstations
VF_fnt_height	rs.w	1	;height of that font  (as per VDI vst_height)
VF_fnt_name	rs.b	0
		rs.b	VF_cnf_size-(VF_fnt_name-VF_cnf_buf)
;
VF_cnf_path_p	rs.l	1	;-> CNF path. At boot = '\VDIFONT.CNF'
VF_cnf_path_s	rs.b	256	;Variable CNF path, as set by tools
;
VF_size	rs.b	0		;End of VFnt cookie structure
;
;NB:	Most of the above data should be considerd READ_ONLY,
;	with the notable exceptions below:
;
;VF_inhibit_f	$00/$FF => font is/is_not forced at next screen v_opnwk
;VF_allvwk_f	$FF/$00 => font is/is_not forced at every screen v_opnvwk
;VF_fnt_id	id of font to be used in any future font forcing
;VF_fnt_height	height of font to be used in any future font forcing
;
;NB:	Do NOT alter any data without knowing exactly what you do,
;	since VDIFont considers this data to be pretested and ok.
;	(All supplied tools pretest all data before installing any.)
;
;NB:	NEVER rely on information you have copied from the cookie structure
;	except for the moment as you have read it.  Although many parts
;	of it are static, others are dynamic, so changes are always possible.
;	(This is a good assumption for all cookies, and is never harmful.)
;
;
;	Bit definitions for 'VF_partner_f' byte
;
Gnva_bit	= 0		;flags presence of 'Gnva' cookie (set at v_opnwk)
MiNT_bit	= 1		;flags presence of 'MiNT' cookie (set at v_opnwk)
nAES_bit	= 2		;flags presence of 'nAES' cookie (set at v_opnwk)
;
;NB:	Many partner programs cannot be tested at start of VDIFONT.PRG,
;	since they are started later than it in the \AUTO\ folder.
;	They must, however, be installed before desktop start to function,
;	so at execution of VDI function 'v_opnwk' (for screen device!)
;	all such tests can be made.
;
;
;	Macro definition for cookie creation in VDIFONT.PRG
;
VF_def	MACRO
VF_def_1:
		dc.l	VF_magic_con		;magic
		dc.w	VF_ver_con		;version
		dc.w	VF_int_con		;interface
VF_def_2:
		ds.b	VF_size+VF_def_1-VF_def_2	;rest of structure
		ENDM
;
;----------------------------------------------------------------------------
;End of file:	VDIFONT.SH
;----------------------------------------------------------------------------
