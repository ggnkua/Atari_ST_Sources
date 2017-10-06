/******************************************************************************/
/*																										*/
/*     Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C       */
/*																										*/
/* Die (N)VDI-Funktionen - Raster-Funktionen												*/
/*																										*/
/*	(c) 1999 by Martin ElsÑsser																*/
/******************************************************************************/

#include <ACSVDI.H>

/******************************************************************************/
/*																										*/
/* VDI 109: Copy Raster, Opaque																*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

void vro_cpyfm( const INT16 handle, const INT16 wr_mode, const Axywh *koor_src,
			const Axywh *koor_dest, const MFDB *source, MFDB *dest )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={109, 4, 0, 1, 0};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	
	/* ptsin anlegen */
	INT16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	*(MFDB **)(contrl+7) = (MFDB *)source;
	*(MFDB **)(contrl+9) = (MFDB *)dest;
	
	intin[0]=wr_mode;
	
	ptsin[0]=koor_src->x;
	ptsin[1]=koor_src->y;
	ptsin[2]=koor_src->x+koor_src->w;
	ptsin[3]=koor_src->y+koor_src->h;
	ptsin[4]=koor_dest->x;
	ptsin[5]=koor_dest->y;
	ptsin[6]=koor_dest->x+koor_dest->w;
	ptsin[7]=koor_dest->y+koor_dest->h;
	
	/* VDI aufrufen */
	vdi(contrl, intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	void vro_cpyfm( const INT16 handle, const INT16 wr_mode, const INT16 *pxyarray,
					const MFDB *source, MFDB *dest )
#else
	void vro_cpyfm_( const INT16 handle, const INT16 wr_mode, const INT16 *pxyarray,
					const MFDB *source, MFDB *dest )
#endif
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={109, 4, 0, 1, 0};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	*(MFDB **)(contrl+7) = (MFDB *)source;
	*(MFDB **)(contrl+9) = (MFDB *)dest;
	
	intin[0]=wr_mode;
	
	/* VDI aufrufen */
	vdi(contrl, intin, (INT16 *)pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 121: Copy Raster, Transparent														*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

void vrt_cpyfm( const INT16 handle, const INT16 wr_mode, const Axywh *koor_src,
				const Axywh *koor_dest, const MFDB *source, MFDB *dest, const INT16 color[2] )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={121, 4, 0, 3, 0};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* ptsin anlegen */
	INT16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0] = wr_mode;
	intin[1] = color[0];
	intin[2] = color[1];
	
	*(MFDB **)(contrl+7) = (MFDB *)source;
	*(MFDB **)(contrl+9) = (MFDB *)dest;
	
	ptsin[0]=koor_src->x;
	ptsin[1]=koor_src->y;
	ptsin[2]=koor_src->x+koor_src->w;
	ptsin[3]=koor_src->y+koor_src->h;
	ptsin[4]=koor_dest->x;
	ptsin[5]=koor_dest->y;
	ptsin[6]=koor_dest->x+koor_dest->w;
	ptsin[7]=koor_dest->y+koor_dest->h;
	
	/* VDI aufrufen */
	vdi(contrl, intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	void vrt_cpyfm( const INT16 handle, const INT16 wr_mode, const INT16 *pxyarray,
					const MFDB *source, MFDB *dest, const INT16 color[2] )
#else
	void vrt_cpyfm_( const INT16 handle, const INT16 wr_mode, const INT16 *pxyarray,
					const MFDB *source, MFDB *dest, const INT16 color[2] )
#endif
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={121, 4, 0, 3, 0};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0] = wr_mode;
	intin[1] = color[0];
	intin[2] = color[1];
	
	*(MFDB **)(contrl+7) = (MFDB *)source;
	*(MFDB **)(contrl+9) = (MFDB *)dest;
	
	/* VDI aufrufen */
	vdi(contrl, intin, (INT16 *)pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 110: Transform Raster																	*/
/*																										*/
/******************************************************************************/

void vr_trnfm( const INT16 handle, const MFDB *source, MFDB *dest )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={110, 0, 0, 0, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	*(MFDB **)(contrl+7) = (MFDB *)source;
	*(MFDB **)(contrl+9) = (MFDB *)dest;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 105: Get Pixel																			*/
/*																										*/
/******************************************************************************/

void v_get_pixel( const INT16 handle, const INT16 x, const INT16 y,
		INT16 *pix_value, INT16 *col_index )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={105, 1, 0, 0, 2};
	
	/* intout anlegen */
	INT16 intout[10];
	
	/* ptsin anlegen */
	INT16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=x;
	ptsin[1]=y;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, ptsin, intout, _VDIParBlk.ptsout);
	
	if( pix_value!=NULL )
		*pix_value=intout[0];
	if( col_index!=NULL )
		*col_index=intout[1];
}
