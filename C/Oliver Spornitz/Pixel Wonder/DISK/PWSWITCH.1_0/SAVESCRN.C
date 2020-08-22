/************************************************************************
 *																		*
 * 	Modul SAVESCRN.C													*
 *																		*
 *	Copyright 1991: Oliver Spornitz und Detlev Nolte					*
 *																		*
 *	Funktion: Beim zurÅckschalten in die Original Auflîsung wird der	*
 *	Bildschirmspeicher restauriert. Dies ist nicht zwingend notwendig,	*
 *	sieht aber schîner aus. 											*
 *	Den Effekt sieht man am deutlichsten, wenn man die Aufrufe von		*
 *	'save_screen', 'copy_screen' und 'restore_screen' in dem Modul		*
 *	chngeres.c auskommentiert.											*
 *																		*
 ************************************************************************/

/*
 * Die Åblichen Headerfiles
 */
#include <linea.h>
#include <tos.h>


/*
 * Modulheader
 */
#include "piwobind.h"
#include "global.h"
#include "savescrn.h"
#include "chngeres.h"


/*
 * Globale Definition des Moduls
 */
int OLDXPOS, OLDYPOS;
long *OLD_ADR;

BITBLT bitblt;


/*
 * Function save_screen()
 */
void save_screen(void)
{
    OLDXPOS = Vdiesc->v_cur_xy[0];
    OLDYPOS = Vdiesc->v_cur_xy[1];
    OLD_ADR = Vdiesc->v_cur_ad;

	
	/* Bildschirm sichern */
    bitblt.s_xmin = 0;
    bitblt.s_ymin = 0;
    bitblt.d_xmin = 0;
    bitblt.d_ymin = 0;
    bitblt.op_tab[0] = bitblt.op_tab[1] = 0x3;	
    bitblt.op_tab[2] = bitblt.op_tab[3] = 0x3;
    bitblt.s_form = Physbase();
    bitblt.d_form = SCRN_BUF;
    bitblt.s_nxwd = bitblt.d_nxwd = 2;
    bitblt.s_nxln = Vdiesc->bytes_lin;			
    bitblt.d_nxln = Vdiesc->bytes_lin;			
    bitblt.s_nxpl = bitblt.d_nxpl = 2;
    bitblt.p_addr = 0L;
    bitblt.plane_ct = 1;
    bitblt.fg_col = 1; bitblt.bg_col = 0;
    bitblt.b_wd = RESOLD.xdisplayed;			 
    bitblt.b_ht = RESOLD.ydisplayed;			 
    
    bit_blt(&bitblt);
}
/* End of Function save_screen() */


/*
 * Function copy_screen()
 */
void copy_screen(void)
{
	
    bitblt.s_xmin = (RESOLD.xdisplayed-RESBUF.xdisplayed)/2;
    bitblt.s_ymin = 0;
    bitblt.d_xmin = 0;
    bitblt.d_ymin = 0;
    bitblt.op_tab[0] = bitblt.op_tab[1] = 0x3;
    bitblt.op_tab[2] = bitblt.op_tab[3] = 0x3;
    bitblt.s_form = SCRN_BUF;
    bitblt.d_form = Physbase();
    bitblt.s_nxwd = bitblt.d_nxwd = 2;
    bitblt.s_nxln = (RESOLD.xdisplayed)/8;		
    bitblt.d_nxln = Vdiesc->bytes_lin;			
    bitblt.s_nxpl = bitblt.d_nxpl = 2;
    bitblt.p_addr = 0L;
    bitblt.plane_ct = 1;
    bitblt.fg_col = 1; bitblt.bg_col = 0;
    bitblt.b_wd = RESBUF.xdisplayed;			
    bitblt.b_ht = RESBUF.ydisplayed;			
    
    bit_blt(&bitblt);
    
	Vdiesc->v_cur_ad = Physbase();
    Vdiesc->v_cur_xy[0] = 0;
    Vdiesc->v_cur_xy[1] = 0;
}
/* End of Function copy_screen() */


/*
 * Function restore_screen()
 */
void restore_screen(void)
{
    
    bitblt.s_xmin = 0;
    bitblt.s_ymin = 0;
    bitblt.d_xmin = 0;
    bitblt.d_ymin = 0;
    bitblt.op_tab[0] = bitblt.op_tab[1] = 0x3;
    bitblt.op_tab[2] = bitblt.op_tab[3] = 0x3;
    bitblt.s_form = SCRN_BUF;
    bitblt.d_form = Physbase();
    bitblt.s_nxwd = bitblt.d_nxwd = 2;
    bitblt.s_nxln = (RESOLD.xdisplayed)/8;		 
    bitblt.d_nxln = (RESOLD.xdisplayed)/8;		 
    bitblt.s_nxpl = bitblt.d_nxpl = 2;
    bitblt.p_addr = 0L;
    bitblt.plane_ct = 1;
    bitblt.fg_col = 1; bitblt.bg_col = 0;
    bitblt.b_wd = RESOLD.xdisplayed;			 
    bitblt.b_ht = RESOLD.ydisplayed;			 
    
    bit_blt(&bitblt);
	
    Vdiesc->v_cur_xy[0]=OLDXPOS;
    Vdiesc->v_cur_xy[1]=OLDYPOS;
    Vdiesc->v_cur_ad = OLD_ADR;
    
}
/* End of Function restore_screen() */



/******************* End of Modul SAVESCRN.C ************************/