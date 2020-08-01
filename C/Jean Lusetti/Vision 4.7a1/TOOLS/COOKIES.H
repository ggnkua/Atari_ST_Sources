/******************************/
/*-------- COOKIES.H ---------*/
/* Header du module COOKIES.C */
/******************************/
typedef struct
{
  long magic ;
  long data ;
} COOKIE;


/**************************************/
/* Renvoit l'adresse de la cookie_jar */
/**************************************/
COOKIE *cookie_jar(void) ;

/***********************************************************/
/* Renvoit l'adresse du cookie identifi‚ par ident         */
/* En retour : NULL si l'identificateur n'a pas ‚t‚ trouv‚ */
/***********************************************************/
COOKIE *cookie_find(char ident[4]) ;
