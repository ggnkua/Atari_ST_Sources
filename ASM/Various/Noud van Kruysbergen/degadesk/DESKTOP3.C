; **************************************************************************
; This is the source of DESKTOP.ACC, a program that changes the normal gray
; background with a Degas P?3 file. This source is public domain, but I
; would appreciate it very much if a program that uses (part) of this
; source respects the name of the author!
; **************************************************************************
; This source is written for Megamax C, with the inline assembly.
; **************************************************************************
; This program needs DESKTOP.PRG version 1.0.
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

int handle;
int menu_id,msgbf[8];
int i;

int clip[4]={0,0,639,399};

int contrl[12],intin[128],ptsin[128],intout[128],ptsout[128];
int work_out[57],work_in[11]={1,1,1,1,1,1,1,1,1,1,2};

extern int gl_apid;
extern long addr_out[2];

long picture=0L;
long l,picstart,bufcount,piccount;

char newdta[44];
char path[50],file[14];
char t[70];

main()
{
     appl_init();
     v_opnvwk(work_in,&handle,work_out);
     vs_clip(handle,-1,clip);
     if (*(long *)intout==0x4e5f4450) picture=*(long *)(intout+4);
     strcpy(path,"A:\\*.P?3");
     file[0]=0;
     path[0]=(char)(Dgetdrv()+65);
     menu_id=menu_register(gl_apid,"  Desktop Picture");
     while ()
     {
          evnt_mesag(msgbf);
          if (msgbf[0]==AC_OPEN && msgbf[4]==menu_id)
          {
               if (picture==0L) form_alert(1,"[3][DESKTOP 1.1 not resident][Cancel]");
               else
               {
                    i=form_alert(3,"[2][| Desktop Picture 2.03|(with DESKTOP.PRG 1.1)|= Noud van Kruysbergen|][P?3|Gray|Cancel]");
                    if (i<3)
                    {
                         wind_update(BEG_UPDATE);
                         form_dial(FMD_START,0,0,0,0,0,0,640,400);
                         if (i==1)
                         {
                              fsel_input(path,file,&i);
                              if (i)
                              {
                                   strcpy(t,path);
                                   i=0;
                                   while(t[i++]!='*' && i<70);
                                   if (i<70)
                                   {
                                        path[i]=0;
                                        t[--i]=0;
                                        strcat(path,".P?3");
                                        strcat(t,file);
                                        if ((handle=Fopen(t,0))>=0)
                                        {
                                             Fseek(34L,handle,0);
                                             i=strlen(file);
                                             if (file[i-2]=='C')
                                             {
                                                  l=Fsetdta(newdta);
                                                  Fsfirst(t,0);
                                                  Fsetdta(l);
                                                  l=*(long *)(newdta+26);
                                                  if (piccount=picstart=Malloc(l))
                                                  {
                                                       l=Fread(handle,l,picstart);
                                                       bufcount=picture;
                                                       do
                                                       {
                                                            asm
                                                            {
                                                                           move.l    piccount(A4),A0
                                                                           move.b    (A0),D0
                                                                           ext.w     D0
                                                                           and.w     #0xff,D0
                                                                           move.w    D0,i(A4)
                                                                           addq.l    #1,piccount(A4)
                                                            }
                                                            if (i<128)
                                                            {
                                                                 asm
                                                                 {
                                                                                move.l    bufcount(A4),A2
                                                                                move.l    piccount(A4),A1
                                                                                move.w    i(A4),D0
                                                                      pic1loop: move.b    (A1)+,(A2)+
                                                                                dbf       D0,pic1loop
                                                                                move.l    A1,piccount(A4)
                                                                                move.l    A2,bufcount(A4)
                                                                 }
                                                            }
                                                            else
                                                            {
                                                                 if (i!=128)
                                                                 {
                                                                      i^=255;
                                                                      asm
                                                                      {
                                                                                     move.l    bufcount(A4),A2
                                                                                     move.l    piccount(A4),A1
                                                                                     move.w    i(A4),D0
                                                                                     addq.w    #1,D0
                                                                           pic2loop: move.b    (A1),(A2)+
                                                                                     dbf       D0,pic2loop
                                                                                     addq.l    #1,piccount(A4)
                                                                                     move.l    A2,bufcount(A4)
                                                                      }
                                                                 }
                                                            }
                                                       }
                                                       while((piccount-picstart<l) && (bufcount-picture<32000L));
                                                       Mfree(picstart);
                                                  }
                                                  else form_error(8);
                                             }
                                             else Fread(handle,32000L,picture);
                                             Fclose(handle);
                                        }
                                        else
                                        {
                                             form_error(2);
                                             file[0]=0;
                                        }
                                   }
                              }
                         }
                         else
                         {
                              asm
                              {
                                             move.l    picture(A4),A0
                                             move.l    A0,A1
                                             move.w    #199,D1
                                   loop1:    adda.l    #80,A1
                                             move.w    #79,D0
                                   loop2:    move.b    #0x55,(A0)+
                                             move.b    #0xaa,(A1)+
                                             dbf       D0,loop2
                                             adda.l    #80,A0
                                             dbf       D1,loop1
                              }
                         }
                         form_dial(FMD_FINISH,0,0,0,0,0,0,640,400);
                         wind_update(END_UPDATE);
                    }
               }
          }
     }
}

