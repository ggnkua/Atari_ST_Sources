#pragma idempotent

/****************************************************************************
 * CTYPE.H      Character classification and conversion
 *
 *              This file provides a 'roll your own' typing function,
 *              'isctype()'.  This macro allows testing of any arbitrary
 *              combo of types.  For example, to check whether a character
 *              is either space or punctuation, code 'isctype(c, _CTp|_CTs)'.
 *              This file also provides 'iscsym()' and 'iscsymf()' a 
 *              couple of non-standard macros handy for writing compilers.
 *              A tokenizer can use these to determine if it's handling 
 *              something that is a symbol as defined by C.  (ie, 1st char
 *              is non-numeric, underbars are like alphas).
 *
 *              Note that this ctype system DOES deal with EOF chars (not
 *              that you can tell that from the code in here; trust me.)
 *
 * 10/30/90 -   Ported to Poco.
 * 11/22/90 -   Tested extensively, fixed a couple typos causing wrong results.
 *              Also, added a couple #ifdef sections so that this file will
 *              work with any compiler, not just poco.
 * 06/27/91 -   Ported from Poco back to Sozobon.  Removed Poco-specifics.
 ***************************************************************************/

#ifndef CTYPE_H
#define CTYPE_H

extern char __ctypes[];

#define _CTb    0x0001 /* underbar, used by iscsym() */
#define _CTd    0x0002 /* numeric digit */
#define _CTu    0x0004 /* upper case */
#define _CTl    0x0008 /* lower case */
#define _CTs    0x0010 /* whitespace */
#define _CTp    0x0020 /* punctuation */
#define _CTx    0x0040 /* hexadecimal */
#define _CTc    0x0080 /* control character */

#define _toupper(c)  ((c)&0xFFDF)
#define _tolower(c)  ((c)|0x0020)
#define toascii(c)   ((c)&0x7F)

#define isascii(c)   (!((c)&0x0080))
#define isalnum(c)   (__ctypes[(c)]&(_CTu|_CTl|_CTd))
#define isalpha(c)   (__ctypes[(c)]&(_CTu|_CTl))
#define iscntrl(c)   (__ctypes[(c)]&_CTc)
#define isdigit(c)   (__ctypes[(c)]&_CTd)
#define isgraph(c)   (__ctypes[(c)]&(_CTd|_CTu|_CTl|_CTp))
#define islower(c)   (__ctypes[(c)]&_CTl)
#define isprint(c)   (__ctypes[(c)]>0)      /* ie, high bit is off */
#define ispunct(c)   (__ctypes[(c)]&_CTp)
#define isspace(c)   (__ctypes[(c)]&_CTs)
#define isupper(c)   (__ctypes[(c)]&_CTu)
#define isxdigit(c)  (__ctypes[(c)]&_CTx)

#define iscsym(c)    (__ctypes[(c)]&(_CTu|_CTl|_CTb|_CTd))
#define iscsymf(c)   (__ctypes[(c)]&(_CTu|_CTl|_CTb))
#define isctype(c,t) (__ctypes[(c)]&(t)) /* roll your own combo */

extern int toupper();
extern int tolower();  

#endif /* CTYPE_H */

