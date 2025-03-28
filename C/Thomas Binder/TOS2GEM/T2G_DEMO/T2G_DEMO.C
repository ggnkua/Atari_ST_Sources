/*3456789012345678901234567890123456789012345678*/
/*
 * t2g_demo.c vom 18.01.1995
 * (c)1995 by MAXON-Computer
 *
 * Autor:
 * Thomas Binder
 *
 * Zweck:
 * Beispielquellcode zur Benutzung von TOS2GEM mit
 * Hilfe der TOS2GEM-Library von Dirk Klemmt. Das
 * fertige Programm ermîglicht es, TOS- oder TTP-
 * Programme zu starten, die dann in einem GEM-
 * Fenster laufen. LÑuft gerade kein Programm, ist
 * es mîglich, im Fenster zu scrollen, es zu
 * verschieben, vergrîûern, etc.
 *
 * History:
 * 04.09.1994-
 * 12.09.1994: Erstellung
 * 12.09.1994: Neue MenÅpunkte "Cursor" und "Wrap"
 *             bei den Optionen. Sie bestimmen,
 *             wie sich TOS2GEM bei der Ausgabe
 *             verhÑlt.
 * 29.09.1994: Back from holiday ;) Beim "Snappen"
 *             des Fensters auf ganze Buchstaben
 *             wird jetzt darauf geachtet, daû
 *             der Arbeitsbereich danach nicht aus
 *             dem Bildschirm ragt.
 *             Kleinen Fehler bei der Anpassung
 *             der FilenamenslÑnge an den Platz in
 *             der Fehlerdialogbox beseitigt.
 *             Scrollen des Fensterinhaltes klappt
 *             jetzt auch richtig, wenn das
 *             Fenster teilweise auûerhalb des
 *             Bildschirms liegt.
 *             Bei der Anpassung zu kleiner
 *             Fenstermaûe in wind_sized hatte ich
 *             das Multiplizieren mit der
 *             aktuellen Zeichengrîûe vergessen.
 *             Verbesserte Kommentierung.
 *             Abspaltung der Funktion
 *             scroll_window aus adjust_window
 *             heraus.
 *             Bei create_environment werden jetzt
 *             nur noch die wirklich benîtigten
 *             Variablen hinzugefÅgt.
 *             Die MenÅpunkte "drucken" und
 *             "lîschen" werden jetzt deaktiviert,
 *             wenn das TOS2GEM-Fenster noch leer
 *             ist.
 * 30.09.1994: TOS2GEM kann jetzt auch mit einem
 *             Kommandozeilenparameter gestartet
 *             werden, der dann als auszufÅhrendes
 *             Programm betrachtet wird. Dazu
 *             muûte ein Teil der Funktion
 *             menu_runprg in die neue Funktion
 *             start_program verlegt werden.
 *             Desweiteren wird jetzt ein
 *             Programmabbruch per ^C nicht mehr
 *             als Fehler gemeldet.
 * 02.10.1994: "Willkommensgruû" eingebaut
 * 03.10.1994: Trotz "Tag der Deutschen Einheit"
 *             wieder 'rumgebastelt. Ergebnis:
 *             Man kann .TTP-Programmen jetzt bis
 *             zu 124 Zeichen Kommandozeile
 *             Åbergeben.
 * 11.10.1994: Trotz Vordiplomklausur am Vormittag
 *             wieder 'rumgebastelt ;) Ergebnis:
 *             Es wird jetzt vor dem Scrollen per
 *             vro_cpyfm geprÅft, ob das Fenster
 *             komplett sichtbar ist (dadurch wird
 *             auch bei einem geSHADEten Fenster
 *             nicht mehr gescrollt).
 *             Das neue Cookie-Element
 *             "cursor_handle" wird unterstÅtzt.
 * 12.10.1994: Beim Fontauswahldialog-Handler
 *             wurde das 15. Bit nicht ausmaskiert
 *             und daher Doppelklicks auf die
 *             Pfeile nicht ausgewertet.
 *             Teile der Kommentierung verbessert.
 * 13.10.1994: Saublîden Fehler beim ôffnen der
 *             VDI-Workstation fÅr den Cursor
 *             beseitigt, der bei Aufruf des
 *             Programms mit Parametern zum
 *             Absturz fÅhrte (die Anweisung
 *             work_in[11] = 2; war falsch, es
 *             muû work_in[10] bzw. work_in[i]
 *             heissen...)
 *             Erneute Erweiterung der
 *             Kommentierung.
 *             Bei Programmstart mit Parametern
 *             werden dem zu startenden Programm
 *             jetzt auch seine Parameter
 *             Åbergeben (noch nicht per ARGV, das
 *             kommt vielleicht noch), auûerdem
 *             wird die "Willkommen"-Meldung dann
 *             nicht mehr ausgegeben.
 *             TOS2GEM-Demo selbst versteht jetzt
 *             ARGV, verwendet es aber nicht
 *             (anderer Startupcode).
 * 14.10.1994: Uff! Ana-Vordiplom geschrieben, zur
 *             Entspannung TOS2GEM-Demo die
 *             FÑhigkeit spendiert, auf die
 *             AES-Nachricht STARTPRG (0x1972) hin
 *             ein bestimmtes Programm zu starten.
 *             Die Nachricht wird von einem Mini-
 *             programm verschickt, das z.B. unter
 *             Geneva als TOSRUN angemeldet werden
 *             kann.
 *             Fehler aus der Parameterauswertung
 *             bei Programmstart entfernt.
 * 16.10.1994: Fehler bei Ermittlung des aktuellen
 *             Pfades ausgebaut.
 * 17.10.1994: Es lebe die MiNTLib! Nachdem ich
 *             TOS2GEM-Demo mit dieser Library neu
 *             compiliert hatte, verschwand das
 *             Problem unter MagiC, daû
 *             der Pexec-Aufruf grundsÑtzlich zu
 *             einer "Speicherblock durch
 *             Benutzerprogramm Åberschrieben"-
 *             Meldung fÅhrte. Hatte wohl was mit
 *             der Speicherverwaltung der normalen
 *             Pure C-Library zu tun.
 *             Auûerdem wird jetzt beim Redraw nur
 *             noch dann geclippt, wenn es nîtig
 *             ist (trotzdem ist das Redraw auf
 *             einem normalen 1040'er mit 8MHz
 *             immer noch quÑlend langsam. Warum?
 *             qed und Ñhnliche Programme benutzen
 *             auch das VDI und sind wesentlich
 *             schneller bei der Ausgabe :(
 *             Wegen der MiNTLib folgt den beiden
 *             printf-Aufrufen jetzt ein fflush,
 *             da die MiNTLib stdout echt puffert.
 * 18.10.1994: Vor dem Pexec-Aufruf wird jetzt
 *             die MenÅzeile ab- und danach wieder
 *             angemeldet.
 *             Unter AES >= 4.0 trÑgt sich
 *             TOS2GEM-Demo jetzt "schîner" in das
 *             Desk-MenÅ ein.
 * 05.11.1994: Die Event-Schleife wartet jetzt
 *             auch auf Doppelklicks, um das
 *             leidige Problem der doppelten
 *             WM_ARROWED-Meldungen zu umgehen.
 *             Die Funktion adjust_window paût
 *             jetzt auch den gespeicherten y-
 *             Offset (last_ypos) an.
 *             Verbesserung der Kommentierung.
 *             last_prgnam wird jetzt
 *             initialisiert.
 * 11.12.1994: Beim Sizen mit Breitenkorrektur
 *             wird jetzt darauf geachtet, daû der
 *             komplette Rahmen des Fensters
 *             sichtbar bleibt (bislang galt das
 *             nur fÅr den Arbeitsbereich).
 * 03.01.1995: Die Korrekturen des gespeicherten
 *             y_offsets sind jetzt weggefallen,
 *             da TOS2GEM seit heute in dieser
 *             Hinsicht korrigiert ist. Folglich
 *             ist zur Benutzung von TOS2GEM-Demo
 *             jetzt mindestens TOS2GEM vom
 *             03.01.1995 nîtig.
 * 06.01.-
 * 07.01.1995: Anpassung an die TOS2GEM-Library
 *             von Dirk Klemmt, dabei auch einige
 *             Optimierungen und Erweiterungen
 *             vorgenommen.
 * 10.01.1995: öberarbeitung der Kommentierung
 * 14.01.1995: Anpassung von wind_arrowed auf die
 *             erweiterten Scrollnachrichten von
 *             WINX.
 * 15.01.1995: Anpassung an erweiterte TOS2GEM-
 *             Library von Dirk Klemmt.
 * 17.01.1995: Nochmalige Erweiterung der
 *             Kommentierung
 * 18.01.1995: Letzte Anpassungen an énderungen in
 *             der TOS2GEM-Library (scroll_t2g
 *             heisst jetzt scroll_t2gwindow)
 */

#include <aes.h>
/*        ^^^
 * Leider ist aesbind.h aus den Include-Files der
 * MiNTLib selbst mit __TCC_COMPAT__ und
 * __OLD_WAY__ nicht 100%ig Pure-C-kompatibel
 * (unterschiedliche Defintion der Union fÅr
 * ob_spec, die nicht mit rsh-Files funktioniert).
 * Am besten ist es also, aes.h zu den anderen
 * Include-Files der MiNTLib hinzuzufÅgen.
 */
#include <vdi.h>
/*        ^^^
 * Gleiches gilt auch fÅr vdibind.h aus den
 * Includes der MiNTLib: Hier wird u.a. MFDB nicht
 * definiert.
 */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#ifdef __MINT__
#include <osbind.h>
#include <basepage.h>
#define _BasPag _base
#else
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#endif
#include <portab.h>
#include "..\uset2g\uset2g.h"
#include "errortxt.h"
#include "t2g_demo.rsh"

/*
 * Benutzter Puffertyp: 0 = Nur im benutzten
 * Bereich scrollen, 1 = immer im gesamten Puffer
 * scrollen
 */
#define BUFFERTYPE  0

/*
 * Puffergrîûe in Zeilen (0 = kein Puffer)
 */
#define BUFFERSIZE  200

/*
 * Diese Markos liefern den kleineren bzw.
 * grîûeren von zwei Werten. Vorsicht: Die beiden
 * Parameter werden u.U. mehrfach ausgewertet!
 */
#ifndef MIN
#define MIN(a, b)   ((a) < (b) ? (a) : (b))
#endif
#ifndef MAX
#define MAX(a, b)   ((a) > (b) ? (a) : (b))
#endif

/* Der benutzte Fenster-Typ */
#define WI_KIND CLOSER|NAME|MOVER|FULLER|UPARROW|\
                VSLIDE|DNARROW|SIZER|RTARROW|\
                HSLIDE|LFARROW

/* Default-Fonthîhe (in Punkt) */
#define DFLT_HEIGHT 9

/* Von T2G_TRUN verschickte Nachricht */
#define STARTPRG    0x1972

/* Prototypen */
void disable_menu(void);
void check_menu(void);
void leave(WORD exit_code);
void event_loop(void);
void handle_keyboard(WORD key, WORD shift);
void handle_message(WORD *msg);
void do_redraw(WORD wind, GRECT *box);
void wind_fulled(void);
void wind_arrowed(WORD dir1, WORD speed1,
    WORD dir2, WORD speed2);
void wind_hslid(WORD new_pos);
void wind_vslid(WORD new_pos);
void wind_sized(GRECT *new_area);
void adjust_window(WORD new_xpos, WORD new_ypos,
    WORD new_tpos);
void scroll_window(WORD x_jump, WORD y_jump);
void adjust_sliders(void);
void menu_selected(WORD title, WORD item);
void menu_about(void);
void menu_runprg(char *ext, char *title);
void start_program(char *prgname, char *cmdline);
void set_cursor_and_wrap(void);
char *create_environment(void);
void menu_print(void);
void menu_delete(void);
WORD window_visible(void);
void menu_quit(void);
void menu_font(void);
WORD do_fontselect(OBJECT *tree, WORD obj);
WORD fileselect(char *path, char *name,
    WORD *button, char *title);
void redraw_window(WORD wind, GRECT *area,
    void (*redraw_func)(WORD wind, GRECT *area));
WORD rc_equal(GRECT *one, GRECT *two);
WORD rc_intersect(GRECT *one, GRECT *two);
void rc_grect_to_array(GRECT *rect, WORD *xy);
WORD do_dialog(OBJECT *tree, WORD sobj,
    WORD (*action)(OBJECT *tree, WORD obj));
WORD get_cookie(ULONG cookie, ULONG *value);

/* Globale Variablen */
WORD    win,
        ap_id,
        quit,
        has_contents,
        cursor,
        wrap;
GRECT   desk,
        winwork,
        window,
        max_window;
char    tos_path[256],
        last_prgnam[256];

WORD main(WORD argc, char *argv[])
{
    WORD    i,
            init_ret;
    char    alert[80],
            cline[128];

    win = -1;
/* Programm bei den AES anmelden */
    if ((ap_id = appl_init()) < 0)
        return(1);
/* Resourcen anpassen und initialisieren */
    rsrc_init();
    strcpy(T2G_CMDL[C_CLINE1].ob_spec.tedinfo
        ->te_ptext, "");
    strcpy(T2G_CMDL[C_CLINE2].ob_spec.tedinfo
        ->te_ptext, "");
    strcpy(T2G_CMDL[C_CLINE3].ob_spec.tedinfo
        ->te_ptext, "");
    strcpy(T2G_CMDL[C_CLINE4].ob_spec.tedinfo
        ->te_ptext, "");
/* Pfeil als Mauscursor */
    graf_mouse(ARROW, 0L);
/* Arbeitsbereich des Desktops ermitteln */
    wind_get(0, WF_WORKXYWH, &desk.g_x, &desk.g_y,
        &desk.g_w, &desk.g_h);
/*
 * FÅr schîneren Eintrag im Desk-MenÅ sorgen, wenn
 * die AES >= 4.0 sind
 */
    if (_GemParBlk.global[0] >= 0x400)
        menu_register(ap_id, "  TOS2GEM-Demo");
/* Aktuelles Verzeichnis ermitteln */
    tos_path[0] = (char)(65 + Dgetdrv());
    tos_path[1] = ':';
    Dgetpath(&tos_path[2], 0);
    if (tos_path[strlen(tos_path) - 1] != '\\')
        strcat(tos_path, "\\");
    strcpy(last_prgnam, "");
/*
 * TOS2GEM Åber den Library-Aufruf init_t2g
 * vorbereiten und auf alle mîglichen Fehler
 * reagieren
 */
    switch (init_ret = init_t2g(80, 25,
        BUFFERSIZE, 1, DFLT_HEIGHT, BLACK, 7715,
        WI_KIND, 1, BUFFERTYPE, 1))
    {
        case T2G_NOTINSTALLED:
            form_alert(1, T2G_NOCK);
            appl_exit();
            return(1);
        case T2G_OLDTOS2GEM:
            form_alert(1, T2G_VERS);
            appl_exit();
            return(1);
        case T2G_CANNOTRESERVE:
            form_alert(1, T2G_LOCK);
            appl_exit();
            return(1);
        case T2G_NOVDIHANDLE:
            form_alert(1, T2G_INIT);
            appl_exit();
            return(1);
        case T2G_OUTOFMEMORY:
            form_alert(1, T2G_MEM);
            appl_exit();
            return(1);
        case T2G_NOERROR:
            break;
/*
 * Sollte eine neuere Version der Library einen
 * unbekannten Return-Code liefern, diesen als
 * solchen melden
 */
        default:
            sprintf(alert, T2G_UKWN, init_ret);
            form_alert(1, alert);
            appl_exit();
            return(1);
    }
/*
 * TOS2GEM ist jetzt vorbereitet. Ab diesem
 * Zeitpunkt muû bei einem Programmende vorher
 * *unbedingt* exit_t2g aufgerufen werden, da
 * TOS2GEM sonst nicht freigegeben wird!
 */
/*
 * Die gesetzte Fontgrîûe in den Fontwahldialog
 * eintragen
 */
    sprintf(T2G_FONT[F_HEIGHT].ob_spec.
        free_string,"%2d", DFLT_HEIGHT);
/* Die MenÅleiste anmelden */
    menu_bar(T2G_MENU, 1);
/*
 * Ein Fenster in passender Grîûe berechnen und
 * die Felder x_off, y_off, x_vis und y_vis der
 * der Cookie-Struktur belegen (macht alles die
 * Funktion calc_t2gwindow)
 */
    calc_t2gwindow(&window, &winwork, 0, 0);
    max_window = window;
/* Versuchen, ein solches Fenster anzulegen */
    if ((win = wind_create(WI_KIND,
        window.g_x, window.g_y,
        window.g_w, window.g_h)) < 0)
    {
        form_alert(1, T2G_WIND);
        leave(1);
    }
/*
 * Das erhaltene Fenster initialisieren und
 * îffnen
 */
    wind_set(win, WF_NAME, " TOS2GEM-Demo ");
    wind_open(win, window.g_x, window.g_y,
        window.g_w, window.g_h);
/*
 * Die Ausgabeumlenkung fÅr unseren Arbeitsbereich
 * aktivieren und gleich wieder abschalten (dient
 * dazu, daû der Textpuffer korrekt initialisiert
 * ist und daû spÑter bei Programmaufrufen nur
 * noch das Cookie-Element switch_output benîtigt
 * wird). Auûerdem lîscht init den Arbeitsbereich
 * von TOS2GEM, also genauso wie wenn man im
 * Desktop ein TOS-Programm startet.
 * Um MiûverstÑndnissen vorzubeugen: Es *muû*
 * init aufgerufen werden, damit TOS2GEM mit der
 * Umlenkung beginnt, da nur so lebenswichtige
 * Initialisierungen innerhalb von TOS2GEM
 * stattfinden! Die Funktion switch_output
 * aus der Cookie-Struktur darf erst danach zur
 * Aus/Einschaltung der Umlenkung benutzt werden.
 * Prinzipielle Vorgehensweise (roh, also vîllig
 * ohne Benutzung der Library):
 * - TOS2GEM per reserve() reservieren
 * - Cookie fÅllen
 * - init() aufrufen -> Umlenkung aktiv
 * + switch_output() -> Umlenkung deaktiv
 * + Erlaubte énderungen am Cookie oder an den
 *   VDI-Workstations vornehmen
 * + switch_output() -> Umlenkung wieder an
 *  oder
 * + init() -> Textpuffer und TOS2GEM-Bildschirm
 *   gelîscht, alle Offsets auf 0 gesetzt und
 *   Ausgabe wieder an;
 * + weitere switch_output()- bzw. init()-Aufrufe,
 *   je nach Bedarf
 * - Zum Schluû TOS2GEM per deinit() freigeben
 * Alles mit '+' am Anfang ist optional.
 */
    graf_mouse(M_OFF, 0L);
    wind_update(BEG_UPDATE);
    if (!(t2g->cookie->init)())
    {
/*
 * Wenn init Null zurÅckliefert, ist der Cookie
 * nicht korrekt belegt (dÅrfte bei korrekter
 * Verwendung der Library eigentlich nicht
 * vorkommen, aber man sollte es (zumindest in der
 * Entwicklungsphase) trotzdem ÅberprÅfen
 */
        wind_update(END_UPDATE);
        graf_mouse(M_ON, 0L);
        form_alert(1, T2G_INIT);
        leave(1);
    }
/*
 * Kleiner Willkommensgruû... (Wird noch von
 * TOS2GEM umgeleitet, da direkt nach dem Aufruf
 * der Init-Funktion des Cookies die Umlenkung
 * aktiv ist; erst der folgende switch_output-
 * Aufruf deaktiviert die Umleitung bis auf
 * weiteres.)
 */
    if (argc == 1)
    {
        printf("Willkommen zur TOS2GEM-Demo!"
            "\n\n");
        fflush(stdout);
    }
    (t2g->cookie->switch_output)();
    t2g->cur_text_offset = t2g->cur_y_offset = 0;
    wind_update(END_UPDATE);
    graf_mouse(M_ON, 0L);
    has_contents = 1;
    disable_menu();
    cursor = 1;
    wrap = 1;
    check_menu();
/* Slider auf Startwerte setzen */
    adjust_sliders();
/*
 * Ein eventuell in der Kommandozeile Åbergebenes
 * Programm starten; aber nur, wenn seine
 * Parameter alle in eine Standard-TOS-
 * Kommandozeile passen (124 Zeichen)
 */
    if (argc > 1)
    {
        strcpy(cline, "");
        for (i = 2; i < argc; i++)
        {
            if (strlen(cline) + strlen(argv[i])
                + 1 > 125)
            {
                break;
            }
            strcat(cline, " ");
            strcat(cline, argv[i]);
        }
        if (i == argc)
        {
            cline[0] = (char)strlen(&cline[1]);
            start_program(argv[1], cline);
        }
    }
/* Und nun ab in die Event-Behandlung... */
    event_loop();
    leave(0);
/*
 * Eigentlich unnîtig, nur damit Pure C nicht
 * meckert... (jaja, ein #pragma warn -rvl tÑte
 * es auch, aber diese Methode ist portabel ;)
 */
    return(0);
}

/*
 * check_menu
 *
 * Setzt oder lîscht die HÑkchen bei den Optionen
 * "Wrap" und "Cursor" im MenÅ.
 */
void check_menu(void)
{
    menu_icheck(T2G_MENU, M_CURSOR, cursor);
    menu_icheck(T2G_MENU, M_WRAP, wrap);
}

/*
 * disable_menu
 *
 * Aktiviert oder deaktiviert die MenÅpunkte
 * "drucken" und "lîschen" abhÑngig davon, ob das
 * TOS2GEM-Fenster leer ist.
 */
void disable_menu(void)
{
    menu_ienable(T2G_MENU, M_PRINT, has_contents);
    menu_ienable(T2G_MENU, M_DELETE,
        has_contents);
}

/*
 * leave
 *
 * VerlÑût das Programm. Vorher wird, falls nîtig,
 * das Fenster entfernt, die MenÅleiste
 * abgemeldet, TOS2GEM und die dazugehîrigen
 * Systemresourcen (VDI-Workstatiosn und Speicher)
 * freigegeben und und das Programm bei den AES
 * abgemeldet.
 *
 * Eingabe:
 * exit_code: Dieser Wert wird an das aufrufende
 *            Programm zurÅckgegeben
 */
void leave(WORD exit_code)
{
    if (win > -1)
    {
        wind_close(win);
        wind_delete(win);
    }
    menu_bar(T2G_MENU, 0);
/*
 * Diesen Aufruf nach erfolgreichem init_t2g *nie*
 * vergessen!
 */
    exit_t2g();
    appl_exit();
    exit(exit_code);
}

/*
 * event_loop
 *
 * Hauptschleife zur Ereignisverwaltung. Wartet
 * auf Tasten- und Mitteilungsereignisse und
 * wertet diese entsprechend aus, bis die globale
 * Variable quit gleich Eins ist.
 */
void event_loop(void)
{
    WORD    event,
            key,
            shift,
            msg[8],
            dummy;

    quit = 0;
    while (!quit)
    {
/*
 * Auf Nachrichten-, Button- und Tastaturevents
 * warten
 */
        event = evnt_multi(MU_MESAG|MU_KEYBD|
            MU_BUTTON, 2, 1, 1, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, msg, 1, 0, &dummy,
            &dummy, &dummy, &shift, &key, &dummy);
/*
 * Das aufgetretene Ereignis auswerten (die
 * Button-Events werden dabei vîllig ignoriert, da
 * sie nur dazu da sind, doppelte WM_ARROWED-
 * Meldungen zu vermeiden)
 */
        wind_update(BEG_UPDATE);
        if (event & MU_KEYBD)
            handle_keyboard(key, shift);
        if (event & MU_MESAG)
            handle_message(msg);
        wind_update(END_UPDATE);
    }
}

/*
 * handle_keyboard
 *
 * Wertet einen Tastendruck mit gegebenem ASCII-
 * und Scancode sowie Sondertastenzustand aus.
 * Dabei werden u.U. MenÅpunkte gewÑhlt oder
 * FensterverÑnderungen herbeigefÅhrt.
 *
 * Eingabe:
 * key: Scan- und ASCII-Code der gedrÅckten Taste
 *      (wie von evnt_multi zurÅckgegeben)
 * shift: Zustand der Umschalttasten (ebenfalls
 *        von evnt_multi)
 */
void handle_keyboard(WORD key, WORD shift)
{
    WORD    title, entry,
            ascii, scan;
#ifdef __MINT__
    _KEYTAB *table;
#else
    KEYTAB  *table;
#endif

/*
 * Die Adresse der aktiven Tastaturtabelle
 * ermitteln
 */
    table = Keytbl((void *)-1L, (void *)-1L,
        (void *)-1L);
/*
 * Scan- und ASCII-Code aus "key" separieren,
 * wobei der ASCII-Code aus der ungeshifteten
 * Tastaturtabelle ausgelesen wird.
 */
    scan = key >> 8;
    ascii = ((char *)table->unshift)[scan];
    title = -1;
/*
 * Jetzt die einzelnen Mîglichkeiten prÅfen und
 * entsprechend reagieren
 */
    if ((ascii == 'o') && (shift == 4))
    {
        title = M_TITLE2;
        entry = M_RUNTTP;
    }
    if ((ascii == 'o') && (shift > 4) &&
        (shift < 8))
    {
        title = M_TITLE2;
        entry = M_RUNTOS;
    }
    if ((ascii == 'p') && (shift == 4))
    {
        title = M_TITLE2;
        entry = M_PRINT;
    }
    if ((ascii == 'q') && (shift == 4))
    {
        title = M_TITLE2;
        entry = M_QUIT;
    }
    if ((ascii == 'z') && (shift == 4))
    {
        title = M_TITLE3;
        entry = M_FONT;
    }
    if ((ascii == 'c') && (shift == 8))
    {
        title = M_TITLE3;
        entry = M_CURSOR;
    }
    if ((ascii == 'w') && (shift == 8))
    {
        title = M_TITLE3;
        entry = M_WRAP;
    }
    if ((scan == 83) && (shift == 4))
    {
        title = M_TITLE2;
        entry = M_DELETE;
    }
    if ((scan == 72) && !shift)
        wind_arrowed(WA_UPLINE, 0, 0, 0);
    if ((scan == 72) && shift && (shift < 4))
        wind_arrowed(WA_UPPAGE, 0, 0, 0);
    if ((scan == 75) && !shift)
        wind_arrowed(WA_LFLINE, 0, 0, 0);
    if ((scan == 75) && shift && (shift < 4))
        wind_arrowed(WA_LFPAGE, 0, 0, 0);
    if ((scan == 77) && !shift)
        wind_arrowed(WA_RTLINE, 0, 0, 0);
    if ((scan == 77) && shift && (shift < 4))
        wind_arrowed(WA_RTPAGE, 0, 0, 0);
    if ((scan == 80) && !shift)
        wind_arrowed(WA_DNLINE, 0, 0, 0);
    if ((scan == 80) && shift && (shift < 4))
        wind_arrowed(WA_DNPAGE, 0, 0, 0);
    if ((scan == 71) && !shift)
        adjust_window(0, 0, 0);
    if ((scan == 71) && shift && (shift < 4))
    {
        adjust_window(0, t2g->cookie->y_size -
            t2g->cookie->y_vis,
            calc_t2gmax_text_offset());
    }
/*
 * War die gedrÅckte Tastenkombination ein MenÅ-
 * Shortcut, den dazugehîrigen Titel invertieren
 * und die MenÅauswertung aufrufen
 */
    if (title > -1)
    {
        menu_tnormal(T2G_MENU, title, 0);
        menu_selected(title, entry);
    }
}

/*
 * handle_message
 *
 * Wertet eine AES-Nachricht aus.
 *
 * Eingabe:
 * msg: Pointer auf das Message-Feld
 */
void handle_message(WORD *msg)
{
    GRECT   area;
    char    prgname[256],
            *commands;

/*
 * Gleich zu Anfang prÅfen, ob sich die Nachricht
 * Åberhaupt auf unser Fenster bezieht (wenn es
 * nicht ein MenÅauswahl-Ereignis oder eine
 * Nachricht mit T2G_TRUN war)
 */
    if ((msg[0] != MN_SELECTED) &&
        (msg[0] != STARTPRG) && (msg[3] != win))
    {
        return;
    }
    switch (msg[0])
    {
        case STARTPRG:
            if ((msg[2] == 0) || (msg[2] > 256))
                return;
            if (!appl_read(ap_id, msg[2],
                prgname))
            {
                return;
            }
            if ((commands = strchr(prgname, ' '))
                == NULL)
            {
                commands = "";
            }
            else
            {
                *(commands++) = 0;
                commands[0] = (char)
                    strlen(&commands[1]);
            }
            wind_set(win, WF_TOP);
            start_program(prgname, commands);
            break;
        case MN_SELECTED:
            menu_selected(msg[3], msg[4]);
            break;
        case WM_REDRAW:
            area.g_x = msg[4];
            area.g_y = msg[5];
            area.g_w = msg[6];
            area.g_h = msg[7];
            redraw_window(win, &area, do_redraw);
            break;
        case WM_TOPPED:
            wind_set(win, WF_TOP);
            break;
        case WM_CLOSED:
            menu_quit();
            break;
        case WM_FULLED:
            wind_fulled();
            break;
        case WM_ARROWED:
            wind_arrowed(msg[4], msg[5], msg[6],
                msg[7]);
            break;
        case WM_HSLID:
            wind_hslid(msg[4]);
            break;
        case WM_VSLID:
            wind_vslid(msg[4]);
            break;
        case WM_SIZED:
        case WM_MOVED:
            area.g_x = msg[4];
            area.g_y = msg[5];
            area.g_w = msg[6];
            area.g_h = msg[7];
            wind_sized(&area);
            break;
    }
}

/*
 * do_redraw
 *
 * Zeichnet ein gegebenes Rechteck des TOS2GEM-
 * Fensters neu (wird als Parameter-Funktion fÅr
 * redraw_window benutzt).
 *
 * Eingabe:
 * handle: Das Handle des Fensters (wird hier
 *         nicht gebraucht, deswegen auch der
 *         #pragma-Krempel fÅr Pure C)
 * box: Zeiger auf neuzuzeichnenden Bereich
 */
#ifdef __TURBOC__
#pragma warn -par
#endif
void do_redraw(WORD wind, GRECT *box)
{
    redraw_t2gwindow(&winwork, box, 1);
}
#ifdef __TURBOC__
#pragma warn .par
#endif

/*
 * wind_fulled
 *
 * Bringt das TOS2GEM-Fenster auf maximale Grîûe.
 * oder, wenn es das bereits war, auf die letzte
 * bekannte Grîûe/Position.
 */
void wind_fulled(void)
{
    GRECT   size;

    if (rc_equal(&window, &max_window))
    {
        wind_get(win, WF_PREVXYWH,
            &size.g_x, &size.g_y,
            &size.g_w, &size.g_h);
    }
    else
        size = max_window;
    wind_sized(&size);
}

/*
 * wind_arrowed
 *
 * Reagiert auf Verschiebeanforderungen fÅr das
 * TOS2GEM-Fenster.
 *
 * Eingabe:
 * dir1: Wie soll verschoben werden (von der
 *       WM_ARROWED-Meldung)
 * speed1: Geschwindigkeit der ersten "Schiebung"
 * dir2, speed2: Analog
 */
void wind_arrowed(WORD dir1, WORD speed1,
    WORD dir2, WORD speed2)
{
    WORD    new_ypos,
            new_xpos,
            new_tpos,
            dx,
            dy;

    dx = dy = 0;
    speed1 = (speed1 < 0) ? -speed1 : 1;
    switch (dir1)
    {
        case WA_UPLINE:
        case WA_UPPAGE:
            dy = (dir1 == WA_UPLINE) ?
                -1 : -t2g->cookie->y_vis;
            break;
        case WA_DNLINE:
        case WA_DNPAGE:
            dy = (dir1 == WA_DNLINE) ?
                1 : t2g->cookie->y_vis;
            break;
        case WA_LFLINE:
        case WA_LFPAGE:
            dx = (dir1 == WA_LFLINE) ?
                -1 : -t2g->cookie->x_vis;
            break;
        case WA_RTLINE:
        case WA_RTPAGE:
            dx = (dir1 == WA_RTLINE) ?
                1 : t2g->cookie->x_vis;
            break;
    }
    dx *= speed1;
    dy *= speed1;
    if (speed2 < 0)
    {
        switch (dir2)
        {
            case WA_UPLINE:
            case WA_UPPAGE:
                dy += (dir2 == WA_UPLINE) ?
                    -1 : -t2g->cookie->y_vis;
                break;
            case WA_DNLINE:
            case WA_DNPAGE:
                dy += (dir2 == WA_DNLINE) ?
                    1 : t2g->cookie->y_vis;
                break;
            case WA_LFLINE:
            case WA_LFPAGE:
                dx += (dir2 == WA_LFLINE) ?
                    -1 : -t2g->cookie->x_vis;
                break;
            case WA_RTLINE:
            case WA_RTPAGE:
                dx += (dir2 == WA_RTLINE) ?
                    1 : t2g->cookie->x_vis;
                break;
        }
        dx *= -speed2;
        dy *= -speed2;
    }
    scroll_t2gwindow(dx, dy, &new_xpos, &new_ypos,
        &new_tpos);
/*
 * Das Fenster an die neu ermittelte Textposition
 * anpassen.
 */
    adjust_window(new_xpos, new_ypos, new_tpos);
}

/*
 * wind_hslid
 *
 * Reagiert auf horizontale Sliderbewegungen.
 *
 * Eingabe:
 * new_pos: Neue Position des Sliders
 */
void wind_hslid(WORD new_pos)
{
    WORD    delta_x,
            old_pos,
            new_xpos,
            dummy;

/*
 * Wenn die neue Position gleich ganz links bzw.
 * ganz rechts ist, direkt die dazugehîrige
 * Position setzen, da in diesen FÑllen die unten
 * benutzte Offset-Methode versagen kann
 */
    if (new_pos <= 1)
    {
        new_xpos = 0;
        goto hsl_adjust;
    }
    if (new_pos == 1000)
    {
        new_xpos = t2g->cookie->x_size -
            t2g->cookie->x_vis;
        goto hsl_adjust;
    }
/*
 * Die folgende Umrechnung Sliderposition ->
 * tatsÑchliche Position arbeitet mit der
 * Differenz zur alten Position, was zum einen die
 * Handhabung in der Vertikalen erleichert und zum
 * anderen auch (weitgehend) verhindert, daû der
 * Fensterinhalt verschoben wird, obwohl der
 * Slider nur angeklickt, aber nicht bewegt wurde
 */
    wind_get(win, WF_HSLIDE, &old_pos);
    delta_x = new_pos - old_pos;
    calc_t2gdeltas(&delta_x, &dummy);
    scroll_t2gwindow(delta_x, 0, &new_xpos,
        &dummy, &dummy);
hsl_adjust:
    adjust_window(new_xpos, t2g->cur_y_offset,
        t2g->cur_text_offset);
}

/*
 * wind_vslid
 *
 * Reagiert auf vertikale Sliderbewegungen.
 *
 * Eingabe:
 * new_pos: Neue Position des Sliders
 */
void wind_vslid(WORD new_pos)
{
    WORD    delta_y,
            old_pos,
            new_ypos,
            new_tpos,
            dummy;

/* Prinzipiell wie oben bei wind_hslid */
    if (new_pos <= 1)
    {
        new_tpos = new_ypos = 0;
        goto vsl_adjust;
    }
    if (new_pos == 1000)
    {
        new_tpos =
            calc_t2gmax_text_offset();
        new_ypos = t2g->cookie->y_size -
            t2g->cookie->y_vis;
        goto vsl_adjust;
    }
    wind_get(win, WF_VSLIDE, &old_pos);
    delta_y = new_pos - old_pos;
    calc_t2gdeltas(&dummy, &delta_y);
    scroll_t2gwindow(0, delta_y, &dummy,
        &new_ypos, &new_tpos);
vsl_adjust:
    adjust_window(t2g->cur_x_offset, new_ypos,
        new_tpos);
}

/*
 * wind_sized
 *
 * Reagiert auf Grîûen- und PositionsÑnderungen
 * des TOS2GEM-Fensters. Durch den Library-Aufruf
 * adjust_t2gwindow wird darauf geachtet, daû die
 * maximale Grîûe nicht Åberschritten wird und
 * immer ganze Zeichen zu sehen sind.
 *
 * Eingabe:
 * new_area: Zeiger auf Rechteckstruktur mit
 *           neuer Fensterposition und -grîûe.
 */
void wind_sized(GRECT *new_area)
{
    WORD    new_xpos,
            new_ypos,
            offset_changed;

    offset_changed = adjust_t2gwindow(new_area,
        &winwork, &new_xpos, &new_ypos);
    wind_set(win, WF_CURRXYWH,
        new_area->g_x, new_area->g_y,
        new_area->g_w, new_area->g_h);
    window = *new_area;
    if (offset_changed)
    {
        adjust_window(new_xpos, new_ypos,
            t2g->cur_text_offset);
    }
    else
        adjust_sliders();
}

/*
 * adjust_window
 *
 * Paût das TOS2GEM-Fenster an eine neue Position
 * an. Dazu wird ggf. gescrollt und der neu
 * sichtbare Bereich aufgefÅllt.
 *
 * Eingabe:
 * new_xpos: Neue x-Textposition
 * new_ypos: Neue y-Textposition
 * new_tpos: Neuer Textpufferoffset
 */
void adjust_window(WORD new_xpos, WORD new_ypos,
    WORD new_tpos)
{
    WORD    dirty = 0,
            scroll,
            x_jump,
            y_jump;

/*
 * Der Fensterinhalt ist "dirty" (muû also neu
 * gezeichnet werden), wenn sich einer der
 * Offsets geÑndert hat
 */
    if ((new_xpos != t2g->cur_x_offset) ||
        (new_ypos != t2g->cur_y_offset) ||
        (new_tpos != t2g->cur_text_offset))
    {
        dirty = 1;
    }
    if (dirty)
    {
/*
 * Feststellen, ob bei neuzuzeichnendem Inhalt
 * gescrollt werden kann oder nicht
 */
        scroll = 1;
        if (!window_visible())
            scroll = 0;
        else
        {
            x_jump = new_xpos - t2g->cur_x_offset;
            y_jump = new_ypos + new_tpos -
                (t2g->cur_y_offset +
                t2g->cur_text_offset);
            if ((abs(x_jump) >= t2g->cookie->x_vis) ||
                (abs(y_jump) >= t2g->cookie->y_vis))
            {
                scroll = 0;
            }
        }
    }
/*
 * Die neuen Werte in die TOS2GEM-Library-Struktur
 * eintragen (dies wird von Library-Aufrufen, die
 * diese Werte verÑndern kînnten, absichtlich
 * nicht selbst gemacht, damit man im eigenen
 * Programm dann die Differenz zur alten Position
 * zu Rate ziehen kann)
 */
    t2g->cur_y_offset = new_ypos;
    t2g->cur_x_offset = new_xpos;
    t2g->cur_text_offset = new_tpos;
/*
 * Wenn nîtig, den Fensterinhalt neuzeichnen bzw.
 * scrollen
 */
    if (dirty)
    {
        if (!scroll)
        {
            redraw_window(win, &winwork,
                do_redraw);
        }
        else
            scroll_window(x_jump, y_jump);
    }
    adjust_sliders();
}

/*
 * scroll_window
 *
 * Verschiebt den Inhalt des TOS2GEM-Fensters in
 * x- und/oder y-Richtung um eine bestimmte Anzahl
 * von Spalten/Zeilen und zeichnet die
 * freigewordenen Bereiche neu.
 *
 * Eingabe:
 * x_jump: Anzahl der Spalten, um die gescrollt
 *         werden soll (positiv: links, negativ:
 *         rechts), oder Null
 * y_jump: Anzahl der Zeilen, um die der
 *         Bildschirm verschoben werden soll
 *         (positiv: hoch, negativ: runter), oder
 *         Null
 */
void scroll_window(WORD x_jump, WORD y_jump)
{
    WORD    lx,
            rx,
            uy,
            ly,
            area[8],
            clip[4];
    GRECT   rect,
            to_scroll;
    MFDB    source, dest;

    to_scroll = winwork;
/*
 * Ist vom Fensterinhalt Åberhaupt nichts
 * sichtbar, gleich aufhîren
 */
    if (!rc_intersect(&desk, &to_scroll))
        return;
/*
 * Ein biûchen tricksen, damit man sich etliche
 * Abfragen auf rauf/runter bzw. links/rechts
 * sparen kann
 */
    lx = (x_jump < 0) ? 0 : 4;
    rx = 4 - lx;
    uy = (y_jump < 0) ? 1 : 5;
    ly = 6 - uy;
    area[lx] = to_scroll.g_x;
    area[uy] = to_scroll.g_y;
    area[lx + 2] = area[lx] +
        to_scroll.g_w - 1 -
        abs(x_jump) * t2g->cookie->char_w;
    area[uy + 2] = area[uy] +
        to_scroll.g_h - 1 -
        abs(y_jump) * t2g->cookie->char_h;
    area[rx] = area[lx] +
        abs(x_jump) * t2g->cookie->char_w;
    area[ly] = area[uy] +
        abs(y_jump) * t2g->cookie->char_h;
    area[rx + 2] = to_scroll.g_x +
        to_scroll.g_w - 1;
    area[ly + 2] = to_scroll.g_y +
        to_scroll.g_h - 1;
/* Den oben ermittelten Bereich verschieben */
    graf_mouse(M_OFF, 0L);
    source.fd_addr = 0L;
    dest = source;
    rc_grect_to_array(&to_scroll, clip);
    vs_clip(t2g->cookie->vdi_handle, 1, clip);
    vro_cpyfm(t2g->cookie->vdi_handle, S_ONLY,
        area, &source, &dest);
    vs_clip(t2g->cookie->vdi_handle, 0, clip);
    graf_mouse(M_ON, 0L);
/* Die freigewordenen Bereiche neuzeichnen */
    rect.g_w =
        abs(x_jump) * t2g->cookie->char_w;
    rect.g_h = winwork.g_h;
    rect.g_x = (x_jump < 0) ? area[0] :
        (area[2] - rect.g_w + 1);
    rect.g_y = winwork.g_y;
    redraw_window(win, &rect, do_redraw);
    rect.g_w = winwork.g_w;
    rect.g_h =
        abs(y_jump) * t2g->cookie->char_h;
    rect.g_x = winwork.g_x;
    rect.g_y = (y_jump < 0) ? area[1] :
        (area[3] - rect.g_h + 1);
    redraw_window(win, &rect, do_redraw);
}

/*
 * adjust_sliders
 *
 * Setzt die Slidergrîûen und -positionen passend
 * zu den aktuellen Gegebenheiten neu.
 */
void adjust_sliders(void)
{
    WORD    xslsize, yslsize,
            xslpos, yslpos;

    calc_t2gsliders(&xslsize, &yslsize,
        &xslpos, &yslpos);
    wind_set(win, WF_HSLSIZE, xslsize);
    wind_set(win, WF_HSLIDE, xslpos);
    wind_set(win, WF_VSLSIZE, yslsize);
    wind_set(win, WF_VSLIDE, yslpos);
}

/*
 * menu_selected
 *
 * Reagiert auf das AnwÑhlen eines
 * MenÅeintrages.
 *
 * Eingabe:
 * title: Aktivierter MenÅtitel
 * item: Aktivierter MenÅeintrag
 */
void menu_selected(WORD title, WORD item)
{
    switch (item)
    {
        case M_ABOUT:
            menu_about();
            break;
        case M_RUNTTP:
            menu_runprg("*.TTP",
                "TTP-Programm auswÑhlen:");
            break;
        case M_RUNTOS:
            menu_runprg("*.TOS",
                "TOS-Programm auswÑhlen:");
            break;
        case M_PRINT:
            menu_print();
            break;
        case M_DELETE:
            menu_delete();
            break;
        case M_QUIT:
            menu_quit();
            break;
        case M_FONT:
            menu_font();
            break;
        case M_CURSOR:
            cursor ^= 1;
            check_menu();
            break;
        case M_WRAP:
            wrap ^= 1;
            check_menu();
            break;
    }
    menu_tnormal(T2G_MENU, title, 1);
}

/*
 * menu_about
 *
 * Stellt den Infodialog von TOS2GEM dar.
 */
void menu_about(void)
{
    do_dialog(T2G_INFO, 0, 0L);
}

/*
 * menu_runprg
 *
 * Startet ein TOS- bzw. TTP-Programm, das per
 * Fileselectbox ermittelt wird (mit vorgegebener
 * Extension). Sollte das TOS2GEM-Fenster bei
 * Aufruf der Funktion nicht komplett sichtbar
 * sein, erhÑlt man eine entsprechende Meldung und
 * die Funktion wird abgebrochen. Handelt es sich
 * bei der vorgegebenen Extension um "*.TTP" wird
 * nach einer Kommandozeile gefragt. Liefert das
 * aufgerufene Programm einen Fehler zurÅck, wird
 * eine entsprechende Dialogbox dargestellt.
 *
 * Eingabe:
 * ext: Vorgegebene Programm-Endung fÅr die
 *      Dateiauswahl
 * title: Titelzeile fÅr die Dateiauswahl
 */
void menu_runprg(char *ext, char *title)
{
    WORD    button,
            len;
    char    name[256],
            begin[4],
            *backslash,
            commandline[128];
    
/*
 * Melden, wenn das TOS2GEM-Fenster zur Zeit nicht
 * vollstÑndig sichtbar ist (TOS2GEM kann (noch)
 * kein Clipping mit mehreren Rechtecken)
 */
    if (!window_visible())
    {
        form_alert(1, T2G_NVIS);
        return;
    }
/* Nach einem Filenamen fragen */
    strcat(tos_path, ext);
    strcpy(name, last_prgnam);
    if (!fileselect(tos_path, name, &button,
        title))
    {
        return;
    }
    if ((backslash = strrchr(tos_path, '\\')) !=
        NULL)
    {
        backslash[1] = 0;
    }
    if (!button)
        return;
    if ((backslash = strrchr(name, '\\')) != NULL)
        strcpy(last_prgnam, &backslash[1]);
    strcpy(commandline, "");
    len = (WORD)strlen(name);
    if (!stricmp(ext, "*.TTP"))
    {
/*
 * Soll ein TTP-Programm gestartet werden, nach
 * der Kommandozeile fragen
 */
        if (len > 29)
        {
            strncpy(begin, name, 3);
            begin[3] = 0;
            backslash = strrchr(&name[len - 23],
                '\\');
            if (backslash == NULL)
                backslash = &name[len - 23];
            sprintf(T2G_CMDL[C_PRGNAM].ob_spec.
                free_string, "%s...%s:", begin,
                backslash);
        }
        else
        {
            sprintf(T2G_CMDL[C_PRGNAM].ob_spec.
                free_string, "%s:", name);
        }
        if (do_dialog(T2G_CMDL, 0, 0L) ==
            C_ABBR)
        {
            return;
        }
        strcpy(&commandline[1],
            T2G_CMDL[C_CLINE1].ob_spec.tedinfo->
            te_ptext);
        strcat(&commandline[1],
            T2G_CMDL[C_CLINE2].ob_spec.tedinfo->
            te_ptext);
        strcat(&commandline[1],
            T2G_CMDL[C_CLINE3].ob_spec.tedinfo->
            te_ptext);
        strcat(&commandline[1],
            T2G_CMDL[C_CLINE4].ob_spec.tedinfo->
            te_ptext);
        commandline[0] = (char)
            strlen(&commandline[1]);
    }
/* Das Programm aufrufen */
    start_program(name, commandline);
}

/*
 * start_program
 *
 * Startet ein bestimmtes TOS-Programm unter
 * Benutzung von TOS2GEM. Trat bei dessen Ende ein
 * Fehler auf, wird dieser in einer Dialogbox
 * angezeigt (im Klartext).
 *
 * Eingabe:
 * prgname: Pfad des zu startenden Programms
 * cmdline: Zu Åbergebende Kommandozeile
 */
void start_program(char *prgname, char *cmdline)
{
    WORD    len;
    LONG    ret_code;
    char    *environment,
            begin[4],
            *backslash,
            *err;

/*
 * Die Ausgabeumlenkung von TOS2GEM wieder
 * aktivieren; dabei paût sich TOS2GEM automatisch
 * an énderungen der Position und/oder Grîûe des
 * sichtbaren Bereichs oder des Zeichensatzes an.
 */
    wind_update(BEG_UPDATE);
    wind_update(BEG_MCTRL);
    graf_mouse(M_OFF, 0L);
    menu_bar(T2G_MENU, 0);
    (t2g->cookie->switch_output)();
    set_cursor_and_wrap();
/*
 * Bei Bedarf neues Environment erzeugen (wenn
 * eine der Variablen LINES, COLUMNS oder ROWS
 * nicht existiert)
 */
    environment = NULL;
    if ((getenv("LINES") == NULL) ||
        (getenv("ROWS") == NULL) ||
        (getenv("COLUMNS") == NULL))
    {
        environment = create_environment();
    }
/*
 * Das Programm aufrufen. Alle Ausgaben werden von
 * TOS2GEM abgefangen und in unser Fenster
 * umgeleitet.
 */
    ret_code = Pexec(0, prgname, cmdline,
        environment);
    if (environment != NULL)
        free(environment);
/*
 * Nach Ende des aufgerufenen Programms TOS2GEM
 * wieder deaktivieren (bzw. die Ausgabeumlenkung)
 */
    (t2g->cookie->switch_output)();
    menu_bar(T2G_MENU, 1);
    graf_mouse(M_ON, 0L);
    wind_update(END_MCTRL);
    wind_update(END_UPDATE);
/*
 * Die letzten Offset-Werte aus der Cookie-
 * Struktur auslesen
 */
    t2g->cur_text_offset =
        t2g->cookie->text_offset;
    t2g->cur_y_offset = t2g->cookie->y_offset;
    t2g->cur_x_offset = 0;
    has_contents = 1;
    disable_menu();
/* Die Slider an den neuen Inhalt anpassen */
    adjust_sliders();
    if (ret_code && (ret_code != (UWORD)-32))
    {
/* Trat ein Fehler auf, den User informieren */
        len = (WORD)strlen(prgname);
        if (len > 33)
        {
            strncpy(begin, prgname, 3);
            begin[3] = 0;
            backslash =
                strrchr(&prgname[len - 27], '\\');
            if (backslash == NULL)
                backslash = &prgname[len - 27];
            sprintf(T2G_ERR[E_PRGNAM].ob_spec.
                free_string, "%s...%s:", begin,
                backslash);
        }
        else
        {
            sprintf(T2G_ERR[E_PRGNAM].ob_spec.
                free_string, "%s:", prgname);
        }
        ret_code = (WORD)ret_code;
        if ((ret_code < MAX_NEG_ERRNR) ||
            (ret_code > MAX_POS_ERRNR))
        {
            err = UNKNOWN;
        }
        else
        {
            if (ret_code < 0)
                err = neg_err_txt[-ret_code];
            else
                err = pos_err_txt[ret_code];
        }
        sprintf(T2G_ERR[E_ERRTXT].ob_spec.
            free_string, "%s (%ld)" ,err,
            ret_code);
        do_dialog(T2G_ERR, 0, 0L);
    }
}

/*
 * set_cursor_and_wrap
 *
 * Gibt, je nach Zustand der Variablen cursor und
 * wrap, die Escapesequenzen zum Ein- bzw.
 * Ausschalten der beiden Optionen aus.
 */
void set_cursor_and_wrap(void)
{
    printf("\033%c\033%c", cursor ? 'e' : 'f',
        wrap ? 'v' : 'w');
    fflush(stdout);
}

/*
 * create_environment
 *
 * Legt ein neues Environment fÅr das aufzurufende
 * Programm an, das um LINES/ROWS und/oder um
 * COLUMNS entsprechend der Grîûe des TOS2GEM-
 * Bildschirms ergÑnzt wird.
 *
 * RÅckgabe:
 * NULL: Es war kein Speicher mehr fÅr das neue
 *       Environment frei
 * sonst: Zeiger auf neues Environment, muû vom
 *        Aufrufer spÑter mittels free wieder
 *        freigegeben werden
 */
char *create_environment(void)
{
    char    *new_env,
            *old_env,
            *i,
            *j,
            lines[12],
            rows[11],
            columns[14];
    ULONG   size;
    WORD    need_lines,
            need_rows,
            need_columns;

/* Die Grîûe des alten Environments feststellen */
    old_env = _BasPag->p_env;
    size = 0L;
    if (old_env != NULL)
    {
        while (*old_env)
        {
            while (*old_env++)
                size++;
            size++;
        }
    }
/*
 * Feststellen, welche neuen Variablen benîtigt
 * werden und deren LÑngen zur GesamtlÑnge des
 * Environments addieren
 */
    need_lines = (getenv("LINES") == NULL);
    need_rows = (getenv("ROWS") == NULL);
    need_columns = (getenv("COLUMNS") == NULL);
    sprintf(lines, "LINES=%d", t2g->cookie->y_size);
    sprintf(rows, "ROWS=%d", t2g->cookie->y_size);
    sprintf(columns, "COLUMNS=%d",
        t2g->cookie->x_size);
    if (need_lines)
        size += strlen(lines) + 1;
    if (need_rows)
        size += strlen(rows) + 1;
    if (need_columns)
        size += strlen(columns) + 1;
    size++;
/*
 * Speicher fÅr neues Environment anfordern, wenn
 * nicht mîglich, NULL zurÅckliefern (dann wird
 * bei Pexec das alte Environment benutzt)
 */
    if ((new_env = malloc(size)) == NULL)
        return(NULL);
/*
 * Das alte Environment kopieren und die
 * benîtigten Variablen hinzufÅgen
 */
    j = new_env;
    if (old_env != _BasPag->p_env)
    {
        for (i = _BasPag->p_env; i != old_env;
            *j++ = *i++);
    }
    if (need_lines)
        j += sprintf(j, "%s%c", lines, 0);
    if (need_rows)
        j += sprintf(j, "%s%c", rows, 0);
    if (need_columns)
        j += sprintf(j, "%s%c", columns, 0);
    sprintf(j, "%c", 0);
    return(new_env);
}

/*
 * menu_print
 *
 * Gibt den Inhalt des TOS2GEM-Fensters auf dem
 * Drucker aus.
 */
void menu_print(void)
{
    WORD    printer,
            i;

/*
 * Versuchen, den Drucker fÅr die Ausgabe zu
 * îffnen (diese Methode kann bei Filelocking von
 * Vorteil sein)
 */
    if ((printer = (WORD)Fcreate("PRN:", 0)) < -3)
    {
        form_alert(1, T2G_PLCK);
        return;
    }
/* PrÅfen, ob der Drucker ausgabebereit ist */
    while (!Cprnos())
    {
        if (form_alert(2, T2G_PRNT) == 1)
        {
            Fclose(printer);
            return;
        }
    }
/*
 * Wenn ja, alle Zeilen ausgeben (ohne jegliche
 * Umwandlungen)
 */
    for (i = 0; i < t2g->cookie->text_offset +
        t2g->cookie->y_size; i++)
    {
        if (Fwrite(printer, t2g->cookie->x_size,
            &t2g->cookie->text_buffer[i *
            (t2g->cookie->x_size + 1)]) !=
            t2g->cookie->x_size)
        {
            break;
        }
    }
/* Zum Schluû das Druckerfile wieder schliessen */
    Fclose(printer);
}

/*
 * menu_delete
 *
 * Lîscht das TOS2GEM-Fenster. War es nicht leer,
 * wird vorher nachgefragt. Das Fenster muû dazu
 * komplett sichtbar sein, falls dies nicht der
 * Fall ist, wird eine entsprechende Meldung
 * ausgegeben.
 */
void menu_delete(void)
{
/*
 * Auch zum Lîschen muû das TOS2GEM-Fenster
 * (noch) komplett sichtbar sein
 */
    if (!window_visible())
    {
        form_alert(1, T2G_NVIS);
        return;
    }
/* Nachfragen, ob man Åberhaupt lîschen will */
    if (form_alert(2, T2G_DEL) == 1)
        return;
    graf_mouse(M_OFF, 0L);
    change_t2gstats(&window, &winwork,
        T2G_CLEARBUFFER);
    graf_mouse(M_ON, 0L);
/*
 * Die programminternen Variablen zurÅcksetzen und
 * die Slider korrigieren
 */
    has_contents = 0;
    disable_menu();
    adjust_sliders();
}

/*
 * window_visible
 *
 * PrÅft, ob der Arbeitsbereich des
 * TOS2GEM-Fensters komplett sichtbar ist.
 *
 * RÅckgabe:
 * 0: Fenster ist nur teilweise sichtbar
 * 1: Arbeitsbereich ist unverdeckt
 */
WORD window_visible(void)
{
    WORD    visible,
            w,
            h;
    GRECT   rect;

    wind_get(win, WF_FIRSTXYWH,
        &rect.g_x, &rect.g_y,
        &rect.g_w, &rect.g_h);
    w = rect.g_w;
    h = rect.g_h;
    rc_intersect(&winwork, &rect);
/*
 * Das Fenster ist dann komplett sichtbar, wenn
 * die SchnittflÑche zwischen Arbeitsbereich und
 * ersten Rechteck der Rechteckliste gleich dem
 * Arbeitsbereich ist
 */
    visible = rc_equal(&winwork, &rect);
/*
 * Im Normalfall mÅûte man nach einem
 * WF_FIRSTXYWH nicht den Rest der Liste auch noch
 * durchgehen, aber die Geneva-AES haben hier
 * einen Fehler, der dazu fÅhrt, daû die
 * Rechteckliste des Fensters durcheinanderkommt
 */
    while (w && h)
    {
        wind_get(win, WF_NEXTXYWH,
            &rect.g_x, &rect.g_y, &w, &h);
    }
    return(visible);
}

/*
 * menu_quit
 *
 * Setzt die globale Variable quit auf 1, wenn
 * entweder das TOS2GEM-Fenster leer ist, oder
 * eine Sicherheitsabfrage postiv beantwortet
 * wurde. ("Leer" heiût in diesem Zusammenhang,
 * daû seit dem letzten Lîschen kein Programm mehr
 * gestartet wurde.)
 */
void menu_quit(void)
{
    if (has_contents)
    {
        if (form_alert(2, T2G_ENDE) == 1)
            return;
    }
    quit = 1;
}

/*
 * menu_font
 *
 * Stellt eine Dialogbox zur énderung der
 * Fontgrîûe im TOS2GEM-Fenster dar und Ñndert
 * diese danach entsprechend. Zur Wahl steht nur
 * der Systemfont.
 */
void menu_font(void)
{
    WORD    old_height,
            height;

    old_height = atoi(T2G_FONT[F_HEIGHT].ob_spec.
        free_string);
    if (do_dialog(T2G_FONT, 0, do_fontselect) ==
        F_ABBR)
    {
        sprintf(T2G_FONT[F_HEIGHT].ob_spec.
            free_string, "%2d", old_height);
        return;
    }
    height = atoi(T2G_FONT[F_HEIGHT].ob_spec.
        free_string);
    if (height == old_height)
        return;
    t2g->fontsize = height;
    change_t2gstats(&window, &winwork,
        T2G_CHGFONT);
    wind_set(win, WF_CURRXYWH,
        window.g_x, window.g_y,
        window.g_w, window.g_h);
    calc_t2gwindow(&window, &winwork,
        t2g->columns, t2g->lines);
    max_window = window;
    wind_set(win, WF_CURRXYWH,
        window.g_x, window.g_y,
        window.g_w, window.g_h);
/*
 * Das zweimalige Setzen der Fensterausmaûe,
 * einmal mit angepaûter alter Grîûe, dann mit
 * neu berechneter Maximalgrîûe, hat den Sinn, fÅr
 * den Fuller eine neue, angepaûte "Previous"-
 * Grîûe bereitzustellen
 */
    redraw_window(win, &winwork, do_redraw);
    adjust_sliders();
}

/*
 * do_fontselect
 *
 * Aktionsroutine fÅr do_dialog, die fÅr den
 * Font-Dialog benutzt wird. Hier wird auf das
 * Anklicken der Pfeile reagiert.
 */
WORD do_fontselect(OBJECT *tree, WORD obj)
{
    WORD    old_height,
            new_height,
            x, y;

    obj &= 0x7fff;
    old_height = atoi(tree[F_HEIGHT].ob_spec.
        free_string);
    new_height = old_height;
    if (obj == F_UP)
    {
        switch (old_height)
        {
            case 8:
            case 9:
                new_height++;
                break;
            case 10:
                new_height = 16;
                break;
            case 16:
            case 18:
                new_height += 2;
        }
    }
    if (obj == F_DOWN)
    {
        switch (old_height)
        {
            case 20:
            case 18:
                new_height -= 2;
                break;
            case 16:
                new_height = 10;
                break;
            case 10:
            case 9:
                new_height--;
                break;
        }
    }
    if (old_height != new_height)
    {
        sprintf(tree[F_HEIGHT].ob_spec.
            free_string, "%2d", new_height);
        objc_offset(tree, F_HBOX, &x, &y);
        objc_draw(tree, F_HBOX, 1, x, y,
            tree[F_HBOX].ob_width,
            tree[F_HBOX].ob_height);
    }
    return((obj != F_ABBR) && (obj != F_OK));
}

/*
 * fileselect
 *
 * Universelle Fileselector-Routine, erhÑlt die
 * gleichen Parameter wie fsel_exinput. Im
 * Gegensatz zum Original enthÑlt name am Ende
 * den kompletten Zugriffspfad des ausgewÑhlten
 * Objekts. Es erfolgt ein Test, ob fsel_exinput
 * aufgerufen werden kann (dabei wird auch der
 * 'FSEL'-Cookie geprÅft), wenn nicht, wird nur
 * fsel_input benutzt.
 *
 * Eingabe:
 * path: Absoluter Suchpfad inklusive Suchmaske
 * name: Absoluter Zugriffspfad der ausgewÑhlten
 *       Datei
 * button: Zeiger auf Wert des Exit-Buttons. Nach
 *         dem Aufruf ist dies Eins fÅr "OK", 0
 *         fÅr Abbruch.
 * title: Zu benutzende Titelzeile (wird
 *        ignoriert, wenn kein fsel_exinput
 *        vorhanden ist).
 *
 * RÅckgabe:
 * 0: Fehler bei Dateiauswahl aufgetreten
 * sonst: Dateiauswahl OK, Inhalt von button
 *        beachten!
 */
WORD fileselect(char *path, char *name,
    WORD *button, char *title)
{
    char    temp1[129], temp2[129];
    WORD    i, fsel_ok;

    wind_update(BEG_UPDATE);
/*
 * PrÅfen, ob fsel_exinput aufgerufen werden kann,
 * dabei wird auch der FSEL-cookie geprÅft, der
 * z.B. von SELECTRIC angelegt wird
 */
    if (((_GemParBlk.global[0] >= 0x0140) &&
        (_GemParBlk.global[0] < 0x0200)) ||
        (_GemParBlk.global[0] >= 0x0300) ||
        get_cookie('FSEL', 0L))
    {
        fsel_ok = fsel_exinput(path, name, button,
        title);
    }
    else
        fsel_ok = fsel_input(path, name, button);
    wind_update(END_UPDATE);

    if (fsel_ok)
    {
/*
 * Dateiauswahl war erfolgreich, jetzt den
 * Zugriffspfad fÅr die ausgewÑhlte Datei
 * zusammensetzen, wenn der Dialog mit "OK"
 * beendet wurde.
 */
        if (*button)
        {
            strcpy(temp1, path);
            
            i = (WORD)strlen(temp1) - 1;
            
            while ((temp1[i] != '\\') && (i >= 0))
                temp1[i--] = 0;
            
            strcpy(temp2, name);
            strcpy(name, temp1);
            strcat(name, temp2);
        }
    }
    return(fsel_ok);
}

/*
 * redraw_window
 *
 * Allgemeine Funktion zum Fensterneuzeichnen. Sie
 * geht die komplette Rechteckliste des
 * gegebenen Fensters durch und ÅberprÅft auf
 * öberschneidungen mit dem neuzuzeichnenden
 * Bereich. Sind diese vorhanden, wird die als
 * Parameter Åbergebene Redraw-Funktion aufgerufen,
 * die das Window-Handle und den zu zeichnenden
 * Bereich erhÑlt.
 *
 * Eingabe:
 * wind: Handle des neuzuzeichnenden Fensters
 * area: Zeiger auf GRECT-Struktur des vom Redraw
 *       betroffenen Bereichs
 * redraw_func: Zeiger auf Funktion, die fÅr jeden
 *              neuzuzeichnenden Teilbereich
 *              aufgerufen werden soll. Als
 *              Parameter erhÑlt diese das Handle
 *              und einen Zeiger auf das
 *              neuzuzeichnende Rechteck (als
 *              GRECT).
 */
void redraw_window(WORD wind, GRECT *area,
    void (*redraw_func)(WORD wind, GRECT *area))
{
    GRECT   box;

    graf_mouse(M_OFF, 0L);
    wind_update(BEG_UPDATE);
    wind_get(wind, WF_FIRSTXYWH, &box.g_x,
        &box.g_y, &box.g_w, &box.g_h);
    while (box.g_w && box.g_h)
    {
/*
 * Die Redraw-Funktion wird nur aufgerufen, wenn
 * das aktuelle Rechteck sichtbar ist und
 * innerhalb des betroffenen Bereichs liegt
 */
        if (rc_intersect(&desk, &box) &&
            rc_intersect(area, &box))
        {
            (*redraw_func)(wind, &box);
        }
        wind_get(wind, WF_NEXTXYWH,
            &box.g_x, &box.g_y,
            &box.g_w, &box.g_h);
    }
    wind_update(END_UPDATE);
    graf_mouse(M_ON, 0L);
}

/*
 * rc_intersect
 *
 * Untersucht zwei Rechtecke auf öberschneidung.
 * Gibt es eine, liefert die Funktion 1, sonst
 * 0. Die Koordinaten des zweiten Rechtecks
 * werden bei öberschneidung durch das
 * Schnittrechteck ersetzt.
 *
 * Eingabe:
 * one: Zeiger auf GRECT-Struktur des ersten
 *      Rechtecks
 * two: Zeiger auf zweites Rechteck
 *
 * RÅckgabe:
 * 0: Keine öberschneidung, beide Rechtecke
 *    unverÑndert
 * 1: Rechtecke Åberschneiden sich, two enthÑlt
 *    Koordinaten des Schnittrechtecks
 */
WORD rc_intersect(GRECT *one, GRECT *two)
{
    WORD    x, y, w, h;

    x = MAX(two->g_x, one->g_x);
    y = MAX(two->g_y, one->g_y);
    w = MIN(two->g_x + two->g_w,
        one->g_x + one->g_w);
    h = MIN(two->g_y + two->g_h,
        one->g_y + one->g_h);

    if ((w > x) && (h > y))
    {
        two->g_x = x;
        two->g_y = y;
        two->g_w = w - x;
        two->g_h = h - y;
        return(1);
    }
    return(0);
}

/*
 * rc_equal
 *
 * PrÅft zwei Rechtecke auf Gleichheit
 *
 * Eingabe:
 * one: Zeiger auf GRECT-Struktur des ersten
 *      Rechtecks
 * two: Zeiger auf zweites Rechteck
 *
 * RÅckgabe:
 * 0: Keine öbereinstimmung
 * 1: one und two beschreiben exakt das gleiche
 *    Rechteck
 */
WORD rc_equal(GRECT *one, GRECT *two)
{
    if ((one->g_x == two->g_x) &&
        (one->g_y == two->g_y) &&
        (one->g_w == two->g_w) &&
        (one->g_h == two->g_h))
    {
        return(1);
    }
    return(0);
}

/*
 * rc_grect_to_array
 *
 * Wandelt eine AES-Rechteckstruktur in VDI-
 * Rechteckkoordinaten um.
 *
 * Eingabe:
 * rect: Zeiger auf die Rechteckstruktur
 * xy: Zeiger auf das WORD-Array, in dem die VDI-
 *     Koordinaten gespeichert werden sollen
 */
void rc_grect_to_array(GRECT *rect, WORD *xy)
{
    xy[0] = rect->g_x;
    xy[1] = rect->g_y;
    xy[2] = xy[0] + rect->g_w - 1;
    xy[3] = xy[1] + rect->g_h - 1;
}

/*
 * do_dialog
 *
 * Universelle Dialogbearbeitungsroutine. Sperrt
 * Bildschirm und Maus, zentriert und zeichnet den
 * Dialog und ruft form_do auf. Wurde eine
 * Reaktionsfunktion Åbergeben, wird form_do so
 * lange nochmals aufgerufen, bis diese 0
 * liefert.
 *
 * Eingabe:
 * tree: Zeiger auf zu benutzenden Objektbaum
 * sobj: Startobjekt fÅr Edit-Cursor
 * action: Zeiger auf eine Funktion, die als
 *         Parameter den Baumzeiger und das
 *         ausgewÑhlte Objekt erhÑlt. Sie
 *         wird nach jedem form_do aufgerufen
 *         und sollte 0 zurÅckgeben, wenn der
 *         Dialog beendet werden soll, sonst
 *         1. öbergibt man fÅr Action einen
 *         Leerzeiger, wird form_do nur
 *         einmal aufgerufen.
 *
 * RÅckgabe:
 * Zuletzt ausgewÑhltes Objekt (gesetztes 15. Bit
 * steht wie gewohnt fÅr Doppelklick)
 */
WORD do_dialog(OBJECT *tree, WORD sobj,
    WORD (*action)(OBJECT *tree, WORD obj))
{
    WORD    x, y, w, h,
            cont,
            obj,
            r_obj;

    wind_update(BEG_UPDATE);
    wind_update(BEG_MCTRL);
/* Dialog zentrieren und zeichnen */
    form_center(tree, &x, &y, &w, &h);
    form_dial(FMD_START, x, y, w, h, x, y, w, h);
    objc_draw(tree, ROOT, MAX_DEPTH,
        x, y, w, h);
/* form_do-Schleife */
    do
    {
/*
 * Dialog bearbeiten, danach ggf. die Reaktions-
 * funktion aufrufen. Je nach deren RÅckgabewert
 * Dialogbearbeitung fortsetzen oder beenden.
 * (Wurde keine Reaktiosnfunktion Åbergeben, wird
 * die Schleife bereits nach dem ersten form_do-
 * Aufruf beendent)
 */
        obj = form_do(tree, sobj);
        if (action != NULL)
            cont = (*action)(tree, obj);
        else
            cont = 0;
    } while (cont);
/*
 * Ist das zuletzt angewÑhlte Objekt noch
 * selektiert, den Status zurÅcksetzen. Dabei
 * vorher das eventuelle Doppelklickbit lîschen.
 */
    r_obj = obj & 0x7fff;
    if ((tree[r_obj].ob_flags & SELECTABLE) &&
        (tree[r_obj].ob_state & SELECTED))
    {
        tree[r_obj].ob_state &= ~SELECTED;
    }
/* Dialogbearbeitung "formell" beenden */
    form_dial(FMD_FINISH, x, y, w, h, x, y, w, h);
    wind_update(END_MCTRL);
    wind_update(END_UPDATE);
/* Zuletzt angewÑhltes Objekt zurÅckgeben */
    return(obj);
}

/*
 * get_cookie:
 *
 * PrÅft, ob ein bestimmter Cookie vorhanden ist
 * und liefert, wenn gewÅnscht, dessen Wert.
 *
 * Eingabe:
 * cookie: Zu suchender Cookie (z.B. 'MiNT')
 * value: Zeiger auf einen vorzeichenlosen Long,
 *        in den der Wert des Cookies geschrieben
 *        werden soll. Ist dies nicht gewÅnscht/
 *        erforderlich, einen Nullzeiger Åber-
 *        geben.
 *
 * RÅckgabe:
 * 0: Cookie nicht vorhanden, value unbeeinfluût
 * 1: Cookie vorhanden, Wert steht in value (wenn
 *    value kein Nullpointer ist)
 */
WORD get_cookie(ULONG cookie, ULONG *value)
{
    LONG    *jar,
            old_stack;
    
    /*
     * Den Zeiger auf den Cookie-Jar ermitteln,
     * dabei ggf. in den Supervisor-Modus
     * wechseln.
     */
    if (Super((void *)1L) == 0L)
    {
        old_stack = Super(0L);
        jar = *((LONG **)0x5a0L);
        Super((void *)old_stack);
    }
    else
        jar = *(LONG **)0x5a0;
    
    /*
     * Ist die "Keksdose" leer, gleich Null zu-
     * rÅckliefern, da ja gar kein Cookie
     * vorhanden ist.
     */
    if (jar == 0L)
        return(0);
    
    /*
     * Sonst den Cookie-Jar bis zum Ende durch-
     * suchen und im Erfolgsfall 1 zurÅckliefern.
     * Falls value kein Nullpointer war, vorher
     * den Wert des Cookies dort eintragen.
     */
    while (jar[0])
    {
        if (jar[0] == cookie)
        {
            if (value != 0L)
                *value = jar[1];
            
            return(1);
        }
        
        jar += 2;
    }
    /*
     * Bis zum Ende gesucht und nichts gefunden,
     * also 0 zurÅckgeben.
     */
    return(0);
}

/* EOF */
