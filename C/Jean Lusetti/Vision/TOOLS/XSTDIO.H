/***********************************************************/
/*-------------------- XSTDIO.H ---------------------------*/
/* Header de EXSTDIO.C                                     */
/* Ensemble de fonctions ‚tendues standard d'entr‚e-sortie */
/***********************************************************/
#if !defined(__STDIO)
#include <stdio.h>        /* Pour la structure size_t */
#endif

#if !defined(__XSTDIO)
#define __XSTDIO

#define FERR_CANCEL   -1
#define FERR_CREATE   -2
#define FERR_WRITE    -3
#define FERR_NOTEXIST -4
#define FERR_APPEND   -5


/*******************************************/
/* Teste si un fichier existe.             */
/* En retour :                             */
/*             0 : Le fichier n'existe pas */
/*             1 : Le fichier existe       */
/*******************************************/
int file_exist(char *name) ;

/*************************************************************/
/* Sauvegarde un fichier.                                    */
/* Efface ce fichier s'il existe d‚j…                        */
/* En retour :                                               */
/*             FERR_CREATE : Impossible de cr‚er le fichier. */
/*             FERR_WRITE  : Erreur d'ecriture.              */
/*************************************************************/
int file_save(char *name, void *buf, size_t size) ;

/*****************************************************************/
/* Sauvegarde un fichier.                                        */
/* Ne d‚truit pas le fichier s'il existe.                        */
/* En retour :                                                   */
/*             FERR_CREATE : Impossible de cr‚er le fichier.     */
/*             FERR_WRITE  : Erreur d'ecriture.                  */
/*             FERR_CANCEL : Annulation. Le fichier existe d‚j…. */
/*****************************************************************/
int file_ssave(char *name, void *buf, size_t size) ;

/******************************************************************/
/* Ajout en fin de fichier.                                       */
/* En retour :                                                    */
/*             FERR_APPEND    : Impossible d'effectuer une ajout. */
/*             FERR_WRITE     : Erreur d'ecriture.                */
/*             FERR_NOTEXIST  : Le fichier n'existe pas           */
/*******************************************************************/
int file_add(char *name, void *buf, size_t size) ;

/*******************************************************/
/* Renvoit la taille en octets d'un fichier.           */
/* Si le fichier n'existe pas, la fonction renvoit -1 .*/
/*******************************************************/
long file_size(char *name) ;

#endif