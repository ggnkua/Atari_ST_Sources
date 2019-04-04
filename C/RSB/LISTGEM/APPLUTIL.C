/************************************************************************
 * Datei: ApplUtil.c    Zweck: NÅtzliche Funktionen fÅr alle            *
 *                             GEM.Applikationen                        *
 * Autor: RSB                                                           *
 * Datum: 23.05.90      Grund: TOS-Magazin                              *
 ************************************************************************/
 
#include <stdlib.h>
#include <string.h>
#include <vdi.h>
#include <aes.h>
#include "FName.h"
#include "GEMWork.h"
#include "ApplUtil.h"

/* unumgehbare Betriebssystem/Umgebungs-AbhÑngigkeiten */
#ifdef __MSDOS__
	#include <dir.h>	/* MAXPATH, ... */
#else
	#include <ext.h>    /* MAXPATH, ... */
#endif

/************************************************************************
 *  Einblendung des Zwecks bei Aufruf des FileSelectors                 *
 ************************************************************************/

void ShowInfo(const char *InfoText)
{
  const ul = 2;
  int k[4] = { 0, 0,  };

  k[2] = ScreenWidth-1; k[3] = FontHeight+1;
  vs_clip(VDIHandle,1,k);
  vsf_interior(VDIHandle,FIS_SOLID);
  vsf_color(VDIHandle,0);		/* WHITE */
  v_bar(VDIHandle,k);
  v_gtext(VDIHandle,(ScreenWidth-(int)strlen(InfoText)*FontWidth) >> 1,
  					FontHeight-ul,(char *) InfoText);
  vs_clip(VDIHandle,0,k);
  k[1] = ++k[3];
  v_pline(VDIHandle,2,k);
} /* ShowInfo */

/************************************************************************
 *  I/O - Funktionen                                                    *
 ************************************************************************/

int HoleVollName(char *Pfad, char *VollName, const char *Kommentar)
{
  char merkPfad[MAXPATH], Name[MAXFILE+MAXEXT];
  
  Name[0] = '\0';
  if (Orte(Pfad,Name,Kommentar) == 0) 
    return 0;
  stcgfp(merkPfad,Pfad); /* Maske entfernen */
  if (merkPfad[strlen(merkPfad)-1] == ':') {
    int i = (int)strlen(merkPfad);
    merkPfad[i++] = _SLASH;
    merkPfad[i] = '\0';
  }
  strmfp(VollName,merkPfad,Name);
  return 1;
} /* HoleVollName */

/************************************************************************
 *  Datei im Dateisystem mittels FileSelector lokalisieren              *
 ************************************************************************/

int Orte(char *Pfad, char *Name, const char *Kommentar)
{
  char merkPfad[MAXPATH], merkName[MAXFILE+MAXEXT];
  int ExButton;

  ShowInfo(Kommentar);
  strcpy(merkPfad,Pfad);
  strcpy(merkName,Name);
  fsel_input(Pfad,Name,&ExButton);
  if (ExButton == 0) {
    strcpy(Pfad,merkPfad); 
    strcpy(Name,merkName);
  }
  return ExButton;
} /* Orte */           

/************************************************************************
 * Bildschirmbereich lîschen				                    		*
 ************************************************************************/

void Clear(int x, int y, int w, int h)
{
	int k[4];
	
	k[0] = x; k[1] = y; k[2] = x+w; k[3] = y+h;
	
	/* Hintergrund weiû ausmalen */
	vsf_interior(VDIHandle,FIS_PATTERN); /* FÅlltyp 2 */
	vsf_style(VDIHandle,8); /* UNI einfarbiges Muster */
	vsf_color(VDIHandle,WHITE/*BLACK*/); /* Farbe weiû */
	v_bar(VDIHandle,k); /* fÅlle Hintergrund */
	
} /* Clear */

