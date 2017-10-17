/***********************************************************************/
/*
 * REGISTER.C
 * ----------
 * 
 * Registration Routines, hidden in an Userdef Object!
 *
 */
/***********************************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <tos.h>
#include <aes.h>
#include <portab.h>

#include "GEMUTIL.H"
#include "PROTO.H"
#include "PAUL_RSC.RH"
#include "PAUL_RSC.H"



/* -------------------------------------------------------------------- */
/* Global Variables														*/
/* -------------------------------------------------------------------- */
int			registered;				/* registration OK ? */
extern GRECT screen;


/* -------------------------------------------------------------------- */
/* code																	*/
/* -------------------------------------------------------------------- */

/* reset_registrationdata
 * falls 'registered' == FALSE steht -> clear dialog fields.
 */
void reset_registrationdata( void )
{
	char	*p;
	OBJECT	*tr;
	
	p = (char *)(reset_registrationdata);			/* base addr 		*/
	p = &p[ ((char *)&registered - (char *)reset_registrationdata) ];
	if (!(*(int *)p))
	{
		tr = rs_trindex[REGISTER];
		*(tr[R_NAME].ob_spec.tedinfo->te_ptext)=0;
		*(tr[R_ADDR].ob_spec.tedinfo->te_ptext)=0;
		*(tr[R_CITY].ob_spec.tedinfo->te_ptext)=0;
		*(tr[R_KEY].ob_spec.tedinfo->te_ptext)=0;
	}
}

/* handle the REGISTER dialog!
 */
void handle_register_dialog( void )
{
	GRECT	sb;
	int		cont, ob;
	char	*n,*a,*c;
	OBJECT	*tr = rs_trindex[REGISTER];

	n = tr[R_NAME].ob_spec.tedinfo->te_ptext;
	a = tr[R_ADDR].ob_spec.tedinfo->te_ptext;
	c = tr[R_CITY].ob_spec.tedinfo->te_ptext;

	reset_registrationdata();
	draw_dialogbox( tr, &sb );
	cont = TRUE;
	do {
		ob = form_do(tr, 0);				/* Dialog ausfhren */
		if (*n)
		{
			if (*a && *c) cont = FALSE;
			else	error_alert( E_REGISTER );
		}
		else cont = FALSE;
		objc_change( tr, ob, 0, ELTS(screen), NORMAL, 1 );
	} while (cont);
	undraw_dialogbox( &sb );
};



/* Userdef Routine checking the key...
 */
WORD cdecl check_userkey(PARMBLK *pb)
{

#define CHKSUMLEN	8			/* 8 bytes = 4 words */
#define KEYRADIX	36

	OBJECT	*ktree;
	char	userkey[16];
	char	userdata[3*32];
	char	*p;
	int		k[CHKSUMLEN/2];		/* 4 words */
	int		Length,
			Seed,
			i,j;
	char 	*regP;
	
	ktree = rs_trindex[REGISTER];
	strcpy( userdata, ktree[R_NAME].ob_spec.tedinfo->te_ptext );
	strcat( userdata, ktree[R_ADDR].ob_spec.tedinfo->te_ptext );
	strcat( userdata, ktree[R_CITY].ob_spec.tedinfo->te_ptext );

	Length = (int)strlen(userdata);
	regP = (char *)(check_userkey);				/* base addr 		*/
	regP = &regP[ ((char *)&registered - (char *)check_userkey) ];
	if (Length>10)
	{
		Seed = rand();					/* alten Seed merken	*/
		
		for (i=CHKSUMLEN; i-->0;) userkey[i] = i;
	
		for (i=0; i<CHKSUMLEN; i++)		/* key berechnen		*/
			for (j=0; j<Length; j++)
			{
				srand( (userkey[i]) | (userdata[j]<<8) );
				userkey[i] = rand();
			}
		*(long *)&k[0] = *(long *)&userkey[0];		/* key bertragen	*/
		*(long *)&k[2] = *(long *)&userkey[4];		/* mit 2 move.l 	*/

		userkey[0] = 0;
		for (i=0; i<4; i++)
		{
			itoa( k[i], userdata, KEYRADIX );		/* key erzeugen		*/
			k[i]=0;									/* trace kill		*/
			strcat( userkey, userdata );			/* und anh„ngen		*/
		}
													/* Vergleichen!		*/
		i = (strcmpi(userkey, ktree[R_KEY].ob_spec.tedinfo->te_ptext)==0);
		*(int *)regP = i;
		for (p=userkey; *p; *p++=0);			/* Spuren verwischen	*/
		for (p=userdata; *p; *p++=0);
		srand(Seed);
	}
	else
		*(int *)regP = pb->pb_currstate;	/* immer NORMAL = 0 = unreg */
	return 0;
}


/* -------------------------------------------------------------------- */
/* end of file															*/
/* -------------------------------------------------------------------- */
