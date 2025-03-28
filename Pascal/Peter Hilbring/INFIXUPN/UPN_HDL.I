{***********************************}
{   INFIX ---> UPN-Notation V 1.0   }
{                                   }
{   Peter Hilbring                  }
{   Dietrich-Ottmarstra·e 16        }
{   W-4782 Erwitte                  }
{                                   }
{ Programmiert in MAXON-PASCAL V1.5 }
{ (c) 1992 MAXON-Computer           }
{***********************************}
{                                   }
{ Listing #3 : UPN_HDL.I            }
{                                   }
{ Konvertierung von Infix nach UPN  }
{                                   }
{***********************************}

function upper(s : string) : string;
var
    p : shortint;
    o : string[85];
begin
    for p:=1 to length(s) do
        o[p]:=upcase(s[p]);
    o[0]:=s[0];
    upper:=o
end;

function is_operator(c : string) : boolean;
var
    flag : boolean;
    p    : shortint;
begin
    flag:=false;
    p:=0;
    repeat
        if (upper(c)=operator[p]) then
            flag:=true;
        inc(p);
    until (flag=true) or (operator[p-1]='###');
    is_operator:=flag
end;

function get_sep(s : char) : shortint;
begin
    case s of
        '0'..'9',
        '.'      : get_sep:=1;
        '_',
        'A'..'Z',
        'a'..'z' : get_sep:=2;
        '+', '-',
        '*', '/',
        '^'      : get_sep:=3;
        ')'      : get_sep:=4;
        '('      : get_sep:=5
    else
        get_sep:=0
    end;
end;

function check_bracket : boolean;
var
    count : shortint;
    p     : shortint;
begin
    count:=0;
    p:=1;
    repeat
        if (eingabe[p]='(') then
            inc(count);
        if (eingabe[p]=')') then
            dec(count);
        inc(p);
    until (count<0) or (p>=length(eingabe));
    if (count=0) then
        check_bracket:=true
    else
    begin
        syntax.p:=p-1;
        syntax.art:=count;
        check_bracket:=false
    end
end;

procedure check_syntax(p, new_sep : shortint);
begin
    case old_sep of
       -1 : old_sep:=new_sep;
        1 : begin               { Zahlen }
                if (new_sep<>0) then
                begin
                    old_sep:=new_sep;
                    if ((new_sep<>3) and 
                        (new_sep<>4)) then
                        syntax.flag:=false
                end
            end;
        2 : begin               { Variablen }
                if (new_sep<>0) then
                begin
                    old_sep:=new_sep;
                    if ((new_sep<>3) and 
                        (new_sep<>4)) then
                        syntax.flag:=false
                end
            end;
        3 : begin               { + - * / ^ }
                if (new_sep<>0) then
                begin
                    old_sep:=new_sep;
                    if ((new_sep<>1) and 
                        (new_sep<>2) and 
                        (new_sep<>5) and 
                        (new_sep<>6)) then
                        syntax.flag:=false
                end
            end;
        4 : begin               { Klammer zu }
                if (new_sep<>0) then
                begin
                    old_sep:=new_sep;
                    if ((new_sep<>3) and 
                        (new_sep<>4)) then
                        syntax.flag:=false
                end
            end;
        5 : begin               { Klammer auf }
                if (new_sep<>0) then
                    old_sep:=new_sep
            end;
        6 : begin               { Funktionen }
                if (new_sep<>0) then
                begin
                    old_sep:=new_sep;
                    if (new_sep<>5) then 
                        syntax.flag:=false
                end
            end
    end;
    if ((syntax.flag=false) and (syntax.p=
        length(eingabe)-1)) then
    begin
        syntax.p:=p;
        syntax.art:=0
    end;
end;

procedure clear_upn;
var
    p : integer;
begin
    if (stack>0) then
    begin
        for p:=stack downto 1 do
        begin
            if (upn_stack.cmd[p]<>'###') then
                upn:=upn+upn_stack.cmd[p]+' '
        end
    end;
    upn:=upn+upn_stack.cmd[0];
    for p:=0 to 160 do
    begin
        upn_stack.cmd[p]:='';
        upn_stack.val[p]:=0
    end
end;

procedure fill_upn(sep, von, bis : shortint);
var
    c   : string[85];
    cmd : string[85];
    wert: shortint;
begin
    cmd:=copy(eingabe, von, bis-von+1);
    if (sep=2) and (is_operator(cmd)) then
        sep:=6;
    check_syntax(von, sep);
    case sep of
        1 : upn:=upn+cmd+' ';   { Zahlen     }
        2 : upn:=upn+cmd+' ';   { Variablen  }
        3,                      { + - * / ^  }
        6 : begin               { Funktionen }
                case cmd[1] of
                    '+' : wert:=3;
                    '-' : wert:=3;
                    '*' : wert:=2;
                    '/' : wert:=2;
                    '^' : wert:=2
                else
                    wert:=0
                end;
                if (stack=0) then
                begin
                    upn_stack.cmd[stack]:=cmd;
                    upn_stack.val[stack]:=wert;
                    inc(stack)
                end
                else
                    if (wert>=upn_stack.
                        val[stack-1]) then
                    begin
                        upn:=upn+upn_stack.
                             cmd[stack-1]+' ';
                        upn_stack.cmd[stack-1]
                                  :=cmd;
                        upn_stack.val[stack-1]
                                  :=wert
                    end
                    else
                    begin
                        upn_stack.cmd[stack]
                                  :=cmd;
                        upn_stack.val[stack]
                                  :=wert;
                        inc(stack)
                    end
            end;
        4 : repeat              { Klammer zu }
                dec(stack);
                c:=upn_stack.cmd[stack];
                if (c<>'###') then
                    upn:=upn+c+' ';
            until (c='###');
        5 : begin               { Klammer auf }
                upn_stack.cmd[stack]:='###';
                upn_stack.val[stack]:=5;
                inc(stack)
            end
    end
end;

procedure make_upn;
var
    c : char;
    p, old_sep, new_sep : shortint;
begin
    if length(eingabe)>1 then
    begin
        for p:=1 to length(eingabe)-1 do
        begin
            c:=eingabe[p];
            old_sep:=get_sep(c);
            c:=eingabe[p+1];
            new_sep:=get_sep(c);
            if(((old_sep=4) and (new_sep=4)) or
               ((old_sep=5) and (new_sep=5)) or
               ((old_sep=3) and (new_sep=3)) or
                (old_sep<>new_sep)) then
            begin
                fill_upn(old_sep,start_pos,p);
                start_pos:=p+1
            end
        end
    end
    else
    begin
        p:=1;
        c:=eingabe[p];
        new_sep:=get_sep(c)
    end;
    fill_upn(new_sep,start_pos,p);
    clear_upn
end;

procedure tos_eingabe;
var
    p   : integer;
    ask : char;
begin
    graf_mouse(M_OFF, NIL);
    repeat
        write(chr(27),'E Infix nach UPN ');
        writeln('Konverter');
        writeln('==========================');
        writeln('(p) 1992 von Peter Hilbring');
        write('             Dietrich-Ottmar ');
        writeln('Stra·e 16');
        writeln('             4782 Erwitte');
        write(' Geschrieben in MAXON-PASCAL ');
        writeln('V 1.5');
        writeln(' fÅr ST-COMPUTER-ESCHBORN');
        writeln;
        write('Infix: ');
        read(eingabe);
        eingabe:=eingabe+#0;
        writeln;
        if check_bracket then
        begin
            upn:='';
            start_pos:=1;
            stack:=0;
            old_sep:=-1;
            syntax.flag:=true;
            syntax.p:=length(eingabe)-1;
            make_upn;
            if((syntax.flag)and(old_sep<>3)and
               (old_sep<>6)) then
            begin
                writeln('  UPN: ');
                p:=0;         
                for p:=1 to length(upn) div 40
                do
                    writeln('       ',copy(upn,
                            p*40-39, 40));
                writeln('       ',copy(upn,
                  p*40+1, length(upn) mod 40))
            end
            else
                writeln('syntax_error')
        end
        else
            writeln('syntax_error');
        writeln;
        write('Noch einmal (J/N) ? ');
        ask:=readkey;
    until ((ask='n') or (ask='N'));
    graf_mouse(M_ON, NIL)
end;
