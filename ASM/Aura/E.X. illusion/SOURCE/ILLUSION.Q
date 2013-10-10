*****************************************************************************
*                                                                           *
* "E.X Illusion" - DEMO-Source.                                             *
* Copyright Ω1995 Jochen Knaus, AURA.                                       *
*                                                                           *
* (This sourcecode can be copied freely (but only including ALL files), but *
*  it is not allowed to spread it in any PD-Pool, put it on ANY CD, or just *
*  sell it for any profit without asking me.)                               *
* (If you missed the demo on the "Transmission"-CD, it is just because they *
*  sell othermens work for 60 DM (about 45 US-$), and so...).               *
*                                                                           *
* The source-code is documented too well (but only in german, sorry), the   *
* demo is not re-compilable (as not all files are included), but you can use*
* seperate routines or parts in your own -UNCOMMERCIAL- programms, just     *
* credit me.                                                                *
* Separate parts are not optimized well, significant parts are (filling...) *
*                                                                           *
* Basierend auf dem 3D-System "sys_3".                                      *
* Fast alle Konstanten sind jetzt fix, da die Demoroutinen starr auf sie    *
* aufbauen (im puren Grafiksysten sind sie aber benutzbar!)                 *
*                                                                           *
* Konzept, Design, Code : Jochen Knaus (BDCannibal/AURA).                   *
* Musik                 : Dominik Bohn (DOMM/Animal Mine).                  *
* Grafiken              : Jan-Mathias Steinforth (JMS/Newline),             *
*                         Markus Hermann (Her/Mugwumps)                     *
* Additional Code       : Christian Cartus (ProtrackerPlayer)               *
*                         Axe (Ice-Packer/Depacker)                         *
*                                                                           *
* Version     : 1.00                                                        *
* Last Update : 01.05.95                                                    *
* Assembler   : Easy-Ass 4.x, Motorola 56k-Assembler                        *
* Monitor     : GrundsÑtzlich wird automatisch zwischen RGB/TV und VGA dif- *
*               ferenziert, eine spezielle Version mit VGA auf 55Hz kann er-*
*               zeugt werden (die Musi lÑuft dann halt schneller...).       *
*                                                                           *
*****************************************************************************

*****************************************************************************
* 3D-SYSTEM (DSP-Objekthandler, Interpol-Polygone...)                       *
* Start:      Im Juni nach dem Abitur... (Juni 1994)                        *
* Autor:      Jochen Knaus aka BDCannibal / AURA / Independent              *
* Version:    0.61                                                          *
* Update:     18.03.1995 (Objektextruder)                                   *
*****************************************************************************

*****************************************************************************
* Organisation der Objektverwaltung:                                        *
* Alle Objekte, Animationen, Objektinformationen und zugehîrige Routinen    *
* wurden aus <sys_3.q> entfernt. Es werden die beiden zusammengehîrigen     *
* Dateien:                                                                  *
*         <objekte.q>   - Alle Grundobjekte.                                *
*                         Labels: "anz_base_obj" - Anzahl Objekte (WORD)    *
*                                 "objekte"      - Pointerliste auf Objekte *
*         <worlds.q>    - Alle Animationen bzw. Objektfolgen und Routinen.  *
*                         Labels: "ex_worlds"    - Informationentabelle     *
*                                               (muû initialisiert werden)  *
*****************************************************************************

              MODUL     "f:\sys_3\illusion.tos"

              MC68030
              MC68881                     ; FPU-Code [integriert]

        PATH  "f:\lib\macros.030\"
              INCLUDE   "genmacro.q"      ; Allgemeine Makros.
              INCLUDE   "vide_mac.q"      ; Videosystem Makros.

an            EQU       TRUE
aus           EQU       FALSE

GAMEZONE      EQU       an                ; Programmversion ?
DINTRO        EQU       an                ; Intro ausfÅhren ?
COL_BOOM      EQU       aus               ; Speedanzeigen via $9800 an ?
INST_DSP_MOD  EQU       an                ; DSP Protrackerplayer ?
TASTATUR      EQU       aus               ; Komplette Tastaturabfrage ?
KEYPRESS      EQU       aus               ; Single-Step Frames ?
_55HZ         EQU       aus               ; VGA-Auflîsungen in 55Hz vertikal ?
FUTPLAY       EQU       aus               ; Future-Composer-Player ?
ONE_DATAFILE  EQU       aus               ; Ein Datenfile oder alles einzeln ?
DEBUG_INF     EQU       an                ; an == Debuginfos aus (ahem...)
OWN_ERR_HAN   EQU       aus               ; Eigene Exceptionhandler ?
CHK_FILES     EQU       an                ; Die Texte auf VerÑnderung checken ?

ANIM_BSS_SIZE EQU       5*10240           ; Grîûe des Rams des Animationssys.
DATA_SIZE     EQU       42*10240          ; Grîûe der Datenbereiche.
MOD_SIZE      EQU       34*10240          ; Grîûe des Modulebuffers.
PER_SIZE      EQU       5*10240           ; Grîûe des Rams fÅr stÑndige Daten.

CHANGE_RES    EQU       an                ; Videohardware umlegen ?
OWN_VBL       EQU       an                ; Eigener VBL ?
REAL_PALS     EQU       aus               ; Hell->dunkel Paletten ?
_CLR_SCR      EQU       aus               ; Bildschirm generell lîschen ?

ST_CONST      EQU       0                 ; Konstantes Shading. (Shadingtypen)
ST_LGTSOURCE  EQU       1                 ; Lightsourcing.

LIGHT_SRC     EQU       ST_CONST          ; 0: Volle Pal. // 1: Lightsource
_DETAIL       EQU       2                 ; 0: Linien // 1: Polygon // 2: Gouraud.
_PLANES       EQU       4                 ; Anzahl Planeausgabe Polygons.

_USE_FPU      EQU       0                 ; 0: ja (falls vorhanden)
_USE_BLITTER  EQU       1                 ; 0: ja (Screenclr...)

; Sichtbereich.
VISIBLE_X0    EQU       1                 ; Sichtfenster (Clippwerte)
VISIBLE_X1    EQU       319               ; Breite MUû Durch 16 teilbar sein.
VISIBLE_Y0    EQU       19
VISIBLE_Y1    EQU       219
SCR_DX        EQU       VISIBLE_X1-VISIBLE_X0+2 ; 0 rechnet mit, zÑhlt aber
SCR_DY        EQU       VISIBLE_Y1-VISIBLE_Y0   ; nicht mit...
MAUS_ABS      EQU       640               ; Absoluter Mausbereich

; Videosystem:
SCR_WIDE      EQU       320               ; Pixel pro Zeile
SCR_HIGH      EQU       240

BYTES_SCAN    EQU       2*SCR_WIDE        ; Bytes pro Zeile (inkl. Off.)
BYTES_SCREEN  EQU       640*SCR_HIGH
ADD_CLR_X     EQU       BYTES_SCAN
ANZ_SCREENS   EQU       13                ; Anzahl HC-Bildschirme (asynron)
_ANZ_VBLS     EQU       2                 ; Anzahl VBLs / gezeigtem Frame.
_CLR_OFF      EQU       VISIBLE_Y1*BYTES_SCAN+ADD_CLR_X

_16_BYTES_SCAN     EQU  SCR_WIDE/2        ; Selbigen Parameter fÅr 16-Farben-
_16_BYTES_SCREEN   EQU  160*SCR_HIGH      ; screen.
_16_ADD_CLR_X      EQU  _16_BYTES_SCAN
_16_ANZ_SCREENS    EQU  48                ; 1 Sekunde Animationsprecalc.
_16_ANZ_VBLS       EQU  1
_16_CLR_OFF        EQU  (VISIBLE_Y1+1)*_16_BYTES_SCAN

_256_BYTES_SCAN    EQU  SCR_WIDE          ; Selbigen Parameter fÅr 256-Farben-
_256_BYTES_SCREEN  EQU  320*SCR_HIGH      ; screen.
_256_ADD_CLR_X     EQU  _256_BYTES_SCAN
_256_ANZ_SCREENS   EQU  24
_256_ANZ_VBLS      EQU  1
_256_CLR_OFF       EQU  (VISIBLE_Y1+1)*_256_BYTES_SCAN

ANZ_SHD_COLS  EQU       32                ; Anzahl Farbschattierungen.
ANZ_PALETTEN  EQU       96                ; 96 Standartfarben
ANZ_BASE_FLA  EQU       3000              ; Anzahl FlÑchen in Grundobjekten.

; Objekt-/Polygonengine.
MAX_ANZ_ANIS     EQU    30                ; max. Anzahl Animationen.
MAX_ANZ_FACES    EQU    2000              ; max. Anzahl verwaltete Polygone
MAX_ANZ_PUNKTE   EQU    2000              ; max. Anzahl verwaltete Punkte
MAX_ANZ_OBJEKTE  EQU    100               ; max. Anzahl verwaltete Objekte
MAX_ANZ_PU_OBJ   EQU    200               ; max. Anzahl verwaltete Punkte/Obj.
WIDE_WORLD       EQU    32768             ; Durchmesser Welt / 2

; Objektflags Objektkoordinaten --> Weltkoordinaten.
STATIC        EQU       1                 ; Objekt wird direkt Åbernommen.
MOVE          EQU       -1                ; Objekt wird nur verschoben.
FULL          EQU       0                 ; Objekt wird rotiert und verschoben.

; Nachladen beim Gedichtanzeigen ?
LOAD          EQU       0
NOLOAD        EQU       1

; "OS": GEMDOS-Traps belassen, um sauberes Harddiskreload zu gewÑhrleisten.
GENERROR      EQU       8                 ; Hardwarerrortrap (!= 1,13,14)
STACKSIZE     EQU       512               ; RAM fÅr ssp, msp & isp

; Maussteuerung:
MAX_SPEED               EQU 30            ; max. Geschwindigkeit
MAX_BESCHLEUNIGUNG      EQU 2             ; max. Beschleunigung

; Farben:
XGA_16        EQU       0                 ; Farbumrechnungsmodell bei 16 Cols.
HINTERGRUND16 EQU       $0800003f         ; Hintergrundfarbe bei 16 Farben.
FARBE_15      EQU       $ff0000ff         ; "Vordergrund".
SET_START_PAL EQU       aus               ; an := Defaultpal. setzen.

; Demoeinstellungen:
MOD_PRESCALE  EQU       2                 ; Playerfrequenz Mainmod: 33KHz.
MOD_PRESCALE2 EQU       1                 ; Playerfrequenz Endtune: 50KHz
START_VOL     EQU       $ffff             ; Startvolume.
WAIT_FIN_MOD  EQU       aus               ; Im VBL warten, bis Tracker alle ?

; Setup-Dinge (z.B. Tasten, mit denen der User Einfluû nehmen kann):
SETUP_BIT     EQU       3                 ; Setup-Call (BIOS-Bel.): Alternate.
HIDDEN_BIT    EQU       4                 ; Hidden-Enable (  "   ): CapsLock.
DISPT_BIT     EQU       2                 ; Protracker-Disable    : Control.

POEM_SCAN     EQU       $01               ; Scancode der "Gedichts-Pausen-Taste"
ANZ_POEM      EQU       200               ; ~ VBLs stehen Gedichte min. stramm.

; Animationssystem:
HUNDERSTEL    EQU       an                ; Zeit bis auf 100stel genau ?
ANZ_RANDOM    EQU       100               ; Anzahl Zufallszahlen.

        IFEQ  (GAMEZONE-an)               ; Debug oder Finishversion ?
              OPT       D-,F-             ; Andere Optionen bringen fast nur
              bra.l     start             ; Probleme...

              INLINE    "f:\sys_3\demo\inl_txt1.txt"
              EVEN
        ELSE
              OPT       D+,F-
              bra.l     start             ; Lasset uns beginnen !
        ENDIF

        IFEQ  (OWN_VBL-aus)               ; Debuggerversion lÑuft mit
ANZ_SCREENS   SET       2                 ; syncronem Bildaufbau.
        ENDIF

paula:        ; Die PAULA fÅr's Demo: VBL tauglich und knackend...
        IFEQ  (INST_DSP_MOD-an)
              PATH      "F:\SUPPORT\DSPPAULA\DSPPAU_5.0HZ\"
              INCLUDE   "DSPPAV22.Q"
        ENDIF

        PATH  "f:\lib\tabellen\"          ; Library-Tabellen.
sinus720:     INLINE    "sin720.dat"      ; Sinustabelle (0.5)
mega_colours: INCLUDE   "colours.q"       ; Standartfarben

        PATH  "f:\sys_3\"                 ; Sys-3 internen ZusÑtze...
           IFEQ  (FUTPLAY-an)
              INCLUDE   "resource\futplay.s"    ; Future-Composer Player.
           ENDIF
              INCLUDE   "objects2.q"      ; Grundobj. Teil 2.
              INCLUDE   "objects.q"       ; Grundobj. Teil 1 und Basis.

        PATH  "f:\sys_3\resource"         ; Sys-3 internen ZusÑtze.
ice_decrunch: INLINE    "ice_dep.bin"     ; ICE-Depack-Rout 1 (Source/Dest)
ice_decrunch_2:
              INLINE    "ice_dec2.bin"    ; ICE-Depack-Rout 2 (Source=Dest)

        PATH  "f:\lib\"                   ; PMOD-LIBRARYMODULE:
              INCLUDE   "blit_clr.h"      ; Blitterlîschen.
              INCLUDE   "systest.h"       ; Ressourcentests.
              INCLUDE   "mouse.h"         ; Mausroutinen.
              INCLUDE   "trueline.h"      ; Linienroutine
              INCLUDE   "gouraud.h"       ; Gouraudroutine.
              INCLUDE   "hline_14.h"      ; 1-Plane-HLines auf 4 Plane-Screen.
              INCLUDE   "hline_18.h"      ; 1-Plane-HLines auf 8 Plane-Screen.
              INCLUDE   "hline_4.h"       ; 4-Planes-HLines auf 4 Plane-Screen.
              INCLUDE   "calc_col.h"      ; Farbverlaufsroutinen.
              INCLUDE   "polygon.h"       ; Polygonroutinen.
              INCLUDE   "dsp3dsys.h"      ; DSP-3D-System.

        PATH  "f:\sys_3\datainc\"         ; Pfad fÅr Datafiles
              INCLUDE   "bs0.lab"         ; Alle Datenlabel einbinden.
              INCLUDE   "bs_x1.lab"
              INCLUDE   "bs1.lab"
              INCLUDE   "bs2.lab"
              INCLUDE   "bs3.lab"
              INCLUDE   "bs4.lab"
              INCLUDE   "bs5.lab"
              INCLUDE   "bs6.lab"

        PATH  "f:\sys_3\"                 ; Sys-3 internen ZusÑtze...
              INCLUDE   "introex.q"       ; Intro und Extro und anderes.
              INCLUDE   "subrout1.q"      ; Allgem. Videosubroutinen.
              INCLUDE   "lc_shock.q"      ; Den kleinen Colourshock.
              INCLUDE   "worlds.q"        ; Animationsdaten
              INCLUDE   "subrout2.q"      ; Weitere Videohandlingrouts.

start:        pea       0.w               ; Kirk: "In Supervisor beamen."
              move.w    #32,-(sp)
              trap      #1
              addq.l    #6,sp
              move.l    sp,old_usp        ; <ssp> sichern.

              moveq     #0,d0             ; VBR-Hacker und Ripper ausknipsen,
              movec     d0,vbr            ; muû mit allen TOS Versionen funkt.

start_up:     lea       system,SYS_PARAS  ; Systemparameterblock.
              bsr.l     SYSTEST           ; System testen.
              bsr.l     FALCON_TEST       ; Falconhardware ?
              bne.w     no_falcon

              tst.b     (system+_MON)     ; Monchrommonitor ?
              beq.w     less_cols

              move      #$2700,sr
              lea       _ssp,a0                 ; Neue Stacks setzen.
              move.l    a0,sp                   ; Supervisorstack
              lea       STACKSIZE(a0),a0        ; Masterstack und IRQ-Stack
              movec     a0,msp
              lea       STACKSIZE(a0),a0
              movec     a0,isp

; ###########################################################################
; #                     UNTERROUTINENINITIALISIERUNG.....                   #
; # (inkl. den "letzten Gemdos-Calls vor der Autobahn" !).                  #
; ###########################################################################

              lea       start_time,a0           ; "Demostartzeit" festhalten.
              bsr.w     u_get_time

              bsr.w     exit_os                 ; "OS-last-calls": Sys. retten
              bsr.w     init_system             ; System Åbernehmen.

              move.w    #SCR_WIDE,IG_SCR_WIDE   ; Screenbreite
              move.w    #SCR_HIGH,IG_SCR_HIGH   ; Screenhîhe
              move.w    #ANZ_SHD_COLS,IG_ANZ_COLS   ; Schattierungstsufen
              lea       scr_offs,IG_SCAN_OFF    ; Scanoffsettabelle
              lea       l_koo,IG_LEFT_KOO       ; Linke Koordinaten
              lea       add_tab,IG_COL_DIST     ; Farbdistanzbuffer
              lea       add_poi,IG_COL_DIST_PO  ; Farbdistanzpointer
              lea       clipping,IG_CLIPPING    ; Clippbox
              bsr.l     INIT_GOURAUD            ; Gouraudroutine init.

              move.w    #2*SCR_WIDE,IG_BYTES_SCAN   ; Bytes pro Scan
              move.w    #SCR_HIGH,IG_SCR_HIGH
              lea       scr_offs,IG_SCAN_OFF
              bsr.l     BUILD_SC_OFFS           ; Screenoffsets generieren.

              movem.w   clipping,CLIPP_X1-CLIPP_Y2
              lea       scr_offs,SCANLINEOFF    ; Linienroutine initialisieren
              bsr.l     INIT_TRUELINE           ; (nach Scanoff.generierung!)

              moveq     #VISIBLE_X0-1,PGC_X0    ; Flat-Polygonclipping.
              move.w    #VISIBLE_X1,PGC_X1
              moveq     #VISIBLE_Y0,PGC_Y0
              move.w    #VISIBLE_Y1,PGC_Y1
              bsr.w     PG_CLIPP_INIT

              lea       h_routs,H16_ROUTBUF     ; 4-Plane HLine-Routs
              lea       h_tab,H16_OFFBUF        ; generieren.
              bsr.w     H16_BUILD

              lea       l_off,H16_LOFF          ; 4-Plane HLinetabellen
              lea       r_off,H16_ROFF          ; generieren.
              lea       tab_160,H16_LINOFF
              bsr.w     H16_OFF_TAB

              lea       l_off-16*4,a0           ; Kleiner Ausschluû von
              lea       l_off+H16_X_MAX*4,a1    ; Fehlern in der Offsettab.
              lea       r_off-16*4,a2
              lea       r_off+H16_X_MAX*4,a3
              move.l    l_off,d0
              move.l    r_off,d2
              move.l    l_off+(H16_X_MAX-1)*4,d1
              move.l    r_off+(H16_X_MAX-1)*4,d3
              moveq     #15,d7
cp_lp:        move.l    d0,(a0)+
              move.l    d1,(a1)+
              move.w    d2,(a2)+
              move.l    d3,(a3)+
              dbra      d7,cp_lp

              lea       l_off_1,H1_LEFT   ; 1-Plane HLinetabellen
              lea       r_off_1,H1_RIGHT  ; generieren.
              bsr.w     H1_BUILD
              lea       l_off_2,H18_LEFT  ; 1-Plane HLinetabellen fÅr 8 Pla.scr.
              lea       r_off_2,H18_RIGHT
              bsr.w     H18_BUILD

              moveq     #0,MO_CLIPP_X1          ; Clippbereich absolute Maus-
              moveq     #0,MO_CLIPP_X2          ; koordinate setzen, Startkoo-
              move.w    #MAUS_ABS,MO_CLIPP_Y1   ; in Mitte des Bereichs.
              move.w    MO_CLIPP_Y1,MO_CLIPP_Y2
              move.w    #MAUS_ABS/2,MO_START_X
              move.w    MO_START_X,MO_START_Y
              bsr.l     INSTALL_MOUSE     ; Maus initialisieren.

              move      #$2700,sr
              bsr.w     inst_screen       ; Videosystem init.

        IFEQ  (CHK_FILES-an)              ; Texte auf VerÑnderungen prÅfen ?
              bsr.w     chk_txts
        ENDIF

              clr.w     d0
              lea       module,a0         ; Mainmodule laden.
              bsr.w     new_ani_blk

              lea       per_base,a0       ; Permanenten Grafikdaten laden.
              bsr.w     load_next_blk

              suba.l    a0,a0             ; Die Introdaten laden (a0==0 -->
              bsr.w     load_next_blk     ; nach "mem_base" laden.

        IFEQ  (INST_DSP_MOD-an)           ; Mit oder ohne DSP-Tracker ?
              moveq     #0,DT_INST_ADS    ; Will User keinen Tracker ?
              tst.b     disable_pro(pc)   ; ja --> Nur ADS installieren.
              bne.s     innomus_ads
              bsr.w     init_music        ; Player installieren (VOR DSP-Init.)
              moveq     #-1,DT_INST_ADS
innomus_ads:  bsr.w     INIT_TRANS_DSP    ; DSP-Proggy rÅberschieben.
        ELSE
              moveq     #0,DT_INST_ADS    ; ADS mit installieren.
              bsr.w     INIT_TRANS_DSP
        ENDIF

              bsr.w     init_world        ; Globale Variablen init.
              bsr.w     install_col_tabs  ; Farbtabellen ber.
              bsr.w     obj_extrudes      ; Extrude-Objekte erzeugen.
              bsr.w     install_obj       ; Objektformat anpassen.

              move.l    #vbl,$70.w
              stop      #$2300            ; Erster VBL: Interrupts an.

        IFEQ  (DINTRO-an)                 ; Intro ausfÅhren ? (Debugging...)
              bsr.l     intro
        ELSE
              bsr.w     switch_16         ; Default sind 16 Farben.
        ENDIF

              moveq     #STARTANI,d0
              bsr.w     new_animat        ; Erste Animation starten.

; ###########################################################################
; #                     .....HAUPTSCHLEIFE.....                             #
; ###########################################################################
main:
        IFEQ  (KEYPRESS-an)               ; Auf Tastendruck warten ?
.wait_key:    move.b    $fffffc02.w,d0    ; Warten, bis <ESC> gedrÅckt und
              subq.b    #1,d0             ; wieder losgelassen wurde.
              bne.s     .wait_key

.wl:          btst      #7,$fffffc02.w
              beq.s     .wl
        ENDIF

        IFEQ  (ANZ_SCREENS-2)             ; Bei syncronem Bildaufbau auf
              bsr.w     vsync             ; StrahlenrÅcklauf warten.
              bsr.w     prep_screens      ; Bildschirmadr. tauschen...
        ENDIF
;             bsr.w     VBL_MOUSE         ; Maus loslassen.

        IFEQ  (_CLR_SCR-an)
              bsr.w     clr_screen        ; Bildschirm (ausschnitt) lîschen.
        ENDIF

              move.l    #$3911,d0         ; FÅr Framerout und BMP-Anis den
              movec     d0,cacr           ; Datencache an.

;             bsr.w     get_mouse         ; Mausbewegung auswerten.

              jsr       ([world_frame.w,pc])    ; Objektroutinen aufrufen.
              bsr.w     bmp_ani_sys       ; Mal schauen, was die Bitmaps machen.

              move.l    world_data(pc),a0 ; Weltarray.
              bsr.w     obj_handler       ; Objektverkneter.
;             bsr.w     get_boxes         ; Objektumrandungen berechnen.

              tst.b     debugging(pc)     ; Debugging eingeschaltet ?
              bne.s     no_deb_inf
              bsr.w     debug_infos       ; Debugginginfos setzen.
no_deb_inf:   bsr.w     ready_frame       ; Frame gesetzt.

              move.b    SCANCODE,d0       ; Tastatur.
        IFEQ  (TASTATUR-an)               ; Keyklicks auswerten.
              bsr.w     tast
        ENDIF

        IFNE  (GAMEZONE-aus)              ; Ende nur im Debuggermode...
              cmpi.b    #$39,d0           ; Die Ungedult in Person...
              bne.w     main              ; ...ist der der hier das Z bekommt.

ende:         illegal                     ; Debugger und dann weiter...
              bra.w     main
        ELSE
              bra.w     main              ; Weiter im frame.
ende:         jmp       $00e00000         ; Beim Ende resetten.
        ENDIF

*********************************************************************************
*  Verwaltet Bitmap-Animationen.                                                *
*********************************************************************************
bmp_ani_sys:  move.l    world_bmp(pc),d0  ; öberhaupt Animationen vorhanden ?
              bne.s     bmp_ani_runs      ; (world_bmp != 0)
ba_s_rts:     rts
bmp_ani_runs: tst.b     bmp_init(pc)      ; LÑuft bereits eine Ani ?
              beq.s     no_running

              move.l    d0,-(sp)
              bsr.w     run_ani           ; ja --> Bearbeiten.
              move.l    (sp)+,d0

no_running:   move.l    d0,a0
              adda.w    bmp_ani(pc),a0    ; Auf aktuellen Stand gehen.
              move.w    (a0)+,d0          ; Startframe.
              bmi.s     ba_s_rts          ; Startframe == 0 --> Nichts mehr.

              cmp.w     ani_frm(pc),d0    ; Animation starten ?
              bne.s     ba_s_rts
              addq.w    #6,bmp_ani        ; Auf nÑchste Ani.
              move.l    (a0),a0           ; Anidaten.
              movem.w   (a0)+,d0-d7/a3-a4
              movem.l   (a0),a0-a2
              bra.w     do_ani            ; Bitmapani initialisieren.

; ****************************************************************************
; * Nach berechnetem Frame logische Screenadressen anpassen (fÅr asyncrone   *
; * Bildschirmverwaltung).                                                   *
; ****************************************************************************
ready_frame:  addq.w    #1,frm_counter    ; Framecounter fÅr Syncro
              addq.w    #1,ani_frm        ; Relativer Framecounter fÅr BMP-Ani

              move.l    scr_lst(pc),a0
              movem.w   akt_scr,d0-d1
              addq.w    #1,d1             ; NÑchster log. Screen.
              cmp.w     _anz_screens,d1
              blt.s     no_swap2
              clr.w     d1
no_swap2:     cmp.w     d0,d1             ; Physikalischen Screens eingeholt ?
              bne.s     hurry_up

              tst.b     disable_sync(pc)  ; VBL-Adr.Sync gesperrt: Nicht
              bne.s     hurry_up          ; warten.

wait_f_sync:  cmp.w     akt_scr,d1        ; ja --> auf VBL warten.
              beq.s     wait_f_sync

hurry_up:     move.w    d1,akt_log
              move.l    ([scr_lst.l,pc],d1.w*4),d0
              move.l    d0,screen
              add.l     clr_off(pc),d0
              move.l    d0,clr_scr
              rts

no_falcon:    pea       no_falc
print_end:    move.w    #9,-(sp)          ; Beliebtes Spielchen: Textausgabe
              trap      #1                ; und Ende.
              addq.l    #6,sp

              move.w    #7,-(sp)
              trap      #1
              addq.l    #2,sp

              move.l    old_usp,-(sp)
              move.w    #32,-(sp)
              trap      #1
              addq.l    #6,sp

              move.l    #$ffff0000,-(sp)  ; PTERMRES, ohne Schutz, aber
              move.w    #31,-(sp)         ; mit Fehlernummer stoppen.
              trap      #1

less_cols:    pea       monochrome
              bra.s     print_end

no_falc:      DC.B      27,'E'
              DC.B      'Please restart on a Falcon030 or (hardware) compatible...',0
monochrome:   DC.B      27,'E'
              DC.B      'Please restart on any coloured monitor (RGB, TV or VGA)...',0
less_memory:  DC.B      27,'E'
              DC.B      'Less free ST-Ram. Please remove Accesorys and resident ',13,10
              DC.B      'programms.',0
              EVEN

*****************************************************************************
*             PROTRACKERMODULINITIALISIERUNG.                               *
*****************************************************************************
        IFEQ  (INST_DSP_MOD-an)           ; Nur wenn Modplayer vorhanden.
init_music:   lea       module,a0         ; Mainmod ist geladen.
              moveq     #MOD_PRESCALE,d0  ; Prescale
              moveq     #-1,d1            ; SSI
              moveq     #0,d2             ; VBL
              bsr.l     paula
              move.w    #START_VOL,main_voice   ; LaustÑrke relativ zivil.
              rts

music_test:   movem.l   d0-a6,-(sp)
              bsr.l     (paula+4)
              movem.l   (sp)+,d0-a6
              addq.w    #1,vbl_counter
              rte

; VBL zum Ausfaden des Trackers. Als Routine fÅr "world_vbl", blendet sich
; selbst aus, wenn Trackersound weg ist.
track_fo_vbl: moveq     #0,d0             ; (LautstÑrke ist <unsigned word>),
              move.w    main_voice,d0     ; deshalb das Ausfaden auf longword.
              sub.l     #$0090,d0
              bmi.s     tend_fo_vbl
              move.w    d0,main_voice
              rts
        ELSE
track_fo_vbl: clr.l     world_vbl         ; VBL ausknipsen.
              rts       
        ENDIF
tend_fo_vbl:  clr.l     world_vbl         ; VBL-Rout ausblenden.
              st        disable_pro       ; Tracker im VBL nicht mehr aufr.
              bra.l     (paula+8)         ; Music aus.


******************************************************************************
******************************************************************************
**            SUBROUTINEN DES GRAFIKSYSTEMS BZW. DESSEN VERWALTUNG.         **
******************************************************************************
******************************************************************************


*****************************************************************************
* Initialisiert 3D-System und Ausgabe fÅr bestimmte Animation.              *
* PARAS:      d0.w - Flag: Lîschen des kompletten VRams ? (!=0: clr)        *
*             d1.w - Videomode: (Line/Flat/Gouraud)                         *
*             d2.w - Planes: (nur bei Videomode 1): Anzahl Planes.          *
*             d3.w - Play-VBLs: Anzahl VBLs, mit denen syncronisiert wird.  *
*             a0.l - Pointer auf Blickwinkel und Beobachter (6.w)           *
*****************************************************************************
set_world:    tst.b     d0                ; VRAM-lîschen ?
              beq.s     no_clr_vram

              bsr.w     clr_screens

no_clr_vram:  cmp.b     planes(pc),d2
              bne.s     hw_switch
              cmp.b     detail(pc),d1     ; neuer = alter Videomode ?
              beq.s     no_hw_switch      ; ja --> kein Hardwareswitch.

hw_switch:    movem.l   d1-d3/a0,-(sp)    ; Hardwareswitch sichert nix.

              subq.b    #1,d1             ; 16-Farben Mode ?
              bne.s     _sw_65k           ; != 0 --> 65K-Farben...

              cmpi.w    #8,d2             ; 256-Farben Modus ?
              blt.s     sewo_sw16

              bsr.w     switch_256        ; Auf 256-Farben Modus gehen.
              bra.s     set_world_2

sewo_sw16:    bsr.w     switch_16         ; Auf 16 Farben gehen.
              bra.s     set_world_2

_sw_65k:      bsr.w     switch_32k        ; Auf 65K Farben gehen.
set_world_2:  movem.l   (sp)+,d1-d3/a0
no_hw_switch: move.b    d2,planes         ; Anzahl Planes.
              move.w    d3,anz_vbls       ; Play-VBLs.
              subq.w    #1,d3
              move.w    d3,akt_vbl        ; mîglichen.

              lea       beovek(pc),a6     ; Blickwinkel/Beobachter setzen.
              move.l    (a0)+,(a6)+
              move.l    (a0)+,(a6)+
              move.l    (a0)+,(a6)+

              clr.w     vbl_counter       ; Zur Sicherheit zurÅck, da nur word.
              rts

*****************************************************************************
* Neue Animationsstufe initialisieren.                                      *
* LABEL:                                                                    *
*   prev_ani: Animation vor Aktueller.                                      *
*   next_ani:      "   nach     "                                           *
*   new_animat: Bestimmte Animation:                                        *
*                 PARAMETER: d0.w - Animationsnummer.                       *
*****************************************************************************
prev_ani:     move.w    anim(pc),d0       ; Aktuelle Animation.
              beq.s     new_animat        ; Erste Animation ?

              subq.w    #1,d0             ; nein --> vorige Ani.
              bra.s     new_animat

next_ani:     move.w    anim(pc),d0       ; Aktuelle Animation.

              tst.l     (4+worlds.l,pc,d0.w*4)  ; Letzte Animation ?
              beq.s     new_animat        ;   ja --> Neu starten.
              addq.w    #1,d0             ; nein --> NÑchste Ani.

new_animat:   clr.l     bmp_ani           ; Bitmapani-Counter/Flags.

              move.w    d0,anim           ; Animationsnummer sichern.
              move.l    (worlds,d0.w*4),a1      ; GewÅnschte "Welt"
              lea       world,a0
              move.l    a1,(a0)+          ; World-Stuktur-Adresse
              move.l    (a1)+,(a0)+       ; Init  - Routine
              move.l    (a1)+,(a0)+       ; Frame -   "
              move.l    (a1)+,(a0)+       ; VBL   -   "
              move.l    (a1)+,(a0)+       ; Objektdaten.
              move.l    (a1)+,(a0)+       ; Bitmap-Animationsdaten.

              st        disable_sync      ; Screensync wÑhrend Init. aus.
              jsr       ([world_init.w,pc])     ; "object.init" (inkl. <rts>)
              clr.b     disable_sync      ; Screensync wieder an.
              rts

*****************************************************************************
* LÑdt Daten eines neuen Animationsblockes (KEINE Sicherheitsabfragen).     *
* PARAMETER:            d0.w  -  Nummer des Blockes.                        *
*                       a0.l  -  Zieladresse (falls a0==0 --> mem_base)     *
*****************************************************************************
load_next_blk:
              move.w    akt_blk(pc),d0          ; NÑchster Block.
              addq.w    #1,d0
              tst.l     (len_list.b,pc,d0.w*8)  ; Sollte etwa Fehler aufgetreten
              trapmi.w  #-1001                  ; sein ?

new_ani_blk:  move.l    a0,d1             ; a0.l == 0.l ?
              bne.s     no_default        ; nein --> explizite Adressangabe.

              lea       mem_base,a0       ; In den Datenbuffer lesen.

no_default:   move.w    d0,akt_blk        ; Aktuelle Blocknummer sichern.
              movem.l   (len_list.b,pc,d0.w*8),d1/a1    ; LÑnge und Filenamen
              bra.w     load_data                       ; File laden (Bei Fehler
                                                        ; globaler Abbruch !!!)

; Nachladelisten:       0.l  -  LÑnge des nachzuladenden Blockes.
;                       4.l  -  == 0 : Aus bereits geîffneter Datei lesen.
;                               != 0 : Datei mit Namen, auf den ~ zeigt, îffnen

TEXT1_LEN     EQU       1682
TEXT2_LEN     EQU       1682

RELOAD_MC     EQU       3
RELOAD_GB     EQU       4
RELOAD_SH     EQU       5
RELOAD_MZ     EQU       6
RELOAD_DS     EQU       7
RELOAD_WP     EQU       8
RELOAD_MUSIC  EQU       9
len_list:     DC.L      183941,module_1         ; MainMod: "Me and Mary Jane" (P)

       IFEQ   (ONE_DATAFILE-aus)
              DC.L      5762,permanent          ; Residente Grafiken. (P)
              DC.L      130610,int_data         ; Intro, Mathematica. (P)
              DC.L      88561,datafile_1        ; Megacubes, SW-Viel. (P)
              DC.L      376583,datafile_2       ; Gouraud-Proof, Dungeon
              DC.L      244605,datafile_4       ; Sternenhimmel (Mugani).
              DC.L      41548,datafile_5        ; Metronomzeit, Fading Objects. (P)
              DC.L      104088,datafile_6       ; Der Nachzieheffekt.
              DC.L      269263,datafile_7       ; World Plates, Extro.
       ELSE
              DC.L      5762,alldatas           ; Alle Daten aus einer Datei.
              DC.L      130610,0
              DC.L      88561,0
              DC.L      376583,0
              DC.L      244605,0
              DC.L      41548,0
              DC.L      104088,0
              DC.L      269263,0
       ENDIF
              DC.L      99427,module_2          ; Endmodule: "Another Illusion"

              DC.L      TEXT1_LEN,text1         ; Die beiden Texte laden.
              DC.L      TEXT2_LEN,text2

              DC.L      -1,-1                   ; Enkennung (fÅr Fehler...)

; Die Datenfiles.
module_1:     DC.B      'music\maryjane.mod',0  ; Main-Module (~240 KBytes).
alldatas:     DC.B      'datainc\bs.dat',0      ; Gesamte Demodaten.
permanent:    DC.B      'datainc\bs0.dat',0     ; Permanente Daten.
int_data:     DC.B      'datainc\bs_x1.dat',0   ; Introdaten, Mathematica
datafile_1:   DC.B      'datainc\bs1.dat',0     ; Megacubes 2, Swinging Viel
datafile_2:   DC.B      'datainc\bs2.dat',0     ; Gouraud-Proof, Dungeon-Expl.
datafile_4:   DC.B      'datainc\bs3.dat',0     ; Sternenhimmel.
datafile_5:   DC.B      'datainc\bs4.dat',0     ; Metronomzeit, Fading Objects.
datafile_6:   DC.B      'datainc\bs5.dat',0     ; Nachzieheffekt.
datafile_7:   DC.B      'datainc\bs6.dat',0     ; World Plates, Extro.
module_2:     DC.B      'music\illusion.mod',0  ; Endmod.
text1:        DC.B      'install.txt',0         ; Beide Demotexte.
text2:        DC.B      'illusion.txt',0
              EVEN

; ***************************************************************************
; * d0-d2: Winkeladds. a1,b1,c1 Ó (-720,720)                                *
; * a0   : Adresse dreier Winkel W.                                         *
; * Addiert (a,b,c) auf W und passt neuen Winkel auf (0,719) an.            *
; ***************************************************************************
rot_d03:      movem.w   d4-d7,-(sp)
              movem.w   (a0),d4-d6        ; Winkel holen.
              move.w    #720,d7           ; Bereichsgrenze.

              add.w     d0,d4
              bpl.s     no_mi_1
              add.w     d7,d4
no_mi_1:      cmp.w     d7,d4
              blt.s     no_pl_1
              sub.w     d7,d4
no_pl_1:      add.w     d1,d5
              bpl.s     no_mi_2
              add.w     d7,d5
no_mi_2:      cmp.w     d7,d5
              blt.s     no_pl_2
              sub.w     d7,d5
no_pl_2:      add.w     d2,d6
              bpl.s     no_mi_3
              add.w     d7,d6
no_mi_3:      cmp.w     d7,d6
              blt.s     no_pl_3
              sub.w     d7,d6
no_pl_3:      movem.w   d4-d6,(a0)        ; Winkel zurÅck.
              movem.w   (sp)+,d4-d7
              rts

; +-------------------------------------------------------------------------+
; | Objekthandler 1: Stellt alle Objektpunkte etc. zusammen (fÅr trans-     |
; | Objekte...)                                                             |
; |                                                                         |
; | a0.l - Worldarray:                                                      |
; |           0.w - Anzahl Objekte                                          |
; |           2.w - Nummer der Objektdaten                                  |
; |           4.w - Flag: Objekt um eigene Achse rotieren: 0.w - ja         |
; |                                                       >0.w - statisch   |
; |                                                       <0.w - translat   |
; |         6-a.w - [optional (wenn Flag != 0): Rotationswinkel]            |
; |       $c-10.w - [optional Translation (Verschiebung an Zielkoordinaten),|
; |                     wenn Objekt NICHT statisch]                         |
; +-------------------------------------------------------------------------+
obj_handler:  movem.l   d0-a6,-(sp)

        IFEQ  (INST_DSP_MOD-an)           ; Sollte DSP-Paula an Paralleljob
          IFNE  (WAIT_FIN_MOD-an)         ; hÑngen...
wait_f_dmod2: btst      #3,$ffffa202.w
              bne.s     wait_f_dmod2
           ENDIF
         ENDIF

              moveq     #$11,d0
              movec     d0,cacr

              st        dsp_works         ; DSP-Paula: Warten auf Ende.

              lea       obj_boxes,a6      ; Boxen um Objekte (werden berechn.)
              lea       polygons,a5       ; Polygonpointer
              lea       worldarray,a4     ; Weltbuffer (Punkte)
              lea       objekte,a3        ; Objektpointer
              clr.l     d6                ; Anz. Punkte. = 0
              move.w    d6,anz_faces
              move.w    (a0)+,d7          ; Anz.Obj.
              subq.w    #1,d7
              bpl.s     obj_exist

              moveq     #0,d0             ; Z-Bit setzen
              move.b    d0,dsp_works      ; DSP-Arbeitet nicht mehr.
              move.w    d0,anz_objekte
              movem.l   (sp)+,d0-a6       ; das ging aber schnell...
              rts

obj_exist:    move.w    d7,anz_objekte    ; Anz. Obj. minus 1
obj_loop:     move.w    (a0)+,d0          ; Objektnummer
              move.l    (a3,d0.w*4),a1    ; Objektstruktur
              move.w    (a1)+,d4          ; Anz. Faces
              move.w    (a1)+,d5          ; Anz. Punkte

              subq.w    #2,d5             ; Grîûenboxecken fallen auf jeden
              move.w    d5,-(sp)          ; Fall weg (2 Punkte)
;             traple.w  #-3               ; Nur Grîûenbox oder weniger Punkte?
              move.w    d5,(2+obj_p_off,d7.l*4) ; Anz. "echte" Punkte

              tst.w     (a0)+             ; Um eigene Achsen rotieren ?
              bne.s     no_i_rotate

              moveq     #16,d0            ; Umfang der Grîûenbox = 16 Bytes.
              adda.l    d0,a6             ; Platz fÅr Grîûenbox lassen, wird
              move.w    d6,(obj_p_off,d7.l*4)   ; Objektpunktoff. (pos.)
              add.l     (a1)+,d0          ; Objekturpunkte hinter Grîûenbox

              movem.l   d4/d6-d7/a1/a3-a6,-(sp) ; TRANS_DSP sichert nicht.

              lea       buf_para,a6       ; Parameterblock fÅr DSP-Transform
              move.w    d5,(a6)+          ; erzeugen.
              move.l    d0,(a6)+          ; Objekturpunkte
              move.l    a4,(a6)+          ; Destinationspunkte
              move.l    (a0)+,(a6)+       ; Winkel a,b
              move.l    (a0)+,(a6)+       ; Winkel c, Translation x
              move.l    (a0)+,(a6)+       ; Translation y,z
              move      a0,usp            ; a0 geupdated sichern

              lea       buf_para,DT_PARABLOCK
              moveq     #1,DT_TRANS_MODE  ; 3D-Return
              moveq     #2,DT_OFF_SOURCE  ; Farben in Quelle und Ziel Åber-
              moveq     #2,DT_OFF_DESTIN  ; gehen.
              bsr.w     TRANS_DSP

              move      usp,a0
              movem.l   (sp)+,d4/d6-d7/a1/a3-a6
              bra.w     points_world

no_i_rotate:  bgt.w     static_obj        ; Flag > 0 --> statisches Obj.

              pea       (a3)
              move.l    (a1)+,a2          ; Urpunkte
              move.l    a4,a3
              movem.w   (a0)+,d0-d2       ; Translation x/y/z

              IFNE      0
              move.l    (a2)+,(a6)        ; Die Grîûenbox des Objekts kann
              add.w     d0,(a6)+          ; Åbernommen werden, da sich an den
              add.w     d1,(a6)+          ; Grenzen nichts Ñndert (abgesehen
              move.l    (a2)+,(a6)+       ; Translation). Die Punktanzahl wird
              add.w     d2,-4(a6)         ; um die beiden Punkte reduziert.
              move.l    (a2)+,(a6)
              add.w     d0,(a6)+
              add.w     d1,(a6)+
              move.l    (a2)+,(a6)+
              add.w     d2,-4(a6)
              ELSE
              lea       4*4(a2),a2
              lea       4*4(a6),a6
              ENDIF

              move.w    #-1,(obj_p_off.l,d7.l*4)    ; Keine Berechung der Box.

              move.w    d5,d3
              asr.w     #2,d5
              subq.w    #1,d5
              bmi.s     rest_transl
transl_poi:
           REPEAT
              move.l    (a2)+,(a3)
              add.w     d0,(a3)+
              add.w     d1,(a3)+
              move.l    (a2)+,(a3)+
              add.w     d2,-4(a3)
           UNTIL #(4-1)
              dbra      d5,transl_poi
rest_transl:  andi.w    #3,d3
              subq.w    #1,d3
              bmi.s     poi_wor_a3
rest_tra_lp:  move.l    (a2)+,(a3)
              add.w     d0,(a3)+
              add.w     d1,(a3)+
              move.l    (a2)+,(a3)+
              add.w     d2,-4(a3)
              dbra      d3,rest_tra_lp
              bra.s     poi_wor_a3

; Statisches Objekt: Punkte direkt in Worldarray Åbernehmen.
static_obj:   pea       (a3)
              move.l    (a1)+,a2          ; Urpunkte

;             movem.l   (a2)+,d0-d3       ; Grîûenbox abzwacken
              lea       16(a2),a2
;             movem.l   d0-d3,(a6)
              lea       16(a6),a6
              move.w    #-1,(obj_p_off.l,d7.l*4)    ; Keine Berechung der Box.

              move.l    a4,a3             ; Destinationpunktebuffer
              move.w    d5,-(sp)
              asr.w     #2,d5
              ble.s     rest_po_co
              subq.w    #1,d5             ; Punkte kopieren, da sie nicht
copy_pu_lp:   ;REPEAT                     ; Åber die Objektrotation ins Welt-
              movem.l   (a2)+,d0-d3       ; array wanderten...
              movem.l   d0-d3,(a3)
              movem.l   (a2)+,d0-d3
              movem.l   d0-d3,16(a3)
              lea       32(a3),a3
              dbra      d5,copy_pu_lp
rest_po_co:   moveq     #3,d5
              move.w    (sp)+,d0
              and.w     d5,d0
              eor.w     d5,d0
              jmp       (rest_puco.b,pc,d0.w*4)
rest_puco:    REPEAT
              move.l    (a2)+,(a3)+       ; x/y
              move.l    (a2)+,(a3)+       ; z/Farbe
              UNTIL     #(3-1)
poi_wor_a3:   move.l    (sp)+,a3

points_world: add.w     d4,anz_faces      ; Mehr FlÑchen !

              move.w    d4,d5             ; FlÑchenadressen in Weltarray Åber-
              asr.w     #2,d4             ; nehmen...
              ble.s     rest_faces
              subq.w    #1,d4
buf_faces:    REPEAT
              move.l    (a1)+,(a5)+       ; Polygonadresse
              move.l    d6,(a5)+          ; passenden Punktoff. dazu
              UNTIL     #(4-1)
              dbra      d4,buf_faces
rest_faces:   moveq     #3,d4
              and.w     d4,d5
              eor.w     d4,d5
              jmp       (rest_fac_lp.b,pc,d5.w*4)
rest_fac_lp:  REPEAT
              move.l    (a1)+,(a5)+
              move.l    d6,(a5)+
              UNTIL     #(3-1)

              move.w    (sp)+,d4          ; Anz. Punkte
              add.w     d4,d6             ; Neue Anzahl Punkte
              lea       (a4,d4.w*8),a4    ; Neuer Stand im Weltarray.
              dbra      d7,obj_loop       ; NÑchstes Objekt.

; +---------------------------------------------------------------------------+
; | Jetzt die ganze "Welt" um den Beobachter drehen bzw. aus seiner Sichtweise|
; | berechnen, da er ja doch nicht der Mittelpunkt ist...                     |
; +---------------------------------------------------------------------------+

              lea       buf_para,a0       ; Parameterblock generieren.
              move.w    d6,(a0)+          ; Gesamtanz. Punkte
              move.l    #worldarray,(a0)+ ; Sourcepunkte
              move.l    #punkte,(a0)+     ; Destinpunkte
              movem.w   beovek(pc),d0-d5  ; Blickwinkel, Beobachter
              movem.w   d0-d5,(a0)

              moveq     #2,DT_OFF_SOURCE
              moveq     #4,DT_OFF_DESTIN
              move.w    anz_faces,DT_ANZ_FACES
              lea       visibles,DT_DEEPSORT
              lea       polygons,DT_POLYPOINT
              lea       buf_para,DT_PARABLOCK
              move.w    trnst_all(pc),DT_TRST_ALL
        IFEQ  (COL_BOOM-an)
              move.l    #$00ff00ff,$ffff9800.w
        ENDIF
              bsr.w     TRANS_WORLD
        IFEQ  (COL_BOOM-an)
              move.l    #$00000000,$ffff9800.w
        ENDIF

              move.w    d0,d7             ; Anz. sichtbarer FlÑchen.
              ble.w     alle_raus         ; Anz. < 0 => alle auûerhalb.

;=============================================================================
; VOR grafischer Ausgabe Parallelprozeû zuendebringen, da dieses eventuell den
; aktuellen logischen Screen lîschen soll....
;=============================================================================

              tst.w     PARALLEL_PRG(pc)  ; öberhaupt Parallelprozeû ?
              beq.s     no_p_prg

              movem.l   d0-a6,-(sp)
              bsr.w     FIN_P_PRG         ; Beenden.
              movem.l   (sp)+,d0-a6
no_p_prg:

;=============================================================================
; Die grafische Ausgabe des Frames.
; Nach Detailleveln wird hier zwischen Linien, Polygonen und Gourauds unter-
; schieden, sowie unter Shading und Festfarben.

; Sichtbarkeitliste ist "verkehrtherum": Das vorderste Polygon liegt an erster
; Stelle.
;=============================================================================
              subq.w    #1,d7
              lea       (2+visibles.l,d7.w*2),a4    ; Sichtbarkeitsarray
              lea       polygons,a3       ; Polygonarray
              lea       punkte,a2         ; Transf. Punkte

        IFEQ  (COL_BOOM-an)
              INDIC_ON
        ENDIF

              move.b    detail(pc),d0     ; Detailstufe:
              beq.w     draw_lines        ; 0 : Nur Linien.
              subq.b    #1,d0             ; 2 : Gouraud.
              beq.s     draw_flats        ; 1 : Nur flache Polys.

              tst.b     pals(pc)          ; Shadingart (Palette)
              bne.s     _real_pals

              lea       irr_pal_32k,a1    ; Farbe --> Farbe Verlauf.
              move      a1,usp
              bra.s     draw_polys

_real_pals:   lea       real_pal_32k,a1   ; Farbe --> Schwarz Verlauf.
              move      a1,usp

; ###########################################################################
; ###   Gouraudschattierte Polygon ausgeben, optional mit Shading (FPU)   ###
; ###########################################################################
draw_polys:   move.w    -(a4),d0          ; Polygonnummer
              movem.l   (a3,d0.w*8),a0/a1 ; Polygonadr. / Punkteoff.

              move.l    (a0),-(sp)              ; Farbinfo sichern.
              move.w    (a0),d1
              move      usp,a5                  ; DafÅr Palettenadr. eintragen.
              move.l    (a5,d1.w*4),(a0)
              lea       (a2,a1.l*8),DG_POINTS   ; Punkteadr.

              bsr.w     shade_points            ; Eckpunkte einshaden.
              move.l    a0,DG_POLY_STRUCT       ; Polygonstruktur.
              move.l    screen,DG_SCR_BASE      ; Screenadresse.
        IFEQ  (COL_BOOM-an)
              not.l     $ffff9800.w
        ENDIF
              jsr       DRAW_GOURAUD      ; Poly shaded rendern.
        IFEQ  (COL_BOOM-an)
              not.l     $ffff9800.w
        ENDIF

              move.l    (sp)+,(a6)        ; Alte Farbinfo zurÅck.

              dbra      d7,draw_polys     ; NÑchstes Poly...
              bra.w     alle_raus         ; Standartabgang

; ###########################################################################
; ###   Flache Flunderpolys mit 16 Farben (ohne slowly Highcolourmode).   ###
; ###########################################################################
draw_flats:   cmp.b     #8,planes         ; 256- oder 16-Farbenmode ???
              beq.w     draw_256

draw_flats16: move.w    -(a4),d0          ; Polygonnr.
              movem.l   d7/a2-a4,-(sp)
              movem.l   (a3,d0.w*8),a0-a1 ; Polygonadr. / Punkteoff.
              lea       (a2,a1.l*8),a5    ; Punkteadr.
              move.l    (a0)+,-(sp)       ; Farbe...
              move.w    (a0)+,PG_ANZ_EDG  ; Anz. Punkte...
              move.l    a0,PG_EDGES       ; Eckpunktnummern.
              lea       l_koo,PG_LEFT     ; Randbuffer.
              lea       r_koo,PG_RIGHT
              bsr.w     PG_CALC           ; Polygonkanten berechnen.
              bne.s     poly_out          ; Polygon komplett raus ?

              move.w    PG_MAX,d7         ; max_y
              sub.w     PG_MIN,d7         ; Hîhe des Polys.
              subq.w    #1,d7
              bmi.s     poly_out

              move.l    screen,a0         ; Screenadresse.
              adda.l    (tab_160,a2.w*4),a0
              lea       (r_koo,PG_MIN.w*2),a6   ; Parameter der HLine-Rout.
              lea       (l_koo,PG_MIN.w*2),a5   

              cmp.b     #4,planes         ; 4- oder 1- Plane ausgeben.
              beq.s     draw_4            ; 3: 1 Plane.

              moveq     #$07,d0           ; Zur Sicherheit auf drei Planes
              and.w     2(sp),d0          ; gebrenzen.
              adda.l    d0,a0             ; Plane einstellen.

              lea       r_off_1,a4        ; Polygon auf einer Plane ausgeben.
              lea       l_off_1,a3
              jsr       H1_FILL
              bra.s     poly_out

draw_4:       lea       r_off,a4
              lea       l_off,a3

              move.w    2(sp),d0          ; Farbe (0-15) (bereits *2)!
              movem.l   (h_tab.l,pc,d0.w*8),d3-d4/a1
              jsr       (a1)              ; HLineroutine.

poly_out:     addq.l    #4,sp             ; Farbe.
              movem.l   (sp)+,d7/a2-a4
              dbra      d7,draw_flats16
              bra.w     alle_raus         ; Standartabgang

draw_256:     move.w    -(a4),d0          ; Grîûtenteils analog "draw_flats16"
              movem.l   d7/a2-a4,-(sp)    ; im Einplane-Mode.
              movem.l   (a3,d0.w*8),a0-a1
              lea       (a2,a1.l*8),a5
              move.l    (a0)+,-(sp)
              move.w    (a0)+,PG_ANZ_EDG
              move.l    a0,PG_EDGES
              lea       l_koo,PG_LEFT
              lea       r_koo,PG_RIGHT
              bsr.w     PG_CALC
              bne.s     poly_out256

              move.w    PG_MAX,d7         ; max_y
              sub.w     PG_MIN,d7         ; Hîhe des Polys.
              subq.w    #1,d7
              bmi.s     poly_out256

              move.l    screen,a0
              adda.l    (tab_320.l,pc,a2.w*4),a0
              lea       (r_koo,PG_MIN.w*2),a6
              lea       (l_koo,PG_MIN.w*2),a5   

              moveq     #$07,d0
              and.w     2(sp),d0
              adda.l    d0,a0

              lea       r_off_2,a4        ; Hier die Einplane-HLinerout ben-
              lea       l_off_2,a3        ; utzen, die auf 8-Plane Screenori-
              jsr       H18_FILL          ; entierung eingerichtet ist.

poly_out256:  addq.l    #4,sp
              movem.l   (sp)+,d7/a2-a4
              dbra      d7,draw_256
              bra.w     alle_raus

; ###########################################################################
; ###     Objekte in schlichter (aber bunter) Liniengrafik ausgeben.      ###
; # Es wird anhand einer Liste ÅberprÅft, ob die Linien bereits gezeichnet  #
; # worden sind. Es ist langsam, da keine RÅckschlÅsse aus Polygonen auf Obj-
; # ekte sind und doppelte Linien nur in FlÑchen eines Objektes vorkommen   #
; # kînnen, aber immer noch schneller als das zeichnen.                     #
; ###########################################################################
draw_lines:   move.w    #-1,anz_doppel    ; Doppelliste initialisieren
draw_lin_lp:  move.w    -(a4),d0          ; Polygonnummer
              movem.l   (a3,d0.w*8),a0-a1 ; Polygonadr. / Punkteoff.
              lea       (a2,a1.l*8),a6    ; Punkteadr.

;             move.l    (a0)+,d5          ; Pointer auf Farbtabelle
;             bne.s     own_tab           ; Blau ?
              move.l    #bluecol,d5       ; ja -> Blau einsetzen.
own_tab:      move.l    d5,a5
              move.w    (a0)+,d6          ; Anzahl Eckpunkte (=Linien)
line_loop:    move.w    (a0)+,d0          ; P1
              move.w    (a0),d2           ; P2
              move      a0,usp
              move.l    (a6,d0.w*8),X1
              move.l    (a6,d2.w*8),X2

              lea       doppelline,a0     ; Linie schon gezeichnet ?
              move.w    anz_doppel,d4
              bmi.s     get_line
search_dop:   move.l    (a0),d5           ; M1
              cmp.l     d5,d0             ; P1 gleich ?
              bne.s     ni_p1_m1
              cmp.l     4(a0),d2          ; P2 gleich ?
              beq.s     nicht_zei         ; ja -> nicht zeichnen

n_tag:        addq.l    #8,a0             ; NÑchstes Punktepaar
              dbra      d4,search_dop
get_line:     move.l    d0,(a0)+          ; Neu: Sichern...
              move.l    d2,(a0)
              addq.w    #1,anz_doppel     ; ...Anzahl erhîhen.
              bra.s     zeichnen

ni_p1_m1:     cmp.l     d5,d2             ; P2 = M1 ?
              bne.s     n_tag
              cmp.l     4(a0),d0          ; P1 = M2 ?
              bne.s     n_tag
              bra.s     nicht_zei         ; ja -> nicht zeichnen

zeichnen:     move.w    X1,Y1             ; P1.y
              move.w    X2,Y2             ; P2.y
              swap      X1                ; P1.x
              swap      X2                ; P2.x
              move.w    (a5),TL_COLOUR    ; Farbe (Farbe 0 in Tabelle)
              move.l    screen,TL_SCR_BASE
              bsr.l     TRUELINE          ; Linie zeichnen.
nicht_zei:    move      usp,a0
              dbra      d6,line_loop      ; NÑchste Linie
              dbra      d7,draw_lin_lp    ; NÑchstes Polygon

alle_raus:    
        IFEQ  (COL_BOOM-an)
              INDIC_OFF
        ENDIF
              clr.b     dsp_works         ; DSP-Paula wieder parallel.
              movem.l   (sp)+,d0-a6
              rts

bluecol:      DC.W      $001f             ; Blau

;=============================================================================
; Shadet Eckpunkte eines Polygons ein.
; Wirkliches Shading mit FPU, Pseudoshading mit konstanten Werten bei MC only.

; a0 - Polygonadresse
; a1 - Punkteoffset (fÅr 3D-Punkteshading benîtigt)
; a5 - Punkteadresse
;=============================================================================
shade_points: movem.l   d7-a6,-(sp)
              addq.l    #4,a0                   ; Farbe spielt keine Rolle.
              move.w    (a0)+,d0                ; Anzahl Punkte - 1

              tst.b     shading                 ; Shaden ?
              beq.s     mc_pseudo

              tst.b     (system+_FPU)(pc)       ; FPU vorhanden ?
              bne.s     real_shade              ; Wirklich einshaden.

mc_pseudo:    lea       (4.b,a0,d0.w*2),a1          ; auf Festshades gehen.
pseudo_shade: move.w    (a0)+,d1                ; Punktnummer
              move.w    (a1)+,(4.b,a5,d1.w*8)   ; Farbwerte Åbertragen.
              dbra      d0,pseudo_shade

              movem.l   (sp)+,d7-a6
              rts

; Mal richtig mit Lichtquelle einshaden ! (Phong-Shade auf jeden Eckpunkt)
; Wegen Wurzel wird FPU benîtigt, SEHR langsam.
real_shade:   move.w    d0,-(sp)
              moveq     #ANZ_SHD_COLS-2,d0      ; Anzahl Shadingfarben
              fmove.w   d0,fp7            ; In der FPU parken.

; Normalenvektor des Polygons bestimmen (Kreuzprodukt Åber zwei in der Ebene
; liegende Vektoren (zwischen 3 Ebenenpunkten aufgespannt)).
              lea       (worldarray,a1.l*8),a2
              movem.w   (a0),d5-d7        ; Punktenummern A,B,C
              movem.w   (a2,d5.w*8),a3-a4/a6    ; A(x/y/z)
              movem.w   (a2,d6.w*8),d0-d2 ; B(x/y/z)
              movem.w   (a2,d7.w*8),d3-d5 ; C(x/y/z)
              sub.w     a3,d0             ; vˇ = (bx - ax)
              sub.w     a4,d1             ;      |by - ay|
              sub.w     a6,d2             ;      (bz - az)
              sub.w     a3,d3             ; wˇ = (cx - ax)
              sub.w     a4,d4             ;      |cy - ay|
              sub.w     a6,d5             ;      (cz - az)

              lea       lp,a1             ; Buffer fÅr LPˇ
              move.w    d1,d6             ; vy * wz
              muls.w    d5,d6
              move.w    d2,d7             ; vz * wy
              muls.w    d4,d7
              sub.l     d7,d6             ; x = (vy*wz-vz*wy)
              move.l    d6,(a1)+
              fmove.l   d6,fp0            ; nˇ.x

              move.w    d2,d6             ; vz * wx
              muls.w    d3,d6
              move.w    d0,d7             ; vx * wz
              muls.w    d5,d7
              sub.l     d7,d6             ; y = (vz*wx-vx*wz)
              move.l    d6,(a1)+
              fmove.l   d6,fp1            ; nˇ.y

              move.w    d0,d6             ; vx * wy
              muls.w    d4,d6
              move.w    d1,d7             ; vy * wx
              muls.w    d3,d7
              sub.l     d7,d6             ; z = (vx*wy-vy*wx)
              move.l    d6,(a1)+
              fmove.l   d6,fp2            ; nˇ.z

              fsglmul.x fp0,fp0           ; |nE| Berechnen: SQR(x^2+y^2+z^2),
              fsglmul.x fp1,fp1           ; wobei die Wuzel erst kombiniert
              fsglmul.x fp2,fp2           ; in der Schleife gezogen wird.
              fadd.x    fp1,fp0
              fadd.x    fp2,fp0           ; fp0: Summe unter Wurzel.

              move.w    (sp)+,d0          ; Anzahl Punkte minus 1
shade_fpu:    move.w    (a0)+,d1          ; Punktnummer
              movem.w   (a2,d1.w*8),d2-d4 ; P(x/y/z)

              movem.w   lightsource,a3-a4/a6    ; (PL)ˇ: Vektor vom Punkt zur
              sub.w     a3,d2             ; Lichtquelle.
              fmove.w   d2,fp3            ; FPU-Parallelverarbeitung ausnutzen
              sub.w     a4,d3
              fmove.w   d3,fp4
              sub.w     a6,d4
              fmove.w   d4,fp5
              ext.l     d2
              ext.l     d3
              ext.l     d4

; Beide Rechnungen ineinander verschachtelt, da so ein bissle die bescheidenen
; "ParallelkÅnste" der FPU ausgenutzt werden.
              lea       -12(a1),a1        ; SkalarproduktzÑhler
              fsglmul.x fp3,fp3           ; lp.x^2
              muls.l    (a1)+,d2          ; n.x * (LP)ˇ.x
              fsglmul.x fp4,fp4           ; lp.y^2
              muls.l    (a1)+,d3          ; n.y * (LP)ˇ.y
              fsglmul.x fp5,fp5           ; lp.z^2
              muls.l    (a1)+,d4          ; n.z * (LP)ˇ.z
              fadd.x    fp4,fp3           ; lp.x^2+lp.y^2
              add.l     d2,d3
              fadd.x    fp5,fp3           ; lp.x^2+lp.y^2+lp.z^2
              add.l     d3,d4
              fmove.l   d4,fp6            ; ZÑhler komplett

              fsglmul.x fp0,fp3           ; SQR(a)*SQR(b) = SQR(a*b)
              fsglmul.x fp7,fp6           ; ZÑhler * Anz. Farben
              fsqrt.x   fp3               ; Skalarproduktnenner
              fsgldiv.x fp3,fp6           ; cos(‡/2) (Ergebnis Ó {-1;1})
              fabs.x    fp6               ; ‡ Ó {0;1}
              fmove.w   fp6,d7            ; Farbe in 030 holen
              neg.w     d7
              addi.w    #30,d7
;             addq.w    #1,d7             ; HLines leicht ungenau:ausgleichen.
              cmpi.w    #ANZ_SHD_COLS-2,d7
              ble.s     in_borders
              moveq     #ANZ_SHD_COLS-2,d7
in_borders:   move.w    d7,(4.b,a5,d1.w*8)      ; Farbe setzen.
              dbra      d0,shade_fpu

              movem.l   (sp)+,d7-a6
              rts

;=============================================================================
; Boxen um Objekte feststellen (fÅr Kollisionstests).
; Die Boxen werden nur fÅr Objekte berechnet, die sich selber im Raum bewegen
; und rotieren. Von allen anderen wird (im Objekthandler) die feste Umrand-
; ungsbox Åbernommen (negativer Punkteoffset!)
;=============================================================================
get_boxes:    movem.l   d0-a6,-(sp)

              move.w    anz_objekte,d7    ; Anzahl Objekte (-1)
              bmi.s     no_boxes
              lea       worldarray,a6     ; Punktebuffer
              lea       (obj_p_off.l,d7.w*4),a5 ; Objektepunkteoffs.
              lea       obj_boxes,a4      ; Boxen um Objekte
              move.w    #WIDE_WORLD-1,d0  ; max_Initit: klein
get_box_obj:  move.w    (a5),d1           ; Offset...
              bmi.s     next_box

              lea       (worldarray,d1.w*8),a6  ; Punkteadressen

              move.w    #-WIDE_WORLD,d1   ;               groû
              move.w    d0,d2             ; min_x
              move.w    d1,d3             ; max_x
              move.w    d0,a0             ; min_y
              move.w    d1,a1             ; max_y
              move.w    d0,a2             ; min_z
              move.w    d1,a3             ; max_z
              move.w    2(a5),d1          ; Anz. Punkte
              subq.w    #1,d1
get_box_pu:   movem.w   (a6),d4-d6        ; x/y/z
              addq.l    #8,a6

              cmp.w     d2,d4             ; min_x ?
              bge.s     nnmi_x
              move.w    d4,d2
nnmi_x:       cmp.w     d3,d4             ; max_x ?
              ble.s     nnma_x
              move.w    d4,d3
nnma_x:       cmp.w     a0,d5             ; min_y ?
              bge.s     nnmi_y
              movea.l   d5,a0
nnmi_y:       cmp.w     a1,d5             ; max_y ?
              ble.s     nnma_y
              movea.l   d5,a1
nnma_y:       cmp.w     a2,d6             ; min_z ?
              bge.s     nnmi_z
              movea.l   d6,a2
nnmi_z:       cmp.w     a3,d6             ; max_z ?
              ble.s     nnma_z
              movea.l   d6,a3
nnma_z:       dbra      d1,get_box_pu

              movem.w   d2/a0/a2,(a4)     ; B1(min_x|min_y|min_z)
              movem.w   d3/a1/a3,8(a4)    ; B2(max_x|max_y|max_z)

next_box:     lea       16(a4),a4         ; 8 Bytes / Punkte
              subq.l    #4,a5             ; NÑchstes Objekt
              dbra      d7,get_box_obj    ; NÑchste Box.

no_boxes:     movem.l   (sp)+,d0-a6
              rts


*****************************************************************************
* Videohandling zwischen den Frames, syncro mit VBL.                        *
* Tauscht Screenadressen, initialisiert Lîschadressen etc.                  *
*****************************************************************************
prep_screens: 
         IFEQ (ANZ_SCREENS-2)             ; Screenliste ?
              lea       screen,a0         ; Screenadressen tauschen.
              movem.l   (a0),d0-d1        ; (Momentan nur 2 logische Videorams
              exg       d0,d1             ; mîglich)
              movem.l   d0-d1,(a0)

              SET_V_ADR d1,d2             ; phy. Screen setzen.

              add.l     #CLR_OFF,d0
              move.l    d0,clr_scr        ; Lîschadresse (Ende !)

; Umrechnung des Wetters, Zeit etc. in Hintergrundfarbe.
              move.w    #$3333,hintergrund

;             pea       0.w               ; DSP: Keine Parallelrout.
;             bsr.w     INIT_PARALLEL     
         ENDIF
              rts

*****************************************************************************
* Beliebigen Speicherbereich lîschen (via Software oder mit Blitter).       *
* Speicherbereich > 208 Bytes.                                              *
* PARAMETER:  a0.l      - Startadresse.                                     *
*             a1.l      - Endadresse.                                       *
*****************************************************************************
clr_mem:      tst.b     use_blitter(pc)   ; Mit Blitter lîschen ???
              beq.l     BLITTER_CLR

              movem.l   d0-a6,-(sp)
              pea       (a0)              ; Speicherblockbeginn sichern.
              exg       a0,a1             ; a0 als Arbeitsreg.
              move.l    a0,d7
              sub.l     a1,d7             ; Grîûe des Speicherblocks berechnen.
              divu.l    #(52*4),d7        ; 208 Bytes / Loop lîschen.
              subq.w    #1,d7             ; u.U. besteht ungel. Bereich.
              bmi.s     clr_rts

              moveq     #0,d0
              move.l    d0,d1
              move.l    d0,d2
              move.l    d0,d3
              move.l    d0,d4
              move.l    d0,d5
              move.l    d0,d6
              movea.l   d0,a1
              movea.l   d0,a2
              movea.l   d0,a3
              movea.l   d0,a4
              movea.l   d0,a5
              movea.l   d0,a6
clr_s_lp:     movem.l   d0-d6/a1-a6,-(a0)
              movem.l   d0-d6/a1-a6,-(a0)
              movem.l   d0-d6/a1-a6,-(a0)
              movem.l   d0-d6/a1-a6,-(a0)
              dbra      d7,clr_s_lp

              move.l    (sp)+,a0          ; Erste 220 wurden u.U. nicht gel.
              lea       208(a0),a0
              movem.l   d0-d6/a1-a6,-(a0)
              movem.l   d0-d6/a1-a6,-(a0)
              movem.l   d0-d6/a1-a6,-(a0)
              movem.l   d0-d6/a1-a6,-(a0)
              movem.l   (sp)+,d0-a6
clr_rts:      rts

*****************************************************************************
* Komplettes Videoram (alle logischen Bildschirme) lîschen.                 *
* Im Planemodus wird nur bis zum "freien" Screen gelîscht !
*****************************************************************************
clr_screens:  movem.l   d0-a6,-(sp)

              cmp.b     #1,detail         ; Planemodus ?
              bne.s     cscr_all          ; Wirklich alles umlîschen !

              lea       _screens,a0       ; Nur bis zum freien Screen: d.h.
              movea.l   free_screen,a1    ; dort kann Bild angezeigt werden,
              bsr.w     clr_mem           ; wÑhrend die "normalen" Screens
                                          ; initialisiert werden.
              movem.l   (sp)+,d0-a6
              rts

cscr_all:     lea       _screens,a0
              lea       _end_screens,a1
              bsr.w     clr_mem

              movem.l   (sp)+,d0-a6
              rts

*****************************************************************************
* Aktuellen logischen Screen lîschen (unabhÑngig der Farbtiefe).            *
* Der Hintergrund wird gefÅllt mit :                  0 (Planemodus)        *
*                                         hintergrund.w (High-Colour Mode)  *
*****************************************************************************
clr_screen:   movem.l   d0-a6,-(sp)

              cmp.b     #1,detail         ; High-Colourscreen ?
              beq.w     tech_no

              move.l    clr_scr(pc),d0    ; Lîschadresse (Ende !)
              beq.w     cleared
              movea.l   d0,a0
              move.w    hintergrund(pc),d0      ; Hintergrundfarbe
              move.w    d0,d1             ; Ins Low- und Highword von d0
              swap      d0                ; kopieren.
              move.w    d1,d0
              move.l    d0,d1             ; Alle Lîschregs mit Hintergrund-
              move.l    d0,d2             ; farbe fÅllen.
              move.l    d0,d3
              move.l    d0,d4             ; a3/a4 kînnten noch benutzt werden,
              move.l    d0,d5             ; dann aber keine freie Breite mehr.
              movea.l   d0,a1
              movea.l   d0,a2
              lea       (SCR_WIDE-SCR_DX)*2.w,a5    ; Zeilenoffset (nach oben!)
              move.w    #SCR_DY,d6        ; Anz. Zeilen (+1)
clr_zeile:
          REPEAT                          ; Schleife einer Zeile
              movem.l   d0-d5/a1-a2,-(a0) ; 16 Pixel lîschen
          UNTIL  #(SCR_DX/16-1)
              suba.l    a5,a0             ; nÑchste Zeile oben.
              dbra      d6,clr_zeile
              bra.w     cleared

tech_no:      move.l    clr_scr(pc),d0    ; Planeorientiert lîschen.
              beq.w     cleared
              movea.l   d0,a0

              move.l    #(SCR_WIDE-SCR_DX)/2,d7 ; Zei.off. (nach oben!)
              bne.s     no_blitter        ; Kein Blitter mîglich.

              tst.b     use_blitter       ; Mit Blitter lîschen ?
              beq.w     .b_clr

no_blitter:   move.l    #$11,d0
              movec     d0,cacr

              moveq     #0,d0
              move.l    d0,d1             ; Alle Lîschregs mit Hintergrund-
              move.l    d0,d2             ; farbe fÅllen.
              move.l    d0,d3
              move.l    d0,d4             ; a3/a4 kînnten noch benutzt werden,
              move.l    d0,d5             ; dann aber keine freie Breite mehr.
              movea.l   d0,a1
              movea.l   d0,a2
              movea.l   d0,a3
              movea.l   d0,a4
              move.w    #SCR_DY/2,d6      ; Anz. Zeilen (immer 2 Zeilen mehr.)

              cmpi.b    #8,planes         ; 256-Farben Modus ?
              bne.s     clr_scr_16

              add.l     d7,d7             ; Zeilenoffset erhîht sich.
              beq.s     clr_fast_256      ; Offset == 0 --> Schnell lîschen.
              bne.w     clr_off_256       ; Offset != 0 --> Offset benutzen.

clr_scr_16:   tst.l     d7                ; Zeilenoffset benîtigt ?
              bne.w     _16_clr_zeile

clr_zeile_fast:
        REPEAT
          REPEAT
              movem.l   d0-d5/a1-a4,-(a0) ; 80 Pixel lîschen
          UNTIL  #(SCR_DX/80-1)
        UNTIL #(2-1)
              dbra      d6,clr_zeile_fast
              bra.w     cleared

clr_fast_256:                             ; 8 Planes schnell lîschen.
        REPEAT
          REPEAT
              movem.l   d0-d5/a1-a4,-(a0) ; 40 Pixel lîschen
          UNTIL  #(SCR_DX/40-1)
        UNTIL #(2-1)
              dbra      d6,clr_fast_256
              bra.w     cleared

_16_clr_zeile:                            ; Zeile mit Offset lîschen.
        REPEAT
          REPEAT
              movem.l   d0-d5/a1-a4,-(a0) ; 80 Pixel lîschen
          UNTIL  #(SCR_DX/80-1)
              suba.l    d7,a0             ; nÑchste Zeile oben.
        UNTIL #(2-1)
              dbra      d6,_16_clr_zeile
              bra.w     cleared

clr_off_256:                              ; 8 Planes mit Offset lîschen.
        REPEAT
          REPEAT
              movem.l   d0-d5/a1-a4,-(a0) ; 40 Pixel lîschen
          UNTIL  #(SCR_DX/40-1)
              suba.l    d7,a0             ; nÑchste Zeile oben.
        UNTIL #(2-1)
              dbra      d6,clr_off_256
              bra.s     cleared

.b_clr:       move.l    a0,BC_END         ; Kompletten Screen mit Blitter lî-
              lea       (-240*160.l,a0),BC_START    ; schen...
              jsr       BLITTER_CLR

cleared:
        IFEQ  (COL_BOOM-an)
              move.l    #$ffffffff,$ffff9800.w
        ENDIF
              movem.l   (sp)+,d0-a6
              rts

*****************************************************************************
* Auf 8 Planescreen 4 Planes lîschen.                                       *
* PARAMETER:  d0.w  -  Planeoffset.                                         *
*****************************************************************************
clr_screen_8: move.l    clr_scr(pc),d1          ; Lîschadresse (Ende !)
              bne.s     cs_scr_8_do
              rts
cs_scr_8_do:  movea.l   d1,a0
              lea       (-16.b,a0,d0.w),a0
              moveq     #0,d0
              moveq     #20,d1
              move.w    #SCR_DY-1+1,d6    ; Anz. Zeilen
clr_scr_8: REPEAT                         ; Ganze Zeile lîschen.
              move.l    d0,(a0)+          ; 4 Planes lîschen.
              move.l    d0,(a0)
              suba.l    d1,a0             ; 4 Planes belassen.
            UNTIL  #(SCR_WIDE/16)-1
              dbra      d6,clr_scr_8
              rts

; 16-Farbenscreen lîschen (Komplett 4 Planes).
clear_screen_par:
              moveq     #$11,d0           ; Datencache kann mich mal.
              movec     d0,cacr

              move.l    clr_scr(pc),d0    ; Clr.addy.
              beq.s     cs_p_wait
              movea.l   d0,a0
              moveq     #0,d0
              move.l    d0,d1             ; Alle Lîschregs mit Hintergrund-
              move.l    d0,d2             ; farbe fÅllen.
              move.l    d0,d3
              move.l    d0,d4             ; a3/a4 kînnten noch benutzt werden,
              move.l    d0,d5             ; dann aber keine freie Breite mehr.
              movea.l   d0,a1
              movea.l   d0,a2
              movea.l   d0,a3
              movea.l   d0,a4
              movea.l   d0,a5
              moveq     #SCR_DY/3-1,d6    ; Anz. Zeilen
cz_para:
        REPEAT
          REPEAT
              movem.l   d0-d5/a1-a4,-(a0) ; 80 Pixel lîschen
          UNTIL  #(SCR_DX/80-1)
        UNTIL #(3-1)
              dbra      d6,cz_para

cs_p_wait:    tst.b     FINISH_FLAG       ; Screen gelîscht, warten, bis
              beq.s     cs_p_wait         ; Hauptprogramm RÅcksprung freigibt.
              rts

*****************************************************************************
* Ein Plane lîschen (NUR komplette Zeilen !!!).                             *
*                                                                           *
* clr_plane_1     : Lîscht 1 Plane sofort.                                  *
* clr_plane_1_par : Lîscht 1 Plane parallel.                                *
*                                                                           *
* PARAMETER:  d0.w - Plane {0,1,2,3}.                                       *
*****************************************************************************
clr_plane_1:  move.l    clr_scr(pc),d1
              bne.s     cp1_do
              rts
cp1_do:       movea.l   d1,a0
              lea       (-8.b,a0,d0.w*2),a0

              moveq     #0,d0
              move.w    #SCR_DY,d1        ; Anz. Zeilen
clr_ze_pl:    move.w    d0,(a0)
OFF           SET       -8
           REPEAT
              move.w    d0,OFF(a0)
OFF           SET       OFF-8
           UNTIL #(SCR_WIDE/16-2)
              lea       -_16_BYTES_SCAN(a0),a0
              dbra      d1,clr_ze_pl
              rts

clr_plane_1_par:                          ; d0.w : Plane.
              move.l    clr_scr(pc),d1
              beq.s     cs_1p_wait
              movea.l   d1,a0
              lea       (-8.b,a0,d0.w*2),a0

              moveq     #0,d0
              move.w    #SCR_DY,d1        ; Anz. Zeilen
clr_ze_pl_par:
              move.w    d0,(a0)
OFF           SET       -8
           REPEAT
              move.w    d0,OFF(a0)
OFF           SET       OFF-8
           UNTIL #(SCR_WIDE/16-2)
              lea       -_16_BYTES_SCAN(a0),a0
              dbra      d1,clr_ze_pl_par

cs_1p_wait:   tst.b     FINISH_FLAG       ; Screen gelîscht, warten, bis
              beq.s     cs_1p_wait        ; Hauptprogramm RÅcksprung freigibt.
              rts

*****************************************************************************
* Zwei hintereinanderliegende Planes lîschen (NUR komplette Zeilen !!!).    *
*                                                                           *
* clr_plane_2     : Lîscht sofort.                                          *
* clr_plane_2_par : Lîscht Parallel.                                        *
*                                                                           *
* PARAMETER:  d0.w - Plane {0,1,2}.                                         *
*****************************************************************************
clr_plane_2:  move.l    clr_scr(pc),d1
              bne.s     cp2_do
              rts
cp2_do:       movea.l   d1,a0

              cmpi.b    #8,planes         ; 8 Planeorientierter Screen ?
              beq.w     clr_plane28

              lea       (-8.b,a0,d0.w*2),a0     ; Screenadresse.

              moveq     #0,d0
              move.w    #SCR_DY,d1              ; Anz. Zeilen
              move.l    #_16_BYTES_SCAN,d2      ; Zeilenoffset.
clr_ze_pl_2:  move.l    d0,(a0)
OFF           SET       -8
        REPEAT
              move.l    d0,OFF(a0)
OFF           SET       OFF-8
        UNTIL #(SCR_WIDE/16-2)
              suba.l    d2,a0             ; VRam nÑchste Zeile.
              dbra      d1,clr_ze_pl_2    ; NÑchste Zeile lîschen.
              rts

clr_plane28:  lea       (-16.b,a0,d0.w*2),a0    ; Zwei Planes lîschen, nur auf
              moveq     #0,d0                   ; einem 8-Planescreen.
              move.w    #SCR_DY,d1
              move.l    #_256_BYTES_SCAN,d2
clr_ze_pl_28: move.l    d0,(a0)
OFF           SET       -16
           REPEAT
              move.l    d0,OFF(a0)
OFF           SET       OFF-16
           UNTIL #(SCR_WIDE/16-2)
              suba.l    d2,a0
              dbra      d1,clr_ze_pl_28
              rts


clr_plane_2_par:
              move.l    clr_scr(pc),d1
              beq.s     cs_2p_wait
              movea.l   d1,a0
              lea       (-8.b,a0,d0.w*2),a0

              moveq     #0,d0
              move.w    #SCR_DY,d1        ; Anz. Zeilen
clr_ze_pl_2par:
              move.l    d0,(a0)
OFF           SET       -8
           REPEAT
              move.l    d0,OFF(a0)
OFF           SET       OFF-8
           UNTIL #(SCR_WIDE/16-2)
              lea       -_16_BYTES_SCAN(a0),a0
              dbra      d1,clr_ze_pl_2par

cs_2p_wait:   tst.b     FINISH_FLAG
              beq.s     cs_2p_wait
              rts

;==========================================================================
; Mausbewegung auswerten, bzw. in Beobachterstandpunkt und Sichtwinkel um-
; rechnen.
; Sichtwinkel: Direkt aus relativer Mausposition.
; Beobachters: Aus Sichtwinkel und Geschwindigkeit trigonometrisch den Bew-
;              egungsvektor berechnen.
;==========================================================================
get_mouse:    movem.w   MX_REL,d0-d1      ; Relative Mausbewegung...
              add.w     d0,d0             ; "Mausspeeder"
              add.w     d1,d1

              btst      #0,M_BUTTONS
              beq.s     not_speeded       ; nein->keine Speedbeeinflussung.

              moveq     #MAX_BESCHLEUNIGUNG,d2
              move.w    speed,d3          ; Alte Geschwindigkeit.

              move.w    d1,d4             ; dy
              beq.s     not_speeded       ; keine VerÑnderung -> Abbruch
              bgt.s     rise_speed        ; dy>0 -> Geschw. erhîhen

              clr.w     d1                ; Wegen normaler Bew.rout.
              tst.w     d3                ; Steht Gleiter schon ?
              beq.s     not_speeded       ; ja -> kein Abbremsen benîtigt

              neg.w     d4                ; |dy|
              cmp.w     d2,d4             ; Grîûer als hîchste Abbrems-
              blt.s     *+4               ; kraft ?
              move.w    d2,d4             ; ja -> max. Bremskraft setzen.
;             asr.w     #1,d4             ; Pixel->Bremse

              subq.w    #1,d3
;             sub.w     d4,d3             ; Neue Gesch. = Alte - Bremse
              bpl.s     neu_speed

              clr.w     d3
              bra.s     neu_speed

rise_speed:   clr.w     d1
              moveq     #MAX_SPEED,d5
              cmp.w     d5,d3             ; Bereits Vollgas ?
              bge.s     not_speeded

              cmp.w     d2,d4             ; Grîûer als hîchste Abbrems-
              blt.s     *+4               ; kraft ?
              move.w    d2,d4
;             asr.w     #1,d4             ; Pixel->Gas

;             add.w     d4,d3
              addq.w    #1,d3
              cmp.w     d5,d3
              blt.s     neu_speed
              move.w    d5,d3

neu_speed:    move.w    d3,speed          ; neue Geschwindigkeit
not_speeded:  move.w    #720,d2           ; const SIZE_SINTAB
              lea       beovek,a0         ; Sichtwinkel

              add.w     d0,2(a0)          ; x-Bewegung: Rotation um y-Achse.
              bpl.s     plus1
              add.w     d2,2(a0)
plus1:        cmp.w     2(a0),d2
              bgt.s     neg1
              sub.w     d2,2(a0)
neg1:         add.w     d1,(a0)           ; y-Bewegung: Roatation um x-Achse.
              bpl.s     plus2
              add.w     d2,(a0)
plus2:        cmp.w     (a0),d2
              bgt.s     neg2
              sub.w     d2,(a0)
neg2:

              move.w    speed,d3          ; Bewegt sich Beobachter ?
              beq.w     no_beo_move

              movem.w   (a0),d0-d1        ; Sichtwinkel a,b (c unnîtig !)
              lea       beo,a1            ; Beobachter
              lea       beoadd+8,a2       ; Beobachter 32-Bit Fixkomma
              lea       sinus720,a3       ; Sinustabelle, DSP-Grîûe
              lea       720/4(a3),a4      ; Cosinustabelle

; Bewegungsvektor = Grundsichtvektor g-> = ( 0 0 speed ) transformiert um die
; Winkel a,b,c. FÅr g'-> ergibt sich:
;                       x1 = speed * (-sin(b))
;                       x2 = speed * (sin(a)*sin(b))
;                       x3 = speed * (cos(a)*cos(b))

              move.w    (a3,d1.w*2),d4    ; sin(b)

              move.w    (a3,d0.w*2),d5    ; sin(a)
              muls.w    (a3,d1.w*2),d5    ; *sin(b)
              add.l     d5,d5
              swap      d5                ; sin(a)*sin(b)
              
              move.w    (a4,d0.w*2),d6    ; cos(a)
              muls.w    (a4,d1.w*2),d6    ; *cos(b)
              add.l     d6,d6
              swap      d6                ; cos(a)*cos(b)

; Bewegungsvektor um Geschwindigkeit verÑndern.
              muls.w    d3,d4             ;         ( x_move )
              muls.w    d3,d5             ; speed * ( y_move )
              muls.w    d3,d6             ;         ( z_move )

              add.l     d6,(a2)           ; Beobachter neu: 32-Bit Fixkomma.
              trapvs.w  #-1               ; öberlÑufe abfangen.
              add.l     d5,-(a2)
              trapvs.w #-1
              add.l     d4,-(a2)
              trapvs.w  #-1

              move.w     (a2),(a1)+       ; Vorkomma in Integer-beobachter
              move.w    4(a2),(a1)+       ; eintragen (alle anderen Berech-
              move.w    8(a2),(a1)        ; nungen im 16-Bit Punktformat)

no_beo_move:  rts

*****************************************************************************
*             TASTATURAUSWERTUNG (hauptsÑchlich Debugging).                 *
* Kraut und RÅbrn Code.                                                     *
* Parameter: d0.b - Scancode.                                               *
*****************************************************************************
tast:         lea       vbl_counter(pc),a1
              move.w    (a1)+,d1          ; Gewisse Zeit zwischen Switches.
              sub.w     (a1),d1

              cmpi.b    #$01,d0           ; <ESC> schaltet zwischen Gouraud
              bne.s     netsosc           ; und Flat-Polys um.

              cmpi.w    #20,d1            ; Nach einem Tastendruck ein Dauer-
              blt.w     syncro            ; switch eintritt.

              move.w    -(a1),2(a1)       ; FÅr nÑchste Pause.
              bsr.w     clr_screens       ; VRam komplett lîschen.

              not.w     __mode            ; Aktueller Mode umnudeln.
              beq.w     switch_32k
              bsr.w     switch_16
              clr.b     d0
              rts

netsosc:      cmpi.w    #20,d1            ; Animationsumschaltung per "Hand"
              blt.w     syncro

              cmpi.b    #$4b,d0           ; <Cursor links>
              bne.s     no_left

              move.w    -(a1),2(a1)
              bsr.w     prev_ani          ; Vorige Animation.
              clr.b     d0
              rts

no_left:      cmpi.b    #$4d,d0           ; <Cursor rechts>
              bne.s     tast_bm

              move.w    -(a1),2(a1)
              bsr.w     next_ani          ; NÑchste Animation.
              clr.b     d0
              rts

tast_bm:      cmpi.b    #$6d,d0           ; <1>
              bne.s     nnn1
              subq.w    #8,beo
nnn1:         cmpi.b    #$6a,d0           ; <4>
              bne.s     nnn2
              addq.w    #8,beo
              rts
nnn2:         cmpi.b    #$6e,d0           ; <2>
              bne.s     nnn3
              subq.w    #8,beo+2
              rts
nnn3:         cmpi.b    #$6b,d0           ; <5>
              bne.s     nnn4
              addq.w    #8,beo+2
              rts
nnn4:         cmpi.b    #$6f,d0           ; <3>
              bne.s     nnn5
              subq.w    #8,beo+4
              rts
nnn5:         cmpi.b    #$6c,d0           ; <6>
              bne.s     nnn6
              addq.w    #8,beo+4
              rts
nnn6:         move.b    d0,d3
              moveq     #0,d0
              moveq     #0,d1
              moveq     #0,d2
              cmpi.b    #$63,d3           ; <(>
              bne.s     nnn7
              addq.w    #2,d0
              bra.s     nnn12
nnn7:         cmpi.b    #$67,d3           ; <7>
              bne.s     nnn8
              subq.w    #2,d0
              bra.s     nnn12
nnn8:         cmpi.b    #$64,d3           ; <)>
              bne.s     nnn9
              addq.w    #2,d1
              bra.s     nnn12
nnn9:         cmpi.b    #$68,d3           ; <8>
              bne.s     nnn10
              subq.w    #2,d1
              bra.s     nnn12
nnn10:        cmpi.b    #$65,d3           ; </>
              bne.s     nnn11
              addq.w    #2,d2
              bra.s     nnn12
nnn11:        cmpi.b    #$69,d3           ; <9>
              bne.s     nnn12
              subq.w    #2,d2
nnn12:        move.w    d0,d4
              or.w      d1,d4
              or.w      d2,d4
              beq.s     nnn13
              lea       beovek(pc),a0
              bra.w     rot_d03
nnn13:        move.b    d3,d0

              cmpi.b    #$72,d0           ; <Ret> ?
              bne.s     syncro

              lea       anim_buf+4000,a0
              move.w    (a0)+,d0
              move.w    d0,d1
              mulu.w    #9,d1
              movem.w   lightsource(pc),d2-d7/a1-a3
              movem.w   d2-d7/a1-a3,(a0,d1.w*2)
              addq.w    #1,d0
              move.w    d0,-(a0)
wl_1:         move.b    $fffffc02.w,d0
              cmpi.b    #$1c,d0
              bne.s     wl_1
              rts

syncro:       cmpi.b    #$3b,d0           ; <F1>
              bne.s     no_f1
              cmpi.w    #1,anz_vbls       ; minimale fps --
              ble.s     _rts
              subq.w    #1,anz_vbls
_rts:         rts
no_f1:        cmpi.b    #$3c,d0           ; <F2>
              bne.s     _rts
              addq.w    #1,anz_vbls       ; minimale fps ++
              rts

__mode:       DC.W      0

; ============================================================================
; Globales Weltsystem initialisieren.
; ============================================================================
init_world:   movem.l d0-a6,-(sp)

              lea       beo,a0            ; 32-Bit Fixkommabeobachter install-
              lea       beoadd,a1         ; ieren.
              move.w    (a0)+,(a1)+
              clr.w     (a1)+
              move.w    (a0)+,(a1)+
              clr.w     (a1)+
              move.w    (a0)+,(a1)+
              clr.w     (a1)+

              lea       ex_worlds,a0      ; Externe Objektetabelle.
              lea       worlds,a1         ; Interne Ojektepointer.
              lea       world_names,a3    ; Namen der Animationen (Debugging)
              lea       16(a0),a6         ; FÅr Erstinitialisierung.
              clr.w     d0
.get_obj_adr: move.l    (a0),d1
              beq.s     .end_goa

              move.l    a0,(a3)+          ; Namenpointer sichern.
              lea       16(a0),a2
              move.l    a2,(a1)+          ; Pointer auf Animation sichern.

              move.l    (a2)+,d1          ; Init-Routine
              move.l    (a2)+,d2          ; Frame-Routine
              move.l    (a2)+,d3          ; VBL-Routine
              move.l    (a2)+,d4          ; World-Daten
              move.l    (a2)+,d5          ; Bitmap-Animationsstruktur.
              move.l    a2,a0

              addq.w    #1,d0
              bra.s     .get_obj_adr

.end_goa:     tst.w     d0                ; Keine Objekte vorhanden ?
              trapeq.w  #-100

              clr.l     (a1)+             ; Schlusspointer.
              movem.l   (sp)+,d0-a6
              rts

; ============================================================================
; Berechnet FarbverlÑufe anhand vorgegebener Werte...
; 32 Werte / Verlauf (bei Fades werden 40 Berechnet, um nie ganz scharz zu
; erreichen. POV-Standartpalette !
; ============================================================================
install_col_tabs:
              movem.l   d0-a6,-(sp)

; Aus Standartpool Paletten (Default: Farbe-->Dunkel(schwarz) )
              lea       mega_colours,COL_LIST       ; Farbenadressen
              lea       colours,COL_BUF             ; Buffer
              lea       col_adrs,COL_POINTER        ; Palettenpointer
              moveq     #FADE_OUT,COL_MODE              ; Ausfaden
              moveq     #40,COL_STEPS               ; Steps: bei 32 cols nie !
              moveq     #ANZ_PALETTEN,COL_ANZ       ; 104 FarbverlÑufe !
              bsr.l     CALC_PALS_VDI               ; Paletten berechnen.

; Standartpaletten ins XGA-Format konvertiern.
              lea       col_adrs,COL_LIST           ; Erzeugte Palettenadr.
              lea       colours,COL_BUF             ; Zielbuffer
              lea       col_adrs,COL_POINTER        ; Erneut Pointertabelle
              moveq     #_XGA,COL_MODE              ; XGA-Palette
              moveq     #32,COL_STEPS               ; Nur die ersten 32 !
              moveq     #ANZ_PALETTEN,COL_ANZ       ; 104 Paletten...
              bsr.l     CONV_PALS                   ; ...konvertieren

; Farbtabellen (Farbe-->Farbe)
              bsr.w     make_irreals                ; Grundfarben erstellen.

              lea       irreal,COL_LIST             ; FarbverlÑufe generieren.
              lea       irr_buff,COL_BUF
              lea       irr_cols,COL_POINTER
              moveq     #TWO_COLS,COL_MODE
              moveq     #32,COL_STEPS
              moveq     #ANZ_IRREALS,COL_ANZ
              bsr.l     CALC_PALS_VDI

              lea       irr_cols,COL_LIST
              lea       irr_buff,COL_BUF
              lea       irr_cols,COL_POINTER
              moveq     #_XGA,COL_MODE
              moveq     #32,COL_STEPS
              moveq     #ANZ_IRREALS,COL_ANZ
              bsr.l     CONV_PALS

; 16-Farb-Basispalette (diese sofort setzen).
              lea       start_16_col,STARTCOL   ; Grundpalette berechnen.
              lea       end_16_col,ENDCOL       ; Ausgenommen sind:
              lea       l_koo,CALC_PAL              ; Col(0) und Col(15).
              moveq     #14,COLSTEPS
              bsr.l     CALC_PAL_VDI

              lea       l_koo,VDI_PAL           ; Palette ins Falcon-Paletten-
              lea       col_pal+4,DEST_PAL      ; format.
              moveq     #14,COLSTEPS
              bsr.l     VDI_9800

              moveq     #TRUE,d0
              movem.l   (sp)+,d0-a6
              rts

ret_false:    moveq     #FALSE,d0
              movem.l   (sp)+,d0-a6
              rts

start_16_col: DC.W      1000,1000,1000    ; 16-Farbpalette: Start
end_16_col:   DC.W      100,100,100       ;                 Ende

;=============================================================================
; Genriert aus den "diskettentauglichen" Objekten, Objekte mit absoluten Adr-
; essen fÅr Punkte und Farben, "weil's halt schneller isch".
; Keine Parameter.
;=============================================================================
install_obj:  movem.l   d0-a6,-(sp)
              lea       objekte,a0        ; Pointerliste auf Grundobjekte
              lea       col_adrs,a1       ; Farbenpointer (hell->dunkel)
              lea       real_pal_32k,a2   ; Adressen "real"-Shading
              lea       irr_pal_32k,a3    ; Adressen "irreal"-Shading
              moveq     #0,d3             ; FlÑchencounter.

              move.w    anz_base_obj,d7   ; Anzahl Grundobjekte.
              subq.w    #1,d7
              traplt.w  #-4               ; Damit kann man einpacken!
abs_objekte:  move.l    (a0)+,a6          ; Grundtyp
              movem.w   (a6)+,d0-d1       ; Anzahl FlÑchen/Punkte
              move.l    a6,a5             ; Pointer auf Urpunktpointer (->)
              addq.l    #4,a6             ; FlÑchenadressen
              move.l    a6,a4             ; Pointer auf FlÑchenpointer (->)
              lea       (a6,d0.w*4),a6    ; a6 auf erste FlÑche
              subq.w    #1,d0             ; Anzahl FlÑchen
              traplt.w  #-5               ; < 0 -> Genereller Fehler in Daten
gen_po_adr:   move.l    a6,(a4)+          ; Polygonadresse  
              move.l    (a6),d2           ; Farbe...

              cmpi.l    #BLUE,d2          ; Blau ?
              bne.s     shade_tab         ; ja -> keine Farbtabelle !
              clr.l     (a2)+
              bra.s     no_tab_value
shade_tab:    move.l    (a1,d2.l*4),(a2)+ ; Farbpalettenadr. sichern.
no_tab_value: move.l    (irr_cols.l,pc,d2.l*4),(a3)+    ; Farbe->Farbe-Verlauf.

              andi.w    #$0f,d2           ; FÅr Tabellenzugriffe.
              add.w     d2,d2             ; Tja, 2 Tz...

              move.w    d3,(a6)+          ; Farbennr. (fÅr Gourauds)
              move.w    d2,(a6)+          ; Farbennr. (fÅr 4-Planes)
              addq.w    #1,d3             ; Farbpointer erhîhen.

              move.w    (a6)+,d2          ; Anzahl Punkte - 1
              addq.w    #1,d2
              lea       (2.b,a6,d2.w*4),a6      ; Alle Punkte und Festfarben wegla.
              dbra      d0,gen_po_adr     ; NÑchste FlÑche.

disc_obj:     tst.l     (a5)              ; Urpunktaddy: 0 = dann eintragen.
              bne.s     adr_corr          ; Adresse bereits korrekt.

              move.l    a6,(a5)           ; Adr. hinter Polys: Urpunkte.
adr_corr:     dbra      d7,abs_objekte    ; NÑchstes Objekt festsetzen.

              moveq     #TRUE,d0
              movem.l   (sp)+,d0-a6
              rts

*****************************************************************************
* Alle "Extrude"-Objekt anhand globaler Tabelle <extrude_list> erzeugen.    *
* PARAMETER: keine.                                                         *
*****************************************************************************
obj_extrudes: movem.l   d0-a6,-(sp)
              move.w    anz_extr_obj,d0         ; Anzahl zu extruierender Obj.
              subq.w    #1,d0
              bge.s     ex_extr_obj             ; Nur, wenn Objekte verfÅgbar
              movem.l   (sp)+,d0-a6
              rts                               ; sind.
ex_extr_obj:  lea       extrude_list,a6         ; Extrudeobjektliste.
ex_extr_loop: movem.l   (a6)+,d7/a0-a1          ; Mode.w/Deep.w/Kante.l/Obj.l
              bsr.s     obj_extrude             ; Objekt erzeugen.
              dbra      d0,ex_extr_loop         ; NÑchstes Objekt.
              movem.l   (sp)+,d0-a6
              rts

*****************************************************************************
* Objektextruder: generiert Rechtecke in der Tiefe und RÅckseite.           *
* Vorgehen:   - Objekteckpunkte mit verschobener z-Koordinate ablegen.      *
*             - Frontpolygone fÅr RÅckwanderzeugung benutzen                *
*             - Tiefenpolygone anhand Kantenliste.                          *
* Parameter:  a0.l      -  Objektdaten.                                     *
*             a1.l      -  Kantenliste fÅr die TiefenflÑchen.               *
*             d7.w      -  Tiefe der Verschiebung.                          *
*****************************************************************************
obj_extrude:  movem.l   d0-a6,-(sp)

              movem.w   (a0)+,d5-d6       ; Anzahl Punkte und FlÑchen.
              move.l    (a0)+,a5          ; Objekt-Punkteadresse.
              subq.w    #2,d6             ; Dummy-Box-Punkte weg: Punktoffset.
              asr.w     #1,d6             ; Nur die bereits gesetzten zÑhlen.
              move.w    d6,d0
              lea       (16.b,a5,d0.w*8),a4     ; Auf Zielpunkte gehen.
              lea       16(a5),a5         ; Dummy-Box bei Sourcepunkten weg.

              subq.w    #1,d0
              trapmi.w  #-121
cpy_pnts:     move.l    (a5)+,(a4)+       ; x/y bleiben gleich.
              move.w    (a5)+,(a4)        ; z
              add.w     d7,(a4)+          ; z nach hinten verschieben.
              move.w    (a5)+,(a4)+       ; Zusatzparameter Åbernehmen.
              dbra      d0,cpy_pnts       ; NÑchster Punkt.

              lea       (a0,d5.w*4),a0    ; FlÑchenpointer Åbergehen.
              move.l    (a1)+,a2          ; Buffer fÅr ExtrudeflÑchen.
              move.w    (a1)+,d7          ; Anzahl Auûenkanten.
              subq.w    #1,d7
;             trapmi.w  #-121
              move.w    (a1)+,d0          ; Anzahl FrontflÑchen.
              beq.s     gen_extrude       ; Keine da --> Nur die AuûenflÑchen
              subq.w    #1,d0             ; behandeln.

gen_back:     move.l    (a0)+,(a2)+       ; Farbe.
              move.w    (a0)+,d1          ; Anzahl Eckpunkte.
              move.w    d1,(a2)+          ; Anzahl Punkte sichern.
              move.w    d1,d2             ; Zum Kopieren der Farbpunkte gebr.
              subq.w    #1,d1             ; (Erster Punkt gleich)
              trapmi.w  #-121
              move.w    (a0)+,(a2)        ; Erster Punkt (gleich).
              add.w     d6,(a2)+          ; Punkteoffset.
              lea       (2.b,a0,d1.w*2),a3      ; Reihenfolge umkehren.
              movea.l   a3,a0             ; a0 auf Wiederholung 1.
gen_back_pnt: move.w    -(a3),(a2)
              add.w     d6,(a2)+
              dbra      d1,gen_back_pnt
              move.w    (a0)+,(a2)        ; Erster Punkt nochmals (gleich).
              add.w     d6,(a2)+

cpy_helligkt: move.w    (a0)+,(a2)+       ; Helligkeitspunkte Åbernehmen.
              dbra      d2,cpy_helligkt

              dbra      d0,gen_back       ; NÑchste FrontflÑche --> RÅckenfl.

; ExtrudeflÑchen generieren.
gen_extrude:  tst.w     d7
              bmi.s     gen_no_ak         ; Keine Auûenkanten...

gen_ext_lp:   clr.w     (a2)+             ; High-Word Farbe reserviert
              move.w    (a1)+,(a2)+       ; Farbe Åbernehmen.
              move.w    #3,(a2)+          ; Poly immer 4 Punkte.
              movem.w   (a1)+,d0-d1       ; Kantenpunkte
              move.w    d0,(a2)+          ; Punkt 1
              move.w    d1,(a2)+          ; Punkt 2
              add.w     d6,d1             ; Punkt 3 = Verschobener Punkt 2
              move.w    d1,(a2)+
              move.w    d0,(a2)           ; Punkt 4 =           "        1
              add.w     d6,(a2)+
              move.w    d0,(a2)+          ; Abschlieûend nochmals Punkt 1
              clr.l     (a2)+             ; Festshadingwerte.
              clr.l     (a2)+
              dbra      d7,gen_ext_lp

gen_no_ak:    movem.l   (sp)+,d0-a6
              rts


*****************************************************************************
*  Installiert Videohardware und Screenhandling.                            *
*****************************************************************************
inst_screen:  movem.l   d0-a6,-(sp)

              lea       scr_lst_32k,a0    ; Videoramadressen erstellen.
              moveq     #ANZ_SCREENS-1,d7 ; (Screenliste).
              move.l    #_screens+256,d0
              clr.b     d0
save_scr_adr: move.l    d0,(a0)+
              move.l    d0,((ANZ_SCREENS-1)*4.b,a0)
              addi.l    #BYTES_SCREEN,d0
              dbra      d7,save_scr_adr

              move.l    scr_lst_32k,d1
              move.l    d1,screen
              addi.l    #VISIBLE_Y1*BYTES_SCAN+ADD_CLR_X,d1
              move.l    d1,clr_scr
              move.l    scr_lst_32k+4,screen+4

              lsr.w     #8,d0
              move.l    d0,$ffff8200.w

              lea       scr_lst_16,a0           ; Screenliste fÅr 16 Farben.
              moveq     #_16_ANZ_SCREENS-1,d7
              move.l    #_screens+256,d0
              clr.b     d0
              move.l    d0,d1
save_scr_16:  move.l    d0,(a0)+
              move.l    d0,((_16_ANZ_SCREENS-1)*4.b,a0)
              addi.l    #_16_BYTES_SCREEN,d0
              dbra      d7,save_scr_16

              move.l    d0,free_screen    ; Dort liegt unbenutztes Ram (150K)

              lea       scr_lst_256,a0          ; Screenliste fÅr 256 Farben.
              moveq     #_256_ANZ_SCREENS-1,d7
              move.l    d1,d0
save_scr_256: move.l    d0,(a0)+
              move.l    d0,((_256_ANZ_SCREENS-1)*4.b,a0)
              addi.l    #_256_BYTES_SCREEN,d0
              dbra      d7,save_scr_256

              lea       tab_320,a0        ; Offsettabelle fÅr 8-Planescreen er-
              move.w    #SCR_HIGH-1,d7    ; zeugen (wurde noch nicht gemacht)
              clr.l     d0
gen_tab320:   move.l    d0,(a0)+
              addi.l    #SCR_WIDE,d0
              dbra      d7,gen_tab320

              move.l    #rte,$70.w
              move.w    #$2300,sr
              bsr.w     switch_32k        ; Videohardware Default: Highcol.
              move.w    #$2700,sr

              movem.l   (sp)+,d0-a6
              rts

*****************************************************************************
*   Schaltet System auf 4-Plane Videomodus um.                              *
*   NACH SWITCH LOG. SCREENS DIREKT HINTER LOGISCHEN, UM NICHT BEREITS      *
*   VORBERECHNETE ANI. IM ANDEREN MODUS ANZUZEIGEN !!!                      *
*****************************************************************************
switch_16:    st        disable_sync      ; VBL-Bildwechsel aus.

              lea       akt_scr(pc),a0
              move.l    #$00010000,(a0)+  ; <akt_scr>,<akt_log>
              move.w    #_16_ANZ_VBLS,(a0)+     ; Anz. VBLs.
              move.w    #_16_BYTES_SCAN,(a0)+
              move.l    #_16_BYTES_SCREEN,(a0)+
              move.w    #_16_ANZ_SCREENS,(a0)+
              move.l    #_16_CLR_OFF,(a0)+
              move.l    #scr_lst_16,(a0)
              clr.l     clr_scr

              lea       scr_lst_16,a0     ; Screenliste auf erste beiden
              lea       screen,a1         ; Screens setzen.
              move.l    (a0)+,(a1)+
              move.l    (a0),d0
              move.l    d0,(a1)

              bsr.w     vsync             ; Im VBL Videoadr. umschalten, auch
              SET_V_ADR d0,d1             ; wenn bei Umschaltung 32K->16 kein
                                          ; Buserror auftreten kann.
              move.b    #1,detail
              clr.b     disable_sync      ; VBL-Screenhandling an.

hw_switch_16: cmp.b     #2,(system+_MON)  ; VGA-Monitor ?
              beq.s     sw_vga_16

* Monitor: RGB/TV
* 320*240, 16 Farben, 50.0 Hz, 15625 Hz
sw_rgb_16:
        IFEQ  (COL_BOOM-an)               ; Mit Border.
              move.l   #$fe00c3,$ffff8282.w
              move.l   #$200015,$ffff8286.w
              move.l   #$7600d3,$ffff828a.w
              move.l   #$271026b,$ffff82a2.w
              move.l   #$130053,$ffff82a6.w
              move.l   #$233026b,$ffff82aa.w
              move.w   #$200,$ffff820a.w
              move.w   #$182,$ffff82c0.w
              clr.w    $ffff8266.w
              move.w   #$0,$ffff8266.w
              move.w   #$0,$ffff82c2.w
              move.w   #$50,$ffff8210.w
        ELSE                                    ; Mit Overscan.
              move.l   #$c70099,$ffff8282.w
              move.l   #$1902a6,$ffff8286.w
              move.l   #$7500a6,$ffff828a.w
              move.l   #$271026b,$ffff82a2.w
              move.l   #$130057,$ffff82a6.w
              move.l   #$237026b,$ffff82aa.w
              move.w   #$200,$ffff820a.w
              move.w   #$186,$ffff82c0.w
              clr.w    $ffff8266.w
              move.w   #$0,$ffff8266.w
              move.w   #$0,$ffff82c2.w
              move.w   #$50,$ffff8210.w
        ENDIF
              rts

* Monitor: VGA
* 320*240, 16 Farben, 50.0 Hz, 31470 Hz
sw_vga_16:    
        IFNE  (_55HZ-an)
              MOVE.L   #$C6008F,$FFFF8282.W
              MOVE.L   #$B0286,$FFFF8286.W
              MOVE.L   #$670096,$FFFF828A.W
              MOVE.L   #$4EB04D1,$FFFF82A2.W
              MOVE.L   #$3F00AD,$FFFF82A6.W
              MOVE.L   #$46D04E7,$FFFF82AA.W
              MOVE.W   #$200,$FFFF820A.W
              MOVE.W   #$186,$FFFF82C0.W
              CLR.W    $FFFF8266.W
              MOVE.W   #$0,$FFFF8266.W
              MOVE.W   #$5,$FFFF82C2.W
              MOVE.W   #$50,$FFFF8210.W
        ELSE
* 320*240, 16 Farben, 55.0 Hz, 31470 Hz
              move.l   #$c600a1,$ffff8282.w
              move.l   #$286,$ffff8286.w
              move.l   #$670096,$ffff828a.w
              move.l   #$4790479,$ffff82a2.w
              move.l   #$1f006d,$ffff82a6.w
              move.l   #$42d0475,$ffff82aa.w
              move.w   #$200,$ffff820a.w
              move.w   #$186,$ffff82c0.w
              clr.w    $ffff8266.w
              move.w   #$0,$ffff8266.w
              move.w   #$5,$ffff82c2.w
              move.w   #$50,$ffff8210.w
        ENDIF
              rts

*****************************************************************************
*  Schaltet in 256-Farben Modus.                                            *
*****************************************************************************
switch_256:   st        disable_sync      ; Analog "switch_16"

              lea       akt_scr(pc),a0
              move.l    #$00010000,(a0)+
              move.w    #_256_ANZ_VBLS,(a0)+
              move.w    #_256_BYTES_SCAN,(a0)+
              move.l    #_256_BYTES_SCREEN,(a0)+
              move.w    #_256_ANZ_SCREENS,(a0)+
              move.l    #_256_CLR_OFF,(a0)+
              move.l    #scr_lst_256,(a0)
              clr.l     clr_scr

              lea       scr_lst_256,a0
              lea       screen,a1
              move.l    (a0)+,(a1)+
              move.l    (a0),d0
              move.l    d0,(a1)

              bsr.w     vsync
              SET_V_ADR d0,d1

              move.b    #1,detail
              clr.b     disable_sync

              cmp.b     #2,(system+_MON)
              beq.s     sw_vga_256

* Monitor: RGB/TV
* 320*240, 256 Farben, 50.0 Hz, 15625 Hz
              MOVE.L    #$C700A0,$FFFF8282.W
              MOVE.L    #$1F02AA,$FFFF8286.W
              MOVE.L    #$7900AA,$FFFF828A.W
              MOVE.L    #$2710265,$FFFF82A2.W
              MOVE.L    #$2F004B,$FFFF82A6.W
              MOVE.L    #$22B026B,$FFFF82AA.W
              MOVE.W    #$200,$FFFF820A.W
              MOVE.W    #$186,$FFFF82C0.W
              CLR.W     $FFFF8266.W
              MOVE.W    #$10,$FFFF8266.W
              MOVE.W    #$0,$FFFF82C2.W
              MOVE.W    #$A0,$FFFF8210.W
              rts

sw_vga_256:   
        IFEQ  (_55HZ-an)
* 320*240, 256 Farben, 55.0 Hz, 31470 Hz
              move.l   #$c600a3,$ffff8282.w
              move.l   #$295,$ffff8286.w
              move.l   #$760096,$ffff828a.w
              move.l   #$479045f,$ffff82a2.w
              move.l   #$d0069,$ffff82a6.w
              move.l   #$4290475,$ffff82aa.w
              move.w   #$200,$ffff820a.w
              move.w   #$186,$ffff82c0.w
              clr.w    $ffff8266.w
              move.w   #$10,$ffff8266.w
              move.w   #$5,$ffff82c2.w
              move.w   #$A0,$ffff8210.w
        ELSE
* 320*240, 256 Farben, 50.0 Hz, 31470 Hz
              move.l    #$c60087,$ffff8282.w
              move.l    #$f0294,$ffff8286.w
              move.l    #$75008f,$ffff828a.w
              move.l    #$4eb045d,$ffff82a2.w
              move.l    #$9d009d,$ffff82a6.w
              move.l    #$45d04e7,$ffff82aa.w
              move.w    #$200,$ffff820a.w
              move.w    #$186,$ffff82c0.w
              clr.w     $ffff8266.w
              move.w    #$10,$ffff8266.w
              move.w    #$5,$ffff82c2.w
              move.w    #$A0,$ffff8210.w
     ENDIF
              rts

*****************************************************************************
*  Schaltet auf High-Colour Screenmodus um.                                 *
*****************************************************************************
switch_32k:   st        disable_sync

              lea       akt_scr(pc),a0    ; Dok. s. <switch_16>
              move.l    #$00010000,(a0)+
              move.w    #_ANZ_VBLS,(a0)+
              move.w    #BYTES_SCAN,(a0)+
              move.l    #BYTES_SCREEN,(a0)+
              move.w    #ANZ_SCREENS,(a0)+
              move.l    #_CLR_OFF,(a0)+
              move.l    #scr_lst_32k,(a0)       
              clr.l     clr_scr

              move.b    #2,detail

              lea       scr_lst_32k,a0
              lea       screen(pc),a1
              move.l    (a0)+,(a1)+
              move.l    (a0),d0
              move.l    d0,(a1)

              bsr.w     vsync
              SET_V_ADR d0,d1

              clr.b     disable_sync

hardsw_32k:   cmp.b     #2,(system+_MON)  ; VGA-Monitor ?
              beq.s     sw_vga_65k

* Monitor: RGB/TV
* 320*240, True Color, 50.0 Hz, 15625 Hz
sw_rgb_65k:   move.l   #$c70099,$ffff8282.w
              move.l   #$1902c8,$ffff8286.w
              move.l   #$9700a6,$ffff828a.w
              move.l   #$271026b,$ffff82a2.w
              move.l   #$130053,$ffff82a6.w
              move.l   #$233026b,$ffff82aa.w
              move.w   #$200,$ffff820a.w
              move.w   #$186,$ffff82c0.w
              clr.w    $ffff8266.w
              move.w   #$100,$ffff8266.w
              move.w   #$0,$ffff82c2.w
              move.w   #$140,$ffff8210.w
              rts

sw_vga_65k:   ; VGA-Monitor.
        IFNE  (_55HZ-an)
* 320*240, True Color, 50.0 Hz, 31470 Hz
              MOVE.L   #$C60091,$FFFF8282.W
              MOVE.L   #$1002AB,$FFFF8286.W
              MOVE.L   #$8C0096,$FFFF828A.W
              MOVE.L   #$4EB04D1,$FFFF82A2.W
              MOVE.L   #$3F00A9,$FFFF82A6.W
              MOVE.L   #$46904E7,$FFFF82AA.W
              MOVE.W   #$200,$FFFF820A.W
              MOVE.W   #$186,$FFFF82C0.W
              CLR.W    $FFFF8266.W
              MOVE.W   #$100,$FFFF8266.W
              MOVE.W   #$5,$FFFF82C2.W
              MOVE.W   #$140,$FFFF8210.W
        ELSE
* 320*240, True Color, 55.0 Hz, 31470 Hz
              move.l   #$c6009e,$ffff8282.w
              move.l   #$2a9,$ffff8286.w
              move.l   #$8a0096,$ffff828a.w
              move.l   #$4790477,$ffff82a2.w
              move.l   #$11006d,$ffff82a6.w
              move.l   #$42d0475,$ffff82aa.w
              move.w   #$200,$ffff820a.w
              move.w   #$186,$ffff82c0.w
              clr.w    $ffff8266.w
              move.w   #$100,$ffff8266.w
              move.w   #$5,$ffff82c2.w
              move.w   #$140,$ffff8210.w
        ENDIF
              rts

; ===========================================================================
; =  KlÑrt System Åber aktuelle Lage auf:                                   =
; =  Interrupts installieren, Hardware-Initialisierung.                     =
; ===========================================================================
init_system:  movem.l   d0-a6,-(sp)

              move      sr,d0
              move.w    d0,-(sp)
              move      #$2700,sr

              movec     vbr,a0            ; Errorhandler installieren.

       IFEQ   (OWN_ERR_HAN-an)            ; Im Demo alle Exceptions selber ab-
              lea       $08(a0),a1        ; fangen.
              move.l    #tex_error,d0     ; Allgemeiner Exceptionhandler.
              moveq     #7-1,d7           ; Von Bus- bis Stackframeerror.
insys_vek1:   move.l    d0,(a1)+
              dbra      d7,insys_vek1

              lea       $c0(a0),a1        ; 68881/2-Errors
              move.l    #fpu_error,d0
              moveq     #7-1,d7
insys_vek2:   move.l    d0,(a1)+
              dbra      d7,insys_vek2

              lea       $d8(a0),a1        ; MMU-Errors (dÅrften nicht auftreten)
              move.l    #mmu_error,d0
              moveq     #3-1,d7
insys_vek3:   move.l    d0,(a1)+
              dbra      d7,insys_vek3
       ENDIF

; Die Systemeigenen Exception-Vektoren ("trappcc" und "trap #GENERROR")
              move.l    #err_handler,$1c(a0)    ; TRAPcc - Vektor
              move.l    #gen_error,($80+GENERROR*4)(a0)

       IFEQ   (OWN_VBL-an)
              move.l    #rte,$70(a0)      ; Eigener VBL-Irq installieren.
       ENDIF

              move      (sp)+,sr
              movem.l   (sp)+,d0-a6
              rts

; ===========================================================================
; =  "Die letzten OS-Calls vor dem Abgrund"...                              =
; =  System retten (fÅr sauberen Wiederaufbau) und noch einige Dinge er-    =
; =  ledigen (Dateihandling...)                                             =
; ===========================================================================
exit_os:      movem.l   d0-a6,-(sp)

              move.l    #$000bffff,-(sp)  ; Sondertastenabfrage (Kbshift(-1))
              trap      #13
              addq.l    #4,sp
              btst      #SETUP_BIT,d0     ; Setuptaste gedrÅckt ?
              sne       setup             ; ja --> Flag setzen. 
              btst      #HIDDEN_BIT,d0    ; Hiddenscreens enablen ?
              sne       hidden            ; ja --> Flag setzen.
              btst      #DISPT_BIT,d0     ; Tracker disablen ?
              sne       disable_pro

; Zufallszahlen erzeugen.
              lea       random,a6
              move.w    #ANZ_RANDOM-1,d7
rand_lp:      move.w    #17,-(sp)
              trap      #14
              addq.l    #2,sp
              move.w    d0,(a6)+          ; 16 Bit Randoms sichern.
              dbra      d7,rand_lp

              move.l    $44e.w,old_vadr   ; Videoadresse sichern.
              SAVE_VID  #vid_save         ; Videosystem sichern.

              lea       $ffff8240.w,a0    ; Die ST Farbpalette lîschen.
              moveq     #7,d7
eos_kill_st:  clr.l     (a0)+
              dbra      d7,eos_kill_st

              lea       $ffff9800.w,a0    ; Falcon-Palette lîschen.
              lea       256*4(a0),a1
              bsr.w     clr_mem           

              movem.l   (sp)+,d0-a6
              rts

*****************************************************************************
* Auf VBL-warten.                                                           *
*****************************************************************************
vsync: IFEQ   (OWN_VBL-an)                ; Bei eigenem VBL:
              move.w    d0,-(sp)
              move.w    vbl_counter(pc),d0      ; Wort reicht, da es nur auf
wait_sync:    cmp.w     vbl_counter(pc),d0      ; eine VerÑnderung ankommt !
              beq.s     wait_sync
              move.w    (sp)+,d0
              rts

*****************************************************************************
*  Auf genaue Anzahl VBLs warten.                                           *
* PARAMETER:  d7.w  -  Anzahl VBLs, die gewartet werden soll.               *
*****************************************************************************
vsync_xx:     subq.w    #1,d7
              trapmi.w  #-500
wait_vbls:    bsr.s     vsync
              dbra      d7,wait_vbls
              rts

*****************************************************************************
*  Setzt Screenadresse.                                                     *
*  PARAMETER: d0.l  -  Screenadresse.                                       *
*****************************************************************************
set_scr_adr:  move.w    d1,-(sp)
              SET_V_ADR d0,d1
              move.w    (sp)+,d1
              rts

*****************************************************************************
* Eigener VBL-Interrupt.                                                    *
* IRM auf 7, wegen DSP-Parallelprogramm.                                    *
*****************************************************************************
vbl:
;             move      #$2700,sr         ; Wegen DSP-Parallelprogramm.
         IFEQ (COL_BOOM-an)
              not.l     $ffff9800.w
         ENDIF

         IFGT (ANZ_SCREENS-2)             ; Asyncroner Bildaufbau ?
              movem.l   d0-a6,-(sp)

              tst.b     disable_sync(pc)  ; Bildwechsel disabled ?
              bne.s     vbl_rte           ; (Ani.rout an (wg. Musik))

              move.w    akt_vbl(pc),d0
              addq.w    #1,d0
              cmp.w     anz_vbls(pc),d0
              blt.s     no_new

              clr.w     akt_vbl           ; Framecounter zurueck.

              movem.w   akt_scr(pc),d0-d1 ; Aktuell physikalisch/logisch
              addq.w    #1,d0
              cmp.w     _anz_screens(pc),d0
              blt.s     .no_swap
              clr.w     d0
.no_swap:     cmp.w     d1,d0             ; Logische Screens eingeholt ?
              beq.s     vbl_rte           ; ja --> ruckelruck

              addq.w    #1,show_frm       ; Ein Frame mehr gezeigt.

              move.w    d0,akt_scr
              move.l    ([scr_lst.w,pc],d0.w*4),d0  ; V-Adr.
              move.l    d0,(screen+4)
              SET_V_ADR d0,d1             ; phy. Screen setzen.
              bra.s     vbl_rte
no_new:       move.w    d0,akt_vbl
vbl_rte:
         IFEQ (INST_DSP_MOD-an)           ; Modulesound an ?
              tst.b     disable_pro(pc)   ; Ist der Player ausgeknipst ?
              bne.s     vbl_no_paula      ; (z.B. fÅr Alternativsound !)

              bsr.l     (paula+4)         ; Module playen.

vbl_no_paula: bsr.w     do_vbl_fade       ; VBL-Fading bearbeiten (parallel).

              move.l    world_vbl(pc),d0  ; Animations-VBL-Routine anspringen.
              beq.s     no_world_vbl      ; (Diese DARF den DSP nicht benutzen,
              move.l    d0,a0             ; deshalb kann sie immer parallel
              jsr       (a0)              ; zum Tracker laufen.

no_world_vbl: movem.l   (sp)+,d0-a6       ; Register zurÅck (parallel).
              addq.w    #1,vbl_counter

           IFEQ (WAIT_FIN_MOD-an)         ; Warten, bis Mod vorbei ?
wait_f_dmod:  btst      #3,$ffffa202.w
              bne.s     wait_f_dmod
           ELSE
              tst.b     dsp_works(pc)     ; Gerade DSP an 3D-Job ?
              beq.s     mod_parallel      ; DSP-Modul parallel zu 030 Prg.
wait_f_dmod:  btst      #3,$ffffa202.w
              bne.s     wait_f_dmod
mod_parallel:
           ENDIF
              rte                         ; VBL beenden !!!
         ELSE                             ; Keine Musik -->
              bsr.w     do_vbl_fade       ; VBL-Fading bearbeiten.

              move.l    world_vbl(pc),d0  ; Animations-VBL-Routine anspringen.
              beq.s     _vbl_rte          ; == 0 --> Keine Routine installiert.
              move.l    d0,a0
              jsr       (a0)              ; Danach NUR noch VBL teminieren !!!
         ENDIF                            ; Da Modrout schon verzweigt ist !
_vbl_rte:
              movem.l   (sp)+,d0-a6
         ENDIF
rte:          addq.w    #1,vbl_counter    ; VBL-Counter erhîhen.
              rte
       ELSE                               ; Debugger-VBL dranlassen.
              movem.l   d0-d2/a0-a2,-(sp)
              move.w    #37,-(sp)
              trap      #14
              addq.l    #2,sp
              movem.l   (sp)+,d0-d2/a0-a2
              rts
       ENDIF

*****************************************************************************
* Reload von Datenfiles...                                                  *
* PARAMETER:  d1.l  -  Anzahl Bytes zu laden.                               *
*             a0.l  -  Adresse, wo hingeladen werden soll.                  *
*             a1.l  -  Fall a1 != 0.l --> Pointer auf neues File.           *
*****************************************************************************
load_data:    movem.l   d0-a6,-(sp)

              pea       (a0)              ; FÅr "Fread" auf Stack (und bei
              move.l    d1,-(sp)          ; Neuîffnung werden sie gecrasht...)
              move.l    a0,a6
              move.l    d1,d7

              move.l    a1,d0             ; Aus neuem File laden ?
              beq.s     load_old_fi

              move.w    fhandle,d0        ; Fhandle == 0 --> noch keine offene
              beq.s     no_open_yet       ; Datei (***KRITISCH***)

              move.w    d0,-(sp)          ; Wenn bereits Datei geîffnet war,
              move.w    #$3e,-(sp)        ; diese schlieûen.
              trap      #1
              addq.l    #4,sp

no_open_yet:  clr.w     -(sp)             ; nur lesen.
              pea       (a1)              ; File îffnen.
              move.w    #$3d,-(sp)
              trap      #1
              addq.l    #8,sp

              tst.l     d0                ; Konnte File geîffnet werden ?
              bmi.s     error_open        ; Fehler --> Errorhandler.

              move.w    d0,fhandle        ; Handle.

load_old_fi:  move.w    fhandle,-(sp)
              move.w    #$3f,-(sp)        ; Fread (LÑnge und Adresse auf sp)
              trap      #1
              lea       12(sp),sp

              cmp.l     d0,d7             ; Stimmt Anzahl gelesener Bytes mit
              bne.s     error_read        ; gewÅnschter Åberein ?

              move.l    a6,a0             ; Sollten Daten gepackt sein, ent-
              bsr.l     ice_decrunch_2    ; packen.

              movem.l   (sp)+,d0-a6       ; GlÅcklich Åberstanden...
              rts

error_open:   lea       err_open(pc),a0
              bra.w     r_error
error_read:   lea       err_read(pc),a0
              bra.w     r_error
error_id:     lea       err_id(pc),a0
              bra.w     r_error

; ===========================================================================
; ===========================================================================
;       Allgemeine Unterprogramme, die nicht in lib abgedeckt werden.
; ===========================================================================
; ===========================================================================


*****************************************************************************
* Setzt (Falcon)-16-Farben Palette (Rout muû vom Aufrufprogramm mit dem     *
* VBL-syncronisiert werden.                                                 *
* a0.l - Palette.                                                           *
*****************************************************************************
set_pal:      movem.l   d0-a6,-(sp)

              lea       $ffff9800.w,a1
              moveq     #15,d7
set_pal_lp:   move.l    (a0)+,(a1)+
              dbra      d7,set_pal_lp

              movem.l   (sp)+,d0-a6
              rts

*****************************************************************************
* Installiert Fading auf beliebige Farben (Tabelle oder Echtzeitberechnung).*
* PARAMETER:                                                                *
*  a0.l  -  Ziel-Palettenadresse (oder Fadeingtabellenadresse)              *
*  d5.w  -  Anzahl Fadingsteps (nur bei Tabzugriff relevant, sonst 64):     *
*             d5.w > 0 --> Echtzeitfading auf Zielpalette.                  *
*             d5.w < 0 --> Fadingpalette setzen.                            *
*  d6.w  -  Startfarbe in Palette ($ffff9800+4*~.w)                         *
*  d7.w  -  Anzahl Farben (-1)                                              * 
*****************************************************************************
inst_fade:    movem.l   d0/a1,-(sp)

              lea       vbl_f1_scol(pc),a1
              tst.w     (a1)              ; LÑuft bereits eine Ani ?
              beq.s     free_fade         ; Counter == 0 --> Ani frei.
              lea       vbl_f2_scol(pc),a1      ; Zweiter Fadeblock frei ?
              tst.w     (a1)
              bne.s     n_f_fade          ; Nicht frei --> Error !

free_fade:    move.w    d5,(a1)+          ; Counter = Anz. Steps.
              move.w    d6,(a1)+          ; Startfarbe
              move.w    d7,(a1)+          ; Anzahl Farben
              move.w    frm_counter(pc),(a1)+   ; Startframe
              move.l    a0,(a1)           ; Tabellenpointer (oder 0)

              movem.l   (sp)+,d0/a1
              rts

n_f_fade:     trapne.w  #-122             ; Proggy abbrechen.

inst_norm_fade:                           ; Installiert ganze 16-Farben Pal.
              moveq     #64,d5            ; in Echtzeitshading (spart halt
              moveq     #0,d6             ; Tipparbeit und bei einer Init ists
              moveq     #15,d7            ; eh wurscht...)
              bra.s     inst_fade

*****************************************************************************
* Routine, um im VBL die Fades zu bearbeiten...                             *
* PARAMETER: keine (es werden die globalen Fade-Records benutzt)            *
*****************************************************************************
do_vbl_fade:  lea       vbl_f1_scol(pc),a0      ; Fadeblock 1
              move.w    (a0)+,d0                ; Fade vorhanden ?
              beq.s     no_fade1
              bsr.s     do_fade                 ; Fade bearbeiten.
no_fade1:     lea       vbl_f2_scol(pc),a0      ; Fadeblock 2
              move.w    (a0)+,d0                ; Fade vorhanden ?
              beq.s     no_fade2          
              bra.s     do_fade           ; Fade bearbeiten und "rts".
no_fade2:     rts

; a0.l - Blockadresse.
; d0.w - Counter (Vorzeichen: Modus)
do_fade:      movem.w   (a0),d1/d6-d7     ; Paras gleich im öbergaberegistern.

              move.w    frm_counter(pc),d4      ; Wird/wurde der Screen, in
              sub.w     d7,d4                   ; das Fading angemeldet wurde,
              cmpi.w    #_16_ANZ_SCREENS,d4     ; schon angezeigt ?
              blt.s     no_fade2                ; nein --> rts.

              movea.l   a0,a2             ; "lea 6(a0),a2"
              addq.l    #6,a2
              lea       ($ffff9800.w,d1.w*4),a1 ; Hardwareregister Startfarbe.

              tst.w     d0                ; Echtzeitfade oder Tabelle ?
              bmi.s     good_tab          ; Einen Step Echtzeit faden.

              subq.w    #1,-(a0)          ; Counter erniedrigen.
              movea.l   (a2),a0           ; Pointer auf Zielpalette.
              bra.w     fade_step         ; Einen Step Echtzeitfaden.

good_tab:     addq.w    #1,-(a0)          ; Counter erniedrigen.
              move.l    (a2),a0           ; Tabellenadresse.
c_fade_loop:  move.l    (a0)+,(a1)+       ; Einfach Farben aus Tabelle Åber-
              dbra      d6,c_fade_loop    ; nehmen.

              move.l    a0,(a2)           ; Farbtab.pointer fÅr nÑchsten Step.
              rts

*****************************************************************************
* Holt Zeit aus TT-Clockchip.                                               *
* PAREMETER: a0 - Buffer (3 Bytes: Stunden/Minuten/Sekunden)                *
*****************************************************************************
u_get_time:   pea       (a1)              ; a1 als Hilfsreg.
              GET_TIMEA a0,a1             ; Import aus "genmacro.q".
              move.l    (sp)+,a1
              rts

*****************************************************************************
* Gibt Debugginginfos zur aktuellen Szene aus.                              *
*****************************************************************************
debug_infos:  movem.l   d0-a6,-(sp)

              move.l    screen(pc),a0
              addq.l    #8,a0
              move.w    anim(pc),d0                     ; Animationsnummer.
              move.l    (world_names.l,pc,d0.w*4),a1    ; Animationsname.
              bsr.w     write                           ; ...ausgeben.

              movem.l   (sp)+,d0-a6
              rts

*****************************************************************************
* Klatscht String auf 4-Plane Screen.                                       *
* Erlaubt sind die Zeichen: { [A..Z][a..z][0..9][,.?!();:-=@/+*][chr(13)]   *
* chr(13) beginnt neue Zeile.                                               *
* PARAMETER:  a0  -  Screenadresse (positioniert auf Plane...)              *
*             a1  -  Stringadresse.                                         *
*****************************************************************************
write:        lea       bug_font(pc),a6   ; Fontadresse.
              moveq     #1,d6             ; Offsets.
              moveq     #7,d7
              movea.l   a0,a3
get_chars:    moveq     #0,d0
              move.b    (a1)+,d0          ; Char aus String.
              beq.w     strg_ende         ; Nullbyte beendet.

              cmpi.b    #13,d0            ; Carrige Return ?
              bne.s     no_z_runter       ; ja --> Zeile runter.

              moveq     #1,d6             ; Wort-Offsets zurÅck.
              moveq     #7,d7
              lea       160*8(a3),a3
              movea.l   a3,a0
              bra.s     get_chars

no_z_runter:  cmp2.w    chars_g(pc),d0    ; Groûbuchstaben ?
              bcs.s     no_c_g

              subi.b    #'A',d0
              lsr.w     #1,d0             ; In Byte verschoben ?
              bcc.s     no_in_w_0
              lea       (1.b,a6,d0.w*8),a5      ; Buchstabenfontadresse.
              bra.s     set_char
no_in_w_0:    lea       (a6,d0.w*8),a5
              bra.s     set_char

no_c_g:       cmp2.w    chars_k(pc),d0    ; Kleinbuchstabe ?
              bcs.s     no_c_k

              subi.b    #'a',d0
              lsr.w     #1,d0
              bcc.s     no_in_w_1
              lea       (1+160*8.w,a6,d0.w*8),a5
              bra.s     set_char
no_in_w_1:    lea       (160*8.w,a6,d0.w*8),a5
              bra.s     set_char

no_c_k:       cmp2.w    chars_d(pc),d0
              bcs.s     sonderzei

              subi.b    #'0',d0
              lsr.w     #1,d0
              bcc.s     no_in_w_2
              lea       (13*8+1.b,a6,d0.w*8),a5
              bra.s     set_char
no_in_w_2:    lea       (13*8.b,a6,d0.w*8),a5
              bra.s     set_char

sonderzei:    moveq     #14-1,d5          ; Gîûe Sonderzeichentabelle.
              lea       sondertab(pc),a5  ; Zeichen mit allen So-zei. vergl.
              move.l    a5,a4
so_lp:        cmp.b     (a5)+,d0          ; Zeichen vergl.
              dbeq      d5,so_lp
              tst.w     d5                ; Zeichen gefunden ?
              bmi.s     no_char           ; nein --> ?
              neg.w     d5                ; Offsettabelle steht vor den So-z.
              move.l    a6,a5
              adda.w    (-2.b,a4,d5.w*2),a5

set_char:                                 ; Zeichen setzen.
OFFSET        SET       0
              REPEAT
              move.b    OFFSET(a5),OFFSET(a0)
OFFSET        SET       OFFSET+160
              UNTIL     #(8-1)

no_char:      adda.l    d6,a0             ; Screenadr. weiter.
              exg       d6,d7
              bra.w     get_chars

strg_ende:    rts

chars_g:      DC.W      'A','Z'           ; Groûbuchstaben.
chars_k:      DC.W      'a','z'           ; Kleinbuchstaben.
chars_d:      DC.W      '0','9'           ; Zahlen.
soofftab:     DC.W      18*8+1,18*8,19*8+1,19*8 ; Sonderzeichenoff. ; {
              DC.W      1280+14*8+1,1280+15*8,1280+13*8,1280+13*8+1 ; |
              DC.W      1280+14*8,1280+15*8+1,1280+16*8,1280+16*8+1 ; |
              DC.W      1280+17*8,1280+17*8+1                       ; |
sondertab:    DC.B      ',.?!();:-=@/+*'                            ; }

******************************************************************************
* Errorhandler... Im <trapcc> (Vektor 7) Vektor.                             *
* Nach Aufruf untersucht der Handler anhand des <trap>-Befehls, ob ein Operand
* (= Fehlernummer) existiert und wie groû dieser ist (16 oder 32 Bit).       *
* Er holt die Nummer, erweitert sie gegebenenfalls auf 32 Bit und Åbergibt sie
* der "normalen" Errorroutine.                                               *
* Die verÑnderten Register werden vorsichtshalber im Speicher gesichert, so- *
* llte das Programm fortgefÅhrt werden.                                      *
******************************************************************************
err_handler:  movem.l   d0/a0,save_regs   ; Sollt weitergefÅhrt werden...

              move.l    $08(sp),a0        ; Adresse des <trap>-Befehls
              btst      #2,([a0])         ; Datenwort angegeben ?
              beq.s     no_ext_word       ; 0: cpTRAPcc, TRAPcc

              move.w    (a0),d0           ; Befehl holen.
              andi.b    #$03,d0           ; Bit 0-1: 10 : Word Operand
              cmp.b     #$03,d0           ;          11 : Long Operand
              beq.s     trapcc_l          ; 11: 32 Bit Nummer.

              move.w    2(a0),d0          ; <trapcc.w>: Fehlernummer
              ext.l     d0
              move.l    save_regs+4,a0
              bra.s     r_error

no_ext_word:  
;             moveq     #0,d0             ; Nr.0 : Keine Fehlernummer
;             move.l    save_regs+4,a0
              move.l    #'--- ',err_t_nr  ; Keine Fehlernummer angetroffen.
              move.b    #0,err_t_nr+3
              lea       err_msg(pc),a0
              bra.w     r_error           ; Von dort gibt es kein ZurÅck...

trapcc_l:     move.l    2(a0),d0          ; <trapcc.l>: 32 Bit Fehlernummer
;             move.l    save_regs+4,a0

              lea       err_t_nr(pc),a0   ; Fehlernummer in String.
              bsr.w     ltoa
              lea       err_msg(pc),a0
              bra.s     r_error
              nop

*****************************************************************************
* Allgemeine Errorroutine.                                                  *
* PARAMETER:  a0.l  -  Adresse auf Fehlerstring.                            *
*****************************************************************************
r_error:      move      #$2700,sr         ; IRQs killen.

              move      a0,usp

              move.l    scr_lst_16,d0
              SET_V_ADR d0,d1
wait_till:    move.b    $ffff8201.w,d0
              move.b    $ffff8203.w,d1
              cmp.b     scr_lst_16+1,d0
              bne.s     wait_till
              cmp.b     scr_lst_16+2,d1
              bne.s     wait_till

              bsr.w     hw_switch_16      ; Betriebssystem auf 16 Farben.

              move.l    #$000000ff,$ffff9800.w  ; Text: weiû auf blauem Back.
              move.l    #$ffffffff,$ffff9804.w

              movea.l   scr_lst_16,a0     ; Sichtbarer Screen lîschen und die
              movea.l   a0,a6             ; Fehlermeldung ausgeben.
              move.w    #38400/4-1,d7
clr_err_scr:  clr.l     (a6)+
              dbra      d7,clr_err_scr

              move      usp,a1
              bsr.w     write             ; Fehlerstring ausgeben.

         IFEQ (GAMEZONE-an)               ; Im Demo nur noch auf externen IRQ
              stop      #$2700            ; warten, im Debugmodus noch den
         ELSE                             ; Debugger warmhalten.
              illegal                     ; bzw. diesen anspringen !
         ENDIF

*****************************************************************************
* Genereller Fehler (Hardwarefehler...)                                     *
* d7.l : Magic: $12345678                                                   *
* d6.l : Nummer: nur gÅltig bei Magic                                       *
*****************************************************************************
gen_error:    cmpi.l    #$12345678,d7     ; Stimmt Magic ?
              beq.s     korrekt

              lea       myt_error(pc),a0  ; Seltsam !
              bra.w     r_error

korrekt:      neg.l     d6
              move.l    d6,d0
              lea       ge_err_nr(pc),a0

              lea       gen_error_t(pc),a0
              bra.w     r_error

*****************************************************************************
* Die Exceptionfehlerroutinen: Total billig, aber existent !                *
*****************************************************************************
tex_error:    lea       tex_err_txt(pc),a0
              bra.w     r_error
fpu_error:    lea       fpu_err_txt(pc),a0
              bra.w     r_error
mmu_error:    lea       mmu_err_txt(pc),a0
              bra.w     r_error

*****************************************************************************
* Konvertiert Integer (32 Bit) --> ASCII:                                   *
* Ausgabe linksbÅndig, unnutze Nullen werden abgeschnitten.                 *
* Parameter:  d0.l  -  Value                                                *
*             a0.l  -  Stringadresse.                                       *
*****************************************************************************
ltoa:         movem.l   d0-a6,-(sp)

              tst.l     d0                ; Negative Zahl ?
              bpl.s     prva_noneg

              neg.l     d0                ; Minus voranstellen.
              move.b    #'-',(a0)+

prva_noneg:   moveq     #9,d7             ; 10 Stellen untersuchen
              sf        d6                ; Nullflag: linke Nullen abschneiden
              move.l    #1000000000,d5    ; Startteiler
chk_stelle:   move.l    d0,d1
              divul.l   d5,d0:d1          ; Result -> d1 / Rest -> d0
              tst.l     d1
              beq.s     zero

              st        d6                ; Ab jetzt alle Nullen
              add.b     #'0',d1           ; ins ASCII-Format
              move.b    d1,(a0)+
              bra.s     w_c_val

zero:         tst.b     d6                ; noch in den unbenutzten Nullen ?
              beq.s     w_c_val

              move.b    #'0',(a0)+
              
w_c_val:      divu.l    #10,d5            ; Quotient / 10
              dbra      d7,chk_stelle

              clr.b     (a0)              ; Schluûbyte.
              movem.l   (sp)+,d0-a6
              rts

*****************************************************************************
* Checkt die Texte, ob sie verÑndert wurden.                                *
* Klar, ein simpler Schutz, aber wenigstens eine Lamerbremse, da man schon  *
* mal einen Debugger benutzen muû und nicht nur einen Editor braucht, um ir-*
* gendwas anzustellen (z.B. die Copyrights Ñndern).                         *
*****************************************************************************
chk_txts:     movem.l   d0-a6,-(sp)

              lea       anim_buf,a0
              lea       20000(a0),a1
              bsr.w     clr_mem

              lea       text1(pc),a0
              lea       anim_buf,a1
              bsr.w     load_file
              bmi.s     txt_changed       ; Text nicht vorhanden o.Ñ.
              cmp.l     chk_le1_l(pc),d0  ; Filegrîûe stimmt ?
              bne.s     txt_changed       ; Nein --> dumpfe énderung...

              lea       anim_buf,a0       ; Checksummen berechnen.
              move.w    d0,d7
              lsr.w     #1,d7
              subq.w    #1,d7
              bsr.w     calc_chksum
              
              cmp.b     chk_su1_b(pc),d0  ; Stimmen die Checksummen ?
              bne.s     txt_changed
              cmp.w     chk_su1_w(pc),d1
              bne.s     txt_changed

              lea       anim_buf,a0       ; Zweiten Text checken.
              lea       20000(a0),a1
              bsr.w     clr_mem

              lea       text2(pc),a0
              lea       anim_buf,a1
              bsr.w     load_file
              bmi.s     txt_changed
              cmp.l     chk_le2_l(pc),d0
              bne.s     txt_changed

              lea       anim_buf,a0
              move.w    d0,d7
              lsr.w     #1,d7
              subq.w    #1,d7
              bsr.w     calc_chksum
              
              cmp.b     chk_su2_b(pc),d0
              bne.s     txt_changed
              cmp.w     chk_su2_w(pc),d1
              bne.s     txt_changed

              movem.l   (sp)+,d0-a6
              rts

txt_changed:  lea       file_chg_txt(pc),a0
              bra.w     r_error

calc_chksum:  moveq     #0,d0             ; Berechnte billigste Checksumme,
              moveq     #0,d1             ; simples EOR, einmal byte, dann
chk_txt:      move.b    (a0)+,d2          ; wortweise.
              eor.b     d2,d0
              lsl.w     #8,d2
              move.b    (a0)+,d2
              eor.b     d2,d0
              eor.w     d2,d1
              dbra      d7,chk_txt
              rts

*****************************************************************************
* LÑdt File in Buffer.                                                      *
* PARAMETER:  a0.l  -  Dateinamen.                                          *
*             a1.l  -  Buffer.                                              *
* RETURN:     d0.l  -  Anzahl gelesener Bytes.                              *
*****************************************************************************
load_file:    pea       (a1)
              move.l    #100000,-(sp)     ; Texte werden kaum lÑnger sein...

              clr.w     -(sp)
              pea       (a0)
              move.w    #$3d,-(sp)
              trap      #1
              addq.l    #8,sp

              tst.l     d0
              bmi.s     lf_error

              move.w    d0,d7
              move.w    d7,-(sp)
              move.w    #$3f,-(sp)        ; Fread (LÑnge und Adresse auf sp)
              trap      #1
              lea       12(sp),sp

              tst.l     d0
              bmi.s     lf_error

              move.l    d0,d6

              move.w    d7,-(sp)
              move.w    #$3e,-(sp)
              trap      #1
              addq.l    #4,sp

              move.l    d6,d0             ; Anzahl gelesener Bytes.
              rts

lf_error:     moveq     #-1,d0            ; Errorhandler (long).
              rts       

chk_su1_b:    DC.B      $0b               ; Checksummen (Byte und Wort).
chk_su2_b:    DC.B      $f3
chk_su1_w:    DC.W      $444f
chk_su2_w:    DC.W      $50a3
chk_le1_l:    DC.L      2503              ; DateilÑngen
chk_le2_l:    DC.L      10150

*****************************************************************************
* öberprÅft, ob Speicherbereich Werte != 0 enthÑlt.                         *
* PARAMETER:  a0  -  Adresse.                                               *
*             d7  -  LÑnge -1.                                              *
*****************************************************************************
tst_mem:      movem.l   d0/d7/a0,-(sp)    ; Reine Debuggingroutine.
tst_lp:       tst.w     (a0)+
              bne.s     tst_ill
              dbra      d7,tst_lp
              moveq     #-1,d0
              movem.l   (sp)+,d0/d7/a0
              rts
tst_ill:      moveq     #0,d0
              movem.l   (sp)+,d0/d7/a0
              rts

*****************************************************************************
*  Die Fehlermeldungen bei AbstÅrzen (selbst sowas soll es geben !).        *
*****************************************************************************
err_msg:      DC.B      ' Sorry, an internal error appeared !?!',13
              DC.B      ' Probably a file was damaged and datas',13
              DC.B      ' were changed. Please recopy the demo.',13,13
              DC.B      ' Please excuse and now reset.....',13,13
              DC.B      ' Errornumber: '
err_t_nr:     DC.B      '01234567890',0
myt_error:    DC.B      ' Sorry, an mysterious error apperead!',13
              DC.B      ' Read *readme.txt* and now reset...',13,13
              DC.B      ' Please excuse and now reset.....',0
gen_error_t:  DC.B      ' Sorry, an general error apperead!',13
              DC.B      ' Please excuse and now reset...',13,13
              DC.B      ' Errornumber: '
ge_err_nr:    DC.B      '0123457890',0
mmu_err_txt   DC.B      ' Sorry, the demo was stopped by an',13
              DC.B      ' MMU-exception (???). Please disable',13
              DC.B      ' virtual rams, Multitask-systems or',13
              DC.B      ' any other kind using the PMMU !',13,13
              DC.B      ' Please excuse and now reset...',0
fpu_err_txt:  DC.B      ' Sorry, the demo was interrupted by ',13
              DC.B      ' an FPU exception. If you dont own an',13
              DC.B      ' exotic floating-unit, it was my mis-',13
              DC.B      ' take.',13,13    
              DC.B      ' Please excuse and now reset...',0
tex_err_txt:  DC.B      ' Sorry,  no software without errors,',13
              DC.B      ' and the *E.X-Illusion* demo crashed',13
              DC.B      ' at this moment.',13
              DC.B      ' Please excuse and now reset...',0
err_id:       DC.B      ' Datas changed in files. ',13
              DC.B      ' Please read the instructions in ',13
              DC.B      ' *install.txt* !',13,13
              DC.B      ' Please excuse and now reset...',0
err_open:     DC.B      ' Datafile couldnt be opened !',13
              DC.B      ' Please read the instructions in ',13
              DC.B      ' *install.txt* !',13,13
              DC.B      ' Please excuse and now reset...',0
err_read:     DC.B      ' Read error in datafile !',0
              DC.B      ' Please read the instructions in ',13
              DC.B      ' *install.txt* !',13,13
              DC.B      ' Please excuse and now reset...',0
file_chg_txt: DC.B      ' The demofiles were changed. Please',13
              DC.B      ' recopy the files !',13,13
              DC.B      ' Now reset and read *install.txt*.',0
              EVEN

;             DATA ; Datenteil, der PC (word)-relativ erreichbar sein soll.

system:       DS.B      16                ; Systemparameter.
show_frm:     DC.W      0                 ; Angezeigte Frames (im VBL-Flip).
frm_counter:  DC.W      0                 ; Frame-Counter
vbl_counter:  DC.W      0                 ; { VBL-Counter
__past_vbls:  DC.W      0                 ; } FÅr Tastaturzeitabfrage.
disable_sync: DC.W      0                 ; Bildwechsel im VBL ?
cp_fin:       DC.W      0                 ; Paralleles Screenlîschen fertig ?
anim:         DC.W      0                 ; Aktueller Animationscounter.
dsp_works:    DC.B      0                 ; Arbeitet DSP an 3D-Dingen ?
time:         DS.B      4,0               ; Zeit (h/m/sek/hundertstel)
trnst_all:    DC.W      0                 ; Punkte/FlÑchen Åbertragen ?
setup:        DC.B      0                 ; Setup aufrufen ?
hidden:       DC.B      0                 ; Hidden Screens ermîglichen ?
akt_blk:      DC.W      0                 ; Aktueller Nachladeblock.
disable_pro:  DC.W      0                 ; Protrackerplayer ausknipsen ?

clipping:     DC.W      VISIBLE_X0,VISIBLE_X1-1 ; minx/maxx
              DC.W      VISIBLE_Y0,VISIBLE_Y1+1 ; miny/maxy

anz_visibles: DC.W      0                 ; Anz. sichtbarer Faces.
akt_vbl:      DC.W      0                 ; Aktueller SynczÑhlerstand.
akt_scr:      DC.W      1                 ; { aktueller phy. Screen.
akt_log:      DC.W      0                 ; } aktuelle log. Screen.
anz_vbls:     DC.W      _ANZ_VBLS         ; Anzahl VBL (syncro).
_bytes_scan:  DC.W      BYTES_SCAN
_bytes_scr:   DC.L      BYTES_SCREEN
_anz_screens: DC.W      ANZ_SCREENS
clr_off:      DC.L      _CLR_OFF
scr_lst:      DC.L      scr_lst_32k       ; akt. Videoramliste.
scr_lst_32k:  DS.L      ANZ_SCREENS*2     ; log. Videorams (High-Colour)
scr_lst_16:   DS.L      _16_ANZ_SCREENS*2 ;         "      (16-Farben)
scr_lst_256:  DS.L      _256_ANZ_SCREENS*2 ;        "      (256-Farben)
screen:       DS.L      2                 ; aktuell log/phy. V-Ram.
clr_scr:      DC.L      0                 ; Lîschadresse
hintergrund:  DC.W      0                 ; Hintergrundfarbe (beim Lîschen).
buf_para:     DS.L      16

lightsource:  DC.W      0,0,900           ; {  Lichtquelle
beovek:       DC.W      0,0,0             ; |  Blickwinkel
beo:          DC.W      0,0,-150          ; }  Beobachter
speed:        DC.W      0                 ; Geschwindigkeit.

world:        DC.L      0                 ; {
world_init:   DC.L      0                 ; | Aktuelle Objekte: Routinen...
world_frame:  DC.L      0                 ; |
world_vbl:    DC.L      0                 ; |
world_data:   DC.L      0                 ; | 3D-Daten.
world_bmp:    DC.L      0                 ; } Bitmapanidaten.
bmp_ani:      DC.W      0                 ; { Akt. Bitmap Ani.
ani_frm:      DC.W      0                 ; } Akt. Frame relativ zum Anistart.

li_re:        DC.L      l_koo,l_light,r_koo,r_light ; Adressen der Koo.arrays

; Externe Grafiksystemparameter (vom Installierungsproggy gesetzt...)
; SpÑter im BSS und nachladen Åber .INF-File.
detail:       DC.B      _DETAIL           ; Detaillevel.
shading:      DC.B      LIGHT_SRC         ; Shading.
use_fpu:      DC.B      _USE_FPU          ; FPU benutzen.
use_blitter:  DC.B      _USE_BLITTER      ; Blitter benutzen.
planes:       DC.B      _PLANES           ; Anzahl Planes.
pals:         DC.B      REAL_PALS         ; Hell->Dunkel oder Farbe-Farbe Pals.
debugging:    DC.B      DEBUG_INF         ; Debugginginfos/Features ?
              EVEN

vbl_f1_count: DC.W      0                 ; { VBL-Fading: Counter
vbl_f1_scol:  DC.W      0                 ; | VBL-Fading: Farbe 1
vbl_f1_anz:   DC.W      0                 ; | VBL-Fading: Anzahl Farben
vbl_f1_sfrm:  DC.W      0                 ; | VBL-Fading: Startframe
vbl_f1_tab:   DC.L      0                 ; } VBL-Fading: Palettentabelle
vbl_f2_count: DC.W      0                 ; {
vbl_f2_scol:  DC.W      0                 ; | VBL-Fading Fading 2
vbl_f2_anz:   DC.W      0                 ; |
vbl_f2_sfrm:  DC.W      0                 ; |
vbl_f2_tab:   DC.L      0                 ; }

              DATA

              DS.B      512               ; Abstand zum Protracker-DATA

        PATH  "f:\sys_3\errorscr\"        ; Font fÅr Fehlerausgaben (8*8)
bug_font:     INLINE    "bugfont3.img"    ; (auch fÅr Debugginginfos)

              PATH      "f:\sys_3\resource\"
;D_metronom:  inline    "metronom.dat"    ; "Metronom-Zeit"
;D_ex_logo_x: ;inline   "ex_mono.dat"     ; Fading Objects.

;D_wp_swing:  ;inline   "sine_sw1.dat"    ; "World Plates"
;D_wp_cos1:   ;inline   "sin_wp2.dat"
;D_smooth1:   ;inline   "smooth_1.dat"
;D_smooth2:   ;inline   "smooth2.dat"
;D_wp_beo:    ;inline   "wp_beo.dat"

D_strecke:    ;inline   "strecke.dat"     ; "Enduro Racer 2"
D_er_move:    ;inline   "str_beo.dat"
D_er_beo:     ;inline   "er_beolk.dat"
D_wald:       ;inline   "wald.dat"

D_test_txt:   ;inline   "xxx.dat"         ; Testtext: 226*96*4 Strophen.
D_hfi_tab1:   ;inline   "sinedat1.dat"    ; Sinustabellen fÅr Einfadeeffekt
              ;inline   "sinedat1.dat"    ; Highcolour 1

D_gp_bo:      ;inline   "gp_bo.dat"       ; Gouraud-Fotos.
D_gp_beos:    ;inline   "gp_fly.dat"

;D_gnadenlos: inline    "gnadnlos.dat"    ; Gedichtsanzeiger...

;D_li_xxxii:  inline    "li_xxxii.dat"    ; Cubeswinger.

;D_splat1:    inline    "splat1_f.dat"    ; "swinging viel"
;D_spr_birne: inline    "birne.dat"
;D_sw_bitmap1:          inline            "pactest.dat"
;D_jl_vi:     inline    "jl_vi.dat"
;D_eyes:      inline    "eyes.dat"        ; Megacubes
;D_mugpic0:   inline    "file12.dat"

;D_auralogo:  inline    "auralogo.tpi"    ; Intrologo.
;D_l_viii:    inline    "l_viii.dat"
;D_intro_1:   inline    "in_gfx_1.dat"    ; Introtexte.
;D_intro_2:   inline    "in_gfx_2.dat"
;D_intro_back: inline   "file7.dat"       ; Introhintergrund.

;D_gb_smooth1:          inline            "gb_sm1.dat"  ; Gouraud-Proof.
;D_gb_smooth2:          inline            "gb_sm2.dat"
;D_gb_smooth3:          inline            "gb_sm3.dat"
;D_saeulen:   inline    "file11.dat"      ; Gouraud-Proof
;D_gb_pic1:   inline    "file13.dat"
;D_mugpic3:   inline    "file9.dat"

;D_si180_48:  inline    "st180_48.dat"    ; Dungeon-Explode.
;D_li_xlvi:   inline    "li_xlvi.dat"

D_module_fut: ;inline   "..\music\astaroid.fut" ; Das goilste Tracker Mod !

D_ext_back1:  ;inline   "backtxt1.dat"    ; Extro.
D_ext_back2:  ;inline   "backtxt2.dat"

;D_mugpic1:   inline    "file2.dat"       ; Zwei Bilder und eine Animation im
;D_mugpic2:   inline    "file4.dat"       ; "Sternenhimmel"-Screen.
;D_mugpal:    inline    "muganis.pal"     ; Palette.
;D_mugani:    inline    "mugani.dat"

              BSS
              EVEN
              DS.B      16
bss_start:
; Allgemeine und spezielle Buffer.
scancod:      DS.W      1
save_regs:    DS.L      16                ; Registerbuffer bei Error
scr_clr:      DS.W      1                 ; Endeflag der Screenlîschroutine.
lp:           DS.L      3                 ; Vektorbuffer Shading
start_time:   DS.B      4                 ; Zeit, zu der das Demo gest. wurde.
fhandle:      DS.W      1                 ; Filehandle fÅr's Laden.

; Gouraud- und Polygonroutine:
add_poi:      DS.L      2*ANZ_SHD_COLS+1  ; Pointer in der Additionstab.
add_tab:      DS.L      2*SCR_WIDE*2*ANZ_SHD_COLS+100   ; Additionstabelle
l_koo:        DS.W      SCR_H             ; { Koordinaten und Farbarrays
l_light:      DS.W      SCR_H             ; | fÅr die Gouraudroutine...
r_koo:        DS.W      SCR_H             ; | (werden auch kurzzeitig fÅr
r_light:      DS.W      SCR_H             ; }  Diskladen verwendet!)
tab_160:      DS.L      H16_Y_MAX         ; Scanlineoffsets fÅr 16 Cols.
h_tab:        DS.B      16*16             ; H-Line-Bitmap und Routadrs.
h_routs:      DS.B      16*270            ; H-Line-Routinen.
              DS.L      16
l_off:        DS.L      H16_X_MAX+32      ; 4-Plane HLine-Linkstabelle
r_off:        DS.L      H16_X_MAX+32      ; 4-Plane HLine-Rechtstabelle
l_off_1:      DS.L      H16_X_MAX         ; 1-Plane HLinetabellen (4 Planes)
r_off_1:      DS.L      H16_X_MAX

; Welt- und Transformationssystem:
worlds:       DS.L      MAX_ANZ_ANIS
world_names:  DS.L      MAX_ANZ_ANIS
polygons:     DS.L      MAX_ANZ_FACES+1   ; Polygonpointer
worldarray:   DS.B      MAX_ANZ_FACES*5+200     ; Dort wird alles aufgebaut...
punkte:       DS.L      MAX_ANZ_PUNKTE
anz_punkte:   DS.W      1                 ; Anzahl Punkte in der "Welt"
anz_faces:    DS.W      1                 ; Anzahl Faces        "
anz_objekte:  DS.W      1                 ; Anzahl Objekte      "
visibles:     DS.W      MAX_ANZ_FACES     ; Return vom DSP
beoadd:       DS.L      3                 ; Fixkommabeobachter
obj_boxes:    DS.W      8*MAX_ANZ_OBJEKTE ; Boxen um Obj. (jeweils 2 Punkte)
obj_p_off:    DS.W      MAX_ANZ_OBJEKTE   ; Objektpunktoffsets.
obj_tra_buf:  DS.W      MAX_ANZ_PU_OBJ    ; max. Anzahl Punkte in einem Objekt
doppelline:   DS.W      4*MAX_ANZ_PUNKTE  ; Gegen doppeltes Zeichnen von Linien
anz_doppel:   DS.W      1                 ; Anzahl gezeichnete Linien

; FarbenverlÑufe und Farben:
irr_cols:     DS.L      ANZ_IRREALS+2     ; { FÅr die irrealen FarbverlÑufe.
col_adrs:     DS.L      ANZ_PALETTEN+1    ; } Farbpalettenpointer
cols_16:      DS.L      ANZ_PALETTEN+1    ; Farbenpointer fÅr 16 Farben.
colours:      DS.W      40*3*ANZ_PALETTEN ; Farbpalettenbuffer
irr_buff:     DS.W      32*3*ANZ_IRREALS  ; Irrealenbuffer
irr_pal_32k:  DS.L      ANZ_BASE_FLA      ; Farbpointerlisten
real_pal_32k: DS.L      ANZ_BASE_FLA      ;         "

; Bildschirm:
col_pal:      DS.L      16                ; Farbpalette im 16 Farben Modus.
scr_offs:     DS.L      SCR_HIGH
anz_clr16:    DS.W      1                 ; Anz. 16 Pixel Blîcke
free_screen:  DS.L      1                 ; Ein HC-Screen liegt im 16 Farbmode

; Videoram.
_screens:     DS.B      BYTES_SCREEN*ANZ_SCREENS+256    ; {
_end_screens: DS.B      512                             ; } ( > 256+128 Bytes)

l_off_2:      DS.L      H16_X_MAX         ; 1-Plane HLinetabellen (8 Planes)
r_off_2:      DS.L      H16_X_MAX
tab_320:      DS.L      SCR_HIGH          ; Scanlineoffsets fÅr 256 Cols.

; Alten Systemparameter (fÅr "Wiederaustritt" oder wegen unvermeindlichem Abschuû)
old_vadr:     DS.L      1                 ; Alte Videoramadresse.
vid_save:     DS.B      48                ; Alte Videosytem.

; Zufallszahlen.
random:       DS.W      ANZ_RANDOM        ; Zufallszahlen, am Anfang generiert.

; Animationssystem:
free:         DS.L      1                 ; Pointer fÅr aktuellen Stand.
bmp_ani_clrs: DS.L      _16_ANZ_SCREENS   ; Spritelîschadressen.
anim_buf:     DS.B      ANIM_BSS_SIZE     ; Freier Animationsspeicher.

bss_ende:     DS.B      16                ; Ende des PRG-BSS.

; DATA-Buffer fÅr Diskreload.
; Speicher fÅr komplette Demodaten (Musik, Grafik...)
per_base:     DS.B      PER_SIZE          ; Permanenten Grafikdaten.
module:       DS.B      MOD_SIZE          ; Module.
mem_base:     DS.B      DATA_SIZE         ; Demodatenbuffer.

; Stackbereiche, alle Stacks werden neu gesetzt (auûer USP):
              DS.B      STACKSIZE
_ssp:         DS.B      STACKSIZE         ; Master- und Interruptstack sollten
_msp:         DS.B      STACKSIZE         ; nicht gebraucht werden.
_isp:         DS.L      1                 ; Zur Sicherheit...
old_usp:      DS.L      1
old_msp:      DS.L      1
old_isp:      DS.L      1
