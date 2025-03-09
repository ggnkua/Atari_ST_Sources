/*      Lempel - Ziv - Welsch - Komprimierung
 *
 *      Teil 1 : Komprimierer
 *
 *      Autoren: Gabi Keller und Manuel Chakravarty fÅr die ST-Computer
 *      System : LaserC von Application Systems Heidelberg
 */ 

#include "LZW.H"

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
 
          int    len;   /*  Zeichenkette und ihre LÑnge, die durch den  */
          string str;   /*  Index diese Tabellenelements codiert wird   */
          
        } code_elem;
        
typedef code_elem       *code_tab;

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
 *                     Wird die Zeichenkette gefunden, so wird der zuge-
 *                     hîrige Code aus der Codierungstabelle geliefert.
 *                     Sonst wird die Zeichenkette in die Hashtabelle ein-
 *                     getragen (eintragen des Indizies fÅr den nÑchsten
 *                     freien Eintrag in der Codierungstabelle 'next_entry').
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
  
    /*  War der Eintrag nicht in der Hash-Tabelle vorhanden, so fÅge ihn ein.
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
    
    /*  Alloziere Speicher fÅr Codierungs- und Hash-Tabelle.
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
                                          
    /*  Belege die Variablen vor.                          
     */                                        
    bit = 0;
    bit_width = 9;
    next_width = 512;
    next_entry = FIRST_FREE;
    
    /*  Belege Codierungstabelle mit Werten von 0 bis 255 vor.
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
      
      /*  Falls die Suche erfolgreich ist und die Zeichenkette nicht zu lang
       *  ist, mache den gefundenen Code zum aktuellen Code,
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
         
          /*  Ist die Tabelle voll, so lîsche sie bis auf die ASCII Zeichen
           *  und zeige dies dem EmpfÑnger mit einem Spezialcode an.  
           */
          if (next_entry == TABLESIZE)
          {
            write_code (NEW_TABLE, &bit, bit_width, &dest, &dest_len, code_len);
            init_code_tab (table, hash);
            bit_width = 9;
            next_width = 512;
            next_entry = FIRST_FREE;
          }
        }
        
        /*  Falls der nÑchste freie Code eine grîûere Bitbreite erfordert,
         *  so erhîhe die Bitbreite und schreibe den Spezialcode, der dem
         *  EmpfÑnger eine Erhîhung der Bitbreite anzeigt.
         */
        if (next_entry == next_width)
        {
           next_width += next_width;
           write_code (INCREASE_WIDTH, &bit, bit_width, &dest, &dest_len,
                       code_len);
           bit_width++;
         }
         
         /*  Neue aktuelle Zeichenkette wird das zuletzt gelesene Zeichen.
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
     
    /*  Gib den Speicherplatz der Codierungs- und der Hash-Tabelle frei.
     */
    Mfree (table);
    Mfree (hash);
  }

                        /*  Benutzer-Schnittstelle  */
                        /*  ======================  */

/*  get_ch -- Lieût ein Zeichen von standard input.
 */
 
void    get_ch (ch)

  char  *ch;

  {
    printf ("\33e"); fflush (stdout);
    *ch = (char) Cconin ();
    printf ("\33f"); fflush (stdout);
  }

/*  err_msg -- Schreibt eine Fehlermeldung invertiert nach 'stdout'.
 */

void    err_msg (str)

  char  *str;
  
  {
    printf ("\33p"); fflush (stdout);
    printf ("%s", str);
    printf ("\33q"); fflush (stdout);
  }       

/*  read_file -- Liest die angegebene Datei in einen neu allozierten
 *               Speicherbereich ('in') mit LÑnge 'in_len'.
 *               'success = TRUE', falls das Laden erfolgreich war.
 */
     
void    read_file (fname, in, in_len, success)

  char  fname[], **in;
  long  *in_len;
  bool  *success;

  {
    int         f;
    
    *success = FALSE;
    f = Fopen (fname, 0);
    if (f < 0) {err_msg ("Kann die Eingabedatei nicht îffnen!"); return;}
    *in_len = Fseek (0L, f, 2);
    Fseek (0L, f, 0);
    *in = (char *) Malloc (*in_len);
    if (*in == NULL) {err_msg ("Zu wenig Speicherplatz!"); return;}
    Fread (f, *in_len, *in);
    Fclose (f);
    *success = TRUE;
  }

/*  write_file -- Schreibt den Speicherbereich in die angegebene Datei.
 *                'success = TRUE', falls das Speichern erfolgreich war.
 */
 
void    write_file (fname, out, out_len, success)

  char  *fname, *out;
  long  out_len;
  bool  *success;
  
  {
    int         f, err;
    
    *success = FALSE;
    f = Fcreate (fname, 0);
    if (f < 0) {err_msg ("Konnte Datei nicht erzeugen!"); return;}
    err = Fwrite (f, out_len, out);
    Fclose (f);
    if (err < 0) {Fdelete (fname); err_msg ("Laufwerk ist voll!");}
    *success = TRUE; 
  }

main (argc, argv)

  int   argc;
  char  *argv[];

  {
    char        ch, *in, *out;
    long        in_len, out_len, data_len;
    bool        success;
    int         i;
    
    printf ("Lempel-Ziv-Welsch-Komprimierer\n");
    printf ("von Gabi Keller und Manuel Chakravarty fÅr die ST-Computer\n\n");
    if (argc == 1)
    {
      printf ("Bitte geben Sie in der Argumentzeile die zu\n");
      printf ("komprimierenden Dateien an.\n");
    } 
    else
    {  
      for (i = 1; i < argc; i++) {
        
        printf ("%s: lese..", argv[i]); fflush (stdout);       
        read_file (argv[i], &in, &in_len, &success);
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
        
          printf ("komprimiere.."); fflush (stdout);
          encode (in, in_len, out + 12L, out_len - 12L, &data_len);
          data_len += 12L;
          if (data_len > out_len)
          {
            err_msg ("Komprimierte Datei ist lÑnger als das Original!");
          }
          else if (data_len == 12L) err_msg ("Zu wenig Speicherplatz!");
          else
          {
            printf ("schreibe.."); fflush (stdout);
            write_file (argv[i], out, data_len, &success);
            if (success) printf ("OK!");
          }
          Mfree (out);
          Mfree (in);
          
        }
        printf ("\n");
      }/*for*/
    }
    printf ("\nBitte drÅcken Sie eine Taste...");
    get_ch (&ch);
  }
  
        
