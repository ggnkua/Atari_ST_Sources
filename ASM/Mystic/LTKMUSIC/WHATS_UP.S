*****************************************************************
* Music explanation file					*
* Nota bene: this is no executable source file.			*
* The instructions given are designed only as examples.		*
*****************************************************************

*   To use the music files there are two important addresses. Suppose
* you loaded your music file by this line:

music		INCBIN	"*.SMB"			load the music data & rout

* then you can control the music in the following ways. First of all you
* must install an interrupt like this, e. g. a VBL for 50Hz music:

		move.l	#vbl_interrupt,$70.w
		...
vbl_interrupt	movem.l	d0-d4/a0-a3,-(sp)	Used by routine
		bsr.s	music+2			Terminated by rts
		movem.l	(sp)+,d0-d4/a0-a3	Restore registers
		rte				See you next time

* Then you have the following possibilities. The instruction:

		move.w	#SONGNUM*4+$FF00,music	start song

* signalizes to the routine that you want to initialize a song. It will
* then be initialized in the next VBL and played in the following VBLs.
* Note that by default the routine automatically initializes and plays
* song 0 if you do not tell it to do otherwise.
* The routine has finished initializing when (music) contains
* SONGNUM*4+$0000, i. e. you may restart the currently playing song by a

		move.b	#$FF,music		restart song

*   The routine is capable of playing half-soundtracked music, which means
* that one voice (Channel C) plays soundtrack samples (4-bit logarithmic
* to all you pros out there). The routine uses Timer D for this with
* variable frequencies. Unfortunately the quality of these samples is
* only acceptable when not played too loud, that is why half-soundtrack
* music often sounds more feeble. Also the quality worsens when you use
* half-soundtrack in combination with an upper border overscan routine
* (cf. the intro on this disk). Especially instruments whose main
* frequencies are in a relatively low range suffer from this, e. g. bass
* drums.
*   To quit playing, just

		move.w	#$FFFF,music		stop sound

*   This will stop all sounds and the Timer D routine. The main routine
* thereafter only waits until a new init command arrives. Be aware that the
* Timer D vector, data and control registers will not be restored - only
* bit 4 of the interrupt mask register A is cleared. If you need to use
* the baud generator interrupt again afterwards, you have to save and
* restore its parameters for yourself.
* You might want to check and wait until the routine tells you that sound
* has been turned off. Use this piece of code to do so:

wait_until_off	cmpi.w	#$FFFE,music		sound now off?
		bne.s	wait_until_off		not yet ...

*   If you come across an SMB-file you do not know, just look at it in
* ASCII. You will find some useful information there, the number of songs,
* the frequency of the interrupt used to call the routine and the version
* description. Originally I only put in this info for my personal use, but
* I do not see why you should not profit from it as well. That is the
* reason why I wrote it in ASCII. I only ask you not to modify any of the
* texts there, I like to know where a music comes from when I later come
* across it on other disks. As to the version info, the place where it
* stands will be used as storage space on execution of the routine, so
* please keep your files with the complete info (do not save after
* executing any music).

* So that's all for this time. I hope you enjoy listening to the songs and
* that you find them useful to include into your own demos if you're tired
* of using the same music files all the time.
*   If you want to contact us, write to:

*		  MYSTIC
*		  32, Rue des Rosiers
*		F-31140 Fonbeauzard
*		  FRANCE.

* I have no time for greetings now, so I ask you to read the scroll in the
* Mystic intro I put on this disk (coded by my humble self) if you're
* interested. I have to apologize for the (relative) illegibility of the
* scrolline, but as I had to change concept in the last minute (well,
* nearly) I could do nothing about it. (The change was asked for by
* Quicksilver, and it consisted in rearranging parts of the demo's design.
* Okay, so the new version is more beautiful, but as I mentioned earlier it
* does not only have advantages ...)

* Bye for now,

*				LTK of MYSTIC on 16/DEC/1990.


