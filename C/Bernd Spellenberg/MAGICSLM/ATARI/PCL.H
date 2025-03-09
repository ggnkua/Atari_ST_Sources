/* MagicSLM - PCL Header                       */
/* by Bernd Spellenberg & Harald Sch”nfeld     */
/* (c) Maxon 1995                              */

#define LISTELEMANZ   128L    /* Max. Anzahl   */
                     /* bekannter PCL Befehle  */

#define NOARG  1  /* PCL Befehl ohne Argument  */
#define ARG    2              /* ... mit ...   */

typedef struct {           /* PCL Befehl       */
   char     *BefPrefix;    /* Anfangsequenz    */
   int       Type;         /* Argument j/n     */
} PCLBEFEHL;

typedef struct ELEM {      /* Listeneintrag    */

   struct ELEM *NextElemInLine;  /* Zeiger auf */
         /* n„chsten Befehl in gleicher Ebene  */

   struct ELEM *FirstElemNextLine; /* Zeiger   */
      /* auf n„chsten Bef. in tieferer Ebene   */
      
   int   BefehlNo;   /* Nummer des PCL Befehls */
   char  Zchn;    /* n„chstes Eingabezeichen   */
} LISTELEM;


LISTELEM *FindNextElemInLine (LISTELEM *CurrElem,
                              char Zchn);
LISTELEM *FindEndOfLine (LISTELEM *CurrElem);
void PutNextCmdInList (int CmdNo);
void CopyRaster (unsigned char *To,
                 unsigned char *From,
                 long Length, long Offset);
