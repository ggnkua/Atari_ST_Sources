/* ---------------------------------------------------------------- */
/* TRAX ver 2.5 By T.Schembri & D.Plaza of Virtual Xperience		*/
/* (Sharp Man & Checksum)											*/
/* Use it with PURE C 1.1 (with Falcon Headers & Libraries)			*/
/* Compile in 68000 !! Tab size = 4									*/
/* ---------------------------------------------------------------- */

/* ---------------------------------------------------------------- */
/* Includes & defines												*/
/* ---------------------------------------------------------------- */

/* ~~~~~~~~~~~~~~~~~~~ */
/* Include definitions */
/* ~~~~~~~~~~~~~~~~~~~ */

#include	<stdio.h>
#include	<vdi.h>
#include	<aes.h>
#include	<tos.h>
#include	<stdlib.h>
#include	<string.h>
#include	<ext.h>

/* #define		TEST_DEBUG */
#define		NO_DSP
#define		NO_SORT

/* ~~~~~~~~~~~~~~~~~~~~~~ */
/* include MY d‚finitions */
/* ~~~~~~~~~~~~~~~~~~~~~~ */

#include	"headers\u_track.h"		/* ressource		*/	
#include	"headers\cookie.h"		/* cookie Jar		*/
#include	"..\exemple\u_trax.h"	/* msgs appl_write	*/

/* ~~~~~~~~~~~~~~~~~ */
/* Classical defines */
/* ~~~~~~~~~~~~~~~~~ */

#define		FALSE	0
#define		TRUE	1

/* Bits 0 … 15 */

#define		BIT_0	1
#define		BIT_1	2
#define		BIT_2	4
#define		BIT_3	8
#define		BIT_4	16
#define		BIT_5	32
#define		BIT_6	64
#define		BIT_7	128
#define		BIT_8	256
#define		BIT_9	512
#define		BIT_10	1024
#define		BIT_11	2048
#define		BIT_12	4096
#define		BIT_13	8192
#define		BIT_14	16384
#define		BIT_15	32768

#define		min(a,b)	((a)<(b)?(a):(b))
#define		max(a,b)	((a)>(b)?(a):(b))

/* ~~~~~~~~~~~~~~~ */
/* Defines program */
/* ~~~~~~~~~~~~~~~ */

/* Player routine */

#define		ROUT_68000_8	1
#define		ROUT_68000_16	2
#define		ROUT_DSP_16		3

/* colors & resolution */

#define		REZ_16			0		/* Rezol : 16 col + 200 pixels height */
#define		REZ_LOW_16		1		/*         16 col - 200 pixels heigth */
#define		REZ_MONO		2		/* 		   Mono   + 200 pixels heigth */
#define		REZ_LOW_MONO	3		/*		   Mono   - 200 pixels heigth */
#define		COLOR_MONO		0		/* 2 or 4 colors available 			  */
#define		COLOR_16		1		/* At least 16 colors available		  */

/* Machine type */

#define		MCH_FALCON		1
#define		MCH_STE			2
#define		MCH_TT			3
#define		MCH_MEGA_STE	4

/* DMA sound frequency */

#define		FREQ_6_25		0
#define		FREQ_12_5		1
#define		FREQ_25			2
#define		FREQ_50			3

/* CPU speed */

#define		MHZ_8			0
#define		MHZ_16			1

/* Wait time (in ms) when a click on ON/OFF */

#define		WAIT_BUTTON		15

/* Type ouverture de fenˆtre */

#define		FERME			0
#define		OUVRE			1
#define		SWITCH			2

/* Intern messages */

#define		BEG_LOAD		499		/* Start loading module	*/
#define		BEG_LOAD2		498		/* Idem 				*/
#define		END_LOAD		500		/* End loading module	*/
#define		BEG_LOAD_PLST	501		/* Start loding playlist*/
#define		BEG_SAVE_PLST	502		/* End loading playlist	*/

/* Soft Version */

#define		VERSION			2
#define		NIVEAU			5
#define		SOUS_NIVEAU		2

/* Play List structure */

typedef struct liste_mod
	{
	char				*nom;
	struct liste_mod	*suivant;
	struct liste_mod	*precedent;
	}LISTE_MOD;

#define		AVANT			0		/* go forward in the list 	*/
#define		ARRIERE			1		/* go back					*/

/* Play time structure */

typedef struct duree
	{
	int		heure;
	int		minute;
	int		seconde;
	}DUREE;

/* Define for Falcon coz there're not in the Pure C 1.1 headers */

#define		SNDLOCKED		-129
#define		SETPRESCALE		6

/* ---------------------------------------------------------------- */
/* Prototypes & global variables									*/
/* ---------------------------------------------------------------- */

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* External assembler routines */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

/* Soundtrack Falcon */

extern	void fmt_init(void *);
extern	int  fmt_play(void);
extern	void fmt_stop(void);
extern	void fmt_forward(void);
extern	void fmt_rewind(void);
extern	void fmt_pause(int);
extern	void fmt_freq(int);

/* Soundtrack STe-TT */

extern	int	 smt_init(void *);
extern	void smt_play(int);
extern	void smt_stop(void);
extern 	void smt_forward(void);
extern	void smt_rewind(void);
extern	void smt_pause(int);
extern	void smt_freq(int);

/* Several functions */

extern	void depack(void *);
extern	void Power_pack(void *,long);
extern	long T_unpack(void*,long);
extern	void Unpack_ndpk(void *);
extern	long Lenght_ndpk(void *);
extern	long swap(long);
extern	int	 mode_68000(void);
extern	int	 current_freq(void);
extern	int	 freq_falcon(void);
extern	int	 cache_falcon(void);
extern	void atomik(void *);
extern	void fmt_raz(void);
extern	void fmt_io(void);
extern	void smt_raz(void);
extern	void smt_io(void);
extern	void fmt_rvum(void);
extern	void smt_rvum(void);
extern	int	 u_sp3(void *);
extern	void fmt_off(void);
extern  void smt_off(void);
extern	poke(void *,int,char);

/* ~~~~~~~~~~~~~~ */
/* AES management */
/* ~~~~~~~~~~~~~~ */

OBJECT	*adresse(int);
void	maj(OBJECT *,int);
void	maj_no_mouse(OBJECT *,int);
void	maj_dial(OBJECT *,int);
void	redessine(OBJECT *,int,int);
void	redessine_dial(OBJECT *,int,int);
int		gestion_evenement(int[]);
int		gestion_panel(int,int,int);
void	fin_programme(void);
void	do_redraw(int,OBJECT *,int,int,int,int);
int		rc_intersect(GRECT *,GRECT *);
int		ouvre_fenetre(int);
void	opn_fenetre(int);
void	ferme_fenetre(void);
void	redessine2(OBJECT *,int,int);
void 	redes_icon(OBJECT *,int,int,int);
void	redes_icon2(OBJECT *,int,int,int,int);
void	_objc_draw(OBJECT *,int,int,int,int,int,int,int,int);
void	init_arbre(void);

/* ~~~~~~~~~~~~~~~~ */
/* Program Function */
/* ~~~~~~~~~~~~~~~~ */

void	about(void);
void	play(void);
void	_rewind(void);
void	forward(void);
void	pause(void);
void	stop(void);
int		load(int,char *);
int		l_module(int);
void	fin_load(void);
int		confirm_quit(void);
int		quitter(void);
void	flush(void);
void	mod_mem(void);
void	ouvre_mm(OBJECT *);
void	ferme_mm(OBJECT *);
void	status(char *,int,int);
void	change_frequence(int);
void	test_freq_mste_tt(void);
void	test_cache_falcon(void);
void	change_loop(void);
void	test_fin(void);
void	gestion_timer(void);
void	send_shell(int);
void	position(void);
void	err_mod_mem(char *,void *);
void	efface_liste_mod(void);
int		next_mod(void);
void	affiche_oscillo(void);
void	do_redraw_oscillo(int,int,int,int,int);
void	oscilloscope(int);
void	display_oscillo(void);
void	close_oscillo(void);
void	open_oscillo(void);
void	send_msg(int,int);
void	*_malloc(long);
long	_coreleft(void);
void	d_animations(void);
void	e_animations(void);
int		previous_mod(void);
void	play_list(int);
void	open_pliste(void);
void	close_pliste(void);
void	vu_metre(int);
void	open_vu_metre(void);
void	close_vu_metre(void);
void	do_redraw_vu_metre(int,int,int,int);
void	affiche_vu_metre(void);
int		gestion_clavier(int,int);
void	next_win(void);
void	digit(char *,int,int);
void	digit3(char *,int,int);
void	affiche_liste(int,int);
int		gestion_trax(int,int);
int		gestion_pliste(int,int,int);
void	init_pliste(void);
void	redessine_window(int);
void	plst_loop(int);
void	plst_new(int);
void	plst_remove(int);
void	plst_add(int,char *);
void	plst_lig(int,int,int);
void	plst_save(int,char *);
void	plst_load(int,char *);
void	plst_time(int,int,int,int);
void	panel(int);
void	l_playlist(void);
void	s_playlist(void);

/* ----------------------------------------------------------------	*/
/* Globales variables                                               */
/* ---------------------------------------------------------------- */

OBJECT		*menu,*res,*ros,*rlis;
int			gr_handle,work_in[20],work_out[57],id_appl,w_handle=-1,id_acc;
int			event_buffer[20];
int			com_buffer[20];
int			x_bureau,y_bureau,w_bureau,h_bureau;
char		path[200],name[14];
char		fs_path[200];
char		nom_module[200];
char		titre[]=" Ultimate Tracker ";
void 		*buffer=NULL;
char		*Default_path;
LISTE_MOD	*liste=NULL;
LISTE_MOD	*courant=NULL;
int			nb_mod_play=0;
int			cur_mod_play=0;
int			count_pause=0;
int			count_loop=0;
int			w_h_oscillo=-1;
char		titre_oscillo[]=" Oscilloscope ";
DTA			*_dta;
int			sens_liste=AVANT;
int			w_h_liste=-1;
char		titre_pliste[]=" Play List ";
int			w_h_vu_metre=-1;
char		titre_vu_metre[]=" Vu-meter ";        
char		info_vu_metre[]="ù    ù    ù    ù    ù";
int			px_vm,py_vm;
int			deb_liste_visu=1;
int			ligne_select=-1;
int			mod_select=-1;
int			B_VU_METRE=FALSE;
int			M_VU_METRE=FALSE;
int			IF_OPEN_VUM=FALSE;
int			IF_OPEN_LISTE=FALSE;
int			M_LISTE=FALSE;
int			B_PLAYLIST=FALSE;
int			B_OSCILLO=FALSE;
int			FORBIDDEN=FALSE;
int			NO_ANIMATION=FALSE;
int			OLD_STATE;
int			ID_SHELL=-1;
int			MOD_LOOP=TRUE;
int			F_OPEN=FALSE;
int			M_RSC=FALSE;
int			M_OPEN=FALSE;
int			M_PLAY=FALSE;
int			M_LOAD=FALSE;
int			M_PAUSE=FALSE;
int			NB_COLOR;
int			M_OSCILLO=FALSE;
int			FORBID_PAUSE=FALSE;
int			IF_OPEN=FALSE;
int			LOOP_LISTE=FALSE;
int			FORBID_LOOP_LISTE=FALSE;
int			MULTITACHE=FALSE;

int			rezol,machine;
int			old_freq;
int			increment=-1;
int			tab_freq[4]={F625,F125,F25,F50};
int			tab_icone[]={ICLOAD,LOAD,ICREWIND,REWIND,ICPLAY,BPLAY,ICFORWRD,FORWARD,ICPAUSE,PAUSE,ICSTOP,STOP,ICOSCILL,BOSCILLO};
int			tab_lig[]={LIG1,LIG2,LIG3,LIG4,LIG5,LIG6,LIG7};
char		vide[]="                    ";
char		vide2[]="                          ";
long		mem_res=-1,disk_res=-1;
int			old_s=-1;
DUREE		play_time;
char		pl_path[200],pl_name[14],*pl_nom;
int			var_cmd;
	
/* Global variables in assembler modules */

extern long Taille;
extern char	*Def_path;
extern int	type_machine;
extern int	fmt_end;
extern int	smt_end;
extern int	fmt_loop;
extern int	smt_loop;
extern char	fmt_taille;
extern char	fmt_songpos;
extern char	smt_taille;
extern char	smt_songpos;
extern long fmt_ecran;
extern long	smt_ecran;
extern int	smt_oscil;
extern int	fmt_oscil;
extern int  smt_vum;
extern int  fmt_vum;
extern int	fmt_heure,fmt_minute,fmt_seconde;
extern int  smt_heure,smt_minute,smt_seconde;
extern int  T_rout;

/* -------------------------------------------------------------------------------------------------------------------- */
/* Main code																											*/
/* -------------------------------------------------------------------------------------------------------------------- */

int main(int argc,char *argv[])
	{
	int		i,fin;
	int		mousex,mousey,dummy,event,key,state,nb_clicks;
	COOKIE	*cook;
	COOKIE	p_cook;

	id_appl=appl_init();

	/* ~~~~~~~~~~~~~~~~~~~ */
	/* verify machine type */
	/* ~~~~~~~~~~~~~~~~~~~ */
	
	cook=get_cookie('_SWI');
	if	((cook==NULL) || !(cook->v.l & BIT_7))
		{
		form_alert (1,"[3][    Ultimate TRACKER    | |This program need a|DMA soundchip !!!][ OK ]");
		if (!_app) evnt_timer(-1,-1);
		else {appl_exit();return -1;}
		}
	
	type_machine=0;
	cook=get_cookie('_MCH');
	if (cook->v.l==0x30000L) machine=MCH_FALCON;
	else if (cook->v.l==0x20000L) {machine=MCH_TT;type_machine=-1;}
	else if (cook->v.l==0x10010L) {machine=MCH_MEGA_STE;type_machine=1;}
	else machine=MCH_STE;

	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	/* Initialize frequency & oscillo */
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	
	smt_loop=fmt_loop=MOD_LOOP;

	switch(machine)
		{
		case MCH_FALCON: 
			 if	(freq_falcon()==MHZ_8) fmt_freq(old_freq=FREQ_12_5);
			 else fmt_freq(old_freq=FREQ_25);
			 fmt_io();
			 break;

		case MCH_MEGA_STE:
	   	     if (mode_68000()==DISABLED) smt_freq(old_freq=FREQ_12_5);
	   	     else smt_freq(old_freq=FREQ_25);
			 smt_io();
			 break;
			 
	    case MCH_STE:
			 smt_freq(old_freq=FREQ_12_5);
			 smt_io();
			 break;
			 
	    case MCH_TT:
			 smt_freq(old_freq=FREQ_25);
			 smt_io();
			 break;
		}

	/* ~~~~~~~~~~~~~~~~~~ */
	/* Memory Reservation */
	/* ~~~~~~~~~~~~~~~~~~ */

	mem_res=disk_res=Taille;

	if	(!_app)
		{
		if	((buffer=_malloc(mem_res))==NULL)
			{
			form_alert (1,"[3][    ULTIMATE TRACKER    | |Not enough memory to|reserve buffer|Remove accessories and TSR|and reboot.][ OK ]");
			evnt_timer(-1,-1);
			}
		}

	/* ~~~~~~~~~ */
	/* init. VDI */
	/* ~~~~~~~~~ */
	
	for (i=0;i<10;work_in[i++]=1);
	work_in[10]=2;
	gr_handle=graf_handle(&i,&i,&i,&i);
	v_opnvwk(work_in,&gr_handle,work_out);
	graf_mouse(ARROW,0);
	MULTITACHE=(_GemParBlk.global[1]==-1);
	if (_GemParBlk.global[0]>=0x400) shel_write(9,1,0,NULL,NULL);
	i=_GemParBlk.global[0]>0x320;

	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	/* determines resolution for resource */
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

	/* ---- less than 16 colours ---- */

	if	((work_out[13]<16) || (!i))
		{
		NB_COLOR=COLOR_MONO;
		rezol=(work_out[1]<399)+REZ_MONO;
		}
		
	/* ---- more than 16 colours ---- */
	
	else
		{
		NB_COLOR=COLOR_16;
		rezol=(work_out[1]<399)+REZ_16;
		}		

	/* ~~~~~~~~~~~~~ */
	/* init RESOURCE */
	/* ~~~~~~~~~~~~~ */

	if	(!rsrc_load("U_TRACK.RSC"))
		{
		form_alert (1,"[3][    ULTIMATE TRACKER    | |I can't find the RSC file|(U_TRACK.RSC)...][ OK ]");
		if (!_app) {Mfree(buffer);buffer=NULL;evnt_timer(-1,-1);}
		v_clsvwk(gr_handle);
		appl_exit();
		return -1;
		}
	init_arbre();

	/* ~~~~~~~~~~~~~~~~~~~~~~~ */
	/* Initialise default path */
	/* ~~~~~~~~~~~~~~~~~~~~~~~ */
	
	i=FALSE;

#ifdef TEST_DEBUG
	strcpy(Def_path,"C:\\ZAKOS\\MODULES\\*.MOD");
#endif

	Default_path=Def_path;
	if	(strlen(Default_path))
		{
		int	j;
		if  ((j=(int)Fopen(Default_path,FO_READ))!=-34)
			{
			i=TRUE;
			path[0]=0;
			strcpy(path,Default_path);
			}
		else Fclose(j);
		}

	if	(!i)
		{
		Default_path[0]=0;		
		path[0]=Dgetdrv()+'A';
		path[1]=':';
		Dgetpath(&path[2],0);
		strcat(path,"\\*.MOD");
		}

	/* ~~~~~~~~~~~~~~~~ */
	/* Init. DTA & time */
	/* ~~~~~~~~~~~~~~~~ */
	
	_dta=(DTA *)_malloc(sizeof(DTA));
	fmt_heure=fmt_minute=fmt_seconde=0;
	smt_heure=smt_minute=smt_seconde=0;

	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	/* If accessory -> installs in menu */
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	
	if	(!_app)
		{
		if 	((id_acc=menu_register(id_appl,"  Ultimate Tracker "))<0)
			{
			Mfree(buffer);
			buffer=NULL;
			rsrc_free();
			evnt_timer(-1,-1);
			}
		}
		
	/* ~~~~~~~~~~~~~ */
	/* installs MENU */
	/* ~~~~~~~~~~~~~ */
	
	else	
		{
		menu=adresse(MENU);
		menu_bar(menu,1);

	/* ~~~~~~~~~~~~~~~~~~~~~~~ */
	/* If PRG -> verify if TTP */ 
	/* ~~~~~~~~~~~~~~~~~~~~~~~ */
	
		if 	(argc==2) 
			{
			M_PLAY=TRUE;
			if 	(!ouvre_fenetre(FALSE)) {fin_programme();return -1;}
			if  (!load(TRUE,argv[1]))   {fin_programme();return -1;}
	 		}
	    }

	/* ~~~~~~~~~~~~~~~ */
	/* Installs cookie */
	/* ~~~~~~~~~~~~~~~ */
	
	p_cook.ident='UTRK';
	p_cook.v.i[0]=id_appl;
	if 	(add_cookie(&p_cook)==-1)
		{
		remove_cookie('UTRK');
		add_cookie(&p_cook);
		}

	/* ~~~~~~~~~~~~~~ */
	/* Desktop Coords */
	/* ~~~~~~~~~~~~~~ */

	wind_get(0,WF_WORKXYWH,&x_bureau,&y_bureau,&w_bureau,&h_bureau);

	/* ~~~~~~~~~~~~~ */
	/* Display infos */
	/* ~~~~~~~~~~~~~ */

	if	((_app) && (argc<2)) about();

	/* ~~~~~~~~~ */
	/* Main loop */
	/* ~~~~~~~~~ */
	
	fin=FALSE;
	while(!fin)
		{
		event=evnt_multi(MU_BUTTON|MU_MESAG|MU_TIMER|MU_KEYBD,2,1,1,0,0,0,0,0,0,0,0,0,0,
						  event_buffer,5,0,&mousex,&mousey,&dummy,
						  &state,&key,&nb_clicks);
		
		if (event & MU_MESAG) 	fin=gestion_evenement(event_buffer);
		if (event & MU_BUTTON) 	fin=gestion_panel(mousex,mousey,nb_clicks);
		if (event & MU_TIMER) 	gestion_timer();
		if (event & MU_KEYBD)	fin=gestion_clavier(key,state);	
		}

	/* ~~~~~~ */		
	/* Bye... */
	/* ~~~~~~ */
	
	fin_programme();
	return 0;
	}		

/* -------------------------------------------------------------------------------------------------------------------- */
/* Sous-progz																											*/
/* -------------------------------------------------------------------------------------------------------------------- */

/* ---------------------------------------------------------------- */
/* Open/Close Panel window											*/
/* ---------------------------------------------------------------- */

void panel(int flag)
	{
	switch(flag)
		{
		case OUVRE: if (!M_OPEN) ouvre_fenetre(TRUE);
					break;
		case FERME:	if (M_OPEN) ferme_fenetre();
					break;
		case SWITCH:if (!M_OPEN) ouvre_fenetre(TRUE);
					else ferme_fenetre();
					break;
		}
	}

/* ---------------------------------------------------------------- */
/* Open Tracker window												*/
/* ---------------------------------------------------------------- */

int ouvre_fenetre(int param)
	{
	char	*s;
	int		att;

	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	/* verify if the window is opened */
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	
	if	(M_OPEN) return TRUE;

	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	/* verify if a window is available */
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

	if 	(_app) att=NAME|MOVER|CLOSER;
	else att=NAME|MOVER;

	w_handle=wind_create(att,0,0,work_out[0],work_out[1]);
	if	(w_handle<0) 
		{
		form_alert (1,"[3][    ULTIMATE TRACKER    | |No more windows available|Please close one of|the opened windows.][ OK ]");
		return FALSE;
		}
	wind_set(w_handle,WF_NAME,titre,0,0);

	if 	(B_OSCILLO) oscilloscope(OUVRE); 
	if	(B_PLAYLIST) play_list(OUVRE);
	if	(B_VU_METRE) vu_metre(OUVRE);

	if	(M_RSC)
		{
		if (!param) return TRUE;
		opn_fenetre(att);
		return TRUE;
		}
	
	/* ~~~~~~~~~~~~~~~~~ */
	/* Installs resource */
	/* ~~~~~~~~~~~~~~~~~ */

	if 	(M_LOAD) (res+NOM)->ob_spec.tedinfo->te_ptext=buffer;
	else (res+NOM)->ob_spec.tedinfo->te_ptext=vide;
	if 	(_app) (res+FLUSH)->ob_state|=DISABLED;
	(res+LOOP)->ob_state=MOD_LOOP;
	if	(machine==MCH_FALCON) 
		{(res+F625)->ob_state|=DISABLED;
		if	(freq_falcon()==MHZ_8) (res+F50)->ob_state|=DISABLED;}
	if	(machine==MCH_STE) (res+F50)->ob_state|=DISABLED;
	if  (machine==MCH_MEGA_STE) (res+F50)->ob_state=mode_68000();
	(res+tab_freq[old_freq])->ob_state=SELECTED;
	(res+BITONIO)->ob_width=0;
	s=(res+PH1)->ob_spec.tedinfo->te_ptext;
	s[19]='0'+VERSION;
	s[21]='0'+NIVEAU;

#if SOUS_NIVEAU
	   s[22]='0'+SOUS_NIVEAU;
	   s[23]=' ';
	   s[24]=11;
#endif

	(res+NEXT_MOD)->ob_state|=DISABLED;
	(res+TNEXT_MOD)->ob_state|=DISABLED;
	(res+PREV_MOD)->ob_state|=DISABLED;
	(res+TPREV_MOD)->ob_state|=DISABLED;	

	M_RSC=TRUE;
	if	(!param) return TRUE;	
	opn_fenetre(att);
	return TRUE;
	}

void opn_fenetre(int att)
	{
	int	x,y,w,h,w_x,w_y,w_w,w_h;
	
	if 	(!F_OPEN) 
		{
		form_center(res,&x,&y,&w,&h);
		F_OPEN=TRUE;
		}
	else
		{
		x=(res)->ob_x;
		y=(res)->ob_y;
		w=(res)->ob_width;
		h=(res)->ob_height;
		}
    x=max(x,x_bureau);
    y=max(y,y_bureau);
    (res)->ob_x=x;(res)->ob_y=y;
	wind_calc(WC_BORDER,att,x,y,w,h,&w_x,&w_y,&w_w,&w_h);
	w_w--;
	graf_growbox(work_out[0]/2,work_out[1]/2,0,0,w_x,w_y,w_w,w_h);
	wind_update(BEG_UPDATE);
	form_dial(FMD_START,w_x,w_y,w_w,w_h,0,0,0,0);
	wind_open(w_handle,w_x,w_y,w_w,w_h);
	form_dial(FMD_FINISH,w_x,w_y,w_w,w_h,0,0,0,0);
	wind_update(END_UPDATE);
	M_OPEN=TRUE;
	send_shell(R_OPEN);
	}
	
/* ---------------------------------------------------------------- */
/* Close the tracker window		 									*/
/* ---------------------------------------------------------------- */

void ferme_fenetre(void)
	{
	int	x,y,w,h;

	if 	(!M_OPEN) return;
	M_OPEN=FALSE;
	wind_update(BEG_UPDATE);
	graf_mouse(M_OFF,0);
	wind_get(w_handle,WF_CURRXYWH,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,w,h,0,0,0,0);
	wind_close(w_handle);
	graf_shrinkbox(work_out[0]/2,work_out[1]/2,0,0,x,y,w,h);
	wind_delete(w_handle);
	graf_mouse(M_ON,0);
	form_dial(FMD_FINISH,x,y,w,h,0,0,0,0);
	wind_update(END_UPDATE);
	if (_app) menu_icheck(menu,WTRACK,FALSE);
 	w_handle=-1;
 	send_shell(R_CLOSE);
	}

/* ---------------------------------------------------------------- */
/* End of program													*/
/* ---------------------------------------------------------------- */

void fin_programme(void)
	{
	if 	(M_PLAY) stop();
	Mfree(_dta);
	if	(M_OSCILLO) oscilloscope(FERME);
	if  (M_LISTE) play_list(FERME);
	if  (M_VU_METRE) vu_metre(FERME);
	if 	(M_OPEN) ferme_fenetre();
	if	(!_app) {Mfree(buffer);buffer=NULL;return;}
	menu_bar(menu,0);
	send_shell(R_QUIT);
	remove_cookie('UTRK');
	rsrc_free();
	v_clsvwk(gr_handle);
	appl_exit();
	}

/* ------------------------------------------------------------------------- */
/* Open / Close PLAY LIST window									 		 */
/* ------------------------------------------------------------------------- */

void play_list(int flag)
	{
	switch(flag)
		{
		case OUVRE: if (!M_LISTE) open_pliste();
					break;
		case FERME:	if (M_LISTE) close_pliste();
					break;
		case SWITCH:if (!M_LISTE) open_pliste();
					else close_pliste();
					break;
		}
	}

/* Open window */

void open_pliste(void)
	{
	int	x,y,w,h;
	int wx,wy,ww,wh;

	/* Init. window */
	
	init_pliste();

#if defined NO_SORT
	(rlis+SORT)->ob_state|=DISABLED;
#endif

	w_h_liste=wind_create(NAME|MOVER|CLOSER,0,0,work_out[0],work_out[1]);
	if	(w_h_liste<=0) form_alert (1,"[3][    ULTIMATE TRACKER    | |No more windows available|Please close one of|the opened windows.][ OK ]");
	wind_set(w_h_liste,WF_NAME,titre_pliste,0,0);
	if	(!IF_OPEN_LISTE)
		{
		form_center(rlis,&x,&y,&w,&h);
		IF_OPEN_LISTE=TRUE;
		}
	else
		{
		x=(rlis)->ob_x;
		y=(rlis)->ob_y;
		w=(rlis)->ob_width;
		h=(rlis)->ob_height;
		}
	x=max(x,x_bureau);
	y=max(y,y_bureau);
    (rlis)->ob_x=x;(rlis)->ob_y=y;
	wind_calc(WC_BORDER,NAME|MOVER|CLOSER,x,y,w,h,&wx,&wy,&ww,&wh);
	graf_growbox(work_out[0]/2,work_out[1]/2,0,0,wx,wy,ww,wh);
	wind_update(BEG_UPDATE);
	form_dial(FMD_START,wx,wy,ww,wh,0,0,0,0);
	wind_open(w_h_liste,wx,wy,ww,wh);
	form_dial(FMD_FINISH,wx,wy,ww,wh,0,0,0,0);
	wind_update(END_UPDATE);
	M_LISTE=TRUE;
	if (_app) menu_icheck(menu,WLISTE,TRUE);
	redessine(res,PLAYLIST,SELECTED);
	send_shell(R_OPN_PLAYLIST);
	}

/* Close window */

void close_pliste(void)
	{
	int	x,y,w,h;

	M_LISTE=FALSE;
	wind_update(BEG_UPDATE);
	graf_mouse(M_OFF,0);
	wind_get(w_h_liste,WF_CURRXYWH,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,w,h,0,0,0,0);
	wind_close(w_h_liste);
	graf_shrinkbox(work_out[0]/2,work_out[1]/2,0,0,x,y,w,h);
	wind_delete(w_h_liste);
	graf_mouse(M_ON,0);
	form_dial(FMD_FINISH,x,y,w,h,0,0,0,0);
	wind_update(END_UPDATE);
	redessine2(res,PLAYLIST,NORMAL);
	if (_app) menu_icheck(menu,WLISTE,FALSE);
	w_h_liste=-1;
	send_shell(R_CLS_PLAYLIST);
	}

/* Display module list */

void affiche_liste(int debut,int flag)
	{
	LISTE_MOD	*inter;
	int			i,j;

	if	((mod_select>=debut) && (mod_select<=debut+7)) ligne_select=mod_select-debut;
	else ligne_select=-1;
	inter=liste;
	for	(i=1;i<debut;i++) inter=inter->suivant;
	i=0;
	while ((inter!=NULL) && (i<7))	
		{
		char *s=(rlis+tab_lig[i])->ob_spec.tedinfo->te_ptext;
		strcpy(s,vide2);
		strcpy(&s[2],strrchr(inter->nom,'\\')+1);
		s[strlen(s)]=' ';
		if (M_PLAY)
		   {if (debut+i==cur_mod_play) s[0]=0xb;}	
		if (i==ligne_select) (rlis+tab_lig[i])->ob_state|=SELECTED;
		else (rlis+tab_lig[i])->ob_state=NORMAL;
		if (flag) maj(rlis,tab_lig[i]);
		i++;
		inter=inter->suivant;
		}
	for	(j=i;j<7;j++)
		{
		(rlis+tab_lig[j])->ob_state=NORMAL;
		strcpy((rlis+tab_lig[j])->ob_spec.tedinfo->te_ptext,vide2);
		if (flag) maj(rlis,tab_lig[j]);
		}
	}

/* Init. PLAY LIST */

void init_pliste()
	{
	affiche_liste(deb_liste_visu,FALSE);
	digit3((rlis+NBTOTAL)->ob_spec.tedinfo->te_ptext,nb_mod_play,'0');
	if	(M_PLAY) digit3((rlis+PLAYING)->ob_spec.tedinfo->te_ptext,cur_mod_play,0x10);
	if	(LOOP_LISTE) redes_icon(rlis,BREPEAT,ICREPEAT,SELECTED);
	else redes_icon(rlis,BREPEAT,ICREPEAT,NORMAL);
	redessine2(rlis,UP_LIST,DISABLED);
	redessine2(rlis,UP_LIST10,DISABLED);
	if (nb_mod_play<=7)	{redessine2(rlis,DOWN_LIST,DISABLED);redessine2(rlis,DOWN_LIST10,DISABLED);}
	else {redessine2(rlis,DOWN_LIST,NORMAL);redessine2(rlis,DOWN_LIST10,NORMAL);}
	if (mod_select==-1) redes_icon2(rlis,BREMOVE,ICREMOVE,TREMOVE,DISABLED);
	else redes_icon2(rlis,BREMOVE,ICREMOVE,TREMOVE,NORMAL);
	if 	(nb_mod_play<=0) 
		{
		redes_icon2(rlis,BADD,ICADD,TADD,DISABLED); 
		redes_icon2(rlis,BNEW,ICNEW,TNEW,DISABLED); 
		redes_icon2(rlis,BSAVE,ICSAVE,TSAVE,DISABLED); 
		}
	else 
		{
		redes_icon2(rlis,BADD,ICADD,TADD,NORMAL);
		redes_icon2(rlis,BNEW,ICNEW,TNEW,NORMAL); 
		redes_icon2(rlis,BSAVE,ICSAVE,TSAVE,NORMAL); 
		}
	}
	
/* ------------------------------------------------------------------------ */
/* Open / Close oscilloscope window					 						*/
/* ------------------------------------------------------------------------ */

void oscilloscope(int flag)
	{
	switch(flag)
		{
		case OUVRE:	if (!M_OSCILLO) open_oscillo();
					break;
		case FERME: if (M_OSCILLO) close_oscillo();
					break;
		case SWITCH:if (!M_OSCILLO) open_oscillo();
					else close_oscillo();
					break;
		}
	}

/* Open window */

void open_oscillo(void)
	{
	int	x,y,w,h;
	int wx,wy,ww,wh;

	if (NO_ANIMATION) return;
	w_h_oscillo=wind_create(NAME|MOVER|CLOSER,0,0,work_out[0],work_out[1]);
	if	(w_h_oscillo<=0) form_alert (1,"[3][    ULTIMATE TRACKER    | |No more windows available|Please close one of|the opened windows.][ OK ]");
	wind_set(w_h_oscillo,WF_NAME,titre_oscillo,0,0);
	if	(!IF_OPEN)
		{
		form_center(ros,&x,&y,&w,&h);
		IF_OPEN=TRUE;
		}
	else
		{
		x=(ros)->ob_x;
		y=(ros)->ob_y;
		w=(ros)->ob_width;
		h=(ros)->ob_height;
		}
	x=max(x,x_bureau);
	y=max(y,y_bureau);
    (ros)->ob_x=x;(ros)->ob_y=y;
	wind_calc(WC_BORDER,NAME|MOVER|CLOSER,x,y,w,h,&wx,&wy,&ww,&wh);
	graf_growbox(work_out[0]/2,work_out[1]/2,0,0,wx,wy,ww,wh);
	wind_update(BEG_UPDATE);
	form_dial(FMD_START,wx,wy,ww,wh,0,0,0,0);
	wind_open(w_h_oscillo,wx,wy,ww,wh);
	form_dial(FMD_FINISH,wx,wy,ww,wh,0,0,0,0);
	wind_update(END_UPDATE);
	if (machine==MCH_FALCON) fmt_oscil=TRUE;
	else smt_oscil=TRUE;
	M_OSCILLO=TRUE;
	if (_app) menu_icheck(menu,WOSCILLO,TRUE);
	if (NB_COLOR==COLOR_16) redes_icon(res,BOSCILLO,ICOSCILL,SELECTED);
	send_shell(R_OPN_OSCILLO);
	}

/* Close window */

void close_oscillo(void)
	{
	int	x,y,w,h;

	M_OSCILLO=FALSE;
	wind_update(BEG_UPDATE);
	graf_mouse(M_OFF,0);
	wind_get(w_h_oscillo,WF_CURRXYWH,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,w,h,0,0,0,0);
	wind_close(w_h_oscillo);
	graf_shrinkbox(work_out[0]/2,work_out[1]/2,0,0,x,y,w,h);
	wind_delete(w_h_oscillo);
	graf_mouse(M_ON,0);
	form_dial(FMD_FINISH,x,y,w,h,0,0,0,0);
	wind_update(END_UPDATE);
	if (machine==MCH_FALCON) fmt_oscil=FALSE;
	else smt_oscil=FALSE;
	if (NB_COLOR==COLOR_16) redes_icon(res,BOSCILLO,ICOSCILL,NORMAL);
	if (_app) menu_icheck(menu,WOSCILLO,FALSE);
	w_h_oscillo=-1;
	send_shell(R_CLS_OSCILLO);
	}

/* ------------------------------------------------------------------------- */
/* Open / Close the vu-meter window				 							 */
/* ------------------------------------------------------------------------- */

void vu_metre(int flag)
	{
	switch(flag)
		{
		case OUVRE:	if (!M_VU_METRE) open_vu_metre();
					break;
		case FERME: if (M_VU_METRE) close_vu_metre();
					break;
		case SWITCH:if (!M_VU_METRE) open_vu_metre();
					else close_vu_metre();
					break;
		}
	}

/* Open window */

void open_vu_metre(void)
	{
	int	x,y,w,h;
	int wx,wy,ww,wh;

	if (NO_ANIMATION) return;
	w_h_vu_metre=wind_create(NAME|MOVER|CLOSER|INFO,0,0,work_out[0],work_out[1]);
	if	(w_h_vu_metre<=0) form_alert (1,"[3][    ULTIMATE TRACKER    | |No more windows available|Please close one of|the opened windows.][ OK ]");
	wind_set(w_h_vu_metre,WF_NAME,titre_vu_metre,0,0);
	wind_set(w_h_vu_metre,WF_INFO,info_vu_metre,0,0);
	if	(!IF_OPEN_VUM)
		{
		x=(work_out[0]/2)-88;
		y=(work_out[1]/2)-24;
		w=176;
		h=48;
		IF_OPEN_VUM=TRUE;
		}
	else
		{
		x=px_vm;
		y=py_vm;
		w=176;
		h=48;
		}
	wind_calc(WC_BORDER,NAME|MOVER|CLOSER|INFO,x,y,w,h,&wx,&wy,&ww,&wh);
	graf_growbox(work_out[0]/2,work_out[1]/2,0,0,wx,wy,ww,wh);
	graf_mouse(M_OFF,0);
	wind_update(BEG_UPDATE);
	form_dial(FMD_START,wx,wy,ww,wh,0,0,0,0);
	wind_open(w_h_vu_metre,wx,wy,ww,wh);
	form_dial(FMD_FINISH,wx,wy,ww,wh,0,0,0,0);
	wind_update(END_UPDATE);
	graf_mouse(M_ON,0);
	if (machine==MCH_FALCON) fmt_vum=TRUE;
	else smt_vum=TRUE;
	M_VU_METRE=TRUE;
	if (_app) menu_icheck(menu,WVUMETRE,TRUE);
	if (NB_COLOR==COLOR_16) redessine(res,BSPEKTRU,SELECTED);
	send_shell(R_OPN_VUM);
	}

/* Close window */

void close_vu_metre(void)
	{
	int	x,y,w,h,dummy;

	M_VU_METRE=FALSE;
	wind_update(BEG_UPDATE);
	graf_mouse(M_OFF,0);
	wind_get(w_h_vu_metre,WF_WORKXYWH,&px_vm,&py_vm,&dummy,&dummy);
	wind_get(w_h_vu_metre,WF_CURRXYWH,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,w,h,0,0,0,0);
	wind_close(w_h_vu_metre);
	graf_shrinkbox(work_out[0]/2,work_out[1]/2,0,0,x,y,w,h);
	wind_delete(w_h_vu_metre);
	graf_mouse(M_ON,0);
	form_dial(FMD_FINISH,x,y,w,h,0,0,0,0);
	wind_update(END_UPDATE);
	if (machine==MCH_FALCON) fmt_vum=FALSE;
	else smt_vum=FALSE;
	if (NB_COLOR==COLOR_16) redessine(res,BSPEKTRU,NORMAL);
	if (_app) menu_icheck(menu,WVUMETRE,FALSE);
	w_h_vu_metre=-1;
	send_shell(R_CLS_VUM);
	}

/* ---------------------------------------------------------------- */
/* Sous-progz AES													*/
/* ---------------------------------------------------------------- */

/* ~~~~~~~~~~~~~~~~~~~~~~~~ */
/* Init. resource addresses */
/* ~~~~~~~~~~~~~~~~~~~~~~~~ */

void init_arbre(void)
	{
	int	i;

	switch(rezol)
		{
		case REZ_16:		res=adresse(FEN16);
							ros=adresse(OSC16);
							rlis=adresse(LIST16);
							break;

		case REZ_LOW_16:	res=adresse(FENLOW16);
							ros=adresse(OSC16);
							(ros)->ob_height+=32;
							(ros+OSC_FOND)->ob_height+=32;
							rlis=adresse(LISTLOW16);
							break;

		case REZ_MONO:		res=adresse(FENMONO);
							ros=adresse(OSCMONO);
							for (i=0;i<14;i+=2) 
								{
								(res+tab_icone[i])->ob_height=(res+tab_icone[i+1])->ob_height;
								(res+tab_icone[i])->ob_width=(res+tab_icone[i+1])->ob_width;																								
								}
							rlis=adresse(LISTMONO);
							break;

		case REZ_LOW_MONO:	res=adresse(FENLOWM);
							ros=adresse(OSCMONO);
							(ros)->ob_height+=32;
							(ros+OSC_FOND)->ob_height+=32;
							for (i=0;i<14;i+=2) 
								{
								(res+tab_icone[i])->ob_height=(res+tab_icone[i+1])->ob_height;
								(res+tab_icone[i])->ob_width=(res+tab_icone[i+1])->ob_width;																								
								}
							rlis=adresse(LISTLOWM);
							break;
		}

	}

/* ~~~~~~~~~~~~~~ */
/* Object address */
/* ~~~~~~~~~~~~~~ */

OBJECT	*adresse(int n_arbre)
	{
	OBJECT	*ret;
	rsrc_gaddr(0,n_arbre,&ret);
	return ret;
	}
	
/* ~~~~~~~~~~~~~ */
/* redraw object */
/* ~~~~~~~~~~~~~ */

void maj(OBJECT *a,int o)
	{
	if (a==res)	{if (M_OPEN) _objc_draw(a,o,32000,0,0,0,0,w_handle,TRUE);}
	if (a==ros) {if (M_OSCILLO) _objc_draw(a,o,32000,0,0,0,0,w_h_oscillo,TRUE);}
	if (a==rlis){if (M_LISTE) _objc_draw(a,o,32000,0,0,0,0,w_h_liste,TRUE);}
	}

void maj_dial(OBJECT *a,int o)
	{
	objc_draw(a,o,32000,0,0,work_out[0],work_out[1]);
	}
	
void maj_no_mouse(OBJECT *a,int o)
	{
	if (a==res)	{if (M_OPEN) _objc_draw(a,o,32000,0,0,0,0,w_handle,FALSE);}
	if (a==ros) {if (M_OSCILLO) _objc_draw(a,o,32000,0,0,0,0,w_h_oscillo,FALSE);}
	if (a==rlis){if (M_LISTE) _objc_draw(a,o,32000,0,0,0,0,w_h_liste,FALSE);}
	}
	
/* ~~~~~~ */
/* Redraw */
/* ~~~~~~ */

void redessine(OBJECT *a,int o,int etat)
	{
	if	(!etat) (a+o)->ob_state=NORMAL;
	else (a+o)->ob_state|=etat;
	if (a==res)	{if (M_OPEN) _objc_draw(a,o,1,0,0,0,0,w_handle,TRUE);}
	if (a==ros) {if (M_OSCILLO) _objc_draw(a,o,1,0,0,0,0,w_h_oscillo,TRUE);}
	if (a==rlis){if (M_LISTE) _objc_draw(a,o,1,0,0,0,0,w_h_liste,TRUE);}
	}

void redessine_dial(OBJECT *a,int o,int etat)
	{
	if (!etat) (a+o)->ob_state=NORMAL;
	else (a+o)->ob_state|=etat;
	objc_draw(a,o,1,0,0,work_out[0],work_out[1]);
	}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* Redraw according the machine */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

void redessine2(OBJECT *a,int o,int etat)
	{
	if (NB_COLOR==COLOR_16) (a+o)->ob_state=etat;
	else (a+o)->ob_state=etat+SHADOWED+OUTLINED;
	if (a==res) {if (M_OPEN) _objc_draw(a,o,1,0,0,0,0,w_handle,TRUE);}
	if (a==ros) {if (M_OSCILLO) _objc_draw(a,o,1,0,0,0,0,w_h_oscillo,TRUE);}
	if (a==rlis) {if (M_LISTE) _objc_draw(a,o,1,0,0,0,0,w_h_liste,TRUE);}
	}
	
/* ~~~~~~~~~~~~~~~~ */
/* Redraw with icon */
/* ~~~~~~~~~~~~~~~~ */

void redes_icon(OBJECT *a,int obj,int icn,int etat)
	{
	if	(NB_COLOR==COLOR_16) redessine(a,obj,etat);
	else
		{
		(a+icn)->ob_state=etat;
		redessine(a,obj,SHADOWED+OUTLINED);
		}
	}

/* ~~~~~~~~~~~~~~~~~~ */
/* Same but with text */
/* ~~~~~~~~~~~~~~~~~~ */

void redes_icon2(OBJECT *a,int obj,int icn,int txt,int etat)
	{
	if	(NB_COLOR==COLOR_16) redessine(a,obj,etat);
	else
		{
		(a+icn)->ob_state=(a+txt)->ob_state=etat;
		redessine(a,obj,SHADOWED+OUTLINED);
		}
	}

/* ~~~~~~~~~~~~~~~~~~~ */
/* Keyboard management */
/* ~~~~~~~~~~~~~~~~~~~ */

int	gestion_clavier(int key,int state)
	{
	KEYTAB	*clavier;

	/* Verify ALT is pressed */
	
	if	( (!(state & K_ALT)) && (!(state & K_CTRL)) ) return FALSE;

	/* Read the key */
	
	clavier=Keytbl((void *)-1,(void *)-1,(void *)-1);
	
	/* selection + ALT */
	
	if	(state & K_ALT)
		{
		switch((clavier->shift)[(char)(key>>8)])
			{
			case 'L':	load(FALSE,NULL);
						break;
			case 'Q':	return confirm_quit();
			case 'E':   play_list(SWITCH);
						break;
			case 'P':   panel(SWITCH);
						break;
			case 'O':   oscilloscope(SWITCH);
						break;
			case 'V':   vu_metre(SWITCH);
						break;
			case 'C':   mod_mem();
						break;
			case 'F':	if (!_app) flush();
						break;
			}			
		}
		
	/* selection + CTRL */
	
	if	(state & K_CTRL)
		{
		switch((clavier->shift)[(char)(key>>8)])
			{
			case 'W':	next_win();
						break;
			case 'I':	about();
						break;
			}
		}

	return FALSE;
	}

/* ~~~~~~~~~~~~~~ */
/* Window Cycling */
/* ~~~~~~~~~~~~~~ */					

void next_win(void)
	{
	int	tab_win[8];
	int	cw;
	int	dummy=0,i,j,trouve=FALSE;
	
	/* Init. window array */
	
	tab_win[0]=tab_win[4]=w_handle;
	tab_win[1]=tab_win[5]=w_h_oscillo;
	tab_win[2]=tab_win[6]=w_h_vu_metre;
	tab_win[3]=tab_win[7]=w_h_liste;	
	
	/* Active window */
	
	wind_get(dummy,WF_TOP,&cw,&dummy,&dummy,&dummy);

	/* Search for the window in the array */

	i=0;
	while ((i<4) && (!trouve))
		{
		if (tab_win[i++]==cw) trouve=TRUE;
		}

	if (!trouve) j=0;
	else j=i;
	
	trouve=FALSE;

	while ((j<7) && (!trouve))
		{
		if (tab_win[j++]!=-1) trouve=TRUE;
		}
	
	j--;	
	if (trouve) wind_set(tab_win[j],WF_TOP,0,0,0,0);
	send_shell(R_CYCLE_WIN);
	}

/* ~~~~~~~~~~~~~~~~ */
/* Event management */
/* ~~~~~~~~~~~~~~~~ */

int gestion_evenement(int evt[])
	{
	int	dummy;

	switch(evt[0])
		{
		case T_ABOUT:	about();
						break;
		case T_PLAY:	play();
						break;
		case T_LOAD:	{
						char *pm;
						long ad2;

						ad2=evt[4];
						ad2=swap(ad2);
						(int)ad2=evt[3];
						pm=(char *)ad2;
						strupr(pm);
						load(TRUE,pm);
						}
						break;
		case T_REWIND:	_rewind();
						break;
		case T_FORWARD:	forward();
						break;
		case T_PAUSE:	pause();
						break;
		case T_STOP:	stop();
						break;
		case T_OPEN:	panel(OUVRE);
						break;
		case T_CLOSE:	panel(FERME);
						break;
		case T_FREQ:    change_frequence(evt[3]);
						break;
		case T_LOOP:	change_loop();
						break;
		case T_IDENT:	ID_SHELL=evt[1];
						break;
		case T_FIDENT:	ID_SHELL=-1;
						break;
		case T_INFOS:	send_shell(R_INFOS);
						break;
		case T_OPN_OSCILLO:
						oscilloscope(OUVRE);
						break;
		case T_CLS_OSCILLO: oscilloscope(FERME);
						break;
		case T_NEXT_MOD:next_mod();
						break;
		case T_PREV_MOD:previous_mod();
						break;
		case T_OPN_PLAYLIST:
						play_list(OUVRE);
						break;
		case T_CLS_PLAYLIST:
						play_list(FERME);
						break;
	    case T_OPN_VUM:	vu_metre(OUVRE);
	    				break;
	    case T_CLS_VUM: vu_metre(FERME);
	    				break;
		case T_SEL_PLST:plst_lig(FALSE,evt[3],1);
						break;
		case T_REMOVE_PLST:
						plst_remove(FALSE);
						break;
		case T_ADD_PLST:	
						{
						char *pm;
						long ad2;

						ad2=evt[4];
						ad2=swap(ad2);
						(int)ad2=evt[3];
						pm=(char *)ad2;
						strupr(pm);				
						plst_add(FALSE,pm);
						(FALSE,pm);
						}
						break;
		case T_NEW_PLST:plst_new(FALSE);
						break;
		case T_LOAD_PLST:
						{
						char *pm;
						long ad2;

						ad2=evt[4];
						ad2=swap(ad2);
						(int)ad2=evt[3];
						pm=(char *)ad2;
						strupr(pm);
						plst_load(FALSE,pm);
						}
						break;
		case T_SAVE_PLST:
						{
						char *pm;
						long ad2;

						ad2=evt[4];
						ad2=swap(ad2);
						(int)ad2=evt[3];
						pm=(char *)ad2;
						strupr(pm);
						plst_save(FALSE,pm);
						}
						break;
		case T_LOOP_PLST:
						plst_loop(FALSE);
						break;
		case T_TIME_PLST:
						plst_time(FALSE,evt[3],evt[4],evt[5]);
						break;
		case T_CYCLE_WIN:
						next_win();
						break;
		case T_PLAYLIST:
						send_shell(R_PLAYLIST);
						break;
		case WM_MOVED:	
 			 if	(evt[3]==w_handle)
 			 	{
				wind_set(w_handle,WF_CURRXYWH,evt[4],evt[5],evt[6],evt[7]);
				wind_get(w_handle,WF_WORKXYWH,&(res->ob_x),&(res->ob_y),&dummy,&dummy);
				send_shell(R_MOVE);
				}
			if	(evt[3]==w_h_oscillo)
				{
				wind_set(w_h_oscillo,WF_CURRXYWH,(evt[4]/16)*16,evt[5],evt[6],evt[7]);
				wind_get(w_h_oscillo,WF_WORKXYWH,&(ros->ob_x),&(ros->ob_y),&dummy,&dummy);
				send_shell(R_MOVE_OSCILLO);
				}
			if	(evt[3]==w_h_liste)
				{
				wind_set(w_h_liste,WF_CURRXYWH,evt[4],evt[5],evt[6],evt[7]);
				wind_get(w_h_liste,WF_WORKXYWH,&(rlis->ob_x),&(rlis->ob_y),&dummy,&dummy);
				send_shell(R_MOVE_PLAYLIST);
				}
			if	(evt[3]==w_h_vu_metre)
				{
				wind_set(w_h_vu_metre,WF_CURRXYWH,(evt[4]/16)*16,evt[5],evt[6],evt[7]);
				wind_get(w_h_vu_metre,WF_WORKXYWH,&px_vm,&py_vm,&dummy,&dummy);
				send_shell(R_MOVE_VUM);
				}
      		break;
		
		case WM_REDRAW:	
			 if	(evt[3]==w_handle)
				do_redraw(w_handle,res,evt[4],evt[5],evt[6],evt[7]);
			 if (evt[3]==w_h_oscillo)
			 	do_redraw_oscillo(evt[4],evt[5],evt[6],evt[7],TRUE);
			 if (evt[3]==w_h_liste)
			 	do_redraw(w_h_liste,rlis,evt[4],evt[5],evt[6],evt[7]);
			 if (evt[3]==w_h_vu_metre)
			 	do_redraw_vu_metre(evt[4],evt[5],evt[6],evt[7]);
			 break;

		case WM_CLOSED:
			 if (evt[3]==w_h_oscillo)
			 	oscilloscope(FERME);
			 if (evt[3]==w_handle)
			 	ferme_fenetre();
			 if (evt[3]==w_h_liste)
			 	play_list(FERME);
			 if (evt[3]==w_h_vu_metre)
			 	vu_metre(FERME);
			 break;

		case WM_TOPPED:	
			 if	(evt[3]==w_handle)
				wind_set(w_handle,WF_TOP,0,0,0,0);
			 if (evt[3]==w_h_oscillo)
			 	wind_set(w_h_oscillo,WF_TOP,0,0,0,0);
			 if (evt[3]==w_h_liste)
			    wind_set(w_h_liste,WF_TOP,0,0,0,0);
			 if (evt[3]==w_h_vu_metre)
			    wind_set(w_h_vu_metre,WF_TOP,0,0,0,0);
			 send_shell(R_CYCLE_WIN);
			 break;
							
		case MN_SELECTED:
			 menu_tnormal(menu,evt[3],1);
			 switch(evt[4])
			 	{
			 	case MQUIT1:return confirm_quit();
			 	case MLOAD: load(FALSE,NULL);
			 				break;
			 	case MABOUT:about();
			 				break;
			 	case WTRACK:
			 				if (!M_OPEN) ouvre_fenetre(TRUE);
			 				else ferme_fenetre();
	 		 				break;
			 	case WOSCILLO:
			 				oscilloscope(SWITCH);
			 				break;
			 	case WLISTE:
			 				play_list(SWITCH);
			 				break;
			 	case WVUMETRE:
			 				vu_metre(SWITCH);
			 				break;
				case WCONFIGURE:
							mod_mem();
							break;
				case WCYCLE:
							next_win();
							break;
			 	}
			 break;
		
		case AC_CLOSE:
			 if (evt[3]==id_acc)
			 	{
			 	B_OSCILLO=M_OSCILLO;
			 	B_PLAYLIST=M_LISTE;
				B_VU_METRE=M_VU_METRE;
			 	play_list(FERME);
			 	oscilloscope(FERME);
			 	vu_metre(FERME);
			 	ferme_fenetre();
			 	}
			 break;

		case AC_OPEN:
			 if (FORBIDDEN) break;
			 if (evt[4]==id_acc) 
			 	{
			 	if 	(M_OPEN)
			 		{
			 		int	dummy,wt;
			 		
			 		wind_get(w_handle,WF_TOP,&wt,&dummy,&dummy,&dummy);
			 		if ((wt!=w_handle) && (wt!=w_h_oscillo) && (wt!=w_h_liste) && (wt!=w_h_vu_metre))
			 		   {	
			 		   if (M_LISTE) wind_set(w_h_liste,WF_TOP,0,0,0,0);
					   if (M_OSCILLO) wind_set(w_h_oscillo,WF_TOP,0,0,0,0);
					   if (M_VU_METRE) wind_set(w_h_vu_metre,WF_TOP,0,0,0,0);
					   wind_set(w_handle,WF_TOP,0,0,0,0);
			 		   }			 	
					break;
			 		}
			 	}
			 ouvre_fenetre(TRUE);
			 break;

		case AP_TERM:			/* It seems that I never receive this message ! why ??? */
			 stop();
			 oscilloscope(FERME);
			 play_list(FERME);
			 vu_metre(FERME);
			 ferme_fenetre();
			 return TRUE;

		case BEG_LOAD:
			 l_module(FALSE);
			 break;
			 
		case BEG_LOAD2:
			 l_module(TRUE);
			 break;
			 
		case END_LOAD:
			 fin_load();
			 break;

		case BEG_LOAD_PLST:
			 l_playlist();
			 break;
			 
		case BEG_SAVE_PLST:
			 s_playlist();
			 break;
		}
	return FALSE;
	}

/* ~~~~~~~~~~~~~~~~~~~~~ */
/* Redraw panel/playlist */
/* ~~~~~~~~~~~~~~~~~~~~~ */
	
void do_redraw(int handle_window,OBJECT *obj,int xc,int yc,int wc,int hc)
	{
	GRECT	t1,t2;
	
	graf_mouse(M_OFF,0);
	wind_update(BEG_UPDATE);
	t2.g_x=xc;t2.g_y=yc;t2.g_w=wc;t2.g_h=hc;
	wind_get(handle_window,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	while (t1.g_w && t1.g_h)
		{
		if	(rc_intersect(&t1,&t2))
			{
			objc_draw(obj,0,10,t1.g_x,t1.g_y,t1.g_w,t1.g_h);
			}
		wind_get(handle_window,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
		}
	wind_update(END_UPDATE);
	graf_mouse(M_ON,0);
	}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* Redraw for l'oscilloscope / vu_metre */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

void do_redraw_oscillo(int xc,int yc,int wc,int hc,int flag_rsc)
	{
	GRECT	t1,t2;
	int		tab_clip[4];
	
	wind_update(BEG_UPDATE);
	t2.g_x=xc;t2.g_y=yc;t2.g_w=wc;t2.g_h=hc;
	wind_get(w_h_oscillo,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	while (t1.g_w && t1.g_h)
		{
		if	(rc_intersect(&t1,&t2))
			{
			if 	(flag_rsc) 
				{
				graf_mouse(M_OFF,0);
				objc_draw(ros,0,10,t1.g_x,t1.g_y,t1.g_w,t1.g_h);
				graf_mouse(M_ON,0);
				}
			tab_clip[0]=tab_clip[2]=t1.g_x;
			tab_clip[1]=tab_clip[3]=t1.g_y;
			tab_clip[2]+=t1.g_w;
			tab_clip[3]+=t1.g_h;
			vs_clip(gr_handle,TRUE,tab_clip);
			affiche_oscillo();
			vs_clip(gr_handle,FALSE,tab_clip);
			}
		wind_get(w_h_oscillo,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
		}
	wind_update(END_UPDATE);
	}

/* ~~~~~~~~~~~~~~~~~~~ */
/* Redraw for vu-meter */
/* ~~~~~~~~~~~~~~~~~~~ */

void do_redraw_vu_metre(int xc,int yc,int wc,int hc)
	{
	GRECT	t1,t2;
	int		tab_clip[4];
	
	wind_update(BEG_UPDATE);
	t2.g_x=xc;t2.g_y=yc;t2.g_w=wc;t2.g_h=hc;
	wind_get(w_h_vu_metre,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	while (t1.g_w && t1.g_h)
		{
		if	(rc_intersect(&t1,&t2))
			{
			tab_clip[0]=tab_clip[2]=t1.g_x;
			tab_clip[1]=tab_clip[3]=t1.g_y;
			tab_clip[2]+=t1.g_w-1;
			tab_clip[3]+=t1.g_h-1;
			vs_clip(gr_handle,TRUE,tab_clip);
			affiche_vu_metre();
			vs_clip(gr_handle,FALSE,tab_clip);
			}
		wind_get(w_h_vu_metre,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
		}
	wind_update(END_UPDATE);
	}

/* ~~~~~~~~~~~~~~ */
/* Partial redraw */
/* ~~~~~~~~~~~~~~ */

void _objc_draw(OBJECT *arbre,int obj,int prof,int xc,int yc,int wc,int hc,int h_w,int flag)
	{
	GRECT	t1,t2;
	
	objc_offset(arbre,obj,&xc,&yc);
	wc=(arbre+obj)->ob_width;
	hc=(arbre+obj)->ob_height;
	if (((arbre+obj)->ob_flags) & BIT_9) 	/* … cause du relief ! */
	   {
	   xc-=3;
	   yc-=3;
	   hc+=6;
	   wc+=6;
	   }	
	
	if (flag) graf_mouse(M_OFF,0);
	wind_update(BEG_UPDATE);
	t2.g_x=xc;t2.g_y=yc;t2.g_w=wc;t2.g_h=hc;
	wind_get(h_w,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	while (t1.g_w && t1.g_h)
		{
		if	(rc_intersect(&t1,&t2))
			objc_draw(arbre,obj,prof,t1.g_x,t1.g_y,t1.g_w,t1.g_h);
		wind_get(h_w,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
		}
	wind_update(END_UPDATE);
	if (flag) graf_mouse(M_ON,0);
	}

/* ~~~~~~~~~~~~~~~~~~~~ */
/* search intersections */
/* ~~~~~~~~~~~~~~~~~~~~ */
	
int	rc_intersect(GRECT *r1,GRECT *r2 )
	{
	int		x, y, w, h;

	x = max( r2->g_x, r1->g_x );
	y = max( r2->g_y, r1->g_y );
	w = min( r2->g_x + r2->g_w, r1->g_x + r1->g_w );
	h = min( r2->g_y + r2->g_h, r1->g_y + r1->g_h );

	r1->g_x = x;
	r1->g_y = y;
	r1->g_w = w - x;
	r1->g_h = h - y;

	return ( ((w > x) && (h > y) ) );
	}

/* ~~~~~~~~~~ */
/* About .... */
/* ~~~~~~~~~~ */

void about(void)
	{
	int		x,y,w,h,a;
	OBJECT	*about;
	char	*s;
	
	switch(rezol)
		{
		case REZ_16:		about=adresse(AB16);
							break;
		case REZ_LOW_16:	about=adresse(ABLOW16);
							break;
		case REZ_MONO: 		about=adresse(ABMON);
							break;
		case REZ_LOW_MONO:	about=adresse(ABLOWMON);
							break;
		}

	form_center(about,&x,&y,&w,&h);
	x=max(x,x_bureau);
	y=max(y,y_bureau);
    (about)->ob_x=x;(about)->ob_y=y;

	s=(about+AB_PH1)->ob_spec.tedinfo->te_ptext;
	s[8]='0'+VERSION;
	s[10]='0'+NIVEAU;

#if SOUS_NIVEAU
	s[11]='0'+SOUS_NIVEAU;
#else
	s[11]=' ';
#endif
	
	x-=3;
	y-=3;	/* thanks to Digital Research */
	w+=6;	
	h+=6;	
	
	graf_mouse(M_OFF,0);
	form_dial(FMD_START,x,y,w,h,x,y,w,h);
	wind_update(BEG_UPDATE);
	graf_growbox(work_out[0]/2,work_out[1]/2,0,0,x,y,w,h);
	objc_draw(about,0,10,x,y,w,h);
	graf_mouse(M_ON,0);
	a=form_do(about,0);
	form_dial(FMD_FINISH,x,y,w,h,x,y,w,h);
	wind_update(END_UPDATE);
	graf_shrinkbox(work_out[0]/2,work_out[1]/2,0,0,x,y,w,h);
	(about+a)->ob_state=NORMAL;
	}	

/* ~~~~~~~~~~~~~~~~~~~ */
/* Resource management */
/* ~~~~~~~~~~~~~~~~~~~~ */

/* Window management */

int	gestion_panel(int mx,int my,int nb_clicks)
	{
	int	hw,dummy=0;
	int	b;
	
	graf_mkstate(&dummy,&dummy,&b,&dummy);
	while (b>0) graf_mkstate(&dummy,&dummy,&b,&dummy);
	wind_get(dummy,WF_TOP,&hw,&dummy,&dummy,&dummy);
	if	(hw==w_handle) return gestion_trax(mx,my);
	if  (hw==w_h_liste) return gestion_pliste(mx,my,nb_clicks);
	return FALSE;
	}

/* PLAYLIST window management */

int gestion_pliste(int mx,int my,int nb_clicks)
	{
	int			a;
	
	if	(!M_LISTE) return FALSE;

	a=objc_find(rlis,0,10,mx,my);
	switch (a)
		{

		/* up in the list */

		case UP_LIST:	if ((rlis+UP_LIST)->ob_state & DISABLED) break;
						redessine2(rlis,UP_LIST,SELECTED);
						deb_liste_visu--;
						affiche_liste(deb_liste_visu,TRUE);
						redessine2(rlis,UP_LIST,NORMAL);
						if  (deb_liste_visu==1) 
							{
							redessine2(rlis,UP_LIST,DISABLED);
							redessine2(rlis,UP_LIST10,DISABLED);
							}
						if  ((rlis+DOWN_LIST)->ob_state & DISABLED)
							{
							redessine2(rlis,DOWN_LIST,NORMAL);
							redessine2(rlis,DOWN_LIST10,NORMAL);
							}
						break;
						
		/* down in the list */
						
		case DOWN_LIST:	if ((rlis+DOWN_LIST)->ob_state & DISABLED) break;
						redessine2(rlis,DOWN_LIST,SELECTED);
						deb_liste_visu++;
						affiche_liste(deb_liste_visu,TRUE);
						redessine2(rlis,DOWN_LIST,NORMAL);
						if	(deb_liste_visu+7>nb_mod_play)
							{
							redessine2(rlis,DOWN_LIST,DISABLED);
							redessine2(rlis,DOWN_LIST10,DISABLED);
							}
						if  ((rlis+UP_LIST)->ob_state & DISABLED)
							{
							redessine2(rlis,UP_LIST,NORMAL);
							redessine2(rlis,UP_LIST10,NORMAL);
							}
						break;

		/* up by 7 in the list */
		
		case UP_LIST10:	if ((rlis+UP_LIST10)->ob_state & DISABLED) break;
						redessine2(rlis,UP_LIST10,SELECTED);
						deb_liste_visu-=7;
						if (deb_liste_visu<1) deb_liste_visu=1;
						affiche_liste(deb_liste_visu,TRUE);
						redessine2(rlis,UP_LIST10,NORMAL);
						if  (deb_liste_visu==1) 
							{
							redessine2(rlis,UP_LIST10,DISABLED);
							redessine2(rlis,UP_LIST,DISABLED);
							}
						if  ((rlis+DOWN_LIST)->ob_state & DISABLED)
							{
							redessine2(rlis,DOWN_LIST,NORMAL);
							redessine2(rlis,DOWN_LIST10,NORMAL);
							}
						break;
		
		/* down by 7 in the list */
		
		case DOWN_LIST10:	
						if ((rlis+DOWN_LIST10)->ob_state & DISABLED) break;
						redessine2(rlis,DOWN_LIST10,SELECTED);
						deb_liste_visu+=7;
						if 	(deb_liste_visu+7>nb_mod_play) deb_liste_visu=nb_mod_play-6;
						affiche_liste(deb_liste_visu,TRUE);
						redessine2(rlis,DOWN_LIST10,NORMAL);
						if	(deb_liste_visu+7>nb_mod_play)
							{
							redessine2(rlis,DOWN_LIST,DISABLED);
							redessine2(rlis,DOWN_LIST10,DISABLED);
							}
						if  ((rlis+UP_LIST)->ob_state & DISABLED)
							{
							redessine2(rlis,UP_LIST,NORMAL);
							redessine2(rlis,UP_LIST10,NORMAL);
							}
						break;
	
		/* switch loop ON/OFF */

		case BREPEAT:
		case ICREPEAT:
		case TREPEAT:	plst_loop(TRUE);
						break;
		
		/* Erase the list */							

		case BNEW:
		case ICNEW:
		case TNEW:		plst_new(TRUE);
						break;

		/* remove an element from the list */

		case BREMOVE:
		case ICREMOVE:
		case TREMOVE:	plst_remove(TRUE);
						break;
		
		/* add a module to the list */
		
		case BADD:
		case ICADD:
		case TADD:		plst_add(TRUE,NULL);
						break;
		
		/* select a row */

		case LIG1:
		case LIG2:
		case LIG3:
		case LIG4:
		case LIG5:
		case LIG6:
		case LIG7:		plst_lig(TRUE,a,nb_clicks);
						break;
												
		/* Save list */
		
		case BSAVE:
		case ICSAVE:
		case TSAVE:		plst_save(TRUE,NULL);
						break;
		
		/* Load list */
		
		case BLOAD:
		case ICLLOAD:
		case TLOAD:		plst_load(TRUE,NULL);
						break;
		
		/* time */

		case TIME_PLAY:	plst_time(TRUE,0,0,0);
						break;
		
		}
	return FALSE;
	}

/* Functions pliste */

/* ~~~~~~~~~~~ */
/* loop ON/OFF */
/* ~~~~~~~~~~~ */

void plst_loop(int flag)
	{
	if 	(flag) if (FORBID_LOOP_LISTE) return;
	if 	(LOOP_LISTE) 
		{
		LOOP_LISTE=FALSE;
		send_shell(R_LOOP_PLST_OFF);
		}
	else
		{
		LOOP_LISTE=TRUE;
		send_shell(R_LOOP_PLST_ON);
		}
	redes_icon2(rlis,BREPEAT,ICREPEAT,TREPEAT,NORMAL+LOOP_LISTE);
	if  (flag)
		{
		FORBID_LOOP_LISTE=TRUE;
		count_loop=WAIT_BUTTON;
		}
	}

/* ~~~~~~~~ */
/* New list */
/* ~~~~~~~~ */

void plst_new(int flag)
	{
	if	(nb_mod_play<=0) return;
	redes_icon2(rlis,BNEW,ICNEW,TNEW,SELECTED);

	if 	(flag)
		{
		if (form_alert(1,"[2][|Are you sure you want|to erase the current playlist ?][ Yes | No ]")==2)
		   {
		   redes_icon2(rlis,BNEW,ICNEW,TNEW,NORMAL);
		   return;
		   }
		}	
	if (M_PLAY) stop();
	M_LOAD=FALSE;
	(res+NOM)->ob_spec.tedinfo->te_ptext=vide;
	maj(res,NOM);
	digit3((rlis+PLAYING)->ob_spec.tedinfo->te_ptext,0,0x10);
	digit3((rlis+NBTOTAL)->ob_spec.tedinfo->te_ptext,0,'0');
	maj(rlis,PLAYING);
	maj(rlis,NBTOTAL);
	efface_liste_mod();
	send_shell(R_NEW_PLST);
	affiche_liste(1,TRUE);
	redessine2(res,NEXT_MOD,DISABLED);
	redessine(res,TNEXT_MOD,DISABLED);
	redessine2(res,PREV_MOD,DISABLED);
	redessine(res,TPREV_MOD,DISABLED);
	redessine2(rlis,UP_LIST,DISABLED);
	redessine2(rlis,DOWN_LIST,DISABLED);
	redessine2(rlis,UP_LIST10,DISABLED);
	redessine2(rlis,DOWN_LIST10,DISABLED);
	}

/* ~~~~~~~~~~~~~ */
/* Remove module */
/* ~~~~~~~~~~~~~ */

void plst_remove(int flag)
	{
	int			i,j;
	LISTE_MOD 	*inter;

	if ((rlis+BREMOVE)->ob_state & DISABLED) return;
	j=(mod_select<cur_mod_play);		
	send_shell(R_REMOVE_PLST);
	if ((mod_select==cur_mod_play) && (M_PLAY))
	   {
	   if (flag) {if (form_alert(1,"[2][|Do you wanna erase|the current played module ??][ Yes | No ]")==2) return;}
       digit3((rlis+PLAYING)->ob_spec.tedinfo->te_ptext,0,0x10);
	   maj(rlis,PLAYING);
	   stop();
	   M_LOAD=FALSE;
	   cur_mod_play=-1;
	   (res+NOM)->ob_spec.tedinfo->te_ptext=vide;
	   maj(res,NOM);
	   if (courant->suivant!=NULL) next_mod();
	   else if (courant->precedent!=NULL) previous_mod();
	   }
	if (nb_mod_play==1) efface_liste_mod();
	else
	   {
	   inter=liste;
	   for (i=1;i<mod_select;i++) inter=inter->suivant;
	   if (inter->precedent!=NULL) inter->precedent->suivant=inter->suivant;
	   else {liste=liste->suivant;liste->precedent=NULL;}
	   if (inter->suivant!=NULL) inter->suivant->precedent=inter->precedent;
	   Mfree(inter->nom);
	   Mfree(inter);
	   mod_select=-1;
	   nb_mod_play--;
	   ligne_select=-1;
	   }
	digit3((rlis+NBTOTAL)->ob_spec.tedinfo->te_ptext,nb_mod_play,'0');
	maj(rlis,NBTOTAL);
	redes_icon2(rlis,BREMOVE,ICREMOVE,TREMOVE,DISABLED);
	if  (j) 
		{
		cur_mod_play--;
		digit3((rlis+PLAYING)->ob_spec.tedinfo->te_ptext,cur_mod_play,0x10);
		maj(rlis,PLAYING);
		}					
	if 	(nb_mod_play>7)
		{
		if (deb_liste_visu+7>nb_mod_play) deb_liste_visu--;
		}
	affiche_liste(deb_liste_visu,TRUE);
	if ((courant->suivant==NULL) && ((res+NEXT_MOD)->ob_state==NORMAL)) {redessine2(res,NEXT_MOD,DISABLED);redessine(res,TNEXT_MOD,DISABLED);}
	if ((courant->precedent==NULL) && ((res+PREV_MOD)->ob_state==NORMAL)) {redessine2(res,PREV_MOD,DISABLED);redessine(res,TPREV_MOD,DISABLED);}
	if ((nb_mod_play<=7) && ((rlis+DOWN_LIST)->ob_state==NORMAL)) {redessine2(rlis,DOWN_LIST,DISABLED);redessine2(rlis,DOWN_LIST10,DISABLED);}
	if ((nb_mod_play<=7) && ((rlis+UP_LIST)->ob_state==NORMAL)) {redessine2(rlis,UP_LIST,DISABLED);redessine2(rlis,UP_LIST10,DISABLED);}
	}

/* ~~~~~~~~~~~~ */
/* Add a module */
/* ~~~~~~~~~~~~ */

void plst_add(int flag,char *nom)
	{
	int			i,j,result;
	LISTE_MOD	*inter,*inter2,*i3;
	
	if	(nb_mod_play<=0) return;
	if 	(mod_select==-1) j=nb_mod_play;
	else j=mod_select;
	inter=liste;
	for (i=1;i<j;i++) inter=inter->suivant;
	if	(flag)
		{
		strcpy(pl_path,path);
		pl_name[0]=0;
		wind_update(BEG_UPDATE);
		fsel_exinput(pl_path,pl_name,&result,"Choose module to add...");
		wind_update(END_UPDATE);
		graf_mouse(ARROW,0);
		if (!result) return;
		*strrchr(pl_path,'*')=0;
		strcat(pl_path,pl_name);
		}
	else
		strcpy(pl_path,nom);

	inter2=(LISTE_MOD *)_malloc(sizeof(LISTE_MOD));
	pl_nom=(char *)_malloc(sizeof(pl_path));
	strcpy(pl_nom,pl_path);
	i3=inter->suivant;
	inter->suivant=inter2;
	inter2->precedent=inter;
	inter2->suivant=i3;
	if (i3!=NULL) i3->precedent=inter2;
	inter2->nom=pl_nom;
	nb_mod_play++;
	digit3((rlis+NBTOTAL)->ob_spec.tedinfo->te_ptext,nb_mod_play,'0');
	maj(rlis,NBTOTAL);
	if 	(j<cur_mod_play) 
		{
		cur_mod_play++;
		digit3((rlis+PLAYING)->ob_spec.tedinfo->te_ptext,cur_mod_play,0x10);
		maj(rlis,PLAYING);
		}
	mod_select=-1;
	ligne_select=-1;
	affiche_liste(deb_liste_visu,TRUE);
	send_shell(R_ADD_PLST);
	if 	(((rlis+DOWN_LIST)->ob_state & DISABLED) && (nb_mod_play>7)) 
		{
		redessine2(rlis,DOWN_LIST,NORMAL);	
		redessine2(rlis,DOWN_LIST10,NORMAL);
		}
	}

/* ~~~~~~~~~~~~ */
/* Select a row */
/* ~~~~~~~~~~~~ */

void plst_lig(int flag,int num,int nb_clicks)
	{
	int			i;
	LISTE_MOD	*inter;

	if	((flag) && (nb_clicks==2))
		{
		i=0;
		while (tab_lig[i++]!=num);
		if (i>nb_mod_play) return;
		i--;
		if 	(i+deb_liste_visu!=cur_mod_play)
			{					
			OLD_STATE=TRUE;
			if (M_PLAY) stop();								
			cur_mod_play=deb_liste_visu+i;
			digit3((rlis+PLAYING)->ob_spec.tedinfo->te_ptext,cur_mod_play,0x10);
			maj(rlis,PLAYING);
			((rlis+tab_lig[i])->ob_spec.tedinfo->te_ptext)[0]=0xb;
			maj(rlis,tab_lig[i]);
			inter=liste;
			for (i=1;i<cur_mod_play;i++) inter=inter->suivant;
			if (inter==courant) {play();return;}
			courant=inter;
			strcpy(nom_module,courant->nom);
			if (courant->precedent==NULL) i=DISABLED; else i=NORMAL;
			redessine2(res,PREV_MOD,i);redessine(res,TPREV_MOD,i);
			if (courant->suivant==NULL) i=DISABLED; else i=NORMAL;
			redessine2(res,NEXT_MOD,i);redessine(res,TNEXT_MOD,i);
			send_msg(BEG_LOAD,FALSE);
			send_shell(R_BEGLOAD);
			}
		return;
		}

	if	(flag)
		{
		i=0;
		while (tab_lig[i++]!=num);
		if (i>nb_mod_play) return;
		i--;
		if (tab_lig[ligne_select]!=tab_lig[i])
		   {
		   if (ligne_select!=-1) redessine(rlis,tab_lig[ligne_select],NORMAL);
		   redessine(rlis,tab_lig[i],SELECTED);
		   ligne_select=i;
		   mod_select=deb_liste_visu+i;
		   }
		}
	else
		{
		if	(num==mod_select) return;
		mod_select=num;
		if (ligne_select!=-1) redessine(rlis,tab_lig[ligne_select],NORMAL);
		if ((num>=deb_liste_visu) && (num<=deb_liste_visu+7))
		   {
		   ligne_select=num-deb_liste_visu;
		   redessine(rlis,tab_lig[ligne_select],SELECTED);
		   }
		}
		
	if ((rlis+BREMOVE)->ob_state & DISABLED) 
	redes_icon2(rlis,BREMOVE,ICREMOVE,TREMOVE,NORMAL);
	send_shell(R_SEL_PLST);
	}

/* ~~~~~~~~~ */
/* save list */
/* ~~~~~~~~~ */

void plst_save(int flag,char *nom)
	{
	int			result;

	if (nb_mod_play<=0) return;
	redes_icon2(rlis,BSAVE,ICSAVE,TSAVE,SELECTED);
	
	if	(flag)
		{
		strcpy(pl_path,path);
		*strrchr(pl_path,'\\')=0;
		strcat(pl_path,"\\*.PLT");
		pl_name[0]=0;
		wind_update(BEG_UPDATE);
		fsel_exinput(pl_path,pl_name,&result,"Play List to save as...");
		wind_update(END_UPDATE);
		graf_mouse(ARROW,0);
		if (!result) {redes_icon(rlis,BSAVE,ICSAVE,NORMAL);return;}
		*strrchr(pl_path,'*')=0;
		strcat(pl_path,pl_name);
		}
	else strcpy(pl_path,nom);
	
	var_cmd=flag;
	send_shell(R_BEG_SAVE_PLST);
	send_msg(BEG_SAVE_PLST,FALSE);
	}

void s_playlist(void)
	{
	FILE		*fichier;
	LISTE_MOD	*inter;
	int			result;
	char		file_lig[80];
	int			flag=var_cmd;
	
	graf_mouse(BUSYBEE,0);

	/* File already exists */

	if 	(!Fsfirst(pl_path,0))
		{
		if 	(flag) 
			{
			if (form_alert(1,"[2][|This file already exists.|Do you want to erase it ?][ Yes | No ]")==1) result=TRUE;
			else result=FALSE;
			}
		else result=TRUE;
		if	(!result) 
			{
			redes_icon2(rlis,BSAVE,ICSAVE,TSAVE,NORMAL);
			send_shell(R_FAIL_SAVE_PLST);
			return;
			}
		else 
			{
			if 	(Fdelete(pl_path)<0)
				{
				form_alert(1,"[3][Unable to delete|the file.|Check your media|and try again...][ OK ]");
				redes_icon2(rlis,BSAVE,ICSAVE,TSAVE,NORMAL);
				send_shell(R_FAIL_SAVE_PLST);
				return;
				}
			}
		}

	/* Sauve contenu du fichier */

	status("     SAVING PLAY LIST     ",TRUE,TRUE);	
	fichier=fopen(pl_path,"w");
	if 	(fichier==NULL)
		{
		if (flag) form_alert(1,"[3][Error when creating|the Play List file.|Check your media and|try again...][ OK ]");
		goto err_save_play_list;
		}
	if  (fputs("Play List file for Ultimate Tracker\n\n",fichier)==EOF)
		{
		if (flag) form_alert(1,"[3][Error when writing|Play List file header.|Check your media and|try again...][ OK ]");
		goto err_save_play_list;
		}
	if  (fputs("Play Time = ",fichier)==EOF)
		{
		if (flag) form_alert(1,"[3][Error when writing|play time.|Check your media|and try again...][ OK ]");
		goto err_save_play_list;
		}	
					
	strcpy(file_lig,"        ");
			
	if  ((!play_time.heure) && (!play_time.minute) && (!play_time.seconde))
		{
		if 	(fputs("00:00:00\n",fichier)==EOF)
			{
			if (flag) form_alert(1,"[3][Error when writing|play time.|Check your media|and try again...][ OK ]");
			goto err_save_play_list;
			}
		}
	else
		{
		if  (play_time.heure<10) {file_lig[0]='0';itoa(play_time.heure,&file_lig[1],10);}
		else itoa(play_time.heure,file_lig,10);
		strcat(file_lig,":");
		if  (play_time.minute<10) {file_lig[3]='0';itoa(play_time.minute,&file_lig[4],10);}
		else itoa(play_time.minute,&file_lig[3],10);
		strcat(file_lig,":");
		if  (play_time.seconde<10) {file_lig[6]='0';itoa(play_time.seconde,&file_lig[7],10);}
		else itoa(play_time.seconde,&file_lig[6],10);
		strcat(file_lig,"\n");
		if	(fputs(file_lig,fichier)==EOF)
			{
			if (flag) form_alert(1,"[3][Error when writing|play time.|Check your media|and try again...][ OK ]");
			goto err_save_play_list;
			}
		}

	strcpy(file_lig,"LOOP MODULE = ");
	if	(MOD_LOOP) strcat(file_lig,"ON\n");
	else strcat(file_lig,"OFF\n");
						
	if	(fputs(file_lig,fichier)==EOF)
		{
		if (flag) form_alert(1,"[3][Error when writing|Loop module flag.|Check your media|and try again...][ OK ]");
		goto err_save_play_list;
		}
	
	strcpy(file_lig,"REPEAT PLAY LIST = ");
	if	(LOOP_LISTE) strcat(file_lig,"ON\n\n");
	else strcat(file_lig,"OFF\n\n");
	
	if	(fputs(file_lig,fichier)==EOF)
		{
		if (flag) form_alert(1,"[3][Error when writing|Repeat list flag.|Check your media|and try again...][ OK ]");
		goto err_save_play_list;
		}
						
	inter=liste;
	while (inter!=NULL)
		{
		if 	(fputs(inter->nom,fichier)==EOF)
			{
			if (flag) form_alert(1,"[3][Error when writing|Play list file.|Check your media and|try again...][ OK ]");
			goto err_save_play_list;
			}
		fputs("\n",fichier);
		inter=inter->suivant;
		}

	fclose(fichier);
	graf_mouse(ARROW,0);
	redes_icon2(rlis,BSAVE,ICSAVE,TSAVE,NORMAL);
	status(NULL,FALSE,FALSE);
	send_shell(R_END_SAVE_PLST);
	return;

err_save_play_list:		
	fclose(fichier);
	graf_mouse(ARROW,0);
	redes_icon2(rlis,BSAVE,ICSAVE,TSAVE,NORMAL);
	status(NULL,FALSE,FALSE);
	send_shell(R_FAIL_SAVE_PLST);
	}

/* ~~~~~~~~~ */
/* Load list */
/* ~~~~~~~~~ */

void plst_load(int flag,char *nom)
	{
	int		result;
	
	redes_icon2(rlis,BLOAD,ICLLOAD,TLOAD,SELECTED);

	if	(flag)
		{
		if 	(nb_mod_play>0)
			{
			if 	(form_alert(1,"[2][Do you really wanna|erase the current list ?][ Yes | No ]")==2)
				{
				redes_icon2(rlis,BLOAD,ICLLOAD,TLOAD,NORMAL);
				return;
				}
			stop();
			}
		strcpy(pl_path,path);
		*strrchr(pl_path,'\\')=0;
		strcat(pl_path,"\\*.PLT");
		pl_name[0]=0;
		wind_update(BEG_UPDATE);
		fsel_exinput(pl_path,pl_name,&result,"Play List to load...");
		wind_update(END_UPDATE);
		graf_mouse(ARROW,0);
		if (!result) {redes_icon(rlis,BLOAD,ICLLOAD,NORMAL);return;}
		*strrchr(pl_path,'*')=0;
		strcat(pl_path,pl_name);
		}
	else strcpy(pl_path,nom);
	var_cmd=flag;
	send_msg(BEG_LOAD_PLST,FALSE);	
	}

void l_playlist(void)
	{
	FILE		*fichier;
	LISTE_MOD	*inter,*inter2;
	char		file_lig[80];
	int			i;
	int			flag=var_cmd;

	graf_mouse(BUSYBEE,0);
	send_shell(R_BEG_LOAD_PLST);
	if  (flag) status("     LOADING PLAY LIST    ",TRUE,TRUE);
	fichier=fopen(pl_path,"r");
	if  (fichier==NULL)
		{
		if (flag) form_alert(1,"[3][Error when opening|the Play List file.|Check the filename and|the media...][ OK ]");
		goto err_load_play_list;
		}
	if  (fgets(file_lig,80,fichier)==NULL)
		{
		if (flag) form_alert(1,"[3][Error when reading|play list file header.|Check your media and|try again...][ OK ]");
		goto err_load_play_list;
		}
	if  (strcmp(file_lig,"Play List file for Ultimate Tracker\n"))
		{
		if (flag) form_alert(1,"[1][|The choosen file isn't a|Play List file.|Verify it and try again.][ OK ]");
		goto err_load_play_list;
		}
	fgets(file_lig,80,fichier);
	fgets(file_lig,80,fichier);
	play_time.seconde=atoi(strrchr(file_lig,':')+1);
	*strrchr(file_lig,':')=0;
	play_time.minute=atoi(strrchr(file_lig,':')+1);
	*strrchr(file_lig,':')=0;
	play_time.heure=atoi(strrchr(file_lig,' '));
	pl_nom=(rlis+TIME_PLAY)->ob_spec.tedinfo->te_ptext;
	if 	((play_time.seconde>59) || (play_time.minute>59) || (play_time.heure>23))
		play_time.heure=play_time.minute=play_time.seconde=0;
	digit(pl_nom,play_time.heure,'0');
	digit(&pl_nom[2],play_time.minute,'0');
	digit(&pl_nom[4],play_time.seconde,'0');

	if	(fgets(file_lig,80,fichier)==NULL)
		{
		if	(flag) form_alert(1,"[3][Error when reading|Loop module flag.|Check your media and|try again...][ OK ]");
		goto err_load_play_list;
		}
	if 	(!strcmp(strrchr(file_lig,'=')+2,"ON\n"))
		{
		MOD_LOOP=TRUE;
		if ((res+LOOP)->ob_state==NORMAL) redessine(res,LOOP,SELECTED);
		}
	else 
		{
		MOD_LOOP=FALSE;
		if ((res+LOOP)->ob_state & SELECTED) redessine(res,LOOP,NORMAL);
		}

	if	(fgets(file_lig,80,fichier)==NULL)
		{
		if	(flag) form_alert(1,"[3][Error when reading|Repeat List flag.|Check your media|and try again...][ OK ]");
		goto err_load_play_list;
		}
	if	(!strcmp(strrchr(file_lig,'=')+2,"ON\n"))
		{
		LOOP_LISTE=TRUE;
		if ((rlis+BREPEAT)->ob_state==NORMAL) redes_icon2(rlis,BREPEAT,ICREPEAT,TREPEAT,SELECTED);
		}
	else 
		{
		LOOP_LISTE=FALSE;
		if ((rlis+BREPEAT)->ob_state & SELECTED) redes_icon2(rlis,BREPEAT,ICREPEAT,TREPEAT,NORMAL);
		}

	if  (fgets(file_lig,80,fichier)==NULL)
		{
		if (flag) form_alert(1,"[3][Error when reading|the playlist file.|Check your media|and try again...][ OK ]");
		goto err_load_play_list;
		}
		
	efface_liste_mod();
	i=FALSE;
	inter2=NULL;
	while (fgets(pl_path,200,fichier)!=NULL)
		{
		inter=(LISTE_MOD *)_malloc(sizeof(LISTE_MOD));
		pl_nom=(char *)_malloc(strlen(pl_path));
		pl_path[strlen(pl_path)-1]=0;
		strcpy(pl_nom,pl_path);
		inter->nom=pl_nom;
		inter->suivant=NULL;
		inter->precedent=inter2;
		if (!i) {liste=inter;i=TRUE;}
		if (inter2!=NULL) inter2->suivant=inter;
		inter2=inter;
		nb_mod_play++;
		}
	fclose(fichier);
	redes_icon2(rlis,BLOAD,ICLLOAD,TLOAD,NORMAL);
	graf_mouse(ARROW,0);
	init_pliste();
	redessine_window(w_h_liste);
	if  (nb_mod_play)
		{
		redes_icon2(rlis,BADD,ICADD,TADD,NORMAL);
		redes_icon2(rlis,BNEW,ICNEW,TNEW,NORMAL); 
		redes_icon2(rlis,BSAVE,ICSAVE,TSAVE,NORMAL); 
		courant=liste;
		strcpy(nom_module,courant->nom);	
		cur_mod_play=1;
		redessine2(res,PREV_MOD,DISABLED);
		redessine(res,TPREV_MOD,DISABLED);
		if 	(nb_mod_play>1) i=NORMAL;
		else i=DISABLED;
		redessine2(res,NEXT_MOD,i);
		redessine(res,TNEXT_MOD,i);
		send_shell(R_PLAYLIST);
		send_msg(BEG_LOAD,FALSE);
		send_shell(R_BEGLOAD);
		}						
	else
		{
		redes_icon2(rlis,BADD,ICADD,TADD,DISABLED);
		redes_icon2(rlis,BNEW,ICNEW,TNEW,DISABLED); 
		redes_icon2(rlis,BSAVE,ICSAVE,TSAVE,DISABLED); 
		}
	if (flag) status(NULL,FALSE,FALSE);
	send_shell(R_END_LOAD_PLST);
	send_shell(R_TIME_PLST);
	return;

err_load_play_list:
	redes_icon2(rlis,BLOAD,ICLLOAD,TLOAD,NORMAL);
	graf_mouse(ARROW,0);
	if (flag) status(NULL,FALSE,FALSE);
	send_shell(R_FAIL_LOAD_PLST);
	return;
	}

/* ~~~~ */
/* time */
/* ~~~~ */	

void plst_time(int flag,int h,int m,int s)
	{
	if  (nb_mod_play<=0) return;
	
	strcpy(pl_path,(rlis+TIME_PLAY)->ob_spec.tedinfo->te_ptext);
	if 	(flag)
		{
		wind_update(BEG_UPDATE);
		graf_mouse(TEXT_CRSR,0);
		form_do(rlis,TIME_PLAY);
		graf_mouse(ARROW,0);
		wind_update(END_UPDATE);
		redessine(rlis,TIME_PLAY,NORMAL);
		strcpy(pl_name,(rlis+TIME_PLAY)->ob_spec.tedinfo->te_ptext);
		play_time.seconde=atoi(&pl_name[4]);
		pl_name[4]=0;
		play_time.minute=atoi(&pl_name[2]);
		pl_name[2]=0;
		play_time.heure=atoi(pl_name);
		if  ((play_time.minute>59) || (play_time.seconde>59) || (play_time.heure>23))
			{
			form_alert(1,"[1][|Invalid duration.|(Hour must be lower than 24|and minutes and seconds|must be lower than 60 !!)][I'm stupid]");
			strcpy((rlis+TIME_PLAY)->ob_spec.tedinfo->te_ptext,pl_path);
			maj(rlis,TIME_PLAY);
			}
		}
	else
		{
		char	*c=(rlis+TIME_PLAY)->ob_spec.tedinfo->te_ptext;

		digit(c,h,'0');
		digit(c+2,m,'0');
		digit(c+4,s,'0');
		maj(rlis,TIME_PLAY);
		play_time.heure=h;
		play_time.minute=m;
		play_time.seconde=s;
		}
	send_shell(R_TIME_PLST);
	}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* Player management 																		     */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
		
int gestion_trax(int mx,int my)	
	{
	if	(!M_OPEN) return FALSE;
	
	switch (objc_find(res,0,10,mx,my))	
		{
		case PH1:
		case PH2:
		case INFOS2:
		case INFOS3:
		case INFOS:		about();
						break;
		case BPLAY:		
		case ICPLAY:	play();
						break;
		case LOAD:	
		case ICLOAD:	load(FALSE,NULL);
						break;
		case REWIND:
		case ICREWIND:	_rewind();
						break;
		case FORWARD:
		case ICFORWRD:	forward();
						break;
		case PAUSE:		
		case ICPAUSE:	pause();
						break;
		case STOP:
		case ICSTOP:	stop();
						break;		

		case F625:		change_frequence(FREQ_6_25);
						break;
		
		case F125:		change_frequence(FREQ_12_5);
						break;
						
		case F25:		change_frequence(FREQ_25);
						break;
						
		case F50:		change_frequence(FREQ_50);
						break;

		case LOOP:		change_loop();
						break;

		case QUIT:		return quitter();
		
		case FLUSH:		flush();
						break;
	
		case CONFIG:	mod_mem();
						break;
	
		case BOSCILLO:	
		case ICOSCILL:	oscilloscope(SWITCH);
						break;

		case PREV_MOD:
		case TPREV_MOD: previous_mod();
						break;
		
		case NEXT_MOD:
		case TNEXT_MOD: next_mod();
						break;

		case PLAYLIST:	play_list(SWITCH);
						break;

		case BSPEKTRU:
		case ICSPEKTR:  vu_metre(SWITCH);
						break;

		}
	return FALSE;
	}

/* ~~~~ */
/* quit */
/* ~~~~ */

int confirm_quit(void)
	{
	return form_alert (1,"[2][    ULTIMATE TRACKER    | |Are you sure you want|to quit Ultimate Tracker ?][ Yes | No ]")==1;
	}

/* ------------------------------------------------------------------------------------------------------------ */	
/* Display in windows																							*/
/* ------------------------------------------------------------------------------------------------------------ */	

/* ~~~~~~~~~~~~~~~ */
/* Display oscillo */
/* ~~~~~~~~~~~~~~~ */

void display_oscillo(void)
	{
	int	x,y;
	
	if	(!M_OSCILLO) return;
	if	(!M_PLAY) return;
	objc_offset(ros,OSC_FOND,&x,&y);
	do_redraw_oscillo(x,y,(ros+OSC_FOND)->ob_width,(ros+OSC_FOND)->ob_height,FALSE);
	}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* Display oscillo (part II) */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~ */

void affiche_oscillo(void)
	{
	MFDB	source;
	int		pxyarray[8];
	long	screen=0;
	int		color[]={0,1};
	int		x,y;
	int		m_x,m_y,dummy,i;
	
	if (machine==MCH_FALCON) source.fd_addr=(void *)&fmt_ecran;
	else source.fd_addr=(void *)&smt_ecran;
	source.fd_w=640;
	source.fd_h=66*2;
	source.fd_wdwidth=640/16;
	source.fd_stand=0;
	source.fd_nplanes=1;
	source.fd_r1=source.fd_r2=source.fd_r3=0;
	
	pxyarray[0]=1;
	pxyarray[1]=0;
	pxyarray[2]=220;
	pxyarray[3]=63;

	objc_offset(ros,OSC_FOND,&x,&y);
	pxyarray[4]=x+1;
	pxyarray[5]=y;
	pxyarray[6]=x+220;
	pxyarray[7]=y+64;
	graf_mkstate(&m_x,&m_y,&dummy,&dummy);
	i=FALSE;
	if	((m_x>x+1) && (m_x<x+200) && (m_y>y-16) && (m_y<y+64))
		{i=TRUE;graf_mouse(M_OFF,0);}
	Vsync();
	wind_update(BEG_UPDATE);
	vrt_cpyfm(gr_handle,1,pxyarray,&source,(MFDB *)&screen,color);
	wind_update(END_UPDATE);
	if (i) graf_mouse(M_ON,0);
	}

/* ~~~~~~~~~~~~~~~~ */
/* Display vu meter */
/* ~~~~~~~~~~~~~~~~ */

void display_vu_metre(void)
	{
	int x,y,w,h;
	
	if (!M_VU_METRE) return;
	if (!M_PLAY) return;
	wind_get(w_h_vu_metre,WF_WORKXYWH,&x,&y,&w,&h);
	do_redraw_vu_metre(x,y,w,h);
	}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* Display vu meter (Part II) */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~ */

void affiche_vu_metre(void)
	{
	MFDB	source;
	int		pxyarray[8];
	int		color[]={1,0};
	long	screen=0;
	int		x,y,dummy,i;
	int		m_x,m_y;
	
	if (machine==MCH_FALCON) source.fd_addr=(void *)&fmt_ecran;
	else source.fd_addr=(void *)&smt_ecran;
	source.fd_w=640;
	source.fd_h=64;
	source.fd_wdwidth=640/16;
	source.fd_stand=0;
	source.fd_nplanes=1;
	source.fd_r1=source.fd_r2=source.fd_r3=0;
	
	pxyarray[0]=320;
	pxyarray[1]=0;
	pxyarray[2]=320+176;
	pxyarray[3]=48;

	wind_get(w_h_vu_metre,WF_WORKXYWH,&x,&y,&dummy,&dummy);
	pxyarray[4]=x;
	pxyarray[5]=y;
	pxyarray[6]=x+176;
	pxyarray[7]=y+48;
	
	i=FALSE;
	graf_mkstate(&m_x,&m_y,&dummy,&dummy);
	if	((m_x>x) && (m_x<x+176) && (m_y>y-16) && (m_y<y+48))
		{i=TRUE;graf_mouse(M_OFF,0);}
	Vsync();
	wind_update(BEG_UPDATE);
	vrt_cpyfm(gr_handle,1,pxyarray,&source,(MFDB *)&screen,color);
	wind_update(END_UPDATE);
	if	(i) graf_mouse(M_ON,0);
	}
	
/* ~~~~~~~~~~~~~~~~~~ */
/* Muzaekxxx position */
/* ~~~~~~~~~~~~~~~~~~ */

void position(void)
	{
	int	i,j;
	int posit,taille;
	
	if	(!increment) return;
	if	(!M_PLAY) return;
	if	(machine==MCH_FALCON) {posit=fmt_songpos;taille=fmt_taille;}
	else {posit=smt_songpos;taille=smt_taille;}
	if (posit+1==taille) i=(res+ASC)->ob_width;
	else i=(int)(posit+1)*increment;
	j=(res+BITONIO)->ob_width;
	if	(i==j) return;
	(res+BITONIO)->ob_width=i;
	if (i<j) maj(res,ASC);
	else maj(res,BITONIO);

	if	(ID_SHELL==-1) return;
	com_buffer[0]=R_POSIT;
	com_buffer[1]=id_appl;
	com_buffer[2]=0;
	com_buffer[3]=posit;
	com_buffer[4]=taille;
	wind_update(BEG_UPDATE);
	appl_write(ID_SHELL,16,com_buffer);
	wind_update(END_UPDATE);
	}

/* ------------------------------------------------------------------------------------------------------------ */
/* module management																							*/
/* ------------------------------------------------------------------------------------------------------------ */

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* Configuration : memory + path */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */		

void ouvre_mm(OBJECT *mm)
	{
	int	x,y,w,h;
	
	form_center(mm,&x,&y,&w,&h);
    x=max(x,x_bureau);
    y=max(y,y_bureau);
    (mm)->ob_x=x;(mm)->ob_y=y;
	graf_mouse(M_OFF,0);
	wind_update(BEG_UPDATE);
	form_dial(FMD_START,x,y,w,h,x,y,w,h);
	graf_growbox(work_out[0]/2,work_out[1]/2,0,0,x,y,w,h);
	objc_draw(mm,0,10,x,y,w,h);
	graf_mouse(M_ON,0);
	}

void ferme_mm(OBJECT *mm)
	{
	int	x,y,w,h;
	
	form_center(mm,&x,&y,&w,&h);
    x=max(x,x_bureau);
    y=max(y,y_bureau);
    (mm)->ob_x=x;(mm)->ob_y=y;
	graf_mouse(M_OFF,0);
	graf_shrinkbox(work_out[0]/2,work_out[1]/2,0,0,x,y,w,h);
	wind_update(END_UPDATE);
	form_dial(FMD_FINISH,x,y,w,h,x,y,w,h);
	graf_mouse(M_ON,0);
	}
	
void mod_mem(void)
	{
	OBJECT	*mm;
	int		result,fin,a,r_choice;
	int		handle;
	size_t	cp=0;
	char	cs[8];
	char	cs2[8];
	char	_name[14];
	char	_path[200];
	char	old_path[200];
	char	display[26];
	long	l,t_fic,l_fic,*lptr,inter;
	void	*buf_fic;
		
	redessine2(res,CONFIG,SELECTED);
	
	/* Right resource */
	
	switch(rezol)
		{
		case REZ_16:		mm=adresse(RQ16);
							break;
		case REZ_LOW_16:	mm=adresse(RQLOW16);
							break;
		case REZ_MONO:		mm=adresse(RQMONO);
							break;
		case REZ_LOW_MONO:	mm=adresse(RQLOWM);
							break;
		}

	/* Init. resource */

	inter=mem_res-35000L;
	ltoa(inter,cs,10);
	(mm+CSIZE)->ob_spec.tedinfo->te_ptext=cs;
	inter=disk_res-35000L;
	ltoa(inter,cs2,10);
	(mm+MSIZE)->ob_spec.tedinfo->te_ptext=cs2;
	strcpy(old_path,Default_path);
	if (!strlen(Default_path)) display[0]=0;
	else 
		{
		memcpy((void *)display,(void *)Default_path,24);
		display[25]=0;
		}
	(mm+LEFTMOD)->ob_state|=DISABLED;
	if	(strlen(Default_path)>24) (mm+RIGHTMOD)->ob_state=NORMAL;
	else (mm+RIGHTMOD)->ob_state|=DISABLED;
	(mm+PATHMOD)->ob_spec.tedinfo->te_ptext=display;
	(mm+R68000_8)->ob_state=(mm+R68000_16)->ob_state=(mm+RDSP_16)->ob_state=NORMAL;

#ifdef NO_DSP
	(mm+R68000_16)->ob_state=(mm+RDSP_16)->ob_state=DISABLED;
#endif

	if 	(machine==MCH_FALCON) 
		{
		switch (T_rout)
			{
			case ROUT_68000_8:  (mm+R68000_8)->ob_state|=SELECTED;
							    break;
			case ROUT_68000_16: (mm+R68000_16)->ob_state|=SELECTED;
								break;
			case ROUT_DSP_16:	(mm+RDSP_16)->ob_state|=SELECTED;
								break;
			}
		}
	else (mm+R68000_8)->ob_state|=DISABLED;

	/* no memory modification when PRG */

	if	(_app)
		{
		(mm+MSIZE)->ob_flags=NONE;
		(mm+CSIZE)->ob_state|=DISABLED;
		(mm+MSIZE)->ob_state|=DISABLED;
		}

	ouvre_mm(mm);

	/* Box management */
	
	fin=FALSE;
	while (!fin)
		{
		a=form_do(mm,0);
		if ((mm+a)->ob_state & DISABLED) a=-1;
		else redessine_dial(mm,a,NORMAL);
		switch(a)
			{
			case OKSIZE:
			case CANCSIZE:	fin=TRUE;
							break;

			case LEFTMOD:	cp--;
							if	(!cp) redessine_dial(mm,LEFTMOD,DISABLED);
							if 	((mm+RIGHTMOD)->ob_state & DISABLED) redessine_dial(mm,RIGHTMOD,NORMAL);
							memcpy((void *)display,(void *)(Default_path+cp),24);
							maj_dial(mm,PATHMOD);
							break;

			case RIGHTMOD:	cp++;
							if 	(cp+24==strlen(Default_path)) redessine_dial(mm,RIGHTMOD,DISABLED);
							if ((mm+LEFTMOD)->ob_state & DISABLED) redessine_dial(mm,LEFTMOD,NORMAL);
							memcpy((void *)display,(void *)(Default_path+cp),24);
							maj_dial(mm,PATHMOD);
							break;

			case CHPATH:	_name[0]=0;
							ferme_mm(mm);
							wind_update(BEG_UPDATE);
							fsel_exinput(path,_name,&result,"Choose the modules path...");
							wind_update(END_UPDATE);
							graf_mouse(ARROW,0);
							maj(res,0);
							ouvre_mm(mm);
							if (!result) break;		
							strcpy(Default_path,path);
							memcpy((void *)display,(void *)Default_path,24);
							objc_draw(mm,PATHMOD,2,0,0,work_out[0],work_out[1]);
							if (strlen(Default_path)>24) redessine_dial(mm,RIGHTMOD,NORMAL);
							break;
			}
		}

	/* Close window & save */

	ferme_mm(mm);
	if	(a==CANCSIZE) 
		{
		strcpy(Default_path,old_path);
		ltoa(inter,cs2,10);
		inter+=35000L;
		disk_res=inter;
		redessine2(res,CONFIG,NORMAL);
		return;
		}

	if	((mm+R68000_8)->ob_state & SELECTED) r_choice=T_rout=ROUT_68000_8;
	if  ((mm+R68000_16)->ob_state & SELECTED) r_choice=T_rout=ROUT_68000_16;
	if	((mm+RDSP_16)->ob_state & SELECTED) r_choice=T_rout=ROUT_DSP_16;

	l=atol((mm+MSIZE)->ob_spec.tedinfo->te_ptext);
	l+=35000L;
	disk_res=l;
		
	_name[0]=0;
	_path[0]=Dgetdrv()+'A';
	_path[1]=':';
	Dgetpath(&_path[2],0);
	if	(!_app) strcat(_path,"\\*.ACC");
	else strcat(_path,"\\*.PRG");
	wind_update(BEG_UPDATE);
	fsel_exinput(_path,_name,&result,"Where's Ultimate tracker ?");
	wind_update(END_UPDATE);
	graf_mouse(ARROW,0);
	if 	(!result) 
		{
		redessine2(res,CONFIG,NORMAL);
		return;
		}
	*strchr(_path,'*')=0;
	strcat(_path,_name);

	handle=(int)Fopen(_path,FO_READ);
	if 	(handle<0)
		{
		err_mod_mem("[3][File Error:|The specified file|doesn't not exist...][ OK ]",NULL);
		return;
		}

	t_fic=filelength(handle);
	buf_fic=_malloc((long)t_fic);
	if 	(buf_fic==NULL)
		{
		err_mod_mem("[3][Not enough memory to|load the program !|Damned !!!][ OK ]",NULL);
		Fclose(handle);
		return;
		}
	l_fic=Fread(handle,t_fic,buf_fic);
	Fclose(handle);
	if 	(l_fic!=t_fic) 
		{
		err_mod_mem("[3][Read Error :|An error has occured|during reading the|file.][ OK ]",buf_fic);
		return;
		}
			
	lptr=(long *)buf_fic+8;
	if	(*lptr!='FTRK')
		{
		err_mod_mem("[3][This is not the right file|Watch out !|Perhaps you've compressed|ULTIMATE Tracker ?][ OK ]",buf_fic);
		return;
		} 

	*((long *)(buf_fic)+9)=l;
	strcpy((char *)((char *)buf_fic+46),Default_path);
	*((int *)(buf_fic)+22)=r_choice;

	handle=(int)Fcreate(_path,0);
	if	(handle<0)
		{
		err_mod_mem("[3][Write error :|Verify that your disk|is formatted or isn't|write protected.][ OK ]",buf_fic);
		return;
		}
	l_fic=Fwrite(handle,t_fic,buf_fic);
	if	(l_fic<t_fic)
		{
		err_mod_mem("[3][Write error :|Verify that your disk|is not full or|corrupted.][ OK ]",buf_fic);
		return;
		}
	Fclose(handle);
	redessine2(res,CONFIG,NORMAL);
	Mfree(buf_fic);
	return;
	}

void err_mod_mem(char *texte,void *buffer)
	{
	form_alert(1,texte);
	redessine2(res,CONFIG,NORMAL);
	if (buffer!=NULL) {Mfree(buffer);buffer=NULL;}
	}
	
/* ~~~~ */
/* Play */
/* ~~~~ */

void play(void)
	{
	int	lck=FALSE;
	LISTE_MOD *inter;

	if	(M_PLAY) return;
	if  (!M_LOAD) return;
	if	(!nb_mod_play) return;
	
	switch(machine)
		{
		case MCH_FALCON:   lck=fmt_play();
						   break;
		case MCH_TT:	   smt_play(TRUE);
						   break;
		case MCH_MEGA_STE:
		case MCH_STE:	   smt_play(FALSE);
				           break;
		}

	if 	(lck==SNDLOCKED)
		{
		if (M_OPEN) form_alert (1,"[3][    ULTIMATE TRACKER    | |The sound system is|already used by an other|program ! Try later.][ OK ]");
		return;
		}

	redes_icon(res,BPLAY,ICPLAY,SELECTED);

	/* Find the played module */
	
	cur_mod_play=1;
	inter=liste;
	while ((inter!=courant) && (inter!=NULL)) {inter=inter->suivant;cur_mod_play++;}

	/* Init play list */

	if	(M_LISTE)
		{
		digit3((rlis+PLAYING)->ob_spec.tedinfo->te_ptext,cur_mod_play,0x10);
		maj(rlis,PLAYING);
		if ((cur_mod_play>=deb_liste_visu) && (cur_mod_play<deb_liste_visu+7))
      	   {
      	   ((rlis+tab_lig[cur_mod_play-deb_liste_visu])->ob_spec.tedinfo->te_ptext)[0]=0xb;
		   maj(rlis,tab_lig[cur_mod_play-deb_liste_visu]);
		   }
		}

	M_PLAY=TRUE;
	send_shell(R_PLAY);
	}
	
/* ~~~~~~ */
/* rewind */
/* ~~~~~~ */

void _rewind(void)
	{
	if (!M_PLAY) return;
	if (!increment) return;
	redes_icon(res,REWIND,ICREWIND,SELECTED);
	if (machine==MCH_FALCON) fmt_rewind();
	else smt_rewind();
	redes_icon(res,REWIND,ICREWIND,NORMAL);
	send_shell(R_REWIND);
	}

/* ~~~~~~~ */ 
/* forward */
/* ~~~~~~~ */

void forward(void)
	{
	if (!M_PLAY) return;
	if (!increment) return;
	redes_icon(res,FORWARD,ICFORWRD,SELECTED);
	if (machine==MCH_FALCON) fmt_forward();
	else smt_forward();
	redes_icon(res,FORWARD,ICFORWRD,NORMAL);
	send_shell(R_FORWARD);
	}

/* ~~~~~~~~~~~~~~~~ */
/* Frequency change */
/* ~~~~~~~~~~~~~~~~ */
	
void change_frequence(int frequence)
	{
	if	(frequence==old_freq) return;
	if	((res+tab_freq[frequence])->ob_state & DISABLED) return;

	switch(machine)
		{
		case MCH_FALCON:	if ((!cache_falcon()) && (frequence==FREQ_25)) d_animations();
							if ((frequence<FREQ_25) && (NO_ANIMATION)) e_animations();
							fmt_freq(frequence);
							break;

		case MCH_TT:		smt_freq(frequence);
							break;

		case MCH_MEGA_STE:	if (mode_68000()==NORMAL)
							   { 
							   if (frequence==FREQ_50) d_animations();
							   if ((frequence<FREQ_50) && (NO_ANIMATION)) e_animations();
							   smt_freq(frequence);
							   break;
							   }							
							
		case MCH_STE:	   	if ((frequence<FREQ_25) && (NO_ANIMATION)) e_animations();
							if (frequence==FREQ_25) d_animations();
							smt_freq(frequence);
							break;
	
		}
	redessine(res,tab_freq[old_freq],NORMAL);
	redessine(res,tab_freq[frequence],SELECTED);
	old_freq=frequence;
	send_shell(R_FREQ);						
	}

/* ~~~~~ */
/* Pause */
/* ~~~~~ */

void pause(void)
	{
	if 	(!M_PLAY) return;
	if	(FORBID_PAUSE) return;
	if 	(!M_PAUSE) 
		{
		redes_icon(res,PAUSE,ICPAUSE,SELECTED);
		if	(machine==MCH_FALCON) fmt_pause(TRUE);
		else smt_pause(TRUE);
		M_PAUSE=TRUE;
		send_shell(R_PAUSE_ON);
		if	(M_OSCILLO)
			{
			if (machine==MCH_FALCON) fmt_raz();
			else smt_raz();
			display_oscillo();
			}
		if	(M_VU_METRE)
			{
			if (machine==MCH_FALCON) fmt_rvum();
			else smt_rvum();
			display_vu_metre();
			}
		}
	else
		{
		redes_icon(res,PAUSE,ICPAUSE,NORMAL);
		if (machine==MCH_FALCON) fmt_pause(FALSE);
		else smt_pause(FALSE);
		M_PAUSE=FALSE;
		send_shell(R_PAUSE_OFF);
		if	(M_OSCILLO) display_oscillo();
		if	(M_VU_METRE) display_vu_metre();
		}
	FORBID_PAUSE=TRUE;
	count_pause=WAIT_BUTTON;
	}
	
/* ~~~~ */
/* stop */
/* ~~~~ */

void stop(void)
	{
	if  (!increment)
		{
		redes_icon(res,REWIND,ICREWIND,NORMAL);
		redes_icon(res,FORWARD,ICFORWRD,NORMAL);
		redessine(res,LOOP,NORMAL);
		if (MOD_LOOP) redessine(res,LOOP,SELECTED);
		increment=-1;
		}
	if (!M_PLAY) return;
	if (M_PAUSE) pause();
	if (machine==MCH_FALCON) {fmt_stop();fmt_off();}
	else {smt_stop();smt_off();}
	redes_icon(res,STOP,ICSTOP,SELECTED);
	redes_icon(res,BPLAY,ICPLAY,NORMAL);
	(res+BITONIO)->ob_width=0;
	redes_icon(res,STOP,ICSTOP,NORMAL);
	maj(res,NOM);
	maj(res,ASC);
	fmt_heure=fmt_minute=fmt_seconde=0;
	smt_heure=smt_minute=smt_seconde=0;
	if	(M_OSCILLO) 
		{
		if (machine==MCH_FALCON) fmt_raz();
		else smt_raz();
		display_oscillo();
		}
	if 	(M_VU_METRE)
		{
		if	(machine==MCH_FALCON) fmt_rvum();
		else smt_rvum();
		display_vu_metre();
		}
	if	(M_LISTE)
		{
		char *c;
	
		digit3((rlis+PLAYING)->ob_spec.tedinfo->te_ptext,0,0x10);
		maj(rlis,PLAYING);
		if ((cur_mod_play>=deb_liste_visu) && (cur_mod_play<deb_liste_visu+7))
      	   {
      	   ((rlis+tab_lig[cur_mod_play-deb_liste_visu])->ob_spec.tedinfo->te_ptext)[0]=' ';
		   maj(rlis,tab_lig[cur_mod_play-deb_liste_visu]);
		   }
		c=(rlis+COMPTEUR)->ob_spec.tedinfo->te_ptext;
		digit(c,0,0x10);
		digit(&c[3],0,0x10);
		digit(&c[6],0,0x10);
		maj(rlis,COMPTEUR);
		}
	M_PLAY=FALSE;
	send_shell(R_STOP);
	}
	
/* ~~~~ */
/* Quit */
/* ~~~~ */

int quitter(void)
	{
	int i;
	
	if 	(!_app)
		{
		redessine2(res,QUIT,SELECTED);
		stop();
		evnt_timer(200,0);
		redessine2(res,QUIT,NORMAL);
		panel(FERME);
		B_OSCILLO=M_OSCILLO;
		B_VU_METRE=M_VU_METRE;
		B_PLAYLIST=M_LISTE;
		oscilloscope(FERME);
		play_list(FERME);
		vu_metre(FERME);
		return FALSE;
		}
	redessine2(res,QUIT,SELECTED);
	i=confirm_quit();
	redessine2(res,QUIT,NORMAL);
	return i;
	}	
	
/* ~~~~~~~~~~~ */
/* Quit & play */
/* ~~~~~~~~~~~ */

void flush(void)
	{
	if (_app) return;
	if (!M_OPEN) return;
	redessine2(res,FLUSH,SELECTED);
	evnt_timer(200,0);
	redessine2(res,FLUSH,NORMAL);
	panel(FERME);
	B_OSCILLO=M_OSCILLO;
	B_PLAYLIST=M_LISTE;
	B_VU_METRE=M_VU_METRE;
	play_list(FERME);
	vu_metre(FERME);
	oscilloscope(FERME);
	}
	
/* ~~~~ */
/* Load */
/* ~~~~ */

int load(int flag,char *param)
	{
	int			result;
	DTA			*old_dta;
	LISTE_MOD	*inter=NULL,*prec=NULL;
	int			i;
	char		*nom_liste;

	OLD_STATE=M_PLAY;
	if 	(flag)
		{
		strcpy(fs_path,param);
		strcpy(path,param);
		*(strrchr(path,'\\')+1)=0;
		strcat(path,"*.MOD");
		(res+NOM)->ob_spec.tedinfo->te_ptext=vide;
		maj(res,NOM);
		redes_icon(res,LOAD,ICLOAD,SELECTED);
		redes_icon(res,BPLAY,ICPLAY,NORMAL);
		} 
	else
		{
		redes_icon(res,LOAD,ICLOAD,SELECTED);
		name[0]=0;
		wind_update(BEG_UPDATE);
		fsel_exinput(path,name,&result,"Module Name...");
		wind_update(END_UPDATE);
		graf_mouse(ARROW,0);
		if 	(!result) 
			{
			redes_icon(res,LOAD,ICLOAD,NORMAL);
			return FALSE;
			}
		strcpy(fs_path,path);
		*strchr(fs_path,'*')=0;
		strcat(fs_path,name);
		(res+NOM)->ob_spec.tedinfo->te_ptext=vide;
		maj(res,0);
		}
	stop();
	M_LOAD=FALSE;

	/* Read files to play into the list */
	
	redessine2(res,PREV_MOD,DISABLED);
	redessine(res,TPREV_MOD,DISABLED);
	redessine2(res,NEXT_MOD,DISABLED);
	redessine(res,TNEXT_MOD,DISABLED);
	efface_liste_mod();
	old_dta=Fgetdta();
	Fsetdta(_dta);
	result=Fsfirst(fs_path,NORMAL);
	i=0;
	if	(!result)
		{	
		while (!result)
			{
			inter=(LISTE_MOD *)_malloc(sizeof(LISTE_MOD));
			nom_liste=(char *)_malloc(strlen(path)+strlen(_dta->d_fname)+2);
			inter->nom=nom_liste;
			if (prec) {prec->suivant=inter;inter->precedent=prec;}
			if (!i)	{liste=inter;i=1;inter->precedent=NULL;}
			inter->suivant=NULL;
			strcpy(inter->nom,path);
			*strrchr(inter->nom,'*')=0;
			strcat(inter->nom,_dta->d_fname);
			nb_mod_play++;
			prec=inter;
			if (nb_mod_play<999) result=Fsnext(); else result=TRUE;
			}
		}
	else
		{
		Fsetdta(old_dta);
		redes_icon(res,LOAD,ICLOAD,NORMAL);
		send_shell(R_FAILOAD);
		return FALSE;
		} 

	/* Is there a module at least ? */
	
	if	(!nb_mod_play)
		{
		Fsetdta(old_dta);
		redes_icon(res,LOAD,ICLOAD,NORMAL);
		send_shell(R_FAILOAD);
		return FALSE;
		}

	/* Init. the 1st one */
	
	courant=liste;
	strcpy(nom_module,courant->nom);	
	if	(M_LISTE) {init_pliste();redessine_window(w_h_liste);}
	send_shell(R_PLAYLIST);
	
	/* Arrows */
	
	if 	(nb_mod_play>1) 
		{
		redessine2(res,NEXT_MOD,NORMAL);
		redessine(res,TNEXT_MOD,NORMAL);
		}

	/* end */

	send_msg(BEG_LOAD,FALSE);
	send_shell(R_BEGLOAD);
	Fsetdta(old_dta);
	return TRUE;
	}
	
/* ~~~~~ Load module ~~~~~ */
	
int l_module(int flag)	
	{
	char	inter[30];
	int		handle,i;
	long	taille,res_read;
	long	*lptr;
	char	*cbuf;
	char	filename[14];
	char	ligne[28];
	long	mem_dispo;

	if	(_app)
		{
		if  (buffer!=NULL) {Mfree(buffer);buffer=NULL;}
		mem_dispo=(long)(_coreleft()-50000L);
		}
	else
		mem_dispo=mem_res;

	if (flag) redes_icon(res,LOAD,ICLOAD,SELECTED);
	graf_mouse(BUSYBEE,0);
	handle=(int)Fopen(nom_module,FO_READ);
	if 	(handle<0)
		{
		if (M_OPEN) form_alert(1,"[3][File Error:|The specified file|doesn't not exist...][ OK ]");
		goto err_lect_mod;
		}

	taille=filelength(handle);

	if 	(taille+35000L>mem_dispo)
		{
		if (M_OPEN) form_alert(1,"[3][Size of Module is too|important. Choose|a smaller one !][ OK ]");
		Fclose(handle);
		goto err_lect_mod;
		}

	if	(_app) 
		{
		buffer=_malloc(mem_dispo);
		if	(buffer==NULL)
			{
			form_alert(1,"[3][|Memory Reservation Error.|Remove ACCs or TSRs and|reboot your system.][ OK ]");
			Fclose(handle);
			goto err_lect_mod;
			}
		}

	cbuf=(char *)buffer;

	strcpy(filename,"              ");
	strcpy(filename,strrchr(nom_module,'\\')+1);
	filename[strlen(filename)]=' ';
	strcpy(ligne,"  LOADING : ");
	strcat(ligne,filename);
	status(ligne,TRUE,TRUE);
	res_read=Fread(handle,taille,buffer);
	if 	(res_read!=taille) 
		{
		if (M_OPEN) form_alert(1,"[3][Read Error :|An error has occured|during reading the|file.][ OK ]");
		goto err_lect_mod;
		}
	Fclose(handle);
			
	/* ------------------------ */
	/* Test if module is packed */
	/* ------------------------ */

	/* Pack ICE any version (thanks Edy !!!) */

	lptr=(long *)buffer;
	if	((*lptr=='ICE!') || (*lptr=='Ice!'))
		{
		lptr+=2;
		taille=(*lptr);
		if	(taille+35000L>mem_dispo)
			{
			if (M_OPEN) form_alert(1,"[3][Size of Module is too|important. Choose|a smaller one !][ OK ]");
			goto err_lect_mod;              
			}							  
		status("    UNPACKING PACK ICE    ",TRUE,FALSE);
		depack(buffer);	
		}

	/* Amiga Power Packer 2.0 */

	lptr=(long *)buffer;
	if	(*lptr=='PP20')
		{
		taille=T_unpack(buffer,mem_dispo);
		if 	(taille+35000L>mem_dispo)
			{
			if (M_OPEN) form_alert(1,"[3][Size of Module is too|important. Choose|a smaller one !][ OK ]");
			goto err_lect_mod;
			}								
		status("  UNPACKING POWER PACKER  ",TRUE,FALSE);
		Power_pack(buffer,res_read);
		memcpy(buffer,(void *)(cbuf+128),taille);	
		}

	/* Atomik Packer 3.5 */
	
	lptr=(long *)buffer;
	if	(*lptr=='ATM5')
		{
		lptr++;
		taille=(*lptr);
		if	(taille+35000L>mem_dispo)
			{
			if (M_OPEN) form_alert(1,"[3][Size of Module is too|important. Choose|a smaller one !][ OK ]");
			goto err_lect_mod;
			}								
		status("   UNPACKING ATOMIK 3.5   ",TRUE,FALSE);
		atomik(buffer);
		}
	
	/* Speed Packer III (to be verified...) */

	lptr=(long *)buffer;
	if	(*lptr=='SPv3')
		{
		lptr+=2;
		taille=(*lptr);
		if	(taille+35000L>mem_dispo)
			{
			if (M_OPEN) form_alert(1,"[3][Size of Module is too|important. Choose|a smaller one !][ OK ]");
			goto err_lect_mod;
			}								
		status("  UNPACKING SPEED PACKER  ",TRUE,FALSE);
		u_sp3(buffer);	
		}

	/* Delta Force NOISEPAKKER 1.0 */
	
	lptr=(long *)buffer;
	if	(*lptr=='NPKK')
		{
		taille=Lenght_ndpk(buffer);
		if	(taille+35000L>mem_dispo)
			{
			if (M_OPEN) form_alert(1,"[3][Size of Module is too|important. Choose|a smaller one !][ OK ]");
			goto err_lect_mod;
			}								
		status("  UNPACKING NOISEPAKKER   ",TRUE,FALSE);
		Unpack_ndpk(buffer);
		memcpy(buffer,(void *)(lptr+2),taille);
		}

	/* Shrink RAM */

	if	(_app)
		{	
		if 	(Mshrink(0,buffer,taille+35000L))
			{
			if	(M_OPEN) form_alert(1,"[3][|Memory Allocation Error.|Remove ACCs or TSRs|and reboot...][ OK ]");
			goto err_lect_mod;
			}
		}

	/* Copy module name */

	status(NULL,FALSE,FALSE);
	cbuf[20]=0;
	strcpy(inter,cbuf);
	for (i=0;i<20;cbuf[i++]=' ');
	strcpy(cbuf,inter);
	cbuf[(int)strlen(cbuf)]=' ';
	cbuf[20]=0;
	(res+NOM)->ob_spec.tedinfo->te_ptext=buffer;

	/* end OK */
	
	M_LOAD=TRUE;
	send_msg(END_LOAD,FALSE);
	return TRUE;

	/* end with error */

err_lect_mod:
    M_LOAD=FALSE;
    if	(_app) {Mfree(buffer);buffer=NULL;}
	status(NULL,FALSE,FALSE);
	(res+NOM)->ob_spec.tedinfo->te_ptext=vide;
	maj(res,NOM);
	if (OLD_STATE) M_PLAY=TRUE;
	if (sens_liste==AVANT) {if(next_mod()) return TRUE;}
	if (sens_liste==ARRIERE) {if (previous_mod()) return TRUE;}
	send_msg(END_LOAD,FALSE);
	send_shell(R_FAILOAD);
	return FALSE;
	}
	
/* ~~~~ end of loading module ~~~~ */

void fin_load(void)
	{
	int	t;

	if	(M_LOAD)
		{		
		if	(machine==MCH_FALCON) 
			{
			fmt_init(buffer);
			t=fmt_taille;
			}
		else 
			{
			smt_init(buffer);
			t=smt_taille;
			}

		if  (t<=0)
			{
			if ((M_OPEN) && (nb_mod_play==1)) form_alert(1,"[1][This module is protected.|There's no infomations about|its size. Rewind, Forward|or loop are unavailable.][ OK ]");
			redes_icon(res,REWIND,ICREWIND,DISABLED);
			redes_icon(res,FORWARD,ICFORWRD,DISABLED);
			redessine(res,LOOP,DISABLED);
			increment=0;		
			send_shell(R_PROTECMOD);
			}
		else
			{
			increment=((res+ASC)->ob_width)/t;
			send_shell(R_ENDLOAD);
			}
		}
	maj(res,NOM);
	redes_icon(res,LOAD,ICLOAD,NORMAL);
	graf_mouse(ARROW,0);
	if	(OLD_STATE) play();
	}

/* ~~~~~~~~~~~ */
/* Module loop */
/* ~~~~~~~~~~~ */

void change_loop(void)
	{
	if  (!increment) return;
	if	(MOD_LOOP) 
		{
		MOD_LOOP=FALSE;
		if (machine==MCH_FALCON) fmt_loop=FALSE;
		else smt_loop=FALSE;
		}
	else
		{
		MOD_LOOP=TRUE;
		if	(machine==MCH_FALCON) fmt_loop=TRUE;
		else fmt_loop=TRUE;
		}
	redessine(res,LOOP,NORMAL+MOD_LOOP);
	send_shell(R_LOOP_OFF+MOD_LOOP);
	}
	
/* ~~~~~~~~~~~~~~~~~~~~~ */
/* Go to the next module */
/* ~~~~~~~~~~~~~~~~~~~~~ */

int next_mod(void)
	{
	int	i=FALSE;
	
	if	(nb_mod_play<2) return FALSE;

	if	(LOOP_LISTE)
		{
		if (courant->suivant==NULL) {courant=liste;i=TRUE;}
		}
	else
		{
		if	((res+NEXT_MOD)->ob_state & DISABLED) return FALSE;
		}

	redessine2(res,NEXT_MOD,SELECTED);
	redessine(res,TNEXT_MOD,NORMAL);
	if (!i) courant=courant->suivant;
	OLD_STATE=M_PLAY;
	strcpy(nom_module,courant->nom);
	stop();
	redessine2(res,NEXT_MOD,NORMAL);
	redessine(res,TNEXT_MOD,NORMAL);
	if 	(courant->suivant==NULL)
		{
		redessine2(res,NEXT_MOD,DISABLED);
		redessine(res,TNEXT_MOD,DISABLED);
		}
	if	((res+PREV_MOD)->ob_state & DISABLED)
		{
		redessine2(res,PREV_MOD,NORMAL);
		redessine(res,TPREV_MOD,NORMAL);
		}
	sens_liste=AVANT;
	if	(M_LISTE)
		{
		if ((cur_mod_play>=deb_liste_visu) && (cur_mod_play<deb_liste_visu+7))
     	   {
      	   ((rlis+tab_lig[cur_mod_play-deb_liste_visu])->ob_spec.tedinfo->te_ptext)[0]=' ';
		   maj(rlis,tab_lig[cur_mod_play-deb_liste_visu]);
		   }
		}
	if (i) cur_mod_play=1;
	else cur_mod_play++;
	send_msg(BEG_LOAD2,FALSE);
	send_shell(R_NEXT_MOD);
	return TRUE;
	}		

/* ~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* Go to the previous module */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~ */

int	previous_mod(void)
	{
	if	(nb_mod_play<2) return FALSE;
	if	((res+PREV_MOD)->ob_state & DISABLED) return FALSE;
	redessine2(res,PREV_MOD,SELECTED);
	redessine(res,TPREV_MOD,NORMAL);
	courant=courant->precedent;
	OLD_STATE=M_PLAY;
	strcpy(nom_module,courant->nom);
	stop();
	redessine2(res,PREV_MOD,NORMAL);
	redessine(res,TPREV_MOD,NORMAL);
	if 	(courant->precedent==NULL)
		{
		redessine2(res,PREV_MOD,DISABLED);
		redessine(res,TPREV_MOD,DISABLED);
		}
	if	((res+NEXT_MOD)->ob_state & DISABLED)
		{
		redessine2(res,NEXT_MOD,NORMAL);
		redessine(res,TNEXT_MOD,NORMAL);
		}
	sens_liste=ARRIERE;
	if	(M_LISTE)
		{
		if ((cur_mod_play>=deb_liste_visu) && (cur_mod_play<deb_liste_visu+7))
     	   {
      	   ((rlis+tab_lig[cur_mod_play-deb_liste_visu])->ob_spec.tedinfo->te_ptext)[0]=' ';
		   maj(rlis,tab_lig[cur_mod_play-deb_liste_visu]);
		   }
		}
	cur_mod_play--;
	send_msg(BEG_LOAD2,FALSE);
	send_shell(R_PREV_MOD);
	return TRUE;
	}

/* ---------------------------------------------------------------------------------------- */
/* Timer management																			*/
/* ---------------------------------------------------------------------------------------- */		
	
void gestion_timer(void)
	{
	char	*c;
	int		h,m,s;

	test_cache_falcon();
	test_freq_mste_tt();
	test_fin();
	position();
	display_oscillo();
	display_vu_metre();

	if	(FORBID_PAUSE)
		{
		count_pause--;
		if (!count_pause) FORBID_PAUSE=FALSE;
		}
	if	(FORBID_LOOP_LISTE)
		{
		count_loop--;
		if (!count_loop) FORBID_LOOP_LISTE=FALSE;
		}

	if	((M_LISTE) && (M_PLAY))
		{
		if (machine==MCH_FALCON) {h=fmt_heure;m=fmt_minute;s=fmt_seconde;}
		else {h=smt_heure;m=smt_minute;s=smt_seconde;}
		
		if 	(s!=old_s)
			{
			c=(rlis+COMPTEUR)->ob_spec.tedinfo->te_ptext;
			digit(c,h,0x10);
			digit(&c[3],m,0x10);
			digit(&c[6],s,0x10);
			maj_no_mouse(rlis,COMPTEUR);
			old_s=s;
			}
		}

	if  ((!play_time.heure) && (!play_time.minute) && (!play_time.seconde)) return;
	if	((M_PLAY) && (!M_PAUSE)) send_shell(R_CUR_TIME);
	
	if	((h>=play_time.heure) && (m>=play_time.minute) && (s>=play_time.seconde)) next_mod();
	}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* Test Frequency changes on MegaSTe & TT */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

void test_freq_mste_tt(void)
	{
	int	nf;
	
	if ((machine==MCH_FALCON) || (machine==MCH_STE)) return;
	nf=current_freq();
	if 	(old_freq!=nf)
		{
		redessine(res,tab_freq[old_freq],NORMAL);
		redessine(res,tab_freq[nf],SELECTED);
		old_freq=nf;
		send_shell(R_FREQ);
		}
		
	/* look the cache state */
		
	switch(machine)
		{
		case MCH_MEGA_STE:	nf=mode_68000();
							if ((!smt_oscil) && (M_OSCILLO)) d_animations();  						  
							if ((!smt_vum) && (M_VU_METRE)) d_animations();
							if ((nf==DISABLED) && (old_freq>=FREQ_25) && (!NO_ANIMATION)) d_animations(); 
							if ((nf==DISABLED) && (old_freq==FREQ_50) && (!M_PLAY)) change_frequence(FREQ_12_5);
							if ((NO_ANIMATION) && (nf==NORMAL) && (old_freq<FREQ_50)) e_animations();  	 
							break;


		case MCH_TT:		if ((!cache_falcon()) && (!M_PLAY) && (old_freq==FREQ_50))				
							   {
							   change_frequence(FREQ_12_5);
							   d_animations();
							   }	
							if ((old_freq<FREQ_50) && (NO_ANIMATION)) e_animations();  	
							if (!cache_falcon()) nf=DISABLED;
							else nf=NORMAL;
							break;
		}

	/* redraw buttons */
	
	if ((nf==DISABLED) && ((res+F50)->ob_state==NORMAL)) redessine(res,F50,DISABLED);
	if ((nf==NORMAL) && ((res+F50)->ob_state==DISABLED)) redessine(res,F50,NORMAL);
	}

/* ~~~~~~~~~~~~~~~~~~~~~~~~ */
/* Test cache OFF on Falcon */
/* ~~~~~~~~~~~~~~~~~~~~~~~~ */

void test_cache_falcon(void)
	{
	int	nf;
	
	if (machine!=MCH_FALCON) return;
	if (freq_falcon()==MHZ_8) return;
	nf=(int)soundcmd(SETPRESCALE,-1);
	if (old_freq!=nf)
	   {
	   redessine(res,tab_freq[old_freq],0);
	   redessine(res,tab_freq[nf],1);
	   old_freq=nf;
       send_shell(R_FREQ);
	   }
	nf=cache_falcon();
	
	if	((!nf) && (!M_PLAY) && (old_freq==FREQ_50)) {change_frequence(FREQ_12_5);d_animations();}
	if	((!fmt_oscil) && (M_OSCILLO)) d_animations();
	if	((!fmt_vum) && (M_VU_METRE)) d_animations();
	if  ((old_freq==FREQ_25) && (!nf) && (!NO_ANIMATION)) d_animations();
	if  ((nf) && (NO_ANIMATION)) e_animations();

	if ((!nf) && ((res+F50)->ob_state==NORMAL)) redessine(res,F50,DISABLED);
	if ((nf) && ((res+F50)->ob_state==DISABLED)) redessine(res,F50,NORMAL);
	}	

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* Enable/Forbid oscilloscope */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~ */

void e_animations(void)
	{
	redes_icon(res,BOSCILLO,ICOSCILL,NORMAL);
	redes_icon(res,BSPEKTRU,ICSPEKTR,NORMAL);
	NO_ANIMATION=FALSE;
	}
	
void d_animations(void)
	{
	oscilloscope(FERME);
	vu_metre(FERME);
	redes_icon(res,BOSCILLO,ICOSCILL,DISABLED);
	redes_icon(res,BSPEKTRU,ICSPEKTR,DISABLED);
	NO_ANIMATION=TRUE;
	}	
	
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* Teste end of module if loop ON */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

void test_fin(void)
	{
	int	fin;

	if	(!M_PLAY) return;	
	if	(machine==MCH_FALCON) {fin=fmt_end;fmt_end=0;}
	else {fin=smt_end;smt_end=0;}

	/* Module finished -> go to the next one if it exists */
	
	if	(fin)
		{
		send_shell(R_ENDMOD);
		if ((res+NEXT_MOD)->ob_state & DISABLED) stop();
		else next_mod();
		}
	}

/* ~~~~~~~~~~~~~~ */
/* Erase the list */
/* ~~~~~~~~~~~~~~ */

void efface_liste_mod(void)
	{
	LISTE_MOD	*inter;
	
	while (liste!=NULL)
		{
		inter=liste->suivant;
		Mfree(liste->nom);
		Mfree(liste);
		liste=inter;
		}
	nb_mod_play=cur_mod_play=0;
	ligne_select=mod_select=-1;
	deb_liste_visu=1;
	redes_icon2(rlis,BADD,ICADD,TADD,DISABLED);
	redes_icon2(rlis,BNEW,ICNEW,TNEW,NORMAL);
	redes_icon2(rlis,BNEW,ICNEW,TNEW,DISABLED); 
	redes_icon2(rlis,BSAVE,ICSAVE,TSAVE,DISABLED); 
	send_shell(R_DEL_PLST);
	}

/* ~~~~~~~~~~~~~~ */
/* Status message */
/* ~~~~~~~~~~~~~~ */

void status(char *texte,int flag,int redraw)
	{
	OBJECT	*status;
	int		x,y,w,h;

	switch(rezol)
		{
		case REZ_16:		status=adresse(STAT16);	
							break;
		case REZ_LOW_16:	status=adresse(STATLW16);
							break;
		case REZ_MONO:		status=adresse(STATMONO);
							break;
		case REZ_LOW_MONO:	status=adresse(STLOWMON);
							break;
		}

	form_center(status,&x,&y,&w,&h);
    x=max(x,x_bureau);
    y=max(y,y_bureau);
    (status)->ob_x=x;(status)->ob_y=y;
	graf_mouse(M_OFF,0);

	if	(flag)
		{
		if	(!redraw)
			{
			(status+LGSTAT)->ob_spec.tedinfo->te_ptext=texte;
			objc_draw(status,LGSTAT,10,x,y,w,h);
			}
		else
			{
			wind_update(BEG_UPDATE);
			form_dial(FMD_START,x,y,w,h,x,y,w,h);
			(status+LGSTAT)->ob_spec.tedinfo->te_ptext=texte;
			graf_growbox(work_out[0]/2,work_out[1]/2,0,0,x,y,w,h);
			objc_draw(status,0,10,x,y,w,h);
			}
		}
	else
		{
		graf_shrinkbox(work_out[0]/2,work_out[1]/2,0,0,x,y,w,h);
		form_dial(FMD_FINISH,x,y,w,h,x,y,w,h);
		wind_update(END_UPDATE);		
		}		
	graf_mouse(M_ON,0);
	}
	
/* ---------------------------------------------------------------------------------- */
/* Messages to send to the shell													  */
/* ---------------------------------------------------------------------------------- */

void send_shell(int msg)
	{
	long	adr_nom;
	int		dummy=0;
	
	if (ID_SHELL==-1) return;
	
	com_buffer[0]=msg;
	com_buffer[1]=id_appl;
	com_buffer[2]=0;
	
	switch(msg)
		{
		case R_FREQ:    com_buffer[3]=old_freq;
					    break;
		case R_NEXT_MOD:
		case R_PREV_MOD:
		case R_BEGLOAD: adr_nom=(long)nom_module;
						com_buffer[3]=(int)(adr_nom>>16);
						com_buffer[4]=(int)(adr_nom & 0xFFFF);
						break;
		case R_BEG_LOAD_PLST:
		case R_BEG_SAVE_PLST:
						adr_nom=(long)pl_path;
						com_buffer[3]=(int)(adr_nom>>16);
						com_buffer[4]=(int)(adr_nom & 0xFFFF);
						break;
		case R_PLAYLIST:
						adr_nom=(long)liste;
						com_buffer[3]=(int)(adr_nom>>16);
						com_buffer[4]=(int)(adr_nom & 0xFFFF);
						com_buffer[5]=nb_mod_play;
						break;
		case R_TIME_PLST:
						com_buffer[3]=play_time.heure;
						com_buffer[4]=play_time.minute;
						com_buffer[5]=play_time.seconde;
						break;
		case R_MOVE:	wind_get(w_handle,WF_CURRXYWH,&com_buffer[3],&com_buffer[4],
						         &com_buffer[5],&com_buffer[6]);
						break;
		case R_INFOS:	com_buffer[3]=w_handle;
						com_buffer[4]=gr_handle;
						poke(&com_buffer[5],0,(char)VERSION);
						poke(&com_buffer[5],1,(char)NIVEAU);
						com_buffer[6]=w_h_oscillo;
						com_buffer[7]=w_h_liste;
						com_buffer[8]=w_h_vu_metre; /* !!!! */
						break;
		case R_MOVE_OSCILLO:
						wind_get(w_h_oscillo,WF_CURRXYWH,&com_buffer[3],&com_buffer[4],
								 &com_buffer[5],&com_buffer[6]);
						break;
		case R_MOVE_PLAYLIST:
						wind_get(w_h_liste,WF_CURRXYWH,&com_buffer[3],&com_buffer[4],
								 &com_buffer[5],&com_buffer[6]);
						break;
		case R_MOVE_VUM:wind_get(w_h_vu_metre,WF_CURRXYWH,&com_buffer[3],&com_buffer[4],
							     &com_buffer[5],&com_buffer[6]);
					    break;
		case R_SEL_PLST:com_buffer[3]=mod_select;
						break;
		case R_CUR_TIME:if (machine==MCH_FALCON) {com_buffer[3]=fmt_heure;com_buffer[4]=fmt_minute;com_buffer[5]=fmt_seconde;}
						else {com_buffer[3]=smt_heure;com_buffer[4]=smt_minute;com_buffer[5]=smt_seconde;}
						break;
		case R_CYCLE_WIN:
						wind_get(dummy,WF_TOP,&com_buffer[3],&dummy,&dummy,&dummy);
						break;
		}
	
	wind_update(BEG_UPDATE);
	appl_write(ID_SHELL,16,com_buffer); 	
	wind_update(END_UPDATE);
	evnt_timer(1000,0);				
	}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* Ask to a window to be redrawed */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

void redessine_window(int handle)
	{
	int	e_buf[8];
	int	x,y,w,h;
	
	wind_get(handle,WF_WORKXYWH,&x,&y,&w,&h);
	e_buf[0]=WM_REDRAW;
	e_buf[1]=id_appl;
	e_buf[2]=0;
	e_buf[3]=handle;
	e_buf[4]=x;
	e_buf[5]=y;
	e_buf[6]=w;
	e_buf[7]=h;	
	wind_update(BEG_UPDATE);
	appl_write(id_appl,16,e_buf);
	wind_update(END_UPDATE);
	}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* Send a message to application itself */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

void send_msg(int message,int ac_close)
	{
	int	e_buf[8];
	
	e_buf[0]=message;
	e_buf[1]=id_appl;
	if (ac_close) e_buf[3]=id_acc; else e_buf[3]=0;
	e_buf[2]=e_buf[4]=e_buf[5]=e_buf[6]=e_buf[7]=0;
	wind_update(BEG_UPDATE);
	appl_write(id_appl,16,e_buf);
	wind_update(END_UPDATE);
	}

/* ~~~~~~~~~~~~~~~~ */
/* malloc with test */
/* ~~~~~~~~~~~~~~~~ */

void *_malloc(long taille)
	{
	void 	*ret;

	if	((machine==MCH_TT)||(machine==MCH_FALCON)) ret=Mxalloc(taille,0);
	else ret=Malloc(taille);
	if 	(ret==NULL)
		{
		form_alert(1,"[3][Memory allocation error|Program can't continue.|Reboot your system !][ OK ]");
		fin_programme();
		if (_app) exit(-1);
		send_msg(AC_CLOSE,TRUE);
		FORBIDDEN=TRUE;
		}

	return ret;
	}
	
long _coreleft(void)
	{
	if ((machine==MCH_TT)||(machine==MCH_FALCON)) return (long)Mxalloc(-1,0);
	else return (long)Malloc(-1);
	}
	
/* ~~~~~~~~~~~~~~~~~~ */
/* Chiffres with LEDs */
/* ~~~~~~~~~~~~~~~~~~ */

void digit(char *c,int val,int nbe)
	{
	if	(val<10) 
		{
		c[0]=nbe;
		c[1]=val+nbe;
		}
	else
		{
		c[0]=(val/10)+nbe;
		c[1]=(val%10)+nbe;
		}
	}

void digit3(char *c,int val,int nbe)
	{
	int	i;
	
	if  (val<10)
		{
		c[0]=c[1]=nbe;
		c[2]=val+nbe;
		}
	else if(val<100)
		{
		c[0]=nbe;
		c[1]=(val/10)+nbe;
		c[2]=(val%10)+nbe;
		}
	else
		{
		i=(val/100);
		c[0]=i+nbe;
		i*=100;
		c[1]=((val-i)/10)+nbe;
		c[2]=((val-i)%10)+nbe;
		}
	}