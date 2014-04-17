/*======================================================================*/
/*		TITLE:			SCORE				*/
/*		Function:		Scoring Routines		*/
/*									*/
/*		First Edit:		06/02/89			*/
/*		Project #:		532xx				*/
/*		Programmer:		Dennis Harper			*/
/*									*/
/*		COPYRIGHT 1990/1991 ATARI GAMES CORP.			*/
/*	  UNATHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,		*/
/*	  PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR		*/
/*	THE ASSOCIATED AUDIOVISUAL WORK	IS STRICTLY PROHIBITED.		*/
/*	       		ALL RIGHTS RESERVED.				*/
/*									*/
/*----------------------------------------------------------------------*/

#ifdef ARIUM

#include	"prog/inc/rrdef.h"
#include	"prog/inc/message.h"

#else

#include	"inc:rrdef.h"
#include	"inc:message.h"

#endif

extern	ulong	bckdsp;
extern	WORD	alfram[];
extern	BYTE	game;
extern	WORD	wave;
extern	BYTE	rsrv_tbl[];

	ulong	plr_score;			/* Player's score	*/
	ulong	wave_score;			/* Score per wave	*/
	ulong	high_score;			/* High score		*/
	WORD	multx;

	ulong	score_tbl[]={0,150000,300000,0,100000,200000,0,100000,200000};



/*	Init score varaibles		*/
init_score()
{

	plr_score = score_tbl[0];		/* Clear score		*/
	wave_score = 0;
	multx = 1;				/* 1x mutiplier		*/
	bckdsp |= B_SCORE;			/* Display zero		*/
}



/*	advance score varaibles		*/
adv_score()
{
	plr_score += score_tbl[0];		/* Clear score		*/
}



/*	Display score			*/
disp_score()
{
	pdec(33,27,plr_score,7,1,APLT1|BG_BIT);
	bckdsp &= ~B_SCORE;			/* Disable score update	*/
}



/*	Display high score			*/
disp_hscore()
{
	pbdec(34,3,high_score,7,0,APLT7|SET1);
}



/*	Add score to player's total			*/
add_score(amount)
int	amount;
{
	ulong	amt,score;

	if (!game) return;			/* If not game, exit	*/

	amt = amount & ~(NO_MULT | NO_WAVE);	/* Trim display flags	*/

	if (amount & NO_MULT)			/* If no multiplier req	*/
	  score = (WORD)amt;
	else
	  score = (WORD)amt * (WORD)multx;

	if ((amount & NO_WAVE) == 0)		/* If Wave score req	*/
	  wave_score += score;

	plr_score += score;
	bckdsp |= B_SCORE;			/* Respeed score change	*/
}


/*	Check new high score			*/
chk_hscore()
{
	if (plr_score > high_score)
	  high_score = plr_score;
}
