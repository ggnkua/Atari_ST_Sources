#include <gem.h>
#include <stdio.h>
#include <osbind.h>

int phys_handle;
int vdi_handle;
int msgbuff[8];

int work_in[11];
int work_out[57];
int dummy;
int menu_id;
int gl_apid;

main()
{
int i;
	gl_apid=appl_init();
	if(gl_apid < 0)
		return(1);
	phys_handle=graf_handle(&dummy,&dummy,&dummy,&dummy);
	menu_id=menu_register(gl_apid,"  Free RAM");
	x_accessory();
}

x_accessory()
{
int cct,dummy;
	while (TRUE)
{	     evnt_multi(MU_BUTTON|MU_MESAG|MU_KEYBD,
			1,1,1,
			0,0,0,0,0,
			0,0,0,0,0,
			&msgbuff,
			0,0,
			&dummy,&dummy,&dummy,&dummy,
			&dummy,&cct);
		wind_update(BEG_UPDATE);
		if((msgbuff[0]==AC_OPEN) && (msgbuff[4]==menu_id))
		{
		     open_vwork();
		     x_action();
		     v_clsvwk(vdi_handle);
		}
		wind_update(END_UPDATE);
	}
appl_exit();
}

open_vwork()
{
int i;
	for(i=0;i<10;i++) work_in[i]=1;
	work_in[10]=2;
	vdi_handle=phys_handle;
	v_opnvwk(work_in,&vdi_handle,work_out);
	if(!vdi_handle) return(1);
}

x_action() {
	/* display free RAM (roughly) */
char strng[32];
	sprintf(strng,"[1][free memory: %ld][OK]",Malloc(-1L));
	form_alert(1,strng);
}
