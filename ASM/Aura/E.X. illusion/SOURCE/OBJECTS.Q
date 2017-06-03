; This file contains the raw object data.
; Most of the objects were made using Cybersculpt and converted and optimized
; with own software (not to release, as too buggy).
; It also contains the information for the object initialisations and these
; objects, that has to be extruded first.

*****************************************************************************
* BASISOBJEKTE... (teilweise aus 3D2-File konvertiert)                      *
* (Weitere Objekte in "objects2.q", wobei alle Pointer und Namen in diesem  *
*  Filel sein mÅssen.)                                                      *
*                                                                           *
* Dir Farbinfo (LONG!) wird wie folgt ausgewertet:                          *
*             - Gouraud-Objekte (Realshade): wie "colours.q"  (HR)          *
*             -         "       (Irr-shade): wie "colshock.q" (HI)          *
*             - Polys. 16 Farben           : Farbe (0-15)     (16)          *
*             - Polys. 4 Planes (einfarbig): Plane (0-3)       (3)          *
*****************************************************************************

; LABEL               | Nr.   |Cols|        BESCHREIBUNG
; --------------------+-------+----+---------------------------------------
O_BALLON      EQU       0    ;| 16 | Heiûluftballon
O_CUBE_A      EQU       1    ;| 16 | Cube, Farben 1-6
O_CUBE_B      EQU       2    ;| 16 |   " ,   "    7-c
O_CUBE_C      EQU       3    ;| 16 |   " ,   "    ungerade 3-$d
O_CUBE_D      EQU       4    ;| 16 |   " ,   "    gerade 2-$c
MC_CUBE_1     EQU       5    ;| 16 | Cube fÅr Cubetunnel (Farbe 1-3)
MC_CUBE_2     EQU       6    ;| 16 |            "        (Farbe 4-6)
KREUZ_1       EQU       7    ;|  4 | Kreuz 1
WUERFEL_5     EQU       8    ;|  4 | 5 Quadrate
BLUETE_1      EQU       9    ;|  4 | 8 eckige Bluete.
BSTAMM_1      EQU       10   ;|  4 | Rechteckiger Stamm.
BSTAMM_12     EQU       11   ;|  4 |     "          "   Plane 2
BSTAMM_13     EQU       12   ;|  4 |     "          "   Plane 3
OPEN_QUADRAT  EQU       13   ;|  4 | Offenes Quadrat.
O_TABAUM_1    EQU       14   ;| 16 | Tannenbaum AusfÅhrung 1 (ohne Stumpf)
MC_CUBE_3     EQU       15   ;| 16 | Cube fÅr Cubetunnel (Farbe 7-9)
MC_CUBE_4     EQU       16   ;| 16 |            "        (Farbe 10-12)
BASE          EQU       17   ;| 16 | Bladerunner-Pyramide
H_ZEIGER      EQU       18   ;|  4 | Stundenzeiger fÅr Uhr (Plane 2)
M_ZEIGER      EQU       19   ;|  4 | Minutenzeiger         "
S_ZEIGER      EQU       20   ;|  4 | Sekund.zeiger         "
STRECKE_A     EQU       21   ;| 16 | StreckenstÅck 1 (abstrakt)
LOGO_E        EQU       22   ;|  4 | "E" vom "EX."-Logo. (Plane 3)
LOGO_X        EQU       23   ;|  4 | "X"        "        (Plane 2)
LOGO_P1       EQU       24   ;|  4 | Logopunkt           (Plane 1)
LOGO_P0       EQU       25   ;|  4 | Logopunkt           (Plane 0)
O_BALLON_65   EQU       26   ;| HR | Gouraudballon.
O_EXLOGO_65   EQU       27   ;| HR | EX-Logo (Extrude).
O_PLANE_1     EQU       28   ;| HR | Plane 1 (rot).
O_PLANE_2     EQU       29   ;| HR | Plane 2 (grÅn).
O_PLANE_3     EQU       30   ;| HR | Plane 3 (blau).
O_PLANE_4     EQU       31   ;| HR | Plane 4 (weiss).
PLANE_XZ_1    EQU       32   ;| 16 | Zweiseitige Plane parallel zur x/z-Ebene
PLANE_XY_1    EQU       33   ;| 16 |                "               x/y-Ebene
PLANE_YZ_1    EQU       34   ;| 16 |                "               y/z-Ebene
PLANE_XZ_2    EQU       35   ;| 16 |                " (Farbebene 2)
PLANE_XY_2    EQU       36   ;| 16 |                "               x/y-Ebene
PLANE_YZ_2    EQU       37   ;| 16 |                "               y/z-Ebene
PLANE_XZ_3    EQU       38   ;| 16 |                " (Farbebene 3)
PLANE_XY_3    EQU       39   ;| 16 |                "               x/y-Ebene
PLANE_YZ_3    EQU       40   ;| 16 |                "               y/z-Ebene
PLANE_XZ_4    EQU       41   ;| 16 |                " (Farbebene 4)
PLANE_XY_4    EQU       42   ;| 16 |                "               x/y-Ebene
PLANE_YZ_4    EQU       43   ;| 16 |                "               y/z-Ebene
SPI_STERN     EQU       44   ;|  4 | Stern, Extrudeobjekt. (Plane 0+1)
SPI_STERN2    EQU       45   ;|  4 |           "           (Plane 2+3)
EXTR_TEST     EQU       46   ;|  4 | Extrudetest.
LOGO_E_3D     EQU       47   ;|  4 | "E"-3D.
KREUZ_2       EQU       48   ;| 16 | Kreuz, Extrude...
KREUZ_3       EQU       49   ;| 16 | Kreuz flach, gleiche Umrisse wie KREUZ_2
BOPLANE_1     EQU       50   ;| 16 | Bodenplane (x-z), EINSEITIG.
BOPLANE_2     EQU       51   ;| 16 | Bodenplane (x-z), EINSEITIG.
BOPLANE_3     EQU       52   ;| 16 | Bodenplane (x-z), EINSEITIG.
BOPLANE_4     EQU       53   ;| 16 | Bodenplane (x-z), EINSEITIG.
OB_EX_3D      EQU       54   ;| RP | E.X-Extrude-Logo 2 (sparsamere Ausgabe)
OBJ_INTRO1    EQU       55   ;| 16 | SchiebetÅr.
METRONOM      EQU       56   ;| 16 | Metronom Basis.
METRONOM_PEN1 EQU       57   ;| 16 | Metronom Pendel (Farbe 4 (Metrocol 1))
XY_QUAD_1     EQU       58   ;| 16 | Plane senkrecht zur z-Achse, quadratisch
XY_QUAD_2     EQU       59   ;| 16 |                    "
XY_QUAD_3     EQU       60   ;| 16 |                    "
XY_QUAD_4     EQU       61   ;| 16 |                    "
RING_1        EQU       62   ;| 16 | Groûer Ring zur Umrandung.
E_CUBE        EQU       63   ;| 16 | Cube auf Farben 12-14
HC_CUBE_1     EQU       64   ;| IR | Highcolour Cube 1.
HC_CUBE_2     EQU       65   ;| IR | Highcolour Cube 2 (Interferenz-Shading).
HC_CUBE_3     EQU       66   ;| RP | Highcolour Cube 3.
GIGA_PLATE    EQU       67   ;| 16 | Riesige Wand.
GIGA_TOR      EQU       68   ;| 16 | Toreinfahrt fÅr ER-2
ROOMER1       EQU       69   ;| 16 | "(T)Raumschiff Nummer 1"
METRONOM_PEN2 EQU       70   ;| 16 | Metronom Pendel (Farbe 5 (Metrocol 2))
METRONOM_PEN3 EQU       71   ;| 16 |        "        (Farbe 6 (Metrocol 3))
METRONOM_PEN4 EQU       72   ;| 16 |        "        (Farbe 7 (Metrocol 4))
METRONOM_PEN5 EQU       73   ;| 16 |        "        (Farbe 8 (Metrocol 5))
METRONOM_PEN6 EQU       74   ;| 16 |        "        (Farbe 9 (Metrocol 6))
METRONOM_PEN7 EQU       75   ;| 16 |        "        (Farbe 10 (Metrocol 7))
METRONOM_PEN8 EQU       76   ;| 16 |        "        (Farbe 11 (Metrocol 8))
METRONOM_PEN9 EQU       77   ;| 16 |        "        (Farbe 12 (Metrocol 8))
METRONOM_PEN10 EQU      78   ;| 16 |        "        (Farbe 13 (Metrocol 8))
METRO_UNDER   EQU       79   ;| 16 | Untergrund fÅr Metronome.
KUGEL_1       EQU       80   ;| 16 | Als Kugel mit wenig FlÑchen generiert.
;                             |    |
; Objekte in "objects2.q":    |    |
;                             |    |
KUGEL_BIG     EQU       81   ;|  4 | Sehr viele FlÑchen (96 StÅck).
FO_PLANE_1    EQU       82   ;|  4 | EinplaneflÑche (Plane 0/1).
FO_PLANE_2    EQU       83   ;|  4 | EinplaneflÑche (Plane 1/0).
PFEIL         EQU       84   ;|  4 | Pfeil (Extrude).
CUBE_24       EQU       85   ;| RP | Cube mit herausgeschobenen FlÑchenmitten.
CUBE_24_2     EQU       86   ;| RP |                "       (nur gelb)
CUBE_24_3     EQU       87   ;| RP |                "       (nur cyan)

;=============================================================================
; Objektdatenpointer.
anz_base_obj: DC.W      (end_obj_lst-objekte)/4 ;11 ; Anz. Grundobjekte
objekte:      DC.L      ballon
              DC.L      cube_a,cube_b,cube_c,cube_d
              DC.L      d_mc_cube_1,d_mc_cube_2
              DC.L      kreuz_1_obj
              DC.L      wuerfel_5_obj
              DC.L      blume_obj,blumenstamm_obj1,blumenstamm_obj2,blumenstamm_obj3
              DC.L      obj_open_quad
              DC.L      o_tannenbaum_1
              DC.L      d_mc_cube_3,d_mc_cube_4
              DC.L      PYRAMID
              DC.L      ob_h_zeiger,ob_m_zeiger,ob_s_zeiger
              DC.L      ob_strecke_a
              DC.L      ob_logo_e,ob_logo_x,ob_logo_p1,ob_logo_p0
              DC.L      ob_ballon_2,ob_ex_logo1
              DC.L      ob_plane_1,ob_plane_2,ob_plane_3,ob_plane_4
              DC.L      ob_plane_xz,ob_plane_xy,ob_plane_yz     ; Doppelpolys.
              DC.L      ob_plane_xz2,ob_plane_xy2,ob_plane_yz2
              DC.L      ob_plane_xz3,ob_plane_xy3,ob_plane_yz3
              DC.L      ob_plane_xz4,ob_plane_xy4,ob_plane_yz4
              DC.L      ob_stern1,ob_stern2
              DC.L      ex_test                 ; Extrudetest
              DC.L      ob_e_3d                 ; "E"-3D.
              DC.L      kreuz_2_obj,kreuz3_obj  ; Extrude-Kreuz und Flaches.
              DC.L      o1_plane_xz,o1_plane_xz2,o1_plane_xz3,o1_plane_xz4
              DC.L      obj_ex_2
              DC.L      obj_open_1a
              DC.L      obj_metro,obj_metro_p
              DC.L      qu_plane_xy,qu_plane_xy2,qu_plane_xy3,qu_plane_xy4
              DC.L      obj_ring_1
              DC.L      cube_e
              DC.L      obj_hccube1,obj_hccube2,obj_hccube3
              DC.L      giga_plate1,giga_plate2
              DC.L      obj_roomer1
              DC.L      obj_metro_p1,obj_metro_p2,obj_metro_p3,obj_metro_p4
              DC.L      obj_metro_p5,obj_metro_p6,obj_metro_p7,obj_metro_p8
              DC.L      obj_metro_p9,obj_underground
              DC.L      obj_kugel_1
; Objekte in "objects2.q"
              DC.L      bigsphere               ; Groûe Kugel.
              DC.L      obj_fo_pl1,obj_fo_pl2   ; Rechtecke.
              DC.L      obj_pfeil               ; Extrude-Pfeil.
              DC.L      are_you_cube1,are_you_cube2,are_you_cube3

end_obj_lst:  ; Endlabel Objektliste.

*****************************************************************************
* EXTRUDEOBJEKTE...                                                         *
* Objekt, die aus Grunddaten erzeugt werden.                                *
*                                                                           *
* Objekt muû FrontflÑche und Buffer fÅr zu erzeugende FlÑchen enthalten.    *
* Die "TiefenflÑchen" werden Åber eine Auûenkantenliste erzeugt, welche     *
* auch Farbinfos enthÑlt.                                                   *
*****************************************************************************

; Eintrag:    0.w  -  reserviert
;             2.w  -  Extrudetiefe (z-Koordinaten werden auf der RÅckseit um
;                                   ~-Steps verschoben).
;             4.l  -  Objektdaten (Front/Bufferplatz etc)
;             8.l  -  Kantenliste zu diesem Objekt.
anz_extr_obj: DC.W      (end_ext_lst-extrude_list)/12   ; Anz. Extrudeobjekte.
extrude_list: DC.L      50,ex_test,ex_kante         ; Testobjekt
              DC.L      30,ob_e_3d,ob_e_3d_kan      ; "E"
              DC.L      25,kreuz_2_obj,kreuz_2_kan  ; Kreuz.
              DC.L      50,obj_ex_2,obj_ex_2_kan    ; "E-IL"-Logo.
              DC.L      99,obj_open_1a,obj_open_1ak ; Intro-SchiebtÅr.
              DC.L      25,obj_metro,kan_metro      ; Metronom
              DC.L      200,obj_ring_1,kan_ring_1   ; Groûer Ring.
              DC.L      200,giga_plate2,giga_pl2_kan
              DC.L      15,obj_pfeil,kan_pfeil      ; Pfeil.

end_ext_lst:  ; Endlabel Extrude-Objekteliste.


;=============================================================================


* 'VENTILATOR' (C) 1994 Jochen Knaus. [///SYS-3/// FILE].
; ...16 FARBEN MODE...
ballon:
 dc.w 26   * Anz. Polygone
 dc.w 27   * Anz. Punkte
 dc.l ballon_punkte
 ds.l 26,0

* Polygondaten: Farbe (.l), Anz. Ecken - 1, A[0],A[1]..A[n],A[0]:

 dc.w  0,$2,2,5,1,0,5,30,30,1
 dc.w  0,$3,3,1,5,6,2,1,1,1,30,30
 dc.w  0,$2,3,2,6,7,3,2,1,1,30,30
 dc.w  0,$3,2,7,4,3,7,30,30,1
 dc.w  0,$3,2,8,5,0,8,30,30,1
 dc.w  0,$2,3,5,8,9,6,5,1,30,1,30
 dc.w  0,$3,3,6,9,10,7,6,1,30,1,30
 dc.w  0,$2,2,10,4,7,10,30,30,1
 dc.w  0,$2,2,11,8,0,11,30,30,1
 dc.w  0,$3,3,8,11,12,9,8,1,30,1,30
 dc.w  0,$2,3,9,12,13,10,9,1,30,1,30
 dc.w  0,$3,2,13,4,10,13,30,30,1
 dc.w  0,$3,2,14,11,0,14,30,30,1
 dc.w  0,$2,3,11,14,15,12,11,30,1,1,30
 dc.w  0,$3,3,12,15,16,13,12,30,1,1,30
 dc.w  0,$2,2,16,4,13,16,30,30,1
 dc.w  0,$2,2,1,14,0,1,30,30,1
 dc.w  0,$3,3,14,1,2,15,14,30,1,1,30
 dc.w  0,$2,3,15,2,3,16,15,1,1,30,30
 dc.w  0,$3,2,3,4,16,3,30,30,1

 dc.w  0,$2,3,17,21,22,18,17,30,30,1,30         ; Gondel
 dc.w  0,$3,3,18,22,23,19,18,30,30,1,30
 dc.w  0,$2,3,19,23,24,20,19,30,30,1,30
 dc.w  0,$3,3,20,24,21,17,20,30,30,1,30
 dc.w  0,$2,3,19,20,17,18,19,30,30,1,30
 dc.w  0,$3,3,21,24,23,22,21,30,30,1,30

* Urpunkte (x/y/z), Fixkomma: 
SC_ballon EQU 25  /* Skalierung. */
ballon_punkte:
 dc.w 0,0,0,0 * Cb 1
 dc.w 0,0,0,0 * Cb 2
 dc.w 0/SC_ballon,0/SC_ballon,3453/SC_ballon,0
 dc.w 1418/SC_ballon,0/SC_ballon,2980/SC_ballon,0
 dc.w 1892/SC_ballon,0/SC_ballon,1245/SC_ballon,0
 dc.w 1576/SC_ballon,0/SC_ballon,-330/SC_ballon,0
 dc.w 0/SC_ballon,0/SC_ballon,-1907/SC_ballon,0
 dc.w 437/SC_ballon,1349/SC_ballon,2980/SC_ballon,0
 dc.w 584/SC_ballon,1798/SC_ballon,1245/SC_ballon,0
 dc.w 486/SC_ballon,1498/SC_ballon,-330/SC_ballon,0
 dc.w -1147/SC_ballon,833/SC_ballon,2980/SC_ballon,0
 dc.w -1530/SC_ballon,1111/SC_ballon,1245/SC_ballon,0
 dc.w -1275/SC_ballon,925/SC_ballon,-330/SC_ballon,0
 dc.w -1147/SC_ballon,-833/SC_ballon,2980/SC_ballon,0
 dc.w -1530/SC_ballon,-1111/SC_ballon,1245/SC_ballon,0
 dc.w -1275/SC_ballon,-925/SC_ballon,-330/SC_ballon,0
 dc.w 437/SC_ballon,-1349/SC_ballon,2980/SC_ballon,0
 dc.w 584/SC_ballon,-1798/SC_ballon,1245/SC_ballon,0
 dc.w 486/SC_ballon,-1498/SC_ballon,-330/SC_ballon,0
 dc.w 369/SC_ballon,-369/SC_ballon,-2635/SC_ballon,0
 dc.w 369/SC_ballon,-369/SC_ballon,-4106/SC_ballon,0
 dc.w -369/SC_ballon,-369/SC_ballon,-4106/SC_ballon,0
 dc.w -369/SC_ballon,-369/SC_ballon,-2635/SC_ballon,0
 dc.w 369/SC_ballon,369/SC_ballon,-2635/SC_ballon,0
 dc.w 369/SC_ballon,369/SC_ballon,-4106/SC_ballon,0
 dc.w -369/SC_ballon,369/SC_ballon,-4106/SC_ballon,0
 dc.w -369/SC_ballon,369/SC_ballon,-2635/SC_ballon,0

; Cubepunkte fÅr die Mathematica-WÅrfel.
q             EQU       5
cube_punkte_a:
              DC.W      -200/q,-200/q,-200/q,0
              DC.W      200/q,200/q,200/q,0
              DC.W      -210/q,-210/q,-210/q,0
              DC.W      210/q,-210/q,-210/q,0
              DC.W      210/q,210/q,-210/q,0
              DC.W      -210/q,210/q,-210/q,0
              DC.W      -210/q,-210/q,210/q,0
              DC.W      210/q,-210/q,210/q,0
              DC.W      210/q,210/q,210/q,0
              DC.W      -210/q,210/q,210/q,0

; CUBE (16 Farben).
cube_a:       DC.W      6                 ; 6 FlÑche
              DC.W      8+2               ; 8 Punkte
              DC.L      cube_punkte_a     ; Urpunkte
              DS.L      6,0               ; FlÑchenadressen

              DC.W      0,$1,3,0,1,2,3,0,30,30,1,1
              DC.W      0,$2,3,0,4,5,1,0,30,30,1,1
              DC.W      0,$3,3,1,5,6,2,1,30,30,1,1
              DC.W      0,$4,3,2,6,7,3,2,30,30,1,1
              DC.W      0,$2,3,3,7,4,0,3,30,30,1,1
              DC.W      0,$1,3,7,6,5,4,7,30,30,1,1

cube_b:       DC.W      6                 ; 6 FlÑche
              DC.W      8+2               ; 8 Punkte
              DC.L      cube_punkte_a     ; Urpunkte
              DS.L      6,0               ; FlÑchenadressen

              DC.W      0,$7,3,0,1,2,3,0,30,30,1,1
              DC.W      0,$8,3,0,4,5,1,0,30,30,1,1
              DC.W      0,$9,3,1,5,6,2,1,30,30,1,1
              DC.W      0,$a,3,2,6,7,3,2,30,30,1,1
              DC.W      0,$b,3,3,7,4,0,3,30,30,1,1
              DC.W      0,$c,3,7,6,5,4,7,30,30,1,1

cube_c:       DC.W      6                 ; Ananlog "cube_a"
              DC.W      8+2
              DC.L      cube_punkte_a
              DS.L      6,0

              DC.W      0,$5,3,0,1,2,3,0,30,30,1,1
              DC.W      0,$6,3,0,4,5,1,0,30,30,1,1
              DC.W      0,$7,3,1,5,6,2,1,30,30,1,1
              DC.W      0,$8,3,2,6,7,3,2,30,30,1,1
              DC.W      0,$9,3,3,7,4,0,3,30,30,1,1
              DC.W      0,$a,3,7,6,5,4,7,30,30,1,1

cube_d:       DC.W      6                 ; Ananlog "cube_a"
              DC.W      8+2
              DC.L      cube_punkte_a
              DS.L      6,0

              DC.W      0,$e,3,0,1,2,3,0,30,30,1,1
              DC.W      0,$b,3,0,4,5,1,0,30,30,1,1
              DC.W      0,$c,3,1,5,6,2,1,30,30,1,1
              DC.W      0,$d,3,2,6,7,3,2,30,30,1,1
              DC.W      0,$e,3,3,7,4,0,3,30,30,1,1
              DC.W      0,$a,3,7,6,5,4,7,30,30,1,1

; Punkte fÅr die Cubes des "Cubetunnels".
mcs1          EQU       2
mc_cube_punkte_1:
              DC.W      0,0,0,0,0,0,0,0
              DC.W      -200/mcs1,-200/mcs1,-200/mcs1,0 ; 0
              DC.W      200/mcs1,-200/mcs1,-200/mcs1,0  ; 1
              DC.W      200/mcs1,200/mcs1,-200/mcs1,0   ; 2
              DC.W      -200/mcs1,200/mcs1,-200/mcs1,0  ; 3
              DC.W      -200/mcs1,-200/mcs1,200/mcs1,0  ; 4
              DC.W      200/mcs1,-200/mcs1,200/mcs1,0   ; 5
              DC.W      200/mcs1,200/mcs1,200/mcs1,0    ; 6
              DC.W      -200/mcs1,200/mcs1,200/mcs1,0   ; 7

; Cubes fÅr "Cubetunnel": Es fehlt die RÅckwand, da sie nie zu sehen ist...
d_mc_cube_1:  DC.W      3
              DC.W      8+2
              DC.L      mc_cube_punkte_1
              DS.L      3,0

              DC.W      0,1,3,0,1,2,3,0,30,30,1,1
              DC.W      0,2,3,2,6,7,3,2,30,30,1,1
              DC.W      0,3,3,3,7,4,0,3,1,1,30,30

d_mc_cube_2:  DC.W      3
              DC.W      8+2
              DC.L      mc_cube_punkte_1
              DS.L      3,0

              DC.W      0,4,3,0,1,2,3,0,30,30,1,1
              DC.W      0,5,3,0,4,5,1,0,30,1,30,30
              DC.W      0,6,3,3,7,4,0,3,1,1,1,30

d_mc_cube_3:  DC.W      3
              DC.W      8+2
              DC.L      mc_cube_punkte_1
              DS.L      3,0

              DC.W      0,7,3,0,1,2,3,0,30,30,1,1
              DC.W      0,8,3,0,4,5,1,0,30,30,1,1
              DC.W      0,9,3,1,5,6,2,1,30,30,1,1

d_mc_cube_4:  DC.W      3
              DC.W      8+2
              DC.L      mc_cube_punkte_1
              DS.L      3,0

              DC.W      0,10,3,0,1,2,3,0,30,30,1,1
              DC.W      0,11,3,1,5,6,2,1,30,30,1,1
              DC.W      0,12,3,2,6,7,3,2,30,30,1,1

; Kreuz:
kreuz_1_obj:  DC.W      2
              DC.W      8+2
              DC.L      kreuz_punkte_1
              DS.L      2,0

              DC.W      0,3,3,0,1,2,3,0,30,30,1,1
              DC.W      0,3,3,4,5,6,7,4,30,30,1,1

SC_KRZ_1      EQU       1
kreuz_punkte_1:
              DC.W      -200/mcs1,-200/mcs1,-200/mcs1,0
              DC.W      200/mcs1,200/mcs1,200/mcs1,0

              DC.W      10*SC_KRZ_1,30*SC_KRZ_1,0*SC_KRZ_1,0
              DC.W      -10*SC_KRZ_1,30*SC_KRZ_1,0*SC_KRZ_1,0
              DC.W      -10*SC_KRZ_1,-50*SC_KRZ_1,0*SC_KRZ_1,0
              DC.W      10*SC_KRZ_1,-50*SC_KRZ_1,0*SC_KRZ_1,0

              DC.W      -30*SC_KRZ_1,10*SC_KRZ_1,0*SC_KRZ_1,0
              DC.W      -30*SC_KRZ_1,-10*SC_KRZ_1,0*SC_KRZ_1,0
              DC.W      30*SC_KRZ_1,-10*SC_KRZ_1,0*SC_KRZ_1,0
              DC.W      30*SC_KRZ_1,10*SC_KRZ_1,0*SC_KRZ_1,0

; WÅrfelfÅnf:
wuerfel_5_obj:
              DC.W      5
              DC.W      16+2
              DC.L      wuerfel_5_punkte
              DS.L      5,0

              DC.W      0,0,3,0,1,2,3,0,30,30,1,1
              DC.W      0,0,3,4,5,6,7,4,30,30,1,1
              DC.W      0,0,3,8,9,10,11,8,30,30,1,1
              DC.W      0,0,3,12,13,14,15,12,30,30,1,1
              DC.W      0,0,3,10,15,4,2,10,30,30,1,1

SC_WU5_1      EQU       4
wuerfel_5_punkte:
              DC.W      -200/mcs1,-200/mcs1,-200/mcs1,0
              DC.W      200/mcs1,200/mcs1,200/mcs1,0

              DC.W      -30*SC_WU5_1,30*SC_WU5_1,0*SC_WU5_1,0
              DC.W      -30*SC_WU5_1,10*SC_WU5_1,0*SC_WU5_1,0
              DC.W      -10*SC_WU5_1,10*SC_WU5_1,0*SC_WU5_1,0
              DC.W      -10*SC_WU5_1,30*SC_WU5_1,0*SC_WU5_1,0
              DC.W      10*SC_WU5_1,10*SC_WU5_1,0*SC_WU5_1,0
              DC.W      30*SC_WU5_1,10*SC_WU5_1,0*SC_WU5_1,0
              DC.W      30*SC_WU5_1,30*SC_WU5_1,0*SC_WU5_1,0
              DC.W      10*SC_WU5_1,30*SC_WU5_1,0*SC_WU5_1,0
              DC.W      -30*SC_WU5_1,-30*SC_WU5_1,0*SC_WU5_1,0
              DC.W      -10*SC_WU5_1,-30*SC_WU5_1,0*SC_WU5_1,0
              DC.W      -10*SC_WU5_1,-10*SC_WU5_1,0*SC_WU5_1,0
              DC.W      -30*SC_WU5_1,-10*SC_WU5_1,0*SC_WU5_1,0
              DC.W      10*SC_WU5_1,-30*SC_WU5_1,0*SC_WU5_1,0
              DC.W      30*SC_WU5_1,-30*SC_WU5_1,0*SC_WU5_1,0
              DC.W      30*SC_WU5_1,-10*SC_WU5_1,0*SC_WU5_1,0
              DC.W      10*SC_WU5_1,-10*SC_WU5_1,0,0

; ButterblumenblÅte:
blume_obj:
              DC.W      2
              DC.W      16+2
              DC.L      blumen_punkte
              DS.L      2,0

              DC.W      0,1,7,7,6,5,4,3,2,1,0,7
              DC.W      30,30,30,30,30,1,1,1
              DC.W      0,2,7,15,14,13,12,11,10,9,8,15
              DC.W      30,30,30,30,30,1,1,1

SC_BL1        EQU       6                 ; Aussen
SC_BL2        EQU       3                 ; Innen
blumen_punkte:
              DC.W      -200/mcs1,-200/mcs1,-200/mcs1,0
              DC.W      200/mcs1,200/mcs1,200/mcs1,0

              dc.w 50*SC_BL1,0*SC_BL1,1,0       ; Grosse Bluete.
              dc.w 35*SC_BL1,35*SC_BL1,1,0
              dc.w 0*SC_BL1,50*SC_BL1,1,0
              dc.w -35*SC_BL1,35*SC_BL1,1,0
              dc.w -50*SC_BL1,0*SC_BL1,1,0
              dc.w -35*SC_BL1,-35*SC_BL1,1,0
              dc.w 0*SC_BL1,-50*SC_BL1,1,0
              dc.w 35*SC_BL1,-35*SC_BL1,1,0

              dc.w 50*SC_BL2,0*SC_BL2,0,0       ; Innere Bluete.
              dc.w 35*SC_BL2,35*SC_BL2,0,0
              dc.w 0*SC_BL2,50*SC_BL2,0,0
              dc.w -35*SC_BL2,35*SC_BL2,0,0
              dc.w -50*SC_BL2,0*SC_BL2,0,0
              dc.w -35*SC_BL2,-35*SC_BL2,0,0
              dc.w 0*SC_BL2,-50*SC_BL2,0,0
              dc.w 35*SC_BL2,-35*SC_BL2,0,0

; Butterblumenstamm (Rechteck, universell einsetzbar.)
blumenstamm_obj1:
              DC.W      1
              DC.W      4+2
              DC.L      bstamm_punkte1
              DS.L      1,0

              DC.W      0,1,3,3,2,1,0,3
              DC.W      30,30,30,30

SC_BS1        EQU       8
bstamm_punkte1:
              DC.W      -200/mcs1,-200/mcs1,-200/mcs1,0
              DC.W      200/mcs1,200/mcs1,200/mcs1,0

              dc.w 6*SC_BS1,-49*SC_BS1,-1,0
              dc.w -6*SC_BS1,-49*SC_BS1,-1,0
              dc.w -6*SC_BS1,45*SC_BS1,-1,0
              dc.w 6*SC_BS1,45*SC_BS1,-1,0

; Butterblumenstamm (Rechteck, universell einsetzbar.)
blumenstamm_obj2:
              DC.W      1
              DC.W      4+2
              DC.L      bstamm_punkte2
              DS.L      1,0

              DC.W      0,1,3,3,2,1,0,3
              DC.W      30,30,30,30

bstamm_punkte2:
              DC.W      -200/mcs1,-200/mcs1,-200/mcs1,0
              DC.W      200/mcs1,200/mcs1,200/mcs1,0

              dc.w 6*SC_BS1,-47*SC_BS1,-1,0
              dc.w -6*SC_BS1,-45*SC_BS1,-1,0
              dc.w -6*SC_BS1,47*SC_BS1,-1,0
              dc.w 6*SC_BS1,45*SC_BS1,-1,0

blumenstamm_obj3:
              DC.W      1
              DC.W      4+2
              DC.L      bstamm_punkte3
              DS.L      1,0

              DC.W      0,2,3,3,2,1,0,3
              DC.W      30,30,30,30

bstamm_punkte3:
              DC.W      -200/mcs1,-200/mcs1,-200/mcs1,0
              DC.W      200/mcs1,200/mcs1,200/mcs1,0

              dc.w 6*SC_BS1,-47*SC_BS1,-1,0
              dc.w -6*SC_BS1,-45*SC_BS1,-1,0
              dc.w -6*SC_BS1,47*SC_BS1,-1,0
              dc.w 6*SC_BS1,45*SC_BS1,-1,0

; Offenes Quadrat...
obj_open_quad:
              DC.W      4
              DC.W      12+2
              DC.L      obj_open_quad_pun
              DS.L      4,0

              DC.W      0,0,3,0,1,4,5,0,30,30,30,30
              DC.W      0,0,3,6,7,9,10,6,30,30,30,30
              DC.W      0,0,3,1,6,8,2,1,30,30,30,30
              DC.W      0,0,3,3,11,10,4,3,30,30,30,30

OQ_SC         EQU       3
obj_open_quad_pun:
              DC.W      0,0,0,0,0,0,0,0

              DC.W      -100*OQ_SC,-100*OQ_SC,0*OQ_SC,0 
              DC.W      -50*OQ_SC,-100*OQ_SC,0*OQ_SC,0
               DC.W     -60*OQ_SC,-50*OQ_SC,0*OQ_SC,0
               DC.W     -60*OQ_SC,50*OQ_SC,0*OQ_SC,0
              DC.W      -50*OQ_SC,100*OQ_SC,0*OQ_SC,0
              DC.W      -100*OQ_SC,100*OQ_SC,0*OQ_SC,0
              DC.W      50*OQ_SC,-100*OQ_SC,0*OQ_SC,0
              DC.W      100*OQ_SC,-100*OQ_SC,0*OQ_SC,0
               DC.W     60*OQ_SC,-50*OQ_SC,0*OQ_SC,0
              DC.W      100*OQ_SC,100*OQ_SC,0*OQ_SC,0
              DC.W      50*OQ_SC,100*OQ_SC,0*OQ_SC,0
               DC.W     60*OQ_SC,50*OQ_SC,0*OQ_SC,0

; Tannenbaum, AusfÅhrung 1 (ohne Boden und ohne Stumpf).
o_tannenbaum_1:
 dc.w 4                                   * Anz. Polygone
 dc.w 5+2                                 * Anz. Punkte
 dc.l Tannen_punkte
 ds.l 4,0

 dc.w         0,$1,2,4,2,3,4,30,2,2
 dc.w         0,$2,2,4,3,0,4,30,2,2
 dc.w         0,$1,2,4,0,1,4,30,2,2
 dc.w         0,$2,2,4,1,2,4,30,2,2

SCT           EQU       15
Tannen_punkte:
 DS.W         8,0
 DC.W         -750/SCT,0,750/SCT,0        ; 0
 DC.W         750/SCT,0,750/SCT,0         ; 1
 DC.W         750/SCT,0,-750/SCT,0        ; 2
 DC.W         -750/SCT,0,-750/SCT,0       ; 3
 DC.W         0,-1300/SCT,0,0             ; 4 Tannenspitze (Lichtlein blitzen...)

* 'VENTILATOR' (C) 1994 Jochen Knaus. [///SYS-3/// FILE].
PYRAMID:
 dc.w 20   * Anz. Polygone
 dc.w 26   * Anz. Punkte
 dc.l PYRAMID_punkte
 ds.l 20,0

* Polygondaten: Farbe (.l), Anz. Ecken - 1, A[0],A[1]..A[n],A[0]:

 dc.w  0,$3,3,6,5,14,13,6,30,30,30,30
 dc.w  0,$3,3,5,4,16,15,5,30,30,30,30
 dc.w  0,$3,3,4,3,21,17,4,30,30,30,30
 dc.w  0,$3,3,3,6,19,18,3,30,30,30,30
 dc.w  0,$4,2,1,8,5,1,30,30,30
 dc.w  0,$4,2,7,2,6,7,30,30,30
 dc.w  0,$5,2,9,1,5,9,30,30,30
 dc.w  0,$5,2,0,10,4,0,30,30,30
 dc.w  0,$6,2,22,0,4,22,30,30,30
 dc.w  0,$7,2,20,23,3,20,30,30,30
 dc.w  0,$6,2,11,20,3,11,30,30,30
 dc.w  0,$7,2,2,12,6,2,30,30,30

 dc.w  0,$2,2,17,22,4,17,30,30,30
 dc.w  0,$2,2,21,3,23,21,30,30,30
 dc.w  0,$2,2,18,11,3,18,30,30,30
 dc.w  0,$2,2,19,6,12,19,30,30,30
 dc.w  0,$2,2,13,7,6,13,30,30,30
 dc.w  0,$2,2,14,5,8,14,30,30,30
 dc.w  0,$2,2,15,9,5,15,30,30,30
 dc.w  0,$2,2,16,4,10,16,30,30,30

* Urpunkte (x/y/z), Fixkomma: 
SC_PYRAMID EQU 22  /* Skalierung. */
PYRAMID_punkte:
 dc.w 0,0,0,0 * Cb 1
 dc.w 0,0,0,0 * Cb 2
 dc.w -2080/SC_PYRAMID,-2080/SC_PYRAMID,0/SC_PYRAMID,0
 dc.w -2080/SC_PYRAMID,2048/SC_PYRAMID,0/SC_PYRAMID,0
 dc.w 2048/SC_PYRAMID,2048/SC_PYRAMID,0/SC_PYRAMID,0
 dc.w 1280/SC_PYRAMID,-1280/SC_PYRAMID,3424/SC_PYRAMID,0
 dc.w -1280/SC_PYRAMID,-1280/SC_PYRAMID,3424/SC_PYRAMID,0
 dc.w -1280/SC_PYRAMID,1280/SC_PYRAMID,3424/SC_PYRAMID,0
 dc.w 1280/SC_PYRAMID,1280/SC_PYRAMID,3424/SC_PYRAMID,0
 dc.w 1024/SC_PYRAMID,2048/SC_PYRAMID,0/SC_PYRAMID,0
 dc.w -1024/SC_PYRAMID,2048/SC_PYRAMID,0/SC_PYRAMID,0
 dc.w -2048/SC_PYRAMID,1024/SC_PYRAMID,0/SC_PYRAMID,0
 dc.w -2048/SC_PYRAMID,-1024/SC_PYRAMID,0/SC_PYRAMID,0
 dc.w 2048/SC_PYRAMID,-1024/SC_PYRAMID,0/SC_PYRAMID,0
 dc.w 2048/SC_PYRAMID,1024/SC_PYRAMID,0/SC_PYRAMID,0
 dc.w 1024/SC_PYRAMID,3328/SC_PYRAMID,0/SC_PYRAMID,0
 dc.w -1024/SC_PYRAMID,3328/SC_PYRAMID,0/SC_PYRAMID,0
 dc.w -3328/SC_PYRAMID,1105/SC_PYRAMID,0/SC_PYRAMID,0
 dc.w -3328/SC_PYRAMID,-1041/SC_PYRAMID,0/SC_PYRAMID,0
 dc.w -1024/SC_PYRAMID,-3360/SC_PYRAMID,0/SC_PYRAMID,0
 dc.w 3328/SC_PYRAMID,-1056/SC_PYRAMID,0/SC_PYRAMID,0
 dc.w 3328/SC_PYRAMID,1152/SC_PYRAMID,0/SC_PYRAMID,0
 dc.w 2080/SC_PYRAMID,-2048/SC_PYRAMID,0/SC_PYRAMID,0
 dc.w 992/SC_PYRAMID,-3360/SC_PYRAMID,0/SC_PYRAMID,0
 dc.w -1024/SC_PYRAMID,-2048/SC_PYRAMID,-32/SC_PYRAMID,0
 dc.w 1024/SC_PYRAMID,-2048/SC_PYRAMID,-32/SC_PYRAMID,0

ob_h_zeiger:  DC.W      1,3+2
              DC.L      h_zeiger_pnts,0

              DC.W      0,1,2,0,1,2,0,28,8,8
;             DC.W      0,6,2,3,4,5,3,28,8,8

SC_H_ZEIGER   EQU       1
h_zeiger_pnts:
              DS.W      8
              DC.W      0,-60/SC_H_ZEIGER,0,0
              DC.W      10/SC_H_ZEIGER,10/SC_H_ZEIGER,0,0
              DC.W      -10/SC_H_ZEIGER,10/SC_H_ZEIGER,0,0
;             DC.W      0,-65/SC_H_ZEIGER,0,0
;             DC.W      13/SC_H_ZEIGER,13/SC_H_ZEIGER,0,0
;             DC.W      -13/SC_H_ZEIGER,13/SC_H_ZEIGER,0,0

ob_m_zeiger:  DC.W      1,5
              DC.L      m_zeiger_pnts,0

              DC.W      0,2,2,0,1,2,0,30,30,30
;             DC.W      0,4,2,3,4,5,3,28,8,8

m_zeiger_pnts:
              DS.W      8
              DC.W      0,-100/SC_H_ZEIGER,0,0
              DC.W      7/SC_H_ZEIGER,8/SC_H_ZEIGER,0,0
              DC.W      -7/SC_H_ZEIGER,8/SC_H_ZEIGER,0,0
;             DC.W      0,-105/SC_H_ZEIGER,0,0
;             DC.W      12/SC_H_ZEIGER,12/SC_H_ZEIGER,0,0
;             DC.W      -12/SC_H_ZEIGER,12/SC_H_ZEIGER,0,0

ob_s_zeiger:  DC.W      1,5
              DC.L      s_zeiger_pnts,0

              DC.W      0,3,2,0,1,2,0,30,30,30
;             DC.W      0,2,2,3,4,5,3,28,8,8

s_zeiger_pnts:
              DS.W      8
              DC.W      0,-90/SC_H_ZEIGER,0,0
              DC.W      3/SC_H_ZEIGER,9/SC_H_ZEIGER,0,0
              DC.W      -3/SC_H_ZEIGER,9/SC_H_ZEIGER,0,0
;             DC.W      0,-95/SC_H_ZEIGER,0,0
;             DC.W      8/SC_H_ZEIGER,12/SC_H_ZEIGER,0,0
;             DC.W      -8/SC_H_ZEIGER,12/SC_H_ZEIGER,0,0

SC_STRECKE    EQU       17
ob_strecke_a: DC.W      1,6
              DC.L      sa_pnts,0
              DC.W      0,3,3,0,3,2,1,0,30,30,20,20
sa_pnts:      DS.W      8
              DC.W      -1000/SC_STRECKE,7,-1000/SC_STRECKE,0
              DC.W      1000/SC_STRECKE,7,-1000/SC_STRECKE,0
              DC.W      1000/SC_STRECKE,-7,1000/SC_STRECKE,0
              DC.W      -1000/SC_STRECKE,-7,1000/SC_STRECKE,0

; "EX."-Logo: E
SC_OB_L_E     EQU       1
ob_logo_e:    DC.W      4,14+2
              DC.L      ob_e_pnts,0,0,0,0

              DC.W      0,0,3,0,1,2,4,0,30,30,30,30
              DC.W      0,0,3,4,3,10,9,4,30,30,30,30
              DC.W      0,0,3,5,6,7,8,5,30,30,30,30
              DC.W      0,0,3,9,11,12,13,9,30,30,30,30

ob_e_pnts:    DS.W      8
              DC.W      -60/SC_OB_L_E,-105/SC_OB_L_E,0,0
              DC.W      60/SC_OB_L_E,-105/SC_OB_L_E,0,0
              DC.W      60/SC_OB_L_E,-65/SC_OB_L_E,0,0
              DC.W      -30/SC_OB_L_E,-65/SC_OB_L_E,0,0
              DC.W      -60/SC_OB_L_E,-65/SC_OB_L_E,0,0
              DC.W      -32/SC_OB_L_E,-10/SC_OB_L_E,0,0
              DC.W      40/SC_OB_L_E,-10/SC_OB_L_E,0,0
              DC.W      40/SC_OB_L_E,20/SC_OB_L_E,0,0
              DC.W      -32/SC_OB_L_E,20/SC_OB_L_E,0,0
              DC.W      -60/SC_OB_L_E,65/SC_OB_L_E,0,0
              DC.W      -30/SC_OB_L_E,65/SC_OB_L_E,0,0
              DC.W      70/SC_OB_L_E,65/SC_OB_L_E,0,0
              DC.W      70/SC_OB_L_E,105/SC_OB_L_E,0,0
              DC.W      -60/SC_OB_L_E,105/SC_OB_L_E,0,0
              DS.W      14*4              ; FÅr Extrudeobjekt.

; "EX"-Logo: X
ob_logo_x:    DC.W      2,8+2
              DC.L      ob_x_pnts,0,0

              DC.W      0,2,3,0,1,2,3,0,30,30,30,30
              DC.W      0,2,3,4,5,6,7,4,30,30,30,30

ob_x_pnts:    DS.W      8
              DC.W      -90/SC_OB_L_E,-105/SC_OB_L_E,0,0
              DC.W      -50/SC_OB_L_E,-105/SC_OB_L_E,0,0
              DC.W      90/SC_OB_L_E,105/SC_OB_L_E,0,0
              DC.W      50/SC_OB_L_E,105/SC_OB_L_E,0,0
              DC.W      -50/SC_OB_L_E,105/SC_OB_L_E,0,0
              DC.W      -90/SC_OB_L_E,105/SC_OB_L_E,0,0
              DC.W      50/SC_OB_L_E,-105/SC_OB_L_E,0,0
              DC.W      90/SC_OB_L_E,-105/SC_OB_L_E,0,0
              DS.W      8*4               ; FÅr Extrudeobjekt.

; "EX"-Logo: . (Plane 1)
ob_logo_p1:   DC.W      2,12+2
              DC.L      ob_l_p_pnts,0,0

              DC.W      0,1,5,0,1,2,3,4,5,0,30,30,30,30,30,30
              DC.W      0,1,5,6,7,8,9,10,11,6,30,30,30,30,30,30

; "EX"-Logo: . (Plane 0)
ob_logo_p0:   DC.W      2,12+2
              DC.L      ob_l_p_pnts,0,0

              DC.W      0,0,5,0,1,2,3,4,5,0,30,30,30,30,30,30
              DC.W      0,0,5,6,7,8,9,10,11,6,30,30,30,30,30,30

SC_L_P_P      EQU       6
ob_l_p_pnts:  DS.W      8
              DC.W      50*6/SC_L_P_P,0*6/SC_L_P_P,0,0
              DC.W      43*6/SC_L_P_P,25*6/SC_L_P_P,0,0
              DC.W      25*6/SC_L_P_P,43*6/SC_L_P_P,0,0
              DC.W      0*6/SC_L_P_P,50*6/SC_L_P_P,0,0
              DC.W      -25*6/SC_L_P_P,43*6/SC_L_P_P,0,0
              DC.W      -43*6/SC_L_P_P,25*6/SC_L_P_P,0,0
              DC.W      -50*6/SC_L_P_P,0*6/SC_L_P_P,0,0
              DC.W      -43*6/SC_L_P_P,-25*6/SC_L_P_P,0,0
              DC.W      -25*6/SC_L_P_P,-43*6/SC_L_P_P,0,0
              DC.W      0*6/SC_L_P_P,-50*6/SC_L_P_P,0,0
              DC.W      25*6/SC_L_P_P,-43*6/SC_L_P_P,0,0
              DC.W      43*6/SC_L_P_P,-25*6/SC_L_P_P,0,0

ob_ballon_2:            ; Gouraudballon
 dc.w 80,69             ; 80 FlÑchen, 69 Punkte.
 dc.l ob_ballon_2_punkte
 ds.l 80,0

 dc.w  0,YELLOW/4,2,7,1,0,7,1,30,1
 dc.w  0,MAGENTA/4,3,1,7,8,2,1,1,1,30,30
 dc.w  0,YELLOW/4,3,2,8,9,3,2,1,1,30,30
 dc.w  0,MAGENTA/4,3,3,9,10,4,3,1,1,30,30
 dc.w  0,YELLOW/4,3,4,10,11,5,4,1,1,30,30
 dc.w  0,MAGENTA/4,2,11,6,5,11,1,30,1

 dc.w  0,YELLOW/4,2,12,7,0,12,1,30,1
 dc.w  0,RED/4,3,7,12,13,8,7,1,1,30,30
 dc.w  0,YELLOW/4,3,8,13,14,9,8,1,1,30,30
 dc.w  0,RED/4,3,9,14,15,10,9,1,1,30,30
 dc.w  0,YELLOW/4,3,10,15,16,11,10,1,1,30,30
 dc.w  0,RED/4,2,16,6,11,16,1,30,1

 dc.w  0,YELLOW/4,2,17,12,0,17,1,30,1
 dc.w  0,MAGENTA/4,3,12,17,18,13,12,1,1,30,30
 dc.w  0,YELLOW/4,3,13,18,19,14,13,1,1,30,30
 dc.w  0,MAGENTA/4,3,14,19,20,15,14,1,1,30,30
 dc.w  0,YELLOW/4,3,15,20,21,16,15,1,1,30,30
 dc.w  0,MAGENTA/4,2,21,6,16,21,1,30,1

 dc.w  0,RED/4,2,22,17,0,22,1,30,1
 dc.w  0,YELLOW/4,3,17,22,23,18,17,1,1,30,30
 dc.w  0,RED/4,3,18,23,24,19,18,1,1,30,30
 dc.w  0,YELLOW/4,3,19,24,25,20,19,1,1,30,30
 dc.w  0,RED/4,3,20,25,26,21,20,1,1,30,30
 dc.w  0,YELLOW/4,2,26,6,21,26,1,30,1

 dc.w  0,YELLOW/4,2,27,22,0,27,1,30,1
 dc.w  0,MAGENTA/4,3,22,27,28,23,22,1,1,30,30
 dc.w  0,YELLOW/4,3,23,28,29,24,23,1,1,30,30
 dc.w  0,MAGENTA/4,3,24,29,30,25,24,1,1,30,30
 dc.w  0,YELLOW/4,3,25,30,31,26,25,1,1,30,30
 dc.w  0,MAGENTA/4,2,31,6,26,31,1,30,1

 dc.w  0,RED/4,2,32,27,0,32,1,30,1
 dc.w  0,YELLOW/4,3,27,32,33,28,27,1,1,30,30
 dc.w  0,RED/4,3,28,33,34,29,28,1,1,30,30
 dc.w  0,YELLOW/4,3,29,34,35,30,29,1,1,30,30
 dc.w  0,RED/4,3,30,35,36,31,30,1,1,30,30
 dc.w  0,YELLOW/4,2,36,6,31,36,1,30,1

 dc.w  0,YELLOW/4,2,37,32,0,37,1,30,1
 dc.w  0,MAGENTA/4,3,32,37,38,33,32,1,1,30,30
 dc.w  0,YELLOW/4,3,33,38,39,34,33,1,1,30,30
 dc.w  0,MAGENTA/4,3,34,39,40,35,34,1,1,30,30
 dc.w  0,YELLOW/4,3,35,40,41,36,35,1,1,30,30
 dc.w  0,MAGENTA/4,2,41,6,36,41,1,30,1

 dc.w  0,RED/4,2,1,37,0,1,1,30,1
 dc.w  0,YELLOW/4,3,37,1,2,38,37,1,1,30,30
 dc.w  0,RED/4,3,38,2,3,39,38,1,1,30,30
 dc.w  0,YELLOW/4,3,39,3,4,40,39,1,1,30,30
 dc.w  0,RED/4,3,40,4,5,41,40,1,1,30,30
 dc.w  0,YELLOW/4,2,5,6,41,5,1,30,1

 dc.w  0,BROWN/4,3,42,44,45,43,42,1,1,30,30
 dc.w  0,BLUE/4,3,43,45,44,42,43,1,1,30,30
 dc.w  0,BROWN/4,3,44,46,47,45,44,1,1,30,30
 dc.w  0,BLUE/4,3,45,47,46,44,45,1,1,30,30
 dc.w  0,BROWN/4,3,46,48,49,47,46,1,1,30,30
 dc.w  0,BLUE/4,3,47,49,48,46,47,1,1,30,30
 dc.w  0,BROWN/4,3,48,50,51,49,48,1,1,30,30
 dc.w  0,BLUE/4,3,49,51,50,48,49,1,1,30,30
 dc.w  0,BROWN/4,3,50,52,53,51,50,1,1,30,30
 dc.w  0,BLUE/4,3,51,53,52,50,51,1,1,30,30
 dc.w  0,BROWN/4,3,52,54,55,53,52,1,1,30,30
 dc.w  0,BLUE/4,3,53,55,54,52,53,1,1,30,30
 dc.w  0,BROWN/4,3,54,56,57,55,54,1,1,30,30
 dc.w  0,BLUE/4,3,55,57,56,54,55,1,1,30,30
 dc.w  0,BROWN/4,3,56,42,43,57,56,1,1,30,30
 dc.w  0,BLUE/4,3,57,43,42,56,57,1,1,30,30
 dc.w  0,BLUEVIOLET/4,2,60,59,58,60,1,30,1
 dc.w  0,BLUEVIOLET/4,2,60,58,59,60,1,30,1
 dc.w  0,BLUEVIOLET/4,2,61,60,58,61,1,30,1
 dc.w  0,BLUEVIOLET/4,2,61,58,60,61,1,30,1
 dc.w  0,BLUEVIOLET/4,2,62,61,58,62,1,30,1
 dc.w  0,BLUEVIOLET/4,2,62,58,61,62,1,30,1
 dc.w  0,BLUEVIOLET/4,2,63,62,58,63,1,30,1
 dc.w  0,BLUEVIOLET/4,2,63,58,62,63,1,30,1
 dc.w  0,BLUEVIOLET/4,2,64,63,58,64,1,30,1
 dc.w  0,BLUEVIOLET/4,2,64,58,63,64,1,30,1
 dc.w  0,BLUEVIOLET/4,2,65,64,58,65,1,30,1
 dc.w  0,BLUEVIOLET/4,2,65,58,64,65,1,30,1
 dc.w  0,BLUEVIOLET/4,2,66,65,58,66,1,30,1
 dc.w  0,BLUEVIOLET/4,2,66,58,65,66,1,30,1
 dc.w  0,BLUEVIOLET/4,2,59,66,58,59,1,30,1
 dc.w  0,BLUEVIOLET/4,2,59,58,66,59,1,30,1

SC_ob_ballon_2 EQU 35
ob_ballon_2_punkte:
 ds.w 8,0
 dc.w 0/SC_ob_ballon_2,0/SC_ob_ballon_2,4800/SC_ob_ballon_2,0
 dc.w 768/SC_ob_ballon_2,0/SC_ob_ballon_2,4800/SC_ob_ballon_2,0
 dc.w 1792/SC_ob_ballon_2,0/SC_ob_ballon_2,4544/SC_ob_ballon_2,0
 dc.w 2304/SC_ob_ballon_2,0/SC_ob_ballon_2,3520/SC_ob_ballon_2,0
 dc.w 2560/SC_ob_ballon_2,0/SC_ob_ballon_2,2240/SC_ob_ballon_2,0
 dc.w 2048/SC_ob_ballon_2,0/SC_ob_ballon_2,704/SC_ob_ballon_2,0
 dc.w 0/SC_ob_ballon_2,0/SC_ob_ballon_2,-1856/SC_ob_ballon_2,0
 dc.w 543/SC_ob_ballon_2,543/SC_ob_ballon_2,4800/SC_ob_ballon_2,0
 dc.w 1267/SC_ob_ballon_2,1267/SC_ob_ballon_2,4544/SC_ob_ballon_2,0
 dc.w 1629/SC_ob_ballon_2,1629/SC_ob_ballon_2,3520/SC_ob_ballon_2,0
 dc.w 1810/SC_ob_ballon_2,1810/SC_ob_ballon_2,2240/SC_ob_ballon_2,0
 dc.w 1448/SC_ob_ballon_2,1448/SC_ob_ballon_2,704/SC_ob_ballon_2,0
 dc.w 0/SC_ob_ballon_2,768/SC_ob_ballon_2,4800/SC_ob_ballon_2,0
 dc.w 0/SC_ob_ballon_2,1792/SC_ob_ballon_2,4544/SC_ob_ballon_2,0
 dc.w 0/SC_ob_ballon_2,2304/SC_ob_ballon_2,3520/SC_ob_ballon_2,0
 dc.w 0/SC_ob_ballon_2,2560/SC_ob_ballon_2,2240/SC_ob_ballon_2,0
 dc.w 0/SC_ob_ballon_2,2048/SC_ob_ballon_2,704/SC_ob_ballon_2,0
 dc.w -543/SC_ob_ballon_2,543/SC_ob_ballon_2,4800/SC_ob_ballon_2,0
 dc.w -1267/SC_ob_ballon_2,1267/SC_ob_ballon_2,4544/SC_ob_ballon_2,0
 dc.w -1629/SC_ob_ballon_2,1629/SC_ob_ballon_2,3520/SC_ob_ballon_2,0
 dc.w -1810/SC_ob_ballon_2,1810/SC_ob_ballon_2,2240/SC_ob_ballon_2,0
 dc.w -1448/SC_ob_ballon_2,1448/SC_ob_ballon_2,704/SC_ob_ballon_2,0
 dc.w -768/SC_ob_ballon_2,0/SC_ob_ballon_2,4800/SC_ob_ballon_2,0
 dc.w -1792/SC_ob_ballon_2,0/SC_ob_ballon_2,4544/SC_ob_ballon_2,0
 dc.w -2304/SC_ob_ballon_2,0/SC_ob_ballon_2,3520/SC_ob_ballon_2,0
 dc.w -2560/SC_ob_ballon_2,0/SC_ob_ballon_2,2240/SC_ob_ballon_2,0
 dc.w -2048/SC_ob_ballon_2,0/SC_ob_ballon_2,704/SC_ob_ballon_2,0
 dc.w -543/SC_ob_ballon_2,-543/SC_ob_ballon_2,4800/SC_ob_ballon_2,0
 dc.w -1267/SC_ob_ballon_2,-1267/SC_ob_ballon_2,4544/SC_ob_ballon_2,0
 dc.w -1629/SC_ob_ballon_2,-1629/SC_ob_ballon_2,3520/SC_ob_ballon_2,0
 dc.w -1810/SC_ob_ballon_2,-1810/SC_ob_ballon_2,2240/SC_ob_ballon_2,0
 dc.w -1448/SC_ob_ballon_2,-1448/SC_ob_ballon_2,704/SC_ob_ballon_2,0
 dc.w 0/SC_ob_ballon_2,-768/SC_ob_ballon_2,4800/SC_ob_ballon_2,0
 dc.w 0/SC_ob_ballon_2,-1792/SC_ob_ballon_2,4544/SC_ob_ballon_2,0
 dc.w 0/SC_ob_ballon_2,-2304/SC_ob_ballon_2,3520/SC_ob_ballon_2,0
 dc.w 0/SC_ob_ballon_2,-2560/SC_ob_ballon_2,2240/SC_ob_ballon_2,0
 dc.w 0/SC_ob_ballon_2,-2048/SC_ob_ballon_2,704/SC_ob_ballon_2,0
 dc.w 543/SC_ob_ballon_2,-543/SC_ob_ballon_2,4800/SC_ob_ballon_2,0
 dc.w 1267/SC_ob_ballon_2,-1267/SC_ob_ballon_2,4544/SC_ob_ballon_2,0
 dc.w 1629/SC_ob_ballon_2,-1629/SC_ob_ballon_2,3520/SC_ob_ballon_2,0
 dc.w 1810/SC_ob_ballon_2,-1810/SC_ob_ballon_2,2240/SC_ob_ballon_2,0
 dc.w 1448/SC_ob_ballon_2,-1448/SC_ob_ballon_2,704/SC_ob_ballon_2,0
 dc.w 622/SC_ob_ballon_2,0/SC_ob_ballon_2,-2695/SC_ob_ballon_2,0
 dc.w 622/SC_ob_ballon_2,0/SC_ob_ballon_2,-4147/SC_ob_ballon_2,0
 dc.w 439/SC_ob_ballon_2,439/SC_ob_ballon_2,-2695/SC_ob_ballon_2,0
 dc.w 439/SC_ob_ballon_2,439/SC_ob_ballon_2,-4147/SC_ob_ballon_2,0
 dc.w 0/SC_ob_ballon_2,622/SC_ob_ballon_2,-2695/SC_ob_ballon_2,0
 dc.w 0/SC_ob_ballon_2,622/SC_ob_ballon_2,-4147/SC_ob_ballon_2,0
 dc.w -439/SC_ob_ballon_2,439/SC_ob_ballon_2,-2695/SC_ob_ballon_2,0
 dc.w -439/SC_ob_ballon_2,439/SC_ob_ballon_2,-4147/SC_ob_ballon_2,0
 dc.w -622/SC_ob_ballon_2,0/SC_ob_ballon_2,-2695/SC_ob_ballon_2,0
 dc.w -622/SC_ob_ballon_2,0/SC_ob_ballon_2,-4147/SC_ob_ballon_2,0
 dc.w -439/SC_ob_ballon_2,-439/SC_ob_ballon_2,-2695/SC_ob_ballon_2,0
 dc.w -439/SC_ob_ballon_2,-439/SC_ob_ballon_2,-4147/SC_ob_ballon_2,0
 dc.w 0/SC_ob_ballon_2,-622/SC_ob_ballon_2,-2695/SC_ob_ballon_2,0
 dc.w 0/SC_ob_ballon_2,-622/SC_ob_ballon_2,-4147/SC_ob_ballon_2,0
 dc.w 439/SC_ob_ballon_2,-439/SC_ob_ballon_2,-2695/SC_ob_ballon_2,0
 dc.w 439/SC_ob_ballon_2,-439/SC_ob_ballon_2,-4147/SC_ob_ballon_2,0
 dc.w 0/SC_ob_ballon_2,0/SC_ob_ballon_2,-4121/SC_ob_ballon_2,0
 dc.w 635/SC_ob_ballon_2,0/SC_ob_ballon_2,-4121/SC_ob_ballon_2,0
 dc.w 447/SC_ob_ballon_2,447/SC_ob_ballon_2,-4121/SC_ob_ballon_2,0
 dc.w 0/SC_ob_ballon_2,635/SC_ob_ballon_2,-4121/SC_ob_ballon_2,0
 dc.w -447/SC_ob_ballon_2,447/SC_ob_ballon_2,-4121/SC_ob_ballon_2,0
 dc.w -635/SC_ob_ballon_2,0/SC_ob_ballon_2,-4121/SC_ob_ballon_2,0
 dc.w -447/SC_ob_ballon_2,-447/SC_ob_ballon_2,-4121/SC_ob_ballon_2,0
 dc.w 0/SC_ob_ballon_2,-635/SC_ob_ballon_2,-4121/SC_ob_ballon_2,0
 dc.w 447/SC_ob_ballon_2,-447/SC_ob_ballon_2,-4121/SC_ob_ballon_2,0

ob_ex_logo1:
 dc.w 70,64
 dc.l ob_ex_logo1_punkte
 ds.l 70,0

 dc.w  0,$1*4,3,0,24,25,1,0,30,30,30,30
 dc.w  0,$1*4,3,1,25,26,2,1,30,30,30,30
 dc.w  0,$1*4,3,2,26,27,3,2,30,30,30,30
 dc.w  0,$1*4,3,3,27,28,4,3,30,30,30,30
 dc.w  0,$1*4,3,4,28,29,5,4,30,30,30,30
 dc.w  0,$1*4,3,5,29,30,6,5,30,30,30,30
 dc.w  0,$1*4,3,6,30,31,7,6,30,30,30,30
 dc.w  0,$1*4,3,7,31,32,8,7,30,30,30,30
 dc.w  0,$1*4,3,8,32,33,9,8,30,30,30,30
 dc.w  0,$1*4,3,9,33,34,10,9,30,30,30,30
 dc.w  0,$1*4,3,10,34,35,11,10,30,30,30,30
 dc.w  0,$1*4,3,11,35,24,0,11,30,30,30,30
 dc.w  0,$1*4,3,12,36,37,13,12,30,30,30,30
 dc.w  0,$1*4,3,13,37,38,14,13,30,30,30,30
 dc.w  0,$1*4,3,14,38,39,15,14,30,30,30,30
 dc.w  0,$1*4,3,15,39,40,16,15,30,30,30,30
 dc.w  0,$1*4,3,16,40,41,17,16,30,30,30,30
 dc.w  0,$1*4,3,17,41,42,18,17,30,30,30,30
 dc.w  0,$1*4,3,18,42,43,19,18,30,30,30,30
 dc.w  0,$1*4,3,19,43,44,20,19,30,30,30,30
 dc.w  0,$1*4,3,20,44,45,21,20,30,30,30,30
 dc.w  0,$1*4,3,21,45,46,22,21,30,30,30,30
 dc.w  0,$1*4,3,22,46,47,23,22,30,30,30,30
 dc.w  0,$1*4,3,23,47,36,12,23,30,30,30,30
 dc.w  0,$1*4,3,2,11,0,1,2,30,30,30,30
 dc.w  0,$1*4,3,24,35,26,25,24,30,30,30,30
 dc.w  0,$1*4,3,5,6,3,4,5,30,30,30,30
 dc.w  0,$1*4,3,27,30,29,28,27,30,30,30,30
 dc.w  0,$1*4,3,9,10,7,8,9,30,30,30,30
 dc.w  0,$1*4,3,31,34,33,32,31,30,30,30,30
 dc.w  0,$1*4,2,7,10,11,7,30,30,30
 dc.w  0,$1*4,2,35,34,31,35,30,30,30
 dc.w  0,$1*4,2,6,7,11,6,30,30,30
 dc.w  0,$1*4,2,35,31,30,35,30,30,30
 dc.w  0,$1*4,2,11,2,3,11,30,30,30
 dc.w  0,$1*4,2,27,26,35,27,30,30,30
 dc.w  0,$1*4,2,3,6,11,3,30,30,30
 dc.w  0,$1*4,2,35,30,27,35,30,30,30
 dc.w  0,$1*4,3,15,16,13,14,15,30,30,30,30
 dc.w  0,$1*4,3,37,40,39,38,37,30,30,30,30
 dc.w  0,$1*4,3,18,19,16,17,18,30,30,30,30
 dc.w  0,$1*4,3,40,43,42,41,40,30,30,30,30
 dc.w  0,$1*4,3,21,22,19,20,21,30,30,30,30
 dc.w  0,$1*4,3,43,46,45,44,43,30,30,30,30
 dc.w  0,$1*4,2,19,22,23,19,30,30,30
 dc.w  0,$1*4,2,47,46,43,47,30,30,30
 dc.w  0,$1*4,2,19,23,12,19,30,30,30
 dc.w  0,$1*4,2,36,47,43,36,30,30,30
 dc.w  0,$1*4,2,19,12,13,19,30,30,30
 dc.w  0,$1*4,2,37,36,43,37,30,30,30
 dc.w  0,$1*4,2,13,16,19,13,30,30,30
 dc.w  0,$1*4,2,43,40,37,43,30,30,30
 dc.w  0,$1*4,3,48,52,53,49,48,30,30,30,30
 dc.w  0,$1*4,2,53,50,49,53,30,30,30
 dc.w  0,$1*4,2,52,48,51,52,30,30,30
 dc.w  0,$1*4,3,52,54,55,53,52,30,30,30,30
 dc.w  0,$1*4,2,55,50,53,55,30,30,30
 dc.w  0,$1*4,2,54,52,51,54,30,30,30
 dc.w  0,$1*4,3,54,56,57,55,54,30,30,30,30
 dc.w  0,$1*4,2,57,50,55,57,30,30,30
 dc.w  0,$1*4,2,56,54,51,56,30,30,30
 dc.w  0,$1*4,3,56,58,59,57,56,30,30,30,30
 dc.w  0,$1*4,2,59,50,57,59,30,30,30
 dc.w  0,$1*4,2,58,56,51,58,30,30,30
 dc.w  0,$1*4,3,58,60,61,59,58,30,30,30,30
 dc.w  0,$1*4,2,61,50,59,61,30,30,30
 dc.w  0,$1*4,2,60,58,51,60,30,30,30
 dc.w  0,$1*4,3,60,48,49,61,60,30,30,30,30
 dc.w  0,$1*4,2,49,50,61,49,30,30,30
 dc.w  0,$1*4,2,48,60,51,48,30,30,30

SC_ob_ex_logo1 EQU 5
ob_ex_logo1_punkte:
 dc.w 0,0,0,0 * Cb 1
 dc.w 0,0,0,0 * Cb 2
 dc.w -256/SC_ob_ex_logo1,-976/SC_ob_ex_logo1,3584/SC_ob_ex_logo1,0
 dc.w -256/SC_ob_ex_logo1,-976/SC_ob_ex_logo1,2560/SC_ob_ex_logo1,0
 dc.w -3072/SC_ob_ex_logo1,-976/SC_ob_ex_logo1,2560/SC_ob_ex_logo1,0
 dc.w -3072/SC_ob_ex_logo1,-976/SC_ob_ex_logo1,768/SC_ob_ex_logo1,0
 dc.w -1536/SC_ob_ex_logo1,-976/SC_ob_ex_logo1,768/SC_ob_ex_logo1,0
 dc.w -1536/SC_ob_ex_logo1,-976/SC_ob_ex_logo1,-256/SC_ob_ex_logo1,0
 dc.w -3072/SC_ob_ex_logo1,-976/SC_ob_ex_logo1,-256/SC_ob_ex_logo1,0
 dc.w -3072/SC_ob_ex_logo1,-976/SC_ob_ex_logo1,-1280/SC_ob_ex_logo1,0
 dc.w -256/SC_ob_ex_logo1,-976/SC_ob_ex_logo1,-1280/SC_ob_ex_logo1,0
 dc.w -256/SC_ob_ex_logo1,-976/SC_ob_ex_logo1,-2304/SC_ob_ex_logo1,0
 dc.w -4096/SC_ob_ex_logo1,-976/SC_ob_ex_logo1,-2304/SC_ob_ex_logo1,0
 dc.w -4096/SC_ob_ex_logo1,-976/SC_ob_ex_logo1,3584/SC_ob_ex_logo1,0
 dc.w 1536/SC_ob_ex_logo1,240/SC_ob_ex_logo1,2304/SC_ob_ex_logo1,0
 dc.w 2560/SC_ob_ex_logo1,240/SC_ob_ex_logo1,0/SC_ob_ex_logo1,0
 dc.w 3584/SC_ob_ex_logo1,240/SC_ob_ex_logo1,2304/SC_ob_ex_logo1,0
 dc.w 4608/SC_ob_ex_logo1,240/SC_ob_ex_logo1,2304/SC_ob_ex_logo1,0
 dc.w 3200/SC_ob_ex_logo1,240/SC_ob_ex_logo1,-768/SC_ob_ex_logo1,0
 dc.w 4608/SC_ob_ex_logo1,240/SC_ob_ex_logo1,-2304/SC_ob_ex_logo1,0
 dc.w 3328/SC_ob_ex_logo1,240/SC_ob_ex_logo1,-2304/SC_ob_ex_logo1,0
 dc.w 2560/SC_ob_ex_logo1,240/SC_ob_ex_logo1,-1280/SC_ob_ex_logo1,0
 dc.w 1792/SC_ob_ex_logo1,240/SC_ob_ex_logo1,-2304/SC_ob_ex_logo1,0
 dc.w 512/SC_ob_ex_logo1,240/SC_ob_ex_logo1,-2304/SC_ob_ex_logo1,0
 dc.w 2048/SC_ob_ex_logo1,240/SC_ob_ex_logo1,-768/SC_ob_ex_logo1,0
 dc.w 512/SC_ob_ex_logo1,240/SC_ob_ex_logo1,2304/SC_ob_ex_logo1,0
 dc.w -256/SC_ob_ex_logo1,-176/SC_ob_ex_logo1,3584/SC_ob_ex_logo1,0
 dc.w -256/SC_ob_ex_logo1,-176/SC_ob_ex_logo1,2560/SC_ob_ex_logo1,0
 dc.w -3072/SC_ob_ex_logo1,-176/SC_ob_ex_logo1,2560/SC_ob_ex_logo1,0
 dc.w -3072/SC_ob_ex_logo1,-176/SC_ob_ex_logo1,768/SC_ob_ex_logo1,0
 dc.w -1536/SC_ob_ex_logo1,-176/SC_ob_ex_logo1,768/SC_ob_ex_logo1,0
 dc.w -1536/SC_ob_ex_logo1,-176/SC_ob_ex_logo1,-256/SC_ob_ex_logo1,0
 dc.w -3072/SC_ob_ex_logo1,-176/SC_ob_ex_logo1,-256/SC_ob_ex_logo1,0
 dc.w -3072/SC_ob_ex_logo1,-176/SC_ob_ex_logo1,-1280/SC_ob_ex_logo1,0
 dc.w -256/SC_ob_ex_logo1,-176/SC_ob_ex_logo1,-1280/SC_ob_ex_logo1,0
 dc.w -256/SC_ob_ex_logo1,-176/SC_ob_ex_logo1,-2304/SC_ob_ex_logo1,0
 dc.w -4096/SC_ob_ex_logo1,-176/SC_ob_ex_logo1,-2304/SC_ob_ex_logo1,0
 dc.w -4096/SC_ob_ex_logo1,-176/SC_ob_ex_logo1,3584/SC_ob_ex_logo1,0
 dc.w 1536/SC_ob_ex_logo1,1040/SC_ob_ex_logo1,2304/SC_ob_ex_logo1,0
 dc.w 2560/SC_ob_ex_logo1,1040/SC_ob_ex_logo1,0/SC_ob_ex_logo1,0
 dc.w 3584/SC_ob_ex_logo1,1040/SC_ob_ex_logo1,2304/SC_ob_ex_logo1,0
 dc.w 4608/SC_ob_ex_logo1,1040/SC_ob_ex_logo1,2304/SC_ob_ex_logo1,0
 dc.w 3200/SC_ob_ex_logo1,1040/SC_ob_ex_logo1,-768/SC_ob_ex_logo1,0
 dc.w 4608/SC_ob_ex_logo1,1040/SC_ob_ex_logo1,-2304/SC_ob_ex_logo1,0
 dc.w 3328/SC_ob_ex_logo1,1040/SC_ob_ex_logo1,-2304/SC_ob_ex_logo1,0
 dc.w 2560/SC_ob_ex_logo1,1040/SC_ob_ex_logo1,-1280/SC_ob_ex_logo1,0
 dc.w 1792/SC_ob_ex_logo1,1040/SC_ob_ex_logo1,-2304/SC_ob_ex_logo1,0
 dc.w 512/SC_ob_ex_logo1,1040/SC_ob_ex_logo1,-2304/SC_ob_ex_logo1,0
 dc.w 2048/SC_ob_ex_logo1,1040/SC_ob_ex_logo1,-768/SC_ob_ex_logo1,0
 dc.w 512/SC_ob_ex_logo1,1040/SC_ob_ex_logo1,2304/SC_ob_ex_logo1,0
 dc.w 554/SC_ob_ex_logo1,0/SC_ob_ex_logo1,318/SC_ob_ex_logo1,0
 dc.w 554/SC_ob_ex_logo1,0/SC_ob_ex_logo1,-320/SC_ob_ex_logo1,0
 dc.w 0/SC_ob_ex_logo1,0/SC_ob_ex_logo1,-640/SC_ob_ex_logo1,0
 dc.w 0/SC_ob_ex_logo1,0/SC_ob_ex_logo1,640/SC_ob_ex_logo1,0
 dc.w 276/SC_ob_ex_logo1,478/SC_ob_ex_logo1,318/SC_ob_ex_logo1,0
 dc.w 276/SC_ob_ex_logo1,478/SC_ob_ex_logo1,-320/SC_ob_ex_logo1,0
 dc.w -276/SC_ob_ex_logo1,478/SC_ob_ex_logo1,318/SC_ob_ex_logo1,0
 dc.w -276/SC_ob_ex_logo1,478/SC_ob_ex_logo1,-320/SC_ob_ex_logo1,0
 dc.w -554/SC_ob_ex_logo1,0/SC_ob_ex_logo1,318/SC_ob_ex_logo1,0
 dc.w -554/SC_ob_ex_logo1,0/SC_ob_ex_logo1,-320/SC_ob_ex_logo1,0
 dc.w -276/SC_ob_ex_logo1,-478/SC_ob_ex_logo1,318/SC_ob_ex_logo1,0
 dc.w -276/SC_ob_ex_logo1,-478/SC_ob_ex_logo1,-320/SC_ob_ex_logo1,0
 dc.w 276/SC_ob_ex_logo1,-478/SC_ob_ex_logo1,318/SC_ob_ex_logo1,0
 dc.w 276/SC_ob_ex_logo1,-478/SC_ob_ex_logo1,-320/SC_ob_ex_logo1,0

SC_PLANES     EQU       2
ob_plane_1:   DC.W      1,6
              DC.L      ob_pl_1_pnts,0
              DC.W      0,2,3,0,1,2,3,0,30,30,20,20
ob_plane_2:   DC.W      1,6
              DC.L      ob_pl_1_pnts,0
              DC.W      0,3,3,0,1,2,3,0,30,30,20,20
ob_plane_3:   DC.W      1,6
              DC.L      ob_pl_1_pnts,0
              DC.W      0,4,3,0,1,2,3,0,30,30,20,20
ob_plane_4:   DC.W      1,6
              DC.L      ob_pl_1_pnts,0
              DC.W      0,5,3,0,1,2,3,0,30,30,20,20
ob_pl_1_pnts: DS.W      8
              DC.W      100/SC_PLANES,0,-100/SC_PLANES,0
              DC.W      -100/SC_PLANES,0,-100/SC_PLANES,0
              DC.W      -100/SC_PLANES,0,100/SC_PLANES,0
              DC.W      100/SC_PLANES,0,100/SC_PLANES,0

*****************************************************************************
*  Zweiseitige WÑnde, ohne Tiefe...                                         *
*  Zu jeder Ebene eine Plane (x/y/z)                                        *
*****************************************************************************
SC_PLANES_B   EQU       2
PLA_Z         SET       200/SC_PLANES_B
DP_LEN_Z      EQU       PLA_Z*2
ob_plane_xz:  DC.W      2,6               ; Plane parallel zur x/z-Ebene.
              DC.L      pl_1b_pnts,0,0
              DC.W      0,1,3,0,1,2,3,0,30,30,10,10
              DC.W      0,5,3,3,2,1,0,3,10,10,30,30
ob_plane_xz2: DC.W      2,6               ; Das ganze mit verschiedenen Farben.
              DC.L      pl_1b_pnts,0,0
              DC.W      0,3,3,0,1,2,3,0,30,30,10,10
              DC.W      0,6,3,3,2,1,0,3,10,10,30,30
ob_plane_xz3: DC.W      2,6
              DC.L      pl_1b_pnts,0,0
              DC.W      0,5,3,0,1,2,3,0,30,30,10,10
              DC.W      0,7,3,3,2,1,0,3,10,10,30,30
ob_plane_xz4: DC.W      2,6
              DC.L      pl_1b_pnts,0,0
              DC.W      0,7,3,0,1,2,3,0,30,30,10,10
              DC.W      0,8,3,3,2,1,0,3,10,10,30,30
o1_plane_xz:  DC.W      1,6               ; Plane parallel zur x/z-Ebene.
              DC.L      pl_1b_pnts,0
              DC.W      0,1,3,0,1,2,3,0,10,10,30,30
o1_plane_xz2: DC.W      1,6               ; Das ganze mit verschiedenen Farben.
              DC.L      pl_1b_pnts,0
              DC.W      0,3,3,0,1,2,3,0,10,10,30,30
o1_plane_xz3: DC.W      1,6
              DC.L      pl_1b_pnts,0
              DC.W      0,5,3,0,1,2,3,0,10,10,30,30
o1_plane_xz4: DC.W      1,6
              DC.L      pl_1b_pnts,0
              DC.W      0,7,3,0,1,2,3,0,30,30,10,10

pl_1b_pnts:   DS.W      8,0
              DC.W      170/SC_PLANES_B,0,-PLA_Z,0
              DC.W      -170/SC_PLANES_B,0,-PLA_Z,0
              DC.W      -170/SC_PLANES_B,0,PLA_Z,0
              DC.W      170/SC_PLANES_B,0,PLA_Z,0

ob_plane_xy:  DC.W      2,6               ; Plane parallel zur x/y-Ebene.
              DC.L      pl_2b_pnts,0,0
              DC.W      0,8,3,0,1,2,3,0,30,30,10,10
              DC.W      0,3,3,3,2,1,0,3,10,10,30,30
ob_plane_xy2: DC.W      2,6
              DC.L      pl_2b_pnts,0,0
              DC.W      0,10,3,0,1,2,3,0,30,30,10,10
              DC.W      0,7,3,3,2,1,0,3,10,10,30,30
ob_plane_xy3: DC.W      2,6
              DC.L      pl_2b_pnts,0,0
              DC.W      0,12,3,0,1,2,3,0,30,30,10,10
              DC.W      0,8,3,3,2,1,0,3,10,10,30,30
ob_plane_xy4: DC.W      2,6
              DC.L      pl_2b_pnts,0,0
              DC.W      0,14,3,0,1,2,3,0,30,30,10,10
              DC.W      0,10,3,3,2,1,0,3,10,10,30,30

pl_2b_pnts:   DS.W      8,0
              DC.W      170/SC_PLANES_B,-100/SC_PLANES_B,0,0
              DC.W      -170/SC_PLANES_B,-100/SC_PLANES_B,0,0
              DC.W      -170/SC_PLANES_B,100/SC_PLANES_B,0,0
              DC.W      170/SC_PLANES_B,100/SC_PLANES_B,0,0

ob_plane_yz:  DC.W      2,6               ; Plane parallel zur y/z-Ebene.
              DC.L      pl_3b_pnts,0,0
              DC.W      0,2,3,0,1,2,3,0,30,30,10,10
              DC.W      0,9,3,3,2,1,0,3,10,10,30,30
ob_plane_yz2: DC.W      2,6
              DC.L      pl_3b_pnts,0,0
              DC.W      0,4,3,0,1,2,3,0,30,30,10,10
              DC.W      0,13,3,3,2,1,0,3,10,10,30,30
ob_plane_yz3: DC.W      2,6
              DC.L      pl_3b_pnts,0,0
              DC.W      0,6,3,0,1,2,3,0,30,30,10,10
              DC.W      0,7,3,3,2,1,0,3,10,10,30,30
ob_plane_yz4: DC.W      2,6
              DC.L      pl_3b_pnts,0,0
              DC.W      0,8,3,0,1,2,3,0,30,30,10,10
              DC.W      0,14,3,3,2,1,0,3,10,10,30,30

pl_3b_pnts:   DS.W      8,0
              DC.W      0,100/SC_PLANES_B,-PLA_Z,0
              DC.W      0,-100/SC_PLANES_B,-PLA_Z,0
              DC.W      0,-100/SC_PLANES_B,PLA_Z,0
              DC.W      0,100/SC_PLANES_B,PLA_Z,0

*****************************************************************************
* Spitzer fÅnfzackiger Stern (kein Extrudeobjekt) (Plane 0 und 1)           *
*****************************************************************************
ob_stern1:    DC.W      20,12+2
              DC.L      ob_st1_pnts
              DS.L      20,0

              DC.W      0,1,2,0,2,7,0,29,29,29
              DC.W      0,0,2,0,7,6,0,29,29,29

              DC.W      0,0,2,0,8,2,0,29,29,29
              DC.W      0,1,2,0,3,8,0,29,29,29

              DC.W      0,0,2,0,9,3,0,29,29,29
              DC.W      0,1,2,0,4,9,0,29,29,29

              DC.W      0,0,2,0,10,4,0,29,29,29
              DC.W      0,1,2,0,5,10,0,29,29,29

              DC.W      0,0,2,0,11,5,0,29,29,29
              DC.W      0,1,2,0,6,11,0,29,29,29

              DC.W      0,1,2,1,7,2,1,29,29,29      ; Untere Schicht.
              DC.W      0,0,2,1,6,7,1,29,29,29

              DC.W      0,0,2,1,2,8,1,29,29,29
              DC.W      0,1,2,1,8,3,1,29,29,29

              DC.W      0,0,2,1,3,9,1,29,29,29
              DC.W      0,1,2,1,9,4,1,29,29,29
              
              DC.W      0,0,2,1,4,10,1,29,29,29
              DC.W      0,1,2,1,10,5,1,29,29,29

              DC.W      0,0,2,1,5,11,1,29,29,29
              DC.W      0,1,2,1,11,6,1,29,29,29

ob_stern2:    DC.W      20,12+2           ; Dasselbe, nur auf Plane 2 und 3.
              DC.L      ob_st1_pnts
              DS.L      20,0
              DC.W      0,3,2,0,2,7,0,29,29,29
              DC.W      0,2,2,0,7,6,0,29,29,29
              DC.W      0,2,2,0,8,2,0,29,29,29
              DC.W      0,3,2,0,3,8,0,29,29,29
              DC.W      0,2,2,0,9,3,0,29,29,29
              DC.W      0,3,2,0,4,9,0,29,29,29
              DC.W      0,2,2,0,10,4,0,29,29,29
              DC.W      0,3,2,0,5,10,0,29,29,29
              DC.W      0,2,2,0,11,5,0,29,29,29
              DC.W      0,3,2,0,6,11,0,29,29,29
              DC.W      0,3,2,1,7,2,1,29,29,29
              DC.W      0,2,2,1,6,7,1,29,29,29
              DC.W      0,2,2,1,2,8,1,29,29,29
              DC.W      0,3,2,1,8,3,1,29,29,29
              DC.W      0,2,2,1,3,9,1,29,29,29
              DC.W      0,3,2,1,9,4,1,29,29,29
              DC.W      0,2,2,1,4,10,1,29,29,29
              DC.W      0,3,2,1,10,5,1,29,29,29
              DC.W      0,2,2,1,5,11,1,29,29,29
              DC.W      0,3,2,1,11,6,1,29,29,29

OB_SCA_ST1    EQU       1
ob_st1_pnts:  DS.W      8,0
              DC.W      0,0,20/OB_SCA_ST1,0     ; Mittelpunkt oben.
              DC.W      0,0,-20/OB_SCA_ST1,0    ; Mittelpunkt unten.

              DC.W      41/OB_SCA_ST1,29/OB_SCA_ST1,0,0 ; Innerer Kreis.
              DC.W      -15/OB_SCA_ST1,48/OB_SCA_ST1,0,0
              DC.W      -50/OB_SCA_ST1,1/OB_SCA_ST1,0,0
              DC.W      -16/OB_SCA_ST1,-47/OB_SCA_ST1,0,0
              DC.W      40/OB_SCA_ST1,-30/OB_SCA_ST1,0,0

              DC.W      100/OB_SCA_ST1,0,0,0    ; éuûerer Kreis.
              DC.W      31/OB_SCA_ST1,95/OB_SCA_ST1,0,0
              DC.W      -81/OB_SCA_ST1,59/OB_SCA_ST1,0,0
              DC.W      -81/OB_SCA_ST1,-59/OB_SCA_ST1,0,0
              DC.W      31/OB_SCA_ST1,-95/OB_SCA_ST1,0,0

ex_kante:     DC.L      et_back           ; Pointer auf FlÑchenbuffer
              DC.W      4,1               ; Anz. KantenflÑchen, Anz. Frontfl.
              DC.W      3,1,0             ; Farbe, Kantenpunkt 1,2
              DC.W      3,2,1,3,3,2,3,0,3
ex_test:      DC.W      6,10
              DC.L      et_tst
              DS.L      6,0

              DC.W      0,2,3,0,1,2,3,0,30,30,30,30
et_back:      DC.W      0,0,0,0,0,0,0,0,0,0,0,0     ; RÅckwand
              DS.W      4*12                        ; Extrudes...

et_tst:       DS.W      8,0
              DC.W      25/OB_SCA_ST1,50/OB_SCA_ST1,0,0
              DC.W      -50/OB_SCA_ST1,25/OB_SCA_ST1,0,0
              DC.W      -50/OB_SCA_ST1,-25/OB_SCA_ST1,0,0
              DC.W      25/OB_SCA_ST1,-50/OB_SCA_ST1,0,0
              DS.W      4*4,0

*****************************************************************************
* Extrude-"E" (Benutzt Punkte aus flachem Logo-E).                          *
*****************************************************************************
ob_e_3d_kan:  DC.L      ob_e_3d_buf
              DC.W      12,4              ; 12 TiefenflÑchen, 4 FrontflÑchen
              DC.W      1,1,0
              DC.W      1,2,1,0,3,2,0,5,3,0,6,5,1,7,6,0,8,7,0,10,8,0,11,10
              DC.W      1,12,11,1,13,12,1,0,13

ob_e_3d:      DC.W      20,28+2
              DC.L      ob_e_pnts
              DS.L      20

              DC.W      0,2,3,0,1,2,4,0,30,30,30,30
              DC.W      0,2,3,4,3,10,9,4,30,30,30,30
              DC.W      0,2,3,5,6,7,8,5,30,30,30,30
              DC.W      0,2,3,9,11,12,13,9,30,30,30,30
ob_e_3d_buf:  DS.W      4*12              ; RÅckseite.
              DS.W      12*12             ; Tiefenobjekte.

*****************************************************************************
* Extrude-Kreuz.                                                            *
*****************************************************************************
kreuz_2_kan:  DC.L      k2_gen_f
              DC.W      12,2
              DC.W      0,1,0,0,2,1,0,3,2,0,4,3,0,5,4,0,6,5,0,7,6,0,8,7
              DC.W      0,9,8,0,10,9,0,11,10,0,0,11

kreuz_2_obj:  DC.W      12+4,24+2
              DC.L      kreuz2pnt
              DS.L      16

              DC.W      0,14,3,2,3,8,9,2,30,30,30,30
              DC.W      0,14,3,0,5,6,11,0,30,30,30,30
k2_gen_f:     DS.W      (12+2)*12

SC_KREUZ_2    EQU       1
kreuz2pnt:    DS.W      8
              DC.W      -30/SC_KREUZ_2,-60/SC_KREUZ_2,0,0
              DC.W      -10/SC_KREUZ_2,-60/SC_KREUZ_2,0,0
              DC.W      -10/SC_KREUZ_2,-80/SC_KREUZ_2,0,0
              DC.W      10/SC_KREUZ_2,-80/SC_KREUZ_2,0,0
              DC.W      10/SC_KREUZ_2,-60/SC_KREUZ_2,0,0
              DC.W      30/SC_KREUZ_2,-60/SC_KREUZ_2,0,0
              DC.W      30/SC_KREUZ_2,-40/SC_KREUZ_2,0,0
              DC.W      10/SC_KREUZ_2,-40/SC_KREUZ_2,0,0
              DC.W      10/SC_KREUZ_2,-0/SC_KREUZ_2,0,0
              DC.W      -10/SC_KREUZ_2,-0/SC_KREUZ_2,0,0
              DC.W      -10/SC_KREUZ_2,-40/SC_KREUZ_2,0,0
              DC.W      -30/SC_KREUZ_2,-40/SC_KREUZ_2,0,0
              DS.W      12*4

*****************************************************************************
* Spartanisches Kreuz auf Farbe 15.                                         *
*****************************************************************************
kreuz3_obj:   DC.W      2,10
              DC.L      kreuz3_pnt,0,0
              DC.W      0,15,3,0,3,4,7,0,30,30,30,30
              DC.W      0,15,3,1,2,5,6,1,30,30,30,30

kreuz3_pnt:   DS.W      8
              DC.W      -30/SC_KREUZ_2,-60/SC_KREUZ_2,0,0
              DC.W      -10/SC_KREUZ_2,-80/SC_KREUZ_2,0,0
              DC.W      10/SC_KREUZ_2,-80/SC_KREUZ_2,0,0
              DC.W      30/SC_KREUZ_2,-60/SC_KREUZ_2,0,0
              DC.W      30/SC_KREUZ_2,-40/SC_KREUZ_2,0,0
              DC.W      10/SC_KREUZ_2,-0/SC_KREUZ_2,0,0
              DC.W      -10/SC_KREUZ_2,-0/SC_KREUZ_2,0,0
              DC.W      -30/SC_KREUZ_2,-40/SC_KREUZ_2,0,0

* EX-Logo Extrude, Version 2.
obj_ex_2_kan: DC.L      ob_ex_buf
              DC.W      12,4
              DC.W      4,1,0
              DC.W      4,2,1,4,3,2,4,5,3,4,6,5,4,7,6,4,8,7,4,10,8,4,11,10
              DC.W      4,12,11,4,13,12,4,0,13

obj_ex_2:     DC.W      20,28+2
              DC.L      ob_ex_pnts
              DS.L      20

              DC.W      0,4,3,0,1,2,4,0,30,30,30,30
              DC.W      0,4,3,4,3,10,9,4,30,30,30,30
              DC.W      0,4,3,5,6,7,8,5,30,30,30,30
              DC.W      0,4,3,9,11,12,13,9,30,30,30,30
ob_ex_buf:    DS.W      4*12              ; RÅckseite.
              DS.W      12*12             ; Tiefenobjekte.

SC_OB_L_EX    EQU       1
ob_ex_pnts:   DS.W      8
              DC.W      -60/SC_OB_L_EX,-105/SC_OB_L_EX,0,0
              DC.W      60/SC_OB_L_EX,-105/SC_OB_L_EX,0,0
              DC.W      60/SC_OB_L_EX,-65/SC_OB_L_EX,0,0
              DC.W      -30/SC_OB_L_EX,-65/SC_OB_L_EX,0,0
              DC.W      -60/SC_OB_L_EX,-65/SC_OB_L_EX,0,0
              DC.W      -30/SC_OB_L_EX,-10/SC_OB_L_EX,0,0
              DC.W      40/SC_OB_L_EX,-10/SC_OB_L_EX,0,0
              DC.W      40/SC_OB_L_EX,20/SC_OB_L_EX,0,0
              DC.W      -30/SC_OB_L_EX,20/SC_OB_L_EX,0,0
              DC.W      -60/SC_OB_L_EX,65/SC_OB_L_EX,0,0
              DC.W      -30/SC_OB_L_EX,65/SC_OB_L_EX,0,0
              DC.W      70/SC_OB_L_EX,65/SC_OB_L_EX,0,0
              DC.W      70/SC_OB_L_EX,105/SC_OB_L_EX,0,0
              DC.W      -60/SC_OB_L_EX,105/SC_OB_L_EX,0,0
              DS.W      14*4              ; FÅr Extrudeobjekt.

obj_open_1ak: DC.L      o1a_fl
              DC.W      5,2
              DC.W      6,0,1,6,1,2,6,2,3,6,3,4,6,4,5
obj_open_1a:  DC.W      5+4,8+8+2
              DC.L      obj_o1a_pnt
              DS.L      9,0

              DC.W      0,5,3,0,5,6,7,0,30,30,30,30
              DC.W      0,8,3,4,3,2,1,4,30,30,30,30
o1a_fl:       DS.W      14*(2+8)

SC_OO1A       EQU       2
obj_o1a_pnt:  DS.W      8
              DC.W      -1000/SC_OO1A,0,0,0
              DC.W      -100/SC_OO1A,0,0,0
              DC.W      -100/SC_OO1A,200/SC_OO1A,0,0
              DC.W      100/SC_OO1A,200/SC_OO1A,0,0
              DC.W      100/SC_OO1A,0,0,0
              DC.W      1000/SC_OO1A,0,0,0
              DC.W      1000/SC_OO1A,-500/SC_OO1A,0,0
              DC.W      -1000/SC_OO1A,-500/SC_OO1A,0,0
              DS.W      8*4

*****************************************************************************
* Metronom, bestehend aus Pendel und Grundkîrper.                           *
*****************************************************************************
METRO_SCALE   EQU       1
obj_metro_p:  DC.W      2,6
              DC.L      metro2_pnts,0,0
              DC.W      0,4,3,0,1,2,3,0,30,30,30,30
              DC.W      0,4,3,0,3,2,1,0,30,30,30,30
obj_metro_p1: DC.W      2,6
              DC.L      metro2_pnts,0,0
              DC.W      0,5,3,0,1,2,3,0,30,30,30,30
              DC.W      0,5,3,0,3,2,1,0,30,30,30,30
obj_metro_p2: DC.W      2,6
              DC.L      metro2_pnts,0,0
              DC.W      0,6,3,0,1,2,3,0,30,30,30,30
              DC.W      0,6,3,0,3,2,1,0,30,30,30,30
obj_metro_p3: DC.W      2,6
              DC.L      metro2_pnts,0,0
              DC.W      0,7,3,0,1,2,3,0,30,30,30,30
              DC.W      0,7,3,0,3,2,1,0,30,30,30,30
obj_metro_p4: DC.W      2,6
              DC.L      metro2_pnts,0,0
              DC.W      0,8,3,0,1,2,3,0,30,30,30,30
              DC.W      0,8,3,0,3,2,1,0,30,30,30,30
obj_metro_p5: DC.W      2,6
              DC.L      metro2_pnts,0,0
              DC.W      0,9,3,0,1,2,3,0,30,30,30,30
              DC.W      0,9,3,0,3,2,1,0,30,30,30,30
obj_metro_p6: DC.W      2,6
              DC.L      metro2_pnts,0,0
              DC.W      0,10,3,0,1,2,3,0,30,30,30,30
              DC.W      0,10,3,0,3,2,1,0,30,30,30,30
obj_metro_p7: DC.W      2,6
              DC.L      metro2_pnts,0,0
              DC.W      0,11,3,0,1,2,3,0,30,30,30,30
              DC.W      0,11,3,0,3,2,1,0,30,30,30,30
obj_metro_p8: DC.W      2,6
              DC.L      metro2_pnts,0,0
              DC.W      0,12,3,0,1,2,3,0,30,30,30,30
              DC.W      0,12,3,0,3,2,1,0,30,30,30,30
obj_metro_p9: DC.W      2,6
              DC.L      metro2_pnts,0,0
              DC.W      0,13,3,0,1,2,3,0,30,30,30,30
              DC.W      0,13,3,0,3,2,1,0,30,30,30,30

metro2_pnts:  DS.W      8
              DC.W      -5/METRO_SCALE,20/METRO_SCALE,0,0
              DC.W      -5/METRO_SCALE,-65/METRO_SCALE,0,0
              DC.W      5/METRO_SCALE,-65/METRO_SCALE,0,0
              DC.W      5/METRO_SCALE,20/METRO_SCALE,0,0

*** Metronom Grundkîrper: Extrudeobjekt. ***
kan_metro:    DC.L      me_flaech
              DC.W      4,1
              DC.W      2,1,0
              DC.W      3,2,1
              DC.W      2,3,2
              DC.W      3,0,3
obj_metro:    DC.W      6,8+2
              DC.L      metro_pnts
              DS.L      6
              DC.W      0,1,3,0,1,2,3,0,30,30,30,30
me_flaech:    DS.W      5*14
metro_pnts:   DS.W      8
              DC.W      -30/METRO_SCALE,0,0,0
              DC.W      -10/METRO_SCALE,-80/METRO_SCALE,0,0
              DC.W      10/METRO_SCALE,-80/METRO_SCALE,0,0
              DC.W      30/METRO_SCALE,0,0,0
              DS.W      4*4

; Der Untergrund unter den Metronomen.
obj_underground:
              DC.W      1,6
              DC.L      obj_u_pnts,0
              DC.W      0,15,3,0,1,2,3,0,30,30,30,30

obj_u_pnts:   DS.W      8
              DC.W      -30/METRO_SCALE,0,-250,0
              DC.W      -30/METRO_SCALE,0,2750,0
              DC.W      30/METRO_SCALE,0,2750,0
              DC.W      30/METRO_SCALE,0,-250,0

*****************************************************************************
* Planes senkrecht zur y-Achse, quadratisch (nicht Rechteckig wie Dungeons.)*
*****************************************************************************
qu_plane_xy:  DC.W      2,6               ; Plane parallel zur x/y-Ebene.
              DC.L      qu_2b_pnts,0,0
              DC.W      0,1,3,0,1,2,3,0,30,30,10,10
              DC.W      0,5,3,3,2,1,0,3,10,10,30,30
qu_plane_xy2: DC.W      2,6
              DC.L      qu_2b_pnts,0,0
              DC.W      0,2,3,0,1,2,3,0,30,30,10,10
              DC.W      0,6,3,3,2,1,0,3,10,10,30,30
qu_plane_xy3: DC.W      2,6
              DC.L      qu_2b_pnts,0,0
              DC.W      0,3,3,0,1,2,3,0,30,30,10,10
              DC.W      0,7,3,3,2,1,0,3,10,10,30,30
qu_plane_xy4: DC.W      2,6
              DC.L      qu_2b_pnts,0,0
              DC.W      0,4,3,0,1,2,3,0,30,30,10,10
              DC.W      0,8,3,3,2,1,0,3,10,10,30,30

qu_2b_pnts:   DS.W      8,0
              DC.W      170/SC_PLANES_B,-170/SC_PLANES_B,0,0
              DC.W      -170/SC_PLANES_B,-170/SC_PLANES_B,0,0
              DC.W      -170/SC_PLANES_B,170/SC_PLANES_B,0,0
              DC.W      170/SC_PLANES_B,170/SC_PLANES_B,0,0

*****************************************************************************
*  Groûer Ring (Extrudeobjekt ohne FrontflÑche, damit InnenwÑnde sichtbar   *
*               bleiben.)                                                   *
*****************************************************************************
kan_ring_1:   DC.L      ring1_fl
              DC.W      12,0              ; KEINE FrontflÑchen.
              DC.W      14,0,1,13,1,2,12,2,3,14,3,4
              DC.W      13,4,5,12,5,6,14,6,7,13,7,8
              DC.W      12,8,9,14,9,10,13,10,11,12,11,0

obj_ring_1:   DC.W      12,24+2
              DC.L      ring1_pnts
              DS.L      12
ring1_fl:     DS.W      12*14
SC_K1         EQU       14
ring1_pnts:   DS.W      8
              DC.W      100*SC_K1,0*SC_K1,0,0   ; Kreispunkte automatisch generiert.
              DC.W      87*SC_K1,50*SC_K1,0,0
              DC.W      50*SC_K1,87*SC_K1,0,0
              DC.W      0*SC_K1,100*SC_K1,0,0
              DC.W      -50*SC_K1,87*SC_K1,0,0
              DC.W      -87*SC_K1,50*SC_K1,0,0
              DC.W      -100*SC_K1,0*SC_K1,0,0
              DC.W      -87*SC_K1,-50*SC_K1,0,0
              DC.W      -50*SC_K1,-87*SC_K1,0,0
              DC.W      0*SC_K1,-100*SC_K1,0,0
              DC.W      50*SC_K1,-87*SC_K1,0,0
              DC.W      87*SC_K1,-50*SC_K1,0,0
              DS.W      12*4

cube_e:       DC.W      6                 ; Ananlog "cube_a", nur fÅr "wp"
              DC.W      8+2
              DC.L      cube_punkte_e
              DS.L      6,0
              DC.W      0,14,3,0,1,2,3,0,30,30,1,1
              DC.W      0,13,3,0,4,5,1,0,30,30,1,1
              DC.W      0,12,3,1,5,6,2,1,30,30,1,1
              DC.W      0,12,3,2,6,7,3,2,30,30,1,1
              DC.W      0,13,3,3,7,4,0,3,30,30,1,1
              DC.W      0,14,3,7,6,5,4,7,30,30,1,1

SC_CUBE_E     EQU       3
cube_punkte_e: DS.W     8
              DC.W      -220/SC_CUBE_E,-220/SC_CUBE_E,-220/SC_CUBE_E,0
              DC.W      220/SC_CUBE_E,-220/SC_CUBE_E,-220/SC_CUBE_E,0
              DC.W      220/SC_CUBE_E,220/SC_CUBE_E,-220/SC_CUBE_E,0
              DC.W      -220/SC_CUBE_E,220/SC_CUBE_E,-220/SC_CUBE_E,0
              DC.W      -220/SC_CUBE_E,-220/SC_CUBE_E,220/SC_CUBE_E,0
              DC.W      220/SC_CUBE_E,-220/SC_CUBE_E,220/SC_CUBE_E,0
              DC.W      220/SC_CUBE_E,220/SC_CUBE_E,220/SC_CUBE_E,0
              DC.W      -220/SC_CUBE_E,220/SC_CUBE_E,220/SC_CUBE_E,0

*****************************************************************************
* Die Highcolour-Cubefamily: Wird fÅr interpoliertes FÅllen benutzt.        *
*****************************************************************************
obj_hccube1:  DC.W      6,10              ; PrÑdestiniert fÅr Festshading !
              DC.L      hcc1_pnts
              DS.L      6

              DC.W      0,FLESH_BAKERSCHOC,3,0,1,2,3,0,30,30,1,1
              DC.W      0,FLESH_BAKERSCHOC,3,0,4,5,1,0,30,1,1,30

              DC.W      0,FLESH_BAKERSCHOC,3,2,1,5,6,2,30,1,1,30
              DC.W      0,FLESH_BAKERSCHOC,3,3,2,6,7,3,1,30,30,1

              DC.W      0,FLESH_BAKERSCHOC,3,3,7,4,0,3,1,30,30,1
              DC.W      0,FLESH_BAKERSCHOC,3,4,7,6,5,4,30,30,1,1

obj_hccube2:  DC.W      6,10              ; Interferenzen im Shading...
              DC.L      hcc1_pnts
              DS.L      6

              DC.W      0,FLESH_BAKERSCHOC,3,0,1,2,3,0,30,1,30,1
              DC.W      0,FLESH_BAKERSCHOC,3,0,4,5,1,0,30,1,30,1

              DC.W      0,FLESH_BAKERSCHOC,3,2,1,5,6,2,30,1,30,1
              DC.W      0,FLESH_BAKERSCHOC,3,3,2,6,7,3,1,30,1,30

              DC.W      0,FLESH_BAKERSCHOC,3,3,7,4,0,3,1,30,1,30
              DC.W      0,FLESH_BAKERSCHOC,3,4,7,6,5,4,1,30,1,30

obj_hccube3:  DC.W      6,10              ; Interferenzen im Shading...
              DC.L      hcc2_pnts
              DS.L      6
              DC.W      0,BLUE,3,0,1,2,3,0,30,1,30,1
              DC.W      0,BLUE,3,0,4,5,1,0,30,1,30,1
              DC.W      0,BLUE,3,2,1,5,6,2,30,1,30,1
              DC.W      0,BLUE,3,3,2,6,7,3,1,30,1,30
              DC.W      0,BLUE,3,3,7,4,0,3,1,30,1,30
              DC.W      0,BLUE,3,4,7,6,5,4,1,30,1,30

HCC_SC1       EQU       2
HCC_SC2       EQU       5
hcc1_pnts:    DS.W      8
              DC.W      -100/HCC_SC1,100/HCC_SC1,100/HCC_SC1,0
              DC.W      100/HCC_SC1,100/HCC_SC1,100/HCC_SC1,0
              DC.W      100/HCC_SC1,-100/HCC_SC1,100/HCC_SC1,0
              DC.W      -100/HCC_SC1,-100/HCC_SC1,100/HCC_SC1,0

              DC.W      -100/HCC_SC1,100/HCC_SC1,-100/HCC_SC1,0
              DC.W      100/HCC_SC1,100/HCC_SC1,-100/HCC_SC1,0
              DC.W      100/HCC_SC1,-100/HCC_SC1,-100/HCC_SC1,0
              DC.W      -100/HCC_SC1,-100/HCC_SC1,-100/HCC_SC1,0

hcc2_pnts:    DS.W      8
              DC.W      150/HCC_SC2,100/HCC_SC2,100/HCC_SC2,0
              DC.W      350/HCC_SC2,100/HCC_SC2,100/HCC_SC2,0
              DC.W      350/HCC_SC2,-100/HCC_SC2,100/HCC_SC2,0
              DC.W      150/HCC_SC2,-100/HCC_SC2,100/HCC_SC2,0

              DC.W      150/HCC_SC2,100/HCC_SC2,-100/HCC_SC2,0
              DC.W      350/HCC_SC2,100/HCC_SC2,-100/HCC_SC2,0
              DC.W      350/HCC_SC2,-100/HCC_SC2,-100/HCC_SC2,0
              DC.W      150/HCC_SC2,-100/HCC_SC2,-100/HCC_SC2,0

*****************************************************************************
* Die gigantische Absperrmaûnahme am Ende der Enduro-Racer Strecke.         *
*****************************************************************************
giga_plate1:  DC.W      1,6
              DC.L      giga_pnts1,0

;             DC.W      0,8,3,0,3,2,1,0,30,30,30,30
              DC.W      0,8,3,0,1,2,3,0,30,30,30,30

GIG_SC1       EQU       5
giga_pnts1:   DS.W      8
              DC.W      -20000/GIG_SC1,-1500/GIG_SC1,0,0
              DC.W      20000/GIG_SC1,-1500/GIG_SC1,0,0
              DC.W      20000/GIG_SC1,0/GIG_SC1,0,0
              DC.W      -20000/GIG_SC1,0/GIG_SC1,0,0

*****************************************************************************
* Das Startertor.                                                           *
*****************************************************************************
giga_pl2_kan: DC.L      gigpl2_fl
              DC.W      8,2
              DC.W      8,1,0,8,2,1,8,3,2,8,0,3
              DC.W      8,5,4,8,6,5,8,7,6,8,4,7

giga_plate2:  DC.W      12,16+2
              DC.L      giga_pnts2
              DS.L      12,0

              DC.W      0,9,3,0,1,2,3,0,30,30,30,30
              DC.W      0,9,3,4,5,6,7,4,30,30,30,30

gigpl2_fl:    DS.W      10*14

GPLSC2        EQU       2
giga_pnts2:   DS.W      8
              DC.W      -2700/GPLSC2,-350/GPLSC2,-100,0
              DC.W      -300/GPLSC2,-350/GPLSC2,-100,0
              DC.W      -300/GPLSC2,0,-100,0
              DC.W      -2700/GPLSC2,0,-100,0

              DC.W      350/GPLSC2,-350/GPLSC2,-100,0
              DC.W      1700/GPLSC2,-350/GPLSC2,-100,0
              DC.W      1700/GPLSC2,0,-100,0
              DC.W      350/GPLSC2,0,-100,0
              DS.W      8*4

*****************************************************************************
* (T)raumschiff Nummer 1: Cybersculptobjekt von Hand optimiert und erweit-  *
* ert (RÅckseiten, doppelte FlÑchen weg...)                                 *
*****************************************************************************
obj_roomer1:  DC.W      10,12
              DC.L      obj_roomer1_punkte
              DS.L      10,0

              DC.W      0,10,2,2,1,0,2,30,30,30 ; SeitenflÑchen.
              DC.W      0,11,2,3,2,0,3,30,30,30
              DC.W      0,12,2,1,3,0,1,30,30,30
              DC.W      0,13,2,1,2,3,1,30,30,30 ; Deckel am Heck...

              DC.W      0,13,2,1,4,5,1,30,30,30 ; Vorderseiten der FlÅgel.
              DC.W      0,13,2,2,6,7,2,30,30,30
              DC.W      0,13,2,3,8,9,3,30,30,30
              DC.W      0,14,2,1,5,4,1,30,30,30 ; RÅckseiten der FlÅgel.
              DC.W      0,14,2,2,7,6,2,30,30,30
              DC.W      0,14,2,3,9,8,3,30,30,30

SC_or1        EQU       25
obj_roomer1_punkte:
              DS.W 8
              DC.W 0/SC_or1,0/SC_or1,3840/SC_or1,0
              DC.W 1792/SC_or1,0/SC_or1,0/SC_or1,0
              DC.W -896/SC_or1,1551/SC_or1,0/SC_or1,0
              DC.W -895/SC_or1,-1551/SC_or1,0/SC_or1,0
              DC.W 0/SC_or1,0/SC_or1,3840/SC_or1,0
              DC.W 2816/SC_or1,0/SC_or1,576/SC_or1,0
              DC.W 0/SC_or1,0/SC_or1,3840/SC_or1,0
              DC.W -1407/SC_or1,2438/SC_or1,576/SC_or1,0
              DC.W 0/SC_or1,0/SC_or1,3840/SC_or1,0
              DC.W -1407/SC_or1,-2437/SC_or1,576/SC_or1,0 

obj_kugel_1:  DC.W      18,16
              DC.L      obj_kugel_6_punkte
              DS.L      18,0

              DC.W      0,10,3,0,4,5,1,0,30,30,30,30
              DC.W      0,11,2,5,2,1,5,30,30,30
              DC.W      0,12,2,4,0,3,4,30,30,30
              DC.W      0,13,3,4,6,7,5,4,30,30,30,30
              DC.W      0,12,2,7,2,5,7,30,30,30
              DC.W      0,11,2,6,4,3,6,30,30,30
              DC.W      0,10,3,6,8,9,7,6,30,30,30,30
              DC.W      0,11,2,9,2,7,9,30,30,30
              DC.W      0,12,2,8,6,3,8,30,30,30
              DC.W      0,13,3,8,10,11,9,8,30,30,30,30
              DC.W      0,12,2,11,2,9,11,30,30,30
              DC.W      0,11,2,10,8,3,10,30,30,30
              DC.W      0,10,3,10,12,13,11,10,30,30,30,30
              DC.W      0,11,2,13,2,11,13,30,30,30
              DC.W      0,12,2,12,10,3,12,30,30,30
              DC.W      0,13,3,12,0,1,13,12,30,30,30,30
              DC.W      0,12,2,1,2,13,1,30,30,30
              DC.W      0,11,2,0,12,3,0,30,30,30

SC_obj_kugel_6  EQU  12
obj_kugel_6_punkte:
              DS.W 8
              DC.W 1250/SC_obj_kugel_6,0/SC_obj_kugel_6,718/SC_obj_kugel_6,0
              DC.W 1250/SC_obj_kugel_6,0/SC_obj_kugel_6,-721/SC_obj_kugel_6,0
              DC.W 0/SC_obj_kugel_6,0/SC_obj_kugel_6,-1444/SC_obj_kugel_6,0
              DC.W 0/SC_obj_kugel_6,0/SC_obj_kugel_6,1444/SC_obj_kugel_6,0
              DC.W 624/SC_obj_kugel_6,1080/SC_obj_kugel_6,718/SC_obj_kugel_6,0
              DC.W 624/SC_obj_kugel_6,1080/SC_obj_kugel_6,-721/SC_obj_kugel_6,0
              DC.W -624/SC_obj_kugel_6,1080/SC_obj_kugel_6,718/SC_obj_kugel_6,0
              DC.W -624/SC_obj_kugel_6,1080/SC_obj_kugel_6,-721/SC_obj_kugel_6,0
              DC.W -1250/SC_obj_kugel_6,0/SC_obj_kugel_6,718/SC_obj_kugel_6,0
              DC.W -1250/SC_obj_kugel_6,0/SC_obj_kugel_6,-721/SC_obj_kugel_6,0
              DC.W -624/SC_obj_kugel_6,-1080/SC_obj_kugel_6,718/SC_obj_kugel_6,0
              DC.W -624/SC_obj_kugel_6,-1080/SC_obj_kugel_6,-721/SC_obj_kugel_6,0
              DC.W 624/SC_obj_kugel_6,-1080/SC_obj_kugel_6,718/SC_obj_kugel_6,0
              DC.W 624/SC_obj_kugel_6,-1080/SC_obj_kugel_6,-721/SC_obj_kugel_6,0