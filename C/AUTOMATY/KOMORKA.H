/* KOMORKA.H */

#ifndef __WSPOLNE
#define __WSPOLNE

#include <aes.h>
#include <vdi.h>

void _main(void);

#define main  _main

extern 
int glhchar(void),    /* wysokosc systemowej czcionki uzywanej na ekranie */ 
    glwchar(void);    /* szerok. systemowej czcionki uzywanej na ekranie */

#define mouse_on()   defmouse(M_ON)
#define mouse_off()  defmouse(M_OFF)

extern void gotoxy(int x, int y),
            cur_on(void),
            cur_off(void),
            defmouse(int gr_monumber, ...),
            sfinterior(int style),
            sfstyle(int style_index),
            sfcolor(int color),
            sfperimeter(int per_vis),
            pbox(int x1, int y1, int x2, int y2);
extern int nowe_okno(int komponenty_okna, const char *tytul, 
                     int *x1, int *y1, int *x2, int *y2);
extern void clsw(int x1, int y1, int x2, int y2),
            likw_okna(int okno),
            komorka(int x, int y, int bokx, int boky, int kolor);

#endif
