* PLAY DIGITIZED SOUND FILE WHEN TERMINATING PROGRAM

          move.l 4(a7),a0          calculate program size
          move.l #$100,d6
          add.l 12(a0),d6
          add.l 20(a0),d6
          add.l 28(a0),d6

          clr.l -(a7)              enter supervisor mode
          move.w #$20,-(a7)
          trap #1
          addq.l #6,a7
          move.l d0,d4             save ssp

          pea dta(PC)              set DTA
          move.w #$1A,-(a7)
          trap #1
          addq.l #6,a7

          move.w #0,-(a7)          look for RESOUND.INF
          pea inf_file(PC)
          move.w #$4E,-(a7)
          trap #1
          add.l #8,a7
          lea no_inf(PC),a1
          tst d0
          bne problem

          lea dta(PC),a6
          move.l 26(a6),d7         get RESOUND.INF file length
          sub.l #1,d7
          andi.l #$F,d7

          clr.w -(a7)              open RESOUND.INF
          pea inf_file(PC)
          move.w #$3D,-(a7)
          trap #1
          add.l #8,a7
          lea open(PC),a1
          tst.l d0
          bmi problem
          move.w d0,d5             save file handle

          pea freq_ind(PC)         pointer to buffer
          move.l d7,-(a7)          number of bytes to read
          move.w d5,-(a7)          file handle
          move.w #$3F,-(a7)        read RESOUND.INF
          trap #1
          add.l #12,a7
          lea read(PC),a1
          tst.l d0
          bmi problem

          move.w d5,-(a7)          close RESOUND.INF
          move.w #$3E,-(a7)
          trap #1
          addq.l #4,a7

          lea freq_ind(PC),a1      convert frequency index
          move.b (a1),d0
          sub.b #48,d0
          lsl.b #1,d0
          move.b d0,(a1)

          move.w #0,-(a7)          get sample file length
          pea snd_file(PC)
          move.w #$4E,-(a7)
          trap #1
          add.l #8,a7
          lea no_dig(PC),a1
          tst d0
          bne problem

          lea dta(PC),a6           save sample file length
          move.l 26(a6),d7
          add.l d7,d6              add file length to program size

          lea snd_buf,a0
          lea pointers(PC),a6      save buffer pointer
          move.l a0,(a6)+
          move.l a0,a5
          add.l d7,a0              calculate buffer end pointer
          move.l a0,(a6)           save buffer end pointer

          clr.w -(a7)              open sample file
          pea snd_file(PC)
          move.w #$3D,-(a7)
          trap #1
          add.l #8,a7
          lea open(PC),a1
          tst.l d0
          bmi problem
          move.w d0,d5             save file handle

          move.l a5,-(a7)          pointer to sample buffer
          move.l d7,-(a7)          size of sample buffer
          move.w d5,-(a7)          file handle
          move.w #$3F,-(a7)        read sample file
          trap #1
          add.l #12,a7
          lea read(PC),a1
          tst.l d0
          bmi problem

          move.w d5,-(a7)          close sample file
          move.w #$3E,-(a7)
          trap #1
          addq.l #4,a7

          lea start(PC),a0         replace etv_term vector
          move.l a0,$408

          pea done(PC)             print message
          move.w #$9,-(a7)
          trap #1
          addq.l #6,a7

          move.l d4,-(a7)          return to user mode
          move.w #$20,-(a7)
          trap #1
          addq.l #6,a7

          clr.w -(a7)              keep process
          move.l d6,-(a7)
          move.w #$31,-(a7)
          trap #1

problem   move.l a1,-(a7)          print error message
          move.w #$9,-(a7)
          trap #1
          addq.l #6,a7

          pea abort(PC)
          move.w #$9,-(a7)
          trap #1
          addq.l #6,a7

          move.w #1,-(a7)          wait for keypress
          trap #1
          addq.l #2,a7

          move.l d4,-(a7)          return to user mode
          move.w #$20,-(a7)
          trap #1
          addq.l #6,a7

          clr.w -(a7)              terminate
          trap #1

*   GET PARAMETERS/ENTER SUPERVISOR MODE TO ACCESS I/O REGISTERS

start     movem.l d0-d7/a0-a6,-(a7) save registers

          move.l #$FF8800,a0       set up sound chip registers

          move.b #0,(a0)
          move.b #0,2(a0)

          move.b #1,(a0)
          move.b #0,2(a0)

          move.b #2,(a0)
          move.b #0,2(a0)

          move.b #3,(a0)
          move.b #0,2(a0)

          move.b #4,(a0)
          move.b #0,2(a0)

          move.b #5,(a0)
          move.b #0,2(a0)

          move.b #7,(a0)
          move.b #$ff,2(a0)

          move.b #8,(a0)
          move.b #0,2(a0)

          move.b #9,(a0)
          move.b #0,2(a0)

          move.b #10,(a0)
          move.b #0,2(a0)

          lea int_vector(PC),a6    get internal interrupt vector
          lea snd_out(PC),a4       get pointer to sound table

          lea kbd_off(PC),a0       disable keyboard
          bsr ikbdws

          move.w #5,-(a7)          disable timer c interrupt
          move.w #26,-(a7)
          trap #14
          addq.l #4,a7          

          lea pointers(PC),a1
          move.l (a1)+,a3          get pointer to sound buffer
          move.l (a1),d6           get end-of-buffer pointer

          lea frequency(PC),a0     get timer parameters
          lea freq_ind(PC),a1
          clr.w d0
          move.b (a1),d0
          move.w 0(a0,d0.w),d5
          clr.w d4                 
          move.w d5,d4             extract timer parameters from d5
          andi.w #$FF,d5           get timer control byte
          lsr.w #8,d4              get timer data data
          bsr xbtimer              start mfp timer

          bclr.b #3,$FFFA17        set automatic end-of-interrupt mode
          move.w sr,-(a7)          save status register
          move.w #$2400,sr         permit level 6 interrupts only

* MAIN PLAYBACK LOOP - TEST FOR END OF SAMPLE BUFFER

test_end  cmp.l a3,d6              end of buffer?
          bhi test_end

* STOP INTERRUPT GENERATION

          move.w #$2700,sr         disable all interrupts
          bset.b #3,$FFFA17        set software end-of-interrupt mode
          clr.w d5                 stop mfp timer
          bsr xbtimer

          move.w #5,-(a7)          re-enable timer c interrupt
          move.w #27,-(a7)
          trap #14
          addq.l #4,a7          

          lea kbd_on(PC),a0        re-enable keyboard
          bsr ikbdws

clear     btst.b #0,$FFFC00        characters in keyboard buffer?
          beq re_status
          move.b $FFFC02,d7        if go, clear buffer
          bra clear

re_status move.w (a7)+,sr          retrieve status register
          movem.l (a7)+,d0-d7/a0-a6 restore registers
          rts

* TURN KEYBOARD OFF/ON

ikbdws    move.l a0,-(a7)          pointer to string
          move.w #0,-(a7)          1 parameter in string
          move.w #25,-(a7)         write string to keyboard processor
          trap #14
          addq.l #8,a7
          rts

* START/STOP MFP TIMER A

xbtimer   move.l a6,-(a7)          interrupt vector
          move.w d4,-(a7)          timer a data
          move.w d5,-(a7)          timer a control
          move.w #0,-(a7)          timer a select
          move.w #31,-(a7)         start mfp timer
          trap #14
          add.l #12,a7
          rts

* INTERRUPT ROUTINE

int_vector clr.w d7                clear table lookup index
          move.b (a3)+,d7          get byte from sample buffer
          add.b #$80,d7            convert to signed value
          lsl.w #3,d7              double longword offset
          move.l 0(a4,d7.w),d0     load sound to psg registers
          move.l #$FF8800,a2       sound chip pointer
          dc.w $01CA               movep.l d0,0(a2)/move data to
          dc.w $00                      sound chip volume registers
          move.w 4(a4,d7.w),d0     movep.w d0,0(a2)
          dc.w $018A
          dc.w $00
          rte

save_ssp  ds.l 1
pointers  ds.l 2
freq_ind  ds.b 2
snd_file  ds.b 16
dta       ds.b 44
kbd_off   dc.b $13,0
kbd_on    dc.b $11,0
inf_file  dc.b 'RESOUND.INF',0
no_inf    dc.b 13,10,'ERROR: RESOUND.INF FILE NOT FOUND ',0
no_dig    dc.b 13,10,'ERROR: SOUND FILE NOT FOUND ',0
open      dc.b 13,10,'ERROR: CANNOT OPEN FILE ',0
read      dc.b 13,10,'ERROR: CANNOT READ FILE ',0
abort     dc.b '(HIT ANY KEY TO ABORT)',0
done      dc.b 13,10,'Resound installed',0
frequency dc.w $0506,$0505,$0405,$2901,$1f01,$0802

*  INTERNAL SOUND LOOKUP TABLE

snd_out   dc.w    $80c,$90b,$a09,0,$80c,$90b,$a09,0
          dc.w    $80d,$908,$a08,0,$80b,$90b,$a0b,0
          dc.w    $80d,$909,$a05,0,$80c,$90b,$a08,0
          dc.w    $80d,$909,$a02,0,$80d,$908,$a06,0
          dc.w    $80c,$90b,$a07,0,$80d,$907,$a07,0
          dc.w    $80c,$90b,$a06,0,$80c,$90a,$a09,0
          dc.w    $80b,$90b,$a0a,0,$80c,$90b,$a02,0
          dc.w    $80c,$90b,$a00,0,$80c,$90a,$a08,0

          dc.w    $80d,$906,$a04,0,$80d,$905,$a05,0
          dc.w    $80d,$905,$a04,0,$80c,$909,$a09,0
          dc.w    $80d,$904,$a03,0,$80b,$90b,$a09,0
          dc.w    $80c,$90a,$a05,0,$80b,$90a,$a0a,0
          dc.w    $80c,$909,$a08,0,$80b,$90b,$a08,0
          dc.w    $80c,$90a,$a00,0,$80c,$90a,$a00,0
          dc.w    $80c,$909,$a07,0,$80b,$90b,$a07,0
          dc.w    $80c,$909,$a06,0,$80b,$90b,$a06,0

          dc.w    $80b,$90a,$a09,0,$80b,$90b,$a05,0
          dc.w    $80a,$90a,$a0a,0,$80b,$90b,$a02,0
          dc.w    $80b,$90a,$a08,0,$80c,$907,$a07,0
          dc.w    $80c,$908,$a04,0,$80c,$907,$a06,0
          dc.w    $80b,$909,$a09,0,$80c,$906,$a06,0
          dc.w    $80a,$90a,$a09,0,$80c,$907,$a03,0
          dc.w    $80b,$90a,$a05,0,$80b,$909,$a08,0
          dc.w    $80b,$90a,$a03,0,$80a,$90a,$a08,0

          dc.w    $80b,$90a,$a00,0,$80b,$909,$a07,0
          dc.w    $80b,$908,$a08,0,$80a,$90a,$a07,0
          dc.w    $80a,$909,$a09,0,$80c,$901,$a01,0
          dc.w    $80a,$90a,$a06,0,$80b,$908,$a07,0
          dc.w    $80a,$90a,$a05,0,$80a,$909,$a08,0
          dc.w    $80a,$90a,$a02,0,$80a,$90a,$a01,0
          dc.w    $80a,$90a,$a00,0,$809,$909,$a09,0
          dc.w    $80a,$908,$a08,0,$80b,$908,$a01,0

          dc.w    $80a,$909,$a06,0,$80b,$907,$a04,0
          dc.w    $80a,$909,$a05,0,$809,$909,$a08,0
          dc.w    $80a,$909,$a03,0,$80a,$908,$a06,0
          dc.w    $80a,$909,$a00,0,$809,$909,$a07,0
          dc.w    $809,$908,$a08,0,$80a,$908,$a04,0
          dc.w    $809,$909,$a06,0,$80a,$908,$a01,0
          dc.w    $809,$909,$a05,0,$809,$908,$a07,0
          dc.w    $808,$908,$a08,0,$809,$909,$a02,0

          dc.w    $809,$908,$a06,0,$809,$909,$a00,0
          dc.w    $809,$907,$a07,0,$808,$908,$a07,0
          dc.w    $809,$907,$a06,0,$809,$908,$a02,0
          dc.w    $808,$908,$a06,0,$809,$906,$a06,0
          dc.w    $808,$907,$a07,0,$808,$908,$a04,0
          dc.w    $808,$907,$a06,0,$808,$908,$a02,0
          dc.w    $807,$907,$a07,0,$808,$906,$a06,0
          dc.w    $808,$907,$a04,0,$807,$907,$a06,0

          dc.w    $808,$906,$a05,0,$808,$906,$a04,0
          dc.w    $807,$906,$a06,0,$807,$907,$a04,0
          dc.w    $808,$905,$a04,0,$806,$906,$a06,0
          dc.w    $807,$906,$a04,0,$807,$905,$a05,0
          dc.w    $806,$906,$a05,0,$806,$906,$a04,0
          dc.w    $806,$905,$a05,0,$806,$906,$a02,0
          dc.w    $806,$905,$a04,0,$805,$905,$a05,0
          dc.w    $806,$905,$a02,0,$805,$905,$a04,0

          dc.w    $805,$904,$a04,0,$805,$905,$a02,0
          dc.w    $804,$904,$a04,0,$804,$904,$a03,0
          dc.w    $804,$904,$a02,0,$804,$903,$a03,0
          dc.w    $803,$903,$a03,0,$803,$903,$a02,0
          dc.w    $803,$902,$a02,0,$802,$902,$a02,0
          dc.w    $802,$902,$a01,0,$801,$901,$a01,0
          dc.w    $802,$901,$a00,0,$801,$901,$a00,0
          dc.w    $801,$900,$a00,0,$800,$900,$a00,0

          dc.w    $80e,$90d,$a0c,0,$80f,$903,$a00,0
          dc.w    $80f,$903,$a00,0,$80f,$903,$a00,0
          dc.w    $80f,$903,$a00,0,$80f,$903,$a00,0
          dc.w    $80f,$903,$a00,0,$80e,$90d,$a0b,0
          dc.w    $80e,$90d,$a0b,0,$80e,$90d,$a0b,0
          dc.w    $80e,$90d,$a0b,0,$80e,$90d,$a0b,0
          dc.w    $80e,$90d,$a0b,0,$80e,$90d,$a0b,0
          dc.w    $80e,$90d,$a0a,0,$80e,$90d,$a0a,0

          dc.w    $80e,$90d,$a0a,0,$80e,$90d,$a0a,0
          dc.w    $80e,$90c,$a0c,0,$80e,$90d,$a00,0
          dc.w    $80d,$90d,$a0d,0,$80d,$90d,$a0d,0
          dc.w    $80d,$90d,$a0d,0,$80d,$90d,$a0d,0
          dc.w    $80d,$90d,$a0d,0,$80d,$90d,$a0d,0
          dc.w    $80e,$90c,$a0b,0,$80e,$90c,$a0b,0
          dc.w    $80e,$90c,$a0b,0,$80e,$90c,$a0b,0
          dc.w    $80e,$90c,$a0b,0,$80e,$90c,$a0b,0

          dc.w    $80e,$90c,$a0b,0,$80e,$90c,$a0b,0
          dc.w    $80e,$90c,$a0a,0,$80e,$90c,$a0a,0
          dc.w    $80e,$90c,$a0a,0,$80e,$90c,$a0a,0
          dc.w    $80d,$90d,$a0c,0,$80d,$90d,$a0c,0
          dc.w    $80e,$90c,$a09,0,$80e,$90c,$a09,0
          dc.w    $80e,$90c,$a05,0,$80e,$90c,$a00,0
          dc.w    $80e,$90c,$a00,0,$80e,$90b,$a0b,0
          dc.w    $80e,$90b,$a0b,0,$80e,$90b,$a0b,0

          dc.w    $80e,$90b,$a0b,0,$80e,$90b,$a0a,0
          dc.w    $80e,$90b,$a0a,0,$80e,$90b,$a0a,0
          dc.w    $80d,$90d,$a0b,0,$80d,$90d,$a0b,0
          dc.w    $80d,$90d,$a0b,0,$80e,$90b,$a09,0
          dc.w    $80e,$90b,$a09,0,$80e,$90b,$a09,0
          dc.w    $80d,$90c,$a0c,0,$80d,$90d,$a0a,0
          dc.w    $80e,$90b,$a07,0,$80e,$90b,$a00,0
          dc.w    $80e,$90b,$a00,0,$80d,$90d,$a09,0

          dc.w    $80d,$90d,$a09,0,$80e,$90a,$a09,0
          dc.w    $80d,$90d,$a08,0,$80d,$90d,$a07,0
          dc.w    $80d,$90d,$a04,0,$80d,$90d,$a00,0
          dc.w    $80e,$90a,$a04,0,$80e,$909,$a09,0
          dc.w    $80e,$909,$a09,0,$80d,$90c,$a0b,0
          dc.w    $80e,$909,$a08,0,$80e,$909,$a08,0
          dc.w    $80e,$909,$a07,0,$80e,$908,$a08,0
          dc.w    $80e,$909,$a01,0,$80c,$90c,$a0c,0

          dc.w    $80d,$90c,$a0a,0,$80e,$908,$a06,0
          dc.w    $80e,$907,$a07,0,$80e,$908,$a00,0
          dc.w    $80e,$907,$a05,0,$80e,$906,$a06,0
          dc.w    $80d,$90c,$a09,0,$80e,$905,$a05,0
          dc.w    $80e,$904,$a04,0,$80d,$90c,$a08,0
          dc.w    $80d,$90b,$a0b,0,$80e,$900,$a00,0
          dc.w    $80d,$90c,$a06,0,$80d,$90c,$a05,0
          dc.w    $80d,$90c,$a02,0,$80c,$90c,$a0b,0

          dc.w    $80c,$90c,$a0b,0,$80d,$90b,$a0a,0
          dc.w    $80d,$90b,$a0a,0,$80d,$90b,$a0a,0
          dc.w    $80d,$90b,$a0a,0,$80c,$90c,$a0a,0
          dc.w    $80c,$90c,$a0a,0,$80c,$90c,$a0a,0
          dc.w    $80d,$90b,$a09,0,$80d,$90b,$a09,0
          dc.w    $80d,$90a,$a0a,0,$80d,$90a,$a0a,0
          dc.w    $80d,$90a,$a0a,0,$80c,$90c,$a09,0
          dc.w    $80c,$90c,$a09,0,$80c,$90c,$a09,0

          dc.w    $80d,$90b,$a06,0,$80c,$90b,$a0b,0
          dc.w    $80c,$90c,$a08,0,$80d,$90b,$a00,0
          dc.w    $80d,$90b,$a00,0,$80c,$90c,$a07,0
          dc.w    $80c,$90c,$a06,0,$80c,$90c,$a05,0
          dc.w    $80c,$90c,$a03,0,$80c,$90c,$a01,0
          dc.w    $80c,$90b,$a0a,0,$80d,$90a,$a05,0
          dc.w    $80d,$90a,$a04,0,$80d,$90a,$a02,0
          dc.w    $80d,$909,$a08,0,$80d,$909,$a08,0

snd_buf   ds.l 1
          end
















