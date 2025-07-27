/* ICFS-Config, Dirk Haun, 07.03.1994
 *
 * Hiermit kînnen die Fenstergrîûe sowie die "Strategie" fÅr die
 * Verteilung der Icon-Fenster eingestellt werden.
 *
 */

#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include "icfs.h"

int cdecl (*server)(int opt,...);
void *get_cookie(long cookie);

int main(void)
{
 int i, w, h, new_conf=0;
 ICFSCONFIG c;

 appl_init();
 server=get_cookie('ICFS');
 if(server)
 {
  (*server)(ICF_INFO,&c,(int)sizeof(ICFSCONFIG));

  w=c.xsize;
  h=c.ysize;
  if(w!=h) i=2;
  else switch(w)
  {
   case 64: i=1; break;
   case 72: i=2; break;
   case 96: i=3; break;
   default: i=2;
  }
  i=form_alert(i,"[2][Fenstergrîûe:][64x64|72x72|96x96]");
  switch(i)
  {
   case 1: w=h=64; break;
   case 2: w=h=72; break;
   case 3: w=h=96; break;
  }
  (*server)(ICF_SETSIZE,w,h);

  i=form_alert(c.config.top ? 2 : 1,"[2][Anfangen: unten oder oben?][unten|oben]");
  if(i==2) new_conf|=1;
  i=form_alert(c.config.right ? 2 : 1,"[2][Anfangen: links oder rechts?][links|rechts]");
  if(i==2) new_conf|=2;
  i=form_alert(c.config.yfirst ? 2 : 1,"[2][Belegungsrichtung:|zuerst x oder zuerst y?][ x | y ]");
  if(i==2) new_conf|=4;

  (*server)(ICF_CONFIG,new_conf);
 }
 else form_alert(1,"[2][ICFS-Cookie nicht gefunden!][ Abbruch ]");
 appl_exit();
 return(0);
}


/* ----- Cookie Jar -------------------------------------------------------- */

typedef struct {
		long	id,
			*ptr;
		} COOKJAR;

/* ------------------------------------------------------------------------- */
/* ----- get_cookie   (frei nach Oliver Scheel) ---------------------------- */
/* ------------------------------------------------------------------------- */

void *get_cookie(long cookie)
{
	long	sav;
	COOKJAR	*cookiejar;
	int	i = 0;

	sav = Super((void *)1L);
	if(sav == 0L)
		sav = Super(0L);
	cookiejar = *((COOKJAR **)0x05a0l);
	if(sav != -1L)
		Super((void *)sav);
	if(cookiejar)
	{
		while(cookiejar[i].id)
		{
			if(cookiejar[i].id == cookie)
				return(cookiejar[i].ptr);
			i++;
		}
	}
	return(0l);
}
