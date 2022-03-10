/*  SEAlink - Sliding window file transfer protocol

    Version 1.16, created on 01/15/87 at 01:40:52

(C) COPYRIGHT 1986,87 by System Enhancement Associates; ALL RIGHTS RESERVED

    By:  Thom Henderson

    Description:

         This file contains a set of routines to illustrate the SEAlink
         sliding window file transfer protocol.  SEAlink is fully backward
         compatible to XMODEM, and can be easily adapted to most XMODEM
         variants.

         The intent of SEAlink is to provide a file transfer protocol that
         does not suffer from propagation delays, such as are introduced
         by satellite relays or packet switched networks.

    Instructions:

         Two routines are provided to implement SEAlink file transfers.

         int xmtfile(name)             /+ transmit a file +/
         char *name;                   /+ name of file to transmit +/

         This routine is used to send a file.  One file is sent at a time.
         If the name is blank (name is null or *name points to a null),
         then only an end of transmission marker is sent.

         This routine returns a one if the file is successfully
         transmitted, or a zero if a fatal error occurs.

         char *rcvfile(name)           /+ receive a file +/
         char *name;                   /+ name of file (optional) +/

         This routine is used to receive a file.  One file is received.
         The name, if given, takes precedence and will be the name of
         the resulting file.  If the name is blank (name is null or *name
         points to a null), then the name given by the transmitter is used.
         If the transmitter does not give a name, then the file transfer
         is aborted.

         This routine returns a pointer to the name of the file that
         was received.  If the file transfer is not successful, then
         a null pointer is returned.

         The pointer returned by rcvfile() points to a static data buffer.
         This does not have to be freed (and should not be), but it will
         be overwritten the next time rcvfile() is called.

         The rcvfile() function works on a temporary file whose name is
         the same as the final file, but with a dash ("-") added at the
         beginning.  If a file transfer is aborted, then this temporary
         file will be retained.  An aborted file transfer will not harm
         a pre-existing file of the same name.

    Programming notes:

         These routines can be used for either single or multiple file
         transfers.

         To send multiple files, send each one one at a time until either
         a transmit fails or all files are sent.  If all files are sent,
         then signal the end by calling xmtfile() with a null pointer.

         To receive multiple files, call rcvfile() repeatedly until it
         returns a null pointer.

         These routines pass a "block zero", which contains information
         about the original file name, size, and date/time of last
         modification.  If you cannot implement block zero, then you can
         leave it out.  If you cannot set any given field in block zero
         when transmitting, then you should leave it set to zeros.  If you
         cannot use any given field of block zero when receiving, then
         you should ignore it.

         These routines are fully compatible with XMODEM, including the
         original checksum method and later CRC adaptations.  It can be
         easily adapted to Modem7 protocol by adding a Modem7 filename
         transfer shell, though we do not recommend it.  The underlying
         logic, of course, can be adapted to almost any variant of XMODEM.

    License:

         You are granted a license to use this code in your programs, and
         to adapt it to your particular situation and needs, subject only
         to the following conditions:

         1)   You must refer to it as the SEAlink protocol, and you must
              give credit to System Enhancement Associates.

         2)   If you modify it in such a way that your version cannot
              converse with the original code as supplied by us, then
              you should refer to it as "SEAlink derived", or as a
              "variation of SEAlink", or words to that effect.

         In short, we're not asking for any money, but we'd like to
         get some credit for our work.

    Language:
         Computer Innovations Optimizing C86
*/
#include <stdio.h>
#include "fstat.h"
#include <time.h>

#define WINDOW 6                       /* maximum size of window */

struct zeros                           /* block zero data structure */
{   long flen;                         /* file length */
    long fstamp;                       /* file date/time stamp */
    char fnam[17];                     /* original file name */
    char prog[15];                     /* sending program name */
    char fill[88];                     /* reserved for future use */
}   ;

#define ACK 0x06
#define NAK 0x15
#define SOH 0x01
#define EOT 0x04

static int outblk;                     /* number of next block to send */
static int ackblk;                     /* number of last block ACKed */
static int blksnt;                     /* number of last block sent */
static int slide;                      /* true if sliding window */
static int ackst;                      /* ACK/NAK state */
static int numnak;                     /* number of sequential NAKs */
static int chktec;                     /* check type, 1=CRC, 0=checksum */
static int toterr;                     /* total number of errors */

char *progname = "Your name here";     /* name of sending program */

/*  File transmitter logic */

int xmtfile(name)                      /* transmit a file */
char *name;                            /* name of file to send */
{
    FILE *f, *fopen();                 /* file to send */
    long t1, timerset();               /* timers */
    int endblk;                        /* block number of EOT */
    struct filstat fst;                /* data about file */
    struct zeros zero;                 /* block zero data */

    if(name && *name)                  /* if sending a file */
    {    if(!(f=fopen(name,"rb")))
         {    printf("  Can't read %s\n",name);
              return 0;
         }

         setmem(&zero,sizeof(zero),0); /* clear out data block */

         filestat(name,&fst);          /* get file statistics */
         zero.flen = fst.fs_fsize;
         zero.fstamp = fst.fs_abs;
         strcpy(zero.fnam,fst.fs_fname);
         strcpy(zero.prog,progname);

         endblk = ((zero.flen+127)/128) + 1;
         printf("  Ready to send %d blocks of %s\n",endblk-1,zero.fnam);
    }
    else endblk = 0;                   /* fake for no file */

    outblk = 1;                        /* set starting state */
    ackblk = -1;
    blksnt = slide = ackst = numnak = toterr = 0;
    chktec = 2;                        /* undetermined */

    t1 = timerset(300);                /* time limit for first block */
    printf("  Waiting...\r");

    while(ackblk<endblk)               /* while not all there yet */
    {    if(!carrier())
         {    printf("\n  Lost carrier\n");
              goto abort;
         }
         if(key_scan()!=EOF)
         {    if((key_getc()&0xff)==27)
              {    printf("\n  Aborted by operator\n");
                   goto abort;
              }
         }
         if(timeup(t1))
         {    printf("\n  Fatal timeout\n");
              goto abort;
         }
         if(outblk <= ackblk + (slide? WINDOW : 1))
         {    if(outblk<endblk)
              {    if(outblk>0)
                        sendblk(f,outblk);
                   else shipblk(&zero,0);
                   printf(" Sending block #%d \r",outblk);
              }
              else if(outblk==endblk)
              {    com_putc(EOT);
                   printf(" Sent EOT           \r");
              }
              outblk++;
              t1 = timerset(300);      /* time limit between blocks */
         }

         ackchk();
         if(numnak>10)
         {    printf("\n  Too many errors\n");
              goto abort;
         }
    }

    printf(" End of file        \n");
    if(endblk)
         fclose(f);
    if(toterr>2)
         printf("  %d errors detected and fixed in %d blocks.\n",
              toterr,blksnt);
    return 1;                          /* exit with good status */

abort:
    if(endblk)
         fclose(f);
    if(toterr)
         printf("  %d errors detected and fixed in %d blocks.\n",
              toterr,blksnt);
    return 0;                          /* exit with bad status */
}

/*  The various ACK/NAK states are:
    0:   Ground state, ACK or NAK expected.
    1:   ACK received
    2:   NAK received
    3:   ACK, block# received
    4:   NAK, block# received
    5:   Returning to ground state
*/

static ackchk()                        /* check for ACK or NAK */
{
    int c;                             /* one byte of data */
    static int rawblk;                 /* raw block number */

    while((c=com_getc(0))!=EOF)
    {    if(ackst==3 || ackst==4)
         {    slide = 0;               /* assume this will fail */
              if(rawblk == (c^0xff))   /* see if we believe the number */
              {    rawblk = outblk - ((outblk-rawblk)&0xff);
                   if(rawblk >= 0 && rawblk<=outblk && rawblk>outblk-20)
                   {    slide = 1;     /* we have sliding window! */
                        if(ackst==3)
                             ackblk = ackblk>rawblk? ackblk : rawblk;
                        else
                        {    outblk = rawblk<0? 0 : rawblk;
                             com_dump();    /* purge pending output */
                        }
                        printf("\r  %s %d ==",ackst==3?"ACK":"NAK",rawblk);
                   }
              }
              ackst = 5;               /* return to ground state */
         }

         if(ackst==1 || ackst==2)
         {    rawblk = c;
              ackst += 2;
         }

         if(!slide || ackst==0)
         {    if(c==ACK)
              {    if(!slide)
                   {    ackblk++;
                        printf("\r  ACK %d --",ackblk);
                   }
                   ackst = 1;
                   numnak = 0;
              }

              else if(c=='C' || c==NAK)
              {    if(chktec>1)        /* if method not determined yet */
                        chktec = (c=='C');  /* then do what rcver wants */

                   if(!slide)
                   {    outblk = ackblk+1;
                        printf("\r  NAK %d --",ackblk+1);
                   }
                   ackst = 2;
                   numnak++;
                   if(blksnt) toterr++;
              }
         }

         if(ackst==5)
              ackst = 0;
    }
}

static sendblk(f,blknum)               /* send one block */
FILE *f;                               /* file to read from */
int blknum;                            /* block to send */
{
    long blkloc;                       /* address of start of block */
    char buf[128];                     /* one block of data */

    if(blknum != blksnt+1)             /* if jumping */
    {    blkloc = (long)(blknum-1) * 128L;
         fseek(f,blkloc,0);            /* move where to */
    }
    blksnt = blknum;

    setmem(buf,128,26);                /* fill buffer with control Zs */
    fread(buf,1,128,f);                /* read in some data */
    shipblk(buf,blknum);               /* pump it out the comm port */
}

static int shipblk(blk,blknum)         /* physically ship a block */
char *blk;                             /* data to be shipped */
int blknum;                            /* number of block */
{
    char *b = blk;                     /* data pointer */
    int crc = 0;                       /* CRC check value */
    int n;                             /* index */

    com_putc(SOH);                     /* block header */
    com_putc(blknum);                  /* block number */
    com_putc(blknum^0xff);             /* block number check value */

    for(n=0; n<128; n++)               /* ship the data */
    {    if(chktec)
              crc = crc_update(crc,*b);
         else crc += *b;
         com_putc(*b++);
    }

    if(chktec)                         /* send proper check value */
    {    crc = crc_finish(crc);
         com_putc(crc>>8);
         com_putc(crc&0xff);
    }
    else com_putc(crc);

    return 1;
}

/*  File receiver logic */

char *rcvfile(name)                    /* receive file */
char *name;                            /* name of file */
{
    int c;                             /* received character */
    int tries;                         /* retry counter */
    long t1, timerset();               /* timer */
    int blknum;                        /* desired block number */
    int inblk;                         /* this block number */
    FILE *f, *fopen();                 /* file, opener */
    char buf[128];                     /* data buffer */
    char tmpname[100];                 /* name of temporary file */
    static char outname[100];          /* name of final file */
    struct zeros zero;                 /* file header data storage */
    int endblk;                        /* block number of EOT, if known */
    long left;                         /* bytes left to output */
    int n;                             /* index */
    char *stat = "Init";               /* receive block status */
    char *getblock(), *why;            /* single block receiver, status */

    if(name && *name)                  /* figure out a name to use */
    {    strcpy(outname,name);
         strcpy(tmpname,"-"); strcat(tmpname,outname);
    }
    else
    {    *outname = '\0';
         strcpy(tmpname,"-TMPFILE.$$$");
    }

    if(!(f=fopen(tmpname,"wb")))       /* open output file */
    {    printf("  Cannot create %s",tmpname);
         return NULL;
    }

    blknum = *outname? 1 : 0;          /* first block we must get */
    tries = -10;                       /* kludge for first time around */
    chktec = 1;                        /* try for CRC error checking */
    toterr = 0;                        /* no errors yet */
    endblk = 0;                        /* we don't know the size yet */
    setmem(&zero,sizeof(zero),0);      /* or much of anything else */

nakblock:                              /* we got a bad block */
    if(blknum>1) toterr++;
    if(++tries>10)
    {    printf("\n  Too many errors\n");
         goto abort;
    }
    if(tries==0)                       /* if CRC isn't going */
         chktec = 0;                   /* then give checksum a try */

    sendack(0,blknum);                 /* send the NAK */
    printf("  NAK block %d %-5s\r",blknum,stat);
    goto nextblock;

ackblock:                              /* we got a good block */
    printf("  ACK block %d %-5s\r",blknum-1,stat);

nextblock:                             /* start of "get a block" */
    stat = "";
    if(!carrier())
    {    printf("\n  Lost carrier\n");
         goto abort;
    }
    if(key_scan()!=EOF)
    {    if((key_getc()&0xff)==27)
         {    printf("\n  Aborted by operator\n");
              goto abort;
         }
    }
    t1 = timerset(50);                 /* timer to start of block */
    while(!timeup(t1))
    {    c = com_getc(0);
         if(c==EOT)
         {    if(!endblk || endblk==blknum)
                   goto endrcv;
         }
         else if(c==SOH)
         {    inblk = com_getc(5);
              if(com_getc(5) == (inblk^0xff))
                   goto blockstart;    /* we found a start */
         }
    }
    stat = "Time";
    goto nakblock;

blockstart:                            /* start of block detected */
    c = blknum&0xff;
    if(inblk==0 && blknum<=1)          /* if this is the header */
    {    if(!(why=getblock(&zero)))
         {    sendack(1,inblk);        /* ack the header */
              if(!*name)               /* given name takes precedence */
                   strcpy(outname,zero.fnam);
              if(left=zero.flen)       /* length to transfer */
                   endblk = (left+127)/128 + 1;

              printf("  Receiving");
              if(endblk)
                   printf(" %d blocks of",endblk-1);
              printf(" %s",outname);
              if(*zero.prog)
                   printf(" from %s",zero.prog);
              printf("\n");
              blknum = 1;              /* now we want first data block */
              goto ackblock;
         }
         else
         {    stat = why;
              goto nakblock;           /* bad header block */
         }
    }
    else if(inblk==c)                  /* if this is the one we want */
    {    if(!(why=getblock(buf)))      /* else if we get it okay */
         {    sendack(1,inblk);        /* ack the data */
              for(n=0; n<128; n++)
              {    if(endblk)          /* limit file size if known */
                   {    if(!left)
                             break;
                        left--;
                   }
                   if(fputc(buf[n],f)==EOF)
                   {    printf("\n  Write error (disk full?)\n");
                        goto abort;
                   }
              }
              tries = 0;               /* reset try count */
              blknum++;                /* we want the next block */
              goto ackblock;
         }
         else
         {    stat = why;
              goto nakblock;           /* ask for a resend */
         }
    }
    else if(inblk<c || inblk>c+100)    /* else if resending what we have */
    {    getblock(buf);                /* ignore it */
         sendack(1,inblk);             /* but ack it */
         stat = "Dup";
         goto ackblock;
    }
    else goto nextblock;               /* else if running ahead */

endrcv:
    sendack(0,blknum);
    printf("  NAK EOT         \r");
    if(com_getc(20)!=EOT)
         goto nakblock;
    sendack(1,blknum);
    printf("  ACK EOT\r");

    if(blknum>1)                       /* if we really got anything */
    {    if(toterr>2)
              printf("  %d errors detected and fixed in %d blocks.\n",
                   toterr,blknum-1);
         if(zero.fstamp)               /* set stamp, if known */
              setstamp(f,zero.fstamp);
         fclose(f);
         unlink(outname);              /* rename temp to proper name */
         rename(tmpname,outname);
         return outname;               /* signal what file we got */
    }
    else                               /* else no real file */
    {    fclose(f);
         unlink(tmpname);              /* discard empty file */
         return NULL;                  /* signal end of transfer */
    }

abort:
    if(toterr)
         printf("  %d errors detected and fixed in %d blocks.\n",
              toterr,blknum-1);
    fclose(f);
    return NULL;
}

static sendack(acknak,blknum)          /* send an ACK or a NAK */
int acknak;                            /* 1=ACH, 0=NAK */
int blknum;                            /* block number */
{
    if(acknak)                         /* send the right signal */
         com_putc(ACK);
    else if(chktec)
         com_putc('C');
    else com_putc(NAK);

    com_putc(blknum);                  /* block number */
    com_putc(blknum^0xff);             /* block number check */
}

static char *getblock(buf)             /* read a block of data */
char *buf;                             /* data buffer */
{
    int ourcrc = 0, hiscrc;            /* CRC check values */
    int c;                             /* one byte of data */
    int n;                             /* index */

    for(n=0; n<128; n++)
    {    if((c=com_getc(5))==EOF)
              return "Short";

         if(chktec)
              ourcrc = crc_update(ourcrc,c);
         else ourcrc += c;
         *buf++ = c;
    }

    if(chktec)
    {    ourcrc = crc_finish(ourcrc);
         hiscrc = (com_getc(5)<<8) | com_getc(5);
    }
    else
    {    ourcrc &= 0xff;
         hiscrc = com_getc(5) & 0xff;
    }

    if(ourcrc == hiscrc)
         return NULL;                  /* block is good */
    else if(chktec)
         return "CRC";                 /* else CRC error */
    else return "Check";               /* or maybe checksum error */
}
