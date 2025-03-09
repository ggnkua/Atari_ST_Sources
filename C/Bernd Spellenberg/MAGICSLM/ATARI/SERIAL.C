/* MagicSLM - Serielles Modul                  */
/* by Bernd Spellenberg & Harald Sch”nfeld     */
/* (c) Maxon 1995                              */

# include <stdio.h>
# include <tos.h>
# include <string.h>

                /* Gr”že des seriellen Buffers */
# define SBUFFSIZE 16384
         /* Untere und obere Wasserstandsmarke */
# define IBLOW SBUFFSIZE/2
# define IBHI SBUFFSIZE/4*3

# define XON  17        /* Werte fr XON, XOFF */
# define XOFF 19

/* Prototyp                                    */
extern int CheckButton(void);

char buffer[SBUFFSIZE];    /* Serieller Buffer */

IOREC iorecold, /* Buffer fr alte IOREC-Struk.*/
      *iorec;    /* Pointer auf IOREC-Struktur */

/* Serielle Schnittstelle auf eigenen Buffer   */
/* und eigene Bearbeitung umstellen            */

void SInit (void)
{
   iorec=Iorec(0);       /* Alte IOREC sichern */
   memmove(&iorecold,iorec,sizeof(IOREC));
   
   iorec->ibuf=buffer;         /* Neuer Buffer */
   iorec->ibufsiz=SBUFFSIZE;   /* dessen Gr”že */
   iorec->ibufhd=0;    /* N„chste Inputadresse */
   iorec->ibuftl=0;     /* N„chste Leseadresse */
   iorec->ibuflow=IBLOW;  /* Wasserstandsmarken*/
   iorec->ibufhi=IBHI;
}

/* Altes IOREC wieder herstellen               */

void SClose (void)
{
   memmove(iorec,&iorecold,sizeof(IOREC));
}

/* Feststellen ob Zeichen im ser. Buffer ist   */       

int SRec(void)
{
   return iorec->ibufhd != iorec->ibuftl;
}


static int XOn=1;         /* Flag fr XON/XOFF */

/* XON oder XOFF senden                        */

void XOnOff(int Mode)
{
   if(!Mode) {
      XOn=1;                    /* Flag setzen */
      Bconout(1,XON); /*Zeichen auf ser. senden*/
   } else {
      Bconout(1,XOFF);
      XOn=0;
   }
}

/* N„chstes Zeichen aus ser. Buffer lesen      */
/* und Mausoperation abfragen                  */

int SGet(void)
{
   int Byte,                 /* Gelesenes Byte */
   Button;                /* Gedrckter Button */
   
      /* Auf n„chstes Zeichen warten und dabei */
   while(iorec->ibufhd==iorec->ibuftl) {
      Button=CheckButton(); /* Buttons abfragen*/
      if (Button)       /* Wenn gedrckt, dann */
         return Button;    /* Wert zurckgeben */
   }

           /* N„chstes Byte lesen, Lesepointer */
   iorec->ibufhd++;        /* zyklisch erh”hen */
   iorec->ibufhd=iorec->ibufhd%SBUFFSIZE;
   Byte=buffer[iorec->ibufhd];
   
        /* Falls obere Wasserstandsmarke ber- */
                     /* schritten: XOFF senden */
   if(((iorec->ibuftl-iorec->ibufhd+SBUFFSIZE)
                              %SBUFFSIZE)>IBHI)
         XOnOff(1);

      /* Falls untere Wasserstandsmarke unter- */
                      /* schritten: XON senden */

   if(!XOn)
      if(((iorec->ibuftl-iorec->ibufhd+SBUFFSIZE)
                              %SBUFFSIZE)<IBLOW)
         XOnOff(0);

   return Byte;  /* Gelesenes Byte zurckgeben */
}
