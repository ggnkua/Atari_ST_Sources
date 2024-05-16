***********************************
*
*	Visible sprite struct
*	
**********************************

		rsreset
visible		rs.b	1	; Is this currently visable?
actornum	rs.b	1	; Actor number, flags
SprShape	rs.l	1	; Shape of the sprite
SprX		rs.w	1	; Pixelpos x,y
SprY		rs.w	1
SprTz		rs.w	1	; Transformed x,z
SprTx		rs.w	1
thing_t		=	__RS


***********************************
*
*	Data struct for thinking actor
*	
***********************************

; Actor flags

FL_SHOOTABLE	=	0
FL_ACTIVE	=	1
FL_SEEPLAYER	=	2	; if True, dodge instead of moving straight forward
FL_WAITDOOR	=	3	; Waiting for a door to fully open up
FL_NOTMOVING	=	6	; still centered in dest tile
FL_DEAD		=	7	; if set, don't shoot this anymore (death explosion)

		rsset	thing_t
tics		rs.w	1	; Time before motion
class 		rs.l	1	; Actor's class
state		rs.w	1	; State index
flags		rs.b	1	; State flags (See above)
dir		rs.b	1	; 9 directions for motion
distance	rs.w	1	; Distance to travel before change
hitpoints	rs.w	1	; Hit points before death
speed		rs.w	1	; Speed of motion
reacttime	rs.w	1	; Time to react to the player
actor_t		=	__RS




		rsreset
csightsound	rs.l	1	; Sound at the sight of you 
cdeathsound	rs.l	1	; Sound at the death of the actor 
csightstate	rs.w	1	; State when you are sighted 
cstandstate	rs.w	1	; State when at rest 
cattackstate	rs.w	1	; State when attacking you 
cpainstate	rs.w	1	; State when hit 
cdeathstate	rs.w	1	; State when dead 
cpoints		rs.w	1	; Points for death 
cspeed		rs.w	1	; Speed of actor 
creactionmask	rs.w	1	; reaction time = 1 + w_rnd()&reactionmask
chitpoints	rs.w	1	; Hit points 
classinfo_t	=	__RS


		; actor class info

		section	data		
CL_GUARD	dc.l	SND_ESEE,SND_EDIE		; Nazi 
		dc.w	ST_GRD_WLK1, ST_GRD_STND, ST_GRD_ATK1,ST_GRD_PAIN,ST_GRD_DIE
		dc.w	100, 5, $0f, 6	

CL_OFFICER	dc.l	SND_ESEE,SND_EDIE		; Blue guard 
		dc.w	ST_OFC_WLK1, ST_OFC_STND, ST_OFC_ATK1,ST_OFC_PAIN,ST_OFC_DIE
		dc.w	400, 10, $01, 12

CL_SS		dc.l	SND_ESEE,SND_EDIE		; White officer 
		dc.w	ST_SS_WLK1, ST_SS_STND, ST_SS_ATK1,ST_SS_PAIN,ST_SS_DIE
		dc.w	500, 6, $07, 25

CL_DOG		dc.l	SND_DOGBARK,SND_DOGDIE		; Dog 
		dc.w	ST_DOG_WLK1,ST_DOG_STND,ST_DOG_ATK1,ST_DOG_WLK1,ST_DOG_DIE
		dc.w	200, 9, $07, 1
	
CL_MUTANT	dc.l	SND_NOSOUND,SND_EDIE		; Mutant 
		dc.w	ST_MUTANT_WLK1, ST_MUTANT_STND, ST_MUTANT_ATK1,ST_MUTANT_PAIN,ST_MUTANT_DIE
		dc.w	400, 7, $01, 18

CL_HANS		dc.l	SND_GUTEN,SND_EDIE		; Hans 
		dc.w	ST_HANS_WLK1, ST_HANS_STND, ST_HANS_ATK1,ST_GRD_STND,ST_HANS_DIE
		dc.w	5000,7, $01, 250

CL_SCHABBS	dc.l	SND_SHITHEAD,SND_EDIE		; Dr. Schabbs 
		dc.w	ST_SCHABBS_WLK1, ST_SCHABBS_STND, ST_SCHABBS_ATK1,ST_GRD_STND,ST_SCHABBS_DIE
		dc.w	5000, 5,$01, 350

CL_TRANS	dc.l	SND_GUTEN,SND_EDIE		; Trans 
		dc.w	ST_TRANS_WLK1, ST_TRANS_STND, ST_TRANS_ATK1,ST_GRD_STND,ST_TRANS_DIE
		dc.w	5000, 7,$01, 300

CL_UBER		dc.l	SND_DOGBARK,SND_EDIE		; Uber knight 
		dc.w	ST_UBER_WLK1, ST_UBER_STND, ST_UBER_ATK1,ST_GRD_STND,ST_UBER_DIE
		dc.w	5000, 8,$01, 400

CL_DKNIGHT	dc.l	SND_COMEHERE,SND_EDIE		; Dark knight 
		dc.w	ST_DKNIGHT_WLK1, ST_DKNIGHT_STND, ST_DKNIGHT_ATK1,ST_GRD_STND,ST_DKNIGHT_DIE
		dc.w	5000, 7,$01, 450

CL_MECHAHITLER	dc.l	SND_SHIT,SND_EDIE		; Mechahitler 
		dc.w	ST_MHITLER_WLK1, ST_MHITLER_STND, ST_MHITLER_ATK1,ST_GRD_STND, ST_HITLER_DIE
		dc.w	5000, 7,$01, 500

CL_HITLER	dc.l	SND_HITLERSEE,SND_EDIE		; Hitler 
		dc.w	ST_HITLER_WLK1, ST_MHITLER_STND, ST_HITLER_ATK1,ST_GRD_STND,ST_HITLER_DIE
		dc.w	5000, 8,$01, 500
	
CL_PLAYER



***********************************
*
*  void PlaceItemType(d0.w shape,a0.l *Actor)
*
* Drops a bonus item at the x,y of the actor
* If there are no free item spots, nothing is done.
*
***********************************

		section	text		
	ifeq	1
void PlaceItemType(Word shape,actor_t *ActorPtr)
{
	Word tile;
	Word x,y;
	static_t *StaticPtr;

	if (numstatics>=MAXSTATICS) {	; Already full? 
		return;						; Get out! 
	}
	StaticPtr = &statics[numstatics];	; Get pointer to the record 

; drop bonus items on closest tile, rather than goal tile (unless it is a closing door) 

	x = ActorPtr->x >> FRACBITS;
	y = ActorPtr->y >> FRACBITS;
	tile = tilemap[y][x];
	if ( (tile&TI_BLOCKMOVE) && !(tile &TI_ACTOR) ) {
		x = ActorPtr->goalx;
		y = ActorPtr->goaly;
	}
	StaticPtr->pic = shape;
	StaticPtr->x = (x<<FRACBITS)|$80;
	StaticPtr->y = (y<<FRACBITS)|$80;
	StaticPtr->areanumber = ActorPtr->areanumber;
	tilemap[y][x] |= TI_GETABLE;		; Mark as getable 
	++numstatics;		; A new static 
}

***********************************
*
*  void KillActor(a0.l *Actor)
*
* Kill an actor
* Also drop off any items you can get from a dead guy.
*	
***********************************

void KillActor(actor_t *ActorPtr)
{
	Word x,y;
	
	GivePoints(classinfo[ActorPtr->class].points);	; Award the score 
	switch(ActorPtr->class) {	; Drop anything special? 
	case CL_SS:
		PlaceItemType(S_MACHINEGUN,ActorPtr);	; Give a gun 
		break;	
	case CL_OFFICER:
	case CL_MUTANT:
	case CL_GUARD:
		PlaceItemType(S_AMMO,ActorPtr);	; Drop some ammo 
		break;
	case CL_HANS:
	case CL_SCHABBS:
	case CL_TRANS:
	case CL_UBER:
	case CL_DKNIGHT:
		PlaceItemType(S_G_KEY,ActorPtr);	; Drop a key 
		break;
	}
	++gamestate.killcount;		; I killed someone! 
	ActorPtr->flags = FL_DEAD;	; remove old actor marker
	tilemap[ActorPtr->goaly][ActorPtr->goalx] &= ~TI_ACTOR;
	x = ActorPtr->x >> FRACBITS;
	y = ActorPtr->y >> FRACBITS;
	tilemap[y][x] |= TI_BODY;	; body flag on most apparant, no matter what 
	NewState(ActorPtr,classinfo[ActorPtr->class].deathstate);	; start the death animation 	
}

***********************************
*
*  void DamageActor(d0.w damage,a0.l *Actor)
*
* Does damage points to enemy actor, either putting it into a stun frame or
* killing it.
* Called when an enemy is hit.
*	
***********************************

static Word PainTick;
void DamageActor(Word damage,actor_t *ActorPtr)
{
	stateindex_t pain;
	
	madenoise = TRUE;	; You made some noise! 

; do double damage if shooting a non attack mode actor

	if ( !(ActorPtr->flags & FL_ACTIVE) ) {
		if (difficulty<3) {		; Death incarnate? 
			damage <<= 1;
		}
		FirstSighting(ActorPtr);			; Put into combat mode
	}

	if (damage >= ActorPtr->hitpoints) {	; Did I kill it? 
		KillActor(ActorPtr);				; Die!! 
		return;
	}
	
	ActorPtr->hitpoints -= damage;		; Remove the damage 
	if (ActorPtr->class == CL_MECHAHITLER && ActorPtr->hitpoints <= 250 && ActorPtr->hitpoints+damage > 250) {
	; hitler losing armor 
		PlaySound(SND_SHIT);	; Remove armor 
		pain = ST_MHITLER_DIE1;
	} else {
		if ((ReadTick() - PainTick) >= 30) {
			PainTick = ReadTick();
			PlaySound(SND_PAIN);		; Ow!! 
		}
		pain = classinfo[ActorPtr->class].painstate;	; Do pain 
	}
	if (pain) {	; some classes don't have pain frames 		
		if (ActorPtr->state != pain) {	; Already in pain? 
			NewState(ActorPtr,pain);
		}
	}
}

***********************************
*
*  void A_Throw(a0.l *Actor)
*
* Throw a Missile at the player
*		
***********************************

void A_Throw(actor_t *ActorPtr)
{
	Word angle;
	int	speed;
	missile_t *MissilePtr;
	
	PlaySound(SND_ROCKET|$8000);
	MissilePtr = GetNewMissile();		; Create a missile 
	MissilePtr->x = ActorPtr->x;
	MissilePtr->y = ActorPtr->y;
	MissilePtr->areanumber = ActorPtr->areanumber;

	; get direction from enemy to player 
	angle = PointToAngle(ActorPtr->x,ActorPtr->y);
	angle >>= SHORTTOANGLESHIFT;
	speed = costable[angle];
	speed = speed/5;
	MissilePtr->xspeed = -speed;
	speed = sintable[angle];
	speed = speed/5;
	MissilePtr->yspeed = speed;
	MissilePtr->pic = S_NEEDLE;		; Hurl a needle 
	MissilePtr->flags = MF_HITPLAYER | MF_HITSTATICS;	; Can hit the player 
	MissilePtr->type = MI_NEEDLE;	; Needle missile 
}

***********************************
*
*  void A_Launch(a0.l *Actor)
*
* Launch a rocket at the player
*		
***********************************

void A_Launch(actor_t *ActorPtr)
{
	Word angle;
	int	speed;
	missile_t *MissilePtr;
	
	PlaySound(SND_ROCKET|$8000);
	MissilePtr = GetNewMissile();
	MissilePtr->x = ActorPtr->x;
	MissilePtr->y = ActorPtr->y;
	MissilePtr->areanumber = ActorPtr->areanumber;

	; get direction from player to boss
	angle = PointToAngle (ActorPtr->x,ActorPtr->y);
	angle >>= SHORTTOANGLESHIFT;
	speed = costable[angle];
	speed = speed/5;
	MissilePtr->xspeed = -speed;
	speed = sintable[angle];
	speed = speed/5;
	MissilePtr->yspeed = speed;
	MissilePtr->pic = S_ENMISSILE;	; Rocket 
	MissilePtr->flags = MF_HITPLAYER | MF_HITSTATICS;
	MissilePtr->type = MI_EMISSILE;
	A_Shoot(ActorPtr);	; also shoot a bullet 
}

***********************************
*
*  void A_Scream(a0.l *Actor)
*
* Scream a death sound
*		
***********************************

void A_Scream(actor_t *ActorPtr)
{
	Word Sound,i;
	
	Sound = classinfo[ActorPtr->class].deathsound;	; Get the sound # 
	if (Sound==SND_EDIE) {		; Normal death sound? 
		if (w_rnd()&1) {		; Play one randomly 
			++Sound;
		}
		i = 0;
		do {
			StopSound(NaziSound[i]);	; Kill all Nazi voices 
		} while (++i<4);
	}
	PlaySound(Sound);		; Play the sound 
}

***********************************
*
*  void A_Thud()
*
* Body hitting the ground
*		
***********************************

void A_Thud(actor_t *ActorPtr)
{
	PlaySound(SND_BODYFALL);
}

***********************************
*
*  void A_Victory()
*
* You win the game!
*		
***********************************

void A_Victory(actor_t *ActorPtr)
{
	playstate = EX_COMPLETED;
}

***********************************
*
*  void A_HitlerMorph(a0.l *Actor)
*
* Drop Hitler's armor and let hitler run around
*		
***********************************

void A_HitlerMorph(actor_t *ActorPtr)
{
	missile_t *MissilePtr;
	
; Use an inert missile for the armor remnants 

	MissilePtr = GetNewMissile();
	MissilePtr->x = ActorPtr->x;	; Pass the armor x,y 
	MissilePtr->y = ActorPtr->y;
	MissilePtr->areanumber = ActorPtr->areanumber;
	MissilePtr->xspeed = 0;	; No motion 
	MissilePtr->yspeed = 0;
	MissilePtr->flags = 0;
	MissilePtr->type = -1;			; Maximum time 
	MissilePtr->pic = S_MHITLER_DIE4;	; Set the picture 
	ActorPtr->class = CL_HITLER;	; Convert to true hitler 
	ActorPtr->speed = 40/4;		; faster without armor
}

;*********************************

	Try to damage the player, based on skill level and player's speed
		
*********************************

void A_Shoot(actor_t *ActorPtr)
{
	Word damage;		; Damage to inflict 
	Word distance;
	
	if (!areabyplayer[MapPtr->areasoundnum[ActorPtr->areanumber]]) {	; In the same area? 
		return;
	}

	madenoise = TRUE;	; I made a sound! 
	if (ActorPtr->class >= CL_HANS) {		; Boss? 
		PlaySound(SND_BIGGUN|$8000);	; Boom! 
	} else {
		PlaySound(SND_GUNSHT|$8000);	; Bang! 
	}
	
	if (!CheckLine(ActorPtr)) {	; Player is behind a wall
		return;			; Can't shoot! 
	}
	distance = CalcDistance(ActorPtr);	; How far? (0-4095 range) 

	if (distance >= TILEGLOBAL*16) {	; Too far away? 
		return;
	}

	if (ActorPtr->class == CL_OFFICER || ActorPtr->class >= CL_HANS) {	; better shots 
		if (distance < (16*16)) {
			distance = 0;		; Zap the distance 
		} else {
			distance -= (16*16);
		}
	}

	if (playermoving) {	; harder to hit when moving
		if (distance >= (224*16)) {
			return;
		}
		distance += (32*16);
	}

; see if the shot was a hit

	if ((w_rnd()*16)>distance) {
		switch(difficulty) {
		case 0:
			damage = (w_rnd()&3)+1;
			break;
		case 1:
			damage = (w_rnd()&7)+1;
			break;
		default:
			damage = (w_rnd()&7)+3;
		}
		if (distance<(32*16)) {
			damage <<= 2;
		} else if (distance<(64*16)) {
			damage <<= 1;
		}
		TakeDamage(damage,ActorPtr->x,ActorPtr->y);	; Hit the player (Pass the killer's x,y) 
	}
}

;*********************************

	Bite the player
		
*********************************

void A_Bite(actor_t *ActorPtr)
{
	Word dmg;
	
	PlaySound(SND_DOGBARK);	; Take a bite! 
	if (CalcDistance(ActorPtr)<=BITERANGE) {	; In range? 
		switch (difficulty) {
		case 0:
			dmg = (w_rnd()&3)+3;	; Small bite 
			break;
		case 1:
			dmg = (w_rnd()&7)+3;	; Medium bite 
			break;
		default:
			dmg = (w_rnd()&15)+4;	; BIG bite 
		}
		TakeDamage(dmg,ActorPtr->x,ActorPtr->y);	; Pass along the damage 
	}
}
	endc

**********************************
*
*  dx.w macro CalcDistance an.l *Actor, dx.w, dy.w
*
* Return the distance between the player and this actor
*		
**********************************

CalcDistance	macro
		move.l	SprX(\1),\2
		sub.l	player.x(pc),\2
		move.w	\2,\3
		swap.w	\2

		neg.w	\2		; abs(Actor->y - player.y)
		bmi.s	*-2
		neg.w	\3		; abs(Actor->x - player.x)
		bmi.s	*-2

		cmp.w	\2,\3
		bls.s	.\@break
		exg.l	\2,\3		; Return the larger 
.\@break
		endm

	ifeq	1
;*********************************

	Called every few frames to check for sighting and attacking the player
		
*********************************

Word shootchance[8] = {256,64,32,24,20,16,12,8};

void A_Target(actor_t *ActorPtr)
{
	Word chance;	; % chance of hit 
	Word distance;	; Distance of critters 
	
	if (!areabyplayer[MapPtr->areasoundnum[ActorPtr->areanumber]] || !CheckLine(ActorPtr)) {
		ActorPtr->flags &= ~FL_SEEPLAYER;	; Can't see you 
		return;
	}
	
	ActorPtr->flags |= FL_SEEPLAYER;		; I see you 
	distance = CalcDistance(ActorPtr);		; Get the distance 
	
	if (distance < BITERANGE) {	; always attack when this close 
		goto attack;
	}

	if (ActorPtr->class == CL_DOG) {	; Dogs can only bite 
		return;
	}
		
	if (ActorPtr->class == CL_SCHABBS && distance <= TILEGLOBAL*4) {	
		goto attack;		; Dr. schabbs always attacks 
	}

	if (distance >= TILEGLOBAL*8) {		; Too far? 
		return;
	}
			
	chance = shootchance[distance>>FRACBITS];	; Get the base chance 
	if (difficulty >= 2) {
		chance <<= 1;		; Increase chance 
	}
	if (w_rnd() < chance) {
attack:		; go into attack frame
		NewState(ActorPtr,classinfo[ActorPtr->class].attackstate);
	}
}	else

		*temporary*
chance		=	28

A_Target	bsr.w	w_rnd
		cmpi.w	#chance,d0
		bhs.s	.break

		movea.l	class(a0),a1		; Get pointer to actor class
		move.w	cattackstate(a1),d0	; Get my attackstate
		bsr.w	NewState


.break		rts


A_Shoot		btst.b	#FL_SEEPLAYER,flags(a0)	; Only try to shoot a visable player
		beq.s	.break			; Replace with "CheckLine" later on

		move.l	a0,-(sp)
		movea.l	SND_GUNSHT(pc),a0
		bsr.w	PlaySound
		movea.l	(sp)+,a0
.break		rts

	endc

	ifeq	1
;*********************************

	MechaHitler takes a step
		
*********************************

void A_MechStep(actor_t *ActorPtr)
{
	PlaySound(SND_MECHSTEP|$8000);	; Step sound 
	A_Target(ActorPtr);	; Shoot player 
}
	endc

**********************************
*
*  void T_Chase(a0.l *Actor)
*
* Chase the player
*		
**********************************

T_Chase		move.b	flags(a0),d7
		btst.l	#FL_NOTMOVING,d7; If still centered in a tile, try to find a move 
		beq.s	.moving

		btst.l	#FL_WAITDOOR,d7	; Waiting for a door to open
		beq.s	.no_door

		*bsr.w	TryWalk
		bsr.w	SelectChaseDir

.no_door	btst.b	#FL_NOTMOVING,flags(a0)
		beq.s	.moving
		rts			; Still blocked in 


		; OPTIMIZE: integral steps / tile movement 
		; Cover some distance

.moving		*moveq.l	#1,d7
		*mulu.w	ticcounter(pc),d7

		move.w	ticcounter(pc),d7
		lsr.w	d7

		*cmpi.w	#mlimit,d7	; Clamp value to less then a block at a time for slow machines
		*bls.s	.trymove
		*move.w	#mlimit,d7

.trymove	tst.w	d7
		ble.s	.return

		move.w	distance(a0),d0
		cmp.w	d0,d7		; move < Actor->distance?
		bhs.s	.smallstep

		move.w	d7,d0		; Move one step 
		bra.w	MoveActor

		; Reached goal tile, so select another one

.smallstep	sub.w	d0,d7		; move -= Actor->distance
		bsr.w	MoveActor	; Move the last 1 to center
		bsr.w	SelectChaseDir	; Directly chase the player 

.next		btst.b	#FL_NOTMOVING,flags(a0)
		beq.s	.trymove	; Object isn't blocked in

.return	
A_Null		rts
	


***********************************
*
*  void MoveActors()
*
* Move all actors for a single frame
* Actions are performed as the state is entered
*		
***********************************


		** temporary **
A_NULL		=	A_Null
A_TARGET	=	A_Target	** temporary **
A_SHOOT		=	A_Shoot		** temporary **
A_BITE		=	A_Null
A_THROW		=	A_Null
A_LAUNCH	=	A_Null
A_HITLERMORPH	=	A_Null
A_MECHSTEP	=	A_Null
A_VICTORY	=	A_Null
A_SCREAM	=	A_Null
A_THUD		=	A_Null

T_NULL		=	A_Null
T_STAND		=	T_Stand
T_CHASE		=	T_Chase


MoveActors	move.w	NumActors,d7
		bmi.s	.break			; No actors to check?

		lea.l	ActorList,a0		; Init the pointer to the actors

.actorloop	btst.b	#FL_ACTIVE,flags(a0)	; Did this actor spot me yet?
		beq.s	.skip

		lea.l	states,a5		; Get the current state
		adda.w	state(a0),a5

		move.w	ticcounter(pc),d6	; Count down the time
		sub.w	d6,tics(a0)
		bpl.s	.keepstate
		

		; Change state if time's up
		move.w	snext(a5),d6		; Set the next state
		move.w	d6,state(a0)

		lea.l	states,a5		; Get the new state ptr
		adda.w	d6,a5

		move.w	stictime(a5),tics(a0)		; Reset the time
		move.l	sshapenum(a5),SprShape(a0)	; Set the new picture #

		movem.l	d7/a5,-(sp)
		movea.l	sthink(a5),a4		; Action think
		jsr	(a4)			; Call the code
		movem.l	(sp)+,d7/a5

.keepstate	move.w	d7,-(sp)	
		movea.l	saction(a5),a4		; Perform the action
		jsr	(a4)
		move.w	(sp)+,d7

.skip		bclr.b	#FL_SEEPLAYER,flags(a0)	; Mark invisable again *

		lea.l	actor_t(a0),a0		; Next entry
		dbra	d7,.actorloop

.break		clr.w	ticcounter
		rts