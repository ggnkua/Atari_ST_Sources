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
m2ppx $1 portab.dpp $2\portab.$3
m2ppx $1 portab.ipp $2\portab.$4
m2ppx $1 pstorage.dpp $2\pstorage.$3
m2ppx $1 pstorage.ipp $2\pstorage.$4
m2ppx $1 pout.dpp $2\pout.$3
m2ppx $1 pout.ipp $2\pout.$4
#
m2ppx $1 types.dpp $2\types.$3
m2ppx $1 types.ipp $2\types.$4
m2ppx $1 memblk.dpp $2\memblk.$3
m2ppx $1 memblk.ipp $2\memblk.$4
m2ppx $1 plongset.dpp $2\plongset.$3
m2ppx $1 plongset.ipp $2\plongset.$4
m2ppx $1 oscalls.dpp $2\oscalls.$3
m2ppx $1 oscalls.ipp $2\oscalls.$4
#
m2ppx $1 lctypes.dpp $2\lctypes.$3
m2ppx $1 lctypes.ipp $2\lctypes.$4
m2ppx $1 lcposix.dpp $2\lcposix.$3
m2ppx $1 lcposix.ipp $2\lcposix.$4
m2ppx $1 lcgerman.dpp $2\lcgerman.$3
m2ppx $1 lcgerman.ipp $2\lcgerman.$4
m2ppx $1 lcusa.dpp $2\lcusa.$3
m2ppx $1 lcusa.ipp $2\lcusa.$4
m2ppx $1 lc.dpp $2\lc.$3
m2ppx $1 lc.ipp $2\lc.$4
#
m2ppx $1 e.dpp $2\e.$3
m2ppx $1 e.ipp $2\e.$4
m2ppx $1 ctype.dpp $2\ctype.$3
m2ppx $1 ctype.ipp $2\ctype.$4
m2ppx $1 lib.dpp $2\lib.$3
m2ppx $1 lib.ipp $2\lib.$4
m2ppx $1 cstr.dpp $2\cstr.$3
m2ppx $1 cstr.ipp $2\cstr.$4
m2ppx $1 pstring.dpp $2\pstring.$3
m2ppx $1 pstring.ipp $2\pstring.$4
m2ppx $1 dossyste.dpp $2\dossyste.$3
m2ppx $1 dossyste.ipp $2\dossyste.$4
m2ppx $1 cmdline.dpp $2\cmdline.$3
m2ppx $1 cmdline.ipp $2\cmdline.$4
m2ppx $1 dossuppo.dpp $2\dossuppo.$3
m2ppx $1 dossuppo.ipp $2\dossuppo.$4
m2ppx $1 loc.dpp $2\loc.$3
m2ppx $1 loc.ipp $2\loc.$4
m2ppx $1 jump.dpp $2\jump.$3
m2ppx $1 jump.ipp $2\jump.$4
m2ppx $1 sig.dpp $2\sig.$3
m2ppx $1 sig.ipp $2\sig.$4
m2ppx $1 tim.dpp $2\tim.$3
m2ppx $1 tim.ipp $2\tim.$4
m2ppx $1 file.dpp $2\file.$3
m2ppx $1 file.ipp $2\file.$4
m2ppx $1 dir.dpp $2\dir.$3
m2ppx $1 dir.ipp $2\dir.$4
m2ppx $1 sys.dpp $2\sys.$3
m2ppx $1 sys.ipp $2\sys.$4
m2ppx $1 proc.dpp $2\proc.$3
m2ppx $1 proc.ipp $2\proc.$4
m2ppx $1 term.dpp $2\term.$3
m2ppx $1 term.ipp $2\term.$4
m2ppx $1 ansic.dpp $2\ansic.$3
m2ppx $1 ansic.ipp $2\ansic.$4
m2ppx $1 posix1.dpp $2\posix1.$3
m2ppx $1 posix1.ipp $2\posix1.$4
m2ppx $1 posix2.dpp $2\posix2.$3
m2ppx $1 posix2.ipp $2\posix2.$4
m2ppx $1 bsd.dpp $2\bsd.$3
m2ppx $1 bsd.ipp $2\bsd.$4

