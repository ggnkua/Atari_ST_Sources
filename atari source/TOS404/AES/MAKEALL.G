echo makeswgr
touch desk*.c
make -f makeswgr > swg.err
cp desk*.o .\swssger
echo makeswfr
touch desk*.c
make -f makeswfr > swfr.err
cp desk*.o .\swssfre
echo makefre
touch desk*.c
make -f makefre > fre.err
cp desk*.o .\french
echo makegrm
touch desk*.c
make -f makegrm > grm.err
cp desk*.o .\germany
echo makeita
touch desk*.c
make -f makeita > ita.err
cp desk*.o .\italy
echo makespa
touch desk*.c
make -f makespa > spa.err
cp desk*.o .\spain
echo makeswe
touch desk*.c
make -f makeswe > swe.err
cp desk*.o .\sweden
echo makeuk
touch desk*.c
make -f makeuk > uk.err
cp desk*.o .\uk
echo makeusa
touch desk*.c	
make -f makeusa > usa.err
cp desk*.o .\usa
