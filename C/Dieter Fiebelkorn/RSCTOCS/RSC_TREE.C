#include	<define.h>
#include	<stdio.h>
#include	<gemdefs.h>
#include	<obdefs.h>
#include	<osbind.h>

#define		NIL		-1
#define		Wait()	{printf("\033p Weiter - Return \033q\n"); gemdos(1);}

int		handle;
int		vdi_handle;
int 	work_in[11],work_out[57];
int 	contrl[12],intin[128],ptsin[128],intout[128],ptsout[128];

extern int	global[];

RSHDR	header;

main(argc, argv)
int		argc;
char	**argv;
{
	int		i, ret, hndl, height, room;
	int		*help;
	int		print_object();
	OBJECT	**treeadress,
			*ob;
		
	for (i=0; i<10; work_in[i++]=1)
		;
	work_in[10]=2;
	v_opnvwk (work_in, &vdi_handle, work_out);
		
	appl_init();
	
	if (argc != 2)
	{
		form_alert (1,"[1][ | Falsche Parameter][  OK  ]");
		goto ENDE;
	}
	
	if ((hndl = Fopen(argv[1],0)) < 0)
	{
		form_alert (1, "[1][ | Fehler beim ”ffnen | der Datei. ][  OK  ]");
		goto ENDE;
	}
	Fread (hndl, (long) sizeof(RSHDR), &header);
	print_rshdr (&header);
	Fclose (hndl);
	Wait();
	
	if (!rsrc_load (argv[1]))
	{
		form_alert (1,"[1][ | FATAL, keine Resource ! ][  OK  ]");
		goto ENDE;
	}
	
	v_hide_c (vdi_handle);
	
	help = (int *) &treeadress;
	help[0] = global[5];
	help[1] = global[6];
	
	for (i = 0;i < header.rsh_ntree; i++)
		treewalk (treeadress[i], ROOT, NIL, print_object);
		
ENDE:
	v_show_c (vdi_handle);
	appl_exit();
	v_clsvwk(vdi_handle);
}



int print_object (tree, index)
OBJECT	*tree;
int		index;
{
	OBJECT	*o;
	
	o = tree + index;
	
	printf ("\033E");
	printf ("Adresse des Objekts: 0x%08lx\n",o);
	printf ("OB_NEXT   = %d\n",     o->ob_next);
	printf ("OB_HEAD   = %d\n",     o->ob_head);
	printf ("OB_TAIL   = %d\n",     o->ob_tail);
	printf ("OB_TYPE   = %u\n",     o->ob_type);
	printf ("OB_FLAGS  = %04x\n",   o->ob_flags);
	printf ("OB_STATE  = %04x\n",   o->ob_state);
	printf ("OB_SPEC   = 0x%08lx\n",o->ob_spec);
	printf ("OB_X      = %d\n",     o->ob_x);
	printf ("OB_Y      = %d\n",     o->ob_y);
	printf ("OB_WIDTH  = %d\n",     o->ob_width);
	printf ("OB_HEIGHT = %d\n",     o->ob_height);
	
	o->ob_x = 639 - o->ob_width;
	o->ob_y = 399 - o->ob_height;
	objc_draw (o,0,0,0,0,640,400);
	
	Wait();
	return(TRUE);
}



int print_rshdr(h)
RSHDR	*h;
{
	printf ("\033EResource Header\n\n");
	printf ("RSH_VRSN    = %d\n",h->rsh_vrsn);
	printf ("RSH_OBJECT  = %d\n",h->rsh_object);
	printf ("RSH_TEDINFO = %d\n",h->rsh_tedinfo);
	printf ("RSH_ICONBLK = %d\n",h->rsh_iconblk);
	printf ("RSH_BITBLK  = %d\n",h->rsh_bitblk);
	printf ("RSH_STRING  = %d\n",h->rsh_string);
	printf ("RSH_IMDATA  = %d\n",h->rsh_imdata);
	printf ("RSH_FRIMG   = %d\n",h->rsh_frimg);
	printf ("RSH_TRINDEX = %d\n",h->rsh_trindex);
	printf ("RSH_NOBS    = %d\n",h->rsh_nobs);
	printf ("RSH_NTREE   = %d\n",h->rsh_ntree);
	printf ("RSH_NTED    = %d\n",h->rsh_nted);
	printf ("RSH_NIB     = %d\n",h->rsh_nib);
	printf ("RSH_NBB     = %d\n",h->rsh_nbb);
	printf ("RSH_NSTRING = %d\n",h->rsh_nstring);
	printf ("RSH_NIMAGES = %d\n",h->rsh_nimages);
	printf ("RSH_RSSIZE  = %d\n",h->rsh_rssize);
}



treewalk (tree, first, last, routine)
OBJECT	*tree;
int		first,
		last;
int		(*routine)();
{
	register int	this,
					prev;
					
	prev = this = first;
	
	while ((this != last) && (this != NIL))
		if (tree[this].ob_tail != prev)
		{
			prev = this;
			this = NIL;
			
			if ((*routine)(tree, prev))
				this = tree[prev].ob_head;
			
			if (this == NIL)
				this = tree[prev].ob_next;
		}
		else
		{
			prev = this;
			this = tree[prev].ob_next;
		}
}
