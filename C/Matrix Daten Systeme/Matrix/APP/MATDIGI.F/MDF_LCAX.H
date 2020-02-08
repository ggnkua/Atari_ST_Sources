extern int LoadMatDigiFLcaData ( unsigned chip, TDigitiserMode mode, POINT *zoom, bool init ) ;

# ifndef __LCALOAD__
typedef void *PLCAdata ;
# endif

extern int LoadMdfLcaDataBlock ( PLCAdata lcadata ) ;
