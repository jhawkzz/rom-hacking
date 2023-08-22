;SF2 CE USA Program Instructions run from 0 to E38E1, so we're safe to take 
;E38F0 and on

;Disable Round Timer
    org $94D2 ;move.b #98, ($abe,A5) [4 bytes] is original and subs the timr. Replacing with no op
    nop
    nop
;chunk

;Allow each player's start button to refill life during round.
    ;Replace 8 bytes at 9476 and 947A with jump to allow health boost
    org $9476 ;move.b ($ac0,A5), D0 ; 947A is or.b ($ac2,A5), D0
    nop
    jmp $E38F0
    
;chunk
    
    org $E38F0
    move.b ($ac0,A5), D0
    or.b ($ac2,A5), D0
    
    cmp.b #$EF, $800018 ;if P1 start is down, restore P1's life
    bne p2check
    move.b #$90, $ff83e9
    ;move.b #$90, $ff857b ;dont set the lifebar, because our patched func will increment it
    
p2check:
    cmp.b #$DF, $800018 ;if P2 start is down, restore P2's life
    bne exit
    move.b #$90, $ff86e9
    ;move.b #$90, $ff887b; dont patch the lifebar, because our patched func will increment it
    
exit:
    jmp $00947e.l
;chunk

    ;replace their lifebar tick with mine!
    ;979e to 97b8 - 56 bytes. but we want to leave 97b8
    org $979e
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
    jmp $e4000.l
;chunk

    org $e4000
    move.w  ($1bc,A2), D0
	move.w  ($2a,A2), D1
	tst.b   ($ac5,A5)
	beq     checkVals
	move.w  ($164,A2), D1
checkVals:
    cmp.w   D1, D0                          
	beq     return
    bpl.s   subVal
    addq.w  #1, ($1bc,A2)
    jmp     return  
subVal:    
	subq.w  #1, ($1bc,A2)  
return:                    
	jmp $97b8.l
;chunk
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
