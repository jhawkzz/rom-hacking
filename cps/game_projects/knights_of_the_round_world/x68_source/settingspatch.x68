;
;Address range 0F7000-0FFFFF is unused instruction memory, so we put our hacks there.
;Our base RAM address is 00FF0000, because the game starts reading at FF8000. How convenient.
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
;ff0000-ff0003 - magic number
;ff0004     ;Input locked
;ff0005     ;Soft Dip A
;ff0006     ;Soft Dip B
;ff0007     ;Soft Dip C
;ff0008-0B  ;4 Bytes - P1 Input, P2 Input, P1+P2 Start, Unused
;ff000C     ;In Dip Sub Menu
;ff000D     ;In Service Mode (Regardless of submenu)

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

    org $B30 ;Patch to jump to softdip hack. Original:  move.b $80001a.l, ($249c,A5) move.b $80001c.l, ($249d,A5) move.b $80001e.l, ($249e,A5)
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

    org $D78 ;Patch to jump to second softdip read. Original move.b $80001e.l, D0
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
    	jmp $F7400
;chunk

    org $CF2 ;Patch to jump to service menu read. Original move.b $800018.l, D2
        jmp $F7450
;chunk

    ; Copy and try updating Soft Dips
    org $F7000
        cmp.l #$abcdef, $ff0000 ;has the magic number been written?
        beq tryUnlockInput ;Yes, jump down to reading joy inputs and setting the soft dips
        ;No, do first tick init
        move.l #$abcdef, $ff0000 ;write magic number
        move.b $80001a, $ff0005 ;HardDipA to SoftDipA
        move.b $80001c, $ff0006 ;HardDipB to SoftDipB
        move.b $80001e, $ff0007 ;HardDipC to SoftDipC
        move.b #$0, $ff0004 ;clear the input locked flag
        move.l #$0, $ff0008 ;clear the input buffer plus value (longword)
        move.b #0, $ff000C ;clear the dip value
        
        ;force dip defaults that jered likes
        ;HUGE NOTE - MY COMMENTS AND LABELS INDICATING WHICH DIP IS SET BY WHICH INPUT IS WRONG.
        ;CODE IS FINE BUT THE COMMENTS ARE NOT!
        ;andi.b #$7F, $ff0006 ;2 player mode, not THREE
        andi.b #$DF, $ff0007 ;demo sound is on!!!!!
        andi.b #$BF, $ff0007 ;continues ok!
tryUnlockInput:
        move.w $800000, $ff0008 ;copy p1&p2 inputs to memory
        move.b $800018, $ff000A ;copy p1&p2 starts to next byte
        cmpi.l #$ffffff00, $ff0008 ;if everything is set, there are no inputs being held
        bne checkLocked
        move.b #$0, $ff0004 ;no input is held, clear our lock
        
checkLocked:
        cmpi.b #$FF, $ff0004 ;if locked, skip input checks
        beq softDipsToGameAddr
        
readPlayerInputsSetSoftDips:
        ;first make sure we're in the dip menu before processing any input
        cmpi.b #$FF, $ff000C
        bne softDipsToGameAddr

        ;For each dip switch, we'll check for corresponding control input.
        ;If it matches, we'll XOR the bit to toggle it off/on
        ;------
;START DIP A
        ;dip: 1000 0000 - P1 Up
        cmpi.l #$f7ffff00, $ff0008
        bne dip_A6
        eori.b #$80, $ff0005
        move.b #$ff, $ff0004 ;lock inputs

dip_A6: ;dip: 0100 0000 - P1 Right
        cmpi.l #$feffff00, $ff0008
        bne dip_A5
        eori.b #$40, $ff0005
        move.b #$ff, $ff0004 ;lock inputs

dip_A5: ;dip 0010 0000 - P1 Down
        cmpi.l #$fbffff00, $ff0008
        bne dip_A4
        eori.b #$20, $ff0005
        move.b #$ff, $ff0004 ;lock inputs

dip_A4: ;dip: 0001 0000 - P1 Left
        cmpi.l #$fdffff00, $ff0008
        bne dip_A3
        eori.b #$10, $ff0005
        move.b #$ff, $ff0004 ;lock inputs
        
dip_A3: ;dip: 0000 1000 - P1 Up + P1 Start
        cmpi.l #$f7ffef00, $ff0008
        bne dip_A2
        eori.b #$08, $ff0005
        move.b #$ff, $ff0004 ;lock inputs
        
dip_A2: ;dip: 0000 0100 - P1 Right + P1 Start
        cmpi.l #$feffef00, $ff0008
        bne dip_A1
        eori.b #$04, $ff0005
        move.b #$ff, $ff0004 ;lock inputs
        
dip_A1: ;dip: 0000 0010 - P1 Down + P1 Start
        cmpi.l #$fbffef00, $ff0008
        bne dip_A0
        eori.b #$02, $ff0005
        move.b #$ff, $ff0004 ;lock inputs

dip_A0: ;dip: 0000 0001 - P1 Left + P1 Start
        cmpi.l #$fdffef00, $ff0008
        bne dip_B7
        eori.b #$01, $ff0005
        move.b #$ff, $ff0004 ;lock inputs
        
;START DIP B
dip_B7: ;dip: 1000 0000 - P2 Up
        cmpi.l #$fff7ff00, $ff0008
        bne dip_B6
        eori.b #$80, $ff0006
        move.b #$ff, $ff0004 ;lock inputs

dip_B6: ;dip: 0100 0000 - P2 Right
        cmpi.l #$fffeff00, $ff0008
        bne dip_B5
        eori.b #$40, $ff0006
        move.b #$ff, $ff0004 ;lock inputs

dip_B5: ;dip 0010 0000 - P2 Down
        cmpi.l #$fffbff00, $ff0008
        bne dip_B4
        eori.b #$20, $ff0006
        move.b #$ff, $ff0004 ;lock inputs

dip_B4: ;dip: 0001 0000 - P2 Left
        cmpi.l #$fffdff00, $ff0008
        bne dip_B3
        eori.b #$10, $ff0006
        move.b #$ff, $ff0004 ;lock inputs
        
dip_B3: ;dip: 0000 1000 - P2 Up + P1 Start
        cmpi.l #$fff7ef00, $ff0008
        bne dip_B2
        eori.b #$08, $ff0006
        move.b #$ff, $ff0004 ;lock inputs
        
dip_B2: ;dip: 0000 0100 - P2 Right + P1 Start
        cmpi.l #$fffeef00, $ff0008
        bne dip_B1
        eori.b #$04, $ff0006
        move.b #$ff, $ff0004 ;lock inputs
        
dip_B1: ;dip: 0000 0010 - P2 Down + P1 Start
        cmpi.l #$fffbef00, $ff0008
        bne dip_B0
        eori.b #$02, $ff0006
        move.b #$ff, $ff0004 ;lock inputs

dip_B0: ;dip: 0000 0001 - P2 Left + P1 Start
        cmpi.l #$fffdef00, $ff0008
        bne dip_C7
        eori.b #$01, $ff0006
        move.b #$ff, $ff0004 ;lock inputs

;START DIP C
dip_C7: ;dip: 1000 0000 - P1 Up + P2 Start
        cmpi.l #$f7ffdf00, $ff0008
        bne dip_C6
        eori.b #$80, $ff0007
        move.b #$ff, $ff0004 ;lock inputs

dip_C6: ;dip: 0100 0000 - P1 Right + P2 Start
        cmpi.l #$feffdf00, $ff0008
        bne dip_C5
        eori.b #$40, $ff0007
        move.b #$ff, $ff0004 ;lock inputs

dip_C5: ;dip 0010 0000 - P1 Down + P2 Start
        cmpi.l #$fbffdf00, $ff0008
        bne dip_C4
        eori.b #$20, $ff0007
        move.b #$ff, $ff0004 ;lock inputs

dip_C4: ;dip: 0001 0000 - P1 Left + P2 Start
        cmpi.l #$fdffdf00, $ff0008
        bne dip_C3
        eori.b #$10, $ff0007
        move.b #$ff, $ff0004 ;lock inputs
        
dip_C3: ;dip: 0000 1000 - P2 Up + P2 Start
        cmpi.l #$fff7df00, $ff0008 ;caution, this is the FREEZE dip, and will, well, freeze the game.
        bne dip_C2
        eori.b #$08, $ff0007
        move.b #$ff, $ff0004 ;lock inputs
        
dip_C2: ;dip: 0000 0100 - P1 Right + P2 Start
        cmpi.l #$fffedf00, $ff0008
        bne dip_C1
        eori.b #$04, $ff0007
        move.b #$ff, $ff0004 ;lock inputs
        
dip_C1: ;dip: 0000 0100 - P1 Down + P2 Start
        cmpi.l #$fffbdf00, $ff0008
        bne dip_C0
        eori.b #$02, $ff0007
        move.b #$ff, $ff0004 ;lock inputs

dip_C0: ;dip: 0000 0001 - P1 Left + P2 Start
        cmpi.l #$fffddf00, $ff0008 ;caution, this is TEST mode, which locks you in the service menu till you flip the dip again.
        bne softDipsToGameAddr
        eori.b #$01, $ff0007
        move.b #$ff, $ff0004 ;lock inputs
        
softDipsToGameAddr:
        move.b  $ff0005, ($249c,A5) ;SoftDipA to Game Memory Addr
        move.b  $ff0006, ($249d,A5) ;SoftDipB to Game Memory Addr
        move.b  $ff0007, ($249e,A5) ;SoftDipC to Game Memory Addr
    	jmp $B48
;chunk	

    ;Write Soft Dips to data registers
    org $F7400
        move.b  $ff0005, D0 ;SoftDipA
        not.b   D0
        move.b  D0, ($249c,A5)
        move.b  $ff0006, D0 ;SoftDipB
        not.b   D0
        move.b  D0, ($249d,A5)
        move.b  $ff0007, D0 ;SoftDipC
        not.b   D0
        move.b  D0, ($249e,A5)
    	jmp $D9C
;chunk

    org $F7450 ;Write service menu val to D2
        move.b $800018.l, D2 ;Assume we're copying the hard input val
        cmpi.b #$ff, $ff000D ;if we're in service mode, we should just exit. We dont need to be polling cuz doing so will conflict with inputs for exiting submenus.
        beq exit
        cmpi.l #$ffffcf00, $ff0008 ;not in service mode so check for P1 + P2 Start being held
        bne exit
        move.b #$BF, D2 ;start buttons are being held, so write that to D2
exit:
        jmp $CF8
;chunk

    org $684b4 ;Called when setting the index for the service submenu to enter.
        jmp $F7500
;chunk

    ;Check for Entering Dip Submenu and enabling dip change
    org $F7500
        move.b ($0,A0), ($7, A0) ;Perform original instruction
        cmpi.b #$08, ($7, A0) ;Was 8 written? (Entering dip switch menu?)
        bne checkExitingServiceMenu
        move.b #$ff, $ff000C
        jmp finishEnterServiceSubmenu
checkExitingServiceMenu:
        cmpi.b #$09, ($7, A0) ;Was 9 written? (Exiting service menu)
        bne finishEnterServiceSubmenu
        move.b #$00, $ff000D ;clear the 'service mode' flag
        jmp finishEnterServiceSubmenu
finishEnterServiceSubmenu:
        jmp $684ba        
;chunk

    ;Note: The instruction we care about is actually at 686ca, but its only 4 bytes
    ;and our jump is 6, so we're patching the instruction prior so we keep the same alignment.
    org $686c8
        jmp $F7550
;chunk

    ;Handle Exiting Dip Submenu and disabling dip change
    org $f7550
        beq beqTo686d2 ;original instruction: 686c8 BEQ $686d2 - since we cant BEQ that far in memory, we beq here and then jmp.
        subq.b #2, ($2,A0) ;original instruction: 686ca subq.b #2, ($2,A0) (write 02 so it knows its at the main service menu)
        move.b #$00, $ff000C ;clear the flag we use that allows changing dip values
        jmp $686ce
beqTo686d2:
        jmp $686d2
;chunk

    ;This is an instruction within the "setup service mode" method that's only called once on entry
    ;to service mode (from game or submenu). Its further in because its 6 bytes which is what we need,
    ;so it preserves alignment.
    org $68478
    jmp $F7600 ;Original instruction - move.w  #$9280, ($241a,A5)
;chunk

    org $F7600
        move.w  #$9280, ($241a,A5) ;perform original instruction at 68478
        move.b #$FF, $ff000D
    jmp $6847E
;chunk
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
