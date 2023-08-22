@cls

@..\..\patching_tools\cps1_rom_patcher.exe -bintools C:\Users\jered\projects\Cps1RomHacking\patching_tools\cps1_rom_patcher_dependency_bin -game C:\Users\jered\projects\Cps1RomHacking\hacking_projects\knights_of_the_round_usa\original_romset\knightsu.zip -roms kr_23u.8f,kr_22.7f -x68source C:\Users\jered\projects\Cps1RomHacking\hacking_projects\knights_of_the_round_usa\x68_source -output C:\Users\jered\projects\Cps1RomHacking\hacking_projects\knights_of_the_round_usa\patched_romset\knightsu.zip

@echo COPYING PATCHED ROM TO MAME
@copy /Y C:\Users\jered\projects\Cps1RomHacking\hacking_projects\knights_of_the_round_usa\patched_romset\knightsu.zip C:\Users\jered\projects\Cps1RomHacking\emulators\mame\roms\knightsu.zip
@copy /Y C:\Users\jered\projects\Cps1RomHacking\hacking_projects\knights_of_the_round_usa\patched_romset\knightsu.zip C:\Users\jered\projects\Cps1RomHacking\emulators\fba_029743\roms\knightsu.zip
@copy /Y C:\Users\jered\projects\Cps1RomHacking\hacking_projects\knights_of_the_round_usa\patched_romset\knightsu.zip C:\Users\jered\projects\Cps1RomHacking\emulators\winkawaks\roms\cps1\knightsu.zip

@debug-knights.lnk