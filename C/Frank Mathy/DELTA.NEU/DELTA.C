#include "delta.h"
#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>

#define FILE350 358400
#define FILE710 727040
#define MAXFILE bufsize

int contrl[12],intin[128],ptsin[128],intout[128],ptsout[128];
int handle,msg[8];
int work_out[57],work_in[12],wres;
int deskx,desky,deskw,deskh;
int gl_hhbox,gl_hwbox,gl_hhchar,gl_hwchar;
OBJECT *menu,*genform,*playform;
char path[80],name[80];
int normpal[] = { 0x777,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
long picbuf,endbuf,screen,screen2,animbuf,bufsize,scrns[2],maxdisk;
long pause=0;

char *extdlt[3] = { ".DLT","",".DLH" };
char *extpic[3] = { "0000.PI1","","0000.PI3" };
char *multdisk = "[1][Teile Animation in|mehrere Dateien auf.|Diskette fÅr 0. Datei|einlegen...][ OK ]";
char *multload = "[1][ Mehrere zugehîrige Dateien... | Bitte Diskette mit der | 0. Datei einlegen... ][ OK ]";
char *nomem = "[3][ Puffer zu | klein... ][ Abbruch ]";

str_copy(ziel,quelle)
char *ziel,*quelle;
	{
     while(*ziel++ = *quelle++);
	}

int str_len(text)
char *text;
	{	
	int len=0;
	while(*text++) len++;
	return(len);
	}	

str_concat(ziel,quelle)
char *ziel,*quelle;
	{
     while(*ziel++);
     ziel--;
     while(*ziel++ = *quelle++);
	}

name_concat(ziel,quelle)
char *ziel,*quelle;
{
     while(*ziel++);
     ziel--;
     while((*(ziel--) != 92) && (*ziel != 0));
     ziel++;
     ziel++;
     while(*ziel++ = *quelle++);
}

open_work()
	{
	int i;
	appl_init();
	handle=graf_handle(&gl_hwchar,&gl_hhchar,&gl_hwbox,&gl_hhbox);
	for(i=0;i<10;work_in[i++]=1);
	work_in[10]=2;
	v_opnvwk(work_in,&handle,work_out);
	}

close_work()
	{
	v_clsvwk(handle);
	appl_exit();
	}


extern long gemdos(),xbios();

long compress(savedata,page1,page2)
long savedata,page1,page2;
	{
	long dataend;
asm			{
			movea.l savedata(A6),A0
			movea.l page1(A6),A1
			movea.l page2(A6),A2
			clr.w	D0
sd_0loop:	move.w	#158,D1
cmp_loop:	move.w	0(A2,D1.W),D2
			cmp.w	0(A1,D1.W),D2
			bne.s	not_equal
			subq.w	#2,D1
			bpl.s	cmp_loop
			bra.s	next_line
not_equal:	move.w	D0,D1
			mulu	#160,D1
			move.w	D1,(A0)+
			movea.l A0,A3
			adda.l	#10,A0
			move.w	#8,D2
sd_1loop:	move.w	#15,D1
			clr.w	D3
sd_2loop:	cmpm.w	(A1)+,(A2)+
			beq.s	equal_word
			bset	D1,D3
			move.w	-2(A2),(A0)+
equal_word:	dbf		D1,sd_2loop
			move.w	D3,0(A3,D2.W)
			subq.w	#2,D2
			bpl.s	sd_1loop
			bra.s	next_2line
next_line:	adda.l	#160,A1
			adda.l	#160,A2
next_2line:	addq.w	#1,D0
			cmp.w	#200,D0
			blt.s	sd_0loop
			move.w	#0xffff,(A0)+
			move.l	A0,dataend(A6)
			}
	return(dataend);
	}


long transform(data,page)
long data,page;
	{
	long dataend;
	asm		{
			movea.l data(A6),A0
			movea.l page(A6),A1
load_delta:	move.w	(A0)+,D3
			bmi.s	ld_end
			move.l	A0,A2
			adda.l	#10,A0
			move.w	#8,D0
ld_1loop:	move.w	0(A2,D0.W),D1
			bne.s	change
			add.l	#32,D3
			bra.s	no_change
change: 	move.w	#15,D2
ld_2loop:	btst	D2,D1
			beq.s	no_write
			move.w	(A0)+,0(A1,D3.W)
no_write:	addq.w	#2,D3
			dbf		D2,ld_2loop
no_change:	subq.w	#2,D0
			bpl.s	ld_1loop
			bra.s	load_delta
ld_end: 	move.l	A0,dataend(A6)
			}
	return(dataend);
	}

int load_degas(name,pallete,page)
char *name;
int *pallete;
long page;
	{
	int handle;
	handle=(int) Fopen(name,0);
	if(handle>=0)
		{
		Fseek(2L,handle,0);
		Fread(handle,32L,pallete);
		Fread(handle,32000L,page);
		Fclose(handle);
		return(0);
		}
	else
		{
		open_error(name);
		return(1);
		}
	}

copy_screen(quelle,ziel)
long *quelle,*ziel;
	{
	long regs[10];
	asm	{
		lea		regs(A6),A0
		movem.l A2-A5/D1-D6,(A0)
		movea.l quelle(A6),A0
		movea.l ziel(A6),A1
		move.w	#799,D0
cpy_lp: movem.l (A0)+,D1-D6/A2-A5
		movem.l D1-D6/A2-A5,(A1)
		adda.l	#40,A1
		dbf		D0,cpy_lp
		lea		regs(A6),A0
		movem.l (A0),A2-A5/D1-D6
		}
	}

char infot[]="[0][ Delta-Animator | (C) 1987 Frank Mathy  | FÅr ST-Magazin (M&T) | ??????? Bytes Puffer ][ OK ]";

information()
	{
	infot[69]=(bufsize/1000000)%10+0x30;
	infot[70]=(bufsize/100000)%10+0x30;
	infot[71]=(bufsize/10000)%10+0x30;
	infot[72]=(bufsize/1000)%10+0x30;
	infot[73]=(bufsize/100)%10+0x30;
	infot[74]=(bufsize/10)%10+0x30;
	infot[75]=bufsize%10+0x30;
	form_alert(1,infot);
	menu_tnormal(menu,msg[3],1);
	}

open_error(name)
char *name;
	{
	char text[120];
	str_copy(text,"[3][ Fehler beim ôffnen | der Datei | >");
	str_concat(text,name);
	str_concat(text,"< ... ][ Abbruch ]");
	form_alert(1,text);
	}

waitdisk(dname)
char *dname;
	{
	char alstr[100];
	str_copy(alstr,"[1][ Bitte Diskette mit der | Datei >");
	str_concat(alstr,dname);
	str_concat(alstr,"< | einlegen... ][ Return ]");
	form_alert(1,alstr);
	}

make_animation(bilder,waitmode,bname,aname)
int bilder,waitmode;
char *bname,*aname;
	{
	long bufptr,nrpos,animsize,help;
	int pallete[16],i,handle,*intptr,rtn,dnr,namepos;
	if(*bname)
	{
	nrpos=str_len(bname)-8;
	bufptr=animbuf;
	intptr=(int *)bufptr;
	*intptr=bilder;
	bufptr+=2;
	if(waitmode) waitdisk(bname);
	if(rtn=load_degas(bname,bufptr,bufptr+32)) return(0);
	Setpallete(bufptr);
	if(rtn=load_degas(bname,pallete,screen)) return(0);
	bufptr+=32032;
	for(i=1;i<bilder;i++)
		{
		bname[nrpos]=(i/1000)%10+0x30;
		bname[nrpos+1]=(i/100)%10+0x30;
		bname[nrpos+2]=(i/10)%10+0x30;
		bname[nrpos+3]=i%10+0x30;
		if(waitmode) waitdisk(bname);
		if(rtn=load_degas(bname,pallete,picbuf)) return(0);
		bufptr=compress(bufptr,screen,picbuf);
		copy_screen(picbuf,screen);
		if(bufptr>animbuf+bufsize)
			{
			menu_ienable(menu,MNPUFF,0);
			menu_ienable(menu,MNSAVE,0);
			form_alert(1,nomem);
			return(0);
			}
		}
	endbuf=bufptr;
	menu_ienable(menu,MNPUFF,1);
	menu_ienable(menu,MNSAVE,1);
	}
	animsize=endbuf-animbuf+1;
	if(animsize>maxdisk)
		{
		help=animsize/maxdisk;
		help= -help;
		help--;
		if(help<-9)
			{
			form_alert(1,"[3][ Nur bis zu | 9 Dateien ][ Abbruch]");
			return(0);
			}
		bufptr=animbuf;
		namepos=str_len(aname)-5;
		while(animsize>maxdisk)
			{
			dnr++;
			multdisk[57]=0x30+dnr;
			form_alert(1,multdisk);
			aname[namepos]=0x30+dnr;
			handle=(int) Fcreate(aname,0);
			if(handle<0)
				{
				open_error(aname);
				return(0);
				}
			if(dnr==1)
				{
				i=(int) help;
				Fwrite(handle,2L,&i);
				Fwrite(handle,4L,&maxdisk);
				}
			Fwrite(handle,maxdisk,bufptr);
			Fclose(handle);
			bufptr+=maxdisk;
			animsize-=maxdisk;
			}
		dnr++;
		multdisk[57]=0x30+dnr;
		form_alert(1,multdisk);
		aname[namepos]=0x30+dnr;
		handle=(int) Fcreate(aname,0);
		if(handle<0)
			{
			open_error(aname);
			return(0);
			}
		Fwrite(handle,animsize,bufptr);
		Fclose(handle);
		}
	else
		{
		form_alert(1,"[1][ Bitte Diskette fÅr | die Aufzeichnung | der Delta-Datei | einlegen... ][ Return ]");
		handle=(int) Fcreate(aname,0);
		if(handle<0)
			{
			open_error(aname);
			return(0);
			}
		Fwrite(handle,animsize,animbuf);
		Fclose(handle);
		}
	}

play_animation(name,pause,load,scnr)
char *name;
long pause;
int load,scnr;
	{
	long tmpptr,wait,i,filelen,bufspace,bufpos;
	int key,handle,*intptr,bilder,akt,files,fnr,namepos;
	akt=0;
	pause*=5000;
	if(load)
		{
		handle=(int) Fopen(name,0);
		if(handle<0)
			{
			open_error(name);
			return(0);
			}
		Fread(handle,2L,&files);
		Fread(handle,4L,&filelen);
		if(files>=0)
			{
			Fseek(0L,handle,0);
			i=Fread(handle,bufsize,animbuf);
			Fclose(handle);
			if(i>=bufsize)
				{
				form_alert(1,nomem);
				return(0);
				}
			else
				{
				endbuf=i+animbuf-1;
				menu_ienable(menu,MNPUFF,1);
				menu_ienable(menu,MNSAVE,1);
				}
			}
		else
			{
			namepos=str_len(name)-5;
			files= -files;
			bufspace=bufsize;
			bufpos=animbuf;
			if(files*filelen>=bufsize)
				{
				form_alert(1,nomem);
				return(0);
				}
			for(fnr=0;fnr<files;fnr++)
				{
				if(fnr)
					{
					multload[62]=0x31+fnr;
					form_alert(1,multload);
					name[namepos]=0x31+fnr;
					Fopen(name,0);
					}
				if(fnr<files-1)
					{
					Fread(handle,filelen,bufpos);
					bufpos+=filelen;
					bufspace-=filelen;
					}
				else
					{
					i=Fread(handle,bufspace,bufpos);
					if(i>=bufspace)
						{
						form_alert(1,nomem);
						return(0);
						}
					endbuf=bufpos+i;
					}
				Fclose(handle);
				}
			}
		}
	intptr=(int *)animbuf;
	bilder=*intptr;
	Setpallete(animbuf+2);
	if(!scnr)
	do
		{
		for(wait=0;wait<pause;wait++);
		xbios(37);
		copy_screen(animbuf+34,screen);
		tmpptr=animbuf+32034;
		for(i=1;i<bilder;i++)
			{
			for(wait=0;wait<pause;wait++);
			xbios(37);
			tmpptr=transform(tmpptr,screen);
			}
		graf_mkstate(&i,&i,&key,&i);
		} while(key!=1);
	else
	{
	Setscreen(scrns[akt^1],scrns[akt],-1);
	do	{
		for(wait=0;wait<pause;wait++);
		xbios(37);
		copy_screen(animbuf+34,scrns[akt^1]);
		tmpptr=animbuf+32034;
		akt^=1;
		Setscreen(scrns[akt^1],scrns[akt],-1);
		for(i=1;i<bilder;i++)
			{
			for(wait=0;wait<pause;wait++);
			xbios(37);
			copy_screen(scrns[akt],scrns[akt^1]);
			tmpptr=transform(tmpptr,scrns[akt^1]);
			akt^=1;
			Setscreen(scrns[akt^1],scrns[akt],-1);
			}
		graf_mkstate(&i,&i,&key,&i);
		} while(key!=1);
	Setscreen(scrns[0],scrns[0],-1);
	}
	}
	

char *find_ed(ob,index)
OBJECT *ob;
int index;
	{
	TEDINFO *ted;
	ob+=index;
	ted=(TEDINFO *) ob->ob_spec;
	return(ted->te_ptext);
	}

int get_state(ob,index)
OBJECT *ob;
int index;
	{
	ob+=index;
	return(ob->ob_state);
	}

do_generate()
	{
	int x,y,w,h,but,bildz,disks,i;
	OBJECT *help;
	char *piczahl,*picname,*dltname;
	char bname[80],aname[80];
	picname=find_ed(genform,PNAME);
	dltname=find_ed(genform,ANAME);
	
	form_center(genform,&x,&y,&w,&h);
	form_dial(FMD_GROW,x+w/2-5,y+h/2-5,10,10,x,y,w,h);
	objc_draw(genform,ROOT,MAX_DEPTH,deskx,desky,deskw,deskh);
	do	{
		but=form_do(genform,BILDZ);
		objc_change(genform,but,0,deskx,desky,deskw,deskh,NORMAL,1);
		bildz=0;
		piczahl=find_ed(genform,BILDZ);
		while(*piczahl) bildz=bildz*10+(*piczahl++)-0x30;
		} while((but==ERSTELL)&&((bildz<2)||(*picname==0)||(*dltname==0)||(*path==0)));
	form_dial(FMD_SHRINK,x+w/2-5,y+h/2-5,10,10,x,y,w,h);
	menu_tnormal(menu,msg[3],1);
	menu_bar(menu,0);
	
	if(but==ERSTELL)
		{
		v_hide_c(handle);
		v_clrwk(handle);
		i=get_state(genform,SDISK);
		if(i&SELECTED) disks=0;
		else disks=1;
		str_copy(bname,picname);
		str_concat(bname,extpic[wres]);
		str_copy(aname,dltname);
		str_concat(aname,extdlt[wres]);
		make_animation(bildz,disks,bname,aname);
		v_show_c(handle,0);
		}
	v_hide_c(handle);
	v_clrwk(handle);
	v_show_c(handle,0);
	menu_bar(menu,1);
	}

do_save()
	{
	char fname[80],*edtext;
	int i;
	i=form_alert(2,"[2][ Animationsdatei | abspeichern...? ][ OK | Abbruch ]");
	if(i==1)
		{
		edtext=find_ed(genform,ANAME);
		str_copy(fname,edtext);
		str_concat(fname,extdlt[wres]);
		make_animation(0,0,"",fname);
		}
	menu_tnormal(menu,msg[3],1);
	}

do_play(load)
int load;
	{
	int x,y,w,h,but,i,j,screens;
	char pname[80],*pwert;
	pwert=find_ed(playform,PAUSEVAL);
	if(load)
		{
		fsel_input(path,name,&but);
		str_copy(pname,path);
		name_concat(pname,name);
		menu_tnormal(menu,msg[3],1);
		menu_bar(menu,0);
		v_hide_c(handle);
		v_clrwk(handle);
		v_show_c(handle,0);
		}
	else menu_tnormal(menu,msg[3],1);
	if((but)||(load==0))
	{
	form_center(playform,&x,&y,&w,&h);
	form_dial(FMD_GROW,x+w/2-5,y+h/2-5,10,10,x,y,w,h);
	objc_draw(playform,ROOT,MAX_DEPTH,deskx,desky,deskw,deskh);
	do
	{
	but=form_do(playform,0);
	if((but==PAUSEDN)&&(pause>0)) pause--;
	if((but==PAUSEUP)&&(pause<99)) pause++;
	if((but==PAUSEDN)||(but==PAUSEUP))
		{
		pwert[0]=((pause/10)%10)+0x30;
		pwert[1]=(pause%10)+0x30;
		pwert[2]=0;
		objc_draw(playform,PAUSEVAL,ROOT,MAX_DEPTH,deskx,desky,deskw,deskh);
		}
	objc_change(playform,but,0,deskx,desky,deskw,deskh,NORMAL,1);
	} while((but==PAUSEDN)||(but==PAUSEUP));
	form_dial(FMD_SHRINK,x+w/2-5,y+h/2-5,10,10,x,y,w,h);
	if(but==PLAY)
		{
		i=get_state(playform,SCR1);
		if(i&SELECTED) screens=0;
		else screens=1;
		v_hide_c(handle);
		v_clrwk(handle);
		play_animation(pname,pause,load,screens);
		v_show_c(handle,0);
		}
 
	v_hide_c(handle);
	v_clrwk(handle);
	v_show_c(handle,0);
	}
	menu_bar(menu,1);
	}
	
main()
	{
	int i;
	int oldres;
	char *help;
	wres=Getrez();
	if(wres)
		str_copy(path,"A:\*.DLH");
	else
		str_copy(path,"A:\*.DLT");
	path[0]+=Dgetdrv();
	name[0]=0;
	open_work();
	wres=Getrez();
	if((wres!=0)&&(wres!=2))
		form_alert(1,"[3][ Der Delta-Animator lÑuft nur | bei 320x200 oder bei 640x400 | Punkten Auflîsung... ][ Abbruch ]");
	else
	{
	i=rsrc_load("delta.rsc");
	if(i>0)
	{
	maxdisk=MAXFILE;
	scrns[0]=screen=Logbase();
	picbuf=Malloc(32256L);
	scrns[1]=screen2=(picbuf+255)&0xffff00;
	bufsize=Malloc(-1L)-5000L;
	animbuf=Malloc(bufsize);
	rsrc_gaddr(R_TREE,MENU,&menu);
	rsrc_gaddr(R_TREE,GENFORM,&genform);
	rsrc_gaddr(R_TREE,PLAYFORM,&playform);
	wind_get(0,WF_CURRXYWH,&deskx,&desky,&deskw,&deskh);
	help=find_ed(genform,PNAME);
	help[0]=0x41+Dgetdrv();
	help[7]=0;
	help=find_ed(genform,ANAME);
	help[0]=0x41+Dgetdrv();
	help[7]=0;
	v_hide_c(handle);
	v_clrwk(handle);
	v_show_c(handle,0);
	menu_bar(menu,1);
	do	{
	do	{
		graf_mouse(POINT_HAND,0L);
		Setpallete(normpal);
		evnt_mesag(msg);
		if(msg[0]==MN_SELECTED)
			{
			switch(msg[4])
				{
				case MNINFO:	information();
								break;
				case MNGEN:		do_generate();
								break;
				case MNPLAY:	do_play(1);
								break;
				case MNSAVE:	do_save();
						break;
				case MNPUFF:	do_play(0);
								break;
				case MNMAX:	maxdisk=MAXFILE;
						menu_tnormal(menu,msg[3],1);
						menu_icheck(menu,MN350,0);
						menu_icheck(menu,MN710,0);
						menu_icheck(menu,MNMAX,1);
						break;
				case MN350:	maxdisk=FILE350;
						menu_tnormal(menu,msg[3],1);
						menu_icheck(menu,MNMAX,0);
						menu_icheck(menu,MN710,0);
						menu_icheck(menu,MN350,1);
						break;
				case MN710:	maxdisk=FILE710;
						menu_tnormal(menu,msg[3],1);
						menu_icheck(menu,MNMAX,0);
						menu_icheck(menu,MN350,0);
						menu_icheck(menu,MN710,1);
						break;
				}
			}
		} while((msg[0]!=MN_SELECTED)||(msg[4]!=MNEND));
	i=form_alert(2,"[2][ Wollen Sie | beenden...? ][ Ja | Nein ]");
	menu_tnormal(menu,msg[3],1);
	} while(i!=1);
	Mfree(animbuf);
	Mfree(picbuf);
	rsrc_free();
	}
	else form_alert(1,"[3][ Ich kann die RSC-Datei | >DELTA.RSC< nicht | finden... ][ Abbruch ]");
	}
	close_work();
	}

