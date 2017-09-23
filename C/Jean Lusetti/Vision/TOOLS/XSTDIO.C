/**************************************************************/
/*         Extension de la bibliothŠque STDIO du C            */
/*-------------------- XSTDIO.C ------------------------------*/
/* (c) LUSETTI Jean Mars 93                                   */
/* NB : Si on enlŠve les appels GEM (form_... et graf_mouse), */
/*      La bibliothŠque est compatible avec les systŠmes      */
/*      MS-DOS et UNIX.                                       */
/*      Fonctions standards utilis‚es :                       */
/*      fopen, fwrite, fclose, filelength, fileno.            */
/**************************************************************/
#include <string.h>
#include  <stdio.h>
#include    <ext.h>          /* Les headers EXT.H et XGEM.H sont */
                             /* Sp‚cifiques au systŠme Atari     */
#include   "..\tools\xgem.h"


#define FERR_CANCEL   -1
#define FERR_CREATE   -2
#define FERR_WRITE    -3
#define FERR_NOTEXIST -4
#define FERR_APPEND   -5


int file_exist(char *name)
{
  FILE *stream ;

  stream = fopen(name, "rb") ;

  if (stream == NULL) return(0) ;
  else fclose(stream) ;

  return(1) ;
}

int file_save(char *name, void *buf, size_t size)
{
  MOUSE_DEF save ;
  FILE      *stream ;
  size_t    nb_obj ;

  memcpy(&save, &mouse, sizeof(MOUSE_DEF)) ;
  stream = fopen(name, "wb") ;
  if (stream == NULL)
  {
	form_interrogation(1, "[Impossible de cr‚er|un fichier !][OK]") ;
	return(FERR_CREATE) ;
  }

  mouse.gr_monumber = BUSYBEE ;
  set_mform(&mouse) ;
  nb_obj = fwrite(buf, size, 1, stream) ;
  if (nb_obj != 1)
  {
	form_interrogation(1, "[Erreur d'‚criture.][OK]") ;
	fclose(stream) ;
    set_mform(&save) ;
	return(FERR_WRITE) ;
  }

  if (fclose(stream) != 0)
  {
	form_interrogation(1, "[Erreur d'‚criture.][OK]") ;
    set_mform(&save) ;
	return(FERR_WRITE) ;  /* En fait, le flux ne peut pas se vider */
  }                       /* C'est donc une erreur d'‚criture      */

  set_mform(&save) ;
  return(0) ;
}

int file_ssave(char *name, void *buf, size_t size)
{
  MOUSE_DEF save ;
  int       err = 0 ;
  
  memcpy(&save, &mouse, sizeof(MOUSE_DEF)) ;
  if (!file_exist(name))
  {
    FILE   *stream ;
	size_t nb_obj ;
    
	stream = fopen(name, "wb") ;
	if (stream == NULL)
	{
	  form_interrogation(1, "[Impossible de cr‚er|un fichier !][OK]") ;
	  err = FERR_CREATE ;
	}
	else
	{
      mouse.gr_monumber = BUSYBEE ;
      set_mform(&mouse) ;
	  nb_obj = fwrite(buf, size, 1, stream) ;
	  if (nb_obj != 1)
	  {
	    form_interrogation(1, "[Erreur d'‚criture.][OK]") ;
	    fclose(stream) ;
	    err = FERR_WRITE ;
	  }
	  else
	  {
		if (fclose(stream) != 0)
		{
		  form_interrogation(1, "[Erreur d'‚criture.][OK]") ;
		  err = FERR_WRITE ; /* En fait, le flux ne peut pas se vider */
  		}                    /* C'est donc une erreur d'‚criture      */
	  }
	}
  }
  else
  {
	int r = 0 ;

	r = form_interrogation(2, "[Ce fichier existe d‚j….|Dois-je le remplacer ?][Oui|Non]") ;
	if (r == 1)
	  err = file_save(name, buf, size) ;
	else
	{
	  form_stop(1, "[Sauvegarde annul‚e ...][OK]") ;
	  err = FERR_CANCEL ;
	}
  }

  set_mform(&save) ;
  return(err) ;
}

int file_add(char *name, void *buf, size_t size)
{
  MOUSE_DEF save ;
  
  memcpy(&save, &mouse, sizeof(MOUSE_DEF)) ;
  if (!file_exist(name)) return(FERR_NOTEXIST) ;
  else
  {
	FILE      *stream ;
	size_t    nb_obj ;
  
	stream = fopen(name, "ab") ;
	if (stream == NULL) return(FERR_APPEND) ;

    mouse.gr_monumber = BUSYBEE ;
    set_mform(&mouse) ;
	nb_obj = fwrite(buf, size, 1, stream) ;
	if (nb_obj != 1)
	{
	  fclose(stream) ;
	  set_mform(&save) ;
	  return(FERR_WRITE) ;
	}

	if (fclose(stream) != 0)
	{
	  set_mform(&save) ;
	  return(FERR_WRITE) ;  /* En fait, le flux ne peut pas se vider */
	}                       /* C'est donc une erreur d'‚criture      */
  }	

  set_mform(&save) ;
  return(0) ;
}

long file_size(char *name)
{
  FILE *stream ;
  long length ;
  int  handle ;

  stream = fopen(name, "rb") ;
  if (stream == NULL) return(-1) ;
  handle = fileno(stream) ;
  length = filelength(handle) ;

  fclose(stream) ;
  return(length) ;
}
