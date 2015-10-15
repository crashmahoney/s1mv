

asm68k /k /p /o ae- sonic.asm, s1built.bin >errors.txt, , sonic.lst
REM jasm68 /k /p /o ae- sonic.asm, s1built.bin >errors.txt, , sonic.lst
cd SMPS Flamewing
build.bat

cd ..
rem rompad.exe s1built.bin 255 0
fixheadr.exe s1built.bin
pause