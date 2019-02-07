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
#if ISO_proc_const
(*empty*)
#else

IMPORT cmdline,loc,ctype,cstr,lib,tim,sig,proc,MEMBLK;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

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

  strlen     := cstr.strlen;
  strcpy     := cstr.strcpy;
  strncpy    := cstr.strncpy;
  strcat     := cstr.strcat;
  strncat    := cstr.strncat;
  strcmp     := cstr.strcmp;
  strncmp    := cstr.strncmp;
  strchr     := cstr.strchr;
  strrchr    := cstr.strrchr;
  strstr     := cstr.strstr;
  strpbrk    := cstr.strpbrk;
  strerror   := cstr.strerror;

  main       := cmdline.main;
  getenv     := cmdline.getenv;

  atoi       := lib.atoi;
  atol       := lib.atol;
  strtol     := lib.strtol;
  strtoul    := lib.strtoul;
  bsearch    := lib.bsearch;
  qsort      := lib.qsort;
  rand       := lib.rand;
  srand      := lib.srand;

  clock      := proc.clock;

  signal     := sig.signal;
  raise      := sig.raise;

  memmove    := MEMBLK.memmove;
  memcpy     := MEMBLK.memmove; (* Kein Schreibfehler, Synonym *)
  memset     := MEMBLK.memset;
  memchr     := MEMBLK.memchr;
  memcmp     := MEMBLK.memcmp;

  difftime   := tim.difftime;

  localeconv := loc.localeconv;
#endif
END ANSIC.
