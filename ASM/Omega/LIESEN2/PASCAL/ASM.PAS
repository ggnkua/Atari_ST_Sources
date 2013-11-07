Program ASMTesta;

{    ASM Procedure
          0. Reserverar s† m†nga bytes som den beh”ver f”r @Result
          1. LINKAR s† mycket som kr„vs f”r lokala variabler (och
               d† „ven A7 sparas p† stacken s† blir det ytterliggare 4
               bytes. PAJA A6 VILKEN ŽR LINKEN!
          2. Rutinen  du kan b”rja plocka variablar fr†n 4+x(a7) bytes
               d„r X „r det som blev linkat i b”rjan.
               ett annat s„tt „r att ta VARIBEL(A6). Detta funkar „ven
               med IN variablerna......
          3. Spara out v„rdet i @Result
          4. Unlinkar och †terv„nder med egen JMP (plock fr†n stack)
          5. Tillbaka s† plockar den out v„rde fr†n stacken
         Observera at detta skilljer sig ibland, specielt n„r man anv„nder
         arrays och str„ngar.

   Ifall man anv„nder en str„ng s† hoppar den lite till...
   Ifall man „nv„nder en array hoppar den ganska mycket till...

   LONGINT: Lagras som ett longword.
   POINTER: Lagras som ett longword (address pekare).
   WORD: Bara att plocka, lagras som word.
   INTEGER: Samma som word.
   CHAR: Sparade som ett word, f”rsta byten „r noll, kanske f”r att likna
      string. 2a byten „r tecknet. Tydligen alltid 2 bytes.
   STRING: f”rst en byte som s„ger hur l†ng (antal tecken) och sedan 
      f”ljer alla tecken. Plockas direkt ur stacken, INGEN pekare!
   BYTE: Lagras som en byte. Anv„nder du 1 byte s† l„ggs en byte till
      i slutet f”r att f† j„mnt, oavsett ifall en ny byte variabel kommer
      direkt efter.  Men i arrays och records s† avrundas det inte f”rren en
      ny typ kommer.
   SHORTINT: Samma som byte.
   BOOLEAN: Lagras som 2 bytes, men highbyten „r den avg”rande. V„rdet
      ett „r lika med true och noll „r lika med false.

   RECORD: Man kan n† stammen med utan "." och man kan n† indexen med "."
   ARRAYS: Man kan anv„nd [] f”r att komma r„tt, men „ven "basen" g†r.

   
   GLOBALA Variabler n†s med direkt address (tex MOVE.L GRAFDRIVER,D0)

   Jag har inte lyckats skriva   DC.L @Label   
   Den „r „ven r„tt d†lig p† ber„kningar vid tex  X+Y(A6).

   De enda register som kan f”rst”ras „r d0,d1,a0,a1

   Labels g”rs med ett @ tecken framf”r.
   Man skickar tillbaka v„rden fr†n en Function i @Result variableln.   

   T„nk p† att anv„nda x(a6) framf”r alla lokala/ing†ende variabler.
}
Type
      Special = Record
         x: ShortInt;
         y: ShortInt;
      End;
      Special2 = Array[0..9] of ShortInt;

Var   Spec:Special;
      Spec2:Special2;
      s1:   String;
      s2:   String;      

Function TestRutin(Byt1:Special2;
                   Byt2:Special2):Boolean;
Var  Sture:Word;
     janne:LongInt;
Begin
   ASM
         move.b   Byt1[0](a6),d0
         move.b   Byt2[3](a6),d1
         move.b   d0,@Result
         move.w   s1,d1
   END;
End;


Begin
      s1:='I dig you Karin';
      s2:='If I gave you heaven';
      Spec.x:=4;
      Spec.y:=5;
      Spec2[0]:=0;
      Spec2[1]:=1;
      Spec2[2]:=2;
      Spec2[3]:=3;
      Spec2[4]:=4;
      WriteLn(TestRutin(Spec2,Spec2));
      ReadLn;
End.