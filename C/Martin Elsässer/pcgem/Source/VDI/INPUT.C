/******************************************************************************/
/*																										*/
/*     Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C       */
/*																										*/
/* Die (N)VDI-Funktionen - Eingabe-Funktionen											*/
/*																										*/
/*	(c) 1999 by Martin ElsÑsser																*/
/******************************************************************************/

#include <ACSVDI.H>

/******************************************************************************/
/*																										*/
/* VDI  33: Set Input Mode																		*/
/*																										*/
/******************************************************************************/

INT16 vsin_mode( const INT16 handle, const INT16 dev_type, const INT16 mode )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={33, 0, 0, 2, 1};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=dev_type;
	intin[1]=mode;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  28: Input Locator, Request Mode													*/
/*																										*/
/******************************************************************************/

void vrq_locator( const INT16 handle, const INT16 x_in, const INT16 y_in,
		INT16 *x_out, INT16 *y_out, INT16 *term )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={28, 1, 1, 0, 1};
	
	/* intout anlegen */
	INT16 intout[10];
	
	/* ptsin & ptsout anlegen */
	INT16 ptsin[10];
	INT16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=x_in;
	ptsin[1]=y_in;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, ptsin, intout, ptsout);
	
	if( x_out!=NULL )
		*x_out=ptsout[0];
	if( y_out!=NULL )
		*y_out=ptsout[1];
	if( term!=NULL )
		*term=intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  28: Input Locator, Sample Mode														*/
/*																										*/
/******************************************************************************/

INT16 vsm_locator( const INT16 handle, const INT16 x_in, const INT16 y_in,
		INT16 *x_out, INT16 *y_out, INT16 *term )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={28, 1, 1, 0, 1};
	
	/* intout anlegen */
	INT16 intout[10];
	
	/* ptsin & ptsout anlegen */
	INT16 ptsin[10];
	INT16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=x_in;
	ptsin[1]=y_in;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, ptsin, intout, ptsout);
	
	if( x_out!=NULL )
		*x_out=ptsout[0];
	if( y_out!=NULL )
		*y_out=ptsout[1];
	if( term!=NULL )
		*term=intout[0];
	
	/* Bit-Vektor liefern, was passiert ist */
	return (contrl[4]!=0 ? 0x02 : 0x00) | (contrl[2]!=0 ? 0x01 : 0x00);
}

/******************************************************************************/
/*																										*/
/* VDI  29: Input Valuator, Request Mode													*/
/*																										*/
/******************************************************************************/

void vrq_valuator( const INT16 handle, const INT16 value_in, INT16 *value_out, INT16 *term )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={29, 0, 0, 1, 2};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=value_in;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	if( value_out!=NULL )
		*value_out=intout[0];
	if( term!=NULL )
		*term=intout[1];
}

/******************************************************************************/
/*																										*/
/* VDI  29: Input Valuator, Sample Mode													*/
/*																										*/
/******************************************************************************/

void vsm_valuator( const INT16 handle, const INT16 value_in,
		INT16 *value_out, INT16 *term, INT16 *status )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={29, 0, 0, 1, 2};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=value_in;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	if( status!=NULL )
		*status=contrl[4];
	if( value_out!=NULL && contrl[4]>0 )
		*value_out=intout[0];
	if( term!=NULL && contrl[4]>1 )
		*term=intout[1];
}

/******************************************************************************/
/*																										*/
/* VDI  30: Input Choice, Request Mode														*/
/*																										*/
/******************************************************************************/

void vrq_choice( const INT16 handle, const INT16 choice_in, INT16 *choice_out )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={30, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=choice_in;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	if( choice_out!=NULL )
		*choice_out=intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  30: Input Choice, Sample Mode														*/
/*																										*/
/******************************************************************************/

INT16 vsm_choice( const INT16 handle, INT16 *choice )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={30, 0, 0, 0, 1};
	
	/* intout anlegen */
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	if( choice!=NULL )
		*choice=intout[0];
	
	return contrl[4];
}

/******************************************************************************/
/*																										*/
/* VDI  31: Input String, Request Mode														*/
/*																										*/
/******************************************************************************/

void vrq_string( const INT16 handle, const INT16 max_length, const INT16 echo_mode,
		const INT16 *echo_xy, char *string )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={31, 1, 0, 2, 0};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 *intout;
	
	/* ptsin anlegen */
	INT16 ptsin[10];
	
	/* Speicher fÅr intout allozieren */
	intout=(INT16 *)malloc(max_length*sizeof(*intout));
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[4]=max_length;
	
	intin[0]=max_length;
	intin[1]=echo_mode;
	
	ptsin[0]=(echo_xy==NULL ? 0 : echo_xy[0]);
	ptsin[1]=(echo_xy==NULL ? 0 : echo_xy[1]);
	
	/* VDI aufrufen */
	vdi(contrl, intin, ptsin, intout, _VDIParBlk.ptsout);
	
	/* Den String speichern */
	if( string!=NULL )
	{
		INT16 i, *i_ptr;
		char *c_ptr;
		
		for( i=0, i_ptr=intout, c_ptr=string ; i<contrl[4] && i<max_length && *i_ptr!=0 ; i++ )
			*(c_ptr++)=*(i_ptr++);
		*c_ptr='\0';
	}
	
	/* Den Speicher freigeben */
	free(intout);
}

/******************************************************************************/
/*																										*/
/* VDI  31: Input String, Sample Mode														*/
/*																										*/
/******************************************************************************/

INT16 vsm_string( const INT16 handle, const INT16 max_length, const INT16 echo_mode,
		const INT16 *echo_xy, char *string )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={31, 1, 0, 2, 0};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 *intout;
	
	/* ptsin anlegen */
	INT16 ptsin[10];
	
	/* Speicher fÅr intout allozieren */
	intout=(INT16 *)malloc(max_length*sizeof(*intout));
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[4]=max_length;
	
	intin[0]=max_length;
	intin[1]=echo_mode;
	
	ptsin[0]=(echo_xy==NULL ? 0 : echo_xy[0]);
	ptsin[1]=(echo_xy==NULL ? 0 : echo_xy[1]);
	
	/* VDI aufrufen */
	vdi(contrl, intin, ptsin, intout, _VDIParBlk.ptsout);
	
	/* Den String speichern */
	if( string!=NULL )
	{
		INT16 i, *i_ptr;
		char *c_ptr;
		
		for( i=0, i_ptr=intout, c_ptr=string ; i<contrl[4] && i<max_length && *i_ptr!=0; i++ )
			*(c_ptr++)=*(i_ptr++);
		*c_ptr='\0';
	}
	
	/* Den Speicher freigeben */
	free(intout);
	
	return contrl[4];
}

/******************************************************************************/
/*																										*/
/* VDI 111: Set Mouse Form																		*/
/*																										*/
/******************************************************************************/

void vsc_form( const INT16 handle, const INT16 *pcur_form )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={111, 0, 0, 37, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, (INT16 *)pcur_form, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 118: Exchange Timer Interrupt Vector												*/
/*																										*/
/******************************************************************************/

void vex_timv( const INT16 handle, const INT16 (*tim_addr)(),
		INT16 (**otim_addr)(), INT16 *tim_conv )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={118, 0, 0, 0, 1};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	*(INT32 *)(&contrl[7])=(INT32)tim_addr;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, tim_conv, _VDIParBlk.ptsout);
	
	/* Die alte Routine zurÅckgeben */
	*otim_addr=(INT16 (*)())*(INT32 *)(&contrl[9]);
}

/******************************************************************************/
/*																										*/
/* VDI 122: Show Cursor																			*/
/*																										*/
/******************************************************************************/

void v_show_c( const INT16 handle, const INT16 reset )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={122, 0, 0, 1, 0};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=reset;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 123: Hide Cursor																			*/
/*																										*/
/******************************************************************************/

void v_hide_c( const INT16 handle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={123, 0, 0, 0, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsout, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 124: Sample Mouse Button State														*/
/*																										*/
/******************************************************************************/

void vq_mouse( const INT16 handle, INT16 *pstatus, INT16 *x, INT16 *y )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={124, 0, 1, 0, 1};
	
	/* ptsout anlegen */
	INT16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, pstatus, ptsout);
	
	/* Die Werte zurÅckgeben */
	if( x!=NULL )
		*x=ptsout[0];
	if( y!=NULL )
		*y=ptsout[1];
}

/******************************************************************************/
/*																										*/
/* VDI 125: Exchange Button Change Vector													*/
/*																										*/
/******************************************************************************/

void vex_butv( const INT16 handle, const INT16 (*pusrcode)(), INT16 (**psavcode)() )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={125, 0, 0, 0, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	*(INT32 *)(&contrl[7])=(INT32)pusrcode;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
	
	/* Den alten Wert zurÅckgeben */
	*(INT32 *)psavcode=*(INT32 *)(&contrl[9]);
}

/******************************************************************************/
/*																										*/
/* VDI 126: Exchange Mouse Movement Vector												*/
/*																										*/
/******************************************************************************/

void vex_motv( const INT16 handle, const INT16 (*pusrcode)(), INT16 (**psavcode)() )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={126, 0, 0, 0, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	*(INT32 *)(&contrl[7])=(INT32)pusrcode;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
	
	/* Den alten Wert zurÅckgeben */
	*(INT32 *)psavcode=*(INT32 *)(&contrl[9]);
}

/******************************************************************************/
/*																										*/
/* VDI 127: Exchange Cursor Change Vector													*/
/*																										*/
/******************************************************************************/

void vex_curv( const INT16 handle, const INT16 (*pusrcode)(), INT16 (**psavcode)() )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={127, 0, 0, 0, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	*(INT32 *)(&contrl[7])=(INT32)pusrcode;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
	
	/* Den alten Wert zurÅckgeben */
	*(INT32 *)psavcode=*(INT32 *)(&contrl[9]);
}

/******************************************************************************/
/*																										*/
/* VDI 128: Sample Keyboard State Information											*/
/*																										*/
/******************************************************************************/

void vq_key_s( const INT16 handle, INT16 *pstatus )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={128, 0, 0, 0, 1};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, pstatus, _VDIParBlk.ptsout);
}
