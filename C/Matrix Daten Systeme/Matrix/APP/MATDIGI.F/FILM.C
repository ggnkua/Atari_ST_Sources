/* film.c */

# define TEST 0
# define ALIGNy	0	/* ??16 , 2^n ! 	*/

# if ALIGNy > 1
# define _Align(v)	((v+(ALIGNy-1))&~(ALIGNy-1))
# else
# define _Align(v)	(v)
# endif

# include <stdio.h>
# include <string.h>
# include <stdlib.h>
# include <ctype.h>
# include <tos.h>
# include <linea.h>
# include <portab.h>
# include <ext.h>

# include <global.h>
# include <scancode.h>
# include <picfiles.h>
# include <sys_vars.h>
# include <fast.h>
# include <file.h>

# include <vdi.h>		/* needed only for MFDB declaration in jpgdh.h */
# include "d:\pc\app\jpeg_dsp\if\jpgdh.h"
# include "d:\pc\app\jpeg_dsp\if\if.h"

# include "yc.h"
# include "yc_fast.h"
# include "tools.h"

# include "digiblit.h"
# include "digitise.h"

# include "initdmsd.h"
# include "digiblix.h"
# include "stretch.h"
# include "tic.h"
# include "tga.h"
# include "\pc\app\jpeg\jpeg_dec.h"
# include "\pc\app\jpeg\jpeg_com.h"

# include "film.h"
# include "filmx.h"

# define GetTimeCode()	get_lcont(_hz_200)

/*---------------------------------------- DigitiseMatrix --------*/
void DigitiseMatrix ( int nx, int ny, TBlitWindow *blitwind, POINT *zoom, bool wait )
{
	int xi, yi ;
	
	blitwind->dst.window.y = 0 ;
	blitwind->dst.window.w = blitwind->dst.image.w / nx ;
	blitwind->dst.window.h = blitwind->dst.image.h / ny ;

	for ( yi = 0; yi < ny; yi++ )
	{
		blitwind->dst.window.x = 0 ;
		for ( xi = 0; xi < nx; xi++ )
		{
			if ( verbose )
			{
				StatusLine();
				(*uprintf) ( "* frame %2d : %2d", yi, xi ) ;
			}
			DigitiseFrame ( blitwind, zoom, wait ) ;
			blitwind->dst.window.x += blitwind->dst.window.w ;
		}
		blitwind->dst.window.y += blitwind->dst.window.h ;
	}
	blitwind->dst.window.x = blitwind->dst.window.y = 0 ;	/* reset to first frame	*/
}

# define KB	1024L

# define RESmem		 0 /* (512L*KB)	*/
# define RESframes	20 /* 0 		*/

/*---------------------------------------- AvailableFrames ---------*/
int AvailableFrames ( long framesize )
{
	long  available ;
	int   frames ;

	available = (long)Malloc(-1) ;
	frames = (int) ( ( available - RESmem ) / framesize ) ;
	if ( frames < 0 )
		frames = 0 ;
	if ( verbose )
		(*uprintf) ( "MEM(KB) sys=%ld, res=%ld, #f=%d\n",
				available/KB, RESmem/KB, frames ) ;
	return frames ;
}


/*---------------------------------------- InitSequence ------------*/
int InitSequence ( SEQUENCE *sequence )
{
	int i ;
	IMAGE *image ;

	sequence->frames = sequence->valid = 0 ;
	sequence->current = 0 ;

	image = sequence->images ;
	for ( i = 0; i < MAXframesPerSequence; i++, image++ )
	{
		image->data	 = NULL ;
		image->delay = 0 ;
	}
	return MAXframesPerSequence ;
}


/*---------------------------------------- MallocSequence --------*/
int MallocSequence ( SEQUENCE *sequence, int nreq, TImageWindow *srcwnd, POINT *zoom )
{
	int i, available ;
	IMAGE *image ;
# if TEST
	long  start, time ;
# endif
	
	if ( verbose )
	{
		(*uprintf) ( "* malloc sequence, req=%d\n"
				 "base blit wind :\n", nreq ) ;
		ImageWindowInfo ( "", srcwnd ) ;
	}	

	InitSequence ( sequence ) ;
	
	sequence->blitwind.src = *srcwnd ;
	SetToFullSize ( &sequence->blitwind.dst, NULL,
					srcwnd->window.w, srcwnd->window.h, 16 ) ;

	sequence->zoom 	    = *zoom ;
	sequence->framesize = (long)_Align(srcwnd->window.h)
								* (long)sequence->blitwind.dst.image.bpl ;
	if ( verbose )
	{
		(*uprintf) ( "sequence blit wind :\n" ) ;
		BlitWindowInfo ( &sequence->blitwind ) ;
		(*uprintf) ( "frame size = %ld\n", sequence->framesize ) ;
	}

	if ( nreq < 0 || nreq > MAXframesPerSequence )
		nreq = MAXframesPerSequence ;

	available = AvailableFrames ( sequence->framesize ) ;
	if ( nreq > available )
		nreq = available ;

# if TEST
	start = GetTimeCode();
# endif

	image = sequence->images ;
	for ( i = 0; i < nreq; i++, image++ )
	{
		image->data = malloc ( sequence->framesize ) ;
		if ( image->data == NULL )
			break ;
		image->delay = 0 ;
	}

# if TEST		/* 1/200 sec -> 1/100 sec	*/
	time = ( GetTimeCode() - start ) * 5 ;
	printf ( "mallocs : %d, time = %lu.%03lu sec\n",
							i, time / 1000L, time % 1000L ) ;
# endif

# if RESframes	/* free images */
	{
		int n ;
		
		for ( n = RESframes; n > 0 ; n-- )
		{
			image-- ;
			i-- ;
			free ( image->data ) ;
			image->data = NULL ;
		}
	}
# endif

	if ( verbose )
	{
		StatusLine();
		(*uprintf) ( "* %d frames requested, %d malloced", nreq, i ) ;
	}
	sequence->frames = i ;
	sequence->valid = 0 ;
	
	return sequence->frames ;
}


/*---------------------------------------- SequenceLength --------*/
long SequenceLength ( SEQUENCE *sequence )
{
	IMAGE    *image ;
	int 	i ;
	long	len ;
	
	image = sequence->images ;
	for ( len = i = 0 ; i < sequence->valid; i++, image++ )
		len += image->delay ;

	return len ;
}

/*---------------------------------------- SequenceInfo --------*/
void SequenceInfo ( SEQUENCE *sequence )
{
	unsigned time, freq ;
	
	if ( sequence->frames > 0 )
	{
		printf ( "sequence blit window :\n" ) ;
		BlitWindowInfo ( &sequence->blitwind ) ;
		printf ( "frame size = %ld\n", sequence->framesize ) ;
		printf ( "format = $%02x\n", sequence->format ) ;

		printf ( "%d of %d valid\033K\n", sequence->valid, sequence->frames ) ;
		if ( sequence->valid > 0 )
		{
			/* 1/200 sec -> 1/10 sec	*/
			time = (unsigned)( SequenceLength(sequence) / 20L ) ;
			printf ( "time = %u.%u sec", time / 10, time % 10 ) ;
			if ( time > 0 )
			{
				freq = ( sequence->valid * 100 ) / time ;
				printf ( ", %u Hz\n", freq / 10, freq % 10  ) ;
				{
					int i, maxi ;
					IMAGE *image ;
		
					image = sequence->images ;
					maxi = min ( 10, sequence->valid ) ;
					for ( i = 0; i < maxi; i++, image++ )
						printf ( "%2d : %6ld\033K\n", i, image->delay ) ;
				}
			}
			else
				printf ( "\n" ) ;
		}
	}
	else
		printf ( "- sequence not defined\033K\n" ) ;
}


# define FILMbaseNameFormat			"%s.flm"
# define FILMblkImageNameFormat		"%s%04u.flm"
# define FILMtgaImageNameFormat		"%s%04u.tga"
# define FILMticImageNameFormat		"%s%04u.tic"
# define FILMrgbImageNameFormat		"%s%04u.rgb"
# define FILMjpegImageNameFormat	"%s%04u.jpg"

# if 0
TTgaHeader TgaHead16 =	DEFtga16 ;
# else
TTgaHeader TgaHead16 =
{
	{ 0x00,0x00,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 },
	REVint(384), REVint(480), 16, 0
} ;
# endif

/*-------------------------------------- RevInt -------------*/
int RevInt ( int i )
{
	return REVint ( i ) ;
}


/* falcon format : 55o5	*/
/*	r  r  r  r  r  g  g  g . g  g  o  b  b  b  b  b  */
/*	15 14 13 12 11 10 9  8 . 7  6  5  4  3  2  1  0	*/

/* targa : */
/*  normal */
/*	0  r  r  r  r  r  g  g . g  g  g  b  b  b  b  b  */
/*	15 14 13 12 11 10 9  8 . 7  6  5  4  3  2  1  0	*/
/*  reversed */
/*	g  g  g  b  b  b  b  b . 0  r  r  r  r  r  g  g  */
/*	15 14 13 12 11 10 9  8 . 7  6  5  4  3  2  1  0	*/

typedef union { uword w ; byte  b[2] ; } TUwordBytes ;

void *ConvBuffer    = NULL ;
long ConvBufferSize = 0 ;

TTicHeader TicHeader = DEFAULTticHeader ;
TTicHeader ReadTicHeader ;


/*-------------------------------- FreeConvBuffer --------*/
void FreeConvBuffer ( void )
{
	if ( ConvBuffer != NULL )
		free ( ConvBuffer ) ;
	ConvBuffer = NULL ;
	ConvBufferSize = 0 ;
}



/*-------------------------------- GetConvBuffer --------*/
void *GetConvBuffer ( long size )
{
	if ( ConvBufferSize < size )
	{
		if ( ConvBuffer != NULL )
			free ( ConvBuffer ) ;
		ConvBuffer = NULL ;
		ConvBufferSize = 0 ;
	}

	if ( ConvBuffer == NULL )
	{
		ConvBuffer = malloc ( size ) ;
		if ( ConvBuffer != NULL )
			ConvBufferSize = size ;
	}
	return ConvBuffer ;
}


/*-------------------------- TargaToFalconBlock ----------*/
void TargaToFalconBlock ( uword *in, uword *out, int w, int h, long size )
{
	int xi, yi ;
	TUwordBytes falcon ;
	byte *bin ;

	bin = (byte *)in ;
	out = out + (size>>1) - w ;		/* -> start of last line	*/
	for ( yi = 0 ; yi < h ; yi++ )
	{
		for ( xi = 0 ; xi < w ; xi++, in++ )
		{
			falcon.b[1] = *bin++ ;	/* lower byte */
			falcon.b[0] = *bin++ ;	/* upper byte */
						/* shift r & g << 1 		         b ==	*/
			*out++ = ( ( falcon.w & 0x7fe0 ) << 1 )  | ( falcon.w & 0x1f ) ;
		}
		out -= 2 * w ;	/* back 2 lines */
	}
}



/*-------------------------- FalconToTargaBlock ----------*/
void FalconToTargaBlock ( uword *in, uword *out, int w, int h, long size )
{
	int xi, yi, bpl ;
	TUwordBytes targa ;
	byte *bout ;

	bpl = 2 * w ;
	bout = ((byte *)out) + size - bpl ;	/* start of last line	*/
	for ( yi = 0 ; yi < h ; yi++ )
	{
		for ( xi = 0 ; xi < w ; xi++, in++ )
		{				/* shift r & g >> 1 		b ==	*/
			targa.w = ( ( *in >> 1 ) & 0x7fe0 ) | ( *in & 0x1f ) ;
			*bout++ = targa.b[1] ;	/* lower byte */
			*bout++ = targa.b[0] ;	/* upper byte */
		}
		bout -= 2 * bpl ;	/* back 2 lines */
	}
}

/*-------------------------- FalconToRBlock ----------*/
void FalconToRBlock ( uword *in, byte *out, long pixels )
{
	while ( pixels-- > 0 )
		*out++ = (byte)( *in++ >> 11 ) ;
}

/*-------------------------- FalconToGBlock ----------*/
void FalconToGBlock ( uword *in, byte *out, long pixels )
{
	while ( pixels-- > 0 )
		*out++ = (byte)( ( *in++ >> 6 ) & 0x1f ) ;
}

/*-------------------------- FalconToBBlock ----------*/
void FalconToBBlock ( uword *in, byte *out, long pixels )
{
	while ( pixels-- > 0 )
		*out++ = (byte)( *in++ & 0x1f ) ;
}



/*------------------------------------------------------- SetTicHeader --------------*/
long SetTicHeader ( TTicHeader *th, int w, int h )
{
	long pixels, offset ;
    int plane ;

	th->numtags[0].value[0] = w ;
	th->numtags[1].value[0] = h ;
	offset = 0x0074 ;
	pixels = (long)w * (long)h ;
	for ( plane = 0; plane < 3; plane++ )
	{
		th->stripoffs[plane] = offset ;
		offset += pixels ;
	}
    return pixels ;
}


/*------------------------------------------------------- NtcToTic --------------*/
void NtcToTic ( uword *in, byte *out, long pixels )
{
	byte *c, *m, *y;
	uword ntc ;

	y = ( m = ( c = out ) + pixels ) + pixels ;
	while ( pixels-- > 0 )
	{
		ntc = *in++;

		*c++ = (~(ntc>>8)) & 0xf8 ;
		*m++ = (~(ntc>>3)) & 0xf8 ;
		*y++ = (~(ntc<<3)) & 0xf8 ;
    }
}

# define ToNtc(r,g,b) (((r)&0xf8)<<8)|(((g)&0xf8)<<3)|(((b)&0xf8)>>3)

/*------------------------------------------------------- TicToNtc --------------*/
void TicToNtc ( byte *in, uword *out, long pixels )
{
	byte *c, *m, *y;

	y = ( m = ( c = in ) + pixels ) + pixels ;
	while ( pixels-- > 0 )
		*out++ = ToNtc( ~*c++, ~*m++, ~*y++ ) ;
}



/*-------------------------- WriteRGBFiles ---------------------*/
int WriteRGBFiles ( char *filename, int w, int h, uword *data )
{
	char *rgbpos ;
	byte *wbuffer ;
	long  pixels ;
	int	  result ;
	
	if ( verbose )
		(*uprintf) ( "write rgb files : %s\n", filename ) ;

	result = -1 ;
	if ( ( rgbpos = strchr ( filename, '#' ) ) != NULL )
	{
		pixels = (long)w * (long)h ;

		if ( ( wbuffer = GetConvBuffer ( pixels ) ) != NULL )
		{
	/*R*/	FalconToRBlock ( data, wbuffer, pixels ) ;
			*rgbpos = 'r' ;
			if ( verbose )
				(*uprintf) ( "write r file : %s\n", filename ) ;
			result = write_block ( filename, wbuffer, pixels ) ;

	/*G*/	if ( result == OK )
			{
				FalconToGBlock ( data, wbuffer, pixels ) ;
				*rgbpos = 'g' ;
				if ( verbose )
					(*uprintf) ( "write g file : %s\n", filename ) ;
				result = write_block ( filename, wbuffer, pixels ) ;
			}
	
	/*B*/	if ( result == OK )
			{
				FalconToBBlock ( data, wbuffer, pixels ) ;
				*rgbpos = 'b' ;
				if ( verbose )
					(*uprintf) ( "write b file : %s\n", filename ) ;
				result = write_block ( filename, wbuffer, pixels ) ;
			}

			FreeConvBuffer();
		}
	}

	return result ;							 
}

# if 0
/*-------------------------------- WriteJpegFile -------------------*/
int WriteJpegFile ( char *filename, int w, int h, uword *data )
{
	uword *wbuffer ;
	long size ;
	int	 result ;
	
	if ( verbose )
		(*uprintf) ( "write file : %s\n", filename ) ;

	size = (long)(w*2) * (long)h ;

	if ( ( wbuffer = GetConvBuffer ( size ) ) != NULL )
	{
		result = ntc_to_jpeg ( filename, data, w, h ) ;
		FreeConvBuffer();
	}
	else
		result = -1 ;

	return result ;							 
}
# endif


/*-------------------------- WriteTargaFile ---------------------*/
int WriteTargaFile ( char *filename, int w, int h, uword *data )
{
	uword *wbuffer ;
	long size ;
	int	 result ;
	
	if ( verbose )
		(*uprintf) ( "write file : %s\n", filename ) ;

	size = (long)(w*2) * (long)h ;

	TgaHead16.w = RevInt ( w ) ;
	TgaHead16.h = RevInt ( h ) ;
	
	if ( ( wbuffer = GetConvBuffer ( size ) ) != NULL )
	{
		FalconToTargaBlock ( data, wbuffer, w, h, size ) ;
		result = write_blocks ( filename,
							  &TgaHead16, sizeof ( TgaHead16 ),
							  wbuffer, size ) ;
		FreeConvBuffer();
	}
	else
		result = -1 ;

	return result ;							 
}


/*--------------------------------- WriteFrame ---------------------*/
int WriteFrame ( SEQUENCE *sequence, char *basename, int frame )
{
	char  filename[128] ;
	void  *wbuffer ;
	IMAGE *image ;

	image = &sequence->images[frame] ;

	if ( image->data != NULL )
	{

		switch ( sequence->format )
		{
case TICformat :
			{
			long pixels, datasize ;
			
			sprintf ( filename, FILMticImageNameFormat, basename, frame ) ;
			pixels = SetTicHeader ( &TicHeader,
									sequence->blitwind.dst.image.w,
									sequence->blitwind.dst.image.h ) ;
			datasize = 3 * pixels ;
			if ( ( wbuffer = GetConvBuffer ( datasize ) ) != NULL )
			{
				NtcToTic ( image->data, (byte *)wbuffer, pixels ) ;
				return write_blocks ( filename,
										&TicHeader, sizeof ( TicHeader ),
										wbuffer, datasize ) ;
			}
			else
				return -1 ;
			}
			
		
case TGAformat :
			sprintf ( filename, FILMtgaImageNameFormat, basename, frame ) ;

			TgaHead16.w = RevInt ( sequence->blitwind.dst.image.w ) ;
			TgaHead16.h = RevInt ( sequence->blitwind.dst.image.h ) ;
	
			if ( ( wbuffer = GetConvBuffer ( sequence->framesize ) ) != NULL )
			{
				FalconToTargaBlock ( image->data,
							 wbuffer,
							 sequence->blitwind.dst.image.w,
							 sequence->blitwind.dst.image.h,
							 sequence->framesize ) ;
				return write_blocks ( filename,
						&TgaHead16, sizeof ( TgaHead16 ),
						wbuffer, sequence->framesize ) ;
			}
			else
				return -1 ;
case JPGformat :
			sprintf ( filename, FILMjpegImageNameFormat, basename, frame ) ;
			if ( verbose && frame < 4 )
				printf ( "write jpg file : %s\n", filename ) ;	
			return ntc_to_jpeg ( filename, image->data,
									 sequence->blitwind.dst.image.w,
									 sequence->blitwind.dst.image.h ) ;
									 
case BLKformat :
			sprintf ( filename, FILMblkImageNameFormat, basename, frame ) ;
			return write_block ( filename,
								image->data, sequence->framesize ) ;
							
case RGBformat :
			if ( strchr ( basename, '#' ) == NULL )
			{
				sprintf ( filename, FILMrgbImageNameFormat, basename, frame ) ;
				return WriteRGBFiles ( filename,
							   sequence->blitwind.dst.image.w,
							   sequence->blitwind.dst.image.h,
							   image->data ) ;
			}
			else
				return -1 ;
default :
			return -1 ;
		}
	}
	else
		return -1 ;
}


/*------------------------------------ WriteSequenceHeader ---------------*/
int WriteSequenceHeader ( SEQUENCE *sequence, char *basename, uword format )
{
	char 	 filename[128] ;

	if ( format == USEdefault )
		sequence->format = DEFformat ;
	else if ( format != USEcurrent )
		sequence->format = format ;

	sprintf ( filename, FILMbaseNameFormat, basename ) ;
	if ( verbose )
		(*uprintf) ( "\nbase : %s\n", filename ) ;
	return write_block ( filename, sequence, sizeof ( SEQUENCE ) ) ;
}


/*------------------------------------------------- WriteSingleFrame -----*/
int WriteSingleFrame ( SEQUENCE *sequence, char *basename, int frame )
{
	char  filename[128] ;
	IMAGE *image ;

	image = &sequence->images[frame] ;

	if ( image->data != NULL )
	{
		sprintf ( filename, "%s.tga", basename ) ;
		if ( verbose )
			(*uprintf) ( "write : %s\n", filename ) ;
		return WriteTargaFile ( filename,
						  sequence->blitwind.dst.image.w,
			 			  sequence->blitwind.dst.image.h,
			 			  image->data ) ;
	}
	else
		return -1 ;
}


/*------------------------------------------------- SequenceWrite --------*/
int SequenceWrite ( SEQUENCE *sequence, char *basename, int from, int to, uword format )
{
	int  frame, n ;
	
	n = 0 ;
	if ( sequence->frames > 0 && sequence->valid > 0	/* seq ok	*/
	  && from <= to && from < sequence->valid )			/* range ok	*/
	{
		if ( from == to )	/* single picture	*/
		{
			if ( WriteSingleFrame ( sequence, basename, from ) == OK )
				n = 1 ;
		}
		else
		{
			if ( WriteSequenceHeader ( sequence, basename, format ) == OK )
			{
				if ( to >= sequence->valid )
					to = sequence->valid - 1 ;
				{
					for ( frame = from; frame <= to; frame++, n++ )
					{
						if ( WriteFrame ( sequence, basename, frame ) != OK )
							break ;
					}
				}
			}
			if ( verbose )
				(*uprintf) ( "\nwritten : 1 + %i files\n", n ) ;
		}
		FreeConvBuffer();
	}
	return n ;
}



/*---------------------------------------- ReadTicFrame --------*/
int ReadTicFrame ( SEQUENCE *sequence, char *basename, int frame )
{
	char 	filename[128] ;
	IMAGE 	*image ;
	long	rdlen ;
	int		result ;
	byte	*rbuffer ;
	long	pixels, rawsize ;
		
	image = &sequence->images[frame] ;
	sprintf ( filename, FILMticImageNameFormat, basename, frame ) ;
	if ( verbose )
			(*uprintf) ( "\rtic-sequ : %s", filename ) ;

	pixels = (long)sequence->blitwind.dst.image.w *
			 (long)sequence->blitwind.dst.image.h ;
	rawsize = 3 * pixels ;
	if ( ( rbuffer = GetConvBuffer ( rawsize ) ) != NULL )
	{
		if ( ( result = read_blocks ( filename,
						&ReadTicHeader, sizeof ( ReadTicHeader ),
						rbuffer, rawsize, &rdlen ) ) == OK )
		{
			TicToNtc ( rbuffer, image->data, pixels ) ;
		}
		else
		{
			if ( verbose )
				(*uprintf) ( "\nfile not found\n" ) ;
		}
	}
	else
		result = -1 ;

	return result ;
}

/*---------------------------------------- ReadTargaFrame --------*/
int ReadTargaFrame ( SEQUENCE *sequence, char *basename, int frame )
{
	char 	filename[128] ;
	IMAGE 	*image ;
	long	rdlen ;
	int		result ;
	uword	*rbuffer ;
	
	image = &sequence->images[frame] ;
	sprintf ( filename, FILMtgaImageNameFormat, basename, frame ) ;
	if ( verbose )
			(*uprintf) ( "\rtga-sequ : %s", filename ) ;

	if ( ( rbuffer = GetConvBuffer ( sequence->framesize ) ) != NULL )
	{
		if ( ( result = read_blocks ( filename,
						&TgaHead16, sizeof ( TgaHead16 ),
						rbuffer, sequence->framesize, &rdlen ) ) == OK )
		{
			TargaToFalconBlock ( rbuffer,
							 	 image->data,
								 sequence->blitwind.dst.image.w,
								 sequence->blitwind.dst.image.h,
								 sequence->framesize ) ;
		}
		else
		{
			if ( verbose )
				(*uprintf) ( "\nfile not found\n" ) ;
		}
	}
	else
		result = -1 ;

	return result ;
}




/*---------------------------------------- ReadJpegFrame --------*/
int ReadJpegFrame ( SEQUENCE *sequence, char *basename, int frame )
{
	char 	filename[128] ;
	IMAGE 	*image ;
	int		result ;
	ERROR	err ;
	MFDB 	mfdb ;
	long	outsize ;
	
	image = &sequence->images[frame] ;
	sprintf ( filename, FILMjpegImageNameFormat, basename, frame ) ;
	if ( verbose )
		(*uprintf) ( "\rblk-sequ : %s", filename ) ;

# if ALIGNy > 1
	err = JpegDecodeToBuffer ( filename, RGBout, 2, image->data,
								sequence->framesize, &mfdb ) ;
# else
	err = JpegDecodeToMemory ( filename, RGBout, 2, &mfdb, &outsize ) ;
# endif

	switch ( err )
	{
 case OK :
# if ALIGNy > 1
		if (   mfdb.fd_w != sequence->blitwind.dst.image.w
			|| mfdb.fd_h != sequence->blitwind.dst.image.h )
		{
			if ( verbose )
				(*uprintf) ( "jpeg file dimension mismatch\n" ) ;
			result = -1 ;
		}
		else
			result = OK ;
# else

		{
			int win, wdiff, h ;
			/* win   = mfdb.fd_wdwidth << 4 ;	*/
			win = ( mfdb.fd_w + 15 ) & ~15 ;
			wdiff = win - sequence->blitwind.dst.image.w ;
			h = min ( sequence->blitwind.dst.image.h, mfdb.fd_h ) ;
# if 0
					printf ( "\033Hmfdb = $%p - %d:%d    \n",
							mfdb.fd_addr,
							mfdb.fd_w,
							mfdb.fd_h ) ;
					printf ( "ww=%d, std=%d, pln=%d      \n",
							mfdb.fd_wdwidth,
							mfdb.fd_stand,
							mfdb.fd_nplanes ) ;
					printf ( "win=%d, wdiff=%d, h=%d     \n",
										 win, wdiff, h ) ;
# endif
			if ( wdiff >= 0 )
				Blit555Rect ( mfdb.fd_addr, image->data, 
						  	  sequence->blitwind.dst.image.w, h,
						  	  wdiff, 0 ) ;
			else
				Blit555Rect ( mfdb.fd_addr, image->data, 
						  	  win, h,
						  	  0, wdiff ) ;
			result = OK ;
		}
		free ( mfdb.fd_addr ) ;
# endif
		break ;

 case NOjpgCookie :
		if ( ( result = jpeg_to_ntc_window ( filename, image->data,
										0, 0,
										sequence->blitwind.dst.image.w,
						 				sequence->blitwind.dst.image.h,
										2 * sequence->blitwind.dst.image.w ) ) != OK )
		{
			if ( verbose )
				(*uprintf) ( "\nfile not found\n" ) ;
		}
		break ;
 default :
 		if ( verbose )
			(*uprintf) ( "dsp jpeg error #%d : %s\n", err, GetJpegErrorText ( err ) ) ;
 		result = -1 ;
		break ;
	}

	return result ;
}

/*---------------------------------------- ReadBlockFrame --------*/
int ReadBlockFrame ( SEQUENCE *sequence, char *basename, int frame )
{
	char 	filename[128] ;
	IMAGE 	*image ;
	long	rdlen ;
	int		result ;
	
	image = &sequence->images[frame] ;
	sprintf ( filename, FILMblkImageNameFormat, basename, frame ) ;
	if ( verbose )
			(*uprintf) ( "\rblk-sequ : %s", filename ) ;
	if ( ( result = read_block ( filename, image->data, sequence->framesize, &rdlen ) ) != OK )
	{
		if ( verbose )
			(*uprintf) ( "\nfile not found\n" ) ;
	}

	return result ;
}


/*-------------------------- ReadSequenceHeader ---------------------*/
int ReadSequenceHeader ( SEQUENCE *sequence, char *basename )
{
	char 	 filename[128] ;
	IMAGE 	 *image ;
	int 	 frame, available ;
	long	 rdlen ;
	int 	 result ;
	
	sprintf ( filename, FILMbaseNameFormat, basename ) ;
	if ( verbose )
		(*uprintf) ( "\033Ebase : %s\n", filename ) ;
	if ( ( result = read_block ( filename, sequence, sizeof ( SEQUENCE ), &rdlen ) ) == OK )
	{
		if ( verbose )
			SequenceInfo ( sequence ) ;		
		/* clear all data pointers	*/
		image = sequence->images ;
		for ( frame = 0; frame < MAXframesPerSequence; frame++, image++ )
			image->data = NULL ;

# if ALIGNy > 1
		if ( sequence->format == JPGformat )
			sequence->framesize = (long)_Align(sequence->blitwind.dst.image.h)
										* (long)sequence->blitwind.dst.image.bpl ;
# endif

		available = AvailableFrames ( sequence->framesize ) ;
		if ( sequence->valid > available )
		{
			if ( verbose )
				(*uprintf) ( "memory only for %d of %d frames\n", available, sequence->valid ) ;
			sequence->valid = available ;
		}
		return OK ;
	}
	else
		return result ;
}


/*---------------------------------------- ReadFrame -----------*/
int ReadFrame ( SEQUENCE *sequence, char *basename, int frame )
{
	IMAGE *image ;
	int   result ;
	
	image = &sequence->images[frame] ;
	if ( image->data == NULL )
	{
		image->data = malloc ( sequence->framesize ) ;
		if ( image->data == NULL )
		{
			if ( verbose )
				(*uprintf) ( "\nout of memory\n" ) ;
			return -1 ;
		}
		sequence->frames = frame ;
	}

	switch ( sequence->format )
	{
  case TICformat :	result = ReadTicFrame ( sequence, basename, frame ) ;	break ;
  case TGAformat :	result = ReadTargaFrame ( sequence, basename, frame ) ;	break ;
  case BLKformat :	result = ReadBlockFrame ( sequence, basename, frame ) ;	break ;
  case JPGformat :	result = ReadJpegFrame ( sequence, basename, frame ) ;	break ;
  default :			result = -1 ;											break ;
	}
	if ( result == OK )
	{
		if ( frame > sequence->valid )
			sequence->valid = frame ;
	}
	return result ;
}


/*---------------------------------------- SequenceRead --------*/
int SequenceRead ( SEQUENCE *sequence, char *basename, int from, int to )
{
	int frame, n ;

	n = 0 ;	
	if ( ReadSequenceHeader ( sequence, basename ) == OK )
	{
		if ( from <= to && from < sequence->valid )			/* range ok	*/
		{
			if ( to >= sequence->valid )
				to = sequence->valid - 1 ;
			for ( frame = from; frame <= to; frame++, n++ )
			{
				if ( ReadFrame ( sequence, basename, frame ) != OK )
					break ;
			}
			FreeConvBuffer();
		}
	}

	sequence->frames = sequence->valid = frame ;
	sequence->current = 0 ;
	if ( verbose )
		(*uprintf) ( "\nread : 1 + %i files\n", n ) ;
	return n ;
}

/*---------------------------------------- FreeSequence --------*/
void FreeSequence ( SEQUENCE *sequence )
{
	int i ;
	IMAGE *image ;
	
	image = sequence->images ;
	for ( i = 0; i < sequence->frames && image->data != NULL; i++, image++ )
	{
		free ( image->data ) ;
		image->data  = NULL ;
		image->delay = 0 ;
	}
	sequence->frames  = 0 ;
	sequence->valid   = 0 ;
	sequence->current = 0 ;
}



/*.... record ...............................................*/

long  LastRecordTime = 0 ;

/*---------------------------------------- RecordStart --------*/
int RecordStart ( SEQUENCE *sequence )
{
	sequence = sequence ;
	LastRecordTime = GetTimeCode() ;
	return 0 ;
}

/*---------------------------------------- RecordRestart --------*/
int RecordRestart ( SEQUENCE *sequence )
{
	sequence = sequence ;
	LastRecordTime = GetTimeCode() ;
	return 0 ;
}

/*---------------------------------------- RecordStop --------*/
int RecordStop ( SEQUENCE *sequence )
{
	sequence = sequence ;
	return 0 ;
}



/*---------------------------------------- RecordFrame --------*/
int RecordFrame ( SEQUENCE *sequence, int frame, bool wait )
{
	IMAGE *image ;
	
	if ( frame >= 0 && frame < sequence->frames )
	{
		if ( frame > sequence->valid )
			frame = sequence->valid ;
	
		image = &sequence->images[frame] ;
		if ( image->data != NULL )
		{
			sequence->blitwind.dst.image.data = image->data ;
			DigitiseFrame ( &sequence->blitwind, &sequence->zoom, wait ) ;

			image->delay = frame > 0 ? (image-1)->delay	/* same delay as previous frame	*/
									 : 0 ;
			if ( frame == sequence->valid )
				sequence->valid++ ;
			sequence->current = frame + 1 ;
			return frame ;
		}
	}
	return -1 ;
}


/*---------------------------------------- RecordCurrFrame --------*/
int RecordCurrFrame ( SEQUENCE *sequence, bool wait )
{
	int   frame ;
	IMAGE *image ;
	long  currtime ;
	
	frame = sequence->current ;
	if ( frame < sequence->frames )
	{
		image = &sequence->images[frame] ;

		if ( image->data != NULL )
		{
			sequence->blitwind.dst.image.data = image->data ;
			DigitiseFrame ( &sequence->blitwind, &sequence->zoom, wait ) ;

			currtime = GetTimeCode() ;
			image->delay = (unsigned)( currtime - LastRecordTime ) ;
			LastRecordTime = currtime ;

			if ( frame >= sequence->valid )
				sequence->valid++ ;
			sequence->current = frame + 1 ;

			return frame ;
		}
	}
	return -1 ;
}


/*---------------------------------------- RecordSequence --------*/
int RecordSequence ( SEQUENCE *sequence, bool wait )
{
	int i ;
	IMAGE *image ;
	long  lasttime, currtime ;
		
	image = sequence->images ;
	if ( verbose )
		StatusLine();
	lasttime = GetTimeCode() ;
	for ( i = 0; i < sequence->frames; i++, image++ )
	{
		if ( SkipInput() )
		{
			if ( verbose )
				(*uprintf) ( "* stopped " ) ;
			goto exitloop ;
		}
		sequence->blitwind.dst.image.data = image->data ;
		DigitiseFrame ( &sequence->blitwind, &sequence->zoom, wait ) ;

		currtime = GetTimeCode() ;
		image->delay = (unsigned)( currtime - lasttime ) ;
		lasttime = currtime ;

		if ( verbose )
			(*uprintf) ( "# %3d - %6ld\r", i, image->delay ) ;
	}
	if ( verbose )
		StatusLine();
exitloop:
	if ( verbose )
		(*uprintf) ( "* %d frames recorded", i ) ;
	sequence->valid = i ;
	sequence->current = 0 ;
	return sequence->valid ;
}




/*---------------------------------------- ChkAndSetCurrentFrame --------*/
int ChkAndSetCurrentFrame ( SEQUENCE *sequence, int frame )
{
	if ( frame >= 0 && frame < sequence->valid )
	{
		sequence->current = frame ;
		return frame ;
	}
	else
	{
# if 0
		if ( frame >= -1 && frame <= sequence->valid )	/* limits	*/
# else
		if ( frame == sequence->valid )	/* limits	*/
# endif
			sequence->current = frame ;
		return -1 ;
	}
}


/*--------------------------------------------- ActivateFrame -----------*/
TValid ActivateFrame ( SEQUENCE *sequence, int frame )
{
	uword *data ;
	
	if ( frame >= 0 )
	{
		data = sequence->images[frame].data ;
		if ( data != NULL )
		{
			if ( frame < sequence->valid )
			{
				sequence->blitwind.dst.image.data = data ;
				sequence->current = frame ;
				return FR_DATAVALID ;
			}
			else if ( frame < sequence->frames )
			{
				sequence->current = sequence->valid ;
				return FR_BUFFERVALID ;
			}
		}
	}
	return FR_INVALID ;
}


/*---------------------------------------- CheckCurrentFrame -*/
void CheckCurrentFrame ( SEQUENCE *sequence )
{
	if ( sequence->current < 0 )
		sequence->current = 0 ;
	if ( sequence->current >= sequence->valid )
		sequence->current = sequence->valid ;
}


/*.... play ...............................................*/

long  LastPlayTime = 0 ;

/*---------------------------------------- PlayStart --------*/
int PlayStart ( SEQUENCE *sequence, int step )
{
	if ( step > 0 )
	{
		if ( sequence->current < 0 )
			sequence->current = 0 ;
	}
	else /* step < 0 */
	{
		if ( sequence->current >= sequence->valid )
				sequence->current = sequence->valid - 1 ;
	}
	LastPlayTime = GetTimeCode() ;
	return 0 ;
}

/*---------------------------------------- PlayRestart --------*/
int PlayRestart ( SEQUENCE *sequence )
{
	sequence = sequence ;
	LastPlayTime = GetTimeCode() ;
	return 0 ;
}


/*------------------------------------------- PlayStop --------*/
int PlayStop ( SEQUENCE *sequence )
{
	CheckCurrentFrame ( sequence ) ;
	return 0 ;
}



# define SEQend		-2
# define SEQnotSync	-1

/*---------------------------------------- PlaySyncCurrent --------*/
int PlaySyncCurrent ( SEQUENCE *sequence )
/*
	returns = SEQend : 		 sequence end
			  SEQnotSynced : not in sync
			  n			   : in sync
*/
{
	long nexttime ;

	if ( _DataValid(sequence,sequence->current) )
	{
		nexttime = LastPlayTime + sequence->images[sequence->current].delay ;
		if ( GetTimeCode() >= nexttime )
		{
			LastPlayTime = nexttime ;
			return sequence->current ;
		}
		else
			return SEQnotSynced ;
	}
	else
		return SEQend ;
}


/*---------------------------------------- DisplayCurrentFrame --------*/
int  DisplayCurrentFrame ( SEQUENCE *sequence, TImageWindow *dstwnd )
{
	uword *data ;
	
	if ( _DataValid(sequence,sequence->current) )
	{
		data = sequence->images[sequence->current].data ;
		if ( data != NULL )
		{
			sequence->blitwind.dst.image.data = data ;
			BlitFullSourceWindow ( &sequence->blitwind.dst, dstwnd ) ;
			return sequence->current ;
		}
	}
	return -1 ;
}



/*---------------------------------------- DisplayFrame --------*/
int  DisplayFrame ( SEQUENCE *sequence, int frame, TImageWindow *dstwnd )
{
	uword *data ;
	if ( ( frame = ChkAndSetCurrentFrame ( sequence, frame ) ) >= 0 )
	{
		data = sequence->images[frame].data ;
		if ( data != NULL )
		{
			sequence->blitwind.dst.image.data = data ;
			BlitFullSourceWindow ( &sequence->blitwind.dst, dstwnd ) ;
		}
		else
			frame = -1 ;
	}
	return frame ;
}



/*---------------------------------------- PlaySequence --------*/
int  PlaySequence ( SEQUENCE *sequence, TImageWindow *dstwnd )
{
	IMAGE	*image ;
	long  	currtime, nexttime ;

	if ( verbose )
		StatusLine();
	currtime = GetTimeCode() ;
	image = sequence->images ;
	for ( sequence->current = 0; sequence->current < sequence->valid; 
										sequence->current++, image++ )
	{
		for(;;)
		{
			if ( SkipInput() )
			{
				if ( verbose )
					(*uprintf) ( "* stopped " ) ;
				goto exitloop ;
			}
			nexttime = currtime + image->delay ;
			if ( GetTimeCode() >= nexttime )
			{
				currtime = nexttime ;
				break ;
			}
			Vsync();
		}
		if ( verbose )
			(*uprintf) ( "# %3d - %6ld\r", sequence->current, image->delay ) ;
		sequence->blitwind.dst.image.data = image->data ;
		BlitFullSourceWindow ( &sequence->blitwind.dst, dstwnd ) ;
	}
exitloop:
	if ( verbose )
		(*uprintf) ( "* %d frames displayed", sequence->current ) ;
	return sequence->current ;
}
