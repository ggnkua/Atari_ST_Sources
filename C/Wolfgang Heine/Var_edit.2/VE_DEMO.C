/*****************************************************************/
/* Var_edit erzeugt Dialogboxen mit Editfeldern variabler Laenge */
/*																															 */
/*             Autor: Wolfgang Heine, 8111 Urfeld                */
/* 								(c) 1992 MAXON Computer GmbH									 */
/*****************************************************************/

#include  <stdio.h>
#include  <string.h>
#include	<aes.h>
#include	"var_edit.h"

#define TITEL     1
#define TXT_1     2
#define TXT_2     3
#define TXT_3     4
#define AUS       5
#define OK        6

int contrl[12], intin[128], intout[128], ptsin[128], ptsout[128];

typedef char STRING[80];

STRING s[] = 
  {
    "",                                   /* s[ 0]                        */
    "",                                   /* s[ 1]                        */
    "",                                   /* s[ 2]                        */
    "",                                   /* s[ 3]                        */
    "",                                   /* s[ 4]                        */
    "",                                   /* s[ 5]                        */ 
    "",                                   /* s[ 6]                        */
    "",                                   /* s[ 7]                        */
    "",                                   /* s[ 8]                        */ 
    "",                                   /* s[ 9]                        */
    "",                                   /* s[10]                        */
    "",                                   /* s[11]                        */ 
    "Ende",                               /* s[12]                        */
    "OK"                                  /* s[13]                        */
  };

TEDINFO ted[] = 
  {
    s[ 0], s[ 1], s[ 2],  3, 6, 2, 0x1180, 0x0, -4,  -2,  -2,
    s[ 3], s[ 4], s[ 5],  3, 6, 0, 0x1180, 0x0, -1,  -2,  -2,
    s[ 6], s[ 7], s[ 8],  3, 6, 0, 0x1180, 0x0, -1,  -2,  -2,
    s[ 9], s[10], s[11],  3, 6, 0, 0x1180, 0x0, -1,  -2,  -2
  }; 
  
OBJECT baum[] = 
  {
   -1, 1, 6, G_BOX,     NONE,     OUTLINED, 0x21100L,  0,  0,  -2,  200,
    2,-1,-1, G_BOXTEXT, NONE,     OUTLINED|SHADOWED, 
                                            &ted[0],  -2,  20,  -2,  18,
    3,-1,-1, G_FTEXT,   EDITABLE, NORMAL,   &ted[1],  -2,  60,  -2,  18,
    4,-1,-1, G_FTEXT,   EDITABLE, NORMAL,   &ted[2],  -2,  80,  -2,  18,
    5,-1,-1, G_FTEXT,   EDITABLE, NORMAL,   &ted[3],  -2, 100,  -2,  18,
    6,-1,-1, G_BUTTON,  SELECTABLE|EXIT|OUTLINED,  
                                  NORMAL,   s[12],    -2, 130,  70,  20,
    0,-1,-1, G_BUTTON,  SELECTABLE|EXIT|DEFAULT|LASTOB,
                                  NORMAL,   s[13],    -2, 130,  70,  20
  };
  
/**************************************************************************/

main()
{
char help[80];
  int n;                                  /* Buchstaben im Editfeldfeld   */
  char *txt1_adr, *txt2_adr, *txt3_adr;   /* Adressen der Texte           */

  appl_init();                            /* Applikation anmelden         */
  for ( n = 25; n < 85 ; n += 10)         /* Verschiedene n probieren     */
  {
    baum[0].ob_width = n*8+60;            /* Breite des Vaterobjekts      */

    baum[AUS].ob_x=baum[0].ob_width/2     /* Ende-Button und OK-Button    */
              - 10-baum[AUS].ob_width;    /* symmetrisch zur Mitte        */
    baum[OK].ob_x=baum[0].ob_width/2+10;  /* anordnen                     */
    
    /* 3 Editfelder der Laenge n einrichten und Texte eintragen           */
    sprintf(help,"%s %d %s"," Editfelder mit", n, "Buchstaben ");   
    var_edit(baum, TITEL, strlen(help),"",help,"X");
    txt1_adr = var_edit(baum, TXT_1, 18, "Datum : __.__.19__","310790","9");
    txt2_adr = var_edit(baum, TXT_2, n, "Zeile 1: ","Edit-","X");
    txt3_adr = var_edit(baum, TXT_3, n, "Zeile 2: ","felder","X");

    /* Dialogfeld aufrufen, Prog. beenden, falls Ende-Button gedrueckt ist*/

    if ( hndl_dial(baum, TXT_1, 0,0,0,0) == AUS )
      break;
    printf("\033Y  ");                    /* od. "\033Y%c%c",y+' ',x+' '  */
    printf("\033K%s\n",txt1_adr);         /* Zeilen freimachen und aus-   */
    printf("\033K%s\n",txt2_adr);         /* gelesene Texte anschreiben   */
    printf("\033K%s\n",txt3_adr);
    puts("            Taste druecken!");
  }
  appl_exit();                            /* Programm beenden             */
  return(0);
}


