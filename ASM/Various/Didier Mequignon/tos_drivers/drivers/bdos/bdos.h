#include "fs.h"
#include "gemerror.h"

long Dsetdrv(long drv); 
long Dgetdrv(void);
void Fsetdta(DTAINFO *buf); 
DTAINFO *Fgetdta(void);
long Dfree(long *buf, long driveno); 
long Dcreate(const char *path);
long Ddelete(const char *path);  
long Dsetpath(const char *path); 
long Fcreate(const char *fname, long attr);
long Fopen(const char *fname, long mode); 
long Fclose(long handle); 
long Fread(long handle, long count, void *buf); 
long Fwrite(long handle, long count, void *buf); 
long Fdelete(const char *fname);
long Fseek(long offset, long handle, long seekmode); 
long Fattrib(const char *filename, long wflag, long attrib); 
long Dgetpath(char *path, long driveno); 
long Fsfirst(const char *filename, long attr); 
long Fsnext(void); 
long Frename(const char *oldname, const char *newname); 
void Fdatime(short *timeptr, long handle, long wflag);




	 
