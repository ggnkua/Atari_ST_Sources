;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;
;=;                             GIFcolor                              ;=;
;=;===================================================================;=;
;=;    This program is much like GIFscale, but it decompresses the    ;=;
;=;  picture to memory, picks the most popular 16 colours, then maps  ;=;
;=;                the GIF picture to those 16 colours.               ;=;
;=;===================================================================;=;
;=;   Written in November 1990 by Robert Barnhardt & Robert Steger.   ;=;
;=;                (C) 1990 Brain~Waves Freeware Group                ;=;
;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;=;
                     text

GC_ResizeMemory      move.l   4(sp),a2
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

GC_ReadTTP           move.b   #'\',BFS_Pathfudge
                     lea      $80(a2),a2
                     lea      BFS_Pathspec,a1
                     move.b   (a2)+,d0
GC_RT_Loop           move.b   (a2)+,(a1)+
                     dbra     d0,GC_RT_Loop

GC_SaveRez           move.w   #$4,-(sp)
                     trap     #14
                     addq.l   #2,sp
                     move.w   d0,ST_SaveResolution
                     cmpi.b   #2,d0
                     bne.s    GC_SavePalette
                     clr.w    -(sp)
                     trap     #1
GC_SavePalette       move.w   #15,d7
                     lea      ST_SavePalette+32,a6
GC_SP_1              move.w   #-1,-(sp)
                     move.w   d7,-(sp)
                     move.w   #$7,-(sp)
                     trap     #14
                     addq.l   #6,sp
                     move.w   d0,-(a6)
                     dbra     d7,GC_SP_1
GC_SaveDTA           move.w   #$2f,-(sp)
                     trap     #1
                     addq.l   #2,sp
                     move.l   d0,ST_DTASave

GC_NewRez            clr.w    -(sp)
                     pea      -1
                     pea      -1
                     move.w   #$5,-(sp)
                     trap     #14
                     lea      $c(sp),sp
GC_NewPalette        pea      ST_GreyPalette
                     move.w   #$6,-(sp)
                     trap     #14
                     addq.l   #6,sp
GC_NewDTA            pea      ST_DTA
                     move.w   #$1a,-(sp)
                     trap     #1
                     addq.l   #6,sp

GC_FindScreen        move.w   #$3,-(sp)
                     trap     #14
                     addq.l   #2,sp
                     move.l   d0,ST_ScreenPointer

GC_ShowTitleCheck    move.b   BFS_Pathspec,d0
                     sub.b    #65,d0
                     cmpi.b   #':',BFS_Pathspec+1
                     beq.s    GC_STC_1
                     move.w   #$19,-(sp)
                     trap     #1
                     addq.l   #2,sp
GC_STC_1             cmpi.b   #1,d0
                     bgt.s    GC_FindFirstFile
                     pea      ST_TitleScreen
                     move.w   #$9,-(sp)
                     trap     #1
                     addq.l   #6,sp
                     move.b   #1,ST_TitleFlag

GC_FindFirstFile     clr.w    -(sp)
                     pea      BFS_Pathspec
                     move.w   #$4e,-(sp)
                     trap     #1
                     lea      8(sp),sp
                     tst.w    d0
                     bmi      GC_AllDone
                     lea      BFS_Filenames,a6
                     move.l   a6,BFS_FileIndex
GC_StoreName         lea      ST_DTA+30,a5
GC_SN_1              move.b   (a5)+,(a6)+
                     bne.s    GC_SN_1
                     addq.w   #1,BFS_FileCount
GC_FindNextName      move.w   #$4f,-(sp)
                     trap     #1
                     addq.l   #2,sp
                     tst.w    d0
                     bpl.s    GC_StoreName
GC_FindPathEnd       lea      BFS_Pathspec+128,a0
GC_FPE_1             cmpi.b   #'\',-(a0)
                     bne.s    GC_FPE_1
                     addq.l   #1,a0
                     move.l   a0,BFS_FnamePtr
GC_RestoreDTA        move.l   ST_DTASave,-(sp)
                     move.w   #$1a,-(sp)
                     trap     #1
                     addq.l   #6,sp

GC_OpenNextFile      move.l   BFS_FileIndex,a0
                     move.l   BFS_FnamePtr,a1
GC_ONF_1             move.b   (a0)+,(a1)+
                     bne.s    GC_ONF_1
                     move.l   a0,BFS_FileIndex
                     clr.w    -(sp)
                     pea      BFS_Pathspec
                     move.w   #$3d,-(sp)
                     trap     #1
                     lea      8(sp),sp
                     move.w   d0,BFS_FileDescriptor

GC_MakeSaveName      move.l   BFS_FnamePtr,a0
                     move.w   #5,d0
GC_MSN_SS_1          tst.b    (a0)
                     beq.s    GC_MSN_Overlay
                     cmpi.b   #'.',(a0)
                     beq.s    GC_MSN_Overlay
                     addq.l   #1,a0
                     dbra     d0,GC_MSN_SS_1
GC_MSN_Overlay       lea      ST_SaveOverlay,a1
GC_MSN_O_1           move.b   (a1)+,(a0)+
                     bne.s    GC_MSN_O_1
                     subq.l   #6,a0
                     move.l   a0,ST_SaveNumAddr

GC_ReadSDescriptor   pea      GIF_ScreenDescriptor
                     move.l   #13,-(sp)
                     move.w   BFS_FileDescriptor,-(sp)
                     move.w   #$3f,-(sp)
                     trap     #1
                     lea      $c(sp),sp
                     tst.l    d0
                     ble      GC_DoneGIF

GC_ReadGPalette      move.b   GIF_ScreenBits,d0
                     and.b    #7,d0
                     addq.b   #1,d0
                     moveq    #1,d1
                     lsl.w    d0,d1
                     move.w   d1,GIF_ColourCount
                     mulu     #3,d1
                     ext.l    d1
                     pea      GIF_Popularity
                     move.l   d1,-(sp)
                     move.w   BFS_FileDescriptor,-(sp)
                     move.w   #$3f,-(sp)
                     trap     #1
                     lea      $c(sp),sp
                     tst.l    d0
                     ble      GC_DoneGIF

GC_GlobalConvert     lea      GIF_Popularity,a0
                     lea      GIF_GlobalPalette,a1
                     move.w   GIF_ColourCount,d7
GC_GC_1              subq.w   #1,d7
                     blt.s    GC_ImageDescriptor
                     moveq    #0,d0
                     move.b   (a0),d0
                     clr.b    (a0)+
                     lsl.w    #3,d0
                     move.b   (a0),d0
                     clr.b    (a0)+
                     and.b    #$E0,d0
                     lsr.b    #1,d0
                     move.b   (a0),d1
                     clr.b    (a0)+
                     lsr.b    #5,d1
                     or.b     d1,d0
                     move.w   d0,(a1)+
                     bra.s    GC_GC_1

GC_ImageDescriptor   pea      GIF_ImageDescriptor
                     move.l   #11,-(sp)
                     move.w   BFS_FileDescriptor,-(sp)
                     move.w   #$3f,-(sp)
                     trap     #1
                     lea      $c(sp),sp
                     tst.l    d0
                     ble      GC_AllDone

;========================================================================;
;==                  GIFlow : ST-Specific Calculations                 ==;
;========================================================================;
GC_FixDimensions     move.b   GIF_ImageHeight+1,d1
                     lsl.w    #8,d1
                     move.b   GIF_ImageHeight,d1
                     move.w   d1,ST_ImageHeight
                     move.b   GIF_ImageWidth+1,d0
                     lsl.w    #8,d0
                     move.b   GIF_ImageWidth,d0
                     move.w   d0,ST_ImageWidth
                     move.w   d0,d5
                     move.w   d0,d2
                     move.w   d0,d3
                     and.w    #$FFF0,d2
                     lsr.w    #1,d2
                     and.w    #$F,d3
                     beq.s    GC_FD_Even
                     addq.w   #8,d2
GC_FD_Even           move.w   d2,ST_WordWidth

GC_AllocateMemory    mulu     d1,d0
                     add.l    #8,d0
                     move.l   d0,-(sp)
                     move.w   #$48,-(sp)
                     trap     #1
                     addq.l   #6,sp
                     tst.l    d0
                     beq      GC_AllDone
                     move.l   d0,ST_ImagePointer
                     add.l    #8,d0
                     move.l   d0,a4
                     move.l   d0,GIF_ImagePointer

GC_AllocateBuffer    move.l   #-1,-(sp)
                     move.w   #$48,-(sp)
                     trap     #1
                     addq.l   #6,sp
                     move.l   d0,BFS_BufferSize
                     move.l   d0,-(sp)
                     move.w   #$48,-(sp)
                     trap     #1
                     addq.l   #6,sp
                     tst.l    d0
                     beq      GC_AllDone
                     move.l   d0,BFS_BufferPointer

;========================================================================;
;==              GIFlow : Set Interlace and LZW Variables              ==;
;========================================================================;

GC_InterlaceSetup    move.w   ST_ImageHeight,ST_HeightCount
                     btst     #6,GIF_ImageBits
                     beq.s    GC_LZWSetup
                     move.w   ST_ImageWidth,d1
                     move.w   d1,d0
                     clr.w    GIF_InterlaceStart
                     move.w   d0,GIF_InterlaceStart+6
                     move.w   d0,GIF_InterlaceSkip+6
                     add.w    d0,d0
                     move.w   d0,GIF_InterlaceStart+4
                     add.w    d1,d0
                     move.w   d0,GIF_InterlaceSkip+4
                     add.w    d1,d0
                     move.w   d0,GIF_InterlaceStart+2
                     add.w    d0,d0
                     sub.w    d1,d0
                     move.w   d0,GIF_InterlaceSkip+2
                     move.w   d0,GIF_InterlaceSkip
                     move.l   #GIF_InterlaceStart,GIF_IlacePointer

GC_LZWSetup          sub.l    a6,a6
                     sub.l    a5,a5
                     move.b   LZW_CodeSize,d0
                     moveq    #1,d1
                     lsl.w    d0,d1
                     move.w   d1,LZW_ClearCode
                     addq.l   #1,d1
                     move.w   d1,LZW_EOICode
                     addq.l   #1,d1
                     move.w   d1,LZW_FirstCode
                     subq.w   #3,d1
                     lea      LZW_Prefices,a0
                     lea      LZW_Suffices,a1
                     lea      LZW_Transform,a2
GC_LS_1              move.b   d1,(a1,d1.w)
                     lsl.w    #1,d1
                     move.w   #-1,(a0,d1.w)
                     lsr.w    #1,d1
                     subq.w   #1,d1
                     bge.s    GC_LS_1
                     bsr      BFS_ByteRead
                     clr.w    d6
                     move.b   d0,d6
                     clr.l    d4
                     swap     d5
                     clr.w    d5

GC_PopularitySetup   lea      GIF_Popularity,a3
                     move.w   #255,d0
GC_PS_1              clr.l    (a3)+
                     dbra     d0,GC_PS_1
                     lea      GIF_Popularity,a3

;========================================================================;
;==                  GIFlow : LZW Decompression Loop                   ==;
;========================================================================;
GC_LzwLoop           swap     d7
                     move.b   LZW_CodeSize,d7
                     addq.l   #1,d7
                     move.l   #$fff00000,d0
                     rol.l    d7,d0
                     swap     d6
                     move.w   d0,d6
                     swap     d6
                     swap     d7
                     move.w   LZW_FirstCode,d7
                     bsr      UBR_GetCode
                     clr.l    d3
                     move.w   d0,d3
                     cmp.w    LZW_ClearCode,d3
                     beq.s    GC_LzwLoop
                     swap     d3
                     swap     d5
                     moveq    #0,d1
                     subq.w   #1,d7
                     bra      GC_O_Rude

GC_GIFLoop           bsr      UBR_GetCode
                     move.w   d0,d3
                     cmp.w    LZW_ClearCode,d0
                     beq.s    GC_LZWLoop
                     cmp.w    LZW_EOICode,d0
                     beq      GC_ConvertGIF
                     cmp.w    d7,d0
                     beq.s    GC_PredictConvert

GC_NormalConvert     clr.w    d1
                     move.b   (a1,d0.w),(a2,d1.w)
GC_NC_1              add.w    d0,d0
                     move.w   (a0,d0.w),d0
                     bmi.s    GC_NC_2
                     addq.w   #1,d1
                     move.b   (a1,d0.w),(a2,d1.w)
                     bra.s    GC_NC_1
GC_NC_2              swap     d3
                     bra.s    GC_Output
GC_PredictConvert    move.w   #1,d1
                     swap     d3
                     move.w   d3,d0
                     move.b   (a1,d0.w),(a2,d1.w)
GC_PC_1              add.w    d0,d0
                     move.w   (a0,d0.w),d0
                     bmi.s    GC_PC_2
                     addq.w   #1,d1
                     move.b   (a1,d0.w),(a2,d1.w)
                     bra.s    GC_PC_1
GC_PC_2              move.b   (a2,d1.w),(a2)

GC_Output            move.b   (a2,d1.w),(a1,d7.w)
                     add.w    d7,d7
                     move.w   d3,(a0,d7.w)
                     lsr.w    #1,d7
                     swap     d5
GC_O_1               clr.w    d0
                     move.b   (a2,d1.w),d0
GC_O_Rude            move.b   d0,(a4)+
                     lsl.w    #2,d0
                     addq.l   #1,(a3,d0.w)
                     subq.w   #1,d5
                     beq.s    GC_Interlace
GC_O_2               dbra     d1,GC_O_1
                     addq.w   #1,d7
                     swap     d5
                     bra      GC_GIFLoop

GC_Interlace         move.w   ST_ImageWidth,d5
                     btst     #6,GIF_ImageBits
                     beq.s    GC_O_2
                     clr.l    d0
                     move.l   GIF_IlacePointer,a3
                     move.w   8(a3),d0
                     add.l    d0,a4
                     move.w   24(a3),d0
                     sub.w    d0,ST_HeightCount
                     bgt.s    GC_I_1
                     move.l   GIF_ImagePointer,a4
                     add.w    2(a3),a4
                     move.w   18(a3),d0
                     neg.w    d0
                     add.w    ST_ImageHeight,d0
                     move.w   d0,ST_HeightCount
                     addq.l   #2,GIF_IlacePointer
GC_I_1               lea      GIF_Popularity,a3
                     bra.s    GC_O_2


GC_ConvertGIF        lea      ST_BestPalette,a0
                     moveq    #0,d2
                     moveq    #0,d3
                     movem.l  d2-d3,(a0)
                     movem.l  d2-d3,8(a0)
                     movem.l  d2-d3,16(a0)
                     movem.l  d2-d3,24(a0)
GC_PopularPalette    move.w   GIF_ColourCount,d7
                     lea      GIF_GlobalPalette,a1
                     lea      GIF_Popularity,a2
PP_1                 moveq    #0,d0
                     moveq    #0,d1
                     move.w   GIF_ColourCount,d6
PP_2                 cmp.l    (a2,d1.w),d0
                     bgt.s    PP_3
                     move.w   d1,d2
                     move.l   (a2,d1.w),d0
PP_3                 addq.w   #4,d1
                     subq.w   #1,d6
                     bgt.s    PP_2

PP_Redundant         move.l   #-1,(a2,d2.w)
                     lsr.w    #1,d2
                     move.w   (a1,d2.w),d0
                     lea      ST_BestPalette,a0
                     move.w   d3,d1
PP_R_1               tst.w    d1
                     beq.s    PP_R_Add
                     cmp.w    (a0)+,d0
                     beq.s    PP_R_Done
                     dbra     d1,PP_R_1
PP_R_Add             move.w   d0,(a0)
                     addq.b   #1,d3
                     cmpi.b   #16,d3
                     beq.s    SetBackground
PP_R_Done            subq.w   #1,d7
                     bgt.s    PP_1

SetBackground        lea      ST_BestPalette,a0
                     move.w   #15,d0
MBB_1                tst.w    (a0)+
                     beq.s    MBB_2
                     dbra     d0,MBB_1
                     bra.s    MapColours
MBB_2                move.w   ST_BestPalette,-2(a0)
                     clr.w    ST_BestPalette

MapColours           lea      ST_BestPalette,a0
                     lea      GIF_GlobalPalette,a1
                     lea      GIF_GlobalMap,a2
                     move.w   GIF_ColourCount,d7
                     add.w    d7,d7
MC_1                 moveq    #0,d6
                     move.w   #$ff,d0
MC_2                 moveq    #0,d1
                     move.w   (a0,d6.w),d3
                     move.w   -2(a1,d7.w),d4
                     move.w   #2,d5
                     lsl.l    #4,d3
                     lsl.l    #4,d4
MC_3                 lsr.b    #4,d3
                     lsr.b    #4,d4
                     sub.b    d4,d3
                     move.b   d3,d2
                     ext.w    d2
                     muls     d2,d2
                     add.w    d2,d1
                     lsr.w    #4,d3
                     lsr.w    #4,d4
                     dbra     d5,MC_3
                     cmp.w    d1,d0
                     ble.s    MC_4
                     move.w   d1,d0
                     lsr.w    #1,d6
                     lsr.w    #1,d7
                     move.b   d6,-1(a2,d7.w)
                     add.w    d6,d6
                     add.w    d7,d7
MC_4                 addq.w   #2,d6
                     cmpi.w   #32,d6
                     blt.s    MC_2
                     subq.w   #2,d7
                     bne.s    MC_1

GC_PlotPicture       move.l   GIF_ImagePointer,a0
                     lea      GIF_GlobalMap,a1
                     move.l   ST_ImagePointer,a2
                     move.w   ST_ImageHeight,d7
GC_PP_1              move.w   ST_ImageWidth,d6
                     move.b   #16,d5
GC_PP_2              move.b   (a0)+,d4
                     move.b   (a1,d4),d4
                     lsr.b    #1,d4
                     roxl.w   #1,d0
                     lsr.b    #1,d4
                     roxl.w   #1,d1
                     lsr.b    #1,d4
                     roxl.w   #1,d2
                     lsr.b    #1,d4
                     roxl.w   #1,d3
                     subq.b   #1,d5
                     bne.s    GC_PP_3
GC_PP_Rude           movem.w  d0-d3,(a2)
                     addq.l   #8,a2
                     move.b   #16,d5
GC_PP_3              subq.w   #1,d6
                     bne.s    GC_PP_2
                     cmpi.b   #16,d5
                     beq.s    GC_PP_4
                     lsl.w    d5,d0
                     lsl.w    d5,d1
                     lsl.w    d5,d2
                     lsl.w    d5,d3
                     addq.w   #1,d6
                     bra.s    GC_PP_Rude
GC_PP_4              subq.w   #1,d7
                     bne.s    GC_PP_1

;========================================================================;
;==          GIFview3 Display Routines: Splat and ScrollCheck          ==;
;========================================================================;
GC_DisplayGIF        move.w   #-1,-(sp)
                     move.w   #$b,-(sp)
                     trap     #13
                     addq.l   #4,sp
                     btst     #3,d0
                     bne.s    GC_DisplayGIF

GC_ClearScreen       move.l   ST_ScreenPointer,a0
                     move.w   #3999,d0
GC_ClearLoop         clr.l    (a0)+
                     clr.l    (a0)+
                     dbra     d0,GC_ClearLoop

GC_SetPalette        pea      ST_BestPalette
                     move.w   #$6,-(sp)
                     trap     #14
                     addq.l   #6,sp

GC_MovePicture       move.w   #200,d2
                     cmp.w    ST_ImageHeight,d2
                     ble.s    GC_MP_HeightOK
                     move.w   ST_ImageHeight,d2
GC_MP_HeightOK       move.w   #160,d3
                     cmp.w    ST_WordWidth,d3
                     ble.s    GC_MP_WidthOK
                     move.w   ST_WordWidth,d3
GC_MP_WidthOK        lsr.w    #3,d3
                     subq.w   #1,d3
                     subq.w   #1,d2
                     clr.w    d6
                     clr.l    d7

GC_SplatPicture      move.l   ST_ImagePointer,a0
                     move.l   ST_ScreenPointer,a1
                     clr.b    ST_TitleFlag
                     clr.l    d0
                     move.w   ST_WordWidth,d0
                     mulu     d7,d0
                     add.l    d0,a0
                     move.w   d2,d0
GC_SP_HLoop          move.w   d3,d1
                     clr.w    d4
                     move.w   d6,d5
GC_SP_WLoop          move.l   (a0,d5.w),(a1,d4.w)
                     move.l   4(a0,d5.w),4(a1,d4.w)
                     add.w    #8,d4
                     add.w    #8,d5
                     dbra     d1,GC_SP_WLoop
                     add.w    ST_WordWidth,a0
                     add.w    #160,a1
                     dbra     d0,GC_SP_HLoop

GC_KeyCheck          move.w   #$2,-(sp)
                     move.w   #$2,-(sp)
                     trap     #13
                     addq.l   #4,sp
GC_CheckSave         cmpi.b   #115,d0
                     bne.s    GC_CheckExit
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
                     pea      ST_BestPalette
                     move.l   #32,-(sp)
                     move.w   d7,-(sp)
                     move.w   #$40,-(sp)
                     trap     #1
                     lea      $c(sp),sp
                     move.l   ST_ScreenPointer,-(sp)
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
                     bra      GC_KeyCheck
GC_CheckExit         swap     d0
                     cmpi.b   #28,d0
                     beq      GC_DoneGIF
                     cmpi.b   #57,d0
                     beq      GC_DoneGIF
                     cmpi.b   #114,d0
                     beq      GC_DoneGIF
                     cmpi.b   #97,d0
                     bne.s    GC_CheckRight
                     move.w   #1,BFS_FileCount
                     bra      GC_DoneGIF
GC_CheckRight        cmpi.b   #77,d0
                     bne.s    GC_CheckLeft
                     move.w   d6,d0
                     add.w    #160,d0
                     cmp.w    ST_WordWidth,d0
                     bge      GC_KeyCheck
                     add.w    #8,d6
                     bra      GC_SplatPicture
GC_CheckLeft         cmpi.b   #75,d0
                     bne.s    GC_CheckDown
                     tst.w    d6
                     beq      GC_KeyCheck
                     sub.w    #8,d6
                     bra      GC_SplatPicture
GC_CheckDown         cmpi.b   #80,d0
                     bne.s    GC_CheckUp
                     move.w   d7,d0
                     add.w    #200,d0
                     sub.w    ST_ImageHeight,d0
                     bge      GC_KeyCheck
                     neg.w    d0
                     cmpi.w   #16,d0
                     bge.s    GC_CD_1
                     add.w    d0,d7
                     bra      GC_SplatPicture
GC_CD_1              add.w    #16,d7
                     bra      GC_SplatPicture
GC_CheckUp           cmpi.b   #72,d0
                     bne      GC_KeyCheck
                     tst.w    d7
                     beq      GC_KeyCheck
                     sub.w    #16,d7
                     bge.s    GC_CU_1
                     clr.w    d7
GC_CU_1              bra      GC_SplatPicture

GC_DoneGIF           move.l   ST_ImagePointer,-(sp)
                     move.w   #$49,-(sp)
                     trap     #1
                     addq.l   #6,sp
                     move.l   BFS_BufferPointer,-(sp)
                     move.w   #$49,-(sp)
                     trap     #1
                     addq.l   #6,sp
                     move.w   BFS_FileDescriptor,-(sp)
                     move.w   #$3e,-(sp)
                     trap     #1
                     addq.l   #4,sp
                     subq.w   #1,BFS_FileCount
                     bne      GC_OpenNextFile

GC_AllDone           pea      ST_SavePalette
                     move.w   #$6,-(sp)
                     trap     #14
                     addq.l   #6,sp
                     move.w   ST_SaveResolution,-(sp)
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
                     move.l   BFS_BufferPointer,-(sp)
                     move.l   BFS_BufferSize,-(sp)
                     move.w   BFS_FileDescriptor,-(sp)
                     move.w   #$3f,-(sp)
                     trap     #1
                     lea      $c(sp),sp
                     movem.l  (sp)+,d1-d2/a0-a2
                     move.l   BFS_BufferPointer,a5
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
UBR_CBC_1            bsr      BFS_ByteRead
                     tst.l    d0
                     bmi.s    UBR_StreamError
                     subq.w   #1,d6
                     bge.s    UBR_WithinBlock
                     tst.b    d0
                     beq.s    UBR_StreamError
                     move.w   d0,d6
                     bra.s    UBR_CBC_1
UBR_WithinBlock      lsl.l    d5,d0
                     add.l    d0,d4
                     add.b    #8,d5
                     bra.s    UBR_CzechBitCount
UBR_SnatchBits       swap     d6
                     move.w   d4,d0
                     lsr.l    d7,d4
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
                     bset     #0,d6
UBR_HK_Done          swap     d7
UBR_Done             swap     d6
                     rts

UBR_StreamError      addq.l   #4,sp
                     bra      GC_ConvertGIF

                     data
;========================================================================;
;==                  GIFview3 DATA: ST/Subroutines                     ==;
;========================================================================;
ST_TitleScreen       dc.b     27,"E",27,"f",27,"b",15,27,"c",2
                     dc.b     "==============  GIFcolor  =============="
                     dc.b     13,10,"==  ",27,"b",10
                     dc.b     189,"1990 Brain~Waves Freeware Group"
                     dc.b     27,"b",15,"  ==",13,10,"==  ",27,"b",10
                     dc.b     "Robert Barnhardt / Robert Steger"
                     dc.b     27,"b",15,"  ==",13,10
                     dc.b     "========================================"
                     dc.b     13,10,10,27,"b",10
                     dc.b     "             Active Keys...             ",13,10
                     dc.b     "  ALT    Holds/brings up this screen    ",13,10
                     dc.b     "   S     Save screen (Degas format)     ",13,10
                     dc.b     " ARROWS  Scroll picture (if applicable) ",13,10
                     dc.b     "                                        ",13,10
                     dc.b     " SPACE, ENTER, or RETURN for next GIF.  ",13,10
                     dc.b     "          UNDO or ESC to exit.          ",13,10
                     dc.b     27,66,15,27,67,0
                     align
ST_GreyPalette       dc.w     $000,$000,$111,$111,$222,$222,$333,$333
                     dc.w     $444,$444,$555,$555,$666,$666,$777,$777
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
ST_BestPalette       ds.w     16
ST_SaveResolution    ds.w     1
ST_SavePalette       ds.w     16
ST_ScreenPointer     ds.l     1
ST_ImagePointer      ds.l     1
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
BFS_BufferSize       ds.l     1
BFS_BufferPointer    ds.l     1
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
;GIF_Blank            ds.b     1

GIF_ColourCount      ds.w     1
GIF_GlobalPalette    ds.w     256
GIF_GlobalMap        ds.b     256
GIF_Popularity       ds.l     256

GIF_ImageDescriptor:
GIF_ImageSignature   ds.b     1
GIF_ImageXPos        ds.b     2
GIF_ImageYPos        ds.b     2
GIF_ImageWidth       ds.b     2
GIF_ImageHeight      ds.b     2
GIF_ImageBits        ds.b     1
LZW_CodeSize         ds.b     2      ; It's a long & boring story...

GIF_IlacePointer     ds.l     1
GIF_ImagePointer     ds.l     1

                     end

 