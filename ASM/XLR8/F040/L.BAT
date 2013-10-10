@edit /h hardware.asm keyboard.asm f030.asm io.asm blitter.asm screen.asm
@tasm32 /ml /m9 /q /mu hardware.asm
@tasm32 /ml /m9 /q /mu f030.asm
@wlink system pmodew file {m68030\m68030 d68030 hardware F030} name f030.exe

