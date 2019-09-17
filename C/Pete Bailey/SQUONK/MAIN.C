/* ===================================================================== */
/*	Mousetrap Accessory										*/
/* ===================================================================== */

#include	<xgemfast.h>
#include	<osbind.h>


/* ---- Defines -------------------------------------------------------- */

#define	loop	while(1)


/* ---- Globals -------------------------------------------------------- */

int	ap_id;		/* Application ID from appl_init				*/
int	v_handle;		/* VDI handle; used primarily for vector-swapping	*/
long	sysmouse;		/* Vector to system mouse movement handler		*/
long	sysbuttn;		/* Vector to system mouse button handler		*/
int	mbut;		/* Save mouse button state					*/
int	mx;			/* Mouse x position							*/
int	my;			/* Mouse y position							*/
int	active=1;		/* Current state: 1 => active, 0 => disabled		*/


/* ---- Function prototypes -------------------------------------------- */

void	main();		/* Top-level main routine					*/
void	gem_open();	/* Register application, open VDI, etc			*/
void	install();	/* Install mouse trap routines				*/
void	fix_clicks();	/* Wait briefly for a double click				*/
void	deinstall();	/* Deinstall mouse trap routines				*/
void	process();	/* Alert-box control functions				*/
void	mousetrap();	/* Our mouse trap routine (assembler)			*/
void	buttntrap();	/* Out button trap routine (assembler)			*/


/* --------------------------------------------------------------------- */
/*	Main													*/
/* --------------------------------------------------------------------- */

void main()
{
	int		msg[8];
	
	gem_open();  fix_clicks();  install();

	loop {
		evnt_mesag(msg);
		if (msg[0]==AC_OPEN) {
			process();
			}
		}
}


/* --------------------------------------------------------------------- */
/*	Opening cliches										*/
/* --------------------------------------------------------------------- */

void gem_open()
{
	int		n,work_in[12],work_out[57];

	ap_id=appl_init();  v_handle=graf_handle(&n,&n,&n,&n);

	for (n=0; n<10; work_in[n++]=1);  work_in[10]=2*Getrez();

	v_opnvwk(work_in,&v_handle,work_out);
	
	if (menu_register(ap_id,"  Squonk !")<0) {
		v_clsvwk(v_handle);
		appl_exit();
		exit(0);
		}
}


/* --------------------------------------------------------------------- */
/*	Manage alert-box control functions							*/
/* --------------------------------------------------------------------- */

void process()
{
	static char alert_box[] =
	"[0][ |SQUONK!| |(c) 1996, Pete Bailey  |][ Off | On | Ok ]";
	
	fix_clicks();
	
	switch (form_alert(0,alert_box)) {
		case 1:	if (active==1) { deinstall(); active=0; }  break;
		case 2:	if (active==0) { install();   active=1; }  break;
		}
}


/* --------------------------------------------------------------------- */
/*	Install traps into vectors								*/
/* --------------------------------------------------------------------- */

void install()
{
	vex_butv(v_handle,buttntrap,&sysbuttn);
	vex_motv(v_handle,mousetrap,&sysmouse);
}


/* --------------------------------------------------------------------- */
/*	Deinstall traps from vectors								*/
/* --------------------------------------------------------------------- */

void deinstall()
{
	long		trash;
	
	vex_butv(v_handle,sysbuttn,&trash);
	vex_motv(v_handle,sysmouse,&trash);
}


/* --------------------------------------------------------------------- */
/*	Wait for a double click to fix the scroll bug				*/
/* --------------------------------------------------------------------- */

void fix_clicks()
{
	int		dummy;
	
	evnt_multi(MU_BUTTON|MU_TIMER,2,3,3,
			0,0,0,0,0,0,0,0,0,0,0L,100,0,
			&dummy,&dummy,&dummy,&dummy,&dummy,&dummy);
}

