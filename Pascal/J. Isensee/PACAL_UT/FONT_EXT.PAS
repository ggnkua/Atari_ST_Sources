
{$e+,m+ }

program font_ext_o_file ;

  function adresse (  i : long_integer ) : long_integer ;
   begin adresse := i ;
   end ;

  procedure l_poke ( var x : long_integer ; y : long_integer );
  begin x := y ;
  end ;

  function l_peek ( var x : long_integer ): long_integer ;
  begin l_peek := x ;
  end ;

begin end.
