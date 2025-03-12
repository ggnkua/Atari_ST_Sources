***********************************
*
*  boolean d0.b CheckLine(a0.l *Actor)
*
* Returns True if a straight line between the player and actor is unobstructed
*
***********************************

		section	text
CheckLine	ifeq	1
{
	Word actorx,actory,actortx,actorty;		/* Current actor's coords */
	Word playerx,playery,playertx,playerty;	/* Player's coords */
	Word xl,xh,yl,yh;				/* Min x,y Max x,y for test */
	int delta;		/* Pixel differance to calc Step and Frac */
	int Step;		/* Step value for each whole xy */
	Word Frac;		/* Fractional xy stepper */
	Word deltafrac;	/* True distance for whole numbers */
	Word intercept;	/* Temp for door code */
	Word tile;		/* Temp for tile check */
	Byte partial;	/* Fraction to force whole numbers */
	
	actorx = ActorPtr->x;		/* Get the actor's x,y */
	actortx = actorx>>FRACBITS;	/* Get the actor's tile x,y */
	actory = ActorPtr->y;
	actorty = actory>>FRACBITS;

	playerx = actors[0].x;	/* Get the player's x,y */
	playertx = playerx>>FRACBITS;	/* Get the player's tile x,y */
	playery = actors[0].y;	
	playerty = playery>>FRACBITS;

	/* The actor COULD be standing on a blocked tile (On a CLOSING door tile) */

#if 0
	if (tilemap[actorty][actortx] & TI_BLOCKSIGHT) {	/* Is the actor IN a wall? */
		return FALSE;			/* This could happen on a closing door */
	}
#endif

/* check for solid tiles at x crossings */
	
	if (playertx!=actortx) {		/* Scan in the x direction? */
		if (actortx<playertx) {		
			partial = -actorx;	/* Isolate the fraction */
			xl = actortx-1;			/* Actor is on the left side */
			xh = playertx-1;
			yl = actory;
			yh = playery;
			deltafrac = playerx-actorx;	/* Distance in pixels */
		} else {
			partial = -playerx;
			xl = playertx;			/* Player is on the left side */
			xh = actortx;
			yl = playery;
			yh = actory;
			deltafrac = actorx-playerx;	/* Distance in pixels */
		}
		delta = yh-yl;				/* Y adjust (Signed) */
		if (w_abs(delta) >= (16*FRACUNIT) || deltafrac >= (16*FRACUNIT)) {	/* Farther than 16 tiles? */
			return FALSE;
		}
		Step = FixedDiv(delta,deltafrac);		/* How much to y step */
		Frac = FixedByFrac(Step,partial)+yl;	/* Init the Y coord */
		do {
			++xl;
			tile = tilemap[Frac>>FRACBITS][xl];		/* Get the current tile */
			if (tile & TI_BLOCKSIGHT) {
				return FALSE;		/* Can't see! */
			}
			if (tile & TI_DOOR) {	/* see if the door is open enough*/
				intercept = ((Step/2)+Frac)&0xff;
				if (intercept > doors[tile&TI_NUMMASK].position) {
					return FALSE;	/* Can't see! */
				}
			}
			Frac += Step;
		} while (xl<xh);
	}

/* check for solid tiles at y crossings */

	if (playerty!=actorty) {
		if (actorty<playerty) {
			partial = -actory;
			xl = actorx;
			xh = playerx;
			yl = actorty-1;
			yh = playerty-1;
			deltafrac = playery-actory;
		} else {
			partial = -playery;
			xl = playerx;
			xh = actorx;
			yl = playerty;
			yh = actorty;
			deltafrac = actory-playery;
		}
		delta = xh-xl;		/* Number of tiles to scan */
		if (w_abs(delta) >= 16*FRACUNIT || deltafrac >= 16*FRACUNIT) {
			return FALSE;
		}
		Step = FixedDiv(delta,deltafrac);
		Frac = FixedByFrac(Step,partial)+xl;
		do {
			++yl;	
			tile = tilemap[yl][Frac>>FRACBITS];
			if (tile & TI_BLOCKSIGHT) {
				return FALSE;
			}
			if (tile & TI_DOOR) {	/* see if the door is open enough*/
				intercept = ((Step/2)+Frac)&0xff;
				if (intercept > doors[tile&TI_NUMMASK].position) {
					return FALSE;	/* Can't see! */
				}
			}
			Frac += Step;
		} while (yl<yh);
	}
	return TRUE;	/* You are visible */
}
	endc

***********************************
*
*  void FirstSightning(a0.l *Actor)
*
* Puts actor into attack mode, either after reaction time or being shot
*
***********************************

FirstSighting	movea.l	class(a0),a1	; Get pointer to info record
		movea.l	a0,a2
	
		movea.l	csightsound(a1),a0	; Get the requested soundptr

		cmpa.l	#SND_ESEE,a0		; make random human sound
		bne.s	.nonazi

		bsr.w	w_rnd			; Make a different sound
		andi.b	#%1100,d0
		adda.w	d0,a0
		
.nonazi		movea.l	(a0),a0		; Play the sight sound
		bsr.w	PlaySound
		
		movea.l	a2,a0		; Set the next state
		move.w	csightstate(a1),d0
		bra.w	NewState




***********************************
*
*  void T_Stand(a0.l *Actor)
*
* Called by actors that ARE NOT chasing the player. If the player
* is detected, the actor is put into
* it's combat frame.
*
***********************************

T_Stand		move.w	reacttime(a0),d0	; Waiting to react?
		bmi.s	.break

		sub.w	ticcounter(pc),d0	; Still waiting?
		move.w	d0,reacttime(a0)	; Cound down
		bpl.s	.break

		clr.w	reacttime(a0)
		bra.w	FirstSighting	; Attack the player!

.break		rts


