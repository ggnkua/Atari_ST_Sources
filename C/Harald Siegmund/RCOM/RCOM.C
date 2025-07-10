/*TAB=3***CHAR=ATARI************************************************************
*
*  Project name : RESOURCE COMPILER
*  Module name  : Main module
*  Symbol prefix: -
*
*  Author       : Harald Siegmund (HS)
*  Co-Authors   : -
*  Write access : HS
*
*  Notes        : -
*-------------------------------------------------------------------------------
*  Things to do : -
*
*-------------------------------------------------------------------------------
*  History:
*
*  1990:
*     Apr 05: creation of file
*     Jul 17: 32K resource size boundary removed (this was a bug!)
*     Sep 12: RCOM now accepts resource files created by Kuma RCS
*     Oct 09: add some symbols to compiled resource files (used by
*             new RSC.C)
*  1991:
*     Feb 28: minor changes
*     Jun 06: ignore high byte of object types!
*  1993:
*     Aug 30: long resource header format
*             new file header
*             adding _DAY, _MONTH, _YEAR; changing messages
*
*******************************************************************************/
/*KEY _NAME="resource compiler" */
/*KEY _DAY=0x */
/*KEY _MONTH=0x */
/*KEY _YEAR=0x */
/*END*/


/**************************************************************************/
/*                                                                        */
/*                            INCLUDE FILES                               */
/*                                                                        */
/**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <tos.h>
#include <aes.h>


/**************************************************************************/
/*                                                                        */
/*                                MACROS                                  */
/*                                                                        */
/**************************************************************************/

#define _DAY         0x08           /* release date (hex!): */
#define _MONTH       0x02
#define _YEAR        0x1994


#define MAX_FSIZE    120            /* max size of filespec incl. terminator */
#define RELINFO      0x00050001L    /* 5:long relocation, 1:data segment */


/* this macro calculates the offset of a structure element to the start of
   the structure in bytes */

#define SOFF(type,label) ((ULONG)((char *)(&((type *)NULL)->label) - (char *)NULL))


#define TRUE      1                 /* boolean */
#define FALSE     0


/**************************************************************************/
/*                                                                        */
/*                          TYPE DEFINITIONS                              */
/*                                                                        */
/**************************************************************************/

typedef unsigned int UINT;          /* shortcuts */
typedef unsigned long ULONG;


typedef struct                      /* resource file header */
   {
   UINT     vrsn;                   /* version # (0) */
   UINT     object;                 /* offset to first OBJECT */
   UINT     tedinfo;                /* offset to first TEDINFO */
   UINT     iconblk;                /* offset to first ICONBLK */
   UINT     bitblk;                 /* offset to first BITBLK */
   UINT     frstr;                  /* offset to ULONG array of offsets to */
                                    /*  free strings */
   UINT     string;                 /* offset to first string */
   UINT     imdata;                 /* offset to base of image data */
   UINT     frimg;                  /* offset to ULONG array of offsets to */
                                    /*  free images */
   UINT     trindex;                /* offset to ULONG array of offsets to */
                                    /*  first OBJECT of trees */
   UINT     nobs;                   /* # of OBJECTs */
   UINT     ntree;                  /* # of trees */
   UINT     nted;                   /* # of TEDINFOs */
   UINT     nib;                    /* # of ICONBLKs */
   UINT     nbb;                    /* # of BITBLKs */
   UINT     nstring;                /* # of free strings */
   UINT     nimages;                /* # of free images */
   UINT     rssize;                 /* size of resource file */
   } RHDR;

/* any offset 0: data not available */


typedef struct                      /* resource file header (long format) */
   {
   ULONG    vrsn;                   /* version # */
   ULONG    object;                 /* offset to first OBJECT */
   ULONG    tedinfo;                /* offset to first TEDINFO */
   ULONG    iconblk;                /* offset to first ICONBLK */
   ULONG    bitblk;                 /* offset to first BITBLK */
   ULONG    frstr;                  /* offset to ULONG array of offsets to */
                                    /*  free strings */
   ULONG    string;                 /* offset to first string */
   ULONG    imdata;                 /* offset to base of image data */
   ULONG    frimg;                  /* offset to ULONG array of offsets to */
                                    /*  free images */
   ULONG    trindex;                /* offset to ULONG array of offsets to */
                                    /*  first OBJECT of trees */
   ULONG    nobs;                   /* # of OBJECTs */
   ULONG    ntree;                  /* # of trees */
   ULONG    nted;                   /* # of TEDINFOs */
   ULONG    nib;                    /* # of ICONBLKs */
   ULONG    nbb;                    /* # of BITBLKs */
   ULONG    nstring;                /* # of free strings */
   ULONG    nimages;                /* # of free images */
   ULONG    rssize;                 /* size of resource file */
   } LONGHDR;

/* any offset 0: data not available */


typedef struct                      /* object file header */
   {
   int      magic;                  /* magic word */
   ULONG    text_size;              /* size of text segment */
   ULONG    data_size;              /* size of data segment */
   ULONG    bss_size;               /* size of bss segment */
   ULONG    symb_size;              /* size of symbol table */
   long     resvd1;                 /* reserved */
   long     resvd2;                 /* reserved */
   int      resvd3;                 /* reserved */
   } OHDR;


typedef struct                      /* resource header component descriptor: */
   {
   long     srcoff;                 /* offset to UINT in short resource header*/
   long     dstoff;                 /* offset to ULONG in long resource header*/
   int      oflag;                  /* TRUE = this is a file offset */
   } HDDES;


/**************************************************************************/
/*                                                                        */
/*                          LOCAL PROTOTYPES                              */
/*                                                                        */
/**************************************************************************/

   /* display error message and abort process */
static void ms_error(char *cs,...);

   /* display error message "out of memory" and abort process */
static void ms_mfull(void);

   /* read bytes from file */
static void file_read(int fh,char *pfname,long size,void *p);

   /* write bytes to file */
static void file_write(int fh,char *pfname,long size,void *p);

   /* write symbol to object file */
static void write_symbol(char **pp,char *pname,long value);

   /* read resource header */
static void read_header(int fh,char *fspec,LONGHDR *hd,long *off);

   /* compile resource */
static void comp_rsc(char *pifile,char *pofile);



/*******************************************************************************
*                                                                              *
*                              INITIALIZED STATICS                             *
*                                                                              *
*******************************************************************************/

static HDDES convdes[] =            /* header component descriptors: */
   {
      {SOFF(RHDR,vrsn),SOFF(LONGHDR,vrsn),FALSE},
      {SOFF(RHDR,object),SOFF(LONGHDR,object),TRUE},
      {SOFF(RHDR,tedinfo),SOFF(LONGHDR,tedinfo),TRUE},
      {SOFF(RHDR,iconblk),SOFF(LONGHDR,iconblk),TRUE},
      {SOFF(RHDR,bitblk),SOFF(LONGHDR,bitblk),TRUE},
      {SOFF(RHDR,frstr),SOFF(LONGHDR,frstr),TRUE},
      {SOFF(RHDR,string),SOFF(LONGHDR,string),TRUE},
      {SOFF(RHDR,imdata),SOFF(LONGHDR,imdata),TRUE},
      {SOFF(RHDR,frimg),SOFF(LONGHDR,frimg),TRUE},
      {SOFF(RHDR,trindex),SOFF(LONGHDR,trindex),TRUE},
      {SOFF(RHDR,nobs),SOFF(LONGHDR,nobs),FALSE},
      {SOFF(RHDR,ntree),SOFF(LONGHDR,ntree),FALSE},
      {SOFF(RHDR,nted),SOFF(LONGHDR,nted),FALSE},
      {SOFF(RHDR,nib),SOFF(LONGHDR,nib),FALSE},
      {SOFF(RHDR,nbb),SOFF(LONGHDR,nbb),FALSE},
      {SOFF(RHDR,nstring),SOFF(LONGHDR,nstring),FALSE},
      {SOFF(RHDR,nimages),SOFF(LONGHDR,nimages),FALSE},
      {SOFF(RHDR,rssize),SOFF(LONGHDR,rssize),TRUE},
      {-1,-1,0}
   };


/**************************************************************************/
/*                                                                        */
/*                           LOCAL FUNCTIONS                              */
/*                                                                        */
/**************************************************************************/

/*******************************************************************************
*
*  ms_error: display error message and abort process
*
*  A message is printed in the form:
*  rcom: error: <cs>...
*
*  Then all open files are closed, allocated memory blocks are freed and the
*  process is terminated.
*
*  Out:
*     -
*
*******************************************************************************/

static void ms_error(

char        *cs,                    /* ^ to printf-like control string */
            ...)                    /* any parameters for printf() */
{

   va_list  arg;                    /* ^ to argument list for vprintf() */


   printf("\n\x07rcom: ERROR: ");   /* display message header */
   va_start(arg,cs);                /* init argument ^ */
   vprintf(cs,arg);                 /* print ... */
   va_end(arg);                     /* finished */

   exit(1);                         /* terminate */

}     /* ms_error() */


/*******************************************************************************
*
*  ms_mfull: display error message "out of memory" and abort process
*
*  The following message is printed:
*  rcom: error: out of memory
*
*  Then all open files are closed, allocated memory blocks are freed and the
*  process is terminated.
*
*  Out:
*     -
*
*******************************************************************************/

static void ms_mfull(void)
{

   ms_error("out of memory\n");

}     /* ms_mfull() */


/***************************************************************************
*
*  file_read: read data from file
*
*  Out:
*        -
*
***************************************************************************/

static void file_read(fh,pfname,size,p)

int         fh;                     /* file handle */
char        *pfname;                /* ^ to filename */
long        size;                   /* # of bytes to reade */
void        *p;                     /* ^ to buffer */
{

   long     n;                      /* # of read bytes/status */


   n = Fread(fh,size,p);            /* read! */
   if (n >= 0 && n != size)         /* not all bytes read? */
      n = -11;                      /* read fault */

   if (n < 0)                       /* error? */
      ms_error("can't read file %s (error code %d)\n",pfname,(int)n);

}     /* file_read() */




/***************************************************************************
*
*  file_write: write data into file
*
*  Out:
*        -
*
***************************************************************************/

static void file_write(fh,pfname,size,p)

int         fh;                     /* file handle */
char        *pfname;                /* ^ to filename */
long        size;                   /* # of bytes to write */
void        *p;                     /* ^ to data to write */
{

   long     n;                      /* # of written bytes/status */


   n = Fwrite(fh,size,p);           /* write! */
   if (n >= 0 && n != size)         /* not all bytes written */
      n = -10;                      /* write fault */

   if (n < 0)                       /* error? */
      ms_error("can't write file %s (error code %d)\n",pfname,(int)n);

}     /* file_write() */




/***************************************************************************
*
*  write_symbol: write symbol to object file
*
*  Out:
*        symbol data (14 bytes) in **pp
*        new destination ^ in *pp
*
***************************************************************************/

static void write_symbol(pp,pname,value)

char        **pp;                   /* ^ to ^ to destination buffer */
char        *pname;                 /* ^ to symbol name */
long        value;                  /* symbol value */
{     /* write_symbol() */

   char     *buf;                   /* ^ to output buffer */
   int      i;


   buf = *pp;                       /* get dst ^ */
   *pp += 14;                       /* advance ^ */

   for (i = 0; i < 14; buf[i++] = 0);  /* clear buffer */
   strcpy(buf,pname);                  /* put name in buffer */
   buf[8] = 0xa4;                      /* symbol type */
   *(long *)(buf + 10) = value;        /* value */

}     /* write_symbol() */




/*******************************************************************************
*
*  read_header: read resource header from resource file
*
*  The resource file header is read from the given (and opened) resource file
*  and written to *hd. The function supports short and long headers. It
*  returns always the long version of the resource header.
*
*  Note: the file pointer must be set to the beginning of the file.
*
*  Out:
*     resource header (always long version) in *hd
*     offset to add to relocation information in *off
*
*     file pointer set to location behind resource header
*
*******************************************************************************/

static void read_header(

int         fh,                     /* file handle */
char        *fspec,                 /* ^file specification */
LONGHDR     *hd,                    /* ^buffer for resource header */
long        *off)                   /* ^buffer for additional relocation */
                                    /*  offset */
{

   char     *src,*dst;              /* copy pointers for conversion */
   HDDES    *conv;                  /* ^conversion descriptors */
   ULONG    id;                     /* identification/version number */
   RHDR     shd;                    /* buffer for short file header */


   file_read(fh,fspec,sizeof(ULONG),&id);    /* read identification */
   id &= 0xffff0000UL;                       /* mask off version # */
   Fseek(0,fh,0);                            /* rewind file pointer */

   if (id == 0x30000UL)                      /* long format? */
      {
      *off = 0;                              /* no additional relocation */
      file_read(fh,fspec,sizeof(LONGHDR),hd);/* read complete header */
      }
   else                                      /* short header: */
      {
      *off = sizeof(LONGHDR) - sizeof(RHDR); /* relocation offset */

      if (id > 0x10000UL)                    /* illegal version #? */
         ms_error("%s: unknown version number (%d)\n",fspec,(int)(id >> 16));

      file_read(fh,fspec,sizeof(RHDR),&shd); /* read (short) file header */

      conv = convdes;                        /* ^conversion descriptors */
      src = (char *)&shd;                    /* ^source (short header) */
      dst = (char *)hd;                      /* ^destination (long header) */

      while (conv->srcoff >= 0)              /* while not end of table */
         {
         *(ULONG *)(dst + conv->dstoff) =                         /* write */
            (ULONG)*(UINT *)(src + conv->srcoff) +                /* read */
            (conv->oflag ? (sizeof(LONGHDR) - sizeof(RHDR)) : 0); /* size diff*/

         conv++;                             /* next entry */
         }
      }

}     /* read_header() */



/***************************************************************************
*
*  comp_rsc: compile resource
*
*  Out:
*        -
*
***************************************************************************/

static void comp_rsc(pifile,pofile)

char        *pifile;                /* ^ to input filename */
char        *pofile;                /* ^ to output filename */
{

   char     *pd,                    /* ^ to data segment in object file */
            *pr,                    /* ^ to relocation data in object file */
            *p;
   int      fh;                     /* file handle */
   long     reloff,                 /* additional relocation offset */
            osize;                  /* size of object file */
   ULONG    i,j;
   LONGHDR  rhd;                    /* resource header */
   OHDR     *po;                    /* ^ to object file buffer */
   OBJECT   *pobj;                  /* ^ to OBJECT array */


   fh = (int)Fopen(pifile,0);       /* open input file */
   if (fh < 0)                      /* error? abort */
      ms_error("can't open file %s (error code %d)\n",pifile,fh);

                                    /* read resource header */
   read_header(fh,pifile,&rhd,&reloff);

                                    /* allocate buffer */
   po = malloc(osize = sizeof(OHDR) + (ULONG)rhd.rssize * 2 + 8 * 14);
   if (!po)                         /* memory full? abort */
      ms_mfull();

   pd = (char *)(po + 1);           /* ^ to data segment */
   p = pd + rhd.rssize;             /* ^ to symbol table */
   pr = p + 8 * 14;                 /* ^ to relocation data */

   *(LONGHDR *)pd = rhd;            /* write resource header to buffer */
                                    /* read resource data */
   file_read(fh,pifile,rhd.rssize - sizeof(LONGHDR),pd + sizeof(LONGHDR));
   Fclose(fh);                      /* close input file */


                                    /* create symbol table */
   write_symbol(&p,"_RSCLHDR",0);
   write_symbol(&p,"_object",rhd.object);
   write_symbol(&p,"_tedinfo",rhd.tedinfo);
   write_symbol(&p,"_iconblk",rhd.iconblk);
   write_symbol(&p,"_bitblk",rhd.bitblk);
   write_symbol(&p,"_trindex",rhd.trindex);
   write_symbol(&p,"_frstr",rhd.frstr);
   write_symbol(&p,"_frimg",rhd.frimg);


                                    /* init relocation data */
   for (i = rhd.rssize; i; i--,*p++ = 0);


                                    /* init object file header */
   po->magic = 0x601a;              /* magic word */
   po->text_size = 0;               /* size of text segment */
   po->data_size = rhd.rssize;      /* size of data segment */
   po->bss_size = 0;                /* size of BSS */
   po->symb_size = 8 * 14;          /* size of symbol table */
   po->resvd1 = po->resvd2 = 0;     /* reserved */
   po->resvd3 = 0;


                                    /* ^ to first OBJECT */
   pobj = (OBJECT *)(pd + rhd.object);
                                    /* init offset to current ob_spec */
   j = rhd.object + SOFF(OBJECT,ob_spec);

                                    /* relocate OBJECTs */
   for (i = rhd.nobs; i; i--, j += sizeof(OBJECT), pobj++)
      switch (pobj->ob_type & 0xff) /* which type? */
         {
         case G_BOX:                /* non-relocatable objects? */
         case G_IBOX:
         case G_BOXCHAR:
            break;                  /* then do nothing */

         default:                   /* else relocate */
            *(long *)(pr + j) = RELINFO;
            *(long *)(pd + j) += reloff;
         }



                                    /* relocate TEDINFOs */
   for (i = rhd.nted, j = rhd.tedinfo; i; i--, j += sizeof(TEDINFO))
      {
      *(long *)(pr + SOFF(TEDINFO,te_ptext) + j) =
      *(long *)(pr + SOFF(TEDINFO,te_ptmplt) + j) =
      *(long *)(pr + SOFF(TEDINFO,te_pvalid) + j) = RELINFO;

      *(long *)(pd + SOFF(TEDINFO,te_ptext) + j) += reloff;
      *(long *)(pd + SOFF(TEDINFO,te_ptmplt) + j) += reloff;
      *(long *)(pd + SOFF(TEDINFO,te_pvalid) + j) += reloff;
      }



                                    /* relocate ICONBLKs */
   for (i = rhd.nib, j = rhd.iconblk; i; i--, j += sizeof(ICONBLK))
      {
      *(long *)(pr + j + SOFF(ICONBLK,ib_pmask)) =
      *(long *)(pr + j + SOFF(ICONBLK,ib_pdata)) =
      *(long *)(pr + j + SOFF(ICONBLK,ib_ptext)) = RELINFO;

      *(long *)(pd + j + SOFF(ICONBLK,ib_pmask)) += reloff;
      *(long *)(pd + j + SOFF(ICONBLK,ib_pdata)) += reloff;
      *(long *)(pd + j + SOFF(ICONBLK,ib_ptext)) += reloff;
      }


                                    /* relocate BITBLKs */
   for (i = rhd.nbb, j = rhd.bitblk; i; i--, j += sizeof(BITBLK))
      {
      *(long *)(pr + j + SOFF(BITBLK,bi_pdata)) = RELINFO;
      *(long *)(pd + j + SOFF(BITBLK,bi_pdata)) += reloff;
      }


                                    /* relocate free string offset table */
   for (i = rhd.nstring, j = rhd.frstr; i; i--, j += sizeof(long))
      {
      *(long *)(pr + j) = RELINFO;
      *(long *)(pd + j) += reloff;
      }


                                    /* relocate free image offset table */
   for (i = rhd.nimages, j = rhd.frimg; i; i--, j += sizeof(long))
      {
      *(long *)(pr + j) = RELINFO;
      *(long *)(pd + j) += reloff;
      }


                                    /* relocate tree index table */
   for (i = rhd.ntree, j = rhd.trindex; i; i--, j += sizeof(long))
      {
      *(long *)(pr + j) = RELINFO;
      *(long *)(pd + j) += reloff;
      }



   fh = (int)Fcreate(pofile,0);     /* create output file */

   if (fh < 0)                      /* error? abort */
      ms_error("can't create file %s (error code %d)\n",pofile,fh);

   file_write(fh,pofile,osize,po);  /* write file */
   Fclose(fh);                      /* close it */

}     /* comp_rsc() */


/*START*/
/***************************************************************************
*
*  main: application entry point
*
*  Out:
*     application exit status:
*     0                 ok
*     !=0               error
*
***************************************************************************/

int main(argc,argv)

int         argc;
char        *argv[];
{     /* main() */
/*END*/

   char     ofile[MAX_FSIZE],       /* buffer for input filename */
            *p;


   if (argc < 2 || argc > 3)        /* wrong # of arguments? */
      {
      printf(

      "GEM RESOURCE COMPILER                           Release %02x.%02x.%02x\n"
      "Written by Harald Siegmund                      Copyright (c) 1990-%x\n"
      "\n"
      "usage: rcom resource_file [object_file]\n"
      "\n"
      "       default for object_file: resource filename with extension .o\n"

      , _DAY, _MONTH, _YEAR & 0xff, _YEAR);

      return 1;
      }

   if (argc == 2)                   /* no output filename? */
      {
      strcpy(ofile,argv[1]);        /* copy input filename */
      p = strrchr(ofile,'.');       /* search extension */
      if (p > strrchr(ofile,'\\'))  /* if not extension of folder */
         *p = '\0';                 /* then cut it */
      strcat(ofile,".o");           /* add object file extension */
      }
   else strcpy(ofile,argv[2]);      /* copy output filename to buffer */

   comp_rsc(argv[1],ofile);         /* compile */

   return 0;                        /* that's it */

}     /* main() */


/*EOF*/
