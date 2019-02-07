cp68 e:\alcyon\%1.c e:\alcyon\%1.i
c068 e:\alcyon\%1.i e:\alcyon\%1.1 e:\alcyon\%1.2 e:\alcyon\%1.3 -f
rm e:\alcyon\%1.i
c168 e:\alcyon\%1.1 e:\alcyon\%1.2 e:\alcyon\%1.s
rm e:\alcyon\%1.1
rm e:\alcyon\%1.2
as68 -f e:\alcyon\ -l -u e:\alcyon\%1.s
rm e:\alcyon\%1.s
wait
