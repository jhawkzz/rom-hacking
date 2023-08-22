;
;Address range 0F7000-0FFFFF is unused instruction memory, so we put our hacks there.
;Our base RAM address is 00FFF000 because the game seems to read as far in as FF9000
;Note that if we ever get a random crash, well, they probably DO use either 0F7000-0FFFFF and/or 00FF0000.
;
;******ANOTHER POSSIBILITY. DONT RUN OVER YOUR OWN CODE BY CAUSING ONE PATCH CHUNK TO ACCUMULATE TOO MANY INSTRUCTIONS AND RUN INTO THE NEXT******
;
;Settings Hack:
;Patches the game to read from "soft" dip switches instead of the physical hard ones.
;Also patches the game to read from "soft" inputs for the Service Menu input button.
;Then, we check button combinations to allow toggling them.
;
;Instruction Address Range: F7000 - F7380
;
;Memory Addresses Used: 
;fff000-ff0003 - magic number
;fff004     ;Input locked
;fff005     ;Soft Dip A
;fff006     ;Soft Dip B
;fff007     ;Soft Dip C
;fff008-0B  ;4 Bytes - P1 Input, P2 Input, P1+P2 Start, Unused
;fff00C     ;In Dip Sub Menu
;fff00D     ;In Service Mode (Regardless of submenu)

;Inputs - Weird. Inputs bits are set by default, and cleared when received.
;800018 ;P1 Start & P2 Start & Service Menu Btn
;800000 ;P2 (yes, p2) Inputs
;800001 ;P1 (seriously p1) Inputs. theyre reversed.
;80001A ;DipA
;80001C ;DipB
;80001E ;DipC

;Player Input Flags:
;up:         f7  11110111
;right:      fe  11111110
;down:       fb  11111011
;left:       fd  11111101
;btn1:       ef  11101111
;btn2:       df  11011111
;p1_start:   ef  11101111 (at addr 800018)
;p2_start:   df  11011111 (at addr 800018)

    org $157A ;Patch to jump to softdip hack. 
    ;--Original--
;00157A: move.b  $80001a.l, D0  6 bytes
;001580: not.b   D0             2 bytes
;001582: move.b  D0, ($86,A5)   4 bytes
;001586: move.b  $80001c.l, D0  6 bytes
;00158C: not.b   D0             2 bytes
;00158E: move.b  D0, ($87,A5)   4 bytes
;001592: move.b  $80001e.l, D0  6 bytes
;001598: not.b   D0             2 bytes
;00159A: move.b  D0, ($88,A5)   4 bytes
;Return to $00159E
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
     jmp $F7000
;chunk

    ; Copy and try updating Soft Dips
    org $F7000
        cmp.l #$abcdef, $fff000 ;has the magic number been written?
        beq tryUnlockInput ;Yes, jump down to reading joy inputs and setting the soft dips
        ;No, do first tick init
        move.l #$abcdef, $fff000 ;write magic number
        move.b $80001a, $fff005 ;HardDipA to SoftDipA
        move.b $80001c, $fff006 ;HardDipB to SoftDipB
        move.b $80001e, $fff007 ;HardDipC to SoftDipC
        move.b #$0, $fff004 ;clear the input locked flag
        move.l #$0, $fff008 ;clear the input buffer plus value (longword)
        move.b #0, $fff00C ;clear the dip value
        
        ;force dip defaults that jered likes
        andi.b #$7F, $fff006 ;2 player mode, not THREE
        andi.b #$DF, $fff007 ;demo sound is on!!!!!
        andi.b #$BF, $fff007 ;continues ok!
tryUnlockInput:
        move.w $800000, $fff008 ;copy p1&p2 inputs to memory
        move.b $800018, $fff00A ;copy p1&p2 starts to next byte
        cmpi.w #$ffff, $fff008 ;if everything is set, there are no inputs being held
        bne checkLocked
        move.b #$0, $fff004 ;no input is held, clear our lock
        
checkLocked:
        cmpi.b #$FF, $fff004 ;if locked, skip input checks
        beq softDipsToGameAddr
        
readPlayerInputsSetSoftDips:
        ;first make sure we're in the dip menu before processing any input
        cmpi.b #$FF, $fff00C
        bne softDipsToGameAddr

        ;For each dip switch, we'll check for corresponding control input.
        ;If it matches, we'll XOR the bit to toggle it off/on
        ;------
;START DIP A - All of dip bank A controls coins to credits for each of the 3 players
        ;dip: 1000 0000 - P1 Up
        cmpi.l #$fff7ff00, $fff008
        bne dip_A6
        eori.b #$80, $fff005
        move.b #$ff, $fff004 ;lock inputs

dip_A6: ;dip: 0100 0000 - P1 Right
        cmpi.l #$fffeff00, $fff008
        bne dip_A5
        eori.b #$40, $fff005
        move.b #$ff, $fff004 ;lock inputs

dip_A5: ;dip 0010 0000 - P1 Down
        cmpi.l #$fffbff00, $fff008
        bne dip_A4
        eori.b #$20, $fff005
        move.b #$ff, $fff004 ;lock inputs

dip_A4: ;dip: 0001 0000 - P1 Left
        cmpi.l #$fffdff00, $fff008
        bne dip_A3
        eori.b #$10, $fff005
        move.b #$ff, $fff004 ;lock inputs
        
dip_A3: ;dip: 0000 1000 - P1 Up + P1 Start
        cmpi.l #$fff7ef00, $fff008
        bne dip_A2
        eori.b #$08, $fff005
        move.b #$ff, $fff004 ;lock inputs
        
dip_A2: ;dip: 0000 0100 - P1 Right + P1 Start
        cmpi.l #$fffeef00, $fff008
        bne dip_A1
        eori.b #$04, $fff005
        move.b #$ff, $fff004 ;lock inputs
        
dip_A1: ;dip: 0000 0010 - P1 Down + P1 Start
        cmpi.l #$fffbef00, $fff008
        bne dip_A0
        eori.b #$02, $fff005
        move.b #$ff, $fff004 ;lock inputs

dip_A0: ;dip: 0000 0001 - P1 Left + P1 Start
        cmpi.l #$fffdef00, $fff008
        bne dip_B7
        eori.b #$01, $fff005
        move.b #$ff, $fff004 ;lock inputs
        
;START DIP B
dip_B7: ;dip: 1000 0000 - P2 Up
        cmpi.l #$f7ffff00, $fff008
        bne dip_B6
        eori.b #$80, $fff006 ;Player Type: 2p or 3p
        move.b #$ff, $fff004 ;lock inputs

dip_B6: ;dip: 0100 0000 - P2 Right
        cmpi.l #$feffff00, $fff008
        bne dip_B5
        eori.b #$40, $fff006 ;Coin shooter
        move.b #$ff, $fff004 ;lock inputs

dip_B5: ;dip 0010 0000 - P2 Down
        cmpi.l #$fbffff00, $fff008
        bne dip_B4
        eori.b #$20, $fff006 ; Level 2: Normal / Difficult (works with B4,B3)
        move.b #$ff, $fff004 ;lock inputs

dip_B4: ;dip: 0001 0000 - P2 Left
        cmpi.l #$fdffff00, $fff008
        bne dip_B3
        eori.b #$10, $fff006 ;Level 2: Normal / Difficult (works with B5,B3)
        move.b #$ff, $fff004 ;lock inputs
        
dip_B3: ;dip: 0000 1000 - P2 Up + P1 Start
        cmpi.l #$f7ffef00, $fff008
        bne dip_B2
        eori.b #$08, $fff006 ;Level 2: Normal / Difficult (works with B5,B4)
        move.b #$ff, $fff004 ;lock inputs
        
dip_B2: ;dip: 0000 0100 - P2 Right + P1 Start
        cmpi.l #$feffef00, $fff008
        bne dip_B1
        eori.b #$04, $fff006 ;Level 1: Normal / Difficult (works with B1,B0)
        move.b #$ff, $fff004 ;lock inputs
        
dip_B1: ;dip: 0000 0010 - P2 Down + P1 Start
        cmpi.l #$fbffef00, $fff008
        bne dip_B0
        eori.b #$02, $fff006 ;Level 1: Normal / Difficult (works with B2,B0)
        move.b #$ff, $fff004 ;lock inputs

dip_B0: ;dip: 0000 0001 - P2 Left + P1 Start
        cmpi.l #$fdffef00, $fff008
        bne dip_C7
        eori.b #$01, $fff006 ;Level 1: Normal / Difficult (works with B2,B1)
        move.b #$ff, $fff004 ;lock inputs

;START DIP C
dip_C7: ;dip: 1000 0000 - P1 Up + P2 Start
        cmpi.l #$fff7df00, $fff008
        bne dip_C6
        eori.b #$80, $fff007 ;???
        move.b #$ff, $fff004 ;lock inputs

dip_C6: ;dip: 0100 0000 - P1 Right + P2 Start
        cmpi.l #$fffedf00, $fff008
        bne dip_C5
        eori.b #$40, $fff007 ;Continues On / Off
        move.b #$ff, $fff004 ;lock inputs

dip_C5: ;dip 0010 0000 - P1 Down + P2 Start
        cmpi.l #$fffbdf00, $fff008
        bne dip_C4
        eori.b #$20, $fff007 ;Demo Sound On / Off
        move.b #$ff, $fff004 ;lock inputs

dip_C4: ;dip: 0001 0000 - P1 Left + P2 Start
        cmpi.l #$fffddf00, $fff008
        bne dip_C3
        eori.b #$10, $fff007 ;Flip Screen
        move.b #$ff, $fff004 ;lock inputs
        
dip_C3: ;dip: 0000 1000 - P2 Up + P2 Start
        cmpi.l #$f7ffdf00, $fff008
        bne dip_C2
        eori.b #$08, $fff007 ;FREEZE GAME - CAUTION this will basically soft lock the game
        move.b #$ff, $fff004 ;lock inputs
        
dip_C2: ;dip: 0000 0100 - P2 Right + P2 Start
        cmpi.l #$feffdf00, $fff008
        bne dip_C1
        eori.b #$04, $fff007 ;Free Play On / Off
        move.b #$ff, $fff004 ;lock inputs
        
dip_C1: ;dip: 0000 0100 - P2 Down + P2 Start
        cmpi.l #$fbffdf00, $fff008
        bne dip_C0
        eori.b #$02, $fff007 ;Unknown Dip
        move.b #$ff, $fff004 ;lock inputs

dip_C0: ;dip: 0000 0001 - P2 Left + P2 Start
        cmpi.l #$fdffdf00, $fff008
        bne softDipsToGameAddr
        eori.b #$01, $fff007 ;Unknown Dip
        move.b #$ff, $fff004 ;lock inputs
        
softDipsToGameAddr:
        move.b  $fff005, D0 ;SoftDipA to Game Memory Addr
        not.b   D0
        move.b  D0, ($86,A5)
        move.b  $fff006, D0 ;SoftDipB to Game Memory Addr
        not.b   D0
        move.b  D0, ($87,A5)
        move.b  $fff007, D0 ;SoftDipC to Game Memory Addr
        not.b   D0
        move.b  D0, ($88,A5)
    	jmp $00159E.l
;chunk
	
    org $001508 ;Patch to jump to service menu read. Original move.b $800018.l, D0 
        jmp $F7450 ;this is 6 bytes
;chunk

    org $F7450 ;Write service menu val to D0
        move.b $800018.l, D0 ;Assume we're copying the hard input val
        cmpi.l #$ffffcf00, $fff008 ;check for P1 + P2 Start being held
        bne exit
        andi.b #$BF, D0 ;Clear the test button bit (which means its being held)
exit:
        jmp $00150E.l
;chunk

    ;Hook into the Service Menu Main Menu tick, and watch for both start buttons.
    ;If hit, we'll exit by jumping to $6f3a, the char select screen.
    ;To do that, we'll set registers and memory as it is when the PC is at $6f3a
    org $9E24C ;original: move.b ($7d,A5), D0 and next inst was not.b D0
        jmp $F7500 ;this is 6 bytes 
;chunk
    
    org $f7500
        move.b ($7d,A5), D0
        not.b D0
        cmpi.l #$ffffcf00, $fff008 ;check for P1 + P2 Start being held
        beq panic
        jmp $9e252.l
panic:
        move.b #$00, $fff00D ;Clear service mode flag cause we're leaving it.
        
        ;set registers to what they are when PC is at $6f3a
        move.l #$000000ff, D0
        move.l #$ffff0024, D1
        move.l #$00000001, D2
        move.l #$00000001, D3
        move.l #$00000090, D4
        move.l #$00E00004, D5
        move.l #$0000ff8b, D6
        move.l #$0000ffff, D7
        move.l #$ffff8193, A0
        move.l #$ffffcf76, A1
        move.l #$00019476, A2
        move.l #$00098bac, A3
        move.l #$ffff819e, A4
        move.l #$ffff8000, A5
        move.l #$ffffD276, A6
        move.l #$00ff038c, A7
        
        ;Set RAM values
        ;todo figure out what we ACTUALLY need.
        move.w #$02CC, $ff002A
        
        move.w #$0800, $ff0040
        move.w #$08F6, $ff0046
        move.w #$00FF, $ff0048
        move.w #$0350, $ff004A
        
        move.w #$001C, $ff0050
        move.w #$003C, $ff0052
        
        move.w #$0400, $ff00C0
        move.w #$01C4, $ff00D2
        
        move.b #$00  , $ff00E0
        move.w #$0000, $ff00E6
        move.b #$00  , $ff00E9
        move.w #$0000, $ff00EA
        move.l #$0   , $ff00F0
        
        move.w #$08F6, $ff0126
        move.w #$5052, $ff0146        

        move.w #$0040, $ff0206
        move.w #$0034, $ff025A
        move.w #$0000, $ff0264
        move.w #$0003, $ff02D2
        move.w #$003C, $ff02D6
        move.w #$0232, $ff02DA
        move.w #$0004, $ff02E2
        move.w #$00E0, $ff02E4
        move.w #$FFFF, $ff02E6
        move.w #$0000, $ff02E8
        move.w #$FFFF, $ff02EA
        move.w #$FFFF, $ff02EC
        move.w #$0020, $ff02EE
        
        
        move.w #$0000, $ff0384
        move.w #$6364, $ff0386
        move.w #$0000, $ff0388
        move.w #$6F3A, $ff038A
        move.w #$6D8C, $ff038E
        
        move.w #$FFFF, $ff0708
        move.w #$0120, $ff070A
        move.w #$4E30, $ff070E
        
        move.w #$0004, $ff8000
        move.w #$1600, $ff801C
        move.w #$0000, $ff801E
        move.w #$0000, $ff8020
        move.w #$0024, $ff8022
        move.w #$0020, $ff8024
        move.w #$9180, $ff8026
        move.w #$0000, $ff8038
        move.w #$0000, $ff803C
        move.w #$06CE, $ff804E
        move.w #$0300, $ff8062
        move.w #$0700, $ff8066
        move.w #$1000, $ff8072
        move.w #$0000, $ff8074
        move.w #$FFFF, $ff8090
        move.l #$0000ffff, $ff809C
        move.w #$0020, $ff819E
        
        move.w #$0020, $ff81A2
        move.w #$0020, $ff81A6
        move.w #$0020, $ff81AA
        move.w #$00F0, $ff81AE
        
        move.l #$00FF00F7, $ff81B0
        move.l #$00FF00F7, $ff81B4
        move.l #$00FF00F7, $ff81B8
        move.l #$00FF00F7, $ff81Bc
        
        move.b #$ff, $ff81c1
        
        move.b #$72, $ff82a4
        move.b #$0b, $ff82b3
        move.w #$05c8, $ff82c0
        move.b #$00, $ff82d4
        
        move.w #$0003, $ff82d8
        move.b #$04, $ff82dA
        
        
        move.b #$01, $ff82e0
        move.b #$04, $ff82f1
        move.w #$1311, $ff82f4
        
        move.l #$0, $ff8308
        move.l #$0, $ff830A
        move.l #$0, $ff8310
        
        move.b #$01, $ff833b
        move.b #$80, $ff833d
        
        move.b #$0, $ff89d9
        
        jmp $6f3a.l
 
;chunk

    org $9e27a ;Called when setting the index for the service submenu to enter.
        jmp $F7880
        nop
        nop
;chunk

    ;Check for Entering Dip Submenu and enabling dip change
    org $F7880
        move.w (-$747a,A5), ($4,A5)
        addq.w #2, ($0, A5)
        cmpi.b #$02, $ff8005 ;Was 02 written? (Entering dip switch menu?)
        bne finishEnterServiceSubmenu
        move.b #$ff, $fff00C
finishEnterServiceSubmenu:
        jmp $9e284.l        
;chunk

    ;This is an instruction within the "setup service mode" method that's only called once on entry from game or submenu
    ;to service mode
    org $9e21e
    jmp $F7900
;chunk

    org $F7900
        addq.w #2, ($0, A5)
        moveq #$0,D0 
        move.b #$FF, $fff00D
    jmp $9e224.l
;chunk

    ;Note: The instruction we care about is actually at 9e42c, but its only 4 bytes
    ;and our jump is 6, so we're patching the instruction prior so we keep the same alignment.
    org $9e42a
        jmp $F7950
;chunk

    ;Handle Exiting Dip Submenu and disabling dip change
    org $f7950
        beq beqTo9e430 ;This replicates the logic of 'beq 9e430', but we have to use a jmp
        clr.w ($0, A5) ;Clears the value controlling which submenu were in.
        move.b #$00, $fff00C ;clear the flag we use that allows changing dip values
beqTo9e430:
        jmp $9e430.l
;chunk

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
