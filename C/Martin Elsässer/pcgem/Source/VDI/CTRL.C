/******************************************************************************/
/*																										*/
/*     Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C       */
/*																										*/
/* Die (N)VDI-Funktionen - Kontroll-Funktionen											*/
/*																										*/
/*	(c) 1999 by Martin ElsÑsser																*/
/******************************************************************************/

#include <ACSVDI.H>

/******************************************************************************/
/*																										*/
/* VDI   1: Open Workstation																	*/
/*																										*/
/******************************************************************************/

void v_opnwk( INT16 *work_in, INT16 *handle, INT16 *work_out, INT16 max_x, INT16 max_y )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={1, 0, 6, 11, 45};
	
	/* Wenn sinnvoll Werte fÅr max_x und max_y Åbergeben wurden,     */
	/* werden diese auch Åbergeben - evtl. fÅr den Drucker bestimmt! */
	if( max_x>0 && max_y>0 )
	{
		INT16 ptsin[10];
		
		/* Die Werte eintragen */
		ptsin[0]=max_x;
		ptsin[1]=max_y;
		contrl[1]=1;
		
		/* VDI aufrufen */
		vdi(contrl, work_in, ptsin, work_out, &(work_out[45]));
	}
	else
	{
		/* VDI aufrufen */
		vdi(contrl, work_in, _VDIParBlk.ptsin, work_out, &(work_out[45]));
	}
	
	/* RÅckgabewert auswerten */
	if( handle!=NULL )
		*handle=contrl[6];
}

/******************************************************************************/
/*																										*/
/* VDI   2: Close Workstation																	*/
/*																										*/
/******************************************************************************/

void v_clswk( const INT16 handle )
{
	/* contrl anlegen */
	INT16 contrl[12]={2, 0, 0, 0, 0, 0};
	
	/* handle eintragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}
		
/******************************************************************************/
/*																										*/
/* VDI 100: Open virtual Workstation														*/
/*																										*/
/******************************************************************************/

void v_opnvwk( INT16 *work_in, INT16 *handle, INT16 *work_out )
{
	/* contrl anlegen und fÅllen */
	static INT16 contrl[12]={100, 0, 6, 11, 45, 0};
	
	/* VDI-Handle eintragen */
	contrl[6]=*handle;
	
	/* VDI aufrufen */
	vdi(contrl, work_in, _VDIParBlk.ptsin, work_out, &(work_out[45]));
	
	/* RÅckgabewert auswerten */
	*handle=contrl[6];
}

/******************************************************************************/
/*																										*/
/* VDI 101: Close virtual Workstation														*/
/*																										*/
/******************************************************************************/

void v_clsvwk( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={101, 0, 0, 0, 0, 0};
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI   3: Clear Workstation																	*/
/*																										*/
/******************************************************************************/

void v_clrwk( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={3, 0, 0, 0, 0, 0};
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI   4: Update Workstation																*/
/*																										*/
/******************************************************************************/

INT16 v_updwk( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={4, 0, 0, 0, 0, 0};
	INT16 intout[10];
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[10];
}

/******************************************************************************/
/*																										*/
/* VDI 119: Load Fonts																			*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

INT16 vst_load_fonts( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={119, 0, 0, 1, 1, 0};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	intin[0]=0;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	INT16 vst_load_fonts( const INT16 handle, const INT16 select )
#else
	INT16 vst_load_fonts_( const INT16 handle, const INT16 select )
#endif
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={119, 0, 0, 1, 1, 0};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	intin[0]=select;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 120: Unload Fonts																		*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

void vst_unload_fonts( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={120, 0, 0, 1, 0, 0};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	intin[0]=0;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	void vst_unload_fonts( const INT16 handle, const INT16 select )
#else
	void vst_unload_fonts_( const INT16 handle, const INT16 select )
#endif
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={120, 0, 0, 1, 0, 0};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	intin[0]=select;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 129: Set Clipping Rectangle															*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

void vs_clip( const INT16 handle, const INT16 clip_flag, const Axywh *rect )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={129, 2, 0, 1, 0, 0};
	
	/* intin anlegen und fÅllen */
	INT16 intin[10];
	
	/* ptsin anlegen */
	INT16 ptsin[10];
	
	ptsin[0]=rect->x;
	ptsin[1]=rect->y;
	ptsin[2]=rect->x+rect->w;
	ptsin[3]=rect->y+rect->h;
	
	intin[0]=clip_flag;
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	void vs_clip( const INT16 handle, const INT16 clip_flag, const INT16 *pxyarray )
#else
	void vs_clip_( const INT16 handle, const INT16 clip_flag, const INT16 *pxyarray )
#endif
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={129, 2, 0, 1, 0, 0};
	
	/* intin anlegen und fÅllen */
	INT16 intin[10];
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	intin[0]=clip_flag;
	
	/* VDI aufrufen */
	vdi(contrl, intin, (INT16 *)pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 100:	Open Bitmap-Plane																	*/
/*																										*/
/******************************************************************************/

void v_opnbm( INT16 *work_in, MFDB *bitmap, INT16 *handle, INT16 *work_out )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={100, 0, 6, 20, 45, 1};
	
	/* VDI-Handle eintragen */
	contrl[6]=*handle;
   
   /* Den MFDB eintragen */
   *((MFDB **)&(contrl[7])) = bitmap;
	
	/* VDI aufrufen */
	vdi(contrl, work_in, _VDIParBlk.ptsin, work_out, &(work_out[45]));
	
	/* RÅckgabewert auswerten */
	if( handle!=NULL )
		*handle=contrl[6];
}

/******************************************************************************/
/*																										*/
/* VDI 101:	Close Bitmap-Plane																*/
/*																										*/
/******************************************************************************/

void v_clsbm( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={101, 0, 0, 0, 0, 1};
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
   
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 102:	Inquire Screen Information														*/
/*																										*/
/******************************************************************************/

void vq_scrninfo( const INT16 handle, INT16 *work_out )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={102, 0, 0, 1, 272, 1};
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
   
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, work_out, _VDIParBlk.ptsout);
}
