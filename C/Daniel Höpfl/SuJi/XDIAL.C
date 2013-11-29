#include "SuJi_glo.h"
#include <tos.h>

int _get_cookie(long wen,long *wert)
{
  static int use_ssystem = -1;
	int i;
  long    val = -1l;
  COOKJAR *cookiejar;

  if( use_ssystem < 0 )
    use_ssystem = (Ssystem(S_INQUIRE, 0l, 0)==E_OK);

  if(use_ssystem)
  {
    if( Ssystem(S_GETCOOKIE, wen, (long)&val)==E_OK )
    {
      if( wert!=NULL )
        *(LONG *)wert = val;
      return 1;
    }
  }
  else
  {
    /* Zeiger auf Cookie Jar holen */
    cookiejar = (COOKJAR *)(Setexc(0x05A0/4,(const void (*)(void))-1));
    if( cookiejar )
    {
      for( i=0 ; cookiejar[i].id ; i++ )
        if( cookiejar[i].id==wen )
        {
          if( wert!=NULL )
            *(long *)wert = cookiejar[i].value;
          return 1;
        }
    }
  }

  return 0;
}

void make_scroll_edit(OBJECT *tree,int obj,XTED *xted,int len)
{
	TEDINFO *t;
	long cookie;
	AESVARS *av;

	if(!Ash_getcookie((long) 'MagX',&cookie))
		return ;

	av=((MAGX_COOKIE *) (cookie))->aesvars;
	if(!av)
		return;

	if(((av->date << 16l) |
		(av->date >> 24l) |
		((av->date >> 8l) & 0xff00l)) >= 0x19950829l)
	{
		t=tree[obj].ob_spec.tedinfo;
		t->te_just=TE_LEFT;
		t->te_ptext=xted->xte_pvalid;
		xted->xte_pvalid=t->te_pvalid;
		xted->xte_vislen=t->te_tmplen-1;
		xted->xte_scroll=0;

		t->te_tmplen=len+1;
		t->te_ptmplt=0l;
		t->te_pvalid=(char *)xted;
		t->te_txtlen=t->te_tmplen;
	}
}

int cdecl uf_listbox(PARMBLK *pb)
{
	int xy[4];
	char *string;

	if(pb->pb_xc > pb->pb_x)
		xy[0]=pb->pb_xc;
	else
		xy[0]=pb->pb_x;

	if(pb->pb_yc > pb->pb_y)
		xy[1]=pb->pb_yc;
	else
		xy[1]=pb->pb_y;

	if(pb->pb_xc+pb->pb_wc < pb->pb_x+pb->pb_w)
		xy[2]=pb->pb_xc+pb->pb_wc-1;
	else
		xy[2]=pb->pb_x+pb->pb_w-1;

	if(pb->pb_yc+pb->pb_hc < pb->pb_y+pb->pb_h)
		xy[3]=pb->pb_yc+pb->pb_hc-1;
	else
		xy[3]=pb->pb_y+pb->pb_h-1;

	vs_clip(vdi_h,1,xy);

	string = ((TEDINFO *)pb->pb_parm)->te_ptext;

	vswr_mode(vdi_h,MD_REPLACE);

	vsf_color(vdi_h,WHITE);
	vsf_interior(vdi_h,FIS_SOLID);
	vsf_perimeter(vdi_h,0);
	xy[2]=xy[0]=pb->pb_x;
	xy[3]=xy[1]=pb->pb_y;
	xy[2]+=pb->pb_w-1;
	xy[3]+=pb->pb_h-1;
	v_bar(vdi_h,xy);

	if(pb->pb_currstate & SELECTED)
		vswr_mode(vdi_h,MD_ERASE);
	else
		vswr_mode(vdi_h,MD_TRANS);
	vst_alignment(vdi_h,0,5,&i,&i);

	vst_font(vdi_h,1);
	vst_point(vdi_h,13,&i,&i,&i,&i);
	vst_color(vdi_h,BLACK);

	v_gtext(vdi_h,pb->pb_x,pb->pb_y,string);

	vst_font(vdi_h,screen_font);
	vst_point(vdi_h,screen_font_height,&i,&i,&i,&i);

	return pb->pb_currstate & ~SELECTED;
}

void make_listbox_userdef(OBJECT *tree,USERBLK *ud)
{
	ud->ub_code=uf_listbox;
	ud->ub_parm=tree[0].ob_spec.index;

	tree[0].ob_spec.userblk=ud;
	tree[0].ob_type &= ~0x00ff;
	tree[0].ob_type |= G_USERDEF;
}

int fsel(char *pfad,char *file,int *but,char *titel,GlobalArray *globa)
{
	int ex=0;

	mt_wind_update(BEG_UPDATE,globa);

	if(Sversion()>=5376)
		ex=mt_fsel_exinput(pfad,file,but,titel,globa);
	else
	{
		ex=Ash_getcookie('FSEL',0);

		if(ex)
			ex=mt_fsel_exinput(pfad,file,but,titel,globa);
		else
			ex=mt_fsel_input(pfad,file,but,globa);
	}
	mt_wind_update(END_UPDATE,globa);

	return ex;
}
