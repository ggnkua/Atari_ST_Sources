/* ----------------------------------------------------------------------- */
/* J-Source Version 7 - COPYRIGHT 1993 Iverson Software Inc.               */
/* 33 Major Street, Toronto, Ontario, Canada, M5S 2K9, (416) 925 6096      */
/*                                                                         */
/* J-Source is provided "as is" without warranty of any kind.              */
/*                                                                         */
/* J-Source Version 7 license agreement:  You may use, copy, and           */
/* modify the source.  You have a non-exclusive, royalty-free right        */
/* to redistribute source and executable files.                            */
/* ----------------------------------------------------------------------- */
/*                                                                         */
/* Input/Output                                                            */


#define MTYOUT          ((SI)1)
#define MTYOIN          ((SI)2)
#define NEDB            12000           /* size of edit buffer             */
#define NFKD            5               /* size of fn key defn buffer      */
#define NIBUF           843             /* size of keyboard input buffer   */
#define NLOG            16348           /* size of session log             */
#define NOBUF           100             /* size of short output buffer     */
#define NTA             224             /* size of type-ahead buffer       */

extern C                ibuf[];
extern A                inpl();
extern A                jgets();
extern C                obuf[];
extern B                tostdout;


#if (SYS & SYS_SESM)

#if (SYS & SYS_PC+SYS_PC386)
extern C*               edbuf;
#endif

#if (SYS & SYS_ARCHIMEDES+SYS_MACINTOSH)
#define JFOPEN          'o'
#define JFPRINT         'p'
#define JFPROFILE       'f'
#define JFSAVE          's'

typedef struct{I vol,type;C act,name[256];} JF;

extern B                appf();
extern JF              *jstf;
#endif

extern I                jbrk;           /* needed by session manager       */

extern void             jsti(SI,C*);
extern void             jstinit(Ptr);
extern void             jsto(SI,SI,C*);
extern void             jstpoll(void);
extern void             jstsbrk(void);  /* break handling for j /s         */
extern void             jststop(void);

#endif


/* jstf                                                                    */
/*  Pointer to file selected during jsti() cycle.                          */
/* jsti(SI n, C*s)                                                         */
/*  Put input line into 0-terminated string s, maximum n chars.            */
/* jstinit(Ptr v)                                                          */
/*  Initialize sesm. v=&in and is ignored on the Mac.                      */
/*  struct{C*vlog;short nlog;C*vinb;short ninb;C*vfkd;short nfkd;}in;      */
/*  nlog: length of session log;       vlog: session log space             */
/*  ninb: length of typeahead buffer;  vinb: typeahead buffer              */
/*  nfkd: length of fnkey defn buffer; vfkd: fnkey defn buffer             */
/* jstpoll(void)                                                           */
/*  "Keyboard input available?"; invoked by j periodically to pass control */
/*  to sesm.                                                               */
/* jsto(S code, SI n, C*s)                                                 */
/*  Output string s, length n.  code is MTYOUT (more output to follow) or  */
/*  MTYOIN (last line of output, i.e. output is prompt)                    */
/* jststop(void)                                                           */
/*  Called before j terminates, to let sesm shut down gracefully.          */
