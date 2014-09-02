cp68 menu.c menu.i
c068 menu.i menu.1 menu.2 menu.3 -f
rm menu.i
c168 menu.1 menu.2 menu.s
rm menu.1
rm menu.2
as68 -l -u menu.s
as68 -l -u startup.s
as68 -l -u straid.s
as68 -l -u panel.s
as68 -l -u objects.s
as68 -l -u stamps.s
as68 -l -u stars.s
as68 -l -u aftstars.s
as68 -l -u joystick.s
as68 -l -u sound.s
as68 -l -u misc.s
as68 -l -u strimage.s
as68 -l -u shotdata.s
as68 -l -u basedata.s
as68 -l -u shipdata.s
as68 -l -u walldata.s
as68 -l -u shutdata.s
as68 -l -u rockdata.s
as68 -l -u cockpit.s
as68 -l -u titlepic.s
link68 [co[straid.lnk]]
relmod straid.68k straid.prg
rm straid.68k
wait
