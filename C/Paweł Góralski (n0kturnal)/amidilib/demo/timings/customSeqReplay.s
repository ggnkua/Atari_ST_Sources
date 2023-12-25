
;    Copyright 2007-2022 Pawel Goralski
;    
;    This file is part of AMIDILIB.
;    See license.txt for licensing information.

;    midi delta handling and timing demo

    include "mfp_m68k.inc"
    
MIDI_SENDBUFFER_SIZE    equ	32*1024

    xdef _super_on                      	;supervisor mode on
    xdef _super_off                     	;supervisor mode off

    xdef _turnOffKeyclick               	;turns off keyclicks

    xdef _customSeqReplay			;custom sequence replay handler
    xref _updateSequenceStep			;our sequence update routine

    xdef _installReplayRoutGeneric	    	;initialises replay interrupt TB routine and prepares data
    xdef _deinstallReplayRoutGeneric	;removes replay routine from system

    if (IKBD_MIDI_SEND_DIRECT==1)
    xdef _midiSendBuffer                  ;buffer with data to send
    xdef _midiBytesToSend                 ;nb of bytes to send
    xdef _flushMidiSendBufferCr
    xdef _clearMidiOutputBufferCr         ;custom midi buffer clear function
    endif

	TEXT
_customSeqReplay:
	movem.l    d0-7/a0-6,-(a7)          ;save registers

      move.w      sr,-(a7)
      or.w        #$2300,sr               ;disable interrupts, leave ikbd
	
      clr.b      $fffffa1b

      if (DEBUG_BUILD)
	eori.w       #$0f0,$ffff8240        ;change 1st color in palette
      endif

	jsr 		_updateSequenceStep

	if (IKBD_MIDI_SEND_DIRECT==1)
	echo	"[testReplay.s] IKBD MIDI DATA SEND DIRECT ENABLED"
	moveq		#0,d1
	move.l 	#_midiSendBuffer,a0
	move.w	_midiBytesToSend,d1
	
	cmpi.w	#0,d1	
	beq.s       .done		        ;nothing to be done
.send:      
      ;slap data to d0
      move.w	(a0),d0	       ;get word
      clr.w		(a0)+ 	       ;clear it
      
      move.w	d0,d2		       ;make copy
      andi.w	#$FF00,d2	       ;get first byte
      lsr.w 	#8,d2
.wait1:
      btst		#1,$fffffc04.w	;is data register empty?
      beq.s		.wait1		;no, wait!
      move.b	d2,$fffffc06.w	;write to MIDI data register
      subq.w	#1,d1
      cmpi.w	#0,d1	
      beq.s		.done
      
      ;not done
      move.w	d0,d2
      andi.w	#$00FF,d2         ;get second byte
.wait2:
      btst		#1,$fffffc04.w	;is data register empty?
      beq.s		.wait2		;no, wait!
      move.b	d2,$fffffc06.w	;write to MIDI data register
      
      subq.w	#1,d1
      cmpi.w	#0,d1	
      beq.s		.done
      
      bra.s		.send
      
.done:
	move.w	#0,_midiBytesToSend 
	else
	echo	"[testReplay.s] IKBD MIDI DATA SEND DIRECT DISABLED"
	endif
	
	;prepare next tick
      move.l    update,$120		;slap interrupt 
      move.b    tData,$fffffa21	;set data
      move.b    tMode,$fffffa1b	;div mode
	bset.b    #0,$fffffa07		;go!
	bset.b    #0,$fffffa13
.finish:	
      if (DEBUG_BUILD)
      eori.w     #$0f0,$ffff8240      ;change 1st color in palette
      endif

      move.w    (a7)+,sr             ;restore sr
	movem.l   (a7)+,d0-7/a0-6	; restore registers
	bclr.b    #0,$fffffa0f  	; finished!

	rte                 		; return from timer

; installs / deinstalls interrupt routine on timer B (used in demos, probably this pair should be removed at some point)
_installReplayRoutGeneric:
        movem.l	d0-d7/a0-a6,-(sp)
        
        move.b    $40(sp),d1        ; timer event mode
        move.b    $42(sp),d0        ; timer data
        move.l    $44(sp),update  	; interrupt routine ptr

        bsr.w	_super_on
        move.w	sr,-(sp)		;save status register
        or.w	#$0700,sr		;turn off all interupts

        move.b	d1,tMode  		;save parameters for later
        move.b	d0,tData

        clr.b     $fffffa1b		;turn off tb

        move.l	$120,oldVector
        move.l    update,$120		;slap interrupt

        move.b    d0,$fffffa21	;put data
        move.b    d1,$fffffa1b	;put mode
        bset.b    #0,$fffffa07
        bset.b    #0,$fffffa13

        move.w 	(sp)+,sr 		;restore Status Register
        bsr.w     _super_off
        movem.l   (sp)+,d0-d7/a0-a6	;restore registers
        rts

_deinstallReplayRoutGeneric:
        movem.l	  d0-d7/a0-a6,-(sp)

        bsr.w	_super_on

        move.w	sr,-(a7)		;save status register
        or.w	#$0700,sr

        clr.b     $fffffa1b	      ;turn off tb
        move.l	oldVector,$120	;save old tb

        move.w	(sp)+,sr	      ;restore Status Register

        bsr.w	_super_off
        movem.l   (sp)+,d0-d7/a0-a6
        rts

_turnOffKeyclick:
      bsr.w	_super_on
      bclr	#0,$484.w

      bsr.w	_super_off
      rts
      
      if (IKBD_MIDI_SEND_DIRECT==1)

; sends midi data directly to ikbd, plain m68k friendly
_flushMidiSendBufferCr:
      movem.l	d0-d1/a0,-(sp)
      move.w  sr,-(sp)

      move.w  #0,d1
      move.l  #_midiSendBuffer,a0
      move.w  _midiBytesToSend,d1

      cmpi.w	#0,d1	
      beq.s	.done		;nothing to be done

.send:      
      ;slap data to d0
      move.w	(a0)+,d0	;get word
      move.w	d0,d2		;make copy
      andi.w	#$FF00,d2
      lsr.w	      #8,d2
.wait1:
      btst        #1,$fffffc04.w	;is data register empty?
      beq.s       .wait1		;no, wait!
      move.b      d2,$fffffc06.w	;write to MIDI data register
      subq.w	#1,d1
      cmpi.w	#0,d1	
      beq.s       .done
      
      ;not done
      move.w	d0,d2
      andi.w	#$00FF,d2
.wait2:
      btst        #1,$fffffc04.w	;is data register empty?
      beq.s       .wait2		;no, wait!
      move.b	d2,$fffffc06.w	;write to MIDI data register
      
      subq.w	#1,d1
      cmpi.w	#0,d1	
      beq.s       .done
      
      bra.s       .send

.done:
      move.w 	#0,_midiBytesToSend

      move.w	(sp)+,sr
      movem.l (sp)+,d0-d1/a0
      rts

_clearMidiOutputBufferCr:
      movem.l     d0-d7/a0-a6,-(sp)

      move.w      sr,-(sp)                ;disable interrupts
      or.w        #0700,sr

      move.w      #0,_midiBytesToSend

      move.l      #_midiSendBuffer,a0
      add.l       #1024*32,a0

      move.l      #630-1,d7

      move.l      #0,d0
      move.l      #0,d1
      move.l      #0,d2
      move.l      #0,d3
      move.l      #0,d4
      move.l      #0,d5
      move.l      #0,d6

      move.l      #0,a1
      move.l      #0,a2
      move.l      #0,a3
      move.l      #0,a4
      move.l      #0,a5
      move.l      #0,a6
.cpy:
      movem.l     d0-d6/a1-a6,-(a0)
      dbra        d7,.cpy

      move.w  (sp)+,sr
      movem.l (sp)+,d0-d7/a0-a6
      rts
      endif
      
 ; enter supervisor mode
 ; but only when not in supervisor
_super_on:
        movem.l   d0-7/a0-a6,-(sp)

        clr.l     -(sp)
        move.w    #$20,-(sp)
        trap      #1
        addq.l    #6,sp
        move.l    d0,old_ssp
.skip:
        movem.l   (sp)+,d0-7/a0-a6
        rts

;leave supervisor mode
_super_off:
        movem.l   d0-7/a0-a6,-(sp)
        move.l    old_ssp,-(sp)
        move.w    #$20,-(sp)
        trap      #1
        addq.l    #6,sp
        movem.l   (sp)+,d0-7/a0-a6 
        rts
        
        BSS
	if (IKBD_MIDI_SEND_DIRECT==1)
_midiSendBuffer:	
	ds.b	MIDI_SENDBUFFER_SIZE
_midiBytesToSend:	
	ds.w	1	; nb of bytes to send
      endif

old_ssp:          ds.l  1
update:           ds.l  1         ;pointer to interrupt executing midi update routine and for setting up next interrupt

; Timer data
oldVector:        ds.l  1
tData:            ds.b  1         ; current timer data
dummy1:           ds.b  1     
tMode:            ds.b  1         ; current timer mode
dummy2:           ds.b  1
