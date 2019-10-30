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

