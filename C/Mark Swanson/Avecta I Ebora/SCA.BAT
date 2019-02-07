cp68 b:%1.c c:%1.i
c068 c:%1.i c:%1.1 c:%1.2 c:%1.3 -f
rm c:%1.i
c168 c:%1.1 c:%1.2 c:%1.s
rm c:%1.1
rm c:%1.2
as68 -f c: -l -u c:%1.s
rm c:%1.s
wait
