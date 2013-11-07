Program  NeoHDSlide;
Uses     FastRout,DOS;

Type
   BildNames   =Array[0..255] of String[15];

Var
   Pic         :Array[0..1] of Pointer;
   PicMem      :Array[0..1] of Pointer;
Var   t        :Integer;
      fel      :Integer;
      anitime  :LongInt;
      screen   :Integer;
      Addr     :Pointer;
      Slut     :Integer;
      Antal    :Integer;
      Search,
      SearchP  :String;
      Filer    :^BildNames;
Begin
   Case ParamCount of
      0: Begin
         search:='*.NEO';
         searchp:='';
      End;
      1: Begin
         If ParamStr(1)='?' Then Begin
            WriteLn('HDSLIDE path condition');
            WriteLn('path could be C:\ANIM\');
            WriteLn('condition could be WAR*.NEO');
            WriteLn;
            WriteLn('Martin Liesen 1992   HiSpeed Pascal');
            WaitForKey;
            Halt;
         End;
         search:='*.NEO';
         searchp:=ParamStr(1);
      End;
      2: Begin
         search:=ParamStr(2);
         searchp:=ParamStr(1);
      End;
   End;
   GetMem(Filer,SizeOf(BildNames));
   Antal:=0;
   Slut:=SFirst(searchp+search,0);
   WriteLn('Search path  :',searchp);
   WriteLn('Condition    :',search);
   While Slut=0 Do Begin
      Filer^[Antal]:=GetDtaName;
      WriteLn(Filer^[Antal]);
      Slut:=SNext;
      Inc(Antal,1);
      If Antal=256 Then Begin
         WriteLn('Maximum of 255 files');
         WaitForKey;
         Halt(1);
      End;
   End;
   If Antal=0 Then
      Halt(1);
   For t:=0 to 1 Do Begin
      GetMem(PicMem[t],32128+256);
      Pic[t]:=Long2Point(((Point2Long(PicMem[t])+256+128) and $ffffff00)-128);
   End;
   SuperOn;
   Resolution:=0;
   UpdateScreenAttrib;
   screen:=0;
   Repeat
      Fel:=LoadFile(searchp+Filer^[t],Pic[screen],32128);
      If Fel<0 Then Begin 
         WriteLn('Ladda fel ...',Fel);
         WaitForKey;
         Halt(1);
      End;
      Addr:=Pic[screen];
      ASM
         move.l   Addr,a0
         addq.l   #4,a0
         move.l   a0,$45a
         lea      124(a0),a0
         move.l   a0,$45e
      End;
      
      Screen:=(Screen+1) and 1;
         
   Until ConInStat<>0;
   WaitForKey;
   SuperOff;

   For t:=0 to 1 Do
      FreeMem(PicMem[t],32128+256);
   FreeMem(Filer,SizeOf(BildNames));
End.