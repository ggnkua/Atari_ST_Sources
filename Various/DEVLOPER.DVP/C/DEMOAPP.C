/***************************************************/
/*  DÇmonstration d'une mini application sous GEM  */
/*  Laser C             DEMOAPP.C  */
/***************************************************/

char s[80];           /* Chaåne d'aide; la chaåne attendue par form_alert */
                      /* est rÇÇcrite ici (pas obligatoire, mais sert ici */
                      /* uniquement Ö garder une ligne courte) */

main()
{
  appl_init();                                 /* Initialise l'AES */
  
  strcpy (s, "[1][Salut!|Application sous GEM!][Aha]"); 
  
  form_alert (1, s);      /* Afficher une boåte d'alerte et attendre */
                          /* l'appui du bouton */

  appl_exit();            /* Desactive l'AES */
}




