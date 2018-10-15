/***************************************************************
****************************************************************

	Midi Echo

	Accessoire de bureau

	Module MidiShare ( … linker avec la librairie Midi )

	GRAME			D. Fober
	24/10/89
****************************************************************
****************************************************************/

#include <msh_unit.h>
#include "echo.h"

#define NO_APP	0

/*------------------------------------------------------------------*/
/* structure de gestion des echos */
extern struct echoState echo;

/*------------------------------------------------------------------*/
/* le num‚ro de r‚f‚rence de l'application Midi Echo */
int Refnum=NO_APP;

/**************************************************************************/
void cdecl rcv_alarm( refnum)		/* alarme de reception : echo off */
register int refnum;			/* refnum de l'application */
{
	MidiFlushEvs( refnum);		/* on vide le fifo */
}		

/**************************************************************************/
void cdecl echo_alarm( refnum)	/* alarme de reception : echo on */
register int refnum;			/* refnum de l'application */
{
register MidiEvPtr event, copy;	
register int temp, delay, amort;
register unsigned long date;
	
	delay= echo.delay* 10;
	amort= echo.amort;
	while( event= MidiGetEv( refnum)){		/* tant que le fifo n'est pas vide */
		if( EvType(event)== typeKeyOn){	/* si l'evt est un Key On */
			temp= Vel(event);			/* sa v‚locit‚ */
			date= Date( event);			/* sa date */
			while( (temp-= amort)>0){	/* tant que velocit‚ > 0 */
				if( copy= MidiCopyEv( event)){	/* copie de l'evt */
					EvType( copy)= typeNote;		/* chang‚ en note */
					Vel( copy)= temp;			/* nouvelle v‚locit‚*/
					Date( copy)= (date+= delay);	/* nouvelle date */
					Dur( copy)= delay-1;		/* sa dur‚e */
					MidiSend( refnum, copy);		/* on l'envoie */
				}				/* si plus d'evt disponible */
				else break;		/* sortie de la boucle */
			}
		}
		else if( EvType(event)== typeNote){/* si l'evt est une Note */
			temp= Vel(event);			/* sa v‚locit‚ */
			date= Date( event);			/* sa date */
			while( (temp-= amort)>0){	/* tant que velocit‚ > 0 */
				if( copy= MidiCopyEv( event)){	/* copie de l'evt */
					Vel( copy)= temp;			/* nouvelle v‚locit‚*/
					Date( copy)= (date+= delay);	/* nouvelle date */
					Dur( copy)= delay-1;		/* sa dur‚e */
					MidiSend( refnum, copy);		/* on l'envoie */
				}				/* si plus d'evt disponible */
				else break;		/* sortie de la boucle */
			}
		}
		MidiFreeEv( event);				/* on libŠre l'original */
	}
}		

/**************************************************************************/
void chge_alarm( state)		/* switch des deux alarmes de r‚ception */
register int state;
{
	if( state)
		MidiSetRcvAlarm( Refnum, &echo_alarm);
	else
		MidiSetRcvAlarm( Refnum, &rcv_alarm);
}

/**************************************************************************/
int midi_connecte()				/* point d'entr‚e midishare du module */
{
	if( MidiShare()){				     /* v‚rif pr‚sence de MidiShare */
		if( Refnum)					/* si l'appl. est d‚j… ouverte */
			return( MSH_OK);			/* retourne OK */
		if( (Refnum= MidiOpen( "Midi Echo"))> 0){	/* d‚clare Midi Echo  */
			MidiSetRcvAlarm( Refnum, echo_alarm);	/* alarme	de reception */
			MidiConnect( 0, Refnum, TRUE);	/* on connecte … MidiShare */
			MidiConnect( Refnum, 0, TRUE);	/* en entr‚e et en sortie */
			return( MSH_OK);			/* retourne OK */
		}
		else 
		{
			Refnum= NO_APP;
			return( MSH_FULL);		/* pas d'application disponible */
		}
	}
	else return( MSH_NO);			/* MidiShare n'est pas install‚ */
}

/**************************************************************************/
void fin_connecte()	   		/* sortie du module */
{
	if( Refnum){
		MidiSetRcvAlarm( Refnum, &echo_alarm);	/* alarme	de reception */
		MidiFlushEvs( Refnum);
		MidiClose( Refnum );	/* referme l'application MidiShare */
		Refnum= NO_APP;
	}
}

/******************************* fin ***********************************/
