| This module (start.o) must be linked first, ensuring that this will
| be the first instruction of the program. Thanks to Stephen Henson
| for this neat trick!

	jmp _ram_init
