Program Terminal;
Uses FastRout;

var   Fel:Integer;
Begin
   WriteLn(chr(27),'EVT 52 terminal');
   WriteLn('tryck p† CONTROL + VŽNSTER SHIFT F™R ATT SLUTA');
   WriteLn;
   Fel:=RsConf(-1,-1,-1,-1,1,0);
   Repeat
      If AuxInStat=-1 Then
         Write(Chr(AuxIn));
      If ConInStat=-1 Then
         If AuxOutStat=-1 Then
            AuxOut(ConInWE)
   Until (KbShift(-1) and 6)=6;
End.