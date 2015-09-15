/* KOMORKA.C - modul pomocniczy dla programu AUTOM1D */

#include <aes.h>
#include <vdi.h>
#include <stdlib.h>
#include <stdio.h>

/************ Inicjalizacja i "odmeldowanie" aplikacji ******************/

static int work_in[12], work_out[57],
           appl_id, vdi_handle, phys_handle, gl_hchar, 
           gl_wchar, gl_hbox, gl_wbox;

extern void _main(void);

int main(void)
{
   void gem_intro(void),
        gem_finish(void);

   gem_intro();
   atexit(gem_finish);
   _main();
   return(0);
}

static void gem_intro(void)
{
   int i;
   
   appl_id = appl_init();
   if(appl_id==-1)
   {
      printf("\nProgram nie moze prawidlowo sie zainicjowac!\n");
      exit(1);
   }
   else
   {
       for(i=0; i<10; i++)
          work_in[i] = 1;
       work_in[10] = 2;
       phys_handle = graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
       work_in[0] = vdi_handle = phys_handle;
       v_opnvwk(work_in, &vdi_handle, work_out);
       if(vdi_handle==0)
       {
           printf("\nNie moge otworzyc wirtualnej stacji roboczej!\n");
           exit(1);
       }
   }
}

static void gem_finish(void) 
{
    v_clsvwk(vdi_handle);
    appl_exit();
}

int glhchar(void)    /* wysokosc systemowej czcionki uzywanej na ekranie */ 

{
   return(gl_hchar);
}

int glwchar(void)    /* wysokosc systemowej czcionki uzywanej na ekranie */
{
   return(gl_wchar);
}

/*************** Funkcje pracujace w trybie tekstowym ****************/

void gotoxy(int x, int y)
{
   putchar(27);
   putchar(89);
   putchar(y+32);
   putchar(x+32);
}

void cur_on(void)
{
   putchar(27);
   putchar(101);
}

void cur_off(void)
{
   putchar(27);
   putchar(102);
}

/******** Funkcje graficzne (czesciowo wzorowane na GFA Basicu) **********/

void defmouse(int gr_monumber, ...)
{
  MFORM *gr_mofaddr = NULL;
  
  if(gr_monumber==USER_DEF)
  {
       va_list param;
       va_start(param, gr_monumber);
       gr_mofaddr = va_arg(param, MFORM *);
       va_end(param);
  }
  graf_mouse(gr_monumber, gr_mofaddr);
}

void sfinterior(int style)
{
   vsf_interior(vdi_handle, style);
}

void sfstyle(int style_index)
{
   vsf_style(vdi_handle, style_index);
}

void sfcolor(int color)
{
  vsf_color(vdi_handle, color);
}

void sfperimeter(int per_vis)
{
  vsf_perimeter(vdi_handle, per_vis);
}

static int punkty[4];

void pbox(int x1, int y1, int x2, int y2)
{
   int *p = punkty;
   *p++ = x1;
   *p++ = y1;
   *p++ = x2;
   *p++ = y2;
   v_bar(vdi_handle, punkty);
}

/***************************** Okna ***********************************/

int nowe_okno(int komponenty_okna, const char *tytul, int *x1, int *y1, 
              int *x2, int *y2)
{
   void clsw(int x1, int y1, int x2, int y2);
   int o, x, y, h, w;
   
   wind_get(0, WF_WORKXYWH, &x, &y, &w, &h);   /* odczytanie wsp. ekranu */
   if((o = wind_create(komponenty_okna, x, y, h, w))<=0)
   {
      printf("\nNie moge otworzyc okna");
      exit(1);
   }
   wind_set(o, WF_NAME, tytul);
   wind_set(o, WF_VSLIDE, 1);
   wind_set(o, WF_VSLSIZE, -1);
   wind_open(o, x, y, w, h);
   wind_calc(1, komponenty_okna, x, y, w, h, &x, &y, &w, &h); /* obliczenie 
                                             * powierzchni roboczej okna */
   *x1 = x;
   *y1 = y;
   *x2 = x+w-1;
   *y2 = y+h-1;
   clsw(*x1, *y1, *x2, *y2);
   return(o);
}

void clsw(int x1, int y1, int x2, int y2) /* wyczyszczenie pow. rob. okna */
{
   sfinterior(0);   /* wypelnienie w kolorze tla */
   sfperimeter(0);  /* obrzeze wylaczone */
   pbox(x1, y1, x2, y2);
   sfperimeter(1);  /* obrzeze wlaczone */
}

void likw_okna(int okno)                              /* likwidacja okna */
{
    wind_close(okno);
    wind_delete(okno);
}

/*********************** rysowanie kom¢rki *************************/

void komorka(int x, int y, int bokx, int boky, int kolor)
{
   sfinterior(kolor? 1 : 0);
   pbox(x, y, x+bokx, y+boky);
}
