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
/* vdi_ 109: Copy Raster, Opaque																*/
/*																										*/
/******************************************************************************/

void vro_cpyfm( const int16 handle, const int16 wr_mode, const int16 *pxyarray,
				const MFDB *source, MFDB *dest )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={109, 4, 0, 1, 0};
	
	/* intin & intout anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	*(MFDB **)(contrl+7) = (MFDB *)source;
	*(MFDB **)(contrl+9) = (MFDB *)dest;
	
	/* intin fÅllen */
	intin[0]=wr_mode;
	
	/* vdi_ aufrufen */
	vdi_(contrl, intin, (int16 *)pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* vdi_ 121: Copy Raster, Transparent														*/
/*																										*/
/******************************************************************************/

void vrt_cpyfm( const int16 handle, const int16 wr_mode, const int16 *pxyarray,
				const MFDB *source, MFDB *dest, const int16 color[2] )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={121, 4, 0, 3, 0};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	*(MFDB **)(contrl+7) = (MFDB *)source;
	*(MFDB **)(contrl+9) = (MFDB *)dest;
	
	/* intin fÅllen */
	intin[0] = wr_mode;
	intin[1] = color[0];
	intin[2] = color[1];
	
	/* vdi_ aufrufen */
	vdi_(contrl, intin, (int16 *)pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* vdi_ 110: Transform Form																		*/
/*																										*/
/******************************************************************************/

void vr_trnfm( const int16 handle, const MFDB *source, MFDB *dest )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={110, 0, 0, 0, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	*(MFDB **)(contrl+7) = (MFDB *)source;
	*(MFDB **)(contrl+9) = (MFDB *)dest;
	
	/* vdi_ aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* vdi_ 105: Get Pixel																			*/
/*																										*/
/******************************************************************************/

void v_get_pixel( const int16 handle, const int16 x, const int16 y,
		int16 *pix_value, int16 *col_index )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={105, 1, 0, 0, 2};
	
	/* intout anlegen */
	int16 intout[10];
	
	/* ptsin anlegen */
	int16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	ptsin[0]=x;
	ptsin[1]=y;
	
	/* vdi_ aufrufen */
	vdi_(contrl, _VDIParBlk.intin, ptsin, intout, _VDIParBlk.ptsout);
	
	if( pix_value!=NULL )
		*pix_value=intout[0];
	if( col_index!=NULL )
		*col_index=intout[1];
}

/******************************************************************************/
/*																										*/
/* vdi_ 170, Esc	0: Transfer Bitmap														*/
/*																										*/
/******************************************************************************/

void vr_transfer_bits( const int16 handle, const GCBITMAP *src_bm, const GCBITMAP *dst_bm,
			const int16 *src_rect, const int16 *dst_rect, const int16 mode )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[15]={170, 4, 0, 4, 0, 0};
	
	/* intout anlegen */
	int16 intout[10];
	
	/* intin & ptsin anlegen */
	int16 intin[10];
	int16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	*(const GCBITMAP **)&contrl[7] = src_bm;
	*(const GCBITMAP **)&contrl[9] = dst_bm;
	contrl[11] = 0;
	contrl[12] = 0;
	
	/* intin fÅllen */
	intin[0] = mode;
	intin[1] = 0;
	intin[2] = 0;
	intin[3] = 0;
	
	/* ptsin fÅllen */
	ptsin[0] = src_rect[0];
	ptsin[1] = src_rect[1];
	ptsin[2] = src_rect[2];
	ptsin[3] = src_rect[3];
	ptsin[4] = dst_rect[0];
	ptsin[5] = dst_rect[1];
	ptsin[6] = dst_rect[2];
	ptsin[7] = dst_rect[3];
	
	/* vdi_ aufrufen */
	vdi_(contrl, intin, ptsin, intout, _VDIParBlk.ptsout);
}
