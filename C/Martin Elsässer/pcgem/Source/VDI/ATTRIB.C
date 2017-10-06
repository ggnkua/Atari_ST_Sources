/******************************************************************************/
/*																										*/
/*     Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C       */
/*																										*/
/* Die (N)VDI-Funktionen - Attribut-Funktionen											*/
/*																										*/
/*	(c) 1999 by Martin ElsÑsser																*/
/******************************************************************************/

#include <ACSVDI.H>

/******************************************************************************/
/*																										*/
/* VDI  32: Set Writing Mode																	*/
/*																										*/
/******************************************************************************/

INT16 vswr_mode( const INT16 handle, const INT16 mode )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={32, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0] = mode;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  14: Set Color Representation														*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

void vs_color( const INT16 handle, const INT16 index, const RGB *rgb )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={14, 0, 0, 4, 0};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=index;
	intin[1]=rgb->red;
	intin[2]=rgb->green;
	intin[3]=rgb->blue;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	void vs_color( const INT16 handle, const INT16 index, const INT16 *rgb_in )
#else
	void vs_color_( const INT16 handle, const INT16 index, const INT16 *rgb_in )
#endif
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={14, 0, 0, 4, 0};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=index;
	intin[1]=rgb_in[0];
	intin[2]=rgb_in[1];
	intin[3]=rgb_in[2];
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI  15: Set Polyline Line Type															*/
/*																										*/
/******************************************************************************/

INT16 vsl_type( const INT16 handle, const INT16 style )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={15, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=style;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 113: Set user-defined Line-Style Pattern											*/
/*																										*/
/******************************************************************************/

void vsl_udsty( const INT16 handle, const INT16 pattern )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={113, 0, 0, 1, 0};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=pattern;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI  16: Set Polyline Width																*/
/*																										*/
/******************************************************************************/

INT16 vsl_width( const INT16 handle, const INT16 width )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={16, 1, 1, 0, 0};
	
	/* ptsin & ptsout anlegen */
	INT16 ptsin[10];
	INT16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=width;
	ptsin[1]=0;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, ptsin, _VDIParBlk.intout, ptsout);
	
	return ptsout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  17: Set Polyline Color Index														*/
/*																										*/
/******************************************************************************/

INT16 vsl_color( const INT16 handle, const INT16 color )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={17, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=color;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 108: Set Polyline End Styles															*/
/*																										*/
/******************************************************************************/

void vsl_ends( const INT16 handle, const INT16 beg_style, const INT16 end_style )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={108, 0, 0, 2, 0};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=beg_style;
	intin[1]=end_style;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI  18: Set Polymarker Type																*/
/*																										*/
/******************************************************************************/

INT16 vsm_type( const INT16 handle, const INT16 symbol )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={18, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=symbol;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  19: Set Polymarker Height															*/
/*																										*/
/******************************************************************************/

INT16 vsm_height( const INT16 handle, const INT16 height )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={19, 1, 1, 0, 0};
	
	/* ptsin & ptsout anlegen */
	INT16 ptsin[10];
	INT16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=0;
	ptsin[1]=height;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, ptsin, _VDIParBlk.intout, ptsout);
	
	return ptsout[1];
}

/******************************************************************************/
/*																										*/
/* VDI  20: Set Polymarker Color Index														*/
/*																										*/
/******************************************************************************/

INT16 vsm_color( const INT16 handle, const INT16 color )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={20, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[10]=color;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  12: Set Character Height, Absolute Mode											*/
/*																										*/
/******************************************************************************/

void vst_height( const INT16 handle, const INT16 height,
		INT16 *char_width, INT16 *char_height, INT16 *cell_width, INT16 *cell_height )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={12, 1, 2, 0, 0};
	
	/* ptsin & ptsout anlegen */
	INT16 ptsin[10];
	INT16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=0;
	ptsin[1]=height;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, ptsin, _VDIParBlk.intout, ptsout);
	
	/* Die tatsÑchlichen Grîûen zurÅckgeben */
	if( char_width!=NULL )
		*char_width=ptsout[0];
	if( char_height!=NULL )
		*char_height=ptsout[1];
	if( cell_width!=NULL )
		*cell_width=ptsout[2];
	if( cell_height!=NULL )
		*cell_height=ptsout[3];
}

/******************************************************************************/
/*																										*/
/* VDI 107: Set Character Height, Points Mode											*/
/*																										*/
/******************************************************************************/

INT16 vst_point( const INT16 handle, const INT16 point, 
		INT16 *char_width, INT16 *char_height, INT16 *cell_width, INT16 *cell_height )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={107, 0, 2, 1, 1};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* ptsout anlegen */
	INT16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=point;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, ptsout);
	
	/* Die tatsÑchlichen Grîûen zurÅckgeben */
	if( char_width!=NULL )
		*char_width=ptsout[0];
	if( char_height!=NULL )
		*char_height=ptsout[1];
	if( cell_width!=NULL )
		*cell_width=ptsout[2];
	if( cell_height!=NULL )
		*cell_height=ptsout[3];
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  13: Set Character Baseline Vector													*/
/*																										*/
/******************************************************************************/

INT16 vst_rotation( const INT16 handle, const INT16 angle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={13, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=angle;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  21: Set Text Face																		*/
/*																										*/
/******************************************************************************/

INT16 vst_font( const INT16 handle, const INT16 font )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={21, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=font;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  22: Set Graphic Text Color Index													*/
/*																										*/
/******************************************************************************/

INT16 vst_color( const INT16 handle, const INT16 color )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={22, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=color;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 106: Set Graphic Text Special Effects												*/
/*																										*/
/******************************************************************************/

INT16 vst_effects( const INT16 handle, const INT16 effect )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={106, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=effect;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[10];
}

/******************************************************************************/
/*																										*/
/* VDI  39: Set Graphic Text Alignment														*/
/*																										*/
/******************************************************************************/

void vst_alignment( const INT16 handle, const INT16 hor_in, const INT16 ver_in,
		INT16 *hor_out, INT16 *ver_out )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={39, 0, 0, 2, 2};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=hor_in;
	intin[1]=ver_in;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	if( hor_out!=NULL )
		*hor_out=intout[0];
	if( ver_out!=NULL )
		*ver_out=intout[1];
}

/******************************************************************************/
/*																										*/
/* VDI  23: Set Fill Interior Index															*/
/*																										*/
/******************************************************************************/

INT16 vsf_interior( const INT16 handle, const INT16 style )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={23, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=style;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  24: Set Fill Style Index																*/
/*																										*/
/******************************************************************************/

INT16 vsf_style( const INT16 handle, const INT16 style )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={24, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=style;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  25: Set Fill Color Index																*/
/*																										*/
/******************************************************************************/

INT16 vsf_color( const INT16 handle, const INT16 color )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={25, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=color;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 104: Set Fill Perimeter Visibility													*/
/*																										*/
/******************************************************************************/

INT16 vsf_perimeter( const INT16 handle, const INT16 per_vis )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={104, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=per_vis;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 112: Set user-defined Fill Pattern													*/
/*																										*/
/******************************************************************************/

void vsf_udpat( const INT16 handle, const INT16 *pattern, const INT16 nplanes )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={104, 0, 0, 1, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[3]=16*nplanes;
	
	/* VDI aufrufen */
	vdi(contrl, (INT16 *)pattern, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 112: Set user-defined Fill Pattern (wegen Tipfehler in Original-Doku)	*/
/*																										*/
/******************************************************************************/

void vsf_updat( const INT16 handle, const INT16 *pattern, const INT16 nplanes )
{
	vsf_udpat(handle, pattern, nplanes);
}
