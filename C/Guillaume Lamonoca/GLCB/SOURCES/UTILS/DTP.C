/* dtp.c Display Transfer Protocol
   Permet de transferer des fichiers en utilisant un display.
   Ce programme vous depannera si "ftp" ne marche plus.

usage:
mode reception: taper "dtp" dans le repertoire qui recevra les fichiers.
mode emission:  taper "dtp file1 file2 file3 ..." au niveau des fichiers.

Pour appeler dtp a partir d'un decterm rajouter:

sous VMS, dans le fichier "login.com" de votre compte:

$dtp:==$ $USERS:[PUBLIC.GAMES.GLCPROG]dtp.exe
$dis:==set display/create/node=

sous unix, dans le fichier ".login" de votre compte:

alias dtp /usersese/games/GLCprog/dtp
alias st1 setenv DISPLAY 160.228.112.228:0.0
alias st2 setenv DISPLAY 160.228.112.227:0.0
alias st3 setenv DISPLAY 160.228.112.230:0.0
alias st4 setenv DISPLAY 160.228.112.229:0.0
alias st5 setenv DISPLAY 160.228.112.231:0.0
alias stn setenv DISPLAY `who am i | cut -d'(' -f2 | cut -d')' -f1`::0.0

dis permet de changer de display, ex: dis esec17
stn permet de selectionner votre console (si ce n'est pas un terminal X).
st1,st2,st3,st4 et st5 selectionnent les terminaux X (de g. a d.).

Guillaume LAMONOCA
E.S.E Promo 94

PS:On aurait pu s'abstenir d'ouvrir une fenetre graphique, mais cela
permet de s'assurer que l'on utilise bien le bon display!
*/


#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include "header.h"

/***********************************************************************/
/* instructions de communication via display */

Display *cdisplay;

void initdisplay()
{
	cdisplay=XOpenDisplay(0);
	if (!cdisplay) { printf("Mauvais Display!\n"); killsystem(); }
}

void killdisplay()
{
	XCloseDisplay(cdisplay);
}

void send(ch,adr,len)
int ch;
void *adr;
long len;
{
	XStoreBuffer(cdisplay,(char *)adr,(int)len,ch);
	XFlush(cdisplay);
}


long receive(ch,adr)
void *adr;
int ch;
{
	long len;
	int nb;
	char *data;
	char *ptr;
	int i;

	ptr=(char *)adr;
	data=XFetchBuffer(cdisplay,&nb,ch);

	if (nb>0) for(i=0;i<nb;i++) *ptr++ = *data++;

	refresh();

	return((long)nb);
}

/**************************************************************************/


#define MAX 10240


unsigned char header[MAX+1];
char s[80];

int main(np,p)
int np;
char *p[];
{
int i,j;
char cnt;
int f;
long n;
long t,to;

	if (initsystem())
	{
		simplescreen();
		initdisplay();

		setcolor(15);

		print("");
		print("     - display transfer protocol -");
		print("");

		if (np==1)
		{
			cnt= -1;
			send(1,&cnt,1);

			print("mode reception:");
			print("");
			refresh();

			to=t=0;
			f= -1;
			n=1;

			while(!receive(0,header)) refresh();

			while(n)
			{

				n=receive(0,header);

				if ((n==80)&&(header[73]=='D')&&
					(header[74]=='T')&&(header[75]=='P'))
				{
					if (t)
					{
						print("");
						print("transmission interrompue");
						sprintf(s,"(%ld octets recus)",to-t);
						print(s);
						print("");
						if (f>0) bclose(f);
						f= -1;
					}

					t=header[76]*65536*256+header[77]*65536;
					t+=header[78]*256+header[79];
					to=t;
					print((char *)header);
					sprintf(s,"(%ld octets)",t);
					print(s);
					f=bcreate((char *)header);
					if (f<=0) print("creation impossible!");
					refresh();
					cnt=0;
					send(1,&cnt,1);
					cnt++;
					while((header[73]=='D')&&(header[74]=='T')&&
						(header[75]=='P')) receive(0,header);
				}
				else
				if ((n)&&(t))
				if (header[n-1]==cnt)
				{
					if (f>0) bwrite(f,header,n-1);
					t-=(n-1);
					sprintf(s,"%02d",(int)(100*(to-t)/(to+1)));
					printchar(s[0]);
					printchar(s[1]);
					printchar('%');
					printchar(' ');

					if (!t)
					{
						print("100%");
						print("transmission terminee");
						sprintf(s,"(%ld octets recus)",to);
						print(s);
						print("");
						if (f>0) bclose(f);
						f= -1;
					}
					refresh();
					send(1,&cnt,1);
					cnt++;
				}

			}
			
		}
		else
		{
			cnt = -1;
			send(1,&cnt,1);
			print("mode emission:");
			print("");

			for(i=1;i<np;i++)
			{
				cnt= -1;
				send(0,&cnt,1);
				sprintf(s,"%s",p[i]);
				print(s);
				if ((f=bopen(s))>0)
				{
					to=t=bsize(s);
					s[72]=0;
					s[73]='D';
					s[74]='T';
					s[75]='P';
					s[76]=(t>>24)&255;
					s[77]=(t>>16)&255;
					s[78]=(t>>8)&255;
					s[79]=t&255;


					for(j=0;j<80;j++) header[j]=s[j];

					send(0,header,80);

					sprintf(s,"(%ld octets)",t);
					print(s);
					refresh();

					header[0]= -1;
					cnt=0;
					
					while (cnt!=header[0]) receive(1,header);

					while(t)
					{
					
						n=MAX;
						if (t<n) n=t;
						bread(f,header,n);
						cnt++;
						header[n]=cnt;
						send(0,header,n+1);
						t-=n;

						sprintf(s,"%02d",(int)(100*(to-t)/(to+1)));
						printchar(s[0]);
						printchar(s[1]);
						printchar('%');
						printchar(' ');
						refresh();

						while (cnt!=header[0]) receive(1,header);
					}

					cnt++;
					send(0,&cnt,1);

					bclose(f);

					print("100%");
					print("transmission terminee");
					sprintf(s,"(%ld octets envoyes)",to);
					print(s);
					print("");
					refresh();

				} else print("fichier introuvable");
			}
		}

		send(0,&cnt,0);
		print("termine");
		print("");
		print("(clickez)");
		refresh();
		confirm();

		send(0,&cnt,0);
		send(1,&cnt,0);

		killdisplay();
	
		killsystem();
	}

}
