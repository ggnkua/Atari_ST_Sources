/*
 * Library 'uset2g.lib' vom 17.01.1995
 *
 * Autor:   Dirk Klemmt
 *          Heimchenweg 41
 *          D-65929 Frankfurt am Main
 *          069/30 72 25
 *
 * Zweck:
 *
 * Diese Library dient dazu, die Benutzung von
 * TOS2GEM stark zu vereinfachen.
 * Dazu werden einige Routinen zur Verfuegung
 * gestellt, die Standardaufgaben erledigen und
 * auf Aenderungen des TOS2GEM-Screens reagieren.
 *
 * NICHT LAUFFŽHIGER AUSZUG!!! Dient nur der An-
 * schauung!
 *
 * Compiler: Pure C 1.x
 */
#define TOS2GEM_LIB
#include "uset2g.h"

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
