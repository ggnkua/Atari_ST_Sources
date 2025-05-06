
#include <osbind.h>
#include <bios.h>



#define FVERIFY ((int *) 0x0444L)
#define PHYSTOP ((long *) 0x42E)

#define BOOLEAN int
#define TRUE 1
#define FALSE 0



void itoa(n,s)
   register int
      n;
   register char
      *s;
{
   /*
      Fast and small integer to ASCII conversion; leaves off leading
      zeroes.
   */
   register int
      digit,divisor;
   register BOOLEAN
      leading = TRUE;

   for (divisor = 10000; divisor; n %= divisor, divisor /= 10)
      if ((digit = n/divisor) || !leading) {
         *s++ = digit+'0';
         leading = FALSE;
      }
   *s = '\0';
} /* itoa */



void write_s(dev,s)
   register int
      dev;
   register char
      *s;
{
   /*
      Write a string; user can't abort program with ctrl-C, pause
      listing, etc., as with Cconws.
   */
   while (*s)
      Bconout(dev,*s++);
} /* write_s */



main()
{
   register int
      c;
   register long
      map;
   char
      s1[20],s2[20];
   long
      save_ssp;

   write_s(2,"E"); /* clear screen */
   write_s(2,"\n/*--------------------*/\r\n");
   write_s(2,"/*  p DeskJet Booter q  */\r\n");
   write_s(2,  "/*  by Doug Harrison  */\r\n");
   write_s(2,  "/*--------------------*/\r\n\n\np");

   save_ssp = Super(0L); /* Enter supervisor */

/*
   Uncomment this to disable floppy write with verify. I used to do this,
   but unfortunately it also turns off ICD's hard drive booter's verify
   mode, which uses this location as a flag.

   *FVERIFY = 0;
*/

   itoa((int) (*PHYSTOP/1024),s1); /* total memory */

   Super(save_ssp); /* Exit supervisor */

   itoa((int) (Malloc(-1L)/1024),s2); /* largest free block */

   /*
      Display total RAM and "free" RAM.
   */
   write_s(2,s1);
   write_s(2,"K computer, with ");
   write_s(2,s2);
   write_s(2,"K free.\r\n\n");

   /*
      Display active drives.
   */
   write_s(2,"Drives: ");
   for (map = Drvmap(), c = 'A'; map; c++) {
      if (map & 1)
         Bconout(2,c);
      if ((map >>= 1) & 1)
         Bconout(2,',');
   }

   write_s(2,".\r\n\n");
   if (Cprnos()) {
      /*
         This check of the printer status is confounded if a spooler is
         active; well if Migraph's OSpooler is active, anyway. But this
         accessory can only be active at the GEM level, so it isn't a
         problem when running DJETBOOT from the AUTO folder. Not sure
         what other spoolers will do here.
      */
      write_s(0,"(s1Q");
      write_s(2,"DeskJet Print Quality set to Draft.\r\n");
   }
   else
      write_s(2,"DeskJet isn't online...\r\n");
/*
   Uncomment this to get the nice message.

   write_s(2,"Write verify turned OFF.\r\n\n");
*/
   write_s(2,"\r\n\nq"); /* normal video */
   exit(0);
} /* main */

