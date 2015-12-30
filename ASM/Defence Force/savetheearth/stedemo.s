;
;           Dbug's STE only demo
; for the 20th anniversary of the Atari STE
;            2009, 5th of April
;
; Kraftwerk: Music non stop
; p4 changes -l -s submitted -t  //depot/sources/atari/ABriefSteryOfTime/... >commits.txt <- dumps all the commits

enable_steembreak		equ 0
enable_boundschecker	equ 0
enable_colorhelpers		equ 0
enable_music			equ 1
enable_debug_text		equ 0
enable_auto_skip		equ 1
enable_navigation		equ 0

;
; Enable/disable parts
; Nothing enabled=95114
enable_part_loadingdone	equ 1	;  104494
enable_part_tvsnow      equ 1   ;  253644
enable_part_piracy		equ 1   ; 1524008
enable_part_cinemascope	equ 1   ;  778358 - 24"
enable_part_nightcity	equ 1   ;  171388 - 22"
enable_part_motherboard	equ 1   ;  511040 - 44"
enable_part_outrun		equ 1   ;  144620 - 7"
enable_part_insertdisk	equ 1   ;  158570 - 13"
enable_part_office		equ 1   ;  213836 - 36"
enable_part_chatroom	equ 1   ;  154576 - 50"
enable_part_credits		equ 1   ;  197922 - 38"


stack_size		set 500
big_buffer_size	set 0

 opt o+,w-
  
 SECTION TEXT
 
text_start 
  
 bra ProgStart
 
 SECTION DATA
 
data_start

 
 SECTION BSS

bss_start

 include macros.s
 include system.s
 include keyboard.s
 include palette.s
 include blitter.s
 include math.s
 include full.s
 include subtitle.s
 include texting.s
 include audio.s
 include curves.s
 include depack.s
 include sequence.s
 
 SECTION TEXT
  
; ------------------
;   Program start
; ------------------
ProgStart 
 ;
 ; Call the main routine
 ;
 move.l #super_main,-(sp)
 move.w #$26,-(sp)
 trap #14
 addq.w #6,sp

 ;
 ; Quit
 ;
 clr.w -(sp)
 trap #1
	
		 
super_main
 ;
 ; This has to be done first, else we will lose data
 ; We need to start by clearing the BSS in case of some packer let some crap
 ;
 lea bss_start,a0					
 lea bss_end,a1 					
 bsr MemoryClear
 
 ;
 ; Can now safely save the stack pointer and allocate our own stack.
 ;
 move.l sp,save_ssp
 lea my_stack,sp 					
 
 ;
 ; We need to know on which machine we are running the intro.
 ; We accept STE and MegaSTE as valid machines.
 ; Anything else will have a nice message telling them to "upgrade" or use an emulator :)
 ;
 bsr DetectMachine
 tst d0
 bne.s .testok
 
 ; This machine is not a STE/MSTE
 pea NotASteMessage
 move #9,-(sp)
 trap #1
 addq #6,sp
 
 ; wait key
 move #7,-(sp)
 trap #1
 addq #2,sp
 
 move.l save_ssp,sp
 rts

.testok 
    
 
 ;
 ; Ignore all interrupt requests
 ; 
 bsr SaveSystem 					

 bsr SetSystemParameters
 
 bsr SubtitleMapFont
 
 bsr KeyboardFlushBuffer

 move.l #routine_vbl_nothing,$70.w
 bsr screen_choc				; Shake up baby !

 bsr main


;
; Restore everything
;
fin_demo
 bsr WaitVbl
 move.l #routine_vbl_nothing,$70.w
 bsr screen_choc

 bsr KeyboardFlushBuffer
 bsr RestoreSystem 					
 
 move.l save_ssp,sp
 rts

 

main
 
 sf.b flag_end_program
 
.loop_sequence
 ;
 ; Some initialisation code common to all parts
 ;
 move.l #routine_vbl_nothing,$70.w
 move.l #DummyRoutine,_AdrEndOfFadeRoutine 
 
 ; Set a black palette to avoid glitches
 lea empty_line,a0
 bsr PaletteSet
 
 sf.b flag_end_part
 move #0,pos_scr_x
 move #0,pos_scr_y
 move #208,screen_stride		; Default in 320x200 is 160 bytes
 move #208,blit_stride
 move.b #0,$ffff820f.w			; line width (still necessary ???)
 
 move.l #DummyRoutine,_AdrPartVblRoutine
 
 bsr SubtitleClearBuffer
 bsr ClearBigBuffer
  
 bsr KeyboardFlushBuffer
  
 ;
 ; Initialise the part
 ;
 move.l PtrSequencer,a0
 move.l (a0)+,_AdrPartInit
 beq .end_sequence
 move.l (a0)+,_AdrPartPlay
 move.l (a0)+,_AdrPartTerminate
 move.l (a0)+,d0					; Sequencer
 move.l a0,PtrSequencer

 tst.l d0
 beq.s .skip_sequencer
 move.l d0,a0
 bsr SequencerInit
.skip_sequencer 
 
 ; VBL Sync 
 bsr SyncVbl
 
_AdrPartInit=*+2 
 jsr $123456		; Init
 
 ;
 ; Loop on the part
 ;
 tst.l _AdrPartPlay
 beq.s .end_part
.loop_play 

 ; VBL Sync 
 bsr WaitVbl
  
 ; Check the keyboard
 bsr KeyboardManage
   
 ; returns d0=true to quit
_AdrKeyboardManager=*+2 
 jsr KeyboardDefaultManager
 tst.b d0
 bne.s .end_part

_AdrPartPlay=*+2 
 jsr $123456		; Play - receives the pressed key in D0, or 0 if nothing is pressed
 
 tst.b flag_end_part
 beq.s .loop_play
.end_part

 
 ;
 ; Clean-up the part
 ;
 tst.l _AdrPartTerminate
 beq.s .end_cleanup

_AdrPartTerminate=*+2 
 jsr $123456		; Terminate
 
.end_cleanup

 ; User pressed space ?  
 tst.b flag_end_program
 beq .loop_sequence
 
.end_sequence
 ifne enable_music
 bsr StopMusic
 endc
 rts
 
 
ClearBigBuffer
 lea big_buffer_start,a0					
 lea big_buffer_end,a1 
 bsr MemoryClear					
 rts 
     

routine_vbl_nothing
 movem.l d0-a6,-(sp)

 sf $fffffa1b.w							; Disable HBL
 
 st flag_vbl

 ; Update the time counters
 bsr TimeUpdate
  
 ;
 ; Replay music if initialised
 ;
 ifne enable_music
 move.l _AdrMusicVblRoutine,a0
 jsr (a0)
 endc
  
 movem.l (sp)+,d0-a6
 rte
 
  
CommonVblSubRoutine
 st.b flag_vbl

 ; Update the time counters
 bsr TimeUpdate
  
 COLORHELP #$777
_AdrPartVblRoutine=*+2
 jsr DummyRoutine
 COLORHELP #$000

 ;
 ; Compute new palette
 ;
 lea palette_vbl_fade,a0
 bsr ApplyGradient
 rts
  
 
DummyRoutine
 rts

   
; ===========================================================================
;
;					    Additional source for parts
;
; ===========================================================================

 ifne enable_music
 include music.s
 endc

 ifne enable_part_loadingdone
 include loaddone.s
 endc
 
 ifne enable_part_tvsnow
 include tvsnow.s
 endc

 ifne enable_part_piracy
 include piracy.s
 endc

 ifne enable_part_cinemascope
 include cinescop.s
 endc
 
 ifne enable_part_nightcity
 include nighcity.s
 endc
 
 ifne enable_part_insertdisk
 include insrdisk.s
 endc
 
 ifne enable_part_office
 include deskofic.s
 endc
   
 ifne enable_part_chatroom
 include chatroom.s
 endc
 
 ifne enable_part_motherboard
 include mobo.s
 endc
 
 ifne enable_part_outrun
 include outrun.s
 endc
   
 ifne enable_part_credits
 include credits.s
 endc 
 
 SECTION TEXT
 
text_end
 
text_size   equ text_end-text_start
 
 SECTION DATA

 even
  
; Some black area that Will always contains 000 (which is why it is in DATA and not in BSS)
; can be used for erasing, and space character definition
; Required space is:
; - 32 bytes for a palette (16 words)
; - 64 bytes for a fullregister clearing (16 long words)
; - 128 bytes for a space character: 16 lines by 4 bytes by 2 columns
black_palette	 	dcb.l 32
white_palette		dcb.w 16,$fff
 
PtrSequencer  
 dc.l Sequencer

Sequencer
 ifne enable_part_loadingdone
 dc.l LoadDoneInit,LoadDonePlay,LoadDoneTerminate,0
 endc
 
 ifne enable_part_tvsnow
 dc.l TvSnowInit,TvSnowPlay,TvSnowTerminate,0
 endc
 
 ifne enable_part_piracy
 dc.l PiracyInit,PiracyPlay,PiracyTerminate,PiracySequencer
 endc
 
 ifne enable_part_cinemascope
 dc.l CinemaScopeInit,CinemaScopePlay,CinemaScopeTerminate,CinemascopeSequencer
 endc
 
 ifne enable_part_nightcity
 dc.l DisplayNightCityInit,DisplayNightCityPlay,DisplayNightCityTerminate,NightCitySequencer
 endc
 
 ifne enable_part_motherboard
 dc.l MotherBoardInit,MotherBoardPlay,MotherBoardTerminate,AtariBuildingSequencer
 endc
 
 ifne enable_part_outrun
 dc.l OutrunInit,OutrunPlay,OutrunTerminate,OutrunSequencer
 endc
 
 ifne enable_part_insertdisk
 dc.l InsertDiskInit,InsertDiskPlay,InsertDiskTerminate,BootDiskSequencer
 endc
 
 ifne enable_part_office
 dc.l DesktopOfficeInit,DesktopOfficePlay,DesktopOfficeTerminate,DesktopOfficeSequencer
 endc
     
 ifne enable_part_chatroom
 dc.l ChatRoomInit,ChatRoomPlay,ChatRoomTerminate,ChatRoomSequencer
 endc

 ifne enable_part_credits
 dc.l CreditsInit,CreditsPlay,CreditsTerminate,0
 endc 
 
 ; The end
 dc.l 0,0,0

   
; ===========================================================================
;
;					Tables, palettes, and other dc.x thingies
;
; ===========================================================================

NotASteMessage
 dc.b "This demo works only on STE or MegaSTE",0

 even	
 
data_end

data_size 	equ data_end-data_start
    
 SECTION BSS
 
 even
  
			  		ds.l stack_size
my_stack      		ds.l 1

 even
	
empty_line	  		ds.b 256+230	; Some empty bytes to have something "clean" to display during the sync line
   
 even
 
 
big_buffer_start	ds.l (big_buffer_size+3)/4
big_buffer_end

 
bss_end       ds.l 1

bss_size 	equ bss_end-bss_start

;
; 0000574E  T  R  text_end  ->  25780 (was 102528,115754,39372,21174,23612,22350)
; 00000000  T  R  text_start
;
; 000BA702  D  R  data_end  ->  763028 (was 1193668,803840,803956,803982,767264,763650)
; 00000000  D  R  data_start
;
; Total Disk = 788808
;
; 00118DEC  B  R  bss_end   -> 1158298 (was 635528,1297968,1340524,1175250,1150444)
; 00000000  B  R  bss_start
;
; Total memory usage = 1947106
;

 end

