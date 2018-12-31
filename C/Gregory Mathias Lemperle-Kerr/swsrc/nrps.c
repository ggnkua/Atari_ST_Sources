#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mydefs.h>

char buf[1024];
char ppath[128],dpath[128],ppat2[128];
char files[128][14];
long fleng[128],l;

static char *pext  = "\\*.PI3";
static char *dfile = "\\NEOPIC_C.PI3";

long getline(
	char	*dest,
	char	*buf,
	long	start,
	long	max)
	{
	long p,q;
	
	q = 0L;
	p = start;
	while((p<max)&&(*(buf+p)<0x20))
		++p;
	while((p<max)&&(*(buf+p)>0x1f))
		{
		*(dest+q)=*(buf+p);
		++p;
		++q;
		}
	*(dest+q) = 0;
	return(p);
	}

void main(void)
	{
	int fd;
	DTA *d;
	unt u;
	uln	r;
	char *loc;
	static char *backs="\\";

	puts("NRPS V3.0 - with Turbo C 2.0");
	puts("NeoDesk Random Picture Selector");
	puts("BY Gregory Mathias Lemperle-Kerr");

	if (Fsfirst("NRPS.INF",0)>=0)
		{
		d=Fgetdta();
		l=d->d_length;
		puts("Using NRPS.INF for paths...");
		fd=Fopen("NRPS.INF",1);
		Fread(fd,l,buf);
		Fclose(fd);
		getline(dpath,buf,getline(ppath,buf,0,l),l);
		}
	else
		{
		strcpy(ppath,"E:\\CLIPART");
		strcpy(dpath,"C:\\NEODESK");
		}
	*(pext+5)=(*(dfile+12)='1'+Getrez());
	if (Getrez()==2)
		*(dfile+8)='M';
	strcpy(ppat2,ppath);
	strcat(ppath,pext);
	strcat(dpath,dfile);
	strcat(ppat2,backs);
	puts(ppath);
	puts(dpath);
	u = 0;
	if ((fd=Fsfirst(ppath,0))>=0) while (fd>=0)
		{
		d=Fgetdta();
		strncpy(files[u],d->d_fname,14);
		fleng[u]=d->d_length;
		fd = Fsnext();
		++u;
		}
	else
		{
		puts("NO PICTURES FOUND!\007");
		return;
		}
	r=(Random()+Gettime())%u;
	puts(files[r]);
	puts("Copying...");
	if(Fsfirst(dpath,0)<0)
		{
		fd=Fcreate(dpath,0);
		Fclose(fd);
		}
	loc = (char *)Physbase()-34;
	strcat(ppat2,files[r]);
	fd=Fopen(ppat2,READ);
	Fread(fd,fleng[r],loc);
	Fclose(fd);
	fd=Fopen(dpath,WRITE);
	Fwrite(fd,fleng[r],loc);
	Fclose(fd);
	}
