program apx2dat; { APX till sprites.DAT konerterare }
uses
  dos;

var
  SF,DF: file;
  opal: packed array[0..767] of byte;
  dpal: array[0..8] of word;
  m,n: integer;
  oblk: packed array[0..256] of byte;
  dblk: packed array[0..128] of byte;
  r,g,b: word;
  dummy: integer;
  x,y: integer;
  
begin
  reset(SF,'sprites.apx');
  rewrite(DF,'sprites.dat');
  blockread(SF,oblk[0],20);
  blockread(SF,opal[0],256*3);
  for n:=0 to 8 do
   begin
     r:=(opal[n*3] and $F8); r:=r * 256;
     g:=(opal[n*3+1] and $FC); g:=g * 8;
     b:=(opal[n*3+2] and $F8); b:=b div 8;       
     writeln(r,' ',g,' ',b);
     dpal[n]:=r or g or b; 
   end;
  repeat until keypressed;
  blockwrite(DF,dpal[0],18,n);
  for n:=0 to 5 do
   begin
     blockread(SF,oblk[0],256);
       for y:=0 to 15 do
         for x:=0 to 7 do
            dblk[y*8+x]:=oblk[y*16+x*2]*16+oblk[y*16+x*2+1];
     blockwrite(DF,dblk[0],128,dummy);
     {blockwrite(DF,oblk[0],256,dummy);}
   end;
  close(SF);
  close(DF);
end. 