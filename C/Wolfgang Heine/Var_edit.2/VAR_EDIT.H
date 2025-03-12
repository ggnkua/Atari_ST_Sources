
char *var_edit(OBJECT tree[], int index, int n, char *pt, char *tx, char *val);
				/* OBJECT tree[]:       uebergebenes Objekt          */
				/* int index:           Objektindex                  */
				/* int n:               Laenge des Editfeldes        */
				/* char *pt, *tx, *val: Zeiger auf Maskentext u.Text */

int hndl_dial (OBJECT tree[],int cur,int x,int y,int w,int h);
				/* OBJECT tree []:  Baumadresse                  */
				/* int cur,x,y,w,h: Wo soll der Cursor sitzen?   */
