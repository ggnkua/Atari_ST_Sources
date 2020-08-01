echo Project: System

env MODPATH=$OBERON\system.prj
env OCOPT=+x
env OLOPT=-d$PRGPATH\-a-xTTP-t
env LINKALSO
env LINK_IO
env LINK_FORM=IOFORM
