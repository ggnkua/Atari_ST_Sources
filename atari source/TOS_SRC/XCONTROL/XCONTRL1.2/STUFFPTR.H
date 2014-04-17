#include <sys\portab.h>
#include <linea.h>

#define MFSAVE 1
#define MFRESTORE 0

extern MFORM mfAlert, mfOther;

void cdecl MFsave( BOOLEAN saveit, MFORM *mf );
