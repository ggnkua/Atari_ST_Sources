# GULAM-Script for processing the POSIX modules
# NOTE: The order shown is a valid order for compiling too.
#
# Parameters:
#  $1: name that identifies the compiler, e.g. LPRM2, HM2,...-- see PORTAB.M2H
#      for valid names
#  $2: destination directory
#  $3: extension for definition modules, e.g. def, d,...
#  $4: extension for implementation modules, e.g. mod, m,...
#
# Sample call (in gulam): x_m2 LPRM2 m: def mod
#
m2ppx $1 support\portab.dpp $2\portab.$3
m2ppx $1 support\portab.ipp $2\portab.$4
#
m2ppx $1 ix\types.dpp $2\types.$3
m2ppx $1 ix\types.ipp $2\types.$4
m2ppx $1 support\isostrin.dpp $2\isostrin.$3
m2ppx $1 support\isostrin.ipp $2\isostrin.$4
m2ppx $1 support\stringsx.dpp $2\stringsx.$3
m2ppx $1 support\stringsx.ipp $2\stringsx.$4
#
m2ppx $1 ix\er.dpp $2\er.$3
m2ppx $1 ix\er.ipp $2\er.$4
m2ppx $1 support\lctypes.dpp $2\lctypes.$3
m2ppx $1 support\lctypes.ipp $2\lctypes.$4
m2ppx $1 support\lcposix.dpp $2\lcposix.$3
m2ppx $1 support\lcposix.ipp $2\lcposix.$4
m2ppx $1 support\lcen.dpp $2\lcen.$3
m2ppx $1 support\lcen.ipp $2\lcen.$4
m2ppx $1 support\lcde.dpp $2\lcde.$3
m2ppx $1 support\lcde.ipp $2\lcde.$4
m2ppx $1 support\lcfr.dpp $2\lcfr.$3
m2ppx $1 support\lcfr.ipp $2\lcfr.$4
m2ppx $1 support\lcnl.dpp $2\lcnl.$3
m2ppx $1 support\lcnl.ipp $2\lcnl.$4
m2ppx $1 support\lc.dpp $2\lc.$3
m2ppx $1 support\lc.ipp $2\lc.$4
#
m2ppx $1 c\blk.dpp $2\blk.$3
m2ppx $1 c\blk.ipp $2\blk.$4
m2ppx $1 support\plongset.dpp $2\plongset.$3
m2ppx $1 support\plongset.ipp $2\plongset.$4
m2ppx $1 support\oscalls.dpp $2\oscalls.$3
m2ppx $1 support\oscalls.ipp $2\oscalls.$4
m2ppx $1 support\dosfile.dpp $2\dosfile.$3
m2ppx $1 support\dosfile.ipp $2\dosfile.$4
m2ppx $1 support\dostime.dpp $2\dostime.$3
m2ppx $1 support\dostime.ipp $2\dostime.$4
m2ppx $1 support\dossyste.dpp $2\dossyste.$3
m2ppx $1 support\dossyste.ipp $2\dossyste.$4
m2ppx $1 support\dostext.dpp $2\dostext.$3
m2ppx $1 support\dostext.ipp $2\dostext.$4
m2ppx $1 c\ctype.dpp $2\ctype.$3
m2ppx $1 c\ctype.ipp $2\ctype.$4
m2ppx $1 c\str.dpp $2\cstr.$3
m2ppx $1 c\str.ipp $2\cstr.$4
m2ppx $1 c\lib.dpp $2\clib.$3
m2ppx $1 c\lib.ipp $2\clib.$4
m2ppx $1 c\mem.dpp $2\mem.$3
m2ppx $1 c\mem.ipp $2\mem.$4
m2ppx $1 support\pstorage.dpp $2\pstorage.$3
m2ppx $1 support\pstorage.ipp $2\pstorage.$4
#
m2ppx $1 c\args.dpp $2\args.$3
m2ppx $1 c\args.ipp $2\args.$4
m2ppx $1 support\dosdir.dpp $2\dosdir.$3
m2ppx $1 support\dosdir.ipp $2\dosdir.$4
m2ppx $1 ix\socket.dpp $2\socket.$3
m2ppx $1 ix\socket.ipp $2\socket.$4
m2ppx $1 ix\loc.dpp $2\loc.$3
m2ppx $1 ix\loc.ipp $2\loc.$4
m2ppx $1 ix\jump.dpp $2\jump.$3
m2ppx $1 ix\jump.ipp $2\jump.$4
m2ppx $1 ix\sig.dpp $2\sig.$3
m2ppx $1 ix\sig.ipp $2\sig.$4
m2ppx $1 ix\tim.dpp $2\tim.$3
m2ppx $1 ix\tim.ipp $2\tim.$4
m2ppx $1 ix\term.dpp $2\term.$3
m2ppx $1 ix\term.ipp $2\term.$4
m2ppx $1 ix\file.dpp $2\file.$3
m2ppx $1 ix\file.ipp $2\file.$4
m2ppx $1 ix\dir.dpp $2\dir.$3
m2ppx $1 ix\dir.ipp $2\dir.$4
m2ppx $1 ix\sys.dpp $2\sys.$3
m2ppx $1 ix\sys.ipp $2\sys.$4
m2ppx $1 ix\proc.dpp $2\proc.$3
m2ppx $1 ix\proc.ipp $2\proc.$4
m2ppx $1 ix\fcrypt.dpp $2\fcrypt.$3
m2ppx $1 ix\fcrypt.ipp $2\fcrypt.$4
m2ppx $1 c\ansic.dpp $2\ansic.$3
m2ppx $1 c\ansic.ipp $2\ansic.$4
m2ppx $1 ix\posix1.dpp $2\posix1.$3
m2ppx $1 ix\posix1.ipp $2\posix1.$4
m2ppx $1 ix\posix2.dpp $2\posix2.$3
m2ppx $1 ix\posix2.ipp $2\posix2.$4
m2ppx $1 ix\ix.dpp $2\ix.$3
m2ppx $1 ix\ix.ipp $2\ix.$4
#
m2ppx $1 support\pout.dpp $2\pout.$3
m2ppx $1 support\pout.ipp $2\pout.$4
m2ppx $1 support\dosio.dpp $2\dosio.$3
m2ppx $1 support\dosio.ipp $2\dosio.$4

