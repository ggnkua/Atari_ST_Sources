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

void vq_chcells( const int16 handle, int16 *rows, int16 *cols )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 2, 1};
	
	/* intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
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

void v_exit_cur( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 0, 2};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc   3:	Enter Alpha Mode														*/
/*																										*/
/******************************************************************************/

void v_enter_cur( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 0, 3};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc   4:	Alpha Cursor Up														*/
/*																										*/
/******************************************************************************/

void v_curup( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 0, 4};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc   5:	Alpha Cursor Down														*/
/*																										*/
/******************************************************************************/

void v_curdown( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 0, 5};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc   6:	Alpha Cursor Right													*/
/*																										*/
/******************************************************************************/

void v_curright( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 0, 6};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc   7:	Alpha Cursor Left														*/
/*																										*/
/******************************************************************************/

void v_curleft( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 0, 7};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc   8:	Home Alpha Cursor														*/
/*																										*/
/******************************************************************************/

void v_curhome( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 0, 8};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc   9:	Erase To End Of Alpha Screen										*/
/*																										*/
/******************************************************************************/

void v_eeos( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 0, 9};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  10:	Erase To End Of Alpha Text Line									*/
/*																										*/
/******************************************************************************/

void v_eeol( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 0, 10};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  11:	Direct Alpha Cursor Address										*/
/*																										*/
/******************************************************************************/

void v_curaddress( const int16 handle, const int16 row, const int16 col )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 2, 0, 11};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=row;
	intin[1]=col;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  11:	Direct Alpha Cursor Address										*/
/*																										*/
/******************************************************************************/

void vs_curaddress( const int16 handle, const int16 row, const int16 col )
{
	v_curaddress(handle, row, col);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  12:	Output Cursor Addressable Alpha Text							*/
/*																										*/
/******************************************************************************/

void v_curtext( const int16 handle, const char *string )
{
	/* Benîtigte Prototypen */
	int32 strlen( const char *s );
	
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 0, 12};
	
	/* intin anlegen */
	int16 *intin;
	register int16 i, *i_ptr;
	register char *c_ptr;
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[3]=(int16)strlen(string);
	
	intin=(int16 *)malloc((contrl[3]+1)*sizeof(*intin));
	if( intin==NULL )
		return;
	
	for( i=0, i_ptr=intin, c_ptr=(char *)string ; i<=contrl[3] ; i++, i_ptr++, c_ptr++ )
		*i_ptr=*c_ptr;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
	
	/* intin freigeben */
	free(intin);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  13:	Reverse Video On														*/
/*																										*/
/******************************************************************************/

void v_rvon( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 0, 13};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  14:	Reverse Video Off														*/
/*																										*/
/******************************************************************************/

void v_rvoff( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 0, 14};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  15:	Inquire Current Alpha Cursor Address							*/
/*																										*/
/******************************************************************************/

void vq_curaddress( const int16 handle, int16 *row, int16 *col )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 2, 15};
	
	/* intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
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

int16 vq_tabstatus( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 1, 16};
	
	/* intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  17:	Hard Copy																*/
/*																										*/
/******************************************************************************/

void v_hardcopy( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 0, 17};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  18:	Place Graphic Cursor At Location									*/
/*																										*/
/******************************************************************************/

void v_dspcur( const int16 handle, const int16 x, const int16 y )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 1, 0, 0, 0, 18};
	
	/* ptsin anlegen */
	int16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=x;
	ptsin[1]=y;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  19:	Remove Last Graphic Cursor											*/
/*																										*/
/******************************************************************************/

void v_rmcur( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 0, 19};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  20:	Form Advanced															*/
/*																										*/
/******************************************************************************/

void v_form_adv( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 0, 20};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  21:	Output Window															*/
/*																										*/
/******************************************************************************/

void v_output_window( const int16 handle, const int16 *pxyarray )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 2, 0, 0, 0, 21};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, (int16 *)pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  22:	Clear Display List													*/
/*																										*/
/******************************************************************************/

void v_clear_disp_list( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 0, 22};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  23:	Output Bit Image File												*/
/*																										*/
/******************************************************************************/

void v_bit_image( const int16 handle, const char *filename, const int16 aspect,
				const int16 x_scale, const int16 y_scale, const int16 h_align,
				const int16 v_align, const int16 *pxyarray )
{
	/* Benîtigte Prototypen */
	int32 strlen( const char *s );
	
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 2, 0, 0, 0, 23};
	
	/* intin anlegen */
	int16 *intin;
	register int16 i, *i_ptr;
	register char *c_ptr;
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[3]=(int16)strlen(filename)+5;
	
	intin=(int16 *)malloc((contrl[3]+1)*sizeof(*intin));
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
	vdi_(contrl, intin, (int16 *)pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
	
	/* intin freigeben */
	free(intin);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  24:	Inquire Printer Scan													*/
/*																										*/
/******************************************************************************/

void vq_scan( const int16 handle, int16 *g_slice, int16 *g_page,
			int16 *a_slice, int16 *a_page, int16 *div_fac )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 5, 24};
	
	/* intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
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

void v_alpha_text( const int16 handle, const char *string )
{
	/* Benîtigte Prototypen */
	int32 strlen( const char *s );
	
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 0, 25};
	
	/* intin anlegen */
	int16 *intin;
	register int16 i, *i_ptr;
	register char *c_ptr;
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[3]=(int16)strlen(string);
	
	intin=(int16 *)malloc((contrl[3]+1)*sizeof(*intin));
	if( intin==NULL )
		return;
	
	for( i=0, i_ptr=&intin[5], c_ptr=(char *)string ; i<=contrl[3] ; i++, i_ptr++, c_ptr++ )
		*i_ptr=*c_ptr;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
	
	/* intin freigeben */
	free(intin);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  27:	Set Orientation														*/
/*																										*/
/******************************************************************************/

int16 v_orient( const int16 handle, const int16 orient )
{
	/* Benîtigte Prototypen */
	int32 strlen( const char *s );
	
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 1, 1, 27};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	intin[0] = orient;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return (contrl[4]>0 ? intout[0] : 0);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  28:	Set Number of Copies													*/
/*																										*/
/******************************************************************************/

int16 v_copies( int16 handle, int16 count )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 1, 1, 28};
	
	/* intin & intout anlegen */
	int16 intin[10], intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0] = count;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return (contrl[4]>0 ? intout[0] : 1);
} 

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  29:	Set Input and Output Trays											*/
/*																										*/
/******************************************************************************/

int16 v_trays( const int16 handle, const int16 input, const int16 output,
				int16 *set_input, int16 *set_output )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 2, 2, 29};
	
	/* intin & intout anlegen */
	int16 intin[10], intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	intin[0] = input;
	intin[1] = output;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die RÅckgabewerte setzen */
	if( set_input!=NULL )
		*set_input = intout[0];
	if( set_output!=NULL )
		*set_output = intout[1];
	
	return (contrl[4]>0 ? TRUE : FALSE);
} 

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  36:	Inquire Tray Names													*/
/*																										*/
/******************************************************************************/

int16 vq_tray_names( const int16 handle, char *input_name, char *output_name,
				int16 *input, int16 *output )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 4, 1, 36};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	*(char **)&intin[0] = input_name;
	*(char **)&intin[2] = output_name;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die RÅckgabewerte setzen */
	if( input!=NULL )
		*input = (contrl[4]>0 ? intout[0] : 0);
	if( output!=NULL )
		*output = (contrl[4]>0 ? intout[1] : 0);
	
	return (contrl[4]>0 ? TRUE : FALSE);
} 

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  37:	Set Page Size															*/
/*																										*/
/******************************************************************************/

int16 v_page_size( const int16 handle, const int16 page_id )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 1, 1, 37};
	
	/* intin & intout anlegen */
	int16 intin[10], intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	intin[0] = page_id;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die RÅckgabewerte setzen */
	return (contrl[4]>0 ? intin[0] : 0);
} 

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  38:	Inquire Page Name														*/
/*																										*/
/******************************************************************************/

int16 vq_page_name( const int16 handle, const int16 page_id, char *page_name,
				int32 *page_width, int32 *page_height )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 3, 5, 38};
	
	/* intin & intout anlegen */
	int16 intin[10], intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	intin[0] = page_id;
	*(char **)&intin[1] = page_name;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die RÅckgabewerte setzen */
	if( page_width!=NULL )
		*page_width = (contrl[4]>0 ? *(int32 *)&intout[1] : 0);
	if( page_height!=NULL )
		*page_height = (contrl[4]>0 ? *(int32 *)&intout[3] : 0);
	
	return (contrl[4]>0 ? intout[0] : -1);
} 

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  39:	Inquire Printer Scaling												*/
/*																										*/
/******************************************************************************/

fixed vq_prn_scaling( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 2, 2, 39};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	*(int32 *)&intin[0] = -1;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die RÅckgabewerte setzen */
	return (contrl[4]==2 ? *(int32 *)&intout[0] : -1);
} 

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  60:	Select Palette															*/
/*																										*/
/******************************************************************************/

int16 vs_palette( const int16 handle, const int16 palette )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 1, 1, 60};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=palette;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  61:	Generate Specified Tone												*/
/*																										*/
/******************************************************************************/

void v_sound( const int16 handle, const int16 frequency, const int16 duration )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 2, 0, 61};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=frequency;
	intin[1]=duration;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  62:	Set/Clear Tone Muting Flag											*/
/*																										*/
/******************************************************************************/

int16 vs_mute( const int16 handle, const int16 action )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 1, 0, 62};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=action;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  76:	Set Calibration														*/
/*																										*/
/******************************************************************************/

int16 vs_calibrate( const int16 handle, const boolean flag, const RGB1000 *table )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 3, 1, 76};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	*(const RGB1000 **)(&intin[0]) = table;
	intin[2] = flag;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  77:	Inquire Calibration													*/
/*																										*/
/******************************************************************************/

int16 vq_calibrate( const int16 handle, boolean *flag )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 0, 77};
	
	/* intin & intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* RÅckgabewerte liefern */
	if( flag!=NULL )
		*flag = (contrl[4] && intout[0] ? TRUE : FALSE);
	
	return contrl[4];
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  81:	Set Tablet Axis Resolution in Lines/Inch						*/
/*																										*/
/******************************************************************************/

void vt_resolution( const int16 handle, const int16 xres, const int16 yres,
			int16 *xset, int16 *yset )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 2, 2, 81};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=xres;
	intin[1]=yres;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
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

void vt_axis( const int16 handle, const int16 xres, const int16 yres,
			int16 *xset, int16 *yset )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 2, 2, 82};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=xres;
	intin[1]=yres;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
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

void vt_origin( const int16 handle, const int16 xorigin, const int16 yorigin )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 2, 0, 83};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=xorigin;
	intin[1]=yorigin;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  84:	Return Tablet X And Y Dimensions									*/
/*																										*/
/******************************************************************************/

void vq_tdimensions( const int16 handle, int16 *xdim, int16 *ydim )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 2, 84};
	
	/* intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
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

void vt_alignment( const int16 handle, const int16 dx, const int16 dy )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 2, 0, 85};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=dx;
	intin[1]=dy;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  91:	Set Camera Film Type And Exposure Time							*/
/*																										*/
/******************************************************************************/

void vsp_film( const int16 handle, const int16 index, const int16 lightness )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 2, 0, 91};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=index;
	intin[1]=lightness;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  92:	Inquire Camera Film Name											*/
/*																										*/
/******************************************************************************/

int16 vqp_filmname( const int16 handle, const int16 index, char *name )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 1, 25, 92};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[25];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=index;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Den Wert zurÅckgeben */
	if( name!=NULL )
	{
		register int16 i, *i_ptr;
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

void vsc_expose( const int16 handle, const int16 status )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 1, 0, 93};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=status;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  98:	Update Metafile Extents												*/
/*																										*/
/******************************************************************************/

void v_meta_extents( const int16 handle, const int16 min_x, const int16 min_y,
			const int16 max_x, const int16 max_y )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 2, 0, 0, 0, 98};
	
	/* ptsin anlegen */
	int16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=min_x;
	ptsin[1]=min_y;
	ptsin[2]=max_x;
	ptsin[3]=max_y;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  99:	Write Metafile Item													*/
/*																										*/
/******************************************************************************/

void v_write_meta( const int16 handle, const int16 num_intin, const int16 *a_intin,
			const int16 num_ptsin, const int16 *a_ptsin )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 0, 99};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[1]=num_ptsin;
	contrl[3]=num_intin;
	
	/* VDI aufrufen */
	vdi_(contrl, (int16 *)a_intin, (int16 *)a_ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  99, Op. 0:	Write Metafile Item											*/
/*																										*/
/******************************************************************************/

void vm_pagesize( const int16 handle, const int16 pgwidth, const int16 pgheight )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 3, 0, 99};
	
	/* intin anlegen... */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=0;
	intin[1]=pgwidth;
	intin[2]=pgheight;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc  99, Op. 1:	Coordinate Window												*/
/*																										*/
/******************************************************************************/

void vm_coords( const int16 handle, const int16 llx, const int16 lly,
			const int16 urx, const int16 ury )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 5, 0, 99};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=1;
	intin[1]=llx;
	intin[2]=lly;
	intin[3]=urx;
	intin[4]=ury;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc 100:	Change GEM VDI File Name											*/
/*																										*/
/******************************************************************************/

void vm_filename( const int16 handle, const char *filename )
{
	/* Benîtigte Prototypen */
	int32 strlen( const char *s );
	
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 0, 100};
	
	/* intin anlegen */
	int16 *intin;
	register int16 i, *i_ptr;
	register char *c_ptr;
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[3]=(int16)strlen(filename);
	
	intin=(int16 *)malloc((contrl[3]+1)*sizeof(*intin));
	if( intin==NULL )
		return;
	
	for( i=0, i_ptr=intin, c_ptr=(char *)filename ; i<=contrl[3] ; i++, i_ptr++, c_ptr++ )
		*i_ptr=*c_ptr;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc 101:	Set Line Offset														*/
/*																										*/
/******************************************************************************/

void v_offset( const int16 handle, const int16 offset )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 1, 0, 101};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=offset;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc 102:	Init System Font														*/
/*																										*/
/******************************************************************************/

void v_fontinit( const int16 handle, const void *font_header )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 2, 0, 102};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	*(void **)intin=font_header;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc 2000:	Escape 2000 (Atari-SLM-Drucker)									*/
/*																										*/
/******************************************************************************/

void v_escape2000( const int16 handle, const int16 times )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 1, 0, 2000};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=times;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 5, Esc 2103:	Set Document Info														*/
/*																										*/
/******************************************************************************/

int16 vs_document_info( const int16 handle, const int16 type, const char *s, int16 wchar )
{
	register int16 i;
	register const int16 *i_ptr;
	register const char *c_ptr;
	
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 0, 1, 2103};
	
	/* intin & intout anlegen */
	int16 *intin;
	int16 intout[10];
	
	/* Speicher allozieren */
	contrl[3] = (int16)(strlen(s)+1);
	intin = malloc(contrl[3] * sizeof(*intin));
	if( intin==NULL )
		return -2;
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	intin[0] = type;
	if( wchar )
		for( i=0, i_ptr=(const int16 *)s ; i<contrl[3]-1 && *i_ptr!='\0' ; i++, i_ptr++ )
			intin[i+1] = *i_ptr;
	else
		for( i=0, c_ptr=s ; i<contrl[3]-1 && *c_ptr!='\0' ; i++, c_ptr++ )
			intin[i+1] = *c_ptr;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Den Speicher wieder freigeben */
	free(intin);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 138, Esc	3: Set RGB (?)																*/
/*																										*/
/******************************************************************************/

void v_setrgb( const int16 handle, const int16 type,
				const int16 r, const int16 g, const int16 b ){
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={138, 0, 0, 3, 0, 3};
	
	/* intin & intout anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[5] = type;
	contrl[6]=handle;
	
	intin[0] = r;
	intin[1] = g;
	intin[2] = b;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 202, Esc	0: Inquire Foreground Color (Text)									*/
/*																										*/
/******************************************************************************/

int32 vqt_fg_color( const int16 handle, COLOR_ENTRY *fg_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={202, 0, 0, 0, 6, 0};
	
	/* intin & intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* RÅckgabewerte setzen */
	if( fg_color!=NULL )
	{
		fg_color->rgb.reserved	= intout[2];
		fg_color->rgb.red			= intout[3];
		fg_color->rgb.green		= intout[4];
		fg_color->rgb.blue		= intout[5];
	}
		
	return *(int32 *)&intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 202, Esc	1: Inquire Foreground Color (Filled Objects)						*/
/*																										*/
/******************************************************************************/

int32 vqf_fg_color( const int16 handle, COLOR_ENTRY *fg_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={202, 0, 0, 0, 6, 1};
	
	/* intin & intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* RÅckgabewerte setzen */
	if( fg_color!=NULL )
	{
		fg_color->rgb.reserved	= intout[2];
		fg_color->rgb.red			= intout[3];
		fg_color->rgb.green		= intout[4];
		fg_color->rgb.blue		= intout[5];
	}
		
	return *(int32 *)&intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 202, Esc	2: Inquire Foreground Color (Line)									*/
/*																										*/
/******************************************************************************/

int32 vql_fg_color( const int16 handle, COLOR_ENTRY *fg_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={202, 0, 0, 0, 6, 2};
	
	/* intin & intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* RÅckgabewerte setzen */
	if( fg_color!=NULL )
	{
		fg_color->rgb.reserved	= intout[2];
		fg_color->rgb.red			= intout[3];
		fg_color->rgb.green		= intout[4];
		fg_color->rgb.blue		= intout[5];
	}
		
	return *(int32 *)&intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 202, Esc	3: Inquire Foreground Color (Marker)								*/
/*																										*/
/******************************************************************************/

int32 vqm_fg_color( const int16 handle, COLOR_ENTRY *fg_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={202, 0, 0, 0, 6, 3};
	
	/* intin & intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* RÅckgabewerte setzen */
	if( fg_color!=NULL )
	{
		fg_color->rgb.reserved	= intout[2];
		fg_color->rgb.red			= intout[3];
		fg_color->rgb.green		= intout[4];
		fg_color->rgb.blue		= intout[5];
	}
		
	return *(int32 *)&intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 202, Esc	4: Inquire Foreground Color (Raster - Bitmap)					*/
/*																										*/
/******************************************************************************/

int32 vqr_fg_color( const int16 handle, COLOR_ENTRY *fg_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={202, 0, 0, 0, 6, 4};
	
	/* intin & intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* RÅckgabewerte setzen */
	if( fg_color!=NULL )
	{
		fg_color->rgb.reserved	= intout[2];
		fg_color->rgb.red			= intout[3];
		fg_color->rgb.green		= intout[4];
		fg_color->rgb.blue		= intout[5];
	}
		
	return *(int32 *)&intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 203, Esc	0: Inquire Background Color (Text)									*/
/*																										*/
/******************************************************************************/

int32 vqt_bg_color( const int16 handle, COLOR_ENTRY *bg_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={203, 0, 0, 0, 6, 0};
	
	/* intin & intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* RÅckgabewerte setzen */
	if( bg_color!=NULL )
	{
		bg_color->rgb.reserved	= intout[2];
		bg_color->rgb.red			= intout[3];
		bg_color->rgb.green		= intout[4];
		bg_color->rgb.blue		= intout[5];
	}
		
	return *(int32 *)&intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 203, Esc	1: Inquire Background Color (Filled Objects)						*/
/*																										*/
/******************************************************************************/

int32 vqf_bg_color( const int16 handle, COLOR_ENTRY *bg_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={203, 0, 0, 0, 6, 1};
	
	/* intin & intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* RÅckgabewerte setzen */
	if( bg_color!=NULL )
	{
		bg_color->rgb.reserved	= intout[2];
		bg_color->rgb.red			= intout[3];
		bg_color->rgb.green		= intout[4];
		bg_color->rgb.blue		= intout[5];
	}
		
	return *(int32 *)&intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 203, Esc	2: Inquire Background Color (Line)									*/
/*																										*/
/******************************************************************************/

int32 vql_bg_color( const int16 handle, COLOR_ENTRY *bg_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={203, 0, 0, 0, 6, 2};
	
	/* intin & intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* RÅckgabewerte setzen */
	if( bg_color!=NULL )
	{
		bg_color->rgb.reserved	= intout[2];
		bg_color->rgb.red			= intout[3];
		bg_color->rgb.green		= intout[4];
		bg_color->rgb.blue		= intout[5];
	}
		
	return *(int32 *)&intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 203, Esc	3: Inquire Background Color (Marker)								*/
/*																										*/
/******************************************************************************/

int32 vqm_bg_color( const int16 handle, COLOR_ENTRY *bg_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={203, 0, 0, 0, 6, 3};
	
	/* intin & intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* RÅckgabewerte setzen */
	if( bg_color!=NULL )
	{
		bg_color->rgb.reserved	= intout[2];
		bg_color->rgb.red			= intout[3];
		bg_color->rgb.green		= intout[4];
		bg_color->rgb.blue		= intout[5];
	}
		
	return *(int32 *)&intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 203, Esc	4: Inquire Background Color (Raster - Bitmap)					*/
/*																										*/
/******************************************************************************/

int32 vqr_bg_color( const int16 handle, COLOR_ENTRY *bg_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={203, 0, 0, 0, 6, 4};
	
	/* intin & intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* RÅckgabewerte setzen */
	if( bg_color!=NULL )
	{
		bg_color->rgb.reserved	= intout[2];
		bg_color->rgb.red			= intout[3];
		bg_color->rgb.green		= intout[4];
		bg_color->rgb.blue		= intout[5];
	}
		
	return *(int32 *)&intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 204, Esc	0: Translate Color Entry to Pixel Value							*/
/*																										*/
/******************************************************************************/

uint32 v_color2value( const int16 handle, const int32 color_space, COLOR_ENTRY *color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={204, 0, 0, 6, 2, 0};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	*(int32 *)&intin[0] = color_space;
	intin[2] = color->rgb.reserved;
	intin[3] = color->rgb.red;
	intin[4] = color->rgb.green;
	intin[5] = color->rgb.blue;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return *(int32 *)&intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 204, Esc	1: Translate Pixel Value to Color Entry							*/
/*																										*/
/******************************************************************************/

int32 v_value2color( const int16 handle, const uint32 value, COLOR_ENTRY *color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={204, 0, 0, 2, 6, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	*(uint32 *)&intin[0] = value;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* RÅckgabewerte setzen */
	if( color!=NULL )
	{
		color->rgb.reserved	= intout[2];
		color->rgb.red			= intout[3];
		color->rgb.green		= intout[4];
		color->rgb.blue		= intout[5];
	}
		
	return *(int32 *)&intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 204, Esc	2: Translate Color Entry to Nearest Colot Entry					*/
/*																										*/
/******************************************************************************/

int32 v_color2nearest( const int16 handle, const int32 color_space, const COLOR_ENTRY *color,
			COLOR_ENTRY *nearest )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={204, 0, 0, 6, 6, 2};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	*(int32 *)&intin[0] = color_space;
	intin[2] = color->rgb.reserved;
	intin[3] = color->rgb.red;
	intin[4] = color->rgb.green;
	intin[5] = color->rgb.blue;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* RÅckgabewerte setzen */
	if( nearest!=NULL )
	{
		nearest->rgb.reserved	= intout[2];
		nearest->rgb.red			= intout[3];
		nearest->rgb.green		= intout[4];
		nearest->rgb.blue			= intout[5];
	}
		
	return *(int32 *)&intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 204, Esc	3: Inquire Color Space and Pixel Format							*/
/*																										*/
/******************************************************************************/

int32 vq_px_format( const int16 handle, uint32 *px_format )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={204, 0, 0, 0, 4, 3};
	
	/* intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* RÅckgabewerte setzen */
	if( px_format!=NULL )
		*px_format = *(uint32 *)&intout[2];
		
	return *(int32 *)&intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 206, Esc	0: Inqurire Color Table													*/
/*																										*/
/******************************************************************************/

int16 vq_ctab( const int16 handle, const int32 ctab_length, COLOR_TAB *ctab )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={206, 0, 0, 2, 0, 0};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	*(int32 *)&intin[0] = ctab_length;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, (int16 *)ctab, _VDIParBlk.ptsout);
	
	return (contrl[4]>0 ? TRUE : FALSE);
}

/******************************************************************************/
/*																										*/
/* VDI 206, Esc	1: Inquire Color Table Entry											*/
/*																										*/
/******************************************************************************/

int32 vq_ctab_entry( const int16 handle, const int16 index, COLOR_ENTRY *color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={206, 0, 0, 1, 6, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	intin[0] = index;

	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* RÅckgabewerte setzen */
	if( color!=NULL )
	{
		color->rgb.reserved	= intout[2];
		color->rgb.red			= intout[3];
		color->rgb.green		= intout[4];
		color->rgb.blue		= intout[5];
	}
		
	return *(int32 *)&intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 206, Esc	2: Inquire Current Color Table Id									*/
/*																										*/
/******************************************************************************/

int32 vq_ctab_id( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={206, 0, 0, 0, 2, 2};
	
	/* intin & intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return *(int32 *)&intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 206, Esc	3: Translate Color Table Index to VDI Color Index				*/
/*																										*/
/******************************************************************************/

int16 v_ctab_idx2vdi( const int16 handle, const int16 index )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={206, 0, 0, 1, 1, 3};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	intin[0] = index;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 206, Esc	4: Translate vdi_ Color Index to Color Table Index				*/
/*																										*/
/******************************************************************************/

int16 v_ctab_vdi2idx( const int16 handle, const int16 index )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={206, 0, 0, 1, 1, 4};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	intin[0] = index;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 206, Esc	5: Inquire Color Table Value											*/
/*																										*/
/******************************************************************************/

int32 v_ctab_idx2value( const int16 handle, const int16 index )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={206, 0, 0, 1, 2, 5};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	intin[0] = index;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return *(int32 *)intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 206, Esc	6: Inquire Color Table Id												*/
/*																										*/
/******************************************************************************/

int32 v_get_ctab_id( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={206, 0, 0, 0, 2, 6};
	
	/* intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return *(int32 *)intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 206, Esc	7: Inquire Default Color Table										*/
/*																										*/
/******************************************************************************/

int16 vq_dflt_ctab( const int16 handle, int32 ctab_length, COLOR_TAB *ctab )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={206, 0, 0, 2, 0, 7};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* Intin fÅllen */
	*(int32 *)&intin[0] = ctab_length;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, (int16 *)ctab, _VDIParBlk.ptsout);
	
	return (contrl[4]>0 ? TRUE : FALSE);
}

/******************************************************************************/
/*																										*/
/* VDI 206, Esc	8: Create Color Table													*/
/*																										*/
/******************************************************************************/

COLOR_TAB *v_create_ctab( const int16 handle, const int32 color_space, uint32 px_format ){
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={206, 0, 0, 4, 2, 8};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* Intin fÅllen */
	*(int32 *)&intin[0] = color_space;
	*(uint32 *)&intin[2] = px_format;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return *(COLOR_TAB**)&intout[0];}

/******************************************************************************/
/*																										*/
/* VDI 206, Esc	9: Delete Color Table													*/
/*																										*/
/******************************************************************************/

int16 v_delete_ctab( const int16 handle, COLOR_TAB *ctab ){
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={206, 0, 0, 2, 0, 9};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* Intin fÅllen */
	*(COLOR_TAB **)&intin[0] = ctab;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];}

/******************************************************************************/
/*																										*/
/* VDI 208, Esc	0: Create Invers Color Table Referenz								*/
/*																										*/
/******************************************************************************/

ITAB_REF v_create_itab( const int16 handle, COLOR_TAB *ctab, int16 bits )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={208, 0, 0, 5, 2, 0};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* Intin fÅllen */
	*(COLOR_TAB **)&intin[0] = ctab;
	intin[2] = bits;
	intin[3] = 0;
	intin[4] = 0;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, (int16 *)ctab, _VDIParBlk.ptsout);
	
	return *(ITAB_REF *)&intin[0];
}

/******************************************************************************/
/*																										*/
/* VDI 208, Esc	1: Delete Invers Color Table Referenz								*/
/*																										*/
/******************************************************************************/

int16 v_delete_itab( const int16 handle, ITAB_REF *itab )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={208, 0, 0, 2, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* Intin fÅllen */
	*(ITAB_REF **)&intin[0] = itab;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intin[0];
}

