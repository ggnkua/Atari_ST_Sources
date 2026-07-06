/*----------------------------------------------*/
/* CTYPE.H  Header file                         */
/* supported by table __atab in library extra.a */
/*----------------------------------------------*/

#define	_C	0x01
#define	_P	0x02
#define	_N	0x04
#define	_U	0x08
#define	_L	0x10
#define	_S	0x20
#define	_B	0x40
#define	_X	0x80
extern	char __atab[];
#define	isalpha(c)	(__atab[c]&(_U|_L))
#define	isupper(c)	(__atab[c]&_U)
#define	islower(c)	(__atab[c]&_L)
#define	isdigit(c)	(__atab[c]&_N)
#define	isxdigit(c)	(__atab[c]&_X)
#define	isalnum(c)	(__atab[c]&(_U|_L|_N))
#define	isspace(c)	(__atab[c]&_S)
#define	ispunct(c)	(__atab[c]&_P)
#define	isprint(c)	(__atab[c]&(_P|_U|_L|_N|_B))
#define	isgraph(c)	(__atab[c]&(_P|_U|_L|_N))
#define	iscntrl(c)	(__atab[c]&_C)
#define	isascii(c)	((char)(c)<0x80)
#define	toupper(c)	((c)-'a'+'A')
#define	tolower(c)	((c)-'A'+'a')
#define	toascii(c)	((c)&0x7F)
