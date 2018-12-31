#include	<aes.h>
#include    <stdio.h>
#include	<stdlib.h>
#include	<ext.h>
#include    <tos.h>
#include	<ctype.h>
#include	<string.h>
#include	<mydefs.h>
#include	"sam.h"
#include	"gemext.h"

unt				buf[512];
char			bootflag;
volatile int	crmess;
long			olderrh;

static char	*mapcode = "~.B-";

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

#define TESTREDO 0
#define TESTPASS 1

char *chks[] = {
	"ONE",
	"PAS",
	};

int chkscnt = 2;

/*********************************
	Count bits in an unt
*********************************/
int	countbit(unt u)
	{
	int	c,i;
	
	c = u&0x0001;
	for(i=1;i<16;i++)
		c += ((u>>i)&0x0001);
	return(c);
	}

/*********************************
	If quitproc, return 0,else 1
*********************************/
int	quitproc(void)
	{
	int i;

	if (kbhit())
		{
		while (kbhit())
			getch();
		i = mess2("Quit procedure","now?","Yes","No",0);
		if (i==1)
			graf_mouse(HOURGLASS,0);
		return(i);
		}
	else
		return(1);
	}

/*********************************
	Return requested drive from
	dialog... A = 0, B = 1...
*********************************/
int getcdrv(
	int dial,
	int	item
	)
	{
	return(rs_object[rs_trloc[dial]+item].ob_spec.obspec.character-65);
	}

/*********************************
	Set requested drive in
	dialog... A = 0, B = 1...
*********************************/
void setcdrv(
	int	drive,
	int	dial,
	int	item
	)
	{
	rs_object[rs_trloc[dial]+item].ob_spec.obspec.character = drive + 65;
	dial_draw(dial,item);
	}

/*******************************
	Get next valid drive given
	current in (drv) and
	direction (-1,1) in dir
********************************/
void gvaldrv(
	int	*drv,
	int	dir	)
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

/****************************
	Redraw cluster count
****************************/
void dcldraw(unt c)
	{
	sprintf(rs_object[rs_trloc[DMAPDIAL]+DMAPCRNT].ob_spec.tedinfo->te_ptext,
		"%7d",c);
	dial_draw(DMAPDIAL,DMAPCRNT);
	}

/****************************
	Show info in dialog
****************************/
void dmapdraw(void)
	{
	sprintf(rs_object[rs_trloc[DMAPDIAL]+DMAPFATS].ob_spec.tedinfo->te_ptext,
			"%2d *%3d",boot.fat,boot.spf);
	sprintf(rs_object[rs_trloc[DMAPDIAL]+DMAPBPEN].ob_spec.tedinfo->te_ptext,
			"%7d",boot.bpe);
	sprintf(rs_object[rs_trloc[DMAPDIAL]+DMAPBADC].ob_spec.tedinfo->te_ptext,
			"%7d",boot.bad);
	sprintf(rs_object[rs_trloc[DMAPDIAL]+DMAPTOTC].ob_spec.tedinfo->te_ptext,
			"%7d",boot.clu);
	sprintf(rs_object[rs_trloc[DMAPDIAL]+DMAPDIRL].ob_spec.tedinfo->te_ptext,
			"%7d",boot.dir);
	sprintf(rs_object[rs_trloc[DMAPDIAL]+DMAPBPCL].ob_spec.tedinfo->te_ptext,
			"%7d",boot.bps * boot.spc);
	sprintf(rs_object[rs_trloc[DMAPDIAL]+DMAPSPTR].ob_spec.tedinfo->te_ptext,
			"%7d",boot.spt);
	sprintf(rs_object[rs_trloc[DMAPDIAL]+DMAPSDTR].ob_spec.tedinfo->te_ptext,
			"%2d/%4d",boot.sid,boot.sec/boot.spt);
	dial2_draw(DMAPDIAL,DMAPTOTC,DMAPSDTR);
	}

/****************************
	Return reversed word
****************************/
int	hiloswap(int i)
	{
	return(((i&0xff00)>>8)|((i&0x00ff)<<8));
	}

/****************************
	Write FATs
****************************/
void fatwrite(
	int	drive,
	unt	*fat)
	{
	int i;

	crmess = 0;
	for(i=0;i<boot.fat;i++)
		Rwabs(WRITE+2,fat,boot.spf,i*boot.spf+1,drive);
	if (crmess != 0)
		mess("Error writing FATs");
	}

/****************************
	Set fat entry
****************************/
void setfaten(
	unt	*fat,
	unt	pos,	/* First data cluster = 0 */
	unt	val)
	{
	unt	*b1,*b2,*b3,*b4;
	unt	offset;

	offset = boot.spf*boot.bps/2;
	if (boot.bpe == 4)
		*(fat+pos+offset) = (*(fat+pos+2) = hiloswap(val) );
	else
		{
		b3 = (b1 = (fat+((pos*3)/4)+1)) + offset;
		b4 = (b2 = (fat+((pos*3)/4)+2)) + offset;
		switch (pos % 4)
			{
			case 2:
				*b4=(*b2=(((*b2&0x00f0)+((val&0x00ff)<<8))+((val&0x0f00)>>8)));
				break;
			case 3:
				*b3=(*b1=((*b1&0xff0f)+((val&0x000f)<<4)));
				*b4=(*b2=((*b2&0x00ff)+((val&0x0ff0)<<4)));
				break;
			case 0:
				*b3=(*b1=((*b1&0xff00)+(val&0x00ff)));
				*b4=(*b2=((*b2&0xf0ff)+(val&0x0f00)));
				break;
			case 1:
				*b4=(*b2=(((*b2&0x0f00)+((val&0x000f)<<12))+((val&0x0ff0)>>4)));
				break;
			}
		}
	}

/****************************
	Return fat entry for dc
****************************/
unt	fatentry(
	unt	*fat,
	unt	pos)	/* first data cluster = 0 */
	{
	unt	e;
	unt	b1,b2;
	if (boot.bpe == 4)
		e = hiloswap(*(fat+pos+2));
	else
		{
		b1 = *(fat+((pos*3)/4)+1);
		b2 = *(fat+((pos*3)/4)+2);
		switch (pos % 4)
			{
			case 2:
				e = (((b2&0xff00)>>8) + ((b2&0x000f)<<8));
				break;
			case 3:
				e = (((b1&0x00f0)>>4) + ((b2&0xff00)>>4));
				break;
			case 0:
				e = ((b1&0x00ff) + (b2&0x0f00));
				break;
			case 1:
				e = (((b2&0xf000)>>12) + ((b2&0x00ff)<<4));
				break;
			}
		}
	return(e);
	}

/****************************
	Return code for fat entry
		0 = System
		1 = Used
		2 = Free
		3 = Bad Cluster
		4 = Beyond total
****************************/
int	dmapfatc(
	unt		*fat,
	unt		pos)
	{
	unt	e;

#define FATCUSED 0
#define FATCFREE 1
#define FATCBADC 2
#define FATCGONE 3

	if (pos > boot.dcl)
		return(FATCGONE);
	else
		{
		e = fatentry(fat,pos);
		if (e == 0x0000)
			return(FATCFREE);
		else if (((e==0xDBA)&&(boot.bpe==3))||((e == 0xDCBA)&&(boot.bpe==4)))
			return(FATCBADC);
		else
			return(FATCUSED);
		}
	}

/*****************************
	Set fat entry to bad
*****************************/
void enterbad(
	unt	*fat,
	unt	clus)
	{
	if (boot.bpe == 3)
		setfaten(fat,clus,0xdba);
	else
		setfaten(fat,clus,0xdcba);
	}

/****************************
	Set & draw map entries
****************************/
void dmapsmap(
	unt		offset,
	unt		*fat)
	{
	unt	i,j;
	unt	p;
	
	for(i=0;i<6;i++)
		{
		sprintf(rs_object[rs_trloc[DMAPDIAL]+DMAPROW0+i].ob_spec.tedinfo->te_ptext,
				"%7d >",offset+i*28);
		for(j=0;j<28;j++)
			{
			p = i*28+offset+j;
			sprintf(rs_object[rs_trloc[DMAPDIAL]+DMAPROW0+i].ob_spec.tedinfo->te_ptext+j*2+9,
				" %c",*(mapcode+dmapfatc(fat,p)));
			}
		}
	dial2_draw(DMAPDIAL,DMAPROW0,DMAPROW5);
	}

/****************************
	Count bad clusters
****************************/
void badcount(unt *fat)
	{
	unt	cnt;
	
	boot.bad = 0;
	for(cnt=0;cnt<boot.dcl;cnt++)
		if (dmapfatc(fat,cnt)==FATCBADC)
			++boot.bad;
	}

/****************************
	Check fat contingency
****************************/
void fatsanal(void *fat)
	{
	long	*b;
	unt		cnt;
	unt		test;
	uch		flag = 0;
	
	b = fat;
	test = boot.bps*boot.spf/4;
	if (boot.fat)
		for(cnt=0;cnt<test;cnt++)
			if (*(b+cnt)!=*(b+cnt+test))
				flag = 1;
	if (flag)
		mess("Fat Discrepancy!");
	}

/****************************
	Check in disk & set info
****************************/
void dmapdriv(
	int		drive,
	unt		**fat)
	{
	long 	e;
	long	fmem;
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
		boot.spd = (boot.dir * 32 / boot.bps);
		boot.cpd = (boot.spd / boot.spc);
		boot.cpf = (boot.spf / boot.spc) * boot.fat;
		boot.cps = (boot.cpf + ((boot.spd+1)/boot.spc));
		boot.sps =((boot.spf * boot.fat) + boot.spd);
		boot.dcl =((boot.sec/boot.spc)-boot.cps);
		boot.clu = (boot.dcl + boot.cps);
		boot.bpe = 4;
		if (drive < 2)
			boot.bpe = 3;
		fmem = (((long)boot.spf) * boot.bps * boot.fat);
		if (*fat != NULL)
			free(*fat);
		if ((*fat = malloc(fmem)) == NULL)
			mess("No memory for FATs!");
		else
			if (Rwabs(READ+2,*fat,boot.spf*boot.fat,1,drive) != 0)
				mess("FAT read error!");
			else
				{
				fatsanal(*fat);
				badcount(*fat);
				}
		}
	}

/****************************
	Do disk map dialog
****************************/
void maindmap(void)
	{
	int			x,y,w,h,s;
	int			drv;
	unt			*fat;
	static unt	cluster = 0;

	fat = NULL;

	draw_dialog(DMAPDIAL,&x,&y,&w,&h,SHOW);
	dcldraw(cluster);

	drv = getcdrv(DMAPDIAL,DMAPDRIV);
	while ((s = exit_dialog(DMAPDIAL,x,y,w,h,HIDE)) != DMAPQUIT)
		switch (s)
			{
			case DMAPDRIV:
				cluster = 0;
				dcldraw(cluster);
				dmapdriv(drv,&fat);
				dmapdraw();
				dmapsmap(0,fat);
				break;
			case DMAPDPRV:
				gvaldrv(&drv,PREV);
				setcdrv(drv,DMAPDIAL,DMAPDRIV);
				break;
			case DMAPDNXT:
				gvaldrv(&drv,NEXT);
				setcdrv(drv,DMAPDIAL,DMAPDRIV);
				break;
			case DMAPTPRV:
				if (cluster != 0)
					{
					cluster -= 168;
					dcldraw(cluster);
					dmapsmap(cluster,fat);
					}
				break;
			case DMAPTNXT:
				if ((cluster+168) < boot.dcl)
					{
					cluster += 168;
					dcldraw(cluster);
					dmapsmap(cluster,fat);
					}
				break;
			}
	if (fat != NULL)
		free(fat);
	erase_dialog(x,y,w,h);
	}

/****************************
	Critical Error Handler
****************************/
long criterr(int err, int drive)
	{
	crmess = (drive * 0x100) + err + 1;;
	return(0L);
	}

/****************************
	Replace Error Handler
****************************/
void replerr(void)
	{
	olderrh = *(long *)0x404L;
	*(long *)0x404L = (long)criterr;
	}

/****************************
	Restore Error Handler
****************************/
void resterr(void)
	{
	*(long *)0x404L = olderrh;
	}

/****************************
	Set Critical Mine
****************************/
void setcrit(void)
	{
	Supexec(replerr);
	}

/****************************
	Set Critcal Theirs
****************************/
void fixcrit(void)
	{
	Supexec(resterr);
	}

/****************************
	Clear all fats
****************************/
void analclrb(int drive)
	{
	int	i;
	unt	u;
	unt	*fat;
	uln	*empty;
	static char	*d = "or clear all? (A:)";
	
	fat = NULL;
	*(d+15) = 65+drive;
	dmapdriv(drive,&fat);
	if (mess2("Clear only bad",d,"BAD","ALL",0))
		{
		if (mess2("LAST CHANCE","I hope you've backed up!","CANCEL","OK",0))
			{
			empty = malloc(((long)boot.sps)*boot.bps);
			if (empty == NULL)
				mess("Not enough memory!");
			else
				{
				for(i=0;i<(boot.bps/4);i++)
					*(empty+i)=0;
				for(i=1;i<=boot.sps;i++)
					if (Rwabs(WRITE+2,empty,1,i,drive)!=0)
						mess("SYSTEM WRITE ERROR!");
				free(empty);
				}
			}
		bootflag = 1;
		}
	else
		{
		boot.bad = 0;
		for(u=0;u<boot.dcl;u++)
			if (dmapfatc(fat,u)==FATCBADC)
				setfaten(fat,u,0);
		fatwrite(drive,fat);
		}
	if (fat != NULL)
		free(fat);
	}

/****************************
	Draw sense
****************************/
void analsdrw(int sens)
	{
	sprintf(rs_object[rs_trloc[ANALDIAL]+ANALSENS].ob_spec.free_string,
		"%2d",sens);
	dial_draw(ANALDIAL,ANALSENS);
	}

/****************************
	Disable sense count
****************************/
void analsdis(int sens)
	{
	rs_object[rs_trloc[ANALDIAL]+ANALSENS].ob_state |= DISABLED;
	analsdrw(sens);
	}

/****************************
	Disable sense count
****************************/
void analsena(int sens)
	{
	rs_object[rs_trloc[ANALDIAL]+ANALSENS].ob_state &= ENABLED;
	analsdrw(sens);
	}

/****************************
	Draw type of analysis
****************************/
void analadrw(
	int chk,
	int sens)
	{
	strcpy(rs_object[rs_trloc[ANALDIAL]+ANALTEST].ob_spec.free_string,chks[chk]);
	dial_draw(ANALDIAL,ANALTEST);
	if (chk == TESTPASS)
		analsena(sens);
	else
		analsdis(sens);
	}

/****************************
	Draw error status
****************************/
void analedrw(char *stat)
	{
	strcpy(rs_object[rs_trloc[ANALDIAL]+ANALSTAT].ob_spec.free_string,stat);
	dial_draw(ANALDIAL,ANALSTAT);
	}

/****************************
	Draw cluster count
****************************/
void analcdrw(unt clus)
	{
	sprintf(rs_object[rs_trloc[ANALDIAL]+ANALCLUS].ob_spec.free_string,
		"%7d",clus);
	dial_draw(ANALDIAL,ANALCLUS);
	}

/*********************************
	Draw Read/Write
*********************************/
void analrdrw(char mode)
	{
	*rs_object[rs_trloc[ANALDIAL]+ANALRDWR].ob_spec.free_string = mode;
	dial_draw(ANALDIAL,ANALRDWR);
	}

/****************************
	Draw total data clusters
****************************/
void analtdrw(void)
	{
	sprintf(rs_object[rs_trloc[ANALDIAL]+ANALTOTC].ob_spec.free_string,
		"%7d",boot.dcl);
	dial_draw(ANALDIAL,ANALTOTC);
	}

/****************************
	Draw bad cluster count
****************************/
void analbdrw(void)
	{
	sprintf(rs_object[rs_trloc[ANALDIAL]+ANALBADC].ob_spec.free_string,
		"%7d",boot.bad);
	dial_draw(ANALDIAL,ANALBADC);
	}

/****************************
	Compare blocks of ULN's
****************************/
int	blkcomp(
	uln	*b1,
	uln	*b2,
	unt	cnt)
	{
	unt u;

	for(u=0;u<cnt;u++)
		if (*(b1+u)!=*(b2+u))
			return(1);
	return(0);
	}

/****************************
	Find cluster for sector
****************************/
unt	stoclus(unt sec)
	{
	return((sec-boot.sps-1)/boot.spc+boot.cps);
	}

/****************************
	Analyze 1 data cluster
****************************/
void testclus(
	unt clus,
	unt	*fat,
	uln	*hold,
	uln	*rbuf,
	uln	*wbuf,
	int	drive)
	{
	int	s;

	analcdrw(clus);
	if (dmapfatc(fat,clus)!=FATCBADC)
		{
		s = boot.sps + (clus*boot.spc);
		crmess=0;
		analrdrw('R');
		Rwabs(READ+2,hold,boot.spc,s,drive);
		if (crmess!=0)
			analedrw("Read Error!");
		else
			{
			analrdrw('W');
			Rwabs(WRITE+2,wbuf,boot.spc,s,drive);
			analrdrw('R');
			Rwabs(READ+2,rbuf,boot.spc,s,drive);
			analrdrw('W');
			Rwabs(WRITE+2,hold,boot.spc,s,drive);
			if (crmess!=0)
				analedrw("Write Error");
			else
				{
				analrdrw('A');
				if ((crmess = blkcomp(rbuf,wbuf,boot.spc/4*boot.bps))!=0)
					analedrw("Anal. Error");
				}
			}
		if (crmess!=0)
			{
			++boot.bad;
			enterbad(fat,clus);
			analbdrw();
			}
		}
	}

/****************************
	Analyze 16 data clusters
****************************/
void test16cl(
	unt start,
	unt orbits,
	unt	*orfats,
	uln	*hold,
	uln	*rbuf,
	uln	*wbuf,
	int	drive,
	unt	pass,
	int	sens)
	{
	unt	u;
	unt	s;
	unt	c;
	static char *err = "E(R) - P#00";

	analcdrw(start);
	crmess=0;
	s = boot.sps + (start*boot.spc);
	c = 16 * boot.spc;
	if ((s+c)>=boot.sec)
		c = boot.sec - s - 1;
	analrdrw('R');
	Rwabs(READ+2,hold,c,s,drive);
	if (crmess!=0)
		{
		analedrw("Read Error!");
		*(err+2)='R';
		}
	else
		{
		analrdrw('W');
		Rwabs(WRITE+2,wbuf,c,s,drive);
		analrdrw('R');
		Rwabs(READ+2,rbuf,c,s,drive);
		analrdrw('W');
		Rwabs(WRITE+2,hold,c,s,drive);
		if (crmess!=0)
			{
			analedrw("Write Error");
			*(err+2) = 'W';
			}
		else
			{
			analrdrw('A');
			if ((crmess = blkcomp(rbuf,wbuf,c/4*boot.bps))!=0)
				{
				analedrw("Anal. Error");
				*(err+2)='A';
				}
			}
		}
	if (crmess!=0)
		{
		sprintf(err+9,"%2d",pass);
		analedrw(err);
		for(u=0;u<16;u++)
			*(orfats+u+start)|=orbits;
		boot.bad = 0;
		if (pass>=sens)
			pass=sens-1;
		for(u=0;u<boot.dcl;u++)
			if (((unt)countbit(*(orfats+u)))>pass)
				++boot.bad;
		analbdrw();
		}
	}

/****************************
	Analyze drive x times
****************************/
void analanal(
	int	drive,
	int	test,
	int	sens)
	{
	unt		u,p;
	unt		*fats;
	uln		*hold;
	uln		*rbuf;
	uln		*wbuf;
	int		a;
	long	bufsiz;
	unt		orbits = 0x1;
	unt		*orfats = NULL;
	char	*pass = "Pass No. 00";

	fats = NULL;
	dmapdriv(drive,&fats);
	analbdrw();
	analtdrw();
	bufsiz = ((long)boot.sps)*boot.bps;
	if (bufsiz < (0x10L*boot.spc*boot.bps))
		bufsiz = 0x10L*boot.spc*boot.bps;
	if (test==TESTPASS)
		{
		orfats = malloc(boot.dcl*0x2L+0x20L);
		if (orfats != NULL)
			for(u=0;u<boot.dcl;u++)
				if (dmapfatc(fats,u)!=FATCBADC)
					*(orfats+u) = 0;
				else
					*(orfats+u) = 0xffff;
		}
	hold = malloc(bufsiz);
	rbuf = malloc(bufsiz);
	wbuf = malloc(bufsiz);
	if ((wbuf==NULL)||(rbuf==NULL)||(hold==NULL))
		{
		if (rbuf != NULL)
			free(rbuf);
		if (hold != NULL)
			free(hold);
		if (orfats != NULL)
			free(orfats);
		mess("Not enought memory!");
		}
	else
		if (mess2("MAY DESTROY FILES...","ARE YOU SURE?","NO","YES",0))
			{
			for(a=0;a<(bufsiz/4);a++)
				*(wbuf+a) = 0x5e5e5e5eL;
			mess("Any key to abort...");
			graf_mouse(HOURGLASS,0);
			crmess = 0;
			analedrw("FATs & DIR.");
			for (a=0;(a<16)&&(crmess==0);a++)
				{
				analrdrw('R');
				Rwabs(READ+2,hold,boot.sps,1,drive);
				analrdrw('W');
				if (crmess==0)
					Rwabs(WRITE+2,hold,boot.sps,1,drive);
				}
			if (crmess!=0)
				{
				mess("Errors on System sectors!");
				mess("Recommend repartitioning!");
				mess("Aborting analysis...");
				}
			else
				{
				analedrw("DATA CLUST.");
				if (test == TESTREDO)
					for(u=0;(u<boot.dcl)&&((a=quitproc())==1);u++)
						testclus(u,fats,hold,rbuf,wbuf,drive);
				if (test == TESTPASS)
					{
					for(p=0,a=1;(a==1)&&(p<16);p++)
						{
						sprintf(pass+9,"%2d",p);
						analedrw(pass);
						for(u=p;(u<boot.dcl)&&((a=quitproc())==1);u+=16)
							{
							if ((u>0)&&(u<16))
								test16cl(0,orbits,orfats,hold,rbuf,wbuf,drive,p,sens);
							test16cl(u,orbits,orfats,hold,rbuf,wbuf,drive,p,sens);
							}
						orbits = (orbits<<1);
						}
					for(u=0;u<boot.dcl;u++)
						if (countbit(*(orfats+u))>=sens)
							enterbad(fats,u);
					}
				if (a==0)
					a = mess2("Write what has","been done so far?","No","Yes",1);
				if (a==1)
					{
					fatwrite(drive,fats);
					mess("Analysis Done!");
					}
				}
			}
	if (orfats != NULL)
		free(orfats);
	if (fats!=NULL)
		free(fats);
	if (hold!=NULL)
		free(hold);
	if (rbuf!=NULL)
		free(rbuf);
	if (wbuf!=NULL)
		free(wbuf);
	}

/****************************
	Do analyze dialog
****************************/
void mainanal(void)
	{
	int			x,y,w,h,s;
	int			drv;
	static int	test=0;
	static int	sens=16;

	draw_dialog(ANALDIAL,&x,&y,&w,&h,SHOW);
	analadrw(test,sens);
	
	drv = getcdrv(ANALDIAL,ANALDISK);
	while ((s = exit_dialog(ANALDIAL,x,y,w,h,HIDE)) != ANALQUIT)
		switch (s)
			{
			case SENSLESS:
				if (sens > 1)
					--sens;
				analsdrw(sens);
				break;
			case SENSMORE:
				if (sens < 16)
					++sens;
				analsdrw(sens);
				break;
			case ANALLESS:
				if (test > 0)
					--test;
				analadrw(test,sens);
				break;
			case ANALMORE:
				if (test < (chkscnt-1))
					++test;
				analadrw(test,sens);
				break;
			case ANALANAL:
				analanal(drv,test,sens);
				break;
			case ANALDPRV:
				gvaldrv(&drv,PREV);
				setcdrv(drv,ANALDIAL,ANALDISK);
				break;
			case ANALDNXT:
				gvaldrv(&drv,NEXT);
				setcdrv(drv,ANALDIAL,ANALDISK);
				break;
			case ANALCLRB:
				if (mess2("MAY ERASE ALL FILES","ARE YOU SURE?","NO WAY!","DO IT!",0))
					{
					analclrb(drv);
					mess("Done!");
					}
				break;
			}
	erase_dialog(x,y,w,h);
	}

/****************************
	Do partition dialog
****************************/
void mainpart(void)
	{
	int	x,y,w,h,s;
		
	draw_dialog(PARTDIAL,&x,&y,&w,&h,SHOW);
	while ((s = exit_dialog(PARTDIAL,x,y,w,h,HIDE)) != PARTQUIT)
		switch (s)
			{
			case PARTPTUP:
				break;
			case PARTPTDN:
				break;
			case PARTDELE:		
				break;
			case PARTINST:
				break;
			case PARTTOTL:
				break;
			case PARTLEFT:
				break;
			case PARTROW0:
				break;
			case PARTROW1:
				break;
			case PARTROW2:
				break;
			case PARTROW3:
				break;
			case PARTROW4:
				break;
			case PARTROW5:
				break;
			case PARTWRIT:
				break;
			case PARTUPRV:
				break;
			case PARTUNXT:
				break;
			case PARTUNIT:
				break;
			};
	erase_dialog(x,y,w,h);
	}

/****************************
	Do info dialog
****************************/
void maininfo(void)
	{
	int	x,y,w,h,a,b,c,d;
		
	draw_dialog(INFODIAL,&x,&y,&w,&h,SHOW);
	exit_dialog(INFODIAL,x,y,w,h,HIDE);
	draw_dialog(SHARDIAL,&a,&b,&c,&d,SHOW);
	exit_dialog(SHARDIAL,a,b,c,d,HIDE);
	erase_dialog(a,y,c,h);
	}

/*******************************************************************
							MAIN
*******************************************************************/
int main()
	{
	int			msg_buf[8];
	/*      INITIALIZE GEM              */
	appl_init();
   	fix_objects();
	bootflag = 0;
	/*      APPLICATION ROUTINES        */
	graf_mouse(POINT_HAND,0);
	maininfo();
	setcrit();
	menu_bar(rs_trindex[MAINMENU],SHOW);
	for (;;)
		{
		evnt_mesag(msg_buf);
		if (msg_buf[0] != MN_SELECTED)	continue;
		if (msg_buf[4] == MAINQUIT)		break;
		
		switch (msg_buf[4])
			{
			case MAININFO:
				maininfo();
				break;
			case MAINANAL:
				mainanal();
				break;
			case MAINDMAP:
				maindmap();
				break;
			case MAINPART:
				mainpart();
			default:
				break;
			}
			menu_tnormal(rs_trindex[MAINMENU],msg_buf[3],TRUE);
		}
	fixcrit();
	if (bootflag)
		mess("Should Reset Computer");
    menu_bar(rs_trindex[MAINMENU],HIDE);
	appl_exit();
	return(0);
 	}
