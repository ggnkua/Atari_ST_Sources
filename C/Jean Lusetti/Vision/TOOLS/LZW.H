/*******************/
/* Header de LZW.C */
/*******************/
#if !defined(__STDIO)
#include <stdio.h>      /* Pour la structure FILE */
#endif

/* Demander les infos MEMDEBUG si MEMDEBUG est d‚fini (Define Macro) */
#ifdef MEMDEBUG
#include "d:\pure_c\projects\tools\memdebug\memdebug.h"
#endif

#define MAX_BITS   12   /* Taille maximale d'un code en bits */

extern int code_size ;        /* Taille actuelle en bits d'un code      */
extern int bit1 ;             /* Position du d‚but du code dans l'octet */
extern unsigned char *pt_in ; /* Pointeur sur les donn‚es compress‚es   */
extern long bit_shift ;        /* # bit pour routine 68030               */


/*******************************************************/
/* A appeler avant toute autre fonction                */
/* ticode : Taille initiale d'un code en bits          */
/*          NB : ie nombre de plans par pixel pour GIF */
/* start  : Pointeur sur le premier code … interpr‚ter */
/*          NULL si on va faire une compression LZW    */
/* En retour :  0 : OK                                 */
/*             -1 : M‚moire insuffisante               */
/*******************************************************/
int lzw_init(int ticode, unsigned char *start, int gif_flag) ;

/*******************************************************/
/* Lib‚rer la m‚moire occup‚e par le d‚compactage LZW  */
/* Lors d'une compression nb_out est le dernier nombre */
/* D'octets qui ont ‚t‚ compress‚s.                    */ 
/*******************************************************/
void lzw_end(long *nb_out) ;

/*********************************************************/
/* D‚compression LZW                                     */
/* D‚compresse nb_bytesin octets … partir de in dans out */
/* in sert uniquement … compter le nombre d'octets o— un */
/* code est attendu, la gestion du d‚placement r‚el du   */
/* pointeur vers le prochain code est g‚r‚e en interne   */
/*********************************************************/
size_t lzw_decompress(unsigned char *in, unsigned char *out, size_t nb_bytein) ;

/****************************************************************/
/* Compression LZW                                              */
/* Compresse nb octets … partir de l'adresse sp‚cifi‚e src      */
/* A destination dans le fichier sp‚cifi‚ par stream.           */
/* En retour :                                                  */
/*             0 : OK                                           */
/*            -1 : M‚moire insuffisante                         */
/*            -2 : Erreur d'‚criture sur fichier                */
/****************************************************************/
int lzw_compress(unsigned char *src, size_t nb, FILE *stream, long *nb_out) ;
