/*3456789012345678901234567890123456789012345678*/
/*
 * minidemo.c vom 18.01.1995
 * (c)1995 by MAXON-Computer
 *
 * Autor:
 * Thomas Binder
 *
 * Zweck:
 * Sehr einfaches Beispielprogramm fÅr TOS2GEM und
 * die Anwendung der TOS2GEM-Library von Dirk
 * Klemmt.
 *
 * History:
 * 07.01.1995: Erstellung
 * 08.01.1995: Kommentierung
 * 09.01.1995: Cconis und Cconin-Aufrufe durch ein
 *             evnt_multi ersetzt. Dadurch wird
 *             das Programm zwar viel langsamer
 *             (was nicht unbedingt ein Nachteil
 *             ist), lÑuft dafÅr aber auch ohne
 *             Probleme mit Multitasking-Systemen.
 * 18.01.1995: Anpassung an die neueste Version
 *             der TOS2GEM-Library
 */

#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <string.h>
#include <portab.h>
/* Pfad ggf. korrigieren */
#include "..\uset2g\uset2g.h"

#define WI_KIND NAME|MOVER
#define DTEXT   " TOS2GEM "

WORD main(void)
{
    GRECT   work,
            border;
    WORD    window,
            dummy,
            event,
            x, y,
            dx, dy;

    if (appl_init() < 0)
        return(1);

    graf_mouse(ARROW, 0L);
/*
 * init_t2g Åbernimmt die gesamte Anmeldung bei
 * TOS2GEM und liefert einen Wert <> 0 zurÅck,
 * wenn dabei ein Fehler aufgetreten ist. In
 * diesem Fall befindet sich das System im
 * gleichen Zustand wie vor dem Aufruf, d.h. aller
 * evtl. allozierter Speicher und geîffnete VDI-
 * Workstations sind freigegeben.
 * Der hier folgende Aufruf meldet bei TOS2GEM
 * einen TOS-Screen mit 80x25 Zeichen ohne
 * Scrollback an, mit Zeichensatz 1 (Systemfont)
 * in Grîûe 9 und Farbe schwarz. Es wird keine
 * Mindestversion von TOS2GEM vorausgesetzt, das
 * benutzte Fenster soll die in WI_KIND gesetzten
 * Elemente haben. Auûerdem wird kein Extra-Handle
 * fÅr den Cursor benîtigt, und die Environment-
 * Variablen LINES/ROWS und COLUMNS sollen nicht
 * berÅcksichtigt werden.
 */
    switch (init_t2g(80, 25, 0, 1, 9, BLACK, 0,
        WI_KIND, 0, 0, 0))
    {
        case T2G_NOTINSTALLED:
            form_alert(1, "[3][TOS2GEM nicht|"
                "installiert!][ Abbruch ]");
            appl_exit();
            return(1);
        case T2G_CANNOTRESERVE:
            form_alert(1, "[3][TOS2GEM kann nicht"
                "|reserviert werden!]"
                "[ Abbruch ]");
            appl_exit();
            return(1);
        case T2G_NOVDIHANDLE:
            form_alert(1, "[3][Kein VDI-Handle|"
                "mehr frei!][ Abbruch ]");
            appl_exit();
            return(1);
        case T2G_OUTOFMEMORY:
            form_alert(1, "[3][Zu wenig Speicher|"
                "frei!][ Abbruch ]");
            appl_exit();
            return(1);
        case T2G_NOERROR:
            break;
/*
 * Es ist angebracht, auch auf bislang nicht
 * definierte Fehlercodes zu reagieren, falls das
 * Programm irgendwann mit einer neueren Version
 * der TOS2GEM-Library compiliert/gelinkt wird
 */
        default:
            form_alert(1, "[3][Unbekannter Fehler"
                "|bei init_t2g aufge-|treten!]"
                "[ Abbruch ]");
            appl_exit();
            return(1);
    }
/*
 * Jetzt werden Rahmen und Arbeitsbereich eines
 * maximal groûen Fensters fÅr den TOS2GEM-Screen
 * ermittelt und danach ein entsprechendes Fenster
 * bei den AES angefordert. Bei diesem Aufruf
 * werden die dazugehîrigen Parameter von TOS2GEM
 * automatisch auf die ermittelte Grîûe angepaût.
 */
    calc_t2gwindow(&border, &work, 0, 0);
    if ((window = wind_create(WI_KIND,
        border.g_x, border.g_y,
        border.g_w, border.g_h)) < 0)
    {
        form_alert(1, "[3][Kein Fenster-Handle|"
            "verfÅgbar!][ Abbruch ]");
/*
 * Wichtig: Soll das Programm nach erfolgreichem
 * init_t2g beendet werden, muû *unbedingt*
 * exit_t2g aufgerufen werden, um TOS2GEM und die
 * benutzten Systemresourcen wieder freizugeben
 */
        exit_t2g();
        appl_exit();
        return(1);
    }
    wind_set(window, WF_NAME,
        " TOS2GEM-Minidemo ");
    wind_open(window, border.g_x, border.g_y,
        border.g_w, border.g_h);
/*
 * FÅr den gleich folgenden init-Aufruf muû der
 * Bildschirm fÅr uns reserviert und die Maus
 * ausgeschaltet sein
 */
    graf_mouse(M_OFF, 0L);
    wind_update(BEG_UPDATE);
    wind_update(BEG_MCTRL);
/*
 * Jetzt wird TOS2GEM durch einen Aufruf der init-
 * Funktion aus dem Cookie initialisiert, d.h. der
 * als TOS-Screen angegebene Bereich des Screens
 * wird durch Zeichnen eines weiûen Rechtecks
 * gelîscht, TOS2GEM-interne Variablen
 * vorbereitet und die Ausgabeumlenkung aktiviert.
 * Diesen Aufruf *nie* vergessen, sonst gibt's
 * MÅll!
 */
    if (!t2g->cookie->init())
    {
        wind_update(END_MCTRL);
        wind_update(END_UPDATE);
        wind_close(window);
        wind_delete(window);
        graf_mouse(M_ON, 0L);
/*
 * Bei Benutzung der Library dÅrfte zwar kein
 * Fehler beim Aufruf der init-Funktion aus dem
 * Cookie auftreten, arbeitet man aber ohne, ist
 * es (zumindest in der Entwicklungsphase) sehr
 * ratsam, den RÅckgabewert zu prÅfen!
 */
        form_alert(1, "[3][Fehler bei "
            "Initialisierung|von TOS2GEM]"
            "[ Abbruch ]");
        exit_t2g();
        appl_exit();
        return(1);
    }
/*
 * Kleinere Spielereien. Alle Cconws-Ausgaben
 * werden von TOS2GEM in das vorher geîffnete
 * Fenster umgelenkt.
 */
    Cconws("Demonstration von TOS2GEM. \033f"
        "Zum Beenden eine Taste drÅcken!\n");
    x = 0;
    y = 2;
    dx = 3;
    dy = 3;
    for (;;)
    {
        event = evnt_multi(MU_TIMER|MU_KEYBD,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            NULL, 1, 0, &dummy, &dummy, &dummy,
            &dummy, &dummy, &dummy);
        if (event & MU_KEYBD)
            break;
        Cconws("\033Y");
        Cconout(y + 32);
        Cconout(x + 32);
        Cconws(DTEXT);
        x += dx;
        y += dy;
        if (y < 2)
        {
            dy = -dy;
            y = 2 - y;
        }
        if (y > 24)
        {
            dy = -dy;
            y = 48 - y;
        }
        if (x < 0)
        {
            dx = -dx;
            x = -x;
        }
        if ((x + (WORD)strlen(DTEXT)) > 79)
        {
            dx = -dx;
            x = 2 * (79 - (WORD)strlen(DTEXT)) -
                x;
        }
    }
/*
 * Zum Abschluû wird die Ausgabeumlenkung wieder
 * abgeschaltet. Prinzipiell wÑre das bei diesem
 * Beispielprogramm nicht nîtig, da TOS2GEM danach
 * sowieso wieder deaktiviert wird, aber im
 * Normalfall wird man das Ab- bzw. Umschalten der
 * Umlenkung per switch_output doch benîtigen.
 */
    t2g->cookie->switch_output();
    wind_update(END_MCTRL);
    wind_update(END_UPDATE);
    graf_mouse(M_ON, 0L);
    wind_close(window);
    wind_delete(window);
/*
 * Wie bereits erwÑhnt: Vor Programmende unbedingt
 * exit_t2g aufrufen!
 */
    exit_t2g();
    appl_exit();
    return(0);
}

/* EOF */
