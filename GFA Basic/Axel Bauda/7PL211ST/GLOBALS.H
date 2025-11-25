/** globals **/
extern uint    crctab[];
extern byte    decode[];
extern byte    code[];
extern byte    extended;
extern size_t  buflen;
extern char    _drive[];
extern char    _dir[];
extern char    _file[];
extern char    _ext[];
extern char    spaces[];
extern char    *endstr;
extern char    delimit[];
extern char    cant[];
extern char    miss[];
extern char    notsame[];
extern int     noquery;
extern int     force;
extern int     fls;
extern int     autokill;
extern struct m_index *index;

#ifdef __TOS__
  extern int   nowait;
#endif
