/****************************************************************************/
/*									    */
/*				CTYPE					    */
/*				-----					    */
/*									    */
/*   CTYPE.H  -  macros to classify ASCII-coded integers by table lookup.   */
/*									    */
/*									    */
/*	Note:	Integer args are undefined for all int values > 127,	    */
/*		except for macro 'isascii()'.				    */
/*	Assumes:							    */
/*		User will link with standard library functions.		    */
/*		Compiler can handle declarator initializers and		    */
/*		'#defines' with parameters.				    */
/*	Modified:							    */
/*	10/10/84 jc - isxdigit(), isgraph(), _toupper, _tolower	   	    */
/****************************************************************************/

/*
 *	Bit patterns for character class DEFINEs
 */
#define	__c	01
#define	__p	02
#define	__d	04
#define	__u	010
#define	__l	020
#define	__s	040
#define	__cs	041
#define	__ps	042
#define	__x	0100
#define	__ux	0110
#define	__lx	0120

extern	char	__atab[];
extern	int	___atab();

/*
 *	Character Class Testing and Conversion DEFINES:
 */
#define isascii(ch) ((unsigned)(ch) <= 0177)
#define	isalpha(ch) (__atab[ch] & (__u | __l))
#define	isupper(ch) (__atab[ch] & __u)
#define	islower(ch) (__atab[ch] & __l)
#define	isdigit(ch) (__atab[ch] & __d)
#define	isalnum(ch) (__atab[ch] & (__u | __l | __d))
#define	isspace(ch) (__atab[ch] & __s)
#define	ispunct(ch) (__atab[ch] & __p)
#define	isprint(ch) (__atab[ch] & (__u | __l | __d | __p))
#define	iscntrl(ch) (__atab[ch] & __c)
#define	isxdigit(ch)(__atab[ch] & (__d | __x))
#define	isgraph(ch) (__atab[ch] & (__u | __l | __d | __p) && ch != ' ')
#define	tolower(ch) (isupper(ch) ? (ch)+('a'-'A') : (ch))
#define	toupper(ch) (islower(ch) ? (ch)+('A'-'a') : (ch))
#define	toascii(ch) ((ch) & 0177)

#define	_toupper(ch)	((ch) + ('A' - 'a'))
#define	_tolower(ch)	((ch) + ('a' - 'A'))
