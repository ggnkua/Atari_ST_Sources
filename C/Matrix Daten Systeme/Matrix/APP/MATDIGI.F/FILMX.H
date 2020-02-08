extern void DigitiseMatrix ( int nx, int ny, TBlitWindow *blitwind, POINT *zoom, bool wait ) ;

extern int  WriteRGBFiles ( char *filename, int w, int h, uword *data ) ;
extern int  WriteTargaFile ( char *filename, int w, int h, uword *data ) ;
extern int  WriteFrame ( SEQUENCE *sequence, char *basename, int frame ) ;
extern int  WriteSequenceHeader ( SEQUENCE *sequence, char *basename, uword format ) ;
extern int  SequenceWrite ( SEQUENCE *sequence, char *basename, int from, int to, uword format ) ;

extern int  ReadTargaFrame ( SEQUENCE *sequence, char *basename, int frame ) ;
extern int  ReadBlockFrame ( SEQUENCE *sequence, char *basename, int frame ) ;
extern int  ReadFrame ( SEQUENCE *sequence, char *basename, int frame ) ;
extern int  ReadSequenceHeader ( SEQUENCE *sequence, char *basename ) ;
extern int  SequenceRead ( SEQUENCE *sequence, char *basename, int from, int to ) ;

extern void FreeConvBuffer ( void ) ;

extern int  InitSequence ( SEQUENCE *sequence ) ;
extern int  MallocSequence ( SEQUENCE *sequence, int nreq, TImageWindow *srcwnd, POINT *zoom ) ;
extern void FreeSequence ( SEQUENCE *sequence ) ;
extern void SequenceInfo ( SEQUENCE *sequence ) ;
extern int  RecordSequence ( SEQUENCE *sequence, bool wait ) ;
extern int  PlaySequence ( SEQUENCE *sequence, TImageWindow *dstwnd ) ;

extern int RecordStart ( SEQUENCE *sequence ) ;
extern int RecordStop ( SEQUENCE *sequence ) ;
extern int RecordRestart ( SEQUENCE *sequence ) ;
extern int RecordCurrFrame ( SEQUENCE *sequence, bool wait ) ;
extern int RecordFrame ( SEQUENCE *sequence, int frame, bool wait ) ;

extern int PlayStart ( SEQUENCE *sequence, int step ) ;
extern int PlayRestart ( SEQUENCE *sequence ) ;
extern int PlayStop ( SEQUENCE *sequence ) ;

extern int PlaySyncCurrent ( SEQUENCE *sequence ) ;

extern TValid ActivateFrame ( SEQUENCE *sequence, int frame ) ;

extern int    DisplayCurrentFrame ( SEQUENCE *sequence, TImageWindow *dstwnd ) ;

# if 0
# define FORWframe	-1	/* DisplayFrame ( .., frame, ... )	or 0,1,...	valid-1	*/
# define CURRframe	-2
# define BACKframe	-3
# endif
extern int  ChkAndSetCurrentFrame ( SEQUENCE *sequence, int frame ) ;
extern int  DisplayFrame ( SEQUENCE *sequence, int frame, TImageWindow *dstwnd ) ;
