#include <aes.h>
#include <vdi.h>
#include <tos.h>

typedef	int boolean;

int contrl[12],
	intin[128],intout[128],
	ptsin[128],ptsout[128],
	work_in[12],work_out[57];
int	vdi_handle,phys_handle;
int	gl_hchar,gl_wchar,gl_hbox,gl_wbox;
int	gl_apid;

boolean open_vwork(void);
void close_vwork(void);

/* ™ffnen einer VDI-Arbeitsstation */
boolean open_vwork(void)
{
  register int i;

	if ((gl_apid = appl_init()) != -1) {
		phys_handle = graf_handle(&gl_wchar,&gl_hchar,
								  &gl_wbox,&gl_hbox);
		work_in[0] = Getrez()+2;
		for (i = 1; i < 10; work_in[i++] = 1)
			;
		work_in[10] = 2;
		vdi_handle = phys_handle;
		v_opnvwk(work_in,&vdi_handle,work_out);
		return 1;
	}
	else
		return 0;
}


/* Schliežen der VDI-Arbeitsstation */
void close_vwork(void)
{
	v_clsvwk(vdi_handle);
	appl_exit();
}
