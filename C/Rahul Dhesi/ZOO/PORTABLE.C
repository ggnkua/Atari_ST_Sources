/* 
The contents of this file are hereby released to the public domain.
                                   -- Rahul Dhesi 1987/02/08
*/

typedef char BYTE;      /* MUST be an 8-bit value */

#include "func.h"
#include "zoo.h"

long to_long ();
int to_int ();
int b_to_zooh();
int b_to_dir();
int splitlong();
int splitint();

/**********************
to_long() converts four consecutive bytes, in order of increasing
significance, to a long integer.  It is used to make Zoo independent of the
byte order of the system.  
*/
long to_long(data)
BYTE data[];
{
   int i;
   long retval;
   retval = ((unsigned) data[2] & 0xff) | 
      (((unsigned) data[3] & 0xff) << 8);
   retval <<= 16;
   retval |= (((unsigned) data[0] & 0xff) | 
      (((unsigned) data[1] & 0xff) << 8));
   return (retval);
}

/**********************
to_int() converts two consecutive bytes, in order of increasing
significance, to an integer, in a machine-independent manner
*/
int to_int(data)
BYTE data[];
{
   return (int) (((unsigned) data[0] & 0xff) | 
      ((unsigned) (data[1] & 0xff) << 8));
}

/**********************
Function rd_zooh() reads a Zoo archive header in a machine-dependent manner,
from a file handle.
*/
int rd_zooh (header, zoo_han)
struct zoo_header *header;
int zoo_han;
{
   int status;
   BYTE bytes[SIZ_ZOOH];
   status = read (zoo_han, (char *) bytes, SIZ_ZOOH);
   b_to_zooh (header, bytes);
   return (status);
}

/**********************
Function rd_dir() reads a directory entry in a machine-independent manner
from a handle.
*/
int rd_dir(direntry, zoo_han)
struct direntry *direntry;
int zoo_han;
{
   int status;
   BYTE bytes[SIZ_DIR];
   status = read (zoo_han, (char *) bytes, SIZ_DIR);
   b_to_dir (direntry, bytes);
   return (status);
}

/***********************
b_to_zooh() converts an array of BYTE to a zoo_header structure.
*/
int b_to_zooh (zoo_header, bytes)
struct zoo_header *zoo_header;
BYTE bytes[];
{
   int i;
   for (i = 0; i < SIZ_TEXT; i++)
      zoo_header->text[i] = bytes[TEXT_I + i];
   zoo_header->lo_tag = to_int(&bytes[ZTAG_I]);
   zoo_header->hi_tag = to_int(&bytes[ZTAG_I+2]);
   /* zoo_header->zoo_tag = to_long(&bytes[ZTAG_I]); */
   zoo_header->zoo_start = to_long(&bytes[ZST_I]);
   zoo_header->zoo_minus = to_long(&bytes[ZSTM_I]);
   zoo_header->major_ver = bytes[MAJV_I];
   zoo_header->minor_ver = bytes[MINV_I];
}

/* b_to_dir() converts bytes to directory entry structure */
int b_to_dir(direntry, bytes)
struct direntry *direntry;
BYTE bytes[];
{
   int i;
   direntry->lo_tag = to_int(&bytes[DTAG_I]);
   direntry->hi_tag = to_int(&bytes[DTAG_I+2]);
   /* direntry->zoo_tag = to_long(&bytes[DTAG_I]); */
   direntry->type = bytes[DTYP_I];
   direntry->packing_method = bytes[PKM_I];
   direntry->next = to_long(&bytes[NXT_I]);
   direntry->offset = to_long(&bytes[OFS_I]);
   direntry->date = to_int(&bytes[DAT_I]);
   direntry->time = to_int(&bytes[TIM_I]);
   direntry->file_crc = to_int(&bytes[CRC_I]);
   direntry->org_size = to_long(&bytes[ORGS_I]);
   direntry->size_now = to_long(&bytes[SIZNOW_I]);
   direntry->major_ver = bytes[DMAJ_I];
   direntry->minor_ver = bytes[DMIN_I];
   direntry->deleted = bytes[DEL_I];
   direntry->comment = to_long(&bytes[CMT_I]);
   direntry->cmt_size = to_int(&bytes[CMTSIZ_I]);
   for (i = 0; i < FNM_SIZ; i++)
      direntry->fname[i] = bytes[FNAME_I + i];
}
