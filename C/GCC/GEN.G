echo make genconfi.ttp
make genconfi.ttp
echo 'genconfi md > insn-config.h'
genconfi md > insn-config.h
echo make genflags.ttp
make genflags.ttp
echo 'genflags md > insn-flags.h'
genflags md > insn-flags.h
echo make gencodes.ttp
make gencodes.ttp
echo 'gencodes md > insn-codes.h'
gencodes md > insn-codes.h
echo make genemit.ttp
make genemit.ttp
echo 'genemit md > insn-emit.c'
genemit md > insn-emit.c
echo make genrecog.ttp
make genrecog.ttp
echo 'genrecog md > insn-recog.c'
genrecog md > insn-recog.c
echo make genextra.ttp
make genextra.ttp
echo 'genextra md > insn-extract.c'
genextra md > insn-extract.c
echo make genoutpu.ttp
make genoutpu.ttp
echo 'genoutpu md > insn-output.c'
genoutpu md > insn-output.c
echo make genpeep.ttp
make genpeep.ttp
echo 'genpeep md > insn-peep.c'
genpeep md > insn-peep.c
