{***************************************************************************}
{* This program is a general purpose PAL assembler. You may copy and use   *}
{* it for personal purposes. No commercial use of this program is allowed  *}
{* without the consent of the author.                                      *}
{* THIS IS THE Atari ST Version                                            *}
{* (c) Copyright 1987,1988 by Erasmo Brenes.                               *}
{***************************************************************************}
program passm (input,output,source,simfile);
 const
  linewidth = 40;
  blank = ' ';  semicol = ';';  comment = '"';
  maxterms = 19;        maxinputs = 22;
  maxpins = 24;         npals   = 23;
  maxcols = 44;         maxouts = 10;

 type
  symbol =( ident, int, num, eql, quotes, semicolon, apostrophe,
            leftbrkt, rightbrkt, device, pin, equations,module,flag,
            lftparen,rgtparen,title,node,stype,macro,andoperator,
            oroperator,invert,colon,ends,enable,preset,clear);
  palsymb = ( p10l8,p12l6,p14l4,p16l2,p16l8,p16rx,p12l10,p14l8,p16l6,
              p18l4,p20l2,p20l10,p20l8,p20rx,p22vx);
  tkens = packed array [1..15] of char;
  kind  = (reg, nonreg, bidir, tristate);
  palsize = (input18, input22);
  logic = (high, low);
  trans1typ =
   record
        transfer : array[1..maxpins] of integer
   end;
  outtype =
   record
        outnumb : integer;
        outname : tkens;
        outkind : kind;
        size    : palsize;
        form    : logic;
        matrix  : array [1..maxterms,1..maxcols] of char
   end;
  entrytype =
   record
        name : tkens;
        pinn : integer
   end;
  string2 = packed array [1..4] of char;
  filnam = packed array [1..80] of char;
  ptermtyp = array [1..maxcols] of char;

 var
  source,simfile : text;
  token  : tkens;
  palknds : array [1..npals] of char;
  pals    : array [1..npals] of tkens;
  symtable: array [1..maxpins] of entrytype;
  outtable: array [1..11] of outtype;
  palkind : palsymb;
  fusetoinp,fusetopin : array [palsymb] of trans1typ;
  paltyp  : array [1..npals] of palsymb;
  filspc : string[80];
  sym : symbol;
  reserved : array [1..13] of tkens;
  pdevice : tkens;
  wsym : array [1..13] of symbol;
  ptype,ch,tab : char;
  nexout,outindex : integer;
  nexin : integer;
  value,i,j,pointer,iterm,totalterms : integer;
  Abort,empty,pal16,found : boolean;
  ar, sp : ptermtyp;

 procedure bgetchar (var ch:char);
  begin
   empty := false;
   if eof(source)
    then begin
          empty := true;
          ch := blank
         end
    else begin
          if eoln(source)
           then begin
                 readln (source);
                 ch := blank
                end
           else
          if eof(source)
           then begin
                 empty := true;
                 ch := blank
                end
           else begin
                 read (source,ch);
                 if ch = comment
                  then begin
                        repeat
                        readln (source);
                        if eof(source)
                         then begin
                                empty := true;  ch := blank
                              end
                         else read (source,ch)
                        until (ch <> comment) or (eof(source))
                       end
                end
         end
  end; {bgetchar}

 procedure numbr;
{this routine always leaves with ch containing the next character!}
  var
   j : integer;
  begin
   sym := int;
   value := 0;  j:= 0;
   repeat
    value := 10*value + (ord(ch) - ord('0'));
    bgetchar (ch);       j:= j + 1
   until not(ch in ['0'..'9'])
  end; {numbr}

 procedure gettoken;
  var
   i,j,k : integer;
  begin
   i:= 0;
   while ((ch=blank)or(ch=tab))and(not empty) do bgetchar(ch);
   if (ch in ['A'..'Z'])or(ch in['a'..'z'])or(ch = '-')
    then begin
          repeat
           i:= i + 1;
           token [i]:= ch;      bgetchar(ch)
          until not((ch in ['A'..'Z'])or(ch in['a'..'z'])or(ch in ['0'..'9'])
           or (ch='_')) or empty or (i = 15);
          if not empty
           then begin
                 if (i < 15) then repeat
                                   i:= i + 1; token[i]:= blank
                                  until (i=15);
                 k := 0;
                 for j:=1 to 13 do
                  if token = reserved[j]
                   then k := j;
                 if k = 0
                  then sym := ident
                  else sym := wsym [k]
                end
         end
    else begin
          if (ch in ['0'..'9'])
           then numbr
           else case ch of
                 '^':  begin
                        sym := num;
                        bgetchar (ch)
                       end;
                 '=':  begin
                        sym := eql;
                        bgetchar (ch)
                       end;
                 ';':  begin
                        sym := semicolon;
                        bgetchar (ch)
                       end;
                 '''': begin
                        sym := apostrophe;
                        bgetchar (ch)
                       end;
                 '`':  begin
                        sym := apostrophe;
                        bgetchar (ch)
                       end;
                 '"':  begin
                        sym := quotes;
                        bgetchar (ch)
                       end;
                 '[':  begin
                        sym := leftbrkt;
                        bgetchar (ch)
                       end;
                 ']':  begin
                        sym := rightbrkt;
                        bgetchar (ch)
                       end;
                 '(':  begin
                        sym := lftparen;
                        bgetchar (ch)
                       end;
                 ')':  begin
                        sym := rgtparen;
                        bgetchar (ch)
                       end;
                 '!':  begin
                        sym := invert;
                        bgetchar (ch)
                       end;
                 '&':  begin
                        sym := andoperator;
                        bgetchar (ch)
                       end;
                 '#':  begin
                        sym := oroperator;
                        bgetchar (ch)
                       end;
                 ':':  begin
                        sym := colon;
                        bgetchar (ch)
                       end;
                 otherwise:
                    begin
                     bgetchar (ch);
                     gettoken { get next token }
                    end
                end
         end
  end; {gettoken}

 procedure semimodule;
  begin
   gettoken;
   while sym = semicolon
    do gettoken;
  end;

 procedure search ( kind : integer);
  var
   i,j : integer;
  begin
   case kind of
    1:   begin
          pointer := 0;
          for i:=1 to npals do
           if token = pals[i]
            then pointer := i
         end;
    2:  begin
         j := pointer;
         pointer := 0;
         for i:=1 to 24 do
          with symtable[i] do
           if pinn = j
            then pointer := i
        end;
    3:  begin      { search a signal name for its corresponding pin }
         pointer := 0;  found := false;
         for i:= 1 to maxpins do
          with symtable[i] do
           if token = name
            then begin
                  pointer := pinn; found := true
                 end
        end;
    otherwise:
        writeln ('!!! software error in search procedure')
   end
  end; {search}

 procedure start;
  var
   first : integer;
  begin
   while not(sym = equations) and (not Abort) and not(eof(source))do
    begin
     first := nexin + 1;
     if sym = ident
      then begin
            nexin := nexin + 1;
            symtable[nexin].name := token;
            gettoken;
            while sym = ident do
             begin      { get list of identifiers }
              nexin := nexin + 1;
              symtable[nexin].name := token;
              gettoken
             end;
            case sym of
             device: begin
                      nexin := first - 1;  {ignore all previous identifiers}
                      gettoken;
                      if sym = apostrophe
                       then begin
                             gettoken;
                             search (1);
                             if pointer = 0
                              then begin
                                    writeln ('** not a valid part ',token);
                                    Abort := true
                                   end
                              else begin
                                    pdevice := token;
                                    ptype := palknds[pointer];
                                    palkind := paltyp [pointer];
                                    gettoken;
                                    if sym = apostrophe
                                     then gettoken;
                                    if sym = semicolon
                                     then gettoken
                                     else Abort := true {screw the idiot***}
                                   end
                            end
                     end;
             pin:    begin
                      gettoken; { it must be a pin number }
                      while not(sym = int) do gettoken;
                      repeat
                       symtable[first].pinn := value;
                       first := first + 1;
                       gettoken
                      until first > nexin;
                      if sym = semicolon
                       then gettoken
                       else Abort := true       {screw the idiot ***}
                     end;
             otherwise:
                     begin
                      nexin := first - 1;
                      while not (sym = semicolon)
                        do gettoken;
                      gettoken
                     end
            end
           end
    end
  end;   {start}

 procedure titlemodule;
  begin
   gettoken;
   if sym = apostrophe
    then begin
          repeat
           gettoken
          until sym = apostrophe;
          gettoken;
          if sym = semicolon
           then begin
                 semimodule;
                 start
                end
           else start
         end
    else begin
          writeln ('** illegal construct for the title section');
          Abort := true
         end
  end;  {titlemodule}

 procedure flagmodule;
  begin
   gettoken;
   if sym = apostrophe
    then begin
          repeat
           gettoken
          until sym = apostrophe;
          gettoken;
          case sym of
           title : titlemodule;
           semicolon: begin
                        semimodule;
                        if sym = title
                         then titlemodule
                         else start
                      end;
           otherwise:
                start
          end
         end
    else begin
          writeln ('** illegal construct for the flag section');
          Abort := true
         end
  end;  {flagmodule}

 procedure arguments;
  begin
   gettoken;
   case sym of
    ident : begin
             gettoken;
             while not(sym = rgtparen)
              do gettoken;
             gettoken;
             case sym of
              flag : flagmodule;
              title: titlemodule;
              semicolon: begin
                          semimodule;
                          if sym = flag
                           then flagmodule
                           else if sym = title
                                 then titlemodule
                                 else start
                         end;
              otherwise:
                begin
                 writeln ('** illegal path after module arguments');
                 Abort := true
                end
             end
            end;
    rgtparen: begin
                gettoken;
                case sym of
                 flag : flagmodule;
                 title: titlemodule;
                 semicolon: begin
                             semimodule;
                             if sym = flag
                              then flagmodule
                              else if sym = title
                                    then titlemodule
                                    else start
                            end;
                 otherwise:
                        start
                end
              end;
    otherwise:
        begin
         writeln ('** missing right parenthesis in dummy argument list');
         Abort := true
        end
   end
  end;   {arguments}

 procedure getnames;
  begin
   gettoken;
   while not((sym = module))and (not empty)
    do gettoken;
   gettoken;
   if sym = ident
    then begin
          gettoken;
          case sym of
           lftparen :   arguments;
           flag:        flagmodule;
           title:       titlemodule;
           semicolon:   begin
                         semimodule;
                         case sym of
                          flag : flagmodule;
                          title: titlemodule;
                          otherwise:
                            start
                         end
                        end;
           otherwise:
             start
          end
         end
    else begin
          Abort := true;
          writeln ('** missing module name')
         end
  end; {getnames}

 procedure error (errnmbr : integer);
  begin
   case errnmbr of
    1 : begin
         writeln ('Signal name undefined: ',token)
        end;
    2 : begin
         writeln ('error in andoperator!')
        end;
    3 : begin
         writeln ('Expecting a signal name');
         writeln ('Undetermined token ',token)
        end;
    4 : begin
         writeln ('Expecting a "=" operator');
         writeln ('Got instead ',token)
        end;
    5 : begin
         writeln ('Expecting either a ":" or "=" operator');
         writeln ('Instead it got ',token)
        end;
    6 : begin
         writeln ('Expecting a boolean equation');
         writeln ('Unexpected token ',token)
        end;
    7 : begin
         writeln ('Exceeded total or-terms');
         writeln ('Output =',outtable[nexout].outname);
        end;
    8 : begin
         writeln (token,' not a valid input or feedback factor')
        end;
    9 : begin
         writeln ('Expecting ";" at end of equation')
        end;
   10 : begin
         writeln ('This device is not capable of this function')
        end;
   11 : begin
         writeln ('This device is not capable of true-form output ',token)
        end;
   12 : begin
         writeln ('Not a valid output pin for ',token);
        end;
    otherwise:
        writeln ('software error in error routine')
   end
  end; {error}

 procedure andterm;
  begin
   gettoken;
   case sym of
    ident :
     begin
      search (3);     {find pin number attached to this signal name}
      if not found
       then begin error(1); gettoken end
       else begin
             j := fusetoinp[palkind].transfer[pointer]; {get fuse number}
             if j < 0
              then error (8)   {not a valid input or feedback factor}
              else outtable[outindex].matrix[iterm,j]:= '1';
             gettoken;
             if sym = andoperator then andterm  {call back recursively}
            end
     end;
    invert :
     begin
      gettoken;     {get signal name}
      if sym = ident
       then
        begin
         search (3);     {find pin number attached to this signal name}
         if not found
          then begin error(1); gettoken end
          else begin
                j := fusetoinp[palkind].transfer[pointer]; {get fuse number}
                if j < 0
                 then error (8)   {not a valid input or feedback factor}
                 else begin
                       j := j + 1;    {increment fuse number}
                       outtable[outindex].matrix[iterm,j]:= '1'
                      end;
                gettoken;
                if sym = andoperator then andterm  {call back recursively}
               end
        end
       else error (3)   {expecting an identifier, i.e. signal name}
     end;
    otherwise:  error (2)
   end
  end; {andterm}

 procedure nodeterm (var pterm : ptermtyp);
  begin
   gettoken;
   case sym of
    ident :
     begin
      search (3);     {find pin number attached to this signal name}
      if not found
       then begin error(1); gettoken end
       else begin
             j := fusetoinp[palkind].transfer[pointer]; {get fuse number}
             if j < 0
              then error (8)   {not a valid input or feedback factor}
              else pterm[j]:= '1';
             gettoken;
             if sym = andoperator then nodeterm(pterm)  {call back recursively}
            end
     end;
    invert :
     begin
      gettoken;     {get signal name}
      if sym = ident
       then
        begin
         search (3);     {find pin number attached to this signal name}
         if not found
          then begin error(1); gettoken end
          else begin
                j := fusetoinp[palkind].transfer[pointer]; {get fuse number}
                if j < 0
                 then error (8)   {not a valid input or feedback factor}
                 else begin
                       j := j + 1;    {increment fuse number}
                       pterm[j]:= '1'
                      end;
                gettoken;
                if sym = andoperator then nodeterm(pterm)
               end
        end
       else error (3)   {expecting an identifier, i.e. signal name}
     end;
    otherwise:  error (2)
   end
  end; {nodeterm}

  procedure setiterm;
   begin
    case palkind of
     p22vx, p16l8,
     p20l10,p20l8 :  iterm := 2;   { all outputs have OE term }
     p16rx:
      case pointer of
        19,12 : if (ptype = '5')or(ptype='6')
                  then iterm := 2  else iterm := 1;
        18,13 : if (ptype = '6') then iterm :=2 else iterm := 1;
        otherwise:  iterm := 1
      end;
     p20rx:
      case pointer of
        22,15 : if (ptype = 'B')or(ptype='C')
                  then iterm := 2  else iterm := 1;
        21,16 : if (ptype = 'C') then iterm :=2 else iterm := 1;
        otherwise:  iterm := 1
      end;
     otherwise: iterm := 1
    end
   end; {setiterm}

  procedure getterms;
   begin
    case palkind of
     p10l8,p12l10:
        totalterms := 2;
     p14l4,p20l10:
        totalterms := 4;
     p12l6:
        if (pointer = 18) or (pointer = 13)
          then totalterms := 4
          else totalterms := 2;
     p14l8:
        if (pointer = 22) or (pointer = 15)
          then totalterms := 4
          else totalterms := 2;
     p16l6:
        if (pointer = 19) or (pointer = 18)
          then totalterms := 2
          else totalterms := 4;
     p18l4:
        if (pointer = 19) or (pointer = 18)
          then totalterms := 4
          else totalterms := 6;
     p22vx:
        case pointer of
         23,14 :  totalterms := 9;
         22,15 :  totalterms := 11;
         21,16 :  totalterms := 13;
         20,17 :  totalterms := 15;
         19,18 :  totalterms := 17;
         otherwise:  writeln ('Software error in procedure getterms!')
        end;
     otherwise:
        totalterms := 8
    end
   end; {getterms}

 procedure map (typ : char);
  var i,j : integer;
  begin {map}
   case typ of
    '0' : {initialize a new output}
        begin
         {first find out if output already has been defined, that is if
           output has an enable previously defined }
         found := false;
writeln ('output : ',token,' nexout=',nexout);
         for i:=1 to nexout do
           with outtable[i] do
            if outname = token
             then begin
                   found := true;     outindex := i
                  end;
         getterms;   {find out how many or-terms this output has }
         setiterm;   {find out where to start orterms }
         if not found
          then begin
                nexout := nexout + 1;
                outtable[nexout].outnumb := pointer; {store output pin number}
                outtable[nexout].outname := token;   {store output name }
                for i:=1 to maxterms do
                 for j:=1 to maxcols do
                  outtable[nexout].matrix[i,j]:= '0';
                outtable[nexout].outkind := nonreg;     {default}
                if iterm > 1 then outtable[nexout].matrix[1,1]:= 'H';
                case ptype of
                 '2' :  outtable[nexout].form := high;
                 otherwise:  outtable[nexout].form := low
                end;
                outindex := nexout
               end
        end
   end
  end; {map}

 procedure orterms;
  begin
   andterm;
   if sym = oroperator
    then begin
          iterm := iterm + 1;
          if iterm > totalterms
           then error (7)
           else orterms
         end
    else begin    {mark termination of equation}
          iterm := iterm + 1;
          outtable[outindex].matrix[iterm,1]:= 'X'
         end
  end; {orterms}

 procedure getmatrix;
  begin {getmatrix}
   case sym of
     enable :
      begin
       gettoken;
       if sym = ident
        then begin
              search (3);  {find out pin number}
              if not found
               then error (1)
               else begin
                      map ('0');   {create an output description database}
                      if iterm > 1 then
                       begin
                        outtable[nexout].matrix[1,1]:= '0'; {clear possible H}
                        gettoken;    {get equal sign}
                        if sym = eql
                         then begin
                               iterm := 1;
                               andterm;
                               if sym = semicolon
                                then begin
                                      gettoken;   {find out next step}
                                      if sym <> ends then getmatrix
                                     end
                                else error (9)   {missing semicolon}
                              end
                         else error (4)
                       end
                       else error (10)  { Output has no OE term }
                    end
             end
        else error (3)          {expecting a signal name}
      end;
     clear:
      begin
       {find out if this is a Pal 22v10}
       if ptype <> 'D'
        then error (10)
        else begin
              gettoken;  { read dummy pseudo pin name }
              gettoken;  { get equal sign }
              if (sym = eql)
               then begin
                     ar[1]:= '0';   {erase default}
                     nodeterm (ar);
                     if sym = semicolon
                      then begin
                            gettoken;  {find out next step}
                            if sym <> ends then getmatrix
                           end
                      else error (9)
                    end
               else error (4)
             end
      end;
     preset:
      begin
       {find out if this is a Pal 22v10}
       if ptype <> 'D'
        then error (10)
        else begin
              gettoken;  { read dummy pseudo pin name }
              gettoken;  { get equal sign }
              if (sym = eql)
               then begin
                     sp[1]:= '0';   {erase default}
                     nodeterm (sp);
                     if sym = semicolon
                      then begin
                            gettoken;  {find out next step}
                            if sym <> ends then getmatrix
                           end
                      else error (9)
                    end
               else error (4)
             end
      end;
     ident : {a min-term equation}
      begin
       if (ptype = 'D') or (ptype = '2')
        then begin
              search (3);
              if not found
               then error (1)
               else begin
                     map ('0');    {initialize new entry in the output table}
                     outtable[nexout].form := high;      {set output pol }
                     gettoken;  { get equal sign }
                     case sym of
                      colon : {it is a registered output }
                       begin
                        gettoken;     {get equal sign}
                        if (sym = eql)
                         then
                          begin
                           outtable[outindex].outkind := reg;
                           orterms;
                           if sym = semicolon
                            then begin
                                  gettoken; {find out next step}
                                  if sym <> ends then getmatrix
                                 end
                            else error (9)
                          end
                         else error (4)
                       end;
                      eql : {it is a non_registered output }
                       begin
                        outtable[outindex].outkind := nonreg;
                        orterms;
                        if sym = semicolon
                         then begin
                               gettoken; {find out next step}
                               if sym <> ends then getmatrix
                              end
                         else error (9)
                       end;
                      otherwise:  error (5)
                     end
                    end
             end
        else error (11)    {this device is not capable of true form output}
      end;
     invert: {a max-term equation}
      begin
       gettoken;    {get signal name}
       if sym = ident
        then begin
              search (3);       {obtain pin number from table}
              if (not found)
               then error (1)
               else begin
                     map ('0');    {initialize new entry in the output table}
                     gettoken;  { get equal sign }
                     case sym of
                      colon : {it is a registered output }
                       begin
                        gettoken;     {get equal sign}
                        if (sym = eql)
                         then
                          begin
                           outtable[outindex].outkind := reg;
                           orterms;
                           if sym = semicolon
                            then begin
                                  gettoken; {find out next step}
                                  if sym <> ends then getmatrix
                                 end
                            else error (9)
                          end
                         else error (4)
                       end;
                      eql : {it is a non_registered output }
                       begin
                        outtable[outindex].outkind := nonreg;
                        orterms;
                        if sym = semicolon
                         then begin
                               gettoken; {find out next step}
                               if sym <> ends then getmatrix
                              end
                         else error (9)
                       end;
                      otherwise:  error (5)
                     end
                    end
             end
        else error (3)
      end;
     otherwise: error (6) {fatal error, not a valid equation}
   end {case of sym}
  end; {getmatrix}

 procedure convrt (var numbr1 : Long_Integer; var ihex : string2);
  var
   i : integer;
   res,zero,a : Long_Integer;
   vel : Long_Integer;
  begin
   zero := ord ('0');
   a := ord ('A');
   i := 0;
   ihex [1]:= '0';     ihex [2]:= '0';
   ihex [3]:= '0';     ihex [4]:= '0';
   vel := numbr1 & $0000ffff;
   repeat
    res := vel mod 16;
    vel := vel div 16;
    if res < 10
      then  ihex [4-i]:= chr(res + zero)
      else  ihex [4-i]:= chr(res + a - 10);
    i:= i + 1
   until (vel = 0)
  end; {convrt}

 procedure dojedec;
{This procedure generates the jedec file based on information from getmatrix}
  var
   stx,etx : char;
   i,j,k : integer;
   totalcol,totalfuse,nouts,firstp : integer;
   outn,bitn, n : integer;
   checksum : Long_Integer;
   power2 : array [1..8] of integer;
   scksum : string2;
   finish : boolean;
  begin
   i:= 2;       stx:= chr(i);   i:= 3;  etx := chr(i);
   power2[1]:= 1;
   for i:=2 to 8 do power2[i]:= 2*power2[i-1];
   pal16 := false;
   case palkind of
    p10l8: begin
            pal16 := true;      totalcol := 20;
            totalfuse := 320;   nouts := 8;     firstp := 19;
           end;
    p12l6: begin
            pal16 := true;      totalcol := 24;
            totalfuse := 384;   nouts := 6;     firstp := 18;
           end;
    p14l4: begin
            pal16 := true;      totalcol := 28;
            totalfuse := 448;   nouts := 4;     firstp := 17;
           end;
    p16l2: begin
            pal16 := true;      totalcol := 32;
            totalfuse := 512;   nouts := 2;     firstp := 16;
           end;
    p16l8,p16rx:
           begin
            pal16 := true;      totalcol := 32;
            totalfuse := 2048;  nouts := 8;     firstp := 19;
           end;
    p12l10:begin
            totalcol := 24;     totalfuse := 480;
            nouts := 10;        firstp := 23;
           end;
    p14l8: begin
            totalcol := 28;     totalfuse := 560;
            nouts := 8;         firstp := 22;
           end;
    p16l6: begin
            totalcol := 32;     totalfuse := 640;
            nouts := 6;         firstp := 21;
           end;
    p18l4: begin
            totalcol := 36;     totalfuse := 720;
            nouts := 4;         firstp := 20;
           end;
    p20l2: begin
            totalcol := 40;     totalfuse := 640;
            nouts := 2;         firstp := 19;
           end;
    p20l10:begin
            totalcol := 40;     totalfuse := 1600;
            nouts := 10;        firstp := 23;
           end;
    p20l8,p20rx:
           begin
            totalcol := 40;     totalfuse := 2560;
            nouts := 8;         firstp := 22;
           end;
    p22vx: begin
            totalcol := 44;     totalfuse := 5828;
            nouts := 10;        firstp := 23;
           end
   end; {case of ptype}
   write (source,stx);     {write start of text}
   write (source,'Portable Pal Assembler Jedec Output for device :');
   writeln (source,pdevice,'*');
   if pal16 then  write (source,'QP20* ')
            else  write (source,'QP24* ');
   writeln (source,'QF',totalfuse:4,'*');
   write (source,'L0000');
   {at this point in time, it is assumed that every output signal has a valid
    output pin }
   checksum := 0;    bitn:= 0;    {initialize checksum variables}
   if palkind = p22vx
    then {let us take care of special nodes}
     begin
      writeln(source);
      if ar[1] = 'L'
       then begin
              for k:=1 to totalcol do
               write (source,'0');    {unblown fuse}
              bitn := bitn + totalcol   {increment fuse count}
            end
       else begin
             for k:=1 to totalcol do
              if ar[k] = '1' then begin
                                   write (source,'0');
                                   bitn := bitn + 1
                                  end
                             else begin
                                   write (source,'1');
                                   n := (bitn mod 8) + 1;
                                   checksum := checksum + power2[n];
                                   bitn := bitn + 1
                                  end
            end
     end;
   for i:= 1 to nouts do
    begin
    {first find out if there is an output with such pin}
     outn := 0;    {default to no output defined for current pin}
     pointer := firstp;
     getterms;   {find out how many or-terms for this output}
     for j:=1 to nexout do
      with outtable[j] do
       if outnumb = firstp   then outn := j;
     if outn = 0
      then begin  {no output defined for this output pin}
            for j:=1 to totalterms do
             begin
              writeln (source);
              for k:=1 to totalcol do
               write (source,'0');    {unblown fuse}
              bitn := bitn + totalcol   {increment fuse count}
             end
           end
      else begin  {there is an output definition for this output pin}
            finish := false;
            for j:=1 to totalterms do
             begin
              writeln (source);     {terminate previous line}
              with outtable[outn] do
               if (matrix[j,1] <> 'X') and not finish
                then
                 for k:=1 to totalcol do
                  if matrix[j,k] = '1' then begin
                                             write (source,'0');
                                             bitn := bitn + 1
                                            end
                                       else begin
                                             write (source,'1');
                                             n := (bitn mod 8) + 1;
                                             checksum := checksum + power2[n];
                                             bitn := bitn + 1
                                            end
                else begin
                      for k:=1 to totalcol do write (source,'0');
                      bitn := bitn + totalcol;
                      finish := true     {note that this method is redundant}
                     end
             end
           end;
     firstp := firstp - 1         {step to next valid output}
    end;
   if palkind = p22vx
    then {let us take care of special nodes}
     begin
      writeln(source);
      if sp[1] = 'L'
       then begin
              for k:=1 to totalcol do
               write (source,'0');    {unblown fuse}
              bitn := bitn + totalcol   {increment fuse count}
            end
       else begin
             for k:=1 to totalcol do
              if sp[k] = '1' then begin
                                   write (source,'0');
                                   bitn := bitn + 1
                                  end
                             else begin
                                   write (source,'1');
                                   n := (bitn mod 8) + 1;
                                   checksum := checksum + power2[n];
                                   bitn := bitn + 1
                                  end
            end;
      writeln (source,'*');  {terminate main fuse body}
      {now let's take care of output macro cells}
      write (source,'L5808 '); {it must be 5808 }
      firstp := 23;
      for i:=1 to nouts do
       begin
        outn := 0;
        for j:=1 to nexout do
         with outtable[j] do
          if outnumb = firstp then outn := j;
        if outn <> 0
         then begin
               if outtable[outn].form = high
                then begin
                      write (source,'1');
                      n := (bitn mod 8) + 1;
                      checksum := checksum + power2[n];
                      bitn := bitn + 1
                     end
                else begin write(source,'0'); bitn := bitn + 1 end;
               if outtable[outn].outkind = reg
                then begin write(source,'0'); bitn := bitn + 1 end
                else begin
                      write (source,'1');
                      n := (bitn mod 8) + 1;
                      checksum := checksum + power2[n];
                      bitn := bitn + 1
                     end
              end
         else begin
               write (source,'00');     bitn := bitn + 2
              end;
        firstp := firstp - 1   {get next valid output}
       end;
      writeln (source,'*')
     end
    else writeln (source,'*');  {terminate fuse list}
   convrt (checksum,scksum);
   writeln (source,'C',scksum,'*');
   writeln (source,etx,'0000');     {write end of transmission}
  end; {dojedec}

 begin { plassm }
  nexout := 0;
  reserved[1]:= 'device         ';     reserved[2]:= 'pin            ';
  reserved[3]:= 'equations      ';     reserved[4]:= 'module         ';
  reserved[5]:= 'flag           ';     reserved[6]:= 'title          ';
  reserved[7]:= 'node           ';     reserved[8]:= 'istype         ';
  reserved[9]:= 'macro          ';     reserved[10]:='ENABLE         ';
  reserved[11]:='RESET          ';     reserved[12]:='PRESET         ';
  reserved[13]:='end            ';
  wsym [1]:= device;    wsym[2]:= pin;  wsym[3]:= equations;
  wsym [4]:= module;    wsym[5]:= flag; wsym[6]:= title;
  wsym [7]:= node;      wsym[8]:= stype; wsym[9]:= macro;
  wsym [10]:= enable;   wsym[11]:= clear; wsym[12]:= preset;
  wsym [13]:= ends;
  palknds[1]:= '1';     pals[1]:= 'p10l8          ';
  paltyp [1]:= p10l8;
  palknds[2]:= '1';     pals[2]:= 'p12l6          ';
  paltyp [2]:= p12l6;
  palknds[3]:= '1';     pals[3]:= 'p14l4          ';
  paltyp [3]:= p14l4;
  palknds[4]:= '1';     pals[4]:= 'p16l2          ';
  paltyp [4]:= p16l2;
  palknds[5]:= '2';     pals[5]:= 'p10h8          ';
  paltyp [5]:= p10l8;
  palknds[6]:= '2';     pals[6]:= 'p12h6          ';
  paltyp [6]:= p12l6;
  palknds[7]:= '2';     pals[7]:= 'p14h4          ';
  paltyp [7]:= p14l4;
  palknds[8]:= '2';     pals[8]:= 'p16h2          ';
  paltyp [8]:= p16l2;
  palknds[9]:= '3';     pals[9]:= 'p16l8          ';
  paltyp [9]:= p16l8;
  palknds[10]:= '4';    pals[10]:= 'p16r8          ';
  paltyp [10]:= p16rx;
  palknds[11]:= '5';    pals[11]:= 'p16r6          ';
  paltyp [11]:= p16rx;
  palknds[12]:= '6';    pals[12]:= 'p16r4          ';
  paltyp [12]:= p16rx;
  palknds[13]:= '7';    pals[13]:= 'p12l10         ';
  paltyp [13]:= p12l10;
  palknds[14]:= '7';    pals[14]:= 'p14l8          ';
  paltyp [14]:= p14l8;
  palknds[15]:= '7';    pals[15]:= 'p16l6          ';
  paltyp [15]:= p16l6;
  palknds[16]:= '7';    pals[16]:= 'p18l4          ';
  paltyp [16]:= p18l4;
  palknds[17]:= '7';    pals[17]:= 'p20l2          ';
  paltyp [17]:= p20l2;
  palknds[18]:= '8';    pals[18]:= 'p20l10         ';
  paltyp [18]:= p20l10;
  palknds[19]:= '9';    pals[19]:= 'p20l8          ';
  paltyp [19]:= p20l8;
  palknds[20]:= 'A';    pals[20]:= 'p20r8          ';
  paltyp [20]:= p20rx;
  palknds[21]:= 'B';    pals[21]:= 'p20r6          ';
  paltyp [21]:= p20rx;
  palknds[22]:= 'C';    pals[22]:= 'p20r4          ';
  paltyp [22]:= p20rx;
  palknds[23]:= 'D';    pals[23]:= 'p22v10         ';
  paltyp [23]:= p22vx;
  { pin number to fuse column transform }
  with fusetoinp [p10l8] do
   begin
    for i:=1 to maxpins do transfer[i]:= -1;
    transfer[1]:= 3;    transfer[2]:= 1;        transfer[3]:= 5;
    transfer[4]:= 7;    transfer[5]:= 9;        transfer[6]:= 11;
    transfer[7]:= 13;   transfer[8]:= 15;       transfer[9]:= 17;
    transfer[11]:= 19
   end;
  with fusetoinp [p12l6] do
   begin
    for i:=1 to maxpins do transfer[i]:= -1;
    transfer[1]:= 3;    transfer[2]:= 1;        transfer[3]:= 5;
    transfer[4]:= 9;    transfer[5]:= 11;       transfer[6]:= 13;
    transfer[7]:= 15;   transfer[8]:= 17;       transfer[9]:= 21;
    transfer[11]:= 23;  transfer[12]:= 19;      transfer[19]:= 7
   end;
  with fusetoinp [p14l4] do
   begin
    for i:=1 to maxpins do transfer[i]:= -1;
    transfer[1]:= 3;    transfer[2]:= 1;        transfer[3]:= 5;
    transfer[4]:= 9;    transfer[5]:= 13;       transfer[6]:= 15;
    transfer[7]:= 17;   transfer[8]:= 21;       transfer[9]:= 25;
    transfer[11]:= 27;  transfer[12]:= 23;      transfer[13]:= 19;
    transfer[18]:= 11;  transfer[19]:= 7
   end;
  with fusetoinp [p16l2] do
   begin
    for i:=1 to maxpins do transfer[i]:= -1;
    transfer[1]:= 3;    transfer[2]:= 1;        transfer[3]:= 5;
    transfer[4]:= 9;    transfer[5]:= 13;       transfer[6]:= 17;
    transfer[7]:= 21;   transfer[8]:= 25;       transfer[9]:= 29;
    transfer[11]:= 31;  transfer[12]:= 27;      transfer[13]:= 23;
    transfer[14]:= 19;  transfer[17]:= 15;      transfer[18]:= 11;
    transfer[19]:= 7
   end;
  with fusetoinp [p16l8] do
   begin
    for i:=1 to maxpins do transfer[i]:= -1;
    transfer[1]:= 3;    transfer[2]:= 1;        transfer[3]:= 5;
    transfer[4]:= 9;    transfer[5]:= 13;       transfer[6]:= 17;
    transfer[7]:= 21;   transfer[8]:= 25;       transfer[9]:= 29;
    transfer[11]:= 31;  transfer[13]:= 27;      transfer[14]:= 23;
    transfer[15]:= 19;  transfer[16]:= 15;      transfer[17]:= 11;
    transfer[18]:= 7
   end;
  with fusetoinp [p16rx] do
   begin
    for i:=1 to maxpins do transfer[i]:= -1;
                         transfer[2]:= 1;       transfer[3]:= 5;
    transfer[4]:= 9;     transfer[5]:= 13;      transfer[6]:= 17;
    transfer[7]:= 21;    transfer[8]:= 25;      transfer[9]:= 29;
                         transfer[12]:= 31;     transfer[13]:= 27;
    transfer[14]:= 23;   transfer[15]:= 19;     transfer[16]:= 15;
    transfer[17]:= 11;   transfer[18]:= 7;      transfer[19]:= 3
   end;
  with fusetoinp [p12l10] do
   begin
    for i:=1 to maxpins do transfer[i]:= -1;
    transfer[1]:= 3;    transfer[2]:= 1;        transfer[3]:= 5;
    transfer[4]:= 7;    transfer[5]:= 9;        transfer[6]:= 11;
    transfer[7]:= 13;   transfer[8]:= 15;       transfer[9]:= 17;
    transfer[10]:= 19;  transfer[11]:= 21;      transfer[13]:= 23
   end;
  with fusetoinp [p14l8] do
   begin
    for i:=1 to maxpins do transfer[i]:= -1;
    transfer[1]:= 3;    transfer[2]:= 1;        transfer[3]:= 5;
    transfer[4]:= 9;    transfer[5]:= 11;       transfer[6]:= 13;
    transfer[7]:= 15;   transfer[8]:= 17;       transfer[9]:= 19;
    transfer[10]:= 21;  transfer[11]:= 25;
    transfer[13]:= 27;  transfer[14]:= 23;      transfer[23]:= 7
   end;
  with fusetoinp [p16l6] do
   begin
    for i:=1 to maxpins do transfer[i]:= -1;
    transfer[1]:= 3;    transfer[2]:= 1;        transfer[3]:= 5;
    transfer[4]:= 9;    transfer[5]:= 13;       transfer[6]:= 15;
    transfer[7]:= 17;   transfer[8]:= 19;       transfer[9]:= 21;
    transfer[10]:= 25;  transfer[11]:= 29;
    transfer[13]:= 31;  transfer[14]:= 27;      transfer[15]:= 23;
    transfer[22]:= 11;  transfer[23]:= 7
   end;
  with fusetoinp [p18l4] do
   begin
    for i:=1 to maxpins do transfer[i]:= -1;
    transfer[1]:= 3;    transfer[2]:= 1;        transfer[3]:= 5;
    transfer[4]:= 9;    transfer[5]:= 13;       transfer[6]:= 17;
    transfer[7]:= 19;   transfer[8]:= 21;       transfer[9]:= 25;
    transfer[10]:= 29;  transfer[11]:= 33;
    transfer[13]:= 35;  transfer[14]:= 31;     transfer[15]:= 27;
    transfer[16]:= 23;  transfer[21]:= 15;     transfer[22]:= 11;
    transfer[23]:= 7
   end;
  with fusetoinp [p20l2] do
   begin
    for i:=1 to maxpins do transfer[i]:= -1;
    transfer[1]:= 3;    transfer[2]:= 1;        transfer[3]:= 5;
    transfer[4]:= 9;    transfer[5]:= 13;       transfer[6]:= 17;
    transfer[7]:= 21;   transfer[8]:= 25;       transfer[9]:= 29;
    transfer[10]:= 33;  transfer[11]:= 37;
    transfer[13]:= 39;  transfer[14]:= 35;      transfer[15]:= 31;
    transfer[16]:= 27;  transfer[17]:= 23;
    transfer[20]:= 19;  transfer[21]:= 15;      transfer[22]:= 11;
    transfer[23]:= 7
   end;
  with fusetoinp [p20l10] do
   begin
    for i:=1 to maxpins do transfer[i]:= -1;
    transfer[1]:= 3;    transfer[2]:= 1;        transfer[3]:= 5;
    transfer[4]:= 9;    transfer[5]:= 13;       transfer[6]:= 17;
    transfer[7]:= 21;   transfer[8]:= 25;       transfer[9]:= 29;
    transfer[10]:= 33;  transfer[11]:= 37;
    transfer[13]:= 39;  transfer[15]:= 35;      transfer[16]:= 31;
    transfer[17]:= 27;  transfer[18]:= 23;      transfer[19]:= 19;
    transfer[20]:= 15;  transfer[21]:= 11;      transfer[22]:= 7
   end;
  with fusetoinp [p20l8] do
   begin
    for i:=1 to maxpins do transfer[i]:= -1;
    transfer[1]:= 3;    transfer[2]:= 1;        transfer[3]:= 5;
    transfer[4]:= 9;    transfer[5]:= 13;       transfer[6]:= 17;
    transfer[7]:= 21;   transfer[8]:= 25;       transfer[9]:= 29;
    transfer[10]:= 33;  transfer[11]:= 37;
    transfer[13]:= 39;  transfer[14]:= 35;
    transfer[16]:= 31;  transfer[17]:= 27;      transfer[18]:= 23;
    transfer[19]:= 19;  transfer[20]:= 15;      transfer[21]:= 11;
    transfer[23]:= 7
   end;
  with fusetoinp [p20rx] do
   begin
    for i:=1 to maxpins do transfer[i]:= -1;
                        transfer[2]:= 1;        transfer[3]:= 5;
    transfer[4]:= 9;    transfer[5]:= 13;       transfer[6]:= 17;
    transfer[7]:= 21;   transfer[8]:= 25;       transfer[9]:= 29;
    transfer[10]:= 33;  transfer[11]:= 37;
                        transfer[14]:= 39;      transfer[15]:= 35;
    transfer[16]:= 31;  transfer[17]:= 27;      transfer[18]:= 23;
    transfer[19]:= 19;  transfer[20]:= 15;      transfer[21]:= 11;
    transfer[22]:= 7;   transfer[23]:= 3
   end;
  with fusetoinp [p22vx] do
   begin
    for i:=1 to maxpins do transfer[i]:= -1;
    transfer[1]:= 1;    transfer[2]:= 5;        transfer[3]:= 9;
    transfer[4]:= 13;   transfer[5]:= 17;       transfer[6]:= 21;
    transfer[7]:= 25;   transfer[8]:= 29;       transfer[9]:= 33;
    transfer[10]:= 37;  transfer[11]:= 41;
    transfer[13]:= 43;  transfer[14]:= 39;      transfer[15]:= 35;
    transfer[16]:= 31;  transfer[17]:= 27;      transfer[18]:= 23;
    transfer[19]:= 19;  transfer[20]:= 15;      transfer[21]:= 11;
    transfer[22]:= 7;   transfer[23]:= 3
   end;
  tab := chr(9);        nexin := 0;     Abort := false;    ch:= blank;
  writeln;
  writeln ('  Portable Pal Assembler');
  writeln ('  Rev.1  Sep 1988');
  writeln ('  By: Erasmo Brenes ');
  writeln ('  (c) Copyright 1987,1988');
  writeln;
  for i:=1 to 80 do filspc[i]:= blank;
  for i:=1 to maxcols do begin ar[i]:= '0'; sp[i]:= '0'  end;
  { Default to inactive for ar and sp}
  ar[1]:= 'L';  sp[1]:= 'L';
  write ('Enter source filename_');
  readln (filspc);
  reset(source,filspc);
  getnames;
{*** diag print ***}
 for i:= 1 to nexin do
  with symtable[i] do
   writeln ('pin name= ',name,' pin#=',pinn:3);
 i:= 1;
 if not Abort
  then begin
        gettoken;    {get first token before calling getmatrix}
        getmatrix;
        close (source);   {release previous handle}
        while (filspc[i] <> '.') do i:= i + 1;
        i:= i + 1;    j:= i;
        filspc[i]:= 'j';      i:= i + 1;
        filspc[i]:= 'e';      i:= i + 1;
        filspc[i]:= 'd';
        rewrite (source,filspc);
        if not Abort then dojedec;
        writeln ('Press any key to return');
        while (not Keypress) do begin end    {ie do nothing}
       end
 end.
