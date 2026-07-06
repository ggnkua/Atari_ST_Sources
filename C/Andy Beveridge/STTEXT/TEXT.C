/*----------------------------*/
/* text demos                 */
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
draw_text()
{
int i, char_height, char_width, cell_height, cell_width;
int hor_out,vert_out;
int attrib[10];
char s[32];

	v_clrwk(v_handle);
	v_gtext(v_handle,30,40,"This is v_gtext.");
	v_justified(v_handle,30,70,"This is v_justified.",
			200,FALSE,FALSE);
	v_justified(v_handle,30,100,"This is v_justified.",
			200,FALSE,TRUE);
	v_justified(v_handle,30,130,"This is v_justified.",
			200,TRUE,FALSE);
	v_justified(v_handle,30,160,"This is v_justified.",
			200,TRUE,TRUE);
	vst_rotation(v_handle,900);
	v_gtext(v_handle,300,180,"Text on edge");
	vst_rotation(v_handle,1800);
	v_gtext(v_handle,280,180,"Upsidedown text");
	vst_rotation(v_handle,0);
	Crawcin();
	
	v_clrwk(v_handle);
	vqt_attributes(v_handle,attrib);
	sprintf(s,"current text face: %d",attrib[0]);
	v_gtext(v_handle,10,20,s);
	sprintf(s,"current height   : %d",attrib[7]);
	v_gtext(v_handle,10,50,s);
	Crawcin();

	v_clrwk(v_handle);
	vst_point(v_handle,1,&char_width,&char_height,
		  &cell_width,&cell_height);
	v_gtext(v_handle,10,100,"This is 1 point.");

	vst_height(v_handle,1,&char_width,&char_height,
		   &cell_width,&cell_height);
	v_gtext(v_handle,10,190,"This is 1 pixel.");
	Crawcin();

	v_clrwk(v_handle);
	vst_point(v_handle,attrib[7],&char_width,&char_height,
		  &cell_width,&cell_height);
	v_gtext(v_handle,10,100,"This is default point.");

	vst_height(v_handle,attrib[7],&char_width,&char_height,
		   &cell_width,&cell_height);
	v_gtext(v_handle,10,190,"This is default pixel.");
	Crawcin();

	v_clrwk(v_handle);
	vst_point(v_handle,10,&char_width,&char_height,
		  &cell_width,&cell_height);
	v_gtext(v_handle,10,100,"This is 10 point.");

	vst_height(v_handle,10,&char_width,&char_height,
		   &cell_width,&cell_height);
	v_gtext(v_handle,10,190,"This is 10 pixel.");
	Crawcin();

	v_clrwk(v_handle);
	vst_point(v_handle,40,&char_width,&char_height,
		  &cell_width,&cell_height);
	v_gtext(v_handle,10,100,"This is 40 point.");

	vst_height(v_handle,40,&char_width,&char_height,
		   &cell_width,&cell_height);
	v_gtext(v_handle,10,190,"This is 40 pixel.");
	Crawcin();

	v_clrwk(v_handle);
	vst_point(v_handle,72,&char_width,&char_height,
		  &cell_width,&cell_height);
	v_gtext(v_handle,10,100,"This is 72 point.");

	vst_height(v_handle,72,&char_width,&char_height,
		   &cell_width,&cell_height);
	v_gtext(v_handle,10,190,"This is 72 pixel.");

	vst_height(v_handle,attrib[7],&char_width,&char_height,
		   &cell_width,&cell_height);
	Crawcin();

	v_clrwk(v_handle);
	for (i = 0; i < 20; i++)
	{
		vst_font(v_handle,i);
		vqt_name(v_handle,i,s);
		v_gtext(v_handle,(i/10)*150+20, (i%10)*19+20, s);
	}
	vst_font(v_handle, attrib[0]);
	Crawcin();

	v_clrwk(v_handle);
	v_gtext(v_handle,30,20, "Ny__");

	vst_alignment(v_handle,0,1,&hor_out,&vert_out);
	v_gtext(v_handle,80,20, "Hy__");

	vst_alignment(v_handle,0,2,&hor_out,&vert_out);
	v_gtext(v_handle,130,20, "Ay__");

	vst_alignment(v_handle,0,3,&hor_out,&vert_out);
	v_gtext(v_handle,180,20, "By__");

	vst_alignment(v_handle,0,4,&hor_out,&vert_out);
	v_gtext(v_handle,230,20, "Dy__");

	vst_alignment(v_handle,0,5,&hor_out,&vert_out);
	v_gtext(v_handle,280,20, "Ty__");

	vst_alignment(v_handle,0,0,&hor_out,&vert_out);
	v_gtext(v_handle,100,70, "Hleft_y");

	vst_alignment(v_handle,1,0,&hor_out,&vert_out);
	v_gtext(v_handle,100,100, "Hcenter_y");

	vst_alignment(v_handle,2,0,&hor_out,&vert_out);
	v_gtext(v_handle,100,130, "Hright_y");

	vst_alignment(v_handle,0,0,&hor_out,&vert_out);
	Crawcin();

	v_clrwk(v_handle);
	for (i=0; i<64; i++)
	{
		vst_effects(v_handle,i);
		v_gtext(v_handle,(i/8)*35+20,(i%8)*22+20,"Aby");
	}
	vst_effects(v_handle,0);
	Crawcin();
}

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

     draw_text();

     v_clsvwk(v_handle);
     appl_exit();
}

