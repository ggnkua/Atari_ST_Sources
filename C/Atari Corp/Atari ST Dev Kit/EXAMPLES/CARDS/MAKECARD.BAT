cp68 cards.c cards.i
c068 cards.i cards.1 cards.2 cards.3 -f
rm cards.i
c168 cards.1 cards.2 cards.s
rm cards.1
rm cards.2
as68 -l -u cards.s
rm cards.s
aln -o cards.prg apstart.o cards.o ctype.o osbind.o vdibind aesbind
wait
