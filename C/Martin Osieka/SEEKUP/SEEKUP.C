/*********************************************************************
*
* SEEKUP
*
* Kurzbeschreibung:
* SEEKUP schaltet auf STs unter TOS 2.06 die Verdoppelung der
* Seekrate aus (erkennbar am Seek-Ger„usch der Laufwerke)
*
* Versionen:
* 1.0  mo  25.04.92  Basisversion
*
* Autoren:
* mo   (\/) Martin Osieka, Erbacherstr. 2, D-6100 Darmstadt
*
*********************************************************************/

#include <stddef.h>
#include <tos.h>


#define PRGNAME "(\\/) SEEKUP"

#define _sysbase (*((SYSHDR **)0x4F2))

/*** 3. Variante des DSB ***/
typedef struct {
  char cmdbit3;   /* $00 oder $08, wird zum Positionierkommando geodert
                     Kann mit Flopsrate() ver„ndert/abgefragt werden    */
  char dummy;     /* nicht benutzt */
  short track;    /* Aktuelle Spur */
  short hdmode;   /* 0 oder 3, wird in Register $FF860E geschrieben
                     Dieses Register existiert auf STs nicht */
  short seekrate; /* hdmode=0: 0: 6ms, 1: 12ms, 2: 2ms, 3: 3ms
                     hdmode=3: 0,1: 12ms, 2,3: 6ms
                     Kann mit Flopsrate() ver„ndert/abgefragt werden */
} dsb3S;

/*
Das TOS verwaltet die Informationen zu den Floppylaufwerken in DSBs.
Initialisiert werden die DSBs mit { 0, 0, 0xFF00, 3, _seekrate}, damit
ist auf STs defaultmaessig 6ms eingestellt. Die Trackpositionierroutine
schaltet im Fehlerfall <hdmode> um und macht daraufhin einen weiteren
Versuch. Die Formatierfunktion setzt <hdmode> abhaengig von der Anzahl
der Sektoren pro Spur. Besser waere es wohl, wenn das TOS bei jedem
erkannten Diskettenwechsel <hdmode> zunaechst auf 0 setzen wuerde.
*/

/********************************************************************/

int main( void)
{
  void *stk;
  SYSHDR *sys;

  /*** Adresse des OSHEADER bestimmen ***/
  stk = (void *)Super( NULL);
  sys = _sysbase->os_base;
  Super( stk);

  /*** Abbildung der Seekrate ausschalten ***/
  if (sys->os_version == 0x206) {
    dsb3S *pdsb = (dsb3S *)0x160A;
    pdsb->hdmode = 0;
    (pdsb+1)->hdmode = 0;
    Cconws( PRGNAME ": Done.\r\n");
  }
  else {
    Cconws( PRGNAME ": Unsupported TOS.\r\n");
  };

  return( 0);
} /* main */

/********************************************************************/
