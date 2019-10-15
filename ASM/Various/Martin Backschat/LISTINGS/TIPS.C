/* Simulation der Cursortasten per Joystick */

#include <tos.h>

void joycursor(unsigned char r,unsigned char t,unsigned char v)
        {
        unsigned char joycur[7];
        joycur[0]=0x19;                 /* Befehlswort                          */
        joycur[1]=joycur[2]=r;
        joycur[3]=joycur[4]=t;
        joycur[5]=joycur[6]=v;
        Ikbdws(7,joycur);               /* Joystick als Cursortast.     */
        }

void main(void)
        {
        joycursor(6,2,1);
        }



/* Zustand des Blitters testen bzw. setzen */

int aktiv;

aktiv=Blitmode(-1);      /* Zustand testen */
if(aktiv==1) puts("Blitter an");

else         puts("Blitter aus");

aktiv=Blitmode(1);       /* Blitter einschalten */
aktiv=Blitmode(0);       /* Blitter ausschalten */



/* Welche Laufwerke sind angeschlossen */

int testdrive(int nummer) 
     {

     long drives,bit;

     drives=Drvmap(); /* Laufwerke ermitteln */
     bit=1 << nummer; /* Laufwerksbit setzen */
     return((drives&bit) == bit); /* Testen  */
     }



/* Freien Speicherplatz eines Laufwerks ermitteln */

DSPACE platz; /* Variable fr Informationen */
Dfree(&platz,2); /* Hole Info fr Laufwerk C: */

printf("%lu Bytes pro Sektor\n",platz.bps);
printf("%lu Sektoren pro Cluster\n",platz.pspal);
frei=platz.freal * platz.pspal * platz.bps;
total=platz.total * platz.pspal * platz.bps;
printf("%lu von %lu Bytes frei\n",frei,total);

/* Test auf Co-Prozessor */

if(fpumode(0)==1) puts("MC68881 vorhanden");
else              puts("Kein MC68881 vorhanden");
test=fpumode(1); /* MC68881 aus */


