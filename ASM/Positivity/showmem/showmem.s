
 opt o+
 
;######## MACROS ########
;IN   \1.w=x
;     \2.w=y
;OUT  \1.w=mask for pixel at (x;y)
;     \2.w=offset to pixel at (x;y)
;     \3.l and \4.w killed
PIXEL MACRO
  lsl.w     #5,\2       ;\2=y*32
  move.w    \2,\3       ;\3=y*32
  lsl.w     #2,\2       ;\2=y*128, slower but smaller than add.l \2,\2:add.l \2,\2
  add.w     \3,\2       ;\2=y*160
  move.w    \1,\4
  moveq.l   #15,\3
  and.w     \3,\4       ;\4=x mod(16)
  sub.w     \4,\1       ;\1=x-x mod(16)
  lsr.w     #2,\1       ;\1=(x-x mod(16))/4
  add.w     \1,\2       ;\2=y*160+(x-x mod(16))/4
  sub.w     \4,\3       ;\3=15-x mod(16)
  eor.w     \1,\1
  bset.l    \3,\1       ;\1=1<<(x mod(16))
 ENDM  

program_start 
;SWITCH TO SUPERVISOR
  clr.l     -(sp)
  move.w    #32,-(sp)
  trap      #1
  addq.l    #2,sp
  lea       OldConfig(pc),a6
;STOP MOUSE  
  dc.w      $a00a
  move.b    #18,$fffffc02.w
;SAVE RESOLUTION AND CHANGE TO MEDIUM RESOLUTION (CLEARS SCREEN)
  move.w    #4,-(sp)            ;Get Resolution
  trap      #14
;  addq.l    #2,sp
  move.w    d0,(a6)+
  move.w    #1,-(sp)            ;New resolution=1=medium
  moveq.l   #-1,d7
  move.l    d7,-(sp)            ;Don't change physbase
  move.l    d7,-(sp)            ;Don't change logbase
  move.w    #5,-(sp)            ;SetScreen
  trap      #14
  add.l     #2+12,sp
;SAVE PALETTE
  bsr       SwapColors

;a6=@Text=@progbase

;DRAW TEXT
  lea       program_end(pc),a2
  lea       program_start(pc),a3
  move.l    a3,d0               ;d0=program_start
  move.l    a6,a0
  bsr       LongwordToString
  move.l    $432.w,d0           ;d0=membot
  add.w     #membot-progbase-8,a0
;  lea       membot(pc),a0
  bsr       LongwordToString
  move.l    $436.w,d0           ;d0=memtop
  add.w     #memtop-membot-8,a0
;  lea       memtop(pc),a0
  bsr       LongwordToString
  move.l    $42e.w,d0           ;d0=phystop
  move.l    d0,d1
  swap.w    d1
  move.w    d1,a4               ;a4=NbBytesPerPixel
  add.w     #phystop-memtop-8,a0
;  lea       phystop(pc),a0
  bsr       LongwordToString
  move.l    a6,-(sp)            ;Draw Text
  move.w    #9,-(sp)
  trap      #1
  addq.l    #6,sp

;SHOW MEM ON A 256*128 area
;a2=program_end
;a3=program_start
;a4=NbBytesPerPixel
ShowMem
  move.l    $44e.w,a6           ;a6=@vram
  add.w     #72*160,a6          ;72 lines below
  moveq.l   #0,d7               ;d7=y
  move.l    d7,a5               ;a5=@toshow
ShowMem_y  
  moveq.w   #0,d6               ;d6=x
ShowMem_x
  move.w    d6,d0               ;d0=x
  move.w    d7,d1               ;d1=y
  PIXEL     d0,d1,d2,d3         ;d0=mask | d1=offset
  cmp.l     a3,a5
  blt.s     ShowMem_NotInProgram
  cmp.l     a2,a5
  bgt.s     ShowMem_NotInProgram
  eor.w     d0,2(a6,d1.w)
ShowMem_NotInProgram
  eor.w     d0,2(a6,d1.w)  
  moveq.l   #0,d5
  move.w    a4,d4               ;look NbBytesPerPixel pixels
ShowMem_CountSetBytes
  or.b      (a5)+,d5
  subq.w    #1,d4
  bne.s     ShowMem_CountSetBytes
  cmp.b     #0,d5
  beq.s     ShowMem_NextPixel
  or.w      d0,(a6,d1.w)
ShowMem_NextPixel
  addq.w    #1,d6               ;x+=1
  cmp.w     #512,d6
  bne.s     ShowMem_x
  addq.w    #1,d7               ;y+=1
  cmp.w     #128,d7
  bne.s     ShowMem_y
  
Wait
  cmpi.b    #$39,$fffffc02.w  ;Wait for any key
  bne.s     Wait
  
;RESTORE RESOLUTION AND @VRAM  
  lea       OldConfig(pc),a6
  move.w    (a6)+,-(sp)         ;old resolution
  moveq.l   #-1,d7
  move.l    d7,-(sp)            ;Don't change physbase
  move.l    d7,-(sp)            ;Don't change logbase
  move.w    #5,-(sp)            ;SetScreen
  trap      #14
  add.l     #12,sp
;RESTORE PALETTE
  bsr.s     SwapColors
;RESTORE MOUSE
  move.b    #8,$fffffc02.w
  dc.w      $a009
;TERMINATE
  clr.w     -(sp)
  trap      #1

  
;IN  d0.l=longword
;    a0.l=where to convert
;OUT a0 points 8 bytes (=ascii chars) after
;    d0-d2 killed
LongwordToString
  moveq.w   #7,d1
LongwordToString_Loop  
  rol.l     #4,d0
  moveq.l   #$f,d2
  and.b     d0,d2
  add.b     #48,d2            ;add "0"
  cmp.b     #58,d2           ;was bigger than 10?
  blt.s     LongwordToString_Print
  addq.b    #7,d2  
LongwordToString_Print
  move.b    d2,(a0)+
 dbra d1,LongwordToString_Loop  
  rts    

;IN  a6.l=adress of 4 words containing colors
;OUT a6 points after the 4 words
;    d0.l, d1.l, a0.l modified
SwapColors
  move.w    #$8240,a0
  moveq.l   #1,d1
SwapColors_Loop
  move.l    (a0),d0
  move.l    (a6),(a0)+
  move.l    d0,(a6)+
 dbra d1,SwapColors_Loop
  rts
  
OldConfig   
  dc.w 0
Colors
 dc.w $777 ;00 in program (empty)
 dc.w $700 ;01 in program (full)
 dc.w $555 ;10 empty
 dc.w $000 ;11 full

Text
progbase  
  dc.b 32,32,32,32,32,32,32,32
  dc.b " = prog",$d,$a
membot  
  dc.b 32,32,32,32,32,32,32,32
  dc.b " = $432 (_membot)",$d,$a
memtop  
  dc.b 32,32,32,32,32,32,32,32
  dc.b " = $436 (_memtop)",$d,$a
phystop  
  dc.b 32,32,32,32,32,32,32,32
  dc.b " = $42e (phystop)",$d,$a
  dc.b $0
    
  ;1234567890123456789012345678901234567890
program_end   
