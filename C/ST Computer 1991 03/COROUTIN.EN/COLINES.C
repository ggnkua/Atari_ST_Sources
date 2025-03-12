/*                                                                         *\
                 colines.c - Demo fÅr die Verwendung von
                     NEWPROCESS und TRANSFER unter C
\*                                                                         */


#include <stdio.h>                            /* Nur fÅr 'calloc'          */
#include <osbind.h>
#include <gembind.h>
#include "process.h"


#define MIN_Y                              10 /* Arbeitsbereich:           */
#define MAX_Y                             390 /* Kann der aktuellen Bild-  */
#define MIN_X                              10 /* schirmauflîsung angepaût  */
#define MAX_X                             630 /* werden                    */

#define STACKSIZE                        2048 /* Grîûe der lokalen Stacks  */
#define STACK                             int /* Typ des Stacks            */

#define MAXLINES                           70 /* Anzahl der Linie in proc1 */
#define LINE_COOR                           4 /* /2: Anzahl der Eckpunkte  */
#define FIGR_COOR                           8 /*     in proc1 bzw. proc2   */
#define MIN_SPEED                           2 /* Geschwindigkeit der       */
#define MAX_SPEED                           4 /* Objekte                   */

#define COOR(x)                    ((x&1)<<1) /* Einige Makros             */
#define SIGN(x)                  (x<0 ? -1:1)
#define NEXT(x)              ((x+1)%MAXLINES)
#define SPEED  (Random()%MAX_SPEED+MIN_SPEED)


int contrl [12],
    intin [128],
    ptsin [128],
    intout[128],
    ptsout[128];
int handle,
    ap_id;

long mainprocess,                             /* Coroutinen-Variablen      */
     process1,
     process2;

int limits1[4] = {MIN_X, MAX_X, MIN_Y, MAX_Y/2-1},   /* Arbeitsbereich fÅr */
    limits2[4] = {MIN_X, MAX_X, MAX_Y/2+1, MAX_Y};   /* proc1 bzw. proc2   */



proc1()
{
   int  lines[MAXLINES][LINE_COOR];
   int  vel  [LINE_COOR];                     /* Geschwindigkeitsvektoren  */
   register int act_line;

   for (act_line=0; act_line<MAXLINES*LINE_COOR; act_line++)
      *((int *)lines+act_line) = limits1[COOR(act_line)];
   for (act_line=0; act_line<LINE_COOR; vel[act_line++]=-1);

   act_line=0;
   for (;;)                                   /* Normales Prozedurende darf*/
   {                                          /* nicht erreicht werden     */
      check_line (lines[act_line], lines[NEXT(act_line)], vel);

      act_line = NEXT(act_line);
      v_pline (handle, LINE_COOR/2, lines[act_line]);
      v_pline (handle, LINE_COOR/2, lines[NEXT(act_line)]);

      if (act_line&1)                         /* Nach jedem 2. Durchlauf   */
      {                                       /* Kontrolle abgeben:        */
         if (Cconis())                        /* Taste gedrÅckt?           */
            TRANSFER (&process1,&mainprocess);/* => ENDE                   */
         else                                 /* sonst                     */
            TRANSFER (&process1, &process2);  /* => proc2 bearbeiten       */
      }
   }
}


check_line (actl, newl, vel)                  /* Berechnet Koordinaten der */
int actl[],                                   /* nÑchsten Linie            */
    newl[],
    vel[];
{
   register int i, j;

   for (i=0; i<LINE_COOR; i++)
   {
      newl[i] = actl[i]+vel[i];               /* Neue Koordinate berechnen */
      j = COOR(i);                            /* Index fÅr min.x bzw min.y */

      if (newl[i]>limits1[j+1])               /* Neue Koordinate zu groû?  */
      {
         newl[i] = limits1[j+1];
         vel [i] = -SPEED;
         continue;
      }
      if (newl[i]<limits1[j])                 /* Neue Koordinate zu klein? */
      {
         newl[i] = limits1[j];
         vel [i] = SPEED;
      }
   }
}


proc2()
{
   int  figure[FIGR_COOR+2];                  /* Erster und letzter Punkt  */
   int  vel   [FIGR_COOR];                    /* des Objekts sind identisch*/
   register int i, j;

   for (i=0; i<FIGR_COOR; figure[i]=limits2[COOR(i)], vel[i++]=1);
   
   for (;;)
   {
      if (!(figure[0]%100 && figure[1]%100))  /* Ab und zu ...             */
         for (i=0; i<FIGR_COOR; i++)          /* neue Geschwindigkeits-    */
             vel[i] = SPEED * SIGN(vel[i]);   /* vektoren berechnen        */

      v_pline (handle, FIGR_COOR/2+1, figure);

      for (i=0; i<FIGR_COOR; i++)
      {
         j = COOR(i);
         figure[i] += vel[i];
         
         if (figure[i]>limits2[j+1] || figure[i]<limits2[j])
            figure[i] += vel[i] = -vel[i];
      }

      figure[FIGR_COOR]   = figure[0];
      figure[FIGR_COOR+1] = figure[1];
      v_pline (handle, FIGR_COOR/2+1, figure);

      TRANSFER (&process2, &process1);        /* Kontrolle zurÅck an proc1 */
   }
}


int *edge (lim)                               /* éndern der Koordinaten-   */
int lim[];                                    /* darstellung von           */
{                                             /* {minx, maxx, miny, maxy}  */
   static int xyarray[4];                     /* in                        */
                                              /* {minx, miny, maxx, maxy}  */
   xyarray[0] = lim[0];
   xyarray[1] = lim[2];
   xyarray[2] = lim[1];
   xyarray[3] = lim[3];

   return (xyarray);
}


main()
{
   int work_in[11],
       work_out[57],
       pxyarray[4];
   int i;
   STACK  stack1[STACKSIZE],                  /* Zwei Mîglichkeiten Platz  */
         *stack2;                             /* fÅr den lokalen Stack zu  */
                                              /* reservieren               */
   ap_id = appl_init();
   handle = graf_handle (&i, &i, &i, &i);

   for (i=0; i<10; work_in[i++]=1);
   work_in[10]=2;
   v_opnvwk (work_in, &handle, work_out);

   graf_mouse (256);
   v_clrwk (handle);
   vswr_mode (handle, 3);                     /* VDI-Schreibmodus auf XOR  */

   pxyarray[0] = MIN_X;
   pxyarray[1] = MIN_Y;
   pxyarray[2] = MAX_X;
   pxyarray[3] = MAX_Y;
   vs_clip (handle, 1, pxyarray);             /* Cipping auf Arbeitsbe-    */
                                              /* reich setzen              */

   vsf_interior (handle, 3);                  /* 'Box' fÅr proc1 ...       */
   vsf_style    (handle, 9);
   v_rfbox (handle, edge(limits1));

   vsf_interior (handle, 1);                  /* und proc2 zeichnen        */
   v_rfbox (handle, edge(limits2));

/*                          Coroutinen erzeugen                            */

   NEWPROCESS (proc1, stack1, STACKSIZE, &process1);
   
   stack2 = (STACK *)calloc (STACKSIZE, sizeof (STACK));
   NEWPROCESS (proc2, stack2, STACKSIZE, &process2);

   TRANSFER (&mainprocess, &process1);        /* Kontrolle an proc1 geben  */


   v_clsvwk (handle);
   graf_mouse (257);
   appl_exit();
}


