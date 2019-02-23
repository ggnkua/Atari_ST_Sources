* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* MIDI MASTER DRUMMER Assembly Language Routines
* by David Snow
* (C) Copyright 1990 by Antic Publishing, Inc.
* * * * * * * * * * *  * * * * * * * * * * * * * * * * * * * * * * * * *
* PARAMETER ARRAY
*    4(a6)=f_code
*    12(a6)=pat_number
*    20(a6)=pulse_total%
*    28(a6)=pat_array%
*    36(a6)=d_status%
*    44(a6)=d_chanl%
*    52(a6)=d_pitch%
*    60(a6)=clcks
*    68(a6)=mous_flg%
*    76(a6)=seq_part%
*    84(a6)=end_flg%
*    92(a6)=t_arrow%
*    100(a6)=tempo%
*    108(a6)=base_vel%
*    116(a6)=t_flag%
*    124(a6)=v_arrow%
*    132(a6)=v_flag%
*    140(a6)=r%
*    148(a6)=key%
*    156(a6)=btcl (clocks/quarter note)
*    164(a6)=mtcl (clocks/metronome click)
*    172(a6)=mflg% (metronome-flag pointer)
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
          move.l 6(a7),a6               a6=parameter-array pointer
          cmpi.w #0,6(a6)               test f_codes:
          beq initialize                     0=initialize vdi array table
          cmpi.w #1,6(a6)
          beq check_mouse                    1=check mouse (pattern mode)
          cmpi.w #2,6(a6)
          beq playback                       2=playback (pattern mode)
          cmpi.w #3,6(a6)
          beq stop_play                      3=stop playback
          cmpi.w #4,6(a6)
          beq playback                       4=playback (sequence mode)
          cmpi.w #5,6(a6)
          beq playback                       5=playback (song mode)
          cmpi.w #6,6(a6)
          beq check_mouse                    6=check mouse (seq and song mode)
          cmpi.w #7,6(a6)
          beq slave_start                    7=install slave flag/MIDI start flag
          cmpi.w #8,6(a6)
          beq erase_all                      8=erase all patterns
          cmpi.w #9,6(a6)
          beq set_accvel                     9=set accent velocity value
          cmpi.w #10,6(a6)
          beq accent_sym                     10=retrieve accent symbol
          cmpi.w #11,6(a6)
          beq restore_vec24                  11=restore spurious interrupt vector
          rts

* INITIALIZE * * * * * * * * * * *
initialize lea gem_array(PC),a0         save GEM array-table pointer
          move.l 12(a6),(a0)
          dc.w $a000                   vdisys initialization
          lea varpb(PC),a6              save array pointers:
          move.l 4(a0),(a6)                  contrl
          move.l 8(a0),4(a6)                 intin
          move.l 12(a0),8(a6)                ptsin
          move.l 16(a0),12(a6)               intout
          move.l 20(a0),16(a6)               ptsout

          move.w #4,-(a7)               get resolution
          trap #14
          addq.l #2,a7
          subq.w #1,d0                  0=med res, 1=hi res
          lea res_flag(PC),a0
          move.w d0,(a0)

          pea new_vec24(PC)             replace spurious interrupt vector
          move.w #38,-(a7)
          trap #14
          addq.l #6,a7
          rts

new_vec24 lea save_vec24(PC),a0         save spurious interrupt vector
          move.l $60,(a0)
          lea dummy_vec24(PC),a0        replace with dummy vector
          move.l a0,$60
          rts

dummy_vec24 rte

* RESTORE SPURIOUS INTERRUPT VECTOR * * * * *
restore_vec24 pea old_vec24(PC)         restore spurious interrupt vector
          move.w #38,-(a7)
          trap #14
          addq.l #6,a7
          rts

old_vec24 lea save_vec24(PC),a0         retrieve spurious interrupt vector
          move.l (a0),$60
          rts

* CHECK MOUSE * * * * * * * * * * *
check_mouse bsr replace_mode
          bsr vq_mouse
          bsr xor_mode
          rts

* INSTALL SLAVE FLAG/MIDI START FLAG
slave_start lea slave_flag(PC),a0            install slave flag
          move.w 14(a6),(a0)
          lea start_flag(PC),a0              install MIDI start flag
          move.w 22(a6),(a0)
          rts

* STOP PLAYBACK * * * * * * * * * * *
stop_play lea slave_flag(PC),a0              slave mode?
          tst.w (a0)
          beq stop_master                    if not, then stop mfp timer
          move.w #34,-(a7)                   else get kbdvbase
          trap #14
          addq.l #2,a7
          move.l d0,a0                       get pointer to midivec
          lea midivec(PC),a1                 get midivec
          move.l (a1),(a0)                   restore midivec
          lea clock_flag(PC),a0              reset clock flag
          clr.w (a0)
          rts

stop_master pea end_auto(PC)            enable software end-of-interrupt mode
          move.w #38,-(a7)
          trap #14
          addq.l #6,a7

          clr.w d0                      stop clock
          bsr mfptim
          lea clock_flag(PC),a0         clear timer flag
          clr.w (a0)

          pea one_pixel(PC)             set mouse trigger threshold
          move.w #2,-(a7)
          move.w #25,-(a7)
          trap #14
          addq.l #8,a7
          rts                           return to calling program

* ERASE ALL PATTERNS * * * * * * * *
erase_all move.l 12(a6),a0              get pointer to pattern array
          add.l #76032,a0               calculate pointer to end of array
          move.l #19007,d0              set longword counter
e_loop    clr.l -(a0)                   predecrement pointer and clear
          dbra d0,e_loop
          rts                           return to calling program

* SET ACCENT VELOCITY VALUE * * * *
set_accvel move.w 14(a6),d0             get ascii code of number key
          bsr new_accvel
          rts

* RETREIVE ACCENT SYMBOL * * * * * *
accent_sym move.l 12(a6),a0             get symbol pointer
          lea note_symbols(PC),a1       get pointer to note symbols
          move.w 2(a1),(a0)
          rts

* PLAYBACK * * * * * * * * * * * * *
playback  lea res_flag(PC),a0
          tst.w (a0)                    medium res?
          bne set_hires
          pea medres_mouse(PC)
          bra ikbd_send
set_hires pea hires_mouse(PC)           set mouse threshold
ikbd_send move.w #2,-(a7)
          move.w #25,-(a7)
          trap #14
          addq.l #8,a7

test_cflg lea clock_flag(PC),a0         clock on?
          tst.w (a0)
          beq check_tflag               if not, then set tempo/velocity
flag_loop lea pulse_flag(PC),a0         pulse flag set?
          tst.w (a0)
          beq flag_loop                 if not, then loop

check_tflag move.l 116(a6),a0           a0=tempo flag pointer
          tst.w (a0)                    flag set?
          beq check_vflag               if not, then check velocity flag

          move.l 100(a6),a0             a0=pointer to new tempo value
          lea tempo_val(PC),a1
          move.w (a0),(a1)              convey tempo value to interrupt routine
          clr.l d0
          move.w (a0),d0                d0=new tempo value
          mulu.w 158(a6),d0             calculate new tempo arrow position
          divu.w #24,d0                 (((409-((tmpo*btcl)\24))*4)\5)+385
          andi.l #$ffff,d0
          move.l #409,d6
          sub.l d0,d6
          bmi underscale
          mulu.w #4,d6
          divu.w #5,d6
          andi.w #$ff,d6
          addi.w #385,d6

          cmpi.w #611,d6                overscale?
          bls draw_tarrow
          move.w #611,d6
          bra draw_tarrow

underscale move.w #387,d6

draw_tarrow bsr replace_mode
          bsr move_tarrow               move tempo arrow
          move.l 116(a6),a0
          clr.w (a0)                    clear tempo flag
          
check_vflag move.l 132(a6),a0           a0=velocity flag pointer
          tst.w (a0)                    flag set?
          beq clear_ctr                 if not then skip
          move.l 108(a6),a0             calculate new velocity arrow position
          move.w (a0),d6                (vel*2)+25
          lsl.w #1,d6
          addi.w #25,d6
          cmpi.w #218,d6                overscale?
          bls under_scale
          move.w #218,d6                if so, then correct
under_scale bsr move_varrow             move velocity arrow
          move.l 132(a6),a0
          clr.w (a0)                    clear velocity flag

clear_ctr lea pulses(PC),a0             reset total pulse counter
          clr.l (a0)
          lea cl_per_pls(PC),a0         set clocks per pulse for pattern
          move.w 62(a6),(a0)
          lea met_count(PC),a0          set metronome clock counter
          move.w 166(a6),(a0)
          lea clock_flag(PC),a0         clock on?
          tst.w (a0)
          bne start

* * * * * INITIALIZATION * * * * * *
          move.w #1,(a0)                if not, then set clock flag...

          bsr replace_mode              set replace write-mode...

          lea endflg_ptr(PC),a0         save end_flag pointer...
          move.l 84(a6),(a0)

          lea pulse_flag(PC),a0         reset pulse_flag...
          clr.w (a0)

          lea met_clocks(PC),a0         get clocks/click...
          move.w 166(a6),(a0)

          lea clocks(PC),a0             and set MIDI clock counter...
          move.w 62(a6),(a0)

          lea slave_flag(PC),a0         slave mode?
          tst.w (a0)
          beq start_master              if not, then start mfp timer

          lea chase_flag(PC),a0         chase flag set?
          tst.w (a0)
          beq new_vector                if not, then install new midisys vector

          clr.l d0
          clr.l d1
          lea chase_ctr(PC),a0          else get expired clocks...
          move.w (a0),d0
          lea cl_per_pls(PC),a0         get clocks per pulse...
          move.w (a0),d1
          divu d1,d0                    calculate expired pulses...
          lea pulses(PC),a0
          move.w d0,2(a0)               update pulse counter...
          swap d0
          lea clocks(PC),a0             update clock counter...
          move.w d0,(a0)
          lea pulse_flag(PC),a0         set pulse flag...
          move.w #1,(a0)
          lea chase_flag(PC),a0         reset chase flag...
          clr.w (a0)
          bra start                     and start playback

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

new_vector move.w #34,-(a7)             get kbdvbase...
          trap #14
          addq.l #2,a7
          move.l d0,a0                  get midivec pointer...
          lea midivec(PC),a1
          move.l (a0),(a1)              save it...
          lea slave_vec(PC),a1          get slave vector...
          move.l a1,(a0)                install it...
          bra start                     and start playback

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

start_master move.l 100(a6),a1          set interrupt counter...
          lea count(PC),a0
          move.w (a1),(a0)
          lea tempo_val(PC),a0          convey tempo value to interrupt routine...
          move.l (a1),(a0)

          lea start_flag(PC),a0         send MIDI start?
          tst.w (a0)
          beq int_mode
          move.w #$fa,d0                if so, send start byte
          bsr midi_out

int_mode  pea start_auto(PC)            set auto-end-of-interrupt mode...
          move.w #38,-(a7)
          trap #14
          addq.l #6,a7

          move.w #4,d0                  and start timer
          bsr mfptim
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* START OF MAIN PLAYBACK LOOP; first, test for slave mode and if MIDI
* start has been received; if both conditions are met, return to calling
* program with end_flag set at 2 (restart from beginning); else, check
* total pulse counter to see if current pattern has ended
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
start     lea slave_flag(PC),a0         slave mode?
          tst.w (a0)
          beq check_met                 if not, then check metronome flag
          move.l 84(a6),a0              get end_flag
          cmpi.w #2,(a0)                MIDI start received?
          bne check_met                 if not, then continue
          lea clock_flag(PC),a0         else clear clock flag...
          clr.w (a0)
          bra exit_play                 and exit

check_met lea click_flag(PC),a0         metronome duration expired?
          tst.w (a0)
          beq check_tpc                 if not, then check expired-pulse counter
          clr.w (a0)
          move.l 172(a6),a0
          tst.w (a0)                    metronome flag set?
          beq check_tpc
          pea click_snd(PC)             and click
          move.w #32,-(a7)
          trap #14
          addq.l #6,a7

check_tpc lea pulses(PC),a0             check total pulse counter (end of pattern?)
          move.l (a0),d0
          cmp.l 20(a6),d0
          bhi exit_play

check_pulse lea pulse_flag(PC),a0       check pulse flag
          tst.w (a0)
          beq vq_mouse

          clr.w (a0)                    reset pulse flag
          lea off_flag(PC),a0           set note-off flag
          move.w #1,(a0)

          move.l #15,d7                 d7=drum loop counter
loop      move.l d7,d4
          lsl.w #1,d4
          move.l 36(a6),a5              a5=pointer to drum status array
          cmpi.w #2,0(a5,d4.w)          drum status=muted?
          beq next_drum                 if so, then skip to next drum

          move.l 12(a6),d6              calculate pointer to current pulse
          mulu.w #768,d6                (calculate offset to current pattern)
          move.l d7,d5
          mulu.w #48,d5                 (calculate offset to current drum part)
          add.l d5,d6
          lea pulses(PC),a0             (get offset to current pulse)
          add.l (a0),d6
          add.l 28(a6),d6               (get pointer to pattern array)
          move.l d6,a5                  a5=pointer to current pulse
          tst.b (a5)                    velocity=0?
          beq next_drum                 if so then skip to next drum

          move.l 44(a6),a4              a4=pointer to drum channel array
          move.w 0(a4,d4.w),d0          d0=drum channel
          add.w #144,d0                 d0=MIDI note-on status byte
          bsr midi_out                  output note-on status

          move.l 52(a6),a4              a4=pointer to drum pitch array
          move.w 0(a4,d4.w),d0          d0=MIDI drum pitch data
          bsr midi_out                  output pitch data

          move.l 108(a6),a0             a0=pointer to base velocity
          move.w (a0),d0                d0=base velocity
          add.b (a5),d0                 d0=MIDI velocity data
          bsr midi_out                  output velocity data

next_drum dbra d7,loop                  check next drum
          bra vq_mouse

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* MOUSE ROUTINES; check for left mouse button; mouse actions
* depend upon the screen position and playback mode
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

vq_mouse  move.l 68(a6),a0              reset mouse_flag
          clr.w (a0)

          lea varpb(PC),a5              a5=array table pointer
          move.l (a5),a4                a4=contrl pointer
          move.w #124,(a4)              contrl(0)=128 (vq_mouse opcode)
          clr.w 2(a4)                   contrl(1)=0
          clr.w 6(a4)                   contrl(3)=0
          bsr vdisys
          move.l 12(a5),a4              a4=ptsout pointer
          tst.w (a4)                    test mouse button status
          beq check_play                if no button, skip

          move.w (a4),d7                d7=button code
          move.l 16(a5),a4              a4=pstout pointer
          move.w (a4),d6                d6=x coord
          move.w 2(a4),d5               d5=y coord

          cmpi.w #4,6(a6)               seq playback mode?
          beq seq_song
          cmpi.w #5,6(a6)               song playback mode?
          beq seq_song
          cmpi.w #6,6(a6)               check mouse (seq/song) mode?               
          beq stop_pat

*         ///////////TEST RES///////////
          lea res_flag(PC),a0
          tst.w (a0)
          bne hires_1
*    TEST MEDIUM RES Y COORDS
          cmpi.w #41,d5                 if y>41 and y<=184 then:
          bls check_fcode
          cmpi.w #184,d5
          bhi stop_pat
          bra cont_1

hires_1   cmpi.w #74,d5                 if y>74 and y<=346 then:
          bls check_fcode
          cmpi.w #346,d5
          bhi stop_pat

cont_1    cmpi.w #172,d6                if x>172 and x<=193 then select status
          bls check_fcode
          cmpi.w #193,d6
          bhi enter_notes

* ENTER STATUS
          move.l 68(a6),a0              set mouse_flag
          move.w #1,(a0)
          bsr hide_mouse                hide mouse
          clr.l d4
*         ///////////TEST RES///////////
          lea res_flag(PC),a0
          tst.w (a0)
          bne hires_2
*    TEST MEDIUM RES Y COORDS
          move.w d5,d4                  status array index=((y-42)\9)*2
          subi.w #42,d4
          divu.w #9,d4
          lsl.w #1,d4
          bra cont_2

hires_2   move.w d5,d4                  status array index=((y-75)\17)*2
          subi.w #75,d4
          divu.w #17,d4
          lsl.w #1,d4

cont_2    move.l 36(a6),a0              a0=status array pointer
          move.w d7,0(a0,d4.w)          save status (mouse button code)

          lea stat_symbols(PC),a0       a0=symbol array pointer
          move.w d7,d0                  d0=array offset
          subq.w #1,d0
          lsl.w #1,d0
          move.w #180,d1                d1=x coord of symbol
          bsr v_gtext

          pea waste_time(PC)            delay...
          move.w #38,-(a7)              superexec
          trap #14
          addq.l #6,a7
          bra check_fcode

* ENTER NOTES
enter_notes cmpi.w #197,d6              if x>197 and x<=628 then enter notes
          bls check_fcode
          cmpi.w #628,d6
          bhi check_fcode

          move.l 68(a6),a0              set mouse_flag
          move.w #1,(a0)
          bsr hide_mouse

          clr.l d4
          move.w d5,d4
*         ///////////TEST RES///////////
          lea res_flag(PC),a0
          tst.w (a0)
          bne hires_3
*    TEST MEDIUM RES Y COORDS
          subi.w #42,d4                 drum=(y-42)\9
          divu.w #9,d4                  d4=drum
          bra cont_3

hires_3   subi.w #75,d4                 drum=(y-75)\17
          divu.w #17,d4                 d4=drum

cont_3    andi.l #$ffff,d4

          clr.l d3
          move.w d6,d3
          subi.w #198,d3                pulse=(x-198)\9
          divu.w #9,d3                  d3=pulse
          andi.l #$ffff,d3

          move.l 12(a6),d2              d2=pat_number
          mulu.w #768,d2                pat_ptr%=768*pat_number+48*drum+pulse%+pat_array%
          mulu.w #48,d4
          add.l d4,d2
          add.l d3,d2
          add.l 28(a6),d2
          move.l d2,a0                  a0=pat_ptr%
          lea velocity(PC),a1           a1=velocity array pointer
          move.w d7,d0
          subq.w #1,d0                  d0=array offset
          move.b 0(a1,d0.w),(a0)        enter velocity value into pattern array

          clr.l d1
          move.w d6,d1                  x coord of symbol=198+((x-198\9)*9
          subi.w #198,d1
          divu.w #9,d1
          andi.l #$ffff,d1
          mulu.w #9,d1
          addi.w #198,d1                d1=x coord of symbol
          lea note_symbols(PC),a0       a0=symbol array pointer
          move.w d7,d0
          subq.w #1,d0
          lsl.w #1,d0                   d0=array offset
          bsr v_gtext

          pea waste_time(PC)            delay...
          move.w #38,-(a7)              superexec
          trap #14
          addq.l #6,a7
          bra check_fcode

* SET TEMPO WITH MOUSE
stop_pat  cmpi.w #2,6(a6)               if pattern playback mode and...
          bne set_tempo
          cmpi.w #311,d6                if x>311 and x<=366 and...
          bls check_fcode
          cmpi.w #366,d6
          bhi set_tempo
*         ///////////TEST RES///////////
          lea res_flag(PC),a0
          tst.w (a0)
          bne hires_4
*    TEST MEDIUM RES Y COORDS
          cmpi.w #186,d5                if y>186 and x<=194 then...
          bls check_fcode
          cmpi.w #194,d5
          bhi check_fcode
          bra cont_4

hires_4   cmpi.w #359,d5                if y>359 and x<=384 then...
          bls check_fcode
          cmpi.w #384,d5
          bhi check_fcode

cont_4    bsr notes_off
          bsr clean_exit
          bra exit_play                 and return to calling program

set_tempo bsr vel_scale
          bra check_fcode

* PLAYBACK - SEQUENCE AND SONG MODE
seq_song  bsr vel_scale

          cmpi.w #1,d7                  if left button and...
          bne check_play
          cmpi.w #14,d6                 if x>14 and x<=128 and...
          bls check_play
          cmpi.w #128,d6
          bhi song_done
*         ///////////TEST RES///////////
          lea res_flag(PC),a0
          tst.w (a0)
          bne hires_5
*    TEST MEDIUM RES Y COORDS
          cmpi.w #13,d5                 if y>13 and y<=172 then...
          bls check_play
          cmpi.w #172,d5
          bhi check_play
          clr.l d0
          move.w d5,d0                  seq_part=(y-14)\10+1
          subi.w #14,d0
          divu.w #10,d0
          addq.w #1,d0                  d0=seq_part
          bra cont_5

hires_5   cmpi.w #25,d5                 if y>25 and y<=343 then...
          bls check_play
          cmpi.w #343,d5
          bhi check_play
          clr.l d0
          move.w d5,d0                  seq_part=(y-26)\20+1
          subi.w #26,d0
          divu.w #20,d0
          addq.w #1,d0                  d0=seq_part

cont_5    move.l 76(a6),a0
          cmp.w (a0),d0                 old seq_part=new seq_part?
          bne old_part
          clr.w (a0)                    if so, then clear old seq_part
old_part  move.w (a0),d2                d2=previous seq_part
          move.w d0,(a0)                pass new seq_part back to calling program

*         ///////////TEST RES///////////
          lea res_flag(PC),a0
          tst.w (a0)
          bne hires_11
*    TEST MEDIUM RES Y COORDS
          subq.w #1,d0                  calculate y coord
          mulu.w #10,d0                 d0=(seq_part-1)*10+21
          addi.w #21,d0
          bra cont_11

hires_11  subq.w #1,d0                  calculate y coord
          mulu.w #20,d0                 d0=(seq_part-1)*20+40
          addi.w #40,d0

cont_11   move.w #42,d1                 d1=marker code ('*')
          bsr do_marker

          tst d2                        erase old marker?
          beq check_play
          move.w d2,d0
          bsr erase_oldmark
          bra check_play

song_done cmpi.w #276,d6                if x>276 and x<=328 and...
          bls check_play
          cmpi.w #328,d6
          bhi check_play
*         ///////////TEST RES///////////
          lea res_flag(PC),a0
          tst.w (a0)
          bne hires_7
*    TEST MEDIUM RES Y COORDS
          cmpi.w #178,d5                if y>178 and y<=193 then...
          bls check_play
          cmpi.w #193,d5
          bhi check_play
          bra cont_7

hires_7   cmpi.w #359,d5                if y>359 and y<=384 then...
          bls check_play
          cmpi.w #384,d5
          bhi check_play

cont_7    bsr notes_off
          bsr clean_exit
          bra exit_play                 and return to calling program

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* CHECK MODE; if editing pattern with mouse, waste time to make
* mouse handling easier
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
check_fcode cmpi.w #1,6(a6)             check_mouse/pattern mode?
          beq delay_loop
          cmpi.w #6,6(a6)               check_mouse/seq-song mode?
          bne check_play

delay_loop pea waste_time(PC)           if so, then delay...
          move.w #38,-(a7)              superexec
          trap #14
          addq.l #6,a7
          move.l 68(a6),a0              and check mouse flag
          tst.w (a0)
          bne vq_mouse                  if set, then check mouse again
          rts                           else return to calling program

waste_time move.l $4ba,d1               waste 35ms
          addi.l #7,d1
counter   cmp.l $4ba,d1
          bhi counter
          rts

check_play cmpi.w #2,6(a6)              pattern playback mode?
          beq delay                     if so, then count midi clocks
          cmpi.w #4,6(a6)               sequence playback mode?
          beq delay
          cmpi.w #5,6(a6)               song playback mode?
          beq delay
          rts                           else return to calling program

* * * * * PATTERN PULSE DELAY * * * * * * *
delay     lea off_flag(PC),a0           note-off flag set?
          tst.w (a0)
          beq kbd_stat                  if not, then skip note-off
          bsr notes_off

kbd_stat  move.w #2,-(a7)               check keyboard status
          move.w #1,-(a7)               bconstat routine
          trap #13
          addq.l #4,a7
          tst d0                        key pressed?
          beq inc_tpc                   if so, get code

          move.w #2,-(a7)               bconin
          move.w #2,-(a7)
          trap #13
          addq.l #4,a7

          cmpi.w #13,d0                 return/enter key?
          bne met_check
          bsr clean_exit                
          bra exit_play                 if so, then exit

met_check cmpi.w #91,d0                 left bracket ([) key?
          bne nmbr_check
          move.l 172(a6),a0             if so, then get metronome flag...
          addq.l #1,a0
          bchg #0,(a0)                  flip it...
          bra inc_tpc                   and continue

nmbr_check cmpi.w #2,6(a6)              pattern playback mode?
          bne pause_check
          move.l d0,d1                  get key scan code
          swap d1
          cmpi.w #1,d1                  QWERTY number key?
          bls pause_check
          cmpi.w #10,d1
          bhi pause_check

          bsr new_accvel                if so, change accent velocity
          bra inc_tpc                   and continue

pause_check lea slave_flag(PC),a0       master mode?
          tst.w (a0)
          bne arrow_check               if not, then check arrow keys
          cmpi.w #32,d0                 space bar?
          bne arrow_check

          clr.w d0                      stop internal clock
          bsr mfptim
          pea end_auto(PC)              enable software end-of-interrupt mode
          move.w #38,-(a7)
          trap #14
          addq.l #6,a7

          lea start_flag(PC),a0         MIDI start mode?
          tst.w (a0)
          beq make_alert                if not, then no MIDI stop
          move.w #$fc,d0                and send MIDI stop
          bsr midi_out

make_alert movem.l d0-d7/a0-a6,-(a7)    save registers
          lea gem_array(PC),a1          get pointer to GEM control arrays
          move.l (a1),a0

          move.l 8(a0),a1               get gem_intin
          move.w #1,(a1)                default button #1

          move.l 16(a0),a1              get gem_addrin
          lea pause_alert(PC),a2
          move.l a2,(a1)                alert string

          move.l (a0),a1                get gem_control
          move.w #52,(a1)+              form_alert opcode
          move.w #1,(a1)+
          move.w #1,(a1)+
          move.w #1,(a1)+
          move.w #0,(a1)

          move.l a0,d1                  aes call
          move.l #$c8,d0
          trap #2

          bsr replace_mode

          movem.l (a7)+,d0-d7/a0-a6     restore registers
          lea start_flag(PC),a0         MIDI start mode?
          tst.w (a0)
          beq c_restart                 if not, then skip it
          move.w #$fb,d0                else send MIDI continue...
          bsr midi_out
c_restart pea start_auto(PC)            set auto-end-of-interrupt mode...
          move.w #38,-(a7)
          trap #14
          addq.l #6,a7

          move.w #4,d0                  restart clock...
          bsr mfptim
          bra inc_tpc                   and continue

arrow_check cmpi.w #2,6(a6)             pattern playback mode?
          beq inc_tpc                   if so, then skip arrow check
          swap d0                       get scan code
          cmpi.w #$48,d0                up arrow?
          beq load_n_leave

          cmpi.w #$50,d0                down arrow?
          beq load_n_leave

inc_tpc   lea off_flag(PC),a0           note-off flag set?
          tst.w (a0)
          beq start
          clr.w (a0)
          lea pulses(PC),a0             increment total pulse counter
          addq.l #1,(a0)
          bra start

*         ///////////TEST RES///////////
vel_scale lea res_flag(PC),a0
          tst.w (a0)
          bne hires_8
*    TEST MEDIUM RES Y COORDS
          cmpi.w #178,d5                if y>178 and y<=194 and...
          bls quit_tempo
          cmpi.w #194,d5
          bhi quit_tempo
          bra cont_8

hires_8   cmpi.w #355,d5                if y>355 and y<=384 and...
          bls quit_tempo
          cmpi.w #384,d5
          bhi quit_tempo

cont_8    cmpi.w #3,6(a6)               (if f_code<4 then skip vel_scale)
          bls tempo_scale
*
          cmpi.w #24,d6                 if x>24 and x<=218 and...
          bls quit_tempo
          cmpi.w #218,d6
          bhi tempo_scale
          cmpi.w #1,d7                  if left button then set velocity
          bne quit_tempo

          move.w d6,d1                  base_vel=(x-25)\2
          subi.w #25,d1
          lsr.w #1,d1
          move.l 108(a6),a0             save new base velocity
          move.w d1,(a0)

move_varrow bsr hide_mouse              print velocity arrow
          move.l 124(a6),a4             get old velocity arrow position
          move.w (a4),d1
          move.w #32,d0                 print space
          bsr print

          clr.l d1
          move.w d6,d1                  calculate new position
          subq.w #3,d1
          move.l 124(a6),a4             save new position
          move.w d1,(a4)
          move.w #2,d0                  print arrow
          bsr print
          bsr show_mouse
          bra quit_tempo
*
tempo_scale lea slave_flag(PC),a0       slave mode?
          tst.w (a0)
          bne quit_tempo                if so, then skip tempo change
          cmpi.w #386,d6                if x>386 and x<=612 and...
          bls quit_tempo
          cmpi.w #612,d6
          bhi quit_tempo
          cmpi.w #1,d7                  if left button then set tempo
          bne quit_tempo

          move.l 68(a6),a0              set mouse_flag
          move.w #1,(a0)
          clr.l d1                      calculate new cycle duration
          move.w d6,d1                  ((409-(((x-387)*5)\4))*24)\btcl
          subi.w #387,d1
          mulu.w #5,d1
          divu.w #4,d1
          move.l #409,d0
          sub.w d1,d0
* * * * * *
          mulu.w #24,d0
          divu.w 158(a6),d0
* * * * * *
          move.l 100(a6),a0
          lea tempo_val(PC),a1
          move.w d0,(a0)                save new cycle duration
          move.w d0,(a1)

move_tarrow bsr hide_mouse              print tempo arrow
          move.l 92(a6),a4              get old arrow position
          move.w (a4),d1
          move.w #32,d0                 print space
          bsr print

          clr.l d1
          move.w d6,d1                  calculate new position
          subq.w #3,d1
          move.l 92(a6),a4              save new position
          move.w d1,(a4)
          move.w #2,d0                  print arrow
          bsr print
          bsr show_mouse
quit_tempo rts

load_n_leave move.l 148(a6),a0          load key code
          move.w d0,(a0)
          bra exit_play                 exit

clean_exit move.l 84(a6),a0             set end_flag...
          move.w #1,(a0)
          lea slave_flag(PC),a0         slave mode?
          tst.w (a0)
          beq send_stop                 if not, then check start flag
          lea toggle_start(PC),a0       else clear MIDI start toggle...
          clr.w (a0)
          rts                           and return

send_stop lea start_flag(PC),a0         send MIDI stop?
          tst.w (a0)
          beq no_stop                   if not, then return
          move.w #$fc,d0                else send it
          bsr midi_out
no_stop   rts

exit_play rts

notes_off move.l #15,d7                 d7=drum loop_off counter
loop_off  move.l d7,d4
          lsl.w #1,d4
          move.l 36(a6),a5              a5=pointer to drum status array
          cmpi.w #2,0(a5,d4.w)          drum status=muted?
          beq next_drum_off             if so, then skip to next drum

          move.l 12(a6),d6              calculate pointer to current pulse
          mulu.w #768,d6                (calculate offset to current pattern)
          move.l d7,d5
          mulu.w #48,d5                 (calculate offset to current drum part)
          add.l d5,d6
          lea pulses(PC),a0             (get offset to current pulse)
          add.l (a0),d6
          add.l 28(a6),d6               (get pointer to pattern array)
          move.l d6,a5                  a5=pointer to current pulse
          tst.b (a5)                    velocity=0?
          beq next_drum_off             if so then skip to next drum

          move.l 44(a6),a4              a4=pointer to drum channel array
          move.w 0(a4,d4.w),d0          d0=drum channel
          add.w #144,d0                 d0=MIDI note-on status byte
          bsr midi_out                  output note-on status

          move.l 52(a6),a4              a4=pointer to drum pitch array
          move.w 0(a4,d4.w),d0          d0=MIDI drum pitch data
          bsr midi_out                  output pitch data

          clr.w d0                      d0=velocity 0 for note-off
          bsr midi_out                  output velocity data

next_drum_off dbra d7,loop_off          check next drum
          rts

midi_out  move.w d0,-(a7)               get data to ouput
          move.w #3,-(a7)               output device=MIDI interface
          move.w #3,-(a7)               execute bconout routine
          trap #13
          addq.l #6,a7
          rts

hide_mouse lea varpb(PC),a5             a5=vdi array table pointer
           move.l (a5),a4               a4=contrl pointer
           move.w #123,(a4)             contrl(0)=123 (hide mouse)
           clr.w 2(a4)                  contrl(1)=0
           clr.w 6(a4)                  contrl(3)=0
           bsr vdisys
           rts

replace_mode lea varpb(PC),a5           a5=vdi array table pointer 
          move.l (a5),a4                a4=contrl pointer
          move.w #32,(a4)               contrl(0)=8 (writing mode opcode)
          clr.w 2(a4)                   contrl(1)=0
          move.w #1,6(a4)               contrl(3)=1
          move.l 4(a5),a4               a4=intin pointer
          move.w #1,(a4)                intin(0)=1
          bsr vdisys
          rts

xor_mode lea varpb(PC),a5             a5=vdi array table pointer 
          move.l (a5),a4                a4=contrl pointer
          move.w #32,(a4)               contrl(0)=8 (writing mode opcode)
          clr.w 2(a4)                   contrl(1)=0
          move.w #1,6(a4)               contrl(3)=1
          move.l 4(a5),a4               a4=intin pointer
          move.w #3,(a4)                intin(0)=3 (xor mode)
          bsr vdisys
          rts

v_gtext   move.l (a5),a4                a4=contrl pointer
          move.w #8,(a4)                contrl(0)=8 (v_gtext opcode)
          move.w #1,2(a4)               contrl(1)=1
          move.w #1,6(a4)               contrl(3)=2
          move.l 4(a5),a4               a4=intin pointer
          move.w 0(a0,d0.w),(a4)        intin(0)=symbol code
          clr.w 2(a4)
          move.l 8(a5),a4               a4=ptsin pointer
          move.w d1,(a4)                ptsin(0)=x coord
*         ///////////TEST RES///////////
          lea res_flag(PC),a0
          tst.w (a0)
          bne hires_9
*    TEST MEDIUM RES Y COORDS
          move.w d5,d0                  calculate y coord
          subi.w #23,d0                 ((y-23?)\9)*9+30
          divu.w #9,d0
          mulu.w #9,d0
          addi.w #30,d0
          bra cont_9

hires_9   move.w d5,d0                  calculate y coord
          subi.w #41,d0                 ((y-41)\17)*17+54
          divu.w #17,d0
          mulu.w #17,d0
          addi.w #54,d0

cont_9    move.w d0,2(a4)               ptsin(1)=y coord
          bsr vdisys
          bsr show_mouse
          rts

show_mouse move.l (a5),a4               a4=contrl pointer
          move.w #122,(a4)              contrl(0)=122 (show mouse)
          clr.w 2(a4)                   contrl(1)=0
          move.w #1,6(a4)               contrl(3)=1
          move.l 4(a5),a4               a4=intin pointer
          clr.w (a4)                    intin(0)=0
          bsr vdisys
          rts

print     move.l (a5),a4                a4=contrl pointer
          move.w #8,(a4)                contrl(0)=8 (v_gtext opcode)
          move.w #1,2(a4)               contrl(1)=1
          move.w #1,6(a4)               contrl(3)=2
          move.l 4(a5),a4               a4=intin pointer
          move.w d0,(a4)                intin(0)=symbol code
          clr.w 2(a4)                   intin(1)=0
          move.l 8(a5),a4               a4=ptsin pointer
          move.w d1,(a4)                ptsin(0)=x coord
*         ///////////TEST RES///////////
          lea res_flag(PC),a0
          tst.w (a0)
          bne hires_10
*    TEST MEDIUM RES Y COORDS
          move.w #192,2(a4)             ptsin(1)=y coord
          bra cont_10

hires_10  move.w #377,2(a4)             ptsin(1)=y coord

cont_10   bsr vdisys
          rts

do_marker move.l (a5),a4                a4=contrl pointer
          move.w #8,(a4)                contrl(0)=8 (v_gtext opcode)
          move.w #1,2(a4)               contrl(1)=1
          move.w #1,6(a4)               contrl(3)=2
          move.l 4(a5),a4               a4=intin pointer
          move.w d1,(a4)                intin(0)=symbol code ('*' or ' ')
          clr.w 2(a4)
          move.l 8(a5),a4               a4=ptsin pointer
          move.w #150,(a4)              ptsin(0)=x coord
          move.w d0,2(a4)               ptsin(1)=y coord
          bsr vdisys
          rts

erase_oldmark lea res_flag(PC),a0      ///////////TEST RES///////////
          tst.w (a0)
          bne hires_12
*    TEST MEDIUM RES Y COORDS
          subq.w #1,d0                  calculate y coord
          mulu.w #10,d0                 d0=(seq_part-1)*10+21
          addi.w #21,d0
          bra cont_12

hires_12  subq.w #1,d0                  calculate y coord
          mulu.w #20,d0                 d0=(seq_part-1)*20+40
          addi.w #40,d0

cont_12   cmp.w 142(a6),d0              y coord=r%?
          beq draw_arrow
          move.w #32,d1                 d1=marker code (' ')
          bsr do_marker
          rts

draw_arrow move.w #3,d1                 d1=marker code('')
          bsr do_marker
          rts

vdisys    move.l a5,d1
          move.l #$73,d0
          trap #2
          rts

new_accvel lea note_symbols(PC),a0      then change accent velocity
          move.w d0,2(a0)               new note symbol for right mouse button
          cmpi.w #$39,2(a0)             symbol="9"?
          bne new_veloc
          move.w #$3e,2(a0)             if so, then symbol=">"
new_veloc andi.l #$ff,d0
          subi.w #49,d0                 calculate new velocity value...
          mulu.w #3,d0
          addq.w #4,d0
          lea velocity(PC),a0           set new velocity value...
          move.b d0,1(a0)
          rts

start_auto move.w sr,-(a7)              disable interrupts
          or.w #$700,sr 
          bclr.b #3,$fffa17             automatic end-of-interrupt mode
          move.w (a7)+,sr
          rts

end_auto  move.w sr,-(a7)               disable interrupts
          or.w #$700,sr
          bset.b #3,$fffa17             stop auto end-of_int mode
          move.w (a7)+,sr
          rts

mfptim    pea timer(PC)                 interrupt routine vector
          move.w #5,-(a7)               count down from 5
          move.w d0,-(a7)               start/stop timer
          move.w #0,-(a7)               select timer a
          move.w #31,-(a7)              xbtimer routine
          trap #14
          add.l #12,a7
          rts

* * * * * MASTER CLOCK INTERRUPT ROUTINE * * * * * * *
timer     movem.l d0/a0-a2,-(a7)        save registers
          lea count(PC),a0
          addq.w #1,(a0)                increment interrupt counter

          lea tempo_val(PC),a1          get tempo variable pointer
          move.w (a1),d0
          cmp.w (a0),d0                 interrupt counter=interrupts per MIDI clock?
          bhi exit_master
          clr.w (a0)                    if so, then reset interrupt counter...

          lea $fffffc04,a1              MIDI ACIA control
test_midi move.b (a1),d0                get MIDI status
          btst #1,d0
          beq test_midi
          move.b #248,2(a1)             output MIDI clock

          lea met_count(PC),a0          increment metronome-clock counter
          addq.w #1,(a0)
          lea met_clocks(PC),a1         get clocks/click
          move.w (a1),d0
          cmp.w (a0),d0                 metronome click?
          bhi inc_mclock
          clr.w (a0)                    if so, then reset met-clock counter
          lea click_flag(PC),a0
          move.w #1,(a0)                and set click flag

inc_mclock lea clocks(PC),a0            increment MIDI clock counter
          addq.w #1,(a0)
          lea cl_per_pls(PC),a1         get clocks per pulse
          move.w (a1),d0
          cmp.w (a0),d0                 pulse expired?
          bhi exit_master
          clr.w (a0)                    if so, reset clock counter...
          lea pulse_flag(PC),a0         and set pulse_flag
          move.w #1,(a0)
exit_master movem.l (a7)+,d0/a0-a2       restore registers
          rte

* * * * SLAVE CLOCK MIDI VECTOR * * * * * *
slave_vec movem.l d0/a0-a1,-(a7)        save registers

          lea start_flag(PC),a0         wait for MIDI start?
          tst.w (a0)
          beq no_chase                  if not, then continue

          lea toggle_start(PC),a0       MIDI start already received?
          tst.w (a0)
          bne stop_check                if so, then check for MIDI stop

          cmpi.b #$fa,d0                MIDI start?
          beq start_toggle              if so, then restart
          cmpi.b #$fb,d0                MIDI continue?
          beq set_toggle                if so, then set toggle
          bra exit_slave                else exit

start_toggle lea toggle_start(PC),a0    set MIDI start toggle
          move.w #1,(a0)
          lea endflg_ptr(PC),a0         set restart_flag (end_flag=2)
          move.l (a0),a1
          move.w #2,(a1)
          lea chase_flag(PC),a0         set chase_flag
          move.w #1,(a0)
          lea chase_ctr(PC),a0          clear chase counter
          clr.w (a0)
          bra exit_slave

set_toggle lea toggle_start(PC),a0      set MIDI start toggle
          move.w #1,(a0)
          bra exit_slave

stop_check cmpi.b #$fc,d0               MIDI stop?
          bne clock_check               if not, then check for MIDI clock
          lea toggle_start(PC),a0       else clear MIDI start toggle
          clr.w (a0)
          bra exit_slave

clock_check lea chase_flag(PC),a0       chase_flag set?
          tst.w (a0)
          beq no_chase                  if not, then skip chase
          cmpi.b #248,d0                else check for MIDI clock
          bne exit_slave
          lea chase_ctr(PC),a0          if MIDI clock, then increment chase counter
          addq.w #1,(a0)
          bra exit_slave

no_chase  cmpi.b #248,d0                MIDI clock?
          bne exit_slave                if not, then skip it
          lea clocks(PC),a0             else increment clock counter
          addq.w #1,(a0)
          lea cl_per_pls(PC),a1         has pulse expired?
          move.w (a1),d0
          cmp.w (a0),d0
          bhi exit_slave                if not, then exit
          clr.w (a0)                    else reset clock counter...
          lea pulse_flag(PC),a0         and set pulse flag
          move.w #1,(a0)
exit_slave movem.l (a7)+,d0/a0-a1
          rts

stat_symbols dc.b $00,$08,$00,$4d,$00,$53
note_symbols dc.b $00,$0b,$00,$3e,$00,$20
velocity     dc.b $01,$1c,$00,$00
hires_mouse  dc.b $0b,$04,$04
medres_mouse dc.b $0b,$04,$02
one_pixel    dc.b $0b,$01,$01
pause_alert  dc.b '[1][ Pause ][ Continue ]',0,0
click_snd    dc.b $00,$5a,$01,$00,$07,$3e,$08,$10,$0b,$00,$0c,$09,$0d,$00,$ff,$00
varpb        ds.l 5
gem_array    ds.l 1
save_vec24   ds.l 1
midivec      ds.l 1
tempo_val    ds.l 1
pulses       ds.l 1
endflg_ptr   ds.l 1
res_flag     ds.w 1
clock_flag   ds.w 1
slave_flag   ds.w 1
start_flag   ds.w 1
chase_flag   ds.w 1
chase_ctr    ds.w 1
toggle_start ds.w 1
count        ds.w 1
clocks       ds.w 1
cl_per_pls   ds.w 1
pulse_flag   ds.w 1
off_flag     ds.w 1
met_clocks   ds.w 1
met_count    ds.w 1
click_flag   ds.w 1

          end
