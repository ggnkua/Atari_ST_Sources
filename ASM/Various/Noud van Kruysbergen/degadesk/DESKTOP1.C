; **************************************************************************
; This is the source of DESKTOP.ACC, a program that changes the normal gray
; background with a Degas P?3 file. This source is public domain, but I
; would appreciate it very much if a program that uses (part) of this
; source respects the name of the author!
; **************************************************************************
; This source is written for Megamax C, with the inline assembly.
; **************************************************************************
; Noud van Kruysbergen
; N.I.C.I.
; P.O. Box 9104
; 6500 HE Nijmegen
; The Netherlands
; email: kruysbergen@hnykun53.bitnet
; **************************************************************************
#include <gemdefs.h>
#include <stdio.h>
#include <osbind.h>
#include <gembind.h>

int status=1;
int handle;
int menu_id,msgbf[8];
int i,j;
long l,picstart,bufcount,piccount;

static long _oldgem();
static long _newgem();

static int _style(),_interior(),_mode();
extern int gl_apid;
static long _buffer();
long buffer;

static int _clipx0(),_clipy0(),_clipx1(),_clipy1();
char path[50],file[14];
char t[70];

char newdta[44];

newroutines()
{
     asm
     {
                    dc.l      0x58425241
                    dc.l      0x4e5f4450
                    dc.l      0L

          _newgem:  cmpi.w    #115,D0
                    bne       gemquit
                    movem.l   D0-A3,-(A7)

                    move.l    D1,A0
                    move.l    (A0),A0
                    move.w    (A0),D0

                    cmpi.w    #114,D0
                    bne       nofill
                    lea       _interior,A0
                    move.w    (A0),D0
                    cmpi.w    #2,D0
                    bne       gemrest
                    lea       _style,A0
                    move.w    (A0),D0
                    cmpi.w    #4,D0
                    bne       gemrest

                    lea       _mode,A0
                    move.w    (A0),D0
                    beq       gemrest
                    move.l    D1,A0
                    move.l    8(A0),A0
                    move.w    (A0)+,D0
                    bne       gemrest
                    move.w    (A0)+,D0
                    cmpi.w    #19,D0
                    beq       menu
                    tst.w     D0
                    bne       gemrest
          menu:     move.w    (A0)+,D0
                    cmpi.w    #639,D0
                    bne       gemrest
                    move.w    (A0),D0
                    cmpi.w    #399,D0
                    bne       gemrest

                    move.l    0x44e,A1
; A1: screenadress
                    move.w    _clipy0,D0
                    move.w    D0,D2
; D2: y0
                    muls      #80,D0
                    adda.l    D0,A1
; A1: screenadress + y0 offset
                    lea       _buffer,A0
                    move.l    (A0),A0
; A0: pictureadress
                    adda.l    D0,A0
; A0: pictureadress + y0 offset
                    move.w    _clipy1,D0
                    sub.w     D2,D0
                    move.w    D0,D2
; D2: total number of lines
                    move.w    _clipx0,D3
; D3: x0
                    move.w    D3,D7
                    ext.l     D7
                    divs      #8,D7
                    move.w    D7,D3
                    adda.l    D3,A0
                    adda.l    D3,A1
; D3: x0/8
                    swap      D7
                    move.w    D7,D4
; D4: x0%8
                    move.w    _clipx1,D5
                    addq.w    #1,D5
; D5: x1
                    move.w    D5,D7
                    ext.l     D7
                    divs      #8,D7
                    move.w    D7,D5
; D5: x1/8
                    swap      D7
                    move.w    D7,D6
; D6: x1%8
                    move.l    D5,D0
                    sub.l     D3,D0
                    bne       label3

                    move.w    D6,D7
                    subi.w    #8,D7
                    neg.w     D7
                    move.b    #-1,D3
                    lsr.b     D7,D3
                    lsl.b     D7,D3
                    lsl.b     D4,D3
                    lsr.b     D4,D3
          loop2:    move.b    D3,D5
                    move.b    (A0),D7
                    and.b     D5,D7
                    not.b     D5
                    and.b     (A1),D5
                    add.b     D5,D7
                    move.b    D7,(A1)
                    adda.l    #80,A0
                    adda.l    #80,A1
                    dbf       D2,loop2
                    bra       selfok

          label3:   subq.w    #1,D0
                    tst.w     D4
                    seq       D5
                    beq       yloop
                    tst.w     D0
                    sne       D5
                    beq       yloop
                    subq.w    #1,D0
; first incomplete byte
          yloop:    move.l    A0,A2
                    move.l    A1,A3
                    tst.w     D4
                    beq       nostart
                    move.b    (A2)+,D3
                    move.b    #-1,D7
                    lsr.b     D4,D7
                    and.b     D7,D3
                    not.b     D7
                    and.b     (A3),D7
; D1 contains lowest picturebits, D7 highest backgroundbits
                    add.b     D3,D7
                    move.b    D7,(A3)+

          nostart:  move.w    D0,D7
                    tst.w     D5
                    beq       endbyte
          xloop:    move.b    (A2)+,(A3)+
                    dbf       D7,xloop
; last incomplete byte
          endbyte:  tst.w     D6
                    beq       no_end
                    move.b    (A2)+,D3
                    move.b    #-1,D7
                    lsr.b     D6,D7
                    not.b     D7
                    and.b     D7,D3
                    not.b     D7
                    and.b     (A3),D7
                    add.b     D3,D7
                    move.b    D7,(A3)

          no_end:   adda.l    #80,A0
                    adda.l    #80,A1
          label1:   dbf       D2,yloop

          selfok:   movem.l   (A7)+,D0-A3
                    rte

          nofill:   move.l    D1,A0
                    move.l    4(A0),A0
                    move.w    (A0),D2
                    cmpi.w    #23,D0
                    bne       nointerior
                    lea       _interior,A0
                    move.w    D2,(A0)
                    bra       gemrest

          nointerior:cmpi.w   #24,D0
                    bne       nostyle
                    lea       _style,A0
                    move.w    D2,(A0)
                    bra       gemrest

          nostyle:  cmpi.w    #129,D0
                    bne       gemrest
                    lea       _mode,A0
                    move.w    D2,(A0)
                    beq       gemrest
                    move.l    D1,A0
                    move.l    8(A0),A0
                    lea       _clipx0,A1
                    move.w    (A0)+,(A1)
                    lea       _clipy0,A1
                    move.w    (A0)+,(A1)
                    lea       _clipx1,A1
                    move.w    (A0)+,(A1)
                    lea       _clipy1,A1
                    move.w    (A0),(A1)

          gemrest:  movem.l   (A7)+,D0-A3
          gemquit:  move.l    _oldgem,-(A7)
                    rts

          _oldgem:  dc.l      0L
          _buffer:  dc.l      0L
          _style:   dc.w      0
          _interior:dc.w      0
          _mode:    dc.w      0
          _clipx0:  dc.w      0
          _clipy0:  dc.w      0
          _clipx1:  dc.w      0
          _clipy1:  dc.w      0
     }
}

Readfile()
{
     handle=-1;
     strcpy(t,path);
     j=0;
     while(t[j++]!='*' && j<70);
     if (j<70)
     {
          path[j]=0;
          t[--j]=0;
          strcat(path,".P?3");
          strcat(t,file);
          if ((handle=Fopen(t,0))>=0)
          {
               Fseek(34L,handle,0);
               j=strlen(file);
               if (file[--j]=='3' && file[--j]=='C')
               {
                    l=Fsetdta(newdta);
                    Fsfirst(t,0);
                    Fsetdta(l);
                    l=*(long *)(newdta+26);
                    if (piccount=picstart=Malloc(l))
                    {
                         l=Fread(handle,l,picstart);
                         bufcount=buffer;
                         do
                         {
                              asm
                              {
                                             move.l    piccount(A4),A0
                                             move.b    (A0),D0
                                             ext.w     D0
                                             and.w     #0xff,D0
                                             move.w    D0,j(A4)
                                             addq.l    #1,piccount(A4)
                              }
                              if (j<128)
                              {
                                   asm
                                   {
                                                  move.l    bufcount(A4),A2
                                                  move.l    piccount(A4),A1
                                                  move.w    j(A4),D0
                                        pic1loop: move.b    (A1)+,(A2)+
                                                  dbf       D0,pic1loop
                                                  move.l    A1,piccount(A4)
                                                  move.l    A2,bufcount(A4)
                                   }
                              }
                              else
                              {
                                   if (j!=128)
                                   {
                                        j^=255;
                                        asm
                                        {
                                                       move.l    bufcount(A4),A2
                                                       move.l    piccount(A4),A1
                                                       move.w    j(A4),D0
                                                       addq.w    #1,D0
                                             pic2loop: move.b    (A1),(A2)+
                                                       dbf       D0,pic2loop
                                                       addq.l    #1,piccount(A4)
                                                       move.l    A2,bufcount(A4)
                                        }
                                   }
                              }
                         }
                         while((piccount-picstart<l) && (bufcount-buffer<32000L));
                         Mfree(picstart);
                    }
                    else form_error(8);
               }
               else Fread(handle,32000L,buffer);
               Fclose(handle);
          }
     }
     return(handle);
}

Install()
{
          asm
          {
                         lea       _oldgem,A0
                         move.l    0x88,(A0)
                         lea       _newgem,A1
                         move.l    A1,0x88
                         move.l    (A0),-4(A1)
          }
}

main()
{
     appl_init();
     buffer=Malloc(32000L);
     asm
     {
                    lea       _buffer,A0
                    move.l    buffer(A4),(A0)
     }
     strcpy(t,"A:\\DESKTOP.P?3");
     strcpy(path,"A:\\*.P?3");
     t[file[0]=0]=path[0]=(char)(Dgetdrv()+65);
     Fsetdta(newdta);
     i=Fsfirst(t,0);
     if (!i)
     {
          strcpy(file,(char *)(newdta+30));
          if (Readfile()<0) status=file[0]=0;
          else Supexec(Install);
     }
     menu_id=menu_register(gl_apid,"  Desktop Picture");
     while ()
     {
          evnt_mesag(msgbf);
/*************************************************************
--- for version 2.01: include these lines ---
          if (status)
          {
               l=Super(0L);
               asm
               {
                              lea       _newgem,A1
                              cmpa.l    0x88,A1
                              beq       already
                              lea       _oldgem,A0
                              move.l    0x88,(A0)
                              move.l    A1,0x88
                              move.l    (A0),-4(A1)
                    already:
               }
               Super(l);
          }
***************************************************************/
          if (msgbf[0]==AC_OPEN && msgbf[4]==menu_id)
          {
               i=form_alert(3-status,"[2][| Desktop Picture 2.01|= Noud van Kruysbergen|][New| On |Off]");
               if (i!=3-status)
               {
                    wind_update(BEG_UPDATE);
                    form_dial(FMD_START,0,0,0,0,0,0,640,400);
                    if ((i==2 && file[0]==0) || i==1)
                    {
                         fsel_input(path,file,&j);
                         if (j && Readfile()<0)
                         {
                              form_error(2);
                              file[0]=0;
                         }
                    }
                    if (((i==2 && file[0]!=0) || i==3) && status!=(j=3-i))
                    {
                         if (status=j) Supexec(Install);
                         else
                         {
                              l=Super(0L);
                              asm
                              {
                                             lea       _oldgem,A0
                                             move.l    (A0),0x88
                              }
                              Super(l);
                         }
                    }
                    form_dial(FMD_FINISH,0,0,0,0,0,0,640,400);
                    wind_update(END_UPDATE);
               }
          }
     }
}

