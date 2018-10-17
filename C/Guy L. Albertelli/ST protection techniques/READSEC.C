/* Sample XBIOS call to read a sector.    */
/*  Does a FLOPRD function.               */

int  device,sector,track,side,ret;
int  sector_buffer[256];

int
read_sector()
{
/*  called to read the disk key sector into the program.   */
/*    the disk key sector is assumed to be at              */
/*      side = 0                                           */
/*      track = 79        Last track                       */
/*      sector = 2        Second sector                    */
/*                                                         */

/* now use XBIOS to read 1 sector - as documented for "floprd()" */
     device = 0;   sector = 2; track = 79; side = 0;

     ret = Floprd(sector_buffer,0L,device,sector,track,side,1);
    
     if (ret >= 0) {
          /* bad sector missing */
          /* have code here to abort program */
     }
}

