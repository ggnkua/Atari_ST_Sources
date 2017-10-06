/******************************************************************************/
/*																										*/
/*     Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C       */
/*																										*/
/* Die (N)VDI-Funktionen - Escape-Funktionen												*/
/*																										*/
/*	(c) 1999 by Martin ElsÑsser																*/
/******************************************************************************/

#include <ACSVDI.H>

/******************************************************************************/
/*																										*/
/* VDI 5, Esc   1:	Inquire Adresstable Alpha Character Cells						*/
/*																										*/
/******************************************************************************/

void vq_chcells( const INT16 handle, INT16 *rows, INT16 *cols )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 2, 1};
	
	/* intout anlegen */
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die Werte zurÅckgeben */
	if( rows!=NULL )
		*rows=intout[0];
	if( cols!=NULL )
		*cols=intout[1];
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc   2:	Exit Alpha Mode														*/
/*																										*/
/******************************************************************************/

void v_exit_cur( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 0, 2};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc   3:	Enter Alpha Mode														*/
/*																										*/
/******************************************************************************/

void v_enter_cur( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 0, 3};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc   4:	Alpha Cursor Up														*/
/*																										*/
/******************************************************************************/

void v_curup( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 0, 4};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc   5:	Alpha Cursor Down														*/
/*																										*/
/******************************************************************************/

void v_curdown( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 0, 5};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc   6:	Alpha Cursor Right													*/
/*																										*/
/******************************************************************************/

void v_curright( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 0, 6};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc   7:	Alpha Cursor Left														*/
/*																										*/
/******************************************************************************/

void v_curleft( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 0, 7};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc   8:	Home Alpha Cursor														*/
/*																										*/
/******************************************************************************/

void v_curhome( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 0, 8};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc   9:	Erase To End Of Alpha Screen										*/
/*																										*/
/******************************************************************************/

void v_eeos( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 0, 9};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  10:	Erase To End Of Alpha Text Line									*/
/*																										*/
/******************************************************************************/

void v_eeol( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 0, 10};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  11:	Direct Alpha Cursor Address										*/
/*																										*/
/******************************************************************************/

void v_curaddress( const INT16 handle, const INT16 row, const INT16 col )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 2, 0, 11};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=row;
	intin[1]=col;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  12:	Output Cursor Addressable Alpha Text							*/
/*																										*/
/******************************************************************************/

void v_curtext( const INT16 handle, const char *string )
{
	/* Benîtigte Prototypen */
	INT32 strlen( const char *s );
	
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 0, 12};
	
	/* intin anlegen */
	INT16 *intin;
	register INT16 i, *i_ptr;
	register char *c_ptr;
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[3]=(INT16)strlen(string);
	
	intin=(INT16 *)malloc((contrl[3]+1)*sizeof(*intin));
	if( intin==NULL )
		return;
	
	for( i=0, i_ptr=intin, c_ptr=(char *)string ; i<=contrl[3] ; i++, i_ptr++, c_ptr++ )
		*i_ptr=*c_ptr;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
	
	/* intin freigeben */
	free(intin);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  13:	Reverse Video On														*/
/*																										*/
/******************************************************************************/

void v_rvon( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 0, 13};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  14:	Reverse Video Off														*/
/*																										*/
/******************************************************************************/

void v_rvoff( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 0, 14};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  15:	Inquire Current Alpha Cursor Address							*/
/*																										*/
/******************************************************************************/

void vq_curaddress( const INT16 handle, INT16 *row, INT16 *col )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 2, 15};
	
	/* intout anlegen */
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die Werte zurÅckgeben */
	if( row!=NULL )
		*row=intout[0];
	if( col!=NULL )
		*col=intout[1];
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  16:	Inquire Tablet Status												*/
/*																										*/
/******************************************************************************/

INT16 vq_tabstatus( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 1, 16};
	
	/* intout anlegen */
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  17:	Hard Copy																*/
/*																										*/
/******************************************************************************/

void v_hardcopy( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 0, 17};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  18:	Place Graphic Cursor At Location									*/
/*																										*/
/******************************************************************************/

void v_dspcur( const INT16 handle, const INT16 x, const INT16 y )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 1, 0, 0, 0, 18};
	
	/* ptsin anlegen */
	INT16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=x;
	ptsin[1]=y;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  19:	Remove Last Graphic Cursor											*/
/*																										*/
/******************************************************************************/

void v_rmcur( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 0, 19};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  20:	Form Advanced															*/
/*																										*/
/******************************************************************************/

void v_form_adv( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 0, 20};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  21:	Output Window															*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

void v_output_window( const INT16 handle, const Axywh *xywh )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 2, 0, 0, 0, 21};
	
	/* ptsin anlegen */
	INT16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=xywh->x;
	ptsin[1]=xywh->y;
	ptsin[2]=xywh->x+xywh->w;
	ptsin[3]=xywh->h+xywh->h;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	void v_output_window( const INT16 handle, const INT16 *pxyarray )
#else
	void v_output_window_( const INT16 handle, const INT16 *pxyarray )
#endif
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 2, 0, 0, 0, 21};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, (INT16 *)pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  22:	Clear Display List													*/
/*																										*/
/******************************************************************************/

void v_clear_disp_list( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 0, 22};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  23:	Output Bit Image File												*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

void v_bit_image( const INT16 handle, const char *filename, const INT16 aspect,
				const INT16 x_scale, const INT16 y_scale, const INT16 h_align,
				const INT16 v_align, const Axywh *xywh )
{
	/* Benîtigte Prototypen */
	INT32 strlen( const char *s );
	
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 2, 0, 0, 0, 23};
	
	/* intin anlegen */
	INT16 *intin;
	register INT16 i, *i_ptr;
	register char *c_ptr;
	
	/* ptsin anlegen */
	INT16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[3]=(INT16)strlen(filename)+5;
	
	intin=(INT16 *)malloc((contrl[3]+1)*sizeof(*intin));
	if( intin==NULL )
		return;
	
	intin[0]=aspect;
	intin[1]=x_scale;
	intin[2]=y_scale;
	intin[3]=h_align;
	intin[4]=v_align;
	
	for( i=5, i_ptr=&intin[5], c_ptr=(char *)filename ; i<=contrl[3] ; i++, i_ptr++, c_ptr++ )
		*i_ptr=*c_ptr;
	
	ptsin[0]=xywh->x;
	ptsin[1]=xywh->y;
	ptsin[2]=xywh->x+xywh->w;
	ptsin[3]=xywh->y+xywh->h;
	
	/* VDI aufrufen */
	vdi(contrl, intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
	
	/* intin freigeben */
	free(intin);
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	void v_bit_image( const INT16 handle, const char *filename, const INT16 aspect,
					const INT16 x_scale, const INT16 y_scale, const INT16 h_align,
					const INT16 v_align, const INT16 *pxyarray )
#else
	void v_bit_image_( const INT16 handle, const char *filename, const INT16 aspect,
					const INT16 x_scale, const INT16 y_scale, const INT16 h_align,
					const INT16 v_align, const INT16 *pxyarray )
#endif
{
	/* Benîtigte Prototypen */
	INT32 strlen( const char *s );
	
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 2, 0, 0, 0, 23};
	
	/* intin anlegen */
	INT16 *intin;
	register INT16 i, *i_ptr;
	register char *c_ptr;
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[3]=(INT16)strlen(filename)+5;
	
	intin=(INT16 *)malloc((contrl[3]+1)*sizeof(*intin));
	if( intin==NULL )
		return;
	
	intin[0]=aspect;
	intin[1]=x_scale;
	intin[2]=y_scale;
	intin[3]=h_align;
	intin[4]=v_align;
	
	for( i=5, i_ptr=&intin[5], c_ptr=(char *)filename ; i<=contrl[3] ; i++, i_ptr++, c_ptr++ )
		*i_ptr=*c_ptr;
	
	/* VDI aufrufen */
	vdi(contrl, intin, (INT16 *)pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
	
	/* intin freigeben */
	free(intin);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  24:	Inquire Printer Scan													*/
/*																										*/
/******************************************************************************/

void vq_scan( const INT16 handle, INT16 *g_slice, INT16 *g_page,
			INT16 *a_slice, INT16 *a_page, INT16 *div_fac )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 5, 24};
	
	/* intout anlegen */
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die Werte zurÅckgeben */
	if( g_slice!=NULL )
		*g_slice=intout[0];
	if( g_page!=NULL )
		*g_page=intout[1];
	if( a_slice!=NULL )
		*a_slice=intout[2];
	if( a_page!=NULL )
		*a_page=intout[3];
	if( div_fac!=NULL )
		*div_fac=intout[4];
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  25:	Output Alpha Text														*/
/*																										*/
/******************************************************************************/

void v_alpha_text( const INT16 handle, const char *string )
{
	/* Benîtigte Prototypen */
	INT32 strlen( const char *s );
	
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 0, 25};
	
	/* intin anlegen */
	INT16 *intin;
	register INT16 i, *i_ptr;
	register char *c_ptr;
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[3]=(INT16)strlen(string)+5;
	
	intin=(INT16 *)malloc((contrl[3]+1)*sizeof(*intin));
	if( intin==NULL )
		return;
	
	for( i=0, i_ptr=&intin[5], c_ptr=(char *)string ; i<=contrl[3] ; i++, i_ptr++, c_ptr++ )
		*i_ptr=*c_ptr;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
	
	/* intin freigeben */
	free(intin);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  60:	Select Palette															*/
/*																										*/
/******************************************************************************/

INT16 vs_palette( const INT16 handle, const INT16 palette )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 1, 1, 60};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=palette;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  61:	Generate Specified Tone												*/
/*																										*/
/******************************************************************************/

void v_sound( const INT16 handle, const INT16 frequency, const INT16 duration )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 2, 0, 61};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=frequency;
	intin[1]=duration;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  62:	Set/Clear Tone Muting Flag											*/
/*																										*/
/******************************************************************************/

INT16 vs_mute( const INT16 handle, const INT16 action )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 1, 0, 62};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=action;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  81:	Set Tablet Axis Resolution in Lines/Inch						*/
/*																										*/
/******************************************************************************/

void vt_resolution( const INT16 handle, const INT16 xres, const INT16 yres,
			INT16 *xset, INT16 *yset )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 2, 2, 81};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=xres;
	intin[1]=yres;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die Werte zurÅckliefern */
	if( xset!=NULL )
		*xset=intout[0];
	if( yset!=NULL )
		*yset=intout[1];
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  82:	Set Tablet Axis Resolution In Lines								*/
/*																										*/
/******************************************************************************/

void vt_axis( const INT16 handle, const INT16 xres, const INT16 yres,
			INT16 *xset, INT16 *yset )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 2, 2, 82};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=xres;
	intin[1]=yres;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die Werte zurÅckliefern */
	if( xset!=NULL )
		*xset=intout[0];
	if( yset!=NULL )
		*yset=intout[1];
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  83:	Set Tablet X And Y Origin											*/
/*																										*/
/******************************************************************************/

void vt_origin( const INT16 handle, const INT16 xorigin, const INT16 yorigin )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 2, 0, 83};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=xorigin;
	intin[1]=yorigin;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  84:	Return Tablet X And Y Dimensions									*/
/*																										*/
/******************************************************************************/

void vq_tdimensions( const INT16 handle, INT16 *xdim, INT16 *ydim )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 2, 84};
	
	/* intout anlegen */
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die Werte zurÅckgeben */
	if( xdim!=NULL )
		*xdim=intout[0];
	if( ydim!=NULL )
		*ydim=intout[1];
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  85:	Set Tablet Alignment													*/
/*																										*/
/******************************************************************************/

void vt_alignment( const INT16 handle, const INT16 dx, const INT16 dy )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 2, 0, 85};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=dx;
	intin[1]=dy;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  91:	Set Camera Film Type And Exposure Time							*/
/*																										*/
/******************************************************************************/

void vsp_film( const INT16 handle, const INT16 index, const INT16 lightness )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 2, 0, 91};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=index;
	intin[1]=lightness;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  92:	Inquire Camera Film Name											*/
/*																										*/
/******************************************************************************/

INT16 vqp_filmname( const INT16 handle, const INT16 index, char *name )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 1, 25, 92};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[25];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=index;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Den Wert zurÅckgeben */
	if( name!=NULL )
	{
		register INT16 i, *i_ptr;
		register char *c_ptr;
		
		for( i=0, i_ptr=intout, c_ptr=(char *)name ;
				*i_ptr!=0 && i<contrl[4] ;
				i++, i_ptr++, c_ptr++ )
			*c_ptr=(char)*i_ptr;
		*c_ptr='\0';
	}
	
	return contrl[4];
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  93:	Disable Or Enable Film Exposure For Frame						*/
/*																										*/
/******************************************************************************/

void vsc_exposure( const INT16 handle, const INT16 status )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 1, 0, 93};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=status;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  98:	Update Metafile Extents												*/
/*																										*/
/******************************************************************************/

void v_meta_extents( const INT16 handle, const INT16 min_x, const INT16 min_y,
			const INT16 max_x, const INT16 max_y )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 2, 0, 0, 0, 98};
	
	/* ptsin anlegen */
	INT16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=min_x;
	ptsin[1]=min_y;
	ptsin[2]=max_x;
	ptsin[3]=max_y;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  99:	Write Metafile Item													*/
/*																										*/
/******************************************************************************/

void v_write_meta( const INT16 handle, const INT16 num_intin, const INT16 *a_intin,
			const INT16 num_ptsin, const INT16 *a_ptsin )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 0, 99};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[1]=num_ptsin;
	contrl[3]=num_intin;
	
	/* VDI aufrufen */
	vdi(contrl, (INT16 *)a_intin, (INT16 *)a_ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  99:	Write Metafile Item													*/
/*																										*/
/******************************************************************************/

void vm_pagesize( const INT16 handle, const INT16 pgwidth, const INT16 pgheight )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 3, 0, 99};
	
	/* intin anlegen... */
	INT16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=0;
	intin[1]=pgwidth;
	intin[2]=pgheight;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  99, Op. 1:	Coordinate Window												*/
/*																										*/
/******************************************************************************/

void vm_coords( const INT16 handle, const INT16 llx, const INT16 lly,
			const INT16 urx, const INT16 ury )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 5, 0, 99};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=1;
	intin[1]=llx;
	intin[2]=lly;
	intin[3]=urx;
	intin[4]=ury;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc 100:	Change GEM VDI File Name											*/
/*																										*/
/******************************************************************************/

void vm_filename( const INT16 handle, const char *filename )
{
	/* Benîtigte Prototypen */
	INT32 strlen( const char *s );
	
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 0, 0, 100};
	
	/* intin anlegen */
	INT16 *intin;
	register INT16 i, *i_ptr;
	register char *c_ptr;
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[3]=(INT16)strlen(filename);
	
	intin=(INT16 *)malloc((contrl[3]+1)*sizeof(*intin));
	if( intin==NULL )
		return;
	
	for( i=0, i_ptr=intin, c_ptr=(char *)filename ; i<=contrl[3] ; i++, i_ptr++, c_ptr++ )
		*i_ptr=*c_ptr;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc 101:	Set Line Offset														*/
/*																										*/
/******************************************************************************/

void v_offset( const INT16 handle, const INT16 offset )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 1, 0, 101};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=offset;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc 102:	Init System Font														*/
/*																										*/
/******************************************************************************/

void v_fontinit( const INT16 handle, const void *font_header )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 2, 0, 102};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	*(void **)intin=font_header;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc 2000:	Escape 2000 (Atari-SLM-Drucker)									*/
/*																										*/
/******************************************************************************/

void v_escape2000( const INT16 handle, const INT16 times )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={5, 0, 0, 1, 0, 2000};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=times;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

