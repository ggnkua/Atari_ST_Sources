/* cextern.h - external declarations of ezp.c globals - crd 880306 */

extern int  abortp;        /* all externs declared in ezp.c */
extern int  ahite;
extern int  bitln;
extern int  bm;
extern int  bmarg;
extern int  bufsz;
extern int  bytln;
#if DEBUG
extern int  dbug;
#endif
extern int  eb;
extern int  ep;
extern int  lastb;
extern int  lastp;
extern int  lm;
extern int  lmarg;
extern int  *measnum;
extern int  rasys;
extern int  rm;
extern int  rmarg;
extern int  sb;
extern int  sp;
extern int  *staffy;
extern int  stasys;
extern int  sysmax;
extern int  sysrec;
extern int  tm;
extern int  tmarg;
extern int  visys;
extern int  voff;

extern short   *s_image;

extern char *cancan, *set_1_216, *set_22_216, *set_8_72, *reset_1_6, *fmode,
      *dmode;

extern GRECT   desk;

extern LBRACE  *braces;
extern LBRACK  *brackets;
extern SYSDOM  *systems,
               *liney;

extern PRINTER *printer;

/* EOF */
