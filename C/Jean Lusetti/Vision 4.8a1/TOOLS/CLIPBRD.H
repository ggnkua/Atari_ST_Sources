/***********************/
/* Header de CLIPBRD.C */
/***********************/

/*************************************************************/
/* Cr‚e un dossier clipboard CLIPBRD sur                     */
/* Le disque de boot et en informe l'AES.                    */
/* En retour :  0 : OK                                       */
/*             -1 : Impossible de cr‚er le dossier Clipboard */
/*             -2 : Erreur en le signalant … l'AES           */
/*************************************************************/
int clbd_create(char *path) ;

/************************************************************/
/* Demande du chemin du clipboard sous forme normalis‚e      */
/* "C:\CLIPBRD\"                                             */
/* Si le nom du clipboard n'est pas initialis‚, il est       */
/* Cr‚e sur le disque de boot                                */
/* En retour :  0 : OK                                       */
/*             -1 : Impossible de cr‚er le dossier Clipboard */
/*             -2 : Erreur en le signalant … l'AES           */
/*************************************************************/
int clbd_getpath(char *path) ;
