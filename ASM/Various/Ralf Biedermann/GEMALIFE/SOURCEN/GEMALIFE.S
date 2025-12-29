                DEFAULT 4
                OPT F+                  ;Fast-Load (siehe 68000er 11/89)
                OUTPUT 'GEMALIFE.PRG'
                >PART 'Konstanten'
struct          EQU 50
entry           EQU 40
moore_mode      EQU %00000000000000000000000001011010
neumann_mode    EQU %00000000000000000000000011111111
flag            EQU 0
nachbar_zahl    EQU 2
nachbar1        EQU 4
nachbar2        EQU 8
nachbar3        EQU 12
nachbar4        EQU 16
nachbar5        EQU 20
nachbar6        EQU 24
nachbar7        EQU 28
nachbar8        EQU 32
cell_x          EQU 36
cell_y          EQU 38

_sysbase        EQU $000004F2
                ENDPART
                >PART 'AES/VDI-Library-EQUs'
;************************************************************************
;* Die AES-"Library"                                                    *
;************************************************************************
appl_init       EQU $0A000100
appl_read       EQU $0B020101
appl_write      EQU $0C020101
appl_find       EQU $0D000101
appl_tplay      EQU $0E020101
appl_trecord    EQU $0F010101
appl_bvset      EQU $10020100           ;ab GEM 2.0
appl_yield      EQU $11000100           ;ab GEM 2.0
appl_exit       EQU $13000100

evnt_keybd      EQU $14000100
evnt_button     EQU $15030500
evnt_mouse      EQU $16050500
evnt_mesag      EQU $17000101
evnt_timer      EQU $18020100
evnt_multi      EQU $19100701
evnt_dclick     EQU $1A020100

menu_bar        EQU $1E010101
menu_icheck     EQU $1F020101
menu_ienable    EQU $20020101
menu_tnormal    EQU $21020101
menu_text       EQU $22010102
menu_register   EQU $23010101
menu_unregister EQU $24010100           ;ab GEM 2.0

objc_add        EQU $28020101
objc_delete     EQU $29010101
objc_draw       EQU $2A060101
objc_find       EQU $2B040101
objc_offset     EQU $2C010301
objc_order      EQU $2D020101
objc_edit       EQU $2E040201
objc_change     EQU $2F080101

form_do         EQU $32010101
form_dial       EQU $33090100
form_alert      EQU $34010101
form_error      EQU $35010100
form_center     EQU $36000501
form_keybd      EQU $37030301
form_button     EQU $38020201

graf_rubberbox  EQU $46040300
graf_dragbox    EQU $47080300
graf_movebox    EQU $48060100
graf_growbox    EQU $49080100
graf_shrinkbox  EQU $4A080100
graf_watchbox   EQU $4B040101
graf_slidebox   EQU $4C030101
graf_handle     EQU $4D000500
graf_mouse      EQU $4E010101
graf_mkstate    EQU $4F000500

srcp_read       EQU $50000101
srcp_write      EQU $51000101
scrp_clear      EQU $52000100           ;ab GEM 2.0

fsel_input      EQU $5A000202
fsel_exinput    EQU $5B000203           ;ab TOS 1.4

wind_create     EQU $64050100
wind_open       EQU $65050100
wind_close      EQU $66010100
wind_delete     EQU $67010100
wind_get        EQU $68020500
wind_set        EQU $69060100
wind_find       EQU $6A020100
wind_update     EQU $6B010100
wind_calc       EQU $6C060500
wind_new        EQU $6D000000           ;ab TOS 1.4

rsrc_load       EQU $6E000101
rsrc_free       EQU $6F000100
rsrc_gaddr      EQU $70020100
rsrc_saddr      EQU $71020101
rsrc_obfix      EQU $72010101

shel_read       EQU $78000102
shel_write      EQU $79030102
shel_get        EQU $7A010101
shel_put        EQU $7B010101
shel_find       EQU $7C000101
shel_envrn      EQU $7D000102
shel_rdef       EQU $7E000102           ;ab GEM 2.0
shel_wdef       EQU $7F000002           ;ab GEM 2.0

xgrf_stepcalc   EQU $82060600           ;ab GEM 2.0
xgrf_2box       EQU $83090100           ;ab GEM 2.0

; Die Messages des AES
MN_SELECTED     EQU 10                  ;MenÅeintrag angewÑhlt
WM_REDRAW       EQU 20                  ;Teil eines Windows muû neu gezeichnet werden
WM_TOPPED       EQU 21                  ;Window ist nun das aktuelle Fenster
WM_CLOSED       EQU 22                  ;Window soll geschlossen werden
WM_FULLED       EQU 23                  ;Window soll auf max.Grîûe gebracht werden
WM_ARROWED      EQU 24                  ;Scollbalken angeklickt
WM_HSLID        EQU 25                  ;Der horizontale Slider wurde bewegt
WM_VSLID        EQU 26                  ;Der vertikale Slider wurde bewegt
WM_SIZED        EQU 27                  ;Die Grîûe des Windows wurde geÑndert
WM_MOVED        EQU 28                  ;Das Window wurde bewegt
WM_NEWTOP       EQU 29                  ;Das Fenster wurde aktiviert (siehe WM_TOPPED)
WM_UNTOPPED     EQU 30                  ;Der Fenster wird gleich inaktiv (erst ab GEM 2.0!)
AC_OPEN         EQU 40                  ;Ein Acc wurde angeklickt.(30 bzw. 31 ist FALSCH!)
AC_CLOSE        EQU 41                  ;Prg wurde beendet, ACC soll seinen Speicher freigeben.
CT_UPDATE       EQU 50
CT_MOVE         EQU 51                  ;Funktion unbekannt
CT_NEWTOP       EQU 52

; WM_ARROWED angeklickt (nun die genauere Definition)
WA_UPPAGE       EQU 0                   ;Balken oberhalb des Sliders
WA_DNPAGE       EQU 1                   ;Balken unterhalb des Sliders
WA_UPLINE       EQU 2                   ;Pfeil nach oben
WA_DNLINE       EQU 3                   ;Pfeil nach unten
WA_LFPAGE       EQU 4                   ;Balken links vom Slider
WA_RTPAGE       EQU 5                   ;Balken rechts vom Slider
WA_LFLINE       EQU 6                   ;Pfeil nach links
WA_RTLINE       EQU 7                   ;und Pfeil nach rechts

; Object-Flags bei einem Objekt
NONE_FLG        EQU $00000000
SELECTABLE_FLG  EQU $00000001
DEFAULT_FLG     EQU $00000002
EXIT_FLG        EQU $00000004
EDITABLE_FLG    EQU $00000008
RBUTTON_FLG     EQU $00000010           ;Bitte ebenfalls in der Literatur nachlesen
LASTOB_FLG      EQU $00000020
TOUCHEXIT_FLG   EQU $00000040
HIDETREE_FLG    EQU $00000080
INDIRECT_FLG    EQU $00000100

; Objekt-Status bei einem Objekt
NORMAL          EQU $00000000
SELECTED        EQU $00000001
CROSSED         EQU $00000002
CHECKED         EQU $00000004           ;s.o.
DISABLED        EQU $00000008
OUTLINED        EQU $00000010
SHADOWED        EQU $00000020

; Die einzelnen Bits bei evnt_multi()
MU_KEYBD        EQU $00000001           ;Tastaturereignis
MU_BUTTON       EQU $00000002           ;Maustastenereignis
MU_M1           EQU $00000004           ;1.Mausereignis
MU_M2           EQU $00000008           ;2.Mausereignis
MU_MESAG        EQU $00000010           ;Message des AES
MU_TIMER        EQU $00000020           ;Timer-Ereignis

; form_dial()
FMD_START       EQU $00000000           ;Bildschirmhintergrund reservieren
FMD_GROW        EQU $00000001           ;Ausdehnende Box zeichnen
FMD_SHRINK      EQU $00000002           ;Schrumpfende Box zeichnen
FMD_FINISH      EQU $00000003           ;Bildschirmbereich wieder freigeben

; graf_mouse()
ARROW           EQU $00000000
TEXT_CRSR       EQU $00000001
HOURGLASS       EQU $00000002
BUSYBEE         EQU $00000002
POINT_HAND      EQU $00000003
FLAT_HAND       EQU $00000004
THIN_CROSS      EQU $00000005
THICK_CROSS     EQU $00000006
OUTL_CROSS      EQU $00000007
USER_DEF        EQU $000000FF
M_OFF           EQU $00000100
M_ON            EQU $00000101

; Parameter bei wind_create()
WI_NAME         EQU $00000001
WI_CLOSE        EQU $00000002
WI_FULL         EQU $00000004
WI_MOVE         EQU $00000008
WI_INFO         EQU $00000010
WI_SIZE         EQU $00000020
WI_UPARROW      EQU $00000040
WI_DNARROW      EQU $00000080
WI_VSLIDE       EQU $00000100
WI_LFARROW      EQU $00000200
WI_RARROW       EQU $00000400
WI_HSLIDE       EQU $00000800

; Parameter bei wind_get() & wind_set()
WF_KIND         EQU 1
WF_NAME         EQU 2
WF_INFO         EQU 3
WF_WORKXYWH     EQU 4
WF_CURRXYWH     EQU 5
WF_PREVXYWH     EQU 6
WF_FULLXYWH     EQU 7
WF_HSLIDE       EQU 8
WF_VSLIDE       EQU 9
WF_TOP          EQU 10
WF_FIRSTXYWH    EQU 11
WF_NEXTXYWH     EQU 12
WF_NEWDESK      EQU 14
WF_HSLSIZE      EQU 15
WF_VSLSIZE      EQU 16

; wind_update()
END_UPDATE      EQU 0
BEG_UPDATE      EQU 1
END_MCTRL       EQU 2
BEG_MCTRL       EQU 3

;************************************************************************
;* Die VDI-"Library"                                               *
;* Wer nÑheres dazu wissen mîchte, sollte sich im Profibuch von Sybex   *
;* die Informationen dazu besorgen.                                     *
;************************************************************************
;1. Kontrollfunktionen
v_opnwk         EQU $010B0000           ;Open workstation
v_clswk         EQU $00000002           ;Close workstation
v_opnvwk        EQU $640B0000           ;Open virtual screen workstation
v_clsvwk        EQU $00000065           ;Close virtual screen workstation
v_clrwk         EQU $00000003           ;Clear workstation
v_updwk         EQU $00000004           ;Update workstation
vst_load_fonts  EQU $77010000           ;Load fonts
unload_fonts    EQU $78010000           ;Unload fonts
vs_clip         EQU $81010002           ;Set clipping rectangle
;2. Ausgabefunktionen
v_pline         EQU $06000000           ;Polyline (Byte 0=count(n))
v_pmarker       EQU $07000000           ;Polymarker (Byte 0=count(n))
v_gtext         EQU $08000001           ;Text (Byte 2=n)
v_fillarea      EQU $09000000           ;Filled area (Byte 0=count(n))
v_cellarray     EQU $0A000002           ;Cell array (Byte 2=n)
v_contourfill   EQU $67010001           ;Contour fill
vr_recfl        EQU $72000002           ;Fill rectangle
v_bar           EQU $0B000102           ;Bar
v_arc           EQU $0B020204           ;Arc
v_pieslice      EQU $0B020304           ;Pie
v_circle        EQU $0B000403           ;Circle
v_ellipse       EQU $0B000502           ;Ellipse
v_ellarc        EQU $0B020602           ;Elliptical arc
v_ellpie        EQU $0B020702           ;Elliptical pie
v_rbox          EQU $0B000802           ;Rounded rectangle
v_rfbox         EQU $0B000902           ;Filled rounded rectangle
v_justified     EQU $0B020A02           ;Justified graphics text (Byte 2=n+2)
;3. Attribut-Funktionen
vswr_mode       EQU $20010000           ;Set writing mode
vs_color        EQU $0E040000           ;Set color representation
vsl_type        EQU $0F010000           ;Set polyline line type
vsl_udsty       EQU $71010000           ;Set user-defined line style pattern
vsl_width       EQU $10000001           ;Set polyline line width
vsl_color       EQU $11010000           ;Set polyline color index
vsl_ends        EQU $6C020000           ;Set polyline end styles
vsm_type        EQU $12010000           ;Set polymarker type
vsm_height      EQU $13000001           ;Set polymarker height
vsm_color       EQU $14010000           ;Set polymarker color index
vst_height      EQU $0C000001           ;Set character height, absolute mode
vst_point       EQU $6B010000           ;Set character height, points mode
vst_rotation    EQU $0D010000           ;Set character baseline vector
vst_font        EQU $15010000           ;Set text face
vst_color       EQU $16010000           ;Set graphic text color index
vst_effects     EQU $6A010000           ;Set graphic text special effects
vst_alignment   EQU $27020000           ;Set graphic text alignment
vsf_interior    EQU $17010000           ;Set fill interior index
vsf_style       EQU $18010000           ;Set fill style index
vsf_color       EQU $19010000           ;Set fill color index
vsf_perimeter   EQU $68010000           ;Set fill perimeter visibility
vsf_udpat       EQU $70000000           ;Set user-defined fill pattern (Byte 2=16*planes)
;4. Rasteroperationen
vro_cpyfm       EQU $6D010004           ;Copy raster, opaque
vrt_cpyfm       EQU $79030004           ;Copy raster, transparent
vr_trnfm        EQU $6E000000           ;Transform form
v_get_pixel     EQU $69000001           ;Get pixel
;5. Eingabefunktionen
vsin_mode       EQU $21020000           ;Set input mode
vrq_locator     EQU $1C000001           ;Input locator, request mode
vsm_locator     EQU $1C000001           ;Input locator, sample mode
vrq_valuator    EQU $1D010000           ;Input valuator, request mode
vsm_valuator    EQU $1D010000           ;Input valuator, sample mode
vrq_choice      EQU $1E010000           ;Input choice, request mode
vsm_choice      EQU $1E010000           ;Input choice, sample mode
vrq_string      EQU $1F020001           ;Input string, request mode
vsm_string      EQU $1F020001           ;Input string, sample mode
vsc_form        EQU $6F250000           ;Set mouse form
vex_timv        EQU $00000076           ;Exchange timer interrupt vector
v_show_c        EQU $7A010000           ;Show cursor
v_hide_c        EQU $0000007B           ;Hide cursor
vq_mouse        EQU $0000007C           ;Sample mouse button state
vex_butv        EQU $0000007D           ;Exchange button change vector
vex_motv        EQU $0000007E           ;Exchange mouse movement vector
vex_curv        EQU $0000007F           ;Exchange cursor change vector
vq_key_s        EQU $80000000           ;Sample keyboard state information
;6. Auskunftsfunktionen
vq_extnd        EQU $66010000           ;Extended inquire function
vq_color        EQU $1A020000           ;Inquire color representation
vql_attributes  EQU $00000023           ;Inquire current polyline attributes
vqm_attributes  EQU $00000024           ;Inquire current polymarker attributes
vqf_attributes  EQU $00000025           ;Inquire current fill area attributes
vqt_attributes  EQU $00000026           ;Inquire current graphic text attributes
vqt_extent      EQU $00000074           ;Inquire text extent (Byte 2=n)
vqt_width       EQU $75010000           ;Inquire character cell width
vqt_name        EQU $82010000           ;Inquire face name and index
vq_cellarray    EQU $1B000002           ;Inquire cell array
vqin_mode       EQU $73010000           ;Inquire input mode
vqt_fontinfo    EQU $83000000           ;Inquire current face information
vqt_justified   EQU $84020002           ;Inquire just.graph.text (Byte 2=n+2) GEM 2.0!
;7. Escapes
vq_chcells      EQU $05000100           ;Inquire addressable alpha character cells
v_exit_cur      EQU $05000200           ;Exit alpha mode
v_enter_cur     EQU $05000300           ;Enter alpha mode
v_curup         EQU $05000400           ;Alpha cursor up
v_curdown       EQU $05000500           ;Alpha cursor down
v_curright      EQU $05000600           ;Alpha cursor right
c_curleft       EQU $05000700           ;Alpha cursor left
v_curhome       EQU $05000800           ;Home alpha cursor
v_eeos          EQU $05000900           ;Erase to end of alpha screen
v_eeol          EQU $05000A00           ;Erase to end of alpha text line
v_curaddress    EQU $05020B00           ;Direct alpha cursor address
v_curtext       EQU $05000C00           ;Output cursor addressable alpha text (Byte 2=n)
v_rvon          EQU $05000D00           ;Reverse video on
v_rvoff         EQU $05000E00           ;Reverse video off
vq_curaddress   EQU $05000F00           ;Inquire current alpha cursor address
vq_tabstatus    EQU $05001000           ;Inquire tablet status
v_hardcopy      EQU $05001100           ;Hardcopy
v_dspcur        EQU $05001201           ;Place graphic cursor at location
v_rmcur         EQU $05001300           ;Remove last graphic cursor
v_form_adv      EQU $05001400           ;Form advance
v_output_window EQU $05001500           ;Output window
v_clear_disp_list EQU $05001600         ;Clear display list
v_bit_image     EQU $05051702           ;Output bit image file (Byte 2=n+5)
vq_scan         EQU $05001800           ;Inquire printer scan
v_alpha_text    EQU $05001900           ;Output alpha text (Byte 2=n)
vs_palette      EQU $05013C00           ;Select palette
v_sound         EQU $05023D00           ;Generate specified tone
vs_mute         EQU $05013E00           ;Set/clear tone muting flag
vt_resolution   EQU $05025100           ;Set tablet axis resolution in lines/inch
vt_axis         EQU $05025200           ;Set table axis resolution in lines
vt_origin       EQU $05025300           ;Set tablet x and y origin
vq_tdimensions  EQU $05005400           ;Return tablet x and y dimensions
vt_alignment    EQU $05025500           ;Set tablet alignment
vsp_film        EQU $05025B00           ;Set camera file type and exposure time
vqp_filename    EQU $05015C00           ;Inquire camera file name
vsc_expose      EQU $05015D00           ;Disable or enable file exposure for frame preview
v_meta_extents  EQU $05006202           ;Update metafile extents
v_write_meta    EQU $05006300           ;Write metafile item (Byte 0=num_ptsin, Byte 2=num_intin)
vm_pagesize     EQU $05036300           ;Physical page size
wm_coords       EQU $05056300           ;Coordinate window
vm_filename     EQU $05006400           ;Change gem vdi filename (Byte 2=n)
v_offset        EQU $05016500           ;Set line offset
v_fontinit      EQU $05026600           ;Init system font
;v_escape2000(times) -> (klappt mit dem Konzept leider nicht...)
                ENDPART
                >PART 'AES/VDI initialisieren'
                TEXT
start:          move.l  A0,D0           ;falls ACC sollte in A0 Zeiger auf Basepage stehen
                tst.l   D0              ;ACC ?
                beq.s   start_ok
                moveq   #0,D0           ;standard
                lea     no_acc(PC),A0   ;Text 'nicht als ACC
                bsr     alert_box
                clr.w   -(SP)
                trap    #1              ;Pterm()
start_ok:       move.l  4(SP),base_page ;man weiû ja nie
                lea     own_stack(PC),SP ;Eigenen Stack einrichten
                lea     bss_ende(PC),A1
                suba.l  #start-256,A1   ;ProgrammlÑnge
                move.l  A1,-(SP)        ;LÑnge des Starters
                move.l  base_page(PC),-(SP) ;Basepageadr des Starters
                move.l  #$004A0000,-(SP)
                trap    #1              ;Mshrink()
                lea     12(SP),SP
;TOS-Version festellen
                pea     get_tos_vers(PC)
                move.w  #$0026,-(SP)
                trap    #14             ;Supexec()
                addq.l  #6,SP
;Anwendung anmelden
                move.l  #appl_init,D0
                bsr     aes             ;APPL_INIT()
                move.w  D0,ap_id
                lea     _menu_main(PC),A0
                move.w  #_nobs-1,D7     ;150 Objekte im Baum
start_loop:     move.w  D7,int_in       ;die Objektnummer
                move.l  #$72010101,D0
                bsr     aes             ;rsrc_obfix()
                dbra    D7,start_loop
;Handle von Bildschirm-Workstation feststellen
                move.l  #graf_handle,D0
                bsr     aes             ;GRAF_HANDLE()
                move.w  D0,vdi_handle
;Virtuelle Workstation îffnen
                move.l  #v_opnvwk,D0
                lea     int_in(PC),A0
                move.w  #1,(A0)+        ;Bildschirm aktuelle Auflîsung
                move.w  #1,(A0)+        ;Linientyp
                move.w  #1,(A0)+        ;Linienfarbe
                move.w  #1,(A0)+        ;Markertyp
                move.w  #1,(A0)+        ;Markerfarbe
                move.w  #1,(A0)+        ;Zeichensatznummer
                move.w  #1,(A0)+        ;Textfarbe
                move.w  #1,(A0)+        ;FÅlltyp
                move.w  #0,(A0)+        ;FÅllmuster-Index
                move.w  #0,(A0)+        ;FÅllmusterfarbe
                move.w  #2,(A0)+        ;RC-Koordinaten
                bsr     vdi             ;V_OPNVWK()
                move.l  contrl+12(PC),vdi_handle ;Handle der virtuelle Workstation merken
                move.l  #wind_get,D0
                clr.w   int_in
                move.w  #WF_WORKXYWH,int_in+2
                bsr     aes
                move.w  int_out+2(PC),max_x
                move.w  int_out+4(PC),max_y
                move.w  int_out+6(PC),D0
                and.w   #$FFFC,D0
                move.w  D0,max_w
                move.w  D0,max_w1
                move.w  int_out+8(PC),D0
                and.w   #$FFFC,D0
                move.w  D0,max_h
                move.w  D0,max_h1
                ENDPART
                >PART 'Menu und Fenster aufbauen'
* Menue aufbauen
                move.l  #menu_bar,D0
                move.w  #1,int_in       ;Menu setzen
                lea     _menu_main(PC),A0
                bsr     aes             ;MENU_BAR()
                beq     error           ;ja
* Fenster îffnen
                move.l  #wind_create,D0
                move.w  #%0000000000101111,int_in ;NAME,CLOSE,FULL,MOVE,SIZE
                move.w  max_x(PC),int_in+2 ;
                move.w  max_y(PC),int_in+4 ;
                move.w  max_w(PC),int_in+6 ;
                move.w  max_h(PC),int_in+8 ;
                bsr     aes             ;WIND_CREATE()
                move.w  D0,w_handle
                bmi     error_wind      ;<0 == Fehler

                move.l  #wind_set,D0
                move.w  w_handle(PC),int_in ;Handle eintragen
                move.w  #WF_NAME,int_in+2 ;nur Namen festlegen
                move.l  #fenster_name,int_in+4 ;Zeiger auf Fensternamen
                bsr     aes             ;WIND_SET()
                beq     error           ;ja

                move.l  #wind_open,D0
                move.w  w_handle(PC),int_in ;Handle eintragen
                move.w  max_x(PC),int_in+2 ;
                move.w  max_y(PC),int_in+4 ;
                move.w  max_w(PC),int_in+6 ;
                move.w  max_h(PC),int_in+8 ;
                bsr     aes             ;WIND_OPEN()
                beq     error           ;ja
                bsr     arrow           ;Pfeil
                ENDPART
                >PART 'Daten initialisieren'
;INF laden falls vorhanden
                lea     inf_name(PC),A0
                bsr     open
                bmi.s   no_inf
                lea     paras(PC),A0
                move.l  #eparas-paras,D7
                bsr     read
                bsr     close
;Parameter fÅr Dialogboxen setzen
;Nachbarschaft
no_inf:         lea     _ob_moore+10(PC),A0 ;Moorenachbarschaft = 4
                cmpi.w  #moore_mode,nachbarn ;ist es das ?
                beq.s   set_nachbar     ;ja
                lea     _ob_neumann+10(PC),A0 ;sonst von Neumann
set_nachbar:    ori.w   #1,(A0)         ;selektieren
;Form
                lea     _ob_torus+10(PC),A0 ;soll ein Torus genommen werden ?
                tst.w   form
                beq.s   set_form        ;ja
                lea     _ob_rechteck+10(PC),A0 ;sonsts Rechteck
set_form:       ori.w   #1,(A0)         ;selektieren
                lea     birth(PC),A0    ;Anzahl der lebenden Nachbarn fÅr Geburt
                lea     _ob_life+10(PC),A1 ;DialogBox
                lea     death(PC),A2    ;Anzahl der lebenden Nachbarn fÅr Tod
                lea     _ob_death+10(PC),A3 ;DialogBox
                moveq   #8,D7           ;9 Mîglichkeiten 0..8
regel_loop:     clr.w   (A1)            ;zuerst lîschen
                tst.w   (A0)+           ;fÅr Geburt selektiert ?
                beq.s   regel_loop1     ;nein
                move.w  #1,(A1)         ;selektieren
regel_loop1:    clr.w   (A3)            ;zuerst lîschen
                cmpi.w  #6,(A2)+        ;fÅr Tod selektiert ?
                beq.s   regel_loop2     ;nein
                move.w  #1,(A3)         ;selektieren
regel_loop2:    lea     24(A1),A1       ;nÑchstes Object
                lea     24(A3),A3
                dbra    D7,regel_loop
                clr.l   mem
fenster_loop:   move.l  max_x(PC),puffer
                move.l  max_w(PC),puffer+4
                lea     puffer(PC),A0   ;Fenster auf Maximum setzen
                bsr     fenster_neu
                bsr     anfang_draw
                move.l  #v_bar,D0
                move.l  max_x(PC),D3
                move.l  max_w(PC),D4
                move.l  D3,ptsin
                add.l   D3,D4
                subi.l  #$00010001,D4
                move.l  D4,ptsin+4
                bsr     vdi
                bsr     ende_draw
                move.l  #-1,-(SP)       ;freien Speicher erfragen
                move.w  #72,-(SP)       ;Malloc()
                trap    #1
                sub.l   #65536,D0       ;frei halten fÅr z.B. Fileselektor
                move.w  x_zahl(PC),D1
                move.w  y_zahl(PC),D2
                mulu    #struct,D2
                mulu    D2,D1
                move.l  D0,D2
                sub.l   D1,D2           ;reicht Speicher ?
                bpl.s   efenster_loop
                cmpi.l  #$00200020,max_w1
                beq.s   mem_error
                subq.w  #4,max_w1
                subq.w  #4,max_h1
                cmpi.w  #32,max_w1
                bhi.s   fenster_loop1
                move.w  #32,max_w1
fenster_loop1:  cmpi.w  #32,max_h1
                bhi     fenster_loop
                move.w  #32,max_h1
                bra     fenster_loop
mem_error:      moveq   #0,D0
                lea     no_mem(PC),A0
                bsr     alert_box
                bra     exit
;Speicher reservieren
efenster_loop:  move.w  x_zahl(PC),D0
                mulu    #struct,D0
                mulu    y_zahl(PC),D0
                move.l  D0,-(SP)
                move.w  #72,-(SP)       ;Malloc()
                trap    #1
                addq.l  #6,SP
                tst.l   D0
                beq.s   mem_error
                move.l  D0,mem
                move.l  D0,liste
                move.w  x_zahl(PC),D1
                mulu    #entry,D1
                mulu    y_zahl(PC),D1
                add.l   D1,D0
                move.l  D0,life_stack
;Zuerst eine kleine Meldung
                clr.w   changed1
                st      changed
                bsr     init_liste
                clr.l   count
                move.l  life_stack(PC),elife_stack
;Daten initialisieren
                move.l  #vr_trnfm,D0
                move.l  #setzen_MFDB,contrl+14
                move.l  #setzen1_MFDB,contrl+18
                bsr     vdi
                move.l  #vr_trnfm,D0
                move.l  #loeschen_MFDB,contrl+14
                move.l  #loeschen1_MFDB,contrl+18
                bsr     vdi
;jetzt kann die Meldung weg
                ENDPART
                >PART 'Hauptschleife MULTI_EVENT'
main_loop:      move.l  #evnt_multi,D0
                lea     message_puffer(PC),A0
                move.w  #%0000000000010011,int_in ;Tastatur, Mausknopf und Mitteilung
                move.w  #1,int_in+2     ;nur ein Klick
                move.w  #1,int_in+4     ;beide Tasten mask
                move.w  #1,int_in+6     ;beide Tasten state
                bsr     aes             ;EVNT_MULTI()
main_loop1:     btst    #0,D0           ;Tastatur ?
                bne.s   tastatur        ;ja
                btst    #1,D0           ;Mausknopf ?
                bne     maus            ;ja
                btst    #4,D0           ;Mitteilung ?
                bne     message
                bra.s   main_loop
                ENDPART
                >PART 'Tastatur'
;auf Tastatur reagieren
tastatur:       move.w  int_out+10(PC),D0 ;Scancode?
                cmp.w   #3135,D0        ;?
                bne.s   tastatur21
                bsr     copyr
                bra.s   main_loop
tastatur21:     cmp.w   #9740,D0        ;^L
                bne.s   tastatur22
                bsr     load
                bra.s   main_loop
tastatur22:     cmp.w   #7955,D0        ;^S
                bne.s   tastatur23
                bsr     save
                bra.s   main_loop
tastatur23:     cmp.w   #4113,D0        ;^Q
                beq     exit
tastatur31:     cmp.w   #8019,D0        ;S
                bne.s   tastatur32
                bsr     single
                bra     main_loop
tastatur32:     cmp.w   #9547,D0        ;K
                beq     zeit_continue
tastatur33:     cmp.w   #4946,D0        ;R
                beq     zeit_random
tastatur34:     cmp.w   #8775,D0        ;G
                bne.s   tastatur35
                bsr     grid
                bra     main_loop
tastatur35:     cmp.w   #9804,D0        ;L
                bne.s   tastatur41
                bsr     clear
                bra     main_loop
tastatur41:     cmp.w   #4882,D0        ;^R
                bne.s   tastatur42
                bsr     regeln
                bra     main_loop
tastatur42:     cmp.w   #12558,D0       ;^N
                bne.s   tastatur43
                bsr     nachbar
                bra     main_loop
tastatur43:     cmp.w   #8454,D0        ;^F
                bne.s   tastatur44
                bsr     rand
                bra     main_loop
tastatur44:     cmp.w   #7936,D0        ;S
                bne.s   etastatur
                bsr     save_para
etastatur:      bra     main_loop
                ENDPART
                >PART 'Maus'
;auf Mausknopf reagieren
maus:           move.w  int_out+2(PC),D1 ;X-Koordinate
                sub.w   x_koord(PC),D1
                lsr.w   #2,D1
                move.w  x_zahl(PC),D0
                cmp.w   D1,D0
                bmi.s   maus_loop
                move.w  int_out+4(PC),D2
                sub.w   y_koord(PC),D2
                lsr.w   #2,D2
                move.w  y_zahl(PC),D0
                cmp.w   D2,D0
                bmi.s   maus_loop
                bsr     test_punkt
                cmp.w   #-2,D0
                beq.s   maus1
                bsr     anfang_draw
                bsr     unset_punkt
                bsr     ende_draw
                bra.s   maus_loop
maus1:          bsr     anfang_draw
                bsr     set_punkt
                bsr     ende_draw
maus_loop:      move.l  #evnt_multi,D0
                lea     message_puffer(PC),A0
                move.w  #%0000000000110011,int_in ;Tastatur, Mausknopf, Mitteilung, Timer
                move.w  #1,int_in+2     ;nur ein Klick
                move.w  #1,int_in+4     ;linke Tasten mask
                move.w  #1,int_in+6     ;linke Tasten state
                move.l  #$00100000,int_in+28 ;16 Millisekunde
                bsr     aes             ;EVNT_MULTI()
                btst    #5,D0
                beq.s   maus_loop       ;nein
                bra     main_loop
                ENDPART
                >PART 'Message'
;auf Message reagieren
message:        move.w  message_puffer(PC),D0 ;Mitteilung holen
                cmp.w   #MN_SELECTED,D0 ;Menueintrag gewÑhlt ?
                bne.s   message1        ;nein
                move.w  message_puffer+6(PC),D0 ;Welcher Menupunkt ?
                move.w  message_puffer+8(PC),D1 ;Welches Untermenu
                cmp.w   #_titel,D0      ;Info ?
                beq     titel           ;ja
                cmp.w   #_datei,D0      ;Datei ?
                beq     datei
                cmp.w   #_funktion,D0   ;Animate ?
                beq     funktion
                cmp.w   #_einstell,D0   ;Einstellungen ?
                beq     einstellungen
                bra     main_loop
message1:       move.w  message_puffer+6(PC),D1
                cmp.w   w_handle(PC),D1
                bne     main_loop
                cmp.w   #WM_REDRAW,D0
                bne.s   message2
                lea     message_puffer+8(PC),A6
                bsr     redraw
                bra     main_loop
message2:       cmp.w   #WM_CLOSED,D0
                beq     exit
message3:       cmp.w   #WM_TOPPED,D0
                bne.s   message4
                move.l  #wind_set,D0
                move.w  w_handle(PC),int_in
                move.w  #WF_TOP,int_in+2
                bsr     aes
                bra     main_loop
message4:       cmp.w   #WM_MOVED,D0
                bne.s   message5
                lea     message_puffer+8(PC),A0
                bsr     fenster_neu
                bra     main_loop
message5:       cmp.w   #WM_SIZED,D0
                bne.s   message6
                lea     message_puffer+8(PC),A0
                bsr     fenster_neu
                st      changed
                bsr     init_liste
                bsr     clear
                bra     main_loop
message6:       cmp.w   #WM_FULLED,D0
                bne.s   message7
                move.l  max_x(PC),puffer
                move.l  max_w(PC),puffer+4
                lea     puffer(PC),A0
                bsr     fenster_neu
                st      changed
                bsr     init_liste
                bsr     clear
                bra     main_loop
message7:       bra     main_loop

;Infomenu gewÑhlt
titel:          bsr     copyr
etitel:         move.l  #menu_tnormal,D0
                move.w  #_titel,int_in
                move.w  #1,int_in+2
                lea     _menu_main(PC),A0
                bsr     aes
                bra     main_loop

;Dateimenu gewÑhlt
datei:          cmp.w   #_load,D1
                bne.s   datei1
                bsr     load
                bra.s   edatei
datei1:         cmp.w   #_save,D1
                bne.s   datei2
                bsr     save
                bra.s   edatei
datei2:         cmp.w   #_quit,D1
                beq     exit
edatei:         move.l  #menu_tnormal,D0
                move.w  #_datei,int_in
                move.w  #1,int_in+2
                lea     _menu_main(PC),A0
                bsr     aes
                bra     main_loop

;Funtionsmenu gewÑhlt
funktion:       cmp.w   #_single,D1
                bne.s   funktion1
                bsr     single
                bra.s   efunktion
funktion1:      cmp.w   #_continue,D1
                bne.s   funktion2
                bra     zeit_continue
funktion2:      cmp.w   #_clear,D1
                bne.s   funktion3
                bsr     clear
                bra.s   efunktion
funktion3:      cmp.w   #_random,D1
                bne.s   funktion4
                bra     zeit_random
funktion4:      cmp.w   #_grid,D1
                bne.s   funktion5
                bsr     grid
                bra.s   efunktion
funktion5:      cmp.w   #_clear,D1
                bne.s   efunktion
                bsr     grid
efunktion:      move.l  #menu_tnormal,D0
                move.w  #_funktion,int_in
                move.w  #1,int_in+2
                lea     _menu_main(PC),A0
                bsr     aes
                bra     main_loop

;Parametermenu gewÑhlt
einstellungen:  cmp.w   #_regeln,D1     ;sollen die Regeln geÑndert werden ?
                bne.s   einstellungen1
                bsr     regeln
                bra.s   eeinstellungen
einstellungen1: cmp.w   #_nachbar,D1    ;Nchbarschaft Ñndern ?
                bne.s   einstellungen2
                bsr     nachbar
                bra.s   eeinstellungen
einstellungen2: cmp.w   #_form,D1       ;Rand Ñndern ?
                bne.s   einstellungen3
                bsr     rand
                bra.s   eeinstellungen
einstellungen3: cmp.w   #_parasave,D1   ;Einstellungen sichern ?
                bne.s   eeinstellungen
                bsr     save_para
eeinstellungen: move.l  #menu_tnormal,D0
                move.w  #_einstell,int_in
                move.w  #1,int_in+2
                lea     _menu_main(PC),A0
                bsr     aes
                bra     main_loop

                ENDPART
                >PART 'Unterprogramme'
;1. Hauptmenue
copyr:          lea     _tree_copyrigh(PC),A0
                bsr     do_dialog
                rts

;2. Hauptmenue
load:           bsr     is_top
                lea     titel_load(PC),A4
                bsr     file_select
                beq     eload
                lea     f_name(PC),A0
                bsr     open
                bpl.s   load_ok
                moveq   #0,D0           ;standard
                lea     file_not_found(PC),A0 ;
                bsr     alert_box
                rts
load_ok:        bsr     anfang_draw
load_loop1:     lea     file_buffer(PC),A0
                move.l  #1000,D7
                bsr     read
                clr.w   weiter
                cmp.l   #1000,D0
                bne.s   load1
                st      weiter
load1:          move.w  D0,D5
                tst.w   weiter
                beq.s   load2
                subq.w  #2,D5
load2:          lea     file_buffer(PC),A2
                lsr.w   #1,D5
                subq.w  #1,D5
                bmi.s   end_load
load_loop2:     moveq   #0,D1
                move.b  (A2)+,D1
                moveq   #0,D2
                move.b  (A2)+,D2
                cmp.w   y_zahl(PC),D2
                bhi.s   eload_loop2
                cmp.w   x_zahl(PC),D1
                bhi.s   eload_loop2
                bsr     set_punkt
eload_loop2:    dbra    D5,load_loop2
                tst.w   weiter
                bne.s   load_loop1
end_load:       bsr     ende_draw
                cmpi.b  #255,1(A2)
                bne.s   eload1
                tst.w   form
                beq.s   eload
                clr.w   form
                st      changed1
                lea     _ob_torus+10(PC),A0 ;soll ein Torus genommen werden ?
                tst.w   form
                beq.s   set_form1       ;ja
                clr.w   (A0)
                lea     _ob_rechteck+10(PC),A0 ;sonsts Rechteck
set_form1:      ori.w   #1,(A0)         ;selektieren
eload:          rts
eload1:         tst.w   form
                bne.s   eload
                st      form
                st      changed1
                lea     _ob_torus+10(PC),A0 ;soll ein Torus genommen werden ?
                tst.w   form
                beq.s   set_form2       ;ja
                clr.w   (A0)
                lea     _ob_rechteck+10(PC),A0 ;sonsts Rechteck
set_form2:      ori.w   #1,(A0)         ;selektieren
                rts


save:           lea     titel_save(PC),A4
                bsr     file_select
                beq     esave
                lea     f_name(PC),A0
                bsr     open
                bmi.s   save1
                moveq   #1,D0
                lea     file_loeschen(PC),A0
                bsr     alert_box
                cmp.w   #2,D0
                beq.s   esave
save1:          lea     f_name(PC),A0
                bsr     create
                movea.l life_stack(PC),A6
                lea     file_buffer(PC),A0
                move.l  count(PC),D6
                moveq   #0,D7
save_loop1:     movea.l (A6)+,A1
                move.w  cell_x(A1),D0
                lsr.w   #2,D0
                move.b  D0,(A0)+
                move.w  cell_y(A1),D0
                lsr.w   #2,D0
                move.b  D0,(A0)+
                addq.w  #1,D7
                cmp.w   #500,D7
                bne.s   esave_loop1
                lea     file_buffer(PC),A0
                move.w  #1000,D7
                bsr     write
                lea     file_buffer(PC),A0
                moveq   #0,D7
esave_loop1:    subq.l  #1,D6
                bne.s   save_loop1
                move.w  #$FFFF,(A0)
                tst.w   form
                beq.s   end_save
                move.w  #$FFFE,(A0)
end_save:       addq.w  #1,D7
                lsl.w   #1,D7
                lea     file_buffer(PC),A0
                bsr     write
                bsr     close
esave:          rts

;3. Hauptmenue
single:         bsr     init_liste
                bsr     is_top
                bsr     anfang_draw
                bsr     generate
                bsr     ende_draw
                rts

zeit_continue:  bsr     init_liste
                lea     generate(PC),A5
                bra     zeit_init

zeit_random:    lea     random(PC),A5
                bra     zeit_init
random:         move.w  #17,-(SP)
                trap    #14
                addq.l  #2,SP
                lsr.l   #8,D0
                mulu    x_zahl(PC),D0
                swap    D0
                move.w  D0,-(SP)
                move.w  #17,-(SP)
                trap    #14
                addq.l  #2,SP
                lsr.l   #8,D0
                mulu    y_zahl(PC),D0
                swap    D0
                move.w  (SP)+,D1
                move.w  D0,D2
                bsr     set_punkt
                rts

grid:           bsr     is_top
                bsr     anfang_draw
                move.w  y_zahl(PC),D7
                subq.w  #1,D7
                move.w  x_koord(PC),D1
                move.w  D1,D3
                add.w   width(PC),D3
                subq.w  #1,D3
                move.w  y_koord(PC),D2
                addq.w  #3,D2
grid_loop1:     move.l  #v_pline,D0
                move.b  #2,D0
                move.w  D1,ptsin
                move.w  D2,ptsin+2
                move.w  D3,ptsin+4
                move.w  D2,ptsin+6
                bsr     vdi
                addq.w  #4,D2
                dbra    D7,grid_loop1
                move.w  x_zahl(PC),D7
                subq.w  #1,D7
                move.w  x_koord(PC),D1
                addq.w  #3,D1
                move.w  y_koord(PC),D2
                move.w  D2,D4
                add.w   heigth(PC),D4
                subq.w  #1,D4
grid_loop2:     move.l  #v_pline,D0
                move.b  #2,D0
                move.w  D1,ptsin
                move.w  D2,ptsin+2
                move.w  D1,ptsin+4
                move.w  D4,ptsin+6
                bsr     vdi
                addq.w  #4,D1
                dbra    D7,grid_loop2
                bsr     ende_draw
                rts

clear:          bsr     is_top
                move.l  life_stack(PC),elife_stack
                clr.l   count
                bsr     clear_liste
                bsr     draw
                rts

;4. Hauptmenu
regeln:         lea     _tree_regel(PC),A0
                bsr     do_dialog
                bsr.s   get_para
                rts

nachbar:        lea     _tree_neigbour(PC),A0
                bsr     do_dialog
                bsr.s   get_para
                st      changed1
                rts

rand:           lea     _tree_rand(PC),A0
                bsr     do_dialog
                bsr.s   get_para
                st      changed1
                rts

save_para:      bsr     create
                lea     inf_name(PC),A0
                bsr     create
                bmi.s   save_para_err
                lea     paras(PC),A0
                move.l  #eparas-paras,D7
                bsr     write
                cmp.l   #eparas-paras,D0
                bne.s   save_para_abb
                bsr     close
                rts

save_para_abb:  bsr     close
save_para_err:  moveq   #1,D0
                lea     no_file(PC),A0
                bsr     alert_box
                rts

;Parameter aus Dialogboxen holen
;Nachbarschaft
get_para:       move.w  #neumann_mode,D0 ;
                lea     _ob_neumann+10(PC),A0
                lea     _ob_moore+10(PC),A1
                move.w  (A0),D1         ;Moorenachbarschaft = 4
                and.w   #1,D1
                bne.s   get_nachbar
                exg     A0,A1
                move.w  #moore_mode,D0
get_nachbar:    ori.w   #1,(A0)
                clr.w   (A1)
                move.w  D0,nachbarn
;Form
                moveq   #0,D0
                lea     _ob_torus+10(PC),A0
                lea     _ob_rechteck+10(PC),A1
                move.w  (A0),D1
                and.w   #1,D1
                bne.s   get_form
                exg     A0,A1
                moveq   #1,D0
get_form:       ori.w   #1,(A0)
                clr.w   (A1)
                move.w  D0,form
                lea     birth(PC),A0
                lea     _ob_life+10(PC),A1
                lea     death(PC),A2
                lea     _ob_death+10(PC),A3
                moveq   #8,D7
get_regel_loop: moveq   #0,D0
                move.w  (A1),D1
                and.w   #1,D1
                beq.s   get_regel_loop1
                moveq   #2,D0
get_regel_loop1:move.w  D0,(A0)+
                moveq   #6,D0
                move.w  (A3),D1
                and.w   #1,D1
                beq.s   get_regel_loop2
                moveq   #4,D0
get_regel_loop2:move.w  D0,(A2)+
                lea     24(A1),A1
                lea     24(A3),A3
                dbra    D7,get_regel_loop
                rts

fenster_neu:    move.w  max_w1(PC),D0
                cmp.w   4(A0),D0
                bpl.s   fenster_neu1
                move.w  max_w1(PC),4(A0)
fenster_neu1:   move.w  max_h1(PC),D0
                cmp.w   6(A0),D0
                bpl.s   fenster_neu2
                move.w  max_h1(PC),6(A0)
fenster_neu2:   move.w  max_x(PC),D0
                add.w   max_w(PC),D0
                move.w  (A0),D1
                add.w   4(A0),D1
                cmp.w   D1,D0
                bmi     efenster_neu
                move.w  max_y(PC),D0
                add.w   max_h(PC),D0
                move.w  2(A0),D1
                add.w   6(A0),D1
                cmp.w   D1,D0
                bmi     efenster_neu
                move.w  4(A0),D0
                move.w  6(A0),D1
                cmp.w   #64,D0
                bpl.s   fenster_neu3
                moveq   #64,D0
fenster_neu3:   cmp.w   #64,D1
                bpl.s   fenster_neu4
                moveq   #64,D1
fenster_neu4:   move.w  D0,4(A0)
                move.w  D1,6(A0)
                move.l  #wind_set,D0
                move.w  w_handle(PC),int_in
                move.w  #WF_CURRXYWH,int_in+2
                move.l  (A0),int_in+4
                move.l  4(A0),int_in+8
                bsr     aes
;Anzahl der Zellen in X- bzw. Y-Richtung
                move.l  #wind_get,D0
                move.w  w_handle(PC),int_in
                move.w  #WF_WORKXYWH,int_in+2
                bsr     aes
                move.w  int_out+6(PC),D0
                and.w   #3,D0
                sub.w   D0,4(A0)
                move.w  int_out+8(PC),D0
                and.w   #3,D0
                sub.w   D0,6(A0)
                move.l  #wind_set,D0
                move.w  w_handle(PC),int_in
                move.w  #WF_CURRXYWH,int_in+2
                move.l  (A0),int_in+4
                move.l  4(A0),int_in+8
                bsr     aes
;Anzahl der Zellen in X- bzw. Y-Richtung
                move.l  #wind_get,D0
                move.w  w_handle(PC),int_in
                move.w  #WF_WORKXYWH,int_in+2
                bsr     aes
                move.w  int_out+2(PC),x_koord
                move.w  int_out+4(PC),y_koord
                move.w  int_out+6(PC),width
                move.w  int_out+8(PC),heigth
                moveq   #0,D0
                move.w  width(PC),D0
                lsr.w   #2,D0           ;4 Pixel/Celle
                move.w  D0,x_zahl
                lea     x_anzahl(PC),A0
                lea     ziffer3(PC),A1
                bsr     itoa
                moveq   #0,D0
                move.w  heigth(PC),D0
                lsr.w   #2,D0           ;4 Pixel/Celle
                move.w  D0,y_zahl
                lea     y_anzahl(PC),A0
                lea     ziffer3(PC),A1
                bsr     itoa
                move.w  x_zahl(PC),D0
                mulu    y_zahl(PC),D0
                move.l  D0,gesamt_zahl
                move.l  #wind_set,D0
                move.w  w_handle(PC),int_in ;Handle eintragen
                move.w  #WF_NAME,int_in+2 ;nur Namen festlegen
                move.l  #fenster_name,int_in+4 ;Zeiger auf Fensternamen
                bsr     aes             ;WIND_SET()
                move.l  #vs_clip,D0
                move.w  #1,int_in
                move.l  x_koord(PC),D1
                move.l  D1,ptsin
                move.l  width(PC),ptsin+4
                add.l   D1,ptsin+4
                subi.l  #$00010001,ptsin+4
                bsr     vdi
efenster_neu:   rts

anfang_draw:    move.l  #graf_mouse,D0
                move.w  #M_OFF,int_in
                bsr     aes
                move.l  #wind_update,D0
                move.w  #BEG_UPDATE,int_in
                bsr     aes
                rts

ende_draw:      move.l  #wind_update,D0
                move.w  #END_UPDATE,int_in
                bsr     aes
                move.l  #graf_mouse,D0
                move.w  #M_ON,int_in
                bsr     aes
                rts
                ENDPART
                >PART 'Zeichenroutinen'

;neue Generation erzeugen und anzeigen
generate:       movem.l A5-A6,-(SP)
                move.l  count(PC),D7
                move.l  D7,D6           ;Anzahl der angesprochenen Zellen
                beq     egenerate
                movea.l life_stack(PC),A6
                movea.l elife_stack(PC),A5
generate_loop1: movea.l (A6)+,A0
                addq.l  #2,A0
                move.w  (A0)+,D5        ;Flags welche Adressen berÅcksichtigt werden sollen
                movea.l (A0)+,A1
                lsr.w   #1,D5           ;Adressen berÅcksichtigen
                bcc.s   generate_loop2
                addq.w  #2,(A1)
                bne.s   generate_loop2
                move.l  A1,(A5)+
                addq.l  #1,D6
generate_loop2: movea.l (A0)+,A1
                lsr.w   #1,D5           ;Adressen berÅcksichtigen
                bcc.s   generate_loop3
                addq.w  #2,(A1)
                bne.s   generate_loop3
                move.l  A1,(A5)+
                addq.l  #1,D6
generate_loop3: movea.l (A0)+,A1
                lsr.w   #1,D5           ;Adressen berÅcksichtigen
                bcc.s   generate_loop4
                addq.w  #2,(A1)
                bne.s   generate_loop4
                move.l  A1,(A5)+
                addq.l  #1,D6
generate_loop4: movea.l (A0)+,A1
                lsr.w   #1,D5           ;Adressen berÅcksichtigen
                bcc.s   generate_loop5
                addq.w  #2,(A1)
                bne.s   generate_loop5
                move.l  A1,(A5)+
                addq.l  #1,D6
generate_loop5: movea.l (A0)+,A1
                lsr.w   #1,D5           ;Adressen berÅcksichtigen
                bcc.s   generate_loop6
                addq.w  #2,(A1)
                bne.s   generate_loop6
                move.l  A1,(A5)+
                addq.l  #1,D6
generate_loop6: movea.l (A0)+,A1
                lsr.w   #1,D5           ;Adressen berÅcksichtigen
                bcc.s   generate_loop7
                addq.w  #2,(A1)
                bne.s   generate_loop7
                move.l  A1,(A5)+
                addq.l  #1,D6
generate_loop7: movea.l (A0)+,A1
                lsr.w   #1,D5           ;Adressen berÅcksichtigen
                bcc.s   generate_loop8
                addq.w  #2,(A1)
                bne.s   generate_loop8
                move.l  A1,(A5)+
                addq.l  #1,D6
generate_loop8: movea.l (A0)+,A1
                lsr.w   #1,D5           ;Adressen berÅcksichtigen
                bcc.s   egenerate_loop1
                addq.w  #2,(A1)
                bne.s   egenerate_loop1
                move.l  A1,(A5)+
                addq.l  #1,D6
egenerate_loop1:subq.l  #1,D7
                bne.s   generate_loop1
                movea.l life_stack(PC),A6
                lea     birth+2(PC),A5
                movea.l A6,A4
                lea     setzen1_MFDB(PC),A3
                lea     loeschen1_MFDB(PC),A2
show_gen_loop:  movea.l (A6)+,A0
                move.w  (A0),D0
                move.w  0(A5,D0.w),D0
                jmp     jmp_tab(PC,D0.w)
                OPT W-
jmp_tab:        bra.s   no_change_death
                bra.s   death_life
                bra.s   no_change_life
                bra.s   life_death
                OPT W+
no_change_life: move.w  #16,(A0)
                move.l  A0,(A4)+
                addq.l  #1,D7
                bra.s   eshow_gen_loop
life_death:     movea.l A2,A1
                move.w  cell_x(A0),D1
                move.w  cell_y(A0),D2
                move.w  #-2,(A0)
                bsr     draw_punkt
                bra.s   eshow_gen_loop
no_change_death:move.w  #-2,(A0)
                bra.s   eshow_gen_loop
death_life:     movea.l A3,A1
                move.w  cell_x(A0),D1
                move.w  cell_y(A0),D2
                move.w  #16,(A0)
                move.l  A0,(A4)+
                addq.l  #1,D7
                bsr     draw_punkt
eshow_gen_loop: subq.l  #1,D6
                bne.s   show_gen_loop
                move.l  A4,elife_stack
                move.l  D7,count
egenerate:      movem.l (SP)+,A5-A6
                rts

;Feld Komplett neu zeichnen
draw:           bsr     is_top
                bsr     anfang_draw
                bsr     redraw_rect
                bsr     ende_draw
                rts

;Feld teilweise neu zeichnen
redraw:         bsr     anfang_draw
                move.w  w_handle(PC),int_in
                move.w  #WF_WORKXYWH,int_in+2
                move.l  #wind_get,D0
                bsr     aes
                move.l  int_out+2(PC),D1
                move.l  int_out+6(PC),D2
                move.w  w_handle(PC),int_in
                move.w  #WF_FIRSTXYWH,int_in+2
redraw1:        move.l  #wind_get,D0
                bsr     aes
                move.l  int_out+2(PC),D3
                move.l  int_out+6(PC),D4
                tst.l   D4
                beq     end_redraw
                move.l  (A6),D5
                move.l  4(A6),D6
                add.l   D3,D4
                moveq   #1,D0
redraw2:        cmp.w   D5,D3
                bhi.s   redraw3
                move.w  D5,D3
redraw3:        swap    D5
                swap    D3
                dbra    D0,redraw2
                add.l   D6,D5
                moveq   #1,D0
redraw4:        cmp.w   D5,D4
                bcs.s   redraw5
                move.w  D5,D4
redraw5:        swap    D5
                swap    D4
                dbra    D0,redraw4
                sub.l   D3,D4
                tst.w   D4
                ble.s   redraw6
                swap    D4
                tst.w   D4
                ble.s   redraw6
                swap    D4
                swap    D7
                move.l  #vs_clip,D0
                move.w  #1,int_in
                move.l  D3,ptsin
                move.l  D4,ptsin+4
                add.l   D3,ptsin+4
                subi.l  #$00010001,ptsin+4
                bsr     vdi
                bsr.s   redraw_rect
                swap    D7
redraw6:        move.w  w_handle(PC),int_in
                move.w  #WF_NEXTXYWH,int_in+2
                bra     redraw1
end_redraw:     bsr     ende_draw
                rts

redraw_rect:    movem.l D0-D5/A0-A2,-(SP)
                move.w  D3,D2
                sub.w   y_koord(PC),D2
                lsr.w   #2,D2
                swap    D3
                move.l  D3,D1
                sub.w   x_koord(PC),D1
                lsr.w   #2,D1
                swap    D4
                move.w  D4,D3
                swap    D4
                addq.w  #4,D3
                lsr.w   #2,D3           ;/4
                addq.w  #4,D4
                lsr.w   #2,D4           ;/4
                movem.w D1-D2,-(SP)
                movea.l liste(PC),A0
                mulu    #entry,D1
                adda.l  D1,A0
                mulu    x_zahl(PC),D2
                mulu    #entry,D2
                adda.l  D2,A0
                movem.w (SP)+,D1-D2
                add.w   D3,D1
                move.w  x_zahl(PC),D0
                cmp.w   D1,D0
                bpl.s   redraw_rect3
                sub.w   D3,D1
                sub.w   D1,D0
                move.w  D0,D3
redraw_rect3:   add.w   D4,D2
                move.w  y_zahl(PC),D0
                cmp.w   D2,D0
                bpl.s   redraw_rect4
                sub.w   D4,D2
                sub.w   D2,D0
                move.w  D0,D4
redraw_rect4:   subq.w  #1,D3
                subq.w  #1,D4
redraw_rect_l1: movea.l A0,A2
                move.w  D3,D5
redraw_rect_l2: lea     loeschen1_MFDB(PC),A1
                cmpi.w  #-2,(A2)
                beq.s   redraw_rect_l3
                lea     setzen1_MFDB(PC),A1
redraw_rect_l3: move.w  cell_x(A2),D1
                move.w  cell_y(A2),D2
                bsr     draw_punkt
                lea     entry(A2),A2
                dbra    D5,redraw_rect_l2
                move.w  x_zahl(PC),D0
                mulu    #entry,D0
                adda.l  D0,A0
                dbra    D4,redraw_rect_l1
                movem.l (SP)+,D0-D5/A0-A2
                rts

set_punkt:      movea.l liste(PC),A0
                mulu    #entry,D1
                adda.l  D1,A0
                mulu    x_zahl(PC),D2
                mulu    #entry,D2
                adda.l  D2,A0
                cmpi.w  #-2,(A0)        ;lebt Zeile ?
                beq.s   eset_punkt      ;nein
                rts
eset_punkt:     addq.l  #1,count        ;eine lebende Zelle mehr
                move.w  #16,(A0)        ;Cell lebt
                movea.l elife_stack(PC),A1
                move.l  A0,(A1)+
                move.l  A1,elife_stack
                lea     setzen1_MFDB(PC),A1
                move.w  cell_x(A0),D1
                move.w  cell_y(A0),D2
                bra.s   draw_punkt
unset_punkt:    movea.l liste(PC),A0
                mulu    #entry,D1
                adda.l  D1,A0
                mulu    x_zahl(PC),D2
                mulu    #entry,D2
                adda.l  D2,A0
                cmpi.w  #-2,(A0)        ;lebt Zeile ?
                bne.s   eunset_punkt    ;ja
                rts
eunset_punkt:   move.l  count(PC),D7
                subq.l  #1,D7           ;eine lebende Zelle mehr
                move.l  D7,count
                movea.l life_stack(PC),A1
eunset_loop1:   cmpa.l  (A1)+,A0
                dbeq    D7,eunset_loop1
                movea.l A1,A2
                subq.l  #4,A1
                movea.l elife_stack(PC),A3
eunset_loop2:   cmpa.l  A1,A3
                beq.s   eunset_loop3
                move.l  (A2)+,(A1)+
                bra.s   eunset_loop2
eunset_loop3:   subq.l  #4,elife_stack
                move.w  #-2,(A0)        ;Cell ist Tod
                lea     loeschen1_MFDB(PC),A1
                move.w  cell_x(A0),D1
                move.w  cell_y(A0),D2
draw_punkt:     move.l  #vro_cpyfm,D0
                clr.l   ptsin
                move.l  #$00030003,ptsin+4
                add.w   x_koord(PC),D1
                move.w  D1,ptsin+8
                move.w  D1,ptsin+12
                addq.w  #3,ptsin+12
                add.w   y_koord(PC),D2
                move.w  D2,ptsin+10
                move.w  D2,ptsin+14
                addq.w  #3,ptsin+14
                move.l  A1,contrl+14
                move.l  #screen_MFDB,contrl+18
                move.w  #3,int_in
                bsr     vdi
                rts

test_punkt:     movem.w D1-D2,-(SP)
                movea.l liste(PC),A0
                mulu    #entry,D1
                adda.l  D1,A0
                mulu    x_zahl(PC),D2
                mulu    #entry,D2
                adda.l  D2,A0
                move.w  (A0),D0
                movem.w (SP)+,D1-D2
                rts
                ENDPART
                >PART 'Zeitroutinen'
zeit_init:      move.l  #menu_tnormal,D0
                move.w  #_funktion,int_in
                move.w  #1,int_in+2
                lea     _menu_main(PC),A0
                bsr     aes
                bsr     is_top
                bsr     anfang_draw
zeit_loop:      move.l  #evnt_multi,D0
                lea     message_puffer(PC),A0
                move.w  #%0000000000110011,int_in ;Tastatur, Mausknopf, Mitteilung, Timer
                move.w  #1,int_in+2     ;nur ein Klick
                move.w  #1,int_in+4     ;linke Tasten mask
                move.w  #1,int_in+6     ;linke Tasten state
                clr.l   int_in+28       ;0 Millisekunde
                bsr     aes             ;EVNT_MULTI()
                and.w   #%1111111111011111,D0
                bne.s   ezeit_init      ;nein
                jsr     (A5)            ;
                bra.s   zeit_loop
ezeit_init:     move.w  D0,-(SP)
                bsr     ende_draw
                move.w  (SP)+,D0
                bra     main_loop1

                ENDPART
                >PART 'FORM_DO'
do_dialog:      move.l  A0,-(SP)
                clr.w   _ob_copyok+10
                clr.w   _ob_regelok+10
                move.l  #form_center,D0
                movea.l (SP),A0
                bsr     aes
                move.l  int_out+2(PC),xobj
                move.l  int_out+6(PC),wobj
                move.l  #form_dial,D0
                move.w  #FMD_START,int_in
                move.l  xobj(PC),int_in+2
                move.l  wobj(PC),int_in+6
                move.l  xobj(PC),int_in+10
                move.l  wobj(PC),int_in+14
                bsr     aes
                move.l  #objc_draw,D0
                movea.l (SP),A0
                clr.w   int_in
                move.w  #8,int_in+2
                move.l  xobj(PC),int_in+4
                move.l  wobj(PC),int_in+8
                bsr     aes
                move.l  #form_do,D0
                clr.w   int_in
                movea.l (SP),A0
                bsr     aes
                move.l  #form_center,D0
                movea.l (SP)+,A0
                bsr     aes
                move.l  int_out+2(PC),xobj
                move.l  int_out+6(PC),wobj
                move.l  #form_dial,D0
                move.w  #FMD_FINISH,int_in
                move.l  xobj(PC),int_in+2
                move.l  wobj(PC),int_in+6
                move.l  xobj(PC),int_in+10
                move.l  wobj(PC),int_in+14
                bsr     aes
                rts
                ENDPART
                >PART 'Ende wie auch immer'
* irgendein Fehler ist aufgetaucht
error:          moveq   #0,D0
                lea     mist(PC),A0
                bsr     alert_box
                clr.w   -(SP)
                trap    #1              ;Pterm()
error_wind:     moveq   #0,D0
                lea     mist(PC),A0
                bsr     alert_box
                bra.s   exit1

exit:           move.l  mem(PC),D0
                beq.s   exit0
                move.l  D0,-(SP)
                move.w  #73,-(SP)       ;Mfree()
                trap    #1
                addq.l  #6,SP
*Zuerst Fenster schlieûen
exit0:          move.l  #wind_close,D0
                move.w  w_handle(PC),int_in ;Handle eintragen
                bsr     aes             ;WIND_CLOSE()
                move.l  #wind_delete,D0
                move.w  w_handle(PC),int_in ;Handle eintragen
                bsr     aes             ;WIND_DELETE()

*Menu lîschen
exit1:          move.l  #menu_bar,D0
                clr.w   int_in          ;Menu lîschen
                lea     _menu_main(PC),A0
                bsr     aes             ;MENU_BAR()
*virtuelle Worstation schlieûen
                moveq   #101,D0         ;schnelle Methode
                bsr     vdi             ;V_CLSVWK
*jetzt Applikation abmelden
                move.l  #appl_exit,D0
                bsr     aes             ;APPL_EXIT()
                clr.w   -(SP)
                trap    #1              ;Pterm()
                ENDPART
                >PART 'allg. unterprogramme'
************************************************************************
* Zahl in D0 dezimal nach A0 ausgeben                                  *
************************************************************************
itoa:           move.l  -(A1),D4        ;Anzahl der Ziffer
                moveq   #' ',D5         ;FÅllzeichen (vor der Zahl)
itoa1:          move.l  -(A1),D3
                subq.l  #4,A1           ;Anzahl der Ziffer Åberspringen
                moveq   #$D0,D2
itoa2:          sub.l   D3,D0
                dbmi    D2,itoa2
                neg.b   D2
                cmp.b   #'0',D2         ;Eine Null?
                beq.s   itoa4           ;dann vorher aber testen
                moveq   #'0',D5         ;Ab nun dÅrfen Nullen ausgegeben werden
itoa3:          move.b  D2,(A0)+
                add.l   D3,D0
                dbra    D4,itoa1
                moveq   #0,D0
                rts
itoa4:          move.b  D5,D2           ;Ersatzzeichen fÅr evtl.FÅhrungsnull
                tst.w   D4              ;letzte Position?
                bne.s   itoa3           ;Nein => normal ausgeben
                move.b  #'0',(A0)       ;sonst unbedingt eine Null ausgeben
                moveq   #0,D0
                rts

                DC.L 1,0,10,1,100,2
ziffer3:        DC.L 1000,3
ziffer4:        DC.L 10000,4
ziffer5:        DC.L 100000,5
ziffer6:

************************************************************************
* Dezimalzahl ab A0 nach D0 holen                                      *
************************************************************************
atoi:           moveq   #0,D0           ;Zahl erstmal lîschen
                moveq   #0,D1           ;da unten .W benutzt wird, auch lîschen
atoi1:          move.b  (A0)+,D1        ;Ziffer holen
                subi.b  #'0',D1         ;ASCII-Wert abziehen
                bmi.s   atoi2           ;war es ein Space? => nÑchste Ziffer
                mulu    #10,D0          ;Zahl nach ober schieben
                add.w   D1,D0           ;und letzte Ziffer dazu
atoi2:          dbra    D4,atoi1        ;Was das etwa schon alles?
                rts


************************************************************************
* form_alert A0 mit Default D0 aufrufen                                *
************************************************************************
alert_box:      movem.l D0/A0,-(SP)
                bsr.s   arrow
                movem.l (SP)+,D0/A0
                move.w  D0,int_in
                move.l  #form_alert,D0
                bra.s   aes             ;form_alert()

************************************************************************
* Mausform = Pfeil (normal)                                            *
************************************************************************
arrow:          moveq   #0,D0
                move.w  D0,int_in
                move.l  #graf_mouse,D0

************************************************************************
* AES-Aufruf                                                           *
* D0=Die ersten 4 EintrÑge im int_in-Array (Bytebreite!)               *
************************************************************************
aes:            movem.l D1-A6,-(SP)     ;besser retten, man kann nie wissen
                move.l  A0,addr_in
                lea     contrl(PC),A0
                clr.l   (A0)
                clr.l   4(A0)           ;int_in-Array lîschen
                movep.l D0,1(A0)        ;und die neuen Daten eintragen
                lea     aes_para_blk(PC),A0
                move.l  A0,D1
                move.w  #$00C8,D0
                trap    #2              ;AES aufrufen
                moveq   #0,D0
                move.w  int_out(PC),D0
                movem.l (SP)+,D1-A6
                rts
************************************************************************
* VDI-Aufruf                                                           *
* D0 = Die Eingabeparameter                                            *
*      Bit 24-31 = Opcode der Funktion                                 *
*      Bit 16-23 = LÑnge des Intin-Arrays                              *
*      Bit 8-15  = Identifikationsnummer fÅr Unter-Opcodes             *
*      Bit 0-7   = Anzahl der EintrÑge in ptsin                        *
* Die GerÑtekennung wird der Variable "gr_handle" entnommen.           *
************************************************************************
vdi:            movem.l D1-A6,-(SP)
                lea     contrl+2(PC),A0
                clr.w   (A0)+           ;alle Parameter lîschen
                clr.l   (A0)+
                clr.w   (A0)
                move.l  D0,-(SP)
                tst.b   (SP)            ;kein Opcode vorhanden? => Kurzformat
                addq.l  #4,SP
                bne.s   vdi1
                move.b  D0,1-8(A0)      ;Funktionsnummer in den Bits 0-7
                bra.s   vdi2            ;alle anderen Parameter sind 0!
vdi1:           move.b  D0,3-8(A0)      ;Anzahl der EintrÑge in ptsin
                lsr.w   #8,D0
                move.w  D0,10-8(A0)     ;Unter-Opcode
                swap    D0
                move.b  D0,7-8(A0)      ;Anzahl der EintrÑge in intin
                lsr.w   #8,D0
                move.w  D0,0-8(A0)      ;Funktionsnummer
vdi2:           move.w  vdi_handle(PC),12-8(A0) ;VDI-Handle
                lea     vdi_para_blk(PC),A0
                move.l  A0,D1
                moveq   #$73,D0
                trap    #2
                moveq   #0,D0
                move.w  int_out(PC),D0  ;int_out[0]
                movem.l (SP)+,D1-A6
                rts

;TOS version holen
get_tos_vers:   movea.l _sysbase.w,A0   ;_sysbase
                move.w  2(A0),tos_vers  ;tos version
                rts

;Fileselectorbox
file_select:    lea     inpath(PC),A0
                move.l  #insel,addr_in+4
                move.l  A4,addr_in+8
                move.w  #$0102,D0       ;letzte version ohne extended fileselect
                sub.w   tos_vers(PC),D0
                bpl.s   file_select1
                move.l  #fsel_exinput,D0
                bra.s   file_select2
file_select1:   move.l  #fsel_input,D0
file_select2:   bsr     aes
                beq.s   file_select_err
                move.w  int_out+2(PC),D0
                beq.s   file_select_ok
;Dateinamen zusammenbasteln
                lea     inpath(PC),A1   ;Zeiger auf gewÑhlten Pfad
                lea     f_name(PC),A2
file_select_l:  move.b  (A1)+,(A2)+
                bne.s   file_select_l
;Letzten '\' finden
                subq.l  #1,A2
file_select_l1: tst.b   -(A2)           ;Anfang erreicht ?
                beq.s   file_select_err
                cmpi.b  #'\',(A2)       ;ist es das richtige Zeichen ?
                bne.s   file_select_l1  ;nein
                addq.l  #1,A2           ;erstes Zeichen nach '\'
                lea     insel(PC),A1    ;Zeiger auf Dateinamen
file_select_l2: move.b  (A1)+,(A2)+     ;Zeichen vom Namen holen
                bne.s   file_select_l2  ;bei 0 Ende
                moveq   #-1,D0
file_select_ok: rts
file_select_err:moveq   #1,D0
                lea     no_file(PC),A0
                bsr     alert_box
                moveq   #0,D0
                rts

;Feld der Strukturen initialisieren
init_liste:     tst.w   changed         ;wurde geÑndert ?
                bne.s   init_liste1
                tst.w   changed1
                beq.s   einit_liste
init_liste1:    bsr     start_warten
                movea.l liste(PC),A0    ;Zeiger auf Feld
                moveq   #0,D1           ;Y-Koordinate
                move.w  y_zahl(PC),D7   ;Anzahl der Zeilen
                subq.w  #1,D7
init_list_l1:   moveq   #0,D0           ;X-Koordinate
                move.w  x_zahl(PC),D6   ;Anzahl der Spalten
                subq.w  #1,D6
init_list_l2:   bsr.s   make_cell       ;Struct fÅllen
                addq.w  #1,D0           ;nÑchste X-Position
                dbra    D6,init_list_l2
                addq.w  #1,D1           ;nÑchste Y-Position
                dbra    D7,init_list_l1
                clr.w   changed         ;keine énderungen
                clr.w   changed1
                bsr     ende_warten
einit_liste:    rts

;Liste lîschen
clear_liste:    movea.l liste(PC),A0    ;Zeiger auf Feld
                move.w  x_zahl(PC),D0
                mulu    y_zahl(PC),D0
clear_list_l:   move.w  #-2,(A0)
                lea     entry(A0),A0
                subq.l  #1,D0
                bne.s   clear_list_l
                rts

make_cell:      tst.w   changed1
                bne.s   make_cell1
                move.w  #-2,(A0)+
                move.w  nachbarn(PC),(A0)+
                bra.s   make_cell2
make_cell1:     addq.l  #2,A0
                move.w  nachbarn(PC),(A0)+
make_cell2:     movem.w D0-D1,-(SP)
                subq.w  #1,D1           ;eine Zeile drÅber
                subq.w  #1,D0           ;eine Spalte vorher
                bsr.s   set_cell        ;eintragen
                addq.w  #1,D0           ;nÑchste Spalte
                bsr.s   set_cell
                addq.w  #1,D0
                bsr.s   set_cell
                addq.w  #1,D1
                bsr.s   set_cell
                subq.w  #2,D0
                bsr.s   set_cell
                addq.w  #1,D1
                bsr.s   set_cell
                addq.w  #1,D0
                bsr.s   set_cell
                addq.w  #1,D0
                bsr.s   set_cell
                movem.w (SP),D0-D1
                lsl.w   #2,D0
                move.w  D0,(A0)+
                lsl.w   #2,D1
                move.w  D1,(A0)+
                movem.w (SP)+,D0-D1
                rts

;Adresse von einem Nachbarn eintragen
set_cell:       movem.w D0-D1,-(SP)
                tst.w   D0              ;linker Rand ?
                bpl.s   set_cell2       ;nein
                tst.w   form            ;Torus ?
                beq.s   set_cell1
                move.l  #dummy,(A0)+
                bra.s   eset_cell
set_cell1:      move.w  x_zahl(PC),D0
                subq.w  #1,D0
                bra.s   set_cell4
set_cell2:      cmp.w   x_zahl(PC),D0   ;rechter Rand ?
                bne.s   set_cell4       ;nein
                tst.w   form
                beq.s   set_cell3
                move.l  #dummy,(A0)+
                bra.s   eset_cell
set_cell3:      moveq   #0,D0
set_cell4:      tst.w   D1              ;oberer Rand ?
                bpl.s   set_cell6       ;nein
                tst.w   form
                beq.s   set_cell5
                move.l  #dummy,(A0)+
                bra.s   eset_cell
set_cell5:      move.w  y_zahl(PC),D1
                subq.w  #1,D1
                bra.s   set_cell8
set_cell6:      cmp.w   y_zahl(PC),D1   ;unterer Rand ?
                bne.s   set_cell8       ;nein
                tst.w   form
                beq.s   set_cell7
                move.l  #dummy,(A0)+
                bra.s   eset_cell
set_cell7:      moveq   #0,D1
;Adresse berechnen
set_cell8:      mulu    x_zahl(PC),D1
                mulu    #entry,D1
                mulu    #entry,D0
                add.l   D1,D0
                movea.l liste(PC),A1
                adda.l  D0,A1
                move.l  A1,(A0)+
eset_cell:      movem.w (SP)+,D0-D1
                rts
;Meldung warten
start_warten:   move.l  #form_center,D0
                lea     _tree_warten(PC),A0
                bsr     aes
                move.l  int_out+2(PC),xobj
                move.l  int_out+6(PC),wobj
                move.l  #form_dial,D0
                move.w  #FMD_START,int_in
                move.l  xobj(PC),int_in+2
                move.l  wobj(PC),int_in+6
                move.l  xobj(PC),int_in+10
                move.l  wobj(PC),int_in+14
                bsr     aes
                move.l  #objc_draw,D0
                clr.w   int_in
                move.w  #8,int_in+2
                move.l  xobj(PC),int_in+4
                move.l  wobj(PC),int_in+8
                lea     _tree_warten(PC),A0
                bsr     aes
                rts
;Wartemeldung weg
ende_warten:    move.l  #form_center,D0
                lea     _tree_warten(PC),A0
                bsr     aes
                move.l  int_out+2(PC),xobj
                move.l  int_out+6(PC),wobj
                move.l  #form_dial,D0
                move.w  #FMD_FINISH,int_in
                move.l  xobj(PC),int_in+2
                move.l  wobj(PC),int_in+6
                move.l  xobj(PC),int_in+10
                move.l  wobj(PC),int_in+14
                bsr     aes
                rts

is_top:         move.l  #wind_get,D0
                move.w  w_handle(PC),int_in
                move.w  #WF_TOP,int_in+2
                bsr     aes
                move.w  int_out+2(PC),D0
                cmp.w   w_handle(PC),D0
                beq.s   is_top1
                move.l  #wind_set,D0
                move.w  w_handle(PC),int_in
                move.w  #WF_TOP,int_in+2
                bsr     aes
                move.w  w_handle(PC),int_in
                move.w  #WF_WORKXYWH,int_in+2
                move.l  #wind_get,D0
                bsr     aes
                move.l  int_out+2(PC),D3
                move.l  int_out+6(PC),D4
                bsr     redraw_rect
is_top1:        move.w  w_handle(PC),int_in
                move.w  #WF_WORKXYWH,int_in+2
                move.l  #wind_get,D0
                bsr     aes
                move.l  #vs_clip,D0
                move.w  #0,int_in
                move.l  int_out+2(PC),D1
                move.l  D1,ptsin
                move.l  int_out+6(PC),ptsin+4
                add.l   D1,ptsin+4
                subi.l  #$00010001,ptsin+4
                bsr     vdi
                move.l  int_out+2(PC),D3
                move.l  int_out+6(PC),D4
                rts

;enige Dateioperationen
open:           clr.w   -(SP)
                move.l  A0,-(SP)
                move.w  #$003D,-(SP)
                trap    #1
                addq.l  #8,SP
                move.w  D0,f_handle
                rts

create:         clr.w   -(SP)
                move.l  A0,-(SP)
                move.w  #$003C,-(SP)
                trap    #1
                addq.l  #8,SP
                move.w  D0,f_handle
                rts

write:          move.l  A0,-(SP)
                move.l  D7,-(SP)
                move.w  f_handle(PC),-(SP)
                move.w  #$0040,-(SP)
                trap    #1
                lea     12(SP),SP
                rts

read:           move.l  A0,-(SP)
                move.l  D7,-(SP)
                move.w  f_handle(PC),-(SP)
                move.w  #$003F,-(SP)
                trap    #1
                lea     12(SP),SP
                rts

close:          move.w  f_handle(PC),-(SP)
                move.w  #$003E,-(SP)
                trap    #1
                addq.l  #4,SP
                rts

                ENDPART
                >PART 'data'
************************************************************************
* Hier beginnt der DATA-Bereich                                        *
************************************************************************
************************************************************************
* Nun ein paar wichtige Daten                                          *
************************************************************************
                DATA
aes_para_blk:   DC.L contrl
                DC.L global
                DC.L int_in
                DC.L int_out
                DC.L addr_in
                DC.L addr_out

vdi_para_blk:   DC.L contrl             ;Der VDI-Parameterblock
                DC.L int_in
                DC.L ptsin
                DC.L int_out
                DC.L ptsout

************************************************************************
* Ein paar allgemeine Variablendefinitionen                            *
************************************************************************
;titelzeile fÅr fileselect
titel_load:     DC.B 'Generation laden',0
                EVEN
;titelzeile fÅr fileselect
titel_save:     DC.B 'Generation speichern',0
                EVEN
;FÅr Fileselektor bei Dateioperationen
                DC.W 0
inpath:         DC.B '.\*.FLD',0
                DS.B 256
insel:          DC.B '*.FLD',0
                DS.B 8

inf_name:       DC.B 'GEMALIFE.INF',0

fenster_name:   DC.B ' Feldgrîûe:'
x_anzahl:       DC.B '000 x '
y_anzahl:       DC.B '000 ',0
                EVEN
;Definition des Punktes
setzen_MFDB:    DC.L setzen_image       ;Zeiger auf Aussehen
                DC.W 4,4                ;4 Pixel in X- und Y-Richtung
                DC.W 1                  ;1 Wort breit
                DC.W 1                  ;Standardformat
                DC.W 1                  ;1 Plane
                DC.W 0,0,0              ;reserviert
setzen_image:   DC.W %0110000000000000
                DC.W %1111000000000000
                DC.W %1111000000000000
                DC.W %0110000000000000
setzen1_MFDB:   DC.L setzen1_image
                DC.W 4,4
                DC.W 1
                DC.W 0
                DC.W 1
                DC.W 0,0,0
setzen1_image:  DS.B 32
;Definition des Punktes
loeschen_MFDB:  DC.L loeschen_image     ;Zeiger auf Aussehen
                DC.W 4,4                ;4 Pixel in X- und Y-Richtung
                DC.W 1                  ;1 Wort breit
                DC.W 1                  ;Standardformat
                DC.W 1                  ;1 Plane
                DC.W 0,0,0              ;reserviert
loeschen_image: DC.W %0000000000000000
                DC.W %0000000000000000
                DC.W %0000000000000000
                DC.W %0000000000000000
loeschen1_MFDB: DC.L loeschen1_image
                DC.W 4,4
                DC.W 1
                DC.W 0
                DC.W 1
                DC.W 0,0,0
loeschen1_image:DS.B 32

screen_MFDB:    DC.L 0

;Parameter
paras:
nachbarn:       DC.W neumann_mode       ;von Neumann
;Geburt bei 0..8 lebenden Nachbarn 0=nein
birth:          DC.W 0,0,0,2,0,0,0,0,0
;Tod bei 0..8 lebenden Nachbarn 0=ja
death:          DC.W 6,6,4,4,6,6,6,6,6
;Form 0=Torus
form:           DC.W 0
eparas:
dummy:          DC.W 1                  ;ungerade Zahl -> nie Null durch addition von 2

                ENDPART
                >PART 'Alert-Strings'
no_mem:         DC.B '[0][ Speicher reicht | leider nicht ][ Schade ]',0
                EVEN
no_acc:         DC.B '[0][ Gem-a-Life | darf nicht als | ACC laufen ][ Ich werd mich bessern ]',0
                EVEN
mist:           DC.B '[0][ Es ist leider ein | Fehler aufgetreten ][ kann man nicht Ñndern ]',0
                EVEN
no_file:        DC.B '[0][ Bei der Dateioperation ist | leider ein Fehler aufgetreten ][ vielleicht spÑter ]',0
                EVEN
file_loeschen:  DC.B '[1][ Datei schon vorhanden |  lîschen ? ][ Ja | Nein ]',0
                EVEN
file_not_found: DC.B '[0][ Datei nicht vorhanden ][ besser hinsehen]',0
                EVEN
                ENDPART
                >PART 'RSC Dialog'
_rsc:

_nobs           EQU 79
_nted           EQU 0
_nib            EQU 0
_nbb            EQU 0

* erzeugt von Rsc2S v1.01 Ω 1990 by Andreas Alich

* objects:
_titel          EQU 3
_datei          EQU 4
_funktion       EQU 5
_einstell       EQU 6
_wer            EQU 9
_load           EQU 18
_save           EQU 19
_quit           EQU 21
_single         EQU 23
_continue       EQU 24
_random         EQU 25
_grid           EQU 26
_clear          EQU 27
_regeln         EQU 29
_nachbar        EQU 30
_form           EQU 31
_parasave       EQU 32
_copyok         EQU 6
_life           EQU 3
_death          EQU 14
_regelok        EQU 23
_moore          EQU 3
_neumann        EQU 5
_torus          EQU 3
_rechteck       EQU 5
* trees:
_main           EQU 0
_copyrigh       EQU 1
_regel          EQU 2
_neigbour       EQU 3
_rand           EQU 4
_warten         EQU 5

_g_box          EQU 20
_g_text         EQU 21
_g_boxtext      EQU 22
_g_image        EQU 23
_g_userdef      EQU 24
_g_ibox         EQU 25
_g_button       EQU 26
_g_boxchar      EQU 27
_g_string       EQU 28
_g_ftext        EQU 29
_g_fboxtext     EQU 30
_g_icon         EQU 31
_g_title        EQU 32

_objects:

_menu_main:
_ob_0:
                DC.W -1,1,7,_g_ibox
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.B 0,0,%00000000,%00000000
                DC.W 0,0,92,25
_ob_1:
                DC.W 7,2,2,_g_box
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.B 0,0,%00010001,%00000000
                DC.W 0,0,92,513
_ob_2:
                DC.W 1,3,6,_g_ibox
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.B 0,0,%00000000,%00000000
                DC.W 2,0,44,769
_ob_titel:
                DC.W 4,-1,-1,_g_title
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.L _str_titel
                DC.W 0,0,13,769
_ob_datei:
                DC.W 5,-1,-1,_g_title
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.L _str_datei
                DC.W 13,0,8,769
_ob_funktion:
                DC.W 6,-1,-1,_g_title
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.L _str_funktion
                DC.W 21,0,12,769
_ob_einstell:
                DC.W 2,-1,-1,_g_title
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.L _str_einstell
                DC.W 33,0,11,769
_ob_7:
                DC.W 0,8,28,_g_ibox
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.B 0,0,%00000000,%00000000
                DC.W 0,769,92,19
_ob_8:
                DC.W 17,9,16,_g_box
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.B 0,-1,%00010001,%00000000
                DC.W 2,0,20,8
_ob_wer:
                DC.W 10,-1,-1,_g_string
                DC.B 0,%00000101
                DC.B 0,%00000000
                DC.L _str_wer
                DC.W 0,0,20,1
_ob_10:
                DC.W 11,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00001000
                DC.L _str_10
                DC.W 0,1,20,1
_ob_11:
                DC.W 12,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_11
                DC.W 0,2,20,1
_ob_12:
                DC.W 13,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_12
                DC.W 0,3,20,1
_ob_13:
                DC.W 14,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_13
                DC.W 0,4,20,1
_ob_14:
                DC.W 15,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_14
                DC.W 0,5,20,1
_ob_15:
                DC.W 16,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_15
                DC.W 0,6,20,1
_ob_16:
                DC.W 8,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_16
                DC.W 0,7,20,1
_ob_17:
                DC.W 22,18,21,_g_box
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.B 0,-1,%00010001,%00000000
                DC.W 15,0,16,4
_ob_load:
                DC.W 19,-1,-1,_g_string
                DC.B 0,%00000101
                DC.B 0,%00000000
                DC.L _str_load
                DC.W 0,0,16,1
_ob_save:
                DC.W 20,-1,-1,_g_string
                DC.B 0,%00000101
                DC.B 0,%00000000
                DC.L _str_save
                DC.W 0,1,16,1
_ob_20:
                DC.W 21,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00001000
                DC.L _str_20
                DC.W 0,2,16,1
_ob_quit:
                DC.W 17,-1,-1,_g_string
                DC.B 0,%00000101
                DC.B 0,%00000000
                DC.L _str_quit
                DC.W 0,3,16,1
_ob_22:
                DC.W 28,23,27,_g_box
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.B 0,-1,%00010000,%00000000
                DC.W 23,0,24,5
_ob_single:
                DC.W 24,-1,-1,_g_string
                DC.B 0,%00000101
                DC.B 0,%00000000
                DC.L _str_single
                DC.W 0,0,24,1
_ob_continue:
                DC.W 25,-1,-1,_g_string
                DC.B 0,%00000101
                DC.B 0,%00000000
                DC.L _str_continue
                DC.W 0,1,24,1
_ob_random:
                DC.W 26,-1,-1,_g_string
                DC.B 0,%00000101
                DC.B 0,%00000000
                DC.L _str_random
                DC.W 0,2,24,1
_ob_grid:
                DC.W 27,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_grid
                DC.W 0,3,24,1
_ob_clear:
                DC.W 22,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_clear
                DC.W 0,4,24,1
_ob_28:
                DC.W 7,29,32,_g_box
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.B 0,-1,%00010000,%00000000
                DC.W 35,0,16,4
_ob_regeln:
                DC.W 30,-1,-1,_g_string
                DC.B 0,%00000101
                DC.B 0,%00000000
                DC.L _str_regeln
                DC.W 0,0,16,1
_ob_nachbar:
                DC.W 31,-1,-1,_g_string
                DC.B 0,%00000101
                DC.B 0,%00000000
                DC.L _str_nachbar
                DC.W 0,1,16,1
_ob_form:
                DC.W 32,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_form
                DC.W 0,2,16,1
_ob_parasave:
                DC.W 28,-1,-1,_g_string
                DC.B 0,%00100101
                DC.B 0,%00000000
                DC.L _str_parasave
                DC.W 0,3,16,1

_tree_copyrigh:
_ob_33:
                DC.W -1,1,6,_g_box
                DC.B 0,%00000000
                DC.B 0,%00010000
                DC.B 0,2,%00010001,%00000000
                DC.W 1,1,26,9
_ob_34:
                DC.W 2,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_34
                DC.W 6,1,15,1
_ob_35:
                DC.W 3,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_35
                DC.W 1,2,23,1
_ob_36:
                DC.W 4,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_36
                DC.W 3,3,20,1
_ob_37:
                DC.W 5,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_37
                DC.W 8,4,9,1
_ob_38:
                DC.W 6,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_38
                DC.W 5,5,16,1
_ob_copyok:
                DC.W 0,-1,-1,_g_button
                DC.B 0,%00100111
                DC.B 0,%00000000
                DC.L _str_copyok
                DC.W 5,7,16,1

_tree_regel:
_ob_40:
                DC.W -1,1,23,_g_box
                DC.B 0,%00000000
                DC.B 0,%00010000
                DC.B 0,2,%00010001,%00000000
                DC.W 2,1,50,2060
_ob_41:
                DC.W 2,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_41
                DC.W 2,1,45,1
_ob_42:
                DC.W 12,3,11,_g_ibox
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.B 0,0,%00010001,%00000000
                DC.W 1,2,46,2050
_ob_life:
                DC.W 4,-1,-1,_g_boxchar
                DC.B 0,%10000001
                DC.B 0,%00000000
                DC.B '0',-1,%00010001,%00000000
                DC.W 0,1,1,1
_ob_44:
                DC.W 5,-1,-1,_g_boxchar
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.B '1',-1,%00010001,%00000000
                DC.W 3,1,4,1
_ob_45:
                DC.W 6,-1,-1,_g_boxchar
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.B '2',-1,%00010001,%00000000
                DC.W 8,1,4,1
_ob_46:
                DC.W 7,-1,-1,_g_boxchar
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.B '3',-1,%00010001,%00000000
                DC.W 13,1,4,1
_ob_47:
                DC.W 8,-1,-1,_g_boxchar
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.B '4',-1,%00010001,%00000000
                DC.W 18,1,4,1
_ob_48:
                DC.W 9,-1,-1,_g_boxchar
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.B '5',-1,%00010001,%00000000
                DC.W 23,1,4,1
_ob_49:
                DC.W 10,-1,-1,_g_boxchar
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.B '6',-1,%00010001,%00000000
                DC.W 28,1,4,1
_ob_50:
                DC.W 11,-1,-1,_g_boxchar
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.B '7',-1,%00010001,%00000000
                DC.W 33,1,4,1
_ob_51:
                DC.W 2,-1,-1,_g_boxchar
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.B '8',-1,%00010001,%00000000
                DC.W 38,1,4,1
_ob_52:
                DC.W 13,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_52
                DC.W 1,5,48,1
_ob_53:
                DC.W 23,14,22,_g_ibox
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.B 0,0,%00010001,%00000000
                DC.W 1,6,46,2050
_ob_death:
                DC.W 15,-1,-1,_g_boxchar
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.B '0',-1,%00010001,%00000000
                DC.W 1,1,4,1
_ob_55:
                DC.W 16,-1,-1,_g_boxchar
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.B '1',-1,%00010001,%00000000
                DC.W 6,1,4,1
_ob_56:
                DC.W 17,-1,-1,_g_boxchar
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.B '2',-1,%00010001,%00000000
                DC.W 11,1,4,1
_ob_57:
                DC.W 18,-1,-1,_g_boxchar
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.B '3',-1,%00010001,%00000000
                DC.W 16,1,4,1
_ob_58:
                DC.W 19,-1,-1,_g_boxchar
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.B '4',-1,%00010001,%00000000
                DC.W 21,1,4,1
_ob_59:
                DC.W 20,-1,-1,_g_boxchar
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.B '5',-1,%00010001,%00000000
                DC.W 26,1,4,1
_ob_60:
                DC.W 21,-1,-1,_g_boxchar
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.B '6',-1,%00010001,%00000000
                DC.W 31,1,4,1
_ob_61:
                DC.W 22,-1,-1,_g_boxchar
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.B '7',-1,%00010001,%00000000
                DC.W 36,1,4,1
_ob_62:
                DC.W 13,-1,-1,_g_boxchar
                DC.B 0,%00000001
                DC.B 0,%00000000
                DC.B '8',-1,%00010001,%00000000
                DC.W 41,1,4,1
_ob_regelok:
                DC.W 0,-1,-1,_g_button
                DC.B 0,%00100111
                DC.B 0,%00000000
                DC.L _str_regelok
                DC.W 2,9,44,2

_tree_neigbour:
_ob_64:
                DC.W -1,1,5,_g_box
                DC.B 0,%00000000
                DC.B 0,%00010000
                DC.B 0,2,%00010001,%00000000
                DC.W 1,1,27,2055
_ob_65:
                DC.W 2,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_65
                DC.W 2,1,22,1
_ob_66:
                DC.W 3,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_66
                DC.W 8,3,5,1
_ob_moore:
                DC.W 4,-1,-1,_g_boxchar
                DC.B 0,%00010101
                DC.B 0,%00000000
                DC.B '4',-1,%00010001,%00000000
                DC.W 16,3,3,1
_ob_68:
                DC.W 5,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_68
                DC.W 2,5,11,1
_ob_neumann:
                DC.W 0,-1,-1,_g_boxchar

                DC.B 0,%00110111
                DC.B 0,%00000000
                DC.B '8',-1,%00010001,%00000000
                DC.W 16,5,3,1

_tree_rand:
_ob_70:
                DC.W -1,1,5,_g_box
                DC.B 0,%00000000
                DC.B 0,%00010000
                DC.B 0,2,%00010001,%00000000
                DC.W 1,1,17,2055
_ob_71:
                DC.W 2,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_71
                DC.W 1,1,13,1
_ob_72:
                DC.W 3,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_72
                DC.W 4,3,5,1
_ob_torus:
                DC.W 4,-1,-1,_g_boxchar
                DC.B 0,%00010111
                DC.B 0,%00000000
                DC.B 0,-1,%00010001,%00000000
                DC.W 11,3,2,1
_ob_74:
                DC.W 5,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_74
                DC.W 1,5,8,1
_ob_rechteck:
                DC.W 0,-1,-1,_g_boxchar
                DC.B 0,%00110101
                DC.B 0,%00000000
                DC.B 0,-1,%00010001,%00000000
                DC.W 11,5,2,1

_tree_warten:
_ob_76:
                DC.W -1,1,2,_g_box
                DC.B 0,%00000000
                DC.B 0,%00010000
                DC.B 0,2,%00010001,%00000000
                DC.W 1,1,45,2053
_ob_77:
                DC.W 2,-1,-1,_g_string
                DC.B 0,%00000000
                DC.B 0,%00000000
                DC.L _str_77
                DC.W 15,1,12,1
_ob_78:
                DC.W 0,-1,-1,_g_string
                DC.B 0,%00100000
                DC.B 0,%00000000
                DC.L _str_78
                DC.W 4,3,37,1


_str_titel:     DC.B ' Gem-a-Life ',0
_str_datei:     DC.B ' Datei ',0
_str_funktion:  DC.B ' Funktionen',0
_str_einstell:  DC.B ' Parameter',0
_str_wer:       DC.B '  wat willste ?',0
_str_10:        DC.B '--------------------',0
_str_11:        DC.B '  Desk-Zubehôr 1  ',0
_str_12:        DC.B '  Desk-Zubehôr 2  ',0
_str_13:        DC.B '  Desk-Zubehôr 3  ',0
_str_14:        DC.B '  Desk-Zubehôr 4  ',0
_str_15:        DC.B '  Desk-Zubehôr 5  ',0
_str_16:        DC.B '  Desk-Zubehôr 6  ',0
_str_load:      DC.B '  Laden     ^L',0
_str_save:      DC.B '  Speichern ^S',0
_str_20:        DC.B '----------------',0
_str_quit:      DC.B '  Quit      ^Q',0
_str_single:    DC.B '  Singlestep        S',0
_str_continue:  DC.B '  Kontinuierlich    K',0
_str_random:    DC.B '  Zufallsgeneration R',0
_str_grid:      DC.B '  Grid              G',0
_str_clear:     DC.B '  Lîschen           L',0
_str_regeln:    DC.B '  Regeln    ^R',0
_str_nachbar:   DC.B '  Nachbarn  ^N',0
_str_form:      DC.B '  Form      ^F',0
_str_parasave:  DC.B '  Speichern S',0
_str_34:        DC.B 'Gem-a-Life V1.0',0
_str_35:        DC.B 'ist ein PD-Programm von',0
_str_36:        DC.B 'Ralf Biedermann @ HB',0
_str_37:        DC.B 'Ortfeld 3',0
_str_38:        DC.B 'W-2815 Langwedel',0
_str_copyok:    DC.B 'macht ja nichts',0
_str_41:        DC.B 'Geburt bei welcher Anzahl lebenden Nachbarn ?',0
_str_52:        DC.B 'öberleben bei welcher Anzahl lebenden Nachbarn ?',0
_str_regelok:   DC.B 'OK',0
_str_65:        DC.B 'Welche Nachbarschaft ?',0
_str_66:        DC.B 'Moore',0
_str_68:        DC.B 'von Neumann',0
_str_71:        DC.B 'Randverhalten',0
_str_72:        DC.B 'Torus',0
_str_74:        DC.B 'Rechteck',0
_str_77:        DC.B 'Bitte Warten',0
_str_78:        DC.B 'Es werden einige Felder initialisiert',0

                ENDPART
                >PART 'bss'
************************************************************************
* Und ordentlich BSS-Bereich                                           *
************************************************************************
                BSS
bss_start:
ap_id:          DS.W 1                  ;ID der Applikation
vdi_handle:     DS.W 1                  ;Die Handle der Bildschirm-Workstation
virt_handle:    DS.W 1
w_handle:       DS.W 1                  ;Window-Handle
f_handle:       DS.W 1

message_puffer: DS.B 16
puffer:         DS.B 16
xobj:           DS.W 2
wobj:           DS.W 2
max_x:          DS.W 1
max_y:          DS.W 1
max_w:          DS.W 1
max_h:          DS.W 1
max_w1:         DS.W 1
max_h1:         DS.W 1

x:              DS.W 1
x_zahl:         DS.W 1
y:              DS.W 1
y_zahl:         DS.W 1
x_koord:        DS.W 1
y_koord:        DS.W 1
width:          DS.W 1
heigth:         DS.W 1
x1:             DS.W 1
y1:             DS.W 1
x2:             DS.W 1
y2:             DS.W 1
gx:             DS.W 1
gy:             DS.W 1
gw:             DS.W 1
gh:             DS.W 1
base_page:      DS.L 1
changed:        DS.W 1
changed1:       DS.W 1
mem:            DS.L 1                  ;Zeiger auf reserviereten Speicher
liste:          DS.L 1                  ;Zeiger auf das Structfeld
life_stack:     DS.L 1                  ;Zeiger auf den Stack fÅr LIFE
elife_stack:    DS.L 1
count:          DS.L 1                  ;Anzahl der lebenden Zellen
gesamt_zahl:    DS.L 1
tos_vers:       DS.W 1                  ;TOS-Version
weiter:         DS.W 1
f_name:         DS.B 256
global:         DS.W 15
contrl:         DS.W 12
int_in:         DS.W 64
int_out:        DS.W 64
addr_in:        DS.L 16
addr_out:       DS.L 16
ptsin:          DS.W 64
ptsout:         DS.W 64
                DS.L 512                ;jedem Programm seinen eigenen Stack
own_stack:      DS.L 64
file_buffer:    DS.B 1000               ;maximum
bss_ende:
                ENDPART
                END
