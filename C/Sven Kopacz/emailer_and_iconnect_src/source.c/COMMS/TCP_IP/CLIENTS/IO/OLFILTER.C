#include <ec_gem.h>

#include "ioglobal.h"
#include "io.h"

#include "online.h"

extern int	ord_om, ord_pm;

void filter_move(char *path, long ix)
{
	char dst[256], *suffix;
	long a=0;
	
	if(fld_inf.flds==NULL) return;
	while(a < fld_inf.flds_c)
	{
		if(!strcmp(fil_inf.addr[ix].fname, fld_inf.flds[a].from))
			goto _fld_found;
		++a;
	}
	return;

_fld_found:
	strcpy(dst, db_path);
	strcat(dst, "\\OM\\");
	if(strstr(path, dst)) ++ord_om;
	else ++ord_pm;

	suffix=&(path[strlen(path)]);
	while(*suffix!='.')--suffix;
	strcpy(dst, db_path);
	strcat(dst, "\\ORD\\");
	strcat(dst, fld_inf.flds[a].fspec.fname);
	strcat(dst, "\\");
	strcat(dst, get_free_file(dst));
	strcat(dst, suffix);
	Frename(0, path, dst);
}

struct tm	*a_to_time(char *s){/*	Rec. formats:
		Date: Don, 25 Jun 98 21:42:09 +0200
		Date: Fri, 26 May 1998 03:55:08 GMT
		Date: Thu, 16 Apr 1998 09:37:50 +0200 (MET DST)
		Date: 11 Dec 1997 19:01:56 GMT
		Date: Tue, 12 May 98 17:57:35 +0200
*/
	static struct	tm	time;	char	*monthtab[12]={"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};	char	*n;
	if(s==NULL) return(NULL);
	
	/* Ignore day's name */
	if((n=strchr(s, ','))!=NULL)
	{
		if(n-s < 7) s=n+1;
		while(*s==' ')++s;
	}
	
	/* Now we should have the weekday */
	time.tm_mday=atoi(s);
	
	while(*s && (*s!=' ')) ++s;
	while(*s==' ')++s;
	if(!*s) return(NULL);
	
	/* Month's name */
	time.tm_mon=0;
	while((time.tm_mon < 12) && (strnicmp(monthtab[time.tm_mon], s, 3)))
		++time.tm_mon;

	if(time.tm_mon==12) return(NULL);
	while(*s && (*s!=' ')) ++s;
	while(*s==' ')++s;
	if(!*s) return(NULL);

	/* Year */
	time.tm_year=atoi(s);
	if((time.tm_year==0) && (*s!='0')) return(NULL);
	if(time.tm_year < 80) time.tm_year+=2000;
	else if(time.tm_year < 100) time.tm_year+=1900;

	while(*s && (*s!=' ')) ++s;
	while(*s==' ')++s;
	if(!*s) return(NULL);

	/* Time */
	time.tm_hour=atoi(s);
	if(s[1]!=':') ++s;
	if(s[1]!=':') return(NULL);
	s+=2;
	time.tm_min=atoi(s);
	if(s[1]!=':') ++s;
	if(s[1]!=':') return(NULL);
	s+=2;
	time.tm_sec=atoi(s);
	
	if(time.tm_hour > 24) return(NULL);
	if(time.tm_min > 59) return(NULL);
	if(time.tm_sec > 59) return(NULL);

	return(&time);
}
void	set_file_time(int dest_file, struct tm		*ftime)
{
	struct 
	{
		hour: 5;
		min	:6;
		sec	:5;
		
		year : 7;
		mon : 4;
		day : 5;
	}my_time;
	
	DOSTIME			dtime;

	if(ftime==NULL) return;
	
	my_time.sec=ftime->tm_sec/2;
	my_time.min=ftime->tm_min;
	my_time.hour=ftime->tm_hour;
	
	my_time.day=ftime->tm_mday;
	my_time.mon=ftime->tm_mon+1;
	my_time.year=ftime->tm_year-1980;
	
	*(long*)&dtime=*(long*)&my_time;
	Fdatime(&dtime, dest_file, 1);
}

char *hstrstr(char *src, char *srch)
{
	long fnd=0, b=strlen(srch);
	
	while(*src)
	{
		if(*src==srch[fnd])++fnd;
		else fnd=0;
		if(fnd==b) return(src-b+1);
		++src;
	}
	return(NULL);
}

void dat_and_snd_rename(char *path, char *file)
{/* Dateidatum auf Eintrag in "Date:"-Feld setzen
		Falls eigene OM, Datei in *.SND umbenennen. <path> wird dann
		entsprechend Åberschrieben.
		<file>=In Speicher geladene Datei */
	char	*f, *x, *c, *d, *suffix, mem, fmem, renpath[256];
	long	fhl;
	struct tm *tmp;
	
	Flog("Looking for Head-end...");
	f=hstrstr(file, "\r\n\r\n");
	if(f==NULL) f=hstrstr(file, "\r\n\n");
	if(f==NULL) f=hstrstr(file, "\n\n");
	if(f==NULL) f=hstrstr(file, "\r\r");
	if(f==NULL) {Flog("not found\r\n");return;}
	fmem=*f; *f=0;	

	c=stristr(file, "Date:");
	if(c)
	{
		Flog("ok.\r\nDate found-");
		c+=5;
		d=c; while(*d && (*d!=13)&&(*d!=10))++d;
		mem=*d; *d=0;
		while(*c && (*c==' '))++c;
		if(*c)
		{
			tmp=a_to_time(c);
			if(tmp)
			{
				fhl=Fopen(path, FO_READ);
				if(fhl >= 0)
				{
					Flog("set timestamp\r\n");
					set_file_time((int)fhl, tmp);
					Fclose((int)fhl);
				}
				else {Flog("can\'t set timestamp. ("); Flog(path); Flog(")\r\n");}
			}
			else {Flog("bad date-format\r\n");}
		}
		else Flog("empty field.\r\n");
		*d=mem;
	}
	else
		Flog("Date not found.\r\n");
		
	suffix=&(path[strlen(path)]);
	while(*suffix!='.')--suffix;
	if(!strcmp(suffix, ".NEW"))	
	{
		Flog("Received message. ");
		c=stristr(file, "From:");
	}
	else 
	{
		c=NULL;
		Flog("Sent message. ");
	}
	/* Filetype nur Ñndern, wenn nicht im PMs empfangen,
	   dann ist es Nachricht an mich selbst */
	if(c && (!strstr(path, "\\DATABASE\\PM\\")))
	{
		Flog("From found, own OM check\r\n");
		d=c; while(*d && (*d!=13)&&(*d!=10))++d;
		mem=*d; *d=0;
		x=strstr(c, minf.email);
		*d=mem;
		if(x)
		{
			*suffix=0;
			strcpy(renpath, path);
			*suffix='.';
			strcat(renpath, ".SNT");
			Frename(0, path, renpath);
			strcpy(path, renpath);
		}
	}
	else Flog("no OM-check.\r\n");		
	*f=fmem;
}

void filter(char *path, char *file)
{
	long a=0;
	char	*f, *c, *d, mem;

	Flog("Looking for Head-end...");
	f=hstrstr(file, "\r\n\r\n");
	if(f==NULL) f=hstrstr(file, "\r\n\n");
	if(f==NULL) f=hstrstr(file, "\n\n");
	if(f==NULL) f=hstrstr(file, "\r\r");
	if(f==NULL) {Flog("not found.\r\n");return;}
	*f=0;	
	Flog("found.\r\n");
	while(a < fil_inf.addr_c)
	{
		Flog("Scanning filters: ");
		if(fil_inf.addr[a].action==2)
		{
			Flog("X ");
			switch(fil_inf.addr[a].field)
			{
				case 1:	f="From:"; break;
				case 2: f="To:"; break;
				case 3: f="Subject:"; break;
			}
			Flog("<");Flog(f);Flog(">");
			c=stristr(file, f);
			if(c)
			{
				Flog(" found, "); Flog(fil_inf.addr[a].is); Flog(":");
				d=c; while(*d && (*d!=13)&&(*d!=10))++d;
				mem=*d; *d=0;
				f=stristr(c, fil_inf.addr[a].is);
				*d=mem;
				if(f)
				{	
					Flog(" filtered.\r\n");
					filter_move(path, a); 
					return;
				}
				else Flog(" no match ");
			}
			else Flog(" not found. ");
		}
		else Flog("(X) ");
		++a;
	}
	Flog("\r\n");
}

void run_filters(int fh, ulong num)
{/* Selbst versendete OMs umbenennen und Filter-Konfigurationen
		anwenden. fh=Datei in der alle empfangenen Nachrichten
		mit komplettem Pfad und einzelner 0-Terminierung eingetragen
		sind. <num>=Anzahl der EintrÑge */
		
	long	len, fhl;
	int		sfh;
	char *buf, *c, *mem, tnum[30];
	
	len=Fseek(0, fh, 2);
	Fseek(0, fh, 0);
	buf=malloc(len);
	if(buf==NULL){form_alert(1, gettext(NOFILTMEM)); return;}
	Fread(fh, len, buf);
	c=buf;
			
	while(num--)
	{
		fhl=Fopen(c, FO_READ);
		if(fhl >= 0)
		{
			Flog("\r\nFile opened\r\n");
			sfh=(int)fhl;
			len=Fseek(0, sfh, 2);
			Fseek(0, sfh, 0);
			mem=malloc(len+1);
			if(mem)
			{
				Flog("Scanning file ("); ltoa(len, tnum, 10); Flog(tnum); Flog(" Bytes)\r\n");
				Fread(sfh, len, mem);
				Fclose(sfh);
				mem[len]=0;
				dat_and_snd_rename(c, mem);
				filter(c, mem);
				free(mem);
			}
			else {Fclose(sfh); Flog("Not enough memory.\r\n");}
		}
		else
			Flog("Can\'t open file.\r\n");
		c+=strlen(c)+1;
	}
	free(buf);
}

int	sort_filter(void)
{/* Check, ob ein Filter fÅr nach-downloaden konfiguriert ist.
		return: 1=Ja, 0=Nein */
	long a=0;
	
	while(a < fil_inf.addr_c)
	{
		if(fil_inf.addr[a].action==2) return(1);
		++a;
	}
	return(0);
}

int	stop_download_filter(void)
{/* Check, ob ein Filter fÅr nicht-downloaden konfiguriert ist.
		return: 1=Ja, 0=Nein */
	long a=0;
	
	while(a < fil_inf.addr_c)
	{
		if(fil_inf.addr[a].action==1) return(1);
		++a;
	}
	return(0);
}

int check_grp_download_filter(int fh, long len)
{/* PrÅfen, ob Header in Datei <fh> (LÑnge <len>) auf einen
		nicht-download-Filter paût */
	char *mem;
	int	dum;
	
	mem=malloc(len+1);
	if(mem==NULL) return(0);
	Fseek(0, fh, 0);
	Fread(fh, len, mem);
	Fseek(0, fh, 2);
	mem[len]=0;
	dum=check_download_filter(mem, &dum);
	free(mem);
	return(dum);
}

int check_download_filter(char *head, int *del)
{/* PrÅfen, ob <head> auf einen nicht-download-Filter paût.
		Return: 1=ja, 0=nein, *del=Lîschen 0/1 */
	long a=0;
	char	*f, *c, *d, mem;
	
	while(a < fil_inf.addr_c)
	{
		if(fil_inf.addr[a].action==1)
		{
			switch(fil_inf.addr[a].field)
			{
				case 1:	f="From:"; break;
				case 2: f="To:"; break;
				case 3: f="Subject:"; break;
			}
			c=stristr(head, f);
			if(c)
			{
				d=c; while(*d && (*d!=13)&&(*d!=10))++d;
				mem=*d; *d=0;
				f=strstr(c, fil_inf.addr[a].is);
				*d=mem;
				if(f)
				{
					if(fil_inf.addr[a].subact==1)	*del=1;
					else *del=0;
					return(1);
				}
			}
		}
		++a;
	}
	return(0);
}
