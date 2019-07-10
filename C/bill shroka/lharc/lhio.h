/*----------------------------------------------------------------------*/
/*		File I/O module for LHarc UNIX				*/
/*									*/
/*		Copyright(C) MCMLXXXIX  Yooichi.Tagawa			*/
/*									*/
/*  V0.00  Original				1989.06.25  Y.Tagawa	*/
/*  V0.03  Release #3  Beta Version		1989.07.02  Y.Tagawa	*/
/*----------------------------------------------------------------------*/

extern int		text_mode;

extern unsigned int	crc_table[0x100];
extern unsigned int	crc_value;
extern int		crc_getc_cashe;
extern FILE		*crc_infile, *crc_outfile;
extern long		crc_size;
#ifdef atarist
extern int tstflg;
#endif

#define CRC_CHAR(c)						\
{ register unsigned int ctmp = crc_value ^ c; 			\
    crc_value = (ctmp >> 8) ^ crc_table [ ctmp & 0xff ]; }



#if defined (__GNUC__)
/*#define inlnie*/

/* DECODING */
/* '0D0A' -> '0A' conversion and strip '1A' when text_mode */
static inline putc_crc (int c)
{
  CRC_CHAR (c);

#ifdef atarist
 if (!tstflg) /* If we are EXtracting the archive not merely Testing */
#endif
  if (!text_mode || (c != 0x0d && c != 0x1a))
    {
      putc (c, crc_outfile);
    }
}

/* ENCODING */
/* '0A' -> '0D0A' conversion when text_mode */
static inline int getc_crc ()
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
