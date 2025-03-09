/*----------------------------------------------------------------*/
/*					Demo zur Routine zur (Grafik-)Text-Eingabe 						*/
/*																																*/
/* Originalroutine in GFA-BASIC von Tom Quellenberg 							*/
/* C-Konvertierung: Thomas Werner																	*/
/* (c) 1992 Maxon Computer GmbH																		*/
/*----------------------------------------------------------------*/

#include <stddef.h>
#include <stdio.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include "cursor.h"


extern	int	handle, work_out[];


MFDB	Schirm_mfdb;


void gem_prg()
{
	MFDB	Puffer_mfdb;
	void	*Puffer;
	int		xy[4], w_out[57], Modus, Stil, Winkel, Groesse, exit, d;
	
	void	Get(int x1, int y1, int x2, int y2, void *p, MFDB *mp);
	void	Put(int x1, int y1, MFDB *mp);
	
	
	vq_extnd(handle,1, w_out);
	Schirm_mfdb.fd_addr = Physbase();
	Schirm_mfdb.fd_nplanes = w_out[4];
	Schirm_mfdb.fd_w = work_out[0] + 1;
	Schirm_mfdb.fd_h = work_out[1];
	Schirm_mfdb.fd_wdwidth = (work_out[0] + 1)/16;
	Schirm_mfdb.fd_stand = 0;

	xy[0] = 0;
	xy[1] = 0;
	xy[2] = work_out[0];
	xy[3] = work_out[1];
	vs_clip(handle, 1, xy);
	
	graf_mouse(M_OFF,0);
	v_clrwk(handle);
  vswr_mode(handle, 1);
	graf_mouse(ARROW,0);
	graf_mouse(M_ON,0);
	
  Puffer = Malloc((long) work_out[0] * (long) work_out[1] * w_out[4]);
  if (Puffer == NULL)
  {
  	form_alert(1,"[3][ Nicht genÅgend Speicher frei! ][ Abbruch ]");
		vs_clip(handle,0,xy);
	  vswr_mode(handle, 1);
  	return;
  }
	
	do
	{
		Get(0,0,work_out[0],work_out[1],Puffer,&Puffer_mfdb);
		Modus = form_alert(0,"[2][ EndgÅltige Ausgabe | mit Schreibmodus ][ REPLACE | TRANSPARENT ]");
		graf_mouse(M_OFF,0);
		printf("\n\n Textstil <0..31>? ");
		scanf("%i",&Stil);
		printf("\n Ausgabewinkel <0, 90, 180, 270>? ");
		scanf("%i",&Winkel);
		printf("\n Textgrîûe <0..27>? ");
		scanf("%i",&Groesse);
		Put(0,0,&Puffer_mfdb);
		vst_rotation(handle, Winkel*10);
		vst_effects(handle,Stil);
		vst_height(handle, Groesse, &d, &d, &d, &d);
		graf_mouse(M_ON,0);
		Gem_Text(Modus);
		exit = form_alert(1,"[2][ Demo beenden? ][ Ja | Nein ]");
	} while (exit != 1);
	vs_clip(handle, 0, xy);
}


void	Get(int x1, int y1, int x2, int y2, void *p, MFDB *mp)
{
	int	xy[8];


	xy[0] = x1;
	xy[1] = y1;
	xy[2] = x2;
	xy[3] = y2;
	xy[4] = 0;
	xy[5] = 0;
	xy[6] = x2 - x1;
	xy[7] = y2 - y1;
	
	mp->fd_addr = p;
	mp->fd_nplanes = Schirm_mfdb.fd_nplanes;
	mp->fd_w = ((x2 - x1) + 16) & 0xFFF0;
	mp->fd_h = y2 - y1;
	mp->fd_wdwidth = mp->fd_w/16;
	mp->fd_stand = 0;
	
	graf_mouse(M_OFF, 0);
	vro_cpyfm(handle, 3, xy, &Schirm_mfdb, mp);
	graf_mouse(M_ON, 0);
}


void	Put(int x1, int y1, MFDB *mp)
{
	int	xy[8];


	xy[0] = 0;
	xy[1] = 0;
	xy[2] = mp->fd_w;
	xy[3] = mp->fd_h;
	xy[4] = x1;
	xy[5] = y1;
	xy[6] = x1 + mp->fd_w;
	xy[7] = y1 + mp->fd_h;
	
	graf_mouse(M_OFF, 0);
	vro_cpyfm(handle, 3, xy, mp, &Schirm_mfdb);
	graf_mouse(M_ON, 0);
}
