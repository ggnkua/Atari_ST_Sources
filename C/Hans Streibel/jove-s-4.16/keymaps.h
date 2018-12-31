/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

/* tables defined in keys.txt/keys.c */

extern data_obj	*MainKeys[NCHARS];
extern data_obj	*EscKeys[NCHARS];
extern data_obj	*CtlxKeys[NCHARS];

#ifdef PCNONASCII
extern data_obj	*NonASCIIKeys[NCHARS];
#endif

#ifdef MAC			/* used in About Jove... */
#define F_MAINMAP '\001'
#define F_PREF1MAP '\002'
#define F_PREF2MAP '\003'
#endif

#define OTHER_CMD	0
#define ARG_CMD		1
#define LINECMD		2	/* so we can preserve screen col in moves */
#define KILLCMD		3	/* so we can merge kills */
#define YANKCMD		4	/* so we can do yank-pop (ESC Y) */
#define UNDOABLECMD	5	/* so we can do yank-pop to undo */
#define MOUSE_CMD	6	/* to detect other cmds when button is down */

extern int this_cmd;		/* ... */
extern int last_cmd;		/* last command ... to implement appending to kill buffer */

extern void InitKeymaps proto((void));
extern void dispatch proto((ZXchar c));
extern bool IsPrefixChar proto((ZXchar c));

extern void	DelObjRef proto((data_obj *));

/* Commands: */
extern void Apropos proto((void));
extern void LBindAKey proto((void));
extern void LBindMac proto((void));
extern void LBindMap proto((void));
extern void BindAKey proto((void));
extern void BindMac proto((void));
extern void BindMap proto((void));
extern void DescBindings proto((void));
extern void DescCom proto((void));
extern void DescVar proto((void));
extern void KeyDesc proto((void));
extern void Unbound proto((void));

#ifdef IPROCS
extern void PBindAKey proto((void));
extern void PBindMac proto((void));
extern void PBindMap proto((void));
#endif
