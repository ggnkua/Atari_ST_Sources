;!!!CURRENTLY MASK=(BPL0 OR BPL1) BUT THAT CAN/SHALL BE MODIFIED
;!!!TO OPTIMISE, TRY TO LOAD DATA WITH MOVEM

;**********************
;****    GENSPR    ****
;**********************
;IN   a0=@WhereToGenerateRoutine
;     a1=@Sprite, 2bpl (starting with SpriteWidth.w , SpriteHeight.w)
;     SpriteWidth must be a multiple of 16
;OUT  a0 points after generated routine
;     KILLS d0-d6/a0-a4
;Generated routine is called with a0=@drawing, a1=@return, d0 will be killed

;Alain Brobecker - April 2010
;step 1: We go through the sprite and save the value, disp16 and action
;        to perform: "and" for masking, "or" for drawing and some variants
;        ("move", partial "and/or") depending on mask, bpl0 and bpl1.
;step 2: The data are sorted so that "move/and" are before "or", and
;        according to decreasing value.
;step 3: We go through the actions, generating "action.? #value,disp16(a?)"
;        or "move.? #value,dn" + n*"action.? dn,disp16(a?)" if the value is
;        used more than once.
GENSPR
  move.w      (a1)+,d0      ;d0=SpriteWidth (must be a multiple of 16)
  move.w      (a1)+,d1      ;d1=SpriteHeight
  addq.l      #6,a0         ;1st action may need to generate a "move.l #...,d?" before gaining space
  move.l      a0,a2         ;a2=a0=@WhereToSaveData
  moveq.l     #0,d3         ;Sometimes we need upperwords to be 0
  moveq.l     #0,d4         ;so that .w actions will be generated last
  move.l      d4,a3         ;a3=displacement to line
GENSPR_PrepareLine  
  move.l      a3,d2         ;d2=disp16
  move.w      d0,d6         ;d6=SpriteWidth
GENSPR_PrepareWord
  move.w      (a1)+,d3      ;d3.w=0 | bpl0 !!! Can't use movem.w,
  move.w      (a1)+,d4      ;d4.w=0 | bpl1 !!! it extends the sign
  move.l      d3,d5
  or.l        d4,d5         ;compute mask, could also be loaded from memory!!!
  tst.w       d5            ;mask=0?
  beq         GENSPR_PrepareNextWord
  cmp.w       #$ffff,d5     ;mask=$ffff?
  beq.s       GENSPR_mask_is_ffff
  tst.w       d3            ;bpl0=0?
  beq.s       GENSPR_bpl0_is_0
  cmp.w       d5,d3         ;bpl0=mask?
  beq.s       GENSPR_bpl0_is_mask
  tst.w       d4            ;bpl1=0?
  beq         GENSPR_bpl0_not_0_not_mask_bpl1_is_0
  cmp.w       d5,d4         ;bpl1=mask?
  beq         GENSPR_bpl0_not_0_not_mask_bpl1_is_mask
;**** bpl0!=0 AND bpl0!=mask AND bpl1!=0 AND bpl1!=mask
  not.w       d5
  move.w      d5,(a2)+
  move.w      d5,(a2)+
  move.w      d2,(a2)+
  move.w      #32,(a2)+     ;"andi.l #not(mask)|not(mask),disp16(a?)"
  move.w      d3,(a2)+
  move.w      d4,(a2)+
  move.w      d2,(a2)+
  move.w      #8,(a2)+      ;"ori.l #bpl0|bpl1,disp16(a?)"
  bra         GENSPR_PrepareNextWord
  
;**** mask=$ffff,
GENSPR_mask_is_ffff
  move.w      d3,(a2)+
  move.w      d4,(a2)+
  move.w      d2,(a2)+
  move.w      #0,(a2)+      ;"move.l #bpl0|bpl1,disp16(a?)"
  bra         GENSPR_PrepareNextWord
  
;**** bpl0=0
GENSPR_bpl0_is_0
  tst.w       d4            ;bpl1=0?
  beq.s       GENSPR_bpl0_is_0_bpl1_is_0
  cmp.w       d5,d4         ;bpl1=mask?
  beq.s       GENSPR_bpl0_is_0_bpl1_is_mask
;**** bpl0=0 AND bpl1!=0 AND bpl1!=mask
  not.w       d5
  move.w      d5,(a2)+
  move.w      d5,(a2)+
  move.w      d2,(a2)+
  move.w      #32,(a2)+     ;"andi.l #not(mask)|not(mask),disp16(a?)"
  move.l      d4,(a2)+      ;value=0|bpl1
  move.w      d2,(a2)
  addq.w      #2,(a2)+
  move.w      #24,(a2)+     ;"ori.w #bpl1,disp16+2(a?)"
  bra         GENSPR_PrepareNextWord
   
;**** bpl0=0 AND bpl1=0
GENSPR_bpl0_is_0_bpl1_is_0
  not.w       d5
  move.w      d5,(a2)+
  move.w      d5,(a2)+
  move.w      d2,(a2)+
  move.w      #32,(a2)+     ;"andi.l #not(mask)|not(mask),disp16(a?)"
  bra         GENSPR_PrepareNextWord

;**** bpl0=0 AND bpl1=mask
GENSPR_bpl0_is_0_bpl1_is_mask
  not.w       d5
  move.l      d5,(a2)+      ;value=0|not(mask)
  move.w      d2,(a2)+
  move.w      #16,(a2)+     ;"andi.w #not(mask),disp16(a?)"
  move.l      d4,(a2)+      ;value=0|bpl1
  move.w      d2,(a2)
  addq.w      #2,(a2)+
  move.w      #24,(a2)+     ;"ori.w #bpl1,disp16+2(a?)"
  bra.s       GENSPR_PrepareNextWord

;**** bpl0=mask
GENSPR_bpl0_is_mask
  tst.w       d4            ;bpl1=0?
  beq.s       GENSPR_bpl0_is_mask_bpl1_is_0
  cmp.w       d5,d4         ;bpl1=mask?
  beq.s       GENSPR_bpl0_is_mask_bpl1_is_mask
;**** bpl0=mask AND bpl1!=0 AND bpl1!=mask
  not.w       d5
  move.l      d5,(a2)+      ;value=0|not(mask)
  move.w      d2,(a2)
  addq.w      #2,(a2)+
  move.w      #16,(a2)+     ;"andi.w #not(mask),disp16+2(a?)"
  move.w      d3,(a2)+
  move.w      d4,(a2)+
  move.w      d2,(a2)+
  move.w      #8,(a2)+      ;"ori.l #bpl0|bpl1,disp16(a?)"
  bra.s       GENSPR_PrepareNextWord

;**** bpl0=mask AND bpl1=0
GENSPR_bpl0_is_mask_bpl1_is_0
  move.l      d3,(a2)+      ;value=0|bpl0
  move.w      d2,(a2)+
  move.w      #24,(a2)+     ;"ori.w #bpl0,disp16(a?)"
  not.w       d5
  move.l      d5,(a2)+      ;value=0|not(mask)
  move.w      d2,(a2)
  addq.w      #2,(a2)+
  move.w      #16,(a2)+     ;"andi.w #not(mask),disp16+2(a?)"
  bra.s       GENSPR_PrepareNextWord

;**** bpl0=bpl1=mask
GENSPR_bpl0_is_mask_bpl1_is_mask
  move.w      d3,(a2)+
  move.w      d4,(a2)+
  move.w      d2,(a2)+
  move.w      #8,(a2)+      ;"ori.l #bpl0|bpl1,disp16(a?)"
  bra.s       GENSPR_PrepareNextWord

;**** bpl0!=0 AND bpl0!=mask AND bpl1=0
GENSPR_bpl0_not_0_not_mask_bpl1_is_0
  not.w       d5
  move.w      d5,(a2)+
  move.w      d5,(a2)+
  move.w      d2,(a2)+
  move.w      #32,(a2)+     ;"andi.l #not(mask)|not(mask),disp16(a?)"
  move.l      d3,(a2)+      ;value=0|bpl0
  move.w      d2,(a2)+
  move.w      #24,(a2)+     ;"ori.w #bpl0,disp16(a?)"
  bra.s       GENSPR_PrepareNextWord

;**** bpl0!=0 AND bpl0!=mask AND bpl1=mask
GENSPR_bpl0_not_0_not_mask_bpl1_is_mask
  not.w       d5
  move.l      d5,(a2)+      ;value=0|not(mask)
  move.w      d2,(a2)+
  move.w      #16,(a2)+     ;"andi.w #not(mask),disp16(a?)"
  move.w      d3,(a2)+
  move.w      d4,(a2)+
  move.w      d2,(a2)+
  move.w      #8,(a2)+      ;"ori.l #bpl0|bpl1,disp16(a?)"
;  bra         GENSPR_PrepareNextWord

GENSPR_PrepareNextWord
  addq.w      #8,d2         ;disp16+=8
  sub.w       #16,d6        ;pixels left?
  bne         GENSPR_PrepareWord
  add.w       #160,a3       ;displacement to line+=160
  subq.w      #1,d1         ;Lines left?
  bne         GENSPR_PrepareLine
  
;**** STEP 2
;**** SORT DATA
;We put all  "move/and" actions (3rd bit clear) before the "or" actions.
;Then we sort decreasingly according to the value.
;Otherwise the sort method is stupid.
;a0=@SavedData=@WhereToGenerateRoutine+6 contains
;  .l value to insert (action .w => 0 in upperword)
;  .w disp16
;  .w action (0=move.l , 8=or.l , 16=and.w , 24=or.w , 32=and.l)
;a2=@EndOfData
  move.l      a2,a1       ;a1=@EndOfData
  move.l      a2,d3
  subq.l      #8,d3       ;d3=@EndOfData-8
  move.l      a0,a3
GENSPR_Sort  
  move.l      a3,a2
  move.l      (a2),d0     ;d0=maxvalue
  move.w      6(a2),d1    ;d1=maxaction
  and.w       #8,d1       ;d1!=0 when "or"
  move.l      a2,a4       ;a4=maxpos
GENSPR_Sort_SearchMax
  addq.l      #8,a2
  cmp.l       a2,a1       ;EndOfData reached?
  beq.s       GENSPR_PushUpMax
  move.w      6(a2),d2    ;d2=action
  and.w       #8,d2       ;d2!=0 when "or"
  cmp.w       d1,d2       ;flags=d2-d1, "or" must come after "move/and"
  bgt.s       GENSPR_Sort_SearchMax
  blt.s       GENSPR_Sort_DoMaskingBefore
  cmp.l       (a2),d0     ;flags=value-maxvalue
  bHI.s       GENSPR_Sort_SearchMax ;HI/LS for unsigned comparison
GENSPR_Sort_DoMaskingBefore
  move.l      (a2),d0     ;If value>maxvalue then it is new maxvalue,
  move.w      d2,d1       ;  action is new maxaction
  move.l      a2,a4       ;  and a2 is new maxpos
  bra.s       GENSPR_Sort_SearchMax
  
GENSPR_PushUpMax
;exchange data pointed by a3 with the one at maxpos  
;  move.l      (a4),d0
  move.l      (a3),(a4)+
  move.l      d0,(a3)+
  move.l      (a4),d0
  move.l      (a3),(a4)+
  move.l      d0,(a3)+
  cmp.l       a3,d3       ;EndOfData-8 reached?
  bne.s       GENSPR_Sort

;**** STEP 3
;**** ACTUALLY GENERATE CODE
;a0=@SavedData=@WhereToGenerateRoutine+6 contains
;  .l value to insert (action .w => 0 in upperword)
;  .w disp16
;  .w action (0=move.l , 8=or.l , 16=and.w , 24=or.w , 32=and.l)
;a1=@EndOfData
  move.l      a0,a2       ;a2=@SavedData
  subq.l      #6,a0       ;a0=@WhereToGenerateRoutine
  move.l      (a2),d0
  not.l       d0          ;d0=DataInRegister, garbage at first
  move.l      -8(a1),d1
  not.l       d1
  move.l      d1,(a1)     ;And also put garbage at the end of the Data
  lea         GENSPR_Opcodes,a3
  
GENSPR_OneAction
  move.l      (a2)+,d1    ;d1=Data
  move.w      (a2)+,d2    ;d2=disp16
  move.w      (a2)+,d3    ;d3=action
  btst.l      #4,d3       ;.w action?
  beq.s       GENSPR_ActionIsLongWord
  cmp.w       d1,d0       ;Data.w=DataInRegister.w?
  beq.s       GENSPR_Data_is_DataInRegister
GENSPR_ActionIsLongWord
  cmp.l       d1,d0       ;Data.l=DataInRegister.l?
  beq.s       GENSPR_Data_is_DataInRegister
  cmp.l       (a2),d1     ;Data=NextData?
  beq.s       GENSPR_Data_is_NextData
  tst.w       d2          ;disp16=0?
  bne.s       GENSPR_Normal_NoOpcodeChange
  addq.w      #4,d3       ;opcode when disp16=0
GENSPR_Normal_NoOpcodeChange
  btst.l      #4,d3       ;.w action?
  bne.s       GENSPR_Normal_word
;**** normal code: "action.l #...,disp16(a?)"  
  move.w      (a3,d3),(a0)+
  move.l      d1,(a0)+
  tst.w       d2          ;disp16=0?
  beq.s       GENSPR_NextAction
  move.w      d2,(a0)+
  bra.s       GENSPR_NextAction

;**** normal word code: "action.w #...,disp16(a?)"  
GENSPR_Normal_word
  move.w      (a3,d3),(a0)+
  move.w      d1,(a0)+
  tst.w       d2          ;disp16=0?
  beq.s       GENSPR_NextAction
  move.w      d2,(a0)+
  bra.s       GENSPR_NextAction

;**** Data=DataInRegister
GENSPR_Data_is_DataInRegister
  addq.w      #2,d3       ;opcode for register action
  tst.w       d2          ;disp16=0?
  bne.s       GENSPR_Data_is_DataInRegister_NoOpcodeChange
  addq.w      #4,d3       ;opcode when disp16=0
GENSPR_Data_is_DataInRegister_NoOpcodeChange
  move.w      (a3,d3),(a0)+
  tst.w       d2
  beq.s       GENSPR_NextAction
  move.w      d2,(a0)+
  bra.s       GENSPR_NextAction
  
;**** Data=NextData
GENSPR_Data_is_NextData
  btst.l      #4,d3       ;.w action?
  bne.s       GENSPR_Data_is_NextData_Word
  move.l      d0,d4
  swap.w      d4          ;d4=up(DataInRegister)
  move.l      d1,d5
  swap.w      d5          ;d5=up(Data)
  cmp.w       d4,d5       ;up(Data)=up(DataInRegister)
  beq.s       GENSPR_Data_is_NextData_Word
  move.w      -4(a3),(a0)+
  move.l      d1,(a0)+
  move.l      d1,d0       ;DataInRegister=Data
  subq.l      #8,a2       ;We have not finished to process this action, so back
  bra.s       GENSPR_NextAction

;**** Data=NextData, Word
GENSPR_Data_is_NextData_Word
  move.w      -2(a3),(a0)+
  move.w      d1,(a0)+
  move.w      d1,d0       ;DataInRegister=Data
  subq.l      #8,a2       ;We have not finished to process this action, so back
;  bra.s       GENSPR_NextAction
      
GENSPR_NextAction
  cmp.l       a2,a1       ;@SavedData=@EndOfData?
  bne.s       GENSPR_OneAction
  move.w      #$4ed1,(a0)+ ;"jmp (a1)"
  rts

  dc.w  $203c   ;12 "move.l #...,d0" + value.l
  dc.w  $303c   ; 8 "move.w #...,d0" + value.w
GENSPR_Opcodes
  dc.w  $217c   ;24 "move.l #...,disp16(a0)" + value.l + disp16
  dc.w  $2140   ;16 "move.l d0,disp16(a0)" + disp16
  dc.w  $20bc   ;20 "move.l #...,(a0)" + value.l
  dc.w  $2080   ;12 "move.l d0,(a0)"
  
  dc.w  $00a8   ;32 "ori.l #...,disp16(a0)"
  dc.w  $81a8   ;24 "or.l d0,disp16(a0)"
  dc.w  $0090   ;28 "ori.l #...,(a0)"
  dc.w  $8190   ;20 "or.l d0,(a0)"
  
  dc.w  $0268   ;20 "andi.w #...,disp16(a0)" + value.w + disp16
  dc.w  $c168   ;16 "and.w d0,disp16(a0)"
  dc.w  $0250   ;16 "andi.w #...,(a0)" + value.w
  dc.w  $c150   ;12 "and.w d0,(a0)"
  
  dc.w  $0068   ;20 "ori.w #...,disp16(a0)"
  dc.w  $8168   ;16 "or.w d0,disp16(a0)"  
  dc.w  $0050   ;16 "ori.w #...,(a0)"
  dc.w  $8150   ;12 "or.w d0,(a0)"  
  
  dc.w  $02a8   ;32 "andi.l #...,disp16(a0)"
  dc.w  $c1a8   ;24 "and.l d0,disp16(a0)"
  dc.w  $0290   ;28 "andi.l #...,(a0)"
  dc.w  $c190   ;20 "and.l d0,(a0)"
