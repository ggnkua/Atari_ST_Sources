PROGRAM conversion_library_test;   {Hartmut Thordsen, im Februar 1987}

VAR	s	  : STRING ;
	r	  : REAL ;
	l	  : LONG_INTEGER ;
	i, rcode  : INTEGER ;

{$I lib\convlib.inc}

BEGIN
s := '	 1234  ';
  write ('STR_TO_INT	  : *', s, '* ==> *');
  IF str_to_int (s,i)
    THEN writeln (i, '*')
    ELSE writeln ('FEHLER*');
s := '	-1234  ';
  write ('STR_TO_INT	  : *', s, '* ==> *');
  IF str_to_int (s,i)
    THEN writeln (i, '*')
    ELSE writeln ('FEHLER*');
s := '	 123 4 ';
  write ('STR_TO_INT	  : *', s, '* ==> *');
  IF str_to_int (s,i)
    THEN writeln (i, '*')
    ELSE writeln ('FEHLER*');
s := '	61234  ';
  write ('STR_TO_INT	  : *', s, '* ==> *');
  IF str_to_int (s,i)
    THEN writeln (i, '*')
    ELSE writeln ('FEHLER*');
s := '	 1234  ';
  write ('STR_TO_LONG_INT : *', s, '* ==> *');
  IF str_to_long_int (s,l)
    THEN writeln (l, '*')
    ELSE writeln ('FEHLER*');
s := '-891234  ';
  write ('STR_TO_LONG_INT : *', s, '* ==> *');
  IF str_to_long_int (s,l)
    THEN writeln (l, '*')
    ELSE writeln ('FEHLER*');
s := '1189123467';
  write ('STR_TO_LONG_INT : *', s, '* ==> *');
  IF str_to_long_int (s,l)
    THEN writeln (l, '*')
    ELSE writeln ('FEHLER*');
s := ' - 1234  ';
  write ('STR_TO_LONG_INT : *', s, '* ==> *');
  IF str_to_long_int (s,l)
    THEN writeln (l, '*')
    ELSE writeln ('FEHLER*');
s := '	-1234.5678E+12 ';
  write ('STR_TO_REAL	  : *', s, '* ==> *');
  IF str_to_real (s,r)
    THEN writeln (r, '*')
    ELSE writeln ('FEHLER*');
s := '	-123411223E-11 ';
  write ('STR_TO_REAL	  : *', s, '* ==> *');
  IF str_to_real (s,r)
    THEN writeln (r, '*')
    ELSE writeln ('FEHLER*');
s := '	-1234.567812   ';
  write ('STR_TO_REAL	  : *', s, '* ==> *');
  IF str_to_real (s,r)
    THEN writeln (r, '*')
    ELSE writeln ('FEHLER*');
s := '	-1234	       ';
  write ('STR_TO_REAL	  : *', s, '* ==> *');
  IF str_to_real (s,r)
    THEN writeln (r, '*')
    ELSE writeln ('FEHLER*');
writeln ('Weiter mit ENTER.'); readln(s); write (chr(27),'E');

i := -12345;
  write ('INT_TO_STR	  : ', i:20, ' ==> *');
  int_to_str (i,s);
  writeln (s, '*');
i := 0815;
  write ('INT_TO_STR	  : ', i:20, ' ==> *');
  int_to_str (i,s);
  writeln (s, '*');
i := -0;
  write ('INT_TO_STR	  : ', i:20, ' ==> *');
  int_to_str (i,s);
  writeln (s, '*');
l := -123456789;
  write ('LONG_INT_TO_STR : ', l:20, ' ==> *');
  long_int_to_str (l,s);
  writeln (s, '*');
l := 7;
  write ('LONG_INT_TO_STR : ', l:20, ' ==> *');
  long_int_to_str (l,s);
  writeln (s, '*');
l := 0;
  write ('LONG_INT_TO_STR : ', l:20, ' ==> *');
  long_int_to_str (l,s);
  writeln (s, '*');
r := 1.12345678939E4;
  write ('REAL_TO_STR	  : ', r:20, ' ==> *');
  real_to_str (r,s);
  writeln (s, '*');
r := -9999.999999E-22;
  write ('REAL_TO_STR	  : ', r:20, ' ==> *');
  real_to_str (r,s);
  writeln (s, '*');
r := 0.00000;
  write ('REAL_TO_STR	  : ', r:20, ' ==> *');
  real_to_str (r,s);
  writeln (s, '*');
r := 1.000000001E-22;
  write ('REAL_TO_STR	  : ', r:20, ' ==> *');
  real_to_str (r,s);
  writeln (s, '*');
r := 1.000000001E22;
  write ('REAL_TO_STR	  : ', r:20, ' ==> *');
  real_to_str (r,s);
  writeln (s, '*');
r := 1.1234512345E22;
  write ('REAL_TO_STR	  : ', r:20, ' ==> *');
  real_to_str (r,s);
  writeln (s, '*');
r := 0.000000009E22;
  write ('REAL_TO_STR	  : ', r:20, ' ==> *');
  real_to_str (r,s);
  writeln (s, '*');
writeln ('Weiter mit ENTER.'); readln(s); write (chr(27),'E');
END.
