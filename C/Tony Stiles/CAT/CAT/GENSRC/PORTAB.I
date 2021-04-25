#ifdef ST
#include <osbind.h>
#endif
#ifdef PC
#include <dos.h>
#include <conio.h>
#endif

/*****************************************************************************/

#ifdef MAIN		

/* This routine should turn the cursor on */

void crson()
{
#ifdef PC
   union REGS in,out;
   in.h.ah= 0x01;
   in.h.ch= 0x00;
   in.h.cl= 0x0e;
   int86(0x10,&in,&out);
#endif
#ifdef ST
   printf("%c%c", 27, 'e');   /* enable cursor */
#endif
}

/* This routine should turn the cursor off */

void crsoff()
{
#ifdef PC
   union REGS in,out;
   in.h.ah= 0x01;
   in.h.ch= 0x00;
   in.h.cl= 0x00;
   int86(0x10,&in,&out);
#endif
#ifdef ST
   printf("%c%c", 27, 'f');   /* disable cursor */
#endif
}

/* This routine clears the screen and homes the cursor */

void cls()
{
#ifdef PC
   union REGS in,out;
   in.h.ah= 0x06;
   in.h.al= 0;
   in.h.bh= 15;
   in.h.ch= 0;
   in.h.cl= 0;
   in.h.dh= 24;
   in.h.dl= 79;
   int86(0x10,&in,&out);
   in.h.ah= 0x02;
   in.h.bh= 0;
   in.h.dh= 0;
   in.h.dl= 0;
   int86(0x10,&in,&out);
#endif
#ifdef ST
   printf("%c%c", 27, 'E');   /* Clr / home */
#endif
}

/* This routine scrolls lines 2 to 24 of the display, leaving 0/1 intact */

void wrap()
{
#ifdef PC
   union REGS in,out;
   in.h.ah= 0x06;
   in.h.al= 1;
   in.h.bh= 15;
   in.h.ch= 2;
   in.h.cl= 0;
   in.h.dh= 24;
   in.h.dl= 79;
   int86(0x10,&in,&out);
   in.h.ah= 0x02;
   in.h.bh= 0;
   in.h.dh= 24;
   in.h.dl= 1;
   int86(0x10,&in,&out);
#endif
#ifdef ST
   printf("%c%c", 27, 'j');
   printf("%c%c%c%c", 27, 'Y', 32+2, 32+0);
   printf("%c%c", 27, 'M');
   printf("%c%c", 27, 'k');
   printf("%c%c", 27, 'l');
#endif
}

/* This routine prints the room description, score and turns
   on the top line of the screen - in inverse */
   
void phead()
{
   char ol[200];
#ifdef PC
   union REGS in,out;
   short int row, column;
   in.h.ah= 0x03;
   in.h.bh= 0;
   int86(0x010,&in,&out);
   row= out.h.dh;
   column= out.h.dl;
   in.h.ah= 0x06;
   in.h.al= 0;
   in.h.bh= 7*16;
   in.h.ch= 0;
   in.h.cl= 0;
   in.h.dh= 0;
   in.h.dl= 79;
   int86(0x010,&in,&out);
   in.h.ah= 0x02;
   in.h.bh= 0;
   in.h.dh= 0;
   in.h.dl= 1;
   int86(0x010,&in,&out);

   if ISDARK
   {
      expand(msg[M_DARKNESS],ol);
      printf("%s", ol);
   }
   else
   {
      expand(rms[odet[player][2]],ol);
      printf("%s", ol);
   }

   in.h.ah= 0x02;
   in.h.bh= 0;
   in.h.dh= 0;
   in.h.dl= 57;
   int86(0x010,&in,&out);

   printf("Score=%04d Turns=%04d", score, turns);

   in.h.ah= 0x02;
   in.h.bh= 0;
   in.h.dh= row;
   in.h.dl= column;
   int86(0x010,&in,&out);
#endif
#ifdef ST
   int xx;
   printf("%c%c", 27, 'j');      /* save cursor */
   printf("%c%c", 27, 'H');      /* home cursor */
   printf("%c%c", 27, 'p');      /* inverse on */
   printf("%c%c", 27, 'l');      /* clear line */
   xx=width();
   if (xx==40)
      printf("%39s", "");
   else
      printf("%79s", "");
   printf("%c%c", 27, 'H');      /* home cursor */
   
   if ISDARK
   {
      expand(msg[M_DARKNESS],ol);
      printf(" %s", ol);
   }
   else
   {
      expand(rms[odet[player][2]],ol);
      printf(" %s", ol);
   }
   
   printf("%c%c%c%c", 27, 'Y', 32, 32+width()-22); /* position */
   printf("Score=%04d Turns=%04d", score, turns);
   printf("%c%c", 27, 'q');      /* inverse off */
   printf("%c%c", 27, 'k');      /* restore cursor posn */
#endif
}

#endif

/*****************************************************************************/

#ifdef SHELL1
#endif

/*****************************************************************************/

#ifdef SHELL2

/* This routine returns a keypress from the keyboard */

int getachar()
{
#ifdef PC
   char c;

   c= bdos(7,0,0);
   if (c==0)
   {
      c= bdos(7,0,0);
      return c;
   }
   else
      return c ;
#endif
#ifdef ST
   return(Crawcin());
#endif
}

/* This routine returns the width of the screen, in characters */

int width()
{
   int w=80;
#ifdef ST
   if (Getrez()==0)
      w=40;
#endif
   return w;
}

/* This routine prints text to the printer */

void prn_out(in)
char *in;
{
   static FILE *prn= NULL;

   if (prn==NULL)
   {
#ifdef PC
      prn= fopen("PRN", "w");
#endif
#ifdef ST
      prn= fopen("prn:", "w");
#endif
      setbuf(prn, NULL);
   }
   fprintf(prn, in);
}

#endif

/*****************************************************************************/

#ifdef SHELL3
/* The function get_secs returns the time in seconds */

#ifdef PC
long get_secs()
{
   long w;
   union REGS in,out;

   in.h.ah= 0x2C;
   int86(0x21,&in,&out);
   w=((long)(out.h.ch))*3600;
   w+= ((long)(out.h.cl))*60;
   w+= ((long)(out.h.dh));
   return w;
}
#endif

#ifdef ST
long get_secs()
{
   long w, t, t1;
   t= Gettime();
   
   t1= ((t&63488L)>>11);
   w+= t1*3600;
   t1= ((t&2016L)>>5);
   w+= (long) t1*60;
   t1= (t&31);
   w+= (long) t1*2;
}
#endif

#endif

/*****************************************************************************/


