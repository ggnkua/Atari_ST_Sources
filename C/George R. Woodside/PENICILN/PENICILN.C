/****************************************************************************/
/*                                                                          */
/* Module:     peniciln.c                                                   */
/*                                                                          */
/* Function:   Remove any possible virus programs from boot sector          */
/*                                                                          */
/* Programmer: George R. Woodside                                           */
/*                                                                          */
/* Date:       March 27, 1988                                               */
/*                                                                          */
/****************************************************************************/

/****************************************************************************/
/* INCLUDE FILES                                                            */
/****************************************************************************/

#include <stdio.h>
#include <osbind.h>

#define  SECSIZE          512           /* floppy sector size               */

int  msflag = 0;                        /* not doing MS-DOS boot sector     */
int  kflag = 0;                         /* keyboard loop flag               */

unsigned  char  ibuf[SECSIZE];          /* input boot sector buffer         */
unsigned  char  obuf[SECSIZE];          /* output boot sector buffer        */
unsigned  char  mbuf[SECSIZE] =         /* MS-DOS boot sector buffer        */
{
  0xEB, 0x34, 0x90, 0x49, 0x42, 0x4D, 0x20, 0x20, 0x33, 0x2E, 0x32, 0x00, 0x02,
  0x02, 0x01, 0x00, 0x02, 0x70, 0x00, 0xA0, 0x05, 0xF9, 0x03, 0x00, 0x09, 0x00,
  0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0F, 0x00, 0x00, 0x00, 0x00,
  0x01, 0x00, 0xFA, 0x33, 0xC0, 0x8E, 0xD0, 0xBC, 0x00, 0x7C, 0x16, 0x07, 0xBB,
  0x78, 0x00, 0x36, 0xC5, 0x37, 0x1E, 0x56, 0x16, 0x53, 0xBF, 0x2B, 0x7C, 0xB9,
  0x0B, 0x00, 0xFC, 0xAC, 0x26, 0x80, 0x3D, 0x00, 0x74, 0x03, 0x26, 0x8A, 0x05,
  0xAA, 0x8A, 0xC4, 0xE2, 0xF1, 0x06, 0x1F, 0x89, 0x47, 0x02, 0xC7, 0x07, 0x2B,
  0x7C, 0xFB, 0xCD, 0x13, 0x72, 0x67, 0xA0, 0x10, 0x7C, 0x98, 0xF7, 0x26, 0x16,
  0x7C, 0x03, 0x06, 0x1C, 0x7C, 0x03, 0x06, 0x0E, 0x7C, 0xA3, 0x3F, 0x7C, 0xA3,
  0x37, 0x7C, 0xB8, 0x20, 0x00, 0xF7, 0x26, 0x11, 0x7C, 0x8B, 0x1E, 0x0B, 0x7C,
  0x03, 0xC3, 0x48, 0xF7, 0xF3, 0x01, 0x06, 0x37, 0x7C, 0xBB, 0x00, 0x05, 0xA1,
  0x3F, 0x7C, 0xE8, 0x96, 0x00, 0xB8, 0x01, 0x02, 0xE8, 0xAA, 0x00, 0x72, 0x19,
  0x8B, 0xFB, 0xB9, 0x0B, 0x00, 0xBE, 0xCD, 0x7D, 0xF3, 0xA6, 0x75, 0x0D, 0x8D,
  0x7F, 0x20, 0xBE, 0xD8, 0x7D, 0xB9, 0x0B, 0x00, 0xF3, 0xA6, 0x74, 0x18, 0xBE,
  0x6E, 0x7D, 0xE8, 0x61, 0x00, 0x32, 0xE4, 0xCD, 0x16, 0x5E, 0x1F, 0x8F, 0x04,
  0x8F, 0x44, 0x02, 0xCD, 0x19, 0xBE, 0xB7, 0x7D, 0xEB, 0xEB, 0xA1, 0x1C, 0x05,
  0x33, 0xD2, 0xF7, 0x36, 0x0B, 0x7C, 0xFE, 0xC0, 0xA2, 0x3C, 0x7C, 0xA1, 0x37,
  0x7C, 0xA3, 0x3D, 0x7C, 0xBB, 0x00, 0x07, 0xA1, 0x37, 0x7C, 0xE8, 0x40, 0x00,
  0xA1, 0x18, 0x7C, 0x2A, 0x06, 0x3B, 0x7C, 0x40, 0x50, 0xE8, 0x4E, 0x00, 0x58,
  0x72, 0xCF, 0x28, 0x06, 0x3C, 0x7C, 0x76, 0x0C, 0x01, 0x06, 0x37, 0x7C, 0xF7,
  0x26, 0x0B, 0x7C, 0x03, 0xD8, 0xEB, 0xD9, 0x8A, 0x2E, 0x15, 0x7C, 0x8A, 0x16,
  0xFD, 0x7D, 0x8B, 0x1E, 0x3D, 0x7C, 0xEA, 0x00, 0x00, 0x70, 0x00, 0xAC, 0x0A,
  0xC0, 0x74, 0x22, 0xB4, 0x0E, 0xBB, 0x07, 0x00, 0xCD, 0x10, 0xEB, 0xF2, 0x33,
  0xD2, 0xF7, 0x36, 0x18, 0x7C, 0xFE, 0xC2, 0x88, 0x16, 0x3B, 0x7C, 0x33, 0xD2,
  0xF7, 0x36, 0x1A, 0x7C, 0x88, 0x16, 0x2A, 0x7C, 0xA3, 0x39, 0x7C, 0xC3, 0xB4,
  0x02, 0x8B, 0x16, 0x39, 0x7C, 0xB1, 0x06, 0xD2, 0xE6, 0x0A, 0x36, 0x3B, 0x7C,
  0x8B, 0xCA, 0x86, 0xE9, 0x8A, 0x16, 0xFD, 0x7D, 0x8A, 0x36, 0x2A, 0x7C, 0xCD,
  0x13, 0xC3, 0x0D, 0x0A, 0x4E, 0x6F, 0x6E, 0x2D, 0x53, 0x79, 0x73, 0x74, 0x65,
  0x6D, 0x20, 0x64, 0x69, 0x73, 0x6B, 0x20, 0x6F, 0x72, 0x20, 0x64, 0x69, 0x73,
  0x6B, 0x20, 0x65, 0x72, 0x72, 0x6F, 0x72, 0x0D, 0x0A, 0x52, 0x65, 0x70, 0x6C,
  0x61, 0x63, 0x65, 0x20, 0x61, 0x6E, 0x64, 0x20, 0x73, 0x74, 0x72, 0x69, 0x6B,
  0x65, 0x20, 0x61, 0x6E, 0x79, 0x20, 0x6B, 0x65, 0x79, 0x20, 0x77, 0x68, 0x65,
  0x6E, 0x20, 0x72, 0x65, 0x61, 0x64, 0x79, 0x0D, 0x0A, 0x00, 0x0D, 0x0A, 0x44,
  0x69, 0x73, 0x6B, 0x20, 0x42, 0x6F, 0x6F, 0x74, 0x20, 0x66, 0x61, 0x69, 0x6C,
  0x75, 0x72, 0x65, 0x0D, 0x0A, 0x00, 0x49, 0x42, 0x4D, 0x42, 0x49, 0x4F, 0x20,
  0x20, 0x43, 0x4F, 0x4D, 0x49, 0x42, 0x4D, 0x44, 0x4F, 0x53, 0x20, 0x20, 0x43,
  0x4F, 0x4D, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x55, 0xAA
};                                      /* end MS-DOS boot sector buffer    */

/****************************************************************************/
/* Check the command line for the drive to disinfect                        */
/****************************************************************************/
main(argc,argv)
int    argc;                            /* argument count                   */
char  *argv[];                          /* argument pointers                */
{
  register  int    arg;                 /* current argument                 */
  register  int    i;                   /* byte counter                     */
  register  char  *bptr;                /* buffer pointer                   */
  register  char  *drive;               /* drive to clean up                */

  if(argc < 2)                          /* if no arguments                  */
    {
      printf("Usage: peniciln [-km] drive {drive}\n"); /* simple usage      */
      printf("                 -k   Keyboard mode\n"); /* option k          */
      printf("                 -m   MS-DOS boot sector\n"); /* option m     */
      exit(0);                          /* exit without error               */
    }                                   /* end no arguments                 */

  bptr = obuf;                          /* point to normal output buffer    */
  for(i = 0; i < SECSIZE; i++)          /* full buffer size                 */
    *bptr++ = 0x00;                     /* clear the output buffer          */

  for(arg = 1; arg < argc; arg++)       /* for each request                 */
    {
      drive = argv[arg];                /* get the pointer                  */
      if(*drive == '-')                 /* if a leading dash                */
        drive++;                        /* skip it                          */

      switch(*drive)                    /* check the input                  */
        {
          case 'a':                     /* drive a                          */
          case 'A':
            clean_boot(0);              /* clean up drive a                 */
            break;

          case 'b':                     /* drive b                          */
          case 'B':
            clean_boot(1);              /* clean up drive b                 */
            break;

          case 'k':                     /* keyboard loop mode               */
          case 'K':
            kflag = 1;                  /* set keyboard loop mode           */
            break;

          case 'm':                     /* set MS-DOS flag                  */
          case 'M':
            msflag = 1;                 /* set MS-DOS boot sector           */
            break;

          default:
            printf("peniciln: invalid request %c\n",*drive); /* report error */
            break;
        }                               /* end switch                       */
    }                                   /* end for                          */

  if(kflag)                             /* if entering keyboard mode        */
    {
      printf("Press 'a' or 'b' to clean disk in that drive,\n"); /* prompt  */
      printf("or any other key to exit.\n"); /* and explain exit            */
    }                                   /* end keyboard prompt              */

  while(kflag)                          /* as long as in keyboard mode      */
    {
      switch ((int)Crawcin())           /* read a key                       */
        {
          case 'a':                     /* drive a                          */
          case 'A':
            clean_boot(0);              /* clean up drive a                 */
            break;

          case 'b':                     /* drive b                          */
          case 'B':
            clean_boot(1);              /* clean up drive b                 */
            break;

          default:
            kflag = 0;                  /* exit keyboard loop mode          */
            break;

        }                               /* end keyboard switch              */
    }                                   /* end keyboard mode                */

  return(0);                            /* exit without error               */
}                                       /* end main                         */

/****************************************************************************/
/* Clean up the boot sector data                                            */
/****************************************************************************/
clean_boot(dno)
int    dno;                             /* drive number                     */
{
  register  long   reply;               /* I/O reply                        */
  register  int    csum;                /* checksum value                   */
  register  char  *fptr;                /* copy from here                   */
  register  char  *tptr;                /* copy to here                     */
  register  char  *eptr;                /* stop copy here                   */

  Getbpb(dno);                          /* clear media change               */
  reply = Rwabs(0,ibuf,1,0,dno);        /* try the read                     */

  if(reply)                             /* if a read error                  */
    {
      printf("peniciln: read error %ld\n",reply); /* display error code     */
      return;                           /* punt                             */
    }                                   /* end bad read                     */

  if(msflag)                            /* if writing MS-DOS boot           */
    {
      fptr = ibuf + 11L;                /* start at bytes per sector        */
      tptr = mbuf + 11L;                /* to MS-DOS prototype              */
    }                                   /* end MS-DOS boot                  */
  else                                  /* normal boot sector               */
    {
      fptr = ibuf + 8L;                 /* start at serial number           */
      tptr = obuf + 8L;                 /* to empty buffer                  */
    }                                   /* end clean boot sector            */

  eptr = ibuf + 30L;                    /* stop here                        */

  while(fptr != eptr)                   /* up to the last byte we need      */
    *tptr++ = *fptr++;                  /* copy the configuration data      */

  if(msflag)                            /* if writing MS-DOS boot           */
    reply = Rwabs(1,mbuf,1,0,dno);      /* write it                         */
  else                                  /* a clean boot sector              */
    {
      csum = chksum(obuf);              /* get buffer checksum              */
      csum = csum ^ 0xffff;             /* get 1's complement               */
      obuf[510] = (char)(csum >> 8);    /* set high byte                    */
      obuf[511] = (char)(csum & 0xff);  /* set low byte                     */
      reply = Rwabs(1,obuf,1,0,dno);    /* write it                         */
    }                                   /* end non-MS-DOS boot sector       */

  if(reply)                             /* if a read error                  */
    {
      printf("peniciln: write error %ld  ",reply); /* display error code    */
      if(reply == -13L)                 /* may be write protected           */
        printf("(Write Protected)");    /* yep, it was                      */
      printf("\n");                     /* insure we print                  */
    }                                   /* end bad write                    */
}                                       /* end clean boot                   */

/****************************************************************************/
/* Compute checksum of a buffer                                             */
/****************************************************************************/
chksum(bptr)
register  int  *bptr;                   /* buffer address                   */
{
  register  int  sum   = 0;             /* accumulated checksum             */
  register  int  count = (512 / sizeof(int)) - 1; /* ints in buffer less 1  */

  while(count--)                        /* for full buffer                  */
    sum += *bptr++;                     /* add up the data                  */

  return(sum);                          /* give back checksum               */
}                                       /* end checksum buffer              */
