asm56000 -b -ic:\alefn\release\leonid -ic:\cross\56000\include -l recoder.asm
asm56000 -b -ic:\alefn\release\leonid -ic:\cross\56000\include -l synt.asm
asm56000 -b -ic:\alefn\release\leonid -ic:\cross\56000\include -l coder.asm
asm56000 -b -ic:\alefn\release\leonid -ic:\cross\56000\include -l speech.asm

lnk56000 -c -brecoder.lod -mrecoder.map -rrecoder.mem recoder synt coder speech
