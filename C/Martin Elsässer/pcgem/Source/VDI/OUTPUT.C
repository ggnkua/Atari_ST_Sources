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

void v_pline( const INT16 handle, const INT16 count, INT16 *pxyarray )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={6, 0, 0, 0, 0};
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* Anzahl der Punktepaare eintragen */
	contrl[1]=count;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI   7: Polymarker																			*/
/*																										*/
/******************************************************************************/

void v_pmarker( const INT16 handle, const INT16 count, INT16 *pxyarray )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={7, 0, 0, 0, 0};
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* Anzahl der Punktepaare eintragen */
	contrl[1]=count;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI   8: Text																					*/
/*																										*/
/******************************************************************************/

void v_gtext( const INT16 handle, const INT16 x, const INT16 y, const char *string )
{
	/* Benîtigte Prototypen */
	INT32 strlen( const char *s );
	
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={8, 1, 0, 0, 0};
	
	/* ptsin anlegen */
	INT16 ptsin[10];
	
	/* intin anlegen */
	INT16 *intin=NULL;
	register INT16 i, *i_ptr=NULL;
	register char *c_ptr=NULL;
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* Anzahl der Zeichen eintragen */
	contrl[3]=(INT16)strlen(string);
	
	intin=(INT16 *)malloc(((contrl[3]>10 ? contrl[3] : 10)+1)*sizeof(*intin));
	if( intin==NULL )
		return;
	
	for( i=0, c_ptr=(char *)string, i_ptr=intin ; i<=contrl[3] ; c_ptr++, i_ptr++, i++ )
		*i_ptr=(*c_ptr) & 0x00FF;
	
	/* ptsin fÅllen */
	ptsin[0]=x;
	ptsin[1]=y;
	
	/* VDI aufrufen */
	vdi(contrl, intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
	
	/* Das Array wieder freigeben */
	free(intin);
}

/******************************************************************************/
/*																										*/
/* VDI   9: Filled Area																			*/
/*																										*/
/******************************************************************************/

void v_fillarea( const INT16 handle, const INT16 count, INT16 *pxyarray )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={9, 0, 0, 0, 0};
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* Anzahl der Punktepaare eintragen */
	contrl[1]=count;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI  10: Cell Array																			*/
/*																										*/
/******************************************************************************/

void v_cellarray( const INT16 handle, INT16 *pxyarray, const INT16 row_length,
			const INT16 el_used, const INT16 num_rows, const INT16 wrt_mode,
			const INT16 *colarray )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={10, 2, 0, 0, 0};
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* Die Parameter eintragen */
	contrl[7]=row_length;
	contrl[8]=el_used;
	contrl[9]=num_rows;
	contrl[10]=wrt_mode;
	
	/* VDI aufrufen */
	vdi(contrl, (INT16 *)colarray, (INT16 *)pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 103: Contour Fill																		*/
/*																										*/
/******************************************************************************/

void v_contourfill( const INT16 handle, const INT16 x, const INT16 y, const INT16 index )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={103, 1, 0, 1, 0};
	
	/* intin anlegen und fÅllen */
	INT16 intin=(INT16)index;
	
	/* ptsin anlegen und fÅllen */
	INT16 ptsin[10];
	ptsin[0]=(INT16)x;
	ptsin[1]=(INT16)y;
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, &intin, (INT16 *)ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 114: Fill Rectangle																		*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

void vr_recfl( const INT16 handle, const Axywh *rect )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={114, 2, 0, 0, 0};
	
	/* ptsin anlegen */
	INT16 ptsin[10];
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	ptsin[0]=rect->x;
	ptsin[1]=rect->y;
	ptsin[2]=rect->x+rect->w;
	ptsin[3]=rect->y+rect->h;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	void vr_recfl( const INT16 handle, const INT16 *pxyarray )
#else
	void vr_recfl_( const INT16 handle, const INT16 *pxyarray )
#endif
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={114, 2, 0, 0, 0};
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, (INT16 *)pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 11: Generalized Drawing primitive (GDP)											*/
/*																										*/
/******************************************************************************/

/******************************************************************************/
/*																										*/
/* VDI 11, GDP 1: Bar																				*/
/*																										*/
/******************************************************************************/

void v_bar( const INT16 handle, INT16 *pxyarray )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={11, 2, 0, 0, 0, 1};
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 11, GDP 2: Arc																				*/
/*																										*/
/******************************************************************************/

void v_arc( const INT16 handle, const INT16 x, const INT16 y,
		const INT16 radius, const INT16 beg_ang, const INT16 end_ang )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={11, 4, 0, 2, 0, 2};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* ptsin anlegen */
	INT16 ptsin[10]={0, 0, 0, 0, 0, 0, 0};
	
	/* Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=beg_ang;
	intin[1]=end_ang;
	
	ptsin[0]=x;
	ptsin[1]=y;
	ptsin[6]=radius;
	
	/* VDI aufrufen */
	vdi(contrl, intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 11, GDP 3: PieSlice																		*/
/*																										*/
/******************************************************************************/

void v_pieslice( const INT16 handle, const INT16 x, const INT16 y,
		const INT16 radius, const INT16 beg_ang, const INT16 end_ang )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={11, 4, 0, 2, 0, 3};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* ptsin anlegen */
	INT16 ptsin[10]={0, 0, 0, 0, 0, 0, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=beg_ang;
	intin[1]=end_ang;
	
	ptsin[0]=x;
	ptsin[1]=y;
	ptsin[6]=radius;

	/* VDI aufrufen */
	vdi(contrl, intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 11, GDP 4: Circle																			*/
/*																										*/
/******************************************************************************/

void v_circle( const INT16 handle, const INT16 x, const INT16 y, const INT16 radius )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={11, 3, 0, 0, 0, 4};
	
	/* ptsin anlegen */
	INT16 ptsin[10]={0, 0, 0, 0, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=x;
	ptsin[1]=y;
	ptsin[2]=0;
	ptsin[3]=0;
	ptsin[4]=radius;
	ptsin[5]=0;

	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 11, GDP 5: Ellipse																		*/
/*																										*/
/******************************************************************************/

void v_ellipse( const INT16 handle, const INT16 x, const INT16 y,
		const INT16 xradius, const INT16 yradius )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={11, 2, 0, 0, 0, 5};
	
	/* ptsin anlegen */
	INT16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=x;
	ptsin[1]=y;
	ptsin[2]=xradius;
	ptsin[3]=yradius;

	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsin);
}

/******************************************************************************/
/*																										*/
/* VDI 11, GDP 6: Elliptical Arc																*/
/*																										*/
/******************************************************************************/

void v_ellarc( const INT16 handle, const INT16 x, const INT16 y,
		const INT16 xradius, const INT16 yradius, const INT16 beg_ang, const INT16 end_ang )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={11, 2, 0, 2, 0, 6};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* ptsin anlegen */
	INT16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=beg_ang;
	intin[1]=end_ang;
	
	ptsin[0]=x;
	ptsin[1]=y;
	ptsin[2]=xradius;
	ptsin[3]=yradius;

	/* VDI aufrufen */
	vdi(contrl, intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 11, GDP 7: Elliptical Pie																*/
/*																										*/
/******************************************************************************/

void v_ellpie( const INT16 handle, const INT16 x, const INT16 y,
		const INT16 xradius, const INT16 yradius, const INT16 beg_ang, const INT16 end_ang )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={11, 2, 0, 2, 0, 7};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* ptsin anlegen */
	INT16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=beg_ang;
	intin[1]=end_ang;
	
	ptsin[0]=x;
	ptsin[1]=y;
	ptsin[2]=xradius;
	ptsin[3]=yradius;

	/* VDI aufrufen */
	vdi(contrl, intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 11, GDP 8: Rounded Rectangle															*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

void v_rbox( const INT16 handle, const Axywh *rectangle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={11, 2, 0, 0, 0, 8};
	
	/* ptsin anlegen */
	INT16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=rectangle->x;
	ptsin[1]=rectangle->y;
	ptsin[2]=rectangle->x+rectangle->w;
	ptsin[3]=rectangle->y+rectangle->h;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	void v_rbox( const INT16 handle, const INT16 *pxyarray )
#else
	void v_rbox_( const INT16 handle, const INT16 *pxyarray )
#endif
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={11, 2, 0, 0, 0, 8};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, (INT16 *)pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 11, GDP 9: Filled rounded Rectangle												*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

void v_rfbox( const INT16 handle, const Axywh *rectangle )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={11, 2, 0, 0, 0, 9};
	
	/* ptsin anlegen */
	INT16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	ptsin[0]=ptsin[2]=rectangle->x;
	ptsin[1]=ptsin[3]=rectangle->y;
	ptsin[2]+=rectangle->w;
	ptsin[3]+=rectangle->h;;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	void v_rfbox( const INT16 handle, const INT16 *pxyarray )
#else
	void v_rfbox_( const INT16 handle, const INT16 *pxyarray )
#endif
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={11, 2, 0, 0, 0, 9};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, (INT16 *)pxyarray, _VDIParBlk.intout, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 11, GDP 10: Justified graphics Text												*/
/*																										*/
/******************************************************************************/

void v_justified( const INT16 handle, const INT16 x, const INT16 y, char *string,
		const INT16 length, const INT16 word_space, const INT16 char_space )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={11, 2, 0, 0, 0, 10};
	
	/* ptsin anlegen */
	INT16 ptsin[10];
	
	/* intin anlegen */
	INT16 *intin;
	register INT16 i, *i_ptr;
	register char *c_ptr;
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[3]=(INT16)strlen(string)+2;
	
	/* Speicher fÅr intin allozieren */
	intin=(INT16 *)malloc((contrl[3]+1)*sizeof(*intin));
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
	vdi(contrl, intin, ptsin, _VDIParBlk.intout, _VDIParBlk.ptsout);
	
	/* Den Speicher freigeben */
	free(intin);
}
