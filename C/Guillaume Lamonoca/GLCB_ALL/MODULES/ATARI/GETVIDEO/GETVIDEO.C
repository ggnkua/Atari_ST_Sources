#include <ctype.h> 
#include <tos.h>
#include <stdio.h>
#include <vdi.h>
#include <ext.h>
#include <portab.h>
#include <aes.h>
#include <string.h>

#include "eddilib.h"

typedef struct
{	
	long 	ident;
	long	valeur;
}	t_cookie;



void cookie_list(FILE *fd)
{
	long old_stack;
	t_cookie** ptr_tab_cookie=(t_cookie **)0x5a0;	/* pointeur vers le tableau	*/																				/* des cookie	*/
	t_cookie *tab_cookie;
	char s[5];
	char tmp[10];
	char tmp2[3];
	int i;

	/* pour lire l'adresse du tableau des cookies, il faut etre en mode	
		superviseur		*/
	if (Super((void *)1L)==0L)	/* si on est en mode utilisateur	*/
	{		
		old_stack=Super(0L);	/* on passe en mode superviseur	*/
	}
	else
	{	
		old_stack=0;
	}
	tab_cookie=*ptr_tab_cookie;	/* on lit cette adresse			*/
	
	
	if (old_stack)				/* si on etait en utilisateur au debut	*/
	{
		Super((void *)old_stack);	/*  on y retourne */
	}				
		
	if (tab_cookie==0L)		/* si le tos <1.6, on n'a pas de cookie jar	*/
		return;				


	fprintf(fd,"\nCookie list:\n\n");
		
	do		/* on boucle jusqu'a avoir trouve le cookie ou avoir atteint			*/
			/* le dernier element de la cookie jar									*/
	{
		if (tab_cookie->ident)
		{
			memmove(s,(const char *)&tab_cookie->ident,4);
			s[4]=0;
			sprintf(tmp,"'");
			for(i=0;i<4;i++)
				switch(s[i])
				{
					case 0:
						strcat(tmp,"\\0");
						break;
					case 8:
						strcat(tmp,"\\b");
						break;
					case 9:
						strcat(tmp,"\\t");
						break;
					case 13:
						strcat(tmp,"\\r");
						break;
					default:
						sprintf(tmp2,"%c",s[i]);
						strcat(tmp,tmp2);
				}
			strcat(tmp,"'");
					
			fprintf(fd,"%-10s (0x%08lx) -> 0x%08lx\n",tmp,tab_cookie->ident,tab_cookie->valeur);
		}
		tab_cookie++;
	}	
	while (tab_cookie->ident!=0);	/* la table des cookie est toujours	*/
								/* terminee par un cookie dont l'ident vaut	0	*/

}





long gc(long target)
{
	long old_stack;
	t_cookie** ptr_tab_cookie=(t_cookie **)0x5a0;	/* pointeur vers le tableau	*/																				/* des cookie	*/
	t_cookie *tab_cookie;

	/* pour lire l'adresse du tableau des cookies, il faut etre en mode	
		superviseur		*/
	if (Super((void *)1L)==0L)	/* si on est en mode utilisateur	*/
	{		
		old_stack=Super(0L);	/* on passe en mode superviseur	*/
	}
	else
	{	
		old_stack=0;
	}
	tab_cookie=*ptr_tab_cookie;	/* on lit cette adresse			*/
	
	
	if (old_stack)				/* si on etait en utilisateur au debut	*/
	{
		Super((void *)old_stack);	/*  on y retourne */
	}				
		
	if (tab_cookie==0L)		/* si le tos <1.6, on n'a pas de cookie jar	*/
		return(-2);				
		
	do		/* on boucle jusqu'a avoir trouve le cookie ou avoir atteint			*/
			/* le dernier element de la cookie jar									*/
	{
		if (tab_cookie	->ident	==target)	/* si le cookie est le cookie recherch‚	*/
		{
			return(tab_cookie	->valeur);	/* on renvoie sa valeur					*/
		}
		else
		{
			/* sinon, on passe au cookie suivant	*/
			tab_cookie++;
		}	
	}	
	while (tab_cookie->ident!=0);	/* la table des cookie est toujours	*/
								/* terminee par un cookie dont l'ident vaut	0	*/

	/* si on n'a pas trouve le cookie	, on renvoie -1 */
	return(-1);
}

int work_out[300];
int work_in[11];

void getinfo(FILE *fd)
{
	int i,j;
	int deskpalsize;
	int gl_wchar,gl_hchar,gl_wbox,gl_hbox;
	int phys_handle;
	int handle;
	int max_x,max_y;

	fprintf(fd,"GETVIDEO (video ram infos)\n\n");
	
	fprintf(fd,"Video address (Physbase): %08lx\n",Physbase());
	
	fprintf(fd,"Video mode (Getrez): %d\n",Getrez());
	
	for ( i = 0; i < 10; i++ )	
		work_in[i]  = 1;
	work_in[0] = Getrez()+2;
	work_in[10] = 2;
	phys_handle = graf_handle( &gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox );
	
	fprintf(fd,"Phys_handle:%d ; char size:%dx%d ; box size:%dx%d\n",phys_handle,
				gl_wchar,gl_hchar,gl_wbox,gl_hbox);
	
	handle = phys_handle;
	v_opnvwk( work_in, &handle, work_out );
	if ( handle )	
	{	
		deskpalsize=work_out[13];
		max_x = work_out[0]; 
		max_y = work_out[1];
	
		fprintf(fd,"handle:%d ; max_x:%d ; max_y:%d ; palette size:%d\n",
					handle,max_x,max_y,deskpalsize);
		
		vq_extnd(handle,1,work_out);

			
		fprintf(fd,"CLUT : %d ; Nbr planes : %d\n",work_out[5],work_out[4]);
		
			
		if (gc('EdDI')>0)
		{
			fprintf(fd,"\nVDI Enhancer detected. vq_scrninfo() available :\n");
			
			vq_scrninfo(handle,work_out);
			
			fprintf(fd,"Device format: %d\n",work_out[0]);
			fprintf(fd,"CLUT: %d\n",work_out[1]);
			fprintf(fd,"Number of planes: %d\n",work_out[2]);
			fprintf(fd,"Number of colors: %lu\n",(unsigned int)work_out[3]*65536L+(unsigned int)work_out[4]);
			fprintf(fd,"RGB bits: R(%d) G(%d) B(%d)\n",
						work_out[8],work_out[9],work_out[10]);
			fprintf(fd,"Number of bits for alpha channel: %d\n",work_out[11]);
			fprintf(fd,"Number of bits for genlock: %d\n",work_out[12]);
			fprintf(fd,"Number of unused bits: %d\n\n",work_out[13]);

			for(i=0;i<16;i++)
			{
				for(j=0;j<16;j++)
					fprintf(fd,"%4d",work_out[16+i*16+j]);
				fprintf(fd,"\n");
			}
		}
		else
			fprintf(fd,"\nNo VDI Enhancer (NVDI >=2.5) detected (no cookie 'EdDI')\n");



		v_clsvwk(handle);
	}
	
}



int main(void)
{
	int i;
	char name[80];
	FILE *fd;

	fprintf(stdout,"%cE",27);
	getinfo(stdout);
	
	i=0;
	do
	{
		sprintf(name,"info_%03d.txt",i);
		fd=fopen(name,"r");
		if (fd)
			fclose(fd);
		i++;
	}
	while(fd);
	
	fprintf(stdout,"\npress a key...\n(press 's' to save info into '%s' text file)",name);

	if (tolower(getch())=='s')
	{
		fd=fopen(name,"w");
		if (fd)
		{
			getinfo(fd);
			cookie_list(fd);
			fclose(fd);
		}
	}
	
	return 0;
}