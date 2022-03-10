/* CONIO.C
   Source File for porting applications using character oriented
   windows from TC on MSDOS to TC on Atari ST

   Copyright (c)  Heimsoeth & Borland  1988

*/

#define __CONIO

#pragma warn -par /* Warnung bei unbenutztem Parameter ausschalten */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <ctype.h>
#include <vdi.h>
#include <aes.h>
#include <ext.h>
#include <tos.h>
#include "conio.h"

#define charxrast(x) ((x)*wchar) /* Zeichen -> x-Raster */
#define charyrast(y) ((y)*hchar) /* Zeichen -> y-Raster */
#define VT52(a) {putchar(0x1B); putchar(a);} /* Zeichen ausgeben */
#define FALSE 0
#define TRUE !FALSE

int directvideo = FALSE;

/**** Prototypes ****/
int _cont(int, char **, char *);
static void main(int, char **, char *), quit(void), failure(void);
static int  appl_open(int *),   vwork_open(int);
static void init(int *, int *), vwork_close(int);
static void cwindcopy(int, int, int, int, int, int, int);
static void right(void);
static void mouseon(void), mouseoff(void), curxy(int, int);
static int  wchar, hchar; /* Zeichen-Ausmaže */

static struct text_info textinfo;

/**** Initialisierung ****/

void main(int argc, char **argv, char *envp) /* Programm initialisieren */
{       int rows, columns, gem_handle;
        atexit(quit);
        textinfo.app_handle = appl_open(&gem_handle);
        textinfo.vdi_handle = vwork_open(gem_handle);
        if(textinfo.vdi_handle >= 0)
        {       init(&rows, &columns);
                winstyle(0, 0);
                textinfo.xmax = columns;
                textinfo.ymax = rows;
                textinfo.attribute = textinfo.normattr = 0;
                textinfo.currmode = MONO; /* ... */
                window(1,1,columns,rows);
                exit(_cont(argc, argv, envp));
        }
        failure();
}

/**** Funktionen ****/

int movetext(int left, int top, int right, int bottom, int newleft, int newtop)
{       if(left    < 1 || left    > textinfo.xmax ||
           right   < 1 || right   > textinfo.xmax ||
           newleft < 1 || newleft > textinfo.xmax ||
           top     < 1 || top     > textinfo.ymax ||
           bottom  < 1 || bottom  > textinfo.ymax ||
           newtop  < 1 || newtop  > textinfo.ymax)
                return(FALSE);
        cwindcopy(left, top, right, bottom, newleft, newtop, S_ONLY);
        return(TRUE);
}

int window(int left, int top, int right, int bottom)
{       if(left   >= 1 && left   <= textinfo.xmax &&
           top    >= 1 && top    <= textinfo.ymax &&
           right  >= 1 && right  <= textinfo.xmax &&
           bottom >= 1 && bottom <= textinfo.ymax)
        {       textinfo.winleft  = left; textinfo.wintop     = top;
                textinfo.winright = right; textinfo.winbottom = bottom;
                textinfo.screenwidth  = right - left;
                textinfo.screenheight = bottom - top;
                curhome();
                return(TRUE);
        }
        return(FALSE);
}

void clrscr(void) /* Fenster l”schen */
{       cwindfill(textinfo.winleft, textinfo.wintop, textinfo.winright,
                  textinfo.winbottom);
        curhome();
}

void clreol(void) /* Bis Zeilenende l”schen */
{       cwindfill(textinfo.winleft+textinfo.curx, textinfo.wintop+textinfo.cury,
                  textinfo.winright, textinfo.wintop+textinfo.cury);
}

void insline(void) /* Zeile einfgen */
{       cwindcopy(textinfo.winleft, textinfo.wintop+textinfo.cury,
                  textinfo.winright, textinfo.winbottom-1, textinfo.winleft,
                  textinfo.wintop+textinfo.cury+1, S_ONLY);
        cwindfill(textinfo.winleft, textinfo.wintop+textinfo.cury,
                  textinfo.winright, textinfo.wintop+textinfo.cury);
}

void delline(void) /* Aktuelle Zeile l”schen */
{       cwindcopy(textinfo.winleft, textinfo.wintop+textinfo.cury,
                  textinfo.winright, textinfo.winbottom, textinfo.winleft,
                  textinfo.wintop+textinfo.cury-1, S_ONLY);
        cwindfill(textinfo.winleft, textinfo.wintop+textinfo.screenheight,
                  textinfo.winright, textinfo.wintop+textinfo.screenheight);
}

int cprintf(const char *format, ...) /* printf(...) */
{       va_list arg_ptr;
        char s[81];
        va_start(arg_ptr, format);
        vsprintf(s, format, arg_ptr);
        va_end(arg_ptr);
        return(couts(s));
}

int cputs(const char *string) /* puts(...) */
{       couts(string);
        newline();
        return('\n');
}

int couts(const char *string) /* String ausgeben */
{       const char *s;
        if(directvideo)
                return(Cconws((char *) string));
        curoff();
        s = string;
        while(putch(*s++))
                 ;
        curon();
        return((int) (s - string - 1)); /* Anzahl der ausgegebenen Zeichen */
}

int putch(int c) /* putchar(...) */
{       int x;
        if(!isprint(c) && !directvideo)
        {       switch(c)
                {       case '\n': /* CRLF */
                                newline();
                                break;
                        case '\r': /* CR */
                                textinfo.curx = 1;
                                curxy(textinfo.curx, textinfo.cury);
                                break;
                        case '\a': /* Bell */
                                putchar('\a');
                                break;
                        case '\b': /* Backspace */
                                putch(' '); curleft();
                                curleft(); putch(' ');
                                curleft();
                                break;
                        case '\t': /* Tabulator */
                                x = (textinfo.curx / 8 + 1) * 8;
                                gotoxy(x, textinfo.cury);
                                break;
                }
        }
        else
        {       Cconout(c);
                right();
        }
        return(c);
}

int getche(void) /* getchar(...) */
{       int c;
        c = getch();
        putch(c);
        return(c);
}

void gettextinfo(struct text_info *inforec) /* Textinfo-Struktur kopieren (!) */
{       memcpy(inforec, &textinfo, sizeof(textinfo));
}

int wherex(void) /* Cursor-Spalte zurckgeben */
{       return(textinfo.curx);
}

int wherey(void) /* Cursor-Zeile zurckgeben */
{       return(textinfo.cury);
}

int gettext(int left, int top, int right, int bottom, void *destin)
{       return(FALSE); /* Wird nicht untersttzt */
}

int puttext(int left, int top, int right, int bottom, void *source)
{       return(FALSE); /* wird nicht untersttzt */
}

int winstyle(int style, int frame) /* Fensterhintergrund setzen */
{       textinfo.winstyle = style;
        vsf_perimeter(textinfo.vdi_handle, frame);
        return(vsf_interior(textinfo.vdi_handle, style));
}

/**** Nur aus Kompatibilit„tsgrnden vorhanden ****/

void highvideo(void)    {};
void normvideo(void)    {};
void lowvideo(void)             {};
void textattr(int attribute)            {};
void textcolor(int color)       {};
void textbackground(int color)          {};

void textmode(int mode)
{       int xmax;
        if(mode == LAST)
                return;
        if(mode == BW40 || mode == C40)
                xmax = 40;
        else
                xmax = 80;
        textinfo.xmax = xmax;
        window(1,1,textinfo.xmax,textinfo.ymax);
        textinfo.currmode = mode;
        normvideo();
};


/**** Cursor bewegen ****/

void curleft(void) /* Cursor links */
{       if(textinfo.curx > 1) /* Linker Rand erreicht? */
                textinfo.curx--; /* Nein, dann links */
        else if(textinfo.cury > 1) /* Ja: Erste Zeile? */
        {       textinfo.curx = textinfo.screenwidth+1; /* Nein: rauf */
                textinfo.cury--;
        }
        curxy(textinfo.curx, textinfo.cury);
}

void curright(void) /* Cursor rechts */
{       if(textinfo.curx <= textinfo.screenwidth) /* Rechter Rand erreicht? */
                textinfo.curx++; /* Nein, dann rechts */
        else if(textinfo.cury <= textinfo.screenheight) /* Ja: Letzte Zeile? */
        {       textinfo.curx = 1; /* Nein: runter */
                textinfo.cury++;
        }
        curxy(textinfo.curx, textinfo.cury);
}

void curup(void) /* Cursor rauf */
{       if(textinfo.cury > 1) /* Erste Zeile? */
                curxy(textinfo.curx, --textinfo.cury); /* Nein: rauf */
}

void curdown(void) /* Cursor runter */
{       if(textinfo.cury <= textinfo.screenheight) /* Letzte Zeile? */
                curxy(textinfo.curx, ++textinfo.cury); /* Nein: runter */
}

void curhome(void) /* Cursor home */
{       textinfo.curx = textinfo.cury = 1;
        curxy(textinfo.curx, textinfo.cury);
}

void newline(void) /* Cursor CRLF */
{       if(textinfo.cury <= textinfo.screenheight) /* Letzte Zeile? */
                textinfo.cury++; /* Nein: CRLF */
        textinfo.curx = 1;
        curxy(textinfo.curx, textinfo.cury);
}

void gotoxy(int x, int y) /* Cursor positionieren */
{       if(x >= 1 && x <= textinfo.screenwidth+1 &&
           y >= 1 && y <= textinfo.screenheight+1)
                textinfo.curx = x; textinfo.cury = y;
        curxy(textinfo.curx, textinfo.cury);
}

/**** Allgemeine Funktionen ****/

static void curon(void) /* Cursor einschalten */
{       VT52('e');
}

static void curoff(void) /* Cursor ausschalten */
{       VT52('f');
}

void revon(void) /* Revers einschalten */
{       v_rvon(textinfo.vdi_handle);
}

void revoff(void) /* Revers ausschalten */
{       v_rvoff(textinfo.vdi_handle);
}

/**** Interne Funktionen ****/

static int appl_open(int *gem_hndl) /* Application anmelden */
{       int q, app_hndl = appl_init();
        *gem_hndl = graf_handle(&wchar, &hchar, &q, &q);
        return(app_hndl);
}

static int vwork_open(int gem_hndl) /* Virtuelle Workstation ”ffnen */
{       int i, vdi_hndl;
        int work_in[11];
        for(i = 1; i < 10; work_in[i++] = 1)
                ;
        work_in[ 0] = Getrez() + 2;
        work_in[10] = 2; /* Raster-Koordinaten */
        vdi_hndl = gem_hndl;
        v_opnvwk(work_in, &vdi_hndl, _GemParBlk.intout);
        return(vdi_hndl); /* Virtual Workstation Handle */
}

static void init(int *rows, int *columns)
{       mouseoff();
        v_enter_cur(textinfo.vdi_handle);
        vq_chcells(textinfo.vdi_handle, rows, columns);
}

static void quit(void) /* Quit Program */
{       v_exit_cur(textinfo.vdi_handle);
        mouseon();
        vwork_close(textinfo.vdi_handle);
        appl_exit();
}

static void vwork_close(vdi_hndl) /* Virtuelle Arbeitsstation schliežen */
{       v_clsvwk(vdi_hndl);
}

static void failure(void) /* Fatal Error */
{       fprintf(stdout, "CONIO: Fatal Error: Cannot install CharacterWindows.");
        fprintf(stdout, "CONIO: Shutting down....");
        abort();
}

static void mouseon(void) /* Maus einschalten */
{       v_show_c(textinfo.vdi_handle, 0);
}

static void mouseoff(void) /* Maus ausschalten */
{       v_hide_c(textinfo.vdi_handle);
}

static void curxy(int x, int y) /* Cursor positionieren */
{       vs_curaddress(textinfo.vdi_handle, textinfo.wintop+y-1, textinfo.winleft+x-1);
}

static void right(void) /* Cursor schnell rechts */
{       if(textinfo.curx <= textinfo.screenwidth) /* Rechter Rand erreicht? */
        {       textinfo.curx++; /* Nein, dann rechts */
                return;
        }
        if(textinfo.cury <= textinfo.screenheight) /* Ja: Letzte Zeile? */
        {       textinfo.curx = 1; /* Nein: runter */
                textinfo.cury++;
                curxy(textinfo.curx, textinfo.cury);
        }
        else
                curxy(textinfo.curx, textinfo.cury);
}

static void /* Bildschirmausschnitt kopieren */
cwindcopy(int sx1, int sy1, int sx2, int sy2, int dx1, int dy1, int mode)
{       MFDB fdb = { 0L }; /* Wird vom VDI initialisiert */
        int p[8];
        p[0] = charxrast(sx1-1); p[1] = charyrast(sy1-1);
        p[2] = charxrast(sx2)-1; p[3] = charyrast(sy2)-1;
        p[4] = charxrast(dx1-1); p[5] = charyrast(dy1-1);
        p[6] = charxrast(dx1+sx2-sx1)-1;
        p[7] = charyrast(dy1+sy2-sy1)-1;
        curoff();
        vro_cpyfm(textinfo.vdi_handle, mode, p, &fdb, &fdb);
        curon();
}

void /* Fensterhintergrund */
cwindfill(int x1, int y1, int x2, int y2)
{       int p[4];
        p[0] = charxrast(x1-1)-1; p[1] = charyrast(y2);
        p[2] = charxrast(x2); p[3] = charyrast(y1-1)-1;
        if(p[0] < 0)
               p[0] = 0;
        if(p[1] >= charyrast(textinfo.ymax))
               p[1] = charyrast(textinfo.ymax);
        if(p[2] >= charxrast(textinfo.xmax))
               p[2] = charxrast(textinfo.xmax);
        if(p[3] < 0)
               p[3] = 0;
        curoff();
        v_bar(textinfo.vdi_handle, p);
        curon();
}

#pragma warn .par
