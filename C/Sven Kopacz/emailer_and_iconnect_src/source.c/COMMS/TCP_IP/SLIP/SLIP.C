#include <tos.h>
#include "\..\network.h"

#include <ec_gem.h>
#include <hsmod.h>

#include <socket.h>
#include <sockerr.h>
#include <in.h>

#define PEV_LOW_UP			0		/* Lower Level is up */
#define PEV_LOW_DOWN		1		/* Lower Level is down */
#define PEV_ADMIN_OPEN	2		/* Administrative Open */
#define PEV_ADMIN_CLOSE	3		/* Administrative Close */

#include "slip.h"

#define BUFSIZE 200

#define set_ext_type(tree,ob,val)	tree[ob].ob_type &=255; tree[ob].ob_type |= (((char)val)<<8);

#define set_port(a)	if(a >= io_ports){strcpy(ocon[P1].ob_spec.free_string, port_names[0]);set_ext_type(ocon,P1,0);}else{strcpy(ocon[P1].ob_spec.free_string, port_names[a]);set_ext_type(ocon,P1,a);}
#define set_baud(a)	strcpy(ocon[P2].ob_spec.free_string, baud_names[a]);set_ext_type(ocon,P2,a);
#define set_hshk(a)	strcpy(ocon[P3].ob_spec.free_string, hshk_names[a]);set_ext_type(ocon,P3,a);
#define set_parity(a)	strcpy(ocon[P4].ob_spec.free_string, parity_names[a]);set_ext_type(ocon,P4,a);
#define set_dbit(a)	strcpy(ocon[P5].ob_spec.free_string, dbit_names[a]);set_ext_type(ocon,P5,a);
#define set_sbit(a)	strcpy(ocon[P6].ob_spec.free_string, sbit_names[a]);set_ext_type(ocon,P6,a);


int cx, cy, ok, sx, sy, sw, sh;
int	slip=0;
char	*line[BUFSIZE], path[128];

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

int	io_ports;


WINDOW	win, wdial, wcon;
DINFO		ddial, dcon;
OBJECT	*odial, *ocon, *oerrrep;
cookie_struct		*sint;

void quit(WINDOW *win);
int mini_term(void);
void term_out(char *text);
int open_aux(char *path, long baud);
void new_line(void);
void zock(void);

void main(void)
{
	e_start_as(ACC|PRG,"Blip");
	
	if(ap_type & (ACC|PRG))
	{
		wind_get(0,WF_WORKXYWH,&sx,&sy,&sw,&sh);
		uses_txwin();
		if(mini_term() && slip)
			zock();
	}
	
	e_quit();
}

ulong w_ip(uchar i1, uchar i2, uchar i3, uchar i4)
{
	ulong ip;
	
	ip=((ulong)i1<<24)+((ulong)i2<<16)+((ulong)i3<<8)+(ulong)i4;
	return(ip);
}

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

void time_wait(int ms)
{
	evnt_timer(ms,0);
}

int esettext(int ob, int yn)
{/* Set YES/no-text on yn 1/0 in ob of oerrrep */
 /* Return yn */
 
 if(yn)
 	strcpy(oerrrep[ob].ob_spec.free_string, "YES");
 else
 	strcpy(oerrrep[ob].ob_spec.free_string, "NO");

 return(yn);
}

void show_errrep(void)
{
	int x,y,w,h;
	
	wind_update(BEG_UPDATE);
	form_center(oerrrep, &x, &y, &w, &h);
	form_dial(FMD_START, x,y,w,h,x,y,w,h);
	objc_draw(oerrrep, 0, 8, sx,sy,sw,sh);
	form_do(oerrrep, 0);	/* Can only be OK-Button */
	form_dial(FMD_FINISH, x,y,w,h,x,y,w,h);
	wind_update(END_UPDATE);
}

int start_ppp(void)
{
	int		dum, evnt, to_err;
	int	timeout=300;	/* 30 sec. */
	ulong	tip;
	
	sint->sys->ppp_event(PEV_LOW_UP);
	sint->sys->ppp_event(PEV_ADMIN_OPEN);
	
	while(timeout--)
	{
		w_dtimevent(&evnt, &dum, &dum, &dum, &dum, 100,0);
		if(evnt & MU_TIMER)
			sint->sys->timer_jobs();
		if(sint->defs->ppp_suc)	/* Sign up complete */
		{/* Did i get local IP and DNS? */
			tip=sint->defs->my_ip;
			if((tip==0) || (tip==0xfffffffful))
				break;	/* Leave while and proceed to error-report */
			tip=sint->defs->name_server_ip;
			if((tip==0) || (tip==0xfffffffful))
				break;	/* Leave while and proceed to error-report */
			return(1);
		}
	}
	
	/* Prepare and show Error-Report */
	if(sint->defs->ppp_auth_nak)
		form_alert(1,"[3][PPP authentication failed.|Check user and password.][Other errors...]");

	to_err=0;
	rsrc_gaddr(0, ERRREP, &oerrrep);
	to_err+=esettext(ERR1, sint->defs->ppp_crj_sent);
	to_err+=esettext(ERR2, sint->defs->ppp_crj_recv);
	to_err+=esettext(ERR3, sint->defs->ppp_prj_sent);
	to_err+=esettext(ERR4, sint->defs->ppp_prj_recv);
	to_err+=esettext(ERR5, sint->defs->ppp_auth_req);
	to_err+=esettext(ERR6, sint->defs->ppp_lqp_req);
	to_err+=esettext(ERR7, sint->defs->ipcp_address_rej);
	to_err+=esettext(ERR8, sint->defs->ipcp_dns_rej);
	if(to_err)	/* No Timeout-Error */
		esettext(ERR9, 0);
	else
		esettext(ERR9, 1);
	
	show_errrep();
	
	return(0);
}

void zock(void)
{
	int		dum, evnt;
	long	ph;
	char	buf[2];
	
	ok=1;
	sint->sys->terminate();
	sint->defs->my_ip=fetch_ip(odial, IP);
	sint->defs->name_server_ip=fetch_ip(ocon, DNS); /*'\x81\x45\x01\x1c'*/
	if(ocon[PPP_SEL].ob_state & SELECTED)
		sint->defs->using_ppp=1;
	else
		sint->defs->using_ppp=0;
	sint->sys->emalloc=malloc;
	sint->sys->efree=free;
	sint->sys->etimer=time_wait;
	sint->sys->server_pd=_BasPag;
	if(ocon[DEBUG].ob_state & SELECTED)
		sint->sys->_debug=1;
	else
		sint->sys->_debug=0;
	sint->sys->open_port(path);
	strcpy(sint->defs->ppp_auth_user, ocon[AUTHUSER].ob_spec.tedinfo->te_ptext);
	strcpy(sint->defs->ppp_auth_pass, ocon[AUTHPASS].ob_spec.tedinfo->te_ptext);

	if(sint->defs->using_ppp)
	{
		if(start_ppp()==0)
		{	ok=0;}
		else
		{/* IP anzeigen */
			store_ip(odial, IP, sint->defs->my_ip);
			s_redraw(&wdial);
		}
	}
	while(ok)
	{
		w_dtimevent(&evnt, &dum, &dum, &dum, &dum, 100,0);
		if(evnt & MU_TIMER)
			sint->sys->timer_jobs();
	}
	sint->sys->terminate();
	sint->sys->close_port();
	sint->sys->server_pd=NULL;
	ph=-1;

	if(form_alert(1,"[2][Shutdown complete.|Send hang up string?][Yes|No]")==1)
	{
		while(ph < 0)
		{
			ph=Fopen(path, FO_RW);
		}
		Fwrite((int)ph, 3, "+++");
		/* Auf Modem-OK warten */
		ok=1;
		while(ok)
		{
			while(Fread((int)ph, 2, buf)==0);
			if(ok==1)
			{
				if((buf[0]=='O')&&(buf[1]=='K'))
					ok=0;
				else if(buf[1]=='O')
					ok=2;
			}
			else if(ok==2)
			{
				if(buf[0]=='K')
					ok=0;
				else
					ok=1;
			}
		}
		Fwrite((int)ph, 4, "ath\r");
		Fclose((int)ph);
	}

	w_kill(&wdial);
}

void do_dial(int ob)
{
	switch(ob)
	{
		case SLIP:
			ok=0; slip=1;
			odial[SLIP].ob_state|=DISABLED;
			odial[ONLINE].ob_flags&=(~HIDETREE);
			w_objc_draw(&wdial,SLIP,1,sx,sy,sw,sh);
			w_objc_draw(&wdial,ONLINE,1,sx,sy,sw,sh);
		break;
		case QUIT:
			if((!(odial[SLIP].ob_state & SELECTED))
			  ||(form_alert(1,"[2][Shutdown Sockets?][Yes|No]")==1))
				ok=0;
			w_unsel(&wdial, QUIT);
		break;
	}
}

void set_default_port(void)
{/* Tr„gt ersten Port in Dialog ein */
	set_port(DEF_PORT);
	set_baud(DEF_BAUD);
	set_hshk(DEF_HSHK);
	set_parity(DEF_PARITY);
	set_dbit(DEF_DBIT);
	set_sbit(DEF_SBIT);
	ocon[ALT1].ob_spec.tedinfo->te_ptext[0]=0;
	ocon[ALT2].ob_spec.tedinfo->te_ptext[0]=0;
	ocon[ALT3].ob_spec.tedinfo->te_ptext[0]=0;
	ocon[AUTHUSER].ob_spec.tedinfo->te_ptext[0]=0;
	ocon[AUTHPASS].ob_spec.tedinfo->te_ptext[0]=0;
	ocon[DNS].ob_spec.tedinfo->te_ptext[0]=0;
	ocon[LOCAL].ob_spec.tedinfo->te_ptext[0]=0;
	ocon[SLIP_SEL].ob_state |= SELECTED;
	ocon[PPP_SEL].ob_state &= (~SELECTED);
}

void write_setup(int fh)
{/* Schreibe Setup nach Filehandle fh */
	char	cbuf;
	int		ibuf;
	ulong	lbuf;

#define Iwrite(a) ibuf=a;Fwrite(fh,2,&ibuf);	
	
	Iwrite(1);	/* Port */
	Iwrite(ocon[P1].ob_type>>8);
	Iwrite(2);	/* Baud */
	Iwrite(ocon[P2].ob_type>>8);
	Iwrite(3);	/* Handshake */
	Iwrite(ocon[P3].ob_type>>8);
	Iwrite(4);	/* Parity */
	Iwrite(ocon[P4].ob_type>>8);
	Iwrite(5);	/* Data-Bits */
	Iwrite(ocon[P5].ob_type>>8);
	Iwrite(6);	/* Stop-Bits */
	Iwrite(ocon[P6].ob_type>>8);
	
	Iwrite(7);	/* Alt+1 */
	Iwrite((int)strlen(ocon[ALT1].ob_spec.tedinfo->te_ptext)+1);
	Fwrite(fh, (int)strlen(ocon[ALT1].ob_spec.tedinfo->te_ptext)+1, ocon[ALT1].ob_spec.tedinfo->te_ptext);
	Iwrite(8);	/* Alt+2 */
	Iwrite((int)strlen(ocon[ALT2].ob_spec.tedinfo->te_ptext)+1);
	Fwrite(fh, (int)strlen(ocon[ALT2].ob_spec.tedinfo->te_ptext)+1, ocon[ALT2].ob_spec.tedinfo->te_ptext);
	Iwrite(9);	/* Alt+3 */
	Iwrite((int)strlen(ocon[ALT3].ob_spec.tedinfo->te_ptext)+1);
	Fwrite(fh, (int)strlen(ocon[ALT3].ob_spec.tedinfo->te_ptext)+1, ocon[ALT3].ob_spec.tedinfo->te_ptext);

	Iwrite(10);	/* CR 1 */
	if(ocon[CR1].ob_state & SELECTED) cbuf=1; else cbuf=0;
	Fwrite(fh, 1, &cbuf);
	Iwrite(11);	/* CR 2 */
	if(ocon[CR2].ob_state & SELECTED) cbuf=1; else cbuf=0;
	Fwrite(fh, 1, &cbuf);
	Iwrite(12);	/* CR 3 */
	if(ocon[CR3].ob_state & SELECTED) cbuf=1; else cbuf=0;
	Fwrite(fh, 1, &cbuf);
	
	Iwrite(13);	/* DNS IP */
	lbuf=fetch_ip(ocon, DNS);
	Fwrite(fh, 4, &lbuf);
	Iwrite(14);	/* LOCAL IP */
	lbuf=fetch_ip(ocon, LOCAL);
	Fwrite(fh, 4, &lbuf);
	
	Iwrite(15);	/* Debug */
	if(ocon[DEBUG].ob_state & SELECTED) cbuf=1; else cbuf=0;
	Fwrite(fh, 1, &cbuf);
	
	Iwrite(16);	/* Slip(0) or PPP(1) */
	if(ocon[SLIP_SEL].ob_state & SELECTED) cbuf=0; else cbuf=1;
	Fwrite(fh, 1, &cbuf);
	
}

void read_setup(int fh)
{/* Lese Setup aus Filehandle fh */
	char	cbuf;
	int		ibuf;
	ulong	lbuf;
	long	ret;
	
	do
	{
		ret=Fread(fh, 2, &ibuf);
		if(ret > 0) switch(ibuf)
		{
			case 1:	/* Port - 2 Byte Index */
				Fread(fh, 2, &ibuf); set_port(ibuf);	break;
			case 2: /* Baud - 2 Byte Index*/
				Fread(fh, 2, &ibuf); set_baud(ibuf);	break;
			case 3: /* Handshake - 2 Byte Index*/
				Fread(fh, 2, &ibuf); set_hshk(ibuf);	break;
			case 4: /* Parity - 2 Byte Index*/
				Fread(fh, 2, &ibuf); set_parity(ibuf);	break;
			case 5: /* Datenbits - 2 Byte Index*/
				Fread(fh, 2, &ibuf); set_dbit(ibuf);	break;
			case 6: /* Stopbits - 2 Byte Index*/
				Fread(fh, 2, &ibuf); set_sbit(ibuf);	break;

			case 7: /* Alt+1 - 2 Byte L„nge + L„nge Byte */
				Fread(fh, 2, &ibuf); /* Stringl„nge incl. 0 */
				Fread(fh, ibuf, ocon[ALT1].ob_spec.tedinfo->te_ptext);
			break;
			case 8: /* Alt+2 - 2 Byte L„nge + L„nge Byte */
				Fread(fh, 2, &ibuf); /* Stringl„nge incl. 0 */
				Fread(fh, ibuf, ocon[ALT2].ob_spec.tedinfo->te_ptext);
			break;
			case 9: /* Alt+3 - 2 Byte L„nge + L„nge Byte */
				Fread(fh, 2, &ibuf); /* Stringl„nge incl. 0 */
				Fread(fh, ibuf, ocon[ALT3].ob_spec.tedinfo->te_ptext);
			break;
			
			case 10: /* CR 1 - 1 Byte*/
				Fread(fh, 1, &cbuf); 
				if(cbuf) ocon[CR1].ob_state |=SELECTED;
				else ocon[CR1].ob_state &= (~SELECTED);
			break;
			case 11: /* CR 2 - 1 Byte*/
				Fread(fh, 1, &cbuf); 
				if(cbuf) ocon[CR2].ob_state |=SELECTED;
				else ocon[CR2].ob_state &= (~SELECTED);
			break;
			case 12: /* CR 3 - 1 Byte*/
				Fread(fh, 1, &cbuf); 
				if(cbuf) ocon[CR3].ob_state |=SELECTED;
				else ocon[CR3].ob_state &= (~SELECTED);
			break;
			
			case 13: /* DNS IP - 4 Byte*/
				Fread(fh, 4, &lbuf);
				store_ip(ocon, DNS, lbuf);
			break;
			case 14: /* Local IP - 4 Byte*/
				Fread(fh, 4, &lbuf);
				store_ip(ocon, LOCAL, lbuf);
			break;

			case 15: /* Debug - 1 Byte*/
				Fread(fh, 1, &cbuf); 
				if(cbuf) ocon[DEBUG].ob_state |=SELECTED;
				else ocon[DEBUG].ob_state &= (~SELECTED);
			break;
			
			case 16:	/* Slip(0) or PPP(1) - 1 Byte */
				ocon[SLIP_SEL].ob_state &= (~SELECTED);
				ocon[PPP_SEL].ob_state &= (~SELECTED);
				Fread(fh, 1, &cbuf);
				if(cbuf) 
					ocon[PPP_SEL].ob_state|=SELECTED;
				else
					ocon[SLIP_SEL].ob_state|=SELECTED;
			break;
		}
	}while(ret>0);
}

void read_default_set(void)
{
	int fh=(int)Fopen("DEFAULT.CON",FO_READ);
	if(fh < 0) return;
	read_setup(fh);
	Fclose(fh);
}

int	f_input(char *spruch, char *path, char *name)
{
	/* ™ffnet Fileselector und schreibt den Zugriffspfad
		 des Auswahlergebnisses in path */
		 
	char	*backslash;
	int		gb0, button, back;
	long	dum;
	
	gb0=_GemParBlk.global[0];
	wind_update(BEG_UPDATE);
	if ((gb0 >= 0x0140) || find_cookie('FSEL', &dum))
		back=fsel_exinput(path, name, &button, spruch);
	else
		back=fsel_input(path, name, &button);		
	wind_update(END_UPDATE);
	
	if (back)
	{
		if (button)
		{
			if (path[strlen(path)-1] != '\\')
			{
				backslash=strrchr(path, '\\');
				*(++backslash)=0;
			}
			
			strcat(path, name);
		}
		else
			back=0;
	}
	
	return(back);
}

void load_setup(void)
{
	long	fh;
	char	mname[64], mpath[256], *mtitel="Load connection setup";

	strcpy(mpath,"X:");
	Dgetpath(&mpath[2], 0);
	mpath[0]=(char)(Dgetdrv()+65);
	strcat(mpath, "\\*.CON");
	mname[0]=0;
		
	if(f_input(mtitel, mpath, mname)==0) return;

	fh=Fopen(mpath, FO_READ);
	if(fh < 0)
	{
		form_alert(1,"[3][Can\'t open file.][Cancel]");
		return;
	}
	read_setup((int)fh);
	Fclose((int)fh);
}

void save_setup(void)
{
	long	fh;
	char	mname[64], mpath[256], *mtitel="Save connection setup";

	strcpy(mpath,"X:");
	Dgetpath(&mpath[2], 0);
	mpath[0]=(char)(Dgetdrv()+65);
	strcat(mpath, "\\*.CON");
	mname[0]=0;

	if(f_input(mtitel, mpath, mname)==0) return;

	fh=Fopen(mpath, FO_READ);
	if(fh > 0)
	{
		Fclose((int)fh);
		if(form_alert(1,"[2][File exists. Overwrite?][OK|Cancel]")==2)
			return;
	}
	fh=Fcreate(mpath, 0);
	if(fh < 0)
	{
		form_alert(1,"[3][Can\'t create file.][Cancel]");
		return;
	}
	write_setup((int)fh);
	Fclose((int)fh);
}


int get_ports(void)
{/* Liest den RSVF-Cookie aus und fllt port_names[][] */
 /* Return 0=Fehler */
	int			cont=1;
	long 		rsv_ob;

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
		/* Nur Schnittstellen (128) ber Gemdos(64) z„hlen */
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

int open_port(void)
{/* Versucht den Port mit den Parametern aus Dialog einzustellen 
	r: 1=ok, 0=Fehler 
*/

	long hd, var, var2;
	int	 hdi;
	char nl[256];

	strcpy(path, "U:\\DEV\\");
	strcat(path, ocon[P1].ob_spec.free_string);
	
	hd=Fopen(path, FO_RW);
	if(hd < 0)
	{	form_alert(1,"[3][Can\'t open port.][Cancel]");	return(0);}

	hdi=(int)hd;	
	/* Parameter setzen */
	var=atol(ocon[P2].ob_spec.free_string);
	hd=Fcntl(hdi, (long)&var, TIOCIBAUD);
	if(hd < 0)	{form_alert(1,"[3][Can\'t set baud-rate.][Cancel]");	Fclose(hdi); return(0);}

	var=atol(ocon[P2].ob_spec.free_string);
	hd=Fcntl(hdi, (long)&var, TIOCOBAUD);
	if(hd < 0)	{form_alert(1,"[3][Can\'t set baud-rate.][Cancel]");	Fclose(hdi); return(0);}

	var=0;
	hd=Fcntl(hdi, (long)&var, TIOCGFLAGS);
	if(hd < 0)	{form_alert(1,"[3][Can\'t request port-setup.][Cancel]");	Fclose(hdi); return(0);}

	/* Zu „ndernde Parameter ausmaskieren */
	var2=TF_STOPBITS|TF_CHARBITS|TF_FLAG;
	var2<<=16;
	var2=~var2;
	var&=var2;

	var2=0;
	/* Parameter reinodern */
	switch(ocon[P3].ob_type>>8)	/* Handshake: off,xon/xoff,rts/cts */
	{
		case 1:	var2|=T_TANDEM; break;
		case 2: var2|=T_RTSCTS; break;
	}
	switch(ocon[P4].ob_type>>8) /* Parity: off, odd, even */
	{
		case 1: var2|=T_ODDP; break;
		case 2: var2|=T_EVENP; break;
	}
	switch(ocon[P4].ob_type>>8) /* Datenbits: 8,7,6,5 */
	{
		case 0: var2|=TF_8BIT; break;
		case 1: var2|=TF_7BIT; break;
		case 2: var2|=TF_6BIT; break;
		case 3: var2|=TF_5BIT; break;
	}
	switch(ocon[P4].ob_type>>8) /* Stopbits: 1, 1.5, 2 */
	{
		case 0: var2|=TF_1STOP; break;
		case 1: var2|=TF_15STOP; break;
		case 2: var2|=TF_2STOP; break;
	}

	/* Gesamtvariable setzen */
	var2<<=16;
	var|=var2;
	
	hd=Fcntl(hdi, (long)&var, TIOCSFLAGS);
	if(hd < 0)
	{form_alert(1,"[3][Can\'t set port parameters.][Cancel]");	Fclose(hdi); return(0);}


	/* Schnittstellen-Info ausgeben */
	strcpy(nl,"Port ");
	strcat(nl, ocon[P1].ob_spec.free_string);
	strcat(nl," is now active on this terminal.");
	term_out(nl);
	term_out("Port is currently set to:");
	/* Parameter erfragen */
	var=-1;
	hd=Fcntl(hdi, (long)&var, TIOCIBAUD);
	if(hd >= 0)
	{
		ltoa(var, nl, 10);
		strcat(nl, " input baud rate");
		term_out(nl);
	}	
	else
	{
		ltoa(hd, nl, 10);
		strcat(nl, " error input baud rate request");
		term_out(nl);
	}	

	var=-1;
	hd=Fcntl(hdi, (long)&var, TIOCOBAUD);
	if(hd >= 0)
	{
		ltoa(var, nl, 10);
		strcat(nl, " output baud rate");
		term_out(nl);
	}	
	else
	{
		ltoa(hd, nl, 10);
		strcat(nl, " error output baud rate request");
		term_out(nl);
	}	

	var=0;
	hd=Fcntl(hdi, (long)&var, TIOCGFLAGS);
	if(hd >= 0)
	{
		var>>=16;
		if(var & TF_1STOP)
			term_out("1 stopbit");
		else if(var & TF_15STOP)
			term_out("1.5 stopbit");
		else if(var & TF_2STOP)
			term_out("2 stopbit");
			
		if(!(var & TF_CHARBITS))
			term_out("8 data bits");
		else if(var & TF_7BIT)
			term_out("7 data bits");
		else if(var & TF_6BIT)
			term_out("6 data bits");
		else if(var & TF_5BIT)
			term_out("5 data bits");
		
		if(var & T_TANDEM)
			term_out("XON/XOFF active");
		if(var & T_RTSCTS)
			term_out("RTS/CTS active");
			
		if(var & T_EVENP)
			term_out("even parity");
		else if(var & T_ODDP)
			term_out("odd parity");
		else
			term_out("no parity");
	}	
	else
	{
		ltoa(hd, nl, 10);
		strcat(nl, " error parameter request");
		term_out(nl);
	}	
	
	return(hdi);
}

int do_popup(WINDOW *root, int parent, OBJECT *pop)
{/* ™ffnet das Popup pop an x/y von root->dinfo->dtree[PRPOP]
		Vorauswahl (Check) und Y-Pos. werden an root-ext_type
		angepažt.
		Wenn Auswahl getroffen wird, wird Text aus pop ohne die
		ersten zwei Zeichen nach root kopiert und fr dieses ein
		Redraw ausgel”st.
		Gibt 1 zurck, wenn Žnderung vorgenommen wurde, sonst 0
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
	if((a > -1) && (a != b))
	{
		strcpy(oroot[parent].ob_spec.free_string,	&(pop[a+1].ob_spec.free_string[2]));
		w_objc_draw(root, parent, 8, sx, sy, sw, sh);		
		set_ext_type(oroot,parent,a);
		return(1);
	}
	return(0);
}

void fpopup(int ob, char **names, int num)
{/* Popup erstellen, aufrufen und Auswahl in Poproot und
		ext_ob eintragen */
	OBJECT 	*tree, *root;
	char		*strings;
	int			a;
	long		slen;
	
	rsrc_gaddr(0, POPUP, &root);
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
	a=do_popup(&wcon, ob, tree);
	free(tree);
}

void dial_con(int ob)
{
	switch(ob)
	{
		case P1: fpopup(P1, port_names, NUM_PORT); break;
		case P2: fpopup(P2, baud_names, NUM_BAUD); break;
		case P3: fpopup(P3, hshk_names, NUM_HSHK); break;
		case P4: fpopup(P4, parity_names, NUM_PARITY); break;
		case P5: fpopup(P5, dbit_names, NUM_DBIT); break;
		case P6: fpopup(P6, sbit_names, NUM_SBIT); break;
		
		case CANCEL:
			w_unsel(&wcon, CANCEL);
			ok=-1;
		break;
		case OK:
			w_unsel(&wcon, OK);
			if((ok=open_port()) <= 0)
				ok=0;
		break;
		case LOAD:
			load_setup();
			s_redraw(&wcon);
			w_unsel(&wcon, LOAD);
		break;
		case SAVE:
			save_setup();
			w_unsel(&wcon, SAVE);
		break;
	}
}

int port_dial(void)
{/* Ruft port_dialog auf, R: 0 bei Abbruch */

	int dum;
	
	if(get_ports()==0) return(0);
	set_default_port();	/* Dialog fllen */
	read_default_set();	/* Default-Setup einlesen falls vorhanden */

	w_open(&wcon);
	
	ok=0;
	while(!ok)
		w_devent(&dum, &dum, &dum, &dum, &dum);

	/* Dialog schliežen */
	w_close(&wcon);
	w_kill(&wcon);
	
	if(ok == -1) return(0);
	return(ok);
}

int mini_term(void)
{
	TINFO		twin;
	int			a, evnt, f3d, dum, swt, key, port, evret, ocy=0;
	char		buf[1024], *d;
	long 		s_in, cnt;

	if(!find_cookie('SLIP', (long*)&sint))
	{
		form_alert(1,"[3][Slip not installed.][Cancel]");
		return(0);
	}
	if(sint->sys->server_pd != NULL)
	{
		form_alert(1,"[3][Slip allready served.][Cancel]");
		return(0);
	}
	
	sint->sys->close_port();
	if(rsrc_load("SLIP.RSC")==0)
	{
		form_alert(1,"[3][Error reading RSC.][Cancel]");
		return(0);
	}

	rsrc_gaddr(0,SERIAL, &ocon);
	/* Ggf. selektierte 3D-Rahmen deselektieren */
	if((wwork_out[13]<16)||(appl_getinfo(13,&f3d,&dum,&dum,&dum)==0) || (f3d==0))
	{
		ocon[IB1].ob_state &=(~SELECTED);
		ocon[IB2].ob_state &=(~SELECTED);
		ocon[IB3].ob_state &=(~SELECTED);
	}
	dcon.tree=ocon;
	dcon.support=0;
	dcon.dservice=dial_con;
	dcon.osmax=0;
	dcon.odmax=8;
	w_dinit(&wcon);
	wcon.dinfo=&dcon;
	w_dial(&wcon, D_CENTER);
	dcon.dedit=ALT1;

	rsrc_gaddr(0,DIAL,&odial);
	odial[IP].ob_spec.tedinfo->te_ptext[0]=0;
	odial[ONLINE].ob_flags|=HIDETREE;
	ddial.tree=odial;
	ddial.support=0;
	ddial.dservice=do_dial;
	ddial.osmax=0;
	ddial.odmax=8;
	w_dinit(&wdial);
	wdial.dinfo=&ddial;
	w_dial(&wdial, D_CENTER);
	ddial.dedit=IP;

	d=(char*)malloc(12*MAX_PORTS);
	for(a=0; a < MAX_PORTS; ++a)
	{
		port_names[a]=d;
		d+=12;
	}
	
	for(a=0; a < BUFSIZE; ++a)
	{
		line[a]=(char*)malloc(256);
		line[a][0]=0;
	}
	for(a=0; a < 25; ++a)
	{
		line[a][0]=' ';
		line[a][1]=0;
	}

	cx=0;
	cy=0;

	w_init(&win);
	twin.text=line;
	win.tinfo=&twin;
	win.name="Rudi";
	w_text(&win);
	win.do_align=SIZE;
	win.closed=quit;
	
	strcpy(line[cy++], "Rudi-Terminal V0.1  Sven Kopacz");
	strcpy(line[cy++], "-------------------------------");
	
	while(strlen(line[0]) < 80) strcat(line[0],  " ");

	if((port=port_dial())==0)
	 return(0);

	/* IP bernehmen */
	strcpy(odial[IP].ob_spec.tedinfo->te_ptext, ocon[LOCAL].ob_spec.tedinfo->te_ptext);
	
	t_calc(&win);
	w_open(&win);
	w_txchange(&win);
	w_txfit(&win, T_HFIT|T_VFIT);

	
	line[cy][0]='_';
	line[cy][1]=0;
	
	w_open(&wdial);
	
	ok=1;
	while(ok)
	{
		evret=w_dtimevent(&evnt, &dum, &dum, &swt, &key, 100,0);
		if(((evret==-2) || (evret==0)) && (port >= 0))
		{
			if(evnt & MU_KEYBD)
			{
				buf[0]=key & 255;
				if(swt==8) /* Alt-Kombination werden nicht abgeschickt */
				{
					if((key>>8)==120)
					{
						Fwrite(port,strlen(ocon[ALT1].ob_spec.tedinfo->te_ptext),
									 ocon[ALT1].ob_spec.tedinfo->te_ptext);
						if(ocon[CR1].ob_state & SELECTED)
							Fwrite(port,1 ,"\r");
					}
					else if((key>>8)==121)
					{
						Fwrite(port,strlen(ocon[ALT2].ob_spec.tedinfo->te_ptext),
									 ocon[ALT2].ob_spec.tedinfo->te_ptext);
						if(ocon[CR2].ob_state & SELECTED)
							Fwrite(port,1 ,"\r");
					}
					else if((key>>8)==122)
					{
						Fwrite(port,strlen(ocon[ALT3].ob_spec.tedinfo->te_ptext),
									 ocon[ALT3].ob_spec.tedinfo->te_ptext);
						if(ocon[CR3].ob_state & SELECTED)
							Fwrite(port,1 ,"\r");
					}
				}
				else if(buf[0])
					Fwrite(port, 1, buf);
			}
			if(evnt & MU_TIMER)
			{
				s_in=Fread(port, 1024, buf);
				cnt=0;

				while(cnt < s_in)
				{
					while(cnt < s_in)
					{
						if(cx >= 255)
						{
							line[cy][255]=0;
							new_line();
							cx=0;
						}
						if(buf[cnt] > 31)
							line[cy][cx++]=buf[cnt];
						else if(buf[cnt] == 13)
						{
							if(cx == 0)
								line[cy][cx++]=' ';
							line[cy][cx]=0;
							new_line();
							cx=0;
							strcpy(line[cy], " ");
						}
						else if(buf[cnt] == 8)
						{
							--cx;
							if(cx < 0)
								cx=0;
						}
						++cnt;
					}
				}
				if(cx >= 255)
				{
					line[cy][cx]=0;
					new_line();
					cx=0;
				}
				line[cy][cx]='_';
				line[cy][cx+1]=0;
				line[cy+1][0]=0;
				if(s_in)
				{
					if(ocy==cy)
						w_txlinechange(&win, cy);
					else
					{
						ocy=cy;
						w_txchange(&win);
						w_txgoto(&win, 0, cy-1);
					}
				}
			}
		}
	}

	w_kill(&win);

	Fclose(port);
	
	for(a=0; a < BUFSIZE; ++a)
		free(line[a]);
	return(1);
}

void new_line(void)
{
	int		a;
	char	*ml=line[0];
	
	++cy;
	if(cy < BUFSIZE-1)
		return;
		
	for(a=0; a < BUFSIZE-1; ++a)
		line[a]=line[a+1];

	cy=BUFSIZE-2;
	line[cy]=ml;
	line[cy][0]=0;
}

int open_aux(char *path, long baud)
{
	long hd, var, var2;
	int	 hdi;
	char nl[128];
	
	hd=Fopen(path, FO_RW);
	if(hd < 0)
		return((int)hd);

	hdi=(int)hd;	
	
	/* Parameter setzen */
	var=baud;
	hd=Fcntl(hdi, (long)&var, TIOCIBAUD);
	if(hd < 0)
	{
		ltoa(hd, nl, 10);
		strcat(nl, " Fehler Eingabespeed");
		term_out(nl);
	}	
	var=baud;
	hd=Fcntl(hdi, (long)&var, TIOCOBAUD);
	if(hd < 0)
	{
		ltoa(hd, nl, 10);
		strcat(nl, " Fehler Ausgabespeed");
		term_out(nl);
	}	
	var=0;
	hd=Fcntl(hdi, (long)&var, TIOCGFLAGS);
	if(hd < 0)
	{
		ltoa(hd, nl, 10);
		strcat(nl, " Fehler Flags erfragen");
		term_out(nl);
	}
	var2=TF_STOPBITS|TF_CHARBITS|TF_FLAG;
	var2<<=16;
	var2=~var2;
	var&=var2;
	var2=TF_1STOP|TF_8BIT;
	if(baud != 9600)
		var2|=T_RTSCTS;
	var2<<=16;
	var|=var2;
	
	hd=Fcntl(hdi, (long)&var, TIOCSFLAGS);
	if(hd < 0)
	{
		ltoa(hd, nl, 10);
		strcat(nl, " Fehler Protokoll");
		term_out(nl);
	}	

	/* Parameter erfragen */
	var=-1;
	hd=Fcntl(hdi, (long)&var, TIOCIBAUD);
	if(hd >= 0)
	{
		ltoa(var, nl, 10);
		strcat(nl, " Eingabespeed");
		term_out(nl);
	}	
	else
	{
		ltoa(hd, nl, 10);
		strcat(nl, " Fehler Eingabespeed");
		term_out(nl);
	}	

	var=-1;
	hd=Fcntl(hdi, (long)&var, TIOCOBAUD);
	if(hd >= 0)
	{
		ltoa(var, nl, 10);
		strcat(nl, " Ausgabespeed");
		term_out(nl);
	}	
	else
	{
		ltoa(hd, nl, 10);
		strcat(nl, " Fehler Ausgabespeed");
		term_out(nl);
	}	

	var=0;
	hd=Fcntl(hdi, (long)&var, TIOCGFLAGS);
	if(hd >= 0)
	{
		var>>=16;
		if(var & TF_1STOP)
			term_out("1 Stopbit");
		else if(var & TF_15STOP)
			term_out("1.5 Stopbit");
		else if(var & TF_2STOP)
			term_out("2 Stopbit");
			
		if(!(var & TF_CHARBITS))
			term_out("8 Bit pro Zeichen");
		else if(var & TF_7BIT)
			term_out("7 Bit pro Zeichen");
		else if(var & TF_6BIT)
			term_out("6 Bit pro Zeichen");
		else if(var & TF_5BIT)
			term_out("5 Bit pro Zeichen");
		
		if(var & T_TANDEM)
			term_out("XON/XOFF aktiv");
		if(var & T_RTSCTS)
			term_out("RTS/CTS aktiv");
			
		if(var & T_EVENP)
			term_out("Gerade Parit„t");
		else if(var & T_ODDP)
			term_out("Ungerade Parit„t");
		else
			term_out("Keine Parit„t");
	}	
	else
	{
		ltoa(hd, nl, 10);
		strcat(nl, " Fehler Flags erfragen");
		term_out(nl);
	}	
	
	return(hdi);
}

void term_out(char *text)
{
	strcpy(line[cy++],text);
	if(win.open)
	{
		w_txchange(&win);
		w_txgoto(&win, 0, cy-1);
	}
}

void quit(WINDOW *win)
{
	ok=0;
	w_close(win);
}

