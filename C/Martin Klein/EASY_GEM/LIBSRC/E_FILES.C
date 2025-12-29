#include <tos.h>
#include <aes.h>
#include <string.h>

void sget(char *buffer);
void sput(char *buffer);

extern int _sbytes,_shoehe;

int fileselect(char *name,char *ext,char *title)
{
   int ret;
   static char pfad[128],fnam[14];
   char *punkt,*fs_buff;
   
   pfad[0]=(char)Dgetdrv()+'A';
   pfad[1]=':'; 
   Dgetpath(&pfad[2],0);
   strcat(pfad,"\\*.");
   strcat(pfad,ext);
   fs_buff=Malloc((long)_sbytes*_shoehe);
   sget(fs_buff);
   if(Sversion()>=0x1500)
      fsel_exinput(pfad,fnam,&ret,title);
   else
      fsel_input(pfad,fnam,&ret);
   
   sput(fs_buff);
   Mfree(fs_buff);
   Dsetdrv((int)(pfad[0]-'A'));
   punkt=strrchr(pfad,(int)'\\');
   *punkt='\0';
   Dsetpath(&pfad[2]);
   strcpy(name,pfad);
   strcat(name,"\\");
   strcat(name,fnam);
   
   return ret; 
}

char _fname[120];

int file_in(char *pfad,char *title,int save)
{
	int ret;
	static char fnam[14];
	char *punkt,*fs_buff;
	
	if(save)
	{
		fs_buff=Malloc((long)_sbytes*_shoehe);
		sget(fs_buff);
	}
	if(Sversion()>=0x1500)
		fsel_exinput(pfad,fnam,&ret,title);
	else
		fsel_input(pfad,fnam,&ret);
	
	if(save)
	{
		sput(fs_buff);
		Mfree(fs_buff);
	}
	
	strcpy(_fname,pfad);
	punkt=strrchr(_fname,'\\');
	*(punkt+1)=0;
	strcat(_fname,fnam);
	
	return ret;	
}


long Lof(char *filename)
{
	DTA *d;
	
	d=Fgetdta();
	if(Fsfirst(filename,0) != 0)
		return 0;
		
	return d->d_length;	
}
