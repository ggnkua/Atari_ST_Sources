/* Anzahl der Hotkeys */
#define KEYS 90

/* Anzahl der SETTINGS in 2-Bytes */
#define SETTINGS 1733   /* Wegen Fehler immer eins weniger */

#define NOTUSED 69 /* Code fr unbenutzte Taste */

#define andereausblend wincom->e1
#define alleeinblend wincom->e2
#define autokey wincom->e3
#define aufraeumen wincom->e4
#define aktuelleausblend wincom->e5
#define appwechsel wincom->e6
#define kmemory wincom->e7
#define krecall wincom->e8
#define winclose wincom->e9
#define winfull wincom->e10
#define wincycle wincom->e11
#define aup wincom->e12
#define adown wincom->e13
#define aleft wincom->e14
#define aright wincom->e15
#define pup wincom->e16
#define pdown wincom->e17
#define pleft wincom->e18
#define pright wincom->e19
#define winbcycle wincom->e20
#define appbwechsel wincom->e21
#define apptopped wincom->e22

#define accopen1  wincom->e23
#define accopen2  wincom->e24
#define accopen3  wincom->e25
#define accopen4  wincom->e26
#define accopen5  wincom->e27
#define accopen6  wincom->e28

#define emergency wincom->e29

#define cut wincom->e30
#define copy wincom->e31
#define paste wincom->e32

#define accopen7  wincom->e33
#define accopen8  wincom->e34
#define accopen9  wincom->e35
#define accopen10 wincom->e36

#define mem1 wincom->e37
#define mem2 wincom->e38
#define mem3 wincom->e39
#define mem4 wincom->e40
#define mem5 wincom->e41
#define mem6 wincom->e42
#define mem7 wincom->e43
#define mem8 wincom->e44
#define mem9 wincom->e45
#define mem10 wincom->e46
#define smem1 wincom->e47
#define smem2 wincom->e48
#define smem3 wincom->e49
#define smem4 wincom->e50
#define smem5 wincom->e51
#define smem6 wincom->e52
#define smem7 wincom->e53
#define smem8 wincom->e54
#define smem9 wincom->e55
#define smem10 wincom->e56

#define toppingmode wincom->e57
#define rolladen    wincom->e58
#define vfuller     wincom->e59

#define	alleausblend wincom->e60
#define mouse_auto wincom->e61
#define mouse_off wincom->e62
#define mouse_on wincom->e63

#define accpop wincom->e64

#define	masterkey wincom->e65

#define s1 wincom->e66
#define s2 wincom->e67
#define s3 wincom->e68
#define s4 wincom->e69
#define s5 wincom->e70
#define s6 wincom->e71
#define s7 wincom->e72
#define s8 wincom->e73
#define s9 wincom->e74
#define s10 wincom->e75

#define	bottom	wincom->e76

#define globalcycle wincom->e77

#define iconify wincom->e78
#define alliconify wincom->e79
#define uniconify wincom->e80

#define s11 wincom->e81
#define s12 wincom->e82
#define s13 wincom->e83
#define s14 wincom->e84
#define s15 wincom->e85
#define s16 wincom->e86
#define s17 wincom->e87
#define s18 wincom->e88
#define s19 wincom->e89
#define s20 wincom->e90

/* Nicht vergessen: KEYS (oben) „ndern */
#define STARTKEYS 20

typedef struct
{
	int   filter;   /* Filter: Bit 0=verwendete Tasten aus Liste */
									/* (s.u.) filtern. Bit 1=alle Tasten filtern */
									/* šber Bit 2 zeigt WinCom an nach auen an, */
									/* da gerade ein Echtzeitaktion durchgefhrt*/
									/* wird */
									/* Bit 3=WinCom steht (Registrierung) */
	int   num;      /* Anzahl der Eintr„ge (MINDESTENS 1!)*/
	int   e1;       /* Die Eintr„ge selbst */
	int   e2;       /* Zur Zeit 19 fr Automatik, andere ausblenden */
	int   e3;       /*  diese ausblenden, alle einblenden  */
	int   e4;       /*  aufr„umen, APP-Wechsel, Memory, Recall*/
	int   e5;       /*  Closer, Fuller, Cycle, Arrows , Pager*/
	int   e6;       /* nicht benutzte Eintr„ge=$FFFF   */
	int   e7;
	int   e8;
	int   e9;
	int   e10;
	int   e11;
	int   e12;
	int   e13;
	int   e14;
	int   e15;
	int   e16;
	int   e17;
	int   e18;
	int   e19;
	int   e20;
	int   e21;
	int   e22;
	int   e23;
	int   e24;
	int   e25;
	int   e26;
	int   e27;
	int   e28;
	int   e29;
	int   e30;
	int   e31;
	int   e32;
	int   e33;
	int   e34;
	int   e35;
	int   e36;
	int   e37;
	int   e38;
	int   e39;
	int   e40;
	int   e41;
	int   e42;
	int   e43;
	int   e44;
	int   e45;
	int   e46;
	int   e47;
	int   e48;
	int   e49;
	int   e50;
	int   e51;
	int   e52;
	int   e53;
	int   e54;
	int   e55;
	int   e56;
	int   e57;
	int   e58;
	int   e59;
	int		e60;
	int		e61;
	int		e62;
	int		e63;
	int		e64;
	int		e65;
	int   e66;
	int   e67;
	int   e68;
	int   e69;
	int		e70;
	int		e71;
	int		e72;
	int		e73;
	int		e74;
	int		e75;
	int		e76;
	int		e77;
	int		e78;
	int		e79;
	int		e80;
	int		e81;
	int		e82;
	int		e83;
	int		e84;
	int		e85;
	int		e86;
	int		e87;
	int		e88;
	int		e89;
	int		e90;
	int   version;  /* Versionsnummer. 10=1.0 11=1.1 etc.. */
	long  date;     /* NEU AB 1.2 */
	int   settings; /* NEU AB 10.9.94 Anzahl der folgenden Einst.*/
	int   dmcall;   /* NEU AB 1.2 1.Taste Mem-Call*/
	int   dmset;    /* NEU AB 1.2 1.Taste Mem-Set*/
	int   dacall;   /* NEU AB 1.2 1.Taste ACC-Call*/
									/* Wartezeiten in 10tel Sekunden: */
	int   mxnewtop; /* Max. Wartezeit fr newtop (bei aktuelle ausbl.)*/
	int   mxmoved;  /* Max. Wartezeit fr moved 1-10*/
	int   mxsized;  /* Max. Wartezeit fr sized 1-10*/
	int   mxcheckw; /* Max. Checks nach Winaction */
	int   mxstclick;/* Verz”gerung nach erstem ARROW-Rechtsklick */
	int   mxhdclick;/* Verz”gerung fr ARROW-Hold (je 1-10)*/
	
	int   igsize;   /* Sizer fr Rolladen ignorieren? */
	int   membell;  /* Klingeln bei Memorize */

	int   topmode;  /* Modus fr Topping */
	int   mxtop;    /* Wartezeit fr toppen */
	int   kbnotop;  /* Shift-tasten fr nicht-toppen */

	int   automatik;/* Automatik an/aus */
	int   appendmode; /* Appendmode an/aus */
	int   notopmode;  /* Eine (0) oder alle (1) kbnotop fr notop */
	int   altfunc;    /* Fuller-Func bei Alt (1=Roll, 0=VFull) */

	int   screenguard; /* Screen-W„chter ein/aus (nicht mehr benutzt)*/

	int   name[13];   /* Name */
	int   key[6];     /* Schlssel */
	int   reg_ok;     /* Eintrag gltig */

	int		automouse;	/* Maus automatisch an/aus */
	int		all_one;		/* Beim Backdroppen alle(0)next(1)last(2)toppen */
	int		run;				/* WinCom on(1) oder off(0) via Masterkey */

	char	paths[1600];/* Pfade und CMD-Zeilen je 80 Zeichen */

	int		minmin;			/* 0=normal, 1=Keymin, 2=mousmin, 3=bothmin */
	int		msaction;		/* mindest-Bewegung fr Topping */

	int		w_reverse;	/* Echtzeitbedienung rechts(0) oder links(1) */
	int		b_dropper;	/* MagiC-Backroppper ist an(1) oder aus(0) */
	int		hide_it;		/* Beim Auto-Topping verdecken (1) oder nit (0) */
	int		backtop;		/* Rechtstoppen mit Alt(0) oder CTRL(1) */
	int		dt_mouse;		/* Dials to mouse (1) oder nicht (0) */
	int		desk_on;		/* Alle ausblenden->Desktop Men an (1) oder nicht (0) */
	int		no_rightalt;/* Alt-Rechtsklick durchlassen (0) oder nicht (1) */
	int		w_pager;		/* Direkt-Pos. mit links(1) oder rechts(0) */
	
	int		snap_x;			/* Raster horizontal */
	int		snap_y;			/* Raster vertikal */
	
	int		notop_wobj;	/* Auf Fensterelementen kein Auto-Topping */
	
	char	no_tswitch[160]; /* 16 Ausnahme-Apps fr Taskswitch */
	
	char 	paths2[1600]; /* Pfade und CMD-Zeilen fr starter 11-20 */
/* SETTINGS nicht vergessen!! */

	int   sleep;    /* Wird von externem Programm gesetzt */
	int   confirm;  /* Wird von WINCOM best„tigt */
	int   keycode;  /* Enth„lt ikbs w„hrend sleep, mu von externem */
	int   keygot;   /* Wird von WINCOM auf 1 gesetzt, wenn neuer Eintrag*/
	int   setprg;   /* Wird von WinSet benutzt, um Anwesenheit fr */
									/* ein 2. WinSet zu zeigen */
}XKEYGET;


