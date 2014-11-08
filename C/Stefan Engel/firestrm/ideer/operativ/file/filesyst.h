/***********************************************************************/
/* Olika Definitioner som beh”vs till filsystemet                      */
/***********************************************************************/
#define MAXNAMESIZE     64       /* St”rsta filnamnstorleken som det   */
                                 /* g†r att ha i systemet              */
                                 /* Utan noll avslutande byte          */
/***********************************************************************/
/* speciella filer som har betydelse f”r systemets k”rbara biblioteks  */
/* funktioner                                                          */
/***********************************************************************/
#define ICONNAME        ".icon"  /* 2/4/16/256 f„rgers icon            */
                                 /* saknas denna fil plockas icon-     */
                                 /* utseendet fr†n standard iconerna   */
                                 /* som det finns upp till 256 st av.  */
                                 /* Informationen om VILKEN standard   */
                                 /* Icon som skall anv„ndas ligger i   */
                                 /* .info filen                        */
                                 /**************************************/
#define HELPNAME      ".help.??" /* Information som dyker up n„r man   */
                                 /* markerat biblioteket och trycker   */
                                 /* <HELP>, filen f”ljer firestorm-    */
                                 /* help-system, och g”rs i speciell   */
                                 /* editor. ?? ers„tts med spr†k-id:t  */
                                 /**************************************/
#define INFONAME        ".info"  /* info fil f”r systemet, talar om    */
                                 /* tex vilket prog som skall startas  */
                                 /* minneskrav, uppl”sning, mm, som    */
                                 /* beh”vs f”r att kunna k”ra          */
                                 /* programmet.                        */
                                 /**************************************/
#define
/***********************************************************************/
/* beskrivning av olika filattribut (bitarna „r viktiga)               */
/***********************************************************************/
#define FA_READ1        0x0001   /* Attribut f”r att f† l„sa fr†n      */
#define FA_READ2        0x0002   /* filen / i biblioteket f”r „gare,   */
#define FA_READ3        0x0004   /* grupp, alla andra
                                 /**************************************/
#define FA_WRITE1       0x0008   /* Attribut f”r att f† skriva till    */
#define FA_WRITE2       0x0010   /* filen / i biblioteket f”r „gare,   */
#define FA_WRITE3       0x0020   /* Gruppe, och alla andra             */
                                 /**************************************/
#define FA_EXECUTE1     0x0040   /* Attribut f”r att f† k”ra filen /   */
#define FA_EXECUTE2     0x0080   /* f”rflytta sig in i biblioteket     */
#define FA_EXECUTE3     0x0100   /* f”r „garen, gruppen och alla andra */
                                 /**************************************/
#define FA_ARCHIVE      0x0200   /* Attribut f”r att tala om att filen */
                                 /* „r ett Arkiv, bunt av packade filer*/
                                 /* som OS:et betraktar som ett        */
                                 /* bibliotek, vad g„ller kopiering,   */
                                 /* mm, fungerar ej som ett k”rbart    */
                                 /* bibliotek.                         */
                                 /**************************************/
#define FA_DIRECTORY    0x0400   /* Talar om att det „r ett Bibliotek  */
                                 /**************************************/
#define FA_HIDDEN       0x0800   /* Talar om ifall filen „r g”md, ej   */
                                 /* synlig i OS:et.                    */
                                 /**************************************/
#define FA_SYSTEM       0x1000   /* Talar om ifall filen „r en system- */
                                 /* fil.                               */
                                 /**************************************/
#define FA_LINK         0x2000   /* Talar om ifall filen „r l„nkad     */
                                 /* till ett annat st„lle              */
                                 /**************************************/
#define FA_LINKED       0x4000   /* Talar om ifall filen „r en l„nk    */
                                 /* Till en annan fil                  */
                                 /**************************************/
#define FA_ENCRYPTED    0x8000   /* Talar om att filen „r kodad, f”r   */
                                 /* att kunna l„sa in den okodad s†    */
                                 /* m†ste man ange ett l”senord. detta */
                                 /* ligger inte lagrad, utan filen „r  */
                                 /* Helt enkelt kodat med detta l”sen  */
                                 /* som nyckel                         */
                                 /* Och i slutet av den kodade filen   */
                                 /* Ligger en CRC som m†ste st„mma     */
                                 /* efter upppackning                  */
/***********************************************************************/
/* Beskrivning av Filinformationen, DATE                               */
/***********************************************************************/
typedef struct DATE
{
  unsigned year   :23;           /* Actual Year after BC               */
  unsigned month  :4 ;           /* M†nad 1-12 p† †ret                 */
  unsigned day    :5 ;           /* Dag 1-31 i m†naden                 */
}
/***********************************************************************/
/* Beskrivning av Filinformationen, TIME                               */
/***********************************************************************/
typedef struct _TIME
{
  unsigned hour   :5 ;           /* Timme 0-23 p† dagen                */
  unsignde minut  :6 ;           /* Minut 0-59 p† timmen               */
  unsigned second :5 ;           /* Sekund 0,2,4...,58 p† minuten      */
                                 /* OBS! Varannan sekund endast        */
} TIME
/***********************************************************************/
/* Beskrivning av fil-strukturen                                       */
/***********************************************************************/
typedef struct _FILESTRUCT
{
  char             name[MAXNAMESIZE];
  unsigned short   fileatribs;
  DATE             date;
  TIME             time;
} FILESTRUCT