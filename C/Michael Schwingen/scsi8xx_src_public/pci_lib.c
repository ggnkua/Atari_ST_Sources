/******************************************************************************/
/*                                                                            */
/*                           P C I - B I O S   V1.00                          */
/*                                                                            */
/*                        Das PCI-Bios fÅr HADES040/060                       */
/*                                                                            */
/*  Modul:         PCI-BIOS (PCI_BIOS.LIB)                                    */
/*  File:          PCI_LIB.C                                                  */
/*  Teilaufgabe:   PCI-Library                                                */
/*  Beschreibung:  Installationsroutine fÅr das PCI-BIOS Interface            */
/*  Bemerkung:     öberprÅft, ob ein _PCI Cookie installiert ist, und ob die  */
/*                 Versionsnummer des Routinenpools auch mit der Library      */
/*                 unterstÅtzt wird. Anderenfalls wird eine entsprechende     */
/*                 Fehlermeldung an das aufrufende Programm zurÅckgegeben.    */
/*  Funktionen:    pcibios_init                                               */
/*                                                                            */
/*  (c)1997/98 Markus Fichtenbauer                               01.02.1998   */
/*                                                                            */
/******************************************************************************/
/* $Id$ */
/******************************************************************************/
/* $Log$ */

#include <stddef.h>                   /* Standard-Definitionen (NULL,...)     */
#include <portab.h>                   /* Portab-Deklarationen (ULONG,...)     */
#include <osbind.h>                   /* Betriebsystemfunktionen (Super,...) 
 */

#include "pci_lib.h"                 /* PCI-BIOS Interface                */

typedef LONG (*PROCREF)();
typedef struct                         /* Aufbau des _PCI - Cookies           */
{
  ULONG   *subcookie;                  /* Sub-Cookie von PCI_CONF             */
  ULONG   version;                     /* Versionsnummer des PCI-Bios         */
  PROCREF routine[45];                 /* Platz fÅr die Adressen der Routinen */
} PCI_COOKIE;
int getcookie(ULONG cookie, ULONG *value);

#define Cookie_PCI     0x5F504349L     /* '_PCI'  PCI-Bios Cookie             */
#define HIGHW(x)  ((x>>16) & 0xFFFFL)           /* Makro fÅr Higher word      */
#define LOWW(x)   (x & 0xFFFFL)                 /* Makro fÅr Lower word       */



/******************************************************************************/
/*                                                                            */
/*  Unterprogramm:  LONG pcibios_init (void)                                  */
/*                                                                            */
/*  Beschreibung:   sucht nach einem _PCI Cookie und stellt die Versions-     */
/*                  nummer des Routinenpools fest.                            */
/*                                                                            */
/*  Parameter:      Returnwert = PCI-BIOS Fehlercode                          */
/*                                                                            */
/******************************************************************************/
PCI_COOKIE *bios_cookie = 0;    /* Pointer auf PCI-BIOS Struktur */
LONG pcibios_init(void)
{
  int status;

  status = getcookie(Cookie_PCI, (ULONG*) &bios_cookie);

  if (!status)
    return PCI_BIOS_NOT_INSTALLED;     /* kein _PCI Cookie vorhanden          */

/*	bprintf("PCI cookie found at %p\n",bios_cookie);*/
/*  Um welche Version des Routinenpools handelt es sich denn Åberhaupt ?      */
  switch ((UWORD)(bios_cookie->version >> 16))
  {
    case (0x0001):                     /* aktuelle Version                */
      return PCI_SUCCESSFUL;
    break;

    case 0:                          /* das ist nur PCI_CONF installiert      */
      return PCI_BIOS_NOT_INSTALLED;
    break;

    default:                         /* alte oder unbekannte Pool-Version     */
      return PCI_BIOS_WRONG_VERSION;
  }
  return PCI_BIOS_NOT_INSTALLED;
}

int getcookie(ULONG cookie, ULONG *value)
{
	ULONG	*cookies = (ULONG*) Setexc(0x5a0/4, -1);

	if ( !cookies )
	  return 0;
	
	for( ; *cookies; cookies += 2)
	  if ( *cookies == cookie )
	  {
	    *value = cookies[1];
	    return 1;
	  }

	return 0;
}
