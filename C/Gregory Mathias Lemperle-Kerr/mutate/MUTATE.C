#include <aes.h>
#include <linea.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <ext.h>
#include <ctype.h>
#include <string.h>
#include <mydefs.h>
#include "mutate.h"

char *pbase;
long ramtop;
long rambot;
int	changed;
int cdrive;
int coffst;

#define MODEM 0
#define MODEF 1
#define MODED 2

struct
	{
	unt	bps;	/* bytes per sector		*/
	unt	spc;	/* sectors per cluster	*/
	unt	bpc;	/* bytes per cluster	*/
	unt	res;	/* 						*/
	unt	fat;	/* number of fats		*/
	unt	dir;	/* # of dir entries		*/
	unt	sec;	/* # of sectors / disk	*/
	unt	spf;	/* # of sectors / fat	*/
	unt	spt;	/* # of sectors / track	*/
	unt	sid;	/* # of sides			*/
	unt	hid;	/* # of hidden			*/
	unt	bpe;	/* bytes per fat entry	*/
	unt	cpf;	/* clusters per fat		*/
	unt cps;	/* clusters per system	*/
	unt cpd;	/* clusters per direct.	*/
	unt sps;	/* sectors per system	*/
	unt spd;	/* sectors per direct.	*/
	unt bad;	/* bad clusters on disk	*/
	unt dcl;	/* data clusters on disk*/
	unt clu;	/* total clusters/disk	*/
	} boot;

/***********
	blink cursor at x,y
***********/
long cblink(int x, int y, int a)
	{
	long cx,cy;
	register int	i;
	
	if (!a)
		cx=(long)x+13+(coffst==0)*(x/4);
	else
		cx=(long)x/2+53;
	cy=(long)y*16+108-coffst;
	while(!Cconis())
		{
		for(i=0;i<16;i++)
			*(pbase+cx+((cy+i)*80))^=0xff;
		if (!Cconis())
			delay(100);
		for(i=0;i<16;i++)
			*(pbase+cx+((cy+i)*80))^=0xff;
		if (!Cconis())
			delay(100);
		}
	return(Crawcin());
	}

/***********
	print at x,y
***********/
void printxy(int x, int y, int a, uch c)
	{
	long cx,cy;
	register int i;

	Bconout(2,27);
	Bconout(2,'H');
	Bconout(2,(int)c);
	if (!a)
		cx=(long)x+13+(x/4);
	else
		cx=(long)x/2+53;
	cy=(long)y*16+108;
	for(i=0;i<16;i++)
		{
		*(pbase+cx+((cy+i)*80))=*(pbase+i*80);
		*(pbase+i*80)=0;
		}
	}

/***********
	Get a long hex input
***********/
long getlong(int x, int y, long old, int box, int item)
	{
	int c;
	long k,l;
	int p,done;
	
	l=0;
	p=0;
	done=0;
	while(p<7&&!done)
		{
		sprintf(rs_object[rs_trloc[box]+item].ob_spec.free_string,"%lx",l);
		dial_draw(box,item);
		k=cblink(x+p,y,0);
		c=(int)k;
		if ((c==0)||(k==0xE0008L))
			{
			if (((k==0x4d0000L)||(k==0xE0008L))&&(p>0))
				{
				p-=1;
				l=l>>4;
				}
			else
				done=1;
			}
		else if ((done=(c==13))==0)
			{
			if (islower(c)) c=toupper(c);
			if ((c<'0')||(c>'F')||((c>'9')&&(c<'A')))
				printf("\007");
			else
				{
				if (c>'9')
					c=c-55;
				else
					c=c-48;
				l=((l<<4)|c);
				++p;
				}
			}
		}
	if (c==13)
		return(l);
	else
		return(old);
	}

/***********
	Supervisor Peek
***********/
long speekl;
long speekv;
void speek(void)
	{
	speekv=*(long *)speekl;
	}

/***********
	Supervisor Poke
***********/
void spoke(void)
	{
	*(long *)speekl=speekv;
	}

/***********
	Peek a long word
***********/
long peek(long loc)
	{
	if ((loc<ramtop)&&(loc>rambot))
		return(*(long *)loc);
	else
		{
		speekl=loc;
		Supexec(speek);
		return(speekv);
		}
	}

/**********
	Poke a long word
**********/
void poke(long loc, long val)
	{
	if ((loc<ramtop)&&(loc>rambot))
		*(long *)loc=val;
	else
		{
		speekl=loc;
		speekv=val;
		Supexec(spoke);
		}
	}

/***********
	Getfile
***********/
int getfile(uch **buf, long *size)
	{
	int		c,fd;
	long	l;
	static	char *f="FILENAME.EXT";
	static	char *p="A:\\*.*\0                                                 ";
	char	q[128];
	uch		*b;
	
	*p='A'+(char)Dgetdrv();
	fsel_exinput(p,f,&c,"Choose a file to MUTATE!");
	if (c)
		{
		Dsetdrv((int)*p-65);
		strcpy(q,p+2);
		strcpy(strrchr(q,'\\')+1,f);
		if (Fsfirst(q,0)>=0)
			{
			Fgetdta();
			fd=Fopen(q,READ);
			l=filelength(fd);
			if ((b=malloc(l))!=NULL)
				{
				if (*buf!=NULL)
					free(*buf);
				*buf=b;
				strcpy(rs_object[rs_trloc[MAIN]+MAINFNAM].ob_spec.free_string,f);
				dial_draw(MAIN,MAINFNAM);
				Fread(fd,l,*buf);
				*size=l;
				Fclose(fd);
				return(1);
				}
			else
				{
				Fclose(fd);
				return(0);
				}	
			}
		else	
			return(0);
		}
	else
		return(0);
	}


/***********
	Putfile
***********/
int putfile(uch *buf, long size)
	{
	int		c,fd;
	static	char *f="FILENAME.EXT";
	static	char *p="A:\\*.*\0                                                 ";
	char	q[128];
	
	*p='A'+(char)Dgetdrv();
	fsel_exinput(p,f,&c,"Choose a file to save the MUTATION!");
	if (c)
		{
		Dsetdrv((int)*p-65);
		strcpy(q,p+2);
		strcpy(strrchr(q,'\\')+1,f);
		fd=1;
		if (Fsfirst(q,0)>=0)
			{
			Fgetdta();
			fd=mess2("Do you wish to","overwrite?","NO","YES",1);
			}
		if (fd)
			{
			Fdelete(f);
			fd=Fcreate(f,0);
			Fclose(fd);
			fd=Fopen(q,WRITE);
			Fwrite(fd,size,buf);
			Fclose(fd);
			return(1);
			}
		else
			return(putfile(buf,size));
		}
	else
		return(0);
	}

/****************************
	Check in disk & set info
****************************/
void dmapdriv(int drive)
	{
	long 	e;
	unt		*buf;

	buf = (unt *)malloc(0x2000);
	Dsetdrv(drive);
	if (Mediach(drive))
		Getbpb(drive);
	if ((e=Rwabs(READ+2,buf,1,0,drive))!=0)
		{
		mess("Boot read error!");
		messl(e);
		}
	else
		{
		boot.bps = (buf[5]&0x00ff)+(buf[6]&0xff00);
		boot.spc = (buf[6]&0x00ff);
		boot.res = ((buf[7]&0x00ff)<<8)+((buf[7]&0xff00)>>8);
		boot.fat = (buf[8]&0xff00)>>8;
		boot.dir = (buf[8]&0x00ff)+(buf[9]&0xff00);
		boot.sec = (buf[9]&0x00ff)+(buf[10]&0xff00);
		boot.spf = ((buf[11]&0x00ff)<<8)+((buf[11]&0xff00)>>8);
		boot.spt = ((buf[12]&0x00ff)<<8)+((buf[12]&0xff00)>>8);
		boot.sid = ((buf[13]&0x00ff)<<8)+((buf[13]&0xff00)>>8);
		boot.hid = ((buf[14]&0x00ff)<<8)+((buf[14]&0xff00)>>8);
		boot.bpc = (boot.bps * boot.spc);
		boot.spd = (boot.dir / (boot.bps/0x20) * (boot.bps/0x200));
		boot.cpd =((boot.spd +1)/ boot.spc);
		boot.cpf = (boot.spf / boot.spc) * boot.fat * (boot.bps/0x200);
		boot.cps = (boot.cpf + boot.cpd);
		boot.sps =((boot.spf * boot.fat) + boot.spd);
		boot.dcl =((boot.sec-boot.sps)/boot.spc);
		boot.clu = (boot.dcl + boot.cps);
		boot.bpe = 4;
		if (drive < 2) boot.bpe = 3;
		}
	free(buf);
	}

/***********
	Check for Update
***********/
void putbuf(int mode, uch *buf, long boff, long bufsize)
	{ 
	long l,m;
	
	if (changed)
		{
		changed=0;
		if (mess2("Do you wish to","make changes permanent","NO","YES",0))
			{
			switch(mode)
				{
				case MODEM:
					for(l=0L;(l<bufsize)&&(l+boff<ramtop);l+=4)
						poke(l+boff,*((long *)(buf+l)));
					break;
				case MODEF:
					putfile(buf,bufsize);
					break;
				case MODED:
					dmapdriv(cdrive);
					l=bufsize/boot.bps;
					m=boff/boot.bps;
					if (Rwabs(WRITE+2,buf,(int)l,(int)m,cdrive)<0)
						mess("CAREFUL! Write Error");
					break;
				}
			}
		}
	}

/***********
	Fill the buffer with data
***********/
void fillbuf(int mode, uch *buf, long boff, long bufsize)
	{
	long	l,m;

	putbuf(mode,buf,boff,bufsize);
	switch (mode)
		{
		case MODEM:
			for(l=0L;l<bufsize;l+=4)
				*((long *)(buf+l))=peek(l+boff);
			break;
		case MODEF:
			break;
		case MODED:
			dmapdriv(cdrive);
			l=bufsize/boot.bps;
			m=boff/boot.bps;
			if (Rwabs(READ+2,buf,(int)l,(int)m,cdrive)<0)
				mess("CAREFUL! Read Error");
			break;
		}
	}

/***********
	Update the window
***********/
void update(long offset, long boff, long bufsize, uch *buf)
	{
	int		i,j;
	long	m;
	long	l;
	uch		c;
	char	s[5];
	
	for(i=0,l=0L;(l<0xa0L)&&(l<bufsize-offset);l+=0x10,i++)
		{
		sprintf(rs_object[rs_trloc[MAIN]+MAINSTR0+i].ob_spec.tedinfo->te_ptext,
			"%6lx",l+offset);
		*(rs_object[rs_trloc[MAIN]+MAINSTR0+i].ob_spec.tedinfo->te_ptext+6)=':';
		for(m=0;(m<16)&&(l+m<bufsize-offset);m++)
			{
			c=*(buf+l+m);
			sprintf(s,"%4x",(unt)c);
			if (*(s+2)==' ')
				*(s+2)='0';
			if (c==0)
				c=0x2e;
			*(rs_object[rs_trloc[MAIN]+MAINSTR0+i].ob_spec.tedinfo->te_ptext+m+47)=c;
			for(j=0;j<2;j++)
				*(rs_object[rs_trloc[MAIN]+MAINSTR0+i].ob_spec.tedinfo->te_ptext+j+m*2+m/2+7)=s[j+2];
			}
		}
	sprintf(rs_object[rs_trloc[MAIN]+MAINOFFS].ob_spec.free_string,"%7lx",boff);
	dial_draw(MAIN,MAINWIND);
	dial_draw(MAIN,MAINOFFS);
	}

/***********
	Edit entries
***********/
void edit(uch *buf, long offset, long boff, long bs, int line)
	{
	uch c,d;
	int	p;
	int alpha;
	long	l;
	char	s[5];
	int		valid,j;

	c=0;
	p=0;
	alpha=0;
	while(c!=13)
		{
		l=cblink(p,line,alpha);
		c=(int)l;
		if (c==9)
			alpha=1-alpha;
		else if (c==0)
			{
			if (l==0x500000L)
				++line;
			else if (l==0x480000L)
				--line;
			else if (l==0x4b0000L)
				p-=1+alpha;
			else if (l==0x4d0000L)
				p+=1+alpha;
			}
		else if (c!=13)
			{
			valid=0;
			if (alpha)
				valid=1;
			else
				{
				if (islower(c)) c=toupper(c);
				if ((c<'0')||(c>'F')||((c>'9')&&(c<'A')))
					printf("\007");
				else
					{
					valid=1;
					if (c>'9')
						c=c-55;
					else
						c=c-48;
					d=*(buf+p/2+line*16);
					if (p%2==0)
						c=(c<<4)|(d&0xf);
					else
						c=(d&0xf0)|c;
					}
				}
			if (valid)
				{
				changed=1;
				*(buf+p/2+line*16)=c;
				sprintf(s,"%4x",(unt)c);
				if (s[2]==' ')
					s[2]='0';
				if (c==0)
					c=0x2e;
				*(rs_object[rs_trloc[MAIN]+MAINSTR0+line].ob_spec.tedinfo->te_ptext+p/2+47)=c;
				printxy(p,line,1,c);
				for(j=0;j<2;j++)
					*(rs_object[rs_trloc[MAIN]+MAINSTR0+line].ob_spec.tedinfo->te_ptext+2*(p/2)+p/4+7+j)=s[j+2];
				printxy((p/2)*2,line,0,s[2]);
				printxy((p/2)*2+1,line,0,s[3]);
				if (!alpha)
					c=0;
				p+=alpha+1;
				}
			}
		if (p<0)
			{
			p=31;
			--line;
			}
		if (p>31)
			{
			p=0;
			++line;
			}
		if (line>9)
			line=0;
		if (line<0)
			line=9;
		if (offset+line*16+p/2>=bs)
			{
			p=0;
			line=0;
			}
		}
	update(offset, boff, bs, buf);
	}

/***********
	Get ramtop
***********/
void Ramtop(void)
	{
	rambot=*(long *)0x4faL;
	ramtop=*(long *)0x42eL;
	}

/***********
	Update drive
***********/
void drvupd(void)
	{
	Dsetdrv(cdrive);
	rs_object[rs_trloc[MAIN]+MAINDRIV].ob_spec.obspec.character=cdrive+'A';
	dial_draw(MAIN,MAINDRIV);
	}

/*******************************
	Get next valid drive given
	current in (drv) and
	direction (-1,1) in dir
********************************/
void gvaldrv(int *drv, int dir)
	{
	long	map;
	int		dv;
	
	dv = *drv;
	map = Drvmap();
	do	{
		*drv += dir;
		if (*drv<0)
			*drv = 15;
		if (*drv > 15)
			*drv = 0;
		if (map & (0x1L << *drv))
			break;
		}	while (*drv  != dv);
	}

/***********
	Do Info
***********/
void doinfo(void)
	{
	int x,y,w,h;
	draw_dialog(INFODIAL,&x,&y,&w,&h,1);
	exit_dialog(INFODIAL,x,y,w,h,0);
	erase_dialog(x,y,w,h);
	}

/***********
	Do the dialog
***********/
void dodial(void)
	{
	uch *buf;
	int	x,y,w,h,c;
	long noff,offset,boff,bufsize,limit;
	int mode,omode;

	pbase=(char *)Physbase();
	Supexec(Ramtop);
	draw_dialog(MAIN,&x,&y,&w,&h,1);
	mode=MODEM;
	omode=MODEF;
	buf=malloc(0x2000L);
	limit=ramtop;
	offset=0L;
	boff=0L;
	bufsize=0x2000L;
	fillbuf(mode,buf,boff,bufsize);
	update(offset,boff,bufsize,buf+offset);
	drvupd();
	for(;;)
		{
		if (mode != omode)
			{
			omode=mode;
			putbuf(mode,buf,boff,bufsize);
			unselect(MAIN,MAINDISK);
			unselect(MAIN,MAINFILE);
			unselect(MAIN,MAINMEMO);
			switch (mode)
				{
				case MODEM:
					select(MAIN,MAINMEMO);
					break;
				case MODED:
					select(MAIN,MAINDISK);
					break;
				case MODEF:
					select(MAIN,MAINFILE);
					break;
				}
			dial_draw(MAIN,MAINMEMO);
			dial_draw(MAIN,MAINDISK);
			dial_draw(MAIN,MAINFILE);
			}
		c=exit_dialog(MAIN,x,y,w,h,0);
		if(c==MAINQUIT)
			{
			putbuf(mode,buf,boff,bufsize);
			break;
			}
		switch (c)
			{
			case MAININFO:
				erase_dialog(x,y,w,h);
				doinfo();
				draw_dialog(MAIN,&x,&y,&w,&h,1);
				break;
			case MAINBBAR:
				break;
			case MAINBAR:
				break;
			case MAINNEXT:
				switch (mode)
					{
					case MODEM:
						putbuf(mode,buf,boff,bufsize);
						boff+=bufsize;
						if (boff>ramtop)
							boff=ramtop-0x90L;
						fillbuf(mode,buf,boff,bufsize);
						update(offset,boff,bufsize,buf+offset);
						break;
					case MODED:
						break;
					case MODEF:
						break;
					}
				break;
			case MAINPREV:
				switch (mode)
					{
					case MODEM:
						putbuf(mode,buf,boff,bufsize);
						boff-=bufsize;
						if (boff<0L)
							boff=0L;
						fillbuf(mode,buf,boff,bufsize);
						update(offset,boff,bufsize,buf+offset);
						break;
					case MODED:
						break;
					case MODEF:
						break;
					}
				break;
			case MAINDLES:
				gvaldrv(&cdrive,-1);
				drvupd();
				break;
			case MAINDRIV:
				if (mode==MODED)
					{
					}
				break;
			case MAINDMOR:
				gvaldrv(&cdrive,1);
				drvupd();
				break;
			case MAINFIND:
				break;
			case MAINUPDT:
				putbuf(mode,buf,boff,bufsize);
				break;
			case MAINMEMO:
				omode=mode;
				mode=MODEM;
				putbuf(omode,buf,boff,bufsize);
				free(buf);
				buf=malloc(0x2000);
				bufsize=0x2000L;
				limit=ramtop;
				boff=0L;
				offset=0L;
				fillbuf(mode,buf,boff,bufsize);
				update(offset,boff,bufsize,buf+offset);
				break;
			case MAINDISK:
				omode=mode;
				mode=MODED;
				putbuf(omode,buf,boff,bufsize);
				free(buf);
				buf=malloc(0x2000);
				bufsize=0x2000L;
				offset=0L;
				boff=0L;
				fillbuf(mode,buf,boff,bufsize);
				limit=(long)boot.bps*boot.sec;
				update(offset,boff,bufsize,buf+offset);
				break;
			case MAINNFNM:
				if (mode!=MODEF)
					break;
			case MAINFILE:
				omode=mode;
				mode=MODEF;
				putbuf(omode,buf,boff,bufsize);
				if (getfile(&buf,&bufsize))
					{
					boff=0L;
					offset=0L;
					limit=bufsize;
					update(offset,boff,bufsize,buf+offset);
					}
				else
					mode=omode;
				break;
			case MAINQUIT:
				break;
			case MAINSTR0:
			case MAINSTR1:
			case MAINSTR2:
			case MAINSTR3:
			case MAINSTR4:
			case MAINSTR5:
			case MAINSTR6:
			case MAINSTR7:
			case MAINSTR8:
			case MAINSTR9:
				graf_mouse(ARROW,0);
				graf_mouse(M_OFF,0);
				edit(buf+offset,offset,boff,bufsize,c-MAINSTR0);
				graf_mouse(M_ON,0);
				graf_mouse(POINT_HAND,0);
				break;
			case MAINUP:
				if (offset>0L)
					{
					offset-=0x80L;
					if (offset<0L)
						offset=0L;
					update(offset,boff,bufsize,buf+offset);
					}
				break;
			case MAINDOWN:
				if (offset<bufsize)
					{
					offset+=0x80L;
					if (offset>(bufsize-0x90L))
						offset=(bufsize-0x90L)&0xfffffff7eL;
					update(offset,boff,bufsize,buf+offset);
					}
				break;
			case MAINNOFF:
				coffst=9;
				noff=getlong(7,12,offset,MAIN,MAINOFFS);
				coffst=0;
				if (((noff>bufsize+boff)||(noff<boff))&&(noff<limit))
					{
					putbuf(mode,buf,boff,bufsize);
					boff=(noff/bufsize)*bufsize;
					fillbuf(mode,buf,boff,bufsize);
					}
				offset=(noff%bufsize)&0xfffffffeL;
				update(offset,boff,bufsize,buf+offset);
				if (noff>limit)
					mess("Beyond limit!");
				break;
			}
		}
	erase_dialog(x,y,w,h);
	free(buf);
	}

/*******************************************************************
							MAIN
*******************************************************************/
int main(void)
	{
	appl_init();
	linea_init();
   	fix_objects();
  	doinfo();
   	cdrive=Dgetdrv();
   	coffst=0;
	graf_mouse(POINT_HAND,0);
	rsrc_load("MUTATE.RSC");
	dodial();
	appl_exit();
	return(0);
 	}
