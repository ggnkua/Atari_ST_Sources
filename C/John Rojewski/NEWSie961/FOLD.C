/* fold.c  1994 may 19  [gh]
+-----------------------------------------------------------------------------
| Abstract:
|    Fold character sets between different environments based on using
|    ISO Latin 1 as its intermediate encoding.
|
| History:
|    2.0 94 may 19 [gh] Release of version 2.0
|    1.1 94 feb 01 [gh] Improved documentation and MIME support.
|    1.0 94 jan 03 [gh] Wrote first version.
|
| Authorship:
|    Copyright (c) 1994 Gisle Hannemyr.
|    Permission is granted to hack, make and distribute copies of this program
|    as long as this copyright notice is not removed.
|    Flames, bug reports, comments and improvements to:
|       snail: Gisle Hannemyr, Hegermannsgt. 13-3, 0478 Oslo, Norway
|       email: gisle@oslonett.no
|
| Bugs:
|    We may lose information if both source and destination character sets
|    contain characters absent from ISO 8859/1. An approach based on
|    ISO-10646 or Unicode using sparse arrays or mnemonics would have
|    avoided this problem, but would have been much bigger and slower.
+---------------------------------------------------------------------------*/

/* #include "config.h" */
#include <stdio.h>
#include "mimelite.h"

/*---( defines )------------------------------------------------------------*/

#define CONVERROR -4	/* The negative values denote special semantics.    */
#define DONOTHING -3
#define ASCII_ISO -2	/* All conversions is either to or from Latin 1.    */
#define IR060_ISO -1
#define ISO_ASCII  0	/* Zero and positive values is to be interprted as  */
#define ISO_IR060  1	/* indices into array  FoldTables doing the actual  */
#define CP437_ISO  2    /* conversion.					    */
#define ISO_CP437  3
#define CP850_ISO  4
#define ISO_CP850  5
#define ISO_APPLE  6
#define APPLE_ISO  7

			/* Characters to use for missing graphemes	    */
#define XXI      191	/* ISO Latin 1	      : Inverted question mark	    */
#define XX7       63	/* 7 bit ASCII, etc.  : Question mark (?)	    */
#define XXB      168	/* IBM character sets : Inverted question mark	    */

/*---( globals )------------------------------------------------------------*/

static int ITab	    = CONVERROR;
static int OTab	    = CONVERROR;


/*---( constants )----------------------------------------------------------*/

static unsigned char FoldTables[8][128] = {
   { 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, /* 0         */
     32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, /* ISO_ASCII */
     32, 33,XX7, 76, 36, 89,124,XX7, 34, 99, 97, 34,126, 45,114,XX7, /* ISO IR 2  */
     42,XX7, 50, 51, 39,117,XX7, 42, 44, 49,111, 34,XX7,XX7,XX7, 63, /* IRV       */
     65, 65, 65, 65, 65, 65, 65, 67, 69, 69, 69, 69, 73, 73, 73, 73, /* US-ASCII  */
     68, 78, 79, 79, 79, 79, 79,120, 79, 85, 85, 85, 85, 89,XX7,XX7,
     97, 97, 97, 97, 97, 97, 97, 99,101,101,101,101,105,105,105,105,
    100,110,111,111,111,111,111, 47,111,117,117,117,117,121,XX7,121},
   { 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, /* 1         */
     32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, /* ISO_IR060 */
     32, 33,XX7, 76, 36, 89,124,XX7, 34, 99, 97, 34,126, 45,114,XX7, /* ISO IR 60 */
     42,XX7, 50, 51, 39,117,XX7, 42, 44, 49,111, 34,XX7,XX7,XX7, 63, /* Danish    */
     65, 65, 65, 65, 91, 93, 91, 67, 69, 69, 69, 69, 73, 73, 73, 73, /* Norwegian */
     68, 78, 79, 79, 79, 79, 92,120, 92, 85, 85, 85, 85, 89,XX7,XX7,
     97, 97, 97, 97,123,125,123, 99,101,101,101,101,105,105,105,105,
    100,110,111,111,111,111,124, 47,124,117,117,117,117,121,XX7,121},
   {199,252,233,226,228,224,229,231,234,235,232,239,238,236,196,197, /* 2	  */
    201,230,198,244,246,242,251,249,255,214,220,162,163,165,XXI,XXI, /* CP437_ISO */
    225,237,243,250,241,209,170,186,191,174,172,189,188,161,171,187, /* IBM CP437 */
     35, 35, 35,124, 43, 43, 43, 43, 43, 43,124, 43, 43, 43, 43, 43, /* USA       */
     43, 43, 43, 43, 45, 43, 43, 43, 43, 43, 43, 43, 43, 45, 43, 43,
     43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 35, 45,124,124, 45,
    XXI,223,XXI,XXI,XXI,XXI,181,XXI,XXI,XXI,XXI,XXI,XXI,XXI,XXI,XXI,
    XXI,XXI,XXI,XXI,XXI,XXI,247,XXI,176,183,183,XXI,XXI,178,183, 32},
   { 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, /* 3	  */
     32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, /* ISO_CP437 */
     32,173,155,156,XXB,157,124,XXB,XXB,XXB,166,174,170, 45,169,XXB, /* IBM CP437 */
    248,241,253, 51, 39,230,XXB,250, 44, 49,167,175,172,171,XXB,168, /* USA       */
     65, 65, 65, 65,142,143,146,128, 69,144, 69, 69, 73, 73, 73, 73,
     68,165, 79, 79, 79, 89,153,120,153, 85, 85, 85,154, 89,XXB,225,
    133,160,131, 97,132,134,145,135,138,130,136,137,141,161,140,139,
    XXB,164,149,162,147,111,148,246,148,151,163,150,129,121,XXB,152},
   {199,252,233,226,228,224,229,231,234,235,232,239,238,236,196,197, /* 4         */
    201,230,198,244,246,242,251,249,255,214,220,248,163,216,215,102, /* CP850_ISO */
    225,237,243,250,241,209,170,186,191,174,172,189,188,161,171,187, /* IBM CP850 */
     35, 35, 35,124, 43,193,194,192,169, 43,124, 43, 43,162,165, 43, /* multinat. */
     43, 43, 43, 43, 45, 43,227,195, 43, 43, 43, 43, 43, 45, 43,164,
    240,208,202,203,200,105,205,206,207, 43, 43, 35, 45,166,204, 45,
    211,223,212,210,245,213,181,254,222,218,219,217,253,221,175,180,
     45,177, 61,190,182,167,247, 45,176,168,183,185,179,178,183, 32},
   { 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, /* 5         */
     32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, /* ISO_CP850 */
     32,173,189,156,207,190,221,245,249,184,166,174,170, 45,169,238, /* IBM CP850 */
    248,241,253,252,239,230,244,250, 44,251,167,175,172,171,243,168, /* multinat. */
    183,181,182,199,142,143,146,128,212,144,210,211,222,214,215,216,
    209,165,227,224,226,229,153,158,157,235,233,234,154,237,232,225,
    133,160,131,198,132,134,145,135,138,130,136,137,141,161,140,139,
    208,164,149,162,147,228,148,246,155,151,163,150,129,236,231,152},
   { 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, /* 6         */
     32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, /* ISO_APPLE */
    202,193,162,163,192,180,124,164,172,169,187,199,194, 45,168, 45,
    161,177, 50, 51,171,181,166,165, 44, 49,188,200,192,192,192,192,
    203, 65, 65,204,128,129,174,130, 69,131, 69, 69, 73, 73, 73, 73,
     68,132, 79, 79, 79,205,133,120,175, 85, 85, 85,134, 89,192,167,
    136,135,137,139,138,140,190,141,143,142,144,145,147,146,148,149,
    182,150,152,151,153,155,154,214,191,157,156,158,159,121,192,216},
   {196,197,199,201,209,214,220,225,224,226,228,227,229,231,233,232, /* 7         */
    234,235,237,236,238,239,241,243,242,244,246,245,250,249,251,252, /* APPLE_ISO */
    191,176,162,163,167,183,182,223,174,169,191,180,168,191,198,216,
    191,177,191,191,165,181,240,191,191,191,191,170,186,191,230,248,
    191,161,172,191,191,191,191,171,187,191,160,192,195,213,191,191,
     45, 45, 34, 34, 39, 39,247,191,255,191,191,191,191,191,191,191,
    191,191,191,191,191,191,191,191,191,191,191,191,191,191,191,191,
    191,191,191,191,191,191,191,191,191,191,191,191,191,191,191,191}
}; /*  FoldTables */


/*---( functions )----------------------------------------------------------*/

/*
| Abs: Explicitly initialize folding tables.
| Par: iset = source character set
|      oset = target character set
| Sef: Selects folding tables (ITab and OTab).
| Ret: Nonzero if OK, zero if failure.
*/
int ml_foldinit(int iset, int oset)
{
    static int target = CS_UNKWN;

    if (oset != CS_IGNOR) target = oset;
    if (iset == target) {
	ITab = OTab = DONOTHING;
	return(1);
    } /* if (iset == oset, so no point in folding) */

    switch (iset) {
      case CS_IGNOR:			break;
      case CS_UNKWN: /* FALLTHROUGH */
      case CS_PRIVT: /* FALLTHROUGH */
      case CS_ASCII: ITab = DONOTHING;	break;
      case CS_IR060: ITab = IR060_ISO;	break;
      case CS_ISOL1: ITab = DONOTHING;	break;
      case CS_CP437: ITab = CP437_ISO;	break;
      case CS_CP850: ITab = CP850_ISO;	break;
      case CS_APPLE: ITab = APPLE_ISO;	break;
      default:       ITab = CONVERROR;  return(0);
    } /* switch */

    switch (oset) {
      case CS_IGNOR:			break;
      case CS_UNKWN: /* FALLTHROUGH */
      case CS_PRIVT: OTab = CONVERROR;  return(0);
      case CS_ASCII: OTab = ISO_ASCII;	break;
      case CS_IR060: OTab = ISO_IR060;	break;
      case CS_ISOL1: OTab = DONOTHING;	break;
      case CS_CP437: OTab = ISO_CP437;	break;
      case CS_CP850: OTab = ISO_CP850;	break;
      case CS_APPLE: OTab = ISO_APPLE;	break;
      default:	     OTab = CONVERROR;  return(0);
    } /* switch */

    return(1);
} /* ml_foldinit */



/*
| Abs: Fold one charcter to 7 bits using heuristics.
*/
unsigned int ml_foldcto7(unsigned int cc)
{
    if ((cc >= 128) && (ITab >=  0)) cc = FoldTables[ITab]     [cc - 128];
    if  (cc >= 128)		     cc = FoldTables[ISO_ASCII][cc - 128];
    return(cc);
} /* ml_foldcto7 */


/*
| Abs: Fold one charcter.
*/
unsigned int ml_foldchar(unsigned int cc)
{
    if (ITab == IR060_ISO) {
	if (((cc >= 91) && (cc <= 93)) || ((cc >= 123) && (cc <= 125))) {
	    if      ( 91 == cc) cc = 198;
	    else if ( 92 == cc) cc = 216;
	    else if ( 93 == cc) cc = 195;
	    else if (123 == cc) cc = 230;
	    else if (124 == cc) cc = 248;
	    else if (125 == cc) cc = 229;
	} /* if (ISO IR-60, Norwegian/Danish) */
    } else
    if ((cc >= 128) && (ITab >=  0)) cc = FoldTables[ITab][cc - 128];

    if ((cc >= 128) && (OTab >=  0)) cc = FoldTables[OTab][cc - 128];
    return(cc);
} /* ml_foldchar */


/*
| Abs: Fold all the character in a text buffer terminated by '\0'.
*/
void ml_foldbuff(unsigned char *buf)
{
    int ii;

    if (!buf)	      return;
    if (ITab == OTab) return;
    ii = 0;
    while (buf[ii]) {
	buf[ii] = ml_foldchar(buf[ii]);
	ii++;
    } /* while */
} /* ml_foldbuff */



#ifdef SHOWFOLD

/*---( debug )--------------------------------------------------------------*/

static void printconv(int ii)
{
    switch (ii) {
      case CONVERROR: fputs("*ERROR*",	  stderr); break;
      case DONOTHING: fputs("*NONE*",	  stderr); break;
      case ASCII_ISO: fputs("ASCII->ISO", stderr); break;
      case IR060_ISO: fputs("IR060->ISO", stderr); break;
      case ISO_ASCII: fputs("ISO->ASCII", stderr); break;
      case ISO_IR060: fputs("ISO->IR060", stderr); break;
      case CP437_ISO: fputs("CP437->ISO", stderr); break;
      case ISO_CP437: fputs("ISO->CP437", stderr); break;
      case CP850_ISO: fputs("CP850->ISO", stderr); break;
      case ISO_CP850: fputs("ISO->CP850", stderr); break;
      case ISO_APPLE: fputs("ISO->APPLE", stderr); break;
      case APPLE_ISO: fputs("APPLE->ISO", stderr); break;
      default:        fputs("*DEFAULT*",  stderr);
    } /* switch */
} /* printconv */


/*
| Abs: Display the foldings actually performed.
| Des: For debugging.
*/
void ml_printfold(void)
{
    fputs("\nFoldings:      ", stderr);
    printconv(ITab);
    fputs(" + ", stderr);
    printconv(OTab);
} /* ml_printfold */

#endif

/* EOF */
