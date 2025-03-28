{KPXDEKL.PAS}
 const varlen=15;
       maxkey=15;
       hashgroesse=10;
       pi=3.14159265359;

       bez=  #200;
       zahl= #201;
       macro=#202;
       ende= #203;
       expo= #204;
       fkt=  #205;

       f_sin=#210;f_cos=#211;f_tan=#212;f_exp=#213;f_ln= #214;
       f_abs=#215;f_sqr=#216;f_sqrt=#217;f_asin=#218;f_acos=#219;
       f_atan=#220;f_re=#221;f_im=#222;f_arg=#223;

 type  var_string=string[varlen];
       baumzeiger=^syntax_baum;
       syntax_baum=record
                 case operator:char of
                  '#'  :(wert:real);
                  bez  :(name:string[varlen]);
                  macro:(neu_baum:baumzeiger);
                  fkt  :(typ:char;weiter:baumzeiger);
                  '+','-','*','/','^','?':(links,rechts:baumzeiger);
                  '_'  :(next:baumzeiger);        {Vorzeichen}
                 end;
       varzeiger=^var_baum;
       var_baum=record
                name:var_string;
                re,im:real;
                next:varzeiger;
                end;
       macrozeiger=^macro_baum;
       macro_baum=record
                name:var_string;
                inhalt:string;
                s_baum:baumzeiger;
                next:macrozeiger;
                end;

 var pos,l,fehler_nr,rte_nr  :integer;
     key    :array[1..maxkey] of var_string;
     code   :array[1..maxkey] of char;
     fehler,rte :boolean; (* Fehler, RunTimeError *)
     fehlertext:array[1..14] of string;
     rtetext:array[1..5] of string;
     fehlerpos:integer;
     fehlerursache:string;
     varis  :array[0..hashgroesse] of varzeiger;
     macros :array[0..hashgroesse] of macrozeiger;


