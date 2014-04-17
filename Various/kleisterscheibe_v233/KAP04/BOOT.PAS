program boot(input,output);
(* Kleine XBIOS-Anwendung in PASCAL *)
(* Liest Bootsektor ein und erlaubt Modifizierung in *)
(* ausfuehrbaren Bootsektor oder MSDOS-lesbare Diskette *)
(* Written 1987 by Claus Brod *)
(* Dokumentiert in SCHEIBENKLEISTER, Kap.4 *)

type secbuff = packed array [0..511] of char;

var filler, nummer:long_integer;
    laufwerk, sektor, spur, seite, anzahl:integer;
    disktyp, ausfuehrbar:integer;
    media,fatsize,sides:integer;
    zeichen:char;

    fehler:long_integer;
    puffer,buf2:secbuff;

function floprd(var buf:secbuff; dummy: long_integer;
                drive, sector, track, side, count: integer):long_integer;
xbios(8);

function flopwr(var buf:secbuff; dummy: long_integer;
                drive, sector, track, side, count: integer):long_integer;
xbios(9);

function protobt(var buf:secbuff; seriennr: long_integer;
                disktyp, ausfuehrbar:integer):long_integer;
xbios(18);

function rwabs(flag:integer; var buf:secbuff;
               count, log_sec, drive:integer):long_integer;
bios(4);

begin
   writeln('Bootsektor-Utility');
   writeln('(C) 1987 by Claus Brod');
   writeln('Aus SCHEIBENKLEISTER, dem etwas anderen Floppybuch');
   writeln;writeln('Lese Bootsektor');

   laufwerk := 0;
   sektor := 1;
   spur := 0;
   seite := 0;
   anzahl := 1;
   filler := 0;
   fehler := floprd(puffer,filler,laufwerk,sektor,spur,seite,anzahl);

   if (fehler=0) then begin
     writeln('Ausfuehrbar (A) oder MSDOS-lesbar (M) machen ?');
     repeat
       readln(zeichen)
     until (zeichen='A') or (zeichen='a') or (zeichen='m') or (zeichen='M');
     if (zeichen='a') or (zeichen='A') then begin
        disktyp := -1; ausfuehrbar := 1;
        nummer := 4096*4096;
        writeln('Schreibe Bootsektor');
        fehler := protobt(puffer,nummer,disktyp,ausfuehrbar);
        fehler := flopwr(puffer,filler,laufwerk,sektor,spur,seite,anzahl);
        if (fehler<>0) then
          writeln('Fehler bei flopwr:',fehler);
     end else begin
        sides:=ord(puffer[26]);
        media:=sides+$f8-1;
        fatsize:=ord(puffer[22]);
        puffer[21]:=chr(media);
        puffer[0] := chr($eb);
        puffer[1] := chr($34);
        puffer[2] := chr($90);
        fehler := flopwr(puffer,filler,laufwerk,sektor,spur,seite,anzahl);
        if (fehler<>0) then writeln('Fehler bei flopwr:',fehler);

        fehler := rwabs(2,buf2,1,1,laufwerk);
        if (fehler<>0) then writeln('Fehler bei rwabs:',fehler);
        buf2[0]:=chr(media);
        fehler := rwabs(3,buf2,1,1,laufwerk);
        if (fehler<>0) then writeln('Fehler bei rwabs:',fehler);
        fehler := rwabs(2,buf2,1+fatsize,1,laufwerk);
        if (fehler<>0) then writeln('Fehler bei rwabs:',fehler);
        buf2[0]:=chr(media);
        fehler := rwabs(3,buf2,1+fatsize,1,laufwerk);
        if (fehler<>0) then writeln('Fehler bei rwabs:',fehler);
     end
   end
end.


