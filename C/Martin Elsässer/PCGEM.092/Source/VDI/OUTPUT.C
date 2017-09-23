/******************************************************************************/
/*																										*/
/*     Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C       */
/*																										*/
/* Die (N)VDI-Funktionen - Ausgabe-Funktionen											*/
/*																										*/
/*	(c) 1999 by Martin ElsÑsser																*/
/******************************************************************************/

#include <ACSVDI.H>

/******************************************************************************/
/*																										*/
/* VDI   6: Polyline																				*/
/*																										*/
/******************************************************************************/

void v_pline( const int16 handle, const int16 count, int16 *pxyarray )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={6, 0, 0, 0, 0, 0};
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* Anzahl der Punktepaare eintragen */
	contrl[1]=count;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI   6, Esc	13: Output Bezier															*/
/*																										*/
/******************************************************************************/

void v_bez( const int16 handle, const int16 count, int16 *pxyarray, char *bezarray,
			int16 *extent, int16 *totpts, int16 *totmoves )
{
	register int16 i;
	register char *c_intin;
	
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={6, 0, 2, 0, 6, 13};
	
	/* intin anlegen */
	int16 *intin;
	
	/* intout und ptsout anlegen */
	int16 intout[10];
	int16 ptsout[10];
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* Die Daten eintragen */
	intin = malloc(((count + 1) >> 1) + 1);
	if( intin==NULL )
		return;
	
	/* Die Bezier-Infos Åbertragen */
	for( i=0, c_intin=(char *)intin ; i<count ; i++, c_intin++ )
		if( i & 0x0001 )
			c_intin[i-1] = bezarray[i];
		else
			c_intin[i+1] = bezarray[i];
	
	/* Anzahl der Punktepaare eintragen */
	contrl[1]=count;
	contrl[3]=(count+1)>>1;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, pxyarray, intout, ptsout);
	
	/* Speicher wieder freigeben */
	free(intin);
	
	/* Die RÅckgabewerte zusammenstellen */
	if( totpts!=NULL )
		*totpts = intout[0];
	if( totmoves!=NULL )
		*totmoves = intout[1];
	if( extent!=NULL )
	{
		extent[0] = ptsout[0];
		extent[1] = ptsout[1];
		extent[2] = ptsout[2];
		extent[3] = ptsout[3];
	}
}

/******************************************************************************/
/*																										*/
/* VDI   7: Polymarker																			*/
/*																										*/
/******************************************************************************/

void v_pmarker( const int16 handle, const int16 count, int16 *pxyarray )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={7, 0, 0, 0, 0, 0};
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* Anzahl der Punktepaare eintragen */
	contrl[1]=count;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI   8: Text																					*/
/*																										*/
/******************************************************************************/

void v_gtext( const int16 handle, const int16 x, const int16 y, const char *string )
{
	/* Benîtigte Prototypen */
	int32 strlen( const char *s );
	
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={8, 1, 0, 0, 0};
	
	/* ptsin anlegen */
	int16 ptsin[10];
	
	/* intin anlegen */
	int16 *intin=NULL;
	register int16 i, *i_ptr=NULL;
	register char *c_ptr=NULL;
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* Anzahl der Zeichen eintragen */
	contrl[3]=(int16)strlen(string);
	
	intin=(int16 *)malloc(((contrl[3]>10 ? contrl[3] : 10)+1)*sizeof(*intin));
	if( intin==NULL )
		return;
	
	for( i=0, c_ptr=(char *)string, i_ptr=intin ; i<=contrl[3] ; c_ptr++, i_ptr++, i++ )
		*i_ptr=(*c_ptr) & 0x00FF;
	
	/* ptsin fÅllen */
	ptsin[0]=x;
	ptsin[1]=y;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
	
	/* Das Array wieder freigeben */
	free(intin);
}

/******************************************************************************/
/*																										*/
/* VDI   9: Filled Area																			*/
/*																										*/
/******************************************************************************/

void v_fillarea( const int16 handle, const int16 count, int16 *pxyarray )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={9, 0, 0, 0, 0};
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* Anzahl der Punktepaare eintragen */
	contrl[1]=count;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI   9,	Esc	13: Filled Bezier															*/
/*																										*/
/******************************************************************************/

void v_bez_fill( const int16 handle, const int16 count, int16 *pxyarray, uint8 *bezarray,
			int16 *extent, int16 *totpts, int16 *totmoves )
{
	register int16 i;
	register char *c_intin;
	
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={9, 0, 2, 0, 6, 13};
	
	/* intin anlegen */
	int16 *intin;
	
	/* intout und ptsout anlegen */
	int16 intout[10];
	int16 ptsout[10];
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* Die Daten eintragen */
	intin = malloc(((count + 1) >> 1) + 1);
	if( intin==NULL )
		return;
	
	/* Die Bezier-Infos Åbertragen */
	for( i=0, c_intin=(char *)intin ; i<count ; i++, c_intin++ )
		if( i & 0x0001 )
			c_intin[i-1] = bezarray[i];
		else
			c_intin[i+1] = bezarray[i];
	
	/* Anzahl der Punktepaare eintragen */
	contrl[1]=count;
	contrl[3]=(count+1)>>1;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, pxyarray, intout, ptsout);
	
	/* Speicher wieder freigeben */
	free(intin);
	
	/* Die RÅckgabewerte zusammenstellen */
	if( totpts!=NULL )
		*totpts = intout[0];
	if( totmoves!=NULL )
		*totmoves = intout[1];
	if( extent!=NULL )
	{
		extent[0] = ptsout[0];
		extent[1] = ptsout[1];
		extent[2] = ptsout[2];
		extent[3] = ptsout[3];
	}
}

/******************************************************************************/
/*																										*/
/* VDI  10: Cell Array																			*/
/*																										*/
/******************************************************************************/

void v_cellarray( const int16 handle, int16 *pxyarray, const int16 row_length,
			const int16 el_used, const int16 num_rows, const int16 wrt_mode,
			const int16 *colarray )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={10, 2, 0, 0, 0};
	
	/* VDI-Handle eintragen */
	contrl[6] = handle;
	
	/* Die Parameter eintragen */
	contrl[3]  = row_length * num_rows;
	contrl[7]  = row_length;
	contrl[8]  = el_used;
	contrl[9]  = num_rows;
	contrl[10] = wrt_mode;
	
	/* VDI aufrufen */
	vdi_(contrl, (int16 *)colarray, (int16 *)pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 103: Contour Fill																		*/
/*																										*/
/******************************************************************************/

void v_contourfill( const int16 handle, const int16 x, const int16 y, const int16 index )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={103, 1, 0, 1, 0};
	
	/* intin anlegen und fÅllen */
	int16 intin=(int16)index;
	
	/* ptsin anlegen und fÅllen */
	int16 ptsin[10];
	ptsin[0]=(int16)x;
	ptsin[1]=(int16)y;
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, &intin, (int16 *)ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 114: Fill Rectangle																		*/
/*																										*/
/******************************************************************************/

void vr_recfl( const int16 handle, const int16 *pxyarray )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={114, 2, 0, 0, 0};
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, (int16 *)pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 11: Generalized Drawing primitive (GDP)											*/
/*																										*/
/******************************************************************************/

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* VDI 11, GDP 1: Bar																			*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_bar( const int16 handle, int16 *pxyarray )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={11, 2, 0, 0, 0, 1};
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* VDI 11, GDP 2: Arc																			*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_arc( const int16 handle, const int16 x, const int16 y,
		const int16 radius, const int16 beg_ang, const int16 end_ang )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={11, 4, 0, 2, 0, 2};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* ptsin anlegen */
	int16 ptsin[10]={0, 0, 0, 0, 0, 0, 0, 0};
	
	/* Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=beg_ang;
	intin[1]=end_ang;
	
	ptsin[0]=x;
	ptsin[1]=y;
	ptsin[6]=radius;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* VDI 11, GDP 3: PieSlice																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_pieslice( const int16 handle, const int16 x, const int16 y,
		const int16 radius, const int16 beg_ang, const int16 end_ang )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={11, 4, 0, 2, 0, 3};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* ptsin anlegen */
	int16 ptsin[10]={0, 0, 0, 0, 0, 0, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=beg_ang;
	intin[1]=end_ang;
	
	ptsin[0]=x;
	ptsin[1]=y;
	ptsin[6]=radius;

	/* VDI aufrufen */
	vdi_(contrl, intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* VDI 11, GDP 4: Circle																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_circle( const int16 handle, const int16 x, const int16 y, const int16 radius )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12] = {11, 3, 0, 0, 0, 4};
	
	/* ptsin anlegen */
	int16 ptsin[10] = {0, 0, 0, 0, 0, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	ptsin[0] = x;
	ptsin[1] = y;
	ptsin[4] = radius;

	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* VDI 11, GDP 5: Ellipse																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_ellipse( const int16 handle, const int16 x, const int16 y,
		const int16 xradius, const int16 yradius )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={11, 2, 0, 0, 0, 5};
	
	/* ptsin anlegen */
	int16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=x;
	ptsin[1]=y;
	ptsin[2]=xradius;
	ptsin[3]=yradius;

	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsin);
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* VDI 11, GDP 6: Elliptical Arc																*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_ellarc( const int16 handle, const int16 x, const int16 y,
		const int16 xradius, const int16 yradius, const int16 beg_ang, const int16 end_ang )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={11, 2, 0, 2, 0, 6};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* ptsin anlegen */
	int16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=beg_ang;
	intin[1]=end_ang;
	
	ptsin[0]=x;
	ptsin[1]=y;
	ptsin[2]=xradius;
	ptsin[3]=yradius;

	/* VDI aufrufen */
	vdi_(contrl, intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* VDI 11, GDP 7: Elliptical Pie																*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_ellpie( const int16 handle, const int16 x, const int16 y,
		const int16 xradius, const int16 yradius, const int16 beg_ang, const int16 end_ang )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={11, 2, 0, 2, 0, 7};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* ptsin anlegen */
	int16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=beg_ang;
	intin[1]=end_ang;
	
	ptsin[0]=x;
	ptsin[1]=y;
	ptsin[2]=xradius;
	ptsin[3]=yradius;

	/* VDI aufrufen */
	vdi_(contrl, intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* VDI 11, GDP 8: Rounded Rectangle															*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_rbox( const int16 handle, const int16 *pxyarray )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={11, 2, 0, 0, 0, 8};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, (int16 *)pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* VDI 11, GDP 9: Filled rounded Rectangle												*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_rfbox( const int16 handle, const int16 *pxyarray )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={11, 2, 0, 0, 0, 9};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, (int16 *)pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* VDI 11, GDP 10: Justified graphics Text												*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_justified( const int16 handle, const int16 x, const int16 y, char *string,
		const int16 length, const int16 word_space, const int16 char_space )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={11, 2, 0, 0, 0, 10};
	
	/* ptsin anlegen */
	int16 ptsin[10];
	
	/* intin anlegen */
	int16 *intin;
	register int16 i, *i_ptr;
	register char *c_ptr;
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[3]=(int16)strlen(string)+2;
	
	/* Speicher fÅr intin allozieren */
	intin=(int16 *)malloc((contrl[3]+1)*sizeof(*intin));
	if( intin==NULL )
		return;
	
	ptsin[0]=x;
	ptsin[1]=y;
	ptsin[2]=length;
	ptsin[3]=0;
	
	intin[0]=word_space;
	intin[1]=char_space;
	
	for( i=2, c_ptr=(char *)string, i_ptr=&intin[2] ; i<=contrl[3] ; i++, c_ptr++, i_ptr++ )
		*i_ptr=(*c_ptr) & 0x00FF;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
	
	/* Den Speicher freigeben */
	free(intin);
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* VDI 11, GDP 13: Enable Bezier Capabilities											*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

int16 v_bez_on( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={11, 1, 0, 0, 1, 13};
	
	/* intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intout[0] = 0;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* VDI 11, GDP 13: Disable Bezier Capabilities											*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_bez_off( const int16 handle )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={11, 0, 0, 0, 1, 13};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* VDI 5, GDP 99: Set Bezier Quality														*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_bez_qual( const int16 handle, const int16 qual, int16 *set_qual )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={5, 0, 0, 3, 1, 99};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0] = 32;
	intin[1] = 1;
	intin[2] = qual;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	if( set_qual!=NULL )
		*set_qual = intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 241: Outline Font Text																	*/
/*																										*/
/******************************************************************************/

void v_ftext( const int16 handle, const int16 x, const int16 y, const char *string )
{
	/* Benîtigte Prototypen */
	int32 strlen( const char *s );
	
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={241, 1, 0, 0, 0};
	
	/* ptsin anlegen */
	int16 ptsin[10];
	
	/* Variablen zum BefÅllen des Arrays intin */
	register int16 i, *i_ptr=NULL;
	register char *c_ptr=NULL;
	
	/* intin anlegen und allozieren */
	int16 *intin=NULL;
	
	contrl[3]=(int16)strlen(string);
	intin=(int16 *)malloc(((contrl[3]>10 ? contrl[3] : 10)+1)*sizeof(*intin));
	if( intin==NULL )
		return;
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	for( i=0, c_ptr=(char *)string, i_ptr=intin ; i<=contrl[3] ; c_ptr++, i_ptr++, i++ )
		*i_ptr=(*c_ptr) & 0x00FF;
	
	/* ptsin fÅllen */
	ptsin[0]=x;
	ptsin[1]=y;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
	
	/* Das Array wieder freigeben */
	free(intin);
}

/******************************************************************************/
/*																										*/
/* VDI 241: Outline Font Text - Variante mit eigenen Offsets						*/
/*																										*/
/******************************************************************************/

void v_ftext_offset( const int16 handle, const int16 x, const int16 y,
			const char *string, const int16 *offsets )
{
	/* Benîtigte Prototypen */
	int32 strlen( const char *s );
	
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={241, 1, 0, 0, 0};
	
	/* Variablen zum BefÅllen des Arrays intin */
	register int16 i, *i_ptr=NULL;
	register char *c_ptr=NULL;
	
	/* intin & ptsin anlegen */
	int16 *intin=NULL;
	int16 *ptsin=NULL;
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* Anzahl der Zeichen eintragen */
	contrl[3] = (int16)strlen(string);
	contrl[1] = contrl[3] + 1;
	
	/* intin allozieren und fÅllen */
	intin=(int16 *)malloc(((contrl[3]>10 ? contrl[3] : 10)+1)*sizeof(*intin));
	if( intin==NULL )
		return;
	for( i=0, c_ptr=(char *)string, i_ptr=intin ; i<=contrl[3] ; c_ptr++, i_ptr++, i++ )
		*i_ptr=(*c_ptr) & 0x00FF;
	
	/* ptsin allozieren und fÅllen */
	ptsin=(int16 *)malloc(2*((contrl[1]>10 ? contrl[1] : 10)+1)*sizeof(*ptsin));
	if( ptsin==NULL )
	{
		free(intin);
		return;
	}
	ptsin[0] = x;
	ptsin[1] = y;
	for( i=0 ; i<2*contrl[1] ; i++ )
		ptsin[i+2] = offsets[i];
	
	/* VDI aufrufen */
	vdi_(contrl, intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
	
	/* Die Arrays wieder freigeben */
	free(ptsin);
	free(intin);
}
