/************************************************************************/
/*                                                                      */
/*      File I/O Definitions                                            */
/*                                                                      */
/*      The definitions in this section are used by the run-time        */
/*      package to provide an interface between CP/M-68K I/O and        */
/*      standard C I/O.                                                 */
/*                                                                      */
/************************************************************************/
 
 
/****************************************************************************/
/*      Miscellaneous Definitions:                                          */
/****************************************************************************/
 
#define FAILURE (-1)                    /*      Function failure return val */
#define SUCCESS (0)                     /*      Function success return val */
#define YES     1                       /*      "TRUE"                      */
#define NO      0                       /*      "FALSE"                     */
#define FOREVER for(;;)                 /*      Infinite loop declaration   */
#define NULL    0                       /*      Null pointer value          */
#define EOF     (-1)                    /*      EOF Value                   */
#define TRUE    (1)                     /*      Function TRUE  value        */
#define FALSE   (0)                     /*      Function FALSE value        */
#define BUFSIZE 128                     /*      # bytes in a buffer         */
 
/**/
 
 
 
 
 
/****************************************************************************/
/*                                                                          */
/*                              M A C R O S                                 */
/*                              -----------                                 */
/*                                                                          */
/*      Define some stuff as macros ....                                    */
/*                                                                          */
/****************************************************************************/
 
 
#define getchar()   ((char) BDOS(CONIN, 0))  /* Get character from console  */
 
/**/
 
#define isalpha(c) (islower(c)||isupper(c))     /* true if "c" a letter     */
#define isdigit(c) ('0' <= (c) && (c) <= '9')   /* Ascii only!!             */
#define iswhite(c) ((c) <= 040 || 0177<= (c))   /* Is control / funny char  */
#define iswild(c)  ((c) == '*' || (c) == '?')	/* true if a wildcard char  */
/**/
#define islower(c) ('a' <= (c) && (c) <= 'z')   /* Ascii only!!             */
#define isupper(c) ('A' <= (c) && (c) <= 'Z')   /* Ascii only!!             */
/**/
#define tolower(c) (isupper(c) ? ((c)+040):(c)) /* translate to lower case  */
#define toupper(c) (islower(c) ? ((c)-040):(c)) /* translate to upper case  */
/**/
#define abs(x)     ((x) < 0 ? -(x) : (x))       /* Absolute value function  */
#define max(x,y)   (((x) > (y)) ? (x) :  (y))   /* Max function             */
#define min(x,y)   (((x) < (y)) ? (x) :  (y))   /* Min function             */
/**/
 
 
/************************************************************************/
/*                                                                      */
/*      BDOS Procedure Declaration                                      */
/*                                                                      */
/************************************************************************/
 
long BDOS();
 
/***/
