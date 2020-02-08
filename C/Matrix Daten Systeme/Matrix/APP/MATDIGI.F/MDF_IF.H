/* mdf_if.h	*/

# define LCAtypUndef	'?'
# define LCAtypGrey		'u'
# define LCAtypColor	'u'
# define LCAtypYC		'u'
# define DEFlcaTyp		LCAtypColor

extern char 	CurrentLcaType ;
extern unsigned CurrentLcaVersion ;
extern unsigned CurrentLcaRelease ;

extern unsigned LcaVersion	;	/* board/dmsd type	*/
extern unsigned LcaRelease	;
/*
extern unsigned DmsdType ;
*/
extern int  test ;
extern bool	DisplayEnabled ;
extern bool	WaitUntilGrabbed ;

# define BYT_PER_PIX	2

extern int LoadMdfLcaFile ( char typ, unsigned ver, unsigned rel ) ;

extern int  SetDmsdType ( int chip, unsigned lcatyp ) ;
extern void ResetDigiWindows ( TBlitWindow *blitwind ) ;
extern void CheckDigiWindows ( TBlitWindow *blitwind, POINT *zoom,
							   TImage *dstimg ) ;
