

asm68k /k /o op+ /o os+ /o ow+ /o oz+ /o oaq+ /o osq+ /o omq+ /p /o ae- sonic.asm, s1built.bin >errors.txt, sonic.sym, sonic.lst
convsym sonic.sym sonic.symcmp
copy /B s1built.bin+sonic.symcmp s1built.bin /Y
del sonic.symcmp

cd SMPS Flamewing
build.bat

cd ..



rem rompad.exe s1built.bin 255 0
rem fixheadr.exe s1built.bin
pause