CFLAGS	= -O -D_MINIX -D_POSIX_SOURCE


SUB	= atari ar mdb stclock stterm \
	  bawk de elvis ic indent kermit m4 make \
	  mined nroff patch sh zmodem
SUBNEW	=
SUBNOT	= basic elle stevie dis88
BIN	= animals ascii at atrun backup \
	  badblocks banner basename btoa cal \
	  cat cdiff cgrep chgrp chmem \
	  chmod chown ci clr cmp \
	  co comm compress cp cpdir \
	  crc cron cut date dd \
	  df dhrystone diff diskcheck du \
	  echo ed expand expr factor \
	  fgrep file find fix \
	  fold fortune fsck gather getlf \
	  getty grep gres head id \
	  ifdef inodes kill last leave \
	  ln login look lpr \
	  ls machine mail man mkdir mkfs \
	  mknod mkproto modem more mount \
	  mref mv nm od passwd \
	  paste pr prep pretty printenv \
	  printroot ps pwd readall readfs \
	  recover rev rm rmdir roff \
	  sed shar size sleep sort \
	  split strings strip stty su \
	  sum sync tail tar tee \
	  termcap test time touch \
	  tr traverse treecmp tset tsort \
	  ttt tty umount unexpand uniq \
	  unshar update users uud uue \
	  vol wc whatsnew which who \
	  whoami width write
BINNEW	=
BINNOT	=
SCR	= fixbin spell svclog true whereis
SCRNEW	=
SCRNOT	=
CMD	= $(BIN) $(SCR)
CMDNEW	= $(BINNEW) $(SCRNEW)
CMDNOT	= $(BINNOT) $(SCRNOT)

all:	$(CMD) $(CMDNEW)
	for i in $(SUB) $(SUBNEW); do cd $$i; pwd; make $@; cd ..; done

clean:
	rm -f *.o
	for i in $(SUB) $(SUBNEW); do cd $$i; pwd; make $@; cd ..; done

clobber:
	rm -f $(CMD) $(CMDNEW)
	for i in $(SUB) $(SUBNEW); do cd $$i; pwd; make $@; cd ..; done

fixbin: fixbin.sh
	cp $@.sh $@; chmod +wx $@
spell: spell.sh
	cp $@.sh $@; chmod +wx $@
svclog: svclog.sh
	cp $@.sh $@; chmod +wx $@
true: true.sh
	cp $@.sh $@; chmod +wx $@
whereis: whereis.sh
	cp $@.sh $@; chmod +wx $@

animals: animals.c
	$(CC) $(CFLAGS) $@.c -o $@
ascii: ascii.c
	$(CC) $(CFLAGS) $@.c -o $@
at: at.c
	$(CC) $(CFLAGS) $@.c -o $@
atrun: atrun.c
	$(CC) $(CFLAGS) $@.c -o $@
backup: backup.c
	$(CC) $(CFLAGS) $@.c -o $@
badblocks: badblocks.c
	$(CC) $(CFLAGS) $@.c -o $@
banner: banner.c
	$(CC) $(CFLAGS) $@.c -o $@
basename: basename.c
	$(CC) $(CFLAGS) $@.c -o $@
btoa: btoa.c
	$(CC) $(CFLAGS) $@.c -o $@
cal: cal.c
	$(CC) $(CFLAGS) $@.c -o $@
cat: cat.c
	$(CC) $(CFLAGS) $@.c -o $@
cdiff: cdiff.c
	$(CC) $(CFLAGS) $@.c -o $@
cgrep: cgrep.c
	$(CC) $(CFLAGS) $@.c -o $@
chgrp: chgrp.c
	$(CC) $(CFLAGS) $@.c -o $@
chmem: chmem.c
	$(CC) $(CFLAGS) $@.c -o $@
chmod: chmod.c
	$(CC) $(CFLAGS) $@.c -o $@
chown: chown.c
	$(CC) $(CFLAGS) $@.c -o $@
ci: ci.c
	$(CC) $(CFLAGS) $@.c -o $@
clr: clr.c
	$(CC) $(CFLAGS) $@.c -o $@
cmp: cmp.c
	$(CC) $(CFLAGS) $@.c -o $@
co: co.c
	$(CC) $(CFLAGS) $@.c -o $@
comm: comm.c
	$(CC) $(CFLAGS) $@.c -o $@
compress: compress.c
	$(CC) $(CFLAGS) $@.c -o $@
cp: cp.c
	$(CC) $(CFLAGS) $@.c -o $@
cpdir: cpdir.c
	$(CC) $(CFLAGS) $@.c -o $@
crc: crc.c
	$(CC) $(CFLAGS) $@.c -o $@
cron: cron.c
	$(CC) $(CFLAGS) $@.c -o $@
cut: cut.c
	$(CC) $(CFLAGS) $@.c -o $@
date: date.c
	$(CC) $(CFLAGS) $@.c -o $@
dd: dd.c
	$(CC) $(CFLAGS) $@.c -o $@
df: df.c
	$(CC) $(CFLAGS) $@.c -o $@
dhrystone: dhrystone.c
	$(CC) $(CFLAGS) $@.c -o $@
diff: diff.c
	$(CC) $(CFLAGS) $@.c -o $@
diskcheck: diskcheck.c
	$(CC) $(CFLAGS) $@.c -o $@
du: du.c
	$(CC) $(CFLAGS) $@.c -o $@
echo: echo.c
	$(CC) $(CFLAGS) $@.c -o $@
ed: ed.c
	$(CC) $(CFLAGS) $@.c -o $@
expand: expand.c
	$(CC) $(CFLAGS) $@.c -o $@
expr: expr.c
	$(CC) $(CFLAGS) $@.c -o $@
factor: factor.c
	$(CC) $(CFLAGS) $@.c -o $@
fgrep: fgrep.c
	$(CC) $(CFLAGS) $@.c -o $@
file: file.c
	$(CC) $(CFLAGS) $@.c -o $@
find: find.c
	$(CC) $(CFLAGS) $@.c -o $@
fix: fix.c
	$(CC) $(CFLAGS) $@.c -o $@
fold: fold.c
	$(CC) $(CFLAGS) $@.c -o $@
fortune: fortune.c
	$(CC) $(CFLAGS) $@.c -o $@
fsck: fsck.c
	$(CC) $(CFLAGS) $@.c -o $@
gather: gather.c
	$(CC) $(CFLAGS) $@.c -o $@
getlf: getlf.c
	$(CC) $(CFLAGS) $@.c -o $@
getty: getty.c
	$(CC) $(CFLAGS) $@.c -o $@
grep: grep.c
	$(CC) $(CFLAGS) $@.c -o $@
gres: gres.c
	$(CC) $(CFLAGS) $@.c -o $@
head: head.c
	$(CC) $(CFLAGS) $@.c -o $@
id: id.c
	$(CC) $(CFLAGS) $@.c -o $@
ifdef: ifdef.c
	$(CC) $(CFLAGS) $@.c -o $@
inodes: inodes.c
	$(CC) $(CFLAGS) $@.c -o $@
kill: kill.c
	$(CC) $(CFLAGS) $@.c -o $@
last: last.c
	$(CC) $(CFLAGS) $@.c -o $@
leave: leave.c
	$(CC) $(CFLAGS) $@.c -o $@
ln: ln.c
	$(CC) $(CFLAGS) $@.c -o $@
login: login.c
	$(CC) $(CFLAGS) $@.c -o $@
look: look.c
	$(CC) $(CFLAGS) $@.c -o $@
lpr: lpr.c
	$(CC) $(CFLAGS) $@.c -o $@
ls: ls.c
	$(CC) $(CFLAGS) $@.c -o $@
machine: machine.c
	$(CC) $(CFLAGS) $@.c -o $@
mail: mail.c
	$(CC) $(CFLAGS) $@.c -o $@
man: man.c
	$(CC) $(CFLAGS) $@.c -o $@
mkdir: mkdir.c
	$(CC) $(CFLAGS) $@.c -o $@
mkfs: mkfs.c
	$(CC) $(CFLAGS) $@.c -o $@
mknod: mknod.c
	$(CC) $(CFLAGS) $@.c -o $@
mkproto: mkproto.c
	$(CC) $(CFLAGS) $@.c -o $@
modem: modem.c
	$(CC) $(CFLAGS) $@.c -o $@
more: more.c
	$(CC) $(CFLAGS) $@.c -o $@
mount: mount.c
	$(CC) $(CFLAGS) $@.c -o $@
mref: mref.c
	$(CC) $(CFLAGS) $@.c -o $@
mv: mv.c
	$(CC) $(CFLAGS) $@.c -o $@
nm: nm.c
	$(CC) $(CFLAGS) $@.c -o $@
od: od.c
	$(CC) $(CFLAGS) $@.c -o $@
passwd: passwd.c
	$(CC) $(CFLAGS) $@.c -o $@
paste: paste.c
	$(CC) $(CFLAGS) $@.c -o $@
pr: pr.c
	$(CC) $(CFLAGS) $@.c -o $@
prep: prep.c
	$(CC) $(CFLAGS) $@.c -o $@
pretty: pretty.c
	$(CC) $(CFLAGS) $@.c -o $@
printenv: printenv.c
	$(CC) $(CFLAGS) $@.c -o $@
printroot: printroot.c
	$(CC) $(CFLAGS) $@.c -o $@
ps: ps.c
	$(CC) $(CFLAGS) $@.c -o $@
pwd: pwd.c
	$(CC) $(CFLAGS) $@.c -o $@
readall: readall.c
	$(CC) $(CFLAGS) $@.c -o $@
readfs: readfs.c
	$(CC) $(CFLAGS) $@.c -o $@
recover: recover.c
	$(CC) $(CFLAGS) $@.c -o $@
rev: rev.c
	$(CC) $(CFLAGS) $@.c -o $@
rm: rm.c
	$(CC) $(CFLAGS) $@.c -o $@
rmdir: rmdir.c
	$(CC) $(CFLAGS) $@.c -o $@
roff: roff.c
	$(CC) $(CFLAGS) $@.c -o $@
sed: sed.c
	$(CC) $(CFLAGS) $@.c -o $@
shar: shar.c
	$(CC) $(CFLAGS) $@.c -o $@
size: size.c
	$(CC) $(CFLAGS) $@.c -o $@
sleep: sleep.c
	$(CC) $(CFLAGS) $@.c -o $@
sort: sort.c
	$(CC) $(CFLAGS) $@.c -o $@
split: split.c
	$(CC) $(CFLAGS) $@.c -o $@
strings: strings.c
	$(CC) $(CFLAGS) $@.c -o $@
strip: strip.c
	$(CC) $(CFLAGS) $@.c -o $@
stty: stty.c
	$(CC) $(CFLAGS) $@.c -o $@
su: su.c
	$(CC) $(CFLAGS) $@.c -o $@
sum: sum.c
	$(CC) $(CFLAGS) $@.c -o $@
sync: sync.c
	$(CC) $(CFLAGS) $@.c -o $@
tail: tail.c
	$(CC) $(CFLAGS) $@.c -o $@
tar: tar.c
	$(CC) $(CFLAGS) $@.c -o $@
tee: tee.c
	$(CC) $(CFLAGS) $@.c -o $@
termcap: termcap.c
	$(CC) $(CFLAGS) $@.c -o $@
test: test.c
	$(CC) $(CFLAGS) $@.c -o $@
time: time.c
	$(CC) $(CFLAGS) $@.c -o $@
touch: touch.c
	$(CC) $(CFLAGS) $@.c -o $@
tr: tr.c
	$(CC) $(CFLAGS) $@.c -o $@
traverse: traverse.c
	$(CC) $(CFLAGS) $@.c -o $@
treecmp: treecmp.c
	$(CC) $(CFLAGS) $@.c -o $@
tset: tset.c
	$(CC) $(CFLAGS) $@.c -o $@
tsort: tsort.c
	$(CC) $(CFLAGS) $@.c -o $@
ttt: ttt.c
	$(CC) $(CFLAGS) $@.c -o $@
tty: tty.c
	$(CC) $(CFLAGS) $@.c -o $@
umount: umount.c
	$(CC) $(CFLAGS) $@.c -o $@
unexpand: unexpand.c
	$(CC) $(CFLAGS) $@.c -o $@
uniq: uniq.c
	$(CC) $(CFLAGS) $@.c -o $@
unshar: unshar.c
	$(CC) $(CFLAGS) $@.c -o $@
update: update.c
	$(CC) $(CFLAGS) $@.c -o $@
users: users.c
	$(CC) $(CFLAGS) $@.c -o $@
uud: uud.c
	$(CC) $(CFLAGS) $@.c -o $@
uue: uue.c
	$(CC) $(CFLAGS) $@.c -o $@
vol: vol.c
	$(CC) $(CFLAGS) $@.c -o $@
wc: wc.c
	$(CC) $(CFLAGS) $@.c -o $@
whatsnew: whatsnew.c
	$(CC) $(CFLAGS) $@.c -o $@
which: which.c
	$(CC) $(CFLAGS) $@.c -o $@
who: who.c
	$(CC) $(CFLAGS) $@.c -o $@
whoami: whoami.c
	$(CC) $(CFLAGS) $@.c -o $@
width: width.c
	$(CC) $(CFLAGS) $@.c -o $@
write: write.c
	$(CC) $(CFLAGS) $@.c -o $@
