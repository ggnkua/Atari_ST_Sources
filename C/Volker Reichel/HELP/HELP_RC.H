/************************************************/
/*                                              */
/*  H E L P F I L E - R E C O M P I L E R  1.0  */
/*                                              */
/*  Headerfile HELP_RC.H                        */
/*                                              */
/*  Autor: Volker Reichel                       */
/*         BÅhlstraûe 8                         */
/*         7507 Pfinztal 2                      */
/*                                              */
/*  Letzte énderung: 31.01.1992                 */
/************************************************/


/*-------- allgemeine Konstanten----------------*/
#define EOS        0x00
#define CR         0x0d
#define LF         0x0a
#define ESC_CHR    0x1d
#define BACKSLASH  '\\'

/*-------- fÅr die Ausgabe von Meldungen -------*/
#define TO_SCREEN   0x01
#define TO_LOG      0x02
#define TO_ALL      (TO_SCREEN + TO_LOG)

#define NO_RAM          0
#define ILL_OPT         1
#define LOG_OPN_ERR     2
#define HLP_NF          3
#define NO_HF           4
#define HDR_SIZE_ERR    5
#define RD_SENS_TAB     6
#define RD_CAPS_TAB     7
#define RD_SCR_TAB      8
#define RD_SCR_ERR      9
#define RD_STR_TAB      10
#define RD_STR_ERR      11
#define RD_IDX          12
#define RD_IDX_ERR      13
#define SET_ATTR        14
#define SET_LINK        15
#define RECOMP          16
#define RECOMP_ERR      17
#define F_CREAT_ERR     18
#define FINAL           19
#define SCR_CNT         20
#define IDX_WARN        21
#define WR_NAME_TAB     22
#define WR_LINK_TAB     23
#define LINK_HEAD       24
#define LINK_CNT        25
#define ILL_CODE        26
#define ABORT           27
#define GLB_REF         28
#define NAME_TAB_HEAD   29
#define NAME_CNT        30
#define OPTION          31
#define MAKETEXT        32
#define HELP_RC1		33
#define HELP_RC2        34
#define HELP_RC3        35

#define BOLD_ON         "\033E"
#define BOLD_OFF        "\033F"
#define FORM_FEED       "\f"

/*---- Konstanten fÅr die Speicherzuteilung ----*/
#define TXTBUFSIZE      0x8000L
#define MAXCODEDSIZE    0x4000L

/*---- Konstanten fÅr die Dekodierung ----------*/
#define CHAR_DIR   0x0C
#define STR_TABLE  0x0E

/*---------- HC-versionsabhÑngige Konstanten ---*/
#define INDEX_SCR   1   /* 2. Eintrag ScreenTab */
#define HC_VERS "H2.0"  /* HelpCompilerversion  */
#define INDEX_CNT   27  /* EintrÑge im INDEX    */

/*---------- Attribute eines Namens ------------*/
#define SCR_NAME    0             /* ScreenName */
#define CAP_SENS    1 /* Groû/Klein-Unterscheid.*/ 
#define SENSITIVE   2   /* keine Unterscheidung */
#define LINK        3     /* ist ein \link-Name */
#define ATTR_CNT    4   /* Anzahl der Attribute */

/*--------- Typen von Suchworttabellen ---------*/
#define CAP_TABLE   0
#define SENS_TABLE  1

/*---- Header-Struktur einer Helpdatei ---------*/

#define HEADER_SIZE  0x30  /* LÑnge des Headers */

typedef struct {
  long scr_tab_size; /* LÑnge der Screen Tabelle*/
  long str_offset;   /* Stringtabellenanfang   */
  long str_size;              /* LÑnge in Bytes */
  UBYTE char_table[12];   /* hÑufigste Zeichen  */
  long caps_offset;    /* Start capsens-Tabelle */
  long caps_size;             /* LÑnge in Bytes */
  long caps_cnt;           /* Anzahl Suchwîrter */
  long sens_offset;    /* Start sensitive-Tab.  */
  long sens_size;             /* LÑnge in Bytes */
  long sens_cnt;           /* Anzahl Suchwîrter */
} HLPHDR;


/*--------- Beschreibung eines Indexeintrages --*/  
typedef UWORD SUB_IDX_ENTRY;

/*--------- Beschreibung eines Namens ----------*/
typedef struct name_entry {
  UWORD scr_code;       /* Index-Code ScreenTab */
  UBYTE name_attr;      /* Attribut des Namens  */
  char  *name;          /* der Name selbst      */
  UWORD link_index;     /* link-Index ScreenTab */
  struct name_entry *next;        /* Nachfolger */
} NAME_ENTRY;

/*--------- Struktur der Keyword-Tabellen ------*/
typedef struct {
  ULONG pos;  /* Wortanf. bei akt. Position+pos */
  UWORD code;       /* Wort hat diese Codierung */
} SRCHKEY_ENTRY;
 
/*--------------- Ende HELP_RC.H ---------------*/
