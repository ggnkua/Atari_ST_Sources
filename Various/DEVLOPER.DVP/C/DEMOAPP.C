/***************************************************/
/*  D�monstration d'une mini application sous GEM  */
/*  Laser C             DEMOAPP.C  */
/***************************************************/

char s[80];           /* Cha�ne d'aide; la cha�ne attendue par form_alert */
                      /* est r��crite ici (pas obligatoire, mais sert ici */
                      /* uniquement � garder une ligne courte) */

main()
{
  appl_init();                                 /* Initialise l'AES */
  
  strcpy (s, "[1][Salut!|Application sous GEM!][Aha]"); 
  
  form_alert (1, s);      /* Afficher une bo�te d'alerte et attendre */
                          /* l'appui du bouton */

  appl_exit();            /* Desactive l'AES */
}




