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
/* VDI  14: Set Color Representation														*/
/*																										*/
/******************************************************************************/

void vs_color( const int16 handle, const int16 index, const int16 *rgb_in )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={14, 0, 0, 4, 0};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=index;
	intin[1]=rgb_in[0];
	intin[2]=rgb_in[1];
	intin[3]=rgb_in[2];
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI  32: Set Writing Mode																	*/
/*																										*/
/******************************************************************************/

int16 vswr_mode( const int16 handle, const int16 mode )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={32, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0] = mode;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  15: Set Polyline Line Type															*/
/*																										*/
/******************************************************************************/

int16 vsl_type( const int16 handle, const int16 style )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={15, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=style;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 113: Set user-defined Line-Style Pattern											*/
/*																										*/
/******************************************************************************/

void vsl_udsty( const int16 handle, const int16 pattern )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={113, 0, 0, 1, 0};
	
	/* intin & intout anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=pattern;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI  16: Set Polyline Width																*/
/*																										*/
/******************************************************************************/

int16 vsl_width( const int16 handle, const int16 width )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={16, 1, 1, 0, 0};
	
	/* ptsin & ptsout anlegen */
	int16 ptsin[10];
	int16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=width;
	ptsin[1]=0;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, ptsin, _VDIParBlk.intout, ptsout);
	
	return ptsout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  17: Set Polyline Color Index														*/
/*																										*/
/******************************************************************************/

int16 vsl_color( const int16 handle, const int16 color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={17, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=color;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 108: Set Polyline End Styles															*/
/*																										*/
/******************************************************************************/

void vsl_ends( const int16 handle, const int16 beg_style, const int16 end_style )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={108, 0, 0, 2, 0};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=beg_style;
	intin[1]=end_style;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI  18: Set Polymarker Type																*/
/*																										*/
/******************************************************************************/

int16 vsm_type( const int16 handle, const int16 symbol )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={18, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=symbol;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  19: Set Polymarker Height															*/
/*																										*/
/******************************************************************************/

int16 vsm_height( const int16 handle, const int16 height )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={19, 1, 1, 0, 0};
	
	/* ptsin & ptsout anlegen */
	int16 ptsin[10];
	int16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=0;
	ptsin[1]=height;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, ptsin, _VDIParBlk.intout, ptsout);
	
	return ptsout[1];
}

/******************************************************************************/
/*																										*/
/* VDI  20: Set Polymarker Color Index														*/
/*																										*/
/******************************************************************************/

int16 vsm_color( const int16 handle, const int16 color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={20, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	intin[0] = color;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  12: Set Character Height, Absolute Mode											*/
/*																										*/
/******************************************************************************/

void vst_height( const int16 handle, const int16 height,
		int16 *char_width, int16 *char_height, int16 *cell_width, int16 *cell_height )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={12, 1, 2, 0, 0};
	
	/* ptsin & ptsout anlegen */
	int16 ptsin[10];
	int16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=0;
	ptsin[1]=height;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, ptsin, _VDIParBlk.intout, ptsout);
	
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

int16 vst_point( const int16 handle, const int16 point, 
		int16 *char_width, int16 *char_height, int16 *cell_width, int16 *cell_height )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={107, 0, 2, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* ptsout anlegen */
	int16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=point;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, ptsout);
	
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

int16 vst_rotation( const int16 handle, const int16 angle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={13, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=angle;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  21: Set Text Face																		*/
/*																										*/
/******************************************************************************/

int16 vst_font( const int16 handle, const int16 fontID )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={21, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=fontID;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  22: Set Graphic Text Color Index													*/
/*																										*/
/******************************************************************************/

int16 vst_color( const int16 handle, const int16 color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={22, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=color;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 106: Set Graphic Text Special Effects												*/
/*																										*/
/******************************************************************************/

int16 vst_effects( const int16 handle, const int16 effect )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={106, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	intin[0] = effect;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  39: Set Graphic Text Alignment														*/
/*																										*/
/******************************************************************************/

void vst_alignment( const int16 handle, const int16 hor_in, const int16 ver_in,
		int16 *hor_out, int16 *ver_out )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={39, 0, 0, 2, 2};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=hor_in;
	intin[1]=ver_in;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
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

int16 vsf_interior( const int16 handle, const int16 style )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={23, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=style;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  24: Set Fill Style Index																*/
/*																										*/
/******************************************************************************/

int16 vsf_style( const int16 handle, const int16 style )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={24, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=style;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  25: Set Fill Color Index																*/
/*																										*/
/******************************************************************************/

int16 vsf_color( const int16 handle, const int16 color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={25, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=color;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 104: Set Fill Perimeter Visibility													*/
/*																										*/
/******************************************************************************/

int16 vsf_perimeter( const int16 handle, const int16 per_vis )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={104, 0, 0, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=per_vis;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 104: Set Fill Perimeter Visibility (aus PC-GEM/3)								*/
/*																										*/
/******************************************************************************/

int16 vsf_perimeter3( const int16 handle, const int16 per_vis, const int16 style )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={104, 0, 0, 2, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0] = per_vis;
	intin[1] = style;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 112: Set user-defined Fill Pattern													*/
/*																										*/
/******************************************************************************/

void vsf_udpat( const int16 handle, const int16 *pattern, const int16 nplanes )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={112, 0, 0, 1, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[3]=16*nplanes;
	
	/* VDI aufrufen */
	vdi_(contrl, (int16 *)pattern, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 112: Set user-defined Fill Pattern (wegen Tipfehler in Original-Doku)	*/
/*																										*/
/******************************************************************************/

void vsf_updat( const int16 handle, const int16 *pattern, const int16 nplanes )
{
	vsf_udpat(handle, pattern, nplanes);
}

/******************************************************************************/
/*																										*/
/* VDI 200, Esc	0: Set Foreground Color (Text)										*/
/*																										*/
/******************************************************************************/

int16 vst_fg_color( const int16 handle, int32 color_space, COLOR_ENTRY *fg_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={200, 0, 0, 6, 1, 0};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	*(int32 *)&intin[0] = color_space;
	intin[2] = fg_color->rgb.reserved;
	intin[3] = fg_color->rgb.red;
	intin[4] = fg_color->rgb.green;
	intin[5] = fg_color->rgb.blue;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 200, Esc	1: Set Foreground Color (Filled Objects)							*/
/*																										*/
/******************************************************************************/

int16 vsf_fg_color( const int16 handle, int32 color_space, COLOR_ENTRY *fg_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={200, 0, 0, 6, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	*(int32 *)&intin[0] = color_space;
	intin[2] = fg_color->rgb.reserved;
	intin[3] = fg_color->rgb.red;
	intin[4] = fg_color->rgb.green;
	intin[5] = fg_color->rgb.blue;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 200, Esc	2: Set Foreground Color (Lines)										*/
/*																										*/
/******************************************************************************/

int16 vsl_fg_color( const int16 handle, int32 color_space, COLOR_ENTRY *fg_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={200, 0, 0, 6, 1, 2};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	*(int32 *)&intin[0] = color_space;
	intin[2] = fg_color->rgb.reserved;
	intin[3] = fg_color->rgb.red;
	intin[4] = fg_color->rgb.green;
	intin[5] = fg_color->rgb.blue;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 200, Esc	3: Set Foreground Color (Marker)										*/
/*																										*/
/******************************************************************************/

int16 vsm_fg_color( const int16 handle, int32 color_space, COLOR_ENTRY *fg_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={200, 0, 0, 6, 1, 3};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	*(int32 *)&intin[0] = color_space;
	intin[2] = fg_color->rgb.reserved;
	intin[3] = fg_color->rgb.red;
	intin[4] = fg_color->rgb.green;
	intin[5] = fg_color->rgb.blue;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 200, Esc	4: Set Foreground Color (Raster - Bitmaps)						*/
/*																										*/
/******************************************************************************/

int16 vsr_fg_color( const int16 handle, int32 color_space, COLOR_ENTRY *fg_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={200, 0, 0, 6, 1, 4};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	*(int32 *)&intin[0] = color_space;
	intin[2] = fg_color->rgb.reserved;
	intin[3] = fg_color->rgb.red;
	intin[4] = fg_color->rgb.green;
	intin[5] = fg_color->rgb.blue;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 201, Esc	0: Set Background Color (Text)										*/
/*																										*/
/******************************************************************************/

int16 vst_bg_color( const int16 handle, int32 color_space, COLOR_ENTRY *bg_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={201, 0, 0, 6, 1, 0};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	*(int32 *)&intin[0] = color_space;
	intin[2] = bg_color->rgb.reserved;
	intin[3] = bg_color->rgb.red;
	intin[4] = bg_color->rgb.green;
	intin[5] = bg_color->rgb.blue;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 201, Esc	1: Set Background Color (Filled Objects)							*/
/*																										*/
/******************************************************************************/

int16 vsf_bg_color( const int16 handle, int32 color_space, COLOR_ENTRY *bg_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={201, 0, 0, 6, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	*(int32 *)&intin[0] = color_space;
	intin[2] = bg_color->rgb.reserved;
	intin[3] = bg_color->rgb.red;
	intin[4] = bg_color->rgb.green;
	intin[5] = bg_color->rgb.blue;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 201, Esc	2: Set Background Color (Lines)										*/
/*																										*/
/******************************************************************************/

int16 vsl_bg_color( const int16 handle, int32 color_space, COLOR_ENTRY *bg_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={201, 0, 0, 6, 1, 2};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	*(int32 *)&intin[0] = color_space;
	intin[2] = bg_color->rgb.reserved;
	intin[3] = bg_color->rgb.red;
	intin[4] = bg_color->rgb.green;
	intin[5] = bg_color->rgb.blue;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 201, Esc	3: Set Background Color (Marker)										*/
/*																										*/
/******************************************************************************/

int16 vsm_bg_color( const int16 handle, int32 color_space, COLOR_ENTRY *bg_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={201, 0, 0, 6, 1, 3};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	*(int32 *)&intin[0] = color_space;
	intin[2] = bg_color->rgb.reserved;
	intin[3] = bg_color->rgb.red;
	intin[4] = bg_color->rgb.green;
	intin[5] = bg_color->rgb.blue;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 201, Esc	4: Set Background Color (Raster - Bitmaps)						*/
/*																										*/
/******************************************************************************/

int16 vsr_bg_color( const int16 handle, int32 color_space, COLOR_ENTRY *bg_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={201, 0, 0, 6, 1, 4};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	*(int32 *)&intin[0] = color_space;
	intin[2] = bg_color->rgb.reserved;
	intin[3] = bg_color->rgb.red;
	intin[4] = bg_color->rgb.green;
	intin[5] = bg_color->rgb.blue;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 205, Esc	0: Set Color Table														*/
/*																										*/
/******************************************************************************/

int16 vs_ctab( const int16 handle, COLOR_TAB *ctab )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={205, 0, 0, 6, 1, 0};
	
	/* intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	contrl[3] = (int16)(ctab->length/2);
	
	/* VDI aufrufen */
	vdi_(contrl, (int16 *)ctab, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 205, Esc	1: Set Color Table Entry												*/
/*																										*/
/******************************************************************************/

int16 vs_ctab_entry( const int16 handle, const int16 index,
				const int32 color_space, COLOR_ENTRY *color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={205, 0, 0, 7, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	intin[0] = index;
	*(int32 *)&intin[1] = color_space;
	intin[3] = color->rgb.reserved;
	intin[4] = color->rgb.red;
	intin[5] = color->rgb.green;
	intin[6] = color->rgb.blue;

	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 205, Esc	2: Set Default Color Table												*/
/*																										*/
/******************************************************************************/

int16 vs_dflt_ctab( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={205, 0, 0, 0, 1, 2};
	
	/* intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 207, Esc	0: Set Hilight Color														*/
/*																										*/
/******************************************************************************/

int16 vs_hilite_color( const int16 handle, const int32 color_space,
				const COLOR_ENTRY *hilite_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={207, 0, 0, 6, 1, 0};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	*(int32 *)&intin[0] = color_space;
	intin[2] = hilite_color->rgb.reserved;
	intin[3] = hilite_color->rgb.red;
	intin[4] = hilite_color->rgb.green;
	intin[5] = hilite_color->rgb.blue;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 207, Esc	1: Set Minimum Color														*/
/*																										*/
/******************************************************************************/

int16 vs_min_color( const int16 handle, const int32 color_space,
				const COLOR_ENTRY *min_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={207, 0, 0, 6, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	*(int32 *)&intin[0] = color_space;
	intin[2] = min_color->rgb.reserved;
	intin[3] = min_color->rgb.red;
	intin[4] = min_color->rgb.green;
	intin[5] = min_color->rgb.blue;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 207, Esc	2: Set Maximum Color														*/
/*																										*/
/******************************************************************************/

int16 vs_max_color( const int16 handle, const int32 color_space,
				const COLOR_ENTRY *max_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={207, 0, 0, 6, 1, 2};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	*(int32 *)&intin[0] = color_space;
	intin[2] = max_color->rgb.reserved;
	intin[3] = max_color->rgb.red;
	intin[4] = max_color->rgb.green;
	intin[5] = max_color->rgb.blue;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 207, Esc	3: Set Weight Color														*/
/*																										*/
/******************************************************************************/

int16 vs_weight_color( const int16 handle, const int32 color_space,
				const COLOR_ENTRY *weight_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={207, 0, 0, 6, 1, 3};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	*(int32 *)&intin[0] = color_space;
	intin[2] = weight_color->rgb.reserved;
	intin[3] = weight_color->rgb.red;
	intin[4] = weight_color->rgb.green;
	intin[5] = weight_color->rgb.blue;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 230: Set Text Face by Name															*/
/*																										*/
/******************************************************************************/

int16 vst_name( const int16 handle, const int16 font_format, const char *font_name,
				char *ret_name )
{
	/* Benîtigte Prototypen */
	int32 strlen( const char *s );
	
	register int16 i;
	
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={230, 0, 0, 0, 1};
	
	/* intin und intout anlegen */
	int16 intin[256];
	int16 intout[256];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	contrl[3] = (int)strlen(font_name) + 1;
	
	/* intin fÅllen */
	intin[0] = font_format;
	for( i=0 ; i<contrl[3] ; i++ )
		intin[i+1] = font_name[i];
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die Ergebnisse liefern */
	if( ret_name!=NULL )
		for( i=1 ; i<contrl[4] ; i++ )
			ret_name[i-1] = (char)(intin[i] & 0x00FF);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 231: Set Character Width, Absolute Mode											*/
/*																										*/
/******************************************************************************/

void vst_width( const int16 handle, const int16 width, int16 *char_width,
					int16 *char_height, int16 *cell_width, int16 *cell_height )
{
	/* Benîtigte Prototypen */
	int32 strlen( const char *s );
	
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={231, 1, 2, 0, 1};
	
	/* ptsin und intout anlegen */
	int16 ptsin[256];
	int16 ptsout[256];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	ptsin[0] = width;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, ptsin, _VDIParBlk.intout, ptsout);
	
	/* Die Ergebnisse liefern */
	if( char_width!=NULL )
		*char_width = ptsout[0];
	if( char_height!=NULL )
		*char_height = ptsout[1];
	if( cell_width!=NULL )
		*cell_width = ptsout[2];
	if( cell_height!=NULL )
		*cell_height = ptsout[3];
}

/******************************************************************************/
/*																										*/
/* VDI 236: Set Character Mapping Mode														*/
/*																										*/
/******************************************************************************/

void vst_charmap( const int16 handle, const int16 mode )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={236, 0, 0, 1, 0};
	
	/* intin und intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	intin[0] = mode;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 236: Set Character Mapping Mode														*/
/*																										*/
/******************************************************************************/

int16 vst_map_mode( const int16 handle, const int16 mode )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={236, 0, 0, 2, 1};
	
	/* intin und intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	intin[0] = mode;
	intin[1] = 1;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Ggf. den Wert zurÅckgeben */
	return (contrl[4]>0 ? intout[0] : -1);
}

/******************************************************************************/
/*																										*/
/* VDI 237: Set Kerning Mode																	*/
/*																										*/
/******************************************************************************/

void vst_kern( const int16 handle, const int16 track_mode, const int16 pair_mode,
			int16 *tracks, int16 *pairs )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={237, 0, 0, 2, 2};
	
	/* intin und intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	intin[0] = track_mode;
	intin[1] = pair_mode;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Ggf. die Werte zurÅckgeben */
	if( tracks!=NULL )
		*tracks = intout[0];
	if( pairs!=NULL )
		*pairs = intout[1];
}

/******************************************************************************/
/*																										*/
/* VDI 237: Set Kerning Mode - Offset-Variante											*/
/*																										*/
/******************************************************************************/

void vst_track_offset( const int16 handle, const fix31 offset, const int16 pair_mode,
			int16 *tracks, int16 *pairs )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={237, 0, 0, 4, 2};
	
	/* intin und intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	intin[0] = 255;
	intin[1] = pair_mode;
	*(fix31 *)(&intin[2]) = offset;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Ggf. die Werte zurÅckgeben */
	if( tracks!=NULL )
		*tracks = intout[0];
	if( pairs!=NULL )
		*pairs = intout[1];
}

/******************************************************************************/
/*																										*/
/* VDI 237: Set Kerning Mode - Offset-Variante (logischerer Name)					*/
/*																										*/
/******************************************************************************/

void vst_kern_offset( const int16 handle, const fix31 offset, const int16 pair_mode,
			int16 *tracks, int16 *pairs )
{
	vst_track_offset(handle, offset, pair_mode, tracks, pairs);
}

/******************************************************************************/
/*																										*/
/* VDI 244: Set scratch buffer allocation mode											*/
/*																										*/
/******************************************************************************/

void vst_scratch( const int16 handle, const int16 mode )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={244, 0, 0, 1, 0};
	
	/* intin, ptsout und intout anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	intin[0] = mode;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 245: Set SpeedoGDOS error mode														*/
/*																										*/
/******************************************************************************/

void vst_error( const int16 handle, const int16 mode, int16 *errorcode )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={245, 0, 1, 3, 0};
	
	/* intin und intout anlegen */
	int16 intin[10], intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	intin[0] = mode;
	*(int16 **)&intin[1] = errorcode;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 246: Set Character Height by Arbitrary Points									*/
/*																										*/
/******************************************************************************/

fix31 vst_arbpt32( const int16 handle, const fix31 height, int16 *char_width,
			int16 *char_height, int16 *cell_width, int16 *cell_height )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={246, 0, 2, 2, 2};
	
	/* intin, ptsout und intout anlegen */
	int16 intin[10];
	int16 ptsout[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	*(fix31 *)&intin[0] = height;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, ptsout);
	
	/* Ggf. die Werte zurÅckgeben */
	if( char_width!=NULL )
		*char_width = ptsout[0];
	if( char_height!=NULL )
		*char_height = ptsout[1];
	if( cell_width!=NULL )
		*cell_width = ptsout[2];
	if( cell_height!=NULL )
		*cell_height = ptsout[3];
	
	return *(fix31 *)intout;
}

/******************************************************************************/
/*																										*/
/* VDI 246: Set Character Height by Arbitrary Points									*/
/*																										*/
/******************************************************************************/

int16 vst_arbpt( const int16 handle, const int16 point, int16 *char_width,
			int16 *char_height, int16 *cell_width, int16 *cell_height )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={246, 0, 2, 1, 2};
	
	/* intin, ptsout und intout anlegen */
	int16 intin[10];
	int16 ptsout[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	intin[0] = point;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, ptsout);
	
	/* Ggf. die Werte zurÅckgeben */
	if( char_width!=NULL )
		*char_width = ptsout[0];
	if( char_height!=NULL )
		*char_height = ptsout[1];
	if( cell_width!=NULL )
		*cell_width = ptsout[2];
	if( cell_height!=NULL )
		*cell_height = ptsout[3];
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 249: Save outline font cache to disk												*/
/*																										*/
/******************************************************************************/

int16 v_savecache( const int16 handle, char *filename )
{
	register int16 i, len=(int16)strlen(filename);
	register int16 *i_ptr;
	register char *c_ptr;
	
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={249, 0, 0, 3, 1};
	
	/* intin und intout anlegen */
	int16 intout[10];
	int16 *intin;
	
	/* Das Array anlegen */
	intin = malloc(len * sizeof(*intin));
	if( intin==NULL )
		return -1;
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[3] = len;
	contrl[6] = handle;
	
	/* intin fÅllen */
	for( i=0, i_ptr=intin, c_ptr=filename ; i<len ; i++, i_ptr++, c_ptr++ )
		*i_ptr = *c_ptr;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Speicher aufrÑumen */
	free(intin);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 250: Save outline font cache to disk												*/
/*																										*/
/******************************************************************************/

int16 v_loadcache( const int16 handle, const char *filename, const int16 mode )
{
	register int16 i, len=(int16)strlen(filename);
	register int16 *i_ptr;
	register const char *c_ptr;
	
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={250, 0, 0, 0, 1};
	
	/* intin und intout anlegen */
	int16 intout[10];
	int16 *intin;
	
	/* Das Array anlegen */
	intin = malloc(len * sizeof(*intin));
	if( intin==NULL )
		return -1;
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[3] = len + 1;
	contrl[6] = handle;
	
	/* intin fÅllen */
	intin[0] = mode;
	for( i=0, i_ptr=intin+1, c_ptr=filename ; i<len ; i++, i_ptr++, c_ptr++ )
		*i_ptr = *c_ptr;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Speicher aufrÑumen */
	free(intin);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 251:	Flush Outline Font Cache														*/
/*																										*/
/******************************************************************************/

int16 v_flushcache( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={251, 0, 0, 0, 1};
	
	/* intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 252:	Set Character Cell Width by Arbitrary Points								*/
/*																										*/
/******************************************************************************/

int16 vst_setsize( const int16 handle, const int16 width, int16 *char_width,
			int16 *char_height, int16 *cell_width, int16 *cell_height )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={252, 0, 1, 1, 1, 0};
	
	/* intin, intout & ptsin anlegen */
	int16 intin[10];
	int16 intout[10];
	int16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	intin[0] = width;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, ptsout);
	
	/* Ggf. die Werte zurÅckgeben */
	if( char_width!=NULL )
		*char_width = ptsout[0];
	if( char_height!=NULL )
		*char_height = ptsout[1];
	if( cell_width!=NULL )
		*cell_width = ptsout[2];
	if( cell_height!=NULL )
		*cell_height = ptsout[3];
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 252:	Set Character Cell Width by Arbitrary Points								*/
/*																										*/
/******************************************************************************/

fix31 vst_setsize32( const int16 handle, const fix31 width, int16 *char_width,
			int16 *char_height, int16 *cell_width, int16 *cell_height )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={252, 0, 2, 2, 2, 0};
	
	/* intin, intout & ptsin anlegen */
	int16 intin[10];
	int16 intout[10];
	int16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	*(fix31 *)intin = width;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, ptsout);
	
	/* Ggf. die Werte zurÅckgeben */
	if( char_width!=NULL )
		*char_width = ptsout[0];
	if( char_height!=NULL )
		*char_height = ptsout[1];
	if( cell_width!=NULL )
		*cell_width = ptsout[2];
	if( cell_height!=NULL )
		*cell_height = ptsout[3];
	
	return *(fix31 *)intout;
}

/******************************************************************************/
/*																										*/
/* VDI 253:	Set Outline Font Skew															*/
/*																										*/
/******************************************************************************/

int16 vst_skew( const int16 handle, const int16 skew )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={253, 0, 0, 1, 1, 0};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	intin[0] = skew;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Ggf. die Werte zurÅckgeben */
	return intout[0];
}

