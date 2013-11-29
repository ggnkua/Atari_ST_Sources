/***************************************
 *    G‚n‚rateur de code               *
 *      Valvasori Mo‹se                *
 *     16.08.96                        *
 ***************************************/
 
#include <stdio.h>
#include <string.h> 
#include <stdlib.h>
#include <osbind.h>
#include <gemfast.h>
#include	"s_malloc.h"

#define TRUE 1
#define FALSE 0

int		work_in[] = { 1,	 1,	 1,	 1,	 1,	 1,	 1,	 1,	 1,	 0,	 2};	/*tableau de	*/
int		work_out[57],	xwork_out[57];							/* la VDI*/
int		VDIhandle,	ap_id,	buf[8];
int		mousex,	 mousey,	 key,	 key_s,	mb_return;
int		xb,	yb,	wb,	hb;

extern	OBJECT	*adr_menu;
extern	void		*start;		/* C_OBJ */

void		open_work(void);

extern	void	gaddr_rsrc(void);
extern	void efface(void *obj,	void *obj_fin);	/* C_OBJ	*/

void main (void)
{
int quit=FALSE;
int evnt,	dummy;

	open_work();
	if (!rsrc_load("C_GEN.RSC"))
	{
		form_alert(1,	"[1][| C_GEN.RSC ???][ Ciao ]");		
		v_clsvwk(VDIhandle);
		appl_exit();
		Pterm(0);
	}
	gaddr_rsrc();
	wind_get(0,	WF_WORKXYWH,	&xb,	&yb,	&wb,	&hb); /*coord du bureau	*/
	menu_bar(adr_menu,	TRUE);	/* Place le menu		*/
	graf_mouse(ARROW,	0);			/* Une petite flŠche	*/
	do
	{
		evnt = evnt_multi ((MU_MESAG|MU_BUTTON|MU_KEYBD|MU_TIMER),	 2,	 1,	 1,	
									0,	 0,	 0,	 0,	 0,	 0,	 0,	 0,	 0,	 0,	
									buf,	 0,	 10,	
									&mousex,	 &mousey,	 &dummy,	 &key_s,	 &key,	 &mb_return);

	    if (evnt & MU_KEYBD)    /* Si ‚v‚nement clavier */
	    	evnt=short_cut(key_s,	key,	adr_menu);

		if((evnt & MU_MESAG) && buf[0]==MN_SELECTED)
		{
			quit=select_menu();
			menu_tnormal(adr_menu,	buf[3],	TRUE);
		}
		else
		{
			form(evnt);
		}
	}while (quit==FALSE);

	efface(start,	NULL);
	wind_new();
	wind_set(0,	WF_NEWDESK,	0,	0);	/* remet le bureau dans l'‚tat d'origine	*/
	v_clsvwk(VDIhandle);
	rsrc_free();
	appl_exit();

#ifdef	DEBUG_MALLOC	
	S_MemStat();
#endif
}

void open_work(void)  /*on initialise le GEM et la VDI*/
{
int i,	a,	b;

	ap_id=appl_init();
	if(ap_id<0)
		{
		printf("Erreur … appl_init");
		Pterm(0);
		}

		/* Handle de la station que l'AES ouvre automatiquement	*/
	VDIhandle = graf_handle (&a,	 &b,	 &i,	 &i);
		/* Ouverture station de travail virtuelle	*/
	v_opnvwk (work_in,	 &VDIhandle,	 work_out);
	vq_extnd (VDIhandle,	 TRUE,	 xwork_out);		/*	Info ‚ntendue sur la VDI	*/
	Teste_config();
}
