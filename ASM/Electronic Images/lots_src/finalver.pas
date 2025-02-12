{*****************************************************************************}
{***            Martin Griffiths 6B - A level computing project            ***}
{***  File archiver utility - using Shanon-fano probabilistic compression  ***}
{***                                                                       ***}
{***  Development history:                                                 ***}
{***        14/09/90 - Initial Research into compression techniques.       ***}
{***        22/09/90 - Actual programming began, Shanon fano recursive     ***}
{***                   algorithm developed and Tested thorughly!           ***}
{***        24/09/90 - Routines for file selecting and 'front' end coded.  ***}
{***        07/10/90 - Work started on decompression routine, very fast    ***}
{***                   method devised using a binary tree.                 ***}
{***        16/10/90 - Decompression routine now finished, but only after  ***}
{***                   finding a bug in the compression routine which made ***}
{***                   some characters be represented by the same bitcode. ***}
{***        25/10/90 - General tidying up of front 'end' and error traping ***}
{***        14/11/90 - Decompression routine rewritten to accomodate 16    ***}
{***                   bit codes which are very occasionally produced.     ***}
{***        19/12/90 - General options like set path, commandline etc done.***}
{***        09/01/90 - Final touches, testing, and some slight tidying up  ***}
{***                   of the user interface and layout etc.               ***}
{*****************************************************************************}

Program archiver;
uses dos,crt;

{ Some usefull constants }

const
 NULL = #0;
 BACKSPACE = #8;
 ENTER = #13;
 ESC = #27;
 UPKEY = #72;
 DOWNKEY = #80;
 LEFTKEY = #75;
 RIGHTKEY = #77;
 F1 = #59;
 F2 = #60;
 F3 = #61;
 F4 = #62;

{***************************************************************************
 ***                         Global variables                            ***
 ***************************************************************************}

{ Tree node storage }

type treechar = record
                b : array[1..32768] of byte;
                end;

{ Binary tree storage }

type treebrch = record
                b : array[1..16384] of byte;
                end;
var
 inbuf  : array[1..16384] of byte;        {16k input buffer - 'cache'!}
 outbuf : array[1..16384] of byte;        {16k output buffer - 'write cache'!}
 chrs     : array[0..255] of byte;        {character array - actual chars}
 freq     : array[0..255] of longint;     {frequency array - character freqs}
 prob     : array[0..255] of real;        {probability array - character probs}
 shancode : array[0..255] of word;        {code array -  compressed char codes}
 code_len : array[0..255] of byte;        {codelength array - new  codelengths}
 bitmask  : array[0..15] of word;         {bit masks}
 fnames   : array[1..300] of string[13];  {array for holding directory}
 fattr    : array[1..300] of byte;        {array for holding dir attributes}
 flength  : array[1..300] of longint;     {array for holding dir filesizes}
 menu_sel : array[0..3] of string[25];    {array for holding menu options}
 outfile,infile : file;
 menu_pos : integer;
 currdir,filename  : string;
 file_length : longint;                   {input file's length}
 new_length  : longint;
 new_name : string;                       {output file's name}
 numfile  : integer;
 key      : char;
 funckey  : boolean;
 answer   : boolean;                      {alert box result true/false}
 errorcode : integer;                     {errorcode - result of dos function}
 treenode : ^treebrch;
 treeref1 : ^treechar;
 treeref2 : ^treechar;                    {storage area for decompression tree}
 treeref3 : ^treechar;
 treeref4 : ^treechar;
 header_identifier : string[4];
{$M 16384,0,655360}                       {set program to have 16k stack}

{***************************************************************************
 ***            General routines - text output, keyboard etc...          ***
 ***************************************************************************}

{ Simple print at(x,y) subroutine }

procedure printat(x1,y1:byte ; text :string);
begin
 gotoxy(x1,y1);
 write(text);
end;

{ Centre a string of text }

procedure centertxt(y1:byte ; text :string);
begin
 printat(40-trunc(length(text)/2)+1,y1,text);
end;

{ Draw a text box quickly at x1,y1 to x2,y2 }

procedure box(x1,y1,x2,y2:byte; color:byte);
var x,y: byte;
begin
 textcolor(color);
 for x:=x1+1 to x2-1 do
  begin
   gotoxy(x,y1);
   write('Í');
   gotoxy(x,y2);
   write('Í');
  end;
 for y:=y1+1 to y2-1 do
  begin
   gotoxy(x1,y);
   write('³');
   gotoxy(x2,y);
   write('³');
  end;
 gotoxy(x1,y1);
 write('Õ');
 gotoxy(x1,y2);
 write('Ô');
 gotoxy(x2,y1);
 write('¸');
 gotoxy(x2,y2);
 write('¾');
 textcolor(white);
end;

{ Get a keypress returns 'key' Asci character of keypress }

procedure getkey(var return:char; var funckey:boolean);
begin
 funckey:=false;
 return:=readkey;
 if return=NULL then begin
    return:=readkey;
    funckey:=true;
 end;
end;

{ Alert box subroutine, e.g a general yes/no question subroutine. }

Procedure Alert(title:string ; y:byte);
var col1,col2,x:byte;
 begin
  col1:=1;
  col2:=0;
  x:=40-trunc((length(title)+10)/2);
  box(x-2,y-1,81-x,y+1,2);
  printat(x,y,title);
  x:=x+length(title);
  repeat
   textbackground(col1);
   printat(x,y,' YES ');
   textbackground(col2);
   printat(x+5,y,' NO ');
   getkey(key,funckey);
   case key of
     LEFTKEY:
      begin
       col1:=1;
       col2:=0;
      end;
     RIGHTKEY:
      begin
       col1:=0;
       col2:=1;
      end;
  end;
  until key=ENTER;
   if col1=1 then
    answer:=TRUE
     else
    answer:=FALSE;
  textbackground(0);
 end;

{ Bullet proof 12 character input routine }

procedure cool_input(x,y:integer);
 var i:byte;
 begin
   textbackground(1);
   printat(x,y,'            ');
   gotoxy(x,y);
   i:=1;
   repeat
    getkey(key,funckey);
    if (key=BACKSPACE) and (i>1) then
    begin
      dec(i);
      gotoxy(x+i-1,y);
      write(#32);
      gotoxy(x+i-1,y);
    end;
    if (i<=12) and (key<>BACKSPACE) and (key<>ENTER) then
     begin
      new_name[i]:=key;
      gotoxy(x+i-1,y);
      write(key);
      gotoxy(x+i,y);
      inc(i);
     end;
     until key=ENTER;
  new_name[0]:=chr(i-1);
  textbackground(0);
 end;

{ Routine to print the title and box at the top of the screen }

procedure title;
 begin
  textbackground(black);
  window(1,1,80,25);
  clrscr;
  box(1,1,80,3,2);
  centertxt(2,' Pembroke School Network Archive Utility');
 end;

{***************************************************************************
 ***             File selector subroutine(user friendly!)                ***
 ***************************************************************************}

{Recursive quicksort subroutine for sorting filenames into alphabetical order}

procedure qsortfiles(l,r: byte);
var i,j    : byte;
    temp,x : string;
    temp1  : longint;
begin
  i:=l; j:=r; x:=fnames[(l+r) DIV 2];
  repeat
    while fnames[i]<x do inc(i);
    while x<fnames[j] do dec(j);
    if i<=j then
    begin
      temp:=fnames[i]; fnames[i]:=fnames[j]; fnames[j]:=temp;
      temp1:=fattr[i]; fattr[i]:=fattr[j]; fattr[j]:=temp1;
      temp1:=flength[i]; flength[i]:=flength[j]; flength[j]:=temp1;
     inc(i);
     dec(j);
    end;
  until i>j;
  if l<j then qsortfiles(l,j);
  if i<r then qsortfiles(i,r);
end;

procedure file_select(mask : string ; var filename:string);
label 1,2;
var srec       : SearchRec;
    textx,texty: integer;
    maxnorows  : integer;
    printcount : integer;
    namecount  : integer;
    acount     : integer;
    count1,count2,count : integer;
    temp,path  : string;
    ROW,COL    : integer;
    driveno    : integer;
begin
 driveno:=(ord(currdir[1]) and $df)-64;
{$I-}
1:
 textbackground(black);
 window(1,1,80,25);
 clrscr;
 getdir(driveno,currdir);
 errorcode:=IOResult; if errorcode<>0 then exit;
 path:=currdir;
 if currdir[length(currdir)]<>'\' then path:=path+'\';
 path:=path+mask;
 box(1,1,80,24,2);
 centertxt(24,' Please Select a File ');
 centertxt(1,' '+path+' ');
 printat(2,25,'Please wait...');
 window(2,2,79,23);
 numfile:=0;
 for count1:=1 to 300 do fnames[count1]:='              ';
{ get files }
 findfirst(path,anyfile,srec);
  while doserror=0 do begin
   with srec do begin
     if (attr and directory)=0 then
     begin
      inc(numfile);
      fnames[numfile]:=name;
      fattr[numfile]:=0;
      flength[numfile]:=size;
     end;
    end;
  findnext(srec);
  end;
{ get directory names }
 findfirst('*.*',anyfile,srec);
 while doserror=0 do begin
  with srec do begin
   if (attr and directory)<>0 then
   begin
    inc(numfile);
    fnames[numfile]:=name+'\';
    fattr[numfile]:=1;
   end;
 end;
 findnext(srec);
 end;
 qsortfiles(1,numfile);
 acount:=1; namecount:=1; texty:=1;
 maxnorows:=trunc((numfile-1)/5);
 if (maxnorows>22) then printcount:=110 else printcount:=numfile;
 count1:=3;
  for count:=1 to printcount do
   begin
     printat(count1,texty,' '+fnames[namecount]);
     inc(namecount);
     count1:=count1+15;
     if (count1=78) then
     begin;
      count1:=3;
      inc(texty);
     end;
   end;
 window(1,1,80,25);
 printat(2,25,'              ');
 window(2,2,79,23);
 textx:=3; texty:=1; ROW:=0; COL:=0;
 textbackground(blue);
 printat(textx,texty,' '+fnames[acount]);

{ main selecting loop }

2:
  repeat
    getkey(key,funckey);
    textbackground(black);
    printat(textx,texty,' '+fnames[acount]);
    if funckey then
      case key of
    UPKEY    :   BEGIN
                 if (texty=1) and (ROW>0) then
                  begin
                  insline;
                  acount:=acount-5;
                  dec(ROW);
                  namecount:=1+(ROW*5);
                  for count:=0 to 4 do
                   printat(3+(count*15),texty,' '+fnames[namecount+count]);
                 end
                 else
                 if (ROW>0) then
                  begin
                   dec(texty);
                   acount:=acount-5;
                   dec(ROW);
                  end;
                 END;
    DOWNKEY  :   BEGIN
                if (texty=22) and (numfile>=acount+5) then
                 begin
                  inc(ROW);
                  acount:=acount+5;
                  gotoxy(1,1);
                  delline;
                  namecount:=1+(ROW*5);
                  if (numfile-namecount<5) then count1:=numfile-namecount
                  else count1:=4;
                  for count:=0 to count1 do
                  printat(3+(count*15),texty,' '+fnames[namecount+count]);
                 end
                 else
                 if (texty<22) and (numfile>=acount+5) then
                  begin
                   inc(texty);
                   acount:=acount+5;
                   inc(ROW);
                  end;
                 END;
    LEFTKEY  :   BEGIN
                 if (COL>0)then
                  begin
                   textx:=textx-15;
                   dec(acount);
                   dec(COL);
                  end;
                 END;
    RIGHTKEY :   BEGIN
                 if (COL<4) and (1+(ROW*5)+COL<numfile) then
                  begin
                   textx:=textx+15;
                   inc(acount);
                   inc(COL);
                  end;
                 END;
    END;  {of case!}
 textbackground(blue);
 printat(textx,texty,' '+fnames[acount]);
 until (key=ENTER) or (key=ESC);
 if key=ESC then exit;
 if fattr[acount]<>0 then
  begin
    if ((length(currdir)<4) and (fnames[acount]='..\')) or ((length(currdir)<4) and (fnames[acount]='.\')) then
     begin
       write(#7);
       goto 2;
     end;
    temp:=copy(fnames[acount],1,length(fnames[acount])-1);
    chdir(temp);
    errorcode:=IOResult; if errorcode<>0 then exit;
    goto 1;
  end;
 filename:=fnames[acount];
 file_length:=flength[acount];
 textbackground(black);
 window(1,1,80,25);
end;

{ Generate bitmasks 1,2,4,8,16,32,64 etc etc upto 2^15 }

procedure gen_masks;
 var i : byte;
 begin
   for i:=0 to 15 do bitmask[i]:=1 shl i;
 end;

{ Initialize arrays }

procedure init_arrays;
 var i:byte;
 begin
 for i:=0 to 255 do
   begin
    freq[i]:=0;
    code_len[i]:=0;
    prob[i]:=0;
    shancode[i]:=0;
    chrs[i]:=i;
   end;
 end;

{**************************************************************************
 **************************************************************************
 ***                                                                    ***
 ***                                                                    ***
 ***                     Main compression subroutines                   ***
 ***                                                                    ***
 ***                                                                    ***
 **************************************************************************
 **************************************************************************}

{**************************************************************************
 ***        Recursive shanon-fano bitcode generator sub-routine.        ***
 *** This takes the character probabilities and generates bitcodes of   ***
 *** varying length according to the size of each probability....       ***
 **************************************************************************}

procedure shanon_gen(min,max : byte);
 var mid,i     : byte;
     rmain,cnt : real;
 begin
 rmain:=0;
 cnt:=0;
 for i:=min to max do rmain:=rmain+prob[i];  {sum subset's probability}
   rmain:=rmain/2; mid:=min-1;               {half the subset's probability}
   while cnt<rmain do
    begin
     inc(mid);
     cnt:=cnt+prob[mid];
    end;                                     {find midpoint of probability}
  if mid>min then                            {small bitlength optimisation}
   begin
    if (cnt-rmain)>(rmain-(cnt-prob[mid])) then dec(mid);
   end;
  for i:=min to mid do inc(code_len[i]);     {increment bitlength top subset}
  for i:=mid+1 to max do
   begin
    shancode[i]:=shancode[i]+bitmask[code_len[i]];    {add 1 bit to bot subset}
    inc(code_len[i]);                        {increment bitlength bot subset}
   end;
  if mid-min>1 then shanon_gen(min,mid);     {work on top subset}
  if max-mid>2 then shanon_gen(mid+1,max);   {work on the bottom subset}
 end;

{ Recursive quick sort routine to sort probabilities into order of high to low }

procedure qsortprobs(l,r: byte);
var i,j,tempsort2 : byte;
    tempsort1,x   : real;
    tempsort3     : longint;
begin
  i:=l; j:=r; x:=prob[(l+r) DIV 2];
  repeat
    while prob[i]>x do inc(i);
    while x>prob[j] do dec(j);
    if i<=j then
     begin
      tempsort1:=prob[i]; prob[i]:=prob[j]; prob[j]:=tempsort1;
      tempsort2:=chrs[i]; chrs[i]:=chrs[j]; chrs[j]:=tempsort2;
      tempsort3:=freq[i]; freq[i]:=freq[j]; freq[j]:=tempsort3;
      inc(i);
      dec(j);
     end;
  until i>j;
  if l<j then qsortprobs(l,j);
  if i<r then qsortprobs(i,r);
end;

{ Recursive quick sort routine to sort characters back into order }

procedure qsortchrs(l,r: byte);
var i,j,x ,tempsort2 : byte;
    tempsort3        : integer;
begin
  i:=l; j:=r; x:=chrs[(l+r) DIV 2];
  repeat
    while chrs[i]<x do inc(i);
    while x<chrs[j] do dec(j);
    if i<=j then
     begin
      tempsort2:=chrs[i];     chrs[i]:=chrs[j];         chrs[j]:=tempsort2;
      tempsort3:=shancode[i]; shancode[i]:=shancode[j]; shancode[j]:=tempsort3;
      tempsort2:=code_len[i]; code_len[i]:=code_len[j]; code_len[j]:=tempsort2;
      inc(i);
      dec(j);
     end;
  until i>j;
  if l<j then qsortchrs(l,j);
  if i<r then qsortchrs(i,r);
end;

{ Compression routine - lets user select a file and then compresses it. }

procedure compress;
  var  code,i,j,validfreq,mask : integer;
       outcnt : integer;
       currbyte : byte;
       numread,numwritten: word;
begin
{$I-}
 file_select('*.*',filename);
 if key=ESC then exit;
 title;
 box(1,4,80,24,2);
 centertxt(4,' File Compression ');
 box(8,7,72,10,2);
 gotoxy(11,8);  write('Working on file :',filename);
 gotoxy(43,8);  write('Original Filelength  :',file_length);
 printat(43,9,'Compressed filelength:');
 printat(11,9,'Compressed percentage:');
 inline($FA);
 init_arrays;
{ Scan the file to be packed, counting the frequency of each character }
 assign(infile,filename);
 reset(infile,1);
 errorcode:=IOResult; if errorcode<>0 then exit;
 repeat
  blockread(infile,inbuf[1],16384,numread);
  errorcode:=IOResult; if errorcode<>0 then exit;
  for i:=1 to numread do inc(freq[inbuf[i]]);
 until numread=0;
 close(infile); errorcode:=IOResult; if errorcode<>0 then exit;
{ Assign probabilities to characters,sort into order of highest prob to low }
 for i:=0 to 255 do prob[i]:=freq[i]/file_length;
 qsortprobs(0,255);
{ Valid frequency test to determine how many chars actual have a frequency
  of more than 0 (codes need only be produced for these!), call the routine
  to generate the codes on only this subset }
  validfreq:=-1;
  repeat
   inc(validfreq);
  until (validfreq=256) or (freq[validfreq]=0);
  dec(validfreq);
  shanon_gen(0,validfreq);
{ Eliminate all similar codes }
  for i:=0 to validfreq-1 do
   begin
    if (shancode[i]=shancode[i+1]) and (code_len[i]=code_len[i+1]) then
     begin
      shancode[i]:=shancode[i]+bitmask[code_len[i]];
      inc(code_len[i]);
      inc(code_len[i+1]);
     end;
   end;
{ Calculate new file length (approx length) }
  new_length:=0;
  for i:=0 to validfreq do
   begin
    new_length:=new_length+freq[i]*code_len[i];
    new_length:=new_length+code_len[i]+5;
   end;
  new_length:=((new_length+255-validfreq) shr 3)+16;
  gotoxy(65,9); write(new_length);
  gotoxy(33,9); write(trunc((new_length/file_length)*100),'%');
  if new_length>file_length then printat(8,15,#7+'Warning - New file is larger than old!');
  alert('     Do you wish to continue and save file? ',13);
  if answer=TRUE then
  begin
   printat(17,13,'Enter new filename for archive file:');
   cool_input(53,13);
   qsortchrs(0,255);                        { Sort back into character order }
{ Now we actually get round to producing the compressed file!!! }
   printat(8,19,'Please wait... Saving...');
   assign(infile,filename); reset(infile,1);
   errorcode:=IOResult; if errorcode<>0 then exit;
   assign(outfile,new_name); rewrite(outfile,1);
   errorcode:=IOResult; if errorcode<>0 then exit;
{ Write 32 bit unpacked file length + filename }
   blockwrite(outfile,header_identifier,4,numwritten);
   blockwrite(outfile,file_length,4,numwritten);
   blockwrite(outfile,filename[0],length(filename)+1,numwritten);
   errorcode:=IOResult; if errorcode<>0 then exit;
{ Write out bitcodes that were generated }
   currbyte:=0; mask:=128; outcnt:=1;
    for i:=0 to 255 do
     begin
      if code_len[i]>0 then currbyte:=currbyte+mask;
       mask:=mask shr 1;
       if mask=0 then
        begin
         outbuf[outcnt]:=currbyte; inc(outcnt); currbyte:=0; mask:=128;
        end;
      if code_len[i]>0 then
       begin
       dec(code_len[i]);
       for j:=0 to 3 do
        begin
         if (code_len[i] and bitmask[j])>0 then currbyte:=currbyte+mask;
         mask:=mask shr 1;
         if mask=0 then
          begin
            outbuf[outcnt]:=currbyte; inc(outcnt); currbyte:=0; mask:=128;
          end;
        end;
{ Now write out bitcode }
        for j:=0 to code_len[i] do
         begin
          if (shancode[i] and bitmask[j])>0 then currbyte:=currbyte+mask;
          mask:=mask shr 1;
          if mask=0 then
           begin
             outbuf[outcnt]:=currbyte; inc(outcnt); mask:=128; currbyte:=0;
           end;
         end;
      end;
     end;
{ Now encode file using the new bitcodes }
    repeat
     blockread(infile,inbuf[1],16384,numread);
     for i:=1 to numread do
      begin
      code:=shancode[inbuf[i]];
        for j:=0 to code_len[inbuf[i]] do
         begin
          if (code and bitmask[j])>0 then currbyte:=currbyte+mask;
          mask:=mask shr 1;
          if mask=0 then
           begin
            outbuf[outcnt]:=currbyte; inc(outcnt); mask:=128; currbyte:=0;
             if outcnt=16385 then
              begin
               blockwrite(outfile,outbuf[1],16384,numwritten); outcnt:=1;
               errorcode:=IOResult; if errorcode<>0 then exit;
              end;
           end;
       end;
      end;
    until numread<>16384;
    inline($FB);
    if outcnt>1 then
     begin
      blockwrite(outfile,outbuf[1],outcnt-1,numwritten);
      errorcode:=IOResult; if errorcode<>0 then exit;
     end;
    close(infile); errorcode:=IOResult; if errorcode<>0 then exit;
    close(outfile); errorcode:=IOResult; if errorcode<>0 then exit;
    printat(8,20,'File compressed and saved - Press any key.');
    getkey(key,funckey);
  end;
end;


{**************************************************************************
 **************************************************************************
 ***                                                                    ***
 ***                                                                    ***
 ***                  Main decompression subroutines.                   ***
 ***                                                                    ***
 ***                                                                    ***
 **************************************************************************
 **************************************************************************}

procedure uncompress;
  var endcnt,c : longint;
      incnt,outcnt,mask,i,j :integer;
      numread,numwritten : word;
      currbyte:byte;
      codeflag:boolean;
      headerread:string[4];
{$I-}
begin
 file_select('*.ARC',filename); if key=ESC then exit;
 getmem(treenode,16384);                            {reserve memory}
 getmem(treeref1,32768);
 getmem(treeref2,32768);
 getmem(treeref3,32768);
 getmem(treeref4,32768);
 headerread[0]:=#4;
 title;
 box(1,4,80,24,2);
 centertxt(4,' File Decompression ');
 init_arrays;
{ Read 32 bit filelength from packed file - 4 bytes! }
 assign(infile,filename);
 reset(infile,1); errorcode:=IOResult; if errorcode<>0 then exit;
 blockread(infile,headerread[1],4,numread);
 blockread(infile,new_length,4,numread);
{ Read original filename }
 blockread(infile,new_name[0],1,numread);
 blockread(infile,new_name[1],length(new_name),numread);
 box(6,7,74,10,2);
 centertxt(7,' Archive Statistics ');
 printat(11,8,'Archive filename :'+filename);
 printat(11,9,'Original filename:'+new_name);
 printat(44,8,'Archive filelength :'); write(file_length);
 printat(44,9,'Original filelength:');write(new_length);

 alert('Do you want to use the original filename?',13);
 if answer=FALSE then
  begin
   printat(15,13,' Enter new name for Decompressed file:');
   cool_input(53,13);
  end;
 box(8,16,72,18,2);
 printat(10,17,'Decompressing... Please wait... Percentage Decompressed:[00%]');
 fillchar(treeref1^.b[1],32768,0);
 fillchar(treeref2^.b[1],32768,0);
 fillchar(treeref3^.b[1],32768,0);
 fillchar(treeref4^.b[1],32768,0);
 fillchar(treenode^.b[1],16384,0);

{ Read bitcodes that were generated when the file was packed.
1 bit code signifier - 0 no code.
                     - 1 code follows
4 bit number = codelength-1
 add 1 to codelength to get actual shanon-fano code length.
 read codelength bits - actual shanon-fano code }

 blockread(infile,inbuf[1],16384,numread);
 incnt:=1; mask:=128; currbyte:=inbuf[incnt];
 for i:=0 to 255 do
  begin
{ Read 1 bit 'codeflag' }
   if (currbyte and mask)>0 then codeflag:=TRUE else codeflag:=FALSE;
   mask:=mask shr 1;
   if mask=0 then begin inc(incnt); mask:=128; currbyte:=inbuf[incnt]; end;
   if codeflag=TRUE then
{ If codeflag is true then read a 4 bit codelength }
    begin
     for j:=0 to 3 do
      begin
       if (currbyte and mask)>0 then code_len[i]:=code_len[i]+bitmask[j];
       mask:=mask shr 1;
       if mask=0 then begin inc(incnt); mask:=128; currbyte:=inbuf[incnt]; end;
      end;
      inc(code_len[i]);
      c:=1;
       for j:=0 to code_len[i]-1 do
        begin
         c:=c*2;
         if (currbyte and mask)>0 then
          begin
           inc(c);
           shancode[i]:=shancode[i]+bitmask[j];
          end;
         mask:=mask shr 1;
         if mask=0 then begin inc(incnt); mask:=128; currbyte:=inbuf[incnt];end;
        end;
        treenode^.b[c shr 3]:=treenode^.b[c shr 3] or bitmask[c and 7];
        case c shr 15 of
         0:treeref1^.b[c]:=i;
         1:treeref2^.b[c-32767]:=i;
         2:treeref3^.b[c-65535]:=i;
         3:treeref4^.b[c-98303]:=i;
        end;
    end;
  end;
{ Now depack the file }
 assign(outfile,new_name);
 rewrite(outfile,1); outcnt:=1;
 errorcode:=IOResult; if errorcode<>0 then exit;
 inline($FA);
 for endcnt:=1 to new_length do
  begin
   c:=1;
   repeat
    c:=c*2;
    if (currbyte and mask)>0 then inc(c);
    mask:=mask shr 1;
    if mask=0 then
     begin
       inc(incnt); mask:=128; currbyte:=inbuf[incnt];
       if incnt=16384 then
        begin
         blockread(infile,inbuf[1],16384,numread);
         errorcode:=IOResult; if errorcode<>0 then exit;
         incnt:=0;
        end;
     end;
    until (treenode^.b[c shr 3] and bitmask[c and 7])<>0;
     case c shr 15 of
      0 : outbuf[outcnt]:=treeref1^.b[c];
      1 : outbuf[outcnt]:=treeref2^.b[c-32767];
      2 : outbuf[outcnt]:=treeref3^.b[c-65535];
      3 : outbuf[outcnt]:=treeref4^.b[c-98303];
     end;
   if (endcnt and 1023)=0 then
    begin
     j:=trunc(endcnt/new_length*100);
     gotoxy(67,17);
     write(trunc(j/10),j mod 10);
    end;
   inc(outcnt);
   if outcnt=16385 then
    begin
     blockwrite(outfile,outbuf[1],16384,numwritten);
     errorcode:=IOResult; if errorcode<>0 then exit;
     outcnt:=1;
    end;
  end;
 inline($FB);
 if outcnt>1 then
  begin
   blockwrite(outfile,outbuf,outcnt-1,numwritten);
   errorcode:=IOResult; if errorcode<>0 then exit;
  end;
 close(infile); errorcode:=IOResult; if errorcode<>0 then exit;
 close(outfile); errorcode:=IOResult; if errorcode<>0 then exit;
 freemem(treenode,16384);
 freemem(treeref1,32768);
 freemem(treeref2,32768);
 freemem(treeref3,32768);
 freemem(treeref4,32768);
 printat(10,17,'           Decompression complete - Press any key.            ');
 getkey(key,funckey);
end;

{**************************************************************************
 ***                          Error Handler                             ***
 **************************************************************************}

procedure Report_doserror;
var errorstrng : string;
begin
 textbackground(0);
 box(2,10,79,16,2);
 centertxt(10,' Dos/Disk Error Report ');
 window(3,11,78,15);
 clrscr;
 write(#7);
 errorstrng:='General DOS Error';
 case errorcode of
    2 : errorstrng:='File not found';
    3 : errorstrng:='Path not found';
    5 : errorstrng:='File access denied';
    6 : errorstrng:='Invalid file handle';
   15 : errorstrng:='Invalid Drive number';
  100 : errorstrng:='Disk read error';
  101 : errorstrng:='Disk write error';
  150 : errorstrng:='Disk is Write Protected!';
  152 : errorstrng:='Disk missing from Drive!';
 end;
 printat(9,2,'Disk error number: '); write(errorcode);
 printat(9,3,'Error Description: '+errorstrng);
 centertxt(5,'Press any key to Previous Menu');
 getkey(key,funckey);
end;

{**************************************************************************
 ***                                                                    ***
 ***             General commands - Dos commands, Set path etc.         ***
 ***                                                                    ***
 **************************************************************************}

{ Ms-dos command line }

procedure command_line;
 begin
  clrscr;
  Exec('COMMAND.COM', '/C COMMAND');
 end;

{ Set current path }

procedure set_path;
{$I-}
 var i,x,y:byte;
 begin
 box(2,11,79,15,2);
 centertxt(11,' Set Current Path ');
 window(3,12,78,14);
 clrscr;
  printat(3,2,'Please specify full new path:');
  x:=33; y:=2;
  textbackground(1);
  printat(x,y,'                                         ');
  gotoxy(x,y);
  i:=1;
  repeat
    getkey(key,funckey);
    if (key=BACKSPACE) and (i>1) then
    begin
      dec(i);
      gotoxy(x+i-1,y);
      write(#32);
      gotoxy(x+i-1,y);
    end;
    if (i<=41) and (key<>BACKSPACE) and (key<>ENTER) then
     begin
      new_name[i]:=key;
      gotoxy(x+i-1,y);
      write(key);
      gotoxy(x+i,y);
      inc(i);
     end;
     until key=ENTER;
  new_name[0]:=chr(i-1);
  textbackground(0);
  window(1,1,80,25);
  currdir:=new_name;
  chdir(currdir);
  errorcode:=IOResult; if errorcode<>0 then Report_doserror;
 end;

{ General Information }

procedure info;
var drive : byte;
begin
 title;
 box(1,4,80,24,2);
 drive:=(ord(currdir[1]) and $df)-64;
 textbackground(white);
 centertxt(7,'General System Information');
 textbackground(black);
 printat(29,10,'Free Memory     : '); write(trunc(memavail/1024)); Write('K');
 printat(29,12,'Free Disk Space : '); write(trunc(diskfree(drive)/1024)); Write('K');
 printat(29,14,'Total Disk Size : '); write(trunc(disksize(drive)/1024)); Write('K');
 printat(29,16,'Current Path    : '+currdir);
 centertxt(21  ,'Press any key to return to previous menu.');
 getkey(key,funckey);
end;


procedure generalcom;
 var menu_p : byte;
 begin
  repeat
   title;
   box(1,4,80,24,2);
   centertxt(25,'Use '+#24+', '+#25+' and <ENTER> to select an option.');
   textbackground(white);
   centertxt(7,' Dos commands/general ');
   textbackground(black);
   menu_sel[0]:=' Enter DOS command >  ';
   menu_sel[1]:=' Set Current Path.    ';
   menu_sel[2]:=' General information. ';
   menu_sel[3]:=' Exit to main menu.   ';
   printat(28,10,'F1  '+menu_sel[0]);
   printat(28,12,'F2  '+menu_sel[1]);
   printat(28,14,'F3  '+menu_sel[2]);
   printat(28,16,'F4  '+menu_sel[3]);
   menu_p:=0;
   textbackground(blue);
   printat(32,10,menu_sel[0]);
   repeat
    errorcode:=0;
    getkey(key,funckey);
    textbackground(black);
    printat(32,10+menu_p*2,menu_sel[menu_p]);
    case key of
    UPKEY    : menu_p:=(menu_p-1) and 3;
    DOWNKEY  : menu_p:=(menu_p+1) and 3;
    end;
    textbackground(blue);
    printat(32,10+menu_p*2,menu_sel[menu_p]);
   until (key=ENTER) or (KEY=F1) or (KEY=F2) or (KEY=F3) or (KEY=F4);
   if key<>ENTER then menu_p:=ord(key)-59;
   textbackground(black);
   case menu_p of
    0:command_line;
    1:set_path;
    2:info;
   end;
  until menu_p=3;
end;

{**************************************************************************
 ***                                                                    ***
 ***               Main program(menu selection) starts here             ***
 ***                                                                    ***
 **************************************************************************}

begin
  gen_masks;
  header_identifier:='SARC';
  currdir:='N:';
  chdir('N:');
repeat
  title;
  box(1,4,80,24,2);
     centertxt(25,'Use '+#24+', '+#25+' and <ENTER> to select an option.');
     textbackground(white);
     centertxt(7,'  Main Menu  ');
     textbackground(black);
     menu_sel[0]:=' Compress a file.   ';
     menu_sel[1]:=' Uncompress a file. ';
     menu_sel[2]:=' Dos commands/Misc. ';
     menu_sel[3]:=' Quit.              ';
     printat(29,10,'F1  '+menu_sel[0]);
     printat(29,12,'F2  '+menu_sel[1]);
     printat(29,14,'F3  '+menu_sel[2]);
     printat(29,16,'F4  '+menu_sel[3]);
     menu_pos:=0;
     textbackground(blue);
     printat(33,10,menu_sel[0]);
  repeat
     errorcode:=0;
     getkey(key,funckey);
     textbackground(black);
     printat(33,10+menu_pos*2,menu_sel[menu_pos]);
     case key of
      UPKEY    : menu_pos:=(menu_pos-1) and 3;
      DOWNKEY  : menu_pos:=(menu_pos+1) and 3;
     end;
     textbackground(blue);
     printat(33,10+menu_pos*2,menu_sel[menu_pos]);
  until (key=ENTER) or (KEY=F1) or (KEY=F2) or (KEY=F3) or (KEY=F4);
  if key<>ENTER then menu_pos:=ord(key)-59;
  textbackground(black);
  case menu_pos of
   0 : compress;
   1 : uncompress;
   2 : generalcom;
  end;
  if errorcode<>0 then Report_doserror;
  until menu_pos=3;
  clrscr;
 end.
