program bino;
{ BinÑr-Files in DR-Objekt-Format wandeln        }
{ Daten werden fÅr MAXON-PASCAL-Linker im Text-  }
{ segment abgelegt.                              }
{ Aufruf:                                        }
{ BINO <src[.BIN]> [<dest[.O]> [<name>]] [/H]    }
{ wird nur <source.[BIN]> angegeben, sind Wild-  }
{ cards mîglich                                  }
{ Option </H>  fÅr Halten des Bildschirms bis    }
{ Tastendruck                                    }

{ W. Schneider, Berlin 12/1991                   } 
{ (c) 1992 MAXON Computer                        }

{$R-,I-,D-,F+}
uses crt,dos;

var mkres       :longint;
    bnnm,obnm   :pathstr;
    tmpdr       :dirstr;
    tmpnm       :namestr;
    tmpex       :extstr;
    lbnm        :string;
    nms,flcnt   :integer;
    hldscr      :boolean;
    bnrec       :searchrec;


{*** Erzeugen des Objekt-Files ***}
function makeobj (binfl,objfl :pathstr; 
                  labname :string):longint;
var infl,outfl  :file;
    binsz       :longint;
    binbf       :pointer;
    blkres,i    :integer;
    outbt       :shortint;

{$IFNDEF ATARI}
  {* TURBO-PASCAL kennt kein Hi-/LowWord() *}
  function hiword(lv :longint):word;
  begin
    hiword:=lv shr 16;
  end;
  function loword(lv :longint):word;
  begin
    loword:=lv and $ffff;
  end;
{$ENDIF}
procedure wrlong(outvl :longint);
begin
  outbt:=hi(hiword(outvl)); 
  blockwrite(outfl,outbt,1,blkres);
  outbt:=lo(hiword(outvl)); 
  blockwrite(outfl,outbt,1,blkres);
  outbt:=hi(loword(outvl)); 
  blockwrite(outfl,outbt,1,blkres);
  outbt:=lo(loword(outvl)); 
  blockwrite(outfl,outbt,1,blkres);
end;

procedure wrword(outvl :longint);
begin
  outbt:=hi(loword(outvl)); 
  blockwrite(outfl,outbt,1,blkres);
  outbt:=lo(loword(outvl)); 
  blockwrite(outfl,outbt,1,blkres);
end;

begin
  {$IFDEF ATARI}
    reset(infl,binfl);
  {$ELSE}
    assign(infl,binfl);
    reset(infl,1);
  {$ENDIF}
  if ioresult<>0 then
    begin makeobj:=-1; exit; end;
  binsz:=filesize(infl);
  if binsz>$7fff then
  begin
    close(infl);
    makeobj:=-4;
    exit;
  end;  
  if maxavail<binsz then
    begin makeobj:=-3; exit; end;
  getmem(binbf,binsz);
  blockread(infl,binbf^,binsz,blkres);
  close(infl);
  {$IFDEF ATARI}
    erase(objfl);
    rewrite(outfl,objfl);
  {$ELSE}
    assign(outfl,objfl);
    rewrite(outfl,1);
  {$ENDIF}
  if ioresult<>0 then
    begin makeobj:=-2; exit; end;
  wrword($601a);                 { Magic $601A   }
  wrlong(binsz);                 { TEXT-Size     }
  wrlong(0);                     { DATA-Size     }
  wrlong(0);                     { BSS-Size      }
  wrlong(14);                    { Symtablesize  }
  for i:=1 to 5 do wrword(0);    { reserved      }
  blockwrite(outfl,binbf^,binsz,blkres);{ TEXT   }
  for i:=1 to 8 do               { Symboltable:  }
  begin                          { ..Name        }
    if i<=length(labname) then
      outbt:=ord(upcase(labname[i]))
    else
      outbt:=0;
    blockwrite(outfl,outbt,1,blkres);
  end;
  wrword($a200);                 { ..Typ         }
  wrlong(0);                     { ..Offset      }
  { Fixuptable (lauter Nullen) schreiben         } 
  {$IFDEF ATARI}
    asm
          move.l  binsz,d0
          move.l  binbf,a0   
     @l1: clr.b   (a0)+
          dbra    d0,@l1
    end;   
    blockwrite(outfl,binbf^,binsz,blkres); 
  {$ELSE}
    outbt:=0;
    for i:=1 to binsz do 
    blockwrite(outfl,outbt,1,blkres);
  {$ENDIF}
  freemem(binbf,binsz);
  close(outfl);
  if ioresult<>0 then
    makeobj:=-5
  else  
    makeobj:=binsz;
end;{makeobj}

{*** Extension ggf. an Namen anhÑngen ***}
procedure extend(var expth:pathstr; extl:extstr);
var exnm        :namestr;
    exdr        :dirstr;
    exex        :extstr;
begin
  fsplit(expth,exdr,exnm,exex);
  if (exex='') or (exex='.') then
    expth:=exdr+exnm+extl;
end;       

{*** String in Gro·buchst. wandeln ***}
function upstr(lwstr :string):string;
var i :integer;
    s :string; 
begin
  s:='';
  for i:=1 to length(lwstr) do
    s:=s+upcase(lwstr[i]);
  upstr:=s;
end;    

{*** ein File behandeln ***}
procedure processfile;
begin
  extend(bnnm,'.BIN');
  extend(obnm,'.O');
  writeln('converting : ',bnnm);
  writeln('to         : ',obnm);
  writeln('public name: ',lbnm);
  mkres:=makeobj(bnnm,obnm,lbnm);
  if mkres>=0 then
  begin
    writeln(mkres,' bytes converted');
    inc(flcnt);
  end
  else
    case mkres of
      -1: writeln('Can''t open infile !');
      -2: writeln('Can''t create outfile !');
      -3: writeln('Not enough memory !');
      -4: writeln('Infile too large !');
      -5: writeln('Can''t close outfile !');
    end;
  writeln;
end;
        

{**** Hauptprogramm ****}

begin
  nms:=paramcount;
  flcnt:=0;
  hldscr:=upstr(paramstr(nms))='/H';
  if hldscr then
  begin
    dec(nms);
    clrscr;
  end;
  writeln; 
  write
  ('BIN to O Converter for MAXON-PASCAL '); 
  writeln 
  ('Version 1.0  W. Schneider, Berlin 12/1991');
  case nms of
    0: begin
         write
         ('Usage: BINO[.TTP] <src[.BIN]> [<dest[.O]>');
         writeln 
         (' [<public name>]] [/H]');
         writeln('Press any key');
         repeat until readkey<>#0;
         writeln;   
         halt;
       end;
    1: begin
         bnnm:=upstr(paramstr(1));
         fsplit(bnnm,tmpdr,tmpnm,tmpex);
         findfirst(bnnm,0,bnrec);
         while (doserror=0) do
         begin
           with bnrec do
           begin
             bnnm:=tmpdr+name;
             fsplit(bnnm,tmpdr,tmpnm,tmpex);
             obnm:=tmpdr+tmpnm+'.O'; 
             lbnm:=tmpnm;
             processfile;
           end;
           findnext(bnrec);
           if keypressed then if readkey=#27 
             then doserror:=-1;
         end;
         writeln(flcnt,' files converted');
       end;
    2: begin
         bnnm:=upstr(paramstr(1));
         obnm:=upstr(paramstr(2));
         fsplit(obnm,tmpdr,tmpnm,tmpex);
         lbnm:=tmpnm;
         processfile;
       end;
    3: begin
         bnnm:=upstr(paramstr(1));
         obnm:=upstr(paramstr(2));
         lbnm:=upstr(paramstr(3));
         processfile; 
        end;
  end;
  if hldscr then
  begin
    writeln('Press any key');
    repeat until readkey<>#0;
  end;      
end.       
