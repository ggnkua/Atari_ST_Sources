#include <tos.h>
#include <aes.h>
#include <stdlib.h>
#include <hsmod.h>


int open_aux(char *path, long baud);

void main(void)
{
	int er;
	char num[10];

	Cconws("Initialisiere Modem1\r\n");	
	er=open_aux("U:\\DEV\\MODEM1", 57600l);
	if(er < 0)
	{
		Cconws("\r\nFehler ");
		Cconws(itoa(er, num, 10));
		return;
	}

	Cconws("Ok\r\n");
}

int open_aux(char *path, long baud)
{
	long hd, var, var2;
	int	 hdi;
	
	hd=Fopen(path, FO_RW);
	if(hd < 0)
		return(-1);

	hdi=(int)hd;	
	
	/* Parameter setzen */
	var=baud;
	hd=Fcntl(hdi, (long)&var, TIOCIBAUD);
	if(hd < 0)
		return(-2);		/* Fehler Eingabespeed*/
	var=baud;
	hd=Fcntl(hdi, (long)&var, TIOCOBAUD);
	if(hd < 0)
		return(-3);	/* Fehler Ausgabespeed */

	var=0;
	hd=Fcntl(hdi, (long)&var, TIOCGFLAGS);
	if(hd < 0)
		return(-4); /* Fehler Flags erfragen */

	var2=TF_STOPBITS|TF_CHARBITS|TF_FLAG;
	var2<<=16;
	var2=~var2;
	var&=var2;
	var2=TF_1STOP|TF_8BIT|T_TANDEM  /*|T_RTSCTS*/;	/* TANDEM=X_ON,X_OFF */
	var2<<=16;
	var|=var2;
	
	hd=Fcntl(hdi, (long)&var, TIOCSFLAGS);
	if(hd < 0)
		return(-5);	/* Fehler Protokoll */

	return((int)hdi);
}
