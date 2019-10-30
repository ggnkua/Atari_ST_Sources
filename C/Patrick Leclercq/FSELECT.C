/************************************/
/*  UTILISATION SELECTEUR D'OBJETS  */
/************************************/
/*  Programme SELECT.C              */
/************************************/
#include <STDIO.H>
#include <OSBIND.H>
#include <STRING.H>
#include <GEMFAST.H>
#include <INITGEM.H>

/*****************************/
/*  APPEL SELECTEUR D'OBJET  */
/*****************************/
void fselect(nom,ext)
char *ext;
char *nom;
{
  int bouton;
  char chemin[100];
  char *adr;

  Dgetpath (chemin, 0);
  strcat(chemin,"\\");
  strcat(chemin,ext);
  fsel_input(chemin,nom,&bouton);
  if ((bouton!=0)&&(strlen(nom)!=0))
  {
     *strrchr(chemin,'\\')='\0';
     strcat(chemin,"\\");
     strcat(chemin,nom);
     strcpy(nom,chemin);
   }
   else strcpy(nom,"");
 }

void test()
{
  char message[100];

  fselect(message,"*.*");
  printf ("%s\n",message);
}

void main()
{
  InitGem();
  test();
  getchar();
  CloseGem();
}
