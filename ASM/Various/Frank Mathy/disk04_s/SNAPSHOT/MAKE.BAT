as68 -l -u snapshot.s
link68 [i] snapshot,68k=snapshot
relmod snapshot.68k,snapshot.tos
rm snapshot.68k
wait

