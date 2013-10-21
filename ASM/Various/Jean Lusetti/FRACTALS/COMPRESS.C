/************************************************************/
/* D‚duction d'une image par rapport … une image pr‚c‚dente */
/* (c) LUSETTI Jean, Juillet 1993                           */
/************************************************************/
#include  <stdio.h>
#include <string.h>

#define NB_MAX  127

/* ParamŠtres … passer … la routine assembleur asm_dcompress */
char *ain ;   /* Pointeur sur les donn‚es compact‚es                   */
char *aout ;  /* Pointeur sur la zone m‚moire en cours de d‚compactage */

long asize ;           /* Nombre d'octets d‚compact‚s */
void dcompress(void) ; /* Routine dans COMPRESS.S     */
  


size_t compress(char *last, char *new, size_t size, FILE *stream)
{
  size_t nb_ecrit ;
  size_t taille ;
  long   where ;
  int    pos_buf ;
  int    nb ;
  char   buf[1+NB_MAX+4*BUFSIZ] ;
  char   *pt_last, *pt_new, *pt ;

  if (stream == NULL) return(0) ;

  pt_last = last ;
  pt_new  = new ;
  pos_buf = 0 ;
  where   = 0 ;
  taille  = 0 ;

  while (where < size)
  {
    nb = 0 ;
    while ((*pt_last == *pt_new) && (where < size) && (nb < NB_MAX))
    {
      nb++ ;
      pt_last++ ;
      pt_new++ ;
      where++ ;
    }

    if (nb != 0) buf[pos_buf++] = nb | 0x80 ;
    else
    {
      pt = pt_new ;
      while ((*pt_last != *pt_new) && (where < size) && (nb < NB_MAX))
      {
        nb++ ;
        pt_last++ ;
        pt_new++ ;
        where++ ;
      }
      buf[pos_buf++] = nb ;
      memcpy(&buf[pos_buf], pt, 1+nb) ;
      pos_buf += nb ;
    }

    if (pos_buf >= 4*BUFSIZ)
    {
      nb_ecrit = fwrite(buf, pos_buf, 1, stream) ;
      if (nb_ecrit != 1)
      {
        fclose(stream) ;
        return(0) ;
      }
      taille += pos_buf ;
      pos_buf = 0 ;
    }
  }

  buf[pos_buf++] = 0 ;
  nb_ecrit       = fwrite(buf, pos_buf, 1, stream) ;
  if (nb_ecrit != 1)
  {
    fclose(stream) ;
    return(0) ;
  }

  taille += pos_buf ;
  if (taille > (size << 1)) return(0) ; /* A priori impossible */

  return(taille) ;
}

size_t decompress(char *last, char *data, size_t size, char *out)
{
  if (last != out) memcpy(out, last, size) ;

  ain  = data ;
  aout = out ;
  dcompress() ;

  return(asize) ;
}
