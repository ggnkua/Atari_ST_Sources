
 SECTION TEXT
 
 even

InsertDiskInit
 ; Depack test
 lea PackInfoInsertDisk,a0
 bsr DepackBlock
  
 ; Depack audio 
 lea packed_bootdisk_start,a0
 lea big_buffer_start+insertdisk_sample_start,a1
 move.l #insertdisk_sample_end-insertdisk_sample_start,d0
 bsr DepackDelta
   
 move.l #InsertDiskLedOff,_AdrInsertDiskled
 
 ; Using the template data, we generate the fullscreen
 lea PanoramicTemplate_DisplayList,a0
 lea big_buffer_start+insertdisk_fullscreen,a1
 bsr GenerateOverscan
 rts

InsertDiskPlay
_AdrInsertDiskled=*+2
 jsr InsertDiskLedBlinks
 bra SequencerPlay
 
InsertDiskTerminate
 bsr TerminateFullscreenTimer
 bra EndReplay
 
 
; From 272,32 to 315,136
; 3 blocs wide
; 104 lines high
; Starts at block 17, offset 136  
InsertDiskAnimation
 lea big_buffer_start+insertdisk_depacked_picture+32*200+(32*208)+136,a0
 moveq #1,d0
 move.w #105-1,d7
.loop_line 
var set 0
 REPT 4
 lsl.w var+8*2(a0)
 roxl.w var+8*1(a0)
 roxl.w var+8*0(a0)
var set var+2 
 ENDR
 lea 208(a0),a0
 dbra d7,.loop_line 
 rts
  
InsertDiskEjectButton
 lea big_buffer_start+insertdisk_depacked_picture+32*200+(34*208)+136-8,a0
 move.w #15-1,d7
.loop_line 
 move.b 1(a0),8(a0)
 move.b 3(a0),10(a0)
 move.b 5(a0),12(a0)
 move.b 7(a0),14(a0)
 lea 208(a0),a0
 dbra d7,.loop_line 
 rts
  
 
; Line 193/194, index 1
InsertDiskLedOff
 lea big_buffer_start+insertdisk_depacked_picture+32*193+2,a1
 move.w #$320,(a1)
 move.w #$320,32(a1)
 ; turn it off
 move.b #14,$ffff8800.w 
 or.b #%00000010,$ffff8802.w 
 rts

; Line 193/194, index 1
InsertDiskLedOn
 lea big_buffer_start+insertdisk_depacked_picture+32*193+2,a1
 move.w #$760,(a1)
 move.w #$760,32(a1)
 ; turn it on
 move.b #14,$ffff8800.w 
 and.b #%11111101,$ffff8802.w
 rts
  
; Line 193/194, index 1
InsertDiskLedBlinks
 bsr NextPRN
 and #1,d0
 bne.s InsertDiskLedOn
 bra.s InsertDiskLedOff
  
 
;|xxxxxxxx|          PSG register 14 (I/O port A)
; ||||||||__________ Floppy side 0/1 select
; |||||||___________ Floppy drive 0 select
; ||||||____________ Floppy drive 1 select
; |||||_____________ RS232 Ready To Send (RTS)
; ||||______________ RS232 Data Terminal Ready (DTR)
; |||_______________ Centronics STROBE
; ||________________ General purpose output (GPO)
; |_________________ RESERVED 
 
 SECTION DATA

 even
 
 
BootDiskSequencer
 ; Floppy disk is off - ask to insert a floppy
 SEQUENCE_SETPTR _AdrInsertDiskled,InsertDiskLedOff
 
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+insertdisk_depacked_picture
 
 SEQUENCE_TEMPORIZE 50*2
 SEQUENCE_SUBTITLE <"The new machine is now installed,",13,"let's try some exciting demos!">
 SEQUENCE_TEMPORIZE 50
 SEQUENCE_SETPTR _AdrInsertDiskled,InsertDiskAnimation 
 SEQUENCE_TEMPORIZE 50
 SEQUENCE_SETPTR _AdrInsertDiskled,InsertDiskLedOff
 
 ; Pop the eject button !
 SEQUENCE_CALLBACK InsertDiskEjectButton
 SEQUENCE_TEMPORIZE 20
 
 ; Start the read sequence - switch on the light
 SEQUENCE_SETPTR _AdrInsertDiskled,InsertDiskLedOn
 SEQUENCE_PLAYSAMPLES 1,0,9802,big_buffer_start+insertdisk_sample_start		; Start sound of the floppy drive
 
 ; Loading sequence - tac tac tac tac...
 SEQUENCE_SUBTITLE <"Please wait, loading...",13,"...wish I had a harddrive.">
 SEQUENCE_PLAYSAMPLES 35,9802,11979,big_buffer_start+insertdisk_sample_start	; Track change
 
 ; Decrunching - switch off the led 
 SEQUENCE_SETPTR _AdrInsertDiskled,InsertDiskLedOff
 SEQUENCE_SUBTITLE <"Decrunching micro blips..."> 
 SEQUENCE_TEMPORIZE 50*2
 
 ; Decrunching done - Start the music and blinks the led on the rythm of the music
 SEQUENCE_SETPTR _AdrInsertDiskled,InsertDiskLedBlinks
 SEQUENCE_SUBTITLE <"Enjoy the sound of the 80ies !">

; ifne enable_part_office
; SEQUENCE_CALLBACK DesktopOfficeStartMusic
; endc
 
 ; Wait 5 seconds and then move to the next part
 SEQUENCE_TEMPORIZE 250
 
 SEQUENCE_GO_NEXT_PART	; And leave
 
 SEQUENCE_END
	 
  
PackInfoInsertDisk 
 dc.l picture_insertdisk
 dc.l big_buffer_start+insertdisk_depacked_picture
 dc.l 48000

; Unpacked: 48000
; Packed:    9020 
 FILE "insrdisk.pik",picture_insertdisk


; Unpacked: 13352
; Packed:    6677
 FILE "bootdisk.dlt",packed_bootdisk_start,packed_bootdisk_end

   
 SECTION BSS
  
 even


 
;
; The content of this buffer is going to be stored in
; the big common table.
; 
 rsreset
insertdisk_fullscreen		rs.b Size_PanoramicRoutine_DisplayList
insertdisk_depacked_picture	rs.b 48000

insertdisk_sample_start		rs.b 13352
insertdisk_sample_end		rs.b 16				; Some padding to handle the alignment issues

 update_buffer_size
 

 
