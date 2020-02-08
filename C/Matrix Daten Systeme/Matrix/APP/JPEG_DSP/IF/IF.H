/* if.h	/ 22.3.94 / MATRIX / WA	*/

typedef short ERROR ;

# define OK				 0
# define NOjpgCookie	-1
# define READerror		-2
# define OPENerror		-3
# define MALLOCerror	-4
# define FILEnotFound	-5
# define BUFsizeError	-6

# define LASTjpegifError	BUFsizeError

typedef int  (*TPrintfProc) ( const char *format, ... ) ;

/*... import from user module ...*/

extern TPrintfProc uprintf ;
extern short UserRoutine ( JPGD_PTR jpgd ) ;

/*... export ...*/

extern char *GetJpegErrorText ( ERROR err ) ;

extern ERROR CheckJpegDriverLoaded ( void ) ;
extern ERROR JpegDecodeToFile ( char *srcname, char *dstname, int comp, int pixsiz ) ;
extern ERROR JpegDecodeToMemory ( char *srcname, int comp, int pixsiz,
								  MFDB *pmfdb, long *outsize ) ;
extern ERROR JpegDecodeToBuffer ( char *srcname, int comp, int pixsiz,
								  void *buffer, long bufsize,
								  MFDB *pmfdb ) ;
extern ERROR JpegDecodeToPtrBuffer ( char *srcname, int comp, int pixsiz,
						   			 void **pbuffer, long bufsize,
						   			 MFDB *pmfdb ) ;
