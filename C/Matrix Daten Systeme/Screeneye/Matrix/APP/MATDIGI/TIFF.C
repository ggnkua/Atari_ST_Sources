/********************************************************************/
/* 				MatDigi Window Program - Minimal TIFF Files			*/
/*																	*/
/*------------------------------------------------------------------*/
/*	Status : 14.04.93												*/
/*																	*/
/*  HG - Matrix Daten Systeme, Talstr. 16, W-7155 Oppenweiler		*/
/*																	*/
/********************************************************************/

# include <portab.h>
# include <stdio.h>
# include <stdlib.h>
# include <string.h>
# include <tos.h>

# include <global.h>

# include "md_picfi.h"

# define SOFT_WARE "ScreenEye - 0.1"
			      /*01234567890123456789012345678901*/
# define MAKER     "Matrix Daten Systeme GmbH      "

# include "tiff.h"

# define BYTE_ORDER 		0x4d4d
# define TIFF_VERSION 		42		/* life, the universe & everything */

# define TIFF_CLASS			253
# define SUB_FILE_TYPE		254
# define IMAGE_WIDTH		256			
# define IMAGE_LENGTH		257
# define BITS_PER_SAMPLE	258			
# define COMPRESSION		259
# define PHOTO_INTERPRET	262
# define MAKE				271
# define STRIP_OFFSET		273
# define SAMPLES_PER_PIXEL	277
# define ROWS_PER_STRIP		278
# define STRIP_BYTE_COUNTS	279
# define X_RESOLUTION		282
# define Y_RESOLUTION		283
# define PLANAR_CONFIG		284
# define SOFTWARE			305

typedef enum
{
	C_DUO = 1,
	C_GREY,
	C_PAL,
	C_RGB
} CLASS_TYPE ;

# define S_REDUCED	BIT(0)
# define S_ONEPAGE	BIT(1)
# define S_MASK		BIT(2)
# define S_NONE		0
			 
typedef enum
{
	P_WHITE2 = 0,
	P_BLACK2,
	P_RGB,
	P_MASK,
	P_SEPARATION,
	P_DEPTH
} PHOTO_TYPE ;

typedef enum
{
	CMP_NONE = 1,
	CMP_CCITT3,
	CMP_FAX_CCITT3,
	CMP_FAX_CCITT4,
	CMP_DLZW
} COMPRESS_TYPE ;

TIFFpic	tiff_pic ;


/*-------------------------------------------- write_tiff_picture ---*/	
int write_tiff_picture ( char *name, TIFFpic *tiff, int w, int h )
{
	int  out_file, result = OK ;
	long datasize ;
		
	out_file = (int) Fcreate ( name, 0 ) ;	
	if ( out_file > 0 )
	{
		if ( Fwrite ( out_file,
					  sizeof(TIFFhead),
					  tiff->head ) == sizeof(TIFFhead) )
		{
			if ( result == OK )
			{
				if ( Fwrite ( out_file,
							  sizeof(TIFFdir),
							  tiff->dir ) == sizeof(TIFFdir) )
				{
					datasize = 	(long)w * (long)h * 3L ;

					if ( Fwrite ( out_file,
								  datasize,
								  tiff->data ) != datasize )
						result = CANTwrite ;
				} 
				else
					result = CANTwrite ;
			}
			else
				result = CANTwrite ;
		}
		else
			result = CANTwrite ;
		Fclose ( out_file ) ;
	}
	else
		result = CANTcreate ;

	return ( result ) ;
}


/*----------------------------------------- add_directory_offset ---*/	
void add_directory_offset ( TIFFdir *dir, int *com_num, uword c,
						    COM_TYPE t, ulong l, ulong v )
{
	TIFFcom *com ;

	if ( *com_num < MAX_COM )
	{
		com = &(dir->tiff_com[(*com_num)++]) ;	
		com->command		= c ;
		com->com_type		= t ;
		com->length			= l ;
		com->val_or_adr.ul	= v ;
	}
}


/*----------------------------------------- add_directory_value ---*/	
void add_directory_value ( TIFFdir *dir, int *com_num, uword c,
						   COM_TYPE t, ulong l, ulong v )
{
	TIFFcom *com ;

	if ( *com_num < MAX_COM )
	{
		com = &(dir->tiff_com[(*com_num)++]) ;	
		com->command	= c ;
		com->com_type	= t ;
		com->length		= l ;
		switch ( t )
		{
	case COM_BYTE :	com->val_or_adr.ub	= (byte) v ; break ;
	case COM_SHORT:	com->val_or_adr.uw	= (uword)v ; break ;
	case COM_LONG :	com->val_or_adr.ul	= (ulong)v ; break ;
	default	: ;
		}
	}
}


/*--------------------------------------------- malloc_tiff_pic ---*/	
int malloc_tiff_pic ( TIFFpic *tiff, void *buf, int w, int h )
{
	int com_num = 0 ;
	
	tiff->head = Mxalloc ( sizeof(TIFFhead), 3 ) ;
	if ( tiff->head != NULL )
	{
		tiff->head->order = BYTE_ORDER ;
		tiff->head->version = TIFF_VERSION ;
		tiff->head->pic_offset =  sizeof(TIFFhead) ;
		
		tiff->dir = Mxalloc ( sizeof(TIFFdir), 3 ) ;
		if ( tiff->dir != NULL )
		{
			tiff->data = buf ;

			tiff->dir->bps_table.red_bps = 8 ;
			tiff->dir->bps_table.green_bps = 8 ;
			tiff->dir->bps_table.blue_bps = 8 ;
			
			strcpy ( tiff->dir->software, SOFT_WARE ) ;
			strcpy ( tiff->dir->make,     MAKER ) ;

			add_directory_value ( tiff->dir, &com_num,
								  TIFF_CLASS, COM_SHORT, 1, C_RGB ) ;
			add_directory_value ( tiff->dir, &com_num, 
								  SUB_FILE_TYPE, COM_LONG, 1, S_NONE ) ;
			add_directory_value ( tiff->dir, &com_num, 
								  IMAGE_WIDTH, COM_LONG, 1, w ) ;
			add_directory_value ( tiff->dir, &com_num,
								  IMAGE_LENGTH, COM_LONG, 1, h ) ;
			add_directory_value ( tiff->dir, &com_num, 
								  COMPRESSION, COM_SHORT, 1, CMP_NONE ) ;
			add_directory_value ( tiff->dir, &com_num, 
								  PHOTO_INTERPRET, COM_SHORT, 1, P_RGB ) ;
			add_directory_value ( tiff->dir, &com_num, 
								  STRIP_OFFSET, COM_LONG, 1,
								  sizeof(TIFFhead) +
						 		  sizeof(TIFFdir) ) ;
			add_directory_offset ( tiff->dir, &com_num,
								  BITS_PER_SAMPLE, COM_SHORT, 3,
								  sizeof(TIFFhead) +
								  sizeof(TIFFdir)  -
								  sizeof(BPS_TABLE) ) ;
			add_directory_value ( tiff->dir, &com_num,
								  SAMPLES_PER_PIXEL, COM_SHORT, 1, 3 ) ;
			add_directory_value ( tiff->dir, &com_num,
								  PLANAR_CONFIG, COM_SHORT, 1, 1 ) ;
			add_directory_offset ( tiff->dir, &com_num,
								   SOFTWARE, COM_ASCIIZ,
								   strlen (tiff->dir->software)+1,
								   sizeof(TIFFhead) +
								   sizeof(TIFFdir) -
						 		   sizeof(BPS_TABLE) -
								   sizeof(MAKE_STRING) -
								   sizeof(SOFTWARE_STRING) ) ;
			add_directory_offset ( tiff->dir, &com_num,
								   MAKE, COM_ASCIIZ,
								   strlen (tiff->dir->make)+1,
								   sizeof(TIFFhead) +
								   sizeof(TIFFdir)  -
						 		   sizeof(BPS_TABLE) -
						 		   sizeof(MAKE_STRING) ) ;

			tiff->dir->entries = com_num ;

			add_directory_offset ( tiff->dir, &com_num, 0, 0, 0, 0 ) ;
			return ( OK ) ;
		}
	}
	return ( NOmemory ) ;
}	


/*--------------------------------------------- free_tiff_pic --*/	
void free_tiff_pic ( TIFFpic *tiff )
{
	pfree ( &tiff->head ) ;
	pfree ( &tiff->dir ) ;
	/* pfree ( &tiff->data ) ; */
}	


/* ---------------------------------------------- init_tiff ------- */
TIFFpic *init_tiff ( void *buf, int w, int h, int *result )
{
	TIFFpic *tiff ;
	
	*result = malloc_tiff_pic ( &tiff_pic, buf, w, h ) ;

	if ( *result == OK )
		tiff = &tiff_pic ;
	else
		tiff = NULL ;
		
	return tiff ;
}
