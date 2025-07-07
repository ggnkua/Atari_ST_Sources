
;*========================================================================
;*
;* AESFAST GEM bindings.
;* Copyright (c) Nov 1988, by Ian Lepore.
;* See full copyright statement in file AES@NOTE.S for details.
;*
;*========================================================================
 
;*************************************************************************
;*
;* GEMFAST.SH - 
;*  Assembler header file for asm programs using GEMFAST bindings.
;*  (Just like GEMFAST.H is for C).
;*************************************************************************
         
;-------------------------------------------------------------------------
; Constants...
;-------------------------------------------------------------------------

G_BOX        = 20                         ; Object types
G_TEXT       = 21
G_BOXTEXT    = 22
G_IMAGE      = 23
G_USERDEF    = 24
G_IBOX       = 25
G_BUTTON     = 26
G_BOXCHAR    = 27
G_STRING     = 28
G_FTEXT      = 29
G_FBOXTEXT   = 30
G_ICON       = 31
G_TITLE      = 32

NONE         = $0000
SELECTABLE   = $0001                 ; Object flags 
DEFAULT      = $0002                 ; (defined as masks for AND/OR)
EXIT         = $0004
EDITABLE     = $0008
RBUTTON      = $0010
LASTOB       = $0020
TOUCHEXIT    = $0040
HIDETREE     = $0080

NORMAL       = $0000
SELECTED     = $0001                 ; Object states
CROSSED      = $0002                 ; (defined as masks for AND/OR)
CHECKED      = $0004
DISABLED     = $0008
OUTLINED     = $0010
SHADOWED     = $0020
 
BSELECTABLE  = 0 ; $0001               ; Object flags 
BDEFAULT     = 1 ; $0002               ; (defined as bit numbers for BTST)
BEXIT        = 2 ; $0004
BEDITABLE    = 3 ; $0008
BRBUTTON     = 4 ; $0010
BLASTOB      = 5 ; $0020
BTOUCHEXIT   = 6 ; $0040
BHIDETREE    = 7 ; $0080

BSELECTED    = 0 ; $0001               ; Object states
BCROSSED     = 1 ; $0002               ; (defined as bit numbers for BTST)
BCHECKED     = 2 ; $0004
BDISABLED    = 3 ; $0008
BOUTLINED    = 4 ; $0010
BSHADOWED    = 5 ; $0020
                                        ; form_dial commands...
FMD_START    = 0
FMD_GROW     = 1
FMD_SHRINK   = 2
FMD_FINISH   = 3
                                        ; objc_draw stuff...
MAX_DEPTH    = 8
R_TREE       = 0
                                        ; evnt_multi events...
MU_KEYBD     = $0001                   ; (defined as masks for AND/OR)
MU_BUTTON    = $0002
MU_M1        = $0004
MU_M2        = $0008
MU_MESAG     = $0010
MU_TIMER     = $0020
                                        ; keyboard states 
K_RSHIFT     = $0001                   ; (defined as masks for AND/OR)
K_LSHIFT     = $0002
K_CTRL       = $0004
K_ALT        = $0008
                                        ; event message values 
MN_SELECTED  = 10
WM_REDRAW    = 20
WM_TOPPED    = 21
WM_CLOSED    = 22
WM_FULLED    = 23
WM_ARROWED   = 24
WM_HSLID     = 25
WM_VSLID     = 26
WM_SIZED     = 27
WM_MOVED     = 28
WM_NEWTOP    = 29
AC_OPEN      = 40
AC_CLOSE     = 41

                                        ; Window Attributes 
NAME         = $0001                    ; (defined as masks for AND/OR)
CLOSER       = $0002
FULLER       = $0004
MOVER        = $0008
INFO         = $0010
SIZER        = $0020
UPARROW      = $0040
DNARROW      = $0080
VSLIDE       = $0100
LFARROW      = $0200
RTARROW      = $0400
HSLIDE       = $0800
                                        ; wind_create flags 
WC_BORDER    = 0                        
WC_WORK      = 1
                                        ; wind_get flags 
WF_KIND      = 1
WF_NAME      = 2
WF_INFO      = 3
WF_WORKXYWH  = 4
WF_CURRXYWH  = 5
WF_PREVXYWH  = 6
WF_FULLXYWH  = 7
WF_HSLIDE    = 8
WF_VSLIDE    = 9
WF_TOP       = 10
WF_FIRSTXYWH = 11
WF_NEXTXYWH  = 12
WF_RESVD     = 13
WF_NEWDESK   = 14
WF_HSLSIZE   = 15
WF_VSLSIZE   = 16
WF_SCREEN    = 17
                                        ; wind_update flags 
END_UPDATE  = 0
BEG_UPDATE  = 1
END_MCTRL   = 2
BEG_MCTRL   = 3
                                        ; graf_mouse mouse types
ARROW       = 0
BEE         = 2
TEXT_CRSR   = 1
HOURGLASS   = 2
POINT_HAND  = 3
FLAT_HAND   = 4
THIN_CROSS  = 5
THICK_CROSS = 6
OUTLN_CROSS = 7
USER_DEF    = 255
M_OFF       = 256
M_ON        = 257
                                        ; inside fill patterns  
IP_HOLLOW   = 0
IP_1PATT    = 1
IP_2PATT    = 2
IP_3PATT    = 3
IP_4PATT    = 4
IP_5PATT    = 5
IP_6PATT    = 6
IP_SOLID    = 7
                                        ; normal graphics drawing modes 
MD_REPLACE  = 1
MD_TRANS    = 2
MD_XOR      = 3
MD_ERASE    = 4
                                        ; bit blt rules 
ALL_WHITE   = 0
S_AND_D     = 1
S_AND_NOTD  = 2
S_ONLY      = 3
NOTS_AND_D  = 4
D_ONLY      = 5
S_XOR_D     = 6
S_OR_D      = 7
NOT_SORD    = 8
NOT_SXORD   = 9
D_INVERT    = 10
NOT_D       = 10
S_OR_NOTD   = 11
NOT_S       = 12
NOTS_OR_D   = 13
NOT_SANDD   = 14
ALL_BLACK   = 15


                                        ; editable text field definitions 
EDSTART     = 0
EDINIT      = 1
EDCHAR      = 2
EDEND       = 3
                                        ; editable text justification 
TE_LEFT     = 0
TE_RIGHT    = 1
TE_CNTR     = 2

;-------------------------------------------------------------------------
; Define some commonly-used structures as offsets.
;-------------------------------------------------------------------------

          .abs                          ; GRECT - graphics rectangle.
g_x:      ds.w 1
g_y:      ds.w 1
g_w:      ds.w 1
g_h:      ds.w 1

          .abs                          ; VRECT - VDI rectangle.
v_x1:     ds.w 1
v_y1:     ds.w 1
v_x2:     ds.w 1
v_y2:     ds.w 1

          .abs                          ; OBJECT
ob_next:  ds.w 1
ob_head:  ds.w 1
ob_tail:  ds.w 1
ob_type:  ds.w 1
ob_flags: ds.w 1
ob_state: ds.w 1
ob_spec:  ds.l 1
ob_x:     ds.w 1
ob_y:     ds.w 1
ob_w:     ds.w 1
ob_h:     ds.w 1
OBJ_SIZ   =         *

             .abs                       ; TEDINFO
te_ptext:    ds.l      1                ; ptr to text             
te_ptmplt:   ds.l      1                ; ptr to template                   
te_pvalid:   ds.l      1                ; ptr to validation chrs. 
te_font:     ds.w      1                ; font                              
te_junk1:    ds.w      1                ; junk word               
te_just:     ds.w      1                ; justification                     
te_color:    ds.w      1                ; color information word  
te_junk2:    ds.w      1                ; junk word               
te_thickness:ds.w      1                ; border thickness        
te_txtlen:   ds.w      1                ; length of text string   
te_tmplen:   ds.w      1                ; length of template string
TEDINF_SIZ   =    *

;-------------------------------------------------------------------------
; Macros...
; Caveat:
;  This stuff is not currently supported as part of the GEMFAST bindings
;  system, but I have code which relies on these macros being in this
;  file, so I'm leaving it in.  For the curious, these macros are the
;  bare beginnings of a system to make it easier to program AES stuff
;  in assembler.  The current macros are involved with building resource
;  trees in source code.  Puzzling out how to use them is left as an
;  exercise for the reader <snicker>.
;            - Ian
;-------------------------------------------------------------------------

.macro    Teddef ptext,ptmpl,pvalid,font,rsvd1,just,color,rsvd2,thick,textlen,tmpllen
          dc.l      \ptext,\ptmpl,\pvalid
          dc.w      \font,\rsvd1,\just,\color
          dc.w      \rsvd2,\thick,\textlen,\tmpllen
.endm

.macro    Treedef datatype
          .\datatype
TR$OBJ$IDX   set 0
TR$OBJ$INIT  set (^^streq \datatype,"text") | (^^streq \datatype,"data") 
.endm

.macro    Objdef objidx,next,head,tail,type,flags,state,spec,x,y,w,h
          .iif \?objidx, \objidx = TR$OBJ$IDX
          .if  TR$OBJ$INIT
          dc.w      \next,\head,\tail
          dc.w      \type,\flags,\state
          dc.l      \spec
          dc.w      \x,\y,\w,\h
          .else
          ds.b      OBJ_SIZ
          .endif
TR$OBJ$IDX set TR$OBJ$IDX+1
.endm

.macro    Objptr tree,objidx,areg
          lea    [OBJ_SIZ * \objidx]+\tree,\areg
.endm


          .text
          
