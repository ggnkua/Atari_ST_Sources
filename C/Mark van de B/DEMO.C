#include <osbind.h>
#include <algol.h>
#define NEWLINE Cconout(10);Cconout(13)

int contrl[12],
    intin[128],
    ptsin[128],
    intout[128],
    ptsout[128];
int handle1,handle2;
int work_out[57],
    work_in[12];
int i,x,y;

open_work()
{ int i;
  appl_init();
  for(i=0;i<10;work_in[i++]=1);
  work_in[10]=2;
  v_opnvwk(work_in,&handle1,work_out);
}

close_work()
{ Cconin();
  v_clsvwk(handle1);
  appl_exit();
}

main()
{ open_work();
  vswr_mode(handle1,1); /* replace mode */
  v_clrwk(handle1); /* scherm schoonmaken */
/*
  ptsin[0]=40;
  ptsin[1]=35;
  ptsin[2]=200;
  ptsin[3]=200;
  vs_clip(handle1,1,ptsin);
*/
  vsl_type(handle1,1); /* ononderbroken lijn */
  ptsin[0]=20;
  ptsin[1]=30;
  ptsin[2]=200;
  ptsin[3]=300;  
  ptsin[4]=300;
  ptsin[5]=120;
  ptsin[6]=20;
  ptsin[7]=30;
  v_pline(handle1,4,ptsin); /* driehoek tekenen */
  v_contourfill(handle1,1,1,1); /* omtrek met zwart vullen */
  Cconin();
  v_clrwk(handle1);
  vsm_type(handle1,1); /* punt */
  vsm_color(handle1,1); /* zwarte polymarker */
  i=1;
  WHILE i!=7
  DO ptsin[0]=(((unsigned int)(Random()))%640);
     ptsin[1]=(((unsigned int)(Random()))%400);
     v_pmarker(handle1,1,ptsin);
     IF Crawio(0xff)!=0
     THEN v_clrwk(handle1);
          vsm_type(handle1,++i)
     FI
  OD
  Cconin();
  v_clrwk(handle1);
  vsf_interior(handle1,2); /* fill-style */
  vsf_style(handle1,20); /* fill-pattern */
  vsf_color(handle1,1); /* black as night */
  vsf_perimeter(handle1,0);
  for(i=0;i<=3600;i+=30) v_pieslice(handle1,319,199,150,0,i);
  Cconin();
  v_clrwk(handle1);
  vsf_interior(handle1,0);
  vsf_perimeter(handle1,1);
  for(x=5,y=150;y!=5;x+=5,y-=5) v_ellipse(handle1,319,199,x,y);
  close_work();
}

