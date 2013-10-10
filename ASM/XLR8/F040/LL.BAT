@edit /h m68030\d68030.asm
@tasm32 /ml /q m68030\d68030.asm
@wlink system pmodew file {m68030\m68030 d68030 F030} name f030.exe

