/**************************************************************************/
/*                                                                        */
/*  NAME:         libstr.inc                                              */
/*                                                                        */
/*  DATUM:        19.06.89                                                */
/*                                                                        */
/*  BESCHREIBUNG: Include-Datei fuer libstr.a.                            */
/*                                                                        */
/**************************************************************************/

#ifndef LIBSTRINC
#define LIBSTRINC

#define BKSSOURCE
#include <portab.h>

extern BYTE *memchr();
extern WORD  memcmp();
extern BYTE *memcpy();
extern BYTE *memset();

extern BYTE *stradjl();
extern BYTE *stradjr();
extern BYTE *strcat();
extern BYTE *strcatn();
extern BYTE *strchr();
extern WORD  strcmp();
extern BYTE *strcnvl();
extern BYTE *strcnvul();
extern BYTE *strcpy();
extern BYTE *strcpyn();
extern WORD  strcspn();
extern BYTE *strctr();
extern BYTE *strdup();
extern BOOL  stremp();
extern WORD  strfnd();
extern BYTE *strfroml();
extern BYTE *strfromul();
extern BYTE *strichr();
extern WORD  stricmp();
extern WORD  stricspn();
extern WORD  strifnd();
extern WORD  strnimat();
extern BYTE *strinv();
extern WORD  strimat();
extern BYTE *stripbrk();
extern WORD  stripos();
extern BYTE  *strirchr();
extern BYTE  *strirpbrk();
extern WORD  strirpl();
extern WORD  strirpos();
extern BYTE *strirstr();
extern WORD  striscmp();
extern BYTE *strisort();
extern WORD  strispn();
extern BYTE *stristr();
extern WORD  strlen();
extern BYTE *strlwr();
extern BYTE *strlwrg();
extern WORD  strmat();
extern BYTE *strn0cpy();
extern BYTE *strncat();
extern BYTE *strncatn();
extern BYTE *strncpy();
extern BYTE *strncpyn();
extern WORD  strncmp();
extern BYTE *strndup();
extern BOOL  strnemp();
extern WORD  strnicmp();
extern BYTE *strninv();
extern WORD  strnirpl();
extern WORD  strniscmp();
extern BYTE *strnlwr();
extern BYTE *strnlwrg();
extern WORD  strnmat();
extern BYTE *strnrotl();
extern BYTE *strnrotr();
extern WORD  strnrpl();
extern WORD  strnscmp();
extern BYTE *strnset();
extern BYTE *strnspc();
extern BYTE *strnupr();
extern BYTE *strnuprg();
extern BYTE *strpbrk();
extern BYTE *strpcpy();
extern WORD  strpos();
extern BYTE *strptrm();
extern BYTE *strptrml();
extern BYTE *strptrmr();
extern BYTE *strrchr();
extern BYTE *strrev();
extern BYTE *strrotl();
extern BYTE *strrotr();
extern BYTE *strrpbrk();
extern WORD  strrpl();
extern WORD  strrpos();
extern BYTE *strrstr();
extern BYTE *strset();
extern WORD  strscmp();
extern BYTE *strspc();
extern WORD  strspn();
extern BYTE *strsort();
extern BYTE *strsset();
extern BYTE *strstr();
extern DOUBLE strtof();
extern BYTE *strtok();
extern LONG  strtol();
extern LONG  strtoul();
extern BYTE *strtrm();
extern BYTE *strtrml();
extern BYTE *strtrmr();
extern BYTE *struprg();
extern BYTE *strwupr();
extern BYTE *substr();
extern BYTE *subnstr();

#define stradj(s,d)    stradjl(s,d)
#if TNIX
#define index(s,c)     strchr(s,c)
#define rindex(s,c)    strrchr(s,c)
#endif TNIX
#define strtrim(s)     strtrm(s)
#define str0cpy(d,s,l) strn0cpy(d,s,l)
#define str0cat(d,s,l) strncat(d,s,l)
#define strtod(s,d)    strtof(s,d,10)
#define blankstr(s)    stremp(s)
#define strsave(s)     strdup(s)
#define strrsort(s)    strrev(strsort(s))
#define strirsort(s)   strrev(strisort(s))

#endif LIBSTRINC

