#include <string.h>
#include <aes.h>

#define STFILELEN            13  /* Longueur max du nom de fichier      */
#define STPATHLEN            64  /* Longueur maxi du chemin             */
#define BACKSLASH          '\\'


int selected(OBJECT arbre[],short int index)
{
	return(arbre[index].ob_state & 1);
}

void activer(OBJECT arbre[],short int index,int x,int y,int w,int h)
{
	arbre[index].ob_state &= -9;
	objc_draw(arbre,index,0,x,y,w,h);
}

void desactiver(OBJECT arbre[],short int index,int x,int y,int w,int h)
{
	arbre[index].ob_state |=8;
	objc_draw(arbre,index,0,x,y,w,h);
}

void select(OBJECT arbre[],short int index,int x,int y,int w,int h)
{ 
	arbre[index].ob_state |=1;
	objc_draw(arbre,index,0,x,y,w,h);
}

void deselect(OBJECT arbre[],short int index,int x,int y,int w,int h)
{ 
	arbre[index].ob_state &=-2;
	objc_draw(arbre,index,0,x,y,w,h);
}
void show_dialog(OBJECT *arbre,int *x,int *y,int *w,int *h)
{
 form_center(arbre,x,y,w,h);
 form_dial(0,*x,*y,*w,*h,*x,*y,*w,*h);
 form_dial(1,1,1,25,25,*x,*y,*w,*h);
 objc_draw(arbre,0,12,*x,*y,*w,*h);
}

void hide_dialog(OBJECT *arbre)
{
 int x,y,w,h;
 
 form_center(arbre,&x,&y,&w,&h);
 form_dial(2,25,25,25,25,x,y,w,h);
 form_dial(3,x,y,w,h,x,y,w,h);
}

void write_text(OBJECT arbre[],int index, char *string)
{ TEDINFO *ted;

	ted=arbre[index].ob_spec.tedinfo;
	strcpy(ted->te_ptext,string);
}

int file_select( char chemin[] )
{ 
   char nom_fichier[STFILELEN]=""; 						/* Buffer pour nom fichier       */
   char path[STPATHLEN]="";
   int  bouton;				                            /* Contient le code du bouton    */
   char *position;
                            					        /* (OK ou ANNULER)               */
 	strcpy(path,chemin);
 	position=strrchr(path,(int) BACKSLASH);
 	strcpy(nom_fichier,position+1);
 	*(position+1)=0;
 	
   	fsel_exinput( path, nom_fichier, &bouton, "Choix du fichier" );

  	if ( bouton != 0)
   	{
   	  strcpy(chemin,path);
      strcpy(strrchr(chemin, (int) BACKSLASH)+1,nom_fichier);
   	}

   return ( bouton );
}