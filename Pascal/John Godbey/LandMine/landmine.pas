(*** LandMine v. 1.0       ***)
(*** Programed in          ***)
(*** HighSpeed Pascal      ***)
(*** by John Godbey        ***)
(*** 7221 Hansford Ct.     ***)
(*** Springfield, VA 22151 ***)
(*** Genie: J.GODBEY       ***)


Program Landmine;

Uses Graph, GemAES, GemVDI;
Type
     cardarray = array [1..64] of integer;
     fieldarray= array [0..9,0..9] of integer;
Var
     a,b     :integer; {screen off-set for minefield}
     w       :Integer; {width of each box}
     t       :Integer; {width of entire field}
     ch,more :char;
     D       :cardarray;  {randomly place mines}
     J       :integer;        
     mines   :fieldarray; {place mines in this array}
     nums    :fieldarray; {number of mines next to a square}
     opensq  :fieldarray;   
        
(**************************************************************************)
Procedure FirstSetUp (var a,b,w,t : Integer);
Var
     Driver,Mode : Integer;

Begin

Clrscr;
Driver := DETECT;
InitGraph(Driver,Mode,'');
If GetGraphMode=STMedium then
     Begin
     a:=getmaxx div 2;
     b:=getmaxy div 2;
     SetTextJustify(1,1);
     OutTextxy(a,b,('Sorry...this program will not work in medium res'));
     OutTextxy(a,b+10,('press any key to abort.'));
     ch:=Readkey;
     Closegraph;
     Halt;
end;
w:=15;
If GetGraphMode=STHigh then w:=2*w;
t:=8*w;
a:=getmaxx-t;
b:=getmaxy-t;
a:=a div 2;
b:=b div 2;
setbkcolor(15);
setpalette(15,0);
v_hide_c(1); {hide mouse}
End;{Procedure FirstSetUp}
(**************************************************************************)

(**************************************************************************)
Procedure Startup;
Var
     x,y  :integer;
Begin
clrscr;
SetTextStyle(1,0,7);
SetColor(1);
X:=TextWidth('LANDMINE') div 2;
x:=(getmaxx div 2) - x;
y:=getmaxy div 3;
OutTextxy(x,y,('LANDMINE'));
SetTextStyle(0,0,1);
X:=TextWidth('v. 1.0') div 2;
x:=(getmaxx div 2) - x;
y:=(getmaxy div 2) - 10;
OutTextxy(x,y,('v. 1.0'));
SetTextStyle(0,0,7);
X:=TextWidth('by John Godbey') div 2;
x:=(getmaxx div 2) - x;
y:=(getmaxy div 2)+ 20;
OutTextxy(x,y,('by John Godbey'));

Delay (4*1000);
End; {Procedure Startup}
(**************************************************************************)


(**************************************************************************)
Procedure Shuffle(var D : cardarray);
Var
     N,T,J,K :Integer;
        
Begin

     N:=64;
     For J:=1 to N
     Do
          D[J] := J;
     For J:=N downto 2 do 
     Begin
          Randomize;
          K:= round(J * Random + 1);
          T := D[J];
          D[J] := D[K];
          D[K] := T
     End;
     
End;{Procedure Shuffle}
(**************************************************************************)
        
(**************************************************************************)
Procedure DrawField (var a,b,w,t : integer);
Var
     x,y,z       : Integer;
     m,n,o,p     : Integer;
     ch          : char;
     Poly        : Array[1..6] Of PointType;
Begin

setbkcolor(15);
setpalette(15,0);
clrscr;
setactivepage(1); {hide drawing process}
clrscr;
v_hide_c(1); {hide mouse}
SetColor(1);
For x:=1 to 9
     do
     Begin
     line(a,b-w+w*x,a+t,b-w+w*x); {draw lines}
     line(a-w+w*x,b,a-w+w*x,b+t);
     end;

{a = x offset}
{b = y offset}
{w = width of boxes in pixals}
For x:=1 to 8
     do
     For y:=1 to 8
          Do        
          begin
          SetFillStyle(1,1);
          Bar (a-w+4+w*x,b-w+4+w*y,a-4+w*x,b-4+w*y); {cover boxes}
          line (a-w+w*x,b-w+w*y,a-w+4+w*x,b-w+4+w*y);
          SetFillStyle(9,1);
          Poly[1].X := a-w+4+w*x;
          Poly[1].Y := b-4+w*y;
          Poly[2].X := a-w+w*x;
          Poly[2].Y := b+w*y;
          Poly[3].X := a+w*x;
          Poly[3].Y := b+w*y;
          Poly[4].X := a+w*x;
          Poly[4].Y := b-w+w*y;
          Poly[5].X := a-4+w*x;
          Poly[5].Y := b-w+4+w*y;
          Poly[6].X := a-4+w*x;
          Poly[6].Y := b-4+w*y;
          FillPoly(6,Poly) {make shadows}
     end;
If GetGraphMode=STHigh then SetTextStyle(0,0,7)
Else SetTextStyle(0,0,2);
Outtextxy (a,b-w,'Mines: 10');
setvisualpage(1); {show results}
v_show_c(1,1); {show mouse}
  
End; {Procedure DrawField}
(**************************************************************************)


(**************************************************************************)
Procedure LayMines (D : CardArray;
                     var mines: fieldarray); 

var     x,y   :integer;
     
Begin
     For x:=0 to 9 Do
     For y:=0 to 9 Do
     mines[x,y]:=0;
     
     For x:=1 to  8 Do 
     If D[x]<11 then
     mines[1,x] :=1
     else
     mines[1,x] :=0; 
     
     For x:=9 to 16 Do
     If D[x] < 11 then
     mines[2,x-8] :=1
     else
     mines[2,x-8] :=0;
     
     For x:=17 to  24 Do 
     If D[x]<11 then
     mines[3,x-16] :=1
     else
     mines[3,x-16] :=0; 
     
     For x:=25 to  32 Do 
     If D[x]<11 then
     mines[4,x-24] :=1
     else
     mines[4,x-24] :=0;
     
     For x:=33 to  40 Do 
     If D[x]<11 then
     mines[5,x-32] :=1
     else
     mines[5,x-32] :=0;
     
     For x:=41 to  48 Do 
     If D[x]<11 then
     mines[6,x-40] :=1
     else
     mines[6,x-40] :=0;
     
     For x:=49 to  56 Do 
     If D[x]<11 then
     mines[7,x-48] :=1
     else
     mines[7,x-48] :=0;
     
     For x:=57 to 64 Do 
     If D[x]<11 then
     mines[8,x-56] :=1
     else
     mines[8,x-56] :=0;
          
End; {Procedure LayMines}
(**************************************************************************)

(**************************************************************************)
Procedure WriteNum (m,n,w:integer;
                    var
                    opensq:fieldarray);

Var  S    :String;

Begin
v_hide_c(1);
str(nums[m+1,n+1],S);
SetColor(1);
If GetGraphMode=STHigh then
begin
SetTextStyle(0,0,7);
outtextxy (a+7+m*w,b+9+n*w,S);
end
Else
begin
SetTextStyle(0,0,1);
outtextxy (a+6+m*w,b+7+n*w,S);
end;
opensq[m+1,n+1]:=1;
v_show_c(1,1);
End;{Procedure WriteNum}
(**************************************************************************)


(**************************************************************************)
Procedure Uncover (var
                   mines   : fieldarray;
                   nums    : fieldarray;
                   opensq  : fieldarray;
                   a,b,w,t : integer);

var
     m,n,o,p,x,y : Integer;
     xmin,xmax   : Integer;
     NumMines    : Integer;
     Opened      : Integer;
     S           : String;
     GameOver    : Boolean;
     Polya       : Array[1..5] of PointType;
     Flags       : fieldarray;

begin

For x:=0 to 9 Do
     For y:=0 to 9 Do
     flags[x,y]:=0;

v_show_c(1,1); {show mouse}
GameOver:=False;
NumMines:=10; {no mines are marked with a flag}
Opened:=0; {no squares have been uncovered}
m:=0;
n:=0;
o:=0; 

Repeat
     graf_mkstate(m,n,o,p); {get mouse button status}

     If ((m>a) and (n>b) and (m<a+t) and (b<b+t)) then {is mouse on field?}
     Begin
          m:=m-a;
          m:=m DIV w;
          n:=n-b;
          n:=n DIV w;
          SetFillStyle (1,0);

     If o=2 then {if right button is pressed}
     Begin
          v_hide_c(1); {hide mouse}
          If flags[m+1,n+1]=0 then {if there's no flag there}
     Begin
     Setcolor(0);
     SetFillStyle(7,1);
     If GetGraphMode=STHigh then
     Begin
     Polya[1].x := a+11+w*m;
     Polya[1].Y := b+24+n*w;
     Polya[2].x := a+11+w*m;
     Polya[2].y := b+6+w*n;
     Polya[3].x := a+24+w*m;
     Polya[3].y := b+6+w*n;
     Polya[4].x := a+24+w*m;
     Polya[4].y := b+15+w*n;
     Polya[5].x := a+11+w*m;
     Polya[5].y := b+15+w*n
     end
     Else
     Begin
     SetColor (10);
     SetFillStyle(1,10);
     Polya[1].x := a+6+w*m;
     Polya[1].Y := b+12+n*w;
     Polya[2].x := a+6+w*m;
     Polya[2].y := b+3+w*n;
     Polya[3].x := a+12+w*m;
     Polya[3].y := b+3+w*n;
     Polya[4].x := a+12+w*m;
     Polya[4].y := b+7+w*n;
     Polya[5].x := a+5+w*m;
     Polya[5].y := b+7+w*n;
     end;
     FillPoly(5,Polya); {draw flag}
     flags[m+1,n+1]:=+1;
     NumMines:=NumMines-1;
     str(nummines,S);
     SetColor(1);
     If GetGraphMode=STHigh then 
     Begin
     SetTextStyle(0,0,7);
     Outtextxy (a+100,b-w,('  '+S+'  '));
     End
     Else 
     Begin
     SetTextStyle(0,0,2);
     Outtextxy (a+40,b-w,('  '+S+'  '));
     End;
end
else{if there was a flag, remove it}
begin
     flags[m+1,n+1]:=0;
     SetFillStyle (1,1);
bar(a+3+m*w,b+3+n*w,a+m*w+w-3,b+n*w+w-3);
NumMines:=NumMines+1;
str(nummines,S);
SetColor(1);
     If GetGraphMode=STHigh then 
     Begin
     SetTextStyle(0,0,7);
     Outtextxy (a+100,b-w,('  '+S+'  '));
     End
     Else 
     Begin  
     SetTextStyle(0,0,2);
     Outtextxy (a+40,b-w,('  '+S+'  '));
     End;

end;
v_show_c(1,1);
repeat
graf_mkstate(m,n,o,p); 
until o=0
End;

If o=1 then if (mines[m+1,n+1]=1) then {if left button is pressed...}
Begin                                  {and there is a mine...}
v_hide_c(1);
bar(a+1+m*w,b+1+n*w,a+m*w+w-1,b+n*w+w-1);
SetTextStyle(0,0,7);
If GetGraphMode=STHigh then
Begin
SetColor(1);
SetFillStyle (1,1)
End
else
Begin
SetColor(4);
setfillstyle (1,14);
end;
Line(a+m*w+w div 2,b+n*w+2,a+m*w+w div 2,b+n*w+w-2);
Line(a+m*w+3,b+n*w+w div 2,a+m*w+w-2,b+n*w+w div 2);
Line(a+m*w+3,b+n*w+3,a+m*w+w-2,b+n*w+w-3);
Line(a+m*w+3,b+n*w+w-3,a+m*w+w-3,b+n*w+3);
FillEllipse (a+m*w+w div 2,b+n*w+w div 2,w div 3,w div 3); {Draw Bomb} 
GameOver:=True;
Writeln('SORRY...You were just blown up.');
v_show_c(1,1);
repeat
graf_mkstate(m,n,o,p); 
until o=0;
end;

If o=1 then if nums[m+1,n+1]>0 then if (mines[m+1,n+1]<>1) then
Begin  {left button pushed, and there is no mine...}
v_hide_c(1);
bar(a+1+m*w,b+1+n*w,a+m*w+w-1,b+n*w+w-1);
WriteNum(m,n,w,opensq);
v_show_c(1,1);

repeat
graf_mkstate(m,n,o,p); 
until o=0;
end;

If o=1 then if nums[m+1,n+1]=0 then if mines[m+1,n+1]<>1 then
Begin
     v_hide_c(1);
     bar(a+1+m*w,b+1+n*w,a+m*w+w-1,b+n*w+w-1);
     opensq[m+1,n+1]:=1;
     x:=m;
     y:=n;
     while (x>=0) and (nums[x+1,y+1]=0) do
     begin
          x:=x-1; 
          bar(a+1+x*w,b+1+y*w,a+x*w+w-1,b+y*w+w-1);
          opensq[x+1,y+1]:=1;
     end;
     If ((x>=0) and (x<8) and (nums[x+1,y+1]<>0)) then WriteNum(x,y,w,opensq);
     xmin:=x;
     x:=m;
     y:=n;
     while (x<8) and (nums[x+1,y+1]=0) do
     begin
          x:=x+1;
          bar(a+1+x*w,b+1+y*w,a+x*w+w-1,b+y*w+w-1);
          opensq[x+1,y+1]:=1;
     end;
     If ((x<8) and (nums[x+1,y+1]<>0))then WriteNum(x,y,w,opensq);
     xmax:=x;

     For x:=xmin to xmax Do
     Begin
          while ((y>=0) and (x<8) and (x>=0) and (nums[x+1,y+1]=0)) do
          begin
          bar(a+1+x*w,b+1+y*w,a+x*w+w-1,b+y*w+w-1);
          opensq[x+1,y+1]:=1;
          If (nums[x,y+1]<>0) then
          Begin
          bar(a+1+(x-1)*w,b+1+y*w,a+(x-1)*w+w-1,b+y*w+w-1);
          WriteNum(x-1,y,w,opensq);
          End;
          
          If (nums[x+2,y+1]<>0) then
          Begin
          bar(a+1+(x+1)*w,b+1+y*w,a+(x+1)*w+w-1,b+y*w+w-1);
          WriteNum(x+1,y,w,opensq);
          End;
          
          y:=y-1;
          end;
          If ((y>=0) and (nums[x+1,y+1]<>0)) then 
          Begin
          bar(a+1+x*w,b+1+y*w,a+x*w+w-1,b+y*w+w-1);
          WriteNum(x,y,w,opensq);
          end;
          y:=n;

while ((y<8) and (x<8) and (x>=0) and (nums[x+1,y+1]=0)) do
          begin
          bar(a+1+x*w,b+1+y*w,a+x*w+w-1,b+y*w+w-1);
          opensq[x+1,y+1]:=1;
          If (nums[x,y+1]<>0) then
          Begin
          bar(a+1+(x-1)*w,b+1+y*w,a+(x-1)*w+w-1,b+y*w+w-1);
          WriteNum(x-1,y,w,opensq);
          End;
          
          If (nums[x+2,y+1]<>0) then
          Begin
          bar(a+1+(x+1)*w,b+1+y*w,a+(x+1)*w+w-1,b+y*w+w-1);
          WriteNum(x+1,y,w,opensq);
          End;
          
          y:=y+1;
          end;
          If ((y<8) and (nums[x+1,y+1]<>0)) then 
          Begin
          bar(a+1+x*w,b+1+y*w,a+x*w+w-1,b+y*w+w-1);
          WriteNum(x,y,w,opensq);
          end;
          y:=n;

 
End; {do}
          
v_show_c(1,1);
repeat
graf_mkstate(m,n,o,p); 
until o=0;
end; 
opened:=0;
For x:=1 to 8 do
begin
For y:=1 to 8 do
begin
     if opensq[x,y]=1 then 
          opened:=opened+1;
end;
end;

If opened=54 then 
Begin
GameOver:=True;
Writeln('CONGRATULATIONS!  You just won.');
End;
 
end;  {If mouse is on field...}

until GameOver;

end; {Procedure Uncover}
(**************************************************************************)


(**************************************************************************)
Procedure AddNumbers ( mines : fieldarray;
                       var nums: fieldarray;  
                           opensq:fieldarray);
{Determines the number of mines adjacent to a given square}
var x,y         : Integer;
Begin
For x:= 0 to 9 Do
For y := 0 to 9 Do
Begin
nums[x,y]:=0;
opensq[x,y]:=0;
end;

For x:=1 to 8 Do
Begin
For y:= 1 to 8 Do
Begin
If mines [x-1,y]=1 then nums[x,y]:=nums[x,y]+1;
If mines [x-1,y-1]=1 then nums[x,y]:=nums[x,y]+1;
If mines [x,y-1]=1 then nums[x,y]:=nums[x,y]+1;
If mines [x+1,y]=1 then nums[x,y]:=nums[x,y]+1;
If mines [x+1,y+1]=1 then nums[x,y]:=nums[x,y]+1;
If mines [x,y+1]=1 then nums[x,y]:=nums[x,y]+1;
If mines [x-1,y+1]=1 then nums[x,y]:=nums[x,y]+1;
If mines [x+1,y-1]=1 then nums[x,y]:=nums[x,y]+1;
end;
end
end; 
(**************************************************************************)



(**************************************************************************)
Begin  {**main program**}

more:='y';

     FirstSetUp(a,b,w,t); {set up graphics}
     Startup;
Repeat       
     Shuffle(D); {generate random numbers}
     DrawField(a,b,w,t); {draw the minefield}
     LayMines(D,mines);{use numbers gnerated in D to mine the field}
     AddNumbers(mines,nums,opensq);{mark mines}        
     Uncover(mines,nums,opensq,a,b,w,t);{play game}  

Writeln ('Do you want to play again? (y/n)?');
Readln(more);
    
     SetVisualPage(0);
until more='n';
     CloseGraph;{close shop}

End.{**main program**)