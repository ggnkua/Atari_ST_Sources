#ifndef H_SNSERVER
#define H_SNSERVER

#ifndef APIENTRY
#include <os2def.h>
#endif

#ifndef CALLBACK
#define CALLBACK pascal far _loadds _export
#endif

typedef SEL  HSNOOP;
typedef PSEL PHSNOOP;
typedef int   (pascal far  *PFNSN)(int flag, char far *str);


USHORT CALLBACK SnoopOpen(PSZ pszPipeName,
                          PHSNOOP phSnoop,
                          PSZ pszAppName,
                          PFNSN NotifyFunc);


USHORT CALLBACK SnoopWrite(HSNOOP hsn, PSZ pszMessage);

USHORT CALLBACK SnoopClose(HSNOOP hsn);

#endif	/* H_SNSERVER */
