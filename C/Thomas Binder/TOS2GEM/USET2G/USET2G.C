/*3456789012345678901234567890123456789012345678*/
/*
 * Library 'uset2g.lib' vom 20.01.1995
 *
 * Autor:   Dirk Klemmt
 *          Heimchenweg 41
 *          D-65929 Frankfurt am Main
 *          069/30 72 25
 * (c)1995 by MAXON-Computer
 * Email:   klemmt@informatik.uni-frankfurt.de
 *
 * Zweck:
 *
 * Diese Library dient dazu, die Benutzung von
 * TOS2GEM stark zu vereinfachen.
 * Dazu werden einige Routinen zur Verfuegung
 * gestellt, die Standardaufgaben erledigen und
 * auf Aenderungen des TOS2GEM-Screens reagieren.
 *
 * Compiler: Pure C 1.x
 *
 * History:
 *
 * 20.01.95:
 *   - dummen Bug in 'change_t2gstats' ausgebaut.
 *     Um auf den Erfolg von realloc zu pruefen,
 *     wurde != NULL getestet. Das ist natuerlich
 *     genau falsch herum. Deshalb klappte das
 *     Aendern der Werte nicht, wenn man gleich-
 *     zeitig die Puffergroesse aenderte. 
 * 19.01.95:
 *   - Beim ™ffnen von der VDI-Workstation fr das
 *     Cursor-Handle wurde nicht korrekt das AES-
 *     Handle fr den v_opnvwk-Aufruf vorbesetzt.
 * 17.01.95:
 *   - 'scroll_t2g' nach 'scroll_t2gwindow' umbe-
 *     nannt.
 * 14.01.95:
 *   - in die t2g-Struktur 2 neue Variablen aufge-
 *     nommen. fontnr und fontcol, damit diese in
 *     'change_t2gstats' auch geaendert werden
 *     koennen.
 * 11.01.95:
 *   - ein paar weitere Kommentare geschrieben.
 *   - 'calc_t2gwindow', 'change_t2gstats',
 *     'moved_t2gwindow' geben
 *     nun auch Returnwerte zurueck.
 *     Es wird zuerst getestet, ob T2G ueberhaupt
 *     schon installiert wurde und eventuell
 *     T2G_NOTINSTALLED zurueckgegeben.
 *   - in 'redraw_t2g' kann man nun uebergeben, ob
 *     mit oder ohne Clipping gezeichnet werden
 *     soll.
 * 10.01.95:
 *   - Kommentare geschrieben. So aehnlich wird
 *     dann auch der Text fuer den Artikel sein.
 *   - Fehler in 'change_t2gstats' ausgebaut.
 *     Erst max_lines setzen, dann realloc.
 *   - Fehler in 'init_t2g' ausgebaut. Es wurde
 *     max_lines schon gesetzt, bevor die Env-Var.
 *     ausgelesen wurden. Bei TRUE, bekam
 *     max_lines einen falschen Wert.
 *   - Fehler in 'init_t2g' ausgebaut. Wenn die
 *     Env-Vars. nicht ausgelesen wurden und man
 *     groessere Werte als die erlaubten ueberge-
 *     ben hatte, wurden die angepassten zwar in
 *     x/y_size eingetragen, aber nicht in
 *     t2g->lines/columns.
 *   - Ausserdem auch die Env-Var. auf Groesse
 *     getestet. Man weiss ja nie, was die Leute
 *     da so reinschreiben ;-).
 *   - define T2G_MAXLINES eingefuehrt. Das als
 *     unbeschraenkt zu lassen ist etwas unsinnig.
 *     Bisher hab ich MAXLINES auf 100 gesetzt.
 *     Sollte mehr als ausreichend sein.
 */
#include <stdlib.h>
#include <string.h>
#include <vdibind.h>
#include <aesbind.h>
#include <mintbind.h>
#include <portab.h>

#define TOS2GEM_LIB
#include "uset2g.h"

static BOOLEAN get_cookie( LONG cookie,
                           LONG *value );
static BOOLEAN rc_equal( GRECT *one, GRECT *two );
static BOOLEAN rc_intersect( GRECT *one,
                             GRECT *two );
static VOID rc_grect_to_array( GRECT *rect,
                               WORD *xy );

#define min(a, b)  ((a) < (b) ? (a) : (b))
#define max(a, b)  ((a) > (b) ? (a) : (b))

/*
 * Diese Routine initialisiert TOS2GEM. Sie fuehrt
 * dabei folgende Schritte durch:
 * 1. Speicher fuer T2G-Struktur allozieren.
 * 2. ueberpruefen, ob T2G installiert ist.
 * 3. Testen, ob T2G neu genug ist.
 * 4. T2G fuer unsere Anwendung reservieren.
 * 5. fuer T2G eine VDI-Workstation oeffnen.
 * Wenn jeweils einer dieser Schritte nicht
 * klappt, kann T2G nicht benutzt werden. Die
 * Initialisierungsroutine wird dann verlassen
 * und das System wieder in genau den Zustand
 * versetzt, der vor dem Aufruf der Routine vor-
 * handen war. Der gelieferte Return-Code gibt
 * Auskunft darueber, warum T2G nicht installiert
 * werden konnte.
 *
 * Klappt alles wird noch fuer den T2G-Cursor eine
 * VDI-WS geoffnet. Dadurch geht die Ausgabe noch
 * schneller.
 * Danach wird die maximal moegliche T2G-Screen
 * Groesse berechnet und evtl. auf die Env-Var.
 * CLOUMNS, LINES/ROWS geachtet. 
 *
 * Eingabe-Variablen:
 *
 * Typ WORD:
 *   t2g_columns  - soviele Spalten hat der T2G-
 *                  Screen (2..200)
 *   t2g_lines    - soviele Zeilen hat der T2G-
 *                  Screen (2..100)
 *   t2g_buffer   - Anzahl der Zeilen, die ge-
 *                  puffert werden sollen.
 *                  Bei 0 wird nichts gepuffert.
 *   t2g_fontnr   - VDI-Fontnr. fuer die Textdar-
 *                  stellung.
 *                  Es darf KEIN PROPORTIONALFONT
 *                  verwendet werden!!
 *   t2g_fontsize - die Groesse des Fonts
 *   t2g_fontcol   - und die Darstellungsfarbe
 *   t2g_mindate  - dieses Datum muss T2G min.
 *                  besitzen, um mit unserer
 *                  Applikation zu arbeiten
 *   t2g_winkind  - Fensterelemente des T2G-
 *                  Fensters
 * Typ BOOLEAN:
 *   cursor_handle - fuer den T2G-Cursor soll eine
 *                   weitere VDI-Workstation ge-
 *                   oeffnet werden.
 *                   Dadurch wird die Ausgabe in
 *                   den T2G-Screen wesentlich
 *                   schneller (Faktor: ~1.8).
 *
 *   whole_buffer  - gibt, an, ob sich die Scroll-
 *                   und Sliderberechnungen auf
 *                   den gesamten Textpuffer be-
 *                   ziehen sollen (TRUE) oder nur
 *                   auf den Bereich, in dem bis-
 *                   her Ausgaben stehen (FALSE)
 *                        
 *   lines_columns - TRUE, dann werden die Env-
 *                   Var. COLUMNS, LINES/ROWS
 *                   ausgelesen, falls vorhanden.
 *
 * Rueckgabe-Variablen:
 *
 * Type WORD:
 *   als Return-Code werden folgende Werte zu-
 *   rueckgegeben:
 *
 *   T2G_NOERROR       - kein Fehler/alles Ok
 *   T2G_OLDTOS2GEM    - zu altes TOS2GEM
 *   T2G_NOTINSTALLED  - T2G nicht installiert
 *   T2G_CANNOTRESERVE - kann T2G nicht fuer diese
 *                       Applikation reservieren
 *   T2G_NOVDIHANDLE   - kann keine weitere VDI-
 *                       Workstation oeffnen
 *   T2G_OUTOFMEM      - kein Speicher mehr frei
 */
WORD init_t2g( WORD t2g_columns, WORD t2g_lines, 
               WORD t2g_buffer, WORD t2g_fontnr,
               WORD t2g_fontsize,
               WORD t2g_fontcol,
               WORD t2g_mindate, WORD t2g_winkind,
               BOOLEAN cursor_hndl,
               BOOLEAN whole_buffer,
               BOOLEAN lines_columns )
{
    BYTE *var;
    WORD work_in[11] = {1,1,1,1,1,1,1,1,1,1,2},
         i,
         du;

    /*
     * Speicher fuer die T2G-Struktur anfordern.
     */
    t2g = (TOS2GEM *)malloc(sizeof(TOS2GEM));
    if (t2g == NULL)
        return T2G_OUTOFMEMORY;

    /*
     * pruefen, ob TOS2GEM vorhanden ist.
     */
    if (get_cookie('T2GM', (LONG *)&t2g->cookie)
        == FALSE)
    {
        free(t2g);
        return T2G_NOTINSTALLED;
    }

    /*
     * Testen, ob das im System installierte
     * TOS2GEM neu genug ist, um mit unserer
     * Applikation arbeiten zu koennen. 
     * Dabei wird das T2G Erstellungsdatum
     * mit dem uebergebenen Datum verglichen.
     */
    if (t2g->cookie->date < t2g_mindate)
    {
        free(t2g);
        return T2G_OLDTOS2GEM;
    }

    /*
     * TOS2GEM fuer unsere Anwendung reservieren.
     */
    if (t2g->cookie->reserve() == 0)
    {
        free(t2g);
        return T2G_CANNOTRESERVE;
    }

    /*
     * Fuer TOS2GEM eine eigene VDI-Workstation
     * aufmachten.
     */
    t2g->cookie->vdi_handle =
    t2g->cookie->cursor_handle =
        graf_handle( &du, &du, &du, &du );

    v_opnvwk( work_in,
              &(t2g->cookie->vdi_handle),
              t2g->work_out );

    if (t2g->cookie->vdi_handle <= 0)
    {
        t2g->cookie->deinit();
        free(t2g);
        return T2G_NOVDIHANDLE;
    }

    /*
     * damit die Ausgabe noch schneller geht, wird
     * noch eine VDI-Workstation fuer den Cursor
     * aufgemacht. Schlaegt dies fehl ist das
     * nicht weiter tragisch, da nur die Ausgabe
     * etwas langsamer wird.
     */
    if (cursor_hndl == TRUE)
    {
        v_opnvwk( work_in,
                  &(t2g->cookie->cursor_handle),
                  t2g->work_out );
    }
    else
        t2g->cookie->cursor_handle = 0;

    if (t2g_columns < 2)
        t2g->columns = 80;
    else
        t2g->columns = t2g_columns;

    if (t2g_lines < 2)
        t2g->lines = 25;
    else
        t2g->lines = t2g_lines;
    
    t2g->linebuffer = t2g_buffer;
    t2g->fontnr     = t2g_fontnr;
    t2g->fontsize   = t2g_fontsize;
    t2g->fontcol    = t2g_fontcol;

    t2g->cur_text_offset =
    t2g->cur_y_offset    =
    t2g->cur_x_offset    = 0;

    /*
     * wenn beide Environment-Var. vorhanden sind
     * und ausgelesen werden sollen, geschieht
     * dies nun.
     */
    if (lines_columns == TRUE &&
        getenv("COLUMNS") != NULL &&
        ((var = getenv("LINES")) != NULL ||
        ((var = getenv("ROWS")) != NULL)))
    {
        t2g->columns        = 
        t2g->cookie->x_size = min(
                        atoi(getenv("COLUMNS")),
                        T2G_MAXCOLUMNS-1);
        t2g->lines          = 
        t2g->cookie->y_size = min(atoi(var),
                        T2G_MAXLINES-1);
    }
    else
    {
        t2g->columns        = 
        t2g->cookie->x_size = min(t2g->columns,
                            T2G_MAXCOLUMNS-1);
        t2g->lines          = 
        t2g->cookie->y_size = min(t2g->lines,
                            T2G_MAXLINES-1);
    }

    t2g->cookie->max_lines = t2g->lines +
                                t2g->linebuffer;
    /*
     * Nun allozieren wir Speicher fuer den
     * Textpuffer von TOS2GEM.
     */
    t2g->cookie->text_buffer =
        malloc((size_t)t2g->cookie->max_lines *
        (size_t)(t2g->cookie->x_size + 1));

    if (t2g->cookie->text_buffer == NULL)
    {
        v_clsvwk(t2g->cookie->vdi_handle);
        if (t2g->cookie->cursor_handle > 0)
            v_clsvwk(t2g->cookie->cursor_handle);
        t2g->cookie->deinit();
        free(t2g);
        return T2G_OUTOFMEMORY;
    }

    /*
     * Die reservierten Felder in der
     * Cookie-Struktur loeschen.
     */
    for (i = 0; i < RESERVED_SIZE; i++)
        t2g->cookie->reserved[i] = 0;

    t2g->winkind = t2g_winkind;
    vst_font( t2g->cookie->vdi_handle,
              t2g->fontnr );
    vst_color( t2g->cookie->vdi_handle,
               t2g->fontcol );
    vst_point( t2g->cookie->vdi_handle,
               t2g->fontsize, &du, &du,
               &t2g->cookie->char_w,
               &t2g->cookie->char_h );

    t2g->whole_buffer = whole_buffer;

    return T2G_NOERROR;
}

/*
 * Diese Routine sollte immer dann aufgerufen
 * werden, wenn man TOS2GEM initialisiert hat,
 * oder Aenderungen am TOS2GEM-Screen mittels
 * 'change_t2gstats' vorgenommen wurden und man
 * sein GEM-Fenster an diese anpassen will.
 * Die Routine berechnet dazu die Arbeitsflaeche
 * und den Rahmen des GEM-Fensters in Abhaengig-
 * keit der uebergebenen Variablen.
 *
 * Eingabe-Variablen:
 *
 * Typ WORD:
 *   max_columns - wenn man diesen Variablen den
 *   max_lines     Wert 0 uebergibt, so wird ver-
 *                 sucht, das GEM-Fenster so gross
 *                 wie den T2G-Screen zu machen.
 *                 Ansonsten wird das Fenster fuer
 *                 die enthaltenen Werte berechnet
 *                 und evtl. zu grosse Werte be-
 *                 richtigt.
 *
 * Rueckgabe-Variablen:
 *
 * Type WORD:
 *   als Return-Code werden folgende Werte zu-
 *   rueckgegeben:
 *
 *   T2G_NOERROR       - kein Fehler/alles Ok
 *   T2G_NOTINSTALLED  - T2G nicht installiert
 *
 * Typ GRECT:
 *   *win_area - enthaelt nachher die Aussenmasse
 *               des GEM-Fensters
 *   *win_work - enthaelt nachher den Arbeitsbe-
 *               reich des GEM-Fensters
 *
 * Dazu ein Beispiel:
 *   Der T2G-Screen ist 90x80 Zeichen gross.
 *   Uebergibt man nun in max_columns & max_lines
 *   jeweils 0, so wird versucht die Werte fuer
 *   ein GEM-Fenster in dieser Groesse zu berech-
 *   nen.
 *   Uebergibt man 50, 20, so wird ein GEM-Fenster
 *   fuer genau diese Groesse berechnet.
 */
WORD calc_t2gwindow( GRECT *win_area,
                     GRECT *win_work,
                     WORD max_columns,
                     WORD max_lines )
{
    GRECT desk_work;

    if (t2g == NULL)
        return T2G_NOTINSTALLED;

    wind_get( 0, WF_WORKXYWH,
              &desk_work.g_x, &desk_work.g_y,
              &desk_work.g_w, &desk_work.g_h );

    wind_calc( WC_WORK, t2g->winkind,
               desk_work.g_x, desk_work.g_y,
               desk_work.g_w, desk_work.g_h,
               &win_work->g_x, &win_work->g_y,
               &win_work->g_w, &win_work->g_h);

    /*
     * das Fenster darf natuerlich nicht groesser
     * als die T2G-Screensize werden und nicht
     * kleiner als 2 Zeichen.
     */
    if (max_columns < 2)
        max_columns = t2g->columns;
    else
        max_columns = min(max_columns,
                          t2g->columns);
    if (max_lines < 2)
        max_lines = t2g->lines;
    else
        max_lines = min(max_lines, t2g->lines);

    if (win_work->g_w > max_columns *
        t2g->cookie->char_w)
    {
        win_work->g_w = max_columns *
                        t2g->cookie->char_w;
    }
    else
        win_work->g_w -= win_work->g_w %
                        t2g->cookie->char_w;
    
    if (win_work->g_h > max_lines *
        t2g->cookie->char_h)
    {
        win_work->g_h = max_lines *
                        t2g->cookie->char_h;
    }
    else
        win_work->g_h -= win_work->g_h %
                        t2g->cookie->char_h;

    t2g->cookie->x_vis = win_work->g_w /
                         t2g->cookie->char_w;
    t2g->cookie->y_vis = win_work->g_h /
                         t2g->cookie->char_h;
    t2g->cur_x_offset = min(t2g->cur_x_offset,
        t2g->cookie->x_size - t2g->cookie->x_vis);
    t2g->cur_y_offset = min(t2g->cur_y_offset,
        t2g->cookie->y_size - t2g->cookie->y_vis);

    t2g->cookie->x_off = win_work->g_x;
    t2g->cookie->y_off = win_work->g_y;

    wind_calc(WC_BORDER, t2g->winkind,
              win_work->g_x, win_work->g_y,
              win_work->g_w, win_work->g_h,
              &win_area->g_x, &win_area->g_y,
              &win_area->g_w, &win_area->g_h);

    return T2G_NOERROR;
}

/*
 * Diese Routine veraendert in Abhaengigkeit des
 * uebergebenen Flags bestimmte Eigenschaften des
 * TOS2GEM-Screens.
 * Im Einzelnen sind dies:
 * - den Textpuffer des T2G-Screens loeschen
 * - die Groesse des T2G-Screens veraendern
 * - die Puffergroesse des T2G-Screens aendern
 * - die Fontgroesse fuer die Darstellung aendern
 *
 * Eingabe-Variablen:
 *
 * Typ WORD:
 *   type - ist das Flag, an dem festgestellt
 *          wird welche Aenderungen gemacht
 *          werden sollen.
 *  
 *   T2G_CLEARBUFFER   - T2G-Screen loeschen
 *   T2G_CHGSCREENSIZE - T2G-Screengroesse aendern
 *   T2G_CHGBUFFER     - T2G-Scrollpuffer aendern
 *   T2G_CHGFONT       - Fontattribute aendern 
 *
 * Rueckgabe-Variablen:
 *
 * Type WORD:
 *   als Return-Code werden folgende Werte zu-
 *   rueckgegeben:
 *
 *   T2G_NOERROR       - kein Fehler/alles Ok
 *   T2G_NOTINSTALLED  - T2G nicht installiert
 *   T2G_OUTOFMEM      - kein Speicher mehr frei
 *
 * Typ GRECT:
 *   *win_area - enthaelt nachher die Aussenmasse
 *               des GEM-Fensters
 *   *win_work - enthaelt nachher den Arbeitsbe-
 *               reich des GEM-Fensters
 */
WORD change_t2gstats( GRECT *win_area,
                      GRECT *win_work, WORD type )
{
    WORD new_charw, new_charh,
         du;

    if (t2g == NULL)
        return T2G_NOTINSTALLED;

    /*
     * die Fontgroesse wurde geaendert. Wir tragen
     * nun die neue Zeichengroesse in die TOS2GEM-
     * Cookiestruktur ein.
     */
    if (type & T2G_CHGFONT)
    {
        vst_font( t2g->cookie->vdi_handle,
                  t2g->fontnr );
        vst_color( t2g->cookie->vdi_handle,
                   t2g->fontcol );
        vst_point( t2g->cookie->vdi_handle,
                   t2g->fontsize, &du, &du,
                   &new_charw, &new_charh );

        if (new_charw != t2g->cookie->char_w)
            t2g->cookie->char_w = new_charw;

        if (new_charh != t2g->cookie->char_h)
            t2g->cookie->char_h = new_charh;

        /*
         * bei einer Fontaenderung kann es
         * vorkommen, dass im T2G-Fenster
         * nicht mehr ganze Zeichen sichtbar sind.
         * Dies ist erstens sehr unschoen und
         * zweitens muss der TOS2GEM-Screen immer
         * ganze Zeichen beinhalten.
         * Nun wird also dafuer gesorgt, dass
         * ganze Zeichen sichtbar werden, indem
         * auf das naechst groessere gesnappt
         * wird.
         */
        if (win_work->g_w %
            t2g->cookie->char_w > 0)
        {
            win_work->g_w +=
                         t2g->cookie->char_w -
                         (win_work->g_w %
                         t2g->cookie->char_w);
        }
        if (win_work->g_h %
            t2g->cookie->char_h > 0)
        {
            win_work->g_h +=
                         t2g->cookie->char_h -
                        (win_work->g_h %
                        t2g->cookie->char_h);
        }

        /*
         * damit das Fenster nicht groesser
         * gesetzt wird als es werden darf.
         */
        if ((win_work->g_w /
            t2g->cookie->char_w) > t2g->columns)
        {
            win_work->g_w = t2g->columns *
                         t2g->cookie->char_w;
        }

        if ((win_work->g_h /
            t2g->cookie->char_h) > t2g->lines)
        {
            win_work->g_h = t2g->lines *
                         t2g->cookie->char_h;
        }
    }

    /*
     * wenn die TOS2GEM Fenstergroesse, die
     * Puffergroesse oder der Puffer geloescht
     * werden soll, springen wir hier hinein.
     */
    if (type & T2G_CLEARBUFFER  ||
        type & T2G_CHGBUFFER ||
        type & T2G_CHGSCREENSIZE)
    {
        /*
         * wir muessen, wenn sich die Fenster-
         * oder Puffergroesse aendert, neuen
         * Speicher fuer den Textpuffer
         * allozieren und einige Variablen
         * anpassen.
         */
        if (type & T2G_CHGBUFFER ||
            type & T2G_CHGSCREENSIZE)
        {
            if (type & T2G_CHGSCREENSIZE)
            {
                /*
                 * die max. # von Spalten darf
                 * nicht ueberschritten werden
                 */
                t2g->columns = min(t2g->columns,
                                T2G_MAXCOLUMNS);

                t2g->cookie->x_size =
                                t2g->columns;
                t2g->cookie->y_size =
                                t2g->lines;
            }
            t2g->cookie->max_lines = t2g->lines +
                                 t2g->linebuffer;

            t2g->cookie->text_buffer =
            realloc(t2g->cookie->text_buffer,
            (size_t)t2g->cookie->max_lines *
            (size_t)(t2g->cookie->x_size + 1));

            /*
             * wenn realloc fehlgeschlagen ist,
             * dann verlassen wir die Routine.
             */
            if (t2g->cookie->text_buffer == NULL)
                return T2G_OUTOFMEMORY;
        }
        /*
         * auf jeden Fall wird der sichtbare
         * Ausschnitt wieder in die linke
         * obere Ecke gelegt.
         */
        t2g->cur_text_offset =
        t2g->cur_y_offset    =
        t2g->cur_x_offset    = 0;
    }

    /*
     * das Fenster muss veraendert werden,
     * wenn der Font oder die T2G-Fenster-
     * groesse geandert wurde.
     */
    if (type & T2G_CHGFONT ||
        type & T2G_CHGSCREENSIZE)
    {
        /*
         * wenn das T2G-Fenster kleiner wird, als
         * das GEM-Fenster, so muessen wir das
         * GEM-Fenster ebenfalls verkleinern.
         * Sonst bleibt die Fenstergroesse
         * unveraendert.
         */
        if (t2g->cookie->x_size *
            t2g->cookie->char_w < win_work->g_w)
        {
            win_work->g_w = t2g->cookie->x_size *
                            t2g->cookie->char_w;
        }

        if (t2g->cookie->y_size *
            t2g->cookie->char_h < win_work->g_h)
        {
            win_work->g_h = t2g->cookie->y_size *
                            t2g->cookie->char_h;
        }

        /*
         * wir muessen nun noch x_vis/y_vis
         * anpassen.
         */
        t2g->cookie->x_vis = win_work->g_w /
                             t2g->cookie->char_w;
        t2g->cookie->y_vis = win_work->g_h /
                             t2g->cookie->char_h;
        t2g->cur_x_offset = min(t2g->cur_x_offset,
                            t2g->cookie->x_size -
                            t2g->cookie->x_vis);
        t2g->cur_y_offset = min(t2g->cur_y_offset,
                            t2g->cookie->y_size -
                            t2g->cookie->y_vis);

        t2g->cookie->x_off = win_work->g_x;
        t2g->cookie->y_off = win_work->g_y;

        wind_calc( WC_BORDER, T2G_WINDOW,
                win_work->g_x, win_work->g_y,
                win_work->g_w, win_work->g_h,
                &win_area->g_x, &win_area->g_y,
                &win_area->g_w, &win_area->g_h );
    }

    /*
     * der Puffer wird nur neu initalisiert,
     * wenn sich an ihm etwas geaendert hat.
     */
    if (type & T2G_CHGSCREENSIZE ||
        type & T2G_CHGBUFFER ||
        type & T2G_CLEARBUFFER)
    {
        graf_mouse( M_OFF, 0L );
        wind_update( BEG_UPDATE );
        (t2g->cookie->init)();
        (t2g->cookie->switch_output)();
        graf_mouse( M_ON, 0L );
        wind_update( END_UPDATE );
    }
    return T2G_NOERROR;
}

/*
 * Diese Routine dient dazu TOS2GEM wieder fuer
 * andere Programme nutzbar zu machen. Dabei
 * wird saemtlicher alloziierter Speicher und
 * die VDI-Handles freigegeben, sowie die Reser-
 * vierung von TOS2GEM aufgehoben.
 * Um TOS2GEM erneut zu nutzen, muss danach wieder
 * 'init_t2g' aufgerufen werden.
 */
VOID exit_t2g( VOID )
{
    if (t2g == NULL)
        return;

    /*
     * T2G-Textpuffer freigeben.
     */
    free(t2g->cookie->text_buffer);

    /*
     * VDI-Workstations freigeben.
     */
    v_clsvwk(t2g->cookie->vdi_handle);
    if (t2g->cookie->cursor_handle > 0)
        v_clsvwk(t2g->cookie->cursor_handle);

    /*
     * TOS2GEM freigeben.
     */
    (t2g->cookie->deinit)();

    /*
     * unsere T2G-Struktur freigeben.
     */
    free(t2g);
}

/*
 * Diese Routine 'redrawed' das TOS2GEM-Fenster.
 * Dabei kann man angeben, ob mit Clipping oder
 * ohne gezeichnet werden soll.
 *
 * Eingabe-Variablen:
 *
 * Typ BOOLEAN:
 *   clipping - TRUE:  mit Clipping zeichnen
 *              FALSE: ohne Clipping zeichnen
 *
 * Typ GRECT:
 *   *win_work - ein Zeiger auf den Arbeitsbereich
 *               des GEM-Fensters
 *   *box      - ein Zeiger auf die Box, die in
 *               dem Fenster redrawed werden soll,
 *               also, die mit WF_FIRSTXYWH oder
 *               WF_NEXTXYWH ermittelte.
 */
VOID redraw_t2gwindow( GRECT *win_work,
                       GRECT *box,
                       BOOLEAN clipping )
{
    BYTE temp[T2G_MAXCOLUMNS];
    WORD i, x1, x2, y1, y2, clip[4];
    GRECT to_draw;

    if (t2g == NULL)
        return;

    x1 = max((box->g_x - win_work->g_x) /
             t2g->cookie->char_w, 0);
    y1 = max((box->g_y - win_work->g_y) /
             t2g->cookie->char_h, 0);

    x2 = (box->g_x + box->g_w -1 -
          win_work->g_x) / t2g->cookie->char_w;
    y2 = (box->g_y + box->g_h -1 -
          win_work->g_y) / t2g->cookie->char_h;

    if (clipping == TRUE)
    {
        to_draw.g_x = t2g->cookie->x_off + x1 *
                      t2g->cookie->char_w;
        to_draw.g_y = t2g->cookie->y_off + y1 *
                      t2g->cookie->char_h;
        to_draw.g_w = (x2 - x1 + 1) *
                       t2g->cookie->char_w;
        to_draw.g_h = (y2 - y1 + 1) *
                       t2g->cookie->char_h;
        rc_grect_to_array(box, clip);
        rc_intersect(&to_draw, box);

        /*
         * vs_clip auf den TOS2GEM-Handles ist
         * auch erlaubt, wenn die Ausgabeum-
         * lenkung nicht aktiv ist, da TOS2GEM
         * beim Wiederaktivieren per switch_output
         * bzw. init auch das Clipping-Rechteck
         * neu bestimmt.
         */
        vs_clip(t2g->cookie->vdi_handle,
            !rc_equal(&to_draw, box), clip);
    }

    for (i = y1; i <= y2; i++)
    {
        strncpy(temp, &TPOS(x1, i), x2 - x1 + 1);
        temp[x2 - x1 + 1] = 0;
        v_gtext( t2g->cookie->vdi_handle,
                 t2g->cookie->x_off + x1 *
                    t2g->cookie->char_w,
                 t2g->cookie->y_off + i *
                    t2g->cookie->char_h, temp);
    }
    if (clipping == TRUE)
        vs_clip(t2g->cookie->vdi_handle, 0, clip);
}

/*
 * Diese Routine sollte aufgerufen werden, wenn
 * das GEM-Fenster, das den TOS2GEM-Screen ent-
 * haelt an eine andere Bildschirmposition ver-
 * schoben wurde.
 * Die Routine passt dann die notwendigen Vari-
 * ablen an die neue Position an.
 *
 * Eingabe-Variablen:
 *
 * Typ GRECT:
 *   win_work - Arbeitsbereich des GEM-Fensters an
 *              der neuen Position
 *
 * Rueckgabe Variablen:
 *
 * Type WORD:
 *   als Return-Code werden folgende Werte zu-
 *   rueckgegeben:
 *
 *   T2G_NOERROR       - kein Fehler/alles Ok
 *   T2G_NOTINSTALLED  - T2G nicht installiert
 */
WORD moved_t2gwindow( GRECT win_work )
{
    if (t2g == NULL)
        return T2G_NOTINSTALLED;

    t2g->cookie->x_off = win_work.g_x;
    t2g->cookie->y_off = win_work.g_y;

    return T2G_NOERROR;
}

/*
 * Wenn man das GEM-Fenster, das TOS2GEM be-
 * inhaltet, in seiner Gr”že ver„ndert, so muž
 * man s„mtliche Variablen der Cookie-Struktur
 * auch anpassen.
 * Diese Routine dient nun dazu, TOS2GEM an diese
 * neue Fenstergr”že anzupassen, sowie eine evtl.
 * falsche Gr”že zu korrigieren.
 * Die Variable *new_area muž beim Aufruf die
 * akt. Aužmaže des GEM-Fensters enthalten.
 *
 * Eingabe-Variablen:
 *
 * Typ GRECT:
 *   *new_area - Arbeitsbereich des GEM-Fensters
 *               an der neuen Position
 *
 * Rueckgabe Variablen:
 *
 * Typ GRECT:
 *   *new_area - evtl. neue Aussenmasse
 *   *win_work - der neue Arbeitsbereich
 *
 * Type WORD:
 *   *new_x_offset, *new_y_offset
 *      enthalten die neuen Werte von cur_x_offset
 *      und cur_y_offset aus der t2g-Struktur, die
 *      allerdings noch in diese Struktur ueber-
 *      nommen werden muessen. Dies wird nicht 
 *      automatisch gemacht, um die M”glichkeit zu
 *      bieten, mit der Differenz zu den alten
 *      Werten zu arbeiten. Z.B. um den Inhalt zu
 *      scrollen.
 *
 * Der Return-Code (Typ BOOLEAN) gibt darueber
 * Auskunft, ob sich die Offsets geaendert haben
 * und daher gescrollt oder neugezeichnet werden
 * muss.
 */
BOOLEAN adjust_t2gwindow( GRECT *new_area,
                          GRECT *win_work,
                          WORD *new_x_offset,
                          WORD *new_y_offset )
{
    BOOLEAN redraw = FALSE;

    if (t2g == NULL)
        return FALSE;

    *new_x_offset = t2g->cur_x_offset;
    *new_y_offset = t2g->cur_y_offset;

    wind_calc(WC_WORK, t2g->winkind,
              new_area->g_x, new_area->g_y,
              new_area->g_w, new_area->g_h,
              &win_work->g_x, &win_work->g_y,
              &win_work->g_w, &win_work->g_h);

    if (win_work->g_w % t2g->cookie->char_w)
    {
        win_work->g_w += t2g->cookie->char_w -
                         (win_work->g_w %
                         t2g->cookie->char_w);
    }
    if ((win_work->g_w / t2g->cookie->char_w) >
         t2g->cookie->x_size)
    {
        win_work->g_w = t2g->cookie->x_size *
                    t2g->cookie->char_w;
    }

    if (win_work->g_h % t2g->cookie->char_h)
    {
        win_work->g_h += t2g->cookie->char_h -
                         (win_work->g_h %
                         t2g->cookie->char_h);
    }
    if ((win_work->g_h / t2g->cookie->char_h) >
         t2g->cookie->y_size)
    {
        win_work->g_h = t2g->cookie->y_size *
                    t2g->cookie->char_h;
    }

    t2g->cookie->x_vis = win_work->g_w/
                         t2g->cookie->char_w;
    t2g->cookie->y_vis = win_work->g_h/
                         t2g->cookie->char_h;

    /*
     * das Fenster wird horizontal groesser.
     */
    if ((t2g->cur_x_offset + t2g->cookie->x_vis) >
         t2g->cookie->x_size)
    {
        *new_x_offset = t2g->cookie->x_size -
                        t2g->cookie->x_vis;
        redraw = TRUE;
    }

    /*
     * das Fenster wird vertikal groesser.
     */
    if ((t2g->cur_y_offset + t2g->cookie->y_vis) >
         t2g->cookie->y_size)
    {
        *new_y_offset = t2g->cookie->y_size -
                        t2g->cookie->y_vis;
        redraw = TRUE;
    }

    t2g->cookie->x_off = win_work->g_x;
    t2g->cookie->y_off = win_work->g_y;

    wind_calc(WC_BORDER, t2g->winkind,
              win_work->g_x, win_work->g_y,
              win_work->g_w, win_work->g_h,
              &new_area->g_x, &new_area->g_y,
              &new_area->g_w, &new_area->g_h);

    return(redraw);
}

/*
 * Mit dieser Funktion kann der Inhalt des sicht-
 * baren Ausschnitts des TOS2GEM-Screens verscho-
 * ben werden. Dazu werden die neuen Werte fr
 * cur_x_offset, cur_y_offset und cur_text_offset
 * berechnet und zurueckgegeben. Im Anschluss muss
 * der Aufrufer den Inhalt entsprechend diesen
 * neuen Werten neuzeichnen oder verschieben und
 * sie in die t2g-Struktur eintragen. Dies wird
 * nicht durch die Routine erledigt, um ein
 * Neuzeichnen unter Beruecksichtung der Aenderung
 * gegenueber den alten Werten zu ermoeglichen.
 *
 * Eingabe-Variablen:
 *
 * Typ WORD:
 *   x_jump - Um wieviele Zeichen soll der sicht-
 *            bare Ausschnitt nach rechts verscho-
 *            ben werden (negative Werte schieben
 *            nach links, Null aendert gar nichts)
 *   y_jump - Analog zu x_jump fr die Vertikale.
 *            Positive Werte verschieben in Rich-
 *            tung des Textpufferendes (dieses ist
 *            abhaengig von der Belegung von
 *            whole_buffer, siehe init_t2g), nega-
 *            tive zum Anfang hin.
 *
 * Rueckgabe-Variablen:
 *
 * Typ WORD:
 *   *new_x_offset    - Neuer Wert fr cur_x_off-
 *                      set, muss nach Auswertung
 *                      in die t2g-Struktur einge-
 *                      tragen werden.
 *   *new_y_offset    - Gleiches fr cur_y_offset
 *   *new_text_offset - dito fr cur_text_offset
 */
VOID scroll_t2gwindow( WORD x_jump, WORD y_jump,
                       WORD *new_x_offset,
                       WORD *new_y_offset,
                       WORD *new_text_offset )
{
    if (t2g == NULL)
        return;

    *new_y_offset    = t2g->cur_y_offset + y_jump;
    *new_text_offset = t2g->cur_text_offset;

    if (*new_y_offset < 0)
    {
        *new_text_offset = max(0,
            *new_text_offset + *new_y_offset);
        *new_y_offset = 0;
    }
    else if (*new_y_offset >
        (t2g->cookie->y_size -
        t2g->cookie->y_vis))
    {
        if (t2g->whole_buffer == TRUE)
        {
            *new_text_offset = min(
                t2g->cookie->max_lines -

                t2g->cookie->y_size,
                *new_text_offset + *new_y_offset -
                t2g->cookie->y_size +
                t2g->cookie->y_vis);
        }
        else
        {
            *new_text_offset = min(
                t2g->cookie->text_offset,
                *new_text_offset + *new_y_offset -
                t2g->cookie->y_size +
                t2g->cookie->y_vis);
        }
        *new_y_offset = t2g->cookie->y_size -
                        t2g->cookie->y_vis;
    }

    *new_x_offset = t2g->cur_x_offset + x_jump;

    if (*new_x_offset < 0)
        *new_x_offset = 0;
    else
    {
        *new_x_offset = min(*new_x_offset,
                            (t2g->cookie->x_size -
                            t2g->cookie->x_vis));
    }
}

/*
 * Mit dieser Funktion werden Groesse und Position
 * der Slider fuer ein Fenster berechnet, das den
 * TOS2GEM-Screen beherbergt und ein Scrollen im
 * Textpuffer (whole_buffer beachten!) ermoeg-
 * licht. Die berechneten Werte koennen direkt mit
 * wind_set eingestellt werden.
 *
 * Rueckgabe-Variablen:
 *
 * Typ WORD:
 *   x_size - Groess des horizontalen Sliders
 *   y_size - Groessee des vertikalen Sliders
 *   x_pos  - Position des horizontalen Sliders
 *   y_pos  - Position des vertikalen Sliders
 */
VOID calc_t2gsliders( WORD *x_size, WORD *y_size,
                      WORD *x_pos, WORD *y_pos )
{
    if (t2g == NULL)
        return;

    *x_size = (WORD)((LONG)t2g->cookie->x_vis *
        1000L / (LONG)t2g->cookie->x_size);

    if (*x_size > 1000)
        *x_size = 1000;

    if (t2g->cookie->x_size - t2g->cookie->x_vis)
    {
        *x_pos = (WORD)((LONG)t2g->cur_x_offset *
            1000L / (LONG)(t2g->cookie->x_size -
            t2g->cookie->x_vis));
    }
    else
        *x_pos = 1;

    if (t2g->whole_buffer == TRUE)
    {
        *y_size = (WORD)
            ((LONG)t2g->cookie->y_vis * 1000L /
            (LONG)t2g->cookie->max_lines);
        if (t2g->cookie->max_lines -
            t2g->cookie->y_vis)
        {
            *y_pos = (WORD)
                ((LONG)(t2g->cur_y_offset +
                t2g->cur_text_offset) * 1000L /
                (LONG)(t2g->cookie->max_lines -
                t2g->cookie->y_vis));
        }
        else
            *y_pos = 1;
    }
    else
    {
        *y_size = (WORD)
            ((LONG)t2g->cookie->y_vis * 1000L /
            (LONG)(t2g->cookie->text_offset +
            t2g->cookie->y_size));
        if (t2g->cur_text_offset +
            t2g->cookie->y_size -
            t2g->cookie->y_vis)
        {
            *y_pos = (WORD)
                ((LONG)(t2g->cur_y_offset +
                t2g->cur_text_offset) * 1000L /
                (LONG)(t2g->cookie->text_offset +
                t2g->cookie->y_size -
                t2g->cookie->y_vis));
        }
        else
            *y_pos = 1;
    }
    if (*y_size > 1000)
        *y_size = 1000;
}

/*
 * Mit dieser Funktion lassen sich aus Slider-
 * differenzwerten (neue Position - alte Position)
 * "Jump"-Werte fr scroll_t2gwindow berechnen.
 *
 * Eingabe-Variablen:
 *
 * Typ WORD:
 *   *dx - Sliderdifferenz horizontal (neu - alt)
 *   *dy - dito fr die Vertikale
 *
 * Rueckfabe-Variablen:
 *
 * Typ WORD:
 *   *dx - Enthaelt den horizontalen Differenzwert
 *         in Zeichen, der als x_jump der Funktion
 *         scroll_t2gwindow uebergeben werden
 *         kann.
 *   *dy - Enth„lt entsprechend den vertikalen
 *         Differnzwert in Zeilen (y_jump)
 */
VOID calc_t2gdeltas( WORD *dx, WORD *dy )
{
    if (t2g == NULL)
        return;

    if (t2g->whole_buffer == TRUE)
    {
        *dy = (WORD)((LONG)*dy *
              (LONG)(t2g->cookie->max_lines -
              t2g->cookie->y_vis) / 1000L);
    }
    else
    {
        *dy = (WORD)((LONG)*dy *
              (LONG)(t2g->cookie->text_offset +
              t2g->cookie->y_size -
              t2g->cookie->y_vis) / 1000L);
    }
    *dx = (WORD)((LONG)*dx *
          (LONG)(t2g->cookie->x_size -
          t2g->cookie->x_vis) / 1000L);
}

/*
 * Mit Hilfe dieser einfachen Funktion ist es
 * moeglich, den fr den gewaehlten Textpuffer-
 * Scrolltyp (whole_buffer, siehe init_t2g)
 * maximalen Wert fr cur_text_offset zu be-
 * stimmen, um Beispielsweise direkt an das Ende
 * des Textpuffers springen zu koennen.
 */
WORD calc_t2gmax_text_offset( void )
{
    if (t2g == NULL)
        return(-1);

    if (t2g->whole_buffer == TRUE)
    {
        return(t2g->cookie->max_lines -
               t2g->cookie->y_size);
    }
    else
        return(t2g->cookie->text_offset);
}

/*
 * rc_intersect
 *
 * Untersucht zwei Rechtecke auf šberschneidung.
 * Gibt es eine, liefert die Funktion 1, sonst
 * 0. Die Koordinaten des zweiten Rechtecks
 * werden bei šberschneidung durch das
 * Schnittrechteck ersetzt.
 *
 * Eingabe:
 * one: Zeiger auf GRECT-Struktur des ersten
 *      Rechtecks
 * two: Zeiger auf zweites Rechteck
 *
 * Rckgabe:
 * FALSE: Keine šberschneidung, beide Rechtecke
 *    unver„ndert
 * TRUE: Rechtecke berschneiden sich, two enth„lt
 *    Koordinaten des Schnittrechtecks
 */
static BOOLEAN rc_intersect(GRECT *one,
                            GRECT *two)
{
    WORD    x, y, w, h;

    x = max(two->g_x, one->g_x);
    y = max(two->g_y, one->g_y);
    w = min(two->g_x + two->g_w,
        one->g_x + one->g_w);
    h = min(two->g_y + two->g_h,
        one->g_y + one->g_h);

    if ((w > x) && (h > y))
    {
        two->g_x = x;
        two->g_y = y;
        two->g_w = w - x;
        two->g_h = h - y;
        return(TRUE);
    }
    return(FALSE);
}

/*
 * rc_equal
 *
 * Prft zwei Rechtecke auf Gleichheit
 *
 * Eingabe:
 * one: Zeiger auf GRECT-Struktur des ersten
 *      Rechtecks
 * two: Zeiger auf zweites Rechteck
 *
 * Rckgabe:
 * FALSE: Keine šbereinstimmung
 * TRUE: one und two beschreiben exakt das gleiche
 *    Rechteck
 */
static BOOLEAN rc_equal(GRECT *one, GRECT *two)
{
    if ((one->g_x == two->g_x) &&
        (one->g_y == two->g_y) &&
        (one->g_w == two->g_w) &&
        (one->g_h == two->g_h))
    {
        return(TRUE);
    }
    return(FALSE);
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
static VOID rc_grect_to_array(GRECT *rect,
                              WORD *xy)
{
    xy[0] = rect->g_x;
    xy[1] = rect->g_y;
    xy[2] = xy[0] + rect->g_w - 1;
    xy[3] = xy[1] + rect->g_h - 1;
}

static BOOLEAN get_cookie( LONG cookie, LONG *value )
{
    LONG oldstack,
         *cookiejar;
 
    /* Zeiger auf Cookiejar holen */
    if (Super((void *)1L) == 0L)
    {
        oldstack = Super(0L);
        cookiejar = *((LONG **)0x5a0L);
        Super((void *)oldstack);
    }
    else
        cookiejar = *(LONG **)0x5a0;
    
    /* Ist der Cookiejar vorhanden ? */
    if (cookiejar == 0L)
        return( FALSE );

    do
    {
        if (cookiejar[0] == cookie)
        {
            if (value != NULL)
                *value = cookiejar[1];

            return( TRUE );
        }
        else
            cookiejar = &(cookiejar[2]);
    } while (cookiejar[-2]);
    return( FALSE );
}
