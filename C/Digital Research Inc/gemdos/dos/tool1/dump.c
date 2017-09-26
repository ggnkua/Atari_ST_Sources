/***********************************************************************
*
*                H E X   F I L E   D U M P   U T I L I T Y
*
*        Dump will display the contents of a file in Hexadecimal and
*        Ascii format.  The format of a line is:
*
* #### ## (######):  #### #### #### #### #### #### #### #### *................*
*  ^   ^     ^        ^    ^    ^    ^    ^    ^    ^    ^           ^
*  ^   ^     ^        ^    ^    ^    ^    ^    ^    ^    ^   Ascii values(byte)
*  ^   ^     ^              Hexadecimal Values(word)
*  ^   ^   Offset from begining of the file
*  ^  Sector offset
* Sector
*
*        The command line interface to dump contains one switch (-s) that
*        specifies the offset in the file that the file dump should start
*        at.  The command syntax is:
*
*             dump [-s########] <files> [-s########] <files> ...
*
*        This syntax allows the same syntax as in the old dump utility
*        on CP/M 68K but alows more flexibility.
*
*        Under Concurrent Dos, dump will read from standard input if
*        the standard input is not a tty device.  This alows programmers
*        to pipe their program's output to the dump utility to see the
*        output in hex format.
*
***********************************************************************/

#include <stdio.h>
#include <ctype.h>

#ifdef DOS4
#include <fcntl.h>
#endif

main(argc,argv)
int     argc;
char    **argv;
{
        long    startaddr;
        int     fd;                             /* File descriptor      */
        int     flags;
        long    decode();

#ifdef DOS4
            /* If Standard Input is not a tty device, then
               dump the Standard input file instead of the
               command line arguments */

        if (isatty(0) == 0) {
                /* Change the standard input file from an
                   ascii file to a binary file. */
            flags = fcntl( 0, F_GETFL );
            fcntl( 0, F_SETFL, (flags & ~O_ASCII) | O_BINARY );
            dumpfile( 0, 0l );
            return( 0 );
        }
#endif

        if(argc < 2)
                usage();

        startaddr= 0;                           /* Zero file address    */
        while( --argc ) {
            argv++;
            if((*argv)[0] == '-') {
                if ((*argv)[1] != 's')
                    usage();
                startaddr = decode((*argv)+2);
                continue;
            }

            if((fd=openb(*argv,0)) < 0) {
                printf("Unable to open \"%s\"\n",*argv);
                exit(FAILURE);
            }
            printf("\n--%s--\n", *argv);
            dumpfile( fd, startaddr );
            printf("\n*** E O F ***\n");
            close( fd );
        }
        return(SUCCESS);
}

dumpfile( fd, filaddr )
int fd;
long    filaddr;
{
        char    buffer[128];                    /* Sector buffer        */
        int     sector;                         /* Sector number        */
        int     offset;                         /* Sector Offset        */
        register i,j,k,l,m;                     /* Temps.               */
        int     nchr, nchars;

        sector = filaddr >> 7;                  /* Zero sector count    */
        filaddr &= ~15;                         /* Round request down   */
        if (filaddr)
            lseek(fd,filaddr,0);                /* Do the seek          */
        m = (128 - (filaddr & 127));            /* # bytes in sector    */
        while((nchr=read(fd,buffer,m)) > 0) /* Until EOF            */
        {
            l = (nchr + 15) / 16;               /* Number of lines      */
            offset = filaddr & 127;             /* Starting Offset      */
            for(i=0; i<l; i++)                  /* 8 lines / sector     */
            {
                   nchars = (nchr >= 16) ? 16 : nchr % 16;
                   printf("%04x %02x (%06lx): ",sector,offset,filaddr);
                   for(j=0; j<nchars; j++) {    /* 16 bytes / line      */
                       if ((j&1) == 0)
                           printf(" ");
                       printf("%02x",(buffer[i*16+j])&0xff);
                   }
                   for(j=nchars;j<16;j++) {
                        if((j&1) == 0)
                            printf(" ");
                        printf("  ");
                   }
                   printf(" *");
                   for(j=0; j<nchars; j++) {    /* Now ASCII            */
                        k = buffer[i*16+j] & 0x7f;
                        if ((k < ' ') || (k == 0x7f)) k= '.';
                        printf("%c",k);
                   }
                   printf("*\n");
                   filaddr += 16;               /* Bump up file address*/
                   offset  += 16;               /* and offset          */
                   nchr -= 16;
            }
            sector++;                           /* Increment sector count*/
            m = 128;                            /* # bytes to read next */
            for(j=0; j<128; j++)
                    buffer[j] = 0;
        }
}

usage()
{
        printf("Usage: dump [-shhhhhh] file\n");
        exit(FAILURE);
}

/****************************************************************************/
/*                                                                          */
/*                      D e c o d e    F u n c t i o n                      */
/*                      ------------------------------                      */
/*                                                                          */
/*      Routine "decode" is called to process the relocation base argument  */
/*      from the command line.                                              */
/*                                                                          */
/*      Calling sequence:                                                   */
/*                                                                          */
/*              ret = decode(string);                                       */
/*                                                                          */
/*      Where:                                                              */
/*              string   -> argument string (usually argv[1])               */
/*                                                                          */
/*              ret      =  Converted long value                            */
/*                       = -1 if anything amiss                             */
/*                                                                          */
/****************************************************************************/
long decode(string)
                                                /*                          */
REG     BYTE    *string;                        /* -> Command argument      */
{                                               /****************************/
REG     LONG    a;                              /* Temp return value        */
REG     BYTE    c;                              /* Temp character           */
                                                /*                          */
        a = 0;                                  /* Zero out accumulator     */
        while(*string)                          /* Until no more chars      */
        {                                       /*                          */
          c = toupper(*string) & 0177;          /* Pick up next char        */
          if (c >= '0' && c <= '9')             /* Digit                    */
                a = (a << 4) + c - '0';         /* Un-ASCIIfy               */
          else if (c >= 'A' && c <= 'F')        /* Hex                      */
                a = (a << 4) + c - 'A'+ 10;     /* Un-ASCIIfy               */
          else                                  /* Bad character            */
                return(FAILURE);                /* So long, sucker!!        */
          string++;                             /* Increment pointer        */
        }                                       /*                          */
        return(a);                              /* Return accumulator       */
}                                               /****************************/
