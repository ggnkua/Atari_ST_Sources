{KPXSUB.PAS    Routinen zur Auswertung komplexer AusdrÅcke
               (c) Tobias Blickle 1989      }

procedure run_time_error(nummer:integer);
begin
 rte:=true;
 rte_nr:=nummer;
end;

(* ---------------- KOMPLEXE GRUNDFUNKTIONEN ------------------------*)
procedure recht_polar(re,im:real; var r,phi:real);
begin
 r:=sqrt(re*re+im*im);
 if re=0 then if im>0 then phi:=pi/2 else phi:=-pi/2
         else begin
              phi:=ArcTan(im/re);
              if re<0 then if im>=0 then phi:=phi+pi
                                    else phi:=phi-pi;
              end;
end;

procedure polar_recht(r,phi:real;var re,im:real); 
begin
 re:=r*cos(phi);
 im:=r*sin(phi);
end;

procedure k_mul(r1,i1,r2,i2:real;var r_back,i_back:real);
begin
 r_back:=r1*r2-i1*i2;
 i_back:=r1*i2+r2*i1;
end;

procedure k_div(zr,zi,nr,ni:real;var r_back,i_back:real);
var n:real;
begin
 n:=nr*nr+ni*ni;
 if n=0 then run_time_error(1)
  else begin
       r_back:=(zr*nr+zi*ni)/n;
       i_back:=(zi*nr-ni*zr)/n;
       end;
end;

procedure k_exp(re_in,im_in:real;var re,im:real);
begin
 re:=exp(re_in)*cos(im_in);
 im:=exp(re_in)*sin(im_in);
end;
 
procedure k_ln(re_in,im_in:real;var re,im:real);
var r:real;
begin
 recht_polar(re_in,im_in,r,im);
 if r=0 then run_time_error(2)
        else re:=0.5*ln(r*r);
end;

procedure k_sqrt(re_in,im_in:real;var re,im:real);
var r,phi:real;
begin
 recht_polar(re_in,im_in,r,phi);
 polar_recht(sqrt(r),phi/2,re,im);
end;

procedure k_sqr(re_in,im_in:real;var re,im:real);
begin re:=re_in*re_in-im_in*im_in;im:=2*re_in*im_in;end;

procedure k_sin(re_in,im_in:real;var re,im:real);
begin
 re:= 0.5*sin(re_in)*(exp(im_in)+exp(-im_in));
 im:=-0.5*cos(re_in)*(exp(-im_in)-exp(im_in));
end;

procedure k_cos(re_in,im_in:real;var re,im:real);
begin
 re:=0.5*cos(re_in)*(exp(-im_in)+exp(im_in));
 im:=0.5*sin(re_in)*(exp(-im_in)-exp(im_in));
end;

procedure k_asin(re_in,im_in:real;var re,im:real);
var r2,i2:real;
begin
 r2:=1-re_in*re_in+im_in*im_in;i2:=-2*re_in*im_in;
 k_sqrt(r2,i2,r2,i2);
 k_ln(r2-im_in,i2+re_in,r2,i2);
 re:=i2;im:=-r2;
end;

procedure k_acos(re_in,im_in:real;var re,im:real);
var r2,i2:real;
begin
 r2:=re_in*re_in-im_in*im_in-1;i2:=2*re_in*im_in;
 k_sqrt(r2,i2,r2,i2);
 k_ln(r2+re_in,i2+im_in,r2,i2);
 re:=i2;im:=-r2;
end;

procedure k_tan(re_in,im_in:real;var re,im:real);
var r2,i2:real;
begin
 r2:=0.5*sin(re_in)*(exp(im_in)+exp(-im_in));
 i2:=-0.5*cos(re_in)*(exp(-im_in)-exp(im_in));
 re:=0.5*cos(re_in)*(exp(-im_in)+exp(im_in));
 im:=0.5*sin(re_in)*(exp(-im_in)-exp(im_in));
 k_div(r2,i2,re,im,re,im);
end;

procedure k_atan(re_in,im_in:real;var re,im:real);
var r2,i2:real;
begin
 k_div(1-im_in,re_in,1+im_in,-re_in,r2,i2);
 k_ln(r2,i2,r2,i2);
 re:=0.5*i2;im:=-0.5*r2;
end;

procedure k_abs(re_in,im_in:real;var re,im:real);
begin  re:=sqrt(re_in*re_in+im_in*im_in);im:=0;end;


(*------------------- AUFBAU DES SYNTAX-BAUMS ----------------------*)
procedure baum_bau(befehl:string;var start:baumzeiger;var status:boolean);  
    forward;
procedure clr_baum(wo:baumzeiger);forward;

(*------------------- VARIABLEN VERWALTUNG -------------------------*)
(* -> Variablenwert festlegen, falls vorhanden, Wert Åberschreiben  *)
(* Das ganze mit Hilfe einer Hashtabelle, Grîûe in "hashgroesse"    *)
procedure set_variable(was:var_string;re,im:real);
var pos:integer;
   neu,hilf:varzeiger;
begin
 pos:=ord(was[1]) mod hashgroesse;
 hilf:=varis[pos]; 
 if hilf=nil then begin
     new(neu);neu^.name:=was;neu^.next:=nil;varis[pos]:=neu;
     hilf:=neu;end       
  else begin
     while (hilf^.next<>nil) and (hilf^.name<>was) do hilf:=hilf^.next;
     if hilf^.name<>was then begin 
        new(neu);neu^.name:=was;neu^.next:=nil;hilf^.next:=neu;
        hilf:=neu;    
        end;
     end;
hilf^.re:=re;hilf^.im:=im;
end;

(* -> Variableninhalt bestimmen                                  *)
procedure get_variable(was:var_string;var re,im:real;var gefunden:boolean);
var pos:integer;
   hilf:varzeiger;
begin
 gefunden:=true;
 pos:=ord(was[1]) mod hashgroesse;
 hilf:=varis[pos];
 re:=0;im:=0;
 if hilf=nil then gefunden:=false
    else begin
     while (hilf^.next<>nil) and (hilf^.name<>was) do hilf:=hilf^.next;
     if hilf^.name=was then begin re:=hilf^.re;im:=hilf^.im;end
                       else gefunden:=false;
     end;
end;

(* -> Variable lîschen, Aufruf mit Leerstring hat keine Wirkung*)
procedure del_variable(was:var_string);
var pos:integer;
   hilf1,hilf2:varzeiger;
begin
 pos:=ord(was[1]) mod hashgroesse;
 hilf1:=varis[pos];
 if (hilf1<>nil) and (was<>'') then begin
    if hilf1^.name=was then varis[pos]:=hilf1^.next
    else begin
      while (hilf1^.next<>nil) and (hilf1^.name<>was) do begin
        hilf2:=hilf1;hilf1:=hilf1^.next;end;
      if hilf1^.name=was then hilf2^.next:=hilf1^.next;
      end;
    dispose(hilf1);
    end;
end;

(*-------------------- MACRO VERWALTUNG -------------------------*)

procedure get_macro(was:var_string;var zeiger:baumzeiger;
                                   var gefunden:boolean);
var pos:integer;
   hilf:macrozeiger;
begin
 gefunden:=true;
 pos:=ord(was[1]) mod hashgroesse;
 hilf:=macros[pos];
 if hilf=nil then gefunden:=false
    else begin
     while (hilf^.next<>nil) and (hilf^.name<>was) do hilf:=hilf^.next;
     if hilf^.name=was then zeiger:=hilf^.s_baum
                       else gefunden:=false;
     end;
end;

procedure set_macro(was:var_string;inhalt:string);
var pos:integer;
   neu,hilf:macrozeiger;
   syntax_b:baumzeiger;
   ok:boolean;
begin
 pos:=ord(was[1]) mod hashgroesse;
 hilf:=macros[pos]; 
 if hilf=nil then begin
     new(neu);neu^.name:=was;neu^.next:=nil;macros[pos]:=neu;
     hilf:=neu;end
  else begin
     while (hilf^.next<>nil) and (hilf^.name<>was) do hilf:=hilf^.next;
     if hilf^.name<>was then begin 
        new(neu);neu^.name:=was;neu^.next:=nil;hilf^.next:=neu;
        hilf:=neu;    
        end;
     end;
hilf^.inhalt:=inhalt;syntax_b:=nil;
baum_bau(inhalt,syntax_b,ok);
if ok then hilf^.s_baum:=syntax_b 
      else begin hilf^.s_baum:=nil;run_time_error(5);end;
end;


procedure del_macro(was:var_string);
var pos:integer;
   hilf1,hilf2:macrozeiger;
begin
 pos:=ord(was[1]) mod hashgroesse;
 hilf1:=macros[pos];
 if (hilf1<>nil) and (was<>'') then begin
    if hilf1^.name=was then macros[pos]:=hilf1^.next
    else begin
      while (hilf1^.next<>nil) and (hilf1^.name<>was) do begin
        hilf2:=hilf1;hilf1:=hilf1^.next;end;
      if hilf1^.name=was then hilf2^.next:=hilf1^.next;
      end;
    clr_baum(hilf1^.s_baum);
    dispose(hilf1);
    end;
end;

(*------------ SYNTAX-BAUM-AUFBAU MIT öBERPRöFUNG ---------------------*)

procedure baum_bau;  
var sym,zei:char;
    inhalt:var_string;

 procedure mach_terror(nummer:integer);
 begin
 if not fehler then begin
   fehler:=true;
   fehler_nr:=nummer;
   fehlerpos:=pos;
   fehlerursache:=inhalt;
  end;
 end;

 (* Liefert nÑchstes Zeichen aus dem Eingabestring              *)
 function nextzei:char;
  begin
  if pos<=length(befehl) then begin nextzei:=befehl[pos];pos:=pos+1;end
                         else nextzei:=ende; 
 end;

 (* Liefert nÑchstes SchlÅsselwort aus dem Eingabestring       *)
 procedure getsym;
 var  k   :integer;
 begin
  while zei=' ' do zei:=nextzei;
  case zei of

  '+','-','*','/','(',')','^','.': begin sym:=zei;zei:=nextzei;end;

  '0','1','2','3','4','5','6','7','8','9':
     begin 
       k:=0;inhalt:='';               (* Das sind (Integer)Zahlen *)
       repeat
         inhalt:=concat(inhalt,zei);
         k:=k+1;
         zei:=nextzei;
       until not (zei in ['0'..'9']) or (k=varlen);
       if k=varlen then mach_terror(14);
       sym:=zahl;
     end;

  'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R',
  'S','T','U','V','W','X','Y','Z':
     begin
       k:=0;inhalt:='';              (* MACROS oder vordefinierte *)
       repeat                        (* Funktionen                *)
         inhalt:=concat(inhalt,zei);
         k:=k+1;
         zei:=nextzei;
       until not (zei in ['A'..'Z','0'..'9','_']) or (k=varlen);
       if k=varlen then mach_terror(1);
       k:=0;
       repeat                        (* öberprÅfung auf SchlÅssel-*)
          k:=k+1                     (* wîrter (Funktionsnamen)   *)
       until (k=maxkey) or (key[k]=inhalt);
       if inhalt=key[k] then sym:=code[k]  
                        else sym:=macro;
     end;

  'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r',
  's','t','u','v','w','x','y','z':
     begin
       k:=0;inhalt:='';             (* Variablennamen              *)
       repeat
         inhalt:=concat(inhalt,zei);
         k:=k+1;
         zei:=nextzei;
       until not (zei in ['a'..'z','0'..'9','_']) or (k=varlen);
       if k=varlen then mach_terror(2);
       sym:=bez;
     end;
   ende: sym:=ende;
   else: begin mach_terror(3);zei:=nextzei;end;
   end;
 end;

(*-------------- Eingentlicher Baumaufbau ----------------------*)
 procedure T(var wohin:baumzeiger);forward;
 procedure H(var wohin:baumzeiger);forward;
 procedure VZF(var wohin:baumzeiger);forward;
 procedure F(var wohin:baumzeiger);forward; 

 procedure E(var wohin:baumzeiger);
 var neu,hilf,hilf2: baumzeiger;
    gueltig,minus  : boolean;
 begin
  new(neu);wohin:=neu;gueltig:=false;
  neu^.operator:='?';neu^.rechts:=nil;neu^.links:=nil;
  T(neu^.links);
  while (sym='+') or (sym='-') do
   begin
     gueltig:=true;
     new(hilf);neu^.rechts:=hilf;hilf^.operator:=sym;hilf^.rechts:=nil;
     neu^.operator:=sym;neu:=hilf;neu^.links:=nil;
     getsym;T(neu^.links);
   end;
 if not gueltig then begin wohin:=neu^.links;dispose(neu);end;

 end;

 procedure T;
 var neu,hilf: baumzeiger;
    gueltig  : boolean;
 begin
  new(neu);wohin:=neu;gueltig:=false;
  neu^.operator:='?';neu^.rechts:=nil;neu^.links:=nil;
  H(neu^.links);
  while (sym='*') or (sym='/') do
   begin
     gueltig:=true;
     new(hilf);neu^.rechts:=hilf;hilf^.operator:=sym;hilf^.rechts:=nil;
     neu^.operator:=sym;neu:=hilf;neu^.links:=nil;
     getsym;H(neu^.links);
   end;
  if not gueltig then  begin wohin:=neu^.links;dispose(neu);end;
 end;

 procedure H;
 var neu : baumzeiger;
 begin
  new(neu);wohin:=neu;
  neu^.operator:='?';neu^.rechts:=nil;neu^.links:=nil;
  VZF(neu^.links);
  if sym='^' then begin neu^.operator:=sym;getsym;VZF(neu^.rechts);end
             else begin wohin:=neu^.links;dispose(neu);end;
 end;

 procedure VZF;
 var neu : baumzeiger;

 begin
  if sym='-' then begin
      getsym;
      new(neu);wohin:=neu;
      neu^.operator:='_';neu^.next:=nil;
      F(neu^.next);end
    else F(wohin);
 end;
  
 procedure F;
 var neu,hilf: baumzeiger;
     vorkomma,nachkomma,exponent,d1,d2:real;
     vorzeichen:char;
     nr:integer;
     ok:boolean;

 begin
  case sym of
  '(' :begin 
       getsym;E(wohin);
       if sym=')' then getsym else mach_terror(4);
       end;
  bez :begin
       new(neu);wohin:=neu;
       neu^.operator:=bez;
       get_variable(inhalt,d1,d2,ok);
       if not ok then mach_terror(12)
                 else neu^.name:=inhalt;
       getsym;
       end;
  macro:begin
       new(neu);wohin:=neu;
       neu^.operator:=macro;
       get_macro(inhalt,hilf,ok);
       if not ok then mach_terror(13)
                 else neu^.name:=inhalt;
       getsym;
       end; 
  zahl:begin
       new(neu);wohin:=neu;
       neu^.operator:='#';nachkomma:=0;exponent:=0;
       readv(inhalt,vorkomma);       
       getsym;
       if sym='.' then begin
          getsym;
          if sym=zahl then 
               begin
                readv(inhalt,nachkomma);
                nachkomma:=nachkomma/PwrOfTen(length(inhalt));
                getsym;  
               end
             else mach_terror(5);
          end;
       if sym=expo then begin
          getsym;
          if (sym='+') or (sym='-') then 
             begin vorzeichen:=sym;
                   getsym;
                   if sym=zahl then
                      begin 
                       readv(inhalt,exponent);
                       getsym;
                      end
                    else mach_terror(6);
               end
               else mach_terror(7);
           end;
      if vorzeichen='+' then 
             neu^.wert:=(vorkomma+nachkomma)*PwrOfTen(trunc(exponent))  
        else neu^.wert:=(vorkomma+nachkomma)/PwrOfTen(trunc(exponent));  
      end;
  f_sin,f_cos,f_exp,f_abs,f_sqr,f_sqrt,f_ln,f_asin,f_acos,
  f_tan,f_atan,f_re,f_im,f_arg :
      begin
      new(neu);wohin:=neu;
      neu^.operator:=fkt;neu^.typ:=sym;getsym;
      if sym='(' then begin
             getsym;E(neu^.weiter);
             if sym=')' then getsym else mach_terror(10);
             end
         else mach_terror(11);
      end;
  else : mach_terror(8);
  end;
 end;

begin (* Prozedur baum_bau *)
 pos:=1;fehler:=false;zei:=nextzei;getsym;
 E(start);
 if sym<>ende then mach_terror(9);
 status:=not fehler;
end;

(* ---- Berechnung des Wertes durch Abarbeiten des Syntax-Baums ------*)
procedure auswertung(wo:baumzeiger;var re,im:real);
var r1,i1,r2,i2,r,phi:real;
    syntax_b:baumzeiger;
    ok:boolean;
begin
 if wo<>nil then begin
 case wo^.operator of
 '_'    : begin auswertung(wo^.next,re,im);re:=-re;im:=-im;end;
 '#'    : begin re:=wo^.wert;im:=0;end;
 '?'    : begin auswertung(wo^.links,re,im);writeln('Leerobjekt !');end;
 '+','-': begin 
           auswertung(wo^.links,re,im);
           repeat
           if wo^.operator='+' then begin
                  wo:=wo^.rechts;
                  auswertung(wo^.links,r1,i1);
                  re:=re+r1;im:=im+i1; 
                end
               else begin 
                  wo:=wo^.rechts;
                  auswertung(wo^.links,r1,i1);
                  re:=re-r1;im:=im-i1;
                end;
            until wo^.rechts=nil;
            end;
 '*','/': begin 
           auswertung(wo^.links,re,im);
           repeat
           if wo^.operator='*' then begin
                  wo:=wo^.rechts;
                  auswertung(wo^.links,r1,i1);
                  k_mul(re,im,r1,i1,re,im);
                end
               else begin 
                  wo:=wo^.rechts;
                  auswertung(wo^.links,r1,i1);
                  k_div(re,im,r1,i1,re,im);
                end;
            until wo^.rechts=nil;
            end;

 '^'     : begin 
            auswertung(wo^.links,r1,i1);
            auswertung(wo^.rechts,r2,i2);
            if i2=0 then begin 
                      recht_polar(r1,i1,r,phi);
                      r:=exp(r2*ln(r));phi:=phi*r2;
                      while phi>pi do phi:=phi-2*pi;
                      polar_recht(r,phi,re,im);
                      end
                    else begin
                      k_ln(r1,i1,re,im);
                      k_mul(re,im,r2,i2,r2,i2);
                      k_exp(r2,i2,re,im);
                      end;
            end;
       
 bez     : begin
             get_variable(wo^.name,re,im,ok);
             if not ok then run_time_error(3);
           end;
 macro   : begin 
             get_macro(wo^.name,syntax_b,ok);
             if not ok then run_time_error(4)
                       else auswertung(syntax_b,re,im);
           end;
 fkt     : begin
            auswertung(wo^.weiter,r1,i1);
            case wo^.typ of
             f_exp :k_exp(r1,i1,re,im); 
             f_sin :k_sin(r1,i1,re,im);
             f_cos :k_cos(r1,i1,re,im);
             f_abs :k_abs(r1,i1,re,im);
             f_sqr :k_sqr(r1,i1,re,im);
             f_sqrt:k_sqrt(r1,i1,re,im);
             f_ln  :k_ln(r1,i1,re,im);
             f_asin:k_asin(r1,i1,re,im);
             f_acos:k_acos(r1,i1,re,im);
             f_tan :k_tan(r1,i1,re,im);
             f_atan:k_atan(r1,i1,re,im);
             f_re:  begin im:=0;re:=r1;end;
             f_im:  begin im:=0;re:=i1;end;
             f_arg: begin im:=0;recht_polar(r1,i1,r1,re);end;
            end;
           end;
 end;
end;
end;

procedure clr_baum;
begin
 if wo<>nil then
 begin
 case wo^.operator of
  '_':begin clr_baum(wo^.next);dispose(wo);end;  
  '#',bez,macro : dispose(wo);
  fkt:begin clr_baum(wo^.weiter);dispose(wo);end;
 else
   begin
      if wo^.links<>nil  then clr_baum(wo^.links);
      if wo^.rechts<>nil then clr_baum(wo^.rechts);
      dispose(wo);
  end;
 end;
end;
end;  

procedure init_komplex;
var i:integer;
begin
 for i:=0 to hashgroesse do begin varis[i]:=nil;macros[i]:=nil;end;
 set_variable('i',0,1);
 set_variable('pi',pi,0);
 key[1]:='E';    code[1]:=expo;
 key[2]:='SIN';  code[2]:=f_sin;
 key[3]:='EXP';  code[3]:=f_exp;
 key[4]:='COS';  code[4]:=f_cos;
 key[5]:='ABS';  code[5]:=f_abs;
 key[6]:='SQR';  code[6]:=f_sqr;
 key[7]:='SQRT'; code[7]:=f_sqrt;
 key[8]:='LN';   code[8]:=f_ln;
 key[9]:='ASIN'; code[9]:=f_asin;
 key[10]:='ACOS';code[10]:=f_acos;
 key[11]:='TAN'; code[11]:=f_tan;
 key[12]:='ATAN';code[12]:=f_atan;
 key[13]:='RE';  code[13]:=f_re;
 key[14]:='IM';  code[14]:=f_im;
 key[15]:='ARG'; code[15]:=f_arg;

 fehlertext[1]:='Macroname zu lang.';
 fehlertext[2]:='Variablenname zu lang.';
 fehlertext[3]:='UngÅltiges Zeichen.';
 fehlertext[4]:='")" erwartet.';
 fehlertext[5]:='Zahl nach Dezimalpunkt erwartet.';
 fehlertext[6]:='Zahl nach E+- erwartet.';
 fehlertext[7]:='+ oder - nach E erwartet.';
 fehlertext[8]:='(Operator zu wenig oder zu viel ?)';
 fehlertext[9]:='Ende des Ausdrucks erwartet';
 fehlertext[10]:='")" nach Funktionsargument erwartet.';
 fehlertext[11]:='"(" nach Funktionsname erwartet.';
 fehlertext[12]:='Variable unbekannt';
 fehlertext[13]:='Macro unbekannt';
 fehlertext[14]:='Zahl zu lang.';

 rtetext[1]:='Division durch Null';
 rtetext[2]:='LN(0) nicht definiert';
 rtetext[3]:='Variable nicht gefunden';
 rtetext[4]:='Macro nicht gefunden';
 rtetext[5]:='Macro ist fehlerhaft!';

end; 

