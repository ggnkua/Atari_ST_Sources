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
# Sample call (in gulam): misc_m2 LPRM2 m: def mod
#
m2ppx $1 bigsets.dpp $2\bigsets.$3
m2ppx $1 bigsets.ipp $2\bigsets.$4
m2ppx $1 datelib.dpp $2\datelib.$3
m2ppx $1 datelib.ipp $2\datelib.$4
m2ppx $1 pvt52.dpp $2\pvt52.$3
m2ppx $1 pvt52.ipp $2\pvt52.$4
m2ppx $1 adtbase.dpp $2\adtbase.$3
m2ppx $1 adtbase.ipp $2\adtbase.$4
m2ppx $1 dlists.dpp $2\dlists.$3
m2ppx $1 dlists.ipp $2\dlists.$4
m2ppx $1 queues.dpp $2\queues.$3
m2ppx $1 queues.ipp $2\queues.$4
m2ppx $1 stacks.dpp $2\stacks.$3
m2ppx $1 stacks.ipp $2\stacks.$4
m2ppx $1 rbtrees.dpp $2\rbtrees.$3
m2ppx $1 rbtrees.ipp $2\rbtrees.$4
m2ppx $1 ptimer.dpp $2\ptimer.$3
m2ppx $1 ptimer.ipp $2\ptimer.$4

