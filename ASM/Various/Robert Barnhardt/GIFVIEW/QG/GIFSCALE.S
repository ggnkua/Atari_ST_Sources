;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;
;=;                             GIFscale                              ;=;
;=;===================================================================;=;
;=;      A very fast GIF viewer that supports greyscaled viewing      ;=;
;=;  of GIF images, including larger-than-screen scrolling and Degas  ;=;
;=;                         PI1 screen saves.                         ;=;
;=;===================================================================;=;
;=;   Written in November 1990 by Robert Barnhardt & Robert Steger.   ;=;
;=;                (C) 1990 Brain~Waves Freeware Group                ;=;
;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;
                     text

GS_ResizeMemory      move.l   4(sp),a2
                     move.l   $c(a2),d0
                     add.l    $14(a2),d0
                     add.l    $1c(a2),d0
                     add.l    #$100,d0
                     move.l   d0,-(sp)
                     move.l   a2,-(sp)
                     clr.w    -(sp)
                     move.w   #$4a,-(sp)
                     trap     #1
                     lea      $c(sp),sp

GS_ReadTTP           move.b   #'\',BFS_Pathfudge
                     lea      $80(a2),a2
                     lea      BFS_Pathspec,a1
                     move.b   (a2)+,d0
GS_RT_Loop           move.b   (a2)+,(a1)+
                     dbra     d0,GS_RT_Loop

GS_SaveRez           move.w   #$4,-(sp)
                     trap     #14
                     addq.l   #2,sp
                     move.w   d0,ST_SaveRez
                     cmpi.b   #2,d0
                     bne.s    GS_SavePalette
                     clr.w    -(sp)
                     trap     #1
GS_SavePalette       move.w   #15,d7
                     lea      ST_SavePalette+32,a6
GS_SP_1              move.w   #-1,-(sp)
                     move.w   d7,-(sp)
                     move.w   #$7,-(sp)
                     trap     #14
                     addq.l   #6,sp
                     move.w   d0,-(a6)
                     dbra     d7,GS_SP_1
GS_SaveDTA           move.w   #$2f,-(sp)
                     trap     #1
                     addq.l   #2,sp
                     move.l   d0,ST_DTASave

GS_NewRez            clr.w    -(sp)
                     pea      -1
                     pea      -1
                     move.w   #$5,-(sp)
                     trap     #14
                     lea      $c(sp),sp
GS_NewPalette        pea      ST_PureGrey
                     move.w   #$6,-(sp)
                     trap     #14
                     addq.l   #6,sp
GS_NewDTA            pea      ST_DTA
                     move.w   #$1a,-(sp)
                     trap     #1
                     addq.l   #6,sp

GS_FindScreen        move.w   #$3,-(sp)
                     trap     #14
                     addq.l   #2,sp
                     move.l   d0,ST_Screen

GS_ShowTitleCheck    move.b   BFS_Pathspec,d0
                     sub.b    #65,d0
                     cmpi.b   #':',BFS_Pathspec+1
                     beq.s    GS_STC_1
                     move.w   #$19,-(sp)
                     trap     #1
                     addq.l   #2,sp
GS_STC_1             cmpi.b   #1,d0
                     bgt.s    GS_FindFirstFile
                     pea      ST_TitleScreen
                     move.w   #$9,-(sp)
                     trap     #1
                     addq.l   #6,sp
                     move.b   #1,ST_TitleFlag

GS_FindFirstFile     clr.w    -(sp)
                     pea      BFS_Pathspec
                     move.w   #$4e,-(sp)
                     trap     #1
                     lea      8(sp),sp
                     tst.w    d0
                     bmi      GS_AllDone
                     lea      BFS_Filenames,a6
                     move.l   a6,BFS_FileIndex
GS_StoreName         lea      ST_DTA+30,a5
GS_SN_1              move.b   (a5)+,(a6)+
                     bne.s    GS_SN_1
                     addq.w   #1,BFS_FileCount
GS_FindNextName      move.w   #$4f,-(sp)
                     trap     #1
                     addq.l   #2,sp
                     tst.w    d0
                     bpl.s    GS_StoreName
GS_FindPathEnd       lea      BFS_Pathspec+128,a0
GS_FPE_1             cmpi.b   #'\',-(a0)
                     bne.s    GS_FPE_1
                     addq.l   #1,a0
                     move.l   a0,BFS_FnamePtr
GS_RestoreDTA        move.l   ST_DTASave,-(sp)
                     move.w   #$1a,-(sp)
                     trap     #1
                     addq.l   #6,sp

GS_OpenNextFile      move.l   BFS_FileIndex,a0
                     move.l   BFS_FnamePtr,a1
GS_ONF_1             move.b   (a0)+,(a1)+
                     bne.s    GS_ONF_1
                     move.l   a0,BFS_FileIndex
                     clr.w    -(sp)
                     pea      BFS_Pathspec
                     move.w   #$3d,-(sp)
                     trap     #1
                     lea      8(sp),sp
                     move.w   d0,BFS_FileDescriptor

GS_MakeSaveName      move.l   BFS_FnamePtr,a0
                     move.w   #5,d0
GS_MSN_SS_1          tst.b    (a0)
                     beq.s    GS_MSN_Overlay
                     cmpi.b   #'.',(a0)
                     beq.s    GS_MSN_Overlay
                     addq.l   #1,a0
                     dbra     d0,GS_MSN_SS_1
GS_MSN_Overlay       lea      ST_SaveOverlay,a1
GS_MSN_O_1           move.b   (a1)+,(a0)+
                     bne.s    GS_MSN_O_1
                     subq.l   #6,a0
                     move.l   a0,ST_SaveNumAddr

GS_ReadSDescriptor   pea      GIF_ScreenDescriptor
                     move.l   #13,-(sp)
                     move.w   BFS_FileDescriptor,-(sp)
                     move.w   #$3f,-(sp)
                     trap     #1
                     lea      $c(sp),sp
                     tst.l    d0
                     ble      GS_DoneGIF

GS_ReadGPalette      move.b   GIF_ScreenBits,d0
                     and.b    #7,d0
                     addq.b   #1,d0
                     moveq    #1,d1
                     lsl.w    d0,d1
                     move.w   d1,GIF_ColourCount
                     mulu     #3,d1
                     ext.l    d1
                     pea      GIF_GlobalPalette
                     move.l   d1,-(sp)
                     move.w   BFS_FileDescriptor,-(sp)
                     move.w   #$3f,-(sp)
                     trap     #1
                     lea      $c(sp),sp
                     tst.l    d0
                     ble      GS_DoneGIF

GS_GreyMap           lea      GIF_GlobalPalette,a0
                     lea      ST_GlobalMap,a1
                     move.w   GIF_ColourCount,d2
                     subq.l   #1,d2
GS_GM_Loop           clr.w    d0
                     clr.l    d1
                     move.b   (a0)+,d0
                     mulu     #30,d0
                     move.w   d0,d1
                     clr.w    d0
                     move.b   (a0)+,d0
                     mulu     #59,d0
                     add.w    d0,d1
                     clr.w    d0
                     move.b   (a0)+,d0
                     mulu     #11,d0
                     add.w    d0,d1
                     divu     #1600,d1
                     move.b   d1,(a1)+
                     dbra     d2,GS_GM_Loop

GS_ReadIDescriptor   pea      GIF_ImageDescriptor
                     move.l   #11,-(sp)
                     move.w   BFS_FileDescriptor,-(sp)
                     move.w   #$3f,-(sp)
                     trap     #1
                     lea      $c(sp),sp
                     tst.l    d0
                     ble      GS_DoneGIF
GS_RI_FixHW          move.b   GIF_ImageHeight+1,d0
                     lsl.w    #8,d0
                     move.b   GIF_ImageHeight,d0
                     move.w   d0,ST_ImageHeight
                     move.b   GIF_ImageWidth+1,d0
                     lsl.w    #8,d0
                     move.b   GIF_ImageWidth,d0
                     move.w   d0,ST_ImageWidth
                     move.l   d0,d5
                     swap     d5

GS_AllocateMemory    lsl.w    #4,d0
                     tst.b    d0
                     beq.s    GS_AM_Even
                     clr.b    d0
                     add.w    #$100,d0
GS_AM_Even           lsr.w    #5,d0
                     move.w   d0,d4
                     clr.l    d1
                     move.w   ST_ImageHeight,d1
                     mulu     d0,d1
                     move.l   d1,-(sp)
                     move.w   #$48,-(sp)
                     trap     #1
                     addq.l   #6,sp
                     tst.l    d0
                     beq      GS_DoneGIF
                     move.l   d0,ST_ScreenBuffer
                     move.l   d0,a4

GS_AllocateBuffer    move.l   #-$1,-(sp)
                     move.w   #$48,-(sp)
                     trap     #1
                     addq.l   #6,sp
                     move.l   d0,BFS_FileBufferSize
                     move.l   d0,-(sp)
                     move.w   #$48,-(sp)
                     trap     #1
                     addq.l   #6,sp
                     tst.l    d0
                     beq      GS_DoneGIF
                     move.l   d0,BFS_FileBuffer

GS_InterlaceSetup    move.w   ST_ImageHeight,ST_HeightCount
                     move.w   d4,ST_WordWidth
                     btst     #6,GIF_ImageBits
                     beq.s    GS_LZWSetup
                     move.w   d4,d0
                     clr.w    GIF_InterlaceStart
                     move.w   d0,GIF_InterlaceStart+6
                     move.w   d0,GIF_InterlaceSkip+6
                     add.w    d0,d0
                     move.w   d0,GIF_InterlaceStart+4
                     add.w    d4,d0
                     move.w   d0,GIF_InterlaceSkip+4
                     add.w    d4,d0
                     move.w   d0,GIF_InterlaceStart+2
                     add.w    d0,d0
                     sub.w    d4,d0
                     move.w   d0,GIF_InterlaceSkip+2
                     move.w   d0,GIF_InterlaceSkip
                     move.l   #GIF_InterlaceStart,GIF_IlacePointer

GS_LZWSetup          sub.l    a6,a6
                     sub.l    a5,a5
                     move.b   #16,ST_BitCount
                     move.b   LZW_CodeSize,d0
                     moveq    #1,d1
                     addq.b   #1,d0
                     lsl.w    d0,d1
                     move.w   d1,LZW_ClearCode
                     addq.l   #2,d1
                     move.w   d1,LZW_EOICode
                     addq.l   #2,d1
                     move.w   d1,LZW_FirstCode
                     subq.w   #6,d1
                     lea      LZW_Prefices,a0
                     lea      LZW_Suffices,a1
                     lea      LZW_Transform,a2
                     lea      ST_GlobalMap,a3
GS_LS_Loop           move.w   #-1,(a0,d1.w)
                     move.w   d1,(a1,d1.w)
                     subq.w   #2,d1
                     bge.s    GS_LS_Loop
                     bsr      BFS_ByteRead
                     clr.w    d6
                     move.b   d0,d6
                     clr.l    d4

GS_LzwLoop           swap     d7
                     move.b   LZW_CodeSize,d7
                     addq.l   #1,d7
                     move.l   #$fff00000,d0
                     rol.l    d7,d0
                     lsl.l    #1,d0
                     swap     d6
                     move.w   d0,d6
                     swap     d6
                     swap     d7
                     move.w   LZW_FirstCode,d7
                     bsr      UBR_GetCode
                     clr.l    d3
                     move.w   d0,d3
                     cmp.w    LZW_ClearCode,d3
                     beq.s    GS_LzwLoop
                     move.w   d3,(a2)
                     swap     d3
                     swap     d5
                     clr.w    d1
                     clr.w    d2
                     subq.l   #2,d7
                     bra      GS_Output
GS_GIFLoop           bsr      UBR_GetCode
                     move.w   d0,d3
                     cmp.w    LZW_ClearCode,d3
                     beq.s    GS_LZWLoop
                     cmp.w    LZW_EOICode,d3
                     beq      GS_DisplayGIF
                     swap     d5
                     cmp.w    d7,d3
                     beq.s    GS_Weird
GS_Normal            move.w   d3,d0
                     bsr      GS_TranslateCode
                     move.w   #2,d1
                     swap     d3
                     move.w   d3,(a0,d7.w)
                     move.w   (a2,d2.w),(a1,d7.w)
                     bra.s    GS_Output
GS_Weird             swap     d3
                     move.w   d3,d0
                     bsr      GS_TranslateCode
                     move.w   d3,(a0,d7.w)
                     move.w   (a2,d2.w),(a1,d7.w)
                     move.w   (a2,d2.w),(a2)
                     clr.w    d1
GS_Output            move.w   (a2,d2.w),d0
                     lsr.w    #1,d0
                     move.b   (a3,d0.w),d0
                     lsr.b    #1,d0
                     roxl     (a4)
                     lsr.b    #1,d0
                     roxl     2(a4)
                     lsr.b    #1,d0
                     roxl     4(a4)
                     lsr.b    #1,d0
                     roxl     6(a4)
                     subq.b   #1,ST_BitCount
                     bne.s    GS_CheckWidth
                     lea      8(a4),a4
                     move.b   #16,ST_BitCount
GS_CheckWidth        subq.w   #1,d5
                     bne      GS_WithinWord
                     move.w   ST_ImageWidth,d5
                     move.b   ST_BitCount,d0
                     and.b    #15,d0
                     tst.b    d0
                     beq.s    GS_CheckInterlace
                     xor.b    #15,d0
GS_CW_Loop           lsl      (a4)
                     lsl      2(a4)
                     lsl      4(a4)
                     lsl      6(a4)
                     dbra     d0,GS_CW_Loop
                     lea      8(a4),a4
                     move.b   #16,ST_BitCount
GS_CheckInterlace    btst     #6,GIF_ImageBits
                     beq.s    GS_WithinWord
                     move.l   a7,ST_USPSave
                     move.l   GIF_IlacePointer,a7
                     clr.l    d0
                     move.w   8(a7),d0
                     add.l    d0,a4
                     move.w   24(a7),d0
                     sub.w    d0,ST_HeightCount
                     bgt.s    GS_ResetUSP
                     move.l   ST_ScreenBuffer,a4
                     move.w   2(a7),d0
                     add.w    d0,a4
                     move.w   18(a7),d0
                     neg.w    d0
                     add.w    ST_ImageHeight,d0
                     move.w   d0,ST_HeightCount
                     addq.l   #2,GIF_IlacePointer
GS_ResetUSP          move.l   ST_USPSave,a7
GS_WithinWord        subq.w   #2,d2
                     cmp.w    d1,d2
                     bge      GS_Output
                     addq.w   #2,d7
                     swap     d5
                     bra      GS_GIFLoop

GS_TranslateCode     move.w   #2,d2
                     move.w   (a1,d0.w),(a2,d2.w)
GS_TC_Loop           cmp.w    LZW_FirstCode,d0
                     blt.s    GS_TC_Done
                     move.w   (a0,d0.w),d0
                     addq.w   #2,d2
                     move.w   (a1,d0.w),(a2,d2.w)
                     bra.s    GS_TC_Loop
GS_TC_Done           rts

;========================================================================;
;==          GIFview3 Display Routines: Splat and ScrollCheck          ==;
;========================================================================;
GS_DisplayGIF        move.w   #-1,-(sp)
                     move.w   #$b,-(sp)
                     trap     #13
                     addq.l   #4,sp
                     btst     #3,d0
                     bne.s    GS_DisplayGIF
GS_ClearScreen       move.l   ST_Screen,a0
                     move.w   #3999,d0
GS_ClearLoop         clr.l    (a0)+
                     clr.l    (a0)+
                     dbra     d0,GS_ClearLoop
GS_MovePicture       move.w   #200,d2
                     cmp.w    ST_ImageHeight,d2
                     ble.s    GS_MP_HeightOK
                     move.w   ST_ImageHeight,d2
GS_MP_HeightOK       move.w   #160,d3
                     cmp.w    ST_WordWidth,d3
                     ble.s    GS_MP_WidthOK
                     move.w   ST_WordWidth,d3
GS_MP_WidthOK        lsr.w    #3,d3
                     subq.w   #1,d3
                     subq.w   #1,d2
                     clr.w    d6
                     clr.l    d7

GS_SplatPicture      move.l   ST_ScreenBuffer,a0
                     move.l   ST_Screen,a1
                     clr.b    ST_TitleFlag
                     clr.l    d0
                     move.w   ST_WordWidth,d0
                     mulu     d7,d0
                     add.l    d0,a0
                     move.w   d2,d0
GS_SP_HLoop          move.w   d3,d1
                     clr.w    d4
                     move.w   d6,d5
GS_SP_WLoop          move.l   (a0,d5.w),(a1,d4.w)
                     move.l   4(a0,d5.w),4(a1,d4.w)
                     add.w    #8,d4
                     add.w    #8,d5
                     dbra     d1,GS_SP_WLoop
                     add.w    ST_WordWidth,a0
                     add.w    #160,a1
                     dbra     d0,GS_SP_HLoop

GS_KeyCheck          move.w   #$2,-(sp)
                     move.w   #$2,-(sp)
                     trap     #13
                     addq.l   #4,sp
GS_CheckPalette      cmpi.b   #$30,d0
                     blt.s    GS_CheckSave
                     cmpi.b   #$36,d0
                     bgt.s    GS_CheckSave
                     and.l    #$f,d0
                     lsl.w    #5,d0
                     add.l    #ST_Palettes,d0
                     move.l   d0,ST_PalettePointer
                     move.l   d0,-(sp)
                     move.w   #$6,-(sp)
                     trap     #14
                     addq.l   #6,sp
                     bra      GS_KeyCheck
GS_CheckSave         cmpi.b   #115,d0
                     bne.s    GS_CheckExit
                     movem.l  d0-d7/a0-a6,-(sp)
                     move.l   ST_SaveNumAddr,a0
                     addq.b   #1,(a0)
                     clr.w    -(sp)
                     pea      BFS_Pathspec
                     move.w   #$3c,-(sp)
                     trap     #1
                     lea      8(sp),sp
                     move.w   d0,d7
                     pea      ST_DegasRez
                     move.l   #2,-(sp)
                     move.w   d7,-(sp)
                     move.w   #$40,-(sp)
                     trap     #1
                     lea      $c(sp),sp
                     move.l   ST_PalettePointer,-(sp)
                     move.l   #32,-(sp)
                     move.w   d7,-(sp)
                     move.w   #$40,-(sp)
                     trap     #1
                     lea      $c(sp),sp
                     move.l   ST_Screen,-(sp)
                     move.l   #32000,-(sp)
                     move.w   d7,-(sp)
                     move.w   #$40,-(sp)
                     trap     #1
                     lea      $c(sp),sp
                     move.w   d7,-(sp)
                     move.w   #$3e,-(sp)
                     trap     #1
                     addq.l   #4,sp
                     movem.l  (sp)+,d0-d7/a0-a6
                     bra      GS_KeyCheck
GS_CheckExit         swap     d0
                     cmpi.b   #28,d0
                     beq      GS_DoneGIF
                     cmpi.b   #57,d0
                     beq      GS_DoneGIF
                     cmpi.b   #114,d0
                     beq      GS_DoneGIF
                     cmpi.b   #97,d0
                     bne.s    GS_CheckRight
                     move.w   #1,BFS_FileCount
                     bra      GS_DoneGIF
GS_CheckRight        cmpi.b   #77,d0
                     bne.s    GS_CheckLeft
                     move.w   d6,d0
                     add.w    #160,d0
                     cmp.w    ST_WordWidth,d0
                     bge      GS_KeyCheck
                     add.w    #8,d6
                     bra      GS_SplatPicture
GS_CheckLeft         cmpi.b   #75,d0
                     bne.s    GS_CheckDown
                     tst.w    d6
                     beq      GS_KeyCheck
                     sub.w    #8,d6
                     bra      GS_SplatPicture
GS_CheckDown         cmpi.b   #80,d0
                     bne.s    GS_CheckUp
                     move.w   d7,d0
                     add.w    #200,d0
                     sub.w    ST_ImageHeight,d0
                     bge      GS_KeyCheck
                     neg.w    d0
                     cmpi.w   #16,d0
                     bge.s    GS_CD_1
                     add.w    d0,d7
                     bra      GS_SplatPicture
GS_CD_1              add.w    #16,d7
                     bra      GS_SplatPicture
GS_CheckUp           cmpi.b   #72,d0
                     bne      GS_KeyCheck
                     tst.w    d7
                     beq      GS_KeyCheck
                     sub.w    #16,d7
                     bge.s    GS_CU_1
                     clr.w    d7
GS_CU_1              bra      GS_SplatPicture

GS_DoneGIF           move.l   ST_ScreenBuffer,-(sp)
                     move.w   #$49,-(sp)
                     trap     #1
                     addq.l   #6,sp
                     move.l   BFS_FileBuffer,-(sp)
                     move.w   #$49,-(sp)
                     trap     #1
                     addq.l   #6,sp
                     move.w   BFS_FileDescriptor,-(sp)
                     move.w   #$3e,-(sp)
                     trap     #1
                     addq.l   #4,sp
                     subq.w   #1,BFS_FileCount
                     bne      GS_OpenNextFile

GS_AllDone           pea      ST_SavePalette
                     move.w   #$6,-(sp)
                     trap     #14
                     addq.l   #6,sp
                     move.w   ST_SaveRez,-(sp)
                     pea      -1
                     pea      -1
                     move.w   #$5,-(sp)
                     trap     #14
                     lea      $c(sp),sp
                     clr.w    -(sp)
                     trap     #1

;========================================================================;
;==          GIFview2 Subroutines: Buffered Byte-Read Routine          ==;
;========================================================================;
BFS_ByteRead         cmpa.l   a5,a6
                     bne.s    BFS_BR_Done
                     movem.l  d1-d2/a0-a2,-(sp)
                     move.l   BFS_FileBuffer,-(sp)
                     move.l   BFS_FileBufferSize,-(sp)
                     move.w   BFS_FileDescriptor,-(sp)
                     move.w   #$3f,-(sp)
                     trap     #1
                     lea      $c(sp),sp
                     movem.l  (sp)+,d1-d2/a0-a2
                     move.l   BFS_FileBuffer,a5
                     move.l   a5,a6
                     add.l    d0,a6
                     tst.l    d0
                     bne.s    BFS_BR_Done
                     moveq    #-1,d0
                     rts
BFS_BR_Done          clr.l    d0
                     move.b   (a5)+,d0
                     rts

UBR_GetCode          swap     d7
UBR_CzechBitCount    cmp.b    d7,d5
                     bgt.s    UBR_SnatchBits
                     bsr      BFS_ByteRead
                     tst.l    d0
                     blt.s    FuckingEndOfStream
                     subq.w   #1,d6
                     bge.s    UBR_WithinBlock
                     tst.b    d0
                     beq.s    FuckingEndOfStream
                     move.w   d0,d6
                     bsr      BFS_ByteRead
                     tst.l    d0
                     blt.s    FuckingEndOfStream
                     subq.w   #1,d6
UBR_WithinBlock      lsl.l    d5,d0
                     add.l    d0,d4
                     add.b    #8,d5
                     bra.s    UBR_CzechBitCount
UBR_SnatchBits       swap     d6
                     move.w   d4,d0
                     lsr.l    d7,d4
                     add.w    d0,d0
                     and.w    d6,d0
                     sub.b    d7,d5
                     swap     d7
                     cmp.w    d6,d7
                     bne.s    UBR_Done
UBR_HouseKeeping     swap     d7
                     cmpi.b   #12,d7
                     beq.s    UBR_HK_Done
                     addq.b   #1,d7
                     add.w    d6,d6
                     bset     #1,d6
UBR_HK_Done          swap     d7
UBR_Done             swap     d6
                     rts

FuckingEndOfStream   addq.l   #4,sp
                     bra      GS_DisplayGIF

                     data
;========================================================================;
;==                  GIFview3 DATA: ST/Subroutines                     ==;
;========================================================================;
ST_TitleScreen       dc.b     27,"E",27,"f",27,"b",15,27,"c",2
                     dc.b     "==============  GIFscale  =============="
                     dc.b     13,10,"==  ",27,"b",10
                     dc.b     189,"1990 Brain~Waves Freeware Group"
                     dc.b     27,"b",15,"  ==",13,10,"==  ",27,"b",10
                     dc.b     "Robert Barnhardt / Robert Steger"
                     dc.b     27,"b",15,"  ==",13,10
                     dc.b     "========================================"
                     dc.b     13,10,10,27,"b",10
                     dc.b     "             Active Keys...             ",13,10
                     dc.b     "  ALT    Keeps this screen up           ",13,10
                     dc.b     "   0     Regular (pure grey) palette    ",13,10
                     dc.b     "  1-6    Pseudogrey (tinted) palettes   ",13,10
                     dc.b     "   S     Save screen (Degas format)     ",13,10
                     dc.b     " ARROWS  Scroll picture (if applicable) ",13,10
                     dc.b     "                                        ",13,10
                     dc.b     " SPACE, ENTER, or RETURN for next GIF.  ",13,10
                     dc.b     "          UNDO or ESC to exit.          ",13,10
                     dc.b     27,66,15,27,67,0
                     align
ST_Palettes:
ST_PureGrey          dc.w     $000,$000,$111,$111,$222,$222,$333,$333
                     dc.w     $444,$444,$555,$555,$666,$666,$777,$777
ST_Reddish           dc.w     $000,$100,$111,$211,$222,$322,$333,$433
                     dc.w     $444,$544,$555,$655,$666,$766,$777,$777
ST_Greenish          dc.w     $000,$010,$111,$121,$222,$232,$333,$343
                     dc.w     $444,$454,$555,$565,$666,$676,$777,$777
ST_Blueish           dc.w     $000,$001,$111,$112,$222,$223,$333,$334
                     dc.w     $444,$445,$555,$556,$666,$667,$777,$777
ST_Yellowish         dc.w     $000,$110,$111,$221,$222,$332,$333,$443
                     dc.w     $444,$554,$555,$665,$666,$776,$777,$777
ST_Purplish          dc.w     $000,$101,$111,$212,$222,$323,$333,$434
                     dc.w     $444,$545,$555,$656,$666,$767,$777,$777
ST_Cyanish           dc.w     $000,$011,$111,$122,$222,$233,$333,$344
                     dc.w     $444,$455,$555,$566,$666,$677,$777,$777
ST_PalettePointer    dc.l     ST_PureGrey
ST_SaveOverlay       dc.b     "_0.PI1",0
ST_TitleFlag         dc.b     0
ST_DegasRez          dc.w     0

GIF_InterlaceStart   ds.w     4
GIF_InterlaceSkip    ds.w     4
GIF_IStart_2         dc.w     0,4,2,1
GIF_ISkip_2          dc.w     8,8,4,2

                     bss
;========================================================================;
;==                  GIFview3 BSS: ST/Subroutines                      ==;
;========================================================================;
ST_GlobalMap         ds.b     256
ST_SaveRez           ds.w     1
ST_SavePalette       ds.w     16
ST_USPSave           ds.l     1
ST_Screen            ds.l     1
ST_ScreenBuffer      ds.l     1
ST_SaveNumAddr       ds.l     1
ST_DTASave           ds.l     1
ST_DTAnamePtr        ds.l     1
ST_ImageWidth        ds.w     1
ST_ImageHeight       ds.w     1
ST_HeightCount       ds.w     1
ST_WordWidth         ds.w     1
ST_DTA               ds.b     44
ST_BitCount          ds.b     1

BFS_Pathfudge        ds.b     1
BFS_Pathspec         ds.b     128
BFS_Filenames        ds.b     2048
BFS_FnamePtr         ds.l     1
BFS_FileIndex        ds.l     1
BFS_FileCount        ds.w     1
BFS_FileDescriptor   ds.w     1
BFS_FileBufferSize   ds.l     1
BFS_FileBuffer       ds.l     1
;========================================================================;
;==                    GIFview3 BSS: LZW-Specific                      ==;
;========================================================================;
LZW_Prefices         ds.w     4096
LZW_Suffices         ds.w     4096
LZW_Transform        ds.w     4096
LZW_ClearCode        ds.w     1
LZW_EOICode          ds.w     1
LZW_FirstCode        ds.w     1
;========================================================================;
;==                    GIFview3 BSS: GIF-Specific                      ==;
;========================================================================;
GIF_ScreenDescriptor:
GIF_Signature        ds.b     6
GIF_ScreenWidth      ds.w     1
GIF_ScreenHeight     ds.w     1
GIF_ScreenBits       ds.b     1
GIF_Background       ds.b     1
GIF_Blank            ds.b     1

GIF_ColourCount      ds.w     1
GIF_GlobalPalette    ds.b     256*3

GIF_ImageDescriptor:
GIF_ImageSignature   ds.b     1
GIF_ImageXPos        ds.b     2
GIF_ImageYPos        ds.b     2
GIF_ImageWidth       ds.b     2
GIF_ImageHeight      ds.b     2
GIF_ImageBits        ds.b     1
LZW_CodeSize         ds.b     2      ; It's a long & boring story...

GIF_IlacePointer     ds.l     1

                     end


 