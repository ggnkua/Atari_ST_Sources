/*  File        : Token.c
    Author      : Richard A. O'Keefe
    Modified by : Deeporn H. Beardsley & Saumya Debray
    Updated     : Summer 1988
    Purpose     : Tokenizer for SB-Prolog.
 
*/
 
#ifdef  vms
#include stdio
#else
#include <stdio.h>
#endif
 
/* stuff defined to interface with SB-Prolog */

#include "builtin.h"
#include <errno.h>
 
/*  We used to use an 8-bit character set under VMS, but 7-bit ASCII
 *  elsewhere.  Now that DIS 8859/1 exists (a draft international
 *  standard for an 8-bit extension of ASCII) we use that, and we are
 *  in luck: it is almost identical to the VMS character set.
 */
#define AlphabetSize 256
#define SBPMAXINT       268435455
 
extern  char *strcpy(/* CHAR_PTR, CHAR_PTR */);
#define StrCpy(dst, src) (void)strcpy(dst, src)
#define Printf           (void)printf
#define Sprintf          (void)sprintf
#define Fprintf          (void)fprintf
 
#define InRange(X,L,U) ((unsigned)((X)-(L)) <= (unsigned)((U)-(L)))
#define IsLayout(X) InRange(InType(X), SPACE, EOLN)
 
/*  VERY IMPORTANT NOTE: I assume that the stdio library returns the value
 *  EOF when character input hits the end of the file, and that this value
 *  is actually the integer -1.  You will note the DigVal(), InType(), and
 *  OuType() macros below, and there is a ChType() macro used in crack().
 *  They all depend on this assumption.
 */
 
#define DIGIT    0              /* 0 .. 9 */
#define BREAK    1              /* _ */
#define UPPER    2              /* A .. Z */
#define LOWER    3              /* a .. z */
#define SIGN     4              /* -/+*<=>#@$\^&~`:.? */
#define NOBLE    5              /* !; (don't form compounds) */
#define PUNCT    6              /* (),[]|{}% */
#define ATMQT    7              /* ' (atom quote) */
#define LISQT    8              /* " (list quote) */
#define STRQT    9              /* $ (string quote) */
#define CHRQT   10              /* ` (character quote, maybe) */
#define TILDE   11              /* ~ (like character quote but buggy) */
#define SPACE   12              /* layout and control chars */
#define EOLN    13              /* line terminators ^J ^L */
#define REALO   14              /* floating point number */
#define EOFCH   15              /* end of file */
#define ALPHA   DIGIT           /* any of digit, break, upper, lower */
#define BEGIN   BREAK           /* atom left-paren pair */
#define ENDCL   EOLN            /* end of clause token */
#define RREAL	16		/* radix number(real) - overflowed */
#define RDIGIT	17		/* radix number(int) */
 
#define InType(c)  (intab.chtype+1)[c]
#define DigVal(c)  (digval+1)[c]
 
BYTE outqt[EOFCH+1];
 
struct CHARS
{
   int  eolcom;         /* End-of-line comment, default % */
   int  endeol;         /* early terminator of eolcoms, default none */
   int  begcom;         /* In-line comment start, default / */
   int  astcom;         /* In-line comment second, default * */
   int  endcom;         /* In-line comment finish, default / */
   int  radix;          /* Radix character, default ' */
   int  dpoint;         /* Decimal point, default . */
   int  escape;         /* String escape character, default \ */
   int  termin;         /* Terminates a clause */
   CHAR chtype[AlphabetSize+1];
};
 
struct CHARS intab =       /* Special character table */
{
   '%',                    /* eolcom: end of line comments */
   -1,                     /* endeol: early end for eolcoms */
   '/',                    /* begcom: in-line comments */
   '*',                    /* astcom: in-line comments */
   '/',                    /* endcom: in-line comments */
   '\'',                   /* radix : radix separator */
   '.',                    /* dpoint: decimal point */
   -1,                     /* escape: string escape character */
   '.',                    /* termin: ends clause, sign or solo */
   {
       EOFCH,                  /* really the -1th element of the table: */
   /*  ^@      ^A      ^B      ^C      ^D      ^E      ^F      ^G      */
       SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,
   /*  ^H      ^I      ^J      ^K      ^L      ^M      ^N      ^O      */
       SPACE,  SPACE,  EOLN,   SPACE,  EOLN,   SPACE,  SPACE,  SPACE,
   /*  ^P      ^Q      ^R      ^S      ^T      ^U      ^V      ^W      */
       SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,
   /*  ^X      ^Y      ^Z      ^[      ^\      ^]      ^^      ^_      */
       SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,
   /*  sp      !       "       #       $       %       &       '       */
       SPACE,  NOBLE,  LISQT,  SIGN,   LOWER,  PUNCT,  SIGN,   ATMQT,
   /*  (       )       *       +       ,       -       .       /       */
       PUNCT,  PUNCT,  SIGN,   SIGN,   PUNCT,  SIGN,   SIGN,   SIGN,
   /*  0       1       2       3       4       5       6       7       */
       DIGIT,  DIGIT,  DIGIT,  DIGIT,  DIGIT,  DIGIT,  DIGIT,  DIGIT,
   /*  8       9       :       ;       <       =       >       ?       */
       DIGIT,  DIGIT,  SIGN,   PUNCT,  SIGN,   SIGN,   SIGN,   SIGN,
   /*  @       A       B       C       D       E       F       G       */
       SIGN,   UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,
   /*  H       I       J       K       L       M       N       O       */
       UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,
   /*  P       Q       R       S       T       U       V       W       */
       UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,
   /*  X       Y       Z       [       \       ]       ^       _       */
       UPPER,  UPPER,  UPPER,  PUNCT,  SIGN,   PUNCT,  SIGN,   BREAK,
   /*  `       a       b       c       d       e       f       g       */
       SIGN,   LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,
   /*  h       i       j       k       l       m       n       o       */
       LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,
   /*  p       q       r       s       t       u       v       w       */
       LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,
   /*  x       y       z       {       |       }       ~       ^?      */
       LOWER,  LOWER,  LOWER,  PUNCT,  PUNCT,  PUNCT,  SIGN,   SPACE,
   /*  128     129     130     131     132     133     134     135     */
       SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,
   /*  136     137     138     139     140     141     142     143     */
       SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,
   /*  144     145     146     147     148     149     150     151     */
       SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,
   /*  152     153     154     155     156     157     158     159     */
       SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,  SPACE,
   /*  NBSP    !-inv   cents   pounds  ching   yen     brobar  section */
       SPACE,  SIGN,   SIGN,   SIGN,   SIGN,   SIGN,   SIGN,   SIGN,
   /*  "accent copyr   -a ord  <<      nothook SHY     (reg)   ovbar   */
       SIGN,   SIGN,   LOWER,  SIGN,   SIGN,   SIGN,   SIGN,   SIGN,
   /*  degrees +/-     super 2 super 3 -       micron  pilcrow -       */
       SIGN,   SIGN,   LOWER,  LOWER,  SIGN,   SIGN,   SIGN,   SIGN,
   /*  ,       super 1 -o ord  >>      1/4     1/2     3/4     ?-inv   */
       SIGN,   LOWER,  LOWER,  SIGN,   SIGN,   SIGN,   SIGN,   SIGN,
   /*  `A      'A      ^A      ~A      "A      oA      AE      ,C      */
       UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,
   /*  `E      'E      ^E      "E      `I      'I      ^I      "I      */
       UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,
   /*  ETH     ~N      `O      'O      ^O      ~O      "O      x times */
#ifdef  vms
       UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,
#else
       UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  SIGN,
#endif
   /*  /O      `U      'U      ^U      "U      'Y      THORN   ,B      */
       UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  UPPER,  LOWER,
   /*  `a      'a      ^a      ~a      "a      oa      ae      ,c      */
       LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,
   /*  `e      'e      ^e      "e      `i      'i      ^i      "i      */
       LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,
   /*  eth     ~n      `o      'o      ^o      ~o      "o      -:-     */
#ifdef  vms
       LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,
#else
       LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  SIGN,
#endif
   /*  /o      `u      'u      ^u      "u      'y      thorn  "y       */
#ifdef  vms
       LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  SPACE
#else
       LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER,  LOWER
#endif
   }
};
 
CHAR digval[AlphabetSize+1] =
{
        99,                     /* really the -1th element of the table */
    /*  ^@      ^A      ^B      ^C      ^D      ^E      ^F      ^G      */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  ^H      ^I      ^J      ^K      ^L      ^M      ^N      ^O      */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  ^P      ^Q      ^R      ^S      ^T      ^U      ^V      ^W      */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  ^X      ^Y      ^Z      ^[      ^\      ^]      ^^      ^_      */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  sp      !       "       #       $       %       &       '       */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  (       )       *       +       ,       -       .       /       */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  0       1       2       3       4       5       6       7       */
        0,      1,      2,      3,      4,      5,      6,      7,
    /*  8       9       :       ;       <       =       >       ?       */
        8,      9,      99,     99,     99,     99,     99,     99,
    /*  @       A       B       C       D       E       F       G       */
        99,     10,     11,     12,     13,     14,     15,     99,
    /*  H       I       J       K       L       M       N       O       */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  P       Q       R       S       T       U       V       W       */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  X       Y       Z       [       \       ]       ^       _       */
        99,     99,     99,     99,     99,     99,     99,     0,  /*NB*/
    /*  `       a       b       c       d       e       f       g       */
        99,     10,     11,     12,     13,     14,     15,     99,
    /*  h       i       j       k       l       m       n       o       */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  p       q       r       s       t       u       v       w       */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  x       y       z       {       |       }       ~       ^?      */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  128     129     130     131     132     133     134     135     */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  136     137     138     139     140     141     142     143     */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  144     145     146     147     148     149     150     151     */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  152     153     154     155     156     157     158     159     */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  160     161     162     163     164     165     166     167     */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  168     169     170(-a) 171     172     173     174     175     */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  176     177     178(2)  179(3)  180     181     182     183     */
        99,     99,     2,      3,      99,     99,     99,     99,
    /*  184     185(1)  186(-o) 187     188     189     190     191     */
        99,     1,      99,     99,     99,     99,     99,     99,
    /*  192     193     194     195     196     197     198     199     */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  200     201     202     203     204     205     206     207     */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  208     209     210     211     212     213     214     215     */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  216     217     218     219     220     221     222     223     */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  224     225     226     227     228     229     230     231     */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  232     233     234     235     236     237     238     239     */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  240     241     242     243     244     245     246     247     */
        99,     99,     99,     99,     99,     99,     99,     99,
    /*  248     249     250     251     252     253     254     255     */
        99,     999,     99,     99,     99,     99,     99,     99
    };
 
 
/* values returned to calling program */

#define SPECIAL 0       /* puncuation , ( ) [ ] ... */
#define VARO    1       /* type is a variable */
#define FUNC	2	/* type is atom( */
#define NUMBERO 3       /* type is a number */
#define ATOMO   4       /* type is an atom */
#define ENDCLS	5       /* END of clause but not file */
#define USCORE  6       /* underscore '_' */
#define SEMI	7	/* ; */
#define BADEND  8       /* END of file, not end of clause */
#define STRING  9       /* type is a char string */

int cNUMERO = 0, cATOMO   = 0, cFUNC = 0, cVARO   = 0, cUSCORE = 0,
    cSTRING = 0, cSPECIAL = 0, cSEMI = 0, cENDCLS = 0, cENDPRG = 0;

extern LONG_PTR insert();
static BYTE perm = PERM;

extern FILE *curr_in, *curr_out;    /* current input, output streams */
 
 
void SyntaxError(message)
CHAR_PTR message;
{
   Fprintf(stderr, "Syntax error: %s\n", message);
   exit(1);
}
 
/*  GetToken() reads a single token from the input stream and returns
 *  its type, which is one of
 *      DIGIT   -- a number
 *      BEGIN   -- an atom( pair
 *      LOWER   -- an atom
 *      UPPER   -- a variable
 *      PUNCT   -- a single punctuation mark
 *      LISQT   -- a quoted list of character codes
 *      STRQT   -- a quoted string
 *      ENDCL   -- end of clause (normally '.\n').
 *      EOFCH   -- signifies end-of-file.
 *      RREAL   -- a real, from some radix notation, in double_v.
 *      RDIGIT  -- an integer, from some radix notation, in rad_int.
 *  In all cases except the last, the text of the token is in AtomStr.
 *  There are two questions: between which pairs of adjacent tokens is
 *  a space (a) necessary, (b) desirable?  There is an additional
 *  dummy token type used by the output routines, namely
 *      NOBLE   -- extra space is definitely not needed.
 *  I leave it as an exercise for the reader to answer question (a).
 *  Since this program is to produce output I find palatable (even if
 *  it isn't exactly what I'd write myself), extra spaces are ok.  In
 *  fact, the main use of this program is as an editor command, so it
 *  is normal to do a bit of manual post-processing.  Question (b) is
 *  the one to worry about then.  My answer is that a space is never
 *  written
 *      - after  PUNCT ( [ { |
 *      - before PUNCT ) ] } | , <ENDCL>
 *  is written after comma only sometimes, and is otherwise always
 *  written.  The variable lastput thus takes these values:
 *      ALPHA   -- put a space except before PUNCT
 *      SIGN    -- as alpha, but different so ENDCL knows to put a space.
 *      NOBLE   -- don't put a space
 *      ENDCL   -- just ended a clause
 *      EOFCH   -- at beginning of file
 */
 
int     lastc = ' ';    /* previous character */
#define MaxStrLen      1000 
BYTE    AtomStr[MaxStrLen+20];
LONG    list_p;
int     rtnint;
double  double_v;
LONG    rad_int;
 
CHAR    tok2long[] = "token too long";
CHAR    eofinrem[] = "end of file in comment";
CHAR    badexpt[]  = "bad exponent";
CHAR    badradix[] = "radix > 36";
 
 
/*  read_character(FILE* card, BYTE q)
 *  reads one character from a quoted atom, list, string, or character.
 *  Doubled quotes are read as single characters, otherwise a
 *  quote is returned as -1 and lastc is set to the next character.
 *  If the input syntax has character escapes, they are processed.
 *  Note that many more character escape sequences are accepted than
 *  are generated.  There is a divergence from C: \xhh sequences are
 *  two hexadecimal digits long, not three.
 *  Note that the \c and \<space> sequences combine to make a pretty
 *  way of continuing strings.  Do it like this:
 *      "This is a string, which \c
 *     \ has to be continued over \c
 *     \ several lines.\n".
 */
 
int read_character(card, q)
register FILE *card;
register int q;
{
   register int c;
 
   c = getc(card);
BACK:
   if (c < 0) {
DOERR:
      if (q < 0)
         SyntaxError("end of file in character constant");
      else {
         CHAR message[80];
         Sprintf(message, "end of file in %cquoted%c constant", q, q);
         SyntaxError(message);
      }
   }
   if (c == q) {
      c = getc(card);
      if (c == q)
	 return c;
      lastc = c;
      return -1;
   } else if (c != intab.escape)
      return c;
 
   /*  If we get here, we have read the "\" of an escape sequence  */

   c = getc(card);
   switch (c) {
      case EOF:
	 clearerr(curr_in);
	 goto DOERR;
      case 'n':  case 'N':         /* newline */
         return 10;
      case 't':  case 'T':         /* tab */
         return  9;
      case 'r':  case 'R':         /* reeturn */
         return 13;
      case 'v':  case 'V':         /* vertical tab */
         return 11;
      case 'b':  case 'B':         /* backspace */
         return  8;
      case 'f':  case 'F':         /* formfeed */
         return 12;
      case 'e':  case 'E':         /* escape */
         return 27;
      case 'd':  case 'D':         /* delete */
         return 127;
      case 's':  case 'S':         /* space */
         return 32;
      case 'a':  case 'A':         /* alarm */
         return  7;
      case '^':                    /* control */
         c = getc(card);
         if (c < 0)
	    goto DOERR;
         return (c == '?' ? 127 : c&31);
      case 'c':  case 'C':         /* continuation */
         while (IsLayout(c = getc(card))) 
	    ;
         goto BACK;
      case 'x':  case 'X':         /* hexadecimal */
         {  int i, n;
            for (n = 0, i = 2; --i >= 0; n = (n<<4) + DigVal(c))
               if (DigVal(c = getc(card)) >= 16) {
                  if (c < 0)
	             goto DOERR;
                  (void)ungetc(c, card);
                  break;
               }
            return (n & 255);
         }
      case 'o':  case 'O':         /* octal */
         c = getc(card);
         if (DigVal(c) >= 8) {
            if (c < 0)
	       goto DOERR;
            (void)ungetc(c, card);
            return 0;
         }
      case '0':  case '1':  case '2':  case '3':
      case '4':  case '5':  case '6':  case '7':
         {  int i, n;
            for (n = c-'0', i = 2; --i >= 0; n = (n<<3) + DigVal(c))
               if (DigVal(c = getc(card)) >= 8) {
                  if (c < 0)
	             goto DOERR;
                  (void)ungetc(c, card);
                  break;
               }
            return (n & 255);
         }
      default:
         if (!IsLayout(c))
	    return c;
         c = getc(card);
         goto BACK;
   }
} 
 
 
/*  com0plain(card, endeol)
 *  These comments have the form
 *      <eolcom> <char>* <newline>                      {PUNCT}
 *  or  <eolcom><eolcom> <char>* <newline>              {SIGN }
 *  depending on the classification of <eolcom>.  Note that we could
 *  handle ADA comments with no trouble at all.  There was a Pop-2
 *  dialect which had end-of-line comments using "!" where the comment
 *  could also be terminated by "!".  You could obtain the effect of
 *  including a "!" in the comment by doubling it, but what you had
 *  then was of course two comments.  The endeol parameter of this
 *  function allows the handling of comments like that which can be
 *  terminated either by a new-line character or an <endeol>, whichever
 *  comes first.  For ordinary purposes, endeol = -1 will do fine.
 *  When this is called, the initial <eolcom>s have been consumed.
 *  We return the first character after the comment.
 *  If the end of the source file is encountered, we do not treat it
 *  as an error, but quietly close the comment and return EOF as the
 *  "FOLLOWing" character.
 */

int com0plain(card, endeol)
register FILE *card;        /* source file */
register int endeol;        /* The closing character "!" */
{
   register int c;
 
   while ((c = getc(card)) >= 0 && c != '\n' && c != endeol)
      ;
   if (c >= 0)
      c = getc(card);
   return c;
}
 
 
/*  The states in the next two functions are
 *      0       - after an uninteresting character
 *      1       - after an "astcom"
 *      2       - after a  "begcom"
 *  Assuming begcom = "(", astom = "#", endcom = ")",
 *  com2plain will accept "(#)" as a complete comment.  This can
 *  be changed by initialising the state to 0 rather than 1.
 *  The same is true of com2nest, which accepts "(#(#)#) as a
 *  complete comment.  Changing it would be rather harder.
 *  Fixing the bug where the closing <astcom> is copied if it is
 *  not an asterisk may entail rejecting "(#)".
 */
 
/*  com2plain(card, astcom, endcom)
 *  handles PL/I-style comments, that is, comments which begin with
 *  a pair of characters <begcom><astcom> and end with a pair of
 *  chracters <astcom><endcom>, where nesting is not allowed.  For
 *  example, if we take begcom='(', astcom='*', endcom=')' as in
 *  Pascal, the comment "(* not a (* plain *)^ comment *) ends at
 *  the "^".
 *  For this kind of comment, it is perfectly sensible for any of
 *  the characters to be equal.  For example, if all three of the
 *  bracket characters are "#", then "## stuff ##" is a comment.
 *  When this is called, the initial <begcom><astcom> has been consumed.
 */

void com2plain(card, astcom, endcom)
register FILE *card;        /* source file */
int astcom;                 /* The asterisk character "*" */
int endcom;                 /* The closing character "/" */
{
   register int c;
   register int state;
 
   for (state = 0; (c = getc(card)) >= 0; ) {
      if (c == endcom && state)
	 break;
      state = c == astcom;
   }
   if (c < 0)
      SyntaxError(eofinrem);
}
 
 
int GetToken()
{
   register FILE *card = curr_in;
   register BYTE_PTR s = AtomStr;
   register int  c, d;
   register int  n = MaxStrLen;
   LONG     oldv = 0, newv = 0; 
   LONG_PTR newpair, list_head, stack_top;
 
   c = lastc;
START:
   switch (InType(c)) {
      case DIGIT:
         /* The FOLLOWing kinds of numbers exist:
          * (1) unsigned decimal integers: d+
          * (2) unsigned based integers: d+Ro+[R]
          * (3) unsigned floats: d* [. d*] [e +/-] d+
          * (4) characters: 0Rc[R]
          * We allow underscores in numbers too, ignoring them.
          */
         do {
            if (c != '_')
	       *s++ = c;
            c = getc(card);
         } while (InType(c) <= BREAK);
         if (c == intab.radix) { 
            *s = 0;
            for (d = 0, s = AtomStr; c = *s++; ) {
               d = d*10-'0'+c;
               if (d > 36)
		  SyntaxError(badradix);
            }
            if (d == 0) {       /*  0'c['] is a character code  */
               d = read_character(card, -1);
               Sprintf(AtomStr, "%d", d);
               d = getc(card);
               lastc = d == intab.radix ? getc(card) : d;
               return DIGIT;
            }
            while (c = getc(card), DigVal(c) < 99)
               if (c != '_') {
		  oldv = newv;
		  newv = newv*d + DigVal(c);
		  if (newv < oldv || newv > SBPMAXINT) {
		     Fprintf(stderr, "*** overflow in radix notation ***\n");
		     double_v = oldv*1.0*d + DigVal(c);
		     while (c = getc(card), DigVal(c) < 99)
                        if (c != '_') 
			   double_v = double_v*d + DigVal(c);
                     if (c == intab.radix)
		        c = getc(card);
                     lastc = c;
		     return RREAL;
		  }
	       }
/*
            Sprintf(AtomStr, "%ld", newv);
*/
	    rad_int = newv;
            if (c == intab.radix)
	       c = getc(card);
            lastc = c;
            return RDIGIT;
         } else if (c == intab.dpoint) {
            d = getc(card);
            if (InType(d) == DIGIT) {
DECIMAL:       *s++ = '.';
               do {
                  if (d != '_')
		     *s++ = d;
                  d = getc(card);
               } while (InType(d) <= BREAK);
               if ((d | 32) == 'e') {
                  *s++ = 'E';
                  d = getc(card);
                  if (d == '-') {
		     *s++ = d;
		     d = getc(card);
		  } else if (d == '+')
		     d = getc(card);
                  if (InType(d) > BREAK)
		     SyntaxError(badexpt);
                  do {
                     if (d != '_')
		        *s++ = d;
                     d = getc(card);
                  } while (InType(d) <= BREAK);
               }
               c = d;
               *s = 0;
	       lastc = c;
               return REALO;
            } else       /* c has not changed */
               ungetc(d, card);
         }
         *s = 0;
	 lastc = c;
         return DIGIT;
 
      case BREAK:
      case UPPER:
         do {
            if (--n < 0)
	       SyntaxError(tok2long);
            *s++ = c;
	    c = getc(card);
         } while (InType(c) <= LOWER);
         *s = 0;
	 lastc = c;
         rtnint = (int)(s - AtomStr);
         return UPPER;
 
      case LOWER:
          do {
             if (--n < 0) SyntaxError(tok2long);
             *s++ = c;
	     c = getc(card);
          } while (InType(c) <= LOWER);
          *s = 0;
SYMBOL:   if (c == '(') {
             lastc = getc(card);
             rtnint = (int)(s - AtomStr);
             return BEGIN;
          } else {
             lastc = c;
             rtnint = (int)(s - AtomStr);
             return LOWER;
          }
 
      case SIGN:
          *s = c;
	  d = getc(card);
          if (c == intab.begcom && d == intab.astcom) {
ASTCOM:      com2plain(card, d, intab.endcom);
             c = getc(card);
             goto START;
          } else if (c == intab.dpoint && InType(d) == DIGIT) {
             *s++ = '0';
             goto DECIMAL;
          }
          while (InType(d) == SIGN) {
             if (--n == 0)
		SyntaxError(tok2long);
             *++s = d;
	     d = getc(card);
          }
          *++s = 0;
          if (InType(d) >= SPACE && c == intab.termin && AtomStr[1] == 0) {
             lastc = d;
             return ENDCL;       /* i.e. '.' FOLLOWed by layout */
          }
          c = d;
          goto SYMBOL;
 
      case NOBLE:
          if (c == intab.termin) {
             *s = 0;
	     lastc = ' ';
             return ENDCL;
          } else if (c == intab.eolcom) {
             c = com0plain(card, intab.endeol);
             goto START;
          }
          *s++ = c;
	  *s = 0;
          lastc = c = getc(card);
          goto SYMBOL;
 
      case PUNCT:
         if (c == intab.termin) {
            *s = 0;
	    lastc = ' ';
            return ENDCL;
         } else if (c == intab.eolcom) {
            c = com0plain(card, intab.endeol);
            goto START;
         }
         d = getc(card);
         if (c == intab.begcom && d == intab.astcom)
	    goto ASTCOM;
 
         /*  If we arrive here, c is an ordinary punctuation mark  */

         if (c == '(')    /* need to distingusih between atom( and atom ( */
            *s++ = ' ';
         lastc = d;
	 *s++ = c;
	 *s = 0;
         rtnint = (int)(s - AtomStr);
         return PUNCT;
 
      case CHRQT:
         /* `c[`] is read as an integer.
           * Eventually we should treat characters as a distinct
           * token type, so they can be generated on output.
           * If the character quote, atom quote, list quote,
           * or string quote is the radix character, we should
           * generate 0'x notation, otherwise `x`.
           */
         d = read_character(card, -1);
         Sprintf(AtomStr, "%d", d);
         d = getc(card);
         lastc = d == c ? getc(card) : d;
         return DIGIT;
 
      case ATMQT:
      case STRQT:
         while ((d = read_character(card, c)) >= 0) {
            if (--n < 0) SyntaxError(tok2long);
            *s++ = d;
         }
         *s = 0;
         rtnint = (int) (s - AtomStr);
         c = lastc;
         goto SYMBOL;

      case LISQT: 
	 /* check for potential heap overflow */
	 /*   (this will guarantee space for lists of up to 50 elements) */
	 stack_top = (breg < ereg) ? breg : ereg - ENV_SIZE(cpreg);
	 if (stack_top < hreg + 100) {
	    /* garbage_collection("GetToken"); */
	    if (stack_top < hreg + 100)    /* still too full */
	       quit("Heap overflow\n");
	 }

	 list_head = newpair = hreg;
         while ((d = read_character(card, c)) >= 0) {
	    hreg += 2;
	    *newpair++ = MAKEINT(d);
	    *newpair++ = (LONG)hreg | LIST_TAG; 
	 }
	 if (list_head == hreg)   /* null string */
	    list_p = nil_sym;
	 else {
	    *(--newpair) = nil_sym;
	    list_p = (LONG)list_head | LIST_TAG;
	 }
	 return LISQT;

      case EOLN:
      case SPACE:
         c = getc(card);
         goto START;
 
      case EOFCH:
	 clearerr(curr_in);
         return EOFCH;
   }
   Fprintf(stderr, "Internal error: InType(%d)==%d\n", c, InType(c));
   abort();                /* There is no way we can get here */
   /*NOTREACHED*/
}

 
void b_NEXT_TOKEN()
{
   register LONG     op;
   register LONG_PTR top;
   register FILE     *card = curr_in;
   int      i, atoi(), oldnum, newnum;
   int      len;
   double   atof();
   LONG     makefloat(), ptr;

   i = GetToken();
   switch (i) {
      case LOWER:
	 op = reg[1];  DEREF(op);  FOLLOW(op) = MAKEINT(ATOMO);
         ptr = (LONG)insert(AtomStr, rtnint, 0, &perm) | CS_TAG;
	 op = reg[2];  DEREF(op);  FOLLOW(op) = ptr;
cATOMO++;
         break;
      case BEGIN:
	 op = reg[1];  DEREF(op);  FOLLOW(op) = MAKEINT(FUNC);
         ptr = (LONG)insert(AtomStr, rtnint, 0, &perm) | CS_TAG;
	 op = reg[2];  DEREF(op);  FOLLOW(op) = ptr;
cFUNC++;
         break;
      case UPPER:
         if (AtomStr[0] == '_' && AtomStr[1] == 0) {
	    op = reg[1];  DEREF(op);  FOLLOW(op) = MAKEINT(USCORE);
cUSCORE++;
         } else {
	    op = reg[1];  DEREF(op);  FOLLOW(op) = MAKEINT(VARO);
cVARO++;
	 }
	 if (rtnint > 256) {
	    AtomStr[256] = 0;
	    rtnint = 256;
	    Fprintf(stderr, "*** Name of constant too long: %s\n", AtomStr);
         }
	 ptr = (LONG)insert(AtomStr, rtnint, 0, &perm) | CS_TAG;
	 op = reg[2];  DEREF(op);  FOLLOW(op) = ptr;
         break;
      case REALO:
	 op = reg[2];  DEREF(op);
	 FOLLOW(op) = makefloat(atof(AtomStr));
	 op = reg[1];  DEREF(op);  FOLLOW(op) = MAKEINT(NUMBERO);
cNUMERO++;
         break;
      case RREAL:
	 op = reg[2];  DEREF(op);  FOLLOW(op) = makefloat(double_v);
	 op = reg[1];  DEREF(op);  FOLLOW(op) = MAKEINT(NUMBERO);
cNUMERO++;
	 break;
      case RDIGIT:
cNUMERO++;
	 op = reg[1];  DEREF(op);  FOLLOW(op) = MAKEINT(NUMBERO);
	 op = reg[2];  DEREF(op);  FOLLOW(op) = MAKEINT(rad_int);
	 break;
      case DIGIT:
cNUMERO++;
	 op = reg[1];  DEREF(op);  FOLLOW(op) = MAKEINT(NUMBERO);
	 op = reg[2];  DEREF(op); 
	 for (len = oldnum = newnum = 0; AtomStr[len] != 0; len++) {
      	    oldnum = newnum;
    	    newnum = newnum * 10 + DigVal(AtomStr[len]);
    	    if (newnum < oldnum || newnum > SBPMAXINT) {
	       Fprintf(stderr, "*** overflow >> %s\n", AtomStr);
	       len = strlen(AtomStr);
	       AtomStr[len++] = '.';    
	       AtomStr[len++] = '0';
	       AtomStr[len] = 0;
	       FOLLOW(op) = makefloat(atof(AtomStr));
	       return;
	    }
	 }
     	 FOLLOW(op) = MAKEINT(newnum);
         break;
      case LISQT:
	 op = reg[1];  DEREF(op);  FOLLOW(op) = MAKEINT(STRING);
	 op = reg[2];  DEREF(op);  FOLLOW(op) = list_p;
cSTRING++;
         break;
      case PUNCT:
         /* there are nine punctuation marks, */
         /* ( , )  [ | ]  { ; }  */
         /* % is listed as one, but isn't really. */
         if (AtomStr[0] == ';') {
	    op = reg[1];  DEREF(op);  FOLLOW(op) = MAKEINT(SEMI);
cSEMI++;
         } else {
	    op = reg[1];  DEREF(op);  FOLLOW(op) = MAKEINT(SPECIAL);
cSPECIAL++;
            ptr = (LONG)insert(AtomStr, rtnint, 0, &perm) | CS_TAG;
	    op = reg[2];  DEREF(op);  FOLLOW(op) = ptr;
         }
         break;
      case ENDCL:
	 op = reg[1];  DEREF(op);  FOLLOW(op) = MAKEINT(ENDCLS);
cENDCLS++;
         break;
      case EOFCH:
	 op = reg[1];  DEREF(op);  FOLLOW(op) = MAKEINT(BADEND);
         break;
      default:
         Fprintf(stderr, "Internal error %d %s\n", i, AtomStr);
   }
}

