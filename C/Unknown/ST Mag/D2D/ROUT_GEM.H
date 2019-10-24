#define STFILELEN            13  /* Longueur max du nom de fichier      */
#define STPATHLEN            64  /* Longueur maxi du chemin             */
#define BACKSLASH          '\\'


int selected(OBJECT arbre[],short int index);
void activer(OBJECT arbre[],short int index,int x,int y,int w,int h);
void desactiver(OBJECT arbre[],short int index,int x,int y,int w,int h);
void select(OBJECT arbre[],short int index,int x,int y,int w,int h);
void deselect(OBJECT arbre[],short int index,int x,int y,int w,int h);
void show_dialog(OBJECT *arbre,int *x,int *y,int *w,int *h);
void hide_dialog(OBJECT *arbre);
void write_text(OBJECT arbre[],int index, char *string);
int file_select( char chemin[] );
