/**********************************************************************
 * BeispielProgramm das zeigt, wie man sich unter dem OVERSCAN-Modus
 * eine 2.BildschirmSeite anlegen kann.
 *
 * Karsten Isakovic    05.07.89
 */

#include <osbind.h>

long OldPhys,NewPhys;
long OldLog ,NewLog ;

long Offset;

#define V_REZ_HZ        -0xc    
#define V_REZ_VT        -4    
#define BYTES_LIN       -2    

main()
{
int  BpL,MaxX,MaxY;
long block,*b,len;

 asm    {
        dc.w    0xa000                  ; LineA-Init
        move.w  BYTES_LIN(A0),BpL(A6)   ; Bytes pro Zeile
        move.w  V_REZ_VT(A0),MaxY(A6)   ; Breite in Pixel
        move.w  V_REZ_HZ(A0),MaxX(A6)   ; Hîhe in Pixel
        }

  OldPhys= Physbase();                   /* Alten Werte holen         */
  OldLog = Logbase();
  Offset = OldLog-OldPhys;               /* Offset bestimmen          */

/* Wenn der PhysbaseEmulator an ist bekommt man bei Physbase den Wert */
/* von Logbase zurÅckgeliefert, kann also den notwendigen Offset nicht*/
/* bestimmen !                                                        */
   
  len  = (long)BpL * (long)MaxY + 5000L; /* Breite*Hîhe + ExtraRÑnder */

  block = Malloc(-1L);                   /* SpeicherPlatz testen      */
  if (block < len)
    {
    Cconws("\n\rNicht genug Speicher.\n\r");
    Cconws("   Return drÅcken..\n\r");
    Cnecin();
    exit(-1);
    }
  else
    Cconws("\r\n\n    MiniDemo fÅr 2. Bildschirm\n\r");

  block  = Malloc(len);                 /* SpeicherPlatz anlegen        */  

  b   = (long *)(block);                /* Speicher auf Schwarz lîschen */
  while((long)b < block+len)            /* Ist wegen dem RÅcklaufStrahl */
      *b++ = -1L;                       /* notwendig                    */

  NewPhys = (block+2000L)&0xffff00L;    /* Physbase berechnen           */ 
  NewLog  = NewPhys + Offset;           /* Logbase  berechnen           */

  demo();
  
  Mfree(block);                         /* Speicher wieder freigeben    */
}

demo()  
{
  Cconws("\n\r Mit den Shift Tasten kann zwischen");
  Cconws("\n\r den beiden Bildschirmen umgeschaltet");
  Cconws("\n\r werden.\r\n\n  Ende durch Tastendruck.");

  Setscreen(NewLog,-1L,-1);           /* 2. Bildschirm auf weiû lîschen    */
  Bconout(2,27);
  Bconout(2,'E');                     
  Cconws("\n\r Dies ist der 2. Bildschirm\n\r");
  Cconws("\n\r   Ich hab ja gesagt, daû es nur");
  Cconws("\n\r   eine MiniDemo ist.");

  while( !Cconis() )                  /* Solange keine Taste gedrÅckt      */
    if ( Kbshift(-1) )                /*   Je nach Status der Sondertasten */
      Setscreen(NewLog,NewPhys,-1);   /*   Shift/Control/Alt Schirm 1 oder */
    else                              /*   Schirm 2 anzeigen               */
      Setscreen(OldLog,OldPhys,-1);      

  Cnecin();                           /* Tastendruck lîschen   */
  Setscreen(OldLog,OldPhys,-1);       /* Wieder zurÅckschalten */
}

