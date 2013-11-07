Program CdKat;
Uses GemDecl,GemAES,GemVDI,GEMInterface;
{$I d:\liesen\pascal\mia\records.pas}

CONST
   hemma = 'home'#00;
   AntalShowTypes = 14;

   FlagTab:Array[0..31] of Integer= (B1,B2,B3,B4,B5,B6,B7,B8,B9,B10
   ,B11,B12,B13,B14,B15,B16,B17,B18,B19,B20,B21,B22,B23,B24
   ,B25,B26,B27,B28,B29,B30,B31 );

   ShowEditBox: Array[0..4] of Integer = (ES1,ES2,ES3,ES4,ES5);

   ShowEditOrder:Array[0..7] of Integer = (C1,D1,E1,F1,G1,H1,I1,J1);
   
   LengthOrder:Array[0..31] of Integer = (SI1,SI2,SI3,SI4,SI5,SI6,SI7,SI8,
         SI9,SI10,SI11,SI12,SI13,SI14,SI14,SI14,SI14,SI14,SI14,SI14,
         SI14,SI14,SI14,SI14,SI14,SI14,SI14,SI14,SI14,SI14,SI14,SI14);

   MenuShowTab:Array[0..4] of Integer = (MSHOW1,MSHOW2,MSHOW3,MSHOW4,MSHOW5);


TYPE  Skiva = Record
         Name     :String[41];
         Artist   :String[41];
         Company  :String[41];
         Producer :String[41];
         ArtNr    :String[16];
         Country  :String[11];
         LendTo   :String[41];
         LendTime :String[7];
         Medverk  :String[59];
         Note     :String[52];         
         
         Tracks   :String[3];
         PlayTime :String[6];
         Year     :String[3];
         Rating   :String[3];
         Flags    :LongInt;

         Next     :Pointer;
         Prev     :Pointer;
      End;


      Sort_Type = Record
         addr     :^Skiva;
         found    :Byte;      { 0=newer been search, 1=match 2=not match }
      End;
      
      Sort_Typen = Array[0..$7fff] of Sort_Type;

      Show_Type = Record
         name     :String[15];
         nrtoshow :Array[0..7] of Integer;
         length   :Array[0..31] of Integer;
         lend     :boolean;
      End;

      Show_Typen = Record
         s        :Array[0..4] of Show_Type;
         nr       :Integer;
      End;



      Window_Type = Record
         h        :Integer;
         name     :String[80];
         info     :String[80];
         x,y,                      { Outer coordinates }
         xw,yw,
         ix,iy,                    { Inner coordinates }
         ixw,iyw  :Integer;

         CharH    :Integer;      { Pixel Size }
         CharW    :Integer;      { Pixel Size }
         CharsX   :Integer;      { Chars along X axel}
         CharsY   :Integer;      { Chars along Y axel}         

         FirstCD  :^Skiva;       { first record object }
         LastCD   :^Skiva;       { Existing, but not yet used }

         Antal    :LongInt;      { Antal posters totalt (-LastCD) }         
         SortSize :LongInt;      { Antal posters f”r sort (=MAX m”jliga) }
         Sort     :^Sort_Typen;  { Address till sort tabel }   
         ViewPos  :Integer;      { Top of window pos in sort }
         Group    :Integer;      { 0 = All  1=Found 2=Not Found }
         NotTested:Boolean;      { true: Not tested INCLUDE }

         Show     :^Show_Typen;  { Address to Show tabel }
      End;      
         
   

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
      TEdInfo = Record
         te_ptext    :Pointer;
         te_ptmplt   :Pointer;
         te_pvalid   :Pointer;
         re_font     :Word;
         te_resvd1   :Word;
         te_just     :Word;
         te_clolor   :Word;
         te_resvd2   :Word;
         te_thickness:Word;
         te_txtlen   :Word;
         te_tmplen   :Word;
      End;

Var
      WorkCD   :^Skiva;
      Empty    :^Skiva;      
      Win      :^window_type;    { Always pointing at ACTIVE window }

      p        :ptsin_Array;     { To draw lines.. stupid hu? }

      Enter_tree,
      Lend_tree,
      Menu_tree,
      About_tree,
      ShowEdit_tree
            : Pointer;

{ ************ FREE MEMORY CONNECTED TO WINDOW }
            
Procedure Remove_Window(addr:pointer); 
Var   Wind     :^Window_Type;
      Reco,
      Reco1    :^Skiva;
Begin
   Wind:=addr;
   Dispose(Wind^.Show);
   FreeMem(Wind^.Sort,Wind^.SortSize*SizeOf(Sort_Type));   
   Reco:=Wind^.FirstCD;
   While Reco<>Wind^.LastCD Do Begin
      Reco1:=Reco;
      Dispose(Reco);
      Reco:=Reco1^.Next;
   End;
   Wind^.LastCD:=Nil;
   Wind^.FirstCD:=Nil;
   Wind^.Show:=Nil;
   Wind^.Sort:=Nil;
End;

{ ************* LOAD }

Procedure LoadIt(name:string;addr:pointer);
Var   Wind     :^Window_Type;
      f        :FILE;
      s        :String;
      Loop     :LongInt;
      Show     :^Show_Typen;
      reco     :^Skiva;
Begin
   Wind:=addr;

   Assign(f,name);
   {$I-} Reset(f); {$I+}
   If (IOresult = 0) then
   Begin
      Remove_Window(Wind);
      New(Reco);
      Reco^:=Empty^;
      Wind^.LastCD:=Reco;
      Wind^.FirstCD:=Reco;

      s:='12345678';
      BlockRead(f,s[1],8);
{      s:='[1]['+s+'][Oki]';
      Loop:=Form_Alert(1,s[1]);
}      
      BlockRead(f,Wind^.SortSize,SizeOf(Wind^.SortSize));
      GetMem(Wind^.Sort,Wind^.SortSize*SizeOf(Sort_Type));

      BlockRead(f,Wind^.Antal,SizeOf(Wind^.Antal));

      New(Wind^.Show);
      BlockRead(f,Wind^.Show^,SizeOf(Wind^.Show^));

      Loop:=1;
      While loop<=Wind^.Antal Do Begin
         Wind^.Sort^[loop-1].addr:=Wind^.LastCD;
         Wind^.Sort^[loop-1].found:=0;
         Reco:=Wind^.LastCD^.prev;
         BlockRead(f,Wind^.LastCD^,SizeOf(Skiva));
         Wind^.LastCD^.prev:=Reco;
         New(Reco);
         Reco^:=Empty^;
         Reco^.prev:=Wind^.LastCD;
         Wind^.LastCD^.next:=Reco;
         Wind^.LastCD:=Reco;
         Loop:=Succ(Loop);
      End;
      Close(f);
   End Else Begin
      s:='[1][ Can''t perform | my task. ][ Arghh ]';
      Loop:=Form_Alert(1,s[1]);
      Wind:=Nil;
   End;
End;   

{ **************** SAVE }

Procedure SaveIt(name:string;addr:pointer);
Var   f:          FILE;
      s:          string;
      loop:       LongInt;
      Wind:       ^Window_Type;
      Show:       ^Show_Typen;
      Reco:       ^Skiva;

Begin
   Wind:=Addr;
   Assign(f,name);
   {$I-} Rewrite(f); {$I+}
   If (IOresult = 0) then
   Begin
      s:='MIA V0.1';
      BlockWrite(f,s[1],8);
      BlockWrite(f,Wind^.SortSize,SizeOf(Wind^.SortSize));
      BlockWrite(f,Wind^.Antal,SizeOf(Wind^.Antal));

      Show:=Wind^.Show;
      BlockWrite(f,Show^,SizeOf(Show^));         
   
      Reco:=Wind^.FirstCD;
      Loop:=1;
      While loop<=Wind^.Antal Do Begin
         BlockWrite(f,Reco^,SizeOf(Skiva));
         Reco:=Reco^.Next;
         Loop:=Succ(Loop);
      End;
      Close(f);
   End Else Begin
      s:='[1][ Can''t perform | my task. ][ Arghh ]';
      Loop:=Form_Alert(1,s[1]);
   End;
End;



Function Ptr2LongInt(p:pointer):LongInt;
Var   a:^LongInt;
Begin
      a:=@p;
      Ptr2LongInt:=a^;
End;

Function c2pas(p:pointer):string;
Var   s:string;
      cs:^byte;
Begin
   cs:=p;
   s:='';
   While cs^<>0 Do Begin
      s:=s+chr(cs^);
      cs:=ptr(Ptr2LongInt(cs)+1);
   End;
   c2pas:=s;
End;

Function GetObjectAddr(Base_tree:pointer;Objc:integer):Pointer;
Begin
   GetObjectAddr:=Ptr(Ptr2LongInt(Base_tree)+Objc*24);
End;

Procedure Set_te_ptext(Base_tree:pointer;Object:Integer;TextStart:Pointer);
Var   o:^object;
      t:^tedinfo;
Begin
   o:=GetObjectAddr(Base_tree,Object);
   t:=Ptr(o^.specific);
   t^.te_ptext:=TextStart;
End;


Procedure Variabel_Init;
Var   dummy,
      dummy2:     Integer;
Begin
   New(Empty);
   Empty^.Name:=#00;
   Empty^.Artist:=#00;
   Empty^.ArtNr:=#00;
   Empty^.Company:=#00;
   Empty^.Producer:=#00;
   Empty^.Country:=#00;

   Empty^.LendTo:=hemma;
   Empty^.LendTime:=#00;

   Empty^.Medverk:=#00;
   Empty^.Note:=#00;
      
   Empty^.Tracks:=#00;
   Empty^.PlayTime:=#00;
   Empty^.Year:=#00;
   Empty^.Rating:=#00;

   Empty^.Flags:=0;

   Empty^.Next:=Empty;
   Empty^.Prev:=Nil;


End;


Procedure RedrawWindow(addr:pointer;x,y,w,h:Integer);
Var   Wind:    ^Window_Type;
      Rect,
      MyArea:  GRect;
      Clip:    Array_4;
      Loop,
      Loop2    :Integer;
      Skriv    :^Skiva;
      s        :String;
      CursX,   
      CursY    :Integer;
      Wid      :Integer;
      Show     :^Show_Typen;
      Index    :LongInt;      
Begin
   Wind:=addr;
   Show:=Wind^.Show;
   Skriv:=Wind^.FirstCD;
   graf_mouse(M_OFF, NIL);
   MyArea.x:=x;
   MyArea.y:=y;
   MyArea.w:=w;
   MyArea.h:=h;

   wind_get(Wind^.h,WF_FIRSTXYWH,Rect.x,Rect.y,Rect.w,Rect.h);
      While not EmptyRect(Rect) Do Begin
         If Intersect(MyArea, Rect) Then Begin
            MakeXYXY(Rect, Clip);
            vs_clip(VDI_Handle, 1, Clip); { Set Clip rectangel }
            vsf_color(VDI_handle,0);      { Set fill col}
            vr_recfl(VDI_Handle, Clip);   { Filled box }
            vst_color(VDI_Handle,15);

            Index:=Wind^.ViewPos;
            Loop:=1;
            While((Loop<=Wind^.CharsY) and (Index<Wind^.Antal)) Do Begin
               If ( (Wind^.Group=0) or
                     ( (Wind^.Sort^[Index].found=0) and
                     (Wind^.NotTested=True) ) or
                     (Wind^.Sort^[Index].found=Wind^.Group) ) Then
                  Begin
                  Skriv:=Wind^.Sort^[Index].addr;
                  CursY:=Wind^.iy+Wind^.CharH*Loop;
                  CursX:=0;
                  If Show^.s[Show^.nr].lend=True Then Begin
                     If Skriv^.LendTo<>hemma Then
                        v_gtext(VDI_Handle,CursX,CursY,'>');
                     CursX:=CursX+2*Wind^.CharW;
                  End;
                     
                  For loop2:=0 to 7 Do Begin
                     Wid:=Show^.s[Show^.nr].Length[ Show^.s[Show^.nr].nrtoshow[loop2] ];
                     Case Show^.s[Show^.nr].nrtoshow[loop2] of
                     0: v_gtext(VDI_Handle,CursX,CursY,Copy(Skriv^.Artist,1,wid-1)+#00);
                     1: v_gtext(VDI_Handle,CursX,CursY,Copy(Skriv^.Name,1,wid-1)+#00);
                     2: v_gtext(VDI_Handle,CursX,CursY,Copy(Skriv^.Company,1,wid-1)+#00);
                     3: v_gtext(VDI_Handle,CursX,CursY,Copy(Skriv^.Producer,1,wid-1)+#00);
                     4: v_gtext(VDI_Handle,CursX,CursY,Copy(Skriv^.ArtNr,1,wid-1)+#00);
                     5: v_gtext(VDI_Handle,CursX,CursY,Copy(Skriv^.Country,1,wid-1)+#00);
                     6: v_gtext(VDI_Handle,CursX,CursY,Copy(Skriv^.Year,1,wid-1)+#00);
                     7: v_gtext(VDI_Handle,CursX,CursY,Copy(Skriv^.Tracks,1,wid-1)+#00);
                     8: v_gtext(VDI_Handle,CursX,CursY,Copy(Skriv^.PlayTime,1,wid-1)+#00);
                     9: v_gtext(VDI_Handle,CursX,CursY,Copy(Skriv^.Rating,1,wid-1)+#00);
                     10:v_gtext(VDI_Handle,CursX,CursY,Copy(Skriv^.LendTo,1,wid-1)+#00);
                     11:v_gtext(VDI_Handle,CursX,CursY,Copy(Skriv^.LendTime,1,wid-1)+#00);
                     12:v_gtext(VDI_Handle,CursX,CursY,Copy(Skriv^.Medverk,1,wid-1)+#00);
                     13:v_gtext(VDI_Handle,CursX,CursY,Copy(Skriv^.Note,1,wid-1)+#00);
                     End;                     
                     CursX:=CursX+wid*Wind^.CharW;
                 End;
                 Inc(Loop,1);
               End;
              Inc(Index,1);
            End;
            p[1]:=Clip[1];
            p[3]:=Clip[3];
            If Show^.s[Show^.nr].Lend=True Then Begin
               CursX:=Wind^.CharW+Wind^.CharW div 2;
               p[0]:=CursX;
               p[2]:=CursX;
               v_pline(VDI_handle, 2, p);
            End Else
               CursX:=-Wind^.CharW div 2;
            For loop2:=0 to 7 Do Begin
               Wid:=Show^.s[Show^.nr].Length[ Show^.s[Show^.nr].nrtoshow[loop2] ];
               Inc(CursX,Wid*Wind^.CharW);
               p[0]:=CursX;
               p[2]:=CursX;
               v_pline(VDI_handle, 2, p);
            End;
         end;
         wind_get(Wind^.h, WF_NEXTXYWH,Rect.x,Rect.y,Rect.w,Rect.h);
      end;


   graf_mouse(M_ON, NIL);
   
End;

Procedure InitWindow(Addr:Pointer);
Var   Wind:    ^Window_Type;
      Show:    ^Show_Typen;
      Sort:    ^Sort_Typen;
      dummy:   Integer;
Begin
   Wind:=Addr;

   New(Wind^.FirstCD);
   Wind^.FirstCD^:=Empty^;
   Wind^.LastCD:=Wind^.FirstCD;
   Wind^.Antal:=0;
   Wind^.ViewPos:=0;
   Wind^.Group:=0;
   Wind^.NotTested:=True;

   New(Wind^.Show);
   Show:=Wind^.Show;
   For dummy:=0 to 4 Do Begin
      Show^.s[dummy].name:='  Default'#00;
      Show^.s[dummy].length[0]:=42;
      Show^.s[dummy].length[1]:=42;
      Show^.s[dummy].length[2]:=42;
      Show^.s[dummy].length[3]:=42;
      Show^.s[dummy].length[4]:=17;
      Show^.s[dummy].length[5]:=12;
      Show^.s[dummy].length[6]:=4;
      Show^.s[dummy].length[7]:=5;
      Show^.s[dummy].length[8]:=8;
      Show^.s[dummy].length[9]:=5;
      Show^.s[dummy].length[10]:=22;
      Show^.s[dummy].length[11]:=8;
      Show^.s[dummy].length[12]:=53;
      Show^.s[dummy].length[13]:=60;
      Show^.s[dummy].nrtoshow[0]:=0;
      Show^.s[dummy].nrtoshow[1]:=1;
      Show^.s[dummy].nrtoshow[2]:=2;
      Show^.s[dummy].nrtoshow[3]:=3;
      Show^.s[dummy].nrtoshow[4]:=4;
      Show^.s[dummy].nrtoshow[5]:=5;
      Show^.s[dummy].nrtoshow[6]:=6;
      Show^.s[dummy].nrtoshow[7]:=7;
      Show^.s[dummy].lend:=True;
   End;
   Show^.nr:=0;

   Wind^.SortSize:=1000;
   GetMem(Wind^.Sort,Wind^.SortSize*sizeof(Sort_Type));
   Sort:=Wind^.Sort;

   Wind^.CharH:=16;
   Wind^.CharW:=8;
   Wind^.CharsX:=Win^.ixw Div Win^.CharW;
   Wind^.CharsY:=Win^.iyw Div Win^.CharH;

End;


Procedure LoadGem;
Var
   s:string;
Begin
   s:='RECORD.RSC'+#00;
   rsrc_load(s[1]); 
   If GemError=0 Then Begin
      s:='D:\LIESEN\PASCAL\MIA\RECORDS.RSC'+#00;
      rsrc_load(s[1]);
      If GemError=0 Then Begin
          Message('Couldn''t find RSC file');
          Halt;
      End;
   End;
   rsrc_gaddr(R_TREE,ENTER,enter_tree);
   rsrc_gaddr(R_TREE,LENTAD,lend_tree);
   rsrc_gaddr(R_TREE,MENU,menu_tree);
   rsrc_gaddr(R_TREE,ABOUT,about_tree);
   rsrc_gaddr(R_TREE,SHOWEDIT,showedit_tree);

   Menu_Bar(menu_tree,1);

   New(Win);
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
   Wind_Update(END_UPDATE);


End;
Procedure RemoveGem;
Begin
   wind_close(Win^.h);
   wind_delete(Win^.h);
   Menu_Bar(Menu_tree,0);
   rsrc_free;
End;





Procedure FixPasString(Var s:String);
VAR   c:       ^byte;
      count:   Integer;
Begin
   c:=@s[0];
   c^:=255;
   count:=0;
   Repeat
      count:=count+1;
   Until s[count]=#00; 
   c^:=count;
End;


Procedure GetLend(Addr:Pointer);
VAR
   Work:       ^Skiva;
   x,y,xw,yw:  Integer;
   dummy:      Integer;
Begin
   Work:=Addr;
   form_center(lend_tree,x,y,xw,yw);

   If Work^.LendTo=hemma Then Begin
      Work^.LendTo:=#00;
      Work^.LendTime:=#00;
   End;

   Set_te_ptext(lend_tree,LENDNAME,@Work^.lendto[1]);
   Set_te_ptext(lend_tree,LENDTIME,@Work^.lendtime[1]);

   form_dial(0,1,1,1,1,
            x,y,xw,yw);
   graf_mouse(M_OFF, NIL);       
   objc_draw(lend_tree,0,1,x,y,xw,yw);
   graf_mouse(M_ON, NIL);       
   dummy:=form_do(lend_tree,LENDNAME);
   objc_change(lend_tree,dummy,0,x,y,xw,yw,0,1);
   graf_mouse(M_OFF, NIL);       
   form_dial(3,1,1,1,1,
            x,y,xw,yw);   
   graf_mouse(M_ON, NIL);       

   FixPasString(Work^.LendTo);
   FixPasString(Work^.LendTime);

   If (Work^.LendTo=#00) or (dummy=NOTLEND) Then Begin
      Work^.LendTo:=hemma;
      Work^.LendTime:=#00;
   End;
End;

   
Function FillInForm(Addr:Pointer):Boolean;   { True=OK }
VAR
   Work:       ^Skiva;
   Dest:       ^Skiva;
   x,y,xw,yw:  Integer;
   dummy:      Integer;
   s:          String;
   pressed:    Integer;
   loop:       Integer;
   o:          ^Object;
   t:          ^TedInfo;
Begin
   New(Work);
   Dest:=Addr;
   Work^:=Dest^;

   form_center(enter_tree,x,y,xw,yw);

   Set_te_ptext(enter_tree,ARTIST,@Work^.artist[1]);
   Set_te_ptext(enter_tree,NAME,@Work^.name[1]);
   Set_te_ptext(enter_tree,COMPANY,@Work^.company[1]);
   Set_te_ptext(enter_tree,PRODUCER,@Work^.producer[1]);
   Set_te_ptext(enter_tree,IDNR,@Work^.artnr[1]);
   Set_te_ptext(enter_tree,COUNTRY,@Work^.country[1]);
   Set_te_ptext(enter_tree,YEAR,@Work^.year[1]);
   Set_te_ptext(enter_tree,TRACKS,@Work^.tracks[1]);
   Set_te_ptext(enter_tree,PLAYTIME,@Work^.playtime[1]);
   Set_te_ptext(enter_tree,RATING,@Work^.rating[1]);
   Set_te_ptext(enter_tree,MEDVERK,@Work^.medverk[1]);
   Set_te_ptext(enter_tree,NOTE,@Work^.note[1]);

   For loop:=0 To 31 Do
   Begin
      o:=GetObjectAddr(enter_tree,FlagTab[loop]);
      If (work^.flags and 1) =0 Then
         o^.status:=0
      Else
         o^.status:=1;
      work^.flags:=work^.flags Shr 1;
   End;

   form_dial(0,1,1,1,1,
            x,y,xw,yw);
   Repeat
      graf_mouse(M_OFF, NIL);       
      o:=GetObjectAddr(enter_tree,Lend);
      o^.specific:=Ptr2LongInt(@Work^.LendTo[1]);
      If Work^.LendTo=Hemma Then
         o^.status:=0
      Else
         o^.status:=1;
      objc_draw(enter_tree,0,1,x,y,xw,yw);
      graf_mouse(M_ON, NIL);       
      pressed:=form_do(enter_tree,ARTIST);

      FixPasString(Work^.Artist);
      FixPasString(Work^.Name);
      FixPasString(Work^.Company);
      FixPasString(Work^.Producer);
      FixPasString(Work^.ArtNr);
      FixPasString(Work^.Country);
      FixPasString(Work^.Year);
      FixPasString(Work^.Tracks);
      FixPasString(Work^.PlayTime);
      FixPasString(Work^.Rating);
      FixPasString(Work^.Medverk);
      FixPasString(Work^.Note);

      Work^.flags:=0;
      For loop:=31 Downto 0 Do
      Begin
         Work^.flags:=Work^.flags Shl 1;
         o:=GetObjectAddr(enter_tree,flagtab[loop]);
         If (o^.status and 1)=1 Then
            Work^.flags:=Work^.flags or 1;
      End;

      If pressed=LEND Then
         GetLend(Work);

      objc_change(enter_tree,pressed,0,x,y,xw,yw,0,1);

      If pressed=OKEY Then Begin
         If ((Work^.Artist=#00) or
             (Work^.Name=#00)) Then
         Begin
            s:='[1][ | Forced fields not | correctly filled ][How Silly]'#00;
            pressed:=form_alert(1,s[1]);
            pressed:=LEND;
         End Else Begin
            Dest^:=Work^;
         End;
             
             
      End;
   Until (pressed=OKEY) or (pressed=CANCEL);
   graf_mouse(M_OFF, NIL);       
   form_dial(3,1,1,1,1,
            x,y,xw,yw);   
   graf_mouse(M_ON, NIL);       

   Dispose(Work);   
   If Pressed=Okey Then
      FillInForm:=True
   Else
      FillInForm:=False;
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


Procedure ShowEdit_rout(addr:pointer);
Var   Wind                 :^Window_type;
      dummy,
      dummy2               :Integer;
      dummy3               :Real;
      pressed              :Integer;
      x,y,xw,yw            :Integer;
      EdShow               :Show_Typen;
      O                    :^Object;
      T                    :^TedInfo;
      s                    :string;
      Inputers             :Array[0..31] of string[5];
Begin
   Wind:=Addr;
   EdShow:=Wind^.Show^;
   form_center(showedit_tree,MinX,MinY,MaxX,MaxY);
   form_dial(0,x div 2,y div 2,
      0,0,x,y,xw,yw);
   form_dial(1,x div 2,y div 2,
      0,0,x,y,xw,yw);

   Repeat
      For dummy:=0 to AntalShowTypes-1 Do Begin
         o:=GetObjectAddr(ShowEdit_tree,LengthOrder[dummy]);
         t:=ptr(o^.specific);
         t^.te_ptext:=@Inputers[dummy][1];
         Str(EdShow.s[EdShow.nr].Length[dummy],Inputers[dummy]);
         Inputers[dummy]:=Inputers[dummy]+#00;
      End;

      o:=getObjectAddr(ShowEdit_tree,SELEND);
      If EdShow.s[EdShow.nr].Lend=True Then
         o^.status:=1
      else
         o^.status:=0;
    

      o:=GetObjectAddr(ShowEdit_tree,SENAME);
      t:=Ptr(o^.specific);
      t^.te_ptext:=@EdShow.s[EdShow.nr].Name[3];
      For dummy:=0 to 4 Do Begin
         o:=GetObjectAddr(ShowEdit_tree,ShowEditBox[dummy]);
         o^.status:=o^.status and $FE;
         o^.flags:=o^.flags or 5;
      End;
      o:=GetObjectAddr(ShowEdit_tree,ShowEditBox[EdShow.nr]);
      o^.status:=o^.status or 1;
      o^.flags:=o^.flags and $FA;

      For dummy2:=0 to 7 Do Begin
         For dummy:=0 to AntalShowTypes-1 Do Begin
            o:=GetObjectAddr(ShowEdit_tree,ShowEditOrder[dummy2]+dummy);
            o^.status:=o^.status and $FE;
         End;
         o:=GetObjectAddr(ShowEdit_tree,ShowEditOrder[dummy2]+EdShow.s[EdShow.nr].nrtoshow[dummy2]);
         o^.status:=o^.status or 1;
      End;
    
      graf_mouse(M_OFF, NIL);
      objc_draw(showedit_tree,0,5,MinX,MinY,MaxX,MaxY);
      graf_mouse(M_ON, NIL);       
      pressed:=form_do(showedit_tree,0);

      For dummy:=0 to AntalShowTypes-1 Do Begin
         FixPasString(Inputers[dummy]);
         Val(Inputers[dummy],dummy3,dummy2);
         EdShow.s[EdShow.nr].Length[dummy]:=Trunc(Dummy3);
      End;

      o:=getObjectAddr(ShowEdit_tree,SELEND);
      If (o^.status and 1)=1 Then 
         EdShow.s[EdShow.nr].Lend:=True
      else
         EdShow.s[EdShow.nr].Lend:=False;

      FixPasString(EdShow.s[EdShow.nr].name);
      For dummy:=0 to 7 Do
         For dummy2:=0 to AntalShowTypes-1 Do Begin
            o:=GetObjectAddr(ShowEdit_tree,ShowEditOrder[dummy]+dummy2);
            If (o^.status and 1=1) Then
               EdShow.s[EdShow.nr].nrtoshow[dummy]:=dummy2;
         End;
       
               
      For dummy:=0 to 4 do
         If pressed=ShowEditBox[dummy] Then
            EdShow.nr:=dummy;
   Until ((pressed=SEOK) or (pressed=SECANCEL));
   If pressed=SEOK then
      Wind^.Show^:=EdShow;

   graf_mouse(M_OFF, NIL);       
   objc_change(showedit_tree,pressed,0,
      MinX,MinY,MaxX,MaxY,0,0);
   form_dial(2,MaxX div 2,MaxY div 2,
      0,0,MinX,MinY,MaxX,MaxY);
   form_dial(3,MaxX div 2,MaxY div 2,
      0,0,MinX,MinY,MaxX,MaxY);
   graf_mouse(M_ON, NIL);       
End;


Procedure Update_Menu(addr:pointer);
Var
   Wind:    ^Window_Type;
   Dummy:   Integer;
Begin
   Wind:=addr;
   For dummy:=0 to 4 Do Begin
      Menu_Text(menu_tree,menushowtab[dummy],Wind^.Show^.s[dummy].Name[1]);
      Menu_Icheck(menu_tree,menushowtab[dummy],0);
   End;
   Menu_Icheck(menu_tree,menushowtab[Wind^.Show^.nr],1);
End;


Procedure MainLoop;
VAR
   ToDo:          Integer;
   Ev_Result:     Integer;
   Time1,Time2,
   MX,MY,MB,MC,
   KbStat,Key:    Integer;
   dummy:         Integer;
   s:             String;
   Menu_Pipe :Array[0..15] of Integer;
Begin
   Update_Menu(win);
   Repeat
      Ev_Result:=evnt_multi($13,1,3,3,
         0,0,0,0,0,0,0,0,0,0,
         Menu_Pipe,Time1,Time2,MX,MY,MB,KbStat,Key,MC);
      
      ToDo:=0;
      If (Ev_Result and 1)=1 Then Begin            { KEYBOARD EVENT }
         Case Key of
         $2d18:  ToDo:=-1;          { Quit }
         $5200:  ToDo:=1;           { Insert New }
         $3b00:  ToDo:=2;           { Show F1 }
         $3c00:  ToDo:=3;           { Show F2 }
         $3d00:  ToDo:=4;           { Show F3 }
         $3e00:  ToDo:=5;           { Show F4 }
         $3f00:  ToDo:=6;           { Show F5 }
         $4800:  ToDo:=7;           { Scroll Up }
         $5000:  ToDo:=8;           { Scroll Down }
         
         Else Begin
            Str(Key,s);
            s:='[2][ Key code :'+s+' ][ OK ]';
            dummy:=Form_Alert(1,s[1]);
          End;
         End;
      End;

      If (Ev_Result and $10)=$10 Then Begin        { MESSAGE EVENT }
         Case Menu_Pipe[0] of
          WM_REDRAW:
          Begin
           If Menu_Pipe[3]=Win^.h Then
            RedrawWindow(Win,Menu_Pipe[4],Menu_Pipe[5],
               Menu_Pipe[6],Menu_Pipe[7]);
          End;
          WM_ARROWED:
          Begin
            Case Menu_Pipe[4] of
            0: ToDo:=9;
            1: ToDo:=10;
            2: ToDo:=7;
            3: ToDo:=8;
            End;
          End;
          MN_SELECTED:
          Begin
           menu_tnormal(menu_tree,Menu_Pipe[3],1);
           Case Menu_Pipe[4] of
            MABOUT:
               About_Prog;
            MLOAD:
            Begin
               LoadIt('D:\LIESEN\PASCAL\MIA\OMEGA.MIA',win);
               Update_Menu(win);
               RedrawWindow(Win,Win^.ix,Win^.iy,Win^.ixw,Win^.iyw);
            End;
            MSAVE:
               SaveIt('OMEGA.MIA',win);
            MQUIT:
               ToDo:=-1;
            MEDITS: Begin
               ShowEdit_rout(win);
               RedrawWindow(Win,Win^.ix,Win^.iy,Win^.ixw,Win^.iyw);
               Update_Menu(win);
            End;
            MINSTER:
               ToDo:=1;
           End;
           For dummy:=0 to 4 Do  { new show }
              If Menu_Pipe[4]=MenuShowTab[dummy] Then Begin
                 ToDo:=2+dummy;
              End;
          End;
         End;
      End;

      If ToDo=1 Then Begin       {** Insert New **}
         If FillInForm(Win^.LastCD)=True Then Begin
            Win^.Sort^[Win^.Antal].addr:=Win^.LastCD;
            Win^.Sort^[Win^.Antal].found:=0;
            Inc(Win^.Antal,1);
            WorkCD:=Win^.LastCD;
            New(Win^.LastCD);
            Win^.LastCD^:=Empty^;
            WorkCD^.Next:=Win^.LastCD;
            Win^.LastCD^.Prev:=WorkCD;
            RedrawWindow(Win,Win^.ix,Win^.iy,Win^.ixw,Win^.iyw);
         End;
      End;
      If ((ToDo>1) and (ToDo<7)) Then Begin  {** New Show **}
         Win^.Show^.nr:=ToDo-2;
         Update_Menu(win);
         RedrawWindow(Win,Win^.ix,Win^.iy,Win^.ixw,Win^.iyw);
      End;
      If ToDo=7 Then       {* line down }
         If Win^.ViewPos>0 Then Begin
            Dec(Win^.ViewPos,1);
            RedrawWindow(Win,Win^.ix,Win^.iy,Win^.ixw,Win^.iyw);
         End;
      If ToDo=8 Then       {** line down }
         If Win^.ViewPos<Win^.Antal Then Begin
            Inc(Win^.ViewPos,1);
            RedrawWindow(Win,Win^.ix,Win^.iy,Win^.ixw,Win^.iyw);
         End;
      If ToDo=9 Then       {** Page up }
         If Win^.ViewPos>0 Then Begin
            Dec(Win^.ViewPos,1);
            RedrawWindow(Win,Win^.ix,Win^.iy,Win^.ixw,Win^.iyw);
         End;
      If ToDo=10 Then      {** page down }
         If Win^.ViewPos<Win^.Antal Then Begin
            Inc(Win^.ViewPos,1);
            RedrawWindow(Win,Win^.ix,Win^.iy,Win^.ixw,Win^.iyw);
         End;
         

   Until ToDo=-1;
End;


Begin
   If not Init_Gem Then
      Halt;
   Variabel_Init;
   LoadGem;
   graf_mouse(M_ON, NIL);       

   MainLoop;


   graf_mouse(M_OFF, NIL);       
   RemoveGem;
   Exit_Gem;
End.