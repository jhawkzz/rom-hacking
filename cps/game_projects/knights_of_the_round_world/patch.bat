@cls

@..\..\patching_tools\cps1_rom_patcher.exe -bintools C:\Users\jered\projects\Cps1RomHacking\patching_tools\cps1_rom_patcher_dependency_bin -game C:\Users\jered\projects\Cps1RomHacking\hacking_projects\knights_of_the_round\original_romset\knights.zip -roms kr_23e.8f,kr_22.7f -x68source C:\Users\jered\projects\Cps1RomHacking\hacking_projects\knights_of_the_round\x68_source -output C:\Users\jered\projects\Cps1RomHacking\hacking_projects\knights_of_the_round\patched_romset\knights.zip

@echo COPYING PATCHED ROM TO MAME
@copy /Y C:\Users\jered\projects\Cps1RomHacking\hacking_projects\knights_of_the_round\patched_romset\knights.zip C:\Users\jered\projects\Cps1RomHacking\emulators\mame\roms\knights.zip
@copy /Y C:\Users\jered\projects\Cps1RomHacking\hacking_projects\knights_of_the_round\patched_romset\knights.zip C:\Users\jered\projects\Cps1RomHacking\emulators\fba_029743\roms\knights.zip
@copy /Y C:\Users\jered\projects\Cps1RomHacking\hacking_projects\knights_of_the_round\patched_romset\knights.zip C:\Users\jered\projects\Cps1RomHacking\emulators\winkawaks\roms\cps1\knights.zip

@debug-knights.lnk