/******************************************************************************/
/*																										*/
/*     Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C       */
/*																										*/
/* Die (N)VDI-Funktionen - Auskunfts-Funktionen											*/
/*																										*/
/*	(c) 1999 by Martin ElsÑsser																*/
/******************************************************************************/

#include <ACSVDI.H>

/******************************************************************************/
/*																										*/
/* VDI 102:	Extended Inquire Function														*/
/*																										*/
/******************************************************************************/

void vq_extnd( const INT16 handle, const INT16 owflag, INT16 *workout )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={102, 0, 6, 1, 45};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=owflag;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, workout, &(workout[45]));
}

/******************************************************************************/
/*																										*/
/* VDI  26:	Inquire Color Representation													*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

INT16 vq_color( const INT16 handle, const INT16 color, const INT16 set_flag, RGB *rgb )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={26, 0, 0, 2, 4};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=color;
	intin[1]=set_flag;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	rgb->red=intout[1];
	rgb->green=intout[2];
	rgb->blue=intout[3];
	
	return intout[0];
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	INT16 vq_color( const INT16 handle, const INT16 color, const INT16 set_flag, INT16 *rgb )
#else
	INT16 vq_color_( const INT16 handle, const INT16 color, const INT16 set_flag, INT16 *rgb )
#endif
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={26, 0, 0, 2, 4};
	
	/* intin & intout anlegen */
	INT16 intin[2];
	INT16 intout[4];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=color;
	intin[1]=set_flag;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	rgb[0]=intout[1];
	rgb[1]=intout[2];
	rgb[2]=intout[3];
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  35:	Inquire Current Polyline Attributes											*/
/*																										*/
/******************************************************************************/

void vql_attributes( const INT16 handle, INT16 *attrib )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={35, 0, 1, 0, 3};
	INT16 i;
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, attrib, &attrib[5]);
	
	/* Die evtl. nicht gelieferten Daten initialisieren */
	for( i=contrl[4] ; i<5 ; i++ )
		attrib[i]=0;
}

/******************************************************************************/
/*																										*/
/* VDI  36:	Inquire Current Polymarker Attributes										*/
/*																										*/
/******************************************************************************/

void vqm_attributes( const INT16 handle, INT16 *attrib )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={36, 0, 1, 0, 3};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, attrib, &attrib[3]);
}

/******************************************************************************/
/*																										*/
/* VDI  37:	Inquire Current Fill Area Attributes										*/
/*																										*/
/******************************************************************************/

void vqf_attributes( const INT16 handle, INT16 *attrib )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={37, 0, 0, 0, 5};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, attrib, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI  38:	Inquire Current Graphic Text Attributes									*/
/*																										*/
/******************************************************************************/

void vqt_attributes( const INT16 handle, INT16 *attrib )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={38, 0, 2, 0, 6};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, attrib, &attrib[6]);
}

/******************************************************************************/
/*																										*/
/* VDI 116:	Inquire Text Extent																*/
/*																										*/
/******************************************************************************/

void vqt_extent( const INT16 handle, const char *string, INT16 *extent )
{
	/* Benîtigte Prototypen */
	INT32 strlen( const char *s );
	
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={116, 0, 4, 0, 0};
	
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
	
	for( i=0, i_ptr=intin, c_ptr=(char *)string ; i<=contrl[3] ; i_ptr++, c_ptr++, i++ )
		*i_ptr=*c_ptr;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, extent);
	
	/* Das Array freigeben */
	free(intin);
}

/******************************************************************************/
/*																										*/
/* VDI 117:	Inquire Character Cell Width													*/
/*																										*/
/******************************************************************************/

INT16 vqt_width( const INT16 handle, const INT16 character, INT16 *cell_width,
			INT16 *left_delta, INT16 *right_delta )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={117, 0, 3, 1, 1};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[10];
	
	/* ptsout anlegen */
	INT16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=character;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, ptsout);
	
	/* Die Werte zurÅckgeben */
	if( cell_width!=NULL )
		*cell_width=ptsout[0];
	if( left_delta!=NULL )
		*left_delta=ptsout[2];
	if( right_delta!=NULL )
		*right_delta=ptsout[4];
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 130:	Inquire Face Name And Index													*/
/*																										*/
/******************************************************************************/

INT16 vqt_name( const INT16 handle, const INT16 element_num, char *name )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={130, 0, 0, 1, 33};
	
	/* intin & intout anlegen */
	INT16 intin[10];
	INT16 intout[34];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=element_num;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die Werte zurÅckgeben */
	if( name!=NULL )
	{
		register INT16 *i_ptr;
		register char *c_ptr;
		register INT16 i;
		
		for( i=0, i_ptr=&intout[1], c_ptr=name ; i<33 && *i_ptr!=0 ; i_ptr++, c_ptr++ )
			*c_ptr=(char)*i_ptr;
		*c_ptr='\0';
	}
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  27:	Inquire Cell Array																*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

void vq_cellarray( const INT16 handle, const Axywh *xywh, const INT16 row_length,
			const INT16 num_rows, INT16 *el_used, INT16 *rows_used, INT16 *status,
			INT16 *colarray )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={27, 2, 0, 0, 0};
	
	/* ptsin anlegen */
	INT16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[7]=row_length;
	contrl[8]=num_rows;
	
	ptsin[0]=xywh->x;
	ptsin[1]=xywh->y;
	ptsin[2]=xywh->x+xywh->w;
	ptsin[3]=xywh->x+xywh->h;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, ptsin, colarray, _VDIParBlk.ptsout);
	
	/* Die Daten zurÅckgeben */
	if( el_used!=NULL )
		*el_used=contrl[9];
	if( rows_used!=NULL )
		*rows_used=contrl[10];
	if( status!=NULL )
		*status=contrl[11];
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	void vq_cellarray( const INT16 handle, const INT16 *pxyarray, const INT16 row_length,
					const INT16 num_rows, INT16 *el_used, INT16 *rows_used, INT16 *status,
					INT16 *colarray )
#else
	void vq_cellarray_( const INT16 handle, const INT16 *pxyarray, const INT16 row_length,
					const INT16 num_rows, INT16 *el_used, INT16 *rows_used, INT16 *status,
					INT16 *colarray )
#endif
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={27, 2, 0, 0, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[7]=row_length;
	contrl[8]=num_rows;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, (INT16 *)pxyarray, colarray, _VDIParBlk.ptsout);
	
	/* Die Daten zurÅckgeben */
	if( el_used!=NULL )
		*el_used=contrl[9];
	if( rows_used!=NULL )
		*rows_used=contrl[10];
	if( status!=NULL )
		*status=contrl[11];
}

/******************************************************************************/
/*																										*/
/* VDI 115:	Inquire Input Mode																*/
/*																										*/
/******************************************************************************/

void vqin_mode( const INT16 handle, const INT16 dev_type, INT16 *input_mode )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={115, 0, 0, 1, 1};
	
	/* intin anlegen */
	INT16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=dev_type;
	
	/* VDI aufrufen */
	vdi(contrl, intin, _VDIParBlk.ptsin, input_mode, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 131:	Inquire Current Face Information												*/
/*																										*/
/******************************************************************************/

void vqt_fontinfo( const INT16 handle, INT16 *minADE, INT16 *maxADE, INT16 *distances,
			INT16 *maxwidth, INT16 *effects )
{
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={131, 0, 5, 0, 2};
	
	/* intout & ptsout anlegen */
	INT16 intout[10];
	INT16 ptsout[15];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, ptsout);
	
	/* Die Daten zurÅckgeben */
	if( minADE!=NULL )
		*minADE=intout[0];
	if( maxADE!=NULL )
		*maxADE=intout[1];
	if( maxwidth!=NULL )
		*maxwidth=ptsout[0];
	if( distances!=NULL )
	{
		distances[0]=ptsout[1];
		distances[1]=ptsout[3];
		distances[2]=ptsout[5];
		distances[3]=ptsout[7];
		distances[4]=ptsout[9];
	}
	if( effects!=NULL )
	{
		effects[0]=ptsout[2];
		effects[1]=ptsout[4];
		effects[2]=ptsout[6];
	}
}

/******************************************************************************/
/*																										*/
/* VDI 132:	Inquire Justified Graphics Text												*/
/*																										*/
/******************************************************************************/

/* Die Funktion ist nur fÅr PC-GEM ab Version 2.0 definiert! */
#if 0

void vqt_justified( const INT16 handle, const INT16 x, const INT16 y, const char *string,
			const INT16 length, const INT16 word_space, const INT16 char_space, INT16 *offsets )
{
	/* Benîtigte Prototypen */
	INT32 strlen( const char *s );
	
	/* contrl anlegen und fÅllen */
	INT16 contrl[12]={132, 3, 0, 2, 0};
	
	/* intin & ptsout anlegen */
	INT16 *intin;
	INT16 i, *i_ptr;
	char *c_ptr;
	
	/* ptsin anlegen */
	INT16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[2]=(INT16)strlen(string);
	contrl[3]=contrl[2]+2;
	
	ptsin[0]=x;
	ptsin[1]=y;
	ptsin[2]=length;
	ptsin[3]=0;
	
	intin=(INT16 *)malloc((contrl[3]+1)*sizeof(*intin));
	if( intin==NULL )
		return;
	
	intin[0]=word_space;
	intin[1]=char_space;
	for( i=0, i_ptr=intin, c_ptr=(char *)string ; i<=contrl[3] ; i++, i_ptr++, c_ptr++ )
		*i_ptr=*c_ptr;
	
	/* VDI aufrufen */
	vdi(contrl, intin, ptsin, _VDIParBlk.intout, offsets);
	
	/* intin wieder freigeben */
	free(intin);
}

#endif
