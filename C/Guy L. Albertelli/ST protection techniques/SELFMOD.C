/* Sample XBIOS call from self modifying  */
/* code. Can do any XBIOS call including  */
/* floprd                                 */

int  device,sector,track,side,ret;
int  sector_buffer[256];

int  area[14],*p;  /* area for code */

int  (*q)();     /* pointer to sub */

make_trap()
{
/******** the code to construct for the trap subroutine *****************/
/**  move.l  (sp)+,hoho(pc) ***** ******* m68000 wont allow this ********/
/*   move.l  a1,-(sp)           * save a reg on the stack               */
/*                                      2F 09                           */
/*   lea     hoho(pc),a1        * get the program relative address      */
/*                                      43 FA 00 12                     */
/*   move.l  4(sp),(a1)         * save orig return addr in hoho         */
/*                                      22 AF 00 04                     */
/*   movea.l (sp)+,a1           * restore reg we destroyed              */
/*                                      22 5F                           */
/*   addq.l  #4,sp              * simulate taking return addr off       */
/*                                      58 8F                           */
/*   trap          #14          * *finally* do trap                     */
/*                                      4E 4E                           */
/*   move.l  hoho(pc),-(sp)     * restore return address                */
/*                                      2F 3A 00 04                     */
/*   rts                        * go home                               */
/*                                      4E 75                           */
/* hoho ds.l  1                         00 00 00 00                     */
/* therefore code must be                                               */
/* 2F09 43FA 0012 22AF 0004 225F 588F 4E4E 2F3A 0004 4E75 0000 0000     */
/************************************************************************/

     p = &area[0];   /* setup the pointers */
     q = p;

/* fill in area */
     area[0] = 0x2F09;
     area[1] = 0x43FA;
     area[2] = 0x0012;
     area[3] = 0x22AF;
     area[4] = 0x0004;
     area[5] = 0x225F;
     area[6] = 0x588F;
     area[7] = 0x0E0E;   /* note not real trap instruction yet */
     area[8] = 0x2F3A;
     area[9] = 0x0004;
     area[10] = 0x4E75;
     area[11] = 0;
     area[12] = 0;
   
/* construct the real trap instruction */
     area[7] += 0x4040;

/* now use XBIOS to read 1 sector - as documented for "floprd()" */
     device = 0;   sector = 2; track = 79; side = 0;

     ret = (*q)(8,sector_buffer,0L,device,sector,track,side,1);
    
     if (ret >= 0) {
          /* bad sector missing */
          /* have code here to abort program */
     }
}

