Procedure Debug(Base_tree:pointer);
Var   O        :^Object;
      Objc     :LongInt;
Begin
   Objc:=0;
   Repeat
      O:=GetObjectAddr(Base_tree,Objc);
      Write(chr(27),'E');
      WriteLn('Object nr :',objc);
      WriteLn('Address   :',Ptr2LongInt(GetObjectAddr(Base_tree,Objc)));
      WriteLn;
      WriteLn('Next objc.:',O^.next);
      WriteLn('Starting  :',O^.starting);
      WriteLn('Ending    :',O^.ending);
      Write('Objecttype:');
      Case O^.obtype of
      20: WriteLn('G_BOX');
      21: WriteLn('G_TEXT');
      22: WriteLn('G_BOXTEXT');
      23: WriteLn('G_IMAGE');
      24: WriteLn('G_PROGDEF');
      25: WriteLn('G_IBOX');
      26: WriteLn('G_BUTTON');
      27: WriteLn('G_BOXCHAR');
      28: WriteLn('G_STRING');
      29: WriteLn('G_FTEXT');
      30: WriteLn('G_FBOXTEXT');
      31: WriteLn('G_ICON');
      22: WriteLn('G_TITLE');
      End;
      WriteLn('Flags     :',O^.flags);
      WriteLn('Status    :',O^.status);
      WriteLn('Specific. :',O^.specific);
      If ((o^.obtype=20) or (o^.obtype=25) or (o^.obtype=27)) Then Begin
         WriteLn('Color     :',LoWord(O^.specific));
         WriteLn('LetterCode:',Hi(HiWord(O^.specific)));
         WriteLn('Thickness :',Lo(HiWord(O^.specific)));
      End Else
         WriteLn('String    :',c2pas(Ptr(o^.specific))); { oops..TEDINFO!}
         
      
      WriteLn('Y         :',O^.X);
      WriteLn('X         :',O^.Y);
      WriteLn('Hight     :',O^.hight);
      WriteLn('Width     :',O^.width);
      WriteLn;
      Write('Object :(-1=quit)');
      ReadLn(objc);
   Until objc=-1;
End;
