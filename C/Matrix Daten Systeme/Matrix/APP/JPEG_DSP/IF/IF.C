#include	<stdlib.h>
#include	<stdio.h>
#include	<string.h>
#include	<tos.h>

#include	<vdi.h>		/* needed only for MFDB declaration in jpgdh.h */
#include	"jpgdh.h"

#include 	"if.h"

typedef struct
{
	long	magic;
	long	data;
} COOKIE_STRUCT;

typedef	COOKIE_STRUCT	*COOKIE_PTR;

char *JpegIfErrorTextTable[-LASTjpegifError+1] =
{
	"ok",
	"no jpeg cookie",
	"read error",
	"open error",
	"malloc error",
	"file not found",
	"output buffer too small"
} ;

char *JpegErrorTextTable[LASTjpegError+1] =
{
	"File correctly uncompressed",
	"File is not JFIF (Error)",
	"Reserved CCITT Marker Found (Error)",
	"Mode not handled by the decoder (Error)",
	"Mode not handled by the decoder (Error)",
	"Mode not handled by the decoder (Error)",
	"Mode not handled by the decoder (Error)",
	"Mode not handled by the decoder (Error)",
	"Mode not handled by the decoder (Error)",
	"Mode not handled by the decoder (Error)",
	"Mode not handled by the decoder (Error)",
	"Mode not handled by the decoder (Error)",
	"Mode not handled by the decoder (Error)",
	"Mode not handled by the decoder (Error)",
	"Mode not handled by the decoder (Error)",
	"Unexpected RSTm found (Error)",
	"Buggy DHT Marker (Error)",
	"Marker not handled by the decoder (Error)",
	"Buggy DQT Marker (Error)",
	"Invalid/Unexpected DNL Marker (Error)",
	"Invalid DRI Header Size (Error)",
	"Marker not handled by the decoder (Error)",
	"Marker not handled by the decoder (Error)",
	"Invalid components subsampling (Error)",
	"Not enough memory... (Error)",
	"Decoder is busy (Error)",
	"Can't lock the DSP (Error)",
	"Buggy SOFn marker (Error)",
	"Buggy SOS marker (Error)",
	"Buggy Huffman Stream (Error)",
	"Invalid Output Pixel Format (Error)",
	"Hard/Floppy Disk Full (Error)",
	"Marker expected but not found (Error)",
	"More bytes Needed (Error)",
	"Dummy Bytes after EOI Marker (Warning)",
	"User Routine signaled 'Abort'",
	"Not Enough DSP RAM (Error)",
	"RSTm Marker expected but not found",
	"Invalid RSTm Marker Number",
	"Driver is Already Closed.",
	"Stop Decoding (Internal Message, Should Never Appear)"
} ;
			
char JpegErrorBuffer[48] ;

/*-------------------------------------------------- GetJpegErrorText ----*/
char *GetJpegErrorText ( ERROR err )
{
	if ( err >= 0 && err <= LASTjpegError )
	{
		return JpegErrorTextTable[err] ;
	}
	else if ( err >= LASTjpegifError )
	{
		return JpegIfErrorTextTable[-err] ;
	}
	else 
	{
		sprintf ( JpegErrorBuffer, "unknown dsp-jpeg error : %d", err ) ; 
		return JpegErrorBuffer ;
	}
}


/*------------------------------------------------------------ GetJar ----*/
long GetJar ( void )
{
	return(*(long *)0x5a0);
}

/*------------------------------------------------------------ GetCookie ----*/
ERROR GetCookie(long magic,long *data)
{
	ERROR		err = NOjpgCookie ;
	COOKIE_PTR	cookie ;

	if ((cookie=(COOKIE_PTR)Supexec(GetJar))!=NULL)
	{	/* Cookie jar present */
		while ( cookie->magic != 0L )
		{	/* End not reached */
			if ( cookie->magic == magic )
			{
				*data = cookie->data;
				err = OK ;
				break;
			}
			cookie++;
		}
	}
	return err ;
}


/*------------------------------------------------------ UserRoutine ----*/
void *MemAlloc ( size_t size )
{
	return size > 0L ? malloc ( size ) : NULL ;
}



const char pad[] = { -1,-1,-1,-1,-1,-1,-1,-1,0,0 } ;

/*--------------------------------------------- CheckJpegDriverLoaded ----*/
ERROR CheckJpegDriverLoaded ( void )
{
	JPGDDRV_PTR drv ;

	return GetCookie ( JPGD_MAGIC, (long *)&drv ) ;
}


/*---------------------------------------------------- OpenJpegDriver ----*/
ERROR OpenJpegDriver ( JPGDDRV_PTR *pdrv, JPGD_PTR *pjpgd )
{
	ERROR	err ;
	long	jpgdsize ;

	if ( ( err = GetCookie(JPGD_MAGIC,(long *)pdrv) ) == OK )
	{
		jpgdsize = JPGDGetStructSize(*pdrv) ;
		if ( ( *pjpgd = MemAlloc(jpgdsize) ) != NULL )
		{
			memset(*pjpgd,0,jpgdsize);		/**** CLEAR STRUCT ****/
		}
		else
		{
			(*uprintf)( "Can't allocate JPEG Decoder structure" ) ;
			err = MALLOCerror ;
		}
	}
	else
		(*uprintf)("JPEG Decoder driver not installed");
	return err ;
}

/*---------------------------------------------------- CloseJpegDriver ----*/
ERROR CloseJpegDriver ( JPGDDRV_PTR drv, JPGD_PTR jpgd, ERROR preverr )
{
	ERROR err ;

	if ( (err = JPGDCloseDriver(drv,jpgd)) != OK )
		(*uprintf)("Error closing JPEG Decoder driver: %d",err);
	free ( jpgd ) ;	/* release decoder structure */
	return preverr != OK ? preverr : err ;
}


/*------------------------------------------------------ ReadJPEGfile -*/
ERROR ReadJPEGfile ( char *srcname, void **jpegdata, long *jpegsize )
{
	ERROR		err;
	int			syserr ;
	DTA			dta,*olddta;
	FILE		*fd;
	long		srcsize;
	void		*src;

	*jpegsize = 0 ;
	*jpegdata = NULL ;
	
	olddta = Fgetdta();
	Fsetdta(&dta);
	syserr = Fsfirst(srcname,0x22);
	Fsetdta(olddta);
	if ( syserr == 0 )
	{
		(*uprintf)( "Loading picture %s", srcname ) ;
		srcsize = dta.d_length;			/* JPEG file size */
		if ( srcsize > 0L && (src=malloc(srcsize+sizeof(pad)))!=NULL )
		{
			if ( (fd=fopen(srcname,"rb")) != NULL )
			{
				if ( fread(src,srcsize,1L,fd) == 1L )
				{
					*jpegsize = srcsize ;
					*jpegdata = src ;
					err = OK ;
				}
				else
				{
					(*uprintf)("Read error in file %s",srcname);
					free ( src ) ;
					err = READerror ;
				}
				fclose(fd);
			}
			else
			{
				(*uprintf)("Can't open file %s",srcname);
				free ( src ) ;
				err = OPENerror ;
			}
		}
		else
		{
			(*uprintf) ( "Can't allocate JPEG Picture" ) ;
			err = MALLOCerror ;
		}
	}
	else
	{
		(*uprintf)("File %s not found",srcname);
		err = FILEnotFound ;
	}
	
	return err ;
}


/*------------------------------------------------------ JpegDecodeSetup -*/
ERROR JpegDecodeSetup ( JPGDDRV_PTR drv, void *src, long srcsize,
					  	JPGD_PTR jpgd, int comp, int pixsiz )
{
	ERROR		err;

	memcpy((char *)src+srcsize,pad,sizeof(pad));	/* padding */

	if ( (err=JPGDOpenDriver(drv,jpgd)) != OK )
	{
		(*uprintf)("Error opening JPEG Decoder driver: %d",err);
		return err ;
	}
	jpgd->InPointer=src;			/* JPEG file ptr */
	jpgd->InSize=srcsize;			/* JPEG file size */
	if ( (err=JPGDGetImageInfo(drv,jpgd)) != OK )
	{
		(*uprintf)("Error getting image info: %d",err);
		return err ;
	}

	jpgd->OutComponents = comp ;			/* RGB */
	jpgd->OutPixelSize  = pixsiz ;			/* 24 bits */
	if ( (err=JPGDGetImageSize(drv,jpgd)) != OK )
	{	/* Always do it */
		(*uprintf)("Error getting image size: %d",err);
		return err ;
	}

	return OK ;
}


/*------------------------------------------------------ JpegDecodeImage -*/
ERROR JpegDecodeImage ( JPGDDRV_PTR drv, JPGD_PTR jpgd )
{
	ERROR err ;
	
	if ((err=JPGDDecodeImage(drv,jpgd)) == OK )
		(*uprintf)("Decoding done");
	else
		(*uprintf)("Error decoding picture : %d", err ) ;

	return err ;
}


/*------------------------------------------------------ JpegDecodeToFile -*/
ERROR JpegDecodeToFile ( char *srcname, char *dstname, int comp, int pixsiz  )
{
	ERROR		err ;

	JPGDDRV_PTR	drv;
	JPGD_PTR	jpgd;

	long		srcsize;
	void		*src;

	if ( ( err = OpenJpegDriver ( &drv, &jpgd ) ) == OK )
	{
		if ( ( err = ReadJPEGfile ( srcname, &src, &srcsize ) ) == OK )
		{
		  	if ( ( err = JpegDecodeSetup ( drv, src, srcsize, jpgd, comp, pixsiz ) ) == OK )
			{
				jpgd->OutFlag	  = TOdisk;
				jpgd->UserRoutine = UserRoutine;
				jpgd->OutPointer  = dstname;
				(*uprintf) ( "Decoding picture %s into %s", srcname, dstname ) ;
			
				err = JpegDecodeImage ( drv, jpgd ) ;
			}
			free ( src ) ;	/* release jpeg picture */
		}
		err = CloseJpegDriver ( drv, jpgd, err ) ;
	}

	return err ;
}

/*------------------------------------------------------ JpegDecodeToMemory -*/
ERROR JpegDecodeToMemory ( char *srcname, int comp, int pixsiz,
						   MFDB *pmfdb, long *outsize )
{
	ERROR		err ;

	JPGDDRV_PTR	drv;
	JPGD_PTR	jpgd;

	long		srcsize, dstsize;
	void		*src,	 *dst;

	*outsize = 0 ;
	memset ( pmfdb, 0, sizeof ( MFDB ) ) ;
	
	if ( ( err = OpenJpegDriver( &drv, &jpgd ) ) == OK )
	{
		if ( ( err = ReadJPEGfile ( srcname, &src, &srcsize ) ) == OK )
		{
		  	if ( ( err = JpegDecodeSetup ( drv, src, srcsize, jpgd, comp, pixsiz ) ) == OK )
			{
				(*uprintf) ( "Decoding picture %s into memory", srcname ) ;
				dstsize = jpgd->OutSize;
				if ( ( dst = MemAlloc ( dstsize ) ) != NULL )
				{
					jpgd->UserRoutine = UserRoutine ;
					jpgd->OutPointer  = dst ;
		
					if ( ( err=JpegDecodeImage(drv,jpgd) ) == OK )
					{
						*outsize = dstsize ;
						*pmfdb = jpgd->MFDBStruct ;
					}
				}
				else
				{
					(*uprintf)("Can't allocate destination picture");
					err = MALLOCerror ;
				}
			}
			free(src);	/* release jpeg picture */
		}
		err = CloseJpegDriver ( drv, jpgd, err ) ;
	}
	
	return err ;
}


/*------------------------------------------------------ JpegDecodeToBuffer -*/
ERROR JpegDecodeToBuffer ( char *srcname, int comp, int pixsiz,
						   void *buffer, long bufsize,
						   MFDB *pmfdb )
{
	ERROR		err ;

	JPGDDRV_PTR	drv;
	JPGD_PTR	jpgd;

	long		srcsize ;
	void		*src ;

	memset ( pmfdb, 0, sizeof ( MFDB ) ) ;
	
	if ( ( err = OpenJpegDriver( &drv, &jpgd ) ) == OK )
	{
		if ( ( err = ReadJPEGfile ( srcname, &src, &srcsize ) ) == OK )
		{
		  	if ( ( err = JpegDecodeSetup ( drv, src, srcsize, jpgd, comp, pixsiz ) ) == OK )
			{
				(*uprintf) ( "Decoding picture %s into buffer", srcname ) ;
				if ( bufsize >= jpgd->OutSize )
				{
					jpgd->UserRoutine = UserRoutine ;
					jpgd->OutPointer  = buffer ;
		
					if ( ( err=JpegDecodeImage(drv,jpgd) ) == OK )
						*pmfdb = jpgd->MFDBStruct ;
				}
				else
				{
					(*uprintf) ( "mfdb = $%p - %d:%d",
							jpgd->MFDBStruct.fd_addr,
							jpgd->MFDBStruct.fd_w,
							jpgd->MFDBStruct.fd_h ) ;
					(*uprintf) ( "ww=%d, std=%d, pln=%d",
							jpgd->MFDBStruct.fd_wdwidth,
							jpgd->MFDBStruct.fd_stand,
							jpgd->MFDBStruct.fd_nplanes ) ;

					(*uprintf)("buffer req=%ld, siz=%ld",
										jpgd->OutSize, bufsize ) ;
					err = BUFsizeError ;
				}
			}
			free(src);	/* release jpeg picture */
		}
		err = CloseJpegDriver ( drv, jpgd, err ) ;
	}
	
	return err ;
}

/*------------------------------------------------------ JpegDecodeToPtrBuffer -*/
ERROR JpegDecodeToPtrBuffer ( char *srcname, int comp, int pixsiz,
						   void **pbuffer, long bufsize,
						   MFDB *pmfdb )
{
	ERROR		err ;

	JPGDDRV_PTR	drv;
	JPGD_PTR	jpgd;

	long		srcsize ;
	void		*src ;

	memset ( pmfdb, 0, sizeof ( MFDB ) ) ;
	
	if ( ( err = OpenJpegDriver( &drv, &jpgd ) ) == OK )
	{
		if ( ( err = ReadJPEGfile ( srcname, &src, &srcsize ) ) == OK )
		{
		  	if ( ( err = JpegDecodeSetup ( drv, src, srcsize, jpgd, comp, pixsiz ) ) == OK )
			{
				(*uprintf) ( "Decoding picture %s into buffer", srcname ) ;
				if ( bufsize < jpgd->OutSize || *pbuffer == NULL )
				{
					if ( *pbuffer != NULL )
						free ( *pbuffer ) ;
					*pbuffer = malloc ( jpgd->OutSize ) ;
				}
				if ( *pbuffer != NULL )
				{
					jpgd->UserRoutine = UserRoutine ;
					jpgd->OutPointer  = *pbuffer ;
		
					if ( ( err=JpegDecodeImage(drv,jpgd) ) == OK )
						*pmfdb = jpgd->MFDBStruct ;
				}
				else
					err = BUFsizeError ;
			}
			free(src);	/* release jpeg picture */
		}
		err = CloseJpegDriver ( drv, jpgd, err ) ;
	}
	
	return err ;
}
