		HACKING LANCE(v13)

	The 25 KHz routine project.


Full credits of the Lance ideas go to Lance of course.

I added a few changes:
- i split the DMA register settings (mt_Paula) from the mixer (new mt_mixer) 
so the order now after we waited for the 50 Hz event is: mt_Paula to set the 
DMA, mt_music to get new data from Protracker, mt_mixer to prepare the new 
DMA buffer;
- i added a memory allocation system (i like to work like that);
- i adapted the whole thing to position independent code (i like this);

And, i created a 25 KHz version of the whole stuff.
And now, i added a way to select the DMA replay rate and added a 12.5 KHz replay option.
New update (v5): a no_volume_option is now available in the source. For mods that do
not use "on the fly" volume control, this option allows to save 5% CPU time. Only the
default sample volume will be considered. "On the fly" volume from commands 5, 6, 7, A, C,
EA and EB will be ignored.
New update (v6): the "Trash play" option is now available by changing z_trash_idx.
Value 2 is a normal play. Value can go up to 32 digi buffers.
This allows to save a some % CPU at the peaks using memory.
New update (v7):
- 12.5 KHz speed-up keeping Lance strategy;
- added automatic "no volume control" detection: with this feature active the
value set in Z_VOLUME_ACTIVE will be overwritten;
- correct 3 base source failures (see Annex1);
V8 corrects the short loops problem (in fact any loop where Rep. Start = 0)
V9 starts beating Lance: 1.5% CPU gain for all cases.
The Protracker handler was now separated to allow its update in the future.
V9A improves the Protracker data handler to gain at least 1% CPU.
V10 improves the average CPU load.
Gains versus version 8:
- peak: 2.3%
- average: 3%
V11 update offers:
- global volume control: z_global_volume $0000 -> $FFFF (granularity of LCM is much smaller)
- very small speed increase
- minor bug corrections
- octave 3 cheat option for demo programers (gains CPU time lowering quality)
Octave 3 cheat option idea by Evil / DHS.
V12 corrects a Note Delay bug from the original source (Desert Dream mod).
If you don't believe me, you can test desertd4.mod with the old or original code
and with any reference soundtracker, Winamp or Milky Tracker.
V12 also adds a new cheat possibility called "read skips".
It is similar to octave 3 cheat but you can specify the amount of cheating.
12.5 KHz replay is not affected.
25 KHz replay is only affected by values above 7.
50 KHz replay can be affected by the full set of 1..13 values.
If this feature is active, the octave 3 cheat is disabled.
A low value will only impact the top octave 3 notes.
A 13 value will impact the full set of octave 3 notes.
Of course, the lower the value, the less CPU time is saved.
V13 corrects and Sample Offset skip bug (from the Amiga copy/pasted source)
and ... brings the BPM implementation.


The files:
==========
hackl00I.s	Version 13 source
hackl00H.s	Version 12 source
hackl00G.s	Version 11 source
hackl00E.s	The source (use variable zreplayfreq to change DMA replay rate)
hackl09A.s	The source (v9A = merge of hackl00E_noPT_004.s / PTHDL004.s)
hackl010.s	The source (v10 = merge of hackl00F_noPT_004.s / PTHDL004.s)
hackl00E_noPT_000.s	Base source without the Protracker handler
hackl00E_noPT_004.s	Base source without the Protracker handler (v9A)
hackl00F_noPT_004.s	Base source without the Protracker handler (v10)
PTHDL000.s	Base version of the Protracker handler
PTHDL004.s	Base version of the Protracker handler (v9A/v10)
hackl50I.prg	Version 13 example program
hackl50H.prg	Version 12 example program
hackl50G.prg	Version 11 example program
hackl50E.prg	The program with 50 KHz/auto volume control and 8 buffers
hackl59A.prg	The program with 50 KHz/auto volume control and 8 buffers (v9A)
hackl510.prg	The program with 50 KHz/auto volume control and 8 buffers (v10)
illusion.mod	MOD by Chromix used in the famouse STE screen in the demo from NexT
desertd2.mod	Kefrens Desert Dream MOD used in the winning STNICC 2000 demo
desertd4.mod	A small piece of the above
7theaven-mod	A big BPM mod
pt_src50_2013.s	The commented original code and the design to go down to 25 KHz
hacking_lance_10.xls	Test results with several mods
worsmod3.mod	Worst case mod using all octaves
worsmod2.mod	Worst case mod limited to 2 octaves
read_me.txt	This file


At the end, when pressing space, three 16 bit hex numbers will appear.
If you multiply those values by 20, you will get the free VBL time.
You can then divide by 160256 to get the value in %.
The first is the average value.
The second is the best case.
The last one in the worst case that is important for 1 VBL demos.

With the example mod one gets:

25 KHz	17B8 1A72 13CA
50 KHz	15F2 18E2 114F

In decimal and multiplied by 20:

	Average	Max	Min
25 KHz	121440	135400	101320
50 KHz	112360	127400	 88620
Delta	  9080	  8000	 12700

Now in CPU %:

	Average	Max	Min
25 KHz	75.78	84.49	63.22
50 KHz	70.11	79.50	55.30
Delta	 5.67	 4.99	 7.92

So used CPU % is:

	Average	Min	Max
25 KHz	24.22	15.51	36.78
50 KHz	29.89	20.50	44.70



All work done without an STE, under STEem and Hatari with Devpac 1.24.


Enjoy it and use it if you want.

Paulo Simoes / 10th May 2013




Annex1: Base errors
===================

1- Feeder correction:
---------------------

36 tones and not 37 here:

	and.w	#$0fff,d2
	moveq	#0,d0
	move.b	n_finetune(a6),d0
**	mulu	#37*2,d0
	mulu	#36*2,d0
	lea	mt_periodtable(pc),a0
	add.l	d0,a0
	moveq	#0,d0
mt_stploop
	cmp.w	0(a0,d0.w),d2
	bcc.s	mt_stpfound
	addq.w	#2,d0
**	cmp.w	#37*2,d0
	cmp.w	#36*2,d0
	bcs.s	mt_stploop
	moveq	#35*2,d0
mt_stpfound

2- Amiga clock correction:
--------------------------

**mt_amiga_freq	dc.l	7090000

moved to:

zs_amiga_freq	dc.l	7093790	values 7093790 PAL	7159090 NTSC

3- Finetune correction:
-----------------------

Lance original source is only prepared for VBL read speeds from 75 to 625 bytes.
But finetune on B-3 may required speeds up to 663 bytes per VBL.
As a consequence finetune on B-3 does not work correctly with the base source.
Updated source allows speed from 78 to 663, because speeds from 75 to 77 are useless.
This change looks like a piece of cake but it was not ...
