; Bad Apple!! PV Atari ST(e) by StackDesign 2016
;
; hi, I'm back at it again. now it's 160x200@30
; with progressive (no artifacts :])!
;
; original desc follows. it still stands.
;
; the code sucks since I'm bad at 68000 asm
; go and do something with it.
; if you want to optimize it all to run on 8 MHz
; or 512 KB, good luck
; probably won't take long for people who actually
; know ST programming, unlike myself

start:
   jsr initialize
   
   pea msg_1
   move.w #9,-(a7)
   trap #1
   addq.l #6,a7
   move.w #160,d6
msg1wait:
   jsr wait_vsync
   subq.w #1,d6
   bne.s msg1wait

   pea msg_2
   move.w #9,-(a7)
   trap #1
   addq.l #6,a7
   move.w #160,d6
msg2wait:
   jsr wait_vsync
   subq.w #1,d6
   bne.s msg2wait

   pea msg_3
   move.w #9,-(a7)
   trap #1
   addq.l #6,a7
   move.w #160,d6
msg3wait:
   jsr wait_vsync
   subq.w #1,d6
   bne.s msg3wait

   pea msg_4
   move.w #9,-(a7)
   trap #1
   addq.l #6,a7
   move.w #160,d6
msg4wait:
   jsr wait_vsync
   subq.w #1,d6
   bne.s msg4wait

   pea msg_5
   move.w #9,-(a7)
   trap #1
   addq.l #6,a7
   move.w #160,d6
msg5wait:
   jsr wait_vsync
   subq.w #1,d6
   bne.s msg5wait

   pea msg_6
   move.w #9,-(a7)
   trap #1
   addq.l #6,a7
   move.w #160,d6
msg6wait:
   jsr wait_vsync
   subq.w #1,d6
   bne.s msg6wait
   
   clr.b audioflag
   clr.b endoffile

   pea msg_7
   move.w #9,-(a7)
   trap #1
   addq.l #6,a7
   
   ; init code
   ; get current path
   move.b #$3a,audiodata1+1
   
   move.w #25,-(a7)
   trap #1
   addq.l #2,sp
   move.b d0,d1
   add.l #$41,d1
   move.b d1,audiodata1
   
   move.w d0,-(a7)
   pea audiodata1+2
   move.w #71,-(a7)
   trap #1
   addq.l #8,a7
   
   ; append videoname
   move.l #audiodata1,a0
   move.l #videoname,a1
findEndDir1:
   addq.l #1,a0   
   tst.b (a0)
   bne findEndDir1
   move.l a0,a4
appendNameLoop1:
   tst.b (a1)
   beq.s exitNameLoop1
   move.b (a1)+,(a0)+   
   bra.s appendNameLoop1
exitNameLoop1:
   
   ; open audio file
   move.w #0,-(a7)
   pea audiodata1
   move.w #61,-(a7)
   trap #1
   addq.l #8,a7
   move.w d0,videohandle
   tst.w d0
   bge.s videohandle_ok
   pea error_video
   move.w #9,-(a7)
   trap #1
   addq.l #6,a7
   jmp errorret
videohandle_ok:  
   ; append audioname
   move.l #audioname,a1
   move.l a4,a0
appendNameLoop2:
   tst.b (a1)
   beq.s exitNameLoop2
   move.b (a1)+,(a0)+   
   bra.s appendNameLoop2
exitNameLoop2:

   move.w #0,-(a7)
   pea audiodata1
   move.w #61,-(a7)
   trap #1
   addq.l #8,a7
   move.w d0,audiohandle

   tst.w d0
   bge.s audiohandle_ok
   pea error_audio
   move.w #9,-(a7)
   trap #1
   addq.l #6,a7
   jmp errorret
audiohandle_ok:  
   move.w #4,-(a7)
   trap #14
   addq.l #2,sp
   move.w d0,resolution

   move.w #123,-(a7)
   trap #2
   addq.l #2,sp

   dc.w $a00a
   
   move.w #2,-(a7)
   trap #14
   addq.l #2,sp
   move.l d0,oldphysbase

   move.w #3,-(a7)
   trap #14
   addq.l #2,sp
   move.l d0,oldlogbase

   lea screen1,a0
   move.l a0,d0
   and.l #$ffffff00,d0
   move.l d0,vramaddr

   move.l #dubword,a6
   
   move.w #32,d0
   lea oldpalette,a1
   lea $ffff8240,a0
blockCopy1:
   move.b (a0)+,(a1)+ 
   subq.w #1,d0
   tst.w d0
   bgt blockCopy1
   
   move.l $000000070,oldvbl
  
   jsr wait_vsync
   move.w #0,-(a7)
   move.l #$ffffffff,-(a7)
   move.l #$ffffffff,-(a7)
   move.w #5,-(sp)
   trap #14
   adda.l #12,sp

   move.l #screen1,d0
   clr.b d0
   clr.b $ffff820d
   lsr.l #8,d0
   move.b d0,$ffff8203
   lsr.w #8,d0
   move.b d0,$ffff8201

   move.w #$0000,$ffff8240
   move.w #$0fff,$ffff8242
   move.l #10,vsyncwait
   
   jsr wait_vsync
  
   move.l #audiodata1,d0
   and.l #$FFFFE000,d0
   move.l d0,audioptr1
   add.l #16384,d0
   move.l d0,audioptr2
   add.l #16384,d0
   move.l d0,audioptr3

   move.w #$ffff,frameskip
   ; detect NTSC or PAL
   btst #1,$ffff820a
   beq.s ntsc_mode ; ntsc
pal_mode:   
   move.w #5,frameskip
ntsc_mode:   
      
   ; load first 16K of audio
   move.l audioptr1,-(a7)
   move.l #32768,-(a7)
   move.w audiohandle,-(a7)
   move.w #63,-(a7)
   trap #1
   adda.l #12,sp

   ; load super_rle original length, discard
   move.l #superrledict,-(a7)
   move.l #8,-(a7)
   move.w videohandle,-(a7)
   move.w #63,-(a7)
   trap #1
   adda.l #12,sp

   ; load super_rlei dict 1
   move.l #superrledict,-(a7)
   move.l #768,-(a7)
   move.w videohandle,-(a7)
   move.w #63,-(a7)
   trap #1
   adda.l #12,sp

   ; load super_rlei dict 2
   move.l #superrledict+768,-(a7)
   move.l #768,-(a7)
   move.w videohandle,-(a7)
   move.w #63,-(a7)
   trap #1
   adda.l #12,sp

   ;move.l #videodata,-(a7)
   ;move.l #32768,-(a7)
   ;move.w videohandle,-(a7)
   ;move.w #63,-(a7)
   ;trap #1	
   ;adda.l #12,sp
   
   sf vsyncstat
   move.l #setvblflag,$70

   ; start playing PCM
   move.b #%10000001,$ffff8921
   move.b audioptr1+1,$ffff8903
   move.b audioptr1+2,$ffff8905
   move.b audioptr1+3,$ffff8907
   move.b audioptr2+1,$ffff890f
   move.b audioptr2+2,$ffff8911
   move.b audioptr2+3,$ffff8913
   move.b #3,$ffff8901

   clr.b audioflag
   clr.b videoflag

   move.l vramaddr,a4
   move.l #20,d7
   move.l #4000,d3
   ;move.l #videodata-1,a5
   clr.l d4
   clr.l d5
   clr.l d6
   move.l #0,a5
   jmp mainloop 

mainloop: 
   ; video code, read 2 bytes
   move.l #rlecurrent,-(a7)
   move.l #2,-(a7)
   move.w videohandle,-(a7)
   move.w #63,-(a7)
   trap #1	
   adda.l #12,sp
   
   move.b rlecurrent,d6 
   move.b rlecurrent+1,d4
   blt.s rle_short
   cmp.b #4,d4
   beq.s rle_dict1
   cmp.b #5,d4
   beq.s rle_dict2
   cmp.b #1,d4
   beq.s rle_verylong
rle_long:  
   move.b d4,d5
   bra.s rle_preloop
rle_short:
   move.l #rlecurrent+2,-(a7)
   move.l #1,-(a7)
   move.w videohandle,-(a7)
   move.w #63,-(a7)
   trap #1	
   adda.l #12,sp
   move.b d4,d5
   bra.s rle_short_direct
rle_dict2:
   move.l #superrledict+768,a2
   bra.s rle_dict  
rle_dict1:
   move.l #superrledict,a2
rle_dict:
   move.b d6,d4
   add.l d4,a2
   move.b (a2),d6
   add.w #256,a2
   move.b (a2),d5
   add.w #256,a2
   move.b (a2),rlecurrent+2
   move.b #255,d4
rle_short_direct:
   move.b d5,rlecurrent+1 
   lsr.b #4,d5
   and.w #7,d5
   bra.s rle_preloop
rle_verylong:
   move.l #rlecurrent+2,-(a7)
   move.l #2,-(a7)
   move.w videohandle,-(a7)
   move.w #63,-(a7)
   trap #1	
   adda.l #12,sp
   move.w rlecurrent+2,d5
   rol.w #8,d5
   
   
rle_preloop:
   add.w d6,d6
   and.w #511,d6
   move.w (a6,d6),d7
rle_loop:
   move.w d7,(a4)
   add.w #8,a4
   subq.w #1,d3
   bne.s rle_no_vbl
   bsr.s vblank
rle_no_vbl:
   subq.w #1,d5
   bne rle_loop
rle_postloop:
   bclr #7,d4
   beq.s rle_no_short_reset
   move.b rlecurrent+2,d6
   move.b rlecurrent+1,d5
   and.b #15,d5
   bra rle_preloop 
   
; rle_preloop:
   ; move.l #dubword,a0
   ; and.w #255,d6
   ; add.w d6,d6
   ; move.w 0(a0,d6),d7
   ; tst.b videosafeflag
   ; beq.s rle_preloop_nosafewrite
   ; move.b safestore,d0
   ; and.w #255,d0
   ; add.w d0,d0
   ; move.w 0(a0,d0),d0
   ; move.w d0,(a4)
   ; move.w d7,8(a4)
   ; add.w #16,a4
   ; subq.w #1,d5
   ; subq.w #1,d3
   ; bne.s rle_preloop_nosafewrite
   ; bsr vblank
; rle_preloop_nosafewrite:
   ; ; dualify d6
   ; move.w d7,d6
   ; ; div d5 by 2, store leftover to vsf
   ; lsr.w #1,d5
   ; scs.b videosafeflag
   ; beq.s rle_postloop	
   ; moveq.w #16,d1
; rle_loop:
   ; ; write word d6 at rlecurrent
   ; move.w d6,(a4)
   ; move.w d7,8(a4)
   ; add.w d1,a4
   ; ;addq.l #8,a4
   ; ;subq.b #1,d7
   ; ;bne.s rle_no_hbl
   ; ;move.b #20,d7
   ; ;moveq.l #160,d0
   ; subq.w #1,d3
   ; bne.s rle_no_hbl
   ; bsr.s vblank
   ; moveq.w #16,d1
; rle_no_hbl:
   ; subq.w #1,d5
   ; bne rle_loop
; rle_postloop:
   ; move.b d6,safestore
   ; bclr #7,d4
   ; beq.s rle_no_short_reset
   ; move.b rlecurrent+2,d6
   ; move.b rlecurrent+1,d5
   ; and.b #15,d5
   ; bra rle_preloop 

reached_eof:
   bset.b #0,endoffile
   clr.b $ff8901
   jmp pastaudio
rle_no_short_reset:
   btst.b #0,endoffile
   beq mainloop
   bra endofanim
   
setvblflag:
   addq.w #1,vsyncstat
   rte   
   
vblank:
   move.w #4000,d3
   ; reached end of screen
   ; reset address register
   move.l vramaddr,a4
   ;bchg.b #0,videoflag
   ;bne.s upperField
;lowerField:
   ;add.l #160,a4
;upperField:
   ; vsync timebtst.b #0,audioflag 
   ; time to check audio
   btst.b #0,audioflag
   beq.s check_submit
check_load:
   btst.b #5,$ff890b
   bne pastaudio 
   bclr.b #0,audioflag
   bchg.b #1,audioflag
   beq.s load_ptr1
load_ptr2:
   move.l audioptr2,-(a7)
   bra.s load_ptr
load_ptr1:
   move.l audioptr1,-(a7)
load_ptr:
   move.l #16384,-(a7)
   move.w audiohandle,-(a7)
   move.w #63,-(a7)
   trap #1
   adda.l #12,sp
   tst.l d0
   beq reached_eof
   bra pastaudio
check_submit:   
   btst.b #5,$ff890b
   beq pastaudio
   bset.b #0,audioflag
   bchg.b #2,audioflag
   bne.s submit_ptr1
submit_ptr2:
   move.b audioptr2+1,$ffff8903
   move.b audioptr2+2,$ffff8905
   move.b audioptr2+3,$ffff8907
   move.b audioptr3+1,$ffff890f
   move.b audioptr3+2,$ffff8911
   move.b audioptr3+3,$ffff8913   
   jmp pastaudio
submit_ptr1:
   move.b audioptr1+1,$ffff8903
   move.b audioptr1+2,$ffff8905
   move.b audioptr1+3,$ffff8907
   move.b audioptr2+1,$ffff890f
   move.b audioptr2+2,$ffff8911
   move.b audioptr2+3,$ffff8913
   ; 0x90000: load 8K audioptr2
   ; 0x91000: submit audioptr2:3
   ; 0x92000: load 8K audioptr1
   ; 0x93000: submit audioptr1:2
pastaudio: 
   ; skip one frame if PAL
   tst.w frameskip
   beq frameskip_end
   move.w vsyncwait,d0
   cmp.w vsyncstat,d0
   bhi.s vsync_frameskip_start
   move.l #10,vsyncwait
   subq.w #1,frameskip
   beq.s frameskip_start
pastskip:   
   ; wait two vsyncs
   lea vsyncstat,a0
vbl1:
   tst.w (a0)
   beq vbl1
   subq.w #1,(a0)
vbl2:
   tst.w (a0)
   beq vbl2
   subq.w #1,(a0)
vblank_ret:
   move.w #11,-(sp)
   trap #1
   addq.l #2,sp           ; escape key
   tst.w d0
   beq.s esc_nope
   move.w #1,-(sp)
   trap #1
   addq.l #2,sp
   lsr.l #8,d0
   lsr.l #8,d0
   cmp.b #1,d0 ; is escape?
   beq.s esc_eof 
esc_nope:
   rts
   
esc_eof:
   bset.b #0,endoffile
   clr.b $ff8901       
   bra esc_nope
   
vsync_frameskip_start:
   move.l #4,vsyncwait
   subq.w #1,vsyncstat
   move.w #0,frameskip   
frameskip_start:
   move.l #ghostscreen,d0
   and.l #$fffffffe,d0
   move.l d0,a4
   bchg.b #0,videoflag
   bra vblank_ret
   
frameskip_end:
   move.w #5,frameskip
   bra pastskip
   
; read_byte:
   ; addq.l #1,a5
   ; cmp.l #audiodatabeg,a5
   ; bne read_byteret
   ; move.l #videodata,a5
   ; move.l #videodata,-(a7)
   ; move.l #32768,-(a7)
   ; move.w videohandle,-(a7)
   ; move.w #63,-(a7)
   ; trap #1	
   ; adda.l #12,sp
   ; bsr audio_check
; read_byteret:
   ; move.b (a5),d0
   ; rts

endofanim:
   
   move.l audioptr1,-(a7)
   move.w #73,-(a7)
   trap #1
   addq.l #6,sp

   clr.b $ff8901

   move.w #32,d0
   lea oldpalette,a0
   lea $ffff8240,a1
blockCopy2:
   move.b (a0)+,(a1)+ 
   subq.w #1,d0
   tst.w d0
   bgt blockCopy2
   
   move.l oldvbl,$000000070
   move.w resolution,-(a7)
   move.l oldphysbase,-(a7)
   move.l oldlogbase,-(a7)
   move.w #5,-(sp)
   trap #14
   adda.l #12,sp

errorret2:
   ; close audio file
   move.w audiohandle,-(a7)
   move.w #62,-(a7)
   trap #1
   addq.l #4,a7

   move.w videohandle,-(a7)
   move.w #62,-(a7)
   trap #1
   addq.l #4,a7

   move.w #122,-(a7)
   trap #2
   addq.l #2,sp

   ;move.w   #7,-(a7)
   ;trap  #1                    
   ;addq.l   #2,a7 
   jsr   restore
   clr.l    -(a7)               
   trap  #1
   
initialize:                    
   clr.l -(a7) 
   move.w #32,-(a7)  
   trap #1     
   addq.l #6,a7   
   move.l d0,oldstack
   rts
   
restore:                       
   move.l oldstack,-(a7)
   move.w #32,-(a7)
   trap #1     
   addq.l #6,a7
   rts

wait_vsync:
   move.w #37,-(a7)
   trap #14
   addq.l #2,sp
   rts

errorret:
   move.w #7,-(a7)
   trap #1
   addq.l #2,a7
   jmp errorret2
	
section data
oldstack dc.l 0
audioname dc.b '\BADAPPLE.PCM', 0
videoname dc.b '\BADAPPLE.RLE', 0
error_audio dc.b 'Cannot open audio .PCM', 0
error_video dc.b 'Cannot open video .RLE', 0
msg_1 dc.b 13, 10, 'Bad Apple!! PV for Atari ST(e)', 13, 10, 0
msg_2 dc.b 'Progressive scan edition v1.1, StackDesign 2016', 13, 10, 0
msg_3 dc.b 'Requirements:', 13, 10, '1 MB RAM, 16 MHz CPU', 13, 10, 'STe to get audio.', 13, 10, 0
msg_4 dc.b '512 KB RAM not enough (likely) for data,', 13, 10, '8 MHz too slow for video+compression', 13, 10, 13, 10, 0
msg_5 dc.b 'Specs:', 13, 10, 'Compressed video size 5.9 MB', 13, 10, 'Uncompressed audio size 2.6 MB', 13, 10, 'Video NTSC: 30p, 160x200', 13, 10, 'Video PAL: 25p, 160x200' 
msg_5b dc.b 13, 10, 'Audio: signed 8-bit PCM @12.5KHz', 13, 10, 13, 10, 0
msg_6 dc.b 'Esc to exit mid-play', 13, 10, 13, 10, 0
msg_7 dc.b 'Searching for data files now', 13, 10, 'If disk does not respond, hit Cancel', 13, 10, 0
audiohandle ds.w 1
videohandle ds.w 1
resolution ds.w 1
oldphysbase ds.l 1
oldlogbase ds.l 1
endoffile ds.b 1
audioptr1 ds.l 1
audioptr2 ds.l 1
audioptr3 ds.l 1
vramaddr ds.l 1
buffer0000 cnop 0,8
oldpalette ds.b 32
oldvbl ds.l 1
vsyncstat ds.l 1
vsyncwait ds.l 1
frameskip ds.w 1
dubword even
dubword0 dc.w 0,3,12,15,48,51,60,63
dubword1 dc.w 192,195,204,207,240,243,252,255
dubword2 dc.w 768,771,780,783,816,819,828,831
dubword3 dc.w 960,963,972,975,1008,1011,1020,1023
dubword4 dc.w 3072,3075,3084,3087,3120,3123,3132,3135
dubword5 dc.w 3264,3267,3276,3279,3312,3315,3324,3327
dubword6 dc.w 3840,3843,3852,3855,3888,3891,3900,3903
dubword7 dc.w 4032,4035,4044,4047,4080,4083,4092,4095
dubword8 dc.w 12288,12291,12300,12303,12336,12339,12348,12351
dubword9 dc.w 12480,12483,12492,12495,12528,12531,12540,12543
dubword10 dc.w 13056,13059,13068,13071,13104,13107,13116,13119
dubword11 dc.w 13248,13251,13260,13263,13296,13299,13308,13311
dubword12 dc.w 15360,15363,15372,15375,15408,15411,15420,15423
dubword13 dc.w 15552,15555,15564,15567,15600,15603,15612,15615
dubword14 dc.w 16128,16131,16140,16143,16176,16179,16188,16191
dubword15 dc.w 16320,16323,16332,16335,16368,16371,16380,16383
dubword16 dc.w 49152,49155,49164,49167,49200,49203,49212,49215
dubword17 dc.w 49344,49347,49356,49359,49392,49395,49404,49407
dubword18 dc.w 49920,49923,49932,49935,49968,49971,49980,49983
dubword19 dc.w 50112,50115,50124,50127,50160,50163,50172,50175
dubword20 dc.w 52224,52227,52236,52239,52272,52275,52284,52287
dubword21 dc.w 52416,52419,52428,52431,52464,52467,52476,52479
dubword22 dc.w 52992,52995,53004,53007,53040,53043,53052,53055
dubword23 dc.w 53184,53187,53196,53199,53232,53235,53244,53247
dubword24 dc.w 61440,61443,61452,61455,61488,61491,61500,61503
dubword25 dc.w 61632,61635,61644,61647,61680,61683,61692,61695
dubword26 dc.w 62208,62211,62220,62223,62256,62259,62268,62271
dubword27 dc.w 62400,62403,62412,62415,62448,62451,62460,62463
dubword28 dc.w 64512,64515,64524,64527,64560,64563,64572,64575
dubword29 dc.w 64704,64707,64716,64719,64752,64755,64764,64767
dubword30 dc.w 65280,65283,65292,65295,65328,65331,65340,65343
dubword31 dc.w 65472,65475,65484,65487,65520,65523,65532,65535

section bss
buffer0001 cnop 0,256
superrledict ds.b 1536
emptyspace ds.b 256
clearbuffer ds.b 512
screen1 ds.b 32768
ghostscreen ds.b 32768
;videodata ds.b 32768
audiodatabeg ds.b 16384
audiodata1 ds.b 16384
audiodata2 ds.b 16384
rlecurrent ds.b 4
audioflag ds.b 1
videoflag ds.b 1
videosafeflag ds.b 1
emptyspace2 ds.b 1
safestore ds.b 1