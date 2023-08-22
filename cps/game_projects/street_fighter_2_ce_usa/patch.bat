@cls

@..\..\patching_tools\cps1_rom_patcher.exe -bintools C:\Users\jered\projects\Cps1RomHacking\patching_tools\cps1_rom_patcher_dependency_bin -game C:\Users\jered\projects\Cps1RomHacking\hacking_projects\street_fighter_2_ce_usa\original_romset\sf2ceua.zip -roms s92u_23a.8f,s92_22a.7f -x68source C:\Users\jered\projects\Cps1RomHacking\hacking_projects\street_fighter_2_ce_usa\x68_source -output C:\Users\jered\projects\Cps1RomHacking\hacking_projects\street_fighter_2_ce_usa\patched_romset\sf2ceua.zip

@echo COPYING PATCHED ROM TO MAME
@copy /Y C:\Users\jered\projects\Cps1RomHacking\hacking_projects\street_fighter_2_ce_usa\patched_romset\sf2ceua.zip C:\Users\jered\projects\Cps1RomHacking\emulators\mame\roms\sf2ceua.zip
@copy /Y C:\Users\jered\projects\Cps1RomHacking\hacking_projects\street_fighter_2_ce_usa\patched_romset\sf2ceua.zip C:\Users\jered\projects\Cps1RomHacking\emulators\fba_029743\roms\sf2ceua.zip
@copy /Y C:\Users\jered\projects\Cps1RomHacking\hacking_projects\street_fighter_2_ce_usa\patched_romset\sf2ceua.zip C:\Users\jered\projects\Cps1RomHacking\emulators\winkawaks\roms\cps1\sf2ceua.zip

@debug.lnk