/************************************************************************/
/* -------------------------------------------------------------------- */
/* -------------------------------------------------------------------- */
/*	  Low Level GUI functions											*/
/* -------------------------------------------------------------------- */
/* -------------------------------------------------------------------- */
/************************************************************************/

#include <tos.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <vdi.h>
#include <aes.h>
#include <portab.h>

#include "CKBD.H"
#include "CKBD_RSC.H"
#include "XCONTROL.H"

/************************************************************************/
/* global var's															*/
USERBLK		dummy;
USERBLK 	ublk[4];				/* 4 userblocks needed */
int			userhandle;				/* own VDI handle */
MFDB		screen_mfdb;
int			work_in[11]= { 1,1,1,1,1,1,1,1,1,1,2 },
			work_out[57];
char		*fileselect_name;		/* 'Abfallprodukt' FILESELECT */

extern OBJECT		*images;
extern CPX_PARAMS	*xpcb;


/************************************************************************/
/* User-defined draw functions... */
WORD cdecl draw_radiobutton(PARMBLK *pb)
{
	BITBLK *im;

	if (pb->pb_currstate & SELECTED)
		im = images[RADIOBUT_SEL].ob_spec.bitblk;
	else
		im = images[RADIOBUT_NORM].ob_spec.bitblk;
	return draw_imagebutton(pb, im);
}

WORD cdecl draw_crossbutton(PARMBLK *pb)
{
	BITBLK *im;

	if (pb->pb_currstate & SELECTED)
		im = images[SELBUTTON_SELECT].ob_spec.bitblk;
	else
		im = images[SELBUTTON_NORM].ob_spec.bitblk;
	return draw_imagebutton(pb, im);
}


WORD draw_imagebutton(PARMBLK *pb, BITBLK *im)
{
	WORD	xy[8], xy_clip[4];
	MFDB	image;
	int 	colarray[2];

	/* Set Clip: */
	xy_clip[0] = pb->pb_xc;
	xy_clip[1] = pb->pb_yc;
	xy_clip[2] = pb->pb_xc + pb->pb_wc - 1;
	xy_clip[3] = pb->pb_yc + pb->pb_hc - 1;

	vs_clip(userhandle, 1, xy_clip);

	/* Zuerst den Button richtig zeichnen: */
	image.fd_addr	= im->bi_pdata;
	image.fd_w		= im->bi_wb << 3;		/* *2^3 */
	image.fd_h		= im->bi_hl;
	image.fd_wdwidth= (im->bi_wb+1) >> 1;
	image.fd_stand	= 0;				/* 0 = gerÑteabhÑngiges Format */
	image.fd_nplanes= 1;
	colarray[0] 	= im->bi_color;
	colarray[1] 	= 0;
	xy[0]	= 0;				xy[1]	= 0;
	xy[2]	= image.fd_w-1; 	xy[3]	= image.fd_h-1;
	xy[4]	= pb->pb_x; 		xy[5]	= pb->pb_y;
	xy[6]	= pb->pb_x + xy[2]; xy[7]	= pb->pb_y + xy[3];

	vrt_cpyfm( userhandle, MD_REPLACE, xy, &image, &screen_mfdb, colarray );

	if (pb->pb_prevstate == pb->pb_currstate)
	{	/* auch den Text neuzeichnen! */
		v_gtext( userhandle, xy[6]+8, xy[5], (char *)pb->pb_parm );
	}
	return (pb->pb_currstate & ~SELECTED);
}


/* VDI fÅr USERDEF - Objekte initialisieren
 * Paramester:	keine
 * Return:		nichts
 * SideEffects: globale var 'userhandle' wird gesetzt
 */
void init_uvdi(void)
{
	int 	dummy;

	userhandle = xpcb->handle;
	v_opnvwk(work_in, &userhandle, work_out);
	vst_alignment(userhandle, 0, 5, &dummy, &dummy);
}


/* VDI Workstation schlieûen fÅr Userdefs
 * Parameter:	keine
 * Return:		keine
 * SideEffects: reset userhandle
 */
void exit_uvdi(void)
{
	v_clsvwk(userhandle);
}

/************************************************************************/
/* FILESELECT interface...												*/
/* in:	path: kpl. Pfad mit evtl. Filenamen								*/
/*		mask: Suchmaske *.*												*/
/*		title: Titelzeile fÅr FSEL_EXINPUT								*/
/* out: fileselect(): TRUE wenn was ausgewÑhlt wurde					*/
/*		path: entsprechend geÑndert										*/
int fileselect(char *path, char *mask, char *title)
{
	char	mypath[256], myfile[20], *a;
	int		butn, fret;
	
	strcpy(mypath, path);					/* pfad kopieren */
	if ((a=strrchr(mypath, '\\'))==NULL) {
		mypath[0]=Dgetdrv()+'A'; mypath[1]=':';
		Dgetpath(&mypath[2], 0); 
		a=strrchr(mypath, 0); *a++='\\';
		myfile[0]=0;
	} else {
		strcpy(myfile, ++a);				/* Namen kopieren */
	};
	strcpy(a, mask);						/* Maske dazu */

	wind_update(BEG_UPDATE);
	fret=fsel_exinput(mypath, myfile, &butn, title);
	wind_update(END_UPDATE);

	if ((fret!=0) && (butn==1)) {
		if ((a=strrchr(mypath, '\\'))==NULL) return FALSE;
		strcpy(path, mypath); a=strrchr(path, '\\');
		strcpy(++a, myfile); fileselect_name=a;
		return TRUE;
	} else return FALSE;
}

/*----------------------------------------------------------------------*/
