/*----------------------------------------------------------------*/
/*			            	 		UNFILL-Routine    					            */
/*			             		  								   					            */
/* Originalroutine in GFA-BASIC von Dirk Haun											*/
/* C-Konvertierung: Thomas Werner																	*/
/* (c) 1992 Maxon Computer GmbH																		*/
/*----------------------------------------------------------------*/

#include <stdio.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>


extern	int	handle, work_out[];

MFDB		Schirm_mfdb;

void Unfill(void)
{
	MFDB	P1_mfdb, P2_mfdb, P3_mfdb;
	void	*P1, *P2, *P3;
	int		w_out[57], xy[4];

	void	Get(int x1, int y1, int x2, int y2, void *p, MFDB *mp);
	void	Put(int x1, int y1, MFDB *mp, int Mode);
	
	vq_extnd(handle,1, w_out);
	Schirm_mfdb.fd_addr = Physbase();
	Schirm_mfdb.fd_nplanes = w_out[4];
	Schirm_mfdb.fd_w = work_out[0];
	Schirm_mfdb.fd_h = work_out[1];
	Schirm_mfdb.fd_wdwidth = (work_out[0] + 1)/16;
	Schirm_mfdb.fd_stand = 0;
	
	xy[0] = 0;
	xy[1] = 0;
	xy[2] = work_out[0];
	xy[3] = work_out[1];
	vs_clip(handle,1,xy);
	
  P1 = Malloc((long)(work_out[0]+16) * (long)(work_out[1]+1) * (long)w_out[4]);
  if (P1 == NULL)
  {
  	form_alert(1,"[3][ Nicht gengend Speicher frei! ][ Abbruch ]");
		vs_clip(handle,0,xy);
	  vswr_mode(handle, 1);
  	return;
  }
  P2 = Malloc((long)(work_out[0]+16) * (long)(work_out[1]+1) * (long)w_out[4]);
  if (P2 == NULL)
  {
  	form_alert(1,"[3][ Nicht gengend Speicher frei! ][ Abbruch ]");
  	Mfree(P1);
		vs_clip(handle,0,xy);
	  vswr_mode(handle, 1);
  	return;
  }
  P3 = Malloc((long)(work_out[0]+16) * (long)(work_out[1]+1) * (long)w_out[4]);
  if (P3 == NULL)
  {
  	form_alert(1,"[3][ Nicht gengend Speicher frei! ][ Abbruch ]");
  	Mfree(P1);
  	Mfree(P2);
		vs_clip(handle,0,xy);
	  vswr_mode(handle, 1);
  	return;
  }

	graf_mouse(M_OFF,0);
	Get(0,0,work_out[0],work_out[1],P1,&P1_mfdb);
	
	Get(0,1,work_out[0],work_out[1],P2,&P2_mfdb);
	Put(0,0,&P2_mfdb,6);
	Get(0,0,work_out[0],work_out[1],P3,&P3_mfdb);
	
	Put(0,0,&P1_mfdb,3);
	Get(1,0,work_out[0],work_out[1],P2,&P2_mfdb);
	Put(0,0,&P2_mfdb,6);
	
	Put(0,0,&P3_mfdb,7);
	graf_mouse(M_ON,0);
	
	Mfree(P1);
	Mfree(P2);
	Mfree(P3);
	vs_clip(handle,0,xy);
  vswr_mode(handle, 1);
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
	mp->fd_w = x2 - x1;
	mp->fd_h = y2 - y1;
	mp->fd_wdwidth = ((mp->fd_w+15)&0xFFF0)/16;
	mp->fd_nplanes = Schirm_mfdb.fd_nplanes;
	mp->fd_stand = 0;
	
	vro_cpyfm(handle, 3, xy, &Schirm_mfdb, mp);
}


void	Put(int x1, int y1, MFDB *mp, int Mode)
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
	
	vro_cpyfm(handle, Mode, xy, mp, &Schirm_mfdb);
}
