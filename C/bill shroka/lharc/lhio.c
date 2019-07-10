/*----------------------------------------------------------------------*/
/*		File I/O module for LHarc UNIX				*/
/*									*/
/*		Copyright(C) MCMLXXXIX  Yooichi.Tagawa			*/
/*									*/
/*  V0.00  Original				1989.06.25  Y.Tagawa	*/
/*  V0.03  Release #3  Beta Version		1989.07.02  Y.Tagawa	*/
/*  V0.03a Fix few bugs				1989.07.04  Y.Tagawa	*/
/*----------------------------------------------------------------------*/

#include <stdio.h>
#ifdef atarist
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <unixlib.h>
#include <memory.h>
#endif
#include "lhio.h"

#include "proto.h"
static crcsub P((char *ptr , int length ));
static copy_binary_file P((FILE *ifp , FILE *ofp , long size , int crc_flag ));
static write_generic_text_file P((FILE *ifp , FILE *ofp , long size ));
static read_generic_text_file P((FILE *ifp , FILE *ofp , long size , int crc_flag ));

#undef P

#ifndef BUFFER_SIZE
#define BUFFER_SIZE	16384
#endif


extern int	text_mode;			/* in lharc.c */
FILE		*crc_infile, *crc_outfile;	/* in lzhuf.c */

/* These functions are NO-RETURN */
extern read_error ();
extern write_error ();


int		crc_getc_cashe;
unsigned int	crc_value;
unsigned int	crc_table[0x100];
long		crc_size;


static crcsub (ptr, length)
     char		*ptr;
     register int	length;
{
  register unsigned char	*p;
  register unsigned int		ctmp;
  
  if (length != 0)
    {
      ctmp = crc_value;
      p = (unsigned char*)ptr;
      for (; length; length --)
	{
	  ctmp ^= (unsigned int)*p++;
	  ctmp = (ctmp >> 8) ^ crc_table [ ctmp & 0xff ];
	}
      crc_value = ctmp;
    }
}

#ifndef __GNUC__
void putc_crc (c)
     int c;
{
  CRC_CHAR (c);
  if (!text_mode || (c != 0x0d && c != 0x1a))
    {
      putc (c, crc_outfile);
    }
}

int getc_crc ()
{
  int	c;

  if (crc_getc_cashe != EOF)
    {
      c = crc_getc_cashe;
      crc_getc_cashe = EOF;
      CRC_CHAR (c);
      crc_size++;
    }
  else if ((c = getc (crc_infile)) != EOF)
    {
      if (text_mode && c == 0x0a)
	{
	  crc_getc_cashe = c;
	  c = 0x0d;
	}
      CRC_CHAR (c);
      crc_size++;
    }
  return c;
}
#endif



init_crc ()
{
  static int		inited = 0;
  register unsigned int	*p = crc_table;
  register int		i, j;
  register unsigned int	x;

  if (!inited) {
    for (j = 0; j < 256; j ++) {
      x = j;
      for (i = 0; i < 8; i ++) {
	if ((x & 1) != 0) {
	  x = (x >> 1) ^ 0xa001;
	} else {
	  x = (x >> 1);
	}
      }
      *p ++ = x;
    }
    inited = 1;
  }
  crc_value = 0;
  crc_getc_cashe = EOF;
  crc_size = 0;
}

/*----------------------------------------------------------------------*/
/*									*/
/*----------------------------------------------------------------------*/

/* if return value is -1, see errno */
static copy_binary_file (ifp, ofp, size, crc_flag)
     FILE	*ifp, *ofp;
     long	size;
     int	crc_flag;	/* as boolean value */
{
  char		buffer [ BUFFER_SIZE ];
  int		read_size;
  int		n;
 
  /* safty */
  fflush (ofp);

  while (size > 0)
    {
      read_size = ((size < BUFFER_SIZE) ? (int)size : BUFFER_SIZE);

      n = fread (buffer, sizeof (char), read_size, ifp);

      if (n == 0)
	read_error ();

      if (fwrite (buffer, sizeof (char), n, ofp) < n)
	write_error ();

      if (crc_flag)
	crcsub (buffer, n);

      size -= (long)n;
    }
}

/* read UNIX text file '0A' and write generic text file '0D0A' */
static write_generic_text_file (ifp, ofp, size)
     FILE	*ifp, *ofp;
     long	size;
{
  char		buffer[BUFFER_SIZE];
  int		read_size, write_count, n, m;
  register char	*p, *p1, *e;

  /* safty */
  fflush (ofp);

  write_count = 0;

  while (size > 0)
    {
      read_size = ((size < BUFFER_SIZE) ? (int)size : BUFFER_SIZE);

      n = fread (buffer, sizeof (char), read_size, ifp);

      if (n == 0)
	read_error ();

      for (p1 = p = buffer, e = buffer + n; p < e; p++)
	{
	  if (*p == '\n')
	    {
	      if ((m = p - p1) != 0)
		{
		  if (fwrite (p1, sizeof (char), m, ofp) < m)
		    write_error ();
		  crcsub (p1, m);
		}
	      putc (0x0d, ofp);
	      if (feof (ofp))
		write_error ();
	      CRC_CHAR (0x0d);
	      p1 = p;
	      write_count ++;
	    }
	}
      if ((m = p - p1) != 0)
	{
	  if (fwrite (p1, sizeof (char), m, ofp) < m)
	    write_error ();
	  crcsub (p1, m);
	}

      write_count += (long)n;
      size -= (long)n;
    }

  crc_size = write_count;
}

/* read generic text file '0D0A' and write UNIX text file '0A' */
static read_generic_text_file (ifp, ofp, size, crc_flag)
     FILE	*ifp, *ofp;
     long	size;
     int	crc_flag;
{
  char		buffer[BUFFER_SIZE];
  int		read_size, write_size, n, m;
  register char *p, *p1, *e;

  /* safty */
  fflush (ofp);

  while (size > 0)
    {
      read_size = ((size < BUFFER_SIZE) ? (int)size : BUFFER_SIZE);

      n = fread (buffer, sizeof (char), read_size, ifp);

      if (n == 0)
	read_error ();

      crcsub (buffer, n);

      for (p1 = p = buffer, e = buffer + n; p < e; p ++)
	{
	  if (*p == 0x0d)
	    {
	      if ((m = p - p1) != 0)
		{
		  if (fwrite (p1, sizeof (char), m, ofp) < m)
		    write_error ();
		}
	      p1 = p+1;
	    }
	}
      if ((m = p - p1) != 0)
	{
	  if (fwrite (p1, sizeof (char), m, ofp) < m)
	    write_error ();
	}

      size -= (long)n;
    }
}


/*----------------------------------------------------------------------*/
/*									*/
/*----------------------------------------------------------------------*/


copy_file (ifp, ofp, size)
     FILE	*ifp, *ofp;
     long	size;
{
  copy_binary_file (ifp, ofp, size, 0);
}

/*ARGSUSED*/
int decode_stored_crc (ifp, ofp, original_size, name)
     FILE	*ifp, *ofp;
     long	original_size;
     char	*name;
{
  init_crc ();

  if (text_mode)
    {
      read_generic_text_file (ifp, ofp, original_size, 1);
      return crc_value;
    }
  else
    {
      copy_binary_file (ifp, ofp, original_size, 1);
      return crc_value;
    }
}

/*ARGSUSED*/
int decode_stored_nocrc (ifp, ofp, original_size, name)
     FILE	*ifp, *ofp;
     long	original_size;
     char	*name;
{
  if (text_mode)
    {
      read_generic_text_file (ifp, ofp, original_size, 0);
      return 0;			/* DUMMY */
    }
  else
    {
      copy_binary_file (ifp, ofp, original_size, 0);
    }
  return 0;			/* DUMMY */
}

int encode_stored_crc (ifp, ofp, size, original_size_var, write_size_var)
     FILE	*ifp, *ofp;
     long	*original_size_var;
     long	*write_size_var;
{
  init_crc ();

  if (text_mode)
    {
      write_generic_text_file (ifp, ofp, size);
      *original_size_var = *write_size_var = crc_size;
      return crc_value;
    }
  else
    {
      copy_binary_file (ifp, ofp, size, 1);
      *original_size_var = size;
      *write_size_var = size;
      return crc_value;
    }
}
