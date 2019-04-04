/************************************************************************
 *                                                                      *
 *  Name: GEMWork.c  Zweck: Vereinfachung verschiedener GEM - Aufrufe   *
 *                                                                      *
 *  Autor: RSB                                                          *
 *  Datum: 23.05.90  Grund: Version fÅr TOS-Magazin                     *
 *                                                                      *
 ************************************************************************/

#include <vdi.h>
#include <aes.h>
#include "GEMWork.h"

/************************************************************************
 * exportierte Variablen                                     			*
 ************************************************************************/

int VDIHandle;
int WorkInFeld[11],WorkOutFeld[57];
int ScreenWidth,ScreenLength,FontWidth,FontHeight,BoxWidth,BoxHeight;
int ScreenPlanes;

/************************************************************************
 * Berechnung der Farbebenen aus der Anzahl der Farben					*
 ************************************************************************/

static int CalcPlanes(int Colors)
{
	int Planes = 0;
	while (Colors > 1)
		Colors = Colors >> 1, Planes++;
	return Planes;
}

/************************************************************************
 * GEM Initialisieren fÅr Pulldown- und Formularhandling                *
 ************************************************************************/

int GemInit()
{
  int i,x,y;

  appl_init();
  VDIHandle = graf_handle(&FontWidth,&FontHeight,&BoxWidth,&BoxHeight);
  for (i = 1; i <= 9; i++)
    WorkInFeld[i] = 1; /* Default-Werte */
  WorkInFeld[10] = 2;  /* Raster Koordinaten */
  WorkInFeld[0] = VDIHandle;
  v_opnvwk(WorkInFeld,&VDIHandle,WorkOutFeld); /* ôffne virtuelle Workstation */
  ScreenPlanes = CalcPlanes(WorkOutFeld[13]);
  wind_get(0,WF_CURRXYWH,&x,&y,&ScreenWidth,&ScreenLength);
  return (VDIHandle);
} /* GemInit */

/************************************************************************
 * GEM Abmelden vor Verlassen der Applikation                           *
 ************************************************************************/

void GemExit(VDIHandle)
int VDIHandle;
{
  v_clsvwk(VDIHandle); /* Schlieûe virtuelle Workstation */
  appl_exit(); 
} /* GemExit */

/************************************************************************
 * GEM gesteuerten Dialog durchfÅhren                                   *
 ************************************************************************/

int DoDialog(OBJECT tree[], int first)
{
  int x,y,w,h;
  int ExitObjekt;
 
  form_center(tree,&x,&y,&w,&h);
  form_dial(FMD_START,0,0,0,0,x,y,w,h);
  form_dial(FMD_GROW,0,0,20,20,x,y,w,h);
  objc_draw(tree,0,8,x,y,w,h);
  ExitObjekt = form_do(tree,first) & 0x7FFF;
  form_dial(FMD_SHRINK,0,0,20,20,x,y,w,h);
  form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
  tree[ExitObjekt].ob_state &= ~SELECTED;
  return (ExitObjekt);
} /* DoDialog */
