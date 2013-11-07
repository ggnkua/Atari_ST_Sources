Program Discus;
Uses FastRout,GemDecl,GemAES,GemVDI,GEMInterface;
Const
      Win1Name : String ='Discus disk'#00#00;

Type
      Object = Record
         next        :Word;
         starting    :Word;
         ending      :Word;
         obtype      :Word;
         flags       :Word;
         status      :Word;
         Specific    :LongInt;  {or $LLTT CCCC  lettercode,Thickness,Color}
         X           :Word;
         Y           :Word;
         Width       :Word;
         Hight       :Word;
      End;

      WinData = Record
         files       :Array[0..255] of String[13];
         mark        :Array[0..255] of boolean;
         antal       :Integer;
         antalmark   :Integer;
         pos         :Integer;
         h           :Integer;
         info        :String;
      End;

{$I D:\LIESEN\PASCAL\DISCUS.PAS}
Var
      paths_tree,
      fastbar_tree,
      exec_tree,
      menu_tree,
      about_tree,
      workicon_tree,
      trashicon_tree,
      discusicon_tree
            : Pointer;

      wins        :Array[0..2] of ^WinData;
      MaX,MiX,
      MaY,MiY     :Integer;

Function GetObjectAddr(Base_tree:pointer;Objc:integer):Pointer;
Begin
   GetObjectAddr:=Ptr(Point2Long(Base_tree)+Objc*24);
End;


Procedure LoadGem;
Var
   s:string;
Begin
   s:='DISCUS.RSC'+#00;
   rsrc_load(s[1]); 
   If GemError=0 Then Begin
      s:='D:\LIESEN\PASCAL\DISCUS.RSC'+#00;
      rsrc_load(s[1]);
      If GemError=0 Then Begin
          Message('Couldn''t find RSC file');
          Halt;
      End;
   End;
   rsrc_gaddr(R_TREE,PATHS,paths_tree);
   rsrc_gaddr(R_TREE,FASTBAR,fastbar_tree);
   rsrc_gaddr(R_TREE,EXEC,exec_tree);
   rsrc_gaddr(R_TREE,MENU,menu_tree);
   rsrc_gaddr(R_TREE,ABOUT,about_tree);
   rsrc_gaddr(R_TREE,CLWORK,workicon_tree);
   rsrc_gaddr(R_TREE,CLTRASH,trashicon_tree);
   rsrc_gaddr(R_TREE,CLDISCUS,discusicon_tree);


(*   New(Win);
   Win^.h:=wind_create($fd1,MinX,MinY,MaxW,MaxH);
   graf_growbox(MaxX div 2,MaxY div 2,0,0,
         MinX,MinY,MaxW,MaxH);
   wind_open(Win^.h,MinX,MinY,MaxW,MaxH);
   Win^.Name:='No Name'#00#00;
   Win^.Info:='Light Camera Revolution'#00#00;
   Wind_Update(BEG_UPDATE);
   Wind_Get(Win^.h, WF_WORKXYWH,
      Win^.ix,win^.iy,win^.ixw,win^.iyw);    { get work area }
   Wind_Set(Win^.h, WF_NAME, HiPtr(Win^.name[1]),
                LoPtr(Win^.name[1]),0,0);
   Wind_Set(Win^.h, WF_INFO, HiPtr(Win^.info[1]),
                LoPtr(Win^.info[1]),0,0);

   InitWindow(Win);
   Wind_Update(END_UPDATE); *)
End;

Procedure About_Prog;
Var   dummy                :Integer;
      MinX,MinY,MaxX,MaxY  :Integer;
Begin
   form_center(about_tree,MinX,MinY,MaxX,MaxY);
   form_dial(0,MaxX div 2,MaxY div 2,
      0,0,MinX,MinY,MaxX,MaxY);
   form_dial(1,MaxX div 2,MaxY div 2,
      0,0,MinX,MinY,MaxX,MaxY);
                              
   graf_mouse(M_OFF, NIL);
   objc_draw(about_tree,0,5,MinX,MinY,MaxX,MaxY);
   graf_mouse(M_ON, NIL);       
   dummy:=form_do(about_tree,0);

   graf_mouse(M_OFF, NIL);       
   objc_change(about_tree,dummy,0,
      MinX,MinY,MaxX,MaxY,0,0);
   form_dial(2,MaxX div 2,MaxY div 2,
      0,0,MinX,MinY,MaxX,MaxY);
   form_dial(3,MaxX div 2,MaxY div 2,
      0,0,MinX,MinY,MaxX,MaxY);
   graf_mouse(M_ON, NIL);       
End;


Procedure MainLoop;
Var   
   ToDo        :Integer;
   Ev_Result   :Integer;
   Time1,Time2,
   MX,MY,MB,MC,
   KbStat,Key  :Integer;
   Menu_Pipe   :Array[0..15] of Integer;
   Obj         :^Object;
   ObNr        :Integer;
Begin
   ToDo:=0;
   Menu_Bar(menu_tree,1);
   graf_mouse(M_ON, NIL);       

   Obj:=GetObjectAddr(fastbar_tree,FBORD);
   Obj^.x:=600;
   Obj^.y:=25;
   objc_draw(fastbar_tree,FBORD,2,MiX,MiY,MaX,MaY);

   Wins[0]^.h:=wind_create($fd1,MiX,MiY,MaX,MaY);
   wins[0]^.info:='Testing'#00#00;
   wind_open(wins[0]^.h,10,MiY,200,MaY);
   Wind_Set(wins[0]^.h,WF_NAME,HiPtr(Win1Name[1]),
                LoPtr(Win1Name[1]),0,0);
   Wind_Set(wins[0]^.h,WF_INFO,HiPtr(wins[0]^.info[1]),
                LoPtr(wins[0]^.info[1]),0,0);



   Repeat
      Ev_Result:=evnt_multi($13,1,1,1,
         0,0,0,0,0,0,0,0,0,0,
         Menu_Pipe,Time1,Time2,MX,MY,MB,KbStat,Key,MC);

      If (Ev_Result and $2)<>0 Then Begin          { MOUSE EVENT }
         ObNr:=objc_find(fastbar_tree,FBORD,2,MX,MY);
         If ObNr>FBORD Then Begin
            Obj:=GetObjectAddr(fastbar_tree,ObNr);            
            obj^.status:=obj^.status xor 1;
            objc_draw(fastbar_tree,ObNr,1,MiX,MiY,MaX,MaY);
         End;
      End;

      If (Ev_Result and $10)=$10 Then Begin        { MESSAGE EVENT }
         Case Menu_Pipe[0] of
{            WM_REDRAW:
            WM_ARROWED:
}            MN_SELECTED: Begin
               menu_tnormal(menu_tree,Menu_Pipe[3],1);
               Case Menu_Pipe[4] of
                  MDABOUT:
                     About_Prog;
                  MFQUIT:
                     ToDo:=-1;
               End;
            End;
         End;
      End;
   Until ToDo=-1;
   graf_mouse(M_OFF, NIL);       
   Menu_Bar(Menu_tree,0);
End;

Begin
   MiX:=0;MiY:=0;
   MaX:=639;MaY:=399;
   If not Init_Gem Then
      Halt(1);
   LoadGem;
   wind_get(0,WF_FULLXYWH,MiX,MiY,MaX,MaY);
   inc(MaX,MiX);
   inc(MaY,MiY);
   MainLoop;
   rsrc_free;
   Exit_Gem;
End.