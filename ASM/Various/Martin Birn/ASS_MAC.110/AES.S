;ASS_MAC Version 1.10
;====================
;
;Assembler:     GFA, Version 1.5
;Versionsdatum: 13.10.1990
;
;Macros fÅr:    GEM-AES
;
;(C) 1989,90 by
;Martin Birn, Knoblochstraûe 51, D-7100 Heilbronn
;
;NÑhere Informationen enthÑlt die Datei LIESMICH.DOK.
;-------------------------------------------------------------------------------

;einige Symbole

nil             equ -1        ;1) 2)

mn_selected     equ 10        ;Message-Nummern
wm_redraw       equ 20
wm_topped       equ 21
wm_closed       equ 22
wm_fulled       equ 23
wm_arrowed      equ 24
wm_hslid        equ 25
wm_vslid        equ 26
wm_sized        equ 27
wm_moved        equ 28
wm_newtop       equ 29
wm_untopped     equ 30
ac_open         equ 40
ac_close        equ 41
ct_update       equ 50
ct_move         equ 51
ct_newtop       equ 52

wa_uppage       equ 0         ;WM_ARROWED-Untermeldungen
wa_dnpage       equ 1
wa_upline       equ 2
wa_dnline       equ 3
wa_lfpage       equ 4
wa_rtpage       equ 5
wa_lfline       equ 6
wa_rtline       equ 7

g_box           equ 20        ;Objekte
g_text          equ 21
g_boxtext       equ 22
g_image         equ 23
g_userdef       equ 24
g_ibox          equ 25
g_button        equ 26
g_boxchar       equ 27
g_string        equ 28
g_ftext         equ 29
g_fboxtext      equ 30
g_icon          equ 31
g_title         equ 32

normal          equ $0
selectable      equ $1        ;Flags
default         equ $2
exit            equ $4
editable        equ $8
rbutton         equ $10
lastob          equ $20
touchexit       equ $40
hidetree        equ $80
indirect        equ $100

none            equ 0         ;1) 2)
selected        equ $1        ;Status
crossed         equ $2
checked         equ $4
disabled        equ $8
outlined        equ $10
shadowed        equ $20
draw3d          equ $40
whitebak        equ $80

white           equ 0         ;Farben
black           equ 1
red             equ 2
green           equ 3
blue            equ 4
cyan            equ 5
yellow          equ 6
magenta         equ 7
lwhite          equ 8
lblack          equ 9
lred            equ 10
lgreen          equ 11
lblue           equ 12
lcyan           equ 13
lyellow         equ 14
lmagenta        equ 15

ibm             equ 3         ;Font
small           equ 5

te_left         equ 0         ;Textausrichtung
te_right        equ 1
te_cntr         equ 2
links           equ 0         ;1)
rechts          equ 1         ;1)
zentriert       equ 2         ;1)

ip_hollow       equ 0         ;FÅllmuster
ip_1patt        equ 1
ip_2patt        equ 2
ip_3patt        equ 3
ip_4patt        equ 4
ip_5patt        equ 5
ip_6patt        equ 6
ip_solid        equ 7
hohl            equ 0         ;1)
massiv          equ 7         ;1)
transparent     equ 0         ;1) Textmodus
deckend         equ 1         ;1)
ohne            equ 0         ;1) Rahmen (fÅr OB_SPEC)

k_rshift        equ $1        ;Tastencodes
k_lshift        equ $2
k_ctrl          equ $4
k_alt           equ $8

mu_keybd        equ $1        ;Ereignisse
mu_button       equ $2
mu_m1           equ $4
mu_m2           equ $8
mu_mesag        equ $10
mu_timer        equ $20

ed_start        equ 0         ;OBJC_EDIT-Unterfunktionen
ed_init         equ 1
ed_char         equ 2
ed_end          equ 3

fmd_start       equ 0         ;FORM_DIAL-Unterfunktionen
fmd_grow        equ 1         ;nicht bei GEM 2.0
fmd_shrink      equ 2         ;nicht bei GEM 2.0
fmd_finish      equ 3

no_icon         equ 0         ;Icons bei FORM_ALERT
note            equ 1
wait            equ 2
sstop           equ 3         ;stop wird als Opcode interpretiert

arrow           equ 0         ;Mausformen
text_crsr       equ 1
hourglass       equ 2         ;bei GEM 2.0
busybee         equ 2
point_hand      equ 3
flat_hand       equ 4
thin_cross      equ 5
thick_cross     equ 6
outl_cross      equ 7
user_def        equ 255
m_off           equ 256
m_on            equ 257

name            equ $1        ;Fensterkomponenten
close           equ $2
full            equ $4
mmove           equ $8        ;move geht nicht!
info            equ $10
size            equ $20
uparrow         equ $40
dnarrow         equ $80
vslide          equ $100
lfarrow         equ $200
rtarrow         equ $400
hslide          equ $800
hotclosebox     equ $1000     ;nur bei GEM 2.0

wf_resvd        equ 1         ;WIND_GET-Unterfunktioen
wf_workxywh     equ 4
wf_currxywh     equ 5
wf_prevxywh     equ 6
wf_fullxywh     equ 7
wf_hslide       equ 8
wf_vslide       equ 9
wf_top          equ 10
wf_firstxywh    equ 11
wf_nextxywh     equ 12
wf_resvd2       equ 13
wf_hslsize      equ 15
wf_vslsize      equ 16
wf_screen       equ 17
wf_wxywh        equ 4         ;neue Bezeichnungen
wf_cxywh        equ 5
wf_pxywh        equ 6
wf_fxywh        equ 7

wf_name         equ 2         ;WIND_SET-Unterfunktionen
wf_info         equ 3
wf_newdesk      equ 14
wf_tattrb       equ 18        ;ab GEM 2.0
ef_siztop       equ 19        ;ab GEM 2.0

end_update      equ 0         ;WIND_UPDATE-Funktionsnummern
beg_update      equ 1
end_mctrl       equ 2
beg_mctrl       equ 3

wc_border       equ 0         ;WIND_CALC-Modi
wc_work         equ 1

r_tree          equ 0         ;Typen fÅr RSRC_GADDR bzw. RSRC_SADDR
r_object        equ 1
r_tedinfo       equ 2
r_iconblk       equ 3
r_bitblk        equ 4
r_string        equ 5
r_imagedata     equ 6
r_obspec        equ 7
r_teptext       equ 8
r_teptmplt      equ 9
r_tepvalid      equ 10
r_ibpmask       equ 11
r_ibpdata       equ 12
r_ibptext       equ 13
r_bipdata       equ 14
r_frstr         equ 15
r_frimg         equ 16

                .BSS 

;
;AES-Parameterblock
;
control:        .DS.w 5
global:         .DS.w 3
                .DS.l 6
int_in:         .DS.w 16
int_out:        .DS.w 7
addr_in:        .DS.l 3
addr_out:       .DS.l 1

                .DATA 

aespb:          .DC.l control,global,int_in,int_out,addr_in,addr_out

                .TEXT 

;
;Hilfsmacro
;

                .MACRO AES opcode,c1,c2,c3
                move.l        #(\opcode<<24)|(\c1<<16)|(\c2<<8)|\c3,d1
                jsr           aestrap
                .ENDM 

;
;Funktionen
;

                .MACRO APPL_INIT
                AES           10,0,1,0
                .ENDM 

                .MACRO APPL_READ ap_rid,ap_rlength,ap_rbuff
                lea.l         int_in,a0
                move.w        \ap_rid,(a0)+
                move.w        \ap_rlength,(a0)
                move.l        \ap_rbuff,addr_in
                AES           11,2,1,1
                .ENDM 

                .MACRO APPL_WRITE ap_wid,ap_wlength,ap_wpbuff
                lea.l         int_in,a0
                move.w        \ap_wid,(a0)+
                move.w        \ap_wlength,(a0)
                move.l        \ap_wpbuff,addr_in
                AES           12,2,1,1
                .ENDM 

                .MACRO APPL_FIND ap_fpname
                move.l        \ap_fpname,addr_in
                AES           13,0,1,1
                .ENDM 

                .MACRO APPL_TPLAY ap_tpmem,ap_tpnum,ap_tpscale
                lea.l         int_in,a0
                move.w        \ap_tpnum,(a0)+
                move.w        \ap_tpscale,(a0)
                move.l        \ap_tpmem,addr_in
                AES           14,2,1,1
                .ENDM 

                .MACRO APPL_TRECORD ap_trmem,ap_trcount
                move.w        \ap_trcount,int_in
                move.l        \ap_trmem,addr_in
                AES           15,1,1,1
                .ENDM 

                .MACRO APPL_BVSET ap_bvdisk,ap_bvhard       ;erst ab GEM 2.0!
                lea.l         int_in,a0
                move.w        \ap_bvdisk,(a0)+
                move.w        \ap_bvhard,(a0)
                AES           16,2,1,0
                .ENDM 

                .MACRO APPL_YIELD       ;erst ab GEM 2.0!
                AES           17,0,1,0
                .ENDM 

                .MACRO APPL_EXIT
                AES           19,0,1,0
                .ENDM 

                .MACRO EVNT_KEYBD
                AES           20,0,1,0
                .ENDM 

                .MACRO EVNT_BUTTON ev_bclicks,ev_bmask,ev_bstate
                lea.l         int_in,a0
                move.w        \ev_bclicks,(a0)+
                move.w        \ev_bmask,(a0)+
                move.w        \ev_bstate,(a0)
                AES           21,3,5,0
                .ENDM 

                .MACRO EVNT_MOUSE ev_moflags,ev_mox,ev_moy,ev_mowidth,ev_moheight
                lea.l         int_in,a0
                move.w        \ev_moflags,(a0)+
                move.w        \ev_mox,(a0)+
                move.w        \ev_moy,(a0)+
                move.w        \ev_mowidth,(a0)+
                move.w        \ev_moheight,(a0)
                AES           22,5,5,0
                .ENDM 

                .MACRO EVNT_MESAG ev_mgpbuff
                move.l        \ev_mgpbuff,addr_in
                AES           23,0,1,1
                .ENDM 

                .MACRO EVNT_TIMER ev_tlocount,ev_thicount
                .IF \?ev_thicount       ;normal Åbergeben
                lea.l         int_in,a0
                move.w        \ev_tlocount,(a0)+
                move.w        \ev_thicount,(a0)
                .ELSE         ;Langwort Åbergeben (im INTEL-FORMAT!)
                move.l        \ev_tlocount,int_in
                .ENDIF 
                AES           24,2,1,0
                .ENDM 

;ACHTUNG!
;Da der GfA-Assembler maximal 16 öbergabeparameter verarbeiten kann und
;EVNT_MULTI 17 Parameter hat, muû anstatt der letzten beiden Worte ein
;LANGWORT Åbergeben werden (im INTEL-FORMAT!). Dies dÅrfte normalerweise
;eh einfacher sein.

                .MACRO EVNT_MULTI ev_mflags,ev_mbclicks,ev_mbmask,ev_mbstate,ev_mm1flags,ev_mm1x,ev_mm1y,ev_mm1width,ev_mm1height,ev_mm2flags,ev_mm2x,ev_mm2y,ev_mm2width,ev_mm2height,ev_mmgpbuff,ev_mtcount
                lea.l         int_in,a0
                move.w        \ev_mflags,(a0)+
                .IIF \?ev_mbclicks,     move.w    \ev_mbclicks,(a0)+
                .IIF \?ev_mbmask,       move.w    \ev_mbmask,(a0)+
                .IIF \?ev_mbstate,      move.w    \ev_mbstate,(a0)+
                .IIF \?ev_mm1flags,     move.w    \ev_mm1flags,(a0)+
                .IIF \?ev_mm1x,         move.w    \ev_mm1x,(a0)+
                .IIF \?ev_mm1y,         move.w    \ev_mm1y,(a0)+
                .IIF \?ev_mm1width,     move.w    \ev_mm1width,(a0)+
                .IIF \?ev_mm1height,    move.w    \ev_mm1height,(a0)+
                .IIF \?ev_mm2flags,     move.w    \ev_mm2flags,(a0)+
                .IIF \?ev_mm2x,         move.w    \ev_mm2x,(a0)+
                .IIF \?ev_mm2y,         move.w    \ev_mm2y,(a0)+
                .IIF \?ev_mm2width,     move.w    \ev_mm2width,(a0)+
                .IIF \?ev_mm2height,    move.w    \ev_mm2height,(a0)+
                .IIF \?ev_mtcount,      move.l    \ev_mtcount,(a0)
                move.l        \ev_mmgpbuff,addr_in
                AES           25,16,7,1
                .ENDM 

                .MACRO EVNT_DCLICK ev_dnew,ev_dgetset
                lea.l         int_in,a0
                move.w        \ev_dnew,(a0)+
                move.w        \ev_dgetset,(a0)
                AES           26,2,1,0
                .ENDM 

                .MACRO EVNT_DCLICKS ev_dnew,ev_dgetset      ;das gleiche mit der
                lea.l         int_in,a0 ;                    alten Bezeichnung
                move.w        \ev_dnew,(a0)+
                move.w        \ev_dgetset,(a0)
                AES           26,2,1,0
                .ENDM 

                .MACRO MENU_BAR me_btree,me_bshow
                move.w        \me_bshow,int_in
                move.l        \me_btree,addr_in
                AES           30,1,1,1
                .ENDM 

                .MACRO MENU_ICHECK me_ctree,me_citem,me_ccheck
                lea.l         int_in,a0
                move.w        \me_citem,(a0)+
                move.w        \me_ccheck,(a0)
                move.l        \me_ctree,addr_in
                AES           31,2,1,1
                .ENDM 

                .MACRO MENU_IENABLE me_etree,me_eitem,me_eenable
                lea.l         int_in,a0
                move.w        \me_eitem,(a0)+
                move.w        \me_eenable,(a0)
                move.l        \me_etree,addr_in
                AES           32,2,1,1
                .ENDM 

                .MACRO MENU_TNORMAL me_ntree,me_ntitle,me_nnormal
                lea.l         int_in,a0
                move.w        \me_ntitle,(a0)+
                move.w        \me_nnormal,(a0)
                move.l        \me_ntree,addr_in
                AES           33,2,1,1
                .ENDM 

                .MACRO MENU_TEXT me_ttree,me_titem,me_ttext
                move.w        \me_titem,int_in
                lea.l         addr_in,a0
                move.l        \me_ttree,(a0)+
                move.l        \me_ttext,(a0)
                AES           34,1,1,2
                .ENDM 

                .MACRO MENU_REGISTER me_rapid,me_rpstring
                move.w        \me_rapid,int_in
                move.l        \me_rpstring,addr_in
                AES           35,1,1,1
                .ENDM 

                .MACRO MENU_UNREGISTER me_uapid   ;erst ab GEM 2.0!
                move.w        \me_uapid,int_in
                AES           36,1,1,0
                .ENDM 

                .MACRO OBJC_ADD ob_atree,ob_aparent,ob_achild
                lea.l         int_in,a0
                move.w        \ob_aparent,(a0)+
                move.w        \ob_achild,(a0)
                move.l        \ob_atree,addr_in
                AES           40,1,2,1
                .ENDM 

                .MACRO OBJC_DELETE ob_dltree,ob_dlobject
                move.w        \ob_dlobject,int_in
                move.l        \ob_dltree,addr_in
                AES           41,1,1,1
                .ENDM 

                .MACRO OBJC_DRAW ob_drtree,ob_drstartob,ob_drdepth,ob_drxclip,ob_dryclip,ob_drwclip,ob_drhclip
                lea.l         int_in,a0
                move.w        \ob_drstartob,(a0)+
                move.w        \ob_drdepth,(a0)+
                move.w        \ob_drxclip,(a0)+
                move.w        \ob_dryclip,(a0)+
                move.w        \ob_drwclip,(a0)+
                move.w        \ob_drhclip,(a0)
                move.l        \ob_drtree,addr_in
                AES           42,6,1,1
                .ENDM 

                .MACRO OBJC_FIND ob_ftree,ob_fstartob,ob_fdepth,ob_fmx,ob_fmy
                lea.l         int_in,a0
                move.w        \ob_fstartob,(a0)+
                move.w        \ob_fdepth,(a0)+
                move.w        \ob_fmx,(a0)+
                move.w        \ob_fmy,(a0)
                move.l        \ob_ftree,addr_in
                AES           43,4,1,1
                .ENDM 

                .MACRO OBJC_OFFSET ob_oftree,ob_ofobject
                move.w        \ob_ofobject,int_in
                move.l        \ob_oftree,addr_in
                AES           44,1,3,1
                .ENDM 

                .MACRO OBJC_ORDER ob_ortree,ob_orobject,ob_ornewpos
                lea.l         int_in,a0
                move.w        \ob_orobject,(a0)+
                move.w        \ob_ornewpos,(a0)
                move.l        \ob_ortree,addr_in
                AES           45,2,1,1
                .ENDM 

                .MACRO OBJC_EDIT ob_edtree,ob_edobject,ob_edchar,ob_edidx,ob_edkind
                lea.l         int_in,a0
                move.w        \ob_edobject,(a0)+
                move.w        \ob_edchar,(a0)+
                move.w        \ob_edidx,(a0)+
                move.w        \ob_edkind,(a0)
                move.l        \ob_edtree,addr_in
                AES           46,4,21
                .ENDM 

                .MACRO OBJC_CHANGE ob_ctree,ob_cobject,ob_cresvd,ob_cxclip,ob_cyclip,ob_cwclip,ob_chclip,ob_cnewstate,ob_credraw
                lea.l         int_in,a0
                move.w        \ob_cobject,(a0)+
                .IF \#=9      ;falls res. Wort Åbergeben wurde
                .IF \?ob_cresvd
                move.w        \ob_cresvd,(a0)+
                .ELSE 
                clr.w         (a0)+
                .ENDIF 
                .IIF \?ob_cxclip,       move.w    \ob_cxclip,(a0)+
                .IIF \?ob_cyclip,       move.w    \ob_cyclip,(a0)+
                .IIF \?ob_cwclip,       move.w    \ob_cwclip,(a0)+
                .IIF \?ob_chclip,       move.w    \ob_chclip,(a0)+
                move.w        \ob_cnewstate,(a0)+
                move.w        \ob_credraw,(a0)
                .ELSE         ;falls nicht
                clr.w         (a0)+
                .IIF \?3,     move.w    \3,(a0)+
                .IIF \?4,     move.w    \4,(a0)+
                .IIF \?5,     move.w    \5,(a0)+
                .IIF \?6,     move.w    \6,(a0)+
                move.w        \7,(a0)+
                move.w        \8,(a0)+
                .ENDIF 
                move.l        \ob_ctree,addr_in
                AES           47,8,1,1
                .ENDM 

                .MACRO FORM_DO fo_dotree,fo_dostartob
                move.w        \fo_dostartob,int_in
                move.l        \fo_dotree,addr_in
                AES           50,1,1,1
                .ENDM 

;ACHTUNG BEI FORM_DIAL!
;Die Unterfunktionen 1 und 2 (wachsende/schrumpfende Rechtecke zeichnen)
;sind ab GEM 2.0 nicht mehr verfÅgbar. Statt dessen sollte die XGRF-Bibliothek
;verwendet werden.

                .MACRO FORM_DIAL fo_diflag,fo_dilittlx,fo_dilittly,fo_dilittlw,fo_dilittlh,fo_dibigx,fo_dibigy,fo_dibigw,fo_dibigh
                lea.l         int_in,a0
                move.w        \fo_diflag,(a0)+
                move.w        \fo_dilittlx,(a0)+
                move.w        \fo_dilittly,(a0)+
                move.w        \fo_dilittlw,(a0)+
                move.w        \fo_dilittlh,(a0)+
                move.w        \fo_dibigx,(a0)+
                move.w        \fo_dibigy,(a0)+
                move.w        \fo_dibigw,(a0)+
                move.w        \fo_dibigh,(a0)
                AES           51,9,1,0
                .ENDM 

                .MACRO FORM_ALERT fo_adefbttn,fo_astring
                move.w        \fo_adefbttn,int_in
                move.l        \fo_astring,addr_in
                AES           52,1,1,1
                .ENDM 

                .MACRO FORM_ERROR fo_enum
                move.w        \fo_enum,int_in
                AES           53,1,1,0
                .ENDM 

                .MACRO FORM_CENTER fo_ctree
                move.l        \fo_ctree,addr_in
                AES           54,0,5,1
                .ENDM 

                .MACRO FORM_KEYBD fo_ktree,fo_kobject,fo_kobnext,fo_kchar
                lea.l         int_in,a0
                move.w        fo_kobject,(a0)+
                move.w        fo_kchar,(a0)+
                move.w        fo_kobnext,(a0)
                move.l        fo_ktree,addr_in
                AES           55,3,3,1
                .ENDM 

                .MACRO FORM_BUTTON fo_btree,fo_bobject,fo_bclicks
                lea.l         int_in,a0
                move.w        fo_bobject,(a0)+
                move.w        fo_bclicks,(a0)
                move.l        fo_btree,addr_in
                AES           56,2,2,1
                .ENDM 

                .MACRO GRAF_RUBBERBOX gr_rx,gr_ry,gr_rminwidth,gr_rminheight
                lea.l         int_in,a0
                move.w        \gr_rx,(a0)+
                move.w        \gr_ry,(a0)+
                move.w        \gr_rminwidth,(a0)+
                move.w        \gr_rminheight,(a0)
                AES           70,4,3,0
                .ENDM 

                .MACRO GRAF_RUBBOX gr_rx,gr_ry,gr_rminwidth,gr_rminheight
                lea.l         int_in,a0 ;unter einem neuen Namen
                move.w        \gr_rx,(a0)+
                move.w        \gr_ry,(a0)+
                move.w        \gr_rminwidth,(a0)+
                move.w        \gr_rminheight,(a0)
                AES           70,4,3,0
                .ENDM 

                .MACRO GRAF_RBOX gr_rx,gr_ry,gr_rminwidth,gr_rminheight
                lea.l         int_in,a0 ;ebenso
                move.w        \gr_rx,(a0)+
                move.w        \gr_ry,(a0)+
                move.w        \gr_rminwidth,(a0)+
                move.w        \gr_rminheight,(a0)
                AES           70,4,3,0
                .ENDM 

                .MACRO GRAF_DRAGBOX gr_dwidth,gr_dheight,gr_dstartx,gr_dstarty,gr_dboundx,gr_dboundy,gr_dboundw,gr_dboundh
                lea.l         int_in,a0
                move.w        \gr_dwidth,(a0)+
                move.w        \gr_dheight,(a0)+
                move.w        \gr_dstartx,(a0)+
                move.w        \gr_dstarty,(a0)+
                move.w        \gr_dboundx,(a0)+
                move.w        \gr_dboundy,(a0)+
                move.w        \gr_dboundw,(a0)+
                move.w        \gr_dboundh,(a0)
                AES           71,8,3,0
                .ENDM 

                .MACRO GRAF_MOVEBOX gr_mwidth,gr_mheight,gr_msourcex,gr_msourcey,gr_mdestx,gr_mdesty
                lea.l         int_in,a0
                move.w        \gr_mwidth,(a0)+
                move.w        \gr_mheight,(a0)+
                move.w        \gr_msourcex,(a0)+
                move.w        \gr_msourcey,(a0)+
                move.w        \gr_destx,(a0)+
                move.w        \gr_desty,(a0)
                AES           72,6,1,0
                .ENDM 

                .MACRO GRAF_MBOX gr_mwidth,gr_mheight,gr_msourcex,gr_msourcey,gr_mdestx,gr_mdesty
                lea.l         int_in,a0 ;das selbe wie GRAF_MOVEBOX
                move.w        \gr_mwidth,(a0)+
                move.w        \gr_mheight,(a0)+
                move.w        \gr_msourcex,(a0)+
                move.w        \gr_msourcey,(a0)+
                move.w        \gr_destx,(a0)+
                move.w        \gr_desty,(a0)
                AES           72,6,1,0
                .ENDM 

;ACHTUNG BEI GRAF_GROWBOX UND GRAF_SHRINKBOX!
;Die Funktionen sind ab GEM 2.0 nicht mehr implementiert und werden ignoriert.

                .MACRO GRAF_GROWBOX gr_gstx,gr_gsty,gr_gstwidth,gr_gstheight,gr_gfinx,gr_gfiny,gr_gfinwidth,gr_gfinheight
                lea.l         int_in,a0
                move.w        \gr_gstx,(a0)+
                move.w        \gr_gsty,(a0)+
                move.w        \gr_gstwidth,(a0)+
                move.w        \gr_gstheight,(a0)+
                move.w        \gr_gfinx,(a0)+
                move.w        \gr_gfiny,(a0)+
                move.w        \gr_gfinwidth,(a0)+
                move.w        \gr_gfinheight,(a0)
                AES           73,8,1,0
                .ENDM 

                .MACRO GRAF_SHRINKBOX gr_sfinx,gr_sfiny,gr_sfinwidth,gr_sfinheight,gr_sstx,gr_ssty,gr_sstwidth,gr_sstheight
                lea.l         int_in,a0
                move.w        \gr_sfinx,(a0)+
                move.w        \gr_sfiny,(a0)+
                move.w        \gr_sfinwidth,(a0)+
                move.w        \gr_sfinheight,(a0)+
                move.w        \gr_sstx,(a0)+
                move.w        \gr_ssty,(a0)+
                move.w        \gr_sstwidth,(a0)+
                move.w        \gr_sstheight,(a0)
                AES           73,8,1,0
                .ENDM 

                .MACRO GRAF_WATCHBOX gr_wptree,gr_wobject,gr_winstate,gr_woustate
                lea.l         int_in,a0
                move.w        \gr_wobject,(a0)+
                move.w        \gr_winstate,(a0)+
                move.w        \gr_woutstate,(a0)
                move.l        \gr_wptree,addr_in
                AES           75,4,1,1
                .ENDM 

                .MACRO GRAF_SLIDEBOX gr_slptree,gr_slparent,gr_slobject,gr_slvh
                lea.l         int_in,a0
                move.w        \gr_slparent,(a0)+
                move.w        \gr_slobject,(a0)+
                move.w        \gr_slvh,(a0)
                move.l        \gr_slptree,addr_in
                AES           76,3,1,1
                .ENDM 

                .MACRO GRAF_HANDLE
                AES           77,0,5,0
                .ENDM 

                .MACRO GRAF_MOUSE gr_monumber,gr_mofaddr
                move.w        \gr_monumber,int_in
                .IIF \?gr_mofaddr,      move.l    \gr_mofaddr,addr_in
                AES           78,1,1,1
                .ENDM 

                .MACRO GRAF_MKSTATE
                AES           79,0,5,0
                .ENDM 

                .MACRO SCRP_READ sc_rpscrap
                move.l        \sc_rpscrap,addr_in
                AES           80,0,1,1
                .ENDM 

                .MACRO SCRP_WRITE sc_wpscrap
                move.l        \sc_wpscrap,addr_in
                AES           81,0,1,1
                .ENDM 

                .MACRO FSEL_INPUT fs_iinpath,fs_iinsel
                lea.l         addr_in,a0
                move.l        \fs_iinpath,(a0)+
                move.l        \fs_iinsel,(a0)
                AES           90,0,2,2
                .ENDM 

;ACHTUNG!
;FSEL_EXINPUT gibt es erst ab TOS 1.4!

                .MACRO FSEL_EXINPUT fs_einpath,fs_einsel,fs_elabel
                lea.l         addr_in,a0
                move.l        \fs_einpath,(a0)+
                move.l        \fs_einsel,(a0)+
                move.l        \fs_elabel,(a0)
                AES           91,0,2,3
                .ENDM 

;ZUR UNABHéNGIGKEIT von den TOS-Versionen folgendes Binding nutzen:

                .MACRO FSEL_NEWINPUT fs_ninpath,fs_ninsel,fs_nlabel
                movem.l       d0-d3/d7/a0-a3,-(sp)
                clr.l         -(sp)
                move.w        #$20,-(sp)          ;in den Supervisor-Modus
                trap          #1
                addq.l        #6,sp
                movea.l       $4f2,a0   ;OS-Header
                move.w        2(a0),d7  ;Versionsnummer holen
                move.l        d0,-(sp)
                move.w        #$20,-(sp)          ;in den User-Modus
                trap          #1
                addq.l        #6,sp
                cmpi.w        #$104,d7  ;welches TOS?
                movem.l       (sp)+,d0-d3/d7/a0-a3
                blt           .\~old_tos
                FSEL_EXINPUT  \fs_ninpath,\fs_ninsel,\fs_nlabel
                bra           .\~ntr
.\~old_tos:     FSEL_INPUT    \fs_ninpath,\fs_ninsel
.\~ntr:         .ENDM 

                .MACRO WIND_CREATE wi_crkind,wi_crwx,wi_crwy,wi_crww,wi_crwh
                lea.l         int_in,a0
                move.w        \wi_crkind,(a0)+
                move.w        \wi_crwx,(a0)+
                move.w        \wi_crwy,(a0)+
                move.w        \wi_crww,(a0)+
                move.w        \wi_crwh,(a0)
                AES           100,5,1,0
                .ENDM 

                .MACRO WIND_OPEN wi_ohandle,wi_owx,wi_owy,wi_oww,wi_owh
                lea.l         int_in,a0
                move.w        \wi_ohandle,(a0)+
                move.w        \wi_owx,(a0)+
                move.w        \wi_owy,(a0)+
                move.w        \wi_oww,(a0)+
                move.w        \wi_owh,(a0)
                AES           101,5,1,0
                .ENDM 

                .MACRO WIND_CLOSE wi_clhandle
                move.w        \wi_clhandle,int_in
                AES           102,1,1,0
                .ENDM 

                .MACRO WIND_DELETE wi_dhandle
                move.w        \wi_dhandle,int_in
                AES           103,1,1,0
                .ENDM 

                .MACRO WIND_GET wi_ghandle,wi_gfield
                move.w        \wi_ghandle,int_in
                move.w        \wi_gfield,int_in+2
                AES           104,2,5,0
                .ENDM 

                .MACRO WIND_SET wi_shandle,wi_sfield,wi_sw1,wi_sw2,wi_sw3,wi_sw4
                lea.l         int_in,a0
                move.w        \wi_shandle,(a0)+
                move.w        \wi_sfield,(a0)+
                move.w        \wi_sw1,(a0)+
                move.w        \wi_sw2,(a0)+
                move.w        \wi_sw3,(a0)+
                move.w        \wi_sw4,(a0)
                AES           105,6,1,0
                .ENDM 

                .MACRO WIND_SETL wi_shandle,wi_sfield,wi_sw12,wi_sw3
                lea.l         int_in,a0
                move.w        \wi_shandle,(a0)+
                move.w        \wi_sfield,(a0)+
                move.l        \wi_sw12,(a0)+
                .IF \?wi_sw3
                move.w        \wi_sw3,(a0)+
                .ENDIF 
                AES           105,6,1,0
                .ENDM 

                .MACRO WIND_FIND wi_fmx,wi_fmy
                lea.l         int_in,a0
                move.w        \wi_fmx,(a0)+
                move.w        \wi_fmy,(a0)
                AES           106,2,1,0
                .ENDM 

                .MACRO WIND_UPDATE wi_ubegend
                move.w        \wi_ubegend,int_in
                AES           107,1,1,0
                .ENDM 

                .MACRO WIND_CALC wi_ctype,wi_ckind,wi_cinx,wi_ciny,wi_cinb,wi_cinh
                lea.l         int_in,a0
                move.w        \wi_ctype,(a0)+
                move.w        \wi_ckind,(a0)+
                move.w        \wi_cinx,(a0)+
                move.w        \wi_ciny,(a0)+
                move.w        \wi_cinb,(a0)+
                move.w        \wi_cinh,(a0)
                AES           108,6,5,0
                .ENDM 

;ACHTUNG BEI WIND_NEW!
;Die Funktion existiert erst ab TOS 1.4!

                .MACRO WIND_NEW
                AES           109,0,0,0
                .ENDM 

                .MACRO RSRC_LOAD re_lpfname
                move.l        \re_lpfname,addr_in
                AES           110,0,1,1
                .ENDM 

                .MACRO RSRC_FREE
                AES           111,0,1,0
                .ENDM 

                .MACRO RSRC_GADDR re_gtype,re_gindex
                lea.l         int_in,a0
                move.w        \re_gtype,(a0)+
                move.w        \re_gindex,(a0)
                AES           112,2,1,0
                .ENDM 

                .MACRO RSRC_SADDR re_stype,re_sindex,re_saddr
                lea.l         int_in,a0
                move.w        \re_stype,(a0)+
                move.w        \re_sindex,(a0)
                move.l        \re_saddr,addr_in
                AES           113,2,1,1
                .ENDM 

                .MACRO RSRC_OBFIX re_otree,re_oobject
                move.w        \re_oobject,int_in
                move.l        \re_otree,addr_in
                AES           114,1,1,1
                .ENDM 

;Bei den folgenden beiden Routinen wurden im Profibuch die Namen verwechselt
;vgl. ST-Computer 11/89, S. 186

                .MACRO SHEL_READ sh_rptail,sh_rpcmd
                lea.l         addr_in,a0
                move.l        \sh_rptail,(a0)+
                move.l        \sh_rpcmd,(a0)
                AES           120,0,1,2
                .ENDM 

                .MACRO SHEL_WRITE sh_wdoex,sh_wisgr,sh_wisover,sh_wptail,sh_wpcmd
                lea.l         int_in,a0
                move.w        \sh_wdoex,(a0)+
                move.w        \sh_wisgr,(a0)+
                move.w        \sh_wisover,(a0)    ;ERST AB GEM 2.0
                lea.l         addr_in,a0
                move.l        \sh_wptail,(a0)+
                move.l        \sh_wpcmd,(a0)
                AES           121,3,1,2
                .ENDM 

                .MACRO SHEL_GET sh_gaddr,sh_glen
                move.w        \sh_glen,int_in
                move.l        \sh_gaddr,addr_in
                AES           122,1,1,1
                .ENDM 

                .MACRO SHEL_PUT sh_paddr,sh_plen
                move.w        \sh_plen,int_in
                move.l        \sh_paddr,addr_in
                AES           123,1,1,1
                .ENDM 

                .MACRO SHEL_FIND sh_fpbuff
                move.l        \sh_fpbuff,addr_in
                AES           124,0,1,1
                .ENDM 

                .MACRO SHEL_ENVRN sh_epvalue,sh_eparm
                lea.l         addr_in,a0
                move.l        \sh_epvalue,(a0)+
                move.l        \sh_eparm,(a0)
                AES           125,0,1,2
                .ENDM 

;ACHTUNG!
;ALLE weiteren Funktionen ERST AB GEM 2.0

                .MACRO SHEL_RDEF sh_rlpcmd,sh_rlpdir
                lea.l         addr_in,a0
                move.l        \sh_rlpcmd,(a0)+
                move.l        \sh_rlpdir,(a0)
                AES           126,0,1,2
                .ENDM 

                .MACRO SHEL_WDEF sh_wlpcmd,sh_wlpdir
                lea.l         addr_in,a0
                move.l        \sh_wlpcmd,(a0)+
                move.l        \sh_wlpdir,(a0)
                AES           127,0,0,2
                .ENDM 

                .MACRO XGRF_STEPCALC xg_storgw,xg_storgh,xg_stxc,xg_styc,xg_stw,xg_sth
                lea.l         int_in,a0
                move.w        \xg_storgw,(a0)+
                move.w        \xg_storgh,(a0)+
                move.w        \xg_stxc,(a0)+
                move.w        \xg_styc,(a0)+
                move.w        \xg_stw,(a0)+
                move.w        \xg_sth,(a0)
                AES           130,6,6,0
                .ENDM 

;
;Aufruf der AES-Funktionen
;

                .SECTION 60,TEXT

aestrap:        lea.l         control,a0          ;Adresse des Kontrollfelds
                movep.l       d1,1(a0)  ;vier Bytes schreiben (auf Wortadressen)
                move.l        #aespb,d1 ;Adresse Åbergeben
                move.w        #$c8,d0   ;AES-Magic
                trap          #2        ;Aufruf
                rts                     ;fertig

                .TEXT 

                .END 

