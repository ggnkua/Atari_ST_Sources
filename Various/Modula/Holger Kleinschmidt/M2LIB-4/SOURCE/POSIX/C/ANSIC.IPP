IMPLEMENTATION MODULE ANSIC;
__IMP_SWITCHES__
#ifdef HM2
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif
IMPORT args;
#if !ISO_proc_const
IMPORT DosSystem,loc,ctype,str,lib,dir,tim,sig,proc,blk,mem;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE environ():StrArray;
BEGIN
 RETURN(args.environ);
END environ;

#if !ISO_proc_const
BEGIN (* ANSIC *)
 isalnum    := ctype.isalnum;
 isalpha    := ctype.isalpha;
 iscntrl    := ctype.iscntrl;
 isdigit    := ctype.isdigit;
 isgraph    := ctype.isgraph;
 islower    := ctype.islower;
 isprint    := ctype.isprint;
 ispunct    := ctype.ispunct;
 isspace    := ctype.isspace;
 isupper    := ctype.isupper;
 isxdigit   := ctype.isxdigit;
 tolower    := ctype.tolower;
 toupper    := ctype.toupper;

 strlen     := str.strlen;
 strcpy     := str.strcpy;
 strncpy    := str.strncpy;
 strcat     := str.strcat;
 strncat    := str.strncat;
 strcmp     := str.strcmp;
 strncmp    := str.strncmp;
 strchr     := str.strchr;
 strrchr    := str.strrchr;
 strstr     := str.strstr;
 strpbrk    := str.strpbrk;
 strerror   := str.strerror;

 main       := args.main;
 getenv     := args.getenv;

 exit       := DosSystem.exit;
 atexit     := DosSystem.atexit;

 ptr        := lib.ptr;
 void       := lib.void;
 atoi       := lib.atoi;
 atol       := lib.atol;
 strtol     := lib.strtol;
 strtoul    := lib.strtoul;
 sprintf    := lib.sprintf;
 bsearch    := lib.bsearch;
 qsort      := lib.qsort;
 rand       := lib.rand;
 srand      := lib.srand;

 clock      := proc.clock;

 signal     := sig.signal;
 raise      := sig.raise;
 abort      := sig.abort;

 memmove    := blk.memmove;
 memcpy     := blk.memmove; (* Alias *)
 memset     := blk.memset;
 memchr     := blk.memchr;
 memcmp     := blk.memcmp;

 difftime   := tim.difftime;

 localeconv := loc.localeconv;

 remove     := dir.unlink; (* Alias *)

 malloc     := mem.malloc;
 calloc     := mem.calloc;
 realloc    := mem.realloc;
 free       := mem.free;
 strdup     := mem.strdup;
#endif
END ANSIC.
