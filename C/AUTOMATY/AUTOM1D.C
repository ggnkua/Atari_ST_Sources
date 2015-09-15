/* Jednowymiarowy automat kom¢rkowy */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <aes.h>
#include <tos.h> 
#include "komorka.h"

#define REG_MYSZ    1
#define LICZBA      2
#define STAN_POCZ   3
#define LOSOWANIE   'R'
#define JEDEN_WEZEL 'J'
#define SIATKA      'S'
#define SCROLLING   ' '
#define KONIEC      4

#define N    100  /* liczba kom¢rek */

#define neg(x, nrbitu) ((x) ^= 1<<(nrbitu))      /* zanegowanie bitu w x */
#define bit(x, i)      ((x) & (1<<(i)))          /* informacja, czy i-ty */
                                                 /* bit jest ustawiony */  
#define xy(y)          (((y)*dx) / dy)           /* zamiana boku Y na X */ 
#define yx(x)          (((x)*dy) / dx)           /* zamiana boku X na Y */ 

#define getrez         Getrez
#define SREDNIA_ROZDZ  1

typedef unsigned char byte, typ_komor;

void ewol1(typ_komor *kom, byte regula);

int dx, dy,      /* szerokosc i wysokosc kom¢rki (w pikselach) */
    x0, y0,      /* wsp¢lrzedne lewej g¢rnej kom¢rki automatu */
    dx1,         /* odleglosc miedzy brzegami dw¢ch sasiednich kom¢rek
                  * reprezentujacych bity w postaci graficznej reguly */
    xt, yt,      /* wsp. napisu podajacego wartosc reguly */
    siatka = 0,
    okno;

typ_komor stan_pocz[N]; 
    
void main()
{
   int  zdarzenie(int *xm);
   void ewolucja(int regula, int npok),
        likw_okna(int okno),
        opis(byte regula),
        opis0(void),
        losowanie(typ_komor *stan_pocz);
   byte liczba(void);
   int x1, y1, x2, y2,   /* wsp¢lrzedne powierzchni roboczej okna */
       npok,             /* liczba pokolen widocznych na ekranie */ 
       xl,               /* x-owa wsp¢lrz. miejsca wypisania licznika pok */ 
       xm,               /* x-owa wsp¢lrzedna myszy w chwili wystapienia 
                          * zdarzenia zwiazanego z przyciskami myszy 
                          * badz przesuniecie suwaka */ 
       i, dy1;
   long lpok;            /* licznik pokolen */
   byte regula = 15;
   
   defmouse(ARROW);
   mouse_off();
   okno = nowe_okno(NAME|CLOSER|DNARROW|VSLIDE, " Jednowymiarowe automaty "
                    "kom¢rkowe ", &x1, &y1, &x2, &y2);
   dx = (x2-x1)/N;
   dy = (getrez()==SREDNIA_ROZDZ)? dx/2 : dx;
   x0 = x1 + (x2-x1-N*dx)/2;
   y0 = y1 + (7*dy)/2;
   if(y0<=y1+2*glhchar())
      y0 = y1 + 2*glhchar();
   dy1 = ((y0-y1)*2)/7;
   dx1 = 4 * xy(dy1);
   xt = (x0+8*dx1)/glwchar()+2;
   yt = y0/glhchar()-1;
   npok = (y2-y0)/dy;
   if((xl = x2/glwchar()-(int)strlen("Pokolenie ")-9) <= 
                                          xt+(int)strlen("Regula: 000   "))
       xl = 0;
   lpok = npok-1;
   losowanie(stan_pocz);
   opis0();
   while(1)
   {
     opis(regula);
     ewolucja(regula, npok);
     if(xl)
     {
         gotoxy(xl, yt);
         printf("Pokolenie %-8ld", lpok);
     }
     if(!siatka)
     {
        sfperimeter(1);
        ewolucja(regula, 1);
        sfperimeter(siatka);
     }
     switch(zdarzenie(&xm))
     {
       case REG_MYSZ:                   /* zmiana reguly za pomoca myszy */  
            neg(regula, 7-(xm-x0)/dx1);
            break;
       case LICZBA:                     /* nowa regula z klawiatury */
            regula = liczba();
            break;
       case STAN_POCZ:                  /* zmiana kom¢rki w stanie pocz */
            stan_pocz[(xm-x0)/dx] = 1 - stan_pocz[(xm-x0)/dx];
            break;
       case LOSOWANIE:                  /* losowanie stanu poczatkowego */
            losowanie(stan_pocz);
            break;
       case JEDEN_WEZEL:                /* stan pocz zlozony z samych zer */
            for(i=0; i<N; i++)          /* opr¢cz jednego wezla */
               stan_pocz[i] = 0;
            stan_pocz[N/2] = 1;
            break;
       case SIATKA:
            siatka = !siatka;
            continue;
       case SCROLLING:                 /* przesuniecie o xm pokolen w d¢l */
            if(xm<0)                   /* domyslnie o npok - 2 */
               xm = npok-2;
            for(i=0; i<xm; i++)
               ewol1(stan_pocz, regula);
            lpok += xm;
            continue;
       case KONIEC:
            if(form_alert(1, "[2][|Koniec programu?][ Tak | Nie ]")==1)
            {
               likw_okna(okno);
               mouse_on();
               return;
            }
            continue;
     }
     lpok = npok-1;
   }
}

typ_komor komorki[N], nowe_pok[N];

void ewolucja(int regula, int npok)                /* ewolucja automatu */
{                                                  /* przez npok pokolen */
   int t, i;
   for(memcpy(komorki, stan_pocz, sizeof(komorki)), t=0; t<npok; t++)
   {
      for(i=0; i<N; i++)
         komorka(x0+i*dx, y0+t*dy, dx, dy, komorki[i]);
      ewol1(komorki, regula);
   }
}

void ewol1(typ_komor *kom, byte regula)    /* obliczenie nowego pokolenia */ 
{
   int sasiedzi(const typ_komor *kom, int i);
   int i;
   
   for(i=0; i<N; i++)
     nowe_pok[i] = bit(regula, sasiedzi(kom, i))? 1 : 0;
   memcpy(kom, nowe_pok, sizeof(nowe_pok));
}

int sasiedzi(const typ_komor *kom, int i) /* zbadanie stanu i-tej kom¢rki */ 
{                                            /* i jej sasiad¢w w chwili t */
   byte lewysasiad  = (i>0)? kom[i-1] : kom[N-1],
        prawysasiad = (i<N-1)? kom[i+1] : *kom;
   return((lewysasiad<<2) | (kom[i]<<1) | prawysasiad);
}

void losowanie(typ_komor *stan_pocz)      /* losowanie stanu poczatkowego */
{
  int i;
  for(i=0; i<N; i++)
     stan_pocz[i] = rand() & 1;
}

int getch(void),
    ungetch(int z);

int zdarzenie(int *xm)
{
  int mmox, mmoy, mmbutton, mmokstate, mkreturn, mbreturn,
      mmgpbuff[8],
      zdarz;
  
  while(1)
  {
     mouse_on();
     zdarz = evnt_multi(MU_KEYBD|MU_BUTTON|MU_MESAG, 2, 1, 1,
                        0, 0, 0, 0, 0,    0, 0, 0, 0, 0,    mmgpbuff,
                        0xFFFF, 0xFFFF, 
                        &mmox, &mmoy, &mmbutton, &mmokstate, 
                        &mkreturn, &mbreturn);
     mouse_off();
     if(zdarz & MU_KEYBD)
     {
        if(strchr(" RJS", mkreturn=toupper((char)mkreturn)))
        {
           *xm = -1;
           return(mkreturn);
        }
        if(isdigit(mkreturn))
        {
           ungetch(mkreturn);
           return(LICZBA);
        }
     }
     else if(zdarz & MU_BUTTON)
     {
        *xm = mmox;
        if(mmoy>=y0 && mmoy<=y0+dy && mmox>=x0 && mmox<x0+dx*N)
           return(STAN_POCZ);
        else if(mmoy>=y0-yx(dx1)/2 && mmoy<y0 && mmox>=x0 && mmox<x0+8*dx1)
           return(REG_MYSZ);
     }
     else if(zdarz & MU_MESAG)
        switch(*mmgpbuff)
        {
         case WM_CLOSED:
              if(mmgpbuff[3]==okno)
                  return(KONIEC);
              break;
         case WM_VSLID:
              if(mmgpbuff[3]==okno)
              {
                 *xm = mmgpbuff[4];
                 return(SCROLLING);
              } 
              break;
         case WM_ARROWED:
              if(mmgpbuff[3]==okno)
                  switch(mmgpbuff[4])
                  {
                   case WA_DNLINE:
                        *xm = 1;
                        return(SCROLLING);
                   case WA_DNPAGE:
                        *xm = -1;
                        return(SCROLLING);
                  }
              break;
       }
  }
}

byte liczba(void)                     /* wczytanie liczby z klawiatury */
{
   const int x = xt+(int)strlen("Regula: ");
   byte regula = 0, i = 0;
   char z;
   
   gotoxy(x, yt);
   printf("    ");
   gotoxy(x, yt);
   cur_on();
   while(isdigit(z=getch()) && i<3)
   {
       regula = 10*regula + z - '0';
       putchar(z);
       i++;
   }
   cur_off();
   return(regula);
}

void opis0(void)
{
   const int bokx = dx1/4, boky = yx(bokx), y = y0 - 3*boky;
   int i, j;
   
   for(i=0; i<=7; i++)
     for(j=0; j<3; j++)
        komorka(x0 + (7-i)*dx1 + (2-j)*bokx, y, bokx, boky, bit(i, j)); 
}

void opis(byte regula)             /* napisanie i "narysowanie" reguly */
{
   const int bokx = dx1/4, boky = yx(bokx), y = y0 - (3*boky)/2;
   int i;

   gotoxy(xt, yt);
   printf("Regula: %d  \b\b", regula);
   sfperimeter(1);
   for(i=0; i<=7; i++)
      komorka(x0+(7-i)*dx1+bokx, y, bokx, boky, bit(regula, i));
   sfperimeter(siatka);
} 

int buf, bufp=0;

int getch(void)
{
   if(bufp)
   {
      bufp = 0;
      return(buf);
   }
   else
     return(evnt_keybd());
}

int ungetch(int z)
{
   if(bufp)
      return('\0');
   else
   {
      bufp = 1;
      return(buf = z);
   }
}