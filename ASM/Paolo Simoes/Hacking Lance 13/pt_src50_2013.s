;------------------------------------------------------------------------
;
;			Hacking Lance
;				by Paulo Simoes 	February 2013
;
; 1 Introduction
; --------------
; The only purpose of this "hacking" is to try to find out a way to have
; a 25 KHz replay at a better % CPU than the existing 50 KHz version.
; I was informed about this routine by Leonard from Oxygene in 2004 but
; as i took a superficial look, i found out that the tricks used were 
; really specific and could not be ported to my core program used in
; Hextracker and YM50K that i built in 1991 and 1992.
; So the main hacking was done these last few days.
; The text that follows reflects that hacking and my experience with this
; Soundtracker business.
;
; 2 The Sountracker challenge
; ---------------------------
; Soundtracker music was in the old days one of the main arguments for
; Amiga owners to nagg the ST owners.
; Let's face it. The Paula Amiga soundchip is really powerfull.
; So let's see what is the best it can do.
; It uses the Amiga master clock to read the samples in a controlable
; rate by means of a divider that can be set from $000 to $3FF.
; Loops and end of sample data are controlled by the HW.
; Those 8 bit signed samples will be then volumed by a 64 volume register
; which means a signed multiplication giving a 14 bit result.
; Those 4 14-bit values, one per real digital voice, will be mixed into
; two 15 bit values and sent at around 28 KHz(A500) to two DACs that will
; produce the Left and Right stereo analog signals.
; Finally, a low pass filter can be activated to reduce noice sent to the
; speakers.
; All this stuff is done by hardware with plenty of DMA channels to read
; from the memory costing almost 0 to the CPU ...
; And what does the Atari ST have to do this kind of job ?
; Well for the pre-STE models, known mostly as STFs, the Atari ST has
; nothing except SW and an old YM2149 soundchip.
; The Atari STE has a DMA that can read from memory 1 sample in mono or 2
; interleaved samples in stereo that will be sent to 8 bit DACs to
; produce the mono analog signal or the Left and Right stereo analog
; signals at 6.25 KHz, 12.5 KHz, 25 KHz and 50 KHz.
; It is then easy to understand that SW would have to play an important
; part in porting the Soundtracker music to the Atari ST, including the
; Atari STE.
;
; 3 Splitting the challenge in small parts
; ----------------------------------------
; One of the keys to solve any big problem is to divide it in smaller
; problems without loosing the view to the main picture.
; The same applies here.
; Let's start from the end to the beginning with the Paula soundchip
; features.
; At the end, we have low pass filters.
; As we have no hardware to do that on Atari ST and as the cost to do
; this in terms of SW is terribly high thinking about KHz rates, this is
; the first feature to be dropped as we assume the ST will not do that.
; Before that, we have the 15 bits DACs in stereo or the DAC in mono.
; Well, on STF, we have no DAC, so we emulate one by using combinations
; of 4 bit volume levels (registers 8, 9  and 10) on the YM2149
; soundchip with or without tones active (register 7) (Quartet method
; and ST Replay method). The quality of table will define the quality
; of the DAC emulation. That depends on the number of YM2149 voices used
; (1, 2 or 3) and on the selected combinations for each corresponding
; digital level. Stereo is impossible on STF with the base HW so we drop
; the stereo case for STF.
; On STE, we have 8 bit DACs so we should use them and we can do stereo.
; Paula sends data at around 28 KHz(A500) to the DACs.
; The STF has no DMA to send data to its emulated DAC. So that part has
; to be done by SW. Interrupts is the most common solution used to read
; the mixed data and send it via the DAC emulation table to the YM2149.
; One can also do it in a timed way, updating the YM2149 every XXX cycles
; but that is not compatible with better CPUs or better clock speeds.
; The STE has a DMA to do this job. We just have to store the mixed data
; in the way the DMA wants it to be read and sent to the DACs. In case
; of mono this means a single buffer with the set of 8 bit values to be
; sent to the DAC. In case of stereo, we should have a single buffer with
; interleaved data: 8 bit for the Left DAC followed by 8 bit to the Right
; DAC followed by Left, Right, Left and so on ...
; The next part is the mixer ...
; This where the job starts to be nearly identical both for STFs and STEs
; as the job is to mix 4 voices data to a buffer respecting the STE DMA
; read constraints or the self established rules for STF.
; From this moment on, i will forget the general case and focus only on
; Lance's challenge: 50 KHz replay in stereo on STE.
; Stereo means that the mixer SW will do two times the job to mix two
: voices into one 8 bit value that will be interleaved as the STE DMA
; wants.
; Mixing means mainly adding signed values. To get a 8 bit mixing result
; with 2 voices there are 2 solutions: a convertion via a table like any
; size bits previous mixing result is converted into 8 bit or the speedy
; solution: 7 bit + 7 bit = 8 bit ...
; It is easy to guess which one Lance choosed and which one most of the
; ST Sountracker players choose.
; But the first one is much more accurate to emulate Paula: the 15 bit
; mixing result is converted into 8 bit data to send to the DACs.
; We are now at the point where one should discuss the individual voice
; data.
; Before it is mixed, each voice has to volume the sample data respecting
; the volume set to the sample data.
; Again, this is normally achieved via a lookup table where the sample
; data is converted into volumed sample data.
; We then have the variable speed data reading.
; No HW to do that so it has to be done via SW with memory reading when
; needed via specific addressing modes or pointer increments.
; Finally, we have the loop and end of sample controls. This is the easy
; part as SW can "add" data at the end of the sample to emulate the loop
; with the size of that data corresponding to the maximum data that can
; be read before the pointers are checked which is normally 1 VBL.
;
; 4 Lance's solutions to each small problem
; -----------------------------------------
; Now we will visit again each problem in the reverse order.
; The first choice is that the BPM feature is not emulated by this
; version. This means that the MOD control is done at every VBL.
; This with a replay rate of 50 KHz, this means that we have to update
; the DMA buffer with 50000 / 50 VBLs = 1000 blocks of Left and Right
; data at every VBL. For 25 KHz we would have only 500.
; The dividers for variable speed reading found in the Protacker tables
; go from 108 to 907 (mt_periodtable).
; Considering the european PAL Amiga clock rate of 7.09379 MHz (and not
; simply 7.09 MHz found in this source), this means reading from memory
; at rates from: 7093790/(2x108) = 32841.6 Hz to 7093790/(2x907) = 3910.6
; Hz. Considering the VBLs, this means reading from 32841.6 / 50 = 656.8
; bytes per VBL down to 3910.6 / 50 = 78.2 bytes per VBL for each voice.
; So we have to produce 1000 8 bit mixing values with a maximum of 657
; reads per VBL for each voice. One can see that the maximum read speed
; compared to the mixing speed is lower than 1: 657 / 1000 = 0.657
; This means that we can use the simplest addressing mode for reading:
; move.b (An)+,... or add.b (An)+,...
; This is where we have the first problem at 25 KHz. As we have only to
; produce 500 mixing results per VBL, we have 657 / 500 = 1.314 which is
; bigger than 1 but lower than 2. This means that for a part of the
; dividers one can not apply the simplest addressing mode: one has to
; read 2 times or correct the pointer: move.b (An)+,... move.b (An)+,...
; or addq #1,An move.b (An)+,... This is slower ...
; One can also limit the MOD to use dividers up to the case where we get
; to the limit: 7093790 / 500 updates / 50 VBLs / 2 = 141.9. This means
; dealing with 2.67 octaves instead of 3.
;
;mt_periodtable
; tuning 0, normal
;	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
;	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
;	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
;
; The last 4 values are not usable without addq #1,An inserted ...
;
; Now back to 50 KHz replay, one has to mix two streams read at variable
; speed from memory. How to do that ?
; Lance solution is to divide the VBL in 25 parts where we produce 40
; mixing results (25 x 40 = 1000). At 25 KHz we would have to produce
; only 20 mixing results.
; For each of those 25 blocks, the program will read at two different
; speeds from two samples to mix them.
; To allow that, 23 different reading speed are allowed per block.
; As we have 2 voices mixing, this means that we have 23 possible read
; speeds for voice 0 and 23 possible read speeds for voice 1: 23 x 23 =
; 529 combinations.
; So 529 different code combinations are generated to handle each one of
; the 529 cases (mt_make_mixcode).
; But you will say, we have almost a thousand diferent reading speeds.
; That's right, but we have 25 blocks per VBL. So if we do block 0 at
; speed 13 and block 1 at speed 12 and block 2 at speed 13 and block 3 at
; speed 12 and so on we will get an average speed of 12.5 and the
; listenner will not notice it. That is a first compromise needed for
; memory space reasons: all those code combinations consume memory.
; Now to volume control ...
; Lance choosed to take advantage of the Microwire volume control.
; On STE one can set the volume of both Left and Right stereo signals in
; an independent way.
; So the idea is to volume only 1 of the 2 samples we are mixing.
; Let's do an example: voice 0 has $30 volume and voice 1 has a $20
; volume. You can set the global Microwire volume to the equivalent of
; $30 for a maximum of $40 and volume the voice 1 sample data with the
; relative volume between the two samples: $20/$30 = 0.6667 or 43 in 64.
; The important is to always volume the voice with the lowest volume.
; This is why this routine does not work on Falcon and why it is dificult
; to control the global replay volume. After you have called Lance rout,
; you can change the Microwire volume but you have to respect the set
; relationship between the values found at Left and Right volume.
; If you find 100% for Left and 50% for Right, you can change to 80//40
; or 60//30 or any other 2:1 ration values.
; This Microwire solution has another compromise: the number of volume
; levels available at the Microwire is much less than the 65 Paula levels
; and they are not linear. The converted table can be find here:
;.mt_LCM_vol_tab	
;	dc.w	0
;	dc.w	2,5,7,8,9,10,10,11,11,12,12,13,13,13,14,14
;	dc.w	14,14,15,15,15,15,16,16,16,16,16,16,17,17,17,17
;	dc.w	17,17,17,18,18,18,18,18,18,18,18,18,18,19,19,19
;	dc.w	19,19,19,19,19,19,19,19,19,20,20,20,20,20,20,20
; The relative volume between the two mixing samples is obtaing via a div
; table built at start (mt_make_divtab) with 64x64 = 4096 combinations.
; So Lance only has to read at 2 variable speeds from 2 sources and the
; data from 1 source is volumed (goes via a table) into another value.
; The typical worse case scenario (for time) is the following:
;	move.b	(a0)+,d2	voice 0 data
;	move.b	(a1)+,d1	voice 1 data that goes to D1
;	move.l	d1,a2		that points to the volume table $xxxxxx00
;	add.b	(a2)+,d2	mixing with volumed data
;	move.b	d2,(sp)+
; So here we have the remaing Lance solutions.
; Mixing is done by simple adds so 7 bit samples are used: 7bit + 7bit =
; 8 bit. The reduction to 7 bit can be found at .mt_shift_down.
; STE stereo buffer interleaving problem is solved using the 68000 SP
; protection mechanism that increments the pointer by 2 in case of byte
; access: this was unknown to me until i looked first at this routine in
; 2004 ...
; The volume table is located at a 256 byte even boundary that allows to
; get the volumed converted value in a simple and speedy way. I have a
; similar solution in Hextracker except for real 8 bit samples replay.
; the difference is taht i get a word as a result and so the sample bytes
; have bit 0 set to 0 (reduction to 7 bits) instead of a signed right
; shift like it is done here by Lance.
; For the cases where no read is required then the previous mixed value
; is sent to the buffer or only 1 read is done: this is the job of the
; generated code to take care of each of those cases (mt_make_mixcode).
; All this is compatible with 25 KHz replay except the need to insert a
; addq #1,An for steps bigger than 1 and to reduce the buffer updates to
; 20 per block instead of 40.
; The loop control is done in the general way: 640 bytes are added to
; each sample at the end with the looped sample data in case of loops
; or zeros. This is done at mtloop3 and space for that is reserved here:
;mt_data	incbin	"modules\*.mod"
;	ds.w	31*640/2	;These zeroes are necessary!
; This means that 640 is the maximum number of bytes that Lance expects
; to have to read per VBL. But our calculations point to 657 ...
; May be this was done before Finetune was included. If we do not
; include Finetune, the minimu divider is 113 (mt_periodtable tuning 0).
; 7093790 / (2x113) / 50 VBLs = 627.8 bytes
; The Portamento effects also limit the divider to 113.
; mt_make_tables only starts at 113 keeping the same reading pace for
; dividers below. So if a 108 divider is set by the Finetune, 113 will be
; used.
; Bug or not in the implementation of Finetune, this is not our concern
; now ...
; So we know almost everything now except the core: how is the generated
; code built ? What are the rules ?
; One that is obvious is that registers d0, d1 and d2 are used in their
; byte parts and that the rest of d1 points to the volume table generated
; by mt_make_voltab. a0 and a1 point the the sample data and are
; incremented at each needed read. a2 is used for the volume convertion
; and the data in sent to (sp)+ via a move.b from d0, d1 or d2.
; What remains is the most complex part: when do we need to read from 0,
; from 1, we can use previous data and so on ...
; This is where our analysis of:
; - mt_make_freq
; - mt_make_frame_f
; - mt_make_mixcode
; will be crucial to find out what to change to have a 25 KHz solution
;
; Let's start with mt_make_frame_f.
; That proc is used to fill two very important arrays.
; mt_frame_freq_p points to a table where one finds 551 pointers, one for
; handled read increment in a VBL from 75 bytes to 625 bytes with both
; values included. Depending on the amount of data to be read from a
; sample during a VBL, so depending on the divider (from 113 on), the
; code will dectect how many bytes it needs to read and gets from this
; table the corresponding pointer.
; That pointer will point to a location inside the table pointed by
; mt_frame_freq_t.
; That table contains a serie of 25 words (50 bytes) for each pointer
; from the table pointed by mt_frame_freq_p. SO its length should be
; 551 x 25 = 13775 words or 27550 bytes.
; At this stage i do not understand why Lance reserves 27500 words for it
; here: 	mt_frame_freq	ds.w	27500
; Anyway this data only reflects the pace at which data is read for one
; voice giving us for each of the 25 VBL blocks the selected speed from
; the 23 available from 0 to 22.
; So one word per block, 25 words per VBL and each word with this format:
; [PPPPPPPPPSSSSS00] where [PPPPPPPPP] = [SSSSS] x 23 and SSSSS is 0...22
; Inside the macro mt_channel, for each of the 25 blocks, the value
; for the corresponding frequency divider for one of the voices will be
; "mixed" with the value corresponding to the frequency divider for the
; other voice giving us a pointer to one of the 529 (23 x 23) available
; generated code sub routines to where the program jumps like shown here:
;
;	lea	.mt_return,a6			points to 1st block
;	move.w	(a3)+,d3
;	move.w	(a4)+,d4
;	and.w	d5,d4				isolate 000000000SSSSS00
;	and.w	d6,d3				isolate PPPPPPPPP0000000
;	lsr.w	#5,d3				        00000PPPPPPPPP00
;	add.w	d3,d4				      + 000000000SSSSS00
;	move.l	(a5,d4.w),a2				0000xxxxxxxxxx00 0...528 = 529 ptrs
;	jmp	(a2)
;.mt_return
;    rept	24
;	lea	$16(a6),a6			points to next block
;	move.w	(a3)+,d3
;	move.w	(a4)+,d4
;	and.w	d5,d4
;	and.w	d6,d3
;	lsr.w	#5,d3
;	add.w	d3,d4
;	move.l	(a5,d4.w),a2
;	jmp	(a2)
;    endr
;
; The program comes back from the sub routine with a jmp (a6) where a6
; points to the next block or to the end of the 25 blocks for teh last
; case.
; As this is only handling number of reads and read speeds, changing to
; 25 KHz replay should have no impact here.
;
; We are then left with:
; - mt_make_freq
; - mt_make_mixcode
;
;
; Before we go any thurther, we know enough about Lance routine to safely
; estimate how much CPU cycles per VBL can be gained in going down to 25
; KHz replay.
; Let's divide the main part in 3:
; - reading part;
; - mixing part;
; - storing part;
; As we have seen, if we reduce to 25 KHz replay, then we can only do 500
; reads per VBL. But there are 4 out of the 36 octave notes that require
; more than 500 reads to avoid skipping data: B-3, A#3, A-3 and G#3 with
; dividers 113, 120, 127 and 135 respectively. In fact they would require
; 7093790 / (2 x divider) / 50 VBLs = 628, 591, 559 and 525 reads per VBL
; respectively. As we can only do 500 at 25 KHz, we will skip 128, 91, 59
; and 25 bytes respectively having to insert in the generated code as many
; addq #1,An. The average bytes to skip per note is then: (128+91+59+25)
; / 36 notes = 303 / 36 = 8.42. The clock cycles spent for reading vary
; from 8 (simple read (voice 0)) to 20 (read and volume the data via
; table (voice 1)) and the average is: (8+20)/2 = 14 cycles. The addq
; costs 8 cycles. SO for each read not done, we will save 14-8 = 6 cycles.
; As we do 8.42 reads less in average, we will save 6 * 8.42 = 50.52
; cycles in average.
; In the mixing part, we want to know how many adds we can save. Let's do
; an example that can be considered an average case: a C-2 on one of the
; voices and a C-3 on the other one. A C-2 means aproximately 166.666
; reads per VBL. The correct amount is 7093790 / (2 x 428) / 50 = 165.7.
; A C-3 means twice that amount. To simplify i will use the 166.666 value.
; 166.666 reads out of 1000 updates at 50 KHz means 1 read every 6
; updates. For the C-3, we will have 1 read every 3 updates. At 25 KHz,
; we are down to 1 read every 3 updates and 1 read every 1.5 updates.
; Doing the respective combinations we will get in average at 50 KHz:
; 55.55 simultaneous reads on the two voices, 388.88 reads on one of the
; two voices and 555.55 cases where we just update the buffer with the
; previous mixing result. The same at 25 KHz will result in: 111.11
; simultaneous reads, 277.78 single reads and 111.11 cases where we just
; update the buffer with the previous mixing result. In both cases we
; keep a total of 166.66 + 333.33 = 500 reads. Comparing the two cases,
; this means taht going from 50 KHz to 25 KHz increases the simultaneous
; reads by 55.55 and reduces by 111.11 the single reads. SO in average,
; we have: +55.55 - 111.11 = -55.55 which means 55.55 cases of mixing
; less than before. Each mixing costs a maximum of 8 cycles: move.b
; from the voice register (d0 or d1) to d2 and add.b new one to d2. So
; in total this saves us in average a maximum of 55.55 x 8 = 444.44
; cycles.
; Finally, in the storing part, counting is easy. We have 1000 updates
; at 50 KHz and 500 at 25 KHz so we save 500 updates like this one:
; move.b d2,(sp)+. I assume updating via (sp) with .b would cost the
; same as using any other An despite that specific behaviour that gives
; us the interleaved buffer update. If so, each update costs 8 cyles.
; We save then 500 x 8 = 4000 cycles.
; Adding the 3 parts, we can save up to 50.52 + 444.44 + 4000 = around
; 4495 cycles per mixing. As we have two mixings for Left and Right, we
; can save a maximum of 4495 + 4495 = 8990 cycles by going down to 25
; KHz replay. That represents a maximum of 5.6% of the CPU time.
;
; Still interested ?
;
; If we want to continue, we will have to go down to the real deal.
; Let's look at mt_make_freq.
; This procedure fills a table pointed by mt_freq_list with a serie of
; words with 0 and 1. The table size is 23 x 40 words. For each of the
; 23 available read speeds, it will fill 40 words with 0 or 1. These
; 40 words correspond to the 40 digital buffer updates at 50 KHz for each
; of the 25 VBL code blocks. If a 1 is found then a sample read has to be
; done for that digital buffer update for that voice.
; Looking at the code, one can see that the 23 different speeds relate to
; 23 different increments from 3 to 25 both included. So the minimum read
; bytes from a sample is 3 x 25 VBL blocks = 75 bytes. The maximum read
; bytes is 25 x 25 VBL blocks = 625 bytes for the minimum divider case.
; So first the read step is calculated dividing D0 (number of bytes to
; read) by 40 digital buffer updates. A result below 1 is expected as the
; maximum value for D0 (25) is smaller than 40. The result is then
; rounded if the division rest is bigger than 20 (half of 40). Having now
; a long value with the reading pace per digital buffer update, we add it
; for 40 updates and for each one a check is made is a new integer part
; was reached or if the comma part is bigger than 0.5:
;
;	moveq	#39,d7		40 updates to the digital buffer
;.mt_make_freq	
;	add.w	d2,d1	adds the pace in D2 to the counter in D1
;	negx.w	d4	D4 contains the integer part of the counter
;	neg.w	d4	update D4 with X if the add overflowed
;	move.w	d4,d5	copy result integer part to D5
;	move.w	d1,d6	copy result comma part to D6
;	add.w	d6,d6	if result comma part bigger than 0.5 ($8000) this
;	negx.w	d5	previous add will overflow
;	neg.w	d5	and so we correct the result integer part with X
;	cmp.w	d3,d5		if the new value is lower or equal to the
;	ble.s	.mt_set_zero	previous one then we SET a ZERO in table
;	move.w	d5,d3		otherwise we keep the new value in D3 for
;	moveq	#1,d5		next time and we SET a ONE in the table.
;	move.w	d5,(a0)+		(A0) = 1
;	dbra	d7,.mt_make_freq	40 times
;	addq.w	#1,d0			from 3 to 25 values
;	cmp.w	#26,d0
;	bne.s	.mt_maker
;	rts
;
;.mt_set_zero	
;	moveq	#0,d5
;	move.w	d5,(a0)+		(A0) = 0
;	dbra	d7,.mt_make_freq	40 times
;	addq.w	#1,d0			from 3 to 25 values
;	cmp.w	#26,d0
;	bne.s	.mt_maker
;	rts
;
; Here we have obviously impacts in trying to go down to 25 KHz.
; First one is to reduce everything that is 40 to 20. The division has to
; be done by 20, the round compare value is 10 and the D7 register would
; get 19(20-1) instead of 39(40-1). But that is not all. As we divide by
; 20, the division result can be bigger or equal to 1 for read paces of 
; 20, 21, 22, 23, 24 and 25. These are 6 of the 23 read paces. For those
; cases the code must be updated to allow steps bigger than 1 and may be
; also to store a different value in memory other than 0 or 1 for the
; code generation routine to insert the necessary addq #1,An to skip some
; reads. So this routine has to be completly re-written but only after
; the analysis of the code generation routine: mt_make_mixcode.
;
;
; At last we have mt_make_mixcode that is of course the most complex
; part of this whole code.
; It does not surprise anyone to find here a 40 times dbf loop inside a
; two 23 times dbfs. For each combination of read speeds (23 x 23), we
; have code to generate to update 40 times the digi buffer. For each
; case two values are read from the table generated by mt_make_freq and
; so we can have the following combinations:
; 00 just update digi buffer
; 01 update digi buffer but read from voice 0
; 10 update digi buffer but read from voice 1
; 11 update digi buffer but read from both voices
; On top of that, there is an optimization scheme that compares the
; current combination different from 0 with the next one different from 0
; in order to save CPU time related to registers switches. This includes
; updating the digi buffer with d0 or d1 instead of d2 and other stuff
; not important in the goal to go down to 25 KHz, i think.
;
; So now that have analysed this last procedure, we can identify the full
; impacts both for this procedure as for mt_make_freq in going down to
; 25 KHz.
; mt_make_freq must generate values 0, 1 and 2 instead of 0 and 1.
; 0 will mean no read just as it does now.
; 1 will mean read with 1 byte increment as it does now.
; 2 will mean read with 2 bytes increment so that we add a addq #1,An.
; mt_make_mixcode will have to be changed in order to handle not only the
; 00, 01, 10 and 11 combinations but now 00, 01, 02, 10, 11, 12, 20, 21
; and 22 combinations.
; Every loop in both procs dealing with 40 digi updates will be reduced
; to 20. The divider rounding value for compare will be reduced from 20
; to 10. The division in mt_make_freq must be adapted to handle results
; above 1. The control table size will be reduced in half as well as
; the leas size to go to the next block in mt_make_mixcode.
;
; Last but not least mt_frequency dc.w $0003 has to be changed to $0002.
;
;
; 5 Solution proposal to go down to 25 KHz (changes only)
; -------------------------------------------------------
;
; mt_replay_len	dc.l	1000		500 words instead of  1000
; mt_frequency dc.w $0002			25 KHz replay
; mt_freqer_list	ds.w	23*20
; mt_replay_buf0	ds.w	500
; mt_replay_buf1	ds.w	500
; mt_frame_freq	ds.w	13775	also for the 50 KHz case instead of 27500
; mt_mix_chunk	ds.w	60877	may have to be adapted for 25 KHz
;
; Now mt_make_freq
;
;

mt_make_freq
	move.l	mt_freq_list,a0
	moveq	#3,d0
.mt_maker
	move.l	d0,d1

	moveq	#0,d2				25 KHz => only 20 updates
	cmp	#20,d1				so result can be > 1
	bcs.s	freq_lab1
	sub	#20,d1
	moveq	#1,d2				store integer part in D2.l
freq_lab1
	swap	d2

	swap	d1

*	divu.w	#40,d1
	divu	#20,d1				25 KHz => only 20 updates

	move.w	d1,d2
	swap	d1

*	cmp.w	#20,d1
	cmp.w	#10,d1				25 KHz => only 20 updates

	blt.s	.mt_no_round
	addq.w	#1,d2
.mt_no_round
	moveq	#0,d1
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5

*	moveq	#39,d7
	moveq	#20-1,d7			25 KHz => only 20 updates

.mt_make_freq	
	add.w	d2,d1
	negx.w	d4
	neg.w	d4
	move.w	d4,d5
	move.w	d1,d6
	add.w	d6,d6
	negx.w	d5
	neg.w	d5
	cmp.w	d3,d5
	ble.s	.mt_set_zero
	move.w	d5,d3
	moveq	#1,d5

	swap	d2				25 KHz => add integer part
	add	d2,d5				of division result to D5
	swap	d2

	move.w	d5,(a0)+
	dbra	d7,.mt_make_freq
	addq.w	#1,d0
	cmp.w	#26,d0
	bne.s	.mt_maker
	rts

.mt_set_zero
	moveq	#0,d5

	swap	d2				25 KHz => add integer part
	add	d2,d5				of division result to D5
	swap	d2

	move.w	d5,(a0)+
	dbra	d7,.mt_make_freq
	addq.w	#1,d0
	cmp.w	#26,d0
	bne.s	.mt_maker
	rts

;
; And now mt_make_mixcode
;
;

mt_make_mixcode
	move.l	mt_mixcode_p,a0
	move.l	mt_mixer_chunk,a1
	move.l	mt_freq_list,a2
	lea	(a2),a4
	moveq	#22,d7
	moveq	#22,d6
.mt_maker
	move.l	a1,(a0)+
	lea	(a2),a3

*	moveq	#40-1,d5
	moveq	#20-1,d5			25 KHz => only 20 updates

.mt_make_it
	move.w	.mt_copy,(a1)+
	move.w	(a3)+,d0
	move.w	(a4)+,d1

*	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d1				2 bits instead of 1 to handle 0, 1 and 2

	or.w	d1,d0

	dbne	d5,.mt_make_it
	tst.w	d5
	beq.s	.mt_end_ops
	bpl.s	.mt_no_exit
.mt_make_end
	move.w	#$4ed6,(a1)+
	dbra	d6,.mt_maker
	moveq	#22,d6

*	lea	80(a2),a2
	lea	40(a2),a2			new table size

	move.l	mt_freq_list,a4
	dbra	d7,.mt_maker
	rts
.mt_no_exit
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	move.w	d5,d4
	subq.w	#1,d4
.mt_analyse
	move.w	(a3)+,d1
	move.w	(a4)+,d2

*	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,d2				2 bits instead of 1 to handle 0, 1 and 2

	or.w	d2,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	.mt_ana_code(pc,d1.w),a6
	jsr	(a6)
	dbra	d4,.mt_analyse
	move.l	(sp)+,a4
	move.l	(sp)+,a3
	tst.w	d1
	dbeq	d5,.mt_make_it
	bra.s	.mt_end_ops
.mt_ana_code
	dc.l	.mt_ana_code0			0 and 0
	dc.l	.mt_ana_code1			0 and 1
	dc.l	.mt_ana_code1			0 and 2
	dc.l	.mt_ana_code0			not possible
	dc.l	.mt_ana_code2			1 and 0
	dc.l	.mt_ana_code3			1 and 1
	dc.l	.mt_ana_code3			1 and 2
	dc.l	.mt_ana_code0			not possible
	dc.l	.mt_ana_code2			2 and 0
	dc.l	.mt_ana_code3			2 and 1
	dc.l	.mt_ana_code3			2 and 2
	dc.l	.mt_ana_code0			not possible
	dc.l	.mt_ana_code0			not possible
	dc.l	.mt_ana_code0			not possible
	dc.l	.mt_ana_code0			not possible
	dc.l	.mt_ana_code0			not possible

.mt_end_ops

*	cmp.w	#3,d0
*	beq.s	.mt_ana_code03
*	cmp.w	#2,d0
*	beq.s	.mt_ana_code02
	cmp.w	#%1010,d0			2 2
	beq.s	.mt_ana_code02_2
	cmp.w	#%1001,d0			2 1
	beq.s	.mt_ana_code02_1
	cmp.w	#%1000,d0			2 0
	beq.s	.mt_ana_code02_0
	cmp.w	#%0110,d0			1 2
	beq.s	.mt_ana_code01_2
	cmp.w	#%0101,d0			1 1
	beq.s	.mt_ana_code03
	cmp.w	#%0100,d0			1 0
	beq.s	.mt_ana_code02
	cmp.w	#%0010,d0			0 2
	beq.s	.mt_ana_code00_2

.mt_ana_code01
	lea	.mt_copy,a6
	move.w	.mt_copy2,(a6)
	move.w	.mt_ch0_fetch,(a1)+
	move.l	.mt_add012,(a1)+
	dbra	d5,.mt_make_it
	move.w	#$4ed6,(a1)+
	dbra	d6,.mt_maker
	moveq	#22,d6

*	lea	80(a2),a2
	lea	40(a2),a2			new table size

	move.l	mt_freq_list,a4
	dbra	d7,.mt_maker
	rts

.mt_ana_code00_2
	lea	.mt_copy,a6
	move.w	.mt_copy2,(a6)

	move	.mt_addq0,(a1)+

	move.w	.mt_ch0_fetch,(a1)+
	move.l	.mt_add012,(a1)+
	dbra	d5,.mt_make_it
	move.w	#$4ed6,(a1)+
	dbra	d6,.mt_maker
	moveq	#22,d6

*	lea	80(a2),a2
	lea	40(a2),a2			new table size

	move.l	mt_freq_list,a4
	dbra	d7,.mt_maker
	rts

.mt_ana_code02
	lea	.mt_copy,a6
	move.w	.mt_copy2,(a6)
	move.w	.mt_ch1_fetch,(a1)+
	move.l	.mt_ch1_fetch+2,(a1)+
	move.l	.mt_add012,(a1)+
	dbra	d5,.mt_make_it
	move.w	#$4ed6,(a1)+
	dbra	d6,.mt_maker
	moveq	#22,d6

*	lea	80(a2),a2
	lea	40(a2),a2			new table size

	move.l	mt_freq_list,a4
	dbra	d7,.mt_maker
	rts

.mt_ana_code02_0
	lea	.mt_copy,a6
	move.w	.mt_copy2,(a6)

	move	.mt_addq1,(a1)+

	move.w	.mt_ch1_fetch,(a1)+
	move.l	.mt_ch1_fetch+2,(a1)+
	move.l	.mt_add012,(a1)+
	dbra	d5,.mt_make_it
	move.w	#$4ed6,(a1)+
	dbra	d6,.mt_maker
	moveq	#22,d6

*	lea	80(a2),a2
	lea	40(a2),a2			new table size

	move.l	mt_freq_list,a4
	dbra	d7,.mt_maker
	rts

.mt_ana_code03
	lea	.mt_copy,a6
	move.w	.mt_copy2,(a6)
	move.l	.mt_ch01fetadd1,(a1)+
	move.l	.mt_ch01fetadd1+4,(a1)+
	move.l	.mt_add012,(a1)+
	dbra	d5,.mt_make_it
	move.w	#$4ed6,(a1)+
	dbra	d6,.mt_maker
	moveq	#22,d6

*	lea	80(a2),a2
	lea	40(a2),a2			new table size

	move.l	mt_freq_list,a4
	dbra	d7,.mt_maker
	rts

.mt_ana_code01_2
	lea	.mt_copy,a6
	move.w	.mt_copy2,(a6)

	move	.mt_addq0,(a1)+

	move.l	.mt_ch01fetadd1,(a1)+
	move.l	.mt_ch01fetadd1+4,(a1)+
	move.l	.mt_add012,(a1)+
	dbra	d5,.mt_make_it
	move.w	#$4ed6,(a1)+
	dbra	d6,.mt_maker
	moveq	#22,d6

*	lea	80(a2),a2
	lea	40(a2),a2			new table size

	move.l	mt_freq_list,a4
	dbra	d7,.mt_maker
	rts

.mt_ana_code02_1
	lea	.mt_copy,a6
	move.w	.mt_copy2,(a6)

	move	.mt_addq1,(a1)+

	move.l	.mt_ch01fetadd1,(a1)+
	move.l	.mt_ch01fetadd1+4,(a1)+
	move.l	.mt_add012,(a1)+
	dbra	d5,.mt_make_it
	move.w	#$4ed6,(a1)+
	dbra	d6,.mt_maker
	moveq	#22,d6

*	lea	80(a2),a2
	lea	40(a2),a2			new table size

	move.l	mt_freq_list,a4
	dbra	d7,.mt_maker
	rts

.mt_ana_code02_2
	lea	.mt_copy,a6
	move.w	.mt_copy2,(a6)

	move	.mt_addq0,(a1)+
	move	.mt_addq1,(a1)+

	move.l	.mt_ch01fetadd1,(a1)+
	move.l	.mt_ch01fetadd1+4,(a1)+
	move.l	.mt_add012,(a1)+
	dbra	d5,.mt_make_it
	move.w	#$4ed6,(a1)+
	dbra	d6,.mt_maker
	moveq	#22,d6

*	lea	80(a2),a2
	lea	40(a2),a2			new table size

	move.l	mt_freq_list,a4
	dbra	d7,.mt_maker
	rts

.mt_ana_code0	rts


.mt_ana_code1
*	cmp.w	#3,d0
*	beq.s	.mt_ana_code13
*	cmp.w	#2,d0
*	beq.s	.mt_ana_code12
	cmp.w	#%1010,d0			2 2
	beq.s	.mt_ana_code12_2
	cmp.w	#%1001,d0			2 1
	beq.s	.mt_ana_code12_1
	cmp.w	#%1000,d0			2 0
	beq.s	.mt_ana_code12_0
	cmp.w	#%0110,d0			1 2
	beq.s	.mt_ana_code11_2
	cmp.w	#%0101,d0			1 1
	beq.s	.mt_ana_code13
	cmp.w	#%0100,d0			1 0
	beq.s	.mt_ana_code12
	cmp.w	#%0010,d0			0 2
	beq.s	.mt_ana_code10_2

.mt_ana_code11
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)
	move.w	.mt_ch0_fetch,(a1)+
	move.w	.mt_add10,(a1)+
	rts

.mt_ana_code10_2
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)

	move	.mt_addq0,(a1)+

	move.w	.mt_ch0_fetch,(a1)+
	move.w	.mt_add10,(a1)+
	rts

.mt_ana_code12
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)
	move.w	.mt_ch1_fetch,(a1)+
	move.l	.mt_ch1_fetch+2,(a1)+
	move.w	.mt_add10,(a1)+
	rts

.mt_ana_code12_0
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)

	move	.mt_addq1,(a1)+

	move.w	.mt_ch1_fetch,(a1)+
	move.l	.mt_ch1_fetch+2,(a1)+
	move.w	.mt_add10,(a1)+
	rts

.mt_ana_code13
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)
	move.l	.mt_ch01fetadd1,(a1)+
	move.l	.mt_ch01fetadd1+4,(a1)+
	move.w	.mt_add10,(a1)+
	rts

.mt_ana_code11_2
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)

	move	.mt_addq0,(a1)+

	move.l	.mt_ch01fetadd1,(a1)+
	move.l	.mt_ch01fetadd1+4,(a1)+
	move.w	.mt_add10,(a1)+
	rts

.mt_ana_code12_1
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)

	move	.mt_addq1,(a1)+

	move.l	.mt_ch01fetadd1,(a1)+
	move.l	.mt_ch01fetadd1+4,(a1)+
	move.w	.mt_add10,(a1)+
	rts

.mt_ana_code12_2
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)

	move	.mt_addq0,(a1)+
	move	.mt_addq1,(a1)+

	move.l	.mt_ch01fetadd1,(a1)+
	move.l	.mt_ch01fetadd1+4,(a1)+
	move.w	.mt_add10,(a1)+
	rts


.mt_ana_code2
*	cmp.w	#3,d0
*	beq.s	.mt_ana_code23
*	cmp.w	#2,d0
*	beq.s	.mt_ana_code22
	cmp.w	#%1010,d0			2 2
	beq.s	.mt_ana_code22_2
	cmp.w	#%1001,d0			2 1
	beq.s	.mt_ana_code22_1
	cmp.w	#%1000,d0			2 0
	beq.s	.mt_ana_code22_0
	cmp.w	#%0110,d0			1 2
	beq.s	.mt_ana_code21_2
	cmp.w	#%0101,d0			1 1
	beq.s	.mt_ana_code23
	cmp.w	#%0100,d0			1 0
	beq.s	.mt_ana_code22
	cmp.w	#%0010,d0			0 2
	beq.s	.mt_ana_code20_2

.mt_ana_code21
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy1,(a6)
	move.w	.mt_ch0_fetch,(a1)+
	move.w	.mt_add01,(a1)+
	rts

.mt_ana_code20_2
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy1,(a6)

	move	.mt_addq0,(a1)+

	move.w	.mt_ch0_fetch,(a1)+
	move.w	.mt_add01,(a1)+
	rts

.mt_ana_code22
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy1,(a6)
	move.w	.mt_ch1_fetch,(a1)+
	move.l	.mt_ch1_fetch+2,(a1)+
	move.w	.mt_add01,(a1)+
	rts

.mt_ana_code22_0
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy1,(a6)

	move	.mt_addq1,(a1)+

	move.w	.mt_ch1_fetch,(a1)+
	move.l	.mt_ch1_fetch+2,(a1)+
	move.w	.mt_add01,(a1)+
	rts

.mt_ana_code23
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy1,(a6)
	move.l	.mt_ch01fetadd1,(a1)+
	move.l	.mt_ch01fetadd1+4,(a1)+
	move.w	.mt_add01,(a1)+
	rts

.mt_ana_code21_2
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy1,(a6)

	move	.mt_addq0,(a1)+

	move.l	.mt_ch01fetadd1,(a1)+
	move.l	.mt_ch01fetadd1+4,(a1)+
	move.w	.mt_add01,(a1)+
	rts

.mt_ana_code22_1
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy1,(a6)

	move	.mt_addq1,(a1)+

	move.l	.mt_ch01fetadd1,(a1)+
	move.l	.mt_ch01fetadd1+4,(a1)+
	move.w	.mt_add01,(a1)+
	rts

.mt_ana_code22_2
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy1,(a6)

	move	.mt_addq0,(a1)+
	move	.mt_addq1,(a1)+

	move.l	.mt_ch01fetadd1,(a1)+
	move.l	.mt_ch01fetadd1+4,(a1)+
	move.w	.mt_add01,(a1)+
	rts


.mt_ana_code3
*	cmp.w	#3,d0
*	beq.s	.mt_ana_code33
*	cmp.w	#2,d0
*	beq.s	.mt_ana_code32
	cmp.w	#%1010,d0			2 2
	beq.s	.mt_ana_code32_2
	cmp.w	#%1001,d0			2 1
	beq.s	.mt_ana_code32_1
	cmp.w	#%1000,d0			2 0
	beq.s	.mt_ana_code32_0
	cmp.w	#%0110,d0			1 2
	beq.s	.mt_ana_code31_2
	cmp.w	#%0101,d0			1 1
	beq.s	.mt_ana_code33
	cmp.w	#%0100,d0			1 0
	beq.s	.mt_ana_code32
	cmp.w	#%0010,d0			0 2
	beq.s	.mt_ana_code30_2

.mt_ana_code31
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy1,(a6)
	move.w	.mt_ch0_fet_add,(a1)+
	rts

.mt_ana_code30_2
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy1,(a6)

	move	.mt_addq0,(a1)+

	move.w	.mt_ch0_fet_add,(a1)+
	rts

.mt_ana_code32
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)
	move.w	.mt_ch1_fet_add,(a1)+
	move.l	.mt_ch1_fet_add+2,(a1)+
	rts

.mt_ana_code32_0
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)

	move	.mt_addq1,(a1)+

	move.w	.mt_ch1_fet_add,(a1)+
	move.l	.mt_ch1_fet_add+2,(a1)+
	rts

.mt_ana_code33
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)
	move.l	.mt_ch01fetadd0,(a1)+
	move.l	.mt_ch01fetadd0+4,(a1)+
	rts

.mt_ana_code31_2
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)

	move	.mt_addq0,(a1)+

	move.l	.mt_ch01fetadd0,(a1)+
	move.l	.mt_ch01fetadd0+4,(a1)+
	rts

.mt_ana_code32_1
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)

	move	.mt_addq1,(a1)+

	move.l	.mt_ch01fetadd0,(a1)+
	move.l	.mt_ch01fetadd0+4,(a1)+
	rts

.mt_ana_code32_2
	moveq	#0,d4
	moveq	#1,d1
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)

	move	.mt_addq0,(a1)+
	move	.mt_addq1,(a1)+

	move.l	.mt_ch01fetadd0,(a1)+
	move.l	.mt_ch01fetadd0+4,(a1)+
	rts


.mt_copy
	move.b	d2,(sp)+
.mt_copy0
	move.b	d0,(sp)+
.mt_copy1
	move.b	d1,(sp)+
.mt_copy2
	move.b	d2,(sp)+

.mt_ch0_fetch
	move.b	(a0)+,d0
.mt_ch0_fet_add
	add.b	(a0)+,d1
.mt_ch1_fetch
	move.b	(a1)+,d1
	move.l	d1,a2
	move.b	(a2),d1
.mt_ch1_fet_add
	move.b	(a1)+,d1
	move.l	d1,a2
	add.b	(a2),d0
.mt_ch01fetadd0
	move.b	(a0)+,d0
	move.b	(a1)+,d1
	move.l	d1,a2
	add.b	(a2),d0
.mt_ch01fetadd1
	move.b	(a0)+,d0
	move.b	(a1)+,d1
	move.l	d1,a2
	move.b	(a2),d1
.mt_add01
	add.b	d0,d1
.mt_add10
	add.b	d1,d0
.mt_add012
	move.b	d0,d2
	add.b	d1,d2
.mt_addq0
	addq	#1,a0
.mt_addq1
	addq	#1,a1

; Ok. That's it.
; I have not tried it so don't blame me if it does not work.
; It should be pretty close to work if it does not.
;
; Time for you to test it if you are interested.
;
; Enjoy it.
;
; Paulo Simoes / 1st March 2013
;
;------------------------------------------------------------------------

;----------------------------------------------------------
;
;
;
;
;
;
;                PROtracker replay routine
;                ÿÿÿÿÿÿÿÿÿÿ ÿÿÿÿÿÿ ÿÿÿÿÿÿÿ
;                        converted
;                           by:
;
;                        ¯ Lance ®
;
;
;
;
;
;
;----------------------------------------------------------
;  ....PROtracker was invented by Freelancers (Amiga)....
;----------------------------------------------------------
; This version includes the version 3 of my Paula emulators
; It's totally rewritten and by combining several tricks
; I'm manage to do a 50kHz(!!!) replay routine that only
; takes around 30% and I'm not using any cheats like over-
; sample. This version is indeed four times faster than my
; first replay routine and I hope all you hackers out there
; will like my routine and would like to contact me :
;---------------------------------------------------------- 
;	M†rten R†nge
;	Oxelv„gen 6
;	524 32 HERRLJUNGA
;	SWEDEN
;----------------------------------------------------------
; Or call:
;----------------------------------------------------------
;	+46-(0)513-10137
;    (Ask for M†rten , Maarten in english)
;----------------------------------------------------------
; This program is a CardWare program. Which means if you
; like it and use it regulary you are encouraged to send
; me a card or a letter(I prefer them without bombs(joke!))
; and tell me how much like my routine and that you think
; that I'm the greatest coder in the world etc. etc.
; This will encourage me to go on with my work on a UCDM -
; player and a Octalizer routine(XIA contacted me after he
; saw my version 0 of my Paula emulators and it's much
; thanks to him and to all others that have contacted me
; that version is made. So as you can see,contacting the
; programmer is very important.).
;----------------------------------------------------------
; Some Greets:
; ÿÿÿÿÿÿÿÿÿÿÿÿ
; OMEGA and Electra - (   The Best DemoCrews in Sweden    )
;    Delta Force    - (DiscMaggie has never looked better )
;     AGGRESSION    - ('BrainDamage' is really ultra-cool )
;-------------
;  NewCore - (What do you think about this replay , Blade?)
;  NoCrew  - (Should be named CoolCrew (they're very nice))
;   Chip   - (     Good friend (and also a Teadrinker)    )
;    XIA   - (It was nice to meet you at 'Motorola inside')
;    ICE   - (             Hi there,TECHWAVE              )
;-------------
; Special greet to AURA - I don't know you guys but it's
; thanks to you and your demo 'HiFi-dreams' that I realized
; that it's possible to make a 50kHz replay routine.
;-------------
; And to all members in IMPULSE (They paid me for this!)
;----------------------------------------------------------
; Some notes:
; Always call mt_Paula before mt_music ,this because
; mt_music sometimes takes more time and sometimes takes
; less. DON'T use Trap0 because I am using that to switch
; between Supervisor- and Usermode.
;----------------------------------------------------------
; P.S. This replay routine supports every PT2.2 command D.S
;----------------------------------------------------------
;      - Lance / M†rten R†nge      1993/08/22
;----------------------------------------------------------
n_note	equ	0  ; w
n_cmd	equ	2  ; w
n_cmdlo	equ	3  ; b
n_start	equ	4  ; l
n_length	equ	8  ; w
n_loopstart	equ	10 ; l
n_replen	equ	14 ; w
n_period	equ	16 ; w
n_finetune	equ	18 ; b
n_volume	equ	19 ; b
n_dmabit	equ	20 ; w
n_toneportdirec	equ	22 ; b
n_toneportspeed	equ	23 ; b
n_wantedperiod	equ	24 ; w
n_vibratocmd	equ	26 ; b
n_vibratopos	equ	27 ; b
n_tremolocmd	equ	28 ; b
n_tremolopos	equ	29 ; b
n_wavecontrol	equ	30 ; b
n_glissfunk	equ	31 ; b
n_sampleoffset	equ	32 ; b
n_pattpos	equ	33 ; b
n_loopcount	equ	34 ; b
n_funkoffset	equ	35 ; b
n_wavestart	equ	36 ; l
n_reallength	equ	40 ; w
	rsreset
mt_sample_point	rs.l	1
mt_sample_end	rs.l	1
mt_loop_start	rs.l	1
mt_volume	rs.w	1
mt_period	rs.w	1
mt_add_iw	rs.w	1
mt_check_dummy	rs.w	1
	opt	a+,o+

	section	text

mt_init	
	lea	mt_data,a0
	move.l	a0,mt_songdataptr
	move.l	a0,a1
	lea	952(a1),a1		$3B8
	moveq	#127,d0
	moveq	#0,d1
mtloop	
	move.l	d1,d2
	subq.w	#1,d0
mtloop2	
	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mtloop
	dbra	d0,mtloop2
	addq.b	#1,d2			number of patterns
		
	lea	mt_samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2			x 1024 bytes
	add.l	#1084,d2		$43C
	add.l	a0,d2
	move.l	d2,a2			A2 => samples data
	moveq	#30,d0
	moveq	#0,d2
	lea	42(a0),a0		1st sample descriptor 8 control bytes
mtloop3	
	clr.l	(a2)			clear 1st 4 bytes ?
	move.l	a2,d1
	add.l	d2,d1
	move.l	d1,(a1)+		new sample pointer with loop zone
	moveq	#0,d1
	move.w	(a0),d1
	asl.l	#1,d1
	add.l	d1,a2			sample end
	add.w	#640,d2			+ loop area
	tst.w	4(a0)
	bne.s	.mt_no_test
	cmp.w	#1,6(a0)
	ble.s	.mt_no_test
	subq.w	#1,6(a0)
	move.w	#1,4(a0)
.mt_no_test	
	add.l	#30,a0			next sample descriptor
	dbra	d0,mtloop3
	add.w	d2,a2
	lea	mt_module_end,a1
	move.l	a2,(a1)			end of module pointer
	move.b	#6,mt_speed
	move.b	#6,mt_counter
	clr.b	mt_songpos
	clr.w	mt_patternpos

	lea	-31*640(a2),a1		real end of module

	moveq	#30,d7
mt_init_loops	
	sub.w	#30,a0
	lea	-640(a2),a2
	lea	(a2),a3
	move.w	(a0),d0
	beq.s	.mt_just_loop
	subq.w	#1,d0
.mt_copy_spl	
	move.w	-(a1),-(a2)		move sample because of loop data
	dbra	d0,.mt_copy_spl

.mt_just_loop	
	moveq	#0,d0
	move.w	4(a0),d0
	sne	d1
	andi.w	#$4,d1
	move.l	mt_loop_point(pc,d1.w),a4
	jsr	(a4)
	dbra	d7,mt_init_loops

	move.l	mt_samplestarts,a0
	move.l	mt_module_end,a1
.mt_shift_down	
	move.b	(a0),d0
	asr.b	#1,d0			reduce to 7 bits signed
	move.b	d0,(a0)+
	cmp.l	a0,a1
	bne.s	.mt_shift_down

	bsr	mt_init_Paula
	rts

mt_end	
	bsr	mt_stop_Paula
	rts

mt_loop_point	
	dc.l	.mt_no_loop
	dc.l	.mt_yes_loop
.mt_no_loop	
	move.w	#640/4-1,d0
.mt_clear_loop	
	clr.l	(a3)+
	dbra	d0,.mt_clear_loop
	rts

.mt_yes_loop	
	add.l	d0,d0
	lea	(a2,d0.l),a4
	lea	(a4),a5
	moveq	#0,d1
	move.w	4(a0),d1
	add.w	6(a0),d1
	move.w	d1,(a0)
	add.l	d1,d1
	lea	(a2,d1.l),a3
	move.w	6(a0),d1
	move.w	#320-1,d2
.mt_loop_loop	
	move.w	(a4)+,(a3)+
	subq.w	#1,d1
	bne.s	.mt_no_restart
	lea	(a5),a4
	move.w	6(a0),d1
.mt_no_restart	
	dbra	d2,.mt_loop_loop
	rts

mt_music	
	movem.l	d0-d4/a0-a6,-(sp)
	addq.b	#1,mt_counter
	move.b	mt_counter(pc),d0
	cmp.b	mt_speed(pc),d0
	blo.s	mt_nonewnote
	clr.b	mt_counter
	tst.b	mt_pattdeltime2
	beq.s	mt_getnewnote
	bsr.s	mt_nonewallchannels
	bra	mt_dskip

mt_nonewnote
	bsr.s	mt_nonewallchannels
	bra	mt_nonewposyet

mt_nonewallchannels
	lea	mt_channel_0,a5
	lea	mt_chan1temp(pc),a6
	bsr	mt_checkefx
	lea	mt_channel_1,a5
	lea	mt_chan2temp(pc),a6
	bsr	mt_checkefx
	lea	mt_channel_2,a5
	lea	mt_chan3temp(pc),a6
	bsr	mt_checkefx
	lea	mt_channel_3,a5
	lea	mt_chan4temp(pc),a6
	bra	mt_checkefx

mt_getnewnote
	move.l	mt_songdataptr(pc),a0
	lea	12(a0),a3
	lea	952(a0),a2	;pattpo
	lea	1084(a0),a0	;patterndata
	moveq	#0,d0
	moveq	#0,d1
	move.b	mt_songpos(pc),d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_patternpos(pc),d1
	clr.w	mt_dmacontemp

	lea	mt_channel_0,a5
	lea	mt_chan1temp(pc),a6
	bsr.s	mt_playvoice
	lea	mt_channel_1,a5
	lea	mt_chan2temp(pc),a6
	bsr.s	mt_playvoice
	lea	mt_channel_2,a5
	lea	mt_chan3temp(pc),a6
	bsr.s	mt_playvoice
	lea	mt_channel_3,a5
	lea	mt_chan4temp(pc),a6
	bsr.s	mt_playvoice
	bra	mt_setdma

mt_playvoice	
	tst.l	(a6)
	bne.s	mt_plvskip
	bsr	mt_pernop
mt_plvskip	
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	n_cmd(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq	mt_setregs
	moveq	#0,d3
	lea	mt_samplestarts(pc),a1
	move	d2,d4
	subq.l	#1,d2
	asl.l	#2,d2
	mulu	#30,d4
	move.l	(a1,d2.l),n_start(a6)
	move.w	(a3,d4.l),n_length(a6)
	move.w	(a3,d4.l),n_reallength(a6)
	move.b	2(a3,d4.l),n_finetune(a6)
	move.b	3(a3,d4.l),n_volume(a6)
	move.w	4(a3,d4.l),d3 ; get repeat
	tst.w	d3
	beq.s	mt_noloop
	move.l	n_start(a6),d2		; get start
	asl.w	#1,d3
	add.l	d3,d2		; add repeat
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move.w	4(a3,d4.l),d0	; get repeat
	add.w	6(a3,d4.l),d0	; add replen
	move.w	d0,n_length(a6)
	move.w	6(a3,d4.l),n_replen(a6)	; save replen
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move.w	d0,mt_volume(a5)	; set volume
	bra.s	mt_setregs

mt_noloop	
	move.l	n_start(a6),d2
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move.w	6(a3,d4.l),n_replen(a6)	; save replen
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move.w	d0,mt_volume(a5)	; set volume

mt_setregs	
	move.w	(a6),d0
	and.w	#$0fff,d0
	beq	mt_checkmoreefx	; if no note
	move.w	2(a6),d0
	and.w	#$0ff0,d0
	cmp.w	#$0e50,d0
	beq.s	mt_dosetfinetune
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#3,d0	; toneportamento
	beq.s	mt_chktoneporta
	cmp.b	#5,d0
	beq.s	mt_chktoneporta
	cmp.b	#9,d0	; sample offset
	bne.s	mt_setperiod
	bsr	mt_checkmoreefx
	bra.s	mt_setperiod

mt_dosetfinetune
	bsr	mt_setfinetune
	bra.s	mt_setperiod

mt_chktoneporta
	bsr	mt_settoneporta
	bra	mt_checkmoreefx

mt_setperiod
	movem.l	d0-d1/a0-a1,-(sp)
	move.w	(a6),d1
	and.w	#$0fff,d1
	lea	mt_periodtable(pc),a1
	moveq	#0,d0
	moveq	#36,d7
mt_ftuloop	
	cmp.w	(a1,d0.w),d1
	bhs.s	mt_ftufound
	addq.l	#2,d0
	dbra	d7,mt_ftuloop
mt_ftufound
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	#36*2,d1
	add.l	d1,a1
	move.w	(a1,d0.w),n_period(a6)
	movem.l	(sp)+,d0-d1/a0-a1

	move.w	2(a6),d0
	and.w	#$0ff0,d0
	cmp.w	#$0ed0,d0 ; notedelay
	beq	mt_checkmoreefx

	btst	#2,n_wavecontrol(a6)
	bne.s	mt_vibnoc
	clr.b	n_vibratopos(a6)
mt_vibnoc
	btst	#6,n_wavecontrol(a6)
	bne.s	mt_trenoc
	clr.b	n_tremolopos(a6)
mt_trenoc
	move.l	n_start(a6),mt_sample_point(a5)	; set start
	moveq	#0,d0
	move.w	n_length(a6),d0		; set length
	add.l	d0,d0
	add.l	mt_sample_point(a5),d0
	move.l	d0,mt_sample_end(a5)
	move.l	n_loopstart(a6),d0
	cmp.l	mt_sample_point(a5),d0
	bne.s	.mt_set_loop
	moveq	#0,d0
.mt_set_loop	
	move.l	d0,mt_loop_start(a5)
	move.w	n_period(a6),d0
	move.w	d0,mt_period(a5)		; set period
	move.w	n_dmabit(a6),d0
	or.w	d0,mt_dmacontemp
	bra	mt_checkmoreefx
 
mt_setdma
mt_dskip	
	add.w	#16,mt_patternpos
	move.b	mt_pattdeltime,d0
	beq.s	mt_dskc
	move.b	d0,mt_pattdeltime2
	clr.b	mt_pattdeltime
mt_dskc	
	tst.b	mt_pattdeltime2
	beq.s	mt_dska
	subq.b	#1,mt_pattdeltime2
	beq.s	mt_dska
	sub.w	#16,mt_patternpos
mt_dska	
	tst.b	mt_pbreakflag
	beq.s	mt_nnpysk
	sf	mt_pbreakflag
	moveq	#0,d0
	move.b	mt_pbreakpos(pc),d0
	clr.b	mt_pbreakpos
	lsl.w	#4,d0
	move.w	d0,mt_patternpos
mt_nnpysk	
	cmp.w	#1024,mt_patternpos
	blo.s	mt_nonewposyet
mt_nextposition
	moveq	#0,d0
	move.b	mt_pbreakpos(pc),d0
	lsl.w	#4,d0
	move.w	d0,mt_patternpos
	clr.b	mt_pbreakpos
	clr.b	mt_posjumpflag
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos(pc),d1
	move.l	mt_songdataptr(pc),a0
	cmp.b	950(a0),d1
	blo.s	mt_nonewposyet
	clr.b	mt_songpos
mt_nonewposyet
	tst.b	mt_posjumpflag
	bne.s	mt_nextposition
	movem.l	(sp)+,d0-d4/a0-a6
	rts

mt_checkefx
	bsr	mt_updatefunk
	move.w	n_cmd(a6),d0
	and.w	#$0fff,d0
	beq.s	mt_pernop
	move.b	n_cmd(a6),d0
	and.b	#$0f,d0
	beq.s	mt_arpeggio
	cmp.b	#1,d0
	beq	mt_portaup
	cmp.b	#2,d0
	beq	mt_portadown
	cmp.b	#3,d0
	beq	mt_toneportamento
	cmp.b	#4,d0
	beq	mt_vibrato
	cmp.b	#5,d0
	beq	mt_toneplusvolslide
	cmp.b	#6,d0
	beq	mt_vibratoplusvolslide
	cmp.b	#$e,d0
	beq	mt_e_commands
setback	
	move.w	n_period(a6),mt_period(a5)
	cmp.b	#7,d0
	beq	mt_tremolo
	cmp.b	#$a,d0
	beq	mt_volumeslide
mt_return2
	rts

mt_pernop
	move.w	n_period(a6),mt_period(a5)
	rts

mt_arpeggio
	moveq	#0,d0
	move.b	mt_counter(pc),d0
	divs	#3,d0
	swap	d0
	cmp.w	#0,d0
	beq.s	mt_arpeggio2
	cmp.w	#2,d0
	beq.s	mt_arpeggio1
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	bra.s	mt_arpeggio3

mt_arpeggio1
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#15,d0
	bra.s	mt_arpeggio3

mt_arpeggio2
	move.w	n_period(a6),d2
	bra.s	mt_arpeggio4

mt_arpeggio3
	asl.w	#1,d0
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	#36*2,d1
	lea	mt_periodtable(pc),a0
	add.l	d1,a0
	moveq	#0,d1
	move.w	n_period(a6),d1
	moveq	#36,d7
mt_arploop
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bhs.s	mt_arpeggio4
	addq.l	#2,a0
	dbra	d7,mt_arploop
	rts

mt_arpeggio4	
	move.w	d2,mt_period(a5)
	rts

mt_fineportaup
	tst.b	mt_counter
	bne.s	mt_return2
	move.b	#$0f,mt_lowmask
mt_portaup
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	mt_lowmask(pc),d0
	move.b	#$ff,mt_lowmask
	sub.w	d0,n_period(a6)
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	cmp.w	#113,d0
	bpl.s	mt_portauskip
	and.w	#$f000,n_period(a6)
	or.w	#113,n_period(a6)
mt_portauskip
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	move.w	d0,mt_period(a5)
	rts
 
mt_fineportadown
	tst.b	mt_counter
	bne	mt_return2
	move.b	#$0f,mt_lowmask
mt_portadown
	clr.w	d0
	move.b	n_cmdlo(a6),d0
	and.b	mt_lowmask(pc),d0
	move.b	#$ff,mt_lowmask
	add.w	d0,n_period(a6)
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	cmp.w	#856,d0
	bmi.s	mt_portadskip
	and.w	#$f000,n_period(a6)
	or.w	#856,n_period(a6)
mt_portadskip
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	move.w	d0,mt_period(a5)
	rts

mt_settoneporta
	move.l	a0,-(sp)
	move.w	(a6),d2
	and.w	#$0fff,d2
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	#37*2,d0
	lea	mt_periodtable(pc),a0
	add.l	d0,a0
	moveq	#0,d0
mt_stploop
	cmp.w	(a0,d0.w),d2
	bhs.s	mt_stpfound
	addq.w	#2,d0
	cmp.w	#37*2,d0
	blo.s	mt_stploop
	moveq	#35*2,d0
mt_stpfound
	move.b	n_finetune(a6),d2
	and.b	#8,d2
	beq.s	mt_stpgoss
	tst.w	d0
	beq.s	mt_stpgoss
	subq.w	#2,d0
mt_stpgoss
	move.w	(a0,d0.w),d2
	move.l	(sp)+,a0
	move.w	d2,n_wantedperiod(a6)
	move.w	n_period(a6),d0
	clr.b	n_toneportdirec(a6)
	cmp.w	d0,d2
	beq.s	mt_cleartoneporta
	bge	mt_return2
	move.b	#1,n_toneportdirec(a6)
	rts

mt_cleartoneporta
	clr.w	n_wantedperiod(a6)
	rts

mt_toneportamento
	move.b	n_cmdlo(a6),d0
	beq.s	mt_toneportnochange
	move.b	d0,n_toneportspeed(a6)
	clr.b	n_cmdlo(a6)
mt_toneportnochange
	tst.w	n_wantedperiod(a6)
	beq	mt_return2
	moveq	#0,d0
	move.b	n_toneportspeed(a6),d0
	tst.b	n_toneportdirec(a6)
	bne.s	mt_toneportaup
mt_toneportadown
	add.w	d0,n_period(a6)
	move.w	n_wantedperiod(a6),d0
	cmp.w	n_period(a6),d0
	bgt.s	mt_toneportasetper
	move.w	n_wantedperiod(a6),n_period(a6)
	clr.w	n_wantedperiod(a6)
	bra.s	mt_toneportasetper

mt_toneportaup
	sub.w	d0,n_period(a6)
	move.w	n_wantedperiod(a6),d0
	cmp.w	n_period(a6),d0
	blt.s	mt_toneportasetper
	move.w	n_wantedperiod(a6),n_period(a6)
	clr.w	n_wantedperiod(a6)

mt_toneportasetper
	move.w	n_period(a6),d2
	move.b	n_glissfunk(a6),d0
	and.b	#$0f,d0
	beq.s	mt_glissskip
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	#36*2,d0
	lea	mt_periodtable(pc),a0
	add.l	d0,a0
	moveq	#0,d0
mt_glissloop
	cmp.w	(a0,d0.w),d2
	bhs.s	mt_glissfound
	addq.w	#2,d0
	cmp.w	#36*2,d0
	blo.s	mt_glissloop
	moveq	#35*2,d0
mt_glissfound
	move.w	(a0,d0.w),d2
mt_glissskip
	move.w	d2,mt_period(a5) ; set period
	rts

mt_vibrato
	move.b	n_cmdlo(a6),d0
	beq.s	mt_vibrato2
	move.b	n_vibratocmd(a6),d2
	and.b	#$0f,d0
	beq.s	mt_vibskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_vibskip
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.s	mt_vibskip2
	and.b	#$0f,d2
	or.b	d0,d2
mt_vibskip2
	move.b	d2,n_vibratocmd(a6)
mt_vibrato2
	move.b	n_vibratopos(a6),d0
	lea	mt_vibratotable(pc),a4
	lsr.w	#2,d0
	and.w	#$001f,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	and.b	#$03,d2
	beq.s	mt_vib_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	mt_vib_rampdown
	move.b	#255,d2
	bra.s	mt_vib_set
mt_vib_rampdown
	tst.b	n_vibratopos(a6)
	bpl.s	mt_vib_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.s	mt_vib_set
mt_vib_rampdown2
	move.b	d0,d2
	bra.s	mt_vib_set
mt_vib_sine
	move.b	0(a4,d0.w),d2
mt_vib_set
	move.b	n_vibratocmd(a6),d0
	and.w	#15,d0
	mulu	d0,d2
	lsr.w	#7,d2
	move.w	n_period(a6),d0
	tst.b	n_vibratopos(a6)
	bmi.s	mt_vibratoneg
	add.w	d2,d0
	bra.s	mt_vibrato3
mt_vibratoneg
	sub.w	d2,d0
mt_vibrato3
	move.w	d0,mt_period(a5)
	move.b	n_vibratocmd(a6),d0
	lsr.w	#2,d0
	and.w	#$003c,d0
	add.b	d0,n_vibratopos(a6)
	rts

mt_toneplusvolslide
	bsr	mt_toneportnochange
	bra	mt_volumeslide

mt_vibratoplusvolslide
	bsr.s	mt_vibrato2
	bra	mt_volumeslide

mt_tremolo
	move.b	n_cmdlo(a6),d0
	beq.s	mt_tremolo2
	move.b	n_tremolocmd(a6),d2
	and.b	#$0f,d0
	beq.s	mt_treskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_treskip
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.s	mt_treskip2
	and.b	#$0f,d2
	or.b	d0,d2
mt_treskip2
	move.b	d2,n_tremolocmd(a6)
mt_tremolo2
	move.b	n_tremolopos(a6),d0
	lea	mt_vibratotable(pc),a4
	lsr.w	#2,d0
	and.w	#$001f,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	lsr.b	#4,d2
	and.b	#$03,d2
	beq.s	mt_tre_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	mt_tre_rampdown
	move.b	#255,d2
	bra.s	mt_tre_set
mt_tre_rampdown
	tst.b	n_vibratopos(a6)
	bpl.s	mt_tre_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.s	mt_tre_set
mt_tre_rampdown2
	move.b	d0,d2
	bra.s	mt_tre_set
mt_tre_sine
	move.b	0(a4,d0.w),d2
mt_tre_set
	move.b	n_tremolocmd(a6),d0
	and.w	#15,d0
	mulu	d0,d2
	lsr.w	#6,d2
	moveq	#0,d0
	move.b	n_volume(a6),d0
	tst.b	n_tremolopos(a6)
	bmi.s	mt_tremoloneg
	add.w	d2,d0
	bra.s	mt_tremolo3
mt_tremoloneg
	sub.w	d2,d0
mt_tremolo3
	bpl.s	mt_tremoloskip
	clr.w	d0
mt_tremoloskip
	cmp.w	#$40,d0
	bls.s	mt_tremolook
	move.w	#$40,d0
mt_tremolook
	move.w	d0,mt_volume(a5)
	move.b	n_tremolocmd(a6),d0
	lsr.w	#2,d0
	and.w	#$003c,d0
	add.b	d0,n_tremolopos(a6)
	rts

mt_sampleoffset
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	beq.s	mt_sononew
	move.b	d0,n_sampleoffset(a6)
mt_sononew
	move.b	n_sampleoffset(a6),d0
	lsl.w	#7,d0
	cmp.w	n_length(a6),d0
	bge.s	mt_sofskip
	sub.w	d0,n_length(a6)
	lsl.w	#1,d0
	add.l	d0,n_start(a6)
	add.l	n_loopstart(a6),d0
	cmp.l	n_start(a6),d0
	ble.s	.mt_set_loop
	move.l	n_loopstart(a6),d0
.mt_set_loop	
	move.l	d0,n_loopstart(a6)
	rts
mt_sofskip	
	move.w	#$0001,n_length(a6)
	rts

mt_volumeslide
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_volslidedown
mt_volslideup
	add.b	d0,n_volume(a6)
	cmp.b	#$40,n_volume(a6)
	bmi.s	mt_vsuskip
	move.b	#$40,n_volume(a6)
mt_vsuskip
	move.b	n_volume(a6),d0
	move.w	d0,mt_volume(a5)
	rts

mt_volslidedown
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
mt_volslidedown2
	sub.b	d0,n_volume(a6)
	bpl.s	mt_vsdskip
	clr.b	n_volume(a6)
mt_vsdskip
	move.b	n_volume(a6),d0
	move.w	d0,mt_volume(a5)
	rts

mt_positionjump
	move.b	n_cmdlo(a6),d0
	subq.b	#1,d0
	move.b	d0,mt_songpos
mt_pj2	clr.b	mt_pbreakpos
	st 	mt_posjumpflag
	rts

mt_volumechange
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	cmp.b	#$40,d0
	bls.s	mt_volumeok
	moveq	#$40,d0
mt_volumeok
	move.b	d0,n_volume(a6)
	move.w	d0,mt_volume(a5)
	rts

mt_patternbreak
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	move.l	d0,d2
	lsr.b	#4,d0
	mulu	#10,d0
	and.b	#$0f,d2
	add.b	d2,d0
	cmp.b	#63,d0
	bhi.s	mt_pj2
	move.b	d0,mt_pbreakpos
	st	mt_posjumpflag
	rts

mt_setspeed
	move.b	3(a6),d0
	beq	mt_return2
	clr.b	mt_counter
	move.b	d0,mt_speed
	rts

mt_checkmoreefx
	bsr	mt_updatefunk
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#$9,d0
	beq	mt_sampleoffset
	cmp.b	#$b,d0
	beq	mt_positionjump
	cmp.b	#$d,d0
	beq.s	mt_patternbreak
	cmp.b	#$e,d0
	beq.s	mt_e_commands
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	cmp.b	#$c,d0
	beq	mt_volumechange
	bra	mt_pernop

mt_e_commands
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	lsr.b	#4,d0
	beq.s	mt_filteronoff
	cmp.b	#1,d0
	beq	mt_fineportaup
	cmp.b	#2,d0
	beq	mt_fineportadown
	cmp.b	#3,d0
	beq.s	mt_setglisscontrol
	cmp.b	#4,d0
	beq.s	mt_setvibratocontrol
	cmp.b	#5,d0
	beq.s	mt_setfinetune
	cmp.b	#6,d0
	beq.s	mt_jumploop
	cmp.b	#7,d0
	beq	mt_settremolocontrol
	cmp.b	#9,d0
	beq	mt_retrignote
	cmp.b	#$a,d0
	beq	mt_volumefineup
	cmp.b	#$b,d0
	beq	mt_volumefinedown
	cmp.b	#$c,d0
	beq	mt_notecut
	cmp.b	#$d,d0
	beq	mt_notedelay
	cmp.b	#$e,d0
	beq	mt_patterndelay
	cmp.b	#$f,d0
	beq	mt_funkit
	rts

mt_filteronoff
	rts

mt_setglisscontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	and.b	#$f0,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	rts

mt_setvibratocontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	and.b	#$f0,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_setfinetune
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	move.b	d0,n_finetune(a6)
	rts

mt_jumploop
	tst.b	mt_counter
	bne	mt_return2
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	beq.s	mt_setloop
	tst.b	n_loopcount(a6)
	beq.s	mt_jumpcnt
	subq.b	#1,n_loopcount(a6)
	beq	mt_return2
mt_jmploop	
	move.b	n_pattpos(a6),mt_pbreakpos
	st	mt_pbreakflag
	rts

mt_jumpcnt
	move.b	d0,n_loopcount(a6)
	bra.s	mt_jmploop

mt_setloop
	move.w	mt_patternpos(pc),d0
	lsr.w	#4,d0
	move.b	d0,n_pattpos(a6)
	rts

mt_settremolocontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	lsl.b	#4,d0
	and.b	#$0f,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_retrignote	move.l	d1,-(sp)
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	beq.s	mt_rtnend
	moveq	#0,d1
	move.b	mt_counter(pc),d1
	bne.s	mt_rtnskp
	move.w	(a6),d1
	and.w	#$0fff,d1
	bne.s	mt_rtnend
	moveq	#0,d1
	move.b	mt_counter(pc),d1
mt_rtnskp	
	divu	d0,d1
	swap	d1
	tst.w	d1
	bne.s	mt_rtnend
mt_doretrig	
	move.l	n_start(a6),mt_sample_point(a5)	; set sampledata pointer
	moveq	#0,d0
	move.w	n_length(a6),d0		; set length
	add.l	d0,d0
	add.l	mt_sample_point(a5),d0
	move.l	d0,mt_sample_end(a5)

	move.l	n_loopstart(a6),d0
	cmp.l	mt_sample_point(a5),d0
	bne.s	.mt_set_loop
	moveq	#0,d0
.mt_set_loop	
	move.l	d0,mt_loop_start(a5)

mt_rtnend	
	move.l	(sp)+,d1
	rts

mt_volumefineup
	tst.b	mt_counter
	bne	mt_return2
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	bra	mt_volslideup

mt_volumefinedown
	tst.b	mt_counter
	bne	mt_return2
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	bra	mt_volslidedown2

mt_notecut
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	cmp.b	mt_counter(pc),d0
	bne	mt_return2
	clr.b	n_volume(a6)
	move.w	#0,mt_volume(a5)
	rts

mt_notedelay
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	cmp.b	mt_counter,d0
	bne	mt_return2
	move.w	(a6),d0
	beq	mt_return2
	move.l	d1,-(sp)
	bra	mt_doretrig

mt_patterndelay
	tst.b	mt_counter
	bne	mt_return2
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	tst.b	mt_pattdeltime2
	bne	mt_return2
	addq.b	#1,d0
	move.b	d0,mt_pattdeltime
	rts

mt_funkit
	tst.b	mt_counter
	bne	mt_return2
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	lsl.b	#4,d0
	and.b	#$0f,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	tst.b	d0
	beq	mt_return2
mt_updatefunk
	movem.l	a0/d1,-(sp)
	moveq	#0,d0
	move.b	n_glissfunk(a6),d0
	lsr.b	#4,d0
	beq.s	mt_funkend
	lea	mt_funktable(pc),a0
	move.b	(a0,d0.w),d0
	add.b	d0,n_funkoffset(a6)
	btst	#7,n_funkoffset(a6)
	beq.s	mt_funkend
	clr.b	n_funkoffset(a6)

	move.l	n_loopstart(a6),d0
	moveq	#0,d1
	move.w	n_replen(a6),d1
	add.l	d1,d0
	add.l	d1,d0
	move.l	n_wavestart(a6),a0
	addq.l	#1,a0
	cmp.l	d0,a0
	blo.s	mt_funkok
	move.l	n_loopstart(a6),a0
mt_funkok
	move.l	a0,n_wavestart(a6)
	moveq	#-1,d0
	sub.b	(a0),d0
	move.b	d0,(a0)
mt_funkend
	movem.l	(sp)+,a0/d1
	rts

mt_init_Paula	
	bsr	mt_make_freq
	bsr	mt_make_tables
	bsr	mt_make_frame_f
	bsr	mt_make_voltab
	bsr	mt_make_divtab
	bsr	mt_make_mixcode

.mt_init_trap0	
	lea	mt_save_trap0,a0
	move.l	$80.w,(a0)
	lea	mt_return_Paula,a0
	move.l	a0,$80.w
	rts

**********************************************************************************************
*
*	mt_make_freq
*		fills a table of 23 times 40 values with word values of 0 or 1
*
**********************************************************************************************
mt_make_freq	
	move.l	mt_freq_list,a0			pointer to table with 23*40 words
	moveq	#3,d0				d0 goes from 3 to to 25 both included
.mt_maker	
	move.l	d0,d1
	swap	d1				high word = int part / low word = decimal part
	divu.w	#40,d1				/ 40 updates to the digital buffer
	move.w	d1,d2				decimal part result => D2
	swap	d1
	cmp.w	#20,d1
	blt.s	.mt_no_round
	addq.w	#1,d2				rounding or not the result
.mt_no_round
*						D2 has then the number of reads per update
	moveq	#0,d1
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#39,d7				40 updates to the digital buffer
.mt_make_freq	
	add.w	d2,d1				adds step to D1	comma part
	negx.w	d4
	neg.w	d4				D4 = D4 + X	integer part
	move.w	d4,d5
	move.w	d1,d6
	add.w	d6,d6				D6 = 2*D1	resulting step x 2
	negx.w	d5
	neg.w	d5				D5 = D5 + X	integer part
	cmp.w	d3,d5				compare to previous value
	ble.s	.mt_set_zero			if lower or equal => SET 0
	move.w	d5,d3				save new value as old value in D3
	moveq	#1,d5				SET 1
	move.w	d5,(a0)+			(A0) = 1
	dbra	d7,.mt_make_freq		40 times
	addq.w	#1,d0				from 3 to 25 values
	cmp.w	#26,d0
	bne.s	.mt_maker
	rts

.mt_set_zero	
	moveq	#0,d5
	move.w	d5,(a0)+			(A0) = 0
	dbra	d7,.mt_make_freq		40 times
	addq.w	#1,d0				from 3 to 25 values
	cmp.w	#26,d0
	bne.s	.mt_maker
	rts
**********************************************************************************************



**********************************************************************************************
*
*	mt_make_tables
*		Fills an Amiga dividers indexed table with VBLsteps - 75 ??? at mt_freq_table
*		Example for $71(113): 7090000/(2*113)/50 - 75 = 627.4336 - 75 = 552.4336
*		$226 = 550 ???
*
**********************************************************************************************
mt_make_tables	
	move.l	mt_freq_table,a0
	moveq	#$72-1,d7		114 values
	move.l	#$02260000,d0		filled with $02260000
.mt_make_first	
	move.l	d0,(a0)+
	dbra	d7,.mt_make_first

	moveq	#$72,d0
.mt_maker	
	move.l	mt_amiga_freq,d1	7090000
	move.w	d0,d2			divider
	add.w	d2,d2			x 2
	divu.w	d2,d1			D1 = Amiga clock freq / (dividerx2)
	moveq	#0,d2
	moveq	#0,d3
	move.w	d1,d2
	swap	d1
	cmp.w	d0,d1
	blt.s	.mt_no_round
	addq.w	#1,d2			round or not the result in D2
.mt_no_round	
	divu	#50,d2			/ 50 VBLs
	move.w	d2,d1			save result in D1
	clr.w	d2			rest extended long
	divu.w	#50,d2			/ 50 VBLs
	move.l	d2,d3
	swap	d3
	cmp.w	#50/2,d3
	blt.s	.mt_no_round1
	addq.w	#1,d2			round or not comma result in D2
.mt_no_round1	
	sub.w	#75,d1			subsctract 75 units ?????
	bpl.s	.mt_no_zero
	moveq	#0,d1			if negative set 0/0
	moveq	#0,d2
.mt_no_zero	
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	addq.w	#1,d0
	cmp.w	#$400,d0		from $72 to $3FF (Amiga dividers)
	bne.s	.mt_maker
	rts
**********************************************************************************************



**********************************************************************************************
*
*	mt_make_frame_f
*		mt_frame_freq_p	points to table with 551 pointers
*		mt_frame_freq_t points to table with 27500 words (50 * 550 ?)
*		Fills tables above with 551 pointers and 551*25 = 13775 words like below
*
**********************************************************************************************
mt_make_frame_f	
	move.l	mt_frame_freq_t,a0
	move.l	mt_frame_freq_p,a1
	moveq	#75,d0				from 75 to 625 both included
.mt_maker	
	move.l	d0,d1
	divu.w	#25,d1				/ 25
	moveq	#0,d3
	move.w	d1,d2				result
	subq.w	#3,d2				- 3 to start from 0 !!!
	clr.w	d1
	divu.w	#25,d1				rest.long / 25
	move.w	d1,d3
	addq.w	#1,d3				result + 1
.mt_no_round	
	move.l	a0,(a1)+
	moveq	#0,d4
	moveq	#24,d7				repeat 25 times
	moveq	#0,d1				D1/D4 add counter D2/D3 value to add
.mt_make_it	
	moveq	#0,d1
	add.w	d3,d4				comma part
	addx.w	d2,d1				integer part + X from comma part
	move.w	d1,d5
	mulu.w	#23<<7,d5			$B80 * integer result (max = 22 ((625-75)/25))
	add.w	d1,d1
	add.w	d1,d1				integer result * 4
	or.w	d1,d5				include in D5 max 88 = $58 (7 bits) [PPPPPPPPPSSSSS00]
	move.w	d5,(a0)+			store it: PPPPPPPPP = 23*SSSSS
	dbra	d7,.mt_make_it
	addq.w	#1,d0
	cmp.w	#626,d0
	bne.s	.mt_maker
	rts
**********************************************************************************************


**********************************************************************************************
*
*	mt_make_voltab
*		mt_volume_tab points to $2100 words but only $2000 required from $100 boundary
*		fills volume table
*		
*
**********************************************************************************************
mt_make_voltab	
	lea	mt_volume_tab,a0
	move.l	(a0),d0			get pointer
	andi.w	#$ff00,d0		clear low byte
	add.l	#$100,d0		round to upword 256 bytes boundary
	move.l	d0,(a0)			set new pointer
	move.l	d0,a0			A0 points to start of volume table
	moveq	#0,d0			volume levels 0 to $40
	moveq	#0,d1			first from 00 to $3F
	moveq	#0,d3
.mt_clop0	
	move.w	d1,d2			D1 counter
	ext.w	d2			D2 = D1 with sign
	muls.w	d0,d2			* volume level
	asr.w	#6,d2			/ 64		6bit*6bit / 64 = 12 bit / 6bit = max $3F
	move.b	d2,(a0)+		store adjusted result to byte
	addq.w	#1,d1
	cmp.w	#$40,d1
	bne.s	.mt_clop0
	lea	$80(a0),a0		now the same for negative values
	move.w	#$c0,d1
.mt_clop1	
	move.w	d1,d2			from $C0 to $FF
	ext.w	d2
	muls.w	d0,d2
	asr.w	#6,d2
	move.b	d2,(a0)+
	addq.w	#1,d1
	cmp.w	#$100,d1
	bne.s	.mt_clop1

	moveq	#0,d1
	addq.w	#1,d0
	cmp.w	#$41,d0
	bne.s	.mt_clop0
	rts
**********************************************************************************************

**********************************************************************************************
*
*	mt_make_divtab
*		mt_div_table has a pointer to a table of $1000 words
*		
*
**********************************************************************************************
mt_make_divtab	
	moveq	#1,d0			D0 starts with 1 and ends with $40
	moveq	#1,d1			D1 starts with 1 and ends with $40
	move.l	mt_div_table,a0
.mt_init_div	
	move.l	d1,d2
	asl.w	#6,d2			D2 x 64
	move.w	d0,d3
	divu.w	d0,d2			D2 x 64 / D0
	lsr.w	#1,d3
	negx.w	d3
	neg.w	d3			D3 = bit 1 of D0 + D0/2
	move.w	d2,d4
	swap	d2			rest of division
	cmp.w	d3,d2
	blt.s	.mt_no_round
	addq.w	#1,d4			round or not the result in D4
.mt_no_round
	move.w	d4,(a0)+		update table with division result
	addq.w	#1,d0
	cmp.w	#$41,d0
	bne.s	.mt_init_div
	moveq	#1,d0
	addq.w	#1,d1
	cmp.w	#$41,d1
	bne.s	.mt_init_div
	rts
**********************************************************************************************

**********************************************************************************************
*
*	mt_make_mixcode
*		mt_mixcode_p	points to table with 529 long pointers (23 x 23)
*		mt_mixer_chunk	pointer table with 60877 words !!!
*		
*
**********************************************************************************************
mt_make_mixcode	
	move.l	mt_mixcode_p,a0
	move.l	mt_mixer_chunk,a1
	move.l	mt_freq_list,a2
	lea	(a2),a4
	moveq	#22,d7				23 times
	moveq	#22,d6				23 times
.mt_maker	
	move.l	a1,(a0)+
	lea	(a2),a3
	moveq	#40-1,d5			40 updates to the digi buffer
.mt_make_it	
	move.w	.mt_copy,(a1)+			last update DIGIBUF instruction move.b	d0/d1/d2,(sp)+
	move.w	(a3)+,d0			mt_freq_list data 0 or 1 for ch0
	move.w	(a4)+,d1			mt_freq_list data 0 or 1 for ch1
	add.w	d1,d1				0 or 2
	or.w	d1,d0				0,1,2,3  D1_bit|D0_bit
	dbne	d5,.mt_make_it			if 0 then just copy update
	tst.w	d5				was this the last one ?
	beq.s	.mt_end_ops			no / yes = treat last case mt_ana_code01/02/03
	bpl.s	.mt_no_exit			positive so we still have cases to handle
.mt_make_end	
	move.w	#$4ed6,(a1)+			JMP (A6)
	dbra	d6,.mt_maker			next one of the 23 speed cases for voice 1
	moveq	#22,d6				set next set of 23 speed cases for voice 1
	lea	80(a2),a2			next block of control words
	move.l	mt_freq_list,a4			control words table start
	dbra	d7,.mt_maker			next one of the 23 speed cases for voice 0
	rts
.mt_no_exit
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	move.w	d5,d4				number of cases left to handle
	subq.w	#1,d4				-1 for dbf
.mt_analyse	
	move.w	(a3)+,d1			mt_freq_list data 0 or 1 for ch0
	move.w	(a4)+,d2			mt_freq_list data 0 or 1 for ch1
	add.w	d2,d2				0 or 2
	or.w	d2,d1				0,1,2,3  D2_bit|D1_bit
	add.w	d1,d1
	add.w	d1,d1				x 4 for table pointer purposes
	move.l	.mt_ana_code(pc,d1.w),a6	get subroutine to execute
	jsr	(a6)
	dbra	d4,.mt_analyse			reapeat number of times left
	move.l	(sp)+,a4
	move.l	(sp)+,a3
	tst.w	d1
	dbeq	d5,.mt_make_it			if d1 is 0 the stop dbra
	bra.s	.mt_end_ops
.mt_ana_code	
	dc.l	.mt_ana_code0
	dc.l	.mt_ana_code1
	dc.l	.mt_ana_code2
	dc.l	.mt_ana_code3

.mt_end_ops	
	cmp.w	#3,d0
	beq.s	.mt_ana_code03
	cmp.w	#2,d0
	beq.s	.mt_ana_code02

.mt_ana_code01

*						code 01 means read from ch0 and not from ch1

	lea	.mt_copy,a6
	move.w	.mt_copy2,(a6)			last update instruction is 	move.b d2,(sp)+
	move.w	.mt_ch0_fetch,(a1)+		read from voice 0		move.b	(a0)+,d0
	move.l	.mt_add012,(a1)+		add from voice 1 in d2 		move.b d0,d2  add.b d1,d2
	dbra	d5,.mt_make_it			loop to 40 times dbf label
	move.w	#$4ed6,(a1)+							jmp	(a6)
	dbra	d6,.mt_maker			loop to 23 times 2nd loop
	moveq	#22,d6				set D6 to 23 times looop
	lea	80(a2),a2			next 40 words in mt_freq_list
	move.l	mt_freq_list,a4			A4 points to start of mt_freq_list
	dbra	d7,.mt_maker			loop to 23 times 1st loop
	rts

.mt_ana_code02	

*						code 10 means read from ch1 and not from ch0

	lea	.mt_copy,a6
	move.w	.mt_copy2,(a6)			last update instruction is 	move.b d2,(sp)+
	move.w	.mt_ch1_fetch,(a1)+		read from voice 1		move.b (a1)+,d1
	move.l	.mt_ch1_fetch+2,(a1)+		and get the volumed byte	move.l d1,a2  move.b (a2),d1
	move.l	.mt_add012,(a1)+		add voice 0 and voice 1 in D2	move.b d0,d2  add.b d1,d2

	dbra	d5,.mt_make_it			loop to 40 times dbf label
	move.w	#$4ed6,(a1)+							jmp	(a6)
	dbra	d6,.mt_maker			loop to 23 times 2nd loop
	moveq	#22,d6				set D6 to 23 times looop
	lea	80(a2),a2			next 40 words in mt_freq_list
	move.l	mt_freq_list,a4			A4 points to start of mt_freq_list
	dbra	d7,.mt_maker			loop to 23 times 1st loop
	rts

.mt_ana_code03	

*						code 11 means read from both ch0 and ch1

	lea	.mt_copy,a6
	move.w	.mt_copy2,(a6)			last update instruction is 	move.b d2,(sp)+
	move.l	.mt_ch01fetadd1,(a1)+		read from voice 0 and 1		move.b (a0)+,d0  move.b (a1)+,d1
	move.l	.mt_ch01fetadd1+4,(a1)+		get volumed byte V1		move.l d1,a2  move.b (a2),d1
	move.l	.mt_add012,(a1)+		add voice 0 and voice 1 in D2	move.b d0,d2  add.b d1,d2

	dbra	d5,.mt_make_it			loop to 40 times dbf label
	move.w	#$4ed6,(a1)+							jmp	(a6)
	dbra	d6,.mt_maker			loop to 23 times 2nd loop
	moveq	#22,d6				set D6 to 23 times looop
	lea	80(a2),a2			next 40 words in mt_freq_list
	move.l	mt_freq_list,a4			A4 points to start of mt_freq_list
	dbra	d7,.mt_maker			loop to 23 times 1st loop
	rts

.mt_ana_code0	
	rts

.mt_ana_code1	
	cmp.w	#3,d0
	beq.s	.mt_ana_code13
	cmp.w	#2,d0
	beq.s	.mt_ana_code12

.mt_ana_code11	

*						code 01 means read from ch0 and not from ch1

	moveq	#0,d4				stop dbf
	moveq	#1,d1				no code 00 case
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)			last update instruction is 	move.b d0,(sp)+
	move.w	.mt_ch0_fetch,(a1)+		read from voice 0		move.b	(a0)+,d0
	move.w	.mt_add10,(a1)+			add value from V1 to D0		add.b d1,d0
	rts

.mt_ana_code12	

*						code 10 means read from ch1 and not from ch0

	moveq	#0,d4				stop dbf
	moveq	#1,d1				no code 00 case
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)			last update instruction is 	move.b d0,(sp)+
	move.w	.mt_ch1_fetch,(a1)+		read from voice 1		move.b (a1)+,d1
	move.l	.mt_ch1_fetch+2,(a1)+		and get the volumed byte	move.l d1,a2  move.b (a2),d1
	move.w	.mt_add10,(a1)+			add value from V1 to D0		add.b d1,d0
	rts

.mt_ana_code13	

*						code 11 means read from both ch0 and ch1

	moveq	#0,d4				stop dbf
	moveq	#1,d1				no code 00 case
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)			last update instruction is 	move.b d0,(sp)+
	move.l	.mt_ch01fetadd1,(a1)+		read from voice 0 and 1		move.b (a0)+,d0  move.b (a1)+,d1
	move.l	.mt_ch01fetadd1+4,(a1)+		get volumed byte V1		move.l d1,a2  move.b (a2),d1
	move.w	.mt_add10,(a1)+			add value from V1 to D0		add.b d1,d0
	rts

.mt_ana_code2	
	cmp.w	#3,d0
	beq.s	.mt_ana_code23
	cmp.w	#2,d0
	beq.s	.mt_ana_code22
.mt_ana_code21	

*						code 01 means read from ch0 and not from ch1

	moveq	#0,d4				stop dbf
	moveq	#1,d1				no code 00 case
	lea	.mt_copy,a6
	move.w	.mt_copy1,(a6)			last update instruction is 	move.b d1,(sp)+
	move.w	.mt_ch0_fetch,(a1)+		read from voice 0		move.b	(a0)+,d0
	move.w	.mt_add01,(a1)+			add Voice 0 byte to D1		add.b d0,d1
	rts

.mt_ana_code22	

*						code 10 means read from ch1 and not from ch0

	moveq	#0,d4				stop dbf
	moveq	#1,d1				no code 00 case
	lea	.mt_copy,a6
	move.w	.mt_copy1,(a6)			last update instruction is 	move.b d1,(sp)+
	move.w	.mt_ch1_fetch,(a1)+		read from voice 1		move.b (a1)+,d1
	move.l	.mt_ch1_fetch+2,(a1)+		and get the volumed byte	move.l d1,a2  move.b (a2),d1
	move.w	.mt_add01,(a1)+			add Voice 0 byte to D1		add.b d0,d1
	rts
	rts

.mt_ana_code23	

*						code 11 means read from both ch0 and ch1

	moveq	#0,d4				stop dbf
	moveq	#1,d1				no code 00 case
	lea	.mt_copy,a6
	move.w	.mt_copy1,(a6)			last update instruction is 	move.b d1,(sp)+
	move.l	.mt_ch01fetadd1,(a1)+		read from voice 0 and 1		move.b (a0)+,d0  move.b (a1)+,d1
	move.l	.mt_ch01fetadd1+4,(a1)+		get volumed byte V1		move.l d1,a2  move.b (a2),d1
	move.w	.mt_add01,(a1)+			add Voice 0 byte to D1		add.b d0,d1
	rts

.mt_ana_code3	
	cmp.w	#3,d0
	beq.s	.mt_ana_code33
	cmp.w	#2,d0
	beq.s	.mt_ana_code32

.mt_ana_code31	

*						code 01 means read from ch0 and not from ch1

	moveq	#0,d4				stop dbf
	moveq	#1,d1				no code 00 case
	lea	.mt_copy,a6
	move.w	.mt_copy1,(a6)			last update instruction is 	move.b d1,(sp)+
	move.w	.mt_ch0_fet_add,(a1)+		add the value from V0 to D1	add.b (a0)+,d1
	rts

.mt_ana_code32	

*						code 10 means read from ch1 and not from ch0

	moveq	#0,d4				stop dbf
	moveq	#1,d1				no code 00 case
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)			last update instruction is 	move.b d0,(sp)+
	move.w	.mt_ch1_fet_add,(a1)+		read from voice 1		move.b (a1)+,d1
	move.l	.mt_ch1_fet_add+2,(a1)+		add volumed byte to D0		move.l d1,a2  add.b (a2),d0
	rts

.mt_ana_code33	

*						code 11 means read from both ch0 and ch1

	moveq	#0,d4				stop dbf
	moveq	#1,d1				no code 00 case
	lea	.mt_copy,a6
	move.w	.mt_copy0,(a6)			last update instruction is 	move.b d0,(sp)+
	move.l	.mt_ch01fetadd0,(a1)+		get values from V0 and V1	move.b (a0)+,d0  move.b (a1)+,d1
	move.l	.mt_ch01fetadd0+4,(a1)+		add volumed byte to D0		move.l d1,a2  add.b (a2),d0
	rts

.mt_copy	
	move.b	d2,(sp)+
.mt_copy0	
	move.b	d0,(sp)+
.mt_copy1	
	move.b	d1,(sp)+
.mt_copy2	
	move.b	d2,(sp)+
.mt_ch0_fetch	
	move.b	(a0)+,d0
.mt_ch0_fet_add	
	add.b	(a0)+,d1
.mt_ch1_fetch	
	move.b	(a1)+,d1
	move.l	d1,a2
	move.b	(a2),d1
.mt_ch1_fet_add	
	move.b	(a1)+,d1
	move.l	d1,a2
	add.b	(a2),d0
.mt_ch01fetadd0	
	move.b	(a0)+,d0
	move.b	(a1)+,d1
	move.l	d1,a2
	add.b	(a2),d0
.mt_ch01fetadd1	
	move.b	(a0)+,d0
	move.b	(a1)+,d1
	move.l	d1,a2
	move.b	(a2),d1
.mt_add01	
	add.b	d0,d1
.mt_add10	
	add.b	d1,d0
.mt_add012	
	move.b	d0,d2
	add.b	d1,d2

**********************************************************************************************
**********************************************************************************************



mt_stop_Paula	
	move.l	mt_save_trap0,$80.w

	move.w	mt_LCM_mask,d0
	move.w	mt_LCM_left,d1
	or.w	#20,d1
	bsr	.mt_set_LCM
	move.w	mt_LCM_right,d1
	or.w	#20,d1
	bsr	.mt_set_LCM
	rts

.mt_set_LCM	
	lea	$ffff8900.w,a6
	move.w	d0,$24(a6)
	move.w	d1,$22(a6)
    rept	16
	nop
    endr
.mt_LCM_loop	
	cmp.w	$24(a6),d0
	bne.s	.mt_LCM_loop
	rts

mt_Paula	
	lea	$ffff8900.w,a6
	move.l	mt_LCM_set,a0
	jmp	(a0)

mt_return_Paula	
	lea	mt_physic_buf,a0	switch digi buffers pointers
	lea	mt_logic_buf,a1
	move.l	(a0),d0
	move.l	(a1),(a0)
	move.l	d0,(a1)
	move.l	mt_save_SSP,sp		set back SSP
	rts

	rsreset
mt_temp_regs	rs.l	2
mt_temp_old_sam	rs.w	2



mt_channel

					A3 points to V0 struct
					A4 points to V1 struct
******************
****	STARTMACRO
    macro

	move.l	(a3),d0
	bne.s	.mt_v0_active
	lea	mt_dummy_tab,a3		if not active then get dummy data struct
.mt_v0_active	
	move.l	(a4),d0
	bne.s	.mt_v1_active
	lea	mt_dummy_tab,a4		if not active then get dummy data struct
.mt_v1_active	

	move.w	mt_volume(a3),d0
	cmp.w	mt_volume(a4),d0
	bge.s	.mt_no_swap
	exg	a3,a4			switch or not struct pointer to respect volume order
.mt_no_swap	
	move.w	mt_volume(a3),d0
	moveq	#0,d1
	move.w	d0,(a1)
	beq.s	.mt_set_zero
	move.w	mt_volume(a4),d1
	beq.s	.mt_set_zero
	subq.w	#1,d0
	subq.w	#1,d1
	andi.w	#$3f,d0
	andi.w	#$3f,d1
	asl.w	#6,d1
	or.w	d0,d1
	add.w	d1,d1
	move.l	mt_div_table,a1
	move.w	(a1,d1.w),d1
.mt_set_zero	
	move.l	mt_volume_tab,a1
	asl.w	#8,d1
	add.l	a1,d1				volume tab pointer from calcs
	move.l	mt_sample_point(a3),a0		V0 pointer
	move.l	mt_sample_point(a4),a1		V1 pointer
	lea	mt_temp_old_sam(a6),a2
	move.b	(a2)+,d0			3 main bytes as they were last time
	move.b	(a2)+,d1
	move.b	(a2)+,d2

	move.w	mt_period(a3),d3
	move.l	mt_freq_table,a2		read VBL step table
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a2,d3.w),d3			step
	move.w	d3,d4				comma part
	swap	d3				integer part
	add.w	mt_add_iw(a3),d4		add previous comma part rest
	negx.w	d3
	neg.w	d3				correct integer part with X
	move.w	d4,mt_add_iw(a3)		keep comma part rest for next time

	move.w	mt_period(a4),d4		same thing for other voice
	add.w	d4,d4
	add.w	d4,d4
	move.l	(a2,d4.w),d4
	move.w	d4,d5
	swap	d4
	add.w	mt_add_iw(a4),d5
	negx.w	d4
	neg.w	d4
	move.w	d5,mt_add_iw(a4)

	move.l	mt_frame_freq_p,a2
	add.w	d3,d3				value up to 551 x 4 to get pointer
	add.w	d3,d3
	move.l	(a2,d3.w),d3
	add.w	d4,d4
	add.w	d4,d4
	move.l	(a2,d4.w),d4			same here for other voice

	move.l	a3,(a6)+			keep pointers to structs
	move.l	a4,(a6)+
	move.l	d3,a3				pointer to freq values [PPPPPPPPPSSSSS00]
	move.l	d4,a4				with PPPPPPPPP = 23 x SSSSS
	move.l	mt_mixcode_p,a5
	moveq	#$1f<<2,d5			$7C
	move.w	#$1ff<<7,d6			$FF80
	move.l	a6,d7				save struct ptr

*						repeat the same for 25 blocks
*						each block will produce 40 bytes for digibuf
*						at 50 KHz (only 20 bytes needed at 25 KHz :) )

	lea	.mt_return,a6			points to 1st block
	move.w	(a3)+,d3
	move.w	(a4)+,d4
	and.w	d5,d4				isolate 000000000SSSSS00
	and.w	d6,d3				isolate PPPPPPPPP0000000
	lsr.w	#5,d3				        00000PPPPPPPPP00
	add.w	d3,d4				      + 000000000SSSSS00
	move.l	(a5,d4.w),a2				0000xxxxxxxxxx00 0...528 = 529 ptrs
	jmp	(a2)
.mt_return
    rept	24
	lea	$16(a6),a6			points to next block
	move.w	(a3)+,d3
	move.w	(a4)+,d4
	and.w	d5,d4
	and.w	d6,d3
	lsr.w	#5,d3
	add.w	d3,d4
	move.l	(a5,d4.w),a2
	jmp	(a2)
    endr

	move.l	d7,a6				get struct ptr back
	move.l	-(a6),a4			and voice ptrs back
	move.l	-(a6),a3
	lea	mt_temp_old_sam(a6),a2		store registers d0 d1 d2 like they were left
	move.b	d0,(a2)+
	move.b	d1,(a2)+
	move.b	d2,(a2)+

	move.l	a0,mt_sample_point(a3)		sample end ptrs and loop checks
	cmp.l	mt_sample_end(a3),a0
	blt.s	.mt_no_end_v0
	move.l	mt_loop_start(a3),d0
	beq.s	.mt_no_loop_v0
	move.l	a0,d1
	sub.l	mt_sample_end(a3),d1
	neg.l	d0
	add.l	mt_sample_end(a3),d0
	divu	d0,d1
	clr.w	d1
	swap	d1
	add.l	mt_loop_start(a3),d1
	move.l	d1,mt_sample_point(a3)
	bra.s	.mt_no_end_v0
.mt_no_loop_v0	
	move.w	mt_check_dummy(a3),d2
	bne.s	.mt_no_end_v0
	moveq	#0,d2
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	move.l	d2,(a3)+
.mt_no_end_v0
	move.l	a1,mt_sample_point(a4)
	cmp.l	mt_sample_end(a4),a1
	blt.s	.mt_no_end_v1
	move.l	mt_loop_start(a4),d0
	beq.s	.mt_no_loop_v1
	move.l	a1,d1
	sub.l	mt_sample_end(a4),d1
	neg.l	d0
	add.l	mt_sample_end(a4),d0
	divu	d0,d1
	clr.w	d1
	swap	d1
	add.l	mt_loop_start(a4),d1
	move.l	d1,mt_sample_point(a4)
	bra.s	.mt_no_end_v1
.mt_no_loop_v1	
	move.w	mt_check_dummy(a4),d2
	bne.s	.mt_no_end_v1
	moveq	#0,d2
	move.l	d2,(a4)+
	move.l	d2,(a4)+
	move.l	d2,(a4)+
	move.l	d2,(a4)+
	move.l	d2,(a4)+
.mt_no_end_v1	
	lea	mt_dummy_tab,a3
	move.l	4(a3),(a3)
    endm

****	ENDMACRO
****************

mt_emulate	
	lea	mt_save_USP,a0
	move.l	sp,(a0)				save stack pointer

	lea	mt_channel_p,a0
	lea	mt_left_volume,a1
	lea	mt_left_temp,a6

	move.l	mt_logic_buf,sp			digi buffer STE format
	move.l	0(a0),a3			real voice 0
	move.l	$c(a0),a4			real voice 3

*						deals with real voices 0 and 3

mt_channel03	
	mt_channel			**** MACRO

	lea	mt_channel_p,a0
	lea	mt_right_volume,a1
	lea	mt_right_temp,a6

	move.l	mt_logic_buf,sp			digi buffer STE format
	lea	1(sp),sp			other byte
	move.l	4(a0),a3			real voice 1
	move.l	8(a0),a4			real voice 2

*						deals with real voices 1 and 2

mt_channel12	
	mt_channel			**** MACRO

mt_check_vols	
	lea	mt_left_volume,a0
	lea	mt_left_volold,a1
	move.w	(a0)+,d0
	cmp.w	(a1),d0
	sne	d1
	andi.w	#$4,d1
	move.w	d0,(a1)+
	move.w	(a0)+,d0
	cmp.w	(a1),d0
	sne	d2
	andi.w	#$8,d2
	or.w	d2,d1
	move.w	d0,(a1)+
	lea	mt_LCM_set,a0
	move.l	mt_LCM_set_conf(pc,d1.w),(a0)

	move.l	mt_save_USP,sp
	trap	#0				switch buffers and stack pointer

mt_LCM_set_conf	
	dc.l	mt_set_left	;for timing only
	dc.l	mt_set_left
	dc.l	mt_set_right
	dc.l	mt_set_all

mt_set_left	
	move.w	mt_LCM_mask,$24(a6)
	move.w	mt_left_volume,d0
	add.w	d0,d0
	move.w	.mt_LCM_vol_tab(pc,d0.w),d0
	or.w	mt_LCM_left,d0
	move.w	d0,$22(a6)
	move.l	mt_physic_buf,d0
	movep.l	d0,$1(a6)
	add.l	mt_replay_len,d0
	movep.l	d0,$d(a6)
	move.w	mt_frequency,$20(a6)
	move.w	mt_start,(a6)

	lea	mt_save_SSP,a0
	move.l	sp,(a0)
	pea	mt_emulate
	move.w	sr,d0
	andi.w	#$fff,d0
	move.w	d0,-(sp)
	rte

.mt_LCM_vol_tab	
	dc.w	0
	dc.w	2,5,7,8,9,10,10,11,11,12,12,13,13,13,14,14
	dc.w	14,14,15,15,15,15,16,16,16,16,16,16,17,17,17,17
	dc.w	17,17,17,18,18,18,18,18,18,18,18,18,18,19,19,19
	dc.w	19,19,19,19,19,19,19,19,19,20,20,20,20,20,20,20

mt_set_right	
	move.w	mt_LCM_mask,$24(a6)
	move.w	mt_right_volume,d0
	add.w	d0,d0
	move.w	.mt_LCM_vol_tab(pc,d0.w),d0
	or.w	mt_LCM_right,d0
	move.w	d0,$22(a6)
	move.l	mt_physic_buf,d0
	movep.l	d0,$1(a6)
	add.l	mt_replay_len,d0
	movep.l	d0,$d(a6)
	move.w	mt_frequency,$20(a6)
	move.w	mt_start,(a6)

	lea	mt_save_SSP,a0
	move.l	sp,(a0)
	pea	mt_emulate
	move.w	sr,d0
	andi.w	#$fff,d0
	move.w	d0,-(sp)
	rte

.mt_LCM_vol_tab	
	dc.w	0
	dc.w	2,5,7,8,9,10,10,11,11,12,12,13,13,13,14,14
	dc.w	14,14,15,15,15,15,16,16,16,16,16,16,17,17,17,17
	dc.w	17,17,17,18,18,18,18,18,18,18,18,18,18,19,19,19
	dc.w	19,19,19,19,19,19,19,19,19,20,20,20,20,20,20,20

mt_set_all	
	move.w	mt_LCM_mask,$24(a6)
	move.w	mt_left_volume,d0
	add.w	d0,d0
	move.w	.mt_LCM_vol_tab(pc,d0.w),d0
	or.w	mt_LCM_left,d0
	move.w	d0,$22(a6)
	move.l	mt_physic_buf,d0
	movep.l	d0,$1(a6)
	add.l	mt_replay_len,d0
	movep.l	d0,$d(a6)
	move.w	mt_frequency,$20(a6)
	move.w	mt_start,(a6)
	move.w	mt_LCM_mask,d1
	move.w	mt_right_volume,d0
	add.w	d0,d0
	move.w	.mt_LCM_vol_tab(pc,d0.w),d0
	or.w	mt_LCM_right,d0
.mt_test_LCM	
	cmp.w	$24(a6),d1
	bne.s	.mt_test_LCM
	move.w	d0,$22(a6)

	lea	mt_save_SSP,a0
	move.l	sp,(a0)
	pea	mt_emulate
	move.w	sr,d0
	andi.w	#$fff,d0
	move.w	d0,-(sp)
	rte

.mt_LCM_vol_tab	
	dc.w	0
	dc.w	2,5,7,8,9,10,10,11,11,12,12,13,13,13,14,14
	dc.w	14,14,15,15,15,15,16,16,16,16,16,16,17,17,17,17
	dc.w	17,17,17,18,18,18,18,18,18,18,18,18,18,19,19,19
	dc.w	19,19,19,19,19,19,19,19,19,20,20,20,20,20,20,20

	section	data
mt_funktable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_vibratotable
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

mt_periodtable
; tuning 0, normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

	dc.w	$416E,$6F74,$6865,$7220
	dc.w	$6772,$6561,$7420,$636F
	dc.w	$6465,$2062,$793A,$204C
	dc.w	$616E,$6365,$2000

mt_chan1temp	dc.l	0,0,0,0,$3ff0000,$00010000,0,0,0,0,0
mt_chan2temp	dc.l	0,0,0,0,$3ff0000,$00020000,0,0,0,0,0
mt_chan3temp	dc.l	0,0,0,0,$3ff0000,$00040000,0,0,0,0,0
mt_chan4temp	dc.l	0,0,0,0,$3ff0000,$00080000,0,0,0,0,0

mt_samplestarts	
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mt_songdataptr	dc.l	0
mt_module_end	dc.l	0

mt_speed	dc.b	6
mt_counter	dc.b	0
mt_songpos	dc.b	0
mt_pbreakpos	dc.b	0
mt_posjumpflag	dc.b	0
mt_pbreakflag	dc.b	0
mt_lowmask	dc.b	0
mt_pattdeltime	dc.b	0
mt_pattdeltime2	dc.b	0,0

mt_patternpos	dc.w	0
mt_dmacontemp	dc.w	0

mt_amiga_freq	dc.l	7090000
mt_freq_list	dc.l	mt_freqer_list
mt_freq_table	dc.l	mt_freq_tab
mt_volume_tab	dc.l	mt_vol_tab
mt_div_table	dc.l	mt_div_tab
mt_frame_freq_t	dc.l	mt_frame_freq
mt_frame_freq_p	dc.l	mt_frame_freqp
mt_mixcode_p	dc.l	mt_mixcodes
mt_mixer_chunk	dc.l	mt_mix_chunk
mt_channel_p	
	dc.l	mt_channel_0
	dc.l	mt_channel_1
	dc.l	mt_channel_2
	dc.l	mt_channel_3
mt_physic_buf	dc.l	mt_replay_buf0
mt_logic_buf	dc.l	mt_replay_buf1
mt_replay_len	dc.l	2000
mt_save_SSP	dc.l	0
mt_save_USP	dc.l	0
mt_save_trap0	dc.l	0
mt_LCM_set	dc.l	mt_set_all
mt_start	dc.w	$0001
mt_frequency	dc.w	$0003			$0002 for 25 KHz replay
mt_left_volume	dc.w	0
mt_right_volume	dc.w	0
mt_left_volold	dc.w	0
mt_right_volold	dc.w	0
mt_LCM_mask	dc.w	$07ff
mt_LCM_left	dc.w	$540
mt_LCM_right	dc.w	$500
mt_left_temp	dc.l	0,0,0		mt_temp_regs 2x.l  mt_temp_old_sam 2x.w
mt_right_temp	dc.l	0,0,0		mt_temp_regs 2x.l  mt_temp_old_sam 2x.w

mt_channel_0	
	dc.l	0		mt_sample_point if 0 then not active and use mt_dummy_tab
	dc.l	0		mt_sample_end
	dc.l	0		mt_loop_start
	dc.w	0		mt_volume
	dc.w	$3ff		mt_period
	dc.w	0		mt_add_iw
	dc.w	0		mt_check_dummy
mt_channel_1	
	dc.l	0		mt_sample_point if 0 then not active and use mt_dummy_tab
	dc.l	0		mt_sample_end
	dc.l	0		mt_loop_start
	dc.w	0		mt_volume
	dc.w	$3ff		mt_period
	dc.w	0		mt_add_iw
	dc.w	0		mt_check_dummy
mt_channel_2	
	dc.l	0		mt_sample_point if 0 then not active and use mt_dummy_tab
	dc.l	0		mt_sample_end
	dc.l	0		mt_loop_start
	dc.w	0		mt_volume
	dc.w	$3ff		mt_period
	dc.w	0		mt_add_iw
	dc.w	0		mt_check_dummy
mt_channel_3	
	dc.l	0		mt_sample_point if 0 then not active and use mt_dummy_tab
	dc.l	0		mt_sample_end
	dc.l	0		mt_loop_start
	dc.w	0		mt_volume
	dc.w	$3ff		mt_period
	dc.w	0		mt_add_iw
	dc.w	0		mt_check_dummy
	dc.w	0

mt_dummy_tab	
	dc.l	mt_dummy_spl	mt_sample_point if 0 then not active and use mt_dummy_tab
	dc.l	mt_dummy_spl	mt_sample_end
	dc.l	0		mt_loop_start
	dc.w	0		mt_volume
	dc.w	$3ff		mt_period
	dc.w	0		mt_add_iw
	dc.w	-1		mt_check_dummy

mt_data	incbin	"modules\*.mod"
	ds.w	31*640/2	;These zeroes are necessary!

	section	bss
mt_freqer_list	ds.w	23*40
mt_freq_tab	ds.l	$400
mt_vol_tab	ds.w	$4200/2
mt_div_tab	ds.w	$1000
mt_dummy_spl	ds.w	320
mt_frame_freqp	ds.l	551
mt_mixcodes	ds.l	529
mt_replay_buf0	ds.w	1000
mt_replay_buf1	ds.w	1000
mt_frame_freq	ds.w	27500
mt_mix_chunk	ds.w	60877
