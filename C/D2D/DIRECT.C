#include <ext.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <aes.h>

#include "rout_gem.h"
#include "d2d2.h"
#include "constant.h"

int codec_data[7]; 	/* tableau contenant l'‚tat du codec */
long int	buffpointer[4];
extern char *sound_buffer;

int choix_freq(OBJECT *arbre_adr)
{
if ( selected(arbre_adr,KHZ12) ) return(4); 
if ( selected(arbre_adr,KHZ25) ) return(3); 
if ( selected(arbre_adr,KHZ33) ) return(2); 
if ( selected(arbre_adr,KHZ50) ) return(1);
return(0);
}; 


void setmatrice(OBJECT *arbre,int srcclk,int prescale)
{
	int source,dst,i;
	static int masque[4]={DAC,EXTOUT,DSPREC,DMAREC};
	static int table[4][4]={{DMAP_DAC,DMAP_SX,DMAP_EDSP,DMAP_DMAR},
							{SDSP_DAC,SDSP_SX,SDSP_EDSP,SDSP_DMAR},
							{EX_DAC,EX_SX,EX_EDSP,EX_DMAR},
							{ADC_DAC,ADC_SX,ADC_EDSP,ADC_DMAR}
						 };
						 
	for(source=0;source<4;source++)
	{
		dst=0;
		for(i=0;i<4;i++)
			if ( selected (arbre,table[source][i]) ) dst|=masque[i];
		devconnect(source,dst,srcclk,prescale,1);
	};
}

int stop(OBJECT *arbre)
{
 int clavier,bouton,vide,coord_x,coord_y;

 vide=1;
 vide=evnt_multi(35,1,1,1,vide,vide,vide,vide,vide,
				vide,vide,vide,vide,vide,&vide,5,0, &coord_x,
                &coord_y,&vide,&vide,&clavier,&vide);
 if ( (vide & 2) && ((vide=objc_find(arbre,0,10,coord_x,coord_y)) == STOP) ) return(0);
 if ( (char)clavier==' ') return(0);
 return(1);
}
 
void enregister(OBJECT *arbre,char *chemin,int gain_in,int gain_out,int adderin)
{ 
 int handle;
 long etat;
 long buffpointer[4];

 Fcreate(chemin,0);
 handle=Fopen(chemin,FO_WRITE);
 soundcmd(ADDERIN,adderin);
 soundcmd(ADCINPUT,0);
 soundcmd(LTATTEN,gain_out << 4);
 soundcmd(RTATTEN,gain_out << 4);
 soundcmd(LTGAIN,gain_in << 4);
 soundcmd(RTGAIN,gain_in << 4);
 setmode(1);
 settracks(0,0);
 setmontracks(0);
 setbuffer(1,sound_buffer,sound_buffer+SOUND_BUF_LEN+1);
 buffoper(12);
 
 etat=1;
 do
 {
	do
 	{
 	 buffptr(buffpointer);
 	}
	while ( buffpointer[1] < (long)(sound_buffer+HALF_BUFFER) );
 	if (etat >0) etat=Fwrite(handle,HALF_BUFFER,sound_buffer);

  	do
 	{
 	 buffptr(buffpointer);
 	}
	while ( buffpointer[1] >= (long)(sound_buffer+HALF_BUFFER) );
 	if (etat>0) etat=Fwrite(handle,HALF_BUFFER,sound_buffer+HALF_BUFFER ); 

 }
 while ( stop(arbre) && etat>0);
 
 Fclose(handle);
 buffoper(0);
};
 	
 	
void rejouer(OBJECT *arbre,char *chemin,int gain_out,int adderin)
{ 
 int  handle;
 long buffpointer[4];
 long buffer_count=1,nb_buffer;

 handle=Fopen(chemin,FO_READ);
 nb_buffer=filelength(handle) / SOUND_BUF_LEN;
 Fread(handle,SOUND_BUF_LEN,sound_buffer);

 
 soundcmd(LTATTEN,gain_out << 4);
 soundcmd(RTATTEN,gain_out << 4);
 soundcmd(ADDERIN,adderin);			/* L'erreur ‚tait ici !! */
 								/* Car on mettait 1 au lieu de 2, ce */
 								/* qui faisait que l'on entendait le */
 								/* micro, mais pas ce qui venait de	 */
 								/* la matrice !! (cf STMAG 85, page 41)*/
 setmode(1);
 settracks(0,0);
 setmontracks(0);
 setbuffer(0,sound_buffer,sound_buffer+SOUND_BUF_LEN+1);
 buffoper(3);
 
 do
 {
 	do
 	{
 	 buffptr(buffpointer);
 	}
 	while ( buffpointer[0] < (long)(sound_buffer+HALF_BUFFER) );
	Fread(handle,HALF_BUFFER,sound_buffer);

  	do
 	{
 	 buffptr(buffpointer);
 	}
 	while ( buffpointer[0] >= (long)(sound_buffer+HALF_BUFFER) );
	Fread(handle,HALF_BUFFER,sound_buffer+HALF_BUFFER);

 }
 while ( (++buffer_count)<=nb_buffer && stop(arbre));
 Fclose(handle);
 buffoper(0);
};
 	

void direct2disk(void)
{ 
 int i,x,y,w,h,bouton,gain_in=0,gain_out=0,freq=2,adderin=3;
 int codec_data[7];
 OBJECT	*arbre_adr;
 char gain[3]={'0',0,0};
 static char chemin[STFILELEN+STPATHLEN+1]="c:\\sample.smp";
 
 
 for(i=0;i<7; codec_data[i++]=( int )  soundcmd(i,-1) );
 							/* sauvegarde l'‚tat du codec */

 rsrc_gaddr(1,PRINCIPAL,&arbre_adr);
 
 setmatrice(arbre_adr,0,freq);
 write_text(arbre_adr,CHEMIN,chemin);
 write_text(arbre_adr,VAL_GAIN_IN,gain);
 write_text(arbre_adr,VAL_GAIN_OUT,gain);
 show_dialog(arbre_adr,&x,&y,&w,&h);
 freq=choix_freq(arbre_adr);
 
 soundcmd(LTATTEN,gain_out << 4);
 soundcmd(RTATTEN,gain_out << 4);
 soundcmd(LTGAIN,gain_in << 4);
 soundcmd(RTGAIN,gain_in << 4);
 soundcmd(ADDERIN,adderin);					/* La valeur 1 permet d'entendre */
 soundcmd(ADCINPUT,0);					/* la source sonore */
 setmode(1);
 settracks(0,0);
 setmontracks(0);
 
 do
 {
 	bouton=form_do(arbre_adr,0);
 	switch ( bouton )
 	{
 		case GAIN_IN_PLUS: if (gain_in < GAIN_MAX) gain_in++;
 							break;

 		case GAIN_OUT_PLUS: if (gain_out < GAIN_MAX) gain_out++;
 							break;

  		case GAIN_IN_MOINS: if (gain_in > GAIN_MIN) gain_in--;
 							break;

 		case GAIN_OUT_MOINS: if (gain_out > GAIN_MIN) gain_out--;
 							break;
 							
		case ENREGISTRER: 	freq=choix_freq(arbre_adr);
							setmatrice(arbre_adr,0,freq);
							activer(arbre_adr,STOP,x,y,w,h);
							desactiver(arbre_adr,REJOUER,x,y,w,h);
 							enregister(arbre_adr,chemin,gain_in,gain_out,adderin);
 							deselect(arbre_adr,ENREGISTRER,x,y,w,h);
							desactiver(arbre_adr,STOP,x,y,w,h);
							activer(arbre_adr,REJOUER,x,y,w,h); 
							break;

		case REJOUER: 		if ( Fattrib(chemin,0,0)>0)
							{
								freq=choix_freq(arbre_adr);
								setmatrice(arbre_adr,0,freq);
								activer(arbre_adr,STOP,x,y,w,h);
								desactiver(arbre_adr,ENREGISTRER,x,y,w,h);
 								rejouer(arbre_adr,chemin,gain_out,adderin);
  								desactiver(arbre_adr,STOP,x,y,w,h);
								activer(arbre_adr,ENREGISTRER,x,y,w,h); 
  							};
							deselect(arbre_adr,REJOUER,x,y,w,h);
  							break;
  		
		case CHEMIN:		file_select(chemin);
							write_text(arbre_adr,CHEMIN,chemin);
  							objc_draw(arbre_adr,PRINCIPAL,30,x,y,w,h);		
  							break;

		case SORTIE_MATRICE:
							if(adderin & 2)
								deselect(arbre_adr,SORTIE_MATRICE,x,y,w,h);
							adderin ^=2;
							soundcmd(ADDERIN,adderin);
							break;
		
		case SORTIE_ADC:
							if(adderin & 1)
								deselect(arbre_adr,SORTIE_ADC,x,y,w,h);
							adderin ^=1;
							soundcmd(ADDERIN,adderin);
							break;

		case FIN:
		case STOP:			break;
		
		default:		setmatrice(arbre_adr,0,freq);		
  	};
  	
  	if ( (bouton==GAIN_IN_PLUS) || (bouton==GAIN_IN_MOINS))
  		{
  			write_text(arbre_adr,VAL_GAIN_IN,itoa(gain_in,gain,10));
  			objc_draw(arbre_adr,VAL_GAIN_IN,0,x,y,w,h);
  			soundcmd(LTGAIN,gain_in << 4);
			soundcmd(RTGAIN,gain_in << 4);
  			
  		}
  	else
  		if ( (bouton==GAIN_OUT_PLUS) || (bouton==GAIN_OUT_MOINS))
  		{
  			write_text(arbre_adr,VAL_GAIN_OUT,itoa(gain_out,gain,10));
  			objc_draw(arbre_adr,VAL_GAIN_OUT,0,x,y,w,h);
  			soundcmd(LTATTEN,gain_out << 4);
			soundcmd(RTATTEN,gain_out << 4);
  	};
 	
 	evnt_timer(5,0);
 }
 while(bouton != FIN);  							

 deselect(arbre_adr,bouton,x,y,h,w);
 hide_dialog(arbre_adr);
 for(i=0;i<7; soundcmd(i++,codec_data[i]));
 							/* restaure l'‚tat du codec */
 							/* attention … l'orde d'empilement*/
}
 	

