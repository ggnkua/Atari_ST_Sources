/*      Lempel - Ziv - Welsch - Komprimierung
 *
 *      Autoren: Gabi Keller und Manuel Chakravarty
 *
 *      System : LaserC von Application Systems Heidelberg
 */ 

        
#include <stdio.h>
#include <osbind.h>

#define CODE_WIDTH      9     /* Zum Anschauen auf 16 setzen */
#define BITS_PER_CHAR   8
#define TRUE            (-1)
#define FALSE           0 
#define NO_PREFIX       ((unsigned) -1) /*  Alle Bits auf 1  */        
#define TABLESIZE       1024
#define HASHSIZE        2509  /*  Sollte prim sein  */
#define HASHSTEP        23    /*  Sollte prim sein  */
#define STRSIZE         80
#define INCREASE_WIDTH  256   /*  Spezialcode um dem Decodierer mitzu-
                               *  teilen, daû ab dem nÑchsten Codewort
                               *  die Bitbreite um eins vergrîûert wird */
#define NEW_TABLE       257   /*  ..., daû er seine Decodierungstabelle
                               *  lîschen soll.                         */
#define FIRST_FREE      258   /*  Erster Code fuer neue EintrÑge        */


typedef int     bool;
typedef char    string[STRSIZE];

/*  Typdefinition der Hash-Tabelle
 */

typedef struct {
  
          bool          used;   /*  Hash-Eintrag belegt?  */
          unsigned      elem;   /*  Index in die Codierungstabelle  */
  
        } hash_elem;

typedef hash_elem       *hash_tab;


/*  Typdefintion der Codierungstabelle
 */

typedef struct  {
 
          /* LÑnge der Zeichenkette, die durch den Index
           * dieses Tabellenelements codiert wird
           */
          int    len;
          string str;
          
        } code_elem;
        
typedef code_elem       *code_tab;


/*  Typedefinition der Decodierungstabelle
 */
       
typedef struct {

          /*  Index des Elements in der Decodierungstabelle, das den
           *  Prefix des durch den Index dieses Tabelleneintrags co-
           *  dierten Wortes enthÑlt.
           */
          unsigned      prefix;
          char          first, last;
          
        } decode_elem;
        
typedef decode_elem     *decode_tab;


                        /*  Codieren  */
                        /*  ========  */

/*  init_code_tab -- Initialisiere die Codierungs- und die Hash-Tabelle.
 */
 
void    init_code_tab (table, hash)

  code_tab    table;
  hash_tab    hash;
  
  {
    unsigned    i;
  
    for (i = 0; i <= 255; i++)
    {
      table[i].len = 1;
      table[i].str[0] = (char) i; 
      table[i].str[1] = '\0';
    }
  
    for (i = 0; i < HASHSIZE; i++) hash[i].used = FALSE;
  }

/*  str_equal -- Ermittelt, ob 'curr_str' gleich der Zeichenkette im
 *               Eintrag 'entry' der Codierungstabelle ist.
 *               Dabei gibt 'str_len' die LÑnge von 'curr_str' an.
 */

bool    str_equal (curr_str, str_len, table, entry)

  string        curr_str;
  int           str_len;
  code_tab      table;
  unsigned      entry;

  {
    int         i;
  
    if (table[entry].len != str_len) return (FALSE);
    else {
    
      i = 0;
      while ((i < str_len) && (table[entry].str[i] == curr_str[i])) i++;
    
      return (i == str_len);
    }
  } 
  
/*  search_code_tab -- Durchsucht die Codierungstabelle unter zur Hilfe
 *                     nahme der Hash-Tabelle nach 'curr_str'.
 *                     Wird die Zeichenkette gefunden, so wird der ihr
 *                     zugehîrige Code aus der Codierungstabelle gelie-
 *                     fert.
 *                     Wird sie nicht gefunden, so wird die Zeichenkette
 *                     in die Hashtabelle eingetragen (eintragen des Indi-
 *                     zies fÅr den nÑchsten freien Eintrag in der Codier-
 *                     ungstabelle 'next_entry').
 *                     Es wird 'success = TRUE' geliefert, falls die Zei-
 *                     chenkette bereits in der Tabelle vorhanden war.
 */
 
search_code_tab (curr_str, str_len, table, hash, success, new_code, next_entry)
                 
  string        curr_str;
  int           str_len;
  code_tab      table;
  hash_tab      hash;
  bool          *success;
  unsigned      *new_code, next_entry;

  {
    unsigned    i;
  
    /*  Hash-Funktion (359 ist eine Primzahl)
     *
     *  Die ersten vier Buchstaben der Zeichenkette als long interpretiert
     *  plus die LÑnge der Zeichenkette mal eine Primzahl und das Ganze
     *  modulo der Hash-Tabellen-Grîûe.
     */
    if (str_len < 4)
    {
      curr_str[str_len] = '\0';
      curr_str[str_len + 1] = '\0';
      curr_str[str_len + 2] = '\0';
    }
    i = (unsigned) ((*((unsigned long *) curr_str)
                     + ((unsigned long) str_len) * 359L
                    ) % ((unsigned long) HASHSIZE));   
  
    *success = FALSE;
    while (hash[i].used && (*success == FALSE)) {
    
      if (str_equal (curr_str, str_len, table, hash[i].elem)) {
      
        *success = TRUE;
        *new_code = hash[i].elem;
        
      } else i = (i + HASHSTEP) % HASHSIZE;     /*  lineare Sondierung  */
    
    }
  
    /*  Falls der gesuchte Eintrag nicht in der Hash-Tabelle vorhanden war,
     *  so fÅge ihn nun neu ein.
     */
    if (! *success)
    {
      hash[i].used = TRUE;
      hash[i].elem = next_entry;
    }
  }

/*  write_code -- Schreibt ein Codewort in den Zielbereich.
 *                Dabei gibt 'bit' das nÑchste zu verwendende Bit im Ziel-
 *                bereich an. 'bit_width' spezifiziert die Bitbreite, in
 *                der das Wort abgelegt werden soll. 'dest' und 'dest_len'
 *                beschreiben den Zielbereich und dessen verbleibende Grîûe.
 */
        
void    write_code (code, bit, bit_width, dest, dest_len, code_len)

  unsigned      code;
  int           *bit, bit_width;
  char          **dest;
  long          *dest_len;
  long          *code_len;

  {
    unsigned long       l;
    
    /*  Der zu speichernde Code wird mit den schon verwendeten Bits des
     *  aktuellen Bytes des Zielbereichs verodert und in 'l' abgelegt.
     */
    l = (unsigned long) code;
    if (*bit != 0) {  
      l <<= *bit;
      if (*dest_len != 0L) l = (l | (unsigned long) **dest);
    }
    *bit += bit_width;
    
    /*  'l' wird Byte fÅr Byte im Zielbereich abgelegt.
     */ 
    while (*bit > 0) {
    
      (*code_len)++;
      if (*dest_len != 0L)
      {
        (*dest_len)--;
        *(*dest)++ = (char) l;
        l >>= BITS_PER_CHAR;
      }
      *bit -= 8;
      
    }
    
    /*  Falls nicht alle Bits des zuletzt abgelegten Bytes verwendet wurden,
     *  so werden die Parameter entsprechend korrigiert.
     */
    if (*bit != 0) {
      if (*dest_len != 0L) 
      {
        (*dest)--;
        (*dest_len)++;
      }
      (*code_len)--;
      *bit += 8;
    }
  }      

/*  encode -- Codiere ein Speicherbereich nach dem LZW-Verfahren. Dabei wird
 *            der Code in einen zweiten Bereich geschrieben (Zielbereich).
 *
 *            'source'     - Startadresse des zu codierenden Speicherbereichs
 *            'source_len' - LÑnge des zu codierenden Speicherbereichs
 *            'dest'       - Startadresse des Zielbereichs
 *            'dest_len'   - LÑnge des Zielbereichs
 *            'code_len'   - Liefert die LÑnge der Codedaten im Zielbereich
 *                           nach Abschluû der Codierung.
 *
 *            Wird als LÑnge oder Startadresse des Zielbereichs '0L' ange-
 *            geben, so wird die Codierung durchgefÅhrt, aber kein Code
 *            erzeugt, sondern lediglich die LÑnge der Codedaten ermittelt.
 */
             
void    encode (source, source_len, dest, dest_len, code_len)

  char          *source;
  long          source_len;
  char          *dest;                 
  long          dest_len, *code_len;
                 
  {
    string      curr_str;       /*  aktuell zu codierende Zeichenkette  */
    int         str_len,        /*  LÑnge von 'curr_str'  */
                bit_width,      /*  aktuelle Bitbreite der Codewîrter  */ 
                bit,            /*  nÑchstes freies Bit in 'dest'  */
                j;
    unsigned    new_code,       /*  Code einer gefundenen Zeichenkette  */
                curr_code,      /*  aktueller Code  */ 
                next_entry,     /*  nÑchster freier Eintrag in 'code_tab'  */
                next_width;     /*  Code bei dem Bitbreite erhîht werden muû  */
    long        i;              /*  es wird das i-te Zeichen verarbeitet  */
    bool        success;        /*  zeigt an ob Zeichenkette gefunden wurde  */
    char        ch;             /*  aktuelles Zeichen  */
    code_tab    table;          /*  Codierungstabelle  */               
    hash_tab    hash;           /*  Hash-Tabelle  */
    
    /*  Anforderung des erforderlichen Speicher fÅr Hash- und Codierungs-
     *  tabelle.
     */
    *code_len = 0L;
    if (source_len == 0L) return;
    table = (code_tab) Malloc ((long) sizeof (code_elem) * TABLESIZE);
    if (table == NULL) return;
    hash = (hash_tab) Malloc ((long) sizeof (hash_elem) * HASHSIZE);
    if (hash == NULL)
    {
      Mfree (table);
      return;
    }
    if (dest == NULL) dest_len = 0L;
                                          
    /* Vorbelegung von Variablen                          
     */                                        
    bit = 0;
    bit_width = CODE_WIDTH;
    next_width = 512;
    next_entry = FIRST_FREE;
    
    /*  Vorbelegung der Codierungstabelle mit den ASCII-
     *  Werten von 0 bis 255 und lôschen der Hashtabelle.
     */             
    init_code_tab (table, hash);
    
    /*  Lesen des ersten zu codierenden Zeichens
     */             
    ch = *source++;
    curr_str[0] = ch;
    str_len = 1;
    curr_code = (unsigned) ch;
    
    for (i = 2L; i <= source_len; i++) {
      
      /*  Hole nÑchstes Zeichen und fÅge es an die aktuelle Zeichenkette an.      
       */
      ch = *source++;
      curr_str[str_len++] = ch;
      
      /*  Suche die neue Zeichenkette in der Codierungstabelle (mit Hashing)                    
       */
      search_code_tab (curr_str, str_len, table, hash,
                       &success, &new_code, next_entry);
      
      /*  Falls die Suche erfolgreich war und die Zeichenkette nicht zu lang
       *  ist, wird der gefundene Code zum aktuellen Code,
       *  sonst schreibe den aktuellen Code und erzeuge einen neuen Code fÅr
       *  die aktuelle Zeichenkette.
       */
      if (success && (str_len != STRSIZE - 1)) curr_code = new_code;
      else {
      
        write_code (curr_code, &bit, bit_width, &dest, &dest_len, code_len);
        if (! success) {
        
          /*  Kopiere die aktuelle Zeichenkette an den nÑchsten
           *  unbesetzten Platz in der Codierungstabelle.         
           */
          table[next_entry].len = str_len;
          for (j = 0; j < str_len; j++) table[next_entry].str[j] = curr_str[j];
          next_entry++;
         
          /*  Falls die Codierungstabelle voll ist, lîsche sie bis auf die
           *  ASCII Zeichen und schreibe einen Spezialcode in die kompri-
           *  mierten Daten, um den Lîschvorgang zu protokollieren.
           */
          if (next_entry == TABLESIZE) {
          
            write_code (NEW_TABLE, &bit, bit_width, &dest, &dest_len, code_len);
            init_code_tab (table, hash);
            bit_width = CODE_WIDTH;
            next_width = 512;
            next_entry = FIRST_FREE;
          
          }
          
        }
        
        /*  Falls der nÑchste freie Code in der Codierungstabelle eine
         *  grîûere als die bisher verwendete Bitbreite erfordert, so
         *  erhîhe die Bitbreite um eins und schreibe einen Spezialcode
 `       *  in die komprimierten Daten um das Verbreitern zu protokollieren.
         */
        if (next_entry == next_width) {
        
            next_width += next_width;
            write_code (INCREASE_WIDTH, &bit, bit_width, &dest, &dest_len,
                       code_len);
            bit_width++;
            
          }
         
          /*  Die aktuelle Zeichenkette wird gelîscht und als neue 
           *  aktuelle Kette wird das zuletzt gelesene Zeichen gesetzt.               
           */
          curr_str[0] = ch;
          str_len = 1;
          curr_code = (unsigned) ch;
        }
       
    }
     
    /*  Letztes Codewort in den Codebereich schreiben.           
     */
    write_code (curr_code, &bit, bit_width, &dest, &dest_len, code_len);
    if (bit != 0) (*code_len)++;
     
    /*  Gib den Speicherplatz fÅr die Codierung- und die Hash-Tabelle
     *  wieder frei.                                      
     */
    Mfree (table);
    Mfree (hash);
   
  }

                        /*  Decodieren  */
                        /*  ==========  */  
  
/*  init_decode_tab -- Initialisiere die Decodierungstabelle
 */

void    init_decode_tab (table)

  decode_tab  table;

  {
    unsigned    i;
  
    for (i = 0; i <= 255; i++)
    {
      table[i].first = (char) i;
      table[i].last  = (char) i;
      table[i].prefix = NO_PREFIX;
    }
  }

/*  read_code -- Lieût das nÑchste Codewort und setzt 'endOfSource', falls
 *               kein Codewort mehr vorhanden ist.
 */
 
void    read_code (bit, bit_width, source, source_len, code, end_of_source)

  int           *bit, bit_width;
  char          **source;
  long          *source_len;
  unsigned      *code;
  bool          *end_of_source;
  
  {
    
    unsigned long       l, lb;
    unsigned            i, shift, mask;
    int                 bits;
    
    /*  Lies Byte fÅr Byte soviele Daten, wie bei der aktuellen Bitbreite
     *  erforderlich.
     */
    bits = *bit + bit_width;
    l = 0L; shift = 0;
    do {
        
      if (*source_len == 0L) {*end_of_source = TRUE; return;}
      else {
    
        lb = (unsigned long) *(*source)++; 
        lb <<= shift;  
        l |= lb;
        shift += BITS_PER_CHAR;
        (*source_len)--;
        bits -= BITS_PER_CHAR;
      
      }    
        
    } while (bits > 0);
    if (bits != 0) {(*source)--; (*source_len)++;}
    
    /*  Lîsche die Bits aus den gelesenen Daten, die ÅberflÅssiger Weise
     *  gelesen wurden, da der Code nicht an einer Bytegrenze began oder
     *  endete.
     */   
    l >>= *bit;  
    *bit = (*bit + bit_width) % BITS_PER_CHAR;
    l &= ~(-1 << bit_width);
    *code = (unsigned) l;
        
  }
  
/*  write_data -- Schreibt das durch 'code' codierte Wort in die dekom-
 *                primierten Daten.
 *                Dazu wird die "Pointer"-Kette (aus Array-Indizies) der
 *                Buchstaben des durch 'code' codierten Wortes zuerst
 *                vom letzten Buchstaben bis zum ersten durchlaufen und
 *                dabei alle "Pointer" umgedreht (d.h. zeigte erst A auf
 *                B, so zeigt nun B auf A), danach werden die Buchstaben
 *                entlang der umgedrehten "Pointer"-Kette vom ersten zum
 *                letzten Buchstaben durchlaufen, wobei alle Buchstaben
 *                ausgegeben und die "Pointer" wieder zurÅckgedreht
 *                werden.
 */
   
void    write_data (code, table, dest, dest_len, data_len)

  unsigned      code;
  decode_tab    table;
  char          **dest;
  long          *dest_len, *data_len;

  {    
    unsigned    last, next, zws;
    bool        back;           /*  'TRUE' ~ Liste wird rÅckwÑrts durchlaufen  */
    
    back = FALSE;
    next = table[code].prefix;
    last = NO_PREFIX;
    while (! back || (next != NO_PREFIX)) {
      
      if (next == NO_PREFIX)    /*  Listenende erreicht => zurÅck laufen  */
      {
        back = TRUE;
        zws = next; next = last; last = zws;
      }
      else                      /*  Ein Schritt laufen und Zeiger umdrehen  */
      {
        table[code].prefix = last;
        last = code;
        code = next;
        next = table[code].prefix;
      }
      
      /*  Falls grade zurÅck gelaufen wird, so gib das letzte Zeichen der
       *  Zeichenkette aus, die von dem aktuellen Eintrag bezeichnet wird.
       */
      if (back) {
      
        if (*dest_len != 0L)
        {
          *(*dest)++ = table[code].last;
          (*dest_len)--;
        }  
        (*data_len)++;
        
      }
     
    }
    table[code].prefix = last;
  }
    
    
/*  decode -- Codiere ein Speicherbereich nach dem LZW-Verfahren. Dabei wird
 *            der Code in einen zweiten Bereich beschrieben (Zielbereich).
 *
 *            'source'     - Startadresse des zu decodierenden Speicherbereichs
 *            'source_len' - LÑnge des zu decodierenden Speicherbereichs
 *            'dest'       - Startadresse des Zielbereichs
 *            'dest_len'   - LÑnge des Zielbereichs
 *            'code_len'   - Liefert die LÑnge der Daten im Zielbereich
 *                           nach Abschluû der Decodierung.
 *
 *            Wird als LÑnge oder Startadresse des Zielbereichs '0L' ange-
 *            geben, so wird die Codierung durchgefÅhrt, aber kein Code
 *            erzeugt, sondern lediglich die LÑnge der Codedaten ermittelt.
 */
 
void    decode (source, source_len, dest, dest_len, data_len)

  char  *source;
  long  source_len;
  char  *dest;
  long  dest_len;
  long  *data_len;
  
  {
  
    decode_tab  table;          /*  Decodierungstabelle  */
    unsigned    last_code,      /*  vorheriges Codewort  */
                code,           /*  aktuelles Codewort  */
                next_entry;     /*  nÑchster freier Platz in 'table'  */
    int         bit,            /*  nÑchstes Bit in 'dest'  */
                bit_width;      /*  aktuelle Bitbreite der Codewîrter  */
    bool        end_of_source;  /*  zeigt Ende der Codedaten an  */
     
    /*  Fordere den Speicherbereich fÅr die Decodierungstabelle an.
     */
    *data_len = 0L;
    if (source_len == 0L) return;
    table = (decode_tab) Malloc ((long) sizeof (decode_elem) * TABLESIZE);
    if (table == NULL) return;
    if (dest == NULL) dest_len = 0L;

    /*  Vorbelegen von Variablen
     */
    bit = 0;
    bit_width = CODE_WIDTH;
    next_entry = FIRST_FREE;
    
    /*  Vorbelegen der Decodierungstabelle mit den ASCII-
     *  Werten von 0 bis 255.
     */
    init_decode_tab (table);
    
    /*  Lesen des ersten zu decodierenden Zeichens und Ausgabe desselben
     */
    end_of_source = FALSE;
    read_code (&bit, bit_width, &source, &source_len, &code, &end_of_source);
    last_code = code;
    write_data (code, table, &dest, &dest_len, data_len);
    
    if (! end_of_source) 
      read_code (&bit, bit_width, &source, &source_len, &code, &end_of_source);
    while (! end_of_source) {
  
      /*  Falls das aktuelle Codewort eine Erweiterung der Bitbreite der
       *  Codewîrter anzeigt, so erweitere die Bitbreite um eins,
       *  falls das aktuelle Codewort das Lîschen der Decodierungstabelle
       *  anzeigt, so wird die Tabelle gelîscht,
       *  sonst wird das Wort, das durch den aktuellen Code codiert wird
       *  in die dekomprimierten Daten geschrieben und die Decodierungs-
       *  tabelle um ein Wort erweitert.
       */
      if (code == INCREASE_WIDTH) bit_width++;
      else if (code == NEW_TABLE) {
      
        /*  Lîsche die Decodierungstabelle und lies das nÑchsten Zeichens
         */
        bit_width = CODE_WIDTH;
        next_entry = FIRST_FREE;
        read_code (&bit, bit_width, &source, &source_len, &code, &end_of_source);
        if (!end_of_source)
        {
          last_code = code;
          write_data (code, table, &dest, &dest_len, data_len);
        }  

      } else  {
      
        /*  Schreibe das zum aktuelle Code gehîrende Wort und erweitere
         *  die Decodierungstabelle um das Wort, das aus dem zum vorher-
         *  gehenden Code gehîrenden Wort plus dem Anfangsbuchstaben
         *  des zum aktuellen Code gehîrenden Wortes besteht.
         *  Achtung: Es kann auch passieren, da0 'code == next_entry' ist.
         */
        table[next_entry].prefix = last_code;
        table[next_entry].first  = table[last_code].first;
        table[next_entry].last   = table[code].first;
        next_entry++;
        last_code = code;
        write_data (code, table, &dest, &dest_len, data_len);
      
      }
      read_code (&bit, bit_width, &source, &source_len, &code, &end_of_source);
      
    }/*while*/
      
    Mfree (table);      
  }


                        /*  Benutzer-Schnittstelle  */
                        /*  ======================  */

/*  get_ch -- Lieût ein Zeichen von standard input.
 */
 
void    get_ch (ch)

  char  *ch;

  {
    printf ("\33e");
    fflush (stdout);
    *ch = (char) Cconin ();
    printf ("\33f");
    fflush (stdout);
  }

/*  get_str -- Lieût eine Zeichenkette ein.
 */
 
void    get_str (str)

  char  *str;
  
  {
    printf ("\33e");
    fflush (stdout);
    scanf ("%s", str);
    printf ("\33f");
    fflush (stdout);
  }  

/*  err_msg -- Gibt beliebige Fehlermeldung aus.
 */
   
void    err_msg (msg)

  char  *msg;
  
  {
    char        ch;
    
    printf ("\n\n\7%s\n\n", msg);
    printf ("Bitte Taste drÅcken...");
    get_ch (&ch);
  }

/*  read_file -- Lieût eine Datei, deren Namen vorher erfragt wird ein.
 *               Den Speicherplatz in den die Datei geladen wird, wird
 *               von dieser Routine selbststÑndig alloziert.
 *               'success' liefert 'TRUE', falls das Laden erfolgreich
 *               war.
 */
     
void    read_file (fname, in, in_len, success)

  char  fname[], **in;
  long  *in_len;
  bool  *success;

  {
    int         f;
    
    *success = TRUE;
    printf ("Quelldateiname: ");
    get_str (fname);
    
    f = Fopen (fname, 0);
    if (f < 0)
    {
      err_msg ("Konnte Datei nicht îffnen!");
      *success = FALSE;
      return;
    }
    *in_len = Fseek (0L, f, 2);
    Fseek (0L, f, 0);
    *in = (char *) Malloc (*in_len);
    if (*in == NULL)   
    {
      err_msg ("Zu wenig Speicherplatz!");
      *success = FALSE;
      return;
    }
    Fread (f, *in_len, *in);
    Fclose (f);
  }

/*  write_file -- Schreibt einen Speicherbereich in eine Datei, deren Namen
 *                vorher erfragt wird. Die öbergabe eines Standardnamens
 *                ist in 'fname' mîglich.
 */
 
void    write_file (fname, out, out_len)

  char  *fname, *out;
  long  out_len;
  
  {
    int         f, err;
    char        fname2[80];
    
    printf ("Zieldateiname (default: alter Name): ");
    get_str (fname2); 
    if (fname2[0] != '\0') strcpy (fname, fname2);
    
    f = Fcreate (fname, 0);
    if (f < 0)
    {
      err_msg ("Konnte Datei nicht erzeugen!");
      return;
    }
    err = Fwrite (f, out_len, out);
    Fclose (f);
    if (err < 0) {Fdelete (fname); err_msg ("Laufwerk ist voll!");} 
  }

main ()

  {
    char        ch, fname[80], *in, *out;
    long        in_len, out_len, data_len;
    bool        *success;
    
    do {
    
      printf ("\33E\n\n\nLZW-(De)Kompressor\n");
      printf ("==================\n\n");
      printf ("  1 ... Kompression einer Datei\n");
      printf ("  2 ... Dekompression einer Datei\n");
      printf ("\n  0 ... Verlassen des Programms\n");
      printf ("\n\n  Wahl (0..2): ");
      get_ch (&ch);
      printf ("\n\n");
    
      if (ch == '1') {          /*  Kompression einer Datei  */
      
        read_file (fname, &in, &in_len, &success);
        if (success)
        {
          out_len = in_len + 12L;
          out = (char *) Malloc (out_len);
          if (out == NULL) 
          {
            err_msg ("Zu wenig Speicherplatz!");
            Mfree (in);
            success = FALSE;
          }
          else
          {
            strcpy (out, "LZWComp");
            *((long *) (out + 8L)) = in_len;
          }  
        }
        if (success) {  
        
          encode (in, in_len, out + 12L, out_len - 12L, &data_len);
          data_len += 12L;
          if (data_len > out_len)
          {
            err_msg ("Komprimierte Datei ist lÑnger als das Orginal!");
          }
          else if (data_len == 12L) err_msg ("Zu wenig Speicherplatz!");
          else
          {
            write_file (fname, out, data_len);
          }
          Mfree (out);
          Mfree (in);  
            
        }
      
      } else if (ch == '2') {   /*  Dekompression einer Datei  */
      
        read_file (fname, &in, &in_len, &success);
        if (success)
        {
          if (strcmp (in, "LZWComp") != 0)
          {
            err_msg ("Datei ist nicht komprimiert!");
            Mfree (in);
            success = FALSE;
          }
        }    
        if (success)
        {
          out_len = *((long *) (in + 8L)); 
          out = (char *) Malloc (out_len);
          if (out == NULL) 
          {
            err_msg ("Zu wenig Speicherplatz!");
            Mfree (in);
            success = FALSE;
          }
        }
        if (success) {  
        
          decode (in + 12L, in_len - 12L, out, out_len, &data_len);
          if (data_len == 0L) err_msg ("Zu wenig Speicherplatz!");
          else if (data_len != out_len)
          {
            err_msg ("Fehler beim Dekomprimieren!");
          }
          else
          {
            write_file (fname, out, data_len);
          } 
          Mfree (out);
          Mfree (in); 
            
        }
        
      }
    
    } while (ch != '0');   
  }
  
