.
/* MITES.C     A Nasty Desk Accessory.  Give it to your frineds   */
/* Mites was written by SEAN PUCKETT using ALCYON (developers) C  */

#include <osbind.h>

int   contrl[12],intin[128],ptsin[128],intout[128],ptsout[128];
int   a1,dummy,handle,s_width,s_height,s_colors;
unsigned short   fast[128];
int   cx[20],cy[20],ch[20],cv[20],ptx[10];
int   dirx[]={ -1,-2,-2,-1,1,2,2,1 };
int   diry[]={ 2,1,-1,-2,-2,-1,1,2 };

main()
{
  appl_init();
  handle=graf_handle(&dummy,&dummy,&dummy,&dummy);
  for(a1=1; a1<10; ++a1)  intin[a1] = 1;
  intin[10] = 2;
  v_opnvwk(intin, &handle, intout);
  s_width=intout[0];
  s_height=intout[1];
  s_colors=intout[13];

  program();

  v_clsvwk(handle);
  appl_exit();
}

program()
{
  int  a1,a2,rnd,butb4,mousedn,mousex,mousey,pel,cdum,dx,dy,pcolor;

  mousedn=0;
  for( a1=0; a1<20; fast[a1++]=0 );
  while ( 1==1 ){
    evnt_timer(20,0);
    for( a1=0; a1<20; a1++ ){
      butb4=mousedn;
      vq_mouse(handle,&mousedn,&mousex,&mousey);
      dx=cx[a1];
      dy=cy[a1];
      if (( mousedn==1 )&&( butb4==0 )){
        for( a2=0; a2<20; a2++ ){
          if( fast[a2]==0 ){
            cx[a2]=mousex;
            cy[a2]=mousey;
            rnd=Random()/2091752;
            ch[a2]=dirx[rnd];
            cv[a2]=diry[rnd];
            fast[a2]=1;
            a2=200;
          }
        }
      }
      if( fast[a1]!=0 ){
        ptx[0]=dx;
        ptx[1]=dy;
        ptx[2]=dx;
        ptx[3]=dy;
        vsl_color(handle,0);
        v_pline(handle,2,ptx);
        dx=dx+ch[a1];
        dy=dy+cv[a1];
        if (( dx<0 )||( dx>s_width )||( dy<0 )||( dy>s_height)) fast[a1]=0;
        if ( fast[a1]!=0 ){
          v_get_pixel(handle,dx,dy,&pel,&cdum);
          if( pel!=0 ){
            rnd=Random()/2091752;
            ch[a1]=dirx[rnd];
            cv[a1]=diry[rnd];
          }
          ptx[0]=dx;
          ptx[1]=dy;
          ptx[2]=dx;
          ptx[3]=dy;
          vsl_color(handle,1);
          v_pline(handle,2,ptx);
        }
        cx[a1]=dx;
        cy[a1]=dy;
      }    
    }
  }
}


done