#include "SuJi_glo.h"

char *dragdrop(int *msg)
{
	long fd;
	unsigned long type,daten_lang;
	void *oldsig;
	unsigned int lang;
	int fehler=FALSE;
	char ok=0;
	char typen[33]="\0ARGS";
	char pipename[]="U:\\PIPE\\DRAGDROP.AA";

	pipename[18]=msg[7] & 0x00ff;
	pipename[17]=(msg[7] & 0xff00)>>8;

	fd=Fopen(pipename,2);
	if(fd>=0)
	{
		oldsig=Psignal(SIGPIPE,(void *)SIG_IGN);

		do {
				/* D&D-Header lesen */
			if((Fwrite((int) fd,33,typen)==33) &&
				(Fread((int) fd,2,&lang)==2) &&
				(lang>=9) &&
				(Fread((int) fd,4,&type)==4) &&
				(Fread((int) fd,4,&daten_lang)==4))
			{
				char *buf;

				lang-=8;

				buf=(char *)malloc(lang);
				if(buf)
				{
					if(Fread((int) fd,lang,buf)==lang)
					{ /* Infos gelesen */
						/* ignorieren */
					}
					else
					{
						ok=1;
						Fwrite((int) fd,1,&ok);
						fehler=TRUE;
					}
					free(buf);
				}
				else
				{
					ok=3;
					Fwrite((int) fd,1,&ok);
					fehler=TRUE;
				}

				if(!fehler)
				{
					if(type=='ARGS')
					{
						char *buf;

						buf=(char *)malloc(daten_lang);
						if(buf)
						{
							ok=0;
							if((Fwrite((int) fd,1,&ok)==1) &&
								(Fread((int) fd,daten_lang,buf)==daten_lang))
							{	/* Daten gelesen */
								Fclose((int) fd);
								Psignal(SIGPIPE,oldsig);
								return buf;
							}
							else
							{
								ok=1;
								Fwrite((int) fd,1,&ok);
								fehler=TRUE;
							}
							free(buf);
						}
						else
						{
							ok=3;
							Fwrite((int) fd,1,&ok);
							fehler=TRUE;
						}
					}
					else
					{
						ok=1;
						Fwrite((int) fd,1,&ok);
						fehler=TRUE;
					}
				}
			}
			else
			{
				ok=1;
				Fwrite((int) fd,1,&ok);
				fehler=TRUE;
			}
		} while(type!='ARGS' && !fehler);
		Fclose((int) fd);
		Psignal(SIGPIPE,oldsig);
	}

	return NULL;
}
