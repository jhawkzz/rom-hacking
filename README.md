# rom-hacking
Fun x68 patches that can be applied to certain roms

Work in progress, but some highlights:

## Knights of the Round:
Enter Service Menu: Press P1 and P2 start at the same time to enter the game's service menu.

Soft Dip Settings: Allows a user to change settings normally controlled by hardware dip switches within the game’s service menu.

## Street Fighter II: Champion Edition:
Enter Service Menu: Press P1 and P2 start at the same time to enter the game's service menu.

Soft Dip Settings: Allows a user to change settings normally controlled by hardware dip switches within the game’s service menu.

Exit Service Menu: Support for exiting the game’s service menu was not implemented in the original binary. Instead, an arcade owner had to power cycle to exit the menu. This patch allows exiting back to the game from the service menu.

Restore Health: Patched the game’s main fighting tick function to allow a player to receive full health by pressing their respective Start Button during a match. Additionally, the life bar tick function was never written to animate “up” as life went up, so I replaced that function with a version that supports animating in either direction.
