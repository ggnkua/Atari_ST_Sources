/*----------------------------*/
/* kinetic lines              */
/* ST Application Programming */
/*----------------------------*/

#include <gem.h>
#include <stdio.h>
#include <obdefs.h>
#include <osbind.h>

#define WORD int

WORD p_handle,
     v_handle,
     scrn_rez,    
     col_scrn,
     y_max,
     x_max,
     msgbuff[8];

WORD contrl[12],
     intin[128],
     ptsin[128],
     intout[128],
     ptsout[128];

int x_lower,
    y_lower,
    x_upper,
    y_upper;

/*----------------------------------------------*/

open_vwork(phys_handle)
WORD phys_handle;
{
WORD work_in[11],
     work_out[57],
     new_handle;
int i;

    for(i=0;i<10;i++)
         work_in[i]=1;
    work_in[10]=2;
    new_handle=phys_handle;
    v_opnvwk(work_in,&new_handle,work_out);
    v_clrwk(new_handle);
    return(new_handle);
}
/*---------------------------------------------*/
set_scrn_attr()
{
WORD work_out[57];

    vq_extnd(v_handle,0,work_out);
    x_max=work_out[0];
    y_max=work_out[1];
    scrn_rez=Getrez();
    col_scrn=(scrn_rez < 2);
}
/*---------------------------------------------*/
rnd_rng(low,hi)
int low,hi;
{
 int rnd_wrk;
  hi++;
  rnd_wrk=Random()&0x7FFF;
  return( rnd_wrk%(hi-low)+low);
}
/*---------------------------------------------*/
inchk(x,dx,lb,ub)
WORD x,dx,lb,ub;
{
  if(x+dx <= lb || x+dx >= ub )
      dx*=-1;
  return(dx);
}
/*---------------------------------------------*/
draw_frame()
{
WORD pts[4];

  pts[0]=x_lower;
  pts[1]=y_lower;
  pts[2]=x_upper;
  pts[3]=y_upper;
  v_rbox(v_handle,pts);
}
/*----------------------------------------------*/
draw_lines()
{
int line_number,
    k;

WORD px1,py1,
     px2,py2,
     pdx1,pdx2,
     pdy1,pdy2;

WORD rx1,ry1,
     rx2,ry2,
     rdx1,rdx2,
     rdy1,rdy2;

WORD pxy[100],rxy[100];

do
{
     v_clrwk(v_handle);
     draw_frame();

     px1=rnd_rng(x_lower,x_upper);
     py1=rnd_rng(y_lower,y_upper);
     px2=rnd_rng(x_lower,x_upper);
     py2=rnd_rng(y_lower,y_upper);

     pdx1=rnd_rng(-10,10);
     pdy1=rnd_rng(-10,10);
     pdx2=rnd_rng(-10,10);
     pdy2=rnd_rng(-10,10);

     rx1=rnd_rng(x_lower,x_upper);
     ry1=rnd_rng(y_lower,y_upper);
     rx2=rnd_rng(x_lower,x_upper);
     ry2=rnd_rng(y_lower,y_upper);

     rdx1=rnd_rng(-10,10);
     rdy1=rnd_rng(-10,10);
     rdx2=rnd_rng(-10,10);
     rdy2=rnd_rng(-10,10);

     for( k=0; k<100; k++)
          pxy[k]=rxy[k]=0;
     vsl_color(v_handle,BLACK);

     do
     {
          rxy[96]=rx1; rxy[97]=ry1;
          rxy[98]=rx2; rxy[99]=ry2;
          pxy[96]=px1; pxy[97]=py1;
          pxy[98]=px2; pxy[99]=py2;
          v_pline(v_handle,2,&pxy[96]);
          v_pline(v_handle,2,&rxy[96]);
          v_pline(v_handle,2,pxy);
          v_pline(v_handle,2,rxy);

          for(k=0; k<96; k++)
          {
               pxy[k]=pxy[k+4];
               rxy[k]=rxy[k+4];
          }

          px1 += pdx1; py1 += pdy1;
          px2 += pdx2; py2 += pdy2;
          rx1 += rdx1; ry1 += rdy1;
          rx2 += rdx2; ry2 += rdy2;
          rdx1 =inchk(rx1,rdx1,x_lower,x_upper);
          rdx2 =inchk(rx2,rdx2,x_lower,x_upper);
          rdy1 =inchk(ry1,rdy1,y_lower,y_upper);
          rdy2 =inchk(ry2,rdy2,y_lower,y_upper);
          pdx1 =inchk(px1,pdx1,x_lower,x_upper);
          pdx2 =inchk(px2,pdx2,x_lower,x_upper);
          pdy1 =inchk(py1,pdy1,y_lower,y_upper);
          pdy2 =inchk(py2,pdy2,y_lower,y_upper);
     } while (!Cconis());
} while ((Crawcin() & 0x7F) != 27);
     return;
}
/*-------------------------------------------------*/

main()
{
int ap_id;
WORD gr_wchar,gr_hchar,
     gr_wbox,gr_hbox;

     ap_id=appl_init();
     if (ap_id<0)
     {
       Cconws("*** initialisation error ***\n");
       Cconws("*** press any key....... ***\n");
       Crawcin();
       return(-1);
     }
     p_handle=
       graf_handle(&gr_wchar,&gr_hchar,&gr_wbox,&gr_hbox);
     v_handle=open_vwork(p_handle);
     set_scrn_attr();

     vsl_type(v_handle,1);
     vsl_width(v_handle,1);
     vsf_color(v_handle,WHITE);
     vsf_perimeter(v_handle,TRUE);
     vswr_mode(v_handle,MD_XOR);

     x_lower=10; y_lower=10;
     x_upper=x_max - 10;
     y_upper=y_max - 10;

     draw_lines();

     v_clsvwk(v_handle);
     appl_exit();
}

