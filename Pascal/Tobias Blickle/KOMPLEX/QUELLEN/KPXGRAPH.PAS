{Darstellung der Komplexen W-Ebene einer bel. Funktion}
{Tobias Blickle 1989 }
program komplex_graph;

{$i kpxdekl}
const
{$i gemconst}
type
{$i gemtype}
var
 start:baumzeiger;
 befehl:string;
 i,j,punkte,xmin,xmax,ymin,ymax,x1,x2,y1,y2:integer; 
 a,b : array[1..50,1..50] of real;
 x,y :real;
 taste:char;
 ok:boolean;

{$i kpxsubs}
{$i gemsubs}
function crawcin:char;gemdos(7);
procedure cursor(zeile,spalte:integer);
 begin write(chr(27),'Y',chr(32+zeile),chr(32+spalte));end;
procedure clrscr;begin write(chr(27),'E');end;
procedure cursor_ein;begin write(chr(27),'e');end;
procedure cursor_aus;begin write(chr(27),'f');end;
procedure write_at(x,y:integer;was:string);
  begin cursor(x,y);write(was);end;
procedure form_input(var was:string;zeile,spalte:integer);
 var z:char;
     code:long_integer;
     pos:integer;
     a:string;
 function inkey:long_integer;Gemdos(7);
 begin
  a:=was;pos:=1; 
  cursor(zeile,spalte);writeln(was);
  cursor(zeile,spalte);
  cursor_ein;
  repeat
    code:=inkey;
    case (code & $FF0000) DIV $10000 of
     77: if pos<=length(a) then begin write(chr(27),'C');pos:=pos+1;end; 
     75: if pos>1 then begin write(chr(27),'D');pos:=pos-1;end;
    else begin z:=chr(code & $ff);
         case ord(z) of
          8 : if pos>1 then begin delete(a,pos-1,1);pos:=pos-1;end;
        127 : delete(a,pos,1);
         13 : ;
          else begin insert(z,a,pos);pos:=pos+1;end;
         end;
         cursor_aus;write_at(zeile,spalte,a);write(' ');
         cursor(zeile,spalte+pos-1);cursor_ein;
       end;
     end;
  until z=chr(13);
  cursor_aus;
  was:=a;
end;

procedure status(was:string);
var i:integer;
begin cursor(24,0);for i:=1 to 79 do write(' ');
      cursor(24,0);write(copy(was,1,79));
end;

procedure fehlerausgabe;
begin
 if fehler then begin
    status('');write('FEHLER ',fehler_nr,' ',fehlertext[fehler_nr],
                  ' an Position ',pos,' wegen ',fehlerursache);
    fehler:=false;
 end;
end;

procedure linie;var i:integer;begin for i:=1 to 80 do write('-');end;



begin
if init_gem>=0 then begin
 init_komplex;
 set_clip(0,60,639,399-60);
 line_style(1);line_width(1);line_color(1);
 xmin:=-2;xmax:=2;
 ymin:=-2;ymax:=2;
 punkte:=20;
 repeat
  clrscr;cursor(0,0);linie;
  write_at(1,20,'Komplexer Graph   (c) Tobias Blickle 89');
  cursor(2,0);linie;
  status('Definiert: z i pi LN EXP SIN ASIN COS ACOS TAN ATAN SQR SQRT ABS ARG RE IM');
  write_at(3,0,'Bitte Funktion eingeben :');
  form_input(befehl,3,26);    
  start:=nil;
  set_variable('z',1,0);
  baum_bau(befehl,start,ok);
  if ok then begin
     status('Syntax richtig. Funktion wird berechnet...');
     for i:=1 to punkte do begin
       x:=xmin+i*(xmax-xmin)/punkte;
       y:=ymin;
       for j:=1 to punkte do begin
         set_variable('z',x,y);
         auswertung(start,a[i,j],b[i,j]);
         y:=y+(ymax-ymin)/punkte;
        end;
      end;

     for i:=1 to punkte do 
     begin
       x1:=trunc(80*a[i,1]+300);y1:=trunc(80*b[i,1]+200);
       plot(x1,y1);
       for j:=2 to punkte do begin
        x2:=trunc(80*a[i,j]+300);y2:=trunc(80*b[i,j]+200);
        line_to(x2,y2);
       end;
     end;

     for i:=1 to punkte do 
     begin
       x1:=trunc(80*a[1,i]+300);y1:=trunc(80*b[1,i]+200);
       plot(x1,y1);
       for j:=2 to punkte do begin
        x2:=trunc(80*a[j,i]+300);y2:=trunc(80*b[j,i]+200);
        line_to(x2,y2);
       end;
     end;
     status(concat('Funktion :',befehl));
  end
  else fehlerausgabe;
  clr_baum(start);
  taste:=crawcin;
 until (taste='e') or (taste='E');
 exit_gem;
end;
end.
