PROGRAM string_library_test;   {V2.2, Hartmut Thordsen, Dezember 1987}

VAR	s, look, dest  : STRING ;

{$I lib\strinlib.inc}

BEGIN
s := 'abcdefghijkl';
  write   ('ord(s[0]),s[1],s[2] : *',ord(s[0]), '*', s[1], '*', s[2], '*');
  write   (', copy 1, 3 : *', copy (s,1,3), '*');
  writeln (', copy 4, ende : *', copy (s,4,length(s)-3), '*');
  write   ('pos von a : *', pos('a',s), '*, ');
  write   ('pos von e : *', pos('e',s), '*, ');
  writeln ('pos von x : *', pos('x',s), '*');
{ Test der trim-Prozeduren }
s := '	a  b  c   ';
  write ('LTRIM : *', s, '* ==> *');
  ltrim(s);
  writeln (s, '*');
s := '	a  b  c   ';
  write ('RTRIM : *', s, '* ==> *');
  rtrim(s);
  writeln (s, '*');
s := '	a  b  c   ';
  write ('TRIM	: *', s, '* ==> *');
  trim(s);
  writeln (s, '*');
s := 'a  b  c';
  write ('TRIM	: *', s, '* ==> *');
  trim(s);
  writeln (s, '*');
s := 'abc';
  write ('TRIM	: *', s, '* ==> *');
  trim(s);
  writeln (s, '*');
{ Test der format-Prozeduren }
s := 'Dies ist ein Test.';
  writeln;
  writeln ('Formatierfunktionen *', s, '*');
  lformat (s, 20);
  writeln ('LFORMAT 20 : *', s, '*');
  rformat (s, 25);
  writeln ('RFORMAT 25 : *', s, '*');
  cformat (s, 30);
  writeln ('CFORMAT 30 : *', s, '*');
  cformat (s, 19);
  writeln ('CFORMAT 19 : *', s, '*');
  rformat (s, 13);
  writeln ('RFORMAT 13 : *', s, '*');
writeln ('Weiter mit ENTER.'); readln(s); write (chr(27),'E');

s := 'Wer andern eine Grube graebt, faellt selbst hinein.';
  writeln ('*', s, '*');
  writeln ('VERIFY    *aW nr*	==> ', verify (s, 'aW nr'));
  clean_in (s, 'aeng xi');
  writeln ('CLEAN_IN  *aeng xi* ==> *', s, '*');
  clean_out (s, 'xa i');
  writeln ('CLEAN_OUT *xa i*	==> *', s, '*');
  writeln ('VERIFY    *eng*	==> ', verify (s, 'eng'));
  writeln ('VERIFY    *xng*	==> ', verify (s, 'xng'));
  writeln ('VERIFY    *ng*	==> ', verify (s, 'ng'));
  writeln ('VERIFY    **	==> ', verify (s, ''));
  clean_out (s, 'engx');
  writeln ('CLEAN_OUT *engx*	==> *', s, '*');
  writeln ('VERIFY    *ng*	==> ', verify (s, 'ng'));
  writeln ('VERIFY    **	==> ', verify (s, ''));
  clean_in (s, '');
  writeln ('CLEAN_IN  **	==> *', s, '*');
  clean_out (s, '');
  writeln ('CLEAN_OUT **	==> *', s, '*');
writeln;
s    := 'D:\RCT\RCT.RSC ';
look := '\';
  write ('STR_END : s=*', s, '*, lookex=*', look, '* ==> *');
  str_end (look,s,FALSE,dest);
  writeln (dest, '*');
look := 'CT';
  write ('STR_END : s=*', s, '*, lookin=*', look, '* ==> *');
  str_end (look,s,TRUE,dest);
  writeln (dest, '*');
look := 'A';
  write ('STR_END : s=*', s, '*, lookin=*', look, '* ==> *');
  str_end (look,s,TRUE,dest);
  writeln (dest, '*');
writeln ('STR_GREATER wird von diesem Programm nicht getestet.');
writeln ('Weiter mit ENTER.'); readln(s); write (chr(27),'E');
END.
