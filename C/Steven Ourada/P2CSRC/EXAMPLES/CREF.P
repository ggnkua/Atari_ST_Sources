
$debug$
$ sysprog, partial_eval $

program crefprog(input, output);


const
 {  linesperpage = 139;  }
   maxnamelen = 30;


type
   str255 = string[255];

   occurptr = ^occur;
   occur =
      record
         next : occurptr;
         lnum : integer;
         fnum : integer;
         defn : boolean;
      end;

   kinds = (k_normal, k_proc, k_var, k_const, k_type, k_strlit, k_extproc,
            k_kw, k_prockw, k_varkw, k_constkw, k_typekw, k_beginkw);

   nodeptr = ^node;
   node =
      record
         left, right : nodeptr;
         name : string[maxnamelen];
         first : occurptr;
         kind : kinds;
      end;


var
   f : text;
   fn : string[120];
   fnum : integer;
   buf, name : str255;
   good : boolean;
   i, j : integer;
   lnum : integer;
   np, base : nodeptr;
   op : occurptr;
   curkind, section : kinds;
   paren : integer;
   brace : integer;



procedure lookup(var name : str255; var np : nodeptr);
   var
      npp : ^nodeptr;
   begin
      if strlen(name) > maxnamelen then
         setstrlen(name, maxnamelen);
      npp := addr(base);
      while (npp^ <> nil) and (npp^^.name <> name) do
         begin
            if name < npp^^.name then
               npp := addr(npp^^.left)
            else
               npp := addr(npp^^.right);
         end;
      if (npp^ = nil) then
         begin
            new(np);
            npp^ := np;
            np^.name := name;
            np^.first := nil;
            np^.left := nil;
            np^.right := nil;
            np^.kind := k_normal;
         end
      else
         np := npp^;
   end;


procedure kw(name : str255; kind : kinds);
   var
      np : nodeptr;
   begin
      lookup(name, np);
      np^.kind := kind;
   end;


procedure cref(np : nodeptr; kind : kinds);
   var
      op : occurptr;
   begin
      new(op);
      op^.next := np^.first;
      np^.first := op;
      op^.lnum := lnum;
      op^.fnum := fnum;
      op^.defn := (kind in [k_var, k_type, k_const, k_proc]);
      if op^.defn or (kind = k_strlit) or
         ((kind = k_extproc) and (np^.kind = k_normal)) then
         np^.kind := kind;
   end;



procedure traverse(np : nodeptr);
   var
      op : occurptr;
      i : integer;
   begin
      if (np <> nil) then
         begin
            traverse(np^.left);
            if np^.kind < k_kw then
               begin
                  case np^.kind of
                     k_var:
                        write(f, 'V:');
                     k_type:
                        write(f, 'T:');
                     k_const:
                        write(f, 'C:');
                     k_proc:
                        write(f, 'P:');
                     k_strlit:
                        write(f, 'S:');
                     k_extproc:
                        write(f, 'E:');
                     k_normal:
                        write(f, 'X:');
                  end;
                  write(f, np^.name);
                  i := 0;
                  op := np^.first;
                  while op <> nil do
                     begin
                        if i = 0 then
                           begin
                              writeln(f);
                              write(f, '   ');
                              i := 5;
                           end;
                        write(f, ' ', op^.lnum:1, '/', op^.fnum:1);
                        if op^.defn then
                           write(f, '*');
                        i := i - 1;
                        op := op^.next;
                     end;
                  writeln(f);
               end;
            traverse(np^.right);
         end;
   end;



begin
   base := nil;
   fnum := 0;
   kw('procedure', k_prockw);
   kw('function', k_prockw);
   kw('var', k_varkw);
   kw('record', k_varkw);
   kw('type', k_typekw);
   kw('const', k_constkw);
   kw('begin', k_beginkw);
   kw('end', k_kw);
   kw('do', k_kw);
   kw('for', k_kw);
   kw('to', k_kw);
   kw('while', k_kw);
   kw('repeat', k_kw);
   kw('until', k_kw);
   kw('if', k_kw);
   kw('then', k_kw);
   kw('else', k_kw);
   kw('case', k_kw);
   kw('of', k_kw);
   kw('div', k_kw);
   kw('mod', k_kw);
   kw('nil', k_kw);
   kw('not', k_kw);
   kw('and', k_kw);
   kw('or', k_kw);
   kw('with', k_kw);
   kw('array', k_kw);
   kw('integer', k_kw);
   kw('char', k_kw);
   kw('boolean', k_kw);
   kw('true', k_kw);
   kw('false', k_kw);
   writeln;
   writeln('Pascal Cross Reference Utility');
   writeln;
   repeat
      fnum := fnum + 1;
      write('Name of cross-reference file #', fnum:1, '? ');
      readln(fn);
      good := true;
      if (fn <> '') then
         begin
            try
               reset(f, fn);
            recover
               if escapecode <> -10 then
                  escape(escapecode)
               else
                  begin
                     good := false;
                     writeln('Can''t read file!');
                  end;
         end
      else
         good := false;
      if good then
         begin
            lnum := 0;
            section := k_normal;
            curkind := k_normal;
            paren := 0;
            while not eof(f) do
               begin
                  lnum := lnum + 1;
                  readln(f, buf);
                  strappend(buf, #0);
                  i := 1;
                  while (buf[i] = ' ') do
                     i := i + 1;
                  repeat
                     while not (buf[i] in ['a'..'z', 'A'..'Z', '0'..'9', '_', #0]) do
                        begin
                           case buf[i] of
                              ':', '=':
                                 if brace = 0 then
                                    curkind := k_normal;
                              ';':
                                 if brace = 0 then
                                    curkind := section;
                              '''':
                                 if brace = 0 then
                                    begin
                                       i := i + 1;
                                       j := i;
                                       while ((buf[i] <> '''') or (buf[i+1] = '''')) and
                                             (buf[i] <> #0) do
                                          begin
                                             if (buf[i] = '''') then
                                                i := i + 2
                                             else
                                                i := i + 1;
                                          end;
                                       if (buf[i] = #0) then
                                          i := i - 1;
                                       name := '''' + str(buf, j, i-j) + '''';
                                       lookup(name, np);
                                       cref(np, k_strlit);
                                    end;
                              '(':
                                 if brace = 0 then
                                    if (buf[i+1] = '*') then
                                       begin
                                          brace := 1;
                                          i := i + 1;
                                       end
                                    else
                                       begin
                                          paren := paren + 1;
                                          curkind := k_normal;
                                       end;
                              ')':
                                 if brace = 0 then
                                    paren := paren - 1;
                              '*':
                                 if (buf[i+1] = ')') then
                                    begin
                                       brace := 0;
                                       i := i + 1;
                                    end;
                              '{': brace := 1;
                              '}': brace := 0;
                              otherwise ;
                           end;
                           i := i + 1;
                        end;
                     if (buf[i] <> #0) then
                        begin
                           j := i;
                           if (buf[i] in ['0'..'9']) and (i > 1) and (buf[i-1] = '-') then
                              j := j - 1;
                           while (buf[i] in ['a'..'z', 'A'..'Z', '0'..'9', '_']) do
                              i := i + 1;
                           if brace = 0 then
                              begin
                                 name := str(buf, j, i-j);
                                 for j := 1 to strlen(name) do
                                    if (buf[j] in ['A'..'Z']) then
                                       buf[j] := chr(ord(buf[j]) + 32);
                                 while (buf[i] = ' ') do
                                    i := i + 1;
                                 lookup(name, np);
                                 case np^.kind of
                                    k_varkw:
                                       if paren = 0 then
                                          begin
                                             section := k_var;
                                             curkind := section;
                                          end;
                                    k_typekw:
                                       begin
                                          section := k_type;
                                          curkind := section;
                                       end;
                                    k_constkw:
                                       begin
                                          section := k_const;
                                          curkind := section;
                                       end;
                                    k_prockw:
                                       begin
                                          section := k_normal;
                                          curkind := k_proc;
                                       end;
                                    k_beginkw:
                                       begin
                                          section := k_normal;
                                          curkind := k_normal;
                                       end;
                                    k_kw: ;
                                    otherwise
                                       if (curkind = k_normal) and (buf[i] = '(') then
                                          cref(np, k_extproc)
                                       else
                                          cref(np, curkind);
                                 end;
                              end;
                        end;
                  until buf[i] = #0;
               end;
            if paren <> 0 then
               writeln('Warning: ending paren count = ', paren:1);
            close(f);
         end;
   until fn = '';
   writeln;
   repeat
      write('Output file name: ');
      readln(fn);
   until fn <> '';
   rewrite(f, fn);
   traverse(base);
   close(f, 'save');
end.




