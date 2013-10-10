/******************************************************************************/
/*																										*/
/*     Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C       */
/*																										*/
/* Die (N)VDI-Funktionen - Auskunfts-Funktionen											*/
/*																										*/
/*	(c) 1999 by Martin ElsÑsser																*/
/******************************************************************************/

#include <string.h>
#include <ACSVDI.H>

/******************************************************************************/
/*																										*/
/* VDI 102:	Extended Inquire Function														*/
/*																										*/
/******************************************************************************/

void vq_extnd( const int16 handle, const int16 owflag, int16 *workout )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={102, 0, 6, 1, 45};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=owflag;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, workout, &(workout[45]));
}

/******************************************************************************/
/*																										*/
/* VDI 102,	Esc	1:	Inquire Screen Information											*/
/*																										*/
/******************************************************************************/

void vq_scrninfo( const int16 handle, int16 *work_out )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={102, 0, 0, 1, 272, 1};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	intin[0] = 2;
   
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, work_out, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI  26:	Inquire Color Representation													*/
/*																										*/
/******************************************************************************/

int16 vq_color( const int16 handle, const int16 color, const int16 set_flag, int16 *rgb )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={26, 0, 0, 2, 4};
	
	/* intin & intout anlegen */
	int16 intin[2];
	int16 intout[4];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=color;
	intin[1]=set_flag;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
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

void vql_attributes( const int16 handle, int16 *attrib )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={35, 0, 1, 0, 5};
	int16 i;
	
	/* intout & ptsout anlegen */
	int16 intout[10];
	int16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, ptsout);
	
	/* Die evtl. nicht gelieferten Daten initialisieren */
	for( i=contrl[4] ; i<5 ; i++ )
		intout[i]=0;
	
	/* Die Daten zurÅckgeben */
	if( attrib!=NULL )
	{
		*(int32 *)&attrib[0] = *(int32 *)&intout[0];
		attrib[2] = intout[2];
		attrib[3] = ptsout[0];
		*(int32 *)&attrib[4] = *(int32 *)&intout[3];
	}
}

/******************************************************************************/
/*																										*/
/* VDI  36:	Inquire Current Polymarker Attributes										*/
/*																										*/
/******************************************************************************/

void vqm_attributes( const int16 handle, int16 *attrib )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={36, 0, 1, 0, 3};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, attrib, &attrib[3]);
}

/******************************************************************************/
/*																										*/
/* VDI  37:	Inquire Current Fill Area Attributes										*/
/*																										*/
/******************************************************************************/

void vqf_attributes( const int16 handle, int16 *attrib )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={37, 0, 0, 0, 5};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, attrib, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI  38:	Inquire Current Graphic Text Attributes									*/
/*																										*/
/******************************************************************************/

void vqt_attributes( const int16 handle, int16 *attrib )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={38, 0, 2, 0, 6};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, attrib, &attrib[6]);
}

/******************************************************************************/
/*																										*/
/* VDI 116:	Inquire Text Extent																*/
/*																										*/
/******************************************************************************/

void vqt_extent( const int16 handle, const char *string, int16 *extent )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12] = {116, 0, 4, 0, 0};
	
	/* intin anlegen */
	int16 *intin;
	register int16 i, *i_ptr;
	register unsigned char *c_ptr;
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	contrl[3] = (int16)strlen(string);
	intin = (int16 *)malloc((contrl[3]+1)*sizeof(*intin));
	if( intin == NULL )
		return;
	
	for( i=0, i_ptr=intin, c_ptr=(unsigned char *)string ; i<=contrl[3] ; i_ptr++, c_ptr++, i++ )
		*i_ptr = *c_ptr;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, extent);
	
	/* Das Array freigeben */
	free(intin);
}

/******************************************************************************/
/*																										*/
/* VDI 117:	Inquire Character Cell Width													*/
/*																										*/
/******************************************************************************/

int16 vqt_width( const int16 handle, const int16 character, int16 *cell_width,
			int16 *left_delta, int16 *right_delta )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={117, 0, 3, 1, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* ptsout anlegen */
	int16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=character;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, ptsout);
	
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

int16 vqt_name( const int16 handle, const int16 element_num, char *name )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={130, 0, 0, 1, 33};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[34];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	intin[0] = element_num;
	
	intout[33] = 0;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die Werte zurÅckgeben */
	if( name!=NULL )
	{
		register int16 *i_ptr;
		register char *c_ptr;
		register int16 i;
		
		for( i=0, i_ptr=&intout[1], c_ptr=name ; i<33 ; i_ptr++, c_ptr++, i++ )
			*c_ptr=(char)*i_ptr;
	}
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 130, Esc	1:	Inquire Face Name And Index										*/
/*																										*/
/******************************************************************************/

int16 vqt_ext_name( const int16 handle, const int16 element_num, char *name,
				uint16 *font_format, uint16 *flags )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={130, 0, 0, 2, 35, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[40];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	intin[0] = element_num;
	intin[1] = 0;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die Werte zurÅckgeben */
	if( name!=NULL )
	{
		register int16 *i_ptr;
		register char *c_ptr;
		register int16 i, anz;
		
		anz = (contrl[4]<33 ? contrl[4] : 33);
		for( i=0, i_ptr=&intout[1], c_ptr=name ; i<anz ; i_ptr++, c_ptr++, i++ )
			*c_ptr=(char)*i_ptr;
		for( ; i<33 ; c_ptr++, i++ )
			*c_ptr = 0;
	}
	
	/* Ggf. die erweiterten Parameter liefern */
	if( font_format!=NULL )
	{
		if( contrl[4]>34 )
		{
			/* Die Angabe wird von NVDI geliefert */
			*font_format = intout[34] & 0x00FF;
		}
		else if( contrl[4]>33 )
		{
			/* Es ist irgendein Vektor-Font */
			*font_format = (intout[33]&0x0001 ? 0x0000 : 0x0001);
		}
		else
		{
			/* Es ist ein Bitmap-Font */
			*font_format = 0x0001;
		}
	}
	if( flags!=NULL )
	{
		if( contrl[4]>34 )
			*flags = (intout[34] >> 8) & 0x00FF;
		else
			*flags = 0x0001;
	}
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI  27:	Inquire Cell Array																*/
/*																										*/
/******************************************************************************/

void vq_cellarray( const int16 handle, const int16 *pxyarray, const int16 row_length,
				const int16 num_rows, int16 *el_used, int16 *rows_used, int16 *status,
				int16 *colarray )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={27, 2, 0, 0, 0};
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[7]=row_length;
	contrl[8]=num_rows;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, (int16 *)pxyarray, colarray, _VDIParBlk.ptsout);
	
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

void vqin_mode( const int16 handle, const int16 dev_type, int16 *input_mode )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={115, 0, 0, 1, 1};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0]=dev_type;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, input_mode, _VDIParBlk.ptsout);
}

/******************************************************************************/
/*																										*/
/* VDI 131:	Inquire Current Face Information												*/
/*																										*/
/******************************************************************************/

void vqt_fontinfo( const int16 handle, int16 *minADE, int16 *maxADE, int16 *distances,
			int16 *maxwidth, int16 *effects )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={131, 0, 5, 0, 2};
	
	/* intout & ptsout anlegen */
	int16 intout[10];
	int16 ptsout[15];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, ptsout);
	
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

void vqt_justified( const int16 handle, const int16 x, const int16 y, const char *string,
			const int16 length, const int16 word_space, const int16 char_space, int16 *offsets )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={132, 3, 0, 2, 0};
	
	/* intin & ptsout anlegen */
	int16 *intin;
	int16 i, *i_ptr;
	char *c_ptr;
	
	/* ptsin anlegen */
	int16 ptsin[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	contrl[2]=(int16)strlen(string);
	contrl[3]=contrl[2];
	
	ptsin[0]=x;
	ptsin[1]=y;
	ptsin[2]=length;
	ptsin[3]=0;
	
	intin=(int16 *)malloc((contrl[3]+1)*sizeof(*intin));
	if( intin==NULL )
		return;
	
	intin[0]=word_space;
	intin[1]=char_space;
	for( i=0, i_ptr=intin, c_ptr=(char *)string ; i<=contrl[3] ; i++, i_ptr++, c_ptr++ )
		*i_ptr=*c_ptr;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, ptsin, _VDIParBlk.intout, offsets);
	
	/* intin wieder freigeben */
	free(intin);
}

/******************************************************************************/
/*																										*/
/* VDI 190, Esc	0:	Inquire Character Index												*/
/*																										*/
/******************************************************************************/

uint16 vqt_char_index( const int16 handle, const uint16 src_index,
					const int16 src_mode, const int16 dst_mode )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={190, 0, 0, 3, 1, 0};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	intin[0] = src_index;
	intin[1] = src_mode;
	intin[2] = dst_mode;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 190, Esc	0:	Inquire Character Index												*/
/*																										*/
/******************************************************************************/

boolean vqt_isCharAvailable( const int16 handle, const uint16 unicode )
{
	uint16 direct = vqt_char_index(handle, unicode, CHARIDX_UNICODE, CHARIDX_DIRECT);
	
	return (direct!=0xFFFF ? TRUE : FALSE);
}

/******************************************************************************/
/*																										*/
/* VDI 209, Esc	0: Inquire Hilite Color													*/
/*																										*/
/******************************************************************************/

int32 vq_hilite_color( const int16 handle, COLOR_ENTRY *hilite_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={209, 0, 0, 0, 6, 0};
	
	/* intin & intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die RÅckgabewerte setzen */
	if( hilite_color!=NULL )
	{
		hilite_color->rgb.reserved = intout[2];
		hilite_color->rgb.red = intout[3];
		hilite_color->rgb.green = intout[4];
		hilite_color->rgb.blue = intout[5];
	}
	
	return *(int32 *)&intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 209, Esc	1: Inquire Minimum Color												*/
/*																										*/
/******************************************************************************/

int32 vq_min_color( const int16 handle, COLOR_ENTRY *min_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={209, 0, 0, 0, 6, 1};
	
	/* intin & intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die RÅckgabewerte setzen */
	if( min_color!=NULL )
	{
		min_color->rgb.reserved = intout[2];
		min_color->rgb.red = intout[3];
		min_color->rgb.green = intout[4];
		min_color->rgb.blue = intout[5];
	}
	
	return *(int32 *)&intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 209, Esc	2: Inquire Maximum Color												*/
/*																										*/
/******************************************************************************/

int32 vq_max_color( const int16 handle, COLOR_ENTRY *max_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={209, 0, 0, 0, 6, 2};
	
	/* intin & intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die RÅckgabewerte setzen */
	if( max_color!=NULL )
	{
		max_color->rgb.reserved = intout[2];
		max_color->rgb.red = intout[3];
		max_color->rgb.green = intout[4];
		max_color->rgb.blue = intout[5];
	}
	
	return *(int32 *)&intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 209, Esc	3: Inquire Weight Color													*/
/*																										*/
/******************************************************************************/

int32 vq_weight_color( const int16 handle, COLOR_ENTRY *weight_color )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={209, 0, 0, 0, 6, 3};
	
	/* intin & intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die RÅckgabewerte setzen */
	if( weight_color!=NULL )
	{
		weight_color->rgb.reserved = intout[2];
		weight_color->rgb.red = intout[3];
		weight_color->rgb.green = intout[4];
		weight_color->rgb.blue = intout[5];
	}
	
	return *(int32 *)&intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 229:	Inquire Extended Font Information											*/
/*																										*/
/******************************************************************************/

int16 vqt_xfntinfo( const int16 handle, const int16 flags, const int16 id,
				const int16 index, XFNT_INFO *info )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12] = {229, 0, 0, 5, 3, 0};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* intout & ptsout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	intin[0] = flags;
	intin[1] = id;
	intin[2] = index;
	*(XFNT_INFO **)(&intin[3]) = info;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die RÅckgabewerte setzen */
	info->format	= intout[0];
	info->id			= intout[1];
	info->index		= intout[2];
	
	return intout[1];
}

/******************************************************************************/
/*																										*/
/* VDI 230, Esc 100:	Inquire Face Name and Id by Name									*/
/*																										*/
/******************************************************************************/

int16 vqt_name_and_id( const int16 handle, const int16 font_format,
				const char *font_name, char *ret_name )
{
	register int16 i;
	
	/* contrl anlegen und fÅllen */
	int16 contrl[12] = {230, 0, 0, 5, 3, 100};
	
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
/* VDI 232:	Inquire Speedo Header Information											*/
/*																										*/
/******************************************************************************/

void vqt_fontheader( const int16 handle, void *buffer, char *tdf_name )
{
	register int16 i;
	
	/* contrl anlegen und fÅllen */
	int16 contrl[12] = {232, 0, 0, 2, 0, 0};
	
	/* intin und intout anlegen */
	int16 intin[10];
	int16 intout[256];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	*(void **)(&intin[0]) = buffer;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die Ergebnisse liefern */
	if( tdf_name!=NULL )
		for( i=0 ; i<contrl[4] ; i++ )
			tdf_name[i] = (char)(intin[i] & 0x00FF);
}

/******************************************************************************/
/*																										*/
/* VDI 234:	Inquire Track Kerning Information											*/
/*																										*/
/******************************************************************************/

void vqt_trackkern( const int16 handle, fix31 *x_offset, fix31 *y_offset )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12] = {234, 0, 0, 0, 4, 0};
	
	/* intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die Ergebnisse zurÅckgeben */
	if( x_offset!=NULL )
		*x_offset = *(fix31 *)(&intout[0]);
	if( y_offset!=NULL )
		*y_offset = *(fix31 *)(&intout[2]);
}

/******************************************************************************/
/*																										*/
/* VDI 235:	Inquire Pair Kerning Information												*/
/*																										*/
/******************************************************************************/

void vqt_pairkern( const int16 handle, const int16 index1, const int16 index2,
				fix31 *x_offset, fix31 *y_offset )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12] = {235, 0, 0, 2, 4, 0};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	intin[0] = index1;
	intin[1] = index2;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die Ergebnisse zurÅckgeben */
	if( x_offset!=NULL )
		*x_offset = *(fix31 *)(&intout[0]);
	if( y_offset!=NULL )
		*y_offset = *(fix31 *)(&intout[2]);
}

/******************************************************************************/
/*																										*/
/* VDI 239: Get Character Bitmap Information												*/
/*																										*/
/******************************************************************************/

void v_getbitmap_info( const int16 handle, const int16 index,
			fix31 *x_advance, fix31 *y_advance, fix31 *x_offset, fix31 *y_offset,
			int16 *width, int16 *height, int16 **bitmap )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={239, 0, 0, 1, 12};
	
	/* intin und intout anlegen */
	int16 intin[10];
	int16 intout[15];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* intin fÅllen */
	intin[0] = index;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Ggf. die Werte zurÅckgeben */
	if( width!=NULL )
		*width = intout[0];
	if( height!=NULL )
		*height = intout[1];
	if( x_advance!=NULL )
		*x_advance = *(fix31 *)&intout[2];
	if( y_advance!=NULL )
		*y_advance = *(fix31 *)&intout[4];
	if( x_offset!=NULL )
		*x_offset = *(fix31 *)&intout[6];
	if( y_offset!=NULL )
		*y_offset = *(fix31 *)&intout[8];
	if( bitmap!=NULL )
		*bitmap = *(int16 **)&intout[10];
}

/******************************************************************************/
/*																										*/
/* VDI 240, Esc	0:	Inquire Outline Font Text Extent									*/
/*																										*/
/******************************************************************************/

void vqt_f_extent( const int16 handle, const char *string, int16 *extent )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={240, 0, 4, 0, 0, 0};
	
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
	
	for( i=0, i_ptr=intin, c_ptr=(char *)string ; i<=contrl[3] ; i_ptr++, c_ptr++, i++ )
		*i_ptr=*c_ptr;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, _VDIParBlk.intout, extent);
	
	/* Das Array freigeben */
	free(intin);
}

/******************************************************************************/
/*																										*/
/* VDI 240, Esc 4200:	Inquire Real Outline Font Text Extent						*/
/*																										*/
/******************************************************************************/

void vqt_real_extent( const int16 handle, const int16 x, const int16 y,
			const char *string, int16 *extent )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={240, 1, 4, 0, 0, 4200};
	
	/* Variablen zum BefÅllen des Arrays intin */
	register int16 i, *i_ptr;
	register char *c_ptr;
	
	/* intin & ptsin anlegen */
	int16 *intin;
	int16 ptsin[10];
	
	/* Speicher reservieren */
	contrl[3]=(int16)strlen(string);
	intin=(int16 *)malloc((contrl[3]+1)*sizeof(*intin));
	if( intin==NULL )
		return;
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	for( i=0, i_ptr=intin, c_ptr=(char *)string ; i<=contrl[3] ; i_ptr++, c_ptr++, i++ )
		*i_ptr=*c_ptr;
	
	/* ptsin fÅllen */
	ptsin[0] = x;
	ptsin[1] = y;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, ptsin, _VDIParBlk.intout, extent);
	
	/* Das Array freigeben */
	free(intin);
}

/******************************************************************************/
/*																										*/
/* VDI 243: Get Character Outline															*/
/*																										*/
/******************************************************************************/

void v_getoutline( const int16 handle, const int16 index, int16 *xyarray, 
			uint8 *bezarray, const int16 max_pts, int16 *count )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={243, 0, 0, 6, 0, 0};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* VDI-Handle eintragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	intin[0] = index;
	intin[1] = max_pts;
	*(int16 **)(&intin[2]) = xyarray;
	*(uint8 **)(&intin[4]) = bezarray;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Den RÅckgabewert setzen */
	if( count!=NULL )
		*count = intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 243, Esc 	1:	Get Charcater Outline												*/
/*																										*/
/******************************************************************************/

int16 v_get_outline( const int16 handle, const int16 index, const int16 x_offset,
			const int16 y_offset, int16 *xyarray, uint8 *bezarray, const int16 max_pts )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={243, 0, 0, 8, 0, 1};
	
	/* intin & intout anlegen */
	int16 intin[10];
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	intin[0] = index;
	intin[1] = max_pts;
	*(int16 **)&intin[2] = xyarray;
	*(uint8 **)&intin[4] = bezarray;
	intin[6] = x_offset;
	intin[7] = y_offset;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	return intout[0];
}

/******************************************************************************/
/*																										*/
/* VDI 247:	Inquire Outline Font Advance Placement Vector							*/
/*																										*/
/******************************************************************************/

void vqt_advance( const int16 handle, const int16 ch, int16 *x_advance, int16 *y_advance,
				int16 *x_remainder, int16 *y_remainder )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={247, 0, 2, 1, 0, 0};
	
	/* intin, intout & ptsin anlegen */
	int16 intin[10];
	int16 intout[10];
	int16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	intin[0] = ch;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, ptsout);
	
	/* Die RÅckgabewerte setzen */
	if( x_advance!=NULL )
		*x_advance = ptsout[0];
	if( y_advance!=NULL )
		*y_advance = ptsout[1];
	if( x_remainder!=NULL )
		*x_remainder = ptsout[2];
	if( y_remainder!=NULL )
		*y_remainder = ptsout[3];
}

/******************************************************************************/
/*																										*/
/* VDI 247:	Inquire Outline Font Advance Placement Vector							*/
/*																										*/
/******************************************************************************/

void vqt_advance32( const int16 handle, const int16 index, fix31 *x_advance, fix31 *y_advance )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12]={247, 0, 4, 1, 0, 0};
	
	/* intin, intout & ptsin anlegen */
	int16 intin[10];
	int16 intout[10];
	int16 ptsout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6]=handle;
	
	/* intin fÅllen */
	intin[0] = index;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, ptsout);
	
	/* Die RÅckgabewerte setzen */
	if( x_advance!=NULL )
		*x_advance = *(fix31 *)&ptsout[4];
	if( y_advance!=NULL )
		*y_advance = *(fix31 *)&ptsout[6];
}

/******************************************************************************/
/*																										*/
/* VDI 248:	Inquire Device Status Information											*/
/*																										*/
/******************************************************************************/

void vq_devinfo( const int16 handle, const int16 device, boolean *dev_open,
			char *file_name, char *device_name )
{
	register int16 i;
	
	/* contrl anlegen und fÅllen */
	int16 contrl[12] = {248, 0, 1, 1, 0};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* intout & ptsout anlegen */
	int16 intout[256];
	int16 ptsout[256];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	intin[0] = device;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, ptsout);
	
	/* Die RÅckgabewerte setzen */
	if( dev_open!=NULL )
		*dev_open = (contrl[2]>0 ? ptsout[0] : 0);
	if( file_name!=NULL )
	{
		for( i=0 ; i<contrl[4] ; i++ )
		{
			file_name[i] = (char)(intout[i] & 0x00FF);
			
			/* Ein Leerzeichen mitten im Dateinamen wird gem. */
			/* Beispielbinding NVDI 4 durch '.' ersetzt       */
			if( file_name[i]==' ' && i<contrl[4] && intout[i+1]!=' ' )
				file_name[i] = '.';
		}
		file_name[contrl[4]] = '\0';
	}
	if( device_name!=NULL )
	{
		/* Name in ptsout als C-String, d.h. pro ptsout[] 2 Buchstaben! */		/* Das steht so in der NVDI-4-Doku!                             */
		int16 len = (contrl[2]!=1 || contrl[1]<1 ? (contrl[2]-1) : contrl[1]);
		if( len>0 )
			memcpy(device_name, ptsout + 1, len * sizeof(*ptsout));
		device_name[2*len] =  '\0';	}
}

/******************************************************************************/
/*																										*/
/* VDI 248:	Inquire Device Status Information											*/
/*																										*/
/******************************************************************************/

void vqt_devinfo( const int16 handle, const int16 devnum,
				boolean *devexists, char *devstr )
{
	register int16 i;
	
	/* contrl anlegen und fÅllen */
	int16 contrl[12] = {248, 0, 1, 1, 0};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* intout & ptsout anlegen */
	int16 intout[256];
	int16 ptsout[256];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	intin[0] = devnum;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, ptsout);
	
	/* Die RÅckgabewerte setzen */
	if( devexists!=NULL )
		*devexists = (contrl[2]>0 ? ptsout[0] : 0);
	if( devstr!=NULL )
	{
		for( i=0 ; i<contrl[4] ; i++ )
			devstr[i] = (char)(intout[i] & 0x00FF);
		devstr[contrl[4]] = '\0';
	}
}

/******************************************************************************/
/*																										*/
/* VDI 248:	Inquire Extended Device Status Information								*/
/*																										*/
/******************************************************************************/

boolean vq_ext_devinfo( const int16 handle, const int16 device, boolean *dev_exists,
			char *file_path, char *file_name, char *name )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12] = {248, 0, 0, 7, 2, 4242};
	
	/* intin anlegen */
	int16 intin[10];
	
	/* intout & ptsout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	intin[0] = device;
	*(char **)(&intin[1]) = file_path;
	*(char **)(&intin[3]) = file_name;
	*(char **)(&intin[5]) = name;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die RÅckgabewerte setzen */
	if( dev_exists!=NULL )
		*dev_exists = (intout[0] ? TRUE : FALSE);
	
	return intout[1];
}

/******************************************************************************/
/*																										*/
/* VDI 254: Get Character Mapping Table													*/
/*																										*/
/******************************************************************************/

void vqt_get_table( const int16 handle, int16 **map )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12] = {254, 0, 0, 0, 2};
	
	/* intout anlegen */
	int16 intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	/* VDI aufrufen */
	vdi_(contrl, _VDIParBlk.intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die RÅckgabewerte setzen */
	if( map!=NULL )
		*map = *(int16 **)intout;
}

/******************************************************************************/
/*																										*/
/* VDI 255: Get outline font cache size													*/
/*																										*/
/******************************************************************************/

void vqt_cachesize( const int16 handle, const int16 which_cache, int32 *size )
{
	/* contrl anlegen und fÅllen */
	int16 contrl[12] = {255, 0, 0, 1, 2};
	
	/* intin & intout anlegen */
	int16 intin[10], intout[10];
	
	/* Die Daten in die Arrays Åbertragen */
	contrl[6] = handle;
	
	intin[0] = which_cache;
	
	/* VDI aufrufen */
	vdi_(contrl, intin, _VDIParBlk.ptsin, intout, _VDIParBlk.ptsout);
	
	/* Die RÅckgabewerte setzen */
	if( size!=NULL )
		*size = *(int32 *)intout;
}

