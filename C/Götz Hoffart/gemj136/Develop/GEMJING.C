/*
  GEMJing
  (c) by Gîtz Hoffart, Rheinstetten. Alle Rechte vorbehalten.
  E-Mail: Gîtz Hoffart @ FR (MausNet)
          goetz@hoffart.de (Internet)
  Web:    http://www.hoffart.de/
          http://www.nogfradelt.de/

  V.0.1û:	24.07.96		o erste Version
  V.0.2û:r	28.07.96		o Abspielen lÑuft per VA_START
  V.0.3û:	29.07.96		o Abspielen per Fileselektor
								o mehr Sicherheitsabfragen
  V.0.4:r	19.08.96		o Infodialog wg. Problemen wieder raus
								o zusÑtzliche MiNT/MagX-Cookie-Abfrage wg. Mxalloc-Speicherschutzbits
								o Kommandozeilenoption "-q" wird unterstÅtzt (wg. Texel)
  V.0.5:		20.08.96		o Stellt auf Thomas' Wunsch hin bei Parameter -mq keine MenÅzeile mehr dar
  V.0.51:r	24.08.96    o Testet nun auch auf argv[1], nicht nur auf [2] :-)
            			      FÅhrte unter Nicht-MagiCMac auf 68040 zu Bomben.
  V.0.52û:	25.08.96		o Supexec() statt Super()
								o Fxattr(), wenn vorhanden, fÅr DateilÑngenermittlung
  V.0.53:	28.08.96		o Was einem unter MagiCMac nicht auffÑllt: gab's da doch tatsÑchlich einen Adreû-
									fehler auf non-MagiCMac-Systemen (vergessen, eine Zeile auszukommentieren). Ab
									jetzt wird auch auf einem 520ST getestet, versprochen - er lÑuft wieder.
  V.0.53:	29.08.96		o statt wind_update() gibt's nun menu_ienable().
  V.0.60:r	31.08.96		o Grîûere öberarbeitung
								o kein "-mq" mehr (wird von "-q" erledigt),
								o kein VA_START mit "-q" mehr
								o 6.5kB Speicher gespart (Malloc() statt calloc()).
								o Bei "-q" öbergabe keine AES/GEM-Anmeldung mehr, kein rsrc_load etc.
  V.0.61:r	04.09.96		o Neue EMail-Adressen
								o -q bei VA_START geht wieder (kÅrzer),
								o NULL bei VA_START wird abgefangen.
  V.0.64:r	17.09.96		o Aktive UnterstÅtzung von WeirdMac 0.64
								o dadurch freie Samplefrequenzwahl
								o etwas toleranter gegenÅber fehlerhaften Windows-WAVEs
								o zusÑtzliche Abfrage auf Cookie von MSND und WeirdMac drin wegen
									seltsamen Verhaltens der beiden
  V.0.65:r	18.09.96		o nun gibt's Alert-Fehlermeldungen, wenn das AuswÑhlen des Samples
									per Fileselector erfolgte (und nur dann!).
								o 0,5kB Speicher gespart
  V.0.66: 18.09.96		o GEMJing gibt bei Start per Kommandozeile mit Option -q nun einen
									Returncode zurÅck (siehe GEMJing-Returnmessage).
								o etwas Speicher gespart
  V.0.67:r	01.10.96		o totale interne Umstrukturierung :-)
									Vorteile: leichte(re)s Einbinden neuer Formate, schnellere Laderoutine
				03.12.96		o McSn wird auch dann benutzt, wenn HSND da ist.
				10.12.96		o StIc-UnterstÅtzung
				21.12.96		o neue Kommandooptionen:
									-d x    Delay von x Sekunden zw. wiederholten Samples
									-r x    Repeat x-mal
				30.01.97		o endlich blîden Bug bei der Hardwareerkennung gefunden. Dank an Holger
									Weets fÅr das DrÑngen und Anders Henke fÅr den sinnlosen Anruf.
  V.0.69r	20.02.97		o -r und -d funktionieren jetzt endlich /richtig/
				26.02.97		o VA_START-Bug beseitigt
  V.0.70r	27.02.97		o GEMJing ist 8kB kleiner und braucht 7kB weniger RAM
				04.03.97		o statt GEMJING.RSC wird gemjing.rsc geladen
  V.0.71r	08.03.97		o TT-Abspielbug beseitigt, PSG
								o GEMJing spielt auf dem Hades060: CETiK 97 Edition!
								o menu_register-Abfrage geÑndert  
								o erste Version auf der Homepage
  V.0.72		11.03.97		o Vorbereitungen fÅr HSN und SMP-Samples
								o statt GEMJING.HYP wird gemjing.hyp geladen
  V.1.00r	24.03.97		o erste Åber ASH verîffentlichte Version
  V.1.01		23.04.97		o Englische Version :-)
  .			13.05.97		o sleep als evnt_timer-Ersatz fÅr TTP-Start
  .			17.05.97		o GEMScript, Versuch Nummer eins
  V.1.02		18.05.97		o GEMScript, Kommando "OPEN" wird theoretisch verstanden
								o OLGA-Server-FunktionalitÑt eingebaut
								o appl_getinfo -> shel_write(9, ...) fÅr AP_TERM
				22.05.97		o OLE_EXIT eingebaut
  V.1.03r	02.06.97		o OLGA-Manager sollte nun auch unter MultiTOS & Co. nachgestartet werden
								o einige Verschlankungen: geringerer Speicherverbrauch
				12.06.97		o GS_COMMAND korrigiert, dank Alexander Bartons "GS-Test"
				27.06.97		o bîser Bug bei OLGA-Initialisierung raus -
									dank Olivier Booklage
				15.07.97r	o kleinere énderungen (Info-Dialog: Internet-Adresse)
	V.1.04	28.07.97		o GEMScript R.008 wird unterstÅtzt.
								o GEMScript-Kommando "QUIT" wird unterstÅtzt.
								o Bug bei KommandozeilenÅbergabe bei SingleTOS raus (Dank an Peter Melzer)
				30.07.97		o SCCS-Kennung eingebaut
				03.08.97		o GS_INFO-Extension korrigiert
				06.08.97		o Nullpointerkorrekturen: msg[3], msg[4]
				07.08.97û	o WDIALOG-Routinen rausgeworfen, sie werden nicht
								  mehr benîtigt.
				09.08.97		o AP-Term-Anmeldung korrigiert
								o Mfree am Ende des Spielens
				11.08.97û	o paar Bytes kleiner
								o Es wird nun unter N.AES und MagiC per Fselect gewartet,
								  unter SingleTOS mit sleep.
				29.08.97		o AV_SENDKEY eingebaut
	V.1.05	04.10.97		o Neuss-Messe-Release in den Sprachen:
								  Deutsch, Englisch, Franzîsisch, Spanisch,
								  Japanisch, Fidschi, Bishlamaro, Esperanto,
								  Latein.
	V.1.06REL15.10.97		o Versionsnummer wird direkt in den Dialog
								  eingetragen
								o Abbruchmîglichkeit wÑhrend Delay
								o TÅrkisch, Italienisch, Philippinisch
								o Env.var. GEMJINGPATH
				17.10.97		o Bugfixes bei AVR stereo
				28.10.97		o AV_STARTED direkt nach Umkopieren des Strings versenden
	V.1.10	97-12-01		o Shared-Lib-Versuch ("Ping-Lib" :-)
								o WAV-Einleseroutine chunkfester gemacht,
								  klappt ganz gut
								o GS_COMMAND-Code korrigiert, dank an Manfred Lippert
	V.1.20	98-03-17		o OLGA-Manager wird nicht mehr nachgestartet
								o -m-Parameter
				98-03-18		o GEMScript-Kommando MEMORYPLAY
								o AV_STARTED wird jetzt nach dem Abspielen verschickt, wg. "-m".
	V.1.21	98-03-31		o Kleinigkeiten geÑndert, Beta-Release
	V.1.25	98-04-04		o Neuss-Messe-Version
	V.1.26	98-04-10		o Parameter -p (CLI) eingebaut: keine MenÅzeile mehr, aber AES. FÅr Holger Weets.
	V.1.30	98-05-25		o o minor bugfixes (Falcon/MSND playing code)
                        o updated documentation
            98-05-29    o SMP: stupid bug found and removed. Thanks to Thorsten Otto.
   V.1.33   99-01-27		o GEMJing trîtet auch mit Liberty respektive Freedom 2
   							o Fileselektorbug mit alten SingleTOSsen hoffentlich behoben
	V.1.34	99-02-28		o Dudelt jetzt auch mit den StarTrack-Frequenzen, CETiK-Edition
	V.1.35	99-03-07		o Release mit Texel 2.20. Freedom2-Workaround erstmal wieder ausgebaut
	V.1.36   00-06-01    o Lizenz von Freeware auf Cat PL geÑndert, siehe Doku.
								o neuer Kommandozeilenparser von Dimitri Junker eingebaut
*/


/*
   
   Allgemein gilt: Dieser Code ist alt. Uralt. GEMJing fuût auf einem Programm
   namens PCM-Play, das ich (GH) in GFA-Basic anno 1991 schrieb, um auf meinem
   MegaSTE DMA-QualitÑt bei der Sampleausgabe zu erhalten. Das Programm wurde
   dann in MaxonPascal umgeschrieben, nach TurboC portiert, nach PurePascal
   portiert und wieder zurÅck nach PureC. Da beginnt die VersionszÑhlung, die
   oben aufgefÅhrt ist. Dementsprechend sieht der Code aus.
  
   Und nein, Steve Maguire kannte ich damals ganz offensichtlich noch nicht.
   
   Stellen, die ein "XXX" im Kommentar tragen, weisen darauf hin, daû hier
   entweder ein Bug sitzt oder vermutet wird, oder daû daran nochmals gearbeitet
   werden muû.
   
	gemjing.c		Hauptprogramm mit der OberflÑche
	gemjing.h		zugehîrig
	jingle.c			die eigentlichen Sample- und Konvertierroutinen, oberflÑchenlos
	jingle.h			Definitionen, die sowohl gemjing.c als auch jingle.c kennen mÅssen
	jingein.h		jingle.c-interne Definitionen
	snd.h				erweiterte Sounddefinitionen
	
	16to8.c			Code von Dirk Haun (danke, daû ich ihn mitverîffentlichen darf, Dirk),
						um eine qualitativ bessere 16 Bit nach 8 Bit Wandlung vorzunehmen.

	data.bin			Sprungtabelle, um gepackte Daten zu dekodieren, siehe jingle.c und
						suche nach "lookup". Leider scheint die Tabelle falsch zu sein,
						denn das Entpacken funktioniert hinten und vorne nicht. Oder ich war
						blind.
	data.h			Die Lookup-Tabelle als C-Include.

	samrouts.s		Die Assembler-Routinen von Jîrg Hahne, um auch auf'm ST sauber
	               abzuspielen. Dank der hervorragenden QualitÑt von Jîrgs Code
	               lÑuft das ganze ohne énderungen auch auf dem Hades und anderen
	               Clones, die PSG-Sound anbieten.
	samtab.i			Die Sprungtabellen fÅr samrouts.s als Include-File.
						(Anmerkung: samrouts.s und samtab.i sind von mir (GH) nachbearbeitet.
						Die Originalsourcen von Jîrg stecken in samrouts.src (TurboAss).)
	samrouts.h		Definitionen

	portabn.h		Eigene PORTAB.H-Definition, angelehnt an GEISS/GEISS.
						Muss im INCLUDE-Ordner liegen!
	error.h			Need to say more?
	olga.h			OLGA-Konstanten


	Bekannte UnzulÑnglichkeiten und Fehler, die sonst nirgends dokumentiert
	sind:

	- Spielt nicht mit Liberty 2 / Freedom 2. Liegt IMO an Freedom. Ein
	  Workaround ist aber nicht trivial, da die Cookie-Abfrage-Logik ge-
	  Ñndert werden mÅûte. Das ist aber heikel ...
	- Unzureichender GEMScript-Code, da er nur mit einem Akteur funktioniert.
	- ParameterÅbergabe mÅûte dringend renoviert werden. Die Arbeit habe
	  ich mir ewig gespart, da ich an einer MagiC-Shared-Library-Version
	  von GEMJing gearbeitet habe, die all den Kram nicht mehr braucht.	

   Gîtz Hoffart, 21.5.2000
   
*/


/*----------------------------------------------------------------------------------------*/ 
/* Globale Includes                                               */
/*----------------------------------------------------------------------------------------*/ 
#include	<tos.h>
#include	<vdi.h>
#include	<aes.h>
#include	<string.h>
#include	<stdlib.h>
#include	<stdio.h>
#include "error.h"
#include	<portabn.h>
#include	<ext.h>
#include	"olga.h"
/*----------------------------------------------------------------------------------------*/ 
/* Lokale Includes                                                */
/*----------------------------------------------------------------------------------------*/ 
#include "GEMJING.H"

#include "JINGLE.H"

char SCCS[]="@(#)GEMJing.prg V.1.36 (2000-06-01); (c) by Gîtz Hoffart, Rheinstetten (goetz@hoffart.de, Gîtz Hoffart @ FR). All rights reserved. GEMJing is a sample player that can be operated by other applications via remote-control.";

#define VERS_DATE_STR "13620000601"

NEWDEF neue_strct;
NEWDEF *new = &neue_strct;

/*----------------------------------------------------------------------------------------*/ 
/* Definitionen                                             			*/
/*----------------------------------------------------------------------------------------*/ 

#define MGLOBAL			0x20

#define VA_START			0x4711
#define AV_STARTED		0x4738
#define AV_SENDKEY		0x4710

#define GEMJING_RETURN	0x7407

#define GS_REQUEST		0x1350
#define GS_REPLY			0x1351
#define GS_COMMAND		0x1352
#define GS_ACK				0x1353
#define GS_QUIT			0x1354
#define GSM_COMMAND		0x001
#define GSCRIPT_VERSION	0x50
#define NO_GS_PARTNER	-777

/*----------------------------------------------------------------------------------------*/ 
/* globale Variablen                                                */
/*----------------------------------------------------------------------------------------*/ 

BOOLEAN	MultiTOS;
BOOLEAN	MagiC;
BOOLEAN	MagiCMac;
BOOLEAN	plain = FALSE;

WORD		app_id,
			aes_handle;

RSHDR		*rsh;
BYTE		**fstring_addr;

WORD		work_out[57];
WORD		exinput = FALSE;
WORD		vdi_handle;

OBJECT   *infodial;
OBJECT	*menu;

WORD		quit;

AESPB		aespb;

BYTE		*va_helpbuf = NULL;			/* ST-Guide */
BYTE		*gs_helpbuf = NULL;
BYTE		*args, *path, *name;			/* Filebuffer */

WORD		playing = FALSE;

WORD		gs_partner_id = NO_GS_PARTNER;		/* AES-ID des GEMScript-Partners */
WORD		gs_req_id = 0;
WORD		gs_bel_id = 0;

typedef	BYTE STRING[82];

/* OLGA */
typedef struct
{
  WORD    manager_id;
  BOOLEAN okay;
} MY_OLGA_STRCT;

/* GEMScript-Info */
typedef struct {
   long len;       /* LÑnge der Struktur in Bytes                      */
   int  version;   /* Versionsnummer des Protokolles beim Sender
                      (z.Z. 0x0080 = 0.80)                             */
   int  msgs;      /* Bitmap der unterstÅtzten Nachrichten (GSM_xxx)   */
   long ext;       /* benutzte Endung, etwa '.SIC'                     */
} GS_INFO;

MY_OLGA_STRCT olga;
GS_INFO *gsinfo;

/*----------------------------------------------------------------------------------------*/ 
/* Funktionsprototypen                                              */
/*----------------------------------------------------------------------------------------*/ 
WORD			open_screen_wk( WORD aes_handle, WORD *work_out );
VOID			init_rsrc( VOID );
/*----------------------------------------------------------------------------------------*/ 

VOID			do_events(VOID);
VOID			hdle_mesag(WORD *msg);
VOID			hdle_keybd(WORD key, WORD kstate);
VOID			handle_menu(WORD item, WORD *msg);
VOID			do_help(BYTE *pattern);
VOID			handle_play_error(WORD ret);

WORD			select_file(BYTE *path, BYTE *name);
WORD			file_exist(BYTE *name);
VOID			hide_menu_entries(VOID);
VOID			show_menu_entries(VOID);

VOID			do_stic(WORD flag); /* 1: Icon darstellen, 0: aus */
VOID			split_argumentline(NEWDEF *new, BYTE *args);
VOID			split_gs_line(NEWDEF *new, BYTE *args);

WORD			appl_xgetinfo (WORD type, WORD *out1, WORD *out2, WORD *out3, WORD *out4);

VOID			olga_init(VOID);
VOID			olga_exit(VOID);
WORD			get_avserver(VOID);

VOID			check_getinfo(VOID);

void call_aes(void);
int  form_xdo(OBJECT *tree, int startob, int *lastcrsr, void *tabs, void *flydial);
int  form_xdial(int flag, int ltx, int lty, int ltw, int lth, int bgx, int bgy, int bgw, int bgh, void **flydial);

VOID set_new_to_null(VOID)
{
	new->adr = NULL;
	new->end = NULL;
	new->len = 0L;
	new->header_len = 0L;
	new->sample_start = NULL;
	new->res = 0;
	new->frq = 0;
	new->channels = 0;
	new->fmt = 0;
	new->snd_system = 0;
 /* WORD    malloc_flag; */ 
	new->delayrate = 0;
	new->repeatrate = 0;   
	new->memoryplay = NULL;
	new->memoryplay_len = 0L;
	new->no_menu = FALSE;  
	new->gs_valid = FALSE;
	new->file = NULL;
}

/*----------------------------------------------------------------------------------------*/ 
/* Hauptprogramm                                                  */
/*----------------------------------------------------------------------------------------*/ 
WORD main(INT argc, BYTE *argv [])
{
	WORD  ret_code = -1;
	LONG  dummy;
	WORD  i;
	
	Pdomain(1);
	Psignal(SIGUSR1, handle_SIGUSR1);
	Psignal(SIGTERM, handle_SIGTERM);
	
	args = (BYTE*) Malloc(511L);
	name = (BYTE*) Malloc(511L);
	path = (BYTE*) Malloc(511L);

	if ((get_cookie(MagX_COOKIE, &dummy)==TRUE) || (get_cookie(MiNT_COOKIE, &dummy)==TRUE))
	{
		va_helpbuf = (BYTE *) Mxalloc(150,3|MGLOBAL);
		gs_helpbuf = (BYTE *) Mxalloc(sizeof(GS_INFO),3|MGLOBAL);
	}
	else
	{
		va_helpbuf = (BYTE *) Malloc(150);
		gs_helpbuf = (BYTE *) Malloc(sizeof(GS_INFO));
	}

	if (args == NULL || path == NULL || name == NULL || va_helpbuf == NULL || gs_helpbuf == NULL)
		return ENSMEM;
	
	args[0] = name[0] = va_helpbuf[0] = gs_helpbuf[0] = 0;
	path[0]=Dgetdrv()+65;path[1]=0;
	strcat(path, ":\\*.*");

	set_new_to_null();

	i = argc;
	if (i > 0)
	{
		while (i > 0)
		{
			i--;
			strcat(args, argv[i]);
			if (i > 1)
				strcat(args, " ");
		}
		split_argumentline(new, args);
	}

	check_getinfo();
	
	if (new->no_menu == TRUE)
		ret_code = spiele_sample(new);
	else
	{
		app_id = appl_init();             /* anmelden */
	
		if( app_id != -1 )
		{
			WORD dum;

			if ( (_GemParBlk.global[0] >= 0x140) || get_cookie(FSEL_COOKIE, &dummy) )
				exinput = TRUE;

			if (_GemParBlk.global[0] >= 0x399)
			{
				menu_register(app_id, "  GEMJing ");
				menu_register(-1, "GEMJING ");
			}

			aes_handle = graf_handle(&dum, &dum, &dum, &dum);   

			vdi_handle = open_screen_wk( aes_handle, work_out );
  
			if ( vdi_handle > 0 )
			{
				graf_mouse( ARROW, 0L );

				if( rsrc_load( "gemjing.rsc" ))               /* Resource laden */
				{
					if (plain == FALSE)
					{
						init_rsrc();
						menu_bar(menu, 1);
					}
					olga_init();
				
					do_events();                      /* Fensterdialog anzeigen */
					ret_code = 0;

					olga_exit();
					if (plain == FALSE)
					{
						menu_bar(menu, 0);
					}
					rsrc_free();
				}
				else
					form_alert(1,"[1]['gemjing.rsc' not found! |Program will terminate. ][ OK ]");

				v_clsvwk(vdi_handle);
				}
			appl_exit();                            /* abmelden */	
		}
	}
	Mfree(path);
	Mfree(name);
	Mfree(args);
	Mfree(va_helpbuf);
	Mfree(gs_helpbuf);

	return ret_code;
}

VOID olga_init(VOID)
{
	WORD answer[8];
	
	olga.manager_id = appl_find("OLGA    ");
	
	if (olga.manager_id >= 0)
	{
		answer[0] = OLE_INIT;
		answer[1] = app_id;
		answer[2] = 0;
		answer[3] = OL_SERVER;    /* Bitmap, OL_SERVER und/oder OL_CLIENT gesetzt, OL_PIPES */
		answer[4] = 0;          /* max. von der App. verstandene Stufe des Protokolls (z.Z. immer 0) */
		answer[5] = 0;        /* OEP:  Bitmap, OL_OEP gesetzt */
		answer[6] = 0;          /* OEP:  reserviert (0) */
		answer[7] = 'MU';       /* maschinenlesbarer XAcc-Programmtyp (oder 0) */
		appl_write(olga.manager_id, 16, answer);
	}
}

VOID olga_exit(VOID)
{
	WORD answer[8];

	if (olga.manager_id < 0 || olga.okay == FALSE)
		return;

	answer[0] = OLE_EXIT;
	answer[1] = app_id;
	answer[2] = answer[3] = answer[4] = answer[5] = answer[6] = answer[7] = 0;
	appl_write(olga.manager_id, 16, answer);
}

/*
	Der folgende Code testet, ob appl_getinfo in der aktuellen
	Systemumgebung zur VerfÅgung steht, und ruft im positiven
	Fall die besagte Funktion auf.
	
	Es bietet sich an, statt appl_getinfo nur appl_xgetinfo
	in eigenen Programmen zu verwenden.
	Frisch aus dem TOS.HYP
*/
WORD appl_xgetinfo (WORD type, WORD *out1, WORD *out2, WORD *out3, WORD *out4)
{
	BOOLEAN has_agi = FALSE;

	has_agi = ((_GemParBlk.global[0] == 0x399 && MagiC == TRUE)
					|| (_GemParBlk.global[0] == 0x400 && type < 4)
					|| (_GemParBlk.global[0] > 0x400)
					|| (appl_find ("?AGI") >= 0));

	if (has_agi)
		return (appl_getinfo (type, out1, out2, out3, out4));
	
	else return (0);
} /* appl_xgetinfo */


VOID check_getinfo(VOID)
{
	WORD g1, dum;
	LONG ldum;

	if ((get_cookie(MiNT_COOKIE, &ldum) == TRUE) && (_GemParBlk.global[1] > 1 || _GemParBlk.global[1] == -1))
		MultiTOS = TRUE;
	if (get_cookie(MagX_COOKIE, &ldum) == TRUE)
		MagiC = TRUE;
	if (get_cookie(MgMc_COOKIE, &ldum) == TRUE)
		MagiCMac = TRUE;

	appl_xgetinfo(10, &g1, &dum, &dum, &dum);
	g1 = g1 << 8; g1 = g1 >> 8;					/* ich brauche nur die unteren 8 Bit (0-7) */
	if (g1 >= 9)  
		shel_write(9, 1, 0, NULL, NULL);			/* Sag der Shell, daû GEMJing AP_TERM versteht */
}

VOID split_gs_line(NEWDEF *new, BYTE *str)
{
	if (strcmpi(str, "OPEN") == 0)
	{
		while (*str++)
			;
		new->file = str;
	}
	else if (strcmpi(str, "MEMORYPLAY") == 0)
	{
		while (*str++)
			;
		new->memoryplay = (BYTE*) atol(str);
		while (*str++)
			;
		new->memoryplay_len = atol(str);
		if (new->memoryplay_len == 0)
			new->memoryplay = NULL;
	}
	else if (strcmpi(str, "QUIT") == 0)
		quit = TRUE;
}


/* Neue Version von Dimitri Junker*/
/* Eigentlich sollten nur Dateinamen gequoted werden, CAB hat da aber eine seltsame Alternative:
Message send    : [15 CAB] -> [14 GEMJING]: VA_START( Ø'-q -r0 -d7 H:\CAB\HTML\cow test.wav'Æ )
Deshalb habe ich die Routine so geschrieben, daû innerhalb des gequoteten noch Argumente erlaubt sind.
Programm die richtig quoten stîrt das nicht, aber so funktioniert es eben auch mit CAB.
*/
VOID split_argumentline(NEWDEF *new, BYTE *str)
{
	BYTE		*p,*apostroph,*fileName=NULL;
	BOOLEAN 		inQuote=FALSE;


	memset(new, 0, sizeof(NEWDEF)); new->repeatrate = 1;
	p=str;
	while(p && *p)
	{
		switch (*p)
		{
			case '\'':
				inQuote=TRUE;
			case ' ':
				p++;
				break;
			case '-':
				switch(p[1])
				{
					case 'd':
						new->delayrate = atoi(&p[2]);
						break;
					case 'r':
						new->repeatrate = atoi(&p[2]);
						break;
					case 'p':
						plain = TRUE;
						break;
					case 'm':
						new->memoryplay = (BYTE *) atol(p);
						p=strchr(p,',');
						if(p)
							new->memoryplay_len = atol(++p);
						else
							new->memoryplay = NULL;				/* dann besser ganz ignorieren*/
						break;
					case 'q':
						new->no_menu = TRUE;
						break;
				}
				if(p)
					p=strchr(p,' ');
				break;
			default:
				fileName=p;
				if(inQuote)
				{
					while((apostroph=strstr(p,"''"))!=NULL)		/* gequotetes Apostroph */
					{
						p=apostroph+1;
						strcpy(apostroph,p);
					}
					p=strchr(p,'\'');
				}
				else
					p=strchr(p,' ');
				if(p)
					*p++='\0';
				if (file_exist(fileName) == TRUE)
					new->file = fileName;
				break;
		}
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Funktionsergebnis: -                                           */
/*----------------------------------------------------------------------------------------*/ 
VOID  do_events( VOID )
{
	WORD	mwhich;
	WORD  msg[8], mx, my, mbutton, kstate, key, mclicks;

	if (new->file != NULL)
	{
		spiele_sample(new);
	} 

	do
	{
		mwhich = evnt_multi(MU_KEYBD+MU_BUTTON+MU_MESAG,
			2,                            /* Doppelklicks erkennen */
			1,                            /* nur linke Maustaste */
			1,                            /* linke Maustaste gedrÅckt */
			0, 0, 0, 0, 0,                /* kein 1. Rechteck */
			0, 0, 0, 0, 0,                /* kein 2. Rechteck */
			msg,
			0, 0,                         /* ms */
			&mx, &my,
			&mbutton, &kstate,
			&key, &mclicks );
	
		if (mwhich & MU_KEYBD)           /* Tastendruck? */
			hdle_keybd(key, kstate);
	
		if (mwhich & MU_MESAG)           /* Mitteilungen des SCRENMGR? */
			hdle_mesag(msg);
	
	} while (!quit);

	if (gs_partner_id != NO_GS_PARTNER)
	{
		WORD answer[8];

		/* beim GS-Partner verabschieden */
		answer[0] = GS_QUIT;
		answer[1] = app_id;
		answer[2] = answer[3] = answer[4] = answer[5]  = answer[6] = 0;
		answer[7] = gs_req_id;
		appl_write(gs_req_id, 16, answer);
	}
}

/*----------------------------------------------------------------------------------------*/ 
VOID hdle_keybd(WORD key, WORD kstate)
{
  if (playing == FALSE)
  {
    switch(key)
    {
      case 4113:  handle_menu(MEN_QUIT, NULL); break;
      case 5897:  handle_menu(MEN_ABOUT, NULL); break;
      case 6159:  handle_menu(MEN_OPEN, NULL); break;
      case 25088: handle_menu(MEN_CONTEXT, NULL); break;
      default:		{
      					WORD msg[8];
      					msg[0] = AV_SENDKEY;
      					msg[1] = app_id;
      					msg[2] = 0;
      					msg[3] = kstate;
      					msg[4] = key;
      					msg[5] = msg[6] = msg[7] = 0;
                  	appl_write(get_avserver(), 16, &msg);
      				}
    }
  }
}
/*----------------------------------------------------------------------------------------*/ 
VOID hdle_mesag(WORD *msg)
{
	if (msg[0] == MN_SELECTED)
	{
		if (plain == FALSE)
			handle_menu(msg[4], msg);
	}
	else if (msg[0] == AP_TERM)
		quit=TRUE;
	else if (msg[0] == OLGA_INIT)
	{
		if ((msg[3] & OL_MANAGER) && msg[7] != 0)
			olga.okay = TRUE;
	}
	else if (msg[0] == OLE_EXIT)
	{
		olga.okay = FALSE;
		olga.manager_id = -1;
	}
	else if (msg[0] == OLE_NEW)                 /* Manager teilt sich mit */
	{
		olga_init();
	}
	else if (msg[0] == GS_REQUEST)
	{
   	WORD answer[8];
   	GS_INFO *my_gsinfo;

		my_gsinfo = (GS_INFO *) gs_helpbuf;

		gs_partner_id = msg[1];
		gs_bel_id = msg[7];

		answer[6] = 0;
		gsinfo = (GS_INFO *) *(BYTE **) &msg[3];
		if (gsinfo)
		{
			if (gsinfo->len > (2*sizeof(int) + sizeof(long)))
				if (gsinfo->version < 0x100)
					answer[6] = 777;			/* 777 = willkÅrlich, aber lt. Doku erlaubt */
		}
		else
			answer[6] = 777;					/* 777 = willkÅrlich, aber lt. Doku erlaubt */

		/* GS_INFO fÅllen und zurÅckschicken */
		my_gsinfo = (GS_INFO *) my_gsinfo;
		my_gsinfo->len 		= 2*sizeof(int)+2*sizeof(long);
		my_gsinfo->version	= 0x100;
		my_gsinfo->msgs		= GSM_COMMAND;
		my_gsinfo->ext			= 0L;

		answer[0] = GS_REPLY;
		answer[1] = app_id;
		answer[2] = 0;

		answer[3] = (WORD)(((LONG)my_gsinfo >> 16) & 0x0000ffff);
		answer[4] = (WORD)((LONG)my_gsinfo & 0x0000ffff);
		
		answer[5] = 0;
		answer[7] = gs_bel_id;          /* XXX */
		appl_write(msg[1], 16, answer);
  }
	else if (msg[0] == GS_COMMAND)
	{
		WORD answer[8];
		BYTE *p;

		p = *(BYTE **) &msg[3];

		if (!p)
			return;

		if (strlen(p) != 0)
		{
			memset(new, 0, sizeof(NEWDEF));
			new->repeatrate = 1;

			split_gs_line(new, p);

			hide_menu_entries();
			spiele_sample(new);
			show_menu_entries();

			answer[7] = 0;      
		}
		else
			answer[7] = 2;

		answer[0] = GS_ACK;
		answer[1] = app_id;
		answer[2] = 0;
		answer[3] = msg[3];
		answer[4] = msg[4];
		answer[5] = 0;
		answer[6] = 0;
		appl_write(msg[1], 16, answer);
	}
	else if (msg[0] == VA_START)
	{
		WORD answer[8];
		BYTE *p;


		p = *(BYTE **) &msg[3];
		if (!p)
			return;

		args[510] = 0;
		strncpy(args, p, 511);        /* zur Sicherheit umkopieren */

		if (strlen(args) != 0)
		{
			WORD ret;

			split_argumentline(new, args);

	      hide_menu_entries();
	      ret = spiele_sample(new);
	      show_menu_entries();

	      /* Antwort: "Habe verstanden." */
	      answer[0] = AV_STARTED;
	      answer[1] = app_id;
	      answer[2] = 0;
	      answer[3] = msg[3];
	      answer[4] = msg[4];
	      answer[5] = 0;
	      answer[6] = 0;
	      answer[7] = 0;
	      appl_write(msg[1], 16, answer);

	      answer[0] = GEMJING_RETURN;
	      answer[1] = app_id;
	      answer[2] = 0;
	      answer[3] = ret;
	      answer[4] = 0;
	      answer[5] = 0;
	      answer[6] = 0;
	      answer[7] = 0;
	      appl_write(msg[1], 16, answer);
    	}
  }
}

VOID do_info_dialog(VOID)
{
	WORD	cx, cy, cw, ch, ret, dummy;
	VOID	*flyinf;

	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);

	form_center(infodial, &cx, &cy, &cw, &ch);
	graf_growbox(0, 0, 0, 0, cx, cy, cw, ch);
	form_xdial(FMD_START, cx, cy, cw, ch, cx, cy, cw, ch, &flyinf);

	objc_draw(infodial, ROOT, MAX_DEPTH, cx, cy, cw, ch);
	ret = form_xdo(infodial, 0, &dummy, NULL, flyinf) & 0x7fff;

	form_xdial(FMD_FINISH, cx, cy, cw, ch, cx, cy, cw, ch, &flyinf);
	graf_shrinkbox(0, 0, 0, 0, cx, cy, cw, ch);

	wind_update(END_MCTRL);
	wind_update(END_UPDATE);

	infodial[ret].ob_state &= ~SELECTED;

	return;	
}

/*------------------------------*/
VOID handle_menu(WORD item, WORD *msg)
{
  if (new->no_menu == FALSE)
  {
		if (plain == FALSE)
			if (msg)
      		menu_tnormal(menu,msg[3],1);      /* Kopfzeile normal */
  }

	if (plain == FALSE)
	{
		switch(item)
		{
			case MEN_ABOUT:
				do_info_dialog();
				break;
			case MEN_OPEN:
				if (select_file(path, name) == 1 && name[0] != 0)
				{
					WORD ret;
					
					args[0] = 0;
					strcpy(args, path);
					strcat(args, name);
					if (file_exist(args) == TRUE)
					{
						memset(new, 0, sizeof(NEWDEF));
						new->repeatrate = 1;
						
						new->file = args;
						
						hide_menu_entries();
						ret = spiele_sample(new);
						show_menu_entries();
						handle_play_error(ret);
					}
				}
				break;
		
			case MEN_QUIT:
				quit = TRUE;
				break;
		
			case MEN_CONTEXT:
				do_help("Main");
				break;
		}
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Resource und dazugehîrige Strukturen initialisieren                        */
/* Funktionsergebnis: -                                           */
/*----------------------------------------------------------------------------------------*/ 
VOID  init_rsrc( VOID )
{
  rsh = *((RSHDR **)(&_GemParBlk.global[7]));         /* Adresse des Resource-Headers Åber global[7/8] holen */

  fstring_addr = (BYTE **)((UBYTE *)rsh + rsh->rsh_frstr);  /* Zeiger auf die Free-Strings */

  rsrc_gaddr(R_TREE, MENU, &menu);
  rsrc_gaddr(R_TREE, INFODIAL, &infodial);

  strcpy(infodial[INF_VERSION].ob_spec.tedinfo->te_ptext, VERS_DATE_STR);
}

/*----------------------------------------------------------------------------------------*/ 
/* Virtuelle Bildschirm-Workstation îffnen                                */
/* Funktionsresultat: VDI-Handle oder 0 als Fehlernummer                      */
/* work_out:        GerÑteinformationen                               */
/*----------------------------------------------------------------------------------------*/ 
WORD  open_screen_wk( WORD aes_handle, WORD *work_out )
{
  WORD  work_in[11];
  WORD  handle;
  WORD  i;

  for( i = 1; i < 10; i++ )
    work_in[i] = 1;

  work_in[0] = Getrez() + 2;                      /* Auflîsung */
  work_in[10] = 2;                            /* Rasterkoordinaten benutzen */
  handle = aes_handle;

  v_opnvwk( work_in, &handle, work_out );

  return( handle );
}

/*----------------------------------------------------------------------------------------*/ 

VOID do_help(BYTE *pattern)
{
  WORD  msg[8], i;

  if ((i=appl_find("ST-GUIDE"))>=0)
  {
    strcpy(va_helpbuf, "*:\\gemjing.hyp ");			/* klein wg. Minix-FS */
    strcat(va_helpbuf, pattern);
    msg[0] = VA_START;
    msg[1] = app_id;
    msg[2] = 0;

    msg[3] = (int)(((long)va_helpbuf >> 16) & 0x0000ffff);
    msg[4] = (int)((long)va_helpbuf & 0x0000ffff);
    msg[5] = 0;
    msg[6] = 0;
    msg[7] = 0;
    appl_write(i, 16, msg);
  }
  else
    form_alert(1, fstring_addr[STGUIDE_MISSING] );
}

WORD select_file(BYTE *path, BYTE *name)
{
	WORD i;
	WORD b;                             /* EnthÑlt Code des Buttons der  */
                                       /* zum Abbruch der Dateiauswahl  */
                                       /* fÅhrte.                       */
	WORD  result;
	
	name[0] = 0;                        /* Dateinamen lîschen.           */

	if (path[strlen(path)-1] != '*' && path[strlen(path)-2] != '.' && path[strlen(path)-3] != '*')
	{
		strcat(path, "*.*");
	}

	if ( exinput == FALSE )
		result = fsel_input(path, name, &b);
	else
		result = fsel_exinput(path, name, &b, fstring_addr[FSEL_TITLE]);
	
	if ( result == 0 )
	{
		path[0] = 0;
		name[0] = 0;
	}
	
	for (i=(WORD) strlen(path); i > -1; i--)
		if (path[i] == '\\')
		{
			path[i+1] = 0;
			break;
		}
	
	return ( b );
}

WORD file_exist(BYTE *name)
{
	LONG ret;

	ret = Fopen(name, FO_READ);
	if (ret < 0)
		return FALSE;
	Fclose((WORD)ret);
	return TRUE;
}

VOID hide_menu_entries(VOID)
{
	if (plain == TRUE)
		return;
  menu_ienable(menu, MEN_ABOUT, 0);
  menu_ienable(menu, MEN_OPEN, 0);
  menu_ienable(menu, MEN_QUIT, 0);
  menu_ienable(menu, MEN_CONTEXT, 0);
  playing = TRUE;
}

VOID show_menu_entries(VOID)
{
	if (plain == TRUE)
		return;
  menu_ienable(menu, MEN_ABOUT, 1);
  menu_ienable(menu, MEN_OPEN, 1);
  menu_ienable(menu, MEN_QUIT, 1);
  menu_ienable(menu, MEN_CONTEXT, 1);
  playing = FALSE;
}

VOID handle_play_error(WORD ret)
{
  switch(ret)
  {
    case RT_WRONG_HARDWARE: form_alert(1, fstring_addr[SND_ERR]); break;
    case RT_NO_MEM: form_alert(1, fstring_addr[MEM_ERR]); break;
    case RT_PACKED:
    case RT_WRONG_CHUNK:
    case RT_WRONG_FILE:
    case RT_UNSUPPORTED_AU_SND:
    case RT_NO_FILE: form_alert(1, fstring_addr[READ_ERR]); break;
    case RT_LOCKED: form_alert(1, fstring_addr[SND_LOCKED]); break;
  }
}

int form_xdo(OBJECT *tree, int startob, int *lastcrsr, void *tabs, void *flydial)
{
	_GemParBlk.contrl[0] = 50;
	_GemParBlk.contrl[1] =  1;
	_GemParBlk.contrl[2] =  2;
	_GemParBlk.contrl[3] =  3;
	_GemParBlk.contrl[4] =  0;
	_GemParBlk.intin[0]  = startob;
	_GemParBlk.addrin[0] = tree;
	_GemParBlk.addrin[1] = tabs;
	_GemParBlk.addrin[2] = flydial;

	call_aes();
	*lastcrsr = _GemParBlk.intout[1];
	return(_GemParBlk.intout[0]);
}


int form_xdial(int flag, int ltx, int lty, int ltw, int lth, int bgx, int bgy, int bgw, int bgh, void **flydial)
{
	_GemParBlk.contrl[0] = 51;
	_GemParBlk.contrl[1] =  9;
	_GemParBlk.contrl[2] =  1;
	_GemParBlk.contrl[3] =  2;
	_GemParBlk.contrl[4] =  0;
	_GemParBlk.intin[0]  = flag;
	_GemParBlk.intin[1]  = ltx;
	_GemParBlk.intin[2]  = lty;
	_GemParBlk.intin[3]  = ltw;
	_GemParBlk.intin[4]  = lth;
	_GemParBlk.intin[5]  = bgx;
	_GemParBlk.intin[6]  = bgy;
	_GemParBlk.intin[7]  = bgw;
	_GemParBlk.intin[8]  = bgh;
	_GemParBlk.addrin[0] = flydial;
	_GemParBlk.addrin[1] = 0;

	call_aes();
	return(_GemParBlk.intout[0]);
}

void call_aes(void)
{
	aespb.contrl  = _GemParBlk.contrl;
	aespb.global  = _GemParBlk.global;
	aespb.intin   = _GemParBlk.intin;
	aespb.intout  = _GemParBlk.intout;
	aespb.addrin  = (int *)_GemParBlk.addrin;

	_crystal(&aespb);
}

WORD get_avserver(VOID)
{
	WORD ret;

	va_helpbuf = getenv("AVSERVER");
	if (va_helpbuf)
	{
		ret = appl_find(va_helpbuf);
		va_helpbuf[0] = 0;					/* String wieder lîschen */
		if (ret >= 0)
			return ret;
	}

	ret = appl_find("AVSERVER");
	if (ret >= 0)
		return ret;

	ret = appl_find("JINNEE  ");
	if (ret >= 0)
		return ret;

	ret = appl_find("THING   ");
	if (ret >= 0)
		return ret;

	ret = appl_find("MAGXDESK");
	if (ret >= 0)
		return ret;

	ret = appl_find("GEMINI  ");
	if (ret >= 0)
		return ret;

	return -100;
}
