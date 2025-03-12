/*****************************************************************/
/* Var_edit erzeugt Dialogboxen mit Editfeldern variabler Laenge */
/*																															 */
/*             Autor: Wolfgang Heine, 8111 Urfeld                */
/* 								(c) 1992 MAXON Computer GmbH									 */
/*****************************************************************/

#include  <stdio.h>
#include  <string.h>
#include	<aes.h>

#define TITEL     1
#define TXT_1     2
#define TXT_2     3
#define TXT_3     4
#define AUS       5
#define OK        6

int contrl[12], intin[128], intout[128], ptsin[128], ptsout[128];


char *var_edit(OBJECT tree[], int index, int n, char *pt, char *tx, char *val)
				/* OBJECT tree[]:       uebergebenes Objekt          */
				/* int index:           Objektindex                  */
				/* int n:               Laenge des Editfeldes        */
				/* char *pt, *tx, *val: Zeiger auf Maskentext u.Text */
{                                         /* und Validit„tszeichen        */
  register  OBJECT *obj;
  register TEDINFO *ted;
  register char *s, *t;
  obj = (OBJECT*) &tree[index];           /* Adresse des Objekts im Baum  */
  obj->ob_width = 8*n;                    /* Obj.breite = 8 * Buchst.zahl */
  obj->ob_x = (tree[0].ob_width           /* Objekt zentrieren            */
            - obj->ob_width)/2;
  ted = obj->ob_spec.tedinfo;        /* Tedinfoadresse ermitteln     */
  ted->te_tmplen = n + 1;                 /* Laenge der Textmaske         */
                                          /* Nullbyte nicht vergessen     */   
  strcpy (s = ted->te_ptmplt, pt);        /* Maskentext eintragen         */
  while( strlen(ted->te_ptmplt) < n )     /* Rest mit "_" auffuellen      */ 
    strcat(ted->te_ptmplt, "_");

  t = ted->te_pvalid;                     /* Fuer jedes "_" im Maskentext */  
  while(*s)                               /* wird im Validitaetsstring das*/
    if (*s++ == '_')                      /* in val uebergebene Zeichen   */
      *t++ = *val;                        /* eingetragen                  */
  *t= '\0';                               /* Mit Nullbyte abschliežen     */
  ted->te_txtlen=strlen(ted->te_pvalid)+1;/* Textlaenge=Validlaenge+Nullb.*/
  return strcpy (ted->te_ptext, tx);      /* Text eintragen und Adresse   */
                                          /* zurueckmelden                */
}


/*---------------------*/
/* Dialogfeld aufrufen */
/*---------------------*/

int hndl_dial (OBJECT tree[],int cur,int x,int y,int w,int h)
				/* OBJECT tree []:  Baumadresse                  */
				/* int cur,x,y,w,h: Wo soll der Cursor sitzen?   */
{
  int xd, yd, wd, hd;
  int exit_objc;                                /* Nummer d. Exit-Buttons */
  form_center (tree, &xd, &yd, &wd, &hd);       /* Formular zentrieren    */
  form_dial(FMD_START, x,y,w,h, xd,yd,wd,hd);   /* Bildschirmbereich res. */
  form_dial(FMD_GROW,  x,y,w,h, xd,yd,wd,hd);   /* Growbox                */

  objc_draw(tree,ROOT,MAX_DEPTH, xd,yd,wd,hd);  /* Dialogbox zeichnen     */
  exit_objc = form_do (tree, cur ) & 0x7FFF;    /* Dialog abhandeln       */

  form_dial(FMD_SHRINK, x,y,w,h, xd,yd,wd,hd);  /* Shrinkbox              */
  form_dial(FMD_FINISH, x,y,w,h, xd,yd,wd,hd);  /* Bildschirmbereich frei-*/
                                                /* geben und Hintergrund  */
                                                /* herstellen             */
  objc_change(tree,exit_objc, 0, 0,0,639,399,NORMAL, 0);
                           /* selektierten Knopf wieder normal darstellen */
  return (exit_objc);                           /* Exitbutton melden      */
} 
