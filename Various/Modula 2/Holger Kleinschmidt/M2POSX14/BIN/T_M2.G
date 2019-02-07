# GULAM-Script for processing the test modules
#
# Parameters:
#  $1: name that identifies the compiler, e.g. LPRM2, HM2,...-- see PORTAB.M2H
#      for valid names
#  $2: destination directory
#  $3: extension for program modules, e.g. mod, m,...
#
# Sample call (in gulam): t_m2 LPRM2 m: mod
#
m2ppx $1 tsys.mpp $2\tsys.$3
m2ppx $1 showids.mpp $2\showids.$3
m2ppx $1 forkexec.mpp $2\forkexec.$3
m2ppx $1 spawn.mpp $2\spawn.$3
m2ppx $1 showcmd.mpp $2\showcmd.$3
m2ppx $1 listdir.mpp $2\listdir.$3
m2ppx $1 tdossyst.mpp $2\tdossyst.$3
m2ppx $1 tfile.mpp $2\tfile.$3
m2ppx $1 tlib.mpp $2\tlib.$3
m2ppx $1 tthread.mpp $2\tthread.$3
m2ppx $1 tvfork.mpp $2\tvfork.$3
m2ppx $1 showsig.mpp $2\showsig.$3
m2ppx $1 tsighand.mpp $2\tsighand.$3
m2ppx $1 tsigtime.mpp $2\tsigtime.$3
m2ppx $1 showdate.mpp $2\showdate.$3

