/********************************************************************/
/* 				Read/Write 	Video (for MATdigi	)					*/
/*																	*/
/*------------------------------------------------------------------*/
/*	Status : 20.08.93												*/
/*																	*/
/*  WA/HG - Matrix Daten Systeme, Talstr. 16, W-71570 Oppenweiler	*/
/*																	*/
/********************************************************************/
# define TEST 0

# include <portab.h>
# include <stdlib.h>
# include <stddef.h>
# include <stdio.h>
# include <string.h>
# include <tos.h>
# include <ext.h>

# include "global.h"
# include "md_picfi.h"
# include "md_picfa.h"
# include "\pc\app\dispic\dispic.h"

char *picerr_mesgs[ MAXpicError - PICerrBase + 1 ] = {
	"ok",
	"out of memory",
	"can't open",
	"can't read",
	"wrong file size",
	"illegal file format",
	"can't create",
	"can't write",
	"no color char # in file name",
	"decompression format",
	"argument count",
	"???" } ;


PIChead def_esm_head = DEFAULTesmHead ;
PIChead def_moc_head = DEFAULTmocHead ;
PIChead def_yc_head  = DEFAULTycHead ;

typedef struct {
	char *ext ;
	int  ftyp ;
} FTelem ;

FTelem fttab[] = 
{
	{ ".mog", MOGfile	},
	{ ".moc", MOCfile	},
	{ ".rgb", RGBfile	},
	{ ".esm", ESMfile	},
	{ ".tif", TIFfile	},
	{ ".tff", TIFfile	},
	{ ".rgb", RGBfile	},
	{ ".vid", VIDfile	},
	{ ".img", IMGfile	},
	{ ".bit", BITfile	},

	{ ".i16", I16file	},
	{ ".r16", R16file	},
	{ ".g16", G16file	},
	{ ".b16", B16file	},
	{ ".#16", T16file	},

	{ ".mcc", MCCfile	},
	{ ".inf", INFfile	},
	{ ".yc",  YCfile	},
	
	{ NULL,	  UNDEFfile }
} ;


extern long fram_cookie ;

/*------------------------------------------------- Mdalloc ---*/	
void  *Mdalloc ( long amount )
{
	if ( fram_cookie > 0L )						/* TT-RAM installed */
		return Mxalloc ( amount, 3 ) ;			/* use it 1st */
	else
		return Malloc ( amount ) ;				/* use ST-RAM */
}


/*----------------------------------------------- pic_error ---*/	
char *pic_error ( int error )
{
	if ( error >= OK )
	{
		if ( error >= PICerrBase && error <= MAXpicError )
			return ( picerr_mesgs [ error - PICerrBase ] ) ;
		else
			return ( picerr_mesgs [ MAXpicError - PICerrBase ] ) ;
	}
	else
		return ( picerr_mesgs [ OK ] ) ;
}


/*----------------------------------------------- pic_file_type ---*/	
unsigned int pic_file_type ( char *file_name )
{
	FTelem *ftp ;
	
	strlwr ( file_name ) ;

	ftp = fttab ;
	while ( ftp->ext != NULL )
	{
		if ( strstr ( file_name, ftp->ext ) != NULL )
			return ( ftp->ftyp ) ;
		ftp++ ;
	}
	return ( UNDEFfile ) ;
}	

/*--------------------------------------------- p_free -------------*/	
void p_free ( void **p )
{
	if ( *p != NULL )
	{
		Mfree ( *p ) ;
		*p = NULL ;
	}  
}	

/*=== MOC / ESM ===*/


/*----------------------------------------------------- copy_head --*/
void copy_head ( PIChead *dhead, PIChead *shead )
{	
	memcpy ( dhead, shead, sizeof ( PIChead ) ) ;
}

/*-------------------------------------------------- copy_palette --*/
void copy_palette ( PALETTE *dpalette, PALETTE *spalette )
{	
	memcpy ( dpalette, spalette, sizeof ( PALETTE ) ) ;
}


/*----------------------------------------------- read_me_picture --*/	
int read_me_picture ( PICfileType filtyp, char *name,
					  PIChead **head, PALETTE **palette,
					  byte **rgb_data, long *datasize )
{
	int  in_file, result ;
	long size ;
	
	*head = Mdalloc ( sizeof(PIChead) ) ;
	*rgb_data = NULL ;
	result = OK ;
	
	if ( *head != NULL )
	{
		in_file = (int) Fopen ( name, 0 ) ;	
		if ( in_file >= 0 )
		{
			if ( Fread ( in_file, sizeof(PIChead), *head ) == sizeof(PIChead) )
			{
					
				switch ( filtyp )
				{
		case ESMfile :	Fseek ( (*head)->head_size, in_file, 0 ) ;
						(*head)->tiefe = ESMtiefe ;	/* ESM file	*/
						if ( *(long*)&def_esm_head.kennung != *(long*)&(*head)->kennung )
							result = ILLformat ;
						break ;
		case YCfile :	Fseek ( (*head)->head_size, in_file, 0 ) ;
						(*head)->tiefe = YCtiefe ;
						if ( *(long*)&def_yc_head.kennung != *(long*)&(*head)->kennung )
							result = ILLformat ;
						break ;
		case MOCfile :
		case MCCfile :	(*head)->tiefe = MOCtiefe ;
						*palette = Mdalloc ( sizeof(PALETTE) ) ;
						if ( *palette != NULL )
						{
							if ( Fread ( in_file, sizeof(PALETTE), *palette )
												!= sizeof(PALETTE) )
								result = CANTread ;
						}
						else
							result = NOmemory ;
						break ;
				}
				

				if ( result == OK )
				{
					size = pic_data_size ( *head ) ;
					*rgb_data = Mdalloc ( size ) ;
					if ( *rgb_data != NULL )
					{
						if ( ( *datasize = Fread(in_file,size,*rgb_data ) )
									 != size )
						{
							if ( filtyp != MCCfile || *datasize == 0L )
							{
# if TEST
print_pic_head ( *head ) ;
printf ( "rgb data sizes : expected = %ld, found = %ld\n", size, *datasize ) ;
# endif
								result = WRONGsize ; 
						 		Mfree ( *rgb_data ) ;
								*rgb_data = NULL ;
							}
						}
					}
					else
						result = NOmemory ;
				}
			}
			else
				result = CANTread ;
			Fclose(in_file);
		}
		else
			result = CANTopen ;

		if ( result )
		{
			Mfree ( *head ) ;
			*head = NULL ;
		}
	}
	else
		result = NOmemory ;

	return ( result ) ;
}

/*-------------------------------------------- write_me_picture ---*/	
int write_me_picture ( PICfileType filtyp, char *name,
					   PIChead *head, PALETTE *palette,
					   byte *rgb_data, long datasize )
{
	int  out_file, result ;
	int save_pal ;
	
	result = OK ;

	out_file = (int) Fcreate ( name, 0 ) ;	
	if ( out_file > 0 )
	{
		save_pal = 0 ;

		switch ( filtyp )
		{
	case ESMfile :	head->tiefe = ESMtiefe ;						break ;
	case MCCfile :
	case MOCtiefe :	head->tiefe = MOCtiefe ;	save_pal = 1 ;	break ;
	case YCfile :	head->tiefe = YCtiefe ;							break ;
		}

		if ( Fwrite ( out_file, sizeof(PIChead), head ) == sizeof(PIChead) )
		{
			if ( save_pal )
			{
				if ( Fwrite ( out_file, sizeof(PALETTE), palette )
													 != sizeof(PALETTE) )
					result = CANTwrite ; 
			}
			
			if ( result == OK )
			{
				if ( filtyp != MCCfile )
					datasize = pic_data_size ( head ) ;
				if ( Fwrite(out_file,datasize,rgb_data) != datasize )
					result = CANTwrite ; 
			}
		}
		else
			result = CANTwrite ;
		Fclose(out_file);
	}
	else
		result = CANTcreate ;

	return ( result ) ;
}



/*=== ESM ===*/

/*--------------------------------------------- free_esm_pic --*/	
void free_esm_pic ( ESMpic *esm )
{
	pfree ( &esm->head ) ;
	pfree ( &esm->data ) ;
}	

/*--------------------------------------------- clear_esm_pic --*/	
void clear_esm_pic ( ESMpic *esm )
{
	esm->head = NULL ;
	esm->data = NULL ;
}	

/*----------------------------------------------- print_pic_head --*/	
void print_pic_head ( PIChead *head )
{
   printf ( "kennung = '%s', w = %4d, h = %4d, d = %2d\n",
   				head->kennung, head->breite, head->hoehe, head->tiefe ) ;
   printf ( "art     = %d, R = %d, G = %d, B = %d, black = %d\n",
   				head->bildart, head->tiefe_rot, head->tiefe_gruen, head->tiefe_blau,
   				head->tiefe_schwarz ) ;
}


/*----------------------------------------------- pic_data_size --*/	
long pic_data_size ( PIChead *head )
{
	return ( (long)head->breite * (long)head->hoehe
				* (long)head->tiefe / 8 /* bpp */ ) ;
}

/*------------------------------------------------ resize_esm ---*/	
int resize_esm ( ESMpic *esm, int w, int h )
/* Assumes original size of ESM buffer >= w x h */
{
	if ( esm->head != NULL )
	{
		esm->head->breite = w ;
		esm->head->hoehe  = h ;
	}
	else
		return ( NOmemory ) ;
	return ( OK ) ;
}


/*--------------------------------------------- malloc_pic ---*/	
int malloc_pic ( ESMpic *esm, int w, int h, PIChead *head )
{
	esm->head = Mdalloc ( sizeof(PIChead) ) ;
	if ( esm->head != NULL )
	{
		copy_head ( esm->head, head ) ;
		esm->head->breite = w ;
		esm->head->hoehe  = h ;
		
		esm->data = Mdalloc ( pic_data_size ( esm->head ) ) ;
		if ( esm->data == NULL )
		{
			pfree ( &esm->head ) ;
			return ( NOmemory ) ;
		}
	}
	else
		return ( NOmemory ) ;
		
	return ( OK ) ;
}	

/*--------------------------------------------- malloc_esm_pic ---*/	
int malloc_esm_pic ( ESMpic *esm, int w, int h )
{
	return ( malloc_pic ( esm, w, h, &def_esm_head ) ) ;
}	



/*----------------------------------------------- read_esm_picture --*/	
int read_esm_picture ( char *name, ESMpic *esm )
{
	long datasize ;
	
	return ( read_me_picture ( ESMfile, name, &esm->head, NULL,
										 &esm->data, &datasize ) ) ;
}

/*-------------------------------------------- write_esm_picture ---*/	
int write_esm_picture ( char *name, ESMpic *esm )
{
	strcpy ( esm->head->kennung, ESMmagic ) ;
	return ( write_me_picture ( ESMfile, name, esm->head, NULL,
											esm->data, 0L ) ) ;
}



/*---------------------------------------------------- disti_calc --*/
void disti_calc ( int wpic, int hpic,
				  byte **rp, byte **gp, byte **bp,
				  int x, int y, int w, int h,
				  unsigned bpl,
				  int *difimg, int *difscr,
				  int *dx, int *dy )
{
	long offset ;
	
	if ( w < wpic )
	{
		*dx = w ;
		*difimg = ( wpic - w) ;
	}
	else
	{
		*dx = wpic ;
		*difimg = 0 ;
	}
	
	if ( h < hpic )
		*dy = h ;
	else
		*dy = hpic ;

	*difscr = bpl - *dx ;
	
	offset = (long)y * (long)bpl + (long)x ;
	*rp += offset ;
	if ( gp != NULL )
		*gp += offset ;
	if ( gp != NULL )
		*bp += offset ;
}


byte r6[256], g6[256], b6[256] ;

/*----------------------------------------------------- init_rgb6 ---*/
void init_rgb6 ( void )
{
	int n ;
	byte i6, *rp, *gp, *bp ;
	
	rp = r6 ;
	gp = g6 ;
	bp = b6 ;
	
	for ( n = 0 ; n < 256; n++ )
	{
		i6 = ( n * 6 ) >> 8 ; ;
		*bp++ = 15 + i6 ;
		*gp++ = i6 * 6 ;
		*rp++ = i6 * ( 6 * 6 ) ;
	}
	if ( verbose )
		printf ( "red = %p(->$%02x), green = %p(->$%02x), blue = %p(->$%02x)\n",
						r6, *--rp, g6, *--gp, b6, *--bp ) ;		
}


/*----------------------------------------------------- rgb_to_ix6 -*/
byte rgb_to_ix6 ( byte r, byte g, byte b )
{
# if 0
	byte ix ;
	ix = r6[r] + g6[g] + b6[b] ;
	if ( ix < 16 || ix > 231 )
	{
		printf ( "red = $%02x, green = $%02x, blue = $%02x, ix = %d\n",
						r, g, b, ix ) ;
		getch() ;
	}
	return ix ;
# else
	return r6[r] + g6[g] + b6[b] ;
# endif
}


/*----------------------------------------------- esm_to_6window --*/
void esm_to_6window ( ESMpic *esmpic,
					  byte *dp,
					  int x, int y, int w, int h,
				 	  unsigned bpl )
{
	byte *datptr, r, g, b ;
	int xi, yi, difesm, difscr, dx, dy ;
	
	disti_calc ( esmpic->head->breite, esmpic->head->hoehe,
				 &dp, NULL, NULL,
				 x, y, w, h, bpl,
				 &difesm, &difscr, &dx, &dy ) ;

	difesm *= 3 ;

	datptr = esmpic->data ;
	for ( yi = 0 ;  yi < dy;  yi++ )
	{
		for ( xi = 0 ;  xi < dx;  xi++ )
		{
			r = *datptr++ ;
			g = *datptr++ ;
			b = *datptr++ ;
			*dp++ = rgb_to_ix6 ( r, g, b ) ;
		}
		datptr += difesm ;
		dp += difscr ;
	}
}


/*----------------------------------------------- esm_to_tcwindow --*/
void esm_to_tcwindow ( ESMpic *esmpic,
					   byte *dp,
					   int x, int y, int w, int h,
				 	   unsigned bpl )
{
	int		xi, yi, difesm, difscr, dx, dy ;
	byte	*datptr ;
	long	offset ;
	
	/* like "disti_calc" */
	offset = (long)y * (long)bpl + (long)x * 4L ;

	if ( x + w > esmpic->head->breite )
		dx = esmpic->head->breite - x ;
	else
		dx = w ;

	if ( y + h > esmpic->head->hoehe )
		dy = esmpic->head->hoehe - y ;
	else
		dy = h ;

	dp += offset ;
	/* 4 bytes per pixel for TC */
	difscr = bpl - dx * 4 ;
	/* 3 bytes per pixel for ESM buf */
	difesm = ( esmpic->head->breite - dx ) * 3 ;

	datptr = esmpic->data ;
	for ( yi = 0 ;  yi < dy;  yi++ )
	{
		for ( xi = 0 ;  xi < dx;  xi++ )
		{
			*dp++ = 0 ;
			*dp++ = *datptr++ ;
			*dp++ = *datptr++ ;
			*dp++ = *datptr++ ;
		}
		datptr += difesm ;
		dp += difscr ;
	}
}





/*----------------------------------------------------- disti_esm --*/
void disti_esm ( ESMpic *esmpic,
				 byte *rp, byte *gp, byte *bp,
				 int x, int y, int w, int h,
				 unsigned bpl )
{
	byte *datptr ;
	int xi, yi, difesm, difscr, dx, dy ;
	
	disti_calc ( esmpic->head->breite, esmpic->head->hoehe,
				 &rp, &gp, &bp,
				 x, y, w, h, bpl,
				 &difesm, &difscr, &dx, &dy ) ;

	difesm *= 3 ;

	datptr = esmpic->data ;
	for ( yi = 0 ;  yi < dy;  yi++ )
	{
		for ( xi = 0 ;  xi < dx;  xi++ )
		{
			*rp++ = *datptr++ ;
			*gp++ = *datptr++ ;
			*bp++ = *datptr++ ;
		}
		datptr += difesm ;
		rp += difscr ;
		gp += difscr ;
		bp += difscr ;
	}
}


/*--------------------------------------------------- collect_esm --*/
int collect_esm ( ESMpic *esmpic,
				 byte *rp, byte *gp, byte *bp,
				 int x, int y, int w, int h,
				 unsigned bpl )
{
	byte *datptr ;
	int xi, yi, difesm, difscr, dx, dy ;
	int result ;
	
	disti_calc ( w, h,
				 &rp, &gp, &bp,
				 x, y, w, h, bpl,
				 &difesm, &difscr, &dx, &dy ) ;
	result = malloc_esm_pic ( esmpic, dx, dy ) ;
	if ( result == OK )
	{
		difesm *= 3 ;
	
		datptr = esmpic->data ;
		for ( yi = 0 ;  yi < dy;  yi++ )
		{
			for ( xi = 0 ;  xi < dx;  xi++ )
			{
				*datptr++ = *rp++ ;
				*datptr++ = *gp++ ;
				*datptr++ = *bp++ ;
			}
			datptr += difesm ;
			rp += difscr ;
			gp += difscr ;
			bp += difscr ;
		}
	}
	return ( result ) ;
}


/* === MOC ===*/

/*--------------------------------------------- free_moc_pic --*/	
void free_moc_pic ( MOCpic *moc )
{
	pfree ( &moc->head	  ) ;
	pfree ( &moc->palette ) ;
	pfree ( &moc->data	  ) ;
}	

/*--------------------------------------------- clear_moc_pic --*/	
void clear_moc_pic ( MOCpic *moc )
{
	moc->head	 = NULL ;
	moc->palette = NULL ;
	moc->data	 = NULL ;
}	


/*--------------------------------------------- malloc_moc_pic ---*/	
int malloc_moc_pic ( MOCpic *moc, int w, int h )
{
	clear_moc_pic ( moc ) ;

	moc->head = Mdalloc ( sizeof(PIChead) ) ;

	if ( moc->head != NULL )
	{
		moc->palette = Mdalloc ( sizeof(PALETTE) ) ;
		if ( moc->palette != NULL )
		{
			copy_head ( moc->head, &def_esm_head ) ;
			strcpy ( moc->head->kennung, MOCmagic ) ;
			moc->head->breite = w ;
			moc->head->hoehe  = h ;
			moc->head->tiefe  = MOCtiefe ;
			moc->data = Mdalloc ( pic_data_size ( moc->head ) ) ;
			if ( moc->data != NULL )
				return ( OK ) ;
		}
	}
	free_moc_pic ( moc ) ;
	return ( NOmemory ) ;
}



/*----------------------------------------------- read_moc_picture --*/	
int read_moc_picture ( char *name, MOCpic *moc )
{
	long datasize ;
	
	return ( read_me_picture ( MOCfile, name, &moc->head, &moc->palette,
									&moc->data, &datasize ) ) ;
}

/*-------------------------------------------- write_moc_picture ---*/	
int write_moc_picture ( char *name, MOCpic *moc )
{
	strcpy ( moc->head->kennung, MOCmagic ) ;
	return ( write_me_picture ( MOCfile, name,  moc->head, moc->palette,
												 moc->data, 0L ) ) ;
}


/*--------------------------------------- image_to_window ----------*/
void image_to_window ( UBYTE *start, unsigned bpl,
				 	   int x, int y, int w, int h,
					   UBYTE *data )
{
	UBYTE *winptr ;
	unsigned yi ;

	winptr = start + (long)y*(long)bpl + (long)x ;
	for ( yi = y ;  yi < y + h;  yi++ )
	{
		memcpy ( winptr, data, w ) ;
		data += w ;
		winptr += bpl ;
	}
}

/*--------------------------------------- window_to_image ----------*/
void window_to_image ( UBYTE *start, unsigned bpl,
				 	   int x, int y, int w, int h,
					   UBYTE *data )
{
	UBYTE *winptr ;
	unsigned yi ;

	winptr = start + (long)y*(long)bpl + (long)x ;
	for ( yi = y ;  yi < y + h;  yi++ )
	{
		memcpy ( data, winptr, w ) ;
		data += w ;
		winptr += bpl ;
	}
}


/*--------------------------------------- window_to_esm --*/
void window_to_esm ( byte *start, unsigned bpl,
					 int x, int y, int w, int h,
					 ESMpic *esmpic )
{
	byte *winptr, *linstart, *datptr ;
	unsigned xi, yi ;

	linstart = start + (long)y*(long)bpl + 4l*(long)x ;
	datptr = esmpic->data ;
	for ( yi = y ;  yi < y + h;  yi++ )
	{
		winptr = linstart ;
		for ( xi = x ;  xi < x + w;  xi++ )
		{
			winptr++ ;	/* skip reserved byte	*/
			*datptr++ = *winptr++ ;
			*datptr++ = *winptr++ ;
			*datptr++ = *winptr++ ;
		}
		linstart += bpl ;
	}
}

/*--------------------------------------- cut_esm -------*/
int cut_esm ( ESMpic *oldesm, int x, int y, int w, int h,
			  ESMpic *newesm )
{
	int result ;
	byte *oldptr, *newptr ;
	unsigned xi, yi, bpl, offset ;

	if ( ( result = malloc_esm_pic ( newesm, w, h ) ) == OK )
	{
		bpl = oldesm->head->breite * 3 ;
		offset = bpl - w * 3 ;
	
		oldptr = oldesm->data + (long)y*(long)bpl + 3l*(long)x ;
		newptr = newesm->data ;
		for ( yi = y ;  yi < y + h;  yi++ )
		{
			for ( xi = x ;  xi < x + w;  xi++ )
			{
				*newptr++ = *oldptr++ ;
				*newptr++ = *oldptr++ ;
				*newptr++ = *oldptr++ ;
			}
			oldptr += offset ;
		}
		return ( OK ) ;
	}
	return ( result ) ;
}



/*--------------------------------------- cut_esm -------*/
int cut_yc ( YCpic *oldyc, int x, int y, int w, int h,
			 YCpic *newyc )
{
	int result ;
	byte *oldptr, *newptr ;
	unsigned xi, yi, bpl, offset ;

	if ( ( result = malloc_yc_pic ( newyc, w, h ) ) == OK )
	{
		bpl = oldyc->head->breite * 2 ;	/* 4:2:2 */
		offset = bpl - w * 2 ;
	
		oldptr = oldyc->data + (long)y*(long)bpl + 2l*(long)x ;
		newptr = newyc->data ;
		for ( yi = y ;  yi < y + h;  yi++ )
		{
			for ( xi = x ;  xi < x + w;  xi++ )
			{
				*newptr++ = *oldptr++ ;
				*newptr++ = *oldptr++ ;
			}
			oldptr += offset ;
		}
		return ( OK ) ;
	}
	return ( result ) ;
}


/*--------------------------------------------- disti_moc ---------*/
void disti_moc ( MOCpic *mocpic,
				 byte *rp, byte *gp, byte *bp,
				 int flags, int x, int y, int w, int h,
				 int mincol, int maxcol,
				 unsigned bpl )
{
	byte *datptr ;
	RGB *rgb ;
	int xi, yi, difmoc, difscr, dx, dy, colix ;
	
	disti_calc ( mocpic->head->breite, mocpic->head->hoehe,
				 &rp, &gp, &bp,
				 x, y, w, h, bpl,
				 &difmoc, &difscr, &dx, &dy ) ;

	datptr = mocpic->data ;
	for ( yi = 0 ;  yi < dy;  yi++ )
	{
		for ( xi = 0 ;  xi < dx;  xi++ )
		{
			colix = *datptr++ ;

			if ( flags & MASKcolor )
			{
				if ( colix != mincol )
					colix = maxcol ;
				else
					colix = -1 ;
			}
			else if ( flags & REPLcolor )
			{
				if ( colix == mincol )
					colix = maxcol ;
				else
					colix = -1 ;
			}

			if ( colix >= 0 )
			{
				rgb   = &(*(mocpic->palette))[colix] ;
				*rp++ = rgb->r ;
				*gp++ = rgb->g ;
				*bp++ = rgb->b ;
			}
			else
			{
				rp++ ;
				gp++ ;
				bp++ ;
			}
		}
		datptr += difmoc ;
		rp += difscr ;
		gp += difscr ;
		bp += difscr ;
	}
}


/* === YC ===*/

/*--------------------------------------------- malloc_yc_pic ---*/	
int malloc_yc_pic ( YCpic *yc, int w, int h )
{
	return ( malloc_pic ( yc, w, h, &def_yc_head ) ) ;
}	


/*-------------------------------------------- read_yc_picture --*/	
int read_yc_picture ( char *name, YCpic *yc )
{
	long datasize ;
	
	return ( read_me_picture ( YCfile, name, &yc->head, NULL,
										 &yc->data, &datasize ) ) ;
}

/*------------------------------------------ write_yc_picture ---*/	
int write_yc_picture ( char *name, YCpic *yc )
{
	strcpy ( yc->head->kennung, YCmagic ) ;
	return ( write_me_picture ( YCfile, name, yc->head, NULL,
											yc->data, 0L ) ) ;
}

# if 1
int yc_base_colors[5][3] =
{/*  Y   Cb, Cr	*/
	{ 235, 128, 128 },	/* white	*/
	{  16, 128, 128 },	/* black	*/
	{  82,  90, 240 },	/* red		*/
	{ 145,  54,  34 },	/* green	*/
	{  41, 240, 110 }	/* blue		*/
} ;
# else
int yc_base_colors[5*3] =
{/*  Y   Cb, Cr	*/
	 235, 128, 128,	/* white	*/
	  16, 128, 128,	/* black	*/
	  82,  90, 240,	/* red		*/
	 145,  54,  34,	/* green	*/
	  41, 240, 110 	/* blue		*/
} ;
# endif


/*-------------------------------------------- byte_print_pixel ----------*/	
void byte_print_pixel ( byte *base, int x, int y, int bpl )
{
	byte *p ;

	p = base + ( (long)y * (long)(bpl) + (long)(x) ) ;
	printf ( "%3d", *p ) ;
}


/*-------------------------------------------- yc_print_pixel ----------*/	
void yc_print_pixel ( YCpic *yc, int x, int y )
{
	byte *p ;

	if ( x < yc->head->breite && y < yc->head->hoehe )
	{
		p = yc->data + 2L * ( (long)y * (long)(yc->head->breite) + (long)( x & 0xfffe ) ) ;
		if ( x & 1 )
			printf ( "---:%3d:%3d:%3d",       p[1], p[2], p[3] ) ;
		else
			printf ( "%3d:%3d:---:%3d", p[0], p[1],       p[3] ) ;
	}
	else
		printf ( "???:???:???:???" ) ;
}


/*-------------------------------------------- esm_print_pixel ----------*/	
void esm_print_pixel ( ESMpic *esm, int x, int y )
{
	byte *p ;

	if ( x < esm->head->breite && y < esm->head->hoehe )
	{
		p = esm->data + 3L * ( (long)y * (long)(esm->head->breite) + (long)(x) ) ;
		printf ( "%3d:%3d:%3d", p[0], p[1], p[2] ) ;
	}
	else
		printf ( "???:???:???" ) ;
}


/*-------------------------------------------- fill_yc ----------*/	
void fill_yc ( YCpic *yc, int y, int cr, int cb )
{
	byte *d ;
	int  xi, yi ;
	int  pattern, *p1, *p2 ;
	
	d = yc->data ;

	pattern = y - 256 ;

	if ( pattern > 0 )
	{
		p1 = &yc_base_colors[cr][0] ;	/* == first color	*/
		p2 = &yc_base_colors[cb][0] ;	/* == last color	*/
		y = cr = cb = 0x80 ;	/* gray	*/
	}

	for ( yi = 0 ; yi < yc->head->hoehe ; yi++ )
	{
		for ( xi = 0 ; xi < yc->head->breite ; xi += 2 )
		{
			*d++ = y ;
			*d++ = cb ;
			*d++ = y ;
			*d++ = cr ;
		}
	}



	switch ( pattern )
	{
case 1 :printf ( "calc pattern\n" ) ;
		for ( yi = 0 ; yi < 256 ; yi++ )
		{
			d = yc->data + (long)yi * (long)(2 * yc->head->breite) ;
	
			cr = yi ;
			for ( xi = 0 ; xi < 256 ; xi += 2 )
			{
				cb = xi ;
				*d++ = y ;
				*d++ = cr ;
				*d++ = y ;
				*d++ = cb ;
			}
		}
		break ;
# define  scale(xmi,xma,yma,yi) xmi+(int)( (long)(xma-xmi)*(long)yi/(long)(yma-1) )
/*					 Y   Cr  Cb
echo "white" ; vfill 235 128 128 ; video conv ; video show
echo "black" ; vfill  16 128 128 ; video conv ; video show
echo "red" ;   vfill  82  90 240 ; video conv ; video show
echo "green" ; vfill 145  54  34 ; video conv ; video show
echo "blue" ;  vfill  41 240 110 ; video conv ; video show
*/
case 2 :d = yc->data ;
		printf ( "%d,%d,%d -> %d,%d,%d\n",
					p1[0],p1[1],p1[2],p2[0],p2[1],p2[2] ) ;
		for ( yi = 0 ; yi < yc->head->hoehe ; yi++ )
		{
			y  = scale(p1[0],p2[0],yc->head->hoehe,yi) ;
			cr = scale(p1[1],p2[1],yc->head->hoehe,yi) ;
			cb = scale(p1[2],p2[2],yc->head->hoehe,yi) ;
			for ( xi = 0 ; xi < yc->head->breite ; xi += 2 )
			{
				*d++ = y ;
				*d++ = cr ;
				*d++ = y ;
				*d++ = cb ;
			}
		}
		break ;

	}

	yc->head->bildart = YC_422 ;
}

long cr_r[255] ;
long cr_g[255], cb_g[255] ;
long cb_b[255] ;

/*----------------------------------------------------- init_yc_to_rgb ---*/
bool init_yc_to_rgb ( void )
{
	int n ;
	
	for ( n = 0 ; n < 256; n++ )
	{
		cr_r[n] = (long)  351 * (long)(n-128) ;
		cr_g[n] = (long)- 179 * (long)(n-128) ;
		cb_g[n] = (long)-  86 * (long)(n-128) ;
		cb_b[n] = (long)+ 443 * (long)(n-128) ;
	}
	return TRUE ;	
}

extern int verbose ;

/*----------------------------------------------------- yc_to_rgb ---*/
byte *yc_to_rgb ( byte *d, int y, int cr, int cb )
{
	d = add32_clip8 ( d, y, cr_r[cr] 			) ;
	d = add32_clip8 ( d, y, cr_g[cr] + cb_g[cb]	) ;
	d = add32_clip8 ( d, y, cb_b[cb]			) ;

	if ( verbose > 1 )
		printf ( "Y=%4d, Cr=%4d, Cb=%4d, red = $%02x, green = $%02x, blue = $%02x\n",
						y, cr, cb, d[-3], d[-2], d[-1] ) ;
	return ( d ) ;
}

/*------------------------------------------ print_yc_conv ----------*/	
void print_yc_conv ( int y, int cr, int cb )
{
	byte rgb[3] ;

	init_yc_to_rgb();
	yc_to_rgb ( rgb, y, cr, cb ) ;
	printf ( "y:cr:cb %3d:%3d:%3d -> r:g:b %3d:%3d:%3d", y,cr,cb, rgb[0],rgb[1],rgb[2] ) ;
}
					

/*----------------------------------------------------- yc_to_esm ---*/
int yc_to_esm ( YCpic *yc, ESMpic *esm )
{
	int result ;
	byte *sd, *dd ;
	int  x, y ;

	init_yc_to_rgb();

	if ( esm->data == NULL )
		result = malloc_esm_pic ( esm, yc->head->breite,
								   yc->head->hoehe ) ;
	else
		result = OK ;
	if ( result == OK )
	{
		sd = yc->data ;
		sd += 2 ;
		dd = esm->data ;

		if ( verbose )
		{
			if ( yc->head->bildart == YC_422 )
				printf ( "4:2:2\n" ) ;
			else
				printf ( "4:1:1\n" ) ;
		}
		
		for ( y = 0 ; y < yc->head->hoehe ; y++ )
		{
			for ( x = 0 ; x < yc->head->breite ; x += 4 )
			{
				dd = yc_to_rgb ( dd, sd[0], sd[1], sd[3] ) ;	/*	a	*/
				dd = yc_to_rgb ( dd, sd[2], sd[1], sd[3] ) ;	/*	b	*/
				sd += 4 ;
				dd = yc_to_rgb ( dd, sd[0], sd[1], sd[3] ) ;	/*	c	*/
				dd = yc_to_rgb ( dd, sd[2], sd[1], sd[3] ) ;	/*	d	*/
				sd += 4 ;
			}
		}
	}
	
	return ( result ) ;
}	

/*----------------------------------------------------- buf_to_rgb ---*/
void buf_to_rgb ( byte *sd, byte *dd )
{
	if ( init_yc_to_rgb() )
	{
		dd = yc_to_rgb ( dd, sd[0], sd[1], sd[3] ) ;
		dd = yc_to_rgb ( dd, sd[2], sd[1], sd[3] ) ;
		sd += 4 ;
	}
}	

/*---- T16 ---*/

/*------------------------------------------------- t16_to_window --*/
void t16_to_window ( I16pic *i16pic,
					 byte *rp, byte *gp, byte *bp,
					 int x, int y, int w, int h,
					 unsigned bpl )
{
	byte *rpic, *gpic, *bpic ;
	int  xi, yi, difi16, difscr, dx, dy ;
	
	disti_calc ( i16pic->head->_xres, i16pic->head->_xres,
				 &rp, &gp, &bp,
				 x, y, w, h, bpl,
				 &difi16, &difscr, &dx, &dy ) ;

	rpic = (i16pic++)->data ;
	gpic = (i16pic++)->data ;
	bpic = (i16pic++)->data ;
	for ( yi = 0 ;  yi < dy;  yi++ )
	{
		for ( xi = 0 ;  xi < dx;  xi++ )
		{
			*rp++ = *rpic++ ;
			*gp++ = *gpic++ ;
			*bp++ = *bpic++ ;
		}
		rpic += difi16 ;
		gpic += difi16 ;
		bpic += difi16 ;
		rp += difscr ;
		gp += difscr ;
		bp += difscr ;
	}
}


/*=== TIF ===*/

/*--------------------------------------------- free_tif_pic --*/	
void free_tif_pic ( TIFpic *tif )
{
	pfree ( &tif->head ) ;
	pfree ( &tif->data ) ;
}	


/*--------------------------------------------- clear_tif_pic --*/	
void clear_tif_pic ( TIFpic *tif )
{
	tif->head = NULL ;
	tif->data = NULL ;
}	


/*----------------------------------------------- print_tif_head --*/	
void print_tif_head ( TIFhead *head )
{
   printf ( "TIF : w = %4d, h = %4d\n", head->breite, head->hoehe ) ;
}


/*----------------------------------------------- tif_data_size --*/	
long tif_data_size ( TIFhead *head )
{
	return ( (long)head->breite * (long)head->hoehe / 8 /* bpp */ ) ;
}

/*--------------------------------------------- read_tif_picture --*/	
int read_tif_picture ( char *name, TIFpic *tif )
{
	int  in_file, result ;
	long size, in_size ;

	tif->head = Mdalloc ( sizeof(TIFhead) ) ;
	tif->data = NULL ;
	result = OK ;
	
	if ( tif->head != NULL )
	{
		in_file = (int) Fopen ( name, 0 ) ;	
		if ( in_file >= 0 )
		{
			if ( Fread ( in_file, sizeof(TIFhead), tif->head ) == sizeof(TIFhead) )
			{
				if ( result == OK )
				{
						size = tif_data_size ( tif->head ) ;
						tif->data = Mdalloc ( size ) ;
						if ( tif->data != NULL )
						{
							if ( ( in_size = Fread(in_file,size,tif->data ) )
										 != size )
							{
# if TEST
print_tif_head ( tif->head ) ;
printf ( "tif data sizes : expected = %ld, found = %ld\n", size, in_size ) ;
# else
		in_size = in_size ;
# endif
								result = WRONGsize ; 
							 	Mfree ( tif->data ) ;
								tif->data = NULL ;
							}
						}
						else
							result = NOmemory ;
				}
			}
			else
				result = CANTread ;
			Fclose(in_file);
		}
		else
			result = CANTopen ;

		if ( result )
		{
			Mfree ( tif->head ) ;
			tif->head = NULL ;
		}
	}
	else
		result = NOmemory ;

	return ( result ) ;
}


/*--------------------------------------------- free_rgb_tifs --*/	
void free_rgb_tifs ( RGBtifs tifs )
{
	unsigned base_color ;
	TIFpic *tif ;
	
	tif = &tifs[0] ;
	for ( base_color = 0 ; base_color < 3 ; base_color++ )
		free_tif_pic ( tif++ ) ;
}	


/*--------------------------------------------- clear_rgb_tifs --*/	
void clear_rgb_tifs ( RGBtifs tifs )
{
	unsigned base_color ;
	TIFpic *tif ;
	
	tif = &tifs[0] ;
	for ( base_color = 0 ; base_color < 3 ; base_color++ )
		clear_tif_pic ( tif++ ) ;
}	

char coltab[] = "rgb" ;
# define COLchar '#'

/*--------------------------------------------- read_rgb_tifs --*/	
int read_rgb_tifs ( char *name, RGBtifs tifs )
{
	char	 *colpos ;
	unsigned base_color ;
	TIFpic	 *tif ;
	int		 result ;
	
	clear_rgb_tifs ( tifs ) ;
	
	colpos = strchr(name,COLchar);
	if(colpos == NULL)
	{
		printf("- no '%c' for color char in '%s'\n", COLchar, name );
		return ( NOcolorChr ) ;
	}

	tif = &tifs[0] ;
	for ( base_color = 0 ; base_color < 3 ; base_color++ )
	{
		/* make file_name of input file, first char = color */
		*colpos = coltab[base_color] ;
		result = read_tif_picture ( name, tif ) ;
		if ( result != OK )
		{
			free_rgb_tifs ( tifs ) ;
			break ;
		}
	}
	return ( result ) ;
}			



/*=== MCC ===*/

/*--------------------------------------------- free_mcc_pic --*/	
void free_mcc_pic ( MCCpic *mcc )
{
	pfree ( &mcc->head	  ) ;
	pfree ( &mcc->palette ) ;
	pfree ( &mcc->data	  ) ;
	mcc->size = 0 ;
	mcc->used = 0 ;
}	

/*--------------------------------------------- clear_mcc_pic --*/	
void clear_mcc_pic ( MCCpic *mcc )
{
	mcc->head	 = NULL ;
	mcc->palette = NULL ;
	mcc->data	 = NULL ;
	mcc->size	 = 0 ;
	mcc->used	 = 0 ;
}	

/*----------------------------------------------- read_mcc_picture --*/	
int read_mcc_picture ( char *name, MCCpic *mcc )
{
	int result ;
	
	result =  read_me_picture ( MCCfile, name, &mcc->head, &mcc->palette,
									&mcc->data, &mcc->size ) ;
	mcc->used = mcc->size ;
	return ( result ) ;
}

/*-------------------------------------------- write_mcc_picture ---*/	
int write_mcc_picture ( char *name, MCCpic *mcc )
{
	strcpy ( mcc->head->kennung, "MCC" ) ;
	return ( write_me_picture ( MCCfile, name,  mcc->head, mcc->palette,
									 mcc->data, mcc->used ) ) ;
}

/*--------------------------------------------- malloc_mcc_pic ---*/	
int malloc_mcc_pic ( MCCpic *mcc, int w, int h )
{
	clear_mcc_pic ( mcc ) ;

	mcc->head = Mdalloc ( sizeof(PIChead) ) ;

	if ( mcc->head != NULL )
	{
		mcc->palette = Mdalloc ( sizeof(PALETTE) ) ;
		if ( mcc->palette != NULL )
		{
			copy_head ( mcc->head, &def_esm_head ) ;
			strcpy ( mcc->head->kennung, "MCC" ) ;
			mcc->head->breite = w ;
			mcc->head->hoehe  = h ;

			/* malloc at first space for MOC data,
			   shrink it after compression	*/
			mcc->head->tiefe  = MOCtiefe ;
			mcc->size = pic_data_size ( mcc->head ) ;
			mcc->data = Mdalloc ( mcc->size ) ;
			mcc->used = 0 ;
			if ( mcc->data != NULL )
				return ( OK ) ;
		}
	}
	free_mcc_pic ( mcc ) ;
	return ( NOmemory ) ;
}




/*
	compression format :
	
		file =				line ;
		
		line =				header? packet* ;
		
		header =			0x8000.W ;
		
		packet =			compressed~packet | copy~packet ;
					
		compressed~packet =	( - (run~length - 1) ).W  data.W ;
		
								; packet header < 0, at least 2 equal words

		copy~packet =		( run~length - 1 ).W	data.W* ;
		
								; packet header >= 0 !

*/

# define LINEheader		1

# define COMPRESS_TYPE	int
# define TYPEmax		32767

# define START		0
# define RESTART	1
# define EQU		2
# define NEQ		3

/*--------------------------------------------- compress_line ----*/
byte *compress_line( byte *source, byte *dest, byte *maxdest, int length )
{
	COMPRESS_TYPE *sp,*dp,*cp,*maxp ;
	COMPRESS_TYPE a, b ;			/*	processed : A B	*/
	
	int count, state ;

	state = START ;
	sp   = (COMPRESS_TYPE *)source ;
	dp   = (COMPRESS_TYPE *)dest ;
	maxp = ((COMPRESS_TYPE *)maxdest) - 2  ;	/* reserve at least 2 words	*/
	b = 0 ;

# if LINEheader
	*dp++ = 0x8000 ;
# endif
	
	for ( ; length > 0; length -= (int)sizeof(COMPRESS_TYPE)  )
	{
		if ( dp >= maxp )
			return ( NULL ) ;
		a = b ;				/* look ahead sequence	: ... a b */
		b = *sp++ ;

		/*	START	:	- b	*/
		/*	RESTART	:	a b	*/
		/*	EQU	:		A b	*/
		/*	NEQ	:		a b	*/

		switch ( state )
		{
 case START :	state = RESTART ;	/* read only lookahead : ? b */
				break ;

 case RESTART :	if ( a == b )		/* here we have : .. a b	*/
				{
					state = EQU ;
					count = 2 ;		/* 2 equal items found	: A B */
				}
				else
				{
					state = NEQ ;
					cp = dp ;		/* save and skip count position	*/
					*dp++ = 0 ;
					*dp++ = a ;		/* save first data item	*/
					count = 1 ;		/* 1 unequal item found	: A b */
				}
				break ;
				
 case EQU :		if ( a == b && count > -TYPEmax )	/*	A b	 */
				{
					count++ ;		/* another equal item found	*/
				}									/*	A B	 */
				else	/* finish equal sequence : A .. A b	*/
				{
					*dp++ = -(count-1) ;
					*dp++ = a ;			/* save data item	*/

					state = RESTART ;				/*	A b	 */
				}
				break ;
				
 case NEQ :		/* sequence .. X Y Z a b .. */
				if ( a != b && count < TYPEmax )
				{
					count++ ;		/* another unequal item found	*/
					*dp++ = a ;		/* save last item	*/
				}						/*	X Y Z A b .. */
				else /* a == b */	/* finish unequal sequence	*/
				{
					*cp   = count-1 ;	/* update count in output buffer */
					state = EQU ;
					count = 2 ;	/* 2 equal items found	*/
				}						/*	X Y Z A B .. */
				break ;
		}
		/*	RESTART	:	A ?? b	*/
		/*	EQU	:		A == B	*/
		/*	NEQ	:		A != b	*/
	}
	
	switch ( state )
	{
 case RESTART :	/* one item in buffer b	*/			/*	A b	 */
			*dp++ = 0 ;	/* equal sequence, length = 1 */
			*dp++ = b ;
 			break ;
 			
 case EQU :	/* finish equal sequence	*/			/*	A B	 */
			*dp++ = -(count-1) ;
			*dp++ = a ;
			break ;
				
 case NEQ :	/* finish unequal sequence, one item left in b	*/
			count++ ;
			*dp++ = b ;

			*cp   = count-1 ;	/* update count in output buffer */
			break ;
	}
	
	return ( (byte *) dp ) ;
}


# if 0
/*--------------------------------------------- uncompress_line ----*/
byte *uncompress_line( byte *source, byte *dest, int length )
{
	int *sp,*dp ;
	int a, b, words ;
	
	sp = (int *)source ;
	dp = (int *)dest ;

	if ( (unsigned)*sp == 0x8000 )	/* skip lineheader	*/
		sp++ ;
	
	words = length / 2 ;
	while ( words > 0 )
	{
	 	a = *sp++ ;
 		if ( (unsigned)a == 0x8000 )
 		{
 			printf ( "format: lin %#8.8lx, pos %#8.8lx, scrlin %#8.8lx, key!\n",
 						source, sp-1, dest ) ;
 			getch() ;
 		}

	 	if ( a < 0 )	/* a < 0 : equal sequence	*/
	 	{
	 		words -= -a + 1 ;
		 	b = *sp++ ;
	 		
	 		for ( ; a <= 0 ; a++ ) *dp++ = b ;
	 	}
	 	else			/* a >= 0 : unequal sequence	*/
	 	{
	 		words -= a + 1 ;
	 		
	 		for ( ; a >= 0 ; a-- ) *dp++ = *sp++ ;
	 	}
	 }
	return ( (byte *) sp ) ;
}
# else
/*--------------------------------------------- uncompress_line ----*/
byte *uncompress_line ( byte *source, byte *dest, byte *maxused, int length )
{
	int *sp,*dp ;
	int a, b, words ;
	
	sp = (int *)source ;
	dp = (int *)dest ;

# if TEST
	printf ( "format: source line %#8.8lx, scrlin %#8.8lx, key !\n", source, dest ) ;
/*
	break_point();
*/
# endif

# if 0
	if ( (unsigned)*sp++ != 0x8000 )	/* skip lineheader	*/
	{
		printf ( "format: source line %#8.8lx, scrlin %#8.8lx, key !\n", source, dest ) ;
	 	return ( NULL ) ;
	}
# else
	if ( (unsigned)*sp == 0x8000 )	/* skip lineheader	*/
		sp++ ;
# endif

	words = length / 2 ;
	
	while ( words > 0 )
	{
	 	a = *sp ;
 		if ( (unsigned)a == 0x8000 )
			return ( (byte *) sp ) ;
		if (  sp >= (int *)maxused )
		{
			printf ( "limit : source line %#8.8lx, pos %#8.8lx, scrlin %#8.8lx, key !\n",
							source, sp, dest ) ;
		 	return ( NULL ) ;
		}
		sp++ ;
	 	if ( a < 0 )	/* a < 0 : equal sequence	*/
	 	{
		 	b = *sp++ ;
	 		words -= -a + 1 ;
	 		for ( ; a <= 0 ; a++ ) *dp++ = b ;
	 	}
	 	else			/* a >= 0 : unequal sequence	*/
	 	{
	 		words -= a + 1 ;
	 		for ( ; a >= 0 ; a-- ) *dp++ = *sp++ ;
		}
	}
	return ( (byte *) sp ) ;
}
# endif

/*--------------------------------------- compress_window -----*/
int compress_window ( byte *start, unsigned bpl,
					  int x, int y, int w, int h,
					  MCCpic *mccpic )
{
	byte *winptr, *datptr, *maxdat ;
	unsigned yi ;

	winptr = start + (long)y*(long)bpl + (long)x ;
	datptr = mccpic->data ;
	maxdat = datptr + mccpic->size ;
	for ( yi = y ;  yi < y + h;  yi++ )
	{
		datptr = compress_line ( winptr, datptr, maxdat, w ) ;
		if ( datptr == NULL )
		{
			mccpic->used = 0 ;
			return ( 2 ) ;
		}
		winptr += bpl ;
	}
	mccpic->used = (long) ( datptr - mccpic->data ) ;
	return ( 0 ) ;
}

/*--------------------------------------- uncompress_window -----*/
int uncompress_window ( byte *display, unsigned bpl,
						int x, int y,
						MCCpic *mccpic )
{
	byte *winptr, *datptr, *pp, *maxusd ;
	unsigned yi ;

	winptr = display + (long)y*(long)bpl + (long)x ;
	datptr = mccpic->data ;	
	maxusd = datptr + mccpic->used ;

# if TEST
printf ( "\n" ) ;
# endif
	for ( yi=0; yi < mccpic->head->hoehe; yi++ )
	{
# if TEST
printf ( "\r%4d", yi ) ;
if ( yi == 959 ) break_point() ;
# endif
		pp = datptr ;
		datptr = uncompress_line ( datptr, winptr, maxusd, mccpic->head->breite ) ;
		if ( datptr == NULL )
		{
			printf ( "y = %d, yi = %d, pic = $%8.8lx\n", y, yi, pp ) ;
			return ( DECOMPerr ) ;
		}
		winptr += bpl ;
	}
	return ( OK ) ;
}



/*=== I16 ===*/

/*--------------------------------------------- free_i16_pic --*/	
void free_i16_pic ( I16pic *i16 )
{
	pfree ( &i16->head	  ) ;
	pfree ( &i16->palette ) ;
	pfree ( &i16->data	  ) ;
}	

/*--------------------------------------------- clear_i16_pic --*/	
void clear_i16_pic ( I16pic *i16 )
{
	i16->head	 = NULL ;
	i16->palette = NULL ;
	i16->data	 = NULL ;
}	


/*---------------------------------------------- read_i16_picture --*/	
int read_i16_picture ( char *name, I16pic *i16pic )
{
	int  in_file, result ;
	long size, insize ;

	clear_i16_pic ( i16pic ) ;
	
	i16pic->head = Mdalloc ( sizeof(I16head) ) ;

	result = OK ;
	
	if ( i16pic->head != NULL )
	{
		in_file = (int) Fopen ( name, 0 ) ;	
		if ( in_file >= 0 )
		{
			if ( Fread ( in_file, sizeof(I16head), i16pic->head ) == sizeof(I16head) )
			{
				i16pic->palette = Mdalloc ( sizeof(I16palette) ) ;
				if ( i16pic->palette != NULL )
				{
					Fseek ( PALETTE_START, in_file, 0 ) ;
					if ( Fread ( in_file, sizeof(I16palette), i16pic->palette )
										!= sizeof(I16palette) )
						result = CANTread ;
				}
				else
					result = NOmemory ;
			}
			

			if ( result == OK )
			{
				size = (long)i16pic->head->_xres * (long)i16pic->head->_yres ;
# if 0
				printf (
 "- I16 : %d x %d, data size = %ld, file size = %ld, over = %ld\n",
					i16pic->head->_xres, i16pic->head->_yres, size,
							 i16pic->head->_piclenl - size ) ;
# endif
				i16pic->data = Mdalloc ( size ) ;
				if ( i16pic->data != NULL )
				{
					Fseek ( DATA_START, in_file, 0 ) ;
					insize = Fread( in_file, size, i16pic->data ) ;
					if ( insize != size )
					{
						printf ( "- bytes read : %ld\n", insize ) ;
# if 0
						result = WRONGsize ; 
				 		Mfree ( i16pic->data ) ;
						i16pic->data = NULL ;
# endif
					}
				}
				else
					result = NOmemory ;
			}
			else
				result = CANTread ;
			Fclose(in_file);
		}
		else
			result = CANTopen ;

		if ( result )
		{
			Mfree ( i16pic->head ) ;
			i16pic->head = NULL ;
		}
	}
	else
		result = NOmemory ;

	return ( result ) ;
}



/*===== image operations =====*/

# define Cv(i,n) ((255*i)/n)

byte col3bit[8] = { Cv(0,7), Cv(1,7), Cv(2,7), Cv(3,7),
					Cv(4,7), Cv(5,7), Cv(6,7), Cv(7,7) } ;
byte col2bit[4] = { Cv(0,3), Cv(1,3), Cv(2,3), Cv(3,3) } ;

# undef Cv

/*-------------------------------------------- index_to_rgb ------*/	
void index_to_rgb ( int color, RGB *pp )
{
	pp->rsrvd = 0 ;
	pp->r = col3bit[ (color & 0xe0) >> 5 ] ;
	pp->g = col3bit[ (color & 0x1c) >> 2 ] ;
	pp->b = col2bit[ (color & 0x03)		 ] ;
}

/*-------------------------------------------- pack_palette ------*/	
void pack_palette ( PALETTE *palette )
{
	RGB *pp ;
	int color ;
	
	pp = *palette ;
	for ( color=0; color<256; color++, pp++ )
		index_to_rgb ( color, pp ) ;
}

/*-------------------------------------------- pack_esm ----------*/	
int pack_esm ( ESMpic *esm, MOCpic *moc )
{
	int x, y, moc_dx, esm_inc ;
	byte *esmdat, *mocdat ;
	byte r, g, b ;
	int result ;
	
	moc_dx = esm->head->breite & ~ 1 ;				/* round width	*/
	esm_inc = 3 * ( esm->head->breite - moc_dx ) ;

	result = malloc_moc_pic ( moc, moc_dx, esm->head->hoehe ) ;
	if ( result != OK )
		return ( result ) ;

	pack_palette ( moc->palette ) ;
	
	esmdat = esm->data ;
	mocdat = moc->data ;
	for ( y = 0 ; y < esm->head->hoehe ; y++ )
	{
		for ( x = 0 ; x < moc_dx ; x++ )
		{
			r = *esmdat++ ;
			g = *esmdat++ ;
			b = *esmdat++ ;
# if 0
			*mocdat++ = pack_rgb ( int r, int g, int b ) ;
# else
			*mocdat++ = COLindex(r,g,b) ;
# endif
		}
		esmdat += esm_inc ;
	}
	return ( OK ) ;
}


/*-------------------------------------------- pack_esm_file ------*/	
int pack_esm_file ( char *esmnam, char *mocnam )
{
	ESMpic esm ;
	MOCpic moc ;
	int result ;

	clear_moc_pic ( &moc ) ;
	clear_esm_pic ( &esm ) ;

	printf ( "read esm .." ) ;
	result = read_esm_picture ( esmnam, &esm ) ;
	printf ( " (%d)\n", result ) ;

	if ( result == OK )
	{
		print_pic_head ( esm.head ) ;

		printf ( "pack esm .." ) ;
		result = pack_esm ( &esm, &moc ) ;
		printf ( " (%d)\n", result ) ;

		if ( result == OK )
		{
			printf ( "write moc .." ) ;
			result = write_moc_picture ( mocnam, &moc ) ;
			printf ( " (%d)\n", result ) ;
		
			free_moc_pic ( &moc ) ;
		}
		free_esm_pic ( &esm ) ;
	}
	return ( result ) ; 
}


/*----------------------------------------------------- filter_rect -*/
void filter_rect ( void *source, void *dest,
				  int dx, int dy, int color )
{
	int xi, yi ;
	byte b, *sp, *dp ;


	/* step 1 : copy picture	*/
		
	sp = source ;
	dp = dest ;

	for ( yi = 0; yi < dy; yi++ )
	{
		for ( xi = 0 ; xi < dx ; xi++ )
		{
			*dp++ = *sp++ ;
		}
	}
	
	/* step 2 : filter picture	*/

	sp = source ;
	dp = dest ;

	for ( yi = 1; yi < dy-1; yi++ )
	{
		for ( xi = 1 ; xi < dx-1 ; xi++ )
		{
			b = *sp++ ;
# if 1
# define pix_ok(pv) ( pv == color )
			if ( pix_ok(b)
				&& pix_ok(*(sp-2))
				&& pix_ok(*(sp))
				&& pix_ok(*(sp-dx-1))
				&& pix_ok(*(sp+dx-1)) )
# else
			if ( b == color )
# endif
				*dp = b ;
			dp++ ;
		}
	}
}


/*--------------------------------------------- i16_to_moc ---------*/
int i16_to_moc ( I16pic	*i16, MOCpic *moc )
{
	int	result, cix;
	unsigned char *i16p ;
	RGB *mocp ;
	long data_size ;

	clear_moc_pic ( moc ) ;

	result = malloc_moc_pic ( moc, i16->head->_xres, i16->head->_yres ) ;

	if ( result == OK )
	{
		mocp = *(moc->palette) ;
		i16p = (unsigned char *) *(i16->palette) ;
		for ( cix = 0; cix < 256; cix++ )
		{
			mocp->rsrvd = 0 ;
			if ( i16->head->_maxgrey >= 256 )
			{
				mocp->r = *i16p++ ;
				mocp->g = *i16p++ ;
				mocp->b = *i16p++ ;
			}
			else
			{
				mocp->r = *i16p++ << 2 ;
				mocp->g = *i16p++ << 2 ;
				mocp->b = *i16p++ << 2 ;
			}
			mocp++ ;
		}
		data_size = (long)i16->head->_xres * (long)i16->head->_yres ;
		memcpy ( moc->data, i16->data, data_size ) ;
	}
	return ( result ) ; 
}


/*--------------------------------------------- mcc_to_moc ---------*/
int mcc_to_moc ( MCCpic	*mcc, MOCpic *moc )
{
	int		result ;

	clear_moc_pic ( moc ) ;

	result = malloc_moc_pic ( moc, mcc->head->breite, mcc->head->hoehe ) ;

	if ( result == OK )
	{
		copy_palette ( moc->palette, mcc->palette ) ;
		result = uncompress_window ( moc->data, mcc->head->breite,
							0, 0, mcc );
		if ( result != OK )
			free_moc_pic ( moc ) ;
	}
	return ( result ) ; 
}


/*------------------------------------------ uncompress_mcc_file ---*/	
int uncompress_mcc_file ( char *mccnam, char *mocnam )
{
	MCCpic mcc ;
	MOCpic moc ;
	int result ;

	clear_mcc_pic ( &mcc ) ;
	printf ( "read mcc .." ) ;
	result = read_mcc_picture ( mccnam, &mcc ) ;
	printf ( " (%d)\n", result ) ;

	if ( result == OK )
	{
		print_pic_head ( mcc.head ) ;

		printf ( "uncompress mcc .." ) ;
		result = mcc_to_moc ( &mcc, &moc ) ;
		if ( result == OK )
		{
			printf ( "write moc .." ) ;
			result = write_moc_picture ( mocnam, &moc ) ;
			printf ( " (%d)\n", result ) ;
			free_moc_pic ( &moc ) ;
		}
		free_mcc_pic ( &mcc ) ;
	}
	return ( result ) ; 
}


/*-------------------------------------------- compress_moc_file ---*/	
int compress_moc_file ( char *mocnam, char *mccnam )
{
	MCCpic mcc ;
	MOCpic moc ;
	int result ;

	clear_mcc_pic ( &mcc ) ;
	clear_moc_pic ( &moc ) ;

	printf ( "read moc .." ) ;
	result = read_moc_picture ( mocnam, &moc ) ;
	printf ( " (%d)\n", result ) ;

	if ( result == OK )
	{
		print_pic_head ( moc.head ) ;

		printf ( "malloc mcc .." ) ;
		result = malloc_mcc_pic ( &mcc, moc.head->breite, moc.head->hoehe ) ;
		printf ( " (%d)\n", result ) ;

		if ( result == OK )
		{
			printf ( "compress moc .." ) ;
			copy_palette ( mcc.palette, moc.palette ) ;
			result = compress_window ( moc.data, moc.head->breite,
							0, 0, moc.head->breite, moc.head->hoehe,
							&mcc );
			printf ( " (%d)\n", result ) ;
	
			if ( result == OK )
			{
				printf ( "write mcc .." ) ;
				result = write_mcc_picture ( mccnam, &mcc ) ;
				printf ( " (%d)\n", result ) ;
			
			}
			free_mcc_pic ( &mcc ) ;
		}
		free_moc_pic ( &moc ) ;
	}
	return ( result ) ; 
}


/*-------------------------------------------- flat_esm_picture ---*/	
void flat_esm_picture ( PIChead *head, byte *data, int bits )
{
	long size ;
	char mask ;
	
	mask = (char) ( 0xff00 >> bits ) ;
	
	size = pic_data_size ( head ) ;
	while ( size-- > 0 )
		*data++ &= mask ;
}



/*-------------------------------------------- moc_to_esm ---*/	
int moc_to_esm ( PIChead *moc_head, PALETTE *palette, byte *moc_data,
				 PIChead **esm_head, byte **esm_data )
{
	long size ;
	byte *esmdat ;
	byte *colb ;

	size = pic_data_size ( moc_head ) ;
	*esm_head = Mdalloc ( sizeof ( PIChead ) ) ;
	if ( *esm_head == NULL )
		return ( NOmemory ) ;

	*esm_data = esmdat = Mdalloc ( 3 * size ) ;
	if ( esmdat == NULL )
	{
		Mfree ( *esm_head ) ;
		return ( NOmemory ) ;
	}
		
	copy_head ( *esm_head, moc_head ) ;
	(*esm_head)->tiefe = ESMtiefe ;

	while ( size-- > 0 )
	{
		colb = &(*palette)[*moc_data++].r ;
		*esmdat++ = *colb++ ;	/* R	*/
		*esmdat++ = *colb++ ;	/* G	*/
		*esmdat++ = *colb++ ;	/* B	*/
	}
	return ( OK ) ;
}


/*----------------------------------------------------- tifs_to_esm -------*/
int tifs_to_esm ( RGBtifs *tifs, ESMpic *esm )
{
	int result ;
	byte *rr,*gg,*bb,
		 *dd ;
	long l ;
	
	result = malloc_esm_pic ( esm, (*tifs)[R].head->breite,
								  (*tifs)[R].head->hoehe ) ;
	if ( result == OK )
	{
		rr = (*tifs)[R].data ;
		gg = (*tifs)[G].data ;
		bb = (*tifs)[B].data ;
		
		dd = esm->data ;
		for ( l = tif_data_size ( (*tifs)[R].head ) ; l > 0 ; l-- )
		{
			*dd++ = ~ *rr++ ;
			*dd++ = ~ *gg++ ;
			*dd++ = ~ *bb++ ;
		}
	}
	
	return ( result ) ;
}	
