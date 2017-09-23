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

int16 vsin_mode( const int16 handle, const int16 dev_type, const int16 mode )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={33, 0, 0, 2, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=dev_type;
	intin[1]=mode;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  28: Input Locator, Request Mode													*/
/*																										*/
/******************************************************************************/

void vrq_locator( const int16 handle, const int16 x_in, const int16 y_in,
		int16 *x_out, int16 *y_out, int16 *term )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={28, 1, 1, 0, 1};
	
	/* intout anlegen */
	int16 intout[10];
	
	/* ptsin & ptsout anlegen */
	int16 ptsin[10];
	int16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=x_in;
	ptsin[1]=y_in;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, ptsin, intout, ptsout);
	
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

int16 vsm_locator( const int16 handle, const int16 x_in, const int16 y_in,
		int16 *x_out, int16 *y_out, int16 *term )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={28, 1, 1, 0, 1};
	
	/* intout anlegen */
	int16 intout[10];
	
	/* ptsin & ptsout anlegen */
	int16 ptsin[10];
	int16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=x_in;
	ptsin[1]=y_in;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, ptsin, intout, ptsout);
	
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

void vrq_valuator( const int16 handle, const int16 value_in, int16 *value_out, int16 *term )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={29, 0, 0, 1, 2};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=value_in;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
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

void vsm_valuator( const int16 handle, const int16 value_in,
		int16 *value_out, int16 *term, int16 *status )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={29, 0, 0, 1, 2};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=value_in;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
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

void vrq_choice( const int16 handle, const int16 choice_in, int16 *choice_out )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={30, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=choice_in;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	if( choice_out!=NULL )
		*choice_out=intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  30: Input Choice, Sample Mode														*/
/*																										*/
/******************************************************************************/

int16 vsm_choice( const int16 handle, int16 *choice )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={30, 0, 0, 0, 1};
	
	/* intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	if( choice!=NULL )
		*choice=intout[0];
	
	return contrl[4];
}

/******************************************************************************/
/*																										*/
/* VDI  31: Input String, Request Mode														*/
/*																										*/
/******************************************************************************/

void vrq_string( const int16 handle, const int16 max_length, const int16 echo_mode,
		const int16 *echo_xy, char *string )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={31, 1, 0, 2, 0};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 *intout;
	
	/* ptsin anlegen */
	int16 ptsin[10];
	
	/* Speicher fÅr intout allozieren */
	intout=(int16 *)malloc(max_length*sizeof(*intout));
	if( intout!=NULL )
		return;
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[4]=max_length;
	
	intin[0]=max_length;
	intin[1]=echo_mode;
	
	ptsin[0] = (echo_xy==NULL ? 0 : echo_xy[0]);
	ptsin[1] = (echo_xy==NULL ? 0 : echo_xy[1]);
	
	/* VDI aufrufen */
	vdi_(contrl, intin, ptsin, intout, _VDIParBlk.ptsout);
	
	/* Den String speichern */
	if( string!=NULL )
	{
		int16 i, *i_ptr;
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

int16 vsm_string( const int16 handle, const int16 max_length, const int16 echo_mode,
		const int16 *echo_xy, char *string )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={31, 1, 0, 2, 0};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 *intout;
	
	/* ptsin anlegen */
	int16 ptsin[10];
	
	/* Speicher fÅr intout allozieren */
	intout=(int16 *)malloc(max_length*sizeof(*intout));
	if( intout!=NULL )
		return 0;
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[4]=max_length;
	
	intin[0]=max_length;
	intin[1]=echo_mode;
	
	ptsin[0] = (echo_xy==NULL ? 0 : echo_xy[0]);
	ptsin[1] = (echo_xy==NULL ? 0 : echo_xy[1]);
	
	/* VDI aufrufen */
	vdi_(contrl, intin, ptsin, intout, _VDIParBlk.ptsout);
	
	/* Den String speichern */
	if( string!=NULL )
	{
		int16 i, *i_ptr;
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

void vsc_form( const int16 handle, const int16 *pcur_form )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={111, 0, 0, 37, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, (int16 *)pcur_form, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 118: Exchange Timer Interrupt Vector												*/
/*																										*/
/******************************************************************************/

void vex_timv( const int16 handle, const int16 (*tim_addr)(),
		int16 (**otim_addr)(), int16 *tim_conv )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={118, 0, 0, 0, 1};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	*(int32 *)(&contrl[7])=(int32)tim_addr;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, tim_conv, _VDIParBlk.ptsout);
	
	/* Die alte Routine zurÅckgeben */
	if( otim_addr!=NULL )
		*otim_addr=(int16 (*)())*(int32 *)(&contrl[9]);
}

/******************************************************************************/
/*																										*/
/* VDI 122: Show Cursor																			*/
/*																										*/
/******************************************************************************/

void v_show_c( const int16 handle, const int16 reset )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={122, 0, 0, 1, 0};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=reset;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 123: Hide Cursor																			*/
/*																										*/
/******************************************************************************/

void v_hide_c( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={123, 0, 0, 0, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsout, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 124: Sample Mouse Button State														*/
/*																										*/
/******************************************************************************/

void vq_mouse( const int16 handle, int16 *pstatus, int16 *x, int16 *y )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={124, 0, 1, 0, 1};
	
	/* ptsout anlegen */
	int16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, pstatus, ptsout);
	
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

void vex_butv( const int16 handle, const int16 (*pusrcode)(), int16 (**psavcode)() )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={125, 0, 0, 0, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	*(int32 *)(&contrl[7])=(int32)pusrcode;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
	
	/* Den alten Wert zurÅckgeben */
	if( psavcode!=NULL )
		*(int32 *)psavcode=*(int32 *)(&contrl[9]);
}

/******************************************************************************/
/*																										*/
/* VDI 134: Exchange Wheel Vector															*/
/*																										*/
/******************************************************************************/

void vex_wheelv( const int16 handle, const int16 (*pusrcode)(void), int16 (**psavcode)(void) )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={134, 0, 0, 0, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	*(int32 *)(&contrl[7])=(int32)pusrcode;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
	
	/* Den alten Wert zurÅckgeben */
	if( psavcode!=NULL )
		*(int32 *)psavcode=*(int32 *)(&contrl[9]);
}

/******************************************************************************/
/*																										*/
/* VDI 126: Exchange Mouse Movement Vector												*/
/*																										*/
/******************************************************************************/

void vex_motv( const int16 handle, const int16 (*pusrcode)(), int16 (**psavcode)() )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={126, 0, 0, 0, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	*(int32 *)(&contrl[7])=(int32)pusrcode;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
	
	/* Den alten Wert zurÅckgeben */
	if( psavcode!=NULL )
		*(int32 *)psavcode=*(int32 *)(&contrl[9]);
}

/******************************************************************************/
/*																										*/
/* VDI 127: Exchange Cursor Change Vector													*/
/*																										*/
/******************************************************************************/

void vex_curv( const int16 handle, const int16 (*pusrcode)(), int16 (**psavcode)() )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={127, 0, 0, 0, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	*(int32 *)(&contrl[7])=(int32)pusrcode;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
	
	/* Den alten Wert zurÅckgeben */
	if( psavcode!=NULL )
		*(int32 *)psavcode=*(int32 *)(&contrl[9]);
}

/******************************************************************************/
/*																										*/
/* VDI 128: Sample Keyboard State Information											*/
/*																										*/
/******************************************************************************/

void vq_key_s( const int16 handle, int16 *pstatus )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={128, 0, 0, 0, 1};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, pstatus, _VDIParBlk.ptsout);
}
