/*************************************************************************/
/*                                                                       */
/* ½ Seaton Shareware Coop - All Rights Reserved		                   */
/*                                                                       */
/* Module : SOUND.H                                                      */
/*                                                                       */
/* Purpose: Header file for sampled sound playing                        */
/*                                                                       */
/* Author : Pete Walker & Geoff Smith                                    */
/*                                                                       */
/*************************************************************************/

/*************************************************************************/
/*                                                                       */
/* 001	26/10/94		PAW	Initial Release                               */
/*                                                                       */
/*************************************************************************/

typedef struct SOUNDSTUFFstr /* su04 & su05 */
{
	char  *data;
	long  length;
	long  freq;
} SOUNDSTUFF;

void read_sound /* su04 */
	(
	char *path,
	char *file,
	SOUNDSTUFF *sample
	);

void play_sound /* su04 */
	(
	SOUNDSTUFF *sample
	);

void free_sound /* su04 */
	(
	SOUNDSTUFF *sample
	);

