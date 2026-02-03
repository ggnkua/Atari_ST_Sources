/*
  Tool to generate Milan ROM packages.
  (C) 1999 Michael Schwingen
*/

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#define MAX_FILESIZE (512*1024l)

typedef unsigned long ULONG;
typedef unsigned short UWORD;
typedef          short WORD;
typedef unsigned char UBYTE;

#include "package.h"
#include "crc32.c"

/* gzip flag byte */
#define ASCII_FLAG   0x01 /* bit 0 set: file probably ascii text */
#define CONTINUATION 0x02 /* bit 1 set: continuation of multi-part gzip file */
#define EXTRA_FIELD  0x04 /* bit 2 set: extra field present */
#define ORIG_NAME    0x08 /* bit 3 set: original file name present */
#define COMMENT      0x10 /* bit 4 set: file comment present */
#define ENCRYPTED    0x20 /* bit 5 set: file is encrypted */
#define RESERVED     0xC0 /* bit 6,7:   reserved */

static int check_method(unsigned char **buffer)
{
  unsigned char flags;
  int method;

#define get_byte() (*(*buffer)++)
  
  if( get_byte() != 0x1f)
    return 0;
  if( get_byte() != 0x8B)
    return 0;		/* not GZIP_MAGIC */
  
  method = get_byte();
  flags  = get_byte();

  if ((flags & (ENCRYPTED|CONTINUATION|RESERVED)) != 0)
    return 0;

  get_byte();
  get_byte();
  get_byte();
  get_byte();
  get_byte();
  get_byte();	/* skip over timestamp, skip extra flags, skip OS type */

  if ((flags & EXTRA_FIELD) != 0) {
    unsigned len = get_byte();
    len |= get_byte() << 8;
    while(len--)
      get_byte();
  }
  
  /* Get original file name if it was truncated */
  if ((flags & ORIG_NAME) != 0) {
    while (get_byte() != 0)
      ;
  }

  /* Discard file comment if any */
  if ((flags & COMMENT) != 0) {
    while (get_byte() != 0) /* null */ ;
  }
  return 1; /* OK */
}

unsigned long do_zip(unsigned char *buffer, unsigned long len)
{
  FILE *fp;
  char tmpname[100] = "mkromXXXXXX";
  char cmd[100];

  if(mktemp(tmpname) == 0)
    return 0;
  fp = fopen(tmpname,"wb");
  if (fp==0)
    return 0;
  if(len != fwrite(buffer, 1, len, fp))
  {
    fclose(fp);
    unlink(tmpname);
    return 0;
  }
  fclose(fp);
  sprintf(cmd,"gzip -9 %s",tmpname);
  if(system(cmd) != 0)
    return 0;
  strcat(tmpname,".gz");

  fp = fopen(tmpname,"rb");
  if (fp==0)
    return 0;
  len = fread(buffer, 1, len, fp);
  fclose(fp);
  unlink(tmpname);

  return len;
}

void fputl(unsigned long x, FILE *fp)
{
  fputc((x>>24) & 0xFF, fp);
  fputc((x>>16) & 0xFF, fp);
  fputc((x>> 8) & 0xFF, fp);
  fputc((x    ) & 0xFF, fp);
}

void fputw(unsigned short x, FILE *fp)
{
  fputc((x>> 8) & 0xFF, fp);
  fputc((x    ) & 0xFF, fp);
}

int main(int argc, char *argv[])
{
  FILE *fpin = 0, *fpout=0;
  char c;
  unsigned char *buffer, *ptr;
  int error=0;
  char srcname[256] = "-";
  char dstname[256] = "-";
  unsigned int id=0;
  PKG_TYPE type = PKGTYPE_UNKNOWN;
  unsigned long orig_len, orig_crc, compr_len, compr_crc;
  char pkg_name[32]  = "\000                              ";
  char pkg_descr[32] = "(no description)               ";
  
  extern char *optarg;
  extern int optind;
  
  buffer = malloc(MAX_FILESIZE);
  if(!buffer)
  {
    fprintf(stderr,"can't allocate %ld bytes buffer\n",MAX_FILESIZE);
    return 2;
  }

  while ((c = getopt(argc, argv, "i:t:n:d:")) != -1)
  {
    switch(c)
    {
      case 'i':
	id = atoi(optarg);
	break;
      case 'n':
	strncpy(pkg_name, optarg, 32);
	pkg_name[31] = 0;
	break;
      case 'd':
	strncpy(pkg_descr, optarg, 32);
	pkg_descr[31] = 0;
	break;
      case 't':
	if (0==strcmp(optarg,"GEMRSC"))
          type = PKGTYPE_GEMRSC;
	else if (0==strcmp(optarg,"DESKRSC"))
          type = PKGTYPE_DESKRSC;
	else if (0==strcmp(optarg,"DESKRSC"))
          type = PKGTYPE_DESKRSC;
	else if (0==strcmp(optarg,"DESKINF"))
          type = PKGTYPE_DESKINF;
	else if (0==strcmp(optarg,"TOS"))
          type = PKGTYPE_TOS;
	else if (0==strcmp(optarg,"AUTOPRG"))
          type = PKGTYPE_AUTOPRG;
	else if (0==strcmp(optarg,"ACC"))
          type = PKGTYPE_ACC;
	else if (0==strcmp(optarg,"DESKICON"))
          type = PKGTYPE_DESKICON;
	else
	{
	  fprintf(stderr,"unknown type '%s'\n",optarg);
	  error=1;
	}
	break;
      default:
	fprintf(stderr,"unknown option %c\n",c);
	error=1;
	break;
    }
  }

  if (type == PKGTYPE_UNKNOWN)
  {
    fprintf(stderr,"a type for the package must be specified!\n");
    error=1;
  }
    
  if (optind < argc)
    strcpy(srcname,argv[optind++]);
  if (optind < argc)
    strcpy(dstname,argv[optind++]);
  
  if (strcmp(srcname,"-") == 0)
  {
    strcpy(srcname,"(stdin)");
    fpin = stdin;
  }
  else
  {
    fpin = fopen(srcname,"rb");
    if (fpin == 0)
    {
      fprintf(stderr,"can't open %s:",srcname);
      perror("");
      return 1;
    }
  }
  if (strcmp(dstname,"-") == 0)
  {
    strcpy(dstname,"(stdin)");
    fpout = stdout;
  }
  else
  {
    fpout = fopen(dstname,"wb");
    if (fpout == 0)
    {
      fprintf(stderr,"can't open %s:",dstname);
      perror("");
      return 1;
    }
  }

  if (error || fpin == 0 || fpout==0)
  {
    fprintf(stderr,"usage: %s [-i id] -t type -n name -d descr [infile] [outfile]\n"
	    "type may be: TOS GEMRSC DESKRSC DESKINF DESKICON AUTOPRG ACC\n",argv[0]);
    return 1;
  }

  if(pkg_name[0] == 0)
  {
    strncpy(pkg_name, srcname, 31);
    pkg_name[31] = 0;
  }
  orig_len = fread(buffer, 1, MAX_FILESIZE, fpin);
  if (orig_len == MAX_FILESIZE)
  {
    fprintf(stderr,"input file to big. Enlarge MAX_FILESIZE and recompile.\n");
    return 3;
  }
  if (orig_len == 0)
  {
    fprintf(stderr,"file read error on '%s'.\n",srcname);
    return 3;
  }
  fprintf(stderr,"Original size %ld bytes, ",orig_len);
  
  orig_crc = crc32buf(buffer, orig_len);
  fprintf(stderr,"CRC $%lX\n",orig_crc);
  
  compr_len = do_zip(buffer, orig_len);

  if (compr_len == 0)
  {
    fprintf(stderr,"error during compression!\n");
    return 4;
  }
  
  ptr = buffer;
  if(!check_method(&ptr))
  {
    fprintf(stderr,"%s is not a valid gzip'ed file!\n",srcname);
    return 1;
  }

  compr_len -= ptr-buffer;
  fprintf(stderr,"compressed size %ld bytes.\n",compr_len);

  compr_crc = crc32buf(ptr, compr_len);

  fputs("MPKG",fpout);			/* LONG magic */
  fputw(1, fpout);			/* WORD header_version */
  fputw(type, fpout);			/* WORD type */
  fputw(id, fpout);			/* WORD id */
  fputw(COMPR_GZIP, fpout);		/* WORD compr_type: 1=gzip */
  fputl(compr_len, fpout);		/* LONG pkg_data_len */
  fputl(compr_crc, fpout);		/* LONG compr_crc */
  fputl(orig_len, fpout);		/* LONG orig_len */
  fputl(orig_crc, fpout);		/* LONG orig_crc */
  fwrite(pkg_name, 1, 32, fpout);	/* char name[32] */
  fwrite(pkg_descr, 1, 32, fpout);	/* char descr[32] */

  fwrite(ptr, 1, compr_len, fpout);

  while(ftell(fpout) & 15)		/* fill to multiple of 16 bytes */
    fputc(0, fpout);

  free(buffer);
  if (fpin != stdin)
    fclose(fpin);
  if (fpout != stdout)
    fclose(fpout);
  return 0;
}
