/****************************************************************************

 Konverter von Adressen des Programmes ADR_2_1.PRG zu 'Adresse'.
 
 Dieses Programm ist fix zusammengehackt worden, bitte keine Kritik am Quell-
 text :-)!
 
 Aufruf: con_adr2 <Quelle> <Ziel>
 
 (C)1993 Carsten Setje-Eilers
         Aschauweg 18a
         24119 Kronshagen
         Telefon 0431/544716
         Fax 0431/547212
         
  Dieses Programm gehîrt zu 'Adresse' und darf nicht einzeln weitergegeben
  werden.       

  ( Tabulator: 2 )

 ****************************************************************************/

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <tos.h>

/****************************************************************************

  Adress-Node von 'Adresse'                                                              

 ****************************************************************************/
typedef struct _adrnode
{ 
  char     vorname[33];                             /* Vorname              */
  char     name[33];                                /* Name                 */
  char     name1[33];                               /* z.Hd. o.ae.          */
  char     name2[33];                               /* z.Hd. o.ae.          */
  char     strasse[33];                             /* Strasse              */     
  char     land[7];                                 /* LÑnderkennung        */
  char     plz[13];                                 /* Postleitzahl         */
  char     stadt[33];                               /* Stadt                */
  char     telefon[33];                             /* Telefon              */
  char     telefon1[33];                            /* Telefon              */
  char     fax[33];                                 /* Fax                  */
  char     fax1[33];                                /* Fax                  */
  char     kundennr[15];                            /* Kundennummer         */ 
  char     typ[22];                                 /* Lieferant/Kunde      */
  char     anrede[33];                              /* Anrede (Sehr geehr..)*/
  char     anrede1[33];                             /* Anrede (Sehr geehr..)*/
  char     zahlart[33];                             /* %NULL                */
  char     umsatz[16];                              /* Umsatz mit Kunde     */
  char     rabatt[4];                               /* Kunden-Extra-Rabatt  */
  char     zahlziel[4];                             /* Zahlungsziel in Tage */
  char     bemerkung1[66];                          /* Blah                 */
  char     bemerkung2[66];                          /* Blah                 */
  char     bemerkung3[66];                          /* Blah                 */
  char     geburt[12];                              /* Geburtstag           */
  char     bank[28];                                /* Bankname             */ 
  char     konto[11];                               /* Kontonummer          */
  char     blz[9];                                  /* Bankleitzahl         */
  char     status[22];                              /* Bezahlt/Unbezahlt/.. */
  char     erstellt[12];                            /* Erstellungsdatum     */
  char     geaendert[12];                           /* Letzte énderung      */
  int      selected;                                /* ist selektiert       */
  long     nr;                                      /* Interne Nummer       */ 
  struct   _adrnode *next;
}ADRNODE;

int  write_adr( FILE *stream, ADRNODE *a );
void kill_blanks( char *s, int l );

/****************************************************************************

 Hauptprogramm

 ****************************************************************************/
int main( int argc, char *argv[] )
{
  Cconws("\r\nKonverter ADR_2 -> Adresse\r\n");
  Cconws("\r\nVersion 1.0, (");
  Cconws( __DATE__);
  Cconws(")\r\n");
  Cconws("\r\nDieser Konverter wandelt die Daten von ADR_2_1.PRG in");
  Cconws("\r\ndas Format von Adresse. Es findet keine PrÅfung des");
  Cconws("\r\nFormates statt!");
  Cconws("\r\n");

  Cconws("\r\n(C)1993 Carsten Setje-Eilers");
  Cconws("\r\n        Aschauweg 18a");
  Cconws("\r\n        24119 Kronshagen");

  if( argc < 3 )
  {
    Cconws("\r\n");
    Cconws("\r\nAufruf: CON_ADR2  <quelle> <ziel>");
    Cconws("\r\n");
  }
  else
  {
    int     error = 0;
    long    count = 0;
    FILE    *fh, *dest;
    ADRNODE b, *a = &b;

    Cconws("\r\nôffne Datei:\r\n");
    Cconws( argv[1] );
    fh   = fopen(argv[1], "rb" );
    if( !fh )
      Cconws("\r\nFehler beim ôffnen.");
      
      
    Cconws("\r\nôffne Datei:\r\n");
    Cconws( argv[2] );
    dest = fopen(argv[2], "w" );
    if( !dest )
      Cconws("\r\nFehler beim ôffnen.");

    if( fh && dest )
    {
      if( EOF == fputs( "Adressliste 1.05\n", dest ))
        error = 1;
      else
      {
        char *s, *buf = malloc (260);
        
        while( 1 == fread( buf, 260, 1, fh ) )
        {
          memset( a, 0, sizeof(ADRNODE) );
          
          s = buf;
          memcpy( a->zahlart, s, 2 ); 
          kill_blanks( a->zahlart, 2 );
          s += 2;

          memcpy( a->vorname, s, 30 ); 
          kill_blanks( a->vorname, 30 );
          s += 30;

          memcpy( a->name, s, 30 ); 
          kill_blanks( a->name, 30 );
          s += 30;

          memcpy( a->strasse, s, 30 ); 
          kill_blanks( a->strasse, 30 );
          s += 30;

          memcpy( a->plz, s, 6 ); 
          kill_blanks( a->plz, 6 );
          s += 6;

          memcpy( a->stadt, s, 30 ); 
          kill_blanks( a->stadt, 30 );
          s += 30;

          memcpy( a->land, s, 3 ); 
          kill_blanks( a->land, 3 );
          s += 3;

          s++;            

          memcpy( a->anrede, s, 10 ); 
          kill_blanks( a->anrede, 10 );
          s += 10;

          memcpy( a->telefon, s, 20 ); 
          kill_blanks( a->telefon, 20 );
          s += 20;

          memcpy( a->geburt, s, 8 ); 
          kill_blanks( a->geburt, 8 );
          s += 8;

          memcpy( a->bemerkung1, s, 40 ); 
          kill_blanks( a->bemerkung1, 40 );
          s += 40;

          memcpy( a->bemerkung2, s, 40 ); 
          kill_blanks( a->bemerkung2, 40 );
          s += 40;
          s++;
          
          memcpy( a->bemerkung3, s, 1 ); 
          s++;

          memcpy( a->kundennr, s, 8 ); 
          kill_blanks( a->kundennr, 8 );
          s += 8;
          
          if( count )
          {
            /*
            printf("\n%s\n%s %s\n%s\n%s %s %s\nTel.%s\n%s\n%s\n%s\n%s\n%s\n", 
            a->anrede, a->vorname, a->name, a->strasse, a->land, a->plz, 
            a->stadt, a->telefon, a->bemerkung1, a->bemerkung2, a->bemerkung3, 
            a->kundennr, a->geburt );
            */
            
           if( a->name[0] || a->vorname[0] || a->kundennr[0] || a->name1[0] || a->name2[0] )
             if( EOF == write_adr( dest, a ) ){
               error = 1;
               break;
             }
          }
          count++;
        }
        free(buf);
      }
  
      Cconws("\r\nSchlieûe Dateien");
      fclose( fh );
      
      if( !error )
        fclose( dest );
      else
        Cconws("\r\nFehler beim Sichern!");
    }
  }

  Cconws("\r\n-- Taste --");
  Cconin();

  return 0;
}
/****************************************************************************

 Einen ADRNODE nach stream schreiben.

 ****************************************************************************/
int write_adr(FILE *stream,ADRNODE *a)
{
  return fprintf(stream,
        "%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%ld|\n",
        a->vorname,
        a->name,
        a->name1,
        a->name2,
        a->strasse,
        a->land,
        a->plz,
        a->stadt,
        a->telefon,
        a->fax,
        a->kundennr,
        a->typ,
        a->anrede,
        a->zahlart,
        a->bemerkung1,
        a->bemerkung2,
        a->umsatz,
        a->rabatt,
        a->zahlziel,
        a->bemerkung3,
        a->anrede1,
        a->bank,
        a->blz,
        a->konto,
        a->geburt,
        a->fax1,
        a->telefon1,
        a->status,
        a->erstellt,
        a->geaendert,
        a->nr
        );
}
/****************************************************************************

 Leerzeichen hinten abschneiden

 ****************************************************************************/
void kill_blanks( char *s, int l )
{
  l -= 1;
  
  while( l >= 0 )
  {
    if( s[l] == ' ' )
      s[l] = 0;
    else
      break;
    
    l--;
  }
}
