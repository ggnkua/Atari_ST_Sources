/************************************************/
/*                                              */
/*  H E L P F I L E - R E C O M P I L E R  1.0  */
/*                                              */
/*  Autor: Volker Reichel                       */
/*     BÅhlstraûe 8                             */
/*     7507 Pfinztal 2                          */
/*                                              */
/*  Letzte énderung: 31.01.1992                 */
/************************************************/

#include <portab.h>
#include <stdio.h>
#include <tos.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "HELP_RC.H"

/*-------- VARIABLEN: --------------------------*/
/*-------- zur Verwaltung von Namenstabellen ---*/
NAME_ENTRY *namelist = NULL; /* gefundene Namen */
int name_cnt = 0;            /* Anzahl d. Namen */
NAME_ENTRY **name_array;     /* als Tabelle     */
NAME_ENTRY *link_list = NULL;/* gef. Link Namen */
int  link_cnt = 0;           /* Anzahl davon    */

/*--------- zur Verwaltung der Subindexe -------*/
SUB_IDX_ENTRY subidx_scrs[INDEX_CNT]; 

/*--------- die Suchwortworttabellen -----------*/ 
SRCHKEY_ENTRY *key_table = NULL;
SRCHKEY_ENTRY *c_key_table = NULL;

/*-------- die Screen-Tabelle ------------------*/
long *screen_table;  /* Fileoffsets der Screens */
int screen_cnt = 0;  /* Anzahl der Screens      */
UBYTE *screen_worked;/* 'Bearbeitet'-Markierung */

/*-------- die String-Tabelle ------------------*/
UBYTE *string_tab;          /* codierte Strings */

/*--------- Datei-Strîme -----------------------*/
FILE *hlpfile = NULL;     /* Eingabe HelpDatei  */
FILE *txtfile = NULL;     /* Textausgabedatei   */
FILE *scrfile = NULL;     /* Screenausgabedatei */
FILE *logfile = NULL;     /* Logdatei           */

char filename[80];      
char hlpname[80];      /* Name der Helpdatei    */
char txtname[80];      /* Name der Textdatei    */
char scrname[80];      /* Name der Screen-Datei */
char logname[80];      /* Name der Log-Datei    */

char *options;           /* öbergebene Optionen */
HLPHDR hlphdr;          /* Header der HelpDatei */

int glbref_cnt; /* Anz. Referenzen nach drauûen */
int warnings;   /* Anzahl gegebener Warnungen   */
int errors;     /* Anzahl der Fehler            */

/*------------- Einige Flags zur Steuerung -----*/
UBYTE log_flag = FALSE;  
UBYTE txt_flag = FALSE;
UBYTE scr_flag = FALSE;

char msg[512];          /* Puffer fÅr Meldungen */
char bold_on[80];
char bold_off[80];
char form_feed[80];

/*-------------- Einige Meldungen --------------*/
#define no_ram_msg      Msgs[NO_RAM]
#define ill_opt_msg     Msgs[ILL_OPT]
#define log_opn_err     Msgs[LOG_OPN_ERR]
#define hlp_nf_msg      Msgs[HLP_NF]
#define no_hf_msg       Msgs[NO_HF]
#define hdr_err_msg     Msgs[HDR_SIZE_ERR]
#define rd_sens_msg     Msgs[RD_SENS_TAB]
#define rd_caps_msg     Msgs[RD_CAPS_TAB]
#define rd_scr_msg      Msgs[RD_SCR_TAB]
#define rd_scr_err      Msgs[RD_SCR_ERR]
#define rd_str_msg      Msgs[RD_STR_TAB]
#define rd_str_err      Msgs[RD_STR_ERR]
#define rd_idx_msg      Msgs[RD_IDX]
#define rd_idx_err      Msgs[RD_IDX_ERR]
#define set_attr_msg    Msgs[SET_ATTR]
#define link_msg        Msgs[SET_LINK]
#define recomp_msg      Msgs[RECOMP]
#define recomp_err      Msgs[RECOMP_ERR]
#define file_creat_err  Msgs[F_CREAT_ERR]
#define final_msg       Msgs[FINAL]
#define scr_cnt_msg     Msgs[SCR_CNT]
#define idx_warn_msg    Msgs[IDX_WARN]
#define wr_nt_msg       Msgs[WR_NAME_TAB]
#define wr_lk_msg       Msgs[WR_LINK_TAB]
#define lk_head_msg     Msgs[LINK_HEAD]
#define lk_cnt_msg      Msgs[LINK_CNT]
#define ill_code_msg    Msgs[ILL_CODE]
#define abort_msg       Msgs[ABORT]
#define glb_ref_msg     Msgs[GLB_REF]
#define nt_head_msg     Msgs[NAME_TAB_HEAD]
#define name_cnt_msg    Msgs[NAME_CNT]
#define opt_msg         Msgs[OPTION]
#define maketxt_msg     Msgs[MAKETEXT]
#define hlp_rc1			Msgs[HELP_RC1]
#define hlp_rc2         Msgs[HELP_RC2]
#define hlp_rc3         Msgs[HELP_RC3]

char *Msgs[] = {
   "\n*** Nicht genÅgend Speicherplatz",
   "\nIllegales Optionszeichen '%c'!\n",
   "\n\n*** Kann Logdatei %s nicht îffnen! ***\n",
   "\n\n*** Help-Datei %s nicht gefunden! ***\n",
   "\n\n*** Die Datei %s ist keine Help-Datei! ***\n",
   "\n\n*** Grîûe der HLPHDR-Struktur falsch! ***\n",
   "\n\tLese sensitive Suchworttabelle...",
   "\n\tLese capsensitive Suchworttabelle...",
   "\n\tLese Screen-Tabelle...",
   "\n\n*** Kann ScreenTabelle nicht lesen! ***\n",
   "\n\tLese String-Tabelle...",
   "\n\n*** Kann StringTabelle nicht lesen! ***\n",
   "\n\tLese Index-Screen...",
   "\n\nKann Index nicht verarbeiten! ***\n",
   "\n\tSetze Namensattribute...",
   "\n\tBearbeite \\link-Verweise...",
   "\n\tRekompiliere Screens...",
   "\n\nKann Helpdatei nicht recompilieren!\n\n",
   "\n\nKann Datei %s nicht erzeugen!\n\n",
   "\n\n%d Fehler. %d Warnungen. %d Verweise in andere HELP-Dateien.",
   "\t%d Screens gefunden.",
   "\n\n*** Mehr als 27 EintrÑge im Index! ***\n",
   "\n\tSchreibe Namenstabelle...",
   "\n\tSchreibe Link Tabelle...",
   "\n\n%s\n\t\t\tLink Tabelle\n%s\n",
   "\n%d Link-Verweise gefunden.",
   "\n\n*** UnzulÑssiger ScreenCode 0x%X! ***\n",
   "\n******* Programm wird abgebrochen ********",
   "\n\t*** WARNUNG: Globaler Verweis <%s>",
   "\n\n%s\n\t\t\tNamenstabelle\n%s\n",
   "\n%d Namen gefunden.",
   "Optionen (L=Log, S=SCR-Datei,T=TXT-Datei): ",
   "\n\tErzeuge Text-Datei...",
   "\n\t\t\tHELPFILE RECOMPILER  Ver. 1.0\t"__DATE__,
   "\n\t\t\t=============================\n",
   "\n\t\t\t\t(c) Volker Reichel\n\n",
   "VR compiled: "__DATE__" "__TIME__
};


/*----- hieraus holt get_nibble() seine Daten --*/
UBYTE *curr_coded_text;
UBYTE must_read = TRUE;       /* fÅr get_nibble */

/*-----------------------------------------------------------*/
/*-------------- Prototypen ---------------------------------*/
/*-----------------------------------------------------------*/
char *strsave( char *s);
void strfill(char *s, char c, int cnt);
int strint(char *s, char **lp);
int strin(char c, char *m);
void trans_bstr(char *s, UBYTE *bstr);
void read_info(void);
UBYTE get_nibble(void);
UBYTE get_byte(void);
long decode(int index, char *txtbuf);
void wr_header(void);
void wr_keytables(void);
char *get_keyword(SRCHKEY_ENTRY *keytable, int i);
int read_header(void);
int read_screen_table(void);
int read_string_table(void);
int read_Index(void);
int read_Link(void);
int read_key_table(SRCHKEY_ENTRY **ptable, int which);
int is_helpfile(void);
int get_name(char *pos, char *name);
UWORD screen_index(UWORD scr_code);
int is_dir_screen(long offset);
int rd_sidx_names(SUB_IDX_ENTRY subidx_code);
void ins_name(NAME_ENTRY **namelist,int *name_cnt, char *sname, 
              UWORD code, UBYTE attr, UWORD lnk_idx);
int find_name(NAME_ENTRY *namelist, char *sname, NAME_ENTRY **pelem);
void corr_attrs(NAME_ENTRY *namelist);
void setup_namearr(NAME_ENTRY *namelist);
void order_nametable(NAME_ENTRY *namelist);
int write_names(NAME_ENTRY *namelist);
void wr_nametable(void);
void wr_linktable(void);
void transform(char *source,long length,char *d);
int recompile(void);
int make_txtfile(void);
void init_rc(void);
void get_options(void);
void wr_options(void);
void wr_msg(char *s, UBYTE device);
void open_log(void);
int attr_cmp(NAME_ENTRY **elem1,NAME_ENTRY **elem2);

/*--------- Einige allgemeine Routinen ---------*/
char *strsave( char *s)
{
  char *p;
  
  p = calloc(strlen(s)+1,1);
  if (p)
    strcpy(p,s);
  return( p );
}


void strfill(char *s, char c, int cnt)
{
  while (cnt-- > 0) 
    *s++ = c;
  *s = EOS;
}


/*-------------------------------------------------*/
/*  strin:										   */
/*-------------------------------------------------*/
/*  Testet ob das Zeichen c im String m vorkommt.  */
/*-------------------------------------------------*/
int strin(char c, char *m)
{
  while (*m && *m != c)
    m++;
  return( *m && *m == c);
}

/*----------------------------------------------------*/
/*  strint:                                           */
/*----------------------------------------------------*/
/*  Wandelt den ab s beginnenden String in einen      */
/*  Integerwert um.                                   */
/*  Falls das 1. Zeichen von s ein '$' ist, so wird   */
/*  eine Hex-Zahl erwartet. Ansonsten eine Dezimal-   */
/*  zahl.                                             */
/*  Nach dem Aufruf zeigt *lp auf das erste Zeichen,  */
/*  das nicht zur Zahlendarstellung gehîrt.           */
/*----------------------------------------------------*/
int strint(char *s, char **lp)
{
  int wert;
  int basis = 10;
  
  wert = 0;
  if (*s == '$') {
    basis = 16;
    s++;
  }
  while (*s) {
    *lp = s;
    if (isdigit(*s)) {
      wert *= basis;
      wert += *s - '0';
    }
    else
      if (basis == 16 && isxdigit(*s)) {
        wert *= 16;
        wert += *s - 'A' + 10;
      }
      else
        break;
    s++;
  }  
  return( wert );
}


void trans_bstr(char *s, UBYTE *bstr)
{
  static char *ziffern = "0123456789ABCDEF";

  while (*bstr)
    if ((*bstr < 0x20) || (*bstr > 0x7F)) {
      *s++ = '\\';
      *s++ = ziffern[*bstr >> 4];
      *s++ = ziffern[*bstr++ & 0x0F];
    }
    else
      *s++ = (char) *bstr++;
  *s = EOS;
}

 
void init_rc(void)
{
  char *p;
  
  glbref_cnt = 0;
  screen_cnt = 0;
  warnings   = 0;
  errors     = 0;
  p = strchr(filename,'.');
  if (p)
    *p = EOS;             /* Extension lîschen */
  sprintf(hlpname,"%s.HLP",filename);
  sprintf(logname,"%s.LOG",filename);
  sprintf(txtname,"%s.TXT",filename);
  sprintf(scrname,"%s.SCR",filename);
}


void get_options(void)
{    
  char *s;
  
  s = options;
  while (*s)
    switch (*s++) {
      case 'L':
      case 'l': log_flag = TRUE;
            break;
      case 'T':
      case 't': txt_flag = TRUE;
            break;
      case 'S':
      case 's': scr_flag = TRUE;
            break;
      case '-':
      case ' ':
      case '\t':
            break;
      default: 
            sprintf(msg,ill_opt_msg,*(s-1));
            wr_msg(msg,TO_ALL);
    } /* switch */
    log_flag = log_flag || !(txt_flag || scr_flag);
}


/*-------------------------------------------------------*/
/*  read_info:                                           */
/*-------------------------------------------------------*/
/*  Liest aus der Datei HELP_RC.INF die zu verwendenden  */
/*  Steuersequenzen zur Ausgabeanpassung.                */
/*  bold_on, bold_off, form_feed wird von make_txtfile   */
/*  benutzt. 											 */
/*  Dateiformat:										 */
/*    Kommentare werden durch '*' eingeleitet. Sie       */
/*    beginnen in der ersten Spalte und enden am Zeilen- */
/*    ende. Zuerst kommt die Zeichenfolge zum Einschal-  */
/*    ten der Fettschrift danach die zu Ausschalten.     */
/*    Als letztes muû noch die Zeichenfolge beim Screen- */
/*    wechsel angegeben werden.                          */
/*    Die Zeichenfolge ist als 2stellige Hexziffernfolge */
/*    durch Kommata abgetrennt einzugeben. Sie endet am  */
/*    Zeilenende.                                        */
/*-------------------------------------------------------*/
void read_info(void)
{
  FILE *info_file;
  int cnt = 0;
  char *s, *sp, *lp;
  char line[180];
  
  info_file = fopen("HELP_RC.INF","r");
  if (info_file == NULL) {
    strcpy(bold_on,BOLD_ON);
    strcpy(bold_off,BOLD_OFF);
    strcpy(form_feed,FORM_FEED);
    return;
  }
  
  /*------- Datei vorhanden -----------*/
  while (!feof(info_file) && (cnt < 3)) {
    fgets(line,80,info_file);
    if ( *line && !strin(*line,"\n \t*")) {
      switch (cnt) {
        case 0 :
          s = bold_on; break;
        case 1 : 
          s = bold_off; break;
        case 2 :
          s = form_feed; break;
      }
      cnt++;
      lp = sp = line;
      while (*sp && strin(*sp," \t,$")) {
        while (*sp && strin(*sp," \t,"))
          sp++;
        if (*sp) {
          *s++ = strint(sp,&lp);
          sp = lp;
        }
      } /* while */
      *s = '\0';
    } /* if */
  } /* while */
  fclose(info_file);
}



void wr_nametable(void)
{
  char bar[81];
  
  wr_msg(wr_nt_msg,TO_SCREEN);
  strfill(bar,'=',80);
  fprintf(logfile,nt_head_msg,bar,bar);
  write_names(namelist);
  fprintf(logfile,name_cnt_msg,name_cnt);
}
  
 
void wr_linktable(void)
{
  char bar[81];
  
  wr_msg(wr_lk_msg,TO_SCREEN);
  strfill(bar,'=',80);
  fprintf(logfile,lk_head_msg,bar,bar);
  write_names(link_list);
  fprintf(logfile,lk_cnt_msg,link_cnt);
}


void wr_options(void)
{
  sprintf(msg,"Optionen: %s\n\n",options);
  wr_msg(msg,TO_ALL);
}


void wr_msg(char *s, UBYTE device)
{
  if (device & TO_SCREEN) {
    printf("%s",s);
  }
  if (log_flag && (device & TO_LOG))
      fprintf(logfile,"%s",s);
}


void open_log(void)
{
  if (!logfile) {
    logfile = fopen(logname,"w");
    if (!logfile) {
      printf(log_opn_err,logname);
      errors++;
      log_flag = FALSE;
    } /* Logfile lÑût sich nicht erzeugen */
    else {
      setvbuf(logfile,NULL,_IOFBF,32*1024L);
      fprintf(logfile,"%s%s%s",hlp_rc1,
                               hlp_rc2,
                               hlp_rc3);
    }
  } /* Logfile nicht geîffnet */
}


/*----------------------------------------------*/
/*  get_nibble:                                 */
/*----------------------------------------------*/
/*  liest das nÑchste Halbbyte aus der Eingabe. */
/*  curr_coded_text zeigt auf das nÑchste Bytee.*/
/*----------------------------------------------*/
UBYTE get_nibble(void)
{
  static UBYTE byte_read;
  UBYTE nibble;
  
  if (must_read) {
    byte_read = *curr_coded_text++;
    nibble = byte_read >> 4;
    must_read = FALSE;
  }
  else {
    nibble = byte_read & 0x0F;
    must_read = TRUE;
  }
  return( nibble );
}


/*----------------------------------------------*/
/*  get_byte:                                   */
/*----------------------------------------------*/
/*  Liest aus der Eingabe die nÑchsten beiden   */
/*  Nibbles und gibt sie als Byte zurÅck.       */
/*----------------------------------------------*/
UBYTE get_byte(void)
{
  UBYTE byte;
  
  byte = get_nibble();
  byte <<= 4;
  byte += get_nibble();
  return( byte );
}


void wr_header(void)
{
  char char_string[50];
  
  trans_bstr(char_string,
             (UBYTE *) hlphdr.char_table);
  fprintf(logfile,"\nHeader of Helpfile %s\n\n",
                  hlpname);
  fprintf(logfile,"\tScreens\t\t\t\t\t: %4ld\n",
                  hlphdr.scr_tab_size>>2);
  fprintf(logfile,
         "\tStart String Tabelle\t: %ld (0x%p)\n",
         hlphdr.str_offset,hlphdr.str_offset);
  fprintf(logfile,
              "\tLÑnge\t\t\t\t\t: %ld (0x%p)\n",
              hlphdr.str_size,hlphdr.str_size);
  fprintf(logfile,
              "\tdie hÑufigsten Zeichen\t: %s\n",
              char_string);
  fprintf(logfile,
      "\tStart sensitive Tabelle\t: %ld (0x%p)\n",
      hlphdr.sens_offset,hlphdr.sens_offset);
  fprintf(logfile,
               "\tLÑnge\t\t\t\t\t: %ld (0x%p)\n",
               hlphdr.sens_size,hlphdr.sens_size);
  fprintf(logfile,
         "\tAnz. sens. Worte\t: %ld (0x%p)\n",
         hlphdr.sens_cnt,hlphdr.sens_cnt);
  fprintf(logfile,
       "\tStart capsens. Tabelle\t: %ld (0x%p)\n",
       hlphdr.caps_offset,hlphdr.caps_offset);
  fprintf(logfile,
       "\tLÑnge\t\t\t\t\t: %ld (0x%p)\n",
       hlphdr.caps_size,hlphdr.caps_size);
  fprintf(logfile,
       "\tAnz. capsens Worte\t: %ld (0x%p)\n",
       hlphdr.caps_cnt,hlphdr.caps_cnt);
}


int read_key_table(SRCHKEY_ENTRY **ptable,
                  int which)
{
  long offset;
  long size;
  
  *ptable = NULL;
  if (which == SENS_TABLE) {
    offset = hlphdr.sens_offset;
    size   = hlphdr.sens_size;
    wr_msg(rd_sens_msg,TO_SCREEN);
  }
  
  if (which == CAP_TABLE) {
    offset = hlphdr.caps_offset;
    size   = hlphdr.caps_size;
    wr_msg(rd_caps_msg,TO_SCREEN);
  }
  
  if (size != 0) {
    fseek(hlpfile,offset,SEEK_SET);
    *ptable = (SRCHKEY_ENTRY *) malloc(size);
    if (*ptable != NULL)
      fread(*ptable,1,size,hlpfile);
  }
  return( *ptable != NULL );
}


/*---------------------------------------------*/
/*  read_coded:  liest den Screen 'index' ein. */
/*---------------------------------------------*/
int read_coded(int index, UBYTE *coded_text)
{
  long code_length, bytes_read;
  
  code_length = screen_table[index+1] 
                           - screen_table[index];
  fseek(hlpfile,screen_table[index],SEEK_SET);
  bytes_read = 
         fread(coded_text,1,code_length,hlpfile);
  return( bytes_read == code_length );
}

    
void wr_keytable(SRCHKEY_ENTRY *table, int cnt)
{
  int i;
  
  fprintf(logfile,
               "\tPosition   Code  Suchwort\n");
  for(i=0;i<cnt;i++)
    fprintf(logfile,"\t   0x%p   %x  \"%s\"\n",
                    table[i].pos,
                    table[i].code,
                    get_keyword(table, i));
}



void wr_keytables(void)
{
  char bar[81];
  
  if (hlphdr.caps_cnt > 0) {
    strfill(bar,'c',80);
    fprintf(logfile,
         "\n\n%s\n\t\tCapsensitive Tabelle\n%s\n",
         bar,bar);
    wr_keytable(c_key_table,(int)hlphdr.caps_cnt);
  }
  
  if (hlphdr.sens_cnt > 0) {  
    strfill(bar,'s',80);
    fprintf(logfile,
            "\n\n%s\n\t\tSensitive Tabelle\n%s\n",
            bar,bar);
    wr_keytable(key_table,(int) hlphdr.sens_cnt);
  }
}


/*----------------------------------------------*/
/*  get_keyword:                                */
/*----------------------------------------------*/
/*  Beschafft aus der Suchworttabelle das i.te  */
/*  SchlÅsselwort. (i bei 0 beginnend)          */
/*----------------------------------------------*/
char *get_keyword( SRCHKEY_ENTRY *keytable, int i)
{
  return((char *) (&keytable[i])+keytable[i].pos);
}


/*----------------------------------------------*/
/*  corr_attrs:                                 */
/*----------------------------------------------*/
/*  Korrigiert die Annahme, daû alle Namen      */
/*  Screen_Namen wÑren. Dazu wird das Attribut  */
/*  entsprechend seiner Zugehîrigkeit zu den    */
/*  Suchworttabellen gesetzt.                   */
/*----------------------------------------------*/
void corr_attrs(NAME_ENTRY *namelist)
{
  int i;
  char *search_name;
  NAME_ENTRY *elem;
  
  wr_msg(set_attr_msg,TO_SCREEN);
  /*----- Zuerst die sensitive Namen -----*/
  for (i=0; i < hlphdr.sens_cnt; i++) {
    search_name = get_keyword(key_table,i);
    if (find_name(namelist, search_name, &elem))
      elem->name_attr = SENSITIVE;
  }
  
  /*----- Jetzt fÅr die capsensitive Namen */
  for (i=0; i < hlphdr.caps_cnt; i++) {
    search_name = get_keyword(c_key_table,i);
    if (find_name(namelist, search_name, &elem))
      elem->name_attr = CAP_SENS;
  }
}


/*----------------------------------------------*/
/*  decode:                                     */
/*----------------------------------------------*/
/*  Dekodiert den durch ScreenTable[index] ge-  */
/*  ebenen Screen. plain_text muû auf ein genÅ- */
/*  gend groûes Speicherfeld verweisen.         */ 
/*  ZurÅckgegeben wird die LÑnge des dekodier-  */
/*  ten Screens.                                */    
/*----------------------------------------------*/
long decode(int index, char *plain_text)
{
  static UBYTE first_call = TRUE;
  static UBYTE *code_buffer = NULL;
  UBYTE nibble;
  UWORD idx;
  UWORD str_len;
  ULONG offset;
  char *p;
  long size = 0L;
  
  if (first_call) {
    code_buffer = malloc(MAXCODEDSIZE);
    first_call = FALSE;
  }
 
  /*------------- Den Screen lesen ------*/
  if (!read_coded(index,code_buffer))
    return( 0L );
    
  curr_coded_text = code_buffer;
  must_read = TRUE;  /* noch kein Byte gelesen */
  
  /*------------ Nun noch dekodieren ----------*/
  while (TRUE) {
    nibble = get_nibble();
    if (nibble == CHAR_DIR) {
      *plain_text++ = (char) get_byte();
      size++;
    }
    else
    if (nibble < CHAR_DIR) { 
      *plain_text++ = hlphdr.char_table[nibble];
      size++;
    }
    else
    if (nibble == STR_TABLE) {
      *plain_text++ = (char) CR;
      *plain_text++ = (char) LF;
      size += 2;
    }
    else 
    if (nibble < STR_TABLE) {
      idx = get_byte() << 4;
      idx += get_nibble();
      str_len = (UWORD) 
             (((long *) string_tab)[idx+1] - 
              ((long *) string_tab)[idx]);
      offset = ((long *) string_tab)[idx];
      p = (char *) string_tab+offset;
      size += str_len;
      while (str_len-- > 0) {
        *plain_text++ = (char) (*p ^ 0xA3);
        p++;
      }
    }
    else {
      *plain_text = EOS;
      break;
    }
  }
  return(size);
}


/*----------------------------------------------*/
/*  screen_index:                               */
/*----------------------------------------------*/
/*  berechnet aus einem Verweiscode den Index   */
/*  in die ScreenTabelle.                       */ 
/*----------------------------------------------*/
UWORD screen_index(UWORD scr_code)
{
  UWORD index;
  
  if ((scr_code & 0x0004) > 0x0004) {
    sprintf(msg,ill_code_msg,scr_code);
    wr_msg(msg,TO_ALL);
    wr_msg(abort_msg,TO_ALL);
    errors++;
    exit(1);
  }
  index = (((scr_code & 0x7FF8) >> 1) - 4) >> 2;
  return( index );
}


/*----------------------------------------------*/
/*  get_name:                                   */
/*----------------------------------------------*/
/*  liefert in name den ab pos beginnenden und  */
/*  beim nÑchsten ESC_CHR endenden String ab.   */
/*  ZusÑtzlich wird noch die GesamtlÑnge des    */
/*  Strings zurÅckgegeben.                      */
/*----------------------------------------------*/
int get_name(char *pos, char *name)
{
  char *s;
      
  s = name;
  while (*pos != ESC_CHR)
    *s++ = *pos++;
  *s = '\0';
  return( (int) (s - name + 1) );
}


/*----------------------------------------------*/
/*  find_name:                                  */
/*----------------------------------------------*/
/*  Sucht in der Namensliste namelist nach dem  */
/*  Namen sname und liefert bei Erfolg einen    */
/*  Zeiger *pelem auf den gefundenen Eintrag    */
/*  zurÅck.                                     */
/*----------------------------------------------*/
int find_name(NAME_ENTRY *namelist, char *sname,
              NAME_ENTRY **pelem)
{
  UBYTE found = FALSE;
  
  while ((namelist != NULL) && !found) {
    found = strcmp(namelist->name,sname) == 0;
    *pelem = namelist;
    namelist = namelist->next;
  }
  
  return( found );
}


/*----------------------------------------------*/
/*  find_code:                                  */
/*----------------------------------------------*/
/*  sucht in der Namenstabelle nach dem Verweis */
/*  code code.                                  */
/*----------------------------------------------*/
int find_code(UWORD search_code, 
              NAME_ENTRY **pelem)
{
  int i;
  
  for (i=0; i < name_cnt; i++)
    if (name_array[i]->scr_code == search_code) {
      *pelem = name_array[i];
      return( TRUE );
    }
  return( FALSE );
}


int write_names(NAME_ENTRY *namelist)
{
  static char *attr_str[ATTR_CNT] = 
           { "SCREEN_NAME ",
             "CAPSENSITIVE",
             " SENSITIVE  ",
             "   LINK     ",
           };
  int i = 0;
  
  fprintf(logfile,
"Name\t\t\t\tAttribute    Code     ScreenOffset\n");

  while (namelist != NULL) {
    fprintf(logfile,"<%-32.32s> %s 0x%X",
                    namelist->name,
                    attr_str[namelist->name_attr],
                    namelist->scr_code);
    if (namelist->name_attr == LINK)
      fprintf(logfile," von 0x%X",
                      namelist->link_index);
    else
      fprintf(logfile," = 0x%X",
              screen_index(namelist->scr_code));
    fprintf(logfile,"\n");
    namelist = namelist->next;
    i++;
  }
  return( i );
}


/*----------------------------------------------*/
/* ins_name:                                    */
/*----------------------------------------------*/
/*  fÅgt den Namen sname mit seinen Eigenschaf- */
/*  ten code, attr und lnk_idx in die Namens-   */
/*  liste *namelist ein. Dabei wird die Zahl    */
/*  der EinfÅgungen in *name_cnt mitgezÑhlt.    */
/*----------------------------------------------*/
void ins_name(NAME_ENTRY **namelist,int *name_cnt,
              char *sname, UWORD code, UBYTE attr, 
              UWORD lnk_idx)
{
  NAME_ENTRY *new;
  
  new = malloc( sizeof(NAME_ENTRY) );
  if (!new) {
    sprintf(msg,"%s fÅr Namen ***\n",no_ram_msg);
    wr_msg(msg,TO_ALL);
    wr_msg(abort_msg,TO_ALL);
    errors++;
    exit(1);
  }
  /* Am Anfang der Liste einfÅgen */
  new->next = *namelist; 
  new->name_attr = attr;
  new->scr_code = code;
  new->name = strsave(sname);
  if (attr == LINK)
    new->link_index = lnk_idx;
  *namelist = new;
  (*name_cnt)++;
}


/*-----------------------------------------------*/
/*  attr_cmp:                                    */
/*-----------------------------------------------*/
/* Vergleicht zwei Elemente der Namensliste nach */
/* ihrem Attributwert.                           */
/*-----------------------------------------------*/
int attr_cmp(NAME_ENTRY **elem1,NAME_ENTRY **elem2)
{
  ULONG val1, val2;
  UWORD idx1, idx2;
  
  idx1 = screen_index((*elem1)->scr_code);
  idx2 = screen_index((*elem2)->scr_code);
    
  val1 = (idx1 << 4) + (*elem1)->name_attr;
  val2 = (idx2 << 4) + (*elem2)->name_attr;
  
  return((val1<val2) ? -1 : (val1>val2) ? 1 : 0);
}


/*----------------------------------------------*/
/*  setup_namearr:                              */
/*----------------------------------------------*/
/*  Legt ein dynamisches Array an und speichert */
/*  die Namensliste dort ab.                    */
/*----------------------------------------------*/
void setup_namearr(NAME_ENTRY *namelist)
{
  int  arr_idx;
  
  name_array = 
            malloc(name_cnt*sizeof(NAME_ENTRY *));
  if (!name_array) {
    sprintf(msg,"\n%s fÅr name_array!\n",
            no_ram_msg);
    wr_msg(msg,TO_ALL);
    errors++;
    exit(1);
  }
  
  arr_idx = 0;
  while ((arr_idx < name_cnt) 
          && (namelist != NULL)) {
    name_array[arr_idx++] = namelist;
    namelist = namelist->next;
  }
}


/*----------------------------------------------*/
/*  transform:                                  */
/*----------------------------------------------*/
/*  bereitet die source so auf, daû ausgegeben  */
/*  werden kann.                                */
/*----------------------------------------------*/
void transform(char *source, long length, char *d)
{
  char *s, *limit;
  NAME_ENTRY *elem;
  char name[80];
  UWORD code;
  UBYTE global = FALSE;    /* globale Referenz */

  s = source; limit = source + length;
  while (s < limit)
    switch (*s) {
      case ESC_CHR :
        code = (* (UBYTE *)(s+1)) << 8;
        code += *(UBYTE *)(s+2);
        s += 3;         /* Auf Namen zeigen */
        s += get_name(s,name);
        if (code == 0xFFFF) {
          sprintf(msg,glb_ref_msg,name);
          wr_msg(msg,TO_ALL);
          warnings++;
          glbref_cnt++;
          global = TRUE;
        }
        if (find_name(link_list,name,&elem) 
            || global)
        {
          if (!global) 
            find_code(elem->scr_code,&elem);
          strcpy(d,"\\link(\""); d += 7;
          if (global) {
            strcpy(d,"%%GLOBAL%%"); d += 10; 
            global = FALSE;
          } 
          else {
            strcpy(d,elem->name); 
            d += strlen(elem->name);
          }
          strcpy(d,"\")"); d += 2;
          strcpy(d,name);  d += strlen(name);
          strcpy(d,"\\#"); d += 2;
        } 
        else {
          strcpy(d,"\\#"); d += 2;
          strcpy(d,name);  d += strlen(name);
          strcpy(d,"\\#"); d += 2;
        }
        break;

      case CR :
        *d++ = '\n';
        s += 2;          /* LF Åberspringen */
        break;

      case BACKSLASH:    /* muû verdoppelt werden */
        *d++ = *s++;
        *d++ = '\\';
        break;
      default :
        *d++ = *s++;
    } /* switch */
    
  *d = '\0';
}


/*----------------------------------------------*/
/*  recompile:                                  */
/*----------------------------------------------*/
/*  Erzeugt aus einer HLP-Datei wieder lesbaren */
/*  Text.                                       */
/*----------------------------------------------*/
int recompile(void)
{
  int i=0;
  UWORD last_code;
  UBYTE new_screen = TRUE;
  char *result;
  char *textbuffer;
  long textlength;

  wr_msg(recomp_msg,TO_SCREEN);
  result = malloc(TXTBUFSIZE);
  if (!result) {
    sprintf(msg,"%s fÅr result!",no_ram_msg);
    wr_msg(msg,TO_ALL);
    errors++;
    return( FALSE );
  }
      
  textbuffer = malloc(MAXCODEDSIZE);
  if (!textbuffer) {
    sprintf(msg,"%s fÅr textbuffer!",no_ram_msg);
    wr_msg(msg,TO_ALL);
    errors++;
    return( FALSE);
  }
  
  /*----- nach Attribut sortieren ----*/
  setup_namearr(namelist);
  qsort(name_array,name_cnt,sizeof(NAME_ENTRY *),
        attr_cmp);

  scrfile = fopen(scrname,"w");
  if (!scrfile) {
    sprintf(msg,file_creat_err,scrname);
    wr_msg(msg,TO_ALL);
    errors++;
    return(FALSE);
  }
  
  setvbuf(scrfile,NULL,_IOFBF,32*1024L);
  
  last_code = name_array[0]->scr_code;
  while (i < name_cnt) {
    while ((i < name_cnt) && 
          (name_array[i]->scr_code == last_code)) 
    {
      if (new_screen) {
        fprintf(scrfile,"\n\nscreen( ");
        new_screen = FALSE;
      }
      else
        fprintf(scrfile,",\n\t\t");

      switch (name_array[i]->name_attr) {
        case SCR_NAME :
          fprintf(scrfile,"\"%s\"",
                        name_array[i]->name);
          break;
        case SENSITIVE :
          fprintf(scrfile,"sensitive(\"%s\")",
                          name_array[i]->name);
          break;
        case CAP_SENS :
          fprintf(scrfile,"capsensitive(\"%s\")",
                          name_array[i]->name);
          break;
      } /* switch */
      i++;             /* nÑchsten Eintrag */
    } /* while */
    fprintf(scrfile," )\n");
    textlength = decode(screen_index(last_code),
                        textbuffer);
    transform(textbuffer,textlength,result);
    fputs(result,scrfile);
    fputs("\n\\end",scrfile); 
    /*fprintf(scrfile,"%s\n\\end",result);*/

    if (i < name_cnt) 
      last_code = name_array[i]->scr_code;
    new_screen = TRUE;
  } /* while */
  fprintf(scrfile,"\n");
  fclose(scrfile);
  return( TRUE );
}


/*----------------------------------------------*/
/*  make_txtfile:                               */
/*----------------------------------------------*/
/*  Listet alle Screens der Reihe auf.          */
/*  bold_on bzw. bold_off bestimmen wie Verwei- */
/*  se hervorgehoben werden. form_feed bestimmt */
/*  wie Screens getrennt werden sollen.         */
/*----------------------------------------------*/
int make_txtfile(void)
{
  int index;
  char *textbuffer, *tp, *limit;
  long size;
  
  wr_msg(maketxt_msg,TO_SCREEN);
  txtfile = fopen(txtname,"w");
  if (!txtfile) {
    sprintf(msg,file_creat_err,txtname);
    wr_msg(msg,TO_ALL);
    errors++;
    return( FALSE );
  }
  
  setvbuf(txtfile,NULL,_IOFBF,32*1024L);
  
  textbuffer = malloc(TXTBUFSIZE);
  if (!textbuffer) {
    wr_msg(no_ram_msg,TO_ALL);
    errors++;
    return( FALSE );
  }
  
  for (index = 0; index < screen_cnt; index++) {
    if (!is_dir_screen(screen_table[index])) {
      size = decode(index,textbuffer);
      tp = textbuffer;
      limit = textbuffer + size;
      while (tp < limit) {
        switch (*tp) {
          case ESC_CHR:
            fputs(bold_on,txtfile);
            tp += 3;     /* Verweis Åberspringen */
            while (*tp != ESC_CHR)
              fputc(*tp++,txtfile);
            fputs(bold_off,txtfile);
            tp++;  
            break;
          case CR:
            tp += 2;      /* LF Åberspringen */
            fputc('\n',txtfile);
            break;
          default:
            fputc(*tp++,txtfile);
        } /* switch */
      } /* while */
      fputs(form_feed,txtfile);
    } /* if */
  } /* for */
  
  free(textbuffer);
  fclose(txtfile);

  return( TRUE );
}


/*----------------------------------------------*/
/*  rd_sidx_names:                              */
/*----------------------------------------------*/
/* Alle sich auf diesem Subindex-Screen befind- */
/* lichen Namen in die Namenstabelle eintragen. */
/* Die Annahme, daû alle Screen-Namen sind wird */
/* spÑter korrigiert.                           */
/*----------------------------------------------*/
int rd_sidx_names(SUB_IDX_ENTRY subidx_code)
{
  static char *plain_text = NULL;
  long size;
  char *pos;           
  UWORD scr_index;    /* Index in ScreenTabelle */
  UWORD screen_code;    /* der zum Namen gehîrt */
  char screen_name[80];    
  static UBYTE first_call = TRUE;
  
  if (first_call) {
    plain_text = malloc(MAXCODEDSIZE);
    first_call = FALSE;
  }
  if (!plain_text) 
    return( FALSE );
    
  scr_index = screen_index(subidx_code);
  if (!screen_worked[scr_index]) {
    size = decode(scr_index,plain_text);

    /* Jeden Eintrag des IV abarbeiten */
    pos = plain_text;
    while (pos < plain_text + size) {
      if (*pos == ESC_CHR) {
        pos++;
        screen_code = * (UBYTE *) pos++ << 8;
        screen_code += * (UBYTE *) pos++;
        pos += get_name(pos,screen_name);
        ins_name(&namelist,&name_cnt,screen_name,
                 screen_code,SCR_NAME,0);
      }
      else
        pos++;
    } /* while */
    screen_worked[scr_index] = TRUE;
  } /* if */
  return( TRUE );
}


/*----------------------------------------------*/
/*  is_dir_screen:                              */
/*----------------------------------------------*/
/* Stellt fest ob der offset zu einen Subindex- */
/* Screen gehîrt.                               */
/*----------------------------------------------*/
int is_dir_screen( long offset )
{
  int i;
  
  for (i=0; i < INDEX_CNT; i++)
    if (screen_table[screen_index(subidx_scrs[i])]
        == offset)
      return( TRUE );
  return( FALSE );
}


/*----------------------------------------------*/
/*  read_Link:                                  */
/*----------------------------------------------*/
/* Durchsucht alle Screens auûer dem Copyright-,*/
/* Index- und allen Subindex-Screens auf darin  */
/* enthaltene Verweise ab. Wird dabei ein Ver-  */
/* weis gefunden, der nicht in Namenstabelle    */
/* enthalten ist, so steht fest, daû dieser Ver-*/
/* weis Åber die \link-Anweisung erzeugt wurde. */
/* Denn \link-Anweisungen erzeugen keine Ein-   */
/* trÑge in den Suchworttabellen. Der Verweis   */
/* wird in die link_list Åbernommen.            */
/*----------------------------------------------*/
int read_Link(void)
{
  int i;
  long size;
  char *pos;
  char name[80];
  UWORD to_code;    
  NAME_ENTRY *elem; 
  static char *plain_text = NULL;
  static UBYTE first_call = TRUE;
  char *limit;
  
  wr_msg(link_msg,TO_SCREEN);
  if (first_call) {
    plain_text = malloc(TXTBUFSIZE);
    first_call = FALSE;
  }
  
  if (!plain_text)
    return( FALSE );

  /*--- Screen 0 Copyright Screen 1 Index -----*/
  for(i=2;i<(hlphdr.scr_tab_size >> 2)-1;i++) {
    /*------ Ist es ein Directory Screen?---*/
    if (!is_dir_screen(screen_table[i])) { 
      /*------ Seite holen und dekodieren */
      size = decode(i,plain_text);
      /*----- Jeden Namenseintrag eines -----*/
      /*----- Screens abarbeiten ------------*/
      pos = plain_text; 
      limit = plain_text + size;
      while (pos < limit) {
        if (*pos == ESC_CHR) {
          pos++;
          to_code = * (UBYTE *) pos++ << 8;
          to_code += * (UBYTE *) pos++;
          pos += get_name(pos,name);
          if (!find_name(namelist,name,&elem) &&
              !find_name(link_list,name,&elem)) {
            ins_name(&link_list,&link_cnt,name,
                     to_code,LINK,i);
          }
        } /* if ESC_CHR */
        else
          pos++;
      } /* while */
    } /* if */
  } /* for */
  return( TRUE );
}


/*----------------------------------------------*/
/*  read_Index:                                 */
/*----------------------------------------------*/
/* Es wird der Index-Screen gelesen und die zu  */
/* den Buchstaben A bis Z und dem Eintrag Sons- */
/* tiges gehîrenden Screens festgestellt.       */
/* Anschlieûend werden alle sich auf den Sub-   */
/* index Screens befindlichen Namen eingelesen. */
/*----------------------------------------------*/
int read_Index(void)
{
  
  char *plain_idx_text;    /* dekodierter Index */ 
  long size;                     /* seine LÑnge */
  char *limit;
  int  sub_idx = 0;     /* bearbeiteter Eintrag */
  int  i;
  char *pos;
  char dummy[80];        
  UWORD screen_code;

  wr_msg(rd_idx_msg,TO_SCREEN);
  plain_idx_text = malloc(0x1000L);
  if (!plain_idx_text)
    return( FALSE );
    
  screen_worked[INDEX_SCR] = TRUE;
  size = decode(INDEX_SCR,plain_idx_text);
  
  /* Jeden Eintrag des Index abarbeiten */
  pos = plain_idx_text;
  limit = plain_idx_text + size;
  while (pos < limit) {
    if (*pos == ESC_CHR) {
      pos++;
      screen_code = * (UBYTE *) pos++ << 8;
      screen_code += * (UBYTE *) pos++;
      if (sub_idx >= INDEX_CNT) {
        wr_msg(idx_warn_msg,TO_ALL);
        warnings++;
      }
      else 
        subidx_scrs[sub_idx] = screen_code;
      sub_idx++;
      pos += get_name(pos,dummy);
    }
    else
      pos++;
  }
  
  /* Jetzt jeden SubIndex abarbeiten */
  for (i=0;i<INDEX_CNT;i++)
    if (!rd_sidx_names(subidx_scrs[i]))
      return( FALSE );
    
  free( plain_idx_text );
  return( TRUE );
}


/*----------------------------------------------*/
/*  is_helpfile:                                */
/*----------------------------------------------*/
/* Handelt es sich um ein HC2.0 File?           */
/*----------------------------------------------*/
int is_helpfile(void)
{
  char buffer[4];
  
  fseek(hlpfile,0x54L,SEEK_SET);
  fread(buffer,1,4L,hlpfile);
  return(
    !strncmp(buffer,HC_VERS,strlen(HC_VERS)));
}


/*----------------------------------------------*/
/*  read_header:                             */
/*----------------------------------------------*/
/*  Liest aus dem Helpfile den Beschreibungs-   */
/*  block.                                      */ 
/*----------------------------------------------*/
int read_header(void)
{
  fseek(hlpfile,0x58L,SEEK_SET);
  return( 
      fread(&hlphdr,1,sizeof(HLPHDR),hlpfile)
      == HEADER_SIZE );
}
  

/*----------------------------------------------*/
/*  read_screen_table:                          */
/*----------------------------------------------*/
/* Liest aus dem Helpfile die Tabelle mit den   */
/* Screenoffsets.                               */
/*----------------------------------------------*/  
int read_screen_table(void)
{
  long bytes_read;
  int  i;
  
  wr_msg(rd_scr_msg,TO_SCREEN);
  fseek(hlpfile,0x88L,SEEK_SET);
  screen_table = 
            (long *) malloc(hlphdr.scr_tab_size);
  if (!screen_table) {
    sprintf(msg,"%s fÅr screen_table",no_ram_msg);
    wr_msg(msg,TO_ALL);
  }
  screen_cnt = (int) hlphdr.scr_tab_size >> 2;
  screen_worked = (UBYTE *) malloc(screen_cnt);
  if (!screen_worked) {
    sprintf(msg,"\n%s fÅr ScreenWorked!\n",
            no_ram_msg);
    wr_msg(msg,TO_ALL);
  }
  
  
  for(i=0;i < screen_cnt; i++) {
    screen_worked[i] = FALSE;
  }
    
  bytes_read = 
    fread(screen_table,1,hlphdr.scr_tab_size,
          hlpfile);
  return( (bytes_read == hlphdr.scr_tab_size) 
          && screen_table && screen_worked);
}
  
  
/*----------------------------------------------*/
/*  read_string_table:                          */
/*----------------------------------------------*/
/* Liest die Tabelle mit Code-Strings ein.      */
/*----------------------------------------------*/  
int read_string_table(void)
{
  long bytes_read;
  
  wr_msg(rd_str_msg,TO_SCREEN);
  string_tab = (UBYTE *) malloc(hlphdr.str_size);
  if (!string_tab) {
    sprintf(msg,"%s fÅr string_table",no_ram_msg);
    wr_msg(msg,TO_ALL);
  }
  fseek(hlpfile,hlphdr.str_offset,SEEK_SET);
  bytes_read = 
      fread(string_tab,1,hlphdr.str_size,hlpfile);
  return( (bytes_read == hlphdr.str_size) 
          && string_tab);
}


int main(int argc, char *argv[])
{
  char buf[40];
  
  printf("%s%s%s",hlp_rc1,hlp_rc2,hlp_rc3);
  
  read_info();
  if (argc > 2) {
    options = argv[1];
    strcpy(filename,argv[2]);
  }
  else {
    printf("Name der HELP-Datei: ");
    gets(filename);
    printf(opt_msg);
    gets(buf);
    options = buf;
  }
  init_rc();
  get_options();
  if (log_flag) open_log();
  wr_options();
 
  hlpfile = fopen(hlpname,"rb");
  if (!hlpfile) {
    printf(hlp_nf_msg,hlpname);
    errors++;
    goto ende;
  }
  setvbuf(hlpfile,NULL,_IOFBF,4*1024L);

  if (!is_helpfile()) {
    printf(no_hf_msg,hlpname);
    errors++;
    goto ende;
  }
  
  if (!read_header()) {
    printf(hdr_err_msg);
    errors++;
    goto ende;
  }
  if (log_flag) wr_header();
  
  read_key_table(&key_table,SENS_TABLE);
  read_key_table(&c_key_table,CAP_TABLE);
  if (log_flag) wr_keytables();
  
  if (!read_screen_table()) {
    wr_msg(rd_scr_err,TO_ALL);
    errors++;
    goto ende;
  }
  sprintf(msg,scr_cnt_msg,screen_cnt);
  wr_msg(msg,TO_SCREEN);
  
  if (!read_string_table()) {
    wr_msg(rd_str_err,TO_ALL);
    errors++;
    goto ende;
  }
 
  if (!read_Index()) {
    wr_msg(rd_idx_err,TO_ALL);
    errors++;
    goto ende;
  }
  
  corr_attrs(namelist);
  if (log_flag) wr_nametable();

  read_Link();
  if (log_flag) wr_linktable();

  if (scr_flag) {  
    if (!recompile()) {
      wr_msg(recomp_err,TO_ALL);
      errors++;
      goto ende;
    } /* if */
  } /* if */

  if (txt_flag) {
    if (!make_txtfile()) {
      sprintf(msg,file_creat_err,txtname);
      wr_msg(msg,TO_ALL);
      errors++;
      goto ende;
    }
  }

ende:  

  sprintf(msg,final_msg,errors,warnings,
                        glbref_cnt);
  wr_msg(msg,TO_ALL);
  fclose(hlpfile);
  if (log_flag) fclose(logfile);
  puts("\nFertig.");
  Cnecin();
  return( errors );
}
