{   Here is the standard routines of RAVE
      (C)opyright Martin Liesen 1991-92

   See the main RAVE fiel for more information     }

Function Pos_possible( player:Shortint; pos:pos_t; map_addr:Pointer):Boolean;
Begin
   ASM
      movem.l d0-a1,-(a7)
      move.b   #0,@Result(a6)       { FALSE  }
      move.l   map_addr(a6),a0   { A0=MAP }
      moveq    #0,d0
      moveq    #0,d1
      move.b   pos.x(a6),d0
      move.b   pos.y(a6),d1
      lsl.w    #3,d0
      move.w   d0,d4             { D4 = X }
      move.w   d1,d5             { D5 = Y }
      add.w    d1,d0
      tst.b    0(a0,d0.w)           { sqaure empty ?  }
      bne      @end_pos_p
      
      lea      @Direction(pc),a1
      move.b   player(a6),d6     { D6 = Player  }
      moveq    #7,d7
      @Direkt_loop:
         move.w   d4,d0
         move.w   d5,d1
         moveq    #0,d2          { D2=counter, brick found+1 }
         @Find_dir_slut:
            add.w    (a1),d0
            bmi      @No_good
            cmp.w    #8*8,d0
            bhs      @No_good
            add.w    2(a1),d1
            bmi      @No_good
            cmp.w    #8,d1
            bhs      @No_good
            move.w   d0,d3
            add.w    d1,d3
            move.b   0(a0,d3.w),d3
            beq      @No_good
            addq.w   #1,d2
            cmp.b    d6,d3
            bne      @Find_dir_slut
            cmp.w    #1,d2
            beq      @No_good
            move.b   #1,@Result(a6)       { TRUE   } 
            bra      @end_pos_p            
         @No_good:
         addq.w   #4,a1
         dbra     d7,@Direkt_loop
      bra      @end_pos_p
      @Direction:
         dc.w  0,-1,    8,-1
         dc.w  8,0,     8,1
         dc.w  0,1,     -8,1
         dc.w  -8,0,    -8,-1
      @end_pos_p:
      movem.l  (a7)+,d0-a1
   End;
End;


Function Can_make_turn(player:Shortint;map_addr:Pointer):Boolean;
Var
   pos      :pos_t;
   dummy    :Boolean;
Begin
   Can_make_turn:=False;
   For pos.x:=0 to 7 Do
      For pos.y:=0 to 7 Do
         If Pos_possible(player, pos, map_addr)=True Then
            Can_make_turn:=True;
End;

Procedure Make_turn(player:Shortint;pos:pos_t;map_addr:Pointer);
Var   dir      :Shortint;
      pos2     :pos_t;
      Map      :^map_t;
      o_play   :ShortInt;
Begin
   map:=map_addr;
   o_play:=Other_player[player];

   For dir:=0 to 7 Do Begin
      pos2:=pos;
      Repeat
         Inc(pos2.x,direction[dir].x);
         Inc(pos2.y,direction[dir].y);
      Until((pos2.x<0) or (pos2.y<0) or (pos2.x>7) or (pos2.y>7) or
               (map^[pos2.x,pos2.y]<>o_play));
      If ((pos2.x>=0) and (pos2.y>=0) and (pos2.x<8) and (pos2.y<8)) Then
         If (map^[pos2.x,pos2.y]=player) Then
            Repeat
               Dec(pos2.x,Direction[dir].x);
               Dec(pos2.y,Direction[dir].y);
               map^[pos2.x,pos2.y]:=player;
            Until (pos.x=pos2.x) and (pos.y=pos2.y);
     End;
End;

Function Calculate_score(player:Shortint;map_addr:Pointer):Integer;
Var   map   :^Map_t;
      pos   :pos_t;
      score :Integer;
Begin
   ASM
      move.l   d2,-(a7)
      move.l   map_addr(a6),a0
      moveq    #0,d1
      moveq    #0,d0

      add.b    (a0),d0     { 0  *4  }
      add.b    (a0),d0
      add.b    (a0)+,d0
      add.b    (a0)+,d0
      add.b    (a0)+,d0
      add.b    (a0)+,d0
      add.b    (a0)+,d0
      add.b    (a0)+,d0
      add.b    (a0)+,d0
      add.b    (a0),d0     { 7  *3  }
      add.b    (a0),d0
      add.b    (a0)+,d0
      ext.w    d0
      move.w   d0,d1
      add.w    d0,d1       { x = x * 3 }
      add.w    d0,d1
      moveq    #5,d0
      @Middle:
      add.b    (a0),d1     { 0  *3  }
      add.b    (a0),d1
      add.b    (a0)+,d1
      add.b    (a0)+,d1
      add.b    (a0)+,d1
      add.b    (a0)+,d1
      add.b    (a0)+,d1
      add.b    (a0)+,d1
      add.b    (a0)+,d1
      add.b    (a0),d1     { 7  *3  }
      add.b    (a0),d1
      add.b    (a0)+,d1
      dbf      d0,@Middle
      moveq    #0,d0
      add.b    (a0),d0     { 0  *3  }
      add.b    (a0),d0
      add.b    (a0)+,d0
      add.b    (a0)+,d0
      add.b    (a0)+,d0
      add.b    (a0)+,d0
      add.b    (a0)+,d0
      add.b    (a0)+,d0
      add.b    (a0)+,d0
      add.b    (a0),d0     { 7  *3  }
      add.b    (a0),d0
      add.b    (a0)+,d0
      ext.w    d1
      ext.w    d0
      add.w    d0,d1       { x = x * 2 }
      add.w    d0,d1
      add.w    d0,d1

      move.w   d1,score(a6)
      move.l   (a7)+,d2
   END;
   If player=White Then
      Calculate_score:=-score
   Else
      Calculate_score:=score;
End;
