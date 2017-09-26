#include <ec_gem.h>
#include <atarierr.h>

#define RMAGIC 'RI10'

typedef struct
{
	long	magic; 
	long	width;			/* Pixels */
	long	line_width;	/* Pixels, filled to full word */
	long	height;
	int		bits;		/* 1= S/W, 8=Grey, 24=TC */
}RAW_HEAD;

typedef struct
{
	long 	magic1, magic2;
	long	reserved_len;		/* FÅr "Impfer" um Grîûe zu prÅfen */

	/* Wird vom Impfer eingetragen: */
	int		impfed;
	int		width, ww, height;
	char	map[160/8*1500];
}STXT;

void do_run(void);

void main(void)
{
	appl_init();
	do_run();
	appl_exit();
}

void do_run(void)
{
	long fhl, size, app_len;
	char *msc, *stp;
	int fhi, fho;
	RAW_HEAD	rh;
	STXT			*st;
	char			*buf;

	/* Read RAW-Header */
		
	fhl=Fopen("BITMAP.RAW", FO_READ);
	if(fhl < 0)
	{	gemdos_alert("BITMAP.RAW îffnen:", fhl); return;}
	fhi=(int)fhl;
	fhl=Fread(fhi, sizeof(RAW_HEAD), &rh);
	if(fhl < 0)
	{Fclose(fhi); gemdos_alert("Read:", fhl); return;}
	if(rh.magic != RMAGIC)
	{
		Fclose(fhi);
		form_alert(1, "[2][No RAW-Image][Cancel]");
		return;
	}
	if(rh.bits > 1)
	{
		Fclose(fhi);
		form_alert(1, "[2][No S/W-Image][Cancel]");
		return;
	}
	size=rh.height*rh.line_width/8;

	/* Read EMAILER */
	
	fhl=Fopen("EMAILER.APP", FO_READ);
	if(fhl < 0){Fclose(fhi);gemdos_alert("Open EMAILER:",fhl);return;}
	fho=(int)fhl;
	app_len=fhl=Fseek(0, fho, 2);
	Fseek(0, fho, 0);
	if(fhl < 0){Fclose(fho);Fclose(fhi);gemdos_alert("Seek:",fhl);return;}
	buf=malloc(app_len);
	if(buf==NULL){Fclose(fho);Fclose(fhi);gemdos_alert("Malloc",ENSMEM);return;}
	fhl=Fread(fho, app_len, buf);
	Fclose(fho);
	if(fhl < 0){Fclose(fhi);free(buf);gemdos_alert("Read Mailer:", fhl);return;}
	
	/* Find Magic */
	
	msc=buf;
	stp=buf+app_len; st=NULL;
	while(msc < stp)
	{
		if(*((long*)msc)=='scll')
		{
			st=(STXT*)msc;
			if(st->magic2=='4352') break;
			st=NULL;
		}
		msc+=2;
	}
	if(st==NULL){Fclose(fhi);free(buf);form_alert(1, "[2][Magic not found][Cancel]");return;}
	if(st->reserved_len < size)
	{
		show(1);
		Cconws("Is: ");
		showlxy(4, 1, st->reserved_len);
		showlxy(0,2,size);
		Fclose(fhi);
		form_alert(1, "[2][More reserve][Cancel]"); free(buf); return;
	}
	st->impfed=1;
	st->width=(int)(rh.width);
	st->ww=(int)(rh.line_width/16);
	st->height=(int)(rh.height);
	fhl=Fread(fhi, size, st->map);
	Fclose(fhi);
	if(fhl < 0){free(buf);gemdos_alert("Reading RAW:",fhl);return;}
	fhl=Fcreate("EMAILER.APP",0);
	if(fhl < 0){free(buf);gemdos_alert("Create MAILER:",fhl);return;}
	fho=(int)fhl;
	fhl=Fwrite(fho, app_len, buf);
	Fclose(fho);
	free(buf);
	if(fhl < 0) gemdos_alert("Write Mailer:",fhl);
	else form_alert(1, "[1][Done][OK]");
}