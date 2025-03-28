program wildcarddemo;
{
     Wildcards in Pascal
           von R. Wisser
     (c) MAXON Computer
}

type str=string[255];

var dat        : text;
    fn,s,maske : str;

{ -------- Beginn der Funktion ----------- }

function maskepasst( existenz,all:char; var maske,s:str ):boolean;
var mlen,slen,i:integer;

   function passt( mpos,spos:integer ):boolean;
   var passtnicht,passt_exist:boolean;

      function alltest( mpos,spos:integer ):boolean;
      var existiert:boolean;
      begin { alltest }
           existiert:=(mpos>mlen);
           while (spos<=slen) and not existiert do
                 begin
                 if passt(mpos,spos) then existiert:=true
                 else spos:=spos+1
                 end;
           alltest:=existiert
      end; { alltest }

   begin { passt }
        passtnicht:=false; passt_exist:=false;
        while (mpos<=mlen) and (not passt_exist) and not passtnicht do
              begin
              if maske[mpos]=all then
                 begin
                 passt_exist:=alltest(mpos+1,spos);
                 if not passt_exist then passtnicht:=true;
                 end
              else if spos>slen then passtnicht:=true
                   else if maske[mpos]<>existenz then
                           if maske[mpos]<>s[spos] then passtnicht:=true;
              mpos:=mpos+1; spos:=spos+1;
              end;
        if passt_exist then passt:=true
        else if passtnicht then passt:=false
        else passt:=(mpos>mlen) and (spos>slen);
   end; { passt }

begin { maskepasst }
     mlen:=length(maske); slen:=length(s);
     maskepasst:=passt(1,1)
end;  { maskepasst }

{ ---------------------------------------- }

begin
     write('Filename : '); readln(fn);
     write('Maske    : '); readln(maske);
     writeln; writeln;
     reset(dat,fn);
     while not eof(dat) do
           begin
           readln(dat,s);
           if maskepasst('?','*',maske,s) then
                begin
                write(chr(27),'p'); writeln(s); write(chr(27),'q');
                end
           else writeln(s)
           end
end.



