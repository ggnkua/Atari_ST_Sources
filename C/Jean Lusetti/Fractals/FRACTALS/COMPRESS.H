/************************/
/* Header de COMPRESS.C */
/************************/
#if !defined(__STDIO)     /* Pour la structure size_t */
#include <stdio.h>
#endif


/********************************************************************/
/* Compression de l'image point‚e par new par d‚duction de l'image  */
/* Point‚e par last. Les deux images ont pour taille size octets    */
/* file d‚signe le nom du fichier cible. mode le type d'accŠs fopen */
/* En retour :  > 0 : Longueur en octets du fichier compress‚       */
/*                0 : Impossible de cr‚er le fichier cible ou       */
/*                    Erreur d'‚criture pendant la compression      */
/********************************************************************/
size_t compress(char *last, char *new, size_t size, FILE *stream) ;

/***********************************************************************/
/* D‚duction de l'image point‚e par last avec les donn‚es point‚es     */
/* Par data pour obtenir la nouvelle image point‚e par out.            */
/* Les deux images ont une taille de size octets.                      */
/* Renvoit la taille du fichier aprŠs d‚compression (size normalement) */
/***********************************************************************/
size_t decompress(char *last, char *data, size_t size, char *out) ;
