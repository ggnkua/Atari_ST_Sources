
 
 SECTION TEXT
 
 even

; a0=music file start 
StartMusic
 move.l a0,music_ptr
 jsr 0(a0)
 st.b music_is_initialised

 lea 8+2(a0),a0
 add (a0),a0
 move.l a0,_AdrMusicVblRoutine 
 
 ;lea 8(a0),a0
 ;move.l a0,_AdrMusicVblRoutine 
 rts

StartMusicIfNotStarted
 ifne enable_music
 tst.b music_is_initialised
 bne.s .skip_zic
 lea music,a0
 bsr StartMusic
.skip_zic 
 endc
 rts
 
StopMusic
 tst.b music_is_initialised
 beq.s .skip_zic
 move.l #DummyRoutine,_AdrMusicVblRoutine 
 sf.b music_is_initialised
 move.l music_ptr,a0
 jsr 4(a0)
 bsr YmSilent
.skip_zic
 rts
 
PlayMusic
 tst.b music_is_initialised
 beq.s .skip_zic

 move.l music_ptr,a0
 COLORHELP #$700
 jsr 8(a0)
 COLORHELP #$000
.skip_zic
 rts  
  
YmSilent
 move.b #8,$ffff8800.w		; Volume register 0
 move.b #0,$ffff8802.w      ; Null volume
 move.b #9,$ffff8800.w		; Volume register 1
 move.b #0,$ffff8802.w      ; Null volume
 move.b #10,$ffff8800.w		; Volume register 2
 move.b #0,$ffff8802.w      ; Null volume
 rts
  
 SECTION DATA
 
 even
 
 ;+$0	=init
 ;+$4	=deinit
 ;+$8	=interrupt
 ;+$C.b	=zync code
 even
music	 			incbin "notimer.bin"
voicedataoffset		dc.l music_voice_data-voicedataoffset
songdataoffset		dc.l music_song_data-songdataoffset
songdatalength		dc.l music_end-music_song_data
music_voice_data	incbin "DBUG_STE.myv"
 even
music_song_data		incbin "DBUG_STE.mys"
music_end	
 even
 
 SECTION BSS
  
 even
 
music_ptr					ds.l 1
music_is_initialised		ds.b 1

 even
 