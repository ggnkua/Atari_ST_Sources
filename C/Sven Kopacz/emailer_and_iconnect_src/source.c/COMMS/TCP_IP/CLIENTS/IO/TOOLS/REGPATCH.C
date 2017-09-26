#include <ec_gem.h>
#include <atarierr.h>

char	*reg_magic="rMa*paTB*R#-";	/* followed by 'n' or anything else */

void do_run(void);

int	f_input(char *spruch, char *path, char *name)
{
	/* ôffnet Fileselector und schreibt den Zugriffspfad
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

void main(void)
{
	appl_init();
	do_run();
	appl_exit();
}

void do_run(void)
{
	char path[256], name[64];
	long fhl, app_len, reg_len=strlen(reg_magic);
	char *msc, *stp, *mag;
	int fhi, fho;
	char	*buf, new_val;

	/* Read Program */
	strcpy(path, "x:\\");
	/* Mal wird der Pfad mit, mal ohne fÅhrenden '\' geliefert */
	Dgetpath(&(path[3]), 0);
	if(path[3]=='\\') Dgetpath(&(path[2]), 0);
	path[0]=(char)Dgetdrv()+'A';
	if(path[strlen(path)-1]!='\\') strcat(path, "\\");
	strcat(path, "*.*");
	name[0]=0;
	if(f_input("Programmdatei auswÑhlen", path, name)==0) return;
	
	fhl=Fopen(path, FO_READ);
	if(fhl < 0){gemdos_alert("ERR Open file:",fhl);return;}
	fhi=(int)fhl;
	app_len=fhl=Fseek(0, fhi, 2);
	Fseek(0, fhi, 0);
	if(fhl < 0){Fclose(fhi);gemdos_alert("ERR Seek:",fhl);return;}
	buf=malloc(app_len);
	if(buf==NULL){Fclose(fhi);gemdos_alert("ERR Malloc",ENSMEM);return;}
	fhl=Fread(fhi, app_len, buf);
	Fclose(fhi);
	if(fhl < 0){free(buf);gemdos_alert("ERR Read file:", fhl);return;}
	
	/* Find Magic */
	msc=buf;
	stp=buf+app_len; mag=NULL;
	while(msc < stp)
	{
		if(!strncmp(msc, reg_magic, reg_len)) {mag=msc; break;}
		msc+=2;
	}
	if(mag==NULL){free(buf);form_alert(1, "[2][Kein Koppenhorst-Produkt][Cancel]");return;}
	mag+=reg_len;
	if(*mag=='n')
	{
		if(form_alert(1,"[2][Programm ist NICHT serialisierbar|(funktioniert also immer)][éndern|Abbruch]")==2)
		{ free(buf); return;}
		new_val='y';
	}
	else
	{
		if(form_alert(1,"[2][Programm ist serialisierbar|(muû also registriert werden)][éndern|Abbruch]")==2)
		{ free(buf); return;}
		new_val='n';
	}

	*mag=new_val;	
	fhl=Fcreate(path,0);
	if(fhl < 0){free(buf);gemdos_alert("Create Patched file:",fhl);return;}
	fho=(int)fhl;
	fhl=Fwrite(fho, app_len, buf);
	Fclose(fho);
	free(buf);
	if(fhl < 0) gemdos_alert("Write file:",fhl);
	else 
	{
		if(new_val=='n')
			form_alert(1,"[1][Programm jetzt NICHT MEHR serialisierbar|(funktioniert also immer)][OK]");
		else
			form_alert(1,"[1][Programm ist jetzt serialisierbar|(muû also registriert werden)][OK]");
	}
}