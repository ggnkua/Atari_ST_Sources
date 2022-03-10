
$ sysprog, ucsd, heap_dispose, partial_eval $

{$ debug$}


program basic(input, output);


const

   checking = true;

   varnamelen = 20;
   maxdims = 4;



type

   varnamestring = string[varnamelen];

   string255 = string[255];
   string255ptr = ^string255;

   tokenkinds = (tokvar, toknum, tokstr, toksnerr,

                 tokplus, tokminus, toktimes, tokdiv, tokup, toklp, tokrp, 
                 tokcomma, toksemi, tokcolon, tokeq, toklt, tokgt,
                 tokle, tokge, tokne,

                 tokand, tokor, tokxor, tokmod, toknot, toksqr, toksqrt, toksin,
                 tokcos, toktan, tokarctan, toklog, tokexp, tokabs, toksgn,
                 tokstr_, tokval, tokchr_, tokasc, toklen, tokmid_, tokpeek,

                 tokrem, toklet, tokprint, tokinput, tokgoto, tokif, tokend, 
                 tokstop, tokfor, toknext, tokwhile, tokwend, tokgosub,
                 tokreturn, tokread, tokdata, tokrestore, tokgotoxy, tokon,
                 tokdim, tokpoke,

                 toklist, tokrun, toknew, tokload, tokmerge, toksave, tokbye,
                 tokdel, tokrenum,

                 tokthen, tokelse, tokto, tokstep);

   realptr = ^real;
   basicstring = string255ptr;
   stringptr = ^basicstring;
   numarray = array[0..maxint] of real;
   arrayptr = ^numarray;
   strarray = array[0..maxint] of basicstring;
   strarrayptr = ^strarray;

   tokenptr = ^tokenrec;
   lineptr = ^linerec;
   varptr = ^varrec;
   loopptr = ^looprec;

   tokenrec =
      record
         next : tokenptr;
         case kind : tokenkinds of
            tokvar : (vp : varptr);
            toknum : (num : real);
            tokstr, tokrem : (sp : string255ptr);
            toksnerr : (snch : char);
      end;

   linerec =
      record
         num, num2 : integer;
         txt : tokenptr;
         next : lineptr;
      end;

   varrec =
      record
         name : varnamestring;
         next : varptr;
         dims : array [1..maxdims] of integer;
         numdims : 0..maxdims;
         case stringvar : boolean of
            false : (arr : arrayptr;  val : realptr;  rv : real);
            true : (sarr : strarrayptr;  sval : stringptr;  sv : basicstring);
      end;

   valrec =
      record
         case stringval : boolean of
            false : (val : real);
            true : (sval : basicstring);
      end;

   loopkind = (forloop, whileloop, gosubloop);
   looprec =
      record
         next : loopptr;
         homeline : lineptr;
         hometok : tokenptr;
         case kind : loopkind of
            forloop :
               ( vp : varptr;
                 max, step : real );
      end;



var

   inbuf : string255ptr;

   linebase : lineptr;
   varbase : varptr;
   loopbase : loopptr;

   curline : integer;
   stmtline, dataline : lineptr;
   stmttok, datatok, buf : tokenptr;

   exitflag : boolean;

   excp_line ['EXCP_LINE'] : integer;



$if not checking$
   $range off$
$end$



procedure misc_getioerrmsg(var s : string; io : integer);
   external;

procedure misc_printerror(er, io : integer);
   external;

function asm_iand(a, b : integer) : integer;
   external;

function asm_ior(a, b : integer) : integer;
   external;

procedure hpm_new(var p : anyptr; size : integer);
   external;

procedure hpm_dispose(var p : anyptr; size : integer);
   external;



procedure restoredata;
   begin
      dataline := nil;
      datatok := nil;
   end;



procedure clearloops;
   var
      l : loopptr;
   begin
      while loopbase <> nil do
         begin
            l := loopbase^.next;
            dispose(loopbase);
            loopbase := l;
         end;
   end;



function arraysize(v : varptr) : integer;
   var
      i, j : integer;
   begin
      with v^ do
         begin
            if stringvar then
               j := 4
            else
               j := 8;
            for i := 1 to numdims do
               j := j * dims[i];
         end;
      arraysize := j;
   end;


procedure clearvar(v : varptr);
   begin
      with v^ do
         begin
            if numdims <> 0 then
               hpm_dispose(arr, arraysize(v))
            else if stringvar and (sv <> nil) then
               dispose(sv);
            numdims := 0;
            if stringvar then
               begin
                  sv := nil;
                  sval := addr(sv);
               end
            else
               begin
                  rv := 0;
                  val := addr(rv);
               end;
         end;
   end;


procedure clearvars;
   var
      v : varptr;
   begin
      v := varbase;
      while v <> nil do
         begin
            clearvar(v);
            v := v^.next;
         end;
   end;



function numtostr(n : real) : string255;
   var
      s : string255;
      i : integer;
   begin
      setstrlen(s, 255);
      if (n <> 0) and (abs(n) < 1e-2) or (abs(n) >= 1e12) then
         begin
            strwrite(s, 1, i, n);
            setstrlen(s, i-1);
            numtostr := s;
         end
      else
         begin
            strwrite(s, 1, i, n:30:10);
            repeat
               i := i - 1;
            until s[i] <> '0';
            if s[i] = '.' then
               i := i - 1;
            setstrlen(s, i);
            numtostr := strltrim(s);
         end;
   end;



procedure parse(inbuf : string255ptr; var buf : tokenptr);

   const
      toklength = 20;

   type
      chset = set of char;

   const
      idchars = chset ['A'..'Z','a'..'z','0'..'9','_','$'];

   var
      i, j, k : integer;
      token : string[toklength];
      t, tptr : tokenptr;
      v : varptr;
      ch : char;
      n, d, d1 : real;

   begin
      tptr := nil;
      buf := nil;
      i := 1;
      repeat
         ch := ' ';
         while (i <= strlen(inbuf^)) and (ch = ' ') do
            begin
               ch := inbuf^[i];
               i := i + 1;
            end;
         if ch <> ' ' then
            begin
               new(t);
               if tptr = nil then
                  buf := t
               else
                  tptr^.next := t;
               tptr := t;
               t^.next := nil;
               case ch of
                  'A'..'Z', 'a'..'z' :
                     begin
                        i := i - 1;
                        j := 0;
                        setstrlen(token, strmax(token));
                        while (i <= strlen(inbuf^)) and (inbuf^[i] in idchars) do
                           begin
                              if j < toklength then
                                 begin
                                    j := j + 1;
                                    token[j] := inbuf^[i];
                                 end;
                              i := i + 1;
                           end;
                        setstrlen(token, j);
                        if (token = 'and')     or (token = 'AND')     then t^.kind := tokand     
                   else if (token = 'or')      or (token = 'OR')      then t^.kind := tokor      
                   else if (token = 'xor')     or (token = 'XOR')     then t^.kind := tokxor     
                   else if (token = 'not')     or (token = 'NOT')     then t^.kind := toknot     
                   else if (token = 'mod')     or (token = 'MOD')     then t^.kind := tokmod     
                   else if (token = 'sqr')     or (token = 'SQR')     then t^.kind := toksqr     
                   else if (token = 'sqrt')    or (token = 'SQRT')    then t^.kind := toksqrt    
                   else if (token = 'sin')     or (token = 'SIN')     then t^.kind := toksin     
                   else if (token = 'cos')     or (token = 'COS')     then t^.kind := tokcos     
                   else if (token = 'tan')     or (token = 'TAN')     then t^.kind := toktan     
                   else if (token = 'arctan')  or (token = 'ARCTAN')  then t^.kind := tokarctan  
                   else if (token = 'log')     or (token = 'LOG')     then t^.kind := toklog     
                   else if (token = 'exp')     or (token = 'EXP')     then t^.kind := tokexp     
                   else if (token = 'abs')     or (token = 'ABS')     then t^.kind := tokabs     
                   else if (token = 'sgn')     or (token = 'SGN')     then t^.kind := toksgn     
                   else if (token = 'str$')    or (token = 'STR$')    then t^.kind := tokstr_    
                   else if (token = 'val')     or (token = 'VAL')     then t^.kind := tokval     
                   else if (token = 'chr$')    or (token = 'CHR$')    then t^.kind := tokchr_    
                   else if (token = 'asc')     or (token = 'ASC')     then t^.kind := tokasc     
                   else if (token = 'len')     or (token = 'LEN')     then t^.kind := toklen     
                   else if (token = 'mid$')    or (token = 'MID$')    then t^.kind := tokmid_    
                   else if (token = 'peek')    or (token = 'PEEK')    then t^.kind := tokpeek    
                   else if (token = 'let')     or (token = 'LET')     then t^.kind := toklet     
                   else if (token = 'print')   or (token = 'PRINT')   then t^.kind := tokprint   
                   else if (token = 'input')   or (token = 'INPUT')   then t^.kind := tokinput   
                   else if (token = 'goto')    or (token = 'GOTO')    then t^.kind := tokgoto    
                   else if (token = 'go to')   or (token = 'GO TO')   then t^.kind := tokgoto    
                   else if (token = 'if')      or (token = 'IF')      then t^.kind := tokif      
                   else if (token = 'end')     or (token = 'END')     then t^.kind := tokend     
                   else if (token = 'stop')    or (token = 'STOP')    then t^.kind := tokstop    
                   else if (token = 'for')     or (token = 'FOR')     then t^.kind := tokfor     
                   else if (token = 'next')    or (token = 'NEXT')    then t^.kind := toknext    
                   else if (token = 'while')   or (token = 'WHILE')   then t^.kind := tokwhile   
                   else if (token = 'wend')    or (token = 'WEND')    then t^.kind := tokwend    
                   else if (token = 'gosub')   or (token = 'GOSUB')   then t^.kind := tokgosub   
                   else if (token = 'return')  or (token = 'RETURN')  then t^.kind := tokreturn  
                   else if (token = 'read')    or (token = 'READ')    then t^.kind := tokread    
                   else if (token = 'data')    or (token = 'DATA')    then t^.kind := tokdata    
                   else if (token = 'restore') or (token = 'RESTORE') then t^.kind := tokrestore 
                   else if (token = 'gotoxy')  or (token = 'GOTOXY')  then t^.kind := tokgotoxy  
                   else if (token = 'on')      or (token = 'ON')      then t^.kind := tokon      
                   else if (token = 'dim')     or (token = 'DIM')     then t^.kind := tokdim     
                   else if (token = 'poke')    or (token = 'POKE')    then t^.kind := tokpoke    
                   else if (token = 'list')    or (token = 'LIST')    then t^.kind := toklist    
                   else if (token = 'run')     or (token = 'RUN')     then t^.kind := tokrun     
                   else if (token = 'new')     or (token = 'NEW')     then t^.kind := toknew     
                   else if (token = 'load')    or (token = 'LOAD')    then t^.kind := tokload    
                   else if (token = 'merge')   or (token = 'MERGE')   then t^.kind := tokmerge   
                   else if (token = 'save')    or (token = 'SAVE')    then t^.kind := toksave    
                   else if (token = 'bye')     or (token = 'BYE')     then t^.kind := tokbye     
                   else if (token = 'quit')    or (token = 'QUIT')    then t^.kind := tokbye     
                   else if (token = 'del')     or (token = 'DEL')     then t^.kind := tokdel     
                   else if (token = 'renum')   or (token = 'RENUM')   then t^.kind := tokrenum   
                   else if (token = 'then')    or (token = 'THEN')    then t^.kind := tokthen    
                   else if (token = 'else')    or (token = 'ELSE')    then t^.kind := tokelse    
                   else if (token = 'to')      or (token = 'TO')      then t^.kind := tokto      
                   else if (token = 'step')    or (token = 'STEP')    then t^.kind := tokstep    
                   else if (token = 'rem')     or (token = 'REM')     then
                           begin
                              t^.kind := tokrem;
                              new(t^.sp);
                              t^.sp^ := str(inbuf^, i, strlen(inbuf^)-i+1);
                              i := strlen(inbuf^)+1;
                           end
                        else
                           begin
                              t^.kind := tokvar;
                              v := varbase;
                              while (v <> nil) and (v^.name <> token) do
                                 v := v^.next;
                              if v = nil then
                                 begin
                                    new(v);
                                    v^.next := varbase;
                                    varbase := v;
                                    v^.name := token;
                                    v^.numdims := 0;
                                    if token[strlen(token)] = '$' then
                                       begin
                                          v^.stringvar := true;
                                          v^.sv := nil;
                                          v^.sval := addr(v^.sv);
                                       end
                                    else
                                       begin
                                          v^.stringvar := false;
                                          v^.rv := 0;
                                          v^.val := addr(v^.rv);
                                       end;
                                 end;
                              t^.vp := v;
                           end;
                     end;
                  '"', '''' :
                     begin
                        t^.kind := tokstr;
                        new(t^.sp);
                        setstrlen(t^.sp^, 255);
                        j := 0;
                        while (i <= strlen(inbuf^)) and (inbuf^[i] <> ch) do
                           begin
                              j := j + 1;
                              t^.sp^[j] := inbuf^[i];
                              i := i + 1;
                           end;
                        setstrlen(t^.sp^, j);
                        i := i + 1;
                     end;
                  '0'..'9', '.' :
                     begin
                        t^.kind := toknum;
                        n := 0;
                        d := 1;
                        d1 := 1;
                        i := i - 1;
                        while (i <= strlen(inbuf^)) and ((inbuf^[i] in ['0'..'9'])
                                    or ((inbuf^[i] = '.') and (d1 = 1))) do
                           begin
                              if inbuf^[i] = '.' then
                                 d1 := 10
                              else
                                 begin
                                    n := n * 10 + ord(inbuf^[i]) - 48;
                                    d := d * d1;
                                 end;
                              i := i + 1;
                           end;
                        n := n / d;
                        if (i <= strlen(inbuf^)) and (inbuf^[i] in ['e','E']) then
                           begin
                              i := i + 1;
                              d1 := 10;
                              if (i <= strlen(inbuf^)) and (inbuf^[i] in ['+','-']) then
                                 begin
                                    if inbuf^[i] = '-' then
                                       d1 := 0.1;
                                    i := i + 1;
                                 end;
                              j := 0;
                              while (i <= strlen(inbuf^)) and (inbuf^[i] in ['0'..'9']) do
                                 begin
                                    j := j * 10 + ord(inbuf^[i]) - 48;
                                    i := i + 1;
                                 end;
                              for k := 1 to j do
                                 n := n * d1;
                           end;
                        t^.num := n;
                     end;
                  '+' : t^.kind := tokplus;
                  '-' : t^.kind := tokminus;
                  '*' : t^.kind := toktimes;
                  '/' : t^.kind := tokdiv;
                  '^' : t^.kind := tokup;
                  '(', '[' : t^.kind := toklp;
                  ')', ']' : t^.kind := tokrp;
                  ',' : t^.kind := tokcomma;
                  ';' : t^.kind := toksemi;
                  ':' : t^.kind := tokcolon;
                  '?' : t^.kind := tokprint;
                  '=' : t^.kind := tokeq;
                  '<' : 
                     begin
                        if (i <= strlen(inbuf^)) and (inbuf^[i] = '=') then
                           begin
                              t^.kind := tokle;
                              i := i + 1;
                           end
                        else if (i <= strlen(inbuf^)) and (inbuf^[i] = '>') then
                           begin
                              t^.kind := tokne;
                              i := i + 1;
                           end
                        else
                           t^.kind := toklt;
                     end;
                  '>' :
                     begin
                        if (i <= strlen(inbuf^)) and (inbuf^[i] = '=') then
                           begin
                              t^.kind := tokge;
                              i := i + 1;
                           end
                        else
                           t^.kind := tokgt;
                     end;
                  otherwise
                     begin
                        t^.kind := toksnerr;
                        t^.snch := ch;
                     end;
               end;
            end;
      until i > strlen(inbuf^);
   end;



procedure listtokens(var f : text; buf : tokenptr);
   var
      ltr, ltr0 : boolean;
   begin
      ltr := false;
      while buf <> nil do
         begin
            if buf^.kind in [tokvar, toknum, toknot..tokrenum] then
               begin
                  if ltr then write(f, ' ');
                  ltr := (buf^.kind <> toknot);
               end
            else
               ltr := false;
            case buf^.kind of
               tokvar     : write(f, buf^.vp^.name);
               toknum     : write(f, numtostr(buf^.num));
               tokstr     : write(f, '"', buf^.sp^, '"');
               toksnerr   : write(f, '{', buf^.snch, '}');
               tokplus    : write(f, '+');
               tokminus   : write(f, '-');
               toktimes   : write(f, '*');
               tokdiv     : write(f, '/');
               tokup      : write(f, '^');
               toklp      : write(f, '(');
               tokrp      : write(f, ')');
               tokcomma   : write(f, ',');
               toksemi    : write(f, ';');
               tokcolon   : write(f, ' : ');
               tokeq      : write(f, ' = ');
               toklt      : write(f, ' < ');
               tokgt      : write(f, ' > ');
               tokle      : write(f, ' <= ');
               tokge      : write(f, ' >= ');
               tokne      : write(f, ' <> ');
               tokand     : write(f, ' AND ');
               tokor      : write(f, ' OR ');
               tokxor     : write(f, ' XOR ');
               tokmod     : write(f, ' MOD ');
               toknot     : write(f, 'NOT ');
               toksqr     : write(f, 'SQR');
               toksqrt    : write(f, 'SQRT');
               toksin     : write(f, 'SIN');
               tokcos     : write(f, 'COS');
               toktan     : write(f, 'TAN');
               tokarctan  : write(f, 'ARCTAN');
               toklog     : write(f, 'LOG');
               tokexp     : write(f, 'EXP');
               tokabs     : write(f, 'ABS');
               toksgn     : write(f, 'SGN');
               tokstr_    : write(f, 'STR$');
               tokval     : write(f, 'VAL');
               tokchr_    : write(f, 'CHR$');
               tokasc     : write(f, 'ASC');
               toklen     : write(f, 'LEN');
               tokmid_    : write(f, 'MID$');
               tokpeek    : write(f, 'PEEK');
               toklet     : write(f, 'LET');
               tokprint   : write(f, 'PRINT');
               tokinput   : write(f, 'INPUT');
               tokgoto    : write(f, 'GOTO');
               tokif      : write(f, 'IF');
               tokend     : write(f, 'END');
               tokstop    : write(f, 'STOP');
               tokfor     : write(f, 'FOR');
               toknext    : write(f, 'NEXT');
               tokwhile   : write(f, 'WHILE');
               tokwend    : write(f, 'WEND');
               tokgosub   : write(f, 'GOSUB');
               tokreturn  : write(f, 'RETURN');
               tokread    : write(f, 'READ');
               tokdata    : write(f, 'DATA');
               tokrestore : write(f, 'RESTORE');
               tokgotoxy  : write(f, 'GOTOXY');
               tokon      : write(f, 'ON');
               tokdim     : write(f, 'DIM');
               tokpoke    : write(f, 'POKE');
               toklist    : write(f, 'LIST');
               tokrun     : write(f, 'RUN');
               toknew     : write(f, 'NEW');
               tokload    : write(f, 'LOAD');
               tokmerge   : write(f, 'MERGE');
               toksave    : write(f, 'SAVE');
               tokdel     : write(f, 'DEL');
               tokbye     : write(f, 'BYE');
               tokrenum   : write(f, 'RENUM');
               tokthen    : write(f, ' THEN ');
               tokelse    : write(f, ' ELSE ');
               tokto      : write(f, ' TO ');
               tokstep    : write(f, ' STEP ');
               tokrem     : write(f, 'REM', buf^.sp^);
            end;
            buf := buf^.next;
         end;
   end;



procedure disposetokens(var tok : tokenptr);
   var
      tok1 : tokenptr;
   begin
      while tok <> nil do
         begin
            tok1 := tok^.next;
            if tok^.kind in [tokstr, tokrem] then
               dispose(tok^.sp);
            dispose(tok);
            tok := tok1;
         end;
   end;



procedure parseinput(var buf : tokenptr);
   var
      l, l0, l1 : lineptr;
   begin
      inbuf^ := strltrim(inbuf^);
      curline := 0;
      while (strlen(inbuf^) <> 0) and (inbuf^[1] in ['0'..'9']) do
         begin
            curline := curline * 10 + ord(inbuf^[1]) - 48;
            strdelete(inbuf^, 1, 1);
         end;
      parse(inbuf, buf);
      if curline <> 0 then
         begin
            l := linebase;
            l0 := nil;
            while (l <> nil) and (l^.num < curline) do
               begin
                  l0 := l;
                  l := l^.next;
               end;
            if (l <> nil) and (l^.num = curline) then
               begin
                  l1 := l;
                  l := l^.next;
                  if l0 = nil then
                     linebase := l
                  else
                     l0^.next := l;
                  disposetokens(l1^.txt);
                  dispose(l1);
               end;
            if buf <> nil then
               begin
                  new(l1);
                  l1^.next := l;
                  if l0 = nil then
                     linebase := l1
                  else
                     l0^.next := l1;
                  l1^.num := curline;
                  l1^.txt := buf;
               end;
            clearloops;
            restoredata;
         end;
   end;





procedure errormsg(s : string255);
   begin
      write(#7, s);
      escape(42);
   end;


procedure snerr;
   begin
      errormsg('Syntax error');
   end;

procedure tmerr;
   begin
      errormsg('Type mismatch error');
   end;

procedure badsubscr;
   begin
      errormsg('Bad subscript');
   end;






procedure exec;

   var
      gotoflag, elseflag : boolean;
      t : tokenptr;
      ioerrmsg : string255ptr;


   function factor : valrec;
      forward;

   function expr : valrec;
      forward;

   function realfactor : real;
      var
         n : valrec;
      begin
         n := factor;
         if n.stringval then tmerr;
         realfactor := n.val;
      end;

   function strfactor : basicstring;
      var
         n : valrec;
      begin
         n := factor;
         if not n.stringval then tmerr;
         strfactor := n.sval;
      end;

   function stringfactor : string255;
      var
         n : valrec;
      begin
         n := factor;
         if not n.stringval then tmerr;
         stringfactor := n.sval^;
         dispose(n.sval);
      end;

   function intfactor : integer;
      begin
         intfactor := round(realfactor);
      end;

   function realexpr : real;
      var
         n : valrec;
      begin
         n := expr;
         if n.stringval then tmerr;
         realexpr := n.val;
      end;

   function strexpr : basicstring;
      var
         n : valrec;
      begin
         n := expr;
         if not n.stringval then tmerr;
         strexpr := n.sval;
      end;

   function stringexpr : string255;
      var
         n : valrec;
      begin
         n := expr;
         if not n.stringval then tmerr;
         stringexpr := n.sval^;
         dispose(n.sval);
      end;

   function intexpr : integer;
      begin
         intexpr := round(realexpr);
      end;


   procedure require(k : tokenkinds);
      begin
         if (t = nil) or (t^.kind <> k) then
            snerr;
         t := t^.next;
      end;


   procedure skipparen;
      label 1;
      begin
         repeat
            if t = nil then snerr;
            if (t^.kind = tokrp) or (t^.kind = tokcomma) then
               goto 1;
            if t^.kind = toklp then
               begin
                  t := t^.next;
                  skipparen;
               end;
            t := t^.next;
         until false;
       1 :
      end;


   function findvar : varptr;
      var
         v : varptr;
         i, j, k : integer;
         tok : tokenptr;
      begin
         if (t = nil) or (t^.kind <> tokvar) then snerr;
         v := t^.vp;
         t := t^.next;
         if (t <> nil) and (t^.kind = toklp) then
            with v^ do
               begin
                  if numdims = 0 then
                     begin
                        tok := t;
                        i := 0;
                        j := 1;
                        repeat
                           if i >= maxdims then badsubscr;
                           t := t^.next;
                           skipparen;
                           j := j * 11;
                           i := i + 1;
                           dims[i] := 11;
                        until t^.kind = tokrp;
                        numdims := i;
                        if stringvar then
                           begin
                              hpm_new(sarr, j*4);
                              for k := 0 to j-1 do
                                 sarr^[k] := nil;
                           end
                        else
                           begin
                              hpm_new(arr, j*8);
                              for k := 0 to j-1 do
                                 arr^[k] := 0;
                           end;
                        t := tok;
                     end;
                  k := 0;
                  t := t^.next;
                  for i := 1 to numdims do
                     begin
                        j := intexpr;
                        if (j < 0) or (j >= dims[i]) then
                           badsubscr;
                        k := k * dims[i] + j;
                        if i < numdims then
                           require(tokcomma);
                     end;
                  require(tokrp);
                  if stringvar then
                      sval := addr(sarr^[k])
                  else
                      val := addr(arr^[k]);
               end
         else
            begin
               if v^.numdims <> 0 then
                  badsubscr;
            end;
         findvar := v;
      end;


   function inot(i : integer) : integer;
      begin
         inot := -1 - i;
      end;

   function ixor(a, b : integer) : integer;
      begin
         ixor := asm_ior(asm_iand(a, inot(b)), asm_iand(inot(a), b));
      end;


   function factor : valrec;
      var
         v : varptr;
         facttok : tokenptr;
         n : valrec;
         i, j : integer;
         tok, tok1 : tokenptr;
         s : basicstring;
         trick :
            record
               case boolean of
                  true : (i : integer);
                  false : (c : ^char);
            end;
      begin
         if t = nil then snerr;
         facttok := t;
         t := t^.next;
         n.stringval := false;
         case facttok^.kind of
            toknum :
               n.val := facttok^.num;
            tokstr :
               begin
                  n.stringval := true;
                  new(n.sval);
                  n.sval^ := facttok^.sp^;
               end;
            tokvar :
               begin
                  t := facttok;
                  v := findvar;
                  n.stringval := v^.stringvar;
                  if n.stringval then
                     begin
                        new(n.sval);
                        n.sval^ := v^.sval^^;
                     end
                  else
                     n.val := v^.val^;
               end;
            toklp :
               begin
                  n := expr;
                  require(tokrp);
               end;
            tokminus :
               n.val := - realfactor;
            tokplus :
               n.val := realfactor;
            toknot :
               n.val := inot(intfactor);
            toksqr :
               n.val := sqr(realfactor);
            toksqrt :
               n.val := sqrt(realfactor);
            toksin :
               n.val := sin(realfactor);
            tokcos :
               n.val := cos(realfactor);
            toktan :
               begin
                  n.val := realfactor;
                  n.val := sin(n.val) / cos(n.val);
               end;
            tokarctan :
               n.val := arctan(realfactor);
            toklog:
               n.val := ln(realfactor);
            tokexp :
               n.val := exp(realfactor);
            tokabs :
               n.val := abs(realfactor);
            toksgn :
               begin
                  n.val := realfactor;
                  n.val := ord(n.val > 0) - ord(n.val < 0);
               end;
            tokstr_ :
               begin
                  n.stringval := true;
                  new(n.sval);
                  n.sval^ := numtostr(realfactor);
               end;
            tokval :
               begin
                  s := strfactor;
                  tok1 := t;
                  parse(s, t);
                  tok := t;
                  if tok = nil then
                     n.val := 0
                  else
                     n := expr;
                  disposetokens(tok);
                  t := tok1;
                  dispose(s);
               end;
            tokchr_ :
               begin
                  n.stringval := true;
                  new(n.sval);
                  n.sval^ := ' ';
                  n.sval^[1] := chr(intfactor);
               end;
            tokasc :
               begin
                  s := strfactor;
                  if strlen(s^) = 0 then
                     n.val := 0
                  else
                     n.val := ord(s^[1]);
                  dispose(s);
               end;
            tokmid_ :
               begin
                  n.stringval := true;
                  require(toklp);
                  n.sval := strexpr;
                  require(tokcomma);
                  i := intexpr;
                  if i < 1 then i := 1;
                  j := 255;
                  if (t <> nil) and (t^.kind = tokcomma) then
                     begin
                        t := t^.next;
                        j := intexpr;
                     end;
                  if j > strlen(n.sval^)-i+1 then
                     j := strlen(n.sval^)-i+1;
                  if i > strlen(n.sval^) then
                     n.sval^ := ''
                  else
                     n.sval^ := str(n.sval^, i, j);
                  require(tokrp);
               end;
            toklen :
               begin
                  s := strfactor;
                  n.val := strlen(s^);
                  dispose(s);
               end;
            tokpeek :
               begin
                  $range off$
                  trick.i := intfactor;
                  n.val := ord(trick.c^);
                  $if checking$ $range on$ $end$
               end;
            otherwise
               snerr;
         end;
         factor := n;
      end;

   function upexpr : valrec;
      var
         n, n2 : valrec;
      begin
         n := factor;
         while (t <> nil) and (t^.kind = tokup) do
            begin
               if n.stringval then tmerr;
               t := t^.next;
               n2 := upexpr;
               if n2.stringval then tmerr;
               if n.val < 0 then
                  begin
                     if n2.val <> trunc(n2.val) then n.val := ln(n.val);
                     n.val := exp(n2.val * ln(-n.val));
                     if odd(trunc(n2.val)) then
                        n.val := - n.val;
                  end
               else
                  n.val := exp(n2.val * ln(n.val));
            end;
         upexpr := n;
      end;

   function term : valrec;
      var
         n, n2 : valrec;
         k : tokenkinds;
      begin
         n := upexpr;
         while (t <> nil) and (t^.kind in [toktimes, tokdiv, tokmod]) do
            begin
               k := t^.kind;
               t := t^.next;
               n2 := upexpr;
               if n.stringval or n2.stringval then tmerr;
               if k = tokmod then
                  n.val := round(n.val) mod round(n2.val)
               else if k = toktimes then
                  n.val := n.val * n2.val
               else
                  n.val := n.val / n2.val;
            end;
         term := n;
      end;

   function sexpr : valrec;
      var
         n, n2 : valrec;
         k : tokenkinds;
      begin
         n := term;
         while (t <> nil) and (t^.kind in [tokplus, tokminus]) do
            begin
               k := t^.kind;
               t := t^.next;
               n2 := term;
               if n.stringval <> n2.stringval then tmerr;
               if k = tokplus then
                  if n.stringval then
                     begin
                        n.sval^ := n.sval^ + n2.sval^;
                        dispose(n2.sval);
                     end
                  else
                     n.val := n.val + n2.val
               else
                  if n.stringval then
                     tmerr
                  else
                     n.val := n.val - n2.val;
            end;
         sexpr := n;
      end;

   function relexpr : valrec;
      var
         n, n2 : valrec;
         f : boolean;
         k : tokenkinds;
      begin
         n := sexpr;
         while (t <> nil) and (t^.kind in [tokeq..tokne]) do
            begin
               k := t^.kind;
               t := t^.next;
               n2 := sexpr;
               if n.stringval <> n2.stringval then tmerr;
               if n.stringval then
                  begin
                     f := ((n.sval^ = n2.sval^) and (k in [tokeq, tokge, tokle]) or
                           (n.sval^ < n2.sval^) and (k in [toklt, tokle, tokne]) or
                           (n.sval^ > n2.sval^) and (k in [tokgt, tokge, tokne]));
                     dispose(n.sval);
                     dispose(n2.sval);
                  end
               else
                  f := ((n.val = n2.val) and (k in [tokeq, tokge, tokle]) or
                        (n.val < n2.val) and (k in [toklt, tokle, tokne]) or
                        (n.val > n2.val) and (k in [tokgt, tokge, tokne]));
               n.stringval := false;
               n.val := ord(f);
            end;
         relexpr := n;
      end;

   function andexpr : valrec;
      var
         n, n2 : valrec;
      begin
         n := relexpr;
         while (t <> nil) and (t^.kind = tokand) do
            begin
               t := t^.next;
               n2 := relexpr;
               if n.stringval or n2.stringval then tmerr;
               n.val := asm_iand(trunc(n.val), trunc(n2.val));
            end;
         andexpr := n;
      end;

   function expr : valrec;
      var
         n, n2 : valrec;
         k : tokenkinds;
      begin
         n := andexpr;
         while (t <> nil) and (t^.kind in [tokor, tokxor]) do
            begin
               k := t^.kind;
               t := t^.next;
               n2 := andexpr;
               if n.stringval or n2.stringval then tmerr;
               if k = tokor then
                  n.val := asm_ior(trunc(n.val), trunc(n2.val))
               else
                  n.val := ixor(trunc(n.val), trunc(n2.val));
            end;
         expr := n;
      end;


   procedure checkextra;
      begin
         if t <> nil then
            errormsg('Extra information on line');
      end;


   function iseos : boolean;
      begin
         iseos := (t = nil) or (t^.kind in [tokcolon, tokelse]);
      end;


   procedure skiptoeos;
      begin
         while not iseos do
            t := t^.next;
      end;


   function findline(n : integer) : lineptr;
      var
         l : lineptr;
      begin
         l := linebase;
         while (l <> nil) and (l^.num <> n) do
            l := l^.next;
         findline := l;
      end;


   function mustfindline(n : integer) : lineptr;
      var
         l : lineptr;
      begin
         l := findline(n);
         if l = nil then
            errormsg('Undefined line');
         mustfindline := l;
      end;


   procedure cmdend;
      begin
         stmtline := nil;
         t := nil;
      end;


   procedure cmdnew;
      var
         p : anyptr;
      begin
         cmdend;
         clearloops;
         restoredata;
         while linebase <> nil do
            begin
               p := linebase^.next;
               disposetokens(linebase^.txt);
               dispose(linebase);
               linebase := p;
            end;
         while varbase <> nil do
            begin
               p := varbase^.next;
               if varbase^.stringvar then
                  if varbase^.sval^ <> nil then
                     dispose(varbase^.sval^);
               dispose(varbase);
               varbase := p;
            end;
      end;


   procedure cmdlist;
      var
         l : lineptr;
         n1, n2 : integer;
      begin
         repeat
            n1 := 0;
            n2 := maxint;
            if (t <> nil) and (t^.kind = toknum) then
               begin
                  n1 := trunc(t^.num);
                  t := t^.next;
                  if (t = nil) or (t^.kind <> tokminus) then
                     n2 := n1;
               end;
            if (t <> nil) and (t^.kind = tokminus) then
               begin
                  t := t^.next;
                  if (t <> nil) and (t^.kind = toknum) then
                     begin
                        n2 := trunc(t^.num);
                        t := t^.next;
                     end
                  else
                     n2 := maxint;
               end;
            l := linebase;
            while (l <> nil) and (l^.num <= n2) do
               begin
                  if (l^.num >= n1) then
                     begin
                        write(l^.num:1, ' ');
                        listtokens(output, l^.txt);
                        writeln;
                     end;
                  l := l^.next;
               end;
            if not iseos then
               require(tokcomma);
         until iseos;
      end;


   procedure cmdload(merging : boolean; name : string255);
      var
         f : text;
         buf : tokenptr;
      begin
         if not merging then
            cmdnew;
         reset(f, name + '.TEXT', 'shared');
         while not eof(f) do
            begin
               readln(f, inbuf^);
               parseinput(buf);
               if curline = 0 then
                  begin
                     writeln('Bad line in file');
                     disposetokens(buf);
                  end;
            end;
         close(f);
      end;


   procedure cmdrun;
      var
         l : lineptr;
         i : integer;
         s : string255;
      begin
         l := linebase;
         if not iseos then
            begin
               if t^.kind = toknum then
                  l := mustfindline(intexpr)
               else
                  begin
                     s := stringexpr;
                     i := 0;
                     if not iseos then
                        begin
                           require(tokcomma);
                           i := intexpr;
                        end;
                     checkextra;
                     cmdload(false, s);
                     if i = 0 then
                        l := linebase
                     else
                        l := mustfindline(i)
                  end
            end;
         stmtline := l;
         gotoflag := true;
         clearvars;
         clearloops;
         restoredata;
      end;


   procedure cmdsave;
      var
         f : text;
         l : lineptr;
      begin
         rewrite(f, stringexpr + '.TEXT');
         l := linebase;
         while l <> nil do
            begin
               write(f, l^.num:1, ' ');
               listtokens(f, l^.txt);
               writeln(f);
               l := l^.next;
            end;
         close(f, 'save');
      end;


   procedure cmdbye;
      begin
         exitflag := true;
      end;


   procedure cmddel;
      var
         l, l0, l1 : lineptr;
         n1, n2 : integer;
      begin
         repeat
            if iseos then snerr;
            n1 := 0;
            n2 := maxint;
            if (t <> nil) and (t^.kind = toknum) then
               begin
                  n1 := trunc(t^.num);
                  t := t^.next;
                  if (t = nil) or (t^.kind <> tokminus) then
                     n2 := n1;
               end;
            if (t <> nil) and (t^.kind = tokminus) then
               begin
                  t := t^.next;
                  if (t <> nil) and (t^.kind = toknum) then
                     begin
                        n2 := trunc(t^.num);
                        t := t^.next;
                     end
                  else
                     n2 := maxint;
               end;
            l := linebase;
            l0 := nil;
            while (l <> nil) and (l^.num <= n2) do
               begin
                  l1 := l^.next;
                  if (l^.num >= n1) then
                     begin
                        if l = stmtline then
                           begin
                              cmdend;
                              clearloops;
                              restoredata;
                           end;
                        if l0 = nil then
                           linebase := l^.next
                        else
                           l0^.next := l^.next;
                        disposetokens(l^.txt);
                        dispose(l);
                     end
                  else
                     l0 := l;
                  l := l1;
               end;
            if not iseos then
               require(tokcomma);
         until iseos;
      end;


   procedure cmdrenum;
      var
         l, l1 : lineptr;
         tok : tokenptr;
         lnum, step : integer;
      begin
         lnum := 10;
         step := 10;
         if not iseos then
            begin
               lnum := intexpr;
               if not iseos then
                  begin
                     require(tokcomma);
                     step := intexpr;
                  end;
            end;
         l := linebase;
         if l <> nil then
            begin
               while l <> nil do
                  begin
                     l^.num2 := lnum;
                     lnum := lnum + step;
                     l := l^.next;
                  end;
               l := linebase;
               repeat
                  tok := l^.txt;
                  repeat
                     if tok^.kind in [tokgoto, tokgosub, tokthen, tokelse, 
                                      tokrun, toklist, tokrestore, tokdel] then
                        while (tok^.next <> nil) and (tok^.next^.kind = toknum) do
                           begin
                              tok := tok^.next;
                              lnum := round(tok^.num);
                              l1 := linebase;
                              while (l1 <> nil) and (l1^.num <> lnum) do
                                 l1 := l1^.next;
                              if l1 = nil then
                                 writeln('Undefined line ', lnum:1, ' in line ', l^.num2:1)
                              else
                                 tok^.num := l1^.num2;
                              if (tok^.next <> nil) and (tok^.next^.kind = tokcomma) then
                                 tok := tok^.next;
                           end;
                     tok := tok^.next;
                  until tok = nil;
                  l := l^.next;
               until l = nil;
               l := linebase;
               while l <> nil do
                  begin
                     l^.num := l^.num2;
                     l := l^.next;
                  end;
            end;
      end;


   procedure cmdprint;
      var
         semiflag : boolean;
         n : valrec;
      begin
         semiflag := false;
         while not iseos do
            begin
               semiflag := false;
               if t^.kind in [toksemi, tokcomma] then
                  begin
                     semiflag := true;
                     t := t^.next;
                  end
               else
                  begin
                     n := expr;
                     if n.stringval then
                        begin
                           write(n.sval^);
                           dispose(n.sval);
                        end
                     else
                        write(numtostr(n.val), ' ');
                  end;
            end;
         if not semiflag then 
            writeln;
      end;


   procedure cmdinput;
      var
         v : varptr;
         s : string255;
         tok, tok0, tok1 : tokenptr;
         strflag : boolean;
      begin
         if (t <> nil) and (t^.kind = tokstr) then
            begin
               write(t^.sp^);
               t := t^.next;
               require(toksemi);
            end
         else
            begin
               write('? ');
            end;
         tok := t;
         if (t = nil) or (t^.kind <> tokvar) then snerr;
         strflag := t^.vp^.stringvar;
         repeat
            if (t <> nil) and (t^.kind = tokvar) then
               if t^.vp^.stringvar <> strflag then snerr;
            t := t^.next;
         until iseos;
         t := tok;
         if strflag then
            begin
               repeat
                  readln(s);
                  v := findvar;
                  if v^.sval^ <> nil then
                     dispose(v^.sval^);
                  new(v^.sval^);
                  v^.sval^^ := s;
                  if not iseos then
                     begin
                        require(tokcomma);
                        write('?? ');
                     end;
               until iseos;
            end
         else
            begin
               readln(s);
               parse(addr(s), tok);
               tok0 := tok;
               repeat
                  v := findvar;
                  while tok = nil do
                     begin
                        write('?? ');
                        readln(s);
                        disposetokens(tok0);
                        parse(addr(s), tok);
                        tok0 := tok;
                     end;
                  tok1 := t;
                  t := tok;
                  v^.val^ := realexpr;
                  if t <> nil then
                     if t^.kind = tokcomma then
                        t := t^.next
                     else
                        snerr;
                  tok := t;
                  t := tok1;
                  if not iseos then
                     require(tokcomma);
               until iseos;
               disposetokens(tok0);
            end;
      end;


   procedure cmdlet(implied : boolean);
      var
         v : varptr;
	 old : basicstring;
      begin
         if implied then
            t := stmttok;
         v := findvar;
         require(tokeq);
         if v^.stringvar then
            begin
               old := v^.sval^;
               v^.sval^ := strexpr;
               if old <> nil then
                  dispose(old);
            end
         else
            v^.val^ := realexpr;
      end;


   procedure cmdgoto;
      begin
         stmtline := mustfindline(intexpr);
         t := nil;
         gotoflag := true;
      end;


   procedure cmdif;
      var
         n : real;
         i : integer;
      begin
         n := realexpr;
         require(tokthen);
         if n = 0 then
            begin
               i := 0;
               repeat
                  if t <> nil then
                     begin
                        if t^.kind = tokif then
                           i := i + 1;
                        if t^.kind = tokelse then
                           i := i - 1;
                        t := t^.next;
                     end;
               until (t = nil) or (i < 0);
            end;
         if (t <> nil) and (t^.kind = toknum) then
            cmdgoto
         else
            elseflag := true;
      end;


   procedure cmdelse;
      begin
         t := nil;
      end;


   function skiploop(up, dn : tokenkinds) : boolean;
      label 1;
      var
         i : integer;
         saveline : lineptr;
      begin
         saveline := stmtline;
         i := 0;
         repeat
            while t = nil do
               begin
                  if (stmtline = nil) or (stmtline^.next = nil) then
                     begin
                        skiploop := false;
                        stmtline := saveline;
                        goto 1;
                     end;
                  stmtline := stmtline^.next;
                  t := stmtline^.txt;
               end;
            if t^.kind = up then
               i := i + 1;
            if t^.kind = dn then
               i := i - 1;
            t := t^.next;
         until i < 0;
         skiploop := true;
     1 :
      end;


   procedure cmdfor;
      var
         l : loopptr;
         lr : looprec;
         saveline : lineptr;
         i, j : integer;
      begin
         lr.vp := findvar;
         if lr.vp^.stringvar then snerr;
         require(tokeq);
         lr.vp^.val^ := realexpr;
         require(tokto);
         lr.max := realexpr;
         if (t <> nil) and (t^.kind = tokstep) then
            begin
               t := t^.next;
               lr.step := realexpr;
            end
         else
            lr.step := 1;
         lr.homeline := stmtline;
         lr.hometok := t;
         lr.kind := forloop;
         lr.next := loopbase;
         with lr do
            if ((step >= 0) and (vp^.val^ > max)) or ((step <= 0) and (vp^.val^ < max)) then
               begin
                  saveline := stmtline;
                  i := 0;
                  j := 0;
                  repeat
                     while t = nil do
                        begin
                           if (stmtline = nil) or (stmtline^.next = nil) then
                              begin
                                 stmtline := saveline;
                                 errormsg('FOR without NEXT');
                              end;
                           stmtline := stmtline^.next;
                           t := stmtline^.txt;
                        end;
                     if t^.kind = tokfor then
                        if (t^.next <> nil) and (t^.next^.kind = tokvar) and (t^.next^.vp = vp) then
                           j := j + 1
                        else
                           i := i + 1;
                     if (t^.kind = toknext) then
                        if (t^.next <> nil) and (t^.next^.kind = tokvar) and (t^.next^.vp = vp) then
                           j := j - 1
                        else
                           i := i - 1;
                     t := t^.next;
                  until (i < 0) or (j < 0);
                  skiptoeos;
               end
            else
               begin
                  new(l);
                  l^ := lr;
                  loopbase := l;
               end;
      end;


   procedure cmdnext;
      var
         v : varptr;
         found : boolean;
         l : loopptr;
      begin
         if not iseos then
            v := findvar
         else
            v := nil;
         repeat
            if (loopbase = nil) or (loopbase^.kind = gosubloop) then 
               errormsg('NEXT without FOR');
            found := (loopbase^.kind = forloop) and
                     ((v = nil) or (loopbase^.vp = v));
            if not found then
               begin
                  l := loopbase^.next;
                  dispose(loopbase);
                  loopbase := l;
               end;
         until found;
         with loopbase^ do
            begin
               vp^.val^ := vp^.val^ + step;
               if ((step >= 0) and (vp^.val^ > max)) or ((step <= 0) and (vp^.val^ < max)) then
                  begin
                     l := loopbase^.next;
                     dispose(loopbase);
                     loopbase := l;
                  end
               else
                  begin
                     stmtline := homeline;
                     t := hometok;
                  end;
            end;
      end;


   procedure cmdwhile;
      var
         l : loopptr;
      begin
         new(l);
         l^.next := loopbase;
         loopbase := l;
         l^.kind := whileloop;
         l^.homeline := stmtline;
         l^.hometok := t;
         if not iseos then
            if realexpr = 0 then
               begin
                  if not skiploop(tokwhile, tokwend) then 
                     errormsg('WHILE without WEND');
                  l := loopbase^.next;
                  dispose(loopbase);
                  loopbase := l;
                  skiptoeos;
               end;
      end;


   procedure cmdwend;
      var
         tok : tokenptr;
         tokline : lineptr;
         l : loopptr;
         found : boolean;
      begin
         repeat
            if (loopbase = nil) or (loopbase^.kind = gosubloop) then
               errormsg('WEND without WHILE');
            found := (loopbase^.kind = whileloop);
            if not found then
               begin
                  l := loopbase^.next;
                  dispose(loopbase);
                  loopbase := l;
               end;
         until found;
         if not iseos then
            if realexpr <> 0 then
               found := false;
         tok := t;
         tokline := stmtline;
         if found then
            begin
               stmtline := loopbase^.homeline;
               t := loopbase^.hometok;
               if not iseos then
                  if realexpr = 0 then
                     found := false;
            end;
         if not found then
            begin
               t := tok;
               stmtline := tokline;
               l := loopbase^.next;
               dispose(loopbase);
               loopbase := l;
            end;
      end;


   procedure cmdgosub;
      var
         l : loopptr;
      begin
         new(l);
         l^.next := loopbase;
         loopbase := l;
         l^.kind := gosubloop;
         l^.homeline := stmtline;
         l^.hometok := t;
         cmdgoto;
      end;


   procedure cmdreturn;
      var
         l : loopptr;
         found : boolean;
      begin
         repeat
            if loopbase = nil then
               errormsg('RETURN without GOSUB');
            found := (loopbase^.kind = gosubloop);
            if not found then
               begin
                  l := loopbase^.next;
                  dispose(loopbase);
                  loopbase := l;
               end;
         until found;
         stmtline := loopbase^.homeline;
         t := loopbase^.hometok;
         l := loopbase^.next;
         dispose(loopbase);
         loopbase := l;
         skiptoeos;
      end;


   procedure cmdread;
      var
         v : varptr;
         tok : tokenptr;
         found : boolean;
      begin
         repeat
            v := findvar;
            tok := t;
            t := datatok;
            if dataline = nil then
               begin
                  dataline := linebase;
                  t := dataline^.txt;
               end;
            if (t = nil) or (t^.kind <> tokcomma) then
               repeat
                  while t = nil do
                     begin
                        if (dataline = nil) or (dataline^.next = nil) then
                           errormsg('Out of Data');
                        dataline := dataline^.next;
                        t := dataline^.txt;
                     end;
                  found := (t^.kind = tokdata);
                  t := t^.next;
               until found and not iseos
            else
               t := t^.next;
            if v^.stringvar then
               begin
                  if v^.sval^ <> nil then
                     dispose(v^.sval^);
                  v^.sval^ := strexpr;
               end
            else
               v^.val^ := realexpr;
            datatok := t;
            t := tok;
            if not iseos then
               require(tokcomma);
         until iseos;
      end;


   procedure cmddata;
      begin
         skiptoeos;
      end;


   procedure cmdrestore;
      begin
         if iseos then
            restoredata
         else
            begin
               dataline := mustfindline(intexpr);
               datatok := dataline^.txt;
            end;
      end;


   procedure cmdgotoxy;
      var
         i : integer;
      begin
         i := intexpr;
         require(tokcomma);
         gotoxy(i, intexpr);
      end;


   procedure cmdon;
      var
         i : integer;
         l : loopptr;
      begin
         i := intexpr;
         if (t <> nil) and (t^.kind = tokgosub) then
            begin
               new(l);
               l^.next := loopbase;
               loopbase := l;
               l^.kind := gosubloop;
               l^.homeline := stmtline;
               l^.hometok := t;
               t := t^.next;
            end
         else
            require(tokgoto);
         if i < 1 then
            skiptoeos
         else
            begin
               while (i > 1) and not iseos do
                  begin
                     require(toknum);
                     if not iseos then
                        require(tokcomma);
                     i := i - 1;
                  end;
               if not iseos then
                  cmdgoto;
            end;
      end;


   procedure cmddim;
      var
         i, j, k : integer;
         v : varptr;
         done : boolean;
      begin
         repeat
            if (t = nil) or (t^.kind <> tokvar) then snerr;
            v := t^.vp;
            t := t^.next;
            with v^ do
               begin
                  if numdims <> 0 then
                     errormsg('Array already dimensioned');
                  j := 1;
                  i := 0;
                  require(toklp);
                  repeat
                     k := intexpr + 1;
                     if k < 1 then badsubscr;
                     if i >= maxdims then badsubscr;
                     i := i + 1;
                     dims[i] := k;
                     j := j * k;
                     done := (t <> nil) and (t^.kind = tokrp);
                     if not done then
                        require(tokcomma);
                  until done;
                  t := t^.next;
                  numdims := i;
                  if stringvar then
                     begin
                        hpm_new(sarr, j*4);
                        for i := 0 to j-1 do
                           sarr^[i] := nil;
                     end
                  else
                     begin
                        hpm_new(arr, j*8);
                        for i := 0 to j-1 do
                           arr^[i] := 0;
                     end;
               end;
            if not iseos then
               require(tokcomma);
         until iseos;
      end;


   procedure cmdpoke;
      var
         trick :
            record
               case boolean of
                  true : (i : integer);
                  false : (c : ^char);
            end;
      begin
         $range off$
         trick.i := intexpr;
         require(tokcomma);
         trick.c^ := chr(intexpr);
         $if checking$ $range on$ $end$
      end;


   begin {exec}
      try
         repeat
            repeat
               gotoflag := false;
               elseflag := false;
               while (stmttok <> nil) and (stmttok^.kind = tokcolon) do
                  stmttok := stmttok^.next;
               t := stmttok;
               if t <> nil then
                  begin
                     t := t^.next;
                     case stmttok^.kind of
                        tokrem     : ;
                        toklist    : cmdlist;
                        tokrun     : cmdrun;
                        toknew     : cmdnew;
                        tokload    : cmdload(false, stringexpr);
                        tokmerge   : cmdload(true, stringexpr);
                        toksave    : cmdsave;
                        tokbye     : cmdbye;
                        tokdel     : cmddel;
                        tokrenum   : cmdrenum;
                        toklet     : cmdlet(false);
                        tokvar     : cmdlet(true);
                        tokprint   : cmdprint;
                        tokinput   : cmdinput;
                        tokgoto    : cmdgoto;
                        tokif      : cmdif;
                        tokelse    : cmdelse;
                        tokend     : cmdend;
                        tokstop    : escape(-20);
                        tokfor     : cmdfor;
                        toknext    : cmdnext;
                        tokwhile   : cmdwhile;
                        tokwend    : cmdwend;
                        tokgosub   : cmdgosub;
                        tokreturn  : cmdreturn;
                        tokread    : cmdread;
                        tokdata    : cmddata;
                        tokrestore : cmdrestore;
                        tokgotoxy  : cmdgotoxy;
                        tokon      : cmdon;
                        tokdim     : cmddim;
                        tokpoke    : cmdpoke;
                     otherwise
                        errormsg('Illegal command');
                     end;
                  end;
               if not elseflag and not iseos then
                  checkextra;
               stmttok := t;
            until t = nil;
            if stmtline <> nil then
               begin
                  if not gotoflag then
                     stmtline := stmtline^.next;
                  if stmtline <> nil then
                     stmttok := stmtline^.txt;
               end;
         until stmtline = nil;
      recover
         begin
            if escapecode = -20 then
               begin
                  write('Break');
               end
            else if escapecode = 42 then
               begin end
            else
               case escapecode of
                  -4 : write(#7'Integer overflow');
                  -5 : write(#7'Divide by zero');
                  -6 : write(#7'Real math overflow');
                  -7 : write(#7'Real math underflow');
                  -8, -19..-15 : write(#7'Value range error');
                  -10 :
                     begin
                        new(ioerrmsg);
                        misc_getioerrmsg(ioerrmsg^, ioresult);
                        write(#7, ioerrmsg^);
                        dispose(ioerrmsg);
                     end;
                  otherwise
                     begin
                        if excp_line <> -1 then
                           writeln(excp_line);
                        escape(escapecode);
                     end;
               end;
            if stmtline <> nil then
               write(' in ', stmtline^.num:1);
            writeln;
         end;
   end; {exec}





begin {main}
   new(inbuf);
   linebase := nil;
   varbase := nil;
   loopbase := nil;
   writeln('Chipmunk BASIC 1.0');
   writeln;
   exitflag := false;
   repeat
      try
         repeat
            write('>');
            readln(inbuf^);
            parseinput(buf);
            if curline = 0 then
               begin
                  stmtline := nil;
                  stmttok := buf;
                  if stmttok <> nil then
                     exec;
                  disposetokens(buf);
               end;
         until exitflag or eof(input);
      recover
         if escapecode <> -20 then
            misc_printerror(escapecode, ioresult)
         else
            writeln;
   until exitflag or eof(input);
end.




