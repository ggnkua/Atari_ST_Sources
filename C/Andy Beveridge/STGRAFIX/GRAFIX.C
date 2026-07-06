/*----------------------------*/
/* graphics demos             */
/* ST Application Programming */
/*----------------------------*/

#include <stdio.h>
#include <gem.h>
#include <osbind.h>
#include <obdefs.h>

#define WORD int

WORD p_handle,
     v_handle,
     scrn_rez,    
     col_scrn,
     y_max,
     x_max,
     msgbuff[8];

#define SS 18            /* shape size */

/*-----------------------------------------------------*/
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
/*-----------------------------------------------------*/
set_scrn_attr()
{
WORD work_out[57];

    vq_extnd(v_handle,0,work_out);
    x_max=work_out[0];
    y_max=work_out[1];
    scrn_rez=Getrez();
    col_scrn=(scrn_rez < 2);
}
/*--------------------------------------------------------*/
calc_shape(num_pts,a)
WORD *num_pts, a[];
{

     *num_pts = 7;
     a[2]=a[0] + SS;
     a[3] = a[1];
     a[4] = a[2];
     a[5] = a[3] - SS;
     a[6] = a[2] + SS;
     a[7] = a[1] + (SS/2);
     a[12] = a[0];
     a[13] = a[1] + SS;
     a[10] = a[2];
     a[11] = a[13];
     a[8] = a[4];
     a[9] = a[11] + SS;
 
    return;
}
/*--------------------------------------------------------*/
draw_line()
{
WORD count,pxy[32],x[16],y[16];
int  i;

     x[1] = 10;      y[1] = 20;
     x[2] = 70;      y[2] = 20;
     x[3] = 130;     y[3] = 20;
     x[4] = 190;     y[4] = 20;

     x[5] = 10;      y[5] = 85;
     x[6] = 70;      y[6] = 85;
     x[7] = 130;     y[7] = 85;
     x[8] = 190;     y[8] = 85;

     x[9] = 10;      y[9] = 150;
     x[10] = 70;     y[10] = 150;
     x[11] = 130;    y[11] = 150;
     x[12] = 190;    y[12] = 150;

     v_clrwk(v_handle);
     for (i=1; i <=12; i++)             /* line widths */
     {
          pxy[0] = x[i];
          pxy[1] = y[i];
          calc_shape(&count,pxy);
          vsl_width(v_handle,i);
          v_pline(v_handle,count,pxy);
     }
     Crawcin();
                                        /* line types */
     v_clrwk(v_handle);
     vsl_width(v_handle,1);
     for (i=1; i <=12; i++)
     {
          pxy[0] = x[i];
          pxy[1] = y[i];
          calc_shape(&count,pxy);
          vsl_type(v_handle,i);
          v_pline(v_handle,count,pxy);
     }
     Crawcin();
                                        /* line ends */
     v_clrwk(v_handle);
     vsl_width(v_handle,9);

     pxy[0] = 50;  pxy[1] = 20;         /* squared */
     pxy[2] = 150; pxy[3] = 20;
     vsl_ends(v_handle,0,0);
     v_pline(v_handle,2,pxy);

     pxy[0] = 50;  pxy[1] = 60;         /* arrowed */
     pxy[2] = 150; pxy[3] = 60;
     vsl_ends(v_handle,1,1);
     v_pline(v_handle,2,pxy);

     pxy[0] = 50;  pxy[1] = 100;         /* rounded */
     pxy[2] = 150; pxy[3] = 100;
     vsl_ends(v_handle,2,2);
     v_pline(v_handle,2,pxy);

     Crawcin();
                                         /* marker types */
     v_clrwk(v_handle);
     for (i=1; i <=12; i++)
     {
          pxy[0] = x[i];
          pxy[1] = y[i];
          calc_shape(&count,pxy);
          vsm_type(v_handle,i);
          v_pmarker(v_handle,count,pxy);
     }
     Crawcin();

     return;
}
/*-----------------------------------------------------------*/
draw_boxes()
{
WORD pxy[4];

     v_clrwk(v_handle);
     vsf_perimeter(v_handle,FALSE);
     pxy[1] = 30;  pxy[3] = 90;
     pxy[0] = 30;  pxy[2] = 60;
     vr_recfl(v_handle,pxy);
     pxy[0] += 50; pxy[2] += 50;
     v_rbox(v_handle,pxy);
     pxy[0] += 50; pxy[2] += 50;
     v_rfbox(v_handle,pxy);
     pxy[0] += 50; pxy[2] += 50;
     v_bar(v_handle,pxy);

     vsf_perimeter(v_handle,TRUE);
     pxy[1] = 130;  pxy[3] = 190;
     pxy[0] = 30;  pxy[2] = 60;
     vr_recfl(v_handle,pxy);
     pxy[0] += 50; pxy[2] += 50;
     v_rbox(v_handle,pxy);
     pxy[0] += 50; pxy[2] += 50;
     v_rfbox(v_handle,pxy);
     pxy[0] += 50; pxy[2] += 50;
     v_bar(v_handle,pxy);

     return;
}
/*------------------------------------------------------*/
draw_rect()
{
WORD pxy[32];
int  i;
     draw_boxes();
     Crawcin();

     vsl_width(v_handle,1);
     vsl_ends(v_handle,0,0);
     vsl_type(v_handle,1);
     draw_boxes();
     Crawcin();
                              /* fills */
     vsf_interior(v_handle,0);
     draw_boxes();
     Crawcin();

     vsf_interior(v_handle,1);
     draw_boxes();
     Crawcin();

     vsf_interior(v_handle,2);
     draw_boxes();
     Crawcin();

     vsf_interior(v_handle,3);
     draw_boxes();
     Crawcin();

     v_clrwk(v_handle);
     vsf_interior(v_handle,2);
     for (i=0; i<32; i++)
     {
          vsf_style(v_handle,i+1);
          pxy[0]=((i%8)*30)+20;
          pxy[1]=((i/8)*30)+20;
          pxy[2]=pxy[0]+20;
          pxy[3]=pxy[1]+20;
          vr_recfl(v_handle,pxy);
     }
     Crawcin();

     v_clrwk(v_handle);
     vsf_interior(v_handle,3);
     for (i=0; i<32; i++)
     {
          vsf_style(v_handle,i+1);
          pxy[0]=((i%8)*30)+20;
          pxy[1]=((i/8)*30)+20;
          pxy[2]=pxy[0]+20;
          pxy[3]=pxy[1]+20;
          vr_recfl(v_handle,pxy);
     }
     Crawcin();

     v_clrwk(v_handle);
     vsf_perimeter(v_handle,TRUE);
     vsf_interior(v_handle,2);
     vsf_style(v_handle,9);
     pxy[0]=30;   pxy[1]=30;
     pxy[2]=150;  pxy[3]=150;
     pxy[4]=150;  pxy[5]=30;
     pxy[6]=30;   pxy[7]=150;
     pxy[8]=30;   pxy[9]=30;
     v_fillarea(v_handle,5,pxy);
     Crawcin();

     v_clrwk(v_handle);
     vsf_interior(v_handle,0);
     vswr_mode(v_handle,MD_TRANS);
     pxy[0]=30;   pxy[1]=30;
     pxy[2]=100;  pxy[3]=100;
     v_bar(v_handle,pxy);
     pxy[0]=80;   pxy[1]=80;
     pxy[2]=150;  pxy[3]=150;
     v_bar(v_handle,pxy);
     vsf_interior(v_handle,3);
     vsf_style(v_handle,3);
     v_contourfill(v_handle,90,90,-1);
     Crawcin();

}
/*-----------------------------------------------------*/
draw_circ()
{
     v_clrwk(v_handle);
     vsf_interior(v_handle,2);
     vsf_style(v_handle,17);
     v_circle(v_handle,50,100,40);
     v_ellipse(v_handle,150,100,40,75);
     Crawcin();

     v_clrwk(v_handle);
     v_arc(v_handle,50,100,40,800,1800);
     v_ellarc(v_handle,150,100,40,75,2000,3500);
     Crawcin();

     v_clrwk(v_handle);
     v_pieslice(v_handle,50,100,40,1800,2100);
     v_ellpie(v_handle,150,100,40,75,3500,500);
     Crawcin();
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

     draw_line();
     draw_rect();
     draw_circ();

     v_clsvwk(v_handle);
     appl_exit();
}

