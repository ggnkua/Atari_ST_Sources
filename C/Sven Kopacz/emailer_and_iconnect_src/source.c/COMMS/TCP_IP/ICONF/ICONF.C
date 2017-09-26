#include <ec_gem.h>
#include <inet.h>
#include "iconf.h"
#include "iconfmem.h"


#define set_ext_type(tree,ob,val)	tree[ob].ob_type &=255; tree[ob].ob_type |= (((char)val)<<8);
#define obj_type(a, b) (a[b].ob_type & 0xff)
#define ext_type(a, b) (a[b].ob_type >> 8)

/* Registrierungsdaten */

char	*reg_active="rMa*paTB*R#-n";
char	*reg_name="nnnnnnnnnnnnnnnnnnnnnnnnnnnnnn";
char	*reg_firma="ffffffffffffffffffffffffffffff";
char	*reg_serial="ssssssssss";

/* Versionsnummer in ICON_VERSION in iconfmem.h */

WINDOW	wdial, wuserin;
DINFO		ddial;
OBJECT	*odial, *oicons, *oscripts, *oscriptpop;

#define X 0
#define Y 1

#define SEL_LOGIN RICOLOGIN-RICO1
#define SEL_LOGOUT RICOLOGOUT-RICO1

int	sx,sy,sw,sh, quit=0;
int ico_off=0, max_ico_off, ico_sel=0;
int	login_off=0, logout_off=0;

/* Edit Objekte in Reihenfolge der Icon-Latte */
int	edit_ob[]={MODEMINIT, PHONE_NR, SCRIPTL1+1, SCRIPTL1+1, DNSIP, EMAIL, PROXYIP,
							 ENVOB, CONF_RETRY, CONN_TO, MAX_UDP, IN_QUEUE_TO};

OBSPEC	save_spec[(SCRIPTLL-SCRIPTL1)/(SCRIPTL2-SCRIPTL1)+1];

#define VIS_SCRIPT_STEPS ((SCRIPTLL-SCRIPTL1)/(SCRIPTL2-SCRIPTL1)+1)

SET_LIST	first_set, *act_set=&first_set, backup_list;

#define MIN_SCRIPT_EDIT 5 /* Script-Schritt <=5 hat Editable-Objekt */

/* -------------------------------------- */
/* Globals for Modem-Popups */
#define NUM_PORT io_ports
#define MAX_PORTS 20
char *port_names[MAX_PORTS];
#define DEF_PORT 0
#define NUM_BAUD 16
char *baud_names[NUM_BAUD]=
{"230400","115200","57600","38400","28800","19200","14400","9600",
 "4800","3600","2400","2000","1800","1200","600","300"};
#define DEF_BAUD 6
#define NUM_HSHK 3
char *hshk_names[NUM_HSHK]={"Off","Xon/Xoff","Rts/Cts"};
#define DEF_HSHK 2
#define NUM_PARITY 3
char *parity_names[NUM_PARITY]={"None","Odd","Even"};
#define DEF_PARITY 0
#define NUM_DBIT 4
char *dbit_names[NUM_DBIT]={"8","7","6","5"};
#define DEF_DBIT 0
#define NUM_SBIT 3
char *sbit_names[NUM_SBIT]={"1","1.5","2"};
#define DEF_SBIT 0

#define set_port(a)	if((a==-1)||(a >= io_ports)){strcpy(odial[MODP1].ob_spec.free_string, port_names[0]);set_ext_type(odial,MODP1,0);}else{strcpy(odial[MODP1].ob_spec.free_string, port_names[a]);set_ext_type(odial,MODP1,a);}
#define set_baud(a)	strcpy(odial[MODP2].ob_spec.free_string, baud_names[a]);set_ext_type(odial,MODP2,a);
#define set_hshk(a)	strcpy(odial[MODP3].ob_spec.free_string, hshk_names[a]);set_ext_type(odial,MODP3,a);
#define set_parity(a)	strcpy(odial[MODP4].ob_spec.free_string, parity_names[a]);set_ext_type(odial,MODP4,a);
#define set_dbit(a)	strcpy(odial[MODP5].ob_spec.free_string, dbit_names[a]);set_ext_type(odial,MODP5,a);
#define set_sbit(a)	strcpy(odial[MODP6].ob_spec.free_string, sbit_names[a]);set_ext_type(odial,MODP6,a);


int	io_ports;

/* -------------------------------------- */

void	dial_win(void);
void	init_mainrs(void);
void	init_icos(void);
int		change_frame(int icon_ob);
void	do_dial(int ob);
void	new_ico_val(int val);
void	new_script_val(int val);
void	slide(WINDOW *win, int ob, int min, int max, int now, void (*newval)(int now2));
void	bar(WINDOW *win, int ob, int min, int max, void (*newval)(int now2));
void	fpopup(int ob, char **names, int num);
int		do_popup(WINDOW *root, int parent, OBJECT *pop);
int		do_cpopup(WINDOW *root, int parent, OBJECT *pop, int ch_only);
int		get_ports(void);
int		init_setup_list(void);
void	init_setup(SETUP *set);
void	setup_to_dial(SETUP *set);
void	store_ip(OBJECT *tree, int ob, ulong ip);
ulong	fetch_ip(OBJECT *tree, int ob);
int		script_steps(SCRIPT_STEP *step);
void	service_popup(void);
void	change_service(void);
void	read_proxy(int num);
void	set_proxy(int num);
void	path_select(void);
char	*file_fit(char *dst, char *src, long len);
int		count_setups(void);
void	setpopup(void);
void	rename_setup(void);
void	delete_setup(void);
void	new_setup(void);
void	copy_setup(void);
int 	load_setup(void);
int		save_setup(void);
void	show_info(void);
void	enter_ppp_user(void);
void	enter_ppp_pass(void);
void	encode(char *string, int len);
void	decode(char *string, int len);
int		check_reg(void);

/* -------------------------------------- */
/* -------------------------------------- */

int main(void)
{
	e_start_as(ACC|PRG,"Iconf fÅr PPP-Connect");
	if(ap_type & (ACC|PRG))
	{
		uses_vdi();
		uses_txwin();
		if(rsrc_load("ICONF.RSC")==0)
		{
			form_alert(1,"[3][Error reading RSC.|File not found or|insufficient memory.][Cancel]");
			goto fin;
		}

		if(check_reg()==0) goto fin;
		if(get_ports()==0) goto fin;
		
		wind_get(0,WF_WORKXYWH,&sx,&sy,&sw,&sh);
		if(init_setup_list()==0) goto fin;
		dial_win();
	}

fin:
	rsrc_free();
	e_quit();
	return(0);
}

/* -------------------------------------- */

void code_name(char *ps,char *name)
{
    int i, len;
    len = (int) strlen(name);
    for (i=0; i < len; i++)
    {
        ps[i] = 255 ^name[i];
    }
    ps[len] = 0;
}

int checkser(char *sernum)
{
    long ser,ch;
    char s[7];
    int i;
    for(i=2;i<8;i++)
        s[i-2]=sernum[i];
    s[6]='\0';
    ser=atol(s); ch=sernum[9]-48;
    if(((ser&5)==ch)&&
        (strncmp(sernum,"31",2)==0)&&
        (sernum[8]=='0')&&
        (strcmp(sernum+2,"00000000")!=0))
        return(1);

    return(0); 
}

int check_reg(void)
{
	OBJECT *tree;

	if(reg_active[strlen(reg_active)-1]!='n')
	{
		char	buf[20];
	
		rsrc_gaddr(0, INFOTREE, &tree);
	
		code_name(buf, reg_serial);
		if(!(checkser(buf)))
		{
			form_alert(1,"[3][Not registered.][Cancel]");
			return(0);
		}
		
		code_name(tree[USERNAME].ob_spec.tedinfo->te_ptext, reg_name);
		code_name(tree[USERFIRMA].ob_spec.tedinfo->te_ptext, reg_firma);
	}
	else
	{
		rsrc_gaddr(0, INFOTREE, &tree);

		strcpy(tree[USERNAME].ob_spec.tedinfo->te_ptext, "BETAVERSION");
		strcpy(tree[USERFIRMA].ob_spec.tedinfo->te_ptext, "");
	}

	return(1);
}

/* -------------------------------------- */

char *gettext(int ob)
{
	OBJECT *text_tree;
	
	rsrc_gaddr(0,STRINGS, &text_tree);
	return(text_tree[ob].ob_spec.free_string);
}

/* -------------------------------------- */

int init_setup_list(void)
{
	first_set.set=(SETUP*)calloc(sizeof(SETUP), 1);
	if(first_set.set==NULL)	return(0);
	first_set.next=NULL;
	init_setup(first_set.set);
	return(1);
}

/* -------------------------------------- */

void make_backup_setup(void)
{
	SET_LIST	*sl=&backup_list, *sr=&first_set;
	
	while(sr)
	{
		sl->set=(SETUP*)malloc(sizeof(SETUP));
		if(sl->set==NULL) goto clear_all;
		*(sl->set)=*(sr->set);
		sl->next=(SET_LIST*)malloc(sizeof(SET_LIST));
		if(sl->next==NULL) goto clear_all;
		sl=sl->next;
		sl->next=NULL;
		sl->set=NULL;
		sr=sr->next;
	}
	return;
/* Falls irgendwo der Speicher nicht langt, sein lassen */
clear_all:
	sl=&backup_list;
	while(sl)
	{
		if(sl->set) free(sl->set);
		sr=sl;
		sl=sl->next;
		if(sr != &backup_list) free(sr);
	}
	backup_list.set=NULL;
}

/* -------------------------------------- */

void update_backup_setup(void)
{
	SET_LIST	*sl=&backup_list, *sr=&first_set;
	
	while(sr && sl)
	{
		if((sl->set==NULL) || (sr->set==NULL)) return;
		*(sl->set)=*(sr->set);
		if(sl->next==NULL)	/* Falls neue dazugekommen sind */
		{
			sl->next=malloc(sizeof(SET_LIST));
			if(sl->next)
			{
				sl->next->set=calloc(sizeof(SETUP),1);
				sl->next->next=NULL;
			}
		}
		sl=sl->next;
		sr=sr->next;
	}
}

/* -------------------------------------- */

int check_backup_setup(void)
{
	SET_LIST	*sl=&backup_list, *sr=&first_set;
	
	while(sr)
	{
		if(sl==NULL) return(0);
		if(sl->set==NULL) return(0);
		if(memcmp(sl->set, sr->set, sizeof(SETUP))!=0) return(0);
		sl=sl->next;
		sr=sr->next;
	}
	return(1);
}

/* -------------------------------------- */

void set_script_step(SCRIPT_STEP *step, int action, int para, char *text)
{
	step->action=action;
	step->param=para;
	step->free_string[28]=0;
	if(text)
		strncpy(step->free_string, text, 28);
	else
		step->free_string[0]=0;
}

/* -------------------------------------- */

void delete_step(SCRIPT_STEP *list, int a)
{
	int b;
	
	if((a==49)||(a==script_steps(list)-1))
	{
		form_alert(1,gettext(A1));
		return;
	}
	
	for(b=a+1; b < 50; ++b)
		list[b-1]=list[b];
}

/* -------------------------------------- */

void insert_step(SCRIPT_STEP *list, int a)
{
	int b;
	
	for(b=49; b > a; --b)
		list[b]=list[b-1];
}

/* -------------------------------------- */

void check_editable(void)
{/* PrÅft ob das aktuelle dedit Objekt fÅr Script gÅltig ist, 
		wenn nicht wird ein neues gesetzt */
		
	int ob=SCRIPTL1+1;
	
	if((odial[ddial.dedit].ob_flags & EDITABLE) &&
		 (!(odial[ddial.dedit].ob_flags & HIDETREE)))
		 	return;	/* Ok */
		 	
	while(ob <= SCRIPTLL+1)
	{
		if((odial[ob].ob_flags & EDITABLE) &&
			 (!(odial[ob].ob_flags & HIDETREE)))
		{ ddial.dedit=ob; return; }	 
		++ob;
	}
	ddial.dedit=SCRIPTWAIT;
}

/* -------------------------------------- */

void init_setup(SETUP *set)
{
	int	a;
	
	strcpy(set->name, "Unbenannt");
	set->port=DEF_PORT;
	set->baud=DEF_BAUD;
	set->hshake=DEF_HSHK;
	set->parity=DEF_PARITY;
	set->dbits=DEF_DBIT;
	set->sbits=DEF_SBIT;

	strcpy(set->modem_init, "atz");
	
	set->hang_use_dtr=0;
	strcpy(set->hang_escape, "+++");
	set->hang_wait=2;
	strcpy(set->hang_at, "ath");

	/*	
	set_script_step(&(set->login_step[0]), SC_SEND_STRING, 1, "atz");
	set_script_step(&(set->login_step[1]), SC_WAIT_FOR, 0, "OK");
	set_script_step(&(set->login_step[2]), SC_SEND_STRING, 1, "atdt <phone number>");
	set_script_step(&(set->login_step[3]), SC_WAIT_FOR, 0, "CONNECT");
	set_script_step(&(set->login_step[4]), SC_WAIT_FOR, 0, "Login:");
	set_script_step(&(set->login_step[5]), SC_USER_INPUT, 1, "Username:");
	set_script_step(&(set->login_step[6]), SC_WAIT_FOR, 0, "Password:");
	set_script_step(&(set->login_step[7]), SC_SECRET_INPUT, 1, "Password:");
	set_script_step(&(set->login_step[8]), SC_WAIT_FOR, 0, "successfull");
	*/
	set_script_step(&(set->login_step[0]), SC_DONE, 1, NULL);
	set->login_wait_to=30;
	set->login_restart_to=30;
	
	set_script_step(&(set->logout_step[0]), SC_DONE, 0, NULL);
	set->logout_wait_to=5;
	set->logout_hangup_to=10;

	set->dns_ip=0;
	set->dns_initial_delay=2;
	set->dns_initial_delay_set=1;
	set->query_to=6;
	set->query_rt=4;
	set->use_cache=1;
	set->cache_size=50;
	
	set->email[0]=0;
	set->pop_ip=set->smtp_ip=set->news_ip=set->time_ip=0;
	for(a=0; a < 20; ++a) set->reserved_ip[a]=0;
	
	for(a=0; a < 10; ++a)
	{
		strcpy(set->proxies[a].service, "not used");
		(set->proxies[a]).ip=set->proxies[a].port=0;
		memset(set->proxies[a].not_use, 0, 6*40+2);
	}
	strcpy(set->proxies[0].service, "http");
	strcpy(set->proxies[1].service, "ftp");
	strcpy(set->proxies[2].service, "wais");
	strcpy(set->proxies[3].service, "gopher");
	strcpy(set->proxies[4].service, "news");
	strcpy(set->proxies[9].service, "any other");
	
	set->default_ip=0;

	set->phone_number[0]=0;
	set->dial_type=0;
	set->redial_wait=30;
					
	set->ppp_default_ip=0;
	set->ppp_auth_user[0]=0;
	set->ppp_auth_pass[0]=0;
	set->conf_retry=10;
	set->conf_to=500;
	set->term_retry=2;
	set->term_to=1000;
	set->nak_ack=6;
	set->lcp_echo_sec=0;
	
	set->path_env=1;
	strcpy(set->etc_path, "C:\\");
	strcpy(set->etc_env, "ETCPATH");
	set->min_port=1025;
	set->max_port=4999;
	set->max_backlog=16;
	
	set->conn_to=60;
	set->trans_to=60;
	set->default_rcv_win=2048;
	set->default_snd_win=512;
	set->precedence_raise=1;
	
	set->max_udp_ports=64;
	
	set->in_queue_to=35;
	set->tos=0;
	set->precedence=0;
	set->ttl=64;
	set->mtu=576;
	
	for(a=0; a < RESERVED_INT; ++a)
		set->reserved_int[a]=0;
		
	for(a=0; a < 24; ++a)
		set->service_names[a][0]=0;
	for(a=0; a < 10; ++a)
		set->proxy_names[a][0]=0;

	set->pop_user[0]=0;	
	set->pop_pass[0]=0;	

	set->nntp_user[0]=0;	
	set->nntp_pass[0]=0;	
	
	set->version=ICON_SETUP_VERSION;
}

/* -------------------------------------- */

void objc_copy(OBJECT *dst, int ob1, OBJECT *src, int ob2)
{
	dst[ob1].ob_type=src[ob2].ob_type;
	dst[ob1].ob_flags=src[ob2].ob_flags;
	dst[ob1].ob_state=src[ob2].ob_state;
	if(src[ob2].ob_type==G_FTEXT)
		*(dst[ob1].ob_spec.tedinfo)=*(src[ob2].ob_spec.tedinfo);
	else if((obj_type(src,ob2)==G_BUTTON) && (src[ob2].ob_state & SHADOWED))
		strcpy(dst[ob1].ob_spec.free_string,src[ob2].ob_spec.free_string);
	else
		dst[ob1].ob_spec=src[ob2].ob_spec;
	dst[ob1].ob_x=src[ob2].ob_x;
	dst[ob1].ob_width=src[ob2].ob_width;
}

/* -------------------------------------- */

int script_steps(SCRIPT_STEP *step)
{
	int a=0;
	
	while(step[a].action != SC_DONE) ++a;
	return(++a);	/* Zeilenanzahl gefragt! */
}

/* -------------------------------------- */

void read_login_to(SETUP *set)
{
	set->login_wait_to=atoi(odial[SCRIPTWAIT].ob_spec.tedinfo->te_ptext);
	set->login_restart_to=atoi(odial[SCRIPTRESTART].ob_spec.tedinfo->te_ptext);
}

/* -------------------------------------- */

void read_logout_to(SETUP *set)
{
	set->logout_wait_to=atoi(odial[SCRIPTWAIT].ob_spec.tedinfo->te_ptext);
	set->logout_hangup_to=atoi(odial[SCRIPTRESTART].ob_spec.tedinfo->te_ptext);
}

/* -------------------------------------- */

void set_login_script(SETUP *set)
{
	int a=0, b, ix, max_slide_off;

	/* PrÅfen, ob offset noch gÅltig ist */
	if(login_off > script_steps(set->login_step)-VIS_SCRIPT_STEPS)
		login_off=script_steps(set->login_step)-VIS_SCRIPT_STEPS;
	if(login_off < 0) login_off=0;
	
	do
	{
		ix=a*(SCRIPTL2-SCRIPTL1)+SCRIPTL1;
		for(b=0; b < (SCRIPTL2-SCRIPTL1); ++b)
		{
			if(b==1)	/* Bei mittleren Objekten erst Original-Spec holen */
				odial[ix+b].ob_spec=save_spec[a];
			objc_copy(odial, ix+b, oscripts, set->login_step[a+login_off].action*(SCRIPTL2-SCRIPTL1)+b+STYPL1);
		}

		b=a+login_off;
		switch(set->login_step[b].action)
		{
			case SC_USER_INPUT:
			case SC_SECRET_INPUT:
				if(set->login_step[b].param)
					odial[ix+2].ob_state |= SELECTED;
				else
					odial[ix+2].ob_state &= (~SELECTED);
			break;
			case SC_SEND_STRING:
				if(set->login_step[b].param)
					odial[ix+2].ob_state |= SELECTED;
				else
					odial[ix+2].ob_state &= (~SELECTED);
			case SC_WAIT_FOR:
			case SC_SEND_CHAR:
			case SC_PAUSE:
			case SC_WAIT_CHAR:
				odial[ix+1].ob_spec.tedinfo->te_ptext=set->login_step[b].free_string;
			break;
			case SC_DONE:
				if(set->login_step[b].param)
				{
					odial[ix+1].ob_state &= (~SELECTED);
					odial[ix+2].ob_state |= SELECTED;
				}
				else
				{
					odial[ix+2].ob_state &= (~SELECTED);
					odial[ix+1].ob_state |= SELECTED;
				}
			break;
		}
		++a;
	}	while( (set->login_step[b].action != SC_DONE) &&
					 (a < VIS_SCRIPT_STEPS));
	
	while(a < VIS_SCRIPT_STEPS)
	{
		ix=a*(SCRIPTL2-SCRIPTL1)+SCRIPTL1;
		for(b=0; b < (SCRIPTL2-SCRIPTL1); ++b)
			odial[ix+b].ob_flags|=HIDETREE;
		++a;
	}

	itoa(set->login_wait_to, odial[SCRIPTWAIT].ob_spec.tedinfo->te_ptext, 10);
	itoa(set->login_restart_to, odial[SCRIPTRESTART].ob_spec.tedinfo->te_ptext, 10);
	
	/* Slider */
	/* Steps zÑhlen */
	a=script_steps(set->login_step);
	
	/* Max. Anzeige-Zeilen */
	b=VIS_SCRIPT_STEPS;
	if(a <= b)
	{
		odial[SCRIPTSLIDE].ob_y=0;
		odial[SCRIPTSLIDE].ob_height=odial[SCRIPTBAR].ob_height;
	}
	else
	{/* slide_h/bar_h=vis_steps/script_steps */
		odial[SCRIPTSLIDE].ob_height=(odial[SCRIPTBAR].ob_height*b)/a;
		/* script_off/max_script_off=slide_off/max_slide_off */
		max_slide_off=odial[SCRIPTBAR].ob_height-odial[SCRIPTSLIDE].ob_height;
		odial[SCRIPTSLIDE].ob_y=(login_off*max_slide_off)/(a-b);	
	}
	
	strcpy(odial[SCRIPTRESTART].ob_spec.tedinfo->te_ptmplt, gettext(LOGINSTRING));
}

/* -------------------------------------- */

void set_logout_script(SETUP *set)
{
	int a=0, b, ix, max_slide_off;

	/* PrÅfen, ob offset noch gÅltig ist */
	if(logout_off > script_steps(set->logout_step)-VIS_SCRIPT_STEPS)
		logout_off=script_steps(set->logout_step)-VIS_SCRIPT_STEPS;
	if(logout_off < 0) logout_off=0;
	
	do
	{
		ix=a*(SCRIPTL2-SCRIPTL1)+SCRIPTL1;
		for(b=0; b < (SCRIPTL2-SCRIPTL1); ++b)
		{
			if(b==1)	/* Bei mittleren Objekten erst Original-Spec holen */
				odial[ix+b].ob_spec=save_spec[a];
			objc_copy(odial, ix+b, oscripts, set->logout_step[a+logout_off].action*(SCRIPTL2-SCRIPTL1)+b+STYPL1);
		}

		b=a+logout_off;
		switch(set->logout_step[b].action)
		{
			case SC_SEND_STRING:
				if(set->logout_step[b].param)
					odial[ix+2].ob_state |= SELECTED;
				else
					odial[ix+2].ob_state &= (~SELECTED);
			case SC_WAIT_FOR:
			case SC_SEND_CHAR:
			case SC_PAUSE:
			case SC_WAIT_CHAR:
				odial[ix+1].ob_spec.tedinfo->te_ptext=set->logout_step[b].free_string;
			break;
			case SC_DONE:
				odial[ix+1].ob_flags |= HIDETREE;
				odial[ix+2].ob_flags |= HIDETREE;
			break;
		}
		++a;
	}	while( (set->logout_step[b].action != SC_DONE) &&
					 (a < VIS_SCRIPT_STEPS));
	
	while(a < VIS_SCRIPT_STEPS)
	{
		ix=a*(SCRIPTL2-SCRIPTL1)+SCRIPTL1;
		for(b=0; b < (SCRIPTL2-SCRIPTL1); ++b)
			odial[ix+b].ob_flags|=HIDETREE;
		++a;
	}

	itoa(set->logout_wait_to, odial[SCRIPTWAIT].ob_spec.tedinfo->te_ptext, 10);
	itoa(set->logout_hangup_to, odial[SCRIPTRESTART].ob_spec.tedinfo->te_ptext, 10);

	/* Slider */
	/* Steps zÑhlen */
	a=script_steps(set->logout_step);
	
	/* Max. Anzeige-Zeilen */
	b=VIS_SCRIPT_STEPS;
	if(a <= b)
	{
		odial[SCRIPTSLIDE].ob_y=0;
		odial[SCRIPTSLIDE].ob_height=odial[SCRIPTBAR].ob_height;
	}
	else
	{/* slide_h/bar_h=vis_steps/script_steps */
		odial[SCRIPTSLIDE].ob_height=(odial[SCRIPTBAR].ob_height*b)/a;
		/* script_off/max_script_off=slide_off/max_slide_off */
		max_slide_off=odial[SCRIPTBAR].ob_height-odial[SCRIPTSLIDE].ob_height;
		odial[SCRIPTSLIDE].ob_y=(logout_off*max_slide_off)/(a-b);	
	}

	strcpy(odial[SCRIPTRESTART].ob_spec.tedinfo->te_ptmplt, gettext(LOGOUTSTRING));
}

/* -------------------------------------- */
void setup_to_dial(SETUP *set)
{
	int a;
	OBJECT	*tree;
		
	strcpy(odial[SETPOP].ob_spec.free_string, set->name);

	if(set->port==-1)
		odial[VIA_MAC].ob_state |= SELECTED;
	else
		odial[VIA_MAC].ob_state &= (~SELECTED);
	set_port(set->port);
	set_baud(set->baud);
	set_hshk(set->hshake);
	set_parity(set->parity);
	set_dbit(set->dbits);
	set_sbit(set->sbits);

	strcpy(odial[MODEMINIT].ob_spec.tedinfo->te_ptext, set->modem_init);

	odial[HANGCMD].ob_state&=(~SELECTED);
	odial[HANGDTR].ob_state&=(~SELECTED);
	if(set->hang_use_dtr)
		odial[HANGDTR].ob_state|=SELECTED;
	else
		odial[HANGCMD].ob_state|=SELECTED;
	strcpy(odial[HANGESC].ob_spec.tedinfo->te_ptext, set->hang_escape);
	odial[HANGPAUSE].ob_spec.tedinfo->te_ptext[0]=set->hang_wait+48;
	odial[HANGPAUSE].ob_spec.tedinfo->te_ptext[1]=0;
	strcpy(odial[HANGAT].ob_spec.tedinfo->te_ptext, set->hang_at);
	
	set_login_script(set);
	set_logout_script(set);

	store_ip(odial, DNSIP, set->dns_ip);
	itoa(set->dns_initial_delay, odial[DNSINITDELAY].ob_spec.tedinfo->te_ptext, 10);
	itoa(set->query_to, odial[QUERYTO].ob_spec.tedinfo->te_ptext, 10);
	itoa(set->query_rt, odial[QUERYRT].ob_spec.tedinfo->te_ptext, 10);
	if(set->use_cache)
		odial[CACHE].ob_state |= SELECTED;
	else
		odial[CACHE].ob_state &= (~SELECTED);
	itoa(set->cache_size, odial[CACHESIZE].ob_spec.tedinfo->te_ptext, 10);
	
	objc_xtedcpy(odial, EMAIL, set->email);
	objc_xtedcpy(odial, REALNAME, set->real_name);
	objc_xtedcpy(odial, POPIP, set->service_names[0]);
	objc_xtedcpy(odial, SMTPIP, set->service_names[1]);
	objc_xtedcpy(odial, NEWSIP, set->service_names[2]);
	objc_xtedcpy(odial, TIMEIP, set->service_names[3]);
	objc_xtedcpy(odial, SERVPOPUSER, set->pop_user);	
	objc_xtedcpy(odial, SERVPOPPASS, set->pop_pass);	
	objc_xtedcpy(odial, SERVNNTPUSER, set->nntp_user);	
	objc_xtedcpy(odial, SERVNNTPPASS, set->nntp_pass);	

	strcpy(odial[SERVPOP].ob_spec.free_string, set->proxies[ext_type(odial, SERVPOP)].service);
	objc_xtedcpy(odial, PROXYIP, set->proxy_names[ext_type(odial, SERVPOP)]);
	itoa(set->proxies[ext_type(odial, SERVPOP)].port, odial[PROXYPORT].ob_spec.tedinfo->te_ptext, 10);

	a=PNOT1;
	while(a <= PNOT6)
	{
		strncpy(odial[a].ob_spec.tedinfo->te_ptext, &(set->proxies[ext_type(odial, SERVPOP)].not_use[(a-PNOT1)*40]), 40);
		odial[a].ob_spec.tedinfo->te_ptext[40]=0;
		++a;
	}

	store_ip(odial, LOCAL_IP, set->default_ip);
	objc_xtedcpy(odial, PHONE_NR, set->phone_number);
	set_ext_type(odial, DIALTYPE, set->dial_type);
	rsrc_gaddr(0, DIALPOP,&tree);
	strcpy(odial[DIALTYPE].ob_spec.free_string, &(tree[set->dial_type+1].ob_spec.free_string[2]));
	itoa(set->redial_wait, odial[REDIAL_WAIT].ob_spec.tedinfo->te_ptext, 10);

	if(set->ppp_auth_user[0])
		strcpy(odial[PPPUSERSET].ob_spec.tedinfo->te_ptext, gettext(PPPSET2));
	else
		strcpy(odial[PPPUSERSET].ob_spec.tedinfo->te_ptext, gettext(PPPSET1));
	if(set->ppp_auth_pass[0])
		strcpy(odial[PPPPASSSET].ob_spec.tedinfo->te_ptext, gettext(PPPSET2));
	else
		strcpy(odial[PPPPASSSET].ob_spec.tedinfo->te_ptext, gettext(PPPSET1));

	itoa(set->conf_retry, odial[CONF_RETRY].ob_spec.tedinfo->te_ptext, 10);
	itoa(set->conf_to, odial[CONF_TO].ob_spec.tedinfo->te_ptext, 10);
	itoa(set->term_retry, odial[TERM_RETRY].ob_spec.tedinfo->te_ptext, 10);
	itoa(set->term_to, odial[TERM_TO].ob_spec.tedinfo->te_ptext, 10);
	itoa(set->nak_ack, odial[NAK_ACK].ob_spec.tedinfo->te_ptext, 10);
	itoa(set->lcp_echo_sec, odial[LCP_ECHO].ob_spec.tedinfo->te_ptext, 10);

	if(set->path_env)
	{
		odial[ETCPATH].ob_state &= (~SELECTED);
		odial[ETCENV].ob_state |= SELECTED;
	}
	else
	{
		odial[ETCENV].ob_state &= (~SELECTED);
		odial[ETCPATH].ob_state |= SELECTED;
	}
	strcpy(odial[PATHOB].ob_spec.tedinfo->te_ptext, set->etc_path);
	strcpy(odial[ENVOB].ob_spec.tedinfo->te_ptext, set->etc_env);
	itoa(set->min_port, odial[MINPORT].ob_spec.tedinfo->te_ptext, 10);
	itoa(set->max_port, odial[MAXPORT].ob_spec.tedinfo->te_ptext, 10);
	itoa(set->max_backlog, odial[MAXLOG].ob_spec.tedinfo->te_ptext, 10);
	
	itoa(set->conn_to, odial[CONN_TO].ob_spec.tedinfo->te_ptext, 10);
	itoa(set->trans_to, odial[TRANS_TO].ob_spec.tedinfo->te_ptext, 10);
	itoa(set->default_rcv_win, odial[DEFAULT_RCV_WIN].ob_spec.tedinfo->te_ptext, 10);
	itoa(set->default_snd_win, odial[DEFAULT_SND_WIN].ob_spec.tedinfo->te_ptext, 10);
	if(set->precedence_raise & 1)
		odial[PREC_RAISE].ob_state |= SELECTED;
	else
		odial[PREC_RAISE].ob_state &= (~SELECTED);
	if(set->precedence_raise & 2)
		odial[SEND_AHEAD].ob_state &= (~SELECTED);	/* Bit=Disable! */
	else
		odial[SEND_AHEAD].ob_state |= SELECTED;
	
	itoa(set->max_udp_ports, odial[MAX_UDP].ob_spec.tedinfo->te_ptext, 10);

	itoa(set->in_queue_to, odial[IN_QUEUE_TO].ob_spec.tedinfo->te_ptext, 10);
	itoa(set->tos, odial[IPTOS].ob_spec.tedinfo->te_ptext, 10);
	itoa(set->precedence, odial[PREC].ob_spec.tedinfo->te_ptext, 10);
	itoa(set->ttl, odial[TTL].ob_spec.tedinfo->te_ptext, 10);
	ltoa(set->mtu, odial[MTU].ob_spec.tedinfo->te_ptext, 10);
}

/* -------------------------------------- */

void dial_to_setup(SETUP *set)
{
	int a;
	
	if(odial[VIA_MAC].ob_state & SELECTED)
		set->port=-1;
	else
		set->port=ext_type(odial, MODP1);
	set->baud=ext_type(odial, MODP2);
	set->hshake=ext_type(odial, MODP3);
	set->parity=ext_type(odial, MODP4);
	set->dbits=ext_type(odial, MODP5);
	set->sbits=ext_type(odial, MODP6);
	strcpy(set->port_name, port_names[ext_type(odial, MODP1)]);

	strcpy(set->modem_init, odial[MODEMINIT].ob_spec.tedinfo->te_ptext);

	if(odial[HANGDTR].ob_state & SELECTED)
		set->hang_use_dtr=1;
	else
		set->hang_use_dtr=0;
	strcpy(set->hang_escape, odial[HANGESC].ob_spec.tedinfo->te_ptext);
	set->hang_wait=odial[HANGPAUSE].ob_spec.tedinfo->te_ptext[0]-48;
	strcpy(set->hang_at, odial[HANGAT].ob_spec.tedinfo->te_ptext);

	if(ico_sel==SEL_LOGIN)	read_login_to(set);
	if(ico_sel==SEL_LOGOUT)	read_logout_to(set);
	
	/* Strings in scripts nach Para kopieren */
	a=0;
	while(set->login_step[a].action != SC_DONE)
	{
		switch(set->login_step[a].action)
		{	
			case SC_SEND_CHAR:
			case SC_PAUSE:
			case SC_WAIT_CHAR:
				set->login_step[a].param=atoi(set->login_step[a].free_string);
			break;
		}
		++a;
	}
	a=0;
	while(set->logout_step[a].action != SC_DONE)
	{
		switch(set->logout_step[a].action)
		{	
			case SC_SEND_CHAR:
			case SC_PAUSE:
			case SC_WAIT_CHAR:
				set->logout_step[a].param=atoi(set->logout_step[a].free_string);
			break;
		}
		++a;
	}
	
	set->dns_ip=fetch_ip(odial, DNSIP);
	set->dns_initial_delay=atoi(odial[DNSINITDELAY].ob_spec.tedinfo->te_ptext);

	set->query_to=atoi(odial[QUERYTO].ob_spec.tedinfo->te_ptext);
	set->query_rt=atoi(odial[QUERYRT].ob_spec.tedinfo->te_ptext);
	if(odial[CACHE].ob_state & SELECTED)
		set->use_cache=1;
	else
		set->use_cache=0;
	set->cache_size=atoi(odial[CACHESIZE].ob_spec.tedinfo->te_ptext);
	
	set->pop_ip=0; set->smtp_ip=0; set->news_ip=0; set->time_ip=0;
	for(a=0; a < 20; ++a) set->reserved_ip[a]=0;
	strcpy(set->email, xted(odial, EMAIL)->te_ptext);
	strcpy(set->real_name, xted(odial, REALNAME)->te_ptext);
	strcpy(set->service_names[0], xted(odial, POPIP)->te_ptext);
	strcpy(set->pop_user, xted(odial, SERVPOPUSER)->te_ptext);
	strcpy(set->pop_pass, xted(odial, SERVPOPPASS)->te_ptext);
	strcpy(set->nntp_user, xted(odial, SERVNNTPUSER)->te_ptext);
	strcpy(set->nntp_pass, xted(odial, SERVNNTPPASS)->te_ptext);
	strcpy(set->service_names[1], xted(odial, SMTPIP)->te_ptext);
	strcpy(set->service_names[2], xted(odial, NEWSIP)->te_ptext);
	strcpy(set->service_names[3], xted(odial, TIMEIP)->te_ptext);
	
	strcpy(set->proxy_names[ext_type(odial, SERVPOP)], xted(odial, PROXYIP)->te_ptext);
	set->proxies[ext_type(odial, SERVPOP)].port=atoi(odial[PROXYPORT].ob_spec.tedinfo->te_ptext);
	for(a=PNOT1; a <= PNOT6; ++a)
		strcpy(&(set->proxies[ext_type(odial, SERVPOP)].not_use[(a-PNOT1)*40]), odial[a].ob_spec.tedinfo->te_ptext);

	set->default_ip=fetch_ip(odial, LOCAL_IP);
	strcpy(set->phone_number, xted(odial, PHONE_NR)->te_ptext);
	set->dial_type=ext_type(odial, DIALTYPE);
	set->redial_wait=atoi(odial[REDIAL_WAIT].ob_spec.tedinfo->te_ptext);

	set->conf_retry=atoi(odial[CONF_RETRY].ob_spec.tedinfo->te_ptext);
	set->conf_to=atoi(odial[CONF_TO].ob_spec.tedinfo->te_ptext);
	set->term_retry=atoi(odial[TERM_RETRY].ob_spec.tedinfo->te_ptext);
	set->term_to=atoi(odial[TERM_TO].ob_spec.tedinfo->te_ptext);
	set->nak_ack=atoi(odial[NAK_ACK].ob_spec.tedinfo->te_ptext);
	set->lcp_echo_sec=atoi(odial[LCP_ECHO].ob_spec.tedinfo->te_ptext);

	if(odial[ETCPATH].ob_state & SELECTED)
		set->path_env=0;
	else
		set->path_env=1;
	strcpy(set->etc_env, odial[ENVOB].ob_spec.tedinfo->te_ptext);
	set->min_port=atoi(odial[MINPORT].ob_spec.tedinfo->te_ptext);
	set->max_port=atoi(odial[MAXPORT].ob_spec.tedinfo->te_ptext);
	set->max_backlog=atoi(odial[MAXLOG].ob_spec.tedinfo->te_ptext);
	
	set->conn_to=atoi(odial[CONN_TO].ob_spec.tedinfo->te_ptext);
	set->trans_to=atoi(odial[TRANS_TO].ob_spec.tedinfo->te_ptext);
	set->default_rcv_win=atoi(odial[DEFAULT_RCV_WIN].ob_spec.tedinfo->te_ptext);
	set->default_snd_win=atoi(odial[DEFAULT_SND_WIN].ob_spec.tedinfo->te_ptext);
	if(odial[PREC_RAISE].ob_state & SELECTED)
		set->precedence_raise=1;
	else
		set->precedence_raise=0;
	if(! (odial[SEND_AHEAD].ob_state & SELECTED)) /* Disable! */
		set->precedence_raise|=2;
	
	set->max_udp_ports=atoi(odial[MAX_UDP].ob_spec.tedinfo->te_ptext);

	set->in_queue_to=atoi(odial[IN_QUEUE_TO].ob_spec.tedinfo->te_ptext);
	set->tos=atoi(odial[IPTOS].ob_spec.tedinfo->te_ptext);
	set->precedence=atoi(odial[PREC].ob_spec.tedinfo->te_ptext);
	set->ttl=atoi(odial[TTL].ob_spec.tedinfo->te_ptext);
	set->mtu=atoi(odial[MTU].ob_spec.tedinfo->te_ptext);
}

/* -------------------------------------- */

void init_mainrs(void)
{ /* Alle Frames auf OPTROOT-Position bringen und hidden setzen
		Dialoggrîûe auf MAINSIZE setzen
		Erstes Icon selektieren und passenden Frame auf visible setzen
		Slider in Iconleiste initialisieren
		Scroll-Edits initialisieren
	 */
	
	int a=OUTFRAME1, x, y;
	OBJECT	*tree;
	
	x=odial[OPTFRAME].ob_x;
	y=odial[OPTFRAME].ob_y;

	while(!(odial[a].ob_flags & LASTOB))
	{
		if((obj_type(odial,a)== G_BOX) && ext_type(odial,a))
		{	odial[a].ob_x=x; odial[a].ob_y=y; }

		++a;
	}

	if(unselect_3d(odial, RICOPARENT))
	{
		odial[SCRIPTBOX].ob_state &=(~SELECTED);
	}
	
	odial[RICO1].ob_state |= SELECTED;
	
	change_frame(RICO1);
	
	odial[0].ob_width=odial[MAINSIZE].ob_x;
	odial[0].ob_height=odial[MAINSIZE].ob_y;
	
	a=1;
	while(!(oicons[a].ob_flags & LASTOB)) ++a;
	x=RICOLAST-RICO1+1;
	
	/* x/a=SLIDE/BAR --> SLIDE=(x*BAR)/a */
	odial[RICOSLIDE].ob_y=0;
	odial[RICOSLIDE].ob_height=(x*odial[RICOBAR].ob_height)/a;
	
	odial[RICOLIST].ob_y+=(odial[RICOPARENT].ob_height-odial[RICOLIST].ob_height)/2;

	max_ico_off=ICOMAX-(RICOLAST-RICO1+1);
	
	for(a=MODDOWN1; a<=MODP6; ++a)
		odial[a].ob_y=odial[a-(MODDOWN1-MODLINE1)].ob_y+
									odial[a-(MODDOWN1-MODLINE1)].ob_height+3;


	y=odial[SCRIPTBOX].ob_height-
		((SCRIPTLL-SCRIPTL1)/(SCRIPTL2-SCRIPTL1)+1)*odial[SCRIPTL1].ob_height;
	y/=(SCRIPTLL-SCRIPTL1)/(SCRIPTL2-SCRIPTL1)+2;
	for(a=SCRIPTL1; a<=SCRIPTLLAST; ++a)
		if(a >= SCRIPTL2)
			odial[a].ob_y=odial[a-(SCRIPTL2-SCRIPTL1)].ob_y+
										odial[a-(SCRIPTL2-SCRIPTL1)].ob_height+y;
		else
			odial[a].ob_y+=y;
			
	objc_xted(odial, EMAIL, 44, 0);
	objc_xted(odial, REALNAME, 64, 0);
	objc_xted(odial, POPIP, 64, 0);
	objc_xted(odial, SERVPOPUSER, 64, 0);
	objc_xted(odial, SERVPOPPASS, 64, '*');
	objc_xted(odial, SERVNNTPUSER, 64, 0);
	objc_xted(odial, SERVNNTPPASS, 64, '*');
	objc_xted(odial, SMTPIP, 64, 0);
	objc_xted(odial, NEWSIP, 64, 0);
	objc_xted(odial, TIMEIP, 64, 0);

	objc_xted(odial, PROXYIP, 64, 0);

	objc_xted(odial, PHONE_NR, 30, 0);
	
	rsrc_gaddr(0, ENTERPASS, &tree);
	objc_xted(tree, PASSINPUT, 30, '*');
}

/* -------------------------------------- */

void profi_mode(int onoff)
{
	OBJECT	*tree;
	int			a;
	
	rsrc_gaddr(0, MAIN, &tree);
	a=0;
	do
	{
		if(tree[a].ob_state & (1<<13))
		{
			if((tree[a].ob_type & 0xff)==G_CICON)
			{
				if(onoff)
					tree[a].ob_state &= (~DISABLED);
				else
					tree[a].ob_state |= DISABLED;
			}
			else
			{
				if(onoff)
					tree[a].ob_flags &= (~HIDETREE);
				else
					tree[a].ob_flags |= HIDETREE;
			}
		}
	}while(!(tree[++a].ob_flags & LASTOB));
	
	rsrc_gaddr(0, ICONS, &tree);
	a=0;
	do
	{
		if(tree[a].ob_state & (1<<13))
		{
			if((tree[a].ob_type & 0xff)==G_CICON)
			{
				if(onoff)
					tree[a].ob_state &= (~DISABLED);
				else
					tree[a].ob_state |= DISABLED;
			}
			else
			{
				if(onoff)
					tree[a].ob_flags &= (~HIDETREE);
				else
					tree[a].ob_flags |= HIDETREE;
			}
		}
	}while(!(tree[++a].ob_flags & LASTOB));
}

/* -------------------------------------- */

int get_ports(void)
{/* Liest den RSVF-Cookie aus und fÅllt port_names[][] */
 /* Return 0=Fehler */
	int			cont=1, a;
	long 		rsv_ob;
	char		*d;

	d=(char*)malloc(12*MAX_PORTS);
	for(a=0; a < MAX_PORTS; ++a)
	{
		port_names[a]=d;
		d+=12;
	}

	if(!find_cookie('RSVF', &rsv_ob))
	{
		form_alert(1,"[3][RSVF-Cookie not found.|Install HSMODEM.][Cancel]");
		return(0);
	}
	
	if(!rsv_ob)
	{
		form_alert(1,"[3][RSVF-Cookie is empty.|No ports found.][Cancel]");
		return(0);
	}
		
	while(cont)
	{
		/* Nur Schnittstellen (128) Åber Gemdos(64) zÑhlen */
		if((*(unsigned char*)(rsv_ob+4)) & (128|64))
		{
			strncpy(port_names[io_ports], *(char**)rsv_ob, 10);
			port_names[io_ports++][10]=0;
			rsv_ob+=8;
		}
		else
		{
			if((*(long*)rsv_ob == -1) || (*(long*)rsv_ob == 0))
				cont=0;
			else
				rsv_ob=*(long*)rsv_ob;
		}
	};
	
	if(io_ports==0)
		form_alert(1,"[3][RSVF-Cookie contains no|gemdos-devices.][Cancel]");

	return(io_ports);
}

/* -------------------------------------- */

void set_default_modem(void)
{/* TrÑgt ersten Port in Dialog ein */
	set_port(DEF_PORT);
	set_baud(DEF_BAUD);
	set_hshk(DEF_HSHK);
	set_parity(DEF_PARITY);
	set_dbit(DEF_DBIT);
	set_sbit(DEF_SBIT);
}

/* -------------------------------------- */

int change_frame(int icon_ob)
{/* Wechselt zum Frame, der durch Icon icon_ob referenziert wird */
	int x,a, ret;

	x=odial[icon_ob].ob_type >> 8;
	a=0;
	while(!(odial[a].ob_flags & LASTOB))
	{
		if((obj_type(odial,a)== G_BOX) && ext_type(odial,a))
		{
			if(ext_type(odial,a) == x)
			{ ret=a;	odial[a].ob_flags &= (~HIDETREE); }
			else
				odial[a].ob_flags |=HIDETREE;
		}
		++a;
	}
	
	return(ret);
}

/* -------------------------------------- */

void init_icos(void)
{
	int a, max_slide_off;
	
	/* Icons */
	for(a=RICO1; a<=RICOLAST; ++a)
	{
		odial[a].ob_spec=oicons[ICO1+a-RICO1+ico_off].ob_spec;
		odial[a].ob_type=oicons[ICO1+a-RICO1+ico_off].ob_type;
		odial[a].ob_state=oicons[ICO1+a-RICO1+ico_off].ob_state;	/* Get PROFI-Flag! */
		if(a-RICO1+ico_off==ico_sel)
			odial[a].ob_state|=SELECTED;
		else
			odial[a].ob_state&=(~SELECTED);
	}
	
	/* Slider */
	/* ico_off/max_ico_off=slide_off/max_slide_off */
	max_slide_off=odial[RICOBAR].ob_height-odial[RICOSLIDE].ob_height;
	odial[RICOSLIDE].ob_y=(ico_off*max_slide_off)/max_ico_off;
	
	profi_mode(odial[PROFI_MODE].ob_state & SELECTED);
}

/* -------------------------------------- */

void dial_win(void)
{
	int dum, a;
	
	rsrc_gaddr(0,MAIN,&odial);
	rsrc_gaddr(0,ICONS,&oicons);
	rsrc_gaddr(0,SCRIPTS,&oscripts);
	rsrc_gaddr(0,SCRIPTPOP, &oscriptpop);
	/* Ob-Specs der mittleren Script-Objekte merken */
	for(a=0, dum=SCRIPTL1; dum <= SCRIPTLL; dum+=(SCRIPTL2-SCRIPTL1))
		save_spec[a++]=odial[dum+1].ob_spec;
	init_mainrs();

	set_default_modem();
	
	if(load_setup())	/* ret=1: First start */
		show_info();

	make_backup_setup();

	setup_to_dial(act_set->set);
	profi_mode(0);
	
	init_icos();
	ddial.tree=odial;
	ddial.support=0;
	ddial.dservice=do_dial;
	ddial.osmax=0;
	ddial.odmax=8;
	w_dinit(&wdial);
	wdial.dinfo=&ddial;
	w_dial(&wdial, D_CENTER);
	ddial.dedit=edit_ob[0];
	w_open(&wdial);
/* activate this line if you want to know the password
   of your current setup: */
/*Cconws(act_set->set->pop_pass);*/
	while(!quit)
		w_devent(&dum,&dum,&dum,&dum,&dum);
}

/* -------------------------------------- */

int shutdown(void)
{
	int a;
	
	dial_to_setup(act_set->set);

	if(check_backup_setup()==1) return(1);	/* Nix geÑndert, ok */

	a=form_alert(3,gettext(A2));	/* Abbruch, Nicht sichern, Sichern */
	if(a==1) return(0);

	if(a==3)
	{
		if(save_setup()==0)
			return(0);
		if(appl_find("ICONNECT") > -1)
			form_alert(1,gettext(A11));
	}
	return(1);
}

/* -------------------------------------- */
void show_info(void)
{
	OBJECT *info;
	int m, dum;
	
	rsrc_gaddr(0,INFOTREE, &info);
	strcpy(info[INFOVERSION].ob_spec.free_string, ICON_VERSION);
	strcpy(info[INFODATE].ob_spec.free_string, __DATE__);
	do
		graf_mkstate(&dum,&dum,&m,&dum);
	while(m&3);
	w_do_dial(info);
	info[INFOK].ob_state &= (~SELECTED);
}

/* -------------------------------------- */

void do_dial(int ob)
{
	int a, k;
	OBJECT *tree;
	
	if((ob >= RICO1) && (ob <= RICOLAST))
	{
		if(odial[ob].ob_state & SELECTED) return;	/* Ist schon aktiv */
		for(a=RICO1; a<=RICOLAST;++a) odial[a].ob_state &= (~SELECTED);
		odial[ob].ob_state |= SELECTED;
		/* Wenn aktuelle selektion Liste ist, dann Timeouts auslesen */
		if(ico_sel==SEL_LOGIN) read_login_to(act_set->set);
		if(ico_sel==SEL_LOGOUT) read_logout_to(act_set->set);
		ico_sel=ob-RICO1+ico_off;
		/* Cursor neu setzen */
		wdial.dinfo->dedit=edit_ob[ico_sel];
		wdial.dinfo->cpos=0;
		if(ico_sel==SEL_LOGIN) {set_login_script(act_set->set); check_editable();}
		if(ico_sel==SEL_LOGOUT) {set_logout_script(act_set->set); check_editable();}
		w_objc_draw(&wdial, change_frame(ob), 8, sx,sy,sw,sh);
		w_objc_draw(&wdial, RICOLIST, 8, sx,sy,sw,sh);
		return;
	}
	
	switch(ob)
	{
		case INFOBUT:
		case INFOBUT2:
			show_info();
		break;

		/* Main */
		case PROFI_MODE:
			profi_mode(odial[ob].ob_state & SELECTED);
			s_redraw(&wdial);
		break;
		
		case MAINSAVE:
			dial_to_setup(act_set->set);
			save_setup();
			update_backup_setup();
			w_unsel(&wdial, ob);
		break;
		
		case MAINQUIT:
			if(shutdown())
			{
				w_kill(&wdial);
				quit=1;
			}
			w_unsel(&wdial, ob);
		break;

		case SETPOP:
			setpopup();
		break;
		
		case SETRENAME:
			rename_setup();
			w_unsel(&wdial, ob);
		break;

		case SETDELETE:
			delete_setup();
			w_unsel(&wdial, ob);
		break;

		case SETNEW:
			new_setup();
			w_unsel(&wdial, ob);
		break;
		
		case COPYBUT:
			copy_setup();
		break;
		
		/* Main Option-list */
		case RICOUP:
			if(ico_off == 0) break;	/* Upper gehts net */
			--ico_off;
			init_icos();
			w_objc_draw(&wdial, RICOPARENT, 8, sx,sy,sw,sh);
		break;		
		case RICODOWN:
			if(ico_off == max_ico_off) break;	/* Downer gehts net */
			++ico_off;
			init_icos();
			w_objc_draw(&wdial, RICOPARENT, 8, sx,sy,sw,sh);
		break;
		
		case RICOSLIDE:
			slide(&wdial, ob, 0, max_ico_off, ico_off, new_ico_val);
		break;
		case RICOBAR:
			bar(&wdial, ob, 0, max_ico_off, new_ico_val);
		break;

		/* Modem */
		case MODP1: fpopup(MODP1, port_names, NUM_PORT); break;
		case MODP2: fpopup(MODP2, baud_names, NUM_BAUD); break;
		case MODP3: fpopup(MODP3, hshk_names, NUM_HSHK); break;
		case MODP4: fpopup(MODP4, parity_names, NUM_PARITY); break;
		case MODP5: fpopup(MODP5, dbit_names, NUM_DBIT); break;
		case MODP6: fpopup(MODP6, sbit_names, NUM_SBIT); break;

		/* Zugang */
		case PPPAUTHUSER:
			enter_ppp_user();
			w_unsel(&wdial, ob);
		break;
		case PPPAUTHPASS:
			enter_ppp_pass();
			w_unsel(&wdial, ob);
		break;
		case DIALTYPE:
			rsrc_gaddr(0, DIALPOP, &tree);
			do_cpopup(&wdial, DIALTYPE, tree, 1);
		break;

		/* Script */
		case SCRIPTUP:
			if(ico_sel==(RICOLOGIN-RICO1))
			{
				if(login_off == 0) return;	/* Upper gehts net */
				--login_off;
				k=w_dialcursor(&wdial, D_CUROFF);
				set_login_script(act_set->set);
			}
			else
			{
				if(logout_off == 0) return;	/* Upper gehts net */
				--logout_off;
				k=w_dialcursor(&wdial, D_CUROFF);
				set_logout_script(act_set->set);
			}
			wdial.dinfo->cpos=0;
			check_editable();
			w_objc_draw(&wdial, SCRIPTBOX, 8, sx,sy,sw,sh);
			if(k) w_dialcursor(&wdial, D_CURON);
		break;
		case SCRIPTDOWN:
			if(ico_sel==(RICOLOGIN-RICO1))
			{
				if(login_off == script_steps(act_set->set->login_step)-VIS_SCRIPT_STEPS) return;	/* Downer gehts net */
				++login_off;
				k=w_dialcursor(&wdial, D_CUROFF);
				set_login_script(act_set->set);
			}
			else
			{
				if(logout_off == script_steps(act_set->set->logout_step)-VIS_SCRIPT_STEPS) return;	/* Downer gehts net */
				++logout_off;
				k=w_dialcursor(&wdial, D_CUROFF);
				set_logout_script(act_set->set);
			}
			wdial.dinfo->cpos=0;
			check_editable();
			w_objc_draw(&wdial, SCRIPTBOX, 8, sx,sy,sw,sh);
			if(k) w_dialcursor(&wdial, D_CURON);
		break;
		case SCRIPTSLIDE:
			if(odial[SCRIPTSLIDE].ob_height==odial[SCRIPTBAR].ob_height) break;
			if(ico_sel==(RICOLOGIN-RICO1))
				slide(&wdial, ob, 0, script_steps(act_set->set->login_step)-VIS_SCRIPT_STEPS, login_off, new_script_val);
			else
				slide(&wdial, ob, 0, script_steps(act_set->set->logout_step)-VIS_SCRIPT_STEPS, logout_off, new_script_val);
		break;
		case SCRIPTBAR:
			if(ico_sel==(RICOLOGIN-RICO1))
				bar(&wdial, ob, 0, script_steps(act_set->set->login_step)-VIS_SCRIPT_STEPS, new_script_val);
			else
				bar(&wdial, ob, 0, script_steps(act_set->set->logout_step)-VIS_SCRIPT_STEPS, new_script_val);
		break;
		case SCRIPTL1: case SCRIPTL2: case SCRIPTL3: case SCRIPTL4:
		case SCRIPTL5: case SCRIPTL6: case SCRIPTL7: case SCRIPTLL:
			k=(int)Kbshift(-1);
			if(k & 4)	/* CTRL-Klick->Delete */
			{
				if(ico_sel==(RICOLOGIN-RICO1))
				{
					delete_step(act_set->set->login_step, (ob-SCRIPTL1)/(SCRIPTL2-SCRIPTL1)+login_off);
					set_login_script(act_set->set);
				}
				else
				{
					delete_step(act_set->set->logout_step, (ob-SCRIPTL1)/(SCRIPTL2-SCRIPTL1)+login_off);
					set_logout_script(act_set->set);
				}
				w_objc_draw(&wdial, SCRIPTBOX, 8, sx,sy,sw,sh);
				break;
			}
			if(k & 8)	/* Check for limit */
			{
				if(ico_sel==(RICOLOGIN-RICO1))
					a=script_steps(act_set->set->login_step);
				else
					a=script_steps(act_set->set->logout_step);
				if(a==50)
				{ 
					form_alert(1,gettext(A4));
					break;
				}
				a=do_cpopup(&wdial, ob, oscriptpop, 0);
			}
			else
				a=do_cpopup(&wdial, ob, oscriptpop, 1);

			if(a==0) break;	/* Keine énderung */
			if(ico_sel==(RICOLOGIN-RICO1))
			{
				a=(ob-SCRIPTL1)/(SCRIPTL2-SCRIPTL1)+login_off;
				if(k & 8)	/* Insert */
				{
					insert_step(act_set->set->login_step, a );
					goto new_login;
				}
				if(act_set->set->login_step[a].action==SC_DONE)
				{/* Last step modified->move last step */
						if(a==49)	/* Impossible, Script full */
						{
							form_alert(1,gettext(A4));
							goto no_new_login;
						}
						act_set->set->login_step[a+1]=act_set->set->login_step[a];
				}
				new_login:
				if(ext_type(odial, ob) < MIN_SCRIPT_EDIT)
				{
					wdial.dinfo->dedit=ob+1;
					wdial.dinfo->cpos=0;
				}
				act_set->set->login_step[a].action=ext_type(odial, ob);
				switch ext_type(odial, ob)
				{
					case SC_SEND_STRING:
					case SC_USER_INPUT:
					case SC_SECRET_INPUT:
					case SC_DONE:
						act_set->set->login_step[a].param=1;
					break;
					default:
						act_set->set->login_step[a].param=0;
					break;
				}
				act_set->set->login_step[a].free_string[0]=0;
				no_new_login:
				set_login_script(act_set->set);
			}
			else
			{
				a=(ob-SCRIPTL1)/(SCRIPTL2-SCRIPTL1)+logout_off;
				if(k & 8)	/* Insert */
				{
					insert_step(act_set->set->logout_step, a);
					goto new_logout;
				}
				if(act_set->set->logout_step[a].action==SC_DONE)
				{
						if(a==49)	/* Impossible, Script full */
						{
							form_alert(1,gettext(A4));
							goto no_new_logout;
						}
						act_set->set->logout_step[a+1]=act_set->set->logout_step[a];
				}
				new_logout:
				if(ext_type(odial, ob) < MIN_SCRIPT_EDIT)
				{
					wdial.dinfo->dedit=ob+1;
					wdial.dinfo->cpos=0;
				}
				act_set->set->logout_step[a].action=ext_type(odial, ob);
				switch ext_type(odial, ob)
				{
					case SC_SEND_STRING:
					case SC_USER_INPUT:
					case SC_SECRET_INPUT:
					case SC_DONE:
						act_set->set->logout_step[a].param=1;
					break;
					default:
						act_set->set->logout_step[a].param=0;
					break;
				}
				act_set->set->logout_step[a].free_string[0]=0;
				no_new_logout:
				set_logout_script(act_set->set);
			}
			check_editable();
			w_objc_draw(&wdial, SCRIPTBOX, 8, sx,sy,sw,sh);
		break;
		case SCRIPTL1+1: case SCRIPTL2+1: case SCRIPTL3+1: case SCRIPTL4+1:
		case SCRIPTL5+1: case SCRIPTL6+1: case SCRIPTL7+1: case SCRIPTLL+1:
		/* This is the SLIP-Button, only visible in Login-Script */
			a=(ob-SCRIPTL1)/(SCRIPTL2-SCRIPTL1)+login_off;
			if(act_set->set->login_step[a].action!=SC_DONE)
				break;	/* err...it should have been. :-} */
			if(odial[ob].ob_state & SELECTED)	/* SLIP Selected */
				act_set->set->login_step[a].param=0;
			else
				act_set->set->login_step[a].param=1;
			w_objc_draw(&wdial, SCRIPTBOX, 8, sx,sy,sw,sh);
		break;
		case SCRIPTL1+2: case SCRIPTL2+2: case SCRIPTL3+2: case SCRIPTL4+2:
		case SCRIPTL5+2: case SCRIPTL6+2: case SCRIPTL7+2: case SCRIPTLL+2:
		/* This is the CR- or PPP-Button */
			if(ico_sel==(RICOLOGIN-RICO1))
			{
				a=(ob-SCRIPTL1)/(SCRIPTL2-SCRIPTL1)+login_off;
				if(odial[ob].ob_state & SELECTED)
					act_set->set->login_step[a].param=1;
				else
					act_set->set->login_step[a].param=0;
			}
			else
			{
				a=(ob-SCRIPTL1)/(SCRIPTL2-SCRIPTL1)+logout_off;
				if(odial[ob].ob_state & SELECTED)
					act_set->set->logout_step[a].param=1;
				else
					act_set->set->logout_step[a].param=0;
			}
			if(ext_type(odial, ob-2)==SC_DONE)
				w_objc_draw(&wdial, SCRIPTBOX, 8, sx,sy,sw,sh);
		break;
		
		/* Proxies */
		case SERVPOP:
			service_popup();
		break;
		case SERVCHANGE:
			change_service();
			w_unsel(&wdial, SERVCHANGE);
		break;
		
		/* Sockets */
		case PATHSELECT:
			path_select();
			w_unsel(&wdial, PATHSELECT);
		break;
		
	}
}

/* -------------------------------------- */

int numtest(char *c)
{/* Sind alle Zeichen '0'-'9' oder'#' wird 1 geliefert, sonst 0 */
	while(*c != 0)
	{
		if(  ((*c < '0') || (*c > '9')) && (*c != '#'))
			return(0);
		++c;
	}
	return(1);
}

/* -------------------------------------- */

int remake_to_user(void)
{
	OBJECT *tree;
	char	*c, *d;
	rsrc_gaddr(0, ENTERUSER, &tree);

	
	tree[TOKENNUNG].ob_spec.tedinfo->te_ptext[0]=0;
	tree[TONUMMER].ob_spec.tedinfo->te_ptext[0]=0;
	tree[TOMITBENUTZER].ob_spec.tedinfo->te_ptext[0]=0;
	c=tree[USERINPUT].ob_spec.tedinfo->te_ptext;
	if(numtest(c)==0) return(0);
	if(strlen(c) < 12+2+4) return(0);
	if(strlen(c) > 12+12+4) return(0);
	if((strlen(c) < 12+12+4) && (strchr(c, '#')==NULL)) return(0);

	/* User in Einzeldaten aufsplitten */
	strncpy(tree[TOKENNUNG].ob_spec.tedinfo->te_ptext, c, 12);
	tree[TOKENNUNG].ob_spec.tedinfo->te_ptext[12]=0;
	d=strchr(c, '#');
	if(d==NULL)
	{
		strncpy(tree[TONUMMER].ob_spec.tedinfo->te_ptext, &(c[12]), 12);
		d=&(c[24]);
	}
	else
	{
		*d=0;
		strcpy(tree[TONUMMER].ob_spec.tedinfo->te_ptext, &(c[12]));
		*d++='#';
	}
	tree[TONUMMER].ob_spec.tedinfo->te_ptext[12]=0;
	strncpy(tree[TOMITBENUTZER].ob_spec.tedinfo->te_ptext, d, 4);
	tree[TOMITBENUTZER].ob_spec.tedinfo->te_ptext[4]=0;
	return(1);
}

/* -------------------------------------- */

void make_to_user(void)
{
	OBJECT *tree;
	int			a;
	rsrc_gaddr(0, ENTERUSER, &tree);
	
	strcpy(tree[USERINPUT].ob_spec.tedinfo->te_ptext, tree[TOKENNUNG].ob_spec.tedinfo->te_ptext);
	strcat(tree[USERINPUT].ob_spec.tedinfo->te_ptext, tree[TONUMMER].ob_spec.tedinfo->te_ptext);
	if(strlen(tree[TONUMMER].ob_spec.tedinfo->te_ptext) < 12)
		strcat(tree[USERINPUT].ob_spec.tedinfo->te_ptext, "#");
	a=(int)strlen(tree[TOMITBENUTZER].ob_spec.tedinfo->te_ptext);
	while(a++ < 4)
		strcat(tree[USERINPUT].ob_spec.tedinfo->te_ptext, "0");
	strcat(tree[USERINPUT].ob_spec.tedinfo->te_ptext, tree[TOMITBENUTZER].ob_spec.tedinfo->te_ptext);
}

/* -------------------------------------- */

void to_keybd(int key, int swt)
{
	OBJECT *tree;
	rsrc_gaddr(0, ENTERUSER, &tree);

	if(!(tree[TONLINEMODE].ob_state & SELECTED))
		return;
	
	if(wuserin.dinfo->dedit==USERINPUT)
		return;
		
	key&=255;
	swt&=15;
 	if((key == 27) || (key == 8) || (key ==  127) ||
 			 ((key >= 48) && (key <= 57))
 		)
	{
		make_to_user();
		w_objc_draw(&wuserin, USERINPUT, 8, sx,sy,sw,sh);
	}
}

/* -------------------------------------- */

void do_userdial(WINDOW *win, int ob)
{
	switch(ob)
	{
		case TONLINEMODE:
			if(win->dinfo->tree[TONLINEMODE].ob_state & SELECTED)
			{/* Einschalten */
				if(remake_to_user()==0)
					win->dinfo->tree[USERINPUT].ob_spec.tedinfo->te_ptext[0]=0;
				win->dinfo->dedit=TOKENNUNG;
				win->dinfo->tree[USERINPUT].ob_state|=DISABLED;
				win->dinfo->tree[TOKENNUNG].ob_state&=(~DISABLED);
				win->dinfo->tree[TONUMMER].ob_state&=(~DISABLED);
				win->dinfo->tree[TOMITBENUTZER].ob_state&=(~DISABLED);
				s_redraw(win);
			}
			else
			{/* Ausschalten */
				win->dinfo->tree[TOKENNUNG].ob_spec.tedinfo->te_ptext[0]=0;
				win->dinfo->tree[TONUMMER].ob_spec.tedinfo->te_ptext[0]=0;
				win->dinfo->tree[TOMITBENUTZER].ob_spec.tedinfo->te_ptext[0]=0;
				win->dinfo->dedit=USERINPUT;
				win->dinfo->tree[USERINPUT].ob_state&=(~DISABLED);
				win->dinfo->tree[TOKENNUNG].ob_state|=DISABLED;
				win->dinfo->tree[TONUMMER].ob_state|=DISABLED;
				win->dinfo->tree[TOMITBENUTZER].ob_state|=DISABLED;
				s_redraw(win);
			}
		break;
		case USERINOK:
		case USERINCANCEL:
			w_close(win);
		break;
	}
}

/* -------------------------------------- */

void enter_ppp_user(void)
{
	OBJECT	*intree;
	DINFO		ddial;
	int			dum;
	
	rsrc_gaddr(0, ENTERUSER, &intree);
	((CICONBLK*)(intree[ICON1].ob_spec.iconblk))->monoblk.ib_wtext=0;
	((CICONBLK*)(intree[ICON2].ob_spec.iconblk))->monoblk.ib_wtext=0;

	strncpy(intree[USERINPUT].ob_spec.tedinfo->te_ptext, act_set->set->ppp_auth_user, 30);
	intree[USERINPUT].ob_spec.tedinfo->te_ptext[30]=0;
	intree[TOKENNUNG].ob_spec.tedinfo->te_ptext[0]=0;
	intree[TONUMMER].ob_spec.tedinfo->te_ptext[0]=0;
	intree[TOMITBENUTZER].ob_spec.tedinfo->te_ptext[0]=0;
	if(act_set->set->t_online_mode)
	{
		intree[TONLINEMODE].ob_state|=SELECTED;
		intree[USERINPUT].ob_state|=DISABLED;
		intree[TOKENNUNG].ob_state&=(~DISABLED);
		intree[TONUMMER].ob_state&=(~DISABLED);
		intree[TOMITBENUTZER].ob_state&=(~DISABLED);
	}
	else
	{
		intree[TONLINEMODE].ob_state&=(~SELECTED);
		intree[USERINPUT].ob_state&=(~DISABLED);
		intree[TOKENNUNG].ob_state|=DISABLED;
		intree[TONUMMER].ob_state|=DISABLED;
		intree[TOMITBENUTZER].ob_state|=DISABLED;
	}
	intree[TOFRAME].ob_y=intree[TONLINEMODE].ob_y+intree[TONLINEMODE].ob_height+4;
	
	w_dinit(&wuserin);
	ddial.tree=intree;
	ddial.support=0;
	ddial.osmax=0;
	ddial.odmax=8;
	wuserin.dinfo=&ddial;
	w_dial(&wuserin, D_CENTER);
	ddial.dservice=NULL;
	ddial.dwservice=do_userdial;
	if(intree[TONLINEMODE].ob_state & SELECTED)
	{
		ddial.dedit=TOKENNUNG;
		remake_to_user();
	}
	else
		ddial.dedit=USERINPUT;
	ddial.dakeybd=to_keybd;

	w_open(&wuserin);
	w_modal(&wuserin, MODAL_ON);
	while(wuserin.open)
		w_devent(&dum,&dum,&dum,&dum,&dum);
	w_modal(&wuserin, MODAL_OFF);

	w_kill(&wuserin);
			
	if(intree[ENTRYCANCEL].ob_state & SELECTED)	
	{
		intree[ENTRYCANCEL].ob_state &= (~SELECTED);
		return;
	}

	intree[ENTRYOK].ob_state &= (~SELECTED);
	if(intree[TONLINEMODE].ob_state & SELECTED)
		act_set->set->t_online_mode=1;
	else
		act_set->set->t_online_mode=0;

	strcpy(act_set->set->ppp_auth_user, intree[USERINPUT].ob_spec.tedinfo->te_ptext);
	if(act_set->set->ppp_auth_user[0])
		strcpy(odial[PPPUSERSET].ob_spec.tedinfo->te_ptext, gettext(PPPSET2));
	else
		strcpy(odial[PPPUSERSET].ob_spec.tedinfo->te_ptext, gettext(PPPSET1));
	w_objc_draw(&wdial, PPPUSERSET, 8, sx,sy,sw,sh);
}
void enter_ppp_pass(void)
{
	OBJECT *intree;
	
	rsrc_gaddr(0, ENTERPASS, &intree);
	((CICONBLK*)(intree[ICON3].ob_spec.iconblk))->monoblk.ib_wtext=0;
	objc_xtedcpy(intree, PASSINPUT, act_set->set->ppp_auth_pass);

	if(w_do_dial(intree)==ENTRYCANCEL)
	{
		intree[ENTRYCANCEL].ob_state &= (~SELECTED);
		return;
	}

	intree[ENTRYOK].ob_state &= (~SELECTED);
	strcpy(act_set->set->ppp_auth_pass, xted(intree, PASSINPUT)->te_ptext);
	if(act_set->set->ppp_auth_pass[0])
		strcpy(odial[PPPPASSSET].ob_spec.tedinfo->te_ptext, gettext(PPPSET2));
	else
		strcpy(odial[PPPPASSSET].ob_spec.tedinfo->te_ptext, gettext(PPPSET1));
	w_objc_draw(&wdial, PPPPASSSET, 8, sx,sy,sw,sh);
}


/* -------------------------------------- */

void new_script_val(int val)
{
	int k;
	
	k=w_dialcursor(&wdial, D_CUROFF);
	
	if(ico_sel==(RICOLOGIN-RICO1))
	{
		login_off=val;
		set_login_script(act_set->set);
	}
	else
	{
		logout_off=val;
		set_logout_script(act_set->set);
	}
	wdial.dinfo->cpos=0;
	check_editable();
	w_objc_draw(&wdial, SCRIPTBOX, 8, sx,sy,sw,sh);
	if(k) w_dialcursor(&wdial, D_CURON);
}

/* -------------------------------------- */

void new_ico_val(int val)
{
	ico_off=val;
	init_icos();
	w_objc_draw(&wdial, RICOPARENT, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void	slide(WINDOW *win, int ob, int min, int max, int now, void (*newval)(int now2))
{/* dir ist X oder Y, min und max sind min und max Werte (z.B.1,10)*/
 /* now ist der jetzige Wert (z.B.3), width ist die Breite/Hîhe*/
 /* des Parents abzÅglich des Sliders und dann noch die Funktion, */
 /* die einen neuen Wert bearbeitet */
	int		mx,my,ms,mk, mx2, my2, off, now2, width, dir;
	float	ps;
	OBJECT *tree;
	
	tree=win->dinfo->tree;
	
	if(tree[ob-1].ob_width == tree[ob].ob_width)
	{
		dir=Y;
		width=tree[ob-1].ob_height-tree[ob].ob_height;
	}
	else
	{
		dir=X;
		width=tree[ob-1].ob_width-tree[ob].ob_width;
	}
		
	if(width)
	{
		graf_mouse(FLAT_HAND,NULL);
		graf_mkstate(&mx,&my,&ms,&mk);
		ps=(float)((float)width/(float)((float)max-(float)min));
		if (dir == X)
			off=(int)((float)((float)mx-(float)ps*(float)now));
		else if (dir == Y)
			off=(int)((float)((float)my-(float)ps*(float)now));
		now2=now;
	
		while(ms & 1)
		{
			graf_mkstate(&mx2,&my2,&ms,&mk);
			if ((dir == X) && (mx2 != mx))
			{/* Ausrechnen, ob auch rel-pos neu ist */
				mx=mx2;
				mx=mx-off;
				now2=(int)((float)((float)mx/(float)ps))+min;
			}
			else if ((dir == Y) && (my2 != my))
			{/* Ausrechnen, ob auch rel-pos neu ist */
				my=my2;
				my=my-off;
				now2=(int)((float)((float)my/(float)ps))+min;
			}
			if (now2 < min)
				now2=min;
			if (now2 > max)
				now2=max;
			if (now2 != now)
			{
				now=now2-min;
				if(dir == X)
					tree[ob].ob_x=(int)((float)((float)now*(float)ps));
				else
					tree[ob].ob_y=(int)((float)((float)now*(float)ps));
				/* w_objc_draw(win, ob-1, 2, sx, sy, sw, sh);*/
				newval(now2);
				now=now2;
			}
		}
		graf_mouse(ARROW,NULL);
	}
}

/* -------------------------------------- */

void bar(WINDOW *win, int ob, int min, int max, void (*newval)(int now2))
{/* Berechnet den Wert fÅr einen Direkt-Klick in den Slider */
 /* Setzt den Slider (als Objektnummer wird das erste Child des */
 /* Bars angenommen) und macht mit slide() weiter */
 
 int	width, dif, mx, my, ox, oy, dum, val;
 float	ps, vl;
 	OBJECT *tree;

	tree=win->dinfo->tree;

 	graf_mkstate(&mx, &my, &dum, &dum);
 	objc_offset(tree, ob, &ox, &oy);
 	mx-=ox; my-=oy;
 	mx-=tree[ob+1].ob_width/2;
 	my-=tree[ob+1].ob_height/2;
 	if(mx < 0) mx=0;
 	if(my < 0) my=0;
 	
	if(tree[ob].ob_width == tree[ob+1].ob_width)
	{
		width=tree[ob].ob_height-tree[ob+1].ob_height;
		if(my > width) my=width;
		/* Slider setzen */
		val=tree[ob+1].ob_y=my;
	}
	else
	{
		width=tree[ob].ob_width-tree[ob+1].ob_width;
		if(mx > width) mx=width;
		/* Slider setzen */
		val=tree[ob+1].ob_x=mx;
	}
	
	/* w_objc_draw(win, ob, 8, sx, sy, sw, sh);*/

	/* Position berechnen */
	dif=max-min;
	
	/* Wert berechnen */
	ps=(float)((float)dif/(float)width);
	vl=ps*(float)val; val=(int)vl+min;
	if(val > max) val=max;
	newval(val);
	
	slide(win, ob+1, min, max, val, newval);
}

/* -------------------------------------- */

int do_popup(WINDOW *root, int parent, OBJECT *pop)
{
	return(do_cpopup(root, parent, pop, 1));
}

int do_cpopup(WINDOW *root, int parent, OBJECT *pop, int ch_only)
{/* ôffnet das Popup pop an x/y von root->dinfo->dtree[PRPOP]
		Vorauswahl (Check) und Y-Pos. werden an root-ext_type
		angepaût.
		Wenn Auswahl getroffen wird, wird Text aus pop ohne die
		ersten zwei Zeichen nach root kopiert und fÅr dieses ein
		Redraw ausgelîst.
		ch_only=0: Es wird kein Default gesetzt und eine Auswahl immer 
							 als énderung anerkannt.
		ch_only=1: Der aktuelle ext_type wird als Default gesetzt und
							 0 zurÅckgegeben, falls dieser gewÑhlt wird
		Gibt 1 zurÅck, wenn énderung vorgenommen wurde, sonst 0
 */
    
	int 	x,y,a,b;
	OBJECT *oroot=root->dinfo->tree;
	
	b=oroot[parent].ob_type >> 8;
		
	a=0;
	do
	{
		++a;
		pop[a].ob_state &= (~CHECKED);
	}while(!(pop[a].ob_flags & LASTOB));

	if(ch_only)
		pop[b+1].ob_state |= CHECKED;
		
	objc_offset(oroot, parent, &x, &y);
	y-=b*pop[1].ob_height;

	if(y < sy) y=sy;
	if(y+pop[0].ob_height > sy+sh)
		y=sy+sh-pop[0].ob_height;
	if(x < sx) x=sx;
	if(x+pop[0].ob_width > sx+sw)
		x=sx+sw-pop[0].ob_width;

	a=form_popup(pop, x, y)-1;
	if((a > -1) && !((ch_only==1) && (a == b)))
	{
		strcpy(oroot[parent].ob_spec.free_string,	&(pop[a+1].ob_spec.free_string[2]));
		w_objc_draw(root, parent, 8, sx, sy, sw, sh);		
		set_ext_type(oroot,parent,a);
		return(1);
	}
	return(0);
}

/* -------------------------------------- */

int count_setups(void)
{
	SET_LIST	*sl=&first_set;
	int				num=0;
	
	while(sl) 
	{
		++num; 
		sl=sl->next;
	}
	return(num);
}

/* -------------------------------------- */

void setpopup(void)
{/* Popup aller Setups erstellen, aufrufen und Auswahl in Poproot und
		ext_ob eintragen. Neues Setup darstellen */
	OBJECT 	*tree, *root;
	char		*strings;
	int			a, num;
	long		slen;
	SET_LIST	*sl=&first_set;
	
	/* Sets zÑhlen */
	if((num=count_setups())==0) return;

	dial_to_setup(act_set->set);
	
	rsrc_gaddr(0, SETUPPOP, &root);
	slen=strlen(root[1].ob_spec.free_string)+4; /* Zwei Space vorne, eins hinten, eine 0 */
	
	tree=malloc((num+1)*sizeof(OBJECT)+num*slen);
	strings=(char*)&(tree[num+1]);
	tree[0]=root[0];
	tree[0].ob_tail=num;
	tree[0].ob_height=root[1].ob_height*num;
	for(a=1; a <= num; ++a)
	{
		tree[a]=root[1];
		tree[a].ob_next=a+1;
		tree[a].ob_flags &=(~LASTOB);
		tree[a].ob_spec.free_string=strings;
		strcpy(strings, "  ");
		strcat(strings, sl->set->name);
		strings+=slen;
		tree[a].ob_y=root[1].ob_height*(a-1);
		sl=sl->next;
	}
	tree[num].ob_next=0;
	tree[num].ob_flags|=LASTOB;
	a=do_popup(&wdial, SETPOP, tree);
	free(tree);

	if(!a) return;	/* Auswahl nicht geÑndert */
	
	sl=&first_set;
	a=ext_type(odial, SETPOP);
	while(a--)
		sl=sl->next;
	act_set=sl;
	setup_to_dial(act_set->set);
	/* Cursor neu setzen */
	wdial.dinfo->dedit=edit_ob[ico_sel];
	wdial.dinfo->cpos=0;
	if(ico_sel==SEL_LOGIN) {set_login_script(act_set->set); check_editable();}
	if(ico_sel==SEL_LOGOUT) {set_logout_script(act_set->set); check_editable();}
	s_redraw(&wdial);
}

/* -------------------------------------- */
void fpopup(int ob, char **names, int num)
{/* Popup erstellen, aufrufen und Auswahl in Poproot und
		ext_ob eintragen */
	OBJECT 	*tree, *root;
	char		*strings;
	int			a;
	long		slen;
	
	rsrc_gaddr(0, MODPOPUP, &root);
	slen=strlen(root[1].ob_spec.free_string)+4; /* Zwei Space vorne, eins hinten, eine 0 */
	
	tree=malloc((num+1)*sizeof(OBJECT)+num*slen);
	strings=(char*)&(tree[num+1]);
	tree[0]=root[0];
	tree[0].ob_tail=num;
	tree[0].ob_height=root[1].ob_height*num;
	for(a=1; a <= num; ++a)
	{
		tree[a]=root[1];
		tree[a].ob_next=a+1;
		tree[a].ob_flags &=(~LASTOB);
		tree[a].ob_spec.free_string=strings;
		strcpy(strings, "  ");
		strcat(strings, names[a-1]);
		strings+=slen;
		tree[a].ob_y=root[1].ob_height*(a-1);
	}
	tree[num].ob_next=0;
	tree[num].ob_flags|=LASTOB;
	a=do_popup(&wdial, ob, tree);
	free(tree);
}

/* -------------------------------------- */

ulong fetch_ip(OBJECT *tree, int ob)
{
	char	n[4];
	uchar i1, i2, i3, i4, len;
	ulong ip;

	len=(uchar)strlen(tree[ob].ob_spec.tedinfo->te_ptext);
	
	n[3]=0;
	strncpy(n, tree[ob].ob_spec.tedinfo->te_ptext, 3);
	i1=(uchar)atoi(n);
	if(len>3)
		i2=atoi(strncpy(n, &(tree[ob].ob_spec.tedinfo->te_ptext[3]), 3));
	else
		i2=0;
	if(len>6)
		i3=atoi(strncpy(n, &(tree[ob].ob_spec.tedinfo->te_ptext[6]), 3));
	else
		i3=0;
	if(len>9)
		i4=atoi(strncpy(n, &(tree[ob].ob_spec.tedinfo->te_ptext[9]), 3));
	else
		i4=0;

	ip=((ulong)i1<<24)+((ulong)i2<<16)+((ulong)i3<<8)+(ulong)i4;
	return(ip);
}

/* -------------------------------------- */

void store_ip(OBJECT *tree, int ob, ulong ip)
{
	int		one;
	char	num[4];
	
	one=(int)(ip>>24);
	itoa(one, num, 10);
	while(strlen(num)<3)strcat(num, " ");
	strcpy(tree[ob].ob_spec.tedinfo->te_ptext, num);

	one=(int)((ip>>16) & 255);
	itoa(one, num, 10);
	while(strlen(num)<3)strcat(num, " ");
	strcpy(&(tree[ob].ob_spec.tedinfo->te_ptext[3]), num);

	one=(int)((ip>>8) & 255);
	itoa(one, num, 10);
	while(strlen(num)<3)strcat(num, " ");
	strcpy(&(tree[ob].ob_spec.tedinfo->te_ptext[6]), num);

	one=(int)(ip & 255);
	itoa(one, num, 10);
	while(strlen(num)<3)strcat(num, " ");
	strcpy(&(tree[ob].ob_spec.tedinfo->te_ptext[9]), num);
}

/* -------------------------------------- */

void read_proxy(int num)
{
	int a;
	
	/* Aktuelles Setup Åbernehmen */
	strcpy(act_set->set->proxy_names[ext_type(odial, SERVPOP)], xted(odial, PROXYIP)->te_ptext);
	act_set->set->proxies[num].port=atoi(odial[PROXYPORT].ob_spec.tedinfo->te_ptext);
	for(a=PNOT1; a <= PNOT6; ++a)
		strcpy(&(act_set->set->proxies[num].not_use[(a-PNOT1)*40]), odial[a].ob_spec.tedinfo->te_ptext);
}

/* -------------------------------------- */

void set_proxy(int num)
{
	int a;
	
	objc_xtedcpy(odial, PROXYIP, act_set->set->proxy_names[ext_type(odial, SERVPOP)]);

	itoa(act_set->set->proxies[num].port, odial[PROXYPORT].ob_spec.tedinfo->te_ptext, 10);
	a=PNOT1;
	while(a <= PNOT6)
	{
		strncpy(odial[a].ob_spec.tedinfo->te_ptext, &(act_set->set->proxies[num].not_use[(a-PNOT1)*40]), 40);
		odial[a].ob_spec.tedinfo->te_ptext[40]=0;
		++a;
	}
}

/* -------------------------------------- */

void service_popup(void)
{
	OBJECT *servpop;
	int a;
	
	read_proxy(ext_type(odial, SERVPOP));

	rsrc_gaddr(0, PROXYPOP, &servpop);
	for(a=0; a < 10; ++a)
	{
		strcpy(servpop[a+1].ob_spec.free_string, "  ");
		strcat(servpop[a+1].ob_spec.free_string, act_set->set->proxies[a].service);
	}

	a=do_popup(&wdial, SERVPOP, servpop);
	if(a==0) return;	/* Keine énderung */

	set_proxy(ext_type(odial, SERVPOP));
	w_objc_draw(&wdial, PROXYFRAME, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void rename_setup(void)
{
	OBJECT *onewname;
	
	rsrc_gaddr(0, SETNAME, &onewname);
	strcpy(onewname[SETTEXT].ob_spec.free_string, gettext(NEWSET2));
	strcpy(onewname[SETENTRY].ob_spec.tedinfo->te_ptext, act_set->set->name);
	onewname[NI1].ob_spec.free_string[0]=0;
	onewname[NI2].ob_spec.free_string[0]=0;
	onewname[NI3].ob_spec.free_string[0]=0;
	if(w_do_dial(onewname)!=NEWNAMEOK)
	{
		onewname[NEWNAMECANCEL].ob_state &= (~SELECTED);
		return;
	}
	
	onewname[NEWNAMEOK].ob_state &= (~SELECTED);
	strcpy(act_set->set->name, onewname[SETENTRY].ob_spec.tedinfo->te_ptext);
	strcpy(odial[SETPOP].ob_spec.free_string, act_set->set->name);
	w_objc_draw(&wdial, SETPOP, 8, sx,sy,sw,sh);	
}

/* -------------------------------------- */

void delete_setup(void)
{
	char	alert[512];
	int		a;
	SET_LIST	*sl, *msl;
	
	if(count_setups() < 2)
	{
		form_alert(1,gettext(A5));
		return;
	}
	
	strcpy(alert, gettext(A6));
	strcat(alert, act_set->set->name);
	strcat(alert, gettext(A7));
	if(form_alert(1, alert)==2) return;
	
	/* Delete */
	a=0;
	if(act_set==&first_set)
	{/* Sonderbehandlung */
		free(first_set.set);
		first_set=*(first_set.next);
		/* act_set steht immer noch auf first_set, ok */
	}
	else
	{
		sl=&first_set;
		while(sl->next != act_set)	{sl=sl->next; ++a;}
		msl=sl->next;
		sl->next=sl->next->next;
		free(msl->set);
		free(msl);
		act_set=sl;
	}
	set_ext_type(odial, SETPOP, a);
	setup_to_dial(act_set->set);
	/* Cursor neu setzen */
	wdial.dinfo->dedit=edit_ob[ico_sel];
	wdial.dinfo->cpos=0;
	if(ico_sel==SEL_LOGIN) {set_login_script(act_set->set); check_editable();}
	if(ico_sel==SEL_LOGOUT) {set_logout_script(act_set->set); check_editable();}
	s_redraw(&wdial);
}

/* -------------------------------------- */

void new_setup(void)
{
	OBJECT 		*onewname;
	SET_LIST	*sl, *nl;
	SETUP			*nset;
	int				a;
	
	rsrc_gaddr(0, SETNAME, &onewname);
	strcpy(onewname[SETTEXT].ob_spec.free_string, gettext(NEWSET1));
	strcpy(onewname[SETENTRY].ob_spec.tedinfo->te_ptext, act_set->set->name);
	strcpy(onewname[NI1].ob_spec.free_string, gettext(NSI1));
	strcpy(onewname[NI2].ob_spec.free_string, gettext(NSI2));
	strcpy(onewname[NI3].ob_spec.free_string, gettext(NSI3));
	if(w_do_dial(onewname)!=NEWNAMEOK)
	{
		onewname[NEWNAMECANCEL].ob_state &= (~SELECTED);
		return;
	}
	onewname[NEWNAMEOK].ob_state &= (~SELECTED);
	
	dial_to_setup(act_set->set);
	/* Insert setup */
	sl=&first_set;
	a=0;
	while(sl->next) {sl=sl->next; ++a;}
	/* sl now points to last setup */
	nl=(SET_LIST*)calloc(sizeof(SET_LIST),1);
	if(nl==NULL)
	{
		form_alert(1,gettext(A8));
		return;
	}
	nset=(SETUP*)calloc(sizeof(SETUP),1);
	if(nset==NULL)
	{
		free(nl);
		form_alert(1,gettext(A8));
		return;
	}
	
	sl->next=nl;
	nl->next=NULL;
	nl->set=nset;
	init_setup(nset);
	act_set=nl;
	strcpy(act_set->set->name, onewname[SETENTRY].ob_spec.tedinfo->te_ptext);
	set_ext_type(odial,SETPOP,a+1);
	setup_to_dial(act_set->set);
	/* Cursor neu setzen */
	wdial.dinfo->dedit=edit_ob[ico_sel];
	wdial.dinfo->cpos=0;
	if(ico_sel==SEL_LOGIN) {set_login_script(act_set->set); check_editable();}
	if(ico_sel==SEL_LOGOUT) {set_logout_script(act_set->set); check_editable();}
	s_redraw(&wdial);	
}

/* -------------------------------------- */

void copy_setup(void)
{
	OBJECT 		*onewname;
	SET_LIST	*sl, *nl;
	SETUP			*nset;
	int				a;
	
	rsrc_gaddr(0, SETNAME, &onewname);
	strcpy(onewname[SETTEXT].ob_spec.free_string, gettext(NEWSET1));
	strcpy(onewname[SETENTRY].ob_spec.tedinfo->te_ptext, act_set->set->name);
	strcpy(onewname[NI1].ob_spec.free_string, gettext(CSI1));
	strcpy(onewname[NI2].ob_spec.free_string, act_set->set->name);
	strcpy(onewname[NI3].ob_spec.free_string, gettext(CSI3));
	if(w_do_dial(onewname)!=NEWNAMEOK)
	{
		onewname[NEWNAMECANCEL].ob_state &= (~SELECTED);
		return;
	}
	onewname[NEWNAMEOK].ob_state &= (~SELECTED);
	
	dial_to_setup(act_set->set);
	/* Insert setup */
	sl=&first_set;
	a=0;
	while(sl->next) {sl=sl->next; ++a;}
	/* sl now points to last setup */
	nl=(SET_LIST*)calloc(sizeof(SET_LIST),1);
	if(nl==NULL)
	{
		form_alert(1,gettext(A8));
		return;
	}
	nset=(SETUP*)calloc(sizeof(SETUP),1);
	if(nset==NULL)
	{
		free(nl);
		form_alert(1,gettext(A8));
		return;
	}
	
	sl->next=nl;
	nl->next=NULL;
	nl->set=nset;
	*(nl->set)=*(act_set->set);
/*	init_setup(nset);*/
	act_set=nl;
	strcpy(act_set->set->name, onewname[SETENTRY].ob_spec.tedinfo->te_ptext);
	set_ext_type(odial,SETPOP,a+1);
	setup_to_dial(act_set->set);
	/* Cursor neu setzen */
	wdial.dinfo->dedit=edit_ob[ico_sel];
	wdial.dinfo->cpos=0;
	if(ico_sel==SEL_LOGIN) {set_login_script(act_set->set); check_editable();}
	if(ico_sel==SEL_LOGOUT) {set_logout_script(act_set->set); check_editable();}
	s_redraw(&wdial);	
}

/* -------------------------------------- */

void change_service(void)
{
	OBJECT *oproxy;
	char	alert[512];
	
	if(ext_type(odial, SERVPOP)==9)
	{/* Service <any> kann nicht geÑndert werden */
		strcpy(alert, gettext(A9));
		strcat(alert, gettext(A10));
		form_alert(1,alert);
		return;
	}
	
	rsrc_gaddr(0, SETPROXY, &oproxy);
	strcpy(oproxy[NEWSERVICE].ob_spec.tedinfo->te_ptext, act_set->set->proxies[ext_type(odial, SERVPOP)].service);
	if(w_do_dial(oproxy)!=NEWSOK) 
	{
		oproxy[NEWSCANCEL].ob_state &= (~SELECTED);
		return;
	}

	oproxy[NEWSOK].ob_state &= (~SELECTED);
	strcpy(act_set->set->proxies[ext_type(odial, SERVPOP)].service, oproxy[NEWSERVICE].ob_spec.tedinfo->te_ptext);
	strcpy(odial[SERVPOP].ob_spec.free_string, oproxy[NEWSERVICE].ob_spec.tedinfo->te_ptext);
	w_objc_draw(&wdial, SERVPOP, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void path_select(void)
{
	/* ôffnet Fileselector und schreibt den Zugriffspfad
		 des Auswahlergebnisses in path */
		 
	char	*backslash, path[256], name[64];
	int		gb0, button, back;
	long	dum;
	
	strcpy(path, act_set->set->etc_path);
	
	gb0=_GemParBlk.global[0];
	wind_update(BEG_UPDATE);
	name[0]=0;
	if ((gb0 >= 0x0140) || find_cookie('FSEL', &dum))
		back=fsel_exinput(path, name, &button, gettext(ETCOPEN));
	else
		back=fsel_input(path, name, &button);		
	wind_update(END_UPDATE);
	
	if(!back) return;
	if(!button) return;

	if (path[strlen(path)-1] != '\\')
	{
		backslash=strrchr(path, '\\');
		*(++backslash)=0;
	}

	strcpy(act_set->set->etc_path, path);
	file_fit(odial[PATHOB].ob_spec.tedinfo->te_ptext, path,20);
	while(strlen(odial[PATHOB].ob_spec.tedinfo->te_ptext)<20)
		strcat(odial[PATHOB].ob_spec.tedinfo->te_ptext, " ");
	w_objc_draw(&wdial, PATHOB, 8, sx,sy,sw,sh);

	/* Ggf. Auswahl von Env auf Path umstellen */
	if(odial[ETCPATH].ob_state & SELECTED) return;
	odial[ETCPATH].ob_state |= SELECTED;
	odial[ETCENV].ob_state &= (~SELECTED);
	w_objc_draw(&wdial, ETCPATH, 8,sx,sy,sw,sh);
	w_objc_draw(&wdial, ETCENV, 8,sx,sy,sw,sh);
}

/* -------------------------------------- */

char *file_fit(char *dst, char *src, long len)
{/* Kopiert den Pfad aus src nach dst unter Beachtung von len, d.h.
		ggf. werden im Zwischenteil Ordner durch "..." ersetzt.
		Gibt immer dst zurÅck.
		dst muû wegen 0-Zeichen min. len+1 groû sein */

	long	a, b;
	
	dst[0]=0;
	
	/* Paût's eh? */
	if(strlen(src)<=len)
	{
		strcpy(dst, src);
		return(dst);
	}
	
	/* Solange rÅckwÑrts kopieren, bis der erste '\' auftaucht */
	/* (oder der zweite, falls src mit '\' aufhîrt) */
	dst[len]=0;
	a=len-1; b=strlen(src)-1;
	if((a<=0) || (b<=0)) return(dst);
	do
	{	dst[a--]=src[b--];}
	while((a > -1) && (src[b]!='\\'));
	
	if(a==-1) return(dst); /* Fertig, hat nichtmal der ganze Dateiname reingepaût */
	
	/* Das '\' nehmen wir noch mit */
	dst[a--]='\\';
	
	if(a < 3) /* Da geht fast nix mehr rein->nur Punkte setzen */
	{
		while(a > -1) dst[a--]='.';
		return(dst);
	}
	/* Ansonsten jetzt von vorne soviel wie mîglich reinkopieren */
	strncpy(dst, src, a-2);
	strncpy(&(dst[a-2]),"... ",3); /* Drei Punkte ohne 0 kopieren */
	return(dst);
}

/* -------------------------------------- */

int load_setup(void)
{/* File format:
		4 Bytes magic : ICFG
		2 Bytes int:    sizeof(SETUP)
		2 Bytes int:    number of following entries
		2 Bytes int:		index of default setup (0-...)
		<number> * sizeof(SETUP) Bytes=Setup data equal to SETUP-struct
		
		return:
		1=ICONFSET.CFG wurde noch nicht angelegt
		0=ICONFSET.CFG gibbet
 */
	#ifdef gemret
		#undef gemret
	#endif
	#define gemret(a,b) {gemdos_alert(a,b);Fclose(fh);return(0);}
	long	fhl, id;
	int 	fh, setsize, dix, entries,a;
	char	path[256];
	SETUP *emergency;
	SET_LIST	*sl, *last_l;
	
	strcpy(path, "ICONFSET.CFG");
	/* Datei da? */
	if(shel_find(path)==0) return(1);
	
	fhl=Fopen(path, FO_READ);
	fh=(int)fhl;
	if(fhl < 0) gemret("Can\'t open INCONFSET.CFG", fhl);
	
	fhl=Fread(fh, 4, &id);
	if(fhl < 0) gemret("Can\'t read file ID", fhl);
	if(fhl < 4) {form_alert(1,"[3][ICONFSET.CFG is corrupted.|File size too small (<4).][Cancel]"); return(0);}
	
	if(id != 'ICFG')
		{Fclose(fh); form_alert(1,"[3][ICONFSET.CFG is corrupted.|Wrong ID.][Cancel]"); return(0);}

	fhl=Fread(fh, 2, &setsize);
	if(fhl < 0) gemret("Can\'t read size of entries", fhl);
	if(fhl < 2) {Fclose(fh); form_alert(1,"[3][ICONFSET.CFG is corrupted.|File size too small (<6).][Cancel]"); return(0);}
	/* Falsches Dateiformat ? */
	if(setsize != sizeof(SETUP))
		if(setsize != sizeof(SETUP)-2*80)	
			if(setsize != sizeof(SETUP)-2*80-2*80)	
				if(setsize != sizeof(SETUP)-2*80-2*80-34*66)
					{Fclose(fh); form_alert(1,"[3][Wrong format in ICONFSET.CFG.|Get a newer version of|ICONFSET.PRG.][Cancel]"); return(0);}

	fhl=Fread(fh, 2, &entries);
	if(fhl < 0) gemret("Can\'t read number of entries", fhl);
	if(fhl < 2) {Fclose(fh); form_alert(1,"[3][ICONFSET.CFG is corrupted.|File size too small (<8).][Cancel]"); return(0);}
	if(entries < 1)
		{Fclose(fh); form_alert(1,"[3][ICONFSET.CFG is corrupted.|Illegal number of setups.][Cancel]"); return(0);}

	fhl=Fread(fh, 2, &dix);
	if(fhl < 0) gemret("Can\'t read default setup", fhl);
	if(fhl < 2) {Fclose(fh); form_alert(1,"[3][ICONFSET.CFG is corrupted.|File size too small (<10).][Cancel]"); return(0);}
	if(dix >= entries)
		{Fclose(fh); form_alert(1,"[3][ICONFSET.CFG is corrupted.|Illegal default setup.][Cancel]"); return(0);}

	sl=&first_set;
	emergency=first_set.set;
	while(entries--)
	{
		sl->set=(SETUP*)calloc(sizeof(SETUP),1);
		if(sl->set==NULL)
		{
			Fclose(fh);first_set.set=emergency; first_set.next=NULL;
			form_alert(1,"[3][Insufficient memory|to load ICONFSET.CFG.][Cancel]");
			return(0);
		}
		
		fhl=Fread(fh, setsize, sl->set);
		if(fhl < 0)
		{
			first_set.set=emergency; first_set.next=NULL; 
			gemret("Error reading Setup",fhl);
		}
		if(fhl < setsize)
		{
			Fclose(fh);first_set.set=emergency; first_set.next=NULL; 
			form_alert(1,"[3][ICONFSET.CFG is corrupted.|File too small, setup incomplete.][Cancel]");
			return(0);
		}
		if(sl->set->version==0)	/* Alte Formate ergÑnzen */
		{
			sl->set->version=1;
			if(setsize == sizeof(SETUP)-2*80-34*66)
			{/* Hab leider in Version 1 verpennt, Version 1 zu setzen! */
				for(a=0; a < 24; ++a)	sl->set->service_names[a][0]=0;
				for(a=0; a < 10; ++a)	sl->set->proxy_names[a][0]=0;
	
				/* Alte IP-EintrÑge kopieren */
				if(sl->set->pop_ip)
					strcpy(sl->set->service_names[0], inet_ntoa(sl->set->pop_ip));
				if(sl->set->smtp_ip)
					strcpy(sl->set->service_names[1], inet_ntoa(sl->set->smtp_ip));
				if(sl->set->news_ip)
					strcpy(sl->set->service_names[2], inet_ntoa(sl->set->news_ip));
				if(sl->set->time_ip)
					strcpy(sl->set->service_names[3], inet_ntoa(sl->set->time_ip));
				for(a=0; a < 10; ++a)
				{
					if(sl->set->proxies[a].ip)
						strcpy(sl->set->proxy_names[a], inet_ntoa(sl->set->proxies[a].ip));
				}
			}
		}

		if(sl->set->version==2)
		{
			sl->set->version=3;
			sl->set->nntp_user[0]=0;
			sl->set->nntp_pass[0]=0;
		}
		else
		{
			decode(sl->set->nntp_user, 80);
			decode(sl->set->nntp_pass, 80);
		}

		if(sl->set->version==1)
		{
			sl->set->version=3;
			sl->set->nntp_user[0]=0;
			sl->set->nntp_pass[0]=0;
			sl->set->pop_user[0]=0;
			sl->set->pop_pass[0]=0;
		}
		else
		{
			decode(sl->set->pop_user, 80);
			decode(sl->set->pop_pass, 80);
		}

		decode(sl->set->ppp_auth_user, 80);
		decode(sl->set->ppp_auth_pass, 80);

		if(sl->set->dns_initial_delay_set==0)
		{
			sl->set->dns_initial_delay=1;
			sl->set->dns_initial_delay_set=1;
		}
		if(sl->set->default_snd_win==0) sl->set->default_snd_win=512;
		
		sl->next=(SET_LIST*)calloc(sizeof(SET_LIST),1);
		if(sl->next==NULL)
		{
			Fclose(fh);
			form_alert(1,"[3][Insufficient memory|to load all setups of|ICONFSET.CFG.][Cancel]");
			return(0);
		}
		last_l=sl;
		sl=sl->next;
	}
	Fclose(fh);	
	/* Unnîtig drangehÑngten lîschen */
	free(sl);
	last_l->next=NULL;
	set_ext_type(odial, SETPOP, dix);
	act_set=&first_set;
	while(dix--)
		act_set=act_set->next;
	return(0);
}

/* -------------------------------------- */

int save_setup(void)
{
	#ifdef gemret
		#undef gemret
	#endif
	#define gemret(a,b) {gemdos_alert(a,b);return(0);}
	long	fhl, id;
	int 	fh, setsize, entries, dix;
	SET_LIST	*sl;

	fhl=Fcreate("ICONFSET.CFG", 0);
	fh=(int)fhl;
	if(fhl < 0) gemret("Can\'t create INCONFSET.CFG", fhl);
	
	id='ICFG';
	fhl=Fwrite(fh, 4, &id);
	if(fhl < 0) gemret("Can\'t write file ID", fhl);
	if(fhl < 4) {form_alert(1,"[3][Can\'t write all bytes of|File ID][Cancel]"); return(0);}

	setsize=(int)sizeof(SETUP);
	fhl=Fwrite(fh, 2, &setsize);
	if(fhl < 0) gemret("Can\'t write size of entries", fhl);
	if(fhl < 2) {form_alert(1,"[3][Can\'t write all bytes of|size of entries.][Cancel]"); return(0);}

	entries=count_setups();	
	fhl=Fwrite(fh, 2, &entries);
	if(fhl < 0) gemret("Can\'t write number of entries", fhl);
	if(fhl < 2) {form_alert(1,"[3][Can\'t write all bytes of|number of entries.][Cancel]"); return(0);}

	dix=ext_type(odial, SETPOP);
	fhl=Fwrite(fh, 2, &dix);
	if(fhl < 0) gemret("Can\'t write default setup", fhl);
	if(fhl < 2) {form_alert(1,"[3][Can\'t write all bytes of|default setup.][Cancel]"); return(0);}
	
	sl=&first_set;
	while(entries--)
	{
		encode(sl->set->ppp_auth_user, 80);
		encode(sl->set->ppp_auth_pass, 80);
		encode(sl->set->pop_user, 80);
		encode(sl->set->pop_pass, 80);
		encode(sl->set->nntp_user, 80);
		encode(sl->set->nntp_pass, 80);
		fhl=Fwrite(fh, sizeof(SETUP), sl->set);
		decode(sl->set->ppp_auth_user, 80);
		decode(sl->set->ppp_auth_pass, 80);
		decode(sl->set->pop_user, 80);
		decode(sl->set->pop_pass, 80);
		decode(sl->set->nntp_user, 80);
		decode(sl->set->nntp_pass, 80);
		if(fhl < 0)
		{
			Fclose(fh);
			gemret("Error writing Setup",fhl);
		}
		if(fhl < sizeof(SETUP))
		{
			Fclose(fh);
			form_alert(1,"[3][Can\'t write all bytes of|setup.][Cancel]");
			return(0);
		}
		sl=sl->next;
	}
	Fclose(fh);	
	return(1);
}

/* -------------------------------------- */

void encode(char *string, int len)
{
	uchar	seed, *str=(uchar*)string;
	int a;
	
	seed=(uchar)clock();
	
	str[len-1]=seed;

	srand(seed);

	for(a=0; a < (len-1); ++a)
	{
		str[a]^=(uchar)random(256);
	}
}

/* -------------------------------------- */

void decode(char *string, int len)
{
	uchar	seed, *str=(uchar*)string;
	int		a;
	
	seed=str[len-1];
	
	srand(seed);

	for(a=0; a < (len-1); ++a)
	{
		str[a]^=(uchar)random(256);
	}
	str[len-1]=0;
}


/*
void *malloc(size_t len)
{
	return(Malloc(len));
}

void *calloc(size_t len, size_t size)
{
	void	*m;
	
	len*=size;
	m=malloc(len);
	if(!m) return(NULL);
	memset(m, 0, len);
	return(m);
}

void free(void *p)
{
	Mfree(p);
}
*/