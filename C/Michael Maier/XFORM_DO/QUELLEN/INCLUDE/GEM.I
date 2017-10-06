* -------------------------------------------------- *
*
*               XFORMDO.LIB Version 1.2
*
*          geschrieben von Michael Maier 1991
*
* -------------------------------------------------- *

* -------------------------------------------------- *
* Headerdatei: GEM.I
* Version: 1.0
* Datum: 14.9.1991
* -------------------------------------------------- *

;
; VDI-Strukturen
;
        SECTION TEXT
        ABSSET  0

fd_addr:        ds.l    1
fd_w:           ds.w    1
fd_h:           ds.w    1
fd_wdwidth:     ds.w    1
fd_stand:       ds.w    1
fd_nplanes:     ds.w    1
fd_res:         ds.w    3
fd_size:        ds.w    1

        ABSSET  0
;
; AES-Strukturen
;

; OBJECT
ob_next:        ds.w    1
ob_head:        ds.w    1
ob_tail:        ds.w    1
ob_type:        ds.w    1
ob_flags:       ds.w    1
ob_state:       ds.w    1
ob_spec:        ds.l    1
ob_x:           ds.w    1
ob_y:           ds.w    1
ob_width:       ds.w    1
ob_height:      ds.w    1
ob_size:        ds.w    1

; Konstanten
G_BOX       EQU         20
G_TEXT      EQU         21
G_BOXTEXT   EQU         22
G_IMAGE     EQU         23
G_USERDEF   EQU         24
G_IBOX      EQU         25
G_BUTTON    EQU         26
G_BOXCHAR   EQU         27
G_STRING    EQU         28
G_FTEXT     EQU         29
G_FBOXTEXT  EQU         30
G_ICON      EQU         31
G_TITLE     EQU         32

SELECTABLE  EQU         $0001
DEFAULT     EQU         $0002
EXIT        EQU         $0004
EDITABLE    EQU         $0008
RBUTTON     EQU         $0010
LASTOB      EQU         $0020
TOUCHEXIT   EQU         $0040
HIDETREE    EQU         $0080
INDIRECT    EQU         $0100
INDDEFAULT  EQU         $0200   Hey, das ist neu!!!

SELECTED    EQU         $0001
CROSSED     EQU         $0002
CHECKED     EQU         $0004
DISABLED    EQU         $0008
OUTLINED    EQU         $0010
SHADOWED    EQU         $0020

        ABSSET  0
; USERBLK
ub_code:        ds.l    1
ub_parm:        ds.l    1
ub_size:        ds.w    1

        ABSSET  0
; ICONBLK
ib_pmask:       ds.l    1
ib_pdata:       ds.l    1
ib_ptext:       ds.l    1
ib_char:        ds.w    1
ib_xchar:       ds.w    1
ib_ychar:       ds.w    1
ib_xicon:       ds.w    1
ib_yicon:       ds.w    1
ib_wicon:       ds.w    1
ib_hicon:       ds.w    1
ib_xtext:       ds.w    1
ib_ytext:       ds.w    1
ib_wtext:       ds.w    1
ib_htext:       ds.w    1
ib_resvd:       ds.w    1
ib_size:        ds.w    1

        ABSSET  0
; BITBLK
bi_pdata:       ds.l    1
bi_wb:          ds.w    1
bi_hl:          ds.w    1
bi_x:           ds.w    1
bi_y:           ds.w    1
bi_color:       ds.w    1
bi_size:        ds.w    1

        ABSSET  0
; TEDINFO
te_ptext:       ds.l    1
te_ptmplt:      ds.l    1
te_pvalid:      ds.l    1
te_font:        ds.w    1
te_resvd1:      ds.w    1
te_just:        ds.w    1
te_color:       ds.w    1
te_resvd2:      ds.w    1
te_thickness:   ds.w    1
te_txtlen:      ds.w    1
te_tmplen:      ds.w    1
te_size:        ds.w    1

IBM         EQU         3
SMALL       EQU         5
TE_LEFT     EQU         0
TE_RIGHT    EQU         1
TE_CNTR     EQU         2

        ABSSET  0
; PARMBLK
pb_tree:        ds.l    1
pb_obj:         ds.w    1
pr_pstate:      ds.w    1
pr_cstate:      ds.w    1
pb_xy:          ds.w    4
pb_clip:        ds.w    4
pb_parm:        ds.l    1
pb_size         ds.w    1

*
* Struktur: DIAINFO
*
        ABSSET  0

di_mfdb:        ds.b    fd_size         ; Hintergrund
di_flag:        ds.w    1               ; Restauration
di_length:      ds.l    1               ; L„nge des Speicherblocks
di_size:        EQU     *

