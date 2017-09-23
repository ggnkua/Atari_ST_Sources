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

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Funktion:	Einstellen der VDI-Parameter (leider bei jedem VDI anders)		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

static void initVdiParams( const int16 handle )
{
	short dummy;
	
	vsf_perimeter(handle, PERIMETER_ON);
	vsl_ends(handle, 0, 0);
	vsl_width(handle, 1);
	vst_effects(handle, 0);
	vsm_height(handle, 9);
	vst_height(handle, 13, &dummy, &dummy, &dummy, &dummy);
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* VDI   1: "Normales" Open Workstation													*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_opnwk( int16 *work_in, int16 *handle, int16 *work_out )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12] = {1, 0, 6, 11, 45};
	
	/* VDI aufrufen */
	vdi_(contrl, work_in, _VDIParBlk.ptsin, work_out, &(work_out[45]));
	
	/* Einige VDI-Implementationen haben nicht die gleichen  */
	/* Default Attribute gesetzt => sie werden initialisiert */
	if( contrl[6]!=0 )
		initVdiParams(contrl[6]);
	
	/* RÅckgabewert auswerten */
	if( handle!=NULL )
		*handle = contrl[6];
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* VDI   1: Open Workstation fÅr Drucker gem. NVDI										*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

int16 v_opnprn( int16 *handle, PRN_SETTINGS *settings, int16 *work_out )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12] = {1, 0, 6, 16, 45};
	
	/* intin anlegen und fÅllen */
	int16 intin[16];
	register int16 i;
	
	/* Wurde etwas fÅr die erweiterten NVDI-Parameter Åbergeben? */
	if( settings==NULL )
		return -1;
	
	/* Die Werte Åbertragen */
	intin[0]  = settings->driver_id;
	for( i=1 ; i<10 ; i++ )
		intin[i] = 1;
	intin[10] = 2;
	
	/* Die Werte zusÑtzlich eintragen */
	*(int8 **) &intin[12] = settings->device;
	*(PRN_SETTINGS **)&(intin[14]) = settings;
	intin[11] = (int16) settings->size_id;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, work_out, &(work_out[45]));
	
	/* Einige VDI-Implementationen haben nicht die gleichen  */
	/* Default Attribute gesetzt => sie werden initialisiert */
	if( contrl[6]!=0 )
		initVdiParams(contrl[6]);
	
	/* RÅckgabewert auswerten */
	if( handle!=NULL )
		*handle = contrl[6];
	
	return contrl[6];
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* VDI   1: Open Workstation fÅr Drucker gem. NVDI mit eigenem work_in			*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_opnprnwrk( int16 *handle, int16 *work_in, PRN_SETTINGS *settings, int16 *work_out )
{
	int16 contrl[12] = {1, 0, 6, 11, 45};
	
	/* intin anlegen und fÅllen */
	int16 intin[16];
	register int16 i;
	
	/* Die Werte Åbertragen */
	if( settings!=NULL )
		intin[0]  = settings->driver_id;
	else if( work_in!=NULL )
		intin[0]  = work_in[0];
	else
		return;
	if( work_in!=NULL )
	{
		for( i=1 ; i<10 ; i++ )
			intin[i] = (work_in!=NULL ? work_in[i] : 1);
		intin[10] = 2;
	}
	else
	{
		for( i=1 ; i<10 ; i++ )
			intin[i] = 1;
		intin[10] = 2;
	}
	
	/* Die Werte zusÑtzlich eintragen */
	if( settings!=NULL )
	{
		intin[11] = (int16) settings->size_id;
		*(int8 **) &intin[12] = settings->device;
		*(PRN_SETTINGS **)&(intin[14]) = settings;
		
		/* 5 int-Parameter mehr */
		contrl[3] += 5;
	}
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, work_out, &(work_out[45]));
	
	/* Einige VDI-Implementationen haben nicht die gleichen  */
	/* Default Attribute gesetzt => sie werden initialisiert */
	if( contrl[6]!=0 )
		initVdiParams(contrl[6]);
	
	/* RÅckgabewert auswerten */
	if( handle!=NULL )
		*handle = contrl[6];
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* VDI   1: Open Workstation fÅr Drucker (Matrix-Drucker)							*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_opnmatrixprn( int16 *work_in, int16 *handle, int16 *work_out, int16 max_x, int16 max_y )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12] = {1, 0, 6, 11, 45};
	
	/* Wenn sinnvolle Werte fÅr max_x und max_y Åbergeben wurden,    */
	/* werden diese auch Åbergeben - evtl. fÅr den Drucker bestimmt! */
	if( max_x>0 && max_y>0 )
	{
		int16 ptsin[10];
		
		/* Die Werte eintragen */
		ptsin[0] = max_x;
		ptsin[1] = max_y;
		contrl[1] = 1;
		
		/* VDI aufrufen */
		vdi_(contrl, work_in, ptsin, work_out, &(work_out[45]));
	}
	else
	{
		/* VDI aufrufen */
		vdi_(contrl, work_in, _VDIParBlk.ptsin, work_out, &(work_out[45]));
	}
	
	/* Einige VDI-Implementationen haben nicht die gleichen  */
	/* Default Attribute gesetzt => sie werden initialisiert */
	if( contrl[6]!=0 )
		initVdiParams(contrl[6]);
	
	/* RÅckgabewert auswerten */
	if( handle!=NULL )
		*handle = contrl[6];
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* VDI   1: Open Workstation fÅr Metafiles												*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_opnmeta( int16 *work_in, int16 *handle, int16 *work_out, const char *filename )
{
	/* Wurde etwas fÅr die erweiterten NVDI-Parameter Åbergeben? */
	if( filename!=NULL )
	{
		/* contrl anlegen und fÅllen */
		int16 contrl[12] = {1, 0, 6, 16, 45};
		
		/* intin anlegen und fÅllen */
		int16 intin[16];
		
		/* Die bisherige Werte Åbertragen */
		intin[0]  = work_in[0];
		intin[1]  = work_in[1];
		intin[2]  = work_in[2];
		intin[3]  = work_in[3];
		intin[4]  = work_in[4];
		intin[5]  = work_in[5];
		intin[6]  = work_in[6];
		intin[7]  = work_in[7];
		intin[8]  = work_in[8];
		intin[9]  = work_in[9];
		intin[10] = work_in[10];
		
		/* Die Werte zusÑtzlich eintragen */
		intin[11] = 0;
		*(const char **)&(intin[12]) = filename;
		*(int32 *)&intin[14] = 0;
		
		/* VDI aufrufen */
		vdi_(contrl, intin, _VDIParBlk.ptsin, work_out, &(work_out[45]));
		
		/* Einige VDI-Implementationen haben nicht die gleichen  */
		/* Default Attribute gesetzt => sie werden initialisiert */
		if( contrl[6]!=0 )
			initVdiParams(contrl[6]);
		
		/* RÅckgabewert auswerten */
		if( handle!=NULL )
			*handle=contrl[6];
	}
	else
		v_opnwk(work_in, handle, work_out);
}

/******************************************************************************/
/*																										*/
/* VDI   2: Close Workstation																	*/
/*																										*/
/******************************************************************************/

void v_clswk( const int16 handle )
{
	/* contrl anlegen */
	int16 contrl[12]={2, 0, 0, 0, 0, 0};
	
	/* handle eintragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}
		
/******************************************************************************/
/*																										*/
/* VDI 100: Open virtual Workstation														*/
/*																										*/
/******************************************************************************/

void v_opnvwk( int16 *work_in, int16 *handle, int16 *work_out )
{
	/* contrl anlegen und fÅllen */
	static int16 contrl[12]={100, 0, 6, 11, 45, 0};
	
	/* VDI-Handle eintragen */
	contrl[6]=*handle;
	
	/* VDI aufrufen */
	vdi_(contrl, work_in, _VDIParBlk.ptsin, work_out, &(work_out[45]));
	
	/* Einige VDI-Implementationen haben nicht die gleichen  */
	/* Default Attribute gesetzt => sie werden initialisiert */
	if( contrl[6]!=0 )
		initVdiParams(contrl[6]);
	
	/* RÅckgabewert auswerten */
	*handle=contrl[6];
}

/******************************************************************************/
/*																										*/
/* VDI 101: Close virtual Workstation														*/
/*																										*/
/******************************************************************************/

void v_clsvwk( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={101, 0, 0, 0, 0, 0};
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI   3: Clear Workstation																	*/
/*																										*/
/******************************************************************************/

void v_clrwk( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={3, 0, 0, 0, 0, 0};
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI   4: Update Workstation																*/
/*																										*/
/******************************************************************************/

void v_updwk( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={4, 0, 0, 0, 0, 0};
	int16 intout[10];
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
}


/******************************************************************************/
/*																										*/
/* VDI 100, Esc	1:	Open Bitmap-Plane														*/
/*																										*/
/******************************************************************************/

void v_opnbm( int16 *work_in, const MFDB *bitmap, int16 *handle, int16 *work_out )
{
	if( handle!=NULL )
	{
		/* contrl anlegen und fÅllen */
		int16 contrl[12]={100, 0, 6, 20, 45, 1};
		
		/* VDI-Handle eintragen */
		contrl[6]=*handle;
   	
	   /* Den MFDB eintragen */
   	*((const MFDB **)&(contrl[7])) = bitmap;
		
		/* VDI aufrufen */
		vdi_(contrl, work_in, _VDIParBlk.ptsin, work_out, &(work_out[45]));
		
		/* RÅckgabewert auswerten */
		*handle=contrl[6];
	}
}

/******************************************************************************/
/*																										*/
/* VDI 100, Esc	2:	Resize Bitmap															*/
/*																										*/
/******************************************************************************/

int16 v_resize_bm( const int16 handle, const int16 width, const int16 height,
				const int32 byte_width, const uint8 *addr )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={100, 0, 0, 6, 1, 2};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* VDI-Handle eintragen */
	contrl[6] = handle;
   
	/* intin fÅllen */
	intin[0] = width;
	intin[1] = height;
	*(int32 *)&intin[2] = byte_width;
	*(const uint8 **)&intin[4] = addr;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 100, Esc	3:	Open Bitmap																*/
/*																										*/
/******************************************************************************/

int16 v_open_bm( const int16 base_handle, const GCBITMAP *bitmap, const int16 zero,
				const int16 flags, const int16 pixel_width, const int16 pixel_height )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={100, 0, 0, 4, 1, 3};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* VDI-Handle eintragen */
	contrl[6] = base_handle;
   
   /* Die Bitmap eintragen */
   *((const GCBITMAP **)&(contrl[7])) = bitmap;
	
	/* intin fÅllen */
	intin[0] = zero;
	intin[1] = flags;
	intin[2] = pixel_width;
	intin[3] = pixel_height;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return contrl[6];
}

/******************************************************************************/
/*																										*/
/* VDI 101:	Close Bitmap-Plane																*/
/*																										*/
/******************************************************************************/

void v_clsbm( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={101, 0, 0, 0, 0, 1};
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
   
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 119: Load Fonts																			*/
/*																										*/
/******************************************************************************/

int16 vst_load_fonts( const int16 handle, const int16 select )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={119, 0, 0, 1, 1, 0};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	intin[0]=select;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 120: Unload Fonts																		*/
/*																										*/
/******************************************************************************/

void vst_unload_fonts( const int16 handle, const int16 select )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={120, 0, 0, 1, 0, 0};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	intin[0]=select;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 129: Set Clipping Rectangle															*/
/*																										*/
/******************************************************************************/

void vs_clip( const int16 handle, const int16 clip_flag, const int16 *pxyarray )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={129, 2, 0, 1, 0, 0};
	
	/* intin anlegen und fÅllen */
	int16 intin[10];
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	intin[0]=clip_flag;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, (int16 *)pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI -1, Esc 6:	Set Clipping Rectangle													*/
/*																										*/
/******************************************************************************/

void v_set_app_buff( const int16 handle, void *address, const int16 nparagraphs )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={-1, 0, 0, 3, 0, 6};
	
	/* intin anlegen und fÅllen */
	int16 intin[10];
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	*(void **)&intin[0] = address;
	intin[2] = nparagraphs;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}
