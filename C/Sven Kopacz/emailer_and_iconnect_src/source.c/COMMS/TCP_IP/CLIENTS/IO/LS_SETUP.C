#include <ec_gem.h>
#include "io.h"
#include "ioglobal.h"
#include "imgload.h"

typedef struct
{
	long	magic;			/* 'IOSU' */

	int		version;		/* Setup-version */
	long	set_size;		/* Setup-Gr”že */	
}IOS_HEAD;

int load_setup(void)
{
	long fhl;
	char path[256];
	IOS_HEAD	ih;
	
	strcpy(path, db_path);
	strcat(path, "\\EMAILER.CFG");
	fhl=Fopen(path, FO_READ);
	if(fhl < 0) return(0);
	Fread((int)fhl, sizeof(IOS_HEAD), &ih);
	if(ih.magic != 'IOSU') {Fclose((int)fhl);return(0);}
	if(ih.set_size > sizeof(IO_SETUP))
		Fread((int)fhl, sizeof(IO_SETUP)-sizeof(IOS_HEAD), &(ios.wx));
	else
		Fread((int)fhl, ih.set_size-sizeof(IOS_HEAD), &(ios.wx));
	Fclose((int)fhl);

	if(ios.msg_img_path[0])
		if(load_img(&msg_img, ios.msg_img_path)==0)
			msg_img.fd_addr=NULL;
	if(ios.lst_img_path[0])
		if(load_img(&lst_img, ios.lst_img_path)==0)
			lst_img.fd_addr=NULL;
	if(ios.ed_img_path[0])
		if(load_img(&ed_img, ios.ed_img_path)==0)
			ed_img.fd_addr=NULL;
	
	return(1);
}

int save_setup(void)
{
	long fhl;
	char path[256];

	if(ios.list!=0)
	{
		ios.list=0;
		ios.list_off=ios.list_sel=0;
	}
	
	/* Ausmaže des Haupt-Fensters */
	ios.wx=wdial.wx; ios.wy=wdial.wy; ios.ww=wdial.ww; ios.wh=wdial.wh;

	ios.hide_list=ios.hide_msg=0;
	if(odial[FTEXT].ob_flags & HIDETREE)
		ios.hide_msg=1;
	else if(odial[ALISTE].ob_flags & HIDETREE)
		ios.hide_list=1;

	if(omenu[MVALLE].ob_state & CHECKED)
		ios.view_mask=0;
	else if(omenu[MVSNDSNT].ob_state & CHECKED)
		ios.view_mask=1;
	else if(omenu[MVSND].ob_state & CHECKED)
		ios.view_mask=2;
	else if(omenu[MVSNT].ob_state & CHECKED)
		ios.view_mask=3;
	else if(omenu[MVNEWRED].ob_state & CHECKED)
		ios.view_mask=4;
	else if(omenu[MVRED].ob_state & CHECKED)
		ios.view_mask=5;
	else if(omenu[MVNEW].ob_state & CHECKED)
		ios.view_mask=6;

	ios.s_up_down=0;
	if(omenu[MVFROM].ob_state & CHECKED)
	{
		ios.sort_by=0;
		if(odial[ABSSORT].ob_spec.bitblk==getob(ABSTEIGEND)->ob_spec.bitblk)
			ios.s_up_down=1;
	}
	else if(omenu[MVSUBJ].ob_state & CHECKED)
	{
		ios.sort_by=1;
		if(odial[BTRSORT].ob_spec.bitblk==getob(ABSTEIGEND)->ob_spec.bitblk)
			ios.s_up_down=1;
	}
	else if(omenu[MVDATE].ob_state & CHECKED)
	{
		ios.sort_by=2;
		if(odial[DATSORT].ob_spec.bitblk==getob(ABSTEIGEND)->ob_spec.bitblk)
			ios.s_up_down=1;
	}

	strcpy(path, db_path);
	strcat(path, "\\EMAILER.CFG");
	fhl=Fcreate(path, 0);
	if(fhl < 0) return(0);
	Fwrite((int)fhl, sizeof(IO_SETUP), &ios);
	Fclose((int)fhl);
	return(1);
}