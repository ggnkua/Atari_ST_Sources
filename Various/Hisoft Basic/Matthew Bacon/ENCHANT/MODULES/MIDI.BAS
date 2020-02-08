
' [MIDI.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

SUB clear_midi_buffer
STATIC dummy

POKEW iorec&(2)+6,&h0
POKEW iorec&(2)+8,&h0
FOR dummy=14 TO (PEEKW (iorec&(2)+4))+12
	POKEW iorec&(2)+dummy,&h0
NEXT
END SUB


SUB redirect_midi_buffer (midibuffer(),BYVAL buffer_size)
SHARED midibufferadr&,midibuffer()

IF midibufferadr&=0 THEN midibufferadr&=iorec&(2)
REDIM midibuffer(buffer_size-1)
POKEW iorec&(2),VARPTR(midibuffer(0))
POKEW iorec&(2)+4,buffer_size
POKEW iorec&(2)+6,0
POKEW iorec&(2)+8,0
POKEW iorec&(2)+10,0
POKEW iorec&(2)+12,(buffer_size-1)
END SUB


SUB restore_midi_buffer
SHARED midibufferadr&,midibuffer()

IF midibufferadr&=0 THEN EXIT SUB
REDIM midibuffer(0)
POKEW iorec&(2),midibufferadr&
POKEW iorec&(2)+4,128
POKEW iorec&(2)+6,0
POKEW iorec&(2)+8,0
POKEW iorec&(2)+10,0
POKEW iorec&(2)+12,127
END SUB


SUB play_s_midi (midi_byte(),midi_time!())
SHARED last_midi_byte
STATIC dummy,t!,time!

dummy=0 : t!=TIMER
DO
	time!=TIMER-t!
	IF midi_time!(dummy)<=time!
		OUT 3,midi_byte(dummy)
		INCR dummy
	END IF
LOOP UNTIL dummy=last_midi_byte OR INKEY$<>""
CALL all_notes_off
END SUB


SUB record_s_midi(midi_byte(),midi_time!(),BYVAL rec_bytes)
SHARED last_midi_byte
STATIC dummy,byte,t!,time!

CALL clear_midi_buffer
dummy=0
DO
	IF INP(-3) THEN
		byte=INP(3)
		SELECT CASE byte
		CASE<>&hFE
			IF dummy=0 THEN t!=TIMER
			time!=TIMER-t!
			midi_byte(dummy)=byte
			midi_time!(dummy)=time!
			INCR dummy
		END SELECT
	END IF
LOOP UNTIL dummy=(rec_bytes-1) OR INKEY$<>""
last_midi_byte=dummy : CALL all_notes_off
END SUB


SUB play_all_midi (midi_byte(),midi_time!())
SHARED last_midi_byte,midi_chnl(),chnl()
STATIC t!,time!,ch,byte,dummy

REDIM PRESERVE chnl(17)
FOR dummy=1 TO 16
	chnl(dummy)=0
NEXT dummy
t!=TIMER
DO
	time!=TIMER-t!
	FOR ch=1 TO 16
		IF midi_chnl(ch)<>0 THEN
		IF midi_chnl(ch)>=chnl(ch) THEN
			IF midi_time!(ch,chnl(ch))<=time! THEN
				byte=midi_byte(ch,chnl(ch))
				SELECT CASE byte
					CASE &h80 TO &h8F
						OUT 3,&h80+(ch-1)
						OUT 3,midi_byte(ch,chnl(ch)+1)
						OUT 3,midi_byte(ch,chnl(ch)+2)
						chnl(ch)=(chnl(ch)+3)
					CASE &h90 TO &h9F
						OUT 3,&h90+(ch-1)
						OUT 3,midi_byte(ch,chnl(ch)+1)
						OUT 3,midi_byte(ch,chnl(ch)+2)
						chnl(ch)=(chnl(ch)+3)
					CASE ELSE
						OUT 3,&h90+(ch-1)
						OUT 3,midi_byte(ch,chnl(ch))
						OUT 3,midi_byte(ch,chnl(ch)+1)
						chnl(ch)=(chnl(ch)+2)
				END SELECT
			END IF
		END IF
		END IF
	IF chnl(ch)>(last_midi_byte+1) THEN EXIT LOOP
	IF INKEY$<>"" THEN EXIT LOOP
	NEXT
LOOP UNTIL chnl(ch)>(last_midi_byte+1) OR INKEY$<>""
CALL all_notes_off
END SUB


SUB record_all_midi(midi_byte(),midi_time!(),channel,BYVAL rec_bytes)
SHARED last_midi_byte,midi_chnl(),chnl()
STATIC dummy,byte,t!,time!,ch

FOR dummy=0 TO rec_bytes-1
	midi_byte(channel,dummy)=0
	midi_time!(channel,dummy)=0
NEXT

CALL clear_midi_buffer : dummy=0
REDIM PRESERVE chnl(17)
FOR dummy=1 TO 16
	chnl(dummy)=0
NEXT dummy
t!=TIMER
DO
	FOR ch=1 TO 16
	IF INP(-3) THEN
		byte=INP(3)
		IF byte<>&hFE THEN
			time!=TIMER-t!
			midi_byte(channel,dummy)=byte
			midi_time!(channel,dummy)=time!
			INCR dummy
		END IF
	END IF

	time!=TIMER-t!
	IF midi_chnl(ch)<>0 THEN
		IF midi_chnl(ch)>=chnl(ch) THEN
			IF midi_time!(ch,chnl(ch))<=time! THEN
				byte=midi_byte(ch,chnl(ch))
				SELECT CASE byte
					CASE &h80 TO &h8F
						OUT 3,&h80+(ch-1)
						OUT 3,midi_byte(ch,chnl(ch)+1)
						OUT 3,midi_byte(ch,chnl(ch)+2)
						chnl(ch)=(chnl(ch)+3)
					CASE &h90 TO &h9F
						OUT 3,&h90+(ch-1)
						OUT 3,midi_byte(ch,chnl(ch)+1)
						OUT 3,midi_byte(ch,chnl(ch)+2)
						chnl(ch)=(chnl(ch)+3)
					CASE ELSE
						OUT 3,&h90+(ch-1)
						OUT 3,midi_byte(ch,chnl(ch))
						OUT 3,midi_byte(ch,chnl(ch)+1)
						chnl(ch)=(chnl(ch)+2)
				END SELECT
			END IF
		END IF
	END IF
	IF dummy>(rec_bytes-1) THEN EXIT LOOP
	IF INKEY$<>"" THEN EXIT LOOP
	NEXT
LOOP UNTIL dummy>(rec_bytes-1) OR INKEY$<>""
IF dummy>last_midi_byte THEN last_midi_byte=dummy
chnl(channel)=dummy : CALL all_notes_off : midi_chnl(channel)=dummy
END SUB


SUB midi_monitor
STATIC dummy

CALL clear_midi_buffer
PRINT CHR$(27)+"p"
PRINT "                         "
PRINT " Midi Monitor by ENCHANT "
PRINT "                         "
PRINT CHR$(27)+"q"
DO
	IF INP(-3) THEN
		dummy=INP(3)
		IF dummy<>254 THEN PRINT dummy,"&h"+HEX$(dummy)
	END IF
LOOP UNTIL INKEY$<>""
END SUB

' Midi Events

SUB midi_text (dummy$)
STATIC dummy

IF LEN(dummy$)>=1 THEN
	OUT 3,&hFF
	OUT 3,&h01
	OUT 3,LEN(dummy$)
	FOR dummy=1 TO LEN(dummy$)
		OUT 3,ASC(MID$(dummy$,dummy,1))
	NEXT dummy
END IF
END SUB


SUB midi_copyright (dummy$)
STATIC dummy

IF LEN(dummy$)>=1 THEN
	OUT 3,&hFF
	OUT 3,&h02
	OUT 3,LEN(dummy$)
	FOR dummy=1 TO LEN(dummy$)
		OUT 3,ASC(MID$(dummy$,dummy,1))
	NEXT dummy
END IF
END SUB


SUB midi_trackname (dummy$)
STATIC dummy

IF LEN(dummy$)>=1 THEN
	OUT 3,&hFF
	OUT 3,&h03
	OUT 3,LEN(dummy$)
	FOR dummy=1 TO LEN(dummy$)
		OUT 3,ASC(MID$(dummy$,dummy,1))
	NEXT dummy
END IF
END SUB


SUB midi_instrument (dummy$)
STATIC dummy

IF LEN(dummy$)>=1 THEN
	OUT 3,&hFF
	OUT 3,&h04
	OUT 3,LEN(dummy$)
	FOR dummy=1 TO LEN(dummy$)
		OUT 3,ASC(MID$(dummy$,dummy,1))
	NEXT dummy
END IF
END SUB


SUB midi_lyric (dummy$)
STATIC dummy

IF LEN(dummy$)>=1 THEN
	OUT 3,&hFF
	OUT 3,&h05
	OUT 3,LEN(dummy$)
	FOR dummy=1 TO LEN(dummy$)
		OUT 3,ASC(MID$(dummy$,dummy,1))
	NEXT dummy
END IF
END SUB


SUB midi_marker (dummy$)
STATIC dummy

IF LEN(dummy$)>=1 THEN
	OUT 3,&hFF
	OUT 3,&h06
	OUT 3,LEN(dummy$)
	FOR dummy=1 TO LEN(dummy$)
		OUT 3,ASC(MID$(dummy$,dummy,1))
	NEXT dummy
END IF
END SUB


SUB midi_cuepoint (dummy$)
STATIC dummy

IF LEN(dummy$)>=1 THEN
	OUT 3,&hFF
	OUT 3,&h01
	OUT 3,LEN(dummy$)
	FOR dummy=1 TO LEN(dummy$)
		OUT 3,ASC(MID$(dummy$,dummy,1))
	NEXT dummy
END IF
END SUB


SUB midi_channel (dummy)
	OUT 3,&hFF
	OUT 3,&h20
	OUT 3,&h01
	OUT 3,dummy-1
END SUB


SUB midi_port (dummy)
	OUT 3,&hFF
	OUT 3,&h20
	OUT 3,&h01
	OUT 3,dummy-1
END SUB


SUB midi_EOT
	OUT 3,&hFF
	OUT 3,&h2F
	OUT 3,&h00
END SUB

' Midi Messages

SUB note_off (channel,note,velocity)
	OUT 3,&h80+(channel-1)
	OUT 3,note
	OUT 3,velocity
END SUB


SUB note_on (channel,note,velocity)
	OUT 3,&h90+(channel-1)
	OUT 3,note
	OUT 3,velocity
END SUB


SUB aftertouch (channel,note,pressure)
	OUT 3,&hA0+(channel-1)
	OUT 3,note
	OUT 3,pressure
END SUB


SUB controller (channel,cntrl,dummy)
	OUT 3,&hB0+(channel-1)
	OUT 3,cntrl
	OUT 3,dummy
END SUB


SUB program_change (channel,change)
	OUT 3,&hC0+(channel-1)
	OUT 3,change
END SUB


SUB channel_pressure (channel,dummy)
	OUT 3,&hD0+(channel-1)
	OUT 3,dummy
END SUB


SUB pitch_wheel (channel,dummy)
	OUT 3,&hE0+(channel-1)
	OUT 3,dummy
END SUB

' SYSEX

SUB midi_start
	OUT 3,&hFA
END SUB


SUB midi_continue
	OUT 3,&hFB
END SUB


SUB midi_stop
	OUT 3,&hFC
END SUB


SUB midi_reset
	OUT 3,&hFF
END SUB

' Controller

SUB cntrl_bank_select (channel,dummy)
	OUT 3,&hB0+(channel-1)
	OUT 3,&h00
	OUT 3,dummy
END SUB


SUB cntrl_mod (channel,dummy)
	OUT 3,&hB0+(channel-1)
	OUT 3,&h01
	OUT 3,dummy
END SUB


SUB cntrl_breath (channel,dummy)
	OUT 3,&hB0+(channel-1)
	OUT 3,&h02
	OUT 3,dummy
END SUB


SUB cntrl_footpedal (channel,dummy)
	OUT 3,&hB0+(channel-1)
	OUT 3,&h04
	OUT 3,dummy
END SUB


SUB cntrl_portamento (channel,dummy)
	OUT 3,&hB0+(channel-1)
	OUT 3,&h05
	OUT 3,dummy
END SUB


SUB cntrl_data_entry (channel,dummy)
	OUT 3,&hB0+(channel-1)
	OUT 3,&h06
	OUT 3,dummy
END SUB


SUB cntrl_volume (channel,dummy)
	OUT 3,&hB0+(channel-1)
	OUT 3,&h07
	OUT 3,dummy
END SUB


SUB cntrl_balance (channel,dummy)
	OUT 3,&hB0+(channel-1)
	OUT 3,&h08
	OUT 3,dummy
END SUB


SUB cntrl_pan (channel,dummy)
	OUT 3,&hB0+(channel-1)
	OUT 3,&h0A
	OUT 3,dummy
END SUB


SUB cntrl_expression (channel,dummy)
	OUT 3,&hB0+(channel-1)
	OUT 3,&h0B
	OUT 3,dummy
END SUB


SUB cntrl_FX1 (channel,dummy)
	OUT 3,&hB0+(channel-1)
	OUT 3,&h0C
	OUT 3,dummy
END SUB


SUB cntrl_FX2 (channel,dummy)
	OUT 3,&hB0+(channel-1)
	OUT 3,&h0D
	OUT 3,dummy
END SUB


SUB cntrl_sustain (channel,dummy)
	OUT 3,&hB0+(channel-1)
	OUT 3,&h40
	OUT 3,dummy
END SUB


SUB cntrl_sustenuto (channel,dummy)
	OUT 3,&hB0+(channel-1)
	OUT 3,&h42
	OUT 3,dummy
END SUB


SUB cntrl_softpedal (channel,dummy)
	OUT 3,&hB0+(channel-1)
	OUT 3,&h43
	OUT 3,dummy
END SUB


SUB cntrl_chorus (channel,dummy)
	OUT 3,&hB0+(channel-1)
	OUT 3,&h5D
	OUT 3,dummy
END SUB


SUB cntrl_reverb (channel,dummy)
	OUT 3,&hB0+(channel-1)
	OUT 3,&h5B
	OUT 3,dummy
END SUB

' Midi Registered Parameter Number (RPN)

SUB all_notes_off
STATIC channel

FOR channel=0 TO 15
	OUT 3,&hB0+channel
	OUT 3,&h7B
	OUT 3,0
NEXT channel
END SUB


SUB notes_off (BYVAL channel)
	OUT 3,&hB0+(channel-1)
	OUT 3,&h7B
END SUB


SUB omni_on (BYVAL channel)
	OUT 3,&hB0+(channel-1)
	OUT 3,&h7C
	OUT 3,0
END SUB


SUB omni_off (BYVAL channel)
	OUT 3,&hB0+(channel-1)
	OUT 3,&h7D
	OUT 3,0
END SUB
