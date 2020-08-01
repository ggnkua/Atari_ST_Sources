/* osdefs.h - extern declarations for machine specific functions */

#ifdef MACINTOSH
extern LVAL xhidepen(),xshowpen(),xgetpen(),xpensize(),xpenmode();
extern LVAL xpenpat(),xpennormal(),xmoveto(),xmove(),xlineto(),xline();
extern LVAL xshowgraphics(),xhidegraphics(),xcleargraphics();
#endif

#ifdef MSDOS
extern LVAL xsystem(),xgetkey(),xtime(),xdifftime();
#ifdef NOTDEF
extern LVAL xint86(),xinbyte(),xoutbyte();
#endif
#endif

#ifdef UNIX
extern LVAL xsystem();
#endif
