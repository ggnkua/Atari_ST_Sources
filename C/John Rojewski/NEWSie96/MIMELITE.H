/* mimelite.h  1994 may 19  [gh]
+-----------------------------------------------------------------------------
| Abstract:
|    Public constants and types for the mimelite library.
|
| History:
|    2.3 95 mar 13 [gh] Fixed a bug extracting attachements.
|    2.2 94 oct 10 [gh] Added NS_4551-1 (Eudora uses it).
|    2.1 94 jun 14 [gh] Made lint happier
|    2.0 94 may 19 [gh] Release of version 2.0
|    1.1 94 feb 01 [gh] Improved documentation and MIME support.
|    1.0 94 jan 03 [gh] Wrote first version.
|
| Authorship:
|    Copyright (c) 1994 Gisle Hannemyr.
|    Permission is granted to hack, make and distribute copies of this program
|    as long as this copyright notice is not removed.
|    Flames, bug reports, comments and improvements to:
|       snail: Gisle Hannemyr, Hegermannsgt, 13-3, N-0478 Oslo
|       email: gisle@oslonett.no, gisle@ifi.uio.no
+---------------------------------------------------------------------------*/

/*---( constants )----------------------------------------------------------*/

#define VERSION "2.3"	/* mimelite version number.			    */

			/* Special values og MIME version number.	    */
#define MV_R0822 -2	/* Plain document, no MIME header		    */
#define MV_R1049 -1	/* Pre-MIME, RFC-1049 content-type.		    */
/* Positive values for MIME version is 100*first_field+second_field.	    */


#define CT_UNKNOWN  0	/* Content-Type					   */
#define CT_ASCTEXT  1
#define CT_MULTIPT  2
#define CT_MESSAGE  3
#define CT_APPLCTN  4
#define CT_IMAGECT  5
#define CT_AUDIOCT  6
#define CT_VIDEOCT  7
#define CT_NOTIMPL  8
#define CT_PRIVATE  9

#define AC_DOITALL 0xFFFF
#define AC_ASCTEXT 0x000F
#define AC_MULTIPT 0x00F0
#define AC_MESSAGE 0x0F00
#define AC_APPLCTN 0xF000

#define ST_UNKNOWN  0	/* Content-Type	subtype				   */
#define ST_PLAINTX  1
#define ST_MPMIXED  2
#define ST_MPALTER  3
#define ST_MPDIGST  4
#define ST_MPPARAL  5
#define ST_MERF822  6
#define ST_MEPARTL  7
#define ST_MEEXTRL  8
#define ST_APOCTET  9
#define ST_APPSCRT 10
#define ST_NOTIMPL 11
#define ST_PRIVATE 12

			/* Enumerated character sets we know about.	    */
#define CS_IGNOR   0	/* Ignore this character set token.		    */
#define CS_UNKWN   1	/* Character set is not known.			    */
#define	CS_PRIVT   2	/* X-token, private character set.		    */
#define	CS_ASCII   3	/* US-ASCII / ISO 646 IRV   7 bit (ISO-IR-6)	    */
#define	CS_IR060   4	/* ISO 646 Norwegian/Danish 7 bit (ISO-IR-60)       */
#define	CS_ISOL1   5	/* ISO 8859/1 (ISO Latin 1)                         */
#define	CS_CP437   6	/* IBM codepage 437 (USA)			    */
#define	CS_CP850   7	/* IBM codepage 850 (multinational)		    */
#define	CS_APPLE   8	/* Apple MacIntosh default character set	    */


#define CE_UNCODED 0	/* Content-Transfer-Encoding			    */
#define CE_QUOTEDP 1
#define CE_BASE064 2
#define CE_BINCODE 3
#define CE_NOTIMPL 4
#define CE_PRIVATE 5
#define CE_PRSHEAD 6	/* CE_PRSHEAD and CE_NO_HEAD should have the same   */
#define CE_NO_HEAD 6	/*     numeric value.				    */
#define CE_STRIP_7 7


#define PRIVSIZ   80	/* Buffer size for private (X-...) tokens	    */

#ifdef MAIN
#define EXTERN
#else
#define EXTERN extern
#endif

/*---( globals )------------------------------------------------------------*/

EXTERN int   MimeVers;
EXTERN int   ContType;
EXTERN int   CSubType;
EXTERN int   Encoding;
EXTERN int   Charset;
EXTERN char *NamePar;
EXTERN char PrivCTyp[PRIVSIZ];
EXTERN char PrivSTyp[PRIVSIZ];
EXTERN char PrivCSet[PRIVSIZ];
EXTERN char PrivEncd[PRIVSIZ];
EXTERN char PrivPara[PRIVSIZ];



/*---( public )-------------------------------------------------------------*/

#ifdef __UNIX__
char	      *mktemp(char *t);
#endif

	       /* fold   */
int	       ml_foldinit(int iset, int oset);
unsigned int   ml_foldcto7(unsigned int cc);
unsigned int   ml_foldchar(unsigned int cc);
void           ml_foldbuff(unsigned char *buf);
#ifdef SHOWFOLD
void	       ml_printfold(void);
#endif

	       /* import */
void	       ml_unmimsetup(int cset, int encod, int activ);
void	       ml_unmimedone(void);
int            ml_unmimeline(unsigned char *buf, int *bsiz);

	       /* export */
void	       ml_mimemessage(int headcte, int bodycte, int bodycst, int (*nextchr)(void), FILE *ostream);

/* EOH */
