/*
 *      machine independent definitions and global variables
 */

#define YES	1
#define NO	0
#define ERR	(-1)

#define MAXBUF  256     /* input line length */
#define MAXOP   20      /* space for longest mnemonic */
#define MAXLAB  30      /* longest label */
#define E_LIMIT 32      /* max. bytes per S-record */
#define P_LIMIT 64      /* max. bytes per line to listing */
#define OBJNAME "m.out" /* S-record filename */

#define MAXWORD 32767
#define MINWORD (-32768)
#define MAXUWORD 65535
#define MAXBYTE 127
#define MAXUBYTE 255
#define MINBYTE (-128)

/*      Debug flag values       */
#define PARSE   0x01
#define MATCH   0x02
#define EVAL    0x04
#define LOOKUP  0x08
#define FWDREF  0x10
#define XDEBUG  0x20    /* debug indexed indirect */
#define DUMP    0x40    /* internal table dump */

char mapdn();
char *alloc();
