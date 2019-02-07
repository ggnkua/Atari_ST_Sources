# GULAM-Script for processing the ISO test modules
#
# Parameters:
#  $1: name that identifies the compiler, e.g. LPRM2, HM2,...-- see PORTAB.M2H
#      for valid names
#  $2: destination directory
#  $3: extension for program modules, e.g. mod, m,...
#
# Sample call (in gulam): tiso_m2 LPRM2 m: mod
#
m2ppx $1 tcharcla.mpp $2\tcharcla.$3
m2ppx $1 tstrings.mpp $2\tstrings.$3
m2ppx $1 tsyscloc.mpp $2\tsyscloc.$3
m2ppx $1 tlowlong.mpp $2\tlowlong.$3
m2ppx $1 tlowreal.mpp $2\tlowreal.$3
m2ppx $1 tlongsup.mpp $2\tlongsup.$3
m2ppx $1 trealsup.mpp $2\trealsup.$3
m2ppx $1 tmath.mpp $2\tmath.$3
m2ppx $1 txmath.mpp $2\txmath.$3
m2ppx $1 tcmath.mpp $2\tcmath.$3
m2ppx $1 tlmath.mpp $2\tlmath.$3
m2ppx $1 tlxmath.mpp $2\tlxmath.$3
m2ppx $1 tlcmath.mpp $2\tlcmath.$3
m2ppx $1 twconv.mpp $2\twconv.$3
m2ppx $1 tfconv.mpp $2\tfconv.$3
m2ppx $1 printarg.mpp $2\printarg.$3

