* Right...
* I believe you wanted to know:
* 1> HOW to crack it
* 2> HOW I figured out how to crack it
*
* Answers...
* 1> Run this program!!! Nah, alright then...
* Now, Rob (the nice bloke) doesn't like MonST2 at all (you may have
* noticed), so first thing he does is he checks all the system vectors,
* e.g. TRAPs, anything important at all really... including GEM vectors
* in the system variables area. So you have to crack the damn thing from
* a fully automatic program that runs the protected program from within
* itself WITHOUT taking over any vectors.
* Now, Rob is not going to put himself out of a job by making the perfect
* protection, so he leaves loopholes in for us to play with (ask Birdy,
* he's mates with him!). Old loopholes included being able to Alt-Help into
* the code, being able to reset and save memory, etc. The current ones are
* that he doesn't check the keyboard interrupt or the HBL... Zippy (Medway)
* uses a keyboard interrupt (not quite sure exactly HOW), but I use a far
* superior method of sticking something in $120 which continually checks
* a certain part of the protected program to see if it has decrypted or
* not. If it hasn't, it continues normally. If it has changed (ie., it's
* been decrypted, then I stop everything, restore the exceptions (because
* Rob generally fucks them up), and from various things, figure out how big
* the unencrypted file is, and then save it.
*
* 2> Now, how did I figure out how Rob's routines were working?
* Bloody hell, talk about an awkward question! Well, as you can see from
* the loopholes bit above, I've been zapping his protections for months, so
* I've been following all his little upgrades from day 1. (Back in Copylock
* version 1.0 days...) You should have noticed that he puts something in
* the ILLEGAL and TRACE exceptions, and that's a major part of making any
* monitor useless. He jumps in and out of these vectors all the time,
* modifying his own code and re-encrypting it as he goes, so FORGET ABOUT
* TRYING TO ACTUALLY SEE WHAT HIS CODE DOES. I knew how to find a way to
* crack it by using the old method of... (big cracker secret coming up)...
* TRIAL and ERROR!!!!!!!!!!!!!!!! !!!!!!!!! (and !!!!!!!!!!)
* I tried every vector I could think of until I found one that his code
* didn't take a dislike to, and then stuck with it. Then I fucked about for
* two hours or so when I got the latest version of his protection, stopping
* his code after different intervals, trying to find the perfect place at
* which to stop it (which is AFTER decryption, but BEFORE relocation).
* Then I experimented with the registers that I had at those points, seeing
* where they pointed, fucking about with those... I eventually found the
* right place to monitor to catch the program after decryption... but
* unfortunately there doesn't seem to be a 100% safe way to catch it before
* it relocates the decrypted executable file. My routine only does it 2 out
* of 3 times, so if the file it produces is knackered, run it again!
* I probably haven't explained that at all well, have I?? Well tough...
* cracking is really 50 % trial and error, 49.9 % intelligent logical
* deduction (Sherlock Holmes!), and .1 % Sherbet Lemons.
* What else can I say???????

* When this routine manages to save out the file, complete with exec header
* and relocation table, it sometimes fucks up in another way, by saving out
* a prg that is already relocated. But seeing as you have the relocation
* table intact, you can just derelocate it, can't ya?

*** ROB NORTHEN EXTERNAL PROTECTION CRACKER ***
* For the new version as used in Castle Master
* This is not perfect... it will run the program and save the decrypted
* PRG onto drive B. Sometimes...
* (And as soon as he updates his protection, this is useless!)

start	pea	(end-start)+256.w
	pea	start-256(pc)
	pea	$4a0000		reserve memory
	trap	#1
	lea	12(sp),sp

	lea	stack(pc),sp

	clr.l	-(sp)
	move.w	#$20,-(sp)		supervisor
	trap	#1

	pea	input(pc)
	move.w	#9,-(sp)		input prompt
	trap	#1
	pea	filename(pc)
	move.w	#9,-(sp)
	trap	#1
	pea	cursor(pc)
	move.w	#9,-(sp)
	trap	#1
	lea	18(sp),sp

	pea	inputline(pc)
	move.w	#$a,-(sp)		input filename
	trap	#1
	addq.l	#6,sp

	pea	envcom(pc)
	move.l	(sp),-(sp)
	pea	filename(pc)
	pea	$4b0003		load and set up
	trap	#1
	lea	16(sp),sp
	tst.l	d0
	bmi.s	error

	move.l	d0,a0		basepage addr

	lea	12(a0),a0		to text len pointer
	move.l	a0,compare+6		write addr of that
	move.l	(a0),compare+2	write byte there

	lea	$8.w,a0		save all exception
	lea	tex(pc),a1		vectors, interrupts,
	move.w	#($200-$8)/2-1,d1	etc. etc.
save	move.w	(a0)+,(a1)+
	dbf	d1,save

	move.l	$114.w,oldtimerC+2	save old timer C
	move.l	#mytimerC,$114.w	patch my timer C

	clr.l	-(sp)
	move.l	d0,-(sp)
	clr.l	-(sp)
	pea	$4b0004		run rob's shit...
	trap	#1
** never gets to here **

error	pea	text(pc)
	move.w	#9,-(sp)		error message
	trap	#1
	move.w	#8,-(sp)		wait for key
	trap	#1
	addq.l	#8,sp
	clr.w	-(sp)		bye!
	trap	#1



mytimerC	eor.w	#$77,$ffff8240	muck up colors

	movem.l	d0-d7/a0-a6,-(sp)
* these 00000000s are overwritten -- see above
compare	cmp.l	#$00000000,$00000000	decrypted yet?
	beq	notyet		no

	move.w	#$2700,sr		yes! kill interrupts
	move.w	#$70,$ffff8240.w	green screen
	lea	tex(pc),a0		restore exceptions etc.
	lea	$8.w,a1
	move.w	#($200-$8)/4-1,d0
copy	move.l	(a0)+,(a1)+
	dbf	d0,copy

	move.b	#7,$484.w		keyclick on (ok, maybe)

	clr.l	$426.w		kill rob's anti-reset
	clr.l	$42a.w

	movem.l	(sp)+,d0-d7/a0-a6

	move.l	2(sp),a6		a6=text
	lea	-256(a6),a6		a6=basepage
* create an exec header
	move.w	#$601a,228(a6)	exec header
	move.l	12(a6),230(a6)	write text len
	move.l	20(a6),234(a6)	write data len
	move.l	28(a6),238(a6)	write bss len
	lea	228(a6),a5
	move.l	2(a5),d0
	add.l	6(a5),d0
	add.l	#32,d0
	move.l	d0,len+2
	clr.w	-(sp)
* save using same filename to drive B
	move.b	#'B',filename
	pea	filename(pc)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	pea	(a5)
len	pea	0
	move.w	d0,-(sP)
	move.w	d0,d7
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
* die now, because the system is probably shot to hell anyway
	jmp	$fc0000

notyet	movem.l	(sp)+,d0-d7/a0-a6
oldtimerC	jmp	0		do old timer C


	data
	ds.l	400
stack	ds.l	1
envcom	dc.w	0		null environment/command

text	dc.b	27,"E",7,"File not found. Hit it...",0

input	dc.b	27,"E",27,"e","CrakRob by The Alien.",13,10,10
	dc.b	"Cracks Rob Northen's latest",13,10
	dc.b	"external protection...",13,10,10
	dc.b	"Program to crack? >",0
cursor	dc.b	27,"e",27,"Y",37,51,0

inputline	dc.b	128		max 128 chars
	dc.b	13		8 given chars
filename	dc.b	"A:\HACK_V2.PRG"		default filename
	bss
	ds.b	120		128 chars buffer

tex	ds.l	$200-$8/4		space to save exceptions
end