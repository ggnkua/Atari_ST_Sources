/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
/* ::::::::::::::::::::       e v e n t         :::::::::::::::::::: */
/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
/* 
 * Headerdatei fr die Funktionen aus evnt_lib. Sie enth„lt die dafr
 * notwendigen Strukturen und Konstanten-, Makrodefinitionen
 * 
 */

/* Version 2.0 vom 1. August 1991
 * (c) 1990 by Volker Nawrath
 */


/* Struktur fr die šbergabewerte an v_event()
 * ------------------------------------------- */
typedef struct evnt
{
        int     event;          /* Ereignisse, die berwacht werden */
        int     clicks;         /* Anzahl der erforderl. Mausklicks */
        int     button;         /* Mausknopf, der berwacht wird    */
        int     state;          /* erwarteter Mausknopfzustand:
                                 * 0=gedrckt / 1=nicht gedrckt    */
        int     m1inout;        /* 1. Mausereignis fr Rechteck:
                                 * 0 = warten bis im Rechteck
                                 * 1 = warten bis auáerhalb Rechteck*/
        Rect    rectangle1;     /* Rechteck fr 1. Mausereignis     */
        int     m2inout;        /* 2.Mausereignis                   */
        Rect    rectangle2;     /* Rechteck fr 2. Mausereignis     */
        int     lowtime;        /* unteres Wort fr Zeitintervall   */
        int     hightime;       /* oberes Wort fr Zeitintervall    */
} EVNT;


/* Struktur fr die Rckgabewerte von v_event()
 * -------------------------------------------- */
typedef struct evnt_return
{
        int     event;          /* eingetretenes Ereignis           */
        int     buffer[8];      /* Speicher fr AES Meldungen       */
        int     fl_menu;        /* 1 = Menu-Ereignis, ansonsten 0   */
        int     fl_acc;         /* 1 = Acc-Ereignis, ansonsten 0    */
        int     fl_window;      /* 1 = Window-Ereignis, ansonsten 0 */
        int     mouse_x;        /* X-Koordinate des Mauszeigers     */
        int     mouse_y;        /* Y-Koordinate des Mauszeigers     */
        int     mouse_b;        /* Mausknopfzustand bei Ereignis    */
        int     mouse_k;        /* Zustand der CTRL-,ALT-,Shifttaste*/
        int     times;          /* Anzahl, wie of Mausknopf gedrckt*/
        int     key;            /* Code der gedrckten Taste        */
        int     low_key;        /* Low-Byte des Tastencodes;        */
        int     high_key;       /* High-Byte der Taste = Scancode   */
        int     fl_alpha;       /* 1 = alphabetisch, ansonsten 0    */
        int     fl_alphanum;    /* 1 = alphanumerisch, ansonsten 0  */
        int     fl_num;         /* 1 = numerisch, ansonsten 0       */
        int     fl_zifferbl;    /* 1 = Ziffernblock                 */
        int     fl_crsrpos;     /* 1 = Crsrposition., ansonsten 0   */
        int     fl_crsrtast;    /* 1 = Cursortaste, ansonsten 0     */
        int     fl_fkttast;     /* 1 = Funktionstaste, ansonsten 0  */
        int     fl_sonstig;     /* 1 = sonstige Taste, ansonsten 0  */
} EVNT_RETURN;




/* Tastaturcodes fr den ATARI (1040, Mega, STE, TT)
 * ------------------------------------------------- */
/* 
 * (a) Buchstaben/Zahlen        = K_<buchstabe>
 * (b) Ziffernblock             = KZ_<zeichen>
 * (c) Funktionstasten          = K_<f1-f10>    -> ohne SHIFT-Taste
 * (d) Cursorsteuerung          = KC_<taste>
 * (e) Sonderzeichen            = KX_<taste>
 *
 * Bei einigen Tasten „ndert sich der Scancode, wenn eine Zusatztaste
 * gedrckt wurde. Der Prefix lautet dann:      - KA  = Alternate
 *                                              - KS  = Shift
 *                                              - KCT = Control
 */
 
/* Buchstaben und Zahlen
 * --------------------- */
#define K_a     30
#define K_b     48
#define K_c     46
#define K_d     32
#define K_e     18
#define K_f     33
#define K_g     34
#define K_h     35
#define K_i     23
#define K_j     36
#define K_k     37
#define K_l     38
#define K_m     50
#define K_n     49
#define K_o     24
#define K_p     25
#define K_q     16
#define K_r     19
#define K_s     31
#define K_t     20
#define K_u     22
#define K_v     47
#define K_w     17
#define K_x     45
#define K_y     44
#define K_z     21
#define K_ae    40      /* „                    */
#define K_oe    39      /* ”                    */
#define K_ue    26      /*                     */
#define K_sz    12      /*                     */
#define KA_sz   -126    /* <ALT>               */
#define K_1     2
#define K_2     3
#define K_3     4
#define K_4     5
#define K_5     6
#define K_6     7
#define K_7     8
#define K_8     9
#define K_9     10
#define K_0     11
#define KA_1    120     /* Die folgenden Scancodes fr die Ziffern */
#define KA_2    121     /* 1-0 treten beim Drcken der Alternate-  */
#define KA_3    122     /* taste auf                               */
#define KA_4    123     /* I */
#define KA_5    124     /* I */
#define KA_6    125     /* I */
#define KA_7    126     /* I */
#define KA_8    127     /* I */
#define KA_9    -128    /* I */
#define KA_0    -127    /* Y */

/* Ziffernblock
 * ------------ */
#define KZ_1            109
#define KZ_2            110
#define KZ_3            111
#define KZ_4            106
#define KZ_5            107
#define KZ_6            108
#define KZ_7            103
#define KZ_8            104
#define KZ_9            105
#define KZ_0            112
#define KZ_plus         78      /* +            */
#define KZ_punkt        113     /* .            */
#define KZ_minus        74      /* -            */
#define KZ_klauf        99      /* (            */
#define KZ_klzu         100     /* )            */
#define KZ_strich       101     /* /            */
#define KZ_mult         102     /* *            */

/* Funktionstasten
 * --------------- */
#define K_f1    59
#define K_f2    60
#define K_f3    61
#define K_f4    62
#define K_f5    63
#define K_f6    64
#define K_f7    65
#define K_f8    66
#define K_f9    67
#define K_f10   68
#define KS_f1   84
#define KS_f2   85
#define KS_f3   86
#define KS_f4   87
#define KS_f5   88
#define KS_f6   89
#define KS_f7   90
#define KS_f8   91
#define KS_f9   92
#define KS_f10  93

/* Cursorsteuerung
 * --------------- */
#define KC_return       28              /* Return-Taste         */
#define KC_enter        114             /* Enter-Taste          */
#define KC_crsrup       72              /* Cursor nach oben     */
#define KC_crsrdown     80              /* Cursor nach unten    */
#define KC_crsrright    77              /* Cursor nach rechts   */
#define KCT_crsrright   116             /* <CTRL> Cursor rechts */
#define KC_crsrleft     75              /* Cursor nach links    */
#define KCT_crsrleft    115             /* <CTRL> Cursor links  */
#define KC_delete       83              /* Delete-Taste         */
#define KC_insert       82              /* Insert-Taste         */
#define KC_home         71              /* Home-Taste           */
#define KCT_home        119             /* <CTRL> Home-Taste    */
#define KC_backspace    14              /* BACKSPACE-Taste      */
#define KC_tab          15              /* Tabulator-Taste      */
#define KC_space        57              /* Leertaste            */

/* Sonderzeichen
 * ------------- */
#define KX_esc          1       /* ESC          */
#define KX_akz          13      /* '            */
#define KA_akz          -125    /* <ALT> '      */
#define KX_nr           41      /* #            */
#define KX_plus         27      /* +            */
#define KX_klei         96      /* <            */
#define KX_komma        51      /* ,            */
#define KX_punkt        52      /* .            */
#define KX_minus        53      /* -            */
#define KX_tilde        43      /* ~            */
#define KX_bslash	26	/* \		*/
#define KX_undo		97	/* Undo		*/
#define KX_help		98	/* Help		*/


/* Makros fr den EVENT-Manager
 * ============================ */

/* Ereignisse
 * ---------- */
#define EVNT_KEYBD()  (((event_return.event & 0x01) == 0x01)?1:0)
#define EVNT_BUTTON() (((event_return.event & 0x02) == 0x02)?1:0)
#define EVNT_M1()     (((event_return.event & 0x04) == 0x04)?1:0)
#define EVNT_M2()     (((event_return.event & 0x08) == 0x08)?1:0)
#define EVNT_MESAG()  (((event_return.event & 0x10) == 0x10)?1:0)
#define EVNT_TIMER()  (((event_return.event & 0x20) == 0x20)?1:0)

/* Zustand CTRL-,ALT- und Shifttasten
 * ---------------------------------- */
#define EVNT_RSHIFT() (((event_return.mouse_k & 0x01) == 0x01)?1:0)
#define EVNT_LSHIFT() (((event_return.mouse_k & 0x02) == 0x02)?1:0)
#define EVNT_SHIFT()  ((EVNT_LSHIFT() || EVNT_RSHIFT())?1:0)
#define EVNT_CTRL()   (((event_return.mouse_k & 0x04) == 0x04)?1:0)
#define EVNT_ALT()    (((event_return.mouse_k & 0x08) == 0x08)?1:0)

/* Tastaturabfragemakros; So werden langatmige Abfragen auf den
 * des EVENT-Managers vermieden
 * ------------------------------------------------------------- */
#define	KEY_a()	((event_return.high_key == K_a)?1:0)
#define	KEY_b()	((event_return.high_key == K_b)?1:0)
#define	KEY_c()	((event_return.high_key == K_c)?1:0)
#define	KEY_d()	((event_return.high_key == K_d)?1:0)
#define	KEY_e()	((event_return.high_key == K_e)?1:0)
#define	KEY_f()	((event_return.high_key == K_f)?1:0)
#define	KEY_g()	((event_return.high_key == K_g)?1:0)
#define	KEY_h()	((event_return.high_key == K_h)?1:0)
#define	KEY_i()	((event_return.high_key == K_i)?1:0)
#define	KEY_j()	((event_return.high_key == K_j)?1:0)
#define	KEY_k()	((event_return.high_key == K_k)?1:0)
#define	KEY_l()	((event_return.high_key == K_l)?1:0)
#define	KEY_m()	((event_return.high_key == K_m)?1:0)
#define	KEY_n()	((event_return.high_key == K_n)?1:0)
#define	KEY_o()	((event_return.high_key == K_o)?1:0)
#define	KEY_p()	((event_return.high_key == K_p)?1:0)
#define	KEY_q()	((event_return.high_key == K_q)?1:0)
#define	KEY_r()	((event_return.high_key == K_r)?1:0)
#define	KEY_s()	((event_return.high_key == K_s)?1:0)
#define	KEY_t()	((event_return.high_key == K_t)?1:0)
#define	KEY_u()	((event_return.high_key == K_u)?1:0)
#define	KEY_v()	((event_return.high_key == K_v)?1:0)
#define	KEY_w()	((event_return.high_key == K_w)?1:0)
#define	KEY_x()	((event_return.high_key == K_x)?1:0)
#define	KEY_y()	((event_return.high_key == K_y)?1:0)
#define	KEY_z()	((event_return.high_key == K_z)?1:0)
#define KEY_ae() ((event_return.high_key == K_ae)?1:0)
#define KEY_oe() ((event_return.high_key == K_oe)?1:0)
#define KEY_ue() ((event_return.high_key == K_ue)?1:0)
#define KEY_asz() ((event_return.high_key == KA_sz)?1:0)
#define KEY_nsz() ((event_return.high_key == K_sz)?1:0)
#define KEY_sz()  ((KEY_asz() || KEY_nsz())?1:0)

#define	KEY_n1() ((event_return.high_key == K_1)?1:0)
#define	KEY_n2() ((event_return.high_key == K_2)?1:0)
#define	KEY_n3() ((event_return.high_key == K_3)?1:0)
#define	KEY_n4() ((event_return.high_key == K_4)?1:0)
#define	KEY_n5() ((event_return.high_key == K_5)?1:0)
#define	KEY_n6() ((event_return.high_key == K_6)?1:0)
#define	KEY_n7() ((event_return.high_key == K_7)?1:0)
#define	KEY_n8() ((event_return.high_key == K_8)?1:0)
#define	KEY_n9() ((event_return.high_key == K_9)?1:0)
#define	KEY_n0() ((event_return.high_key == K_0)?1:0)
#define	KEY_a1() ((event_return.high_key == KA_1)?1:0)
#define	KEY_a2() ((event_return.high_key == KA_2)?1:0)
#define	KEY_a3() ((event_return.high_key == KA_3)?1:0)
#define	KEY_a4() ((event_return.high_key == KA_4)?1:0)
#define	KEY_a5() ((event_return.high_key == KA_5)?1:0)
#define	KEY_a6() ((event_return.high_key == KA_6)?1:0)
#define	KEY_a7() ((event_return.high_key == KA_7)?1:0)
#define	KEY_a8() ((event_return.high_key == KA_8)?1:0)
#define	KEY_a9() ((event_return.high_key == KA_9)?1:0)
#define	KEY_a0() ((event_return.high_key == KA_0)?1:0)
#define	KEY_z1() ((event_return.high_key == KZ_1)?1:0)
#define	KEY_z2() ((event_return.high_key == KZ_2)?1:0)
#define	KEY_z3() ((event_return.high_key == KZ_3)?1:0)
#define	KEY_z4() ((event_return.high_key == KZ_4)?1:0)
#define	KEY_z5() ((event_return.high_key == KZ_5)?1:0)
#define	KEY_z6() ((event_return.high_key == KZ_6)?1:0)
#define	KEY_z7() ((event_return.high_key == KZ_7)?1:0)
#define	KEY_z8() ((event_return.high_key == KZ_8)?1:0)
#define	KEY_z9() ((event_return.high_key == KZ_9)?1:0)
#define	KEY_z0() ((event_return.high_key == KZ_0)?1:0)
#define	KEY_1()  ((KEY_n1() || KEY_a1() || KEY_z1())?1:0)
#define	KEY_2()  ((KEY_n2() || KEY_a2() || KEY_z2())?1:0)
#define	KEY_3()  ((KEY_n3() || KEY_a3() || KEY_z3())?1:0)
#define	KEY_4()  ((KEY_n4() || KEY_a4() || KEY_z4())?1:0)
#define	KEY_5()  ((KEY_n5() || KEY_a5() || KEY_z5())?1:0)
#define	KEY_6()  ((KEY_n6() || KEY_a6() || KEY_z6())?1:0)
#define	KEY_7()  ((KEY_n7() || KEY_a7() || KEY_z7())?1:0)
#define	KEY_8()  ((KEY_n8() || KEY_a8() || KEY_z8())?1:0)
#define	KEY_9()  ((KEY_n9() || KEY_a9() || KEY_z9())?1:0)
#define	KEY_0()  ((KEY_n0() || KEY_a0() || KEY_z0())?1:0)

#define KEY_esc()    ((event_return.high_key == KX_esc)?1:0)
#define KEY_nstrich() (((event_return.high_key == K_7) && EVNT_SHIFT())?1:0)
#define KEY_zstrich() (((event_return.high_key == KZ_strich))?1:0)
#define KEY_strich()  ((KEY_nstrich() || KEY_zstrich())?1:0)
#define KEY_nklauf() (((event_return.high_key == K_8) && EVNT_SHIFT())?1:0)
#define KEY_zklauf() (((event_return.high_key == KZ_klauf))?1:0)
#define KEY_klauf()  ((KEY_nklauf() || KEY_zklauf())?1:0)
#define KEY_nklzu()  (((event_return.high_key == K_9) && EVNT_SHIFT())?1:0)
#define KEY_zklzu()  (((event_return.high_key == KZ_klzu))?1:0)
#define KEY_klzu()   ((KEY_nklzu() || KEY_zklzu())?1:0)
#define KEY_akz()    ((event_return.high_key == KX_akz)?1:0)
#define KEY_nr()     ((event_return.high_key == KX_nr)?1:0)
#define KEY_nplus()  ((event_return.high_key == KX_plus)?1:0)
#define KEY_zplus()  ((event_return.high_key == KZ_plus)?1:0)
#define KEY_plus()   ((KEY_nplus() || KEY_zplus())?1:0)
#define KEY_nmult()  (((event_return.high_key==KX_plus)&&EVNT_SHIFT())?1:0)
#define KEY_zmult()  ((event_return.high_key == KZ_mult)?1:0)
#define KEY_mult()   ((KEY_nmult() || KEY_zmult())?1:0)
#define KEY_tilde()  ((event_return.high_key == KX_tilde)?1:0)
#define KEY_klei()   ((event_return.high_key == KX_klei)?1:0)
#define KEY_komma()  ((event_return.high_key == KX_komma)?1:0)
#define KEY_npunkt() ((event_return.high_key == KX_punkt)?1:0)
#define KEY_zpunkt() ((event_return.high_key == KZ_punkt)?1:0)
#define KEY_punkt()  ((KEY_npunkt() || KEY_zpunkt())?1:0)
#define KEY_nminus() ((event_return.high_key == KX_minus)?1:0)
#define KEY_zminus() ((event_return.high_key == KZ_minus)?1:0)
#define KEY_minus()  ((KEY_nminus() || KEY_zminus())?1:0)

#define KEY_nreturn()   ((event_return.high_key == KC_return)?1:0)
#define KEY_zreturn()	((event_return.high_key == KC_enter)?1:0)
#define KEY_return()	((KEY_nreturn() || KEY_zreturn())?1:0)
#define KEY_crsrdown()  ((event_return.high_key == KC_crsrdown)?1:0)
#define KEY_crsrup()    ((event_return.high_key == KC_crsrup)?1:0)
#define KEY_ccrsrleft() ((event_return.high_key == KCT_crsrleft)?1:0)
#define KEY_ncrsrleft() ((event_return.high_key == KC_crsrleft)?1:0)
#define KEY_crsrleft()  ((KEY_ccrsrleft() || KEY_ncrsrleft())?1:0)
#define KEY_ccrsrright() ((event_return.high_key == KCT_crsrright)?1:0)
#define KEY_ncrsrright() ((event_return.high_key == KC_crsrright)?1:0)
#define KEY_crsrright()  ((KEY_ccrsrright() || KEY_ncrsrright())?1:0)
#define KEY_delete()    ((event_return.high_key == KC_delete)?1:0)
#define KEY_insert()    ((event_return.high_key == KC_insert)?1:0)
#define KEY_nhome()     ((event_return.high_key == KC_home)?1:0)
#define KEY_chome()     ((event_return.high_key == KCT_home)?1:0)
#define KEY_home()      ((KEY_nhome() || KEY_chome())?1:0)
#define KEY_help()      ((event_return.high_key == KX_help)?1:0)
#define KEY_undo()      ((event_return.high_key == KX_undo)?1:0)
#define KEY_backspace() ((event_return.high_key == KC_backspace)?1:0)
#define KEY_tab()       ((event_return.high_key == KC_tab)?1:0)
#define KEY_space()     ((event_return.high_key == KC_space)?1:0)

#define KEY_nf1()	((event_return.high_key == K_f1)?1:0)
#define KEY_nf2()	((event_return.high_key == K_f2)?1:0)
#define KEY_nf3()	((event_return.high_key == K_f3)?1:0)
#define KEY_nf4()	((event_return.high_key == K_f4)?1:0)
#define KEY_nf5()	((event_return.high_key == K_f5)?1:0)
#define KEY_nf6()	((event_return.high_key == K_f6)?1:0)
#define KEY_nf7()	((event_return.high_key == K_f7)?1:0)
#define KEY_nf8()	((event_return.high_key == K_f8)?1:0)
#define KEY_nf9()	((event_return.high_key == K_f9)?1:0)
#define KEY_nf10()	((event_return.high_key == K_f10)?1:0)
#define KEY_sf1()	((event_return.high_key == KS_f1)?1:0)
#define KEY_sf2()	((event_return.high_key == KS_f2)?1:0)
#define KEY_sf3()	((event_return.high_key == KS_f3)?1:0)
#define KEY_sf4()	((event_return.high_key == KS_f4)?1:0)
#define KEY_sf5()	((event_return.high_key == KS_f5)?1:0)
#define KEY_sf6()	((event_return.high_key == KS_f6)?1:0)
#define KEY_sf7()	((event_return.high_key == KS_f7)?1:0)
#define KEY_sf8()	((event_return.high_key == KS_f8)?1:0)
#define KEY_sf9()	((event_return.high_key == KS_f9)?1:0)
#define KEY_sf10()	((event_return.high_key == KS_f10)?1:0)
#define KEY_f1()	((KEY_nf1() || KEY_sf1())?1:0)
#define KEY_f2()	((KEY_nf2() || KEY_sf2())?1:0)
#define KEY_f3()	((KEY_nf3() || KEY_sf3())?1:0)
#define KEY_f4()	((KEY_nf4() || KEY_sf4())?1:0)
#define KEY_f5()	((KEY_nf5() || KEY_sf5())?1:0)
#define KEY_f6()	((KEY_nf6() || KEY_sf6())?1:0)
#define KEY_f7()	((KEY_nf7() || KEY_sf7())?1:0)
#define KEY_f8()	((KEY_nf8() || KEY_sf8())?1:0)
#define KEY_f9()	((KEY_nf9() || KEY_sf9())?1:0)
#define KEY_f10()	((KEY_nf10() || KEY_sf10())?1:0)

