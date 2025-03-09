/*	Lempel - Ziv - Welsch - Komprimierung
 *
 *	Teil 2 : Dekomprimierer
 *
 *	Autoren: Gabi Keller und Manuel Chakravarty fÅr die ST-Computer
 *	System : LaserC von Application Systems Heidelberg
 */ 

#include "LZW.H"


/*  Typedefinition der Decodierungstabelle
 */
       
typedef struct {

	  /*  Indiziert den Prefix, des durch diesen Eintrag codierten Wortes
           */
          unsigned	prefix;
          char		first, 	/*  Erstes und letztes Zeichen des durch  */ 
                        last; 	/*  diesen Eintrag codierten Wortes       */
          
        } decode_elem;
        
typedef decode_elem	*decode_tab;


			/*  Decodieren  */
			/*  ==========  */  
  
/*  init_decode_tab -- Initialisiere die Decodierungstabelle
 */

void	init_decode_tab (table)

  decode_tab  table;

  {
    unsigned	i;
  
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
 
void	read_code (bit, bit_width, source, source_len, code, end_of_source)

  int		*bit, bit_width;
  char		**source;
  long		*source_len;
  unsigned	*code;
  bool		*end_of_source;
  
  {
    
    unsigned long	l, lb;
    unsigned		i, shift, mask;
    int			bits;
    
    /*  Lies soviele Bytes, wie es fÅr die aktuelle Bitbreite erforderlich ist.
     */
    bits = *bit + bit_width;
    l = 0L; shift = 0;
    do
    {
      if (*source_len == 0L) {*end_of_source = TRUE; return;}
      else
      {
        lb = (unsigned long) *(*source)++; 
        lb <<= shift;  
        l |= lb;
        shift += BITS_PER_CHAR;
        (*source_len)--;
        bits -= BITS_PER_CHAR;
      }    
    } while (bits > 0);
    if (bits != 0) {(*source)--; (*source_len)++;}
    
    /*  Maskiere die durch BeschrÑnkung auf Bytegrenzen ÅberflÅssiger Weise
     *  gelesenen Bits aus.
     */   
    l >>= *bit;  
    *bit = (*bit + bit_width) % BITS_PER_CHAR;
    l &= ~(-1 << bit_width);
    *code = (unsigned) l;
  }
  
/*  write_data -- Schreibt das durch 'code' codierte Wort in den Zielbereich.
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
   
void	write_data (code, table, dest, dest_len, data_len)

  unsigned	code;
  decode_tab	table;
  char		**dest;
  long		*dest_len, *data_len;

  {    
    unsigned	last, next, zws;
    bool	back;		/*  'TRUE' ~ RÅckwÑrtslauf aktiv */
    
    back = FALSE;
    next = table[code].prefix;
    last = NO_PREFIX;
    while (! back || (next != NO_PREFIX)) {
      
      if (next == NO_PREFIX)	/*  Listenende erreicht => zurÅck laufen  */
      {
        back = TRUE;
        zws = next; next = last; last = zws;
      }
      else			/*  Ein Schritt laufen und Zeiger umdrehen  */
      {
        table[code].prefix = last;
        last = code;
        code = next;
        next = table[code].prefix;
      }
      
      /*  Falls grade zurÅck gelaufen wird, so gib das letzte Zeichen der
       *  Zeichenkette aus, die von 'code' codiert wird.
       */
      if (back)
      {
        if (*dest_len != 0L)
        {
          *(*dest)++ = table[code].last;
          (*dest_len)--;
        }  
        (*data_len)++;
      }
     
    }/*while*/
    table[code].prefix = last;
  }
    
    
/*  decode -- Codiere ein Speicherbereich nach dem LZW-Verfahren. Dabei wird
 *	      der Code in einen zweiten Bereich beschrieben (Zielbereich).
 *
 *	      'source'     - Startadresse des zu decodierenden Speicherbereichs
 *	      'source_len' - LÑnge des zu decodierenden Speicherbereichs
 *	      'dest'       - Startadresse des Zielbereichs
 *	      'dest_len'   - LÑnge des Zielbereichs
 *	      'code_len'   - Liefert die LÑnge der Daten im Zielbereich
 *			     nach Abschluû der Decodierung.
 *
 *	      Wird als LÑnge oder Startadresse des Zielbereichs '0L' ange-
 *	      geben, so wird die Codierung durchgefÅhrt, aber kein Code
 *	      erzeugt, sondern lediglich die LÑnge der Codedaten ermittelt.
 */
 
void	decode (source, source_len, dest, dest_len, data_len)

  char	*source;
  long	source_len;
  char	*dest;
  long	dest_len;
  long	*data_len;
  
  {
  
    decode_tab	table; 		/*  Decodierungstabelle  */
    unsigned	last_code,      /*  vorheriges Codewort  */
      		code,           /*  aktuelles Codewort  */
      		next_entry;     /*  nÑchster freier Platz in 'table'  */
    int		bit,            /*  nÑchstes Bit in 'dest'  */
      		bit_width;     	/*  aktuelle Bitbreite der Codewîrter  */
    bool	end_of_source;  /*  zeigt Ende der Codedaten an  */
     
    /*  Alloziere den Speicherbereich fÅr die Decodierungstabelle.
     */
    *data_len = 0L;
    if (source_len == 0L) return;
    table = (decode_tab) Malloc ((long) sizeof (decode_elem) * TABLESIZE);
    if (table == NULL) return;
    if (dest == NULL) dest_len = 0L;

    /*  Belege die Variablen vor
     */
    bit = 0;
    bit_width = 9;
    next_entry = FIRST_FREE;
    
    /*  Belege die Decodierungstabelle mit den Werten von 0 bis 255 vor.
     */
    init_decode_tab (table);
    
    /*  Lies das erste zu decodierende Zeichen und gib es aus
     */
    end_of_source = FALSE;
    read_code (&bit, bit_width, &source, &source_len, &code, &end_of_source);
    last_code = code;
    write_data (code, table, &dest, &dest_len, data_len);
    
    if (! end_of_source) 
      read_code (&bit, bit_width, &source, &source_len, &code, &end_of_source);
    while (! end_of_source) {
  
      /*  Spezialcode fÅr Erweiterung der Bitbreite => Bitbreitenerweiterung
       *  Spezialcode fÅr Lîschen der Tabelle => Lîschen der Decodierungstab.
       *  Sonst wird das Wort, das durch den aktuellen Code codiert wird
       *  in die dekomprimierten Daten geschrieben und die Decodierungs-
       *  tabelle um ein Wort erweitert.
       */
      if (code == INCREASE_WIDTH) bit_width++;
      else if (code == NEW_TABLE) {
      
        /*  Lîsche die Decodierungstabelle und lies das nÑchsten Zeichens
         */
        bit_width = 9;
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
      
    Mfree (table); /*  Gib den Speicherplatz der Decodierungstabelle frei  */      
  }

			/*  Benutzer-Schnittstelle  */
			/*  ======================  */

/*  get_ch -- Lieût ein Zeichen von standard input.
 */
 
void	get_ch (ch)

  char	*ch;

  {
    printf ("\33e"); fflush (stdout);
    *ch = (char) Cconin ();
    printf ("\33f"); fflush (stdout);
  }

/*  err_msg -- Schreibt eine Fehlermeldung invertiert in stdout.
 */

void	err_msg (str)

  char	*str;
  
  {
    printf ("\33p"); fflush (stdout);
    printf ("%s", str);
    printf ("\33q"); fflush (stdout);
  }       

/*  read_file -- Lies angegebene Datei in neu allozierten Speicherbreich. 
 *		 'success = TRUE', falls das Laden erfolgreich war.
 */
     
void	read_file (fname, in, in_len, success)

  char	fname[], **in;
  long	*in_len;
  bool	*success;

  {
    int		f;
    
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

/*  write_file -- Schreibt angegebenen Speicherbereich in eine Datei.
 *		  'success = TRUE', falls das Speichern erfolgreich war.
 */
 
void	write_file (fname, out, out_len, success)

  char	*fname, *out;
  long	out_len;
  bool  *success;
  
  {
    int		f, err;
    
    *success = FALSE;
    f = Fcreate (fname, 0);
    if (f < 0) {err_msg ("Konnte Datei nicht erzeugen!"); return;}
    err = Fwrite (f, out_len, out);
    Fclose (f);
    if (err < 0) {Fdelete (fname); err_msg ("Laufwerk ist voll!");}
    *success = TRUE; 
  }

main (argc, argv)

  int	argc;
  char	*argv[];

  {
    char	ch, *in, *out;
    long	in_len, out_len, data_len;
    bool	success;
    int 	i;
    
    printf ("Lempel-Ziv-Welsch-Dekomprimierer\n");
    printf ("von Gabi Keller und Manuel Chakravarty fÅr die ST-Computer\n\n");
    if (argc == 1)
    {
      printf ("Bitte geben Sie in der Argumentzeile die zu\n");
      printf ("dekomprimierenden Dateien an.\n");
    } 
    else
    {  
      for (i = 1; i < argc; i++) {
        
        printf ("%s: lese..", argv[i]); fflush (stdout);       
        read_file (argv[i], &in, &in_len, &success);
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
        
          printf ("dekomprimiere.."); fflush (stdout);
          decode (in + 12L, in_len - 12L, out, out_len, &data_len);
          if (data_len == 0L) err_msg ("Zu wenig Speicherplatz!");
          else if (data_len != out_len)
          {
            err_msg ("Fehler beim Dekomprimieren!");
          }
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
  
	
