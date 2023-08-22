
; This tests virtually all the features of LEA Macro Assembler's 68000 target CPU.

	fingerprint "36CC7D09D8A3CB3BD98408E73EA1AE245DFA0AA2"

ERROR_TEST equ 0

	if not ERROR_TEST

	print "68000 normal " + "test"

Start:
qwe set 0
	while qwe < 8
	cmp d{qwe}, d{7-qwe}
	cmp d{qwe}, a{qwe}
	cmp #{qwe}, d{qwe}
	cmp (a{qwe})+, (a{(qwe + 4) & 7})+
qwe set qwe + 1
	endw

	repeat 8
	add  #??,d{7-?}
	addi #??,d{7-?}
	sub  #??,d{7-?}
	subi #??,d{7-?}
	and  #??,d{7-?}
	andi #??,d{7-?}
	or   #??,d{7-?}
	ori  #??,d{7-?}
	eor  #??,d{7-?}
	eori #??,d{7-?}
	endr

	move.w #$1234, sr
	move   #$1234, sr
	move.w #$1234, ccr
	move   #$1234, ccr
	andi.w #$1234, sr
	andi   #$1234, sr
	andi.b #$12, ccr
	andi   #$34, ccr
	and.w  #$1234, sr
	or.w   #$1234, sr
	eor.w  #$1234, sr
	and    #$1234, sr
	or     #$1234, sr
	eor    #$1234, sr
	and.b  #$12, ccr
	or.b   #$34, ccr
	eor.b  #$56, ccr
	and    #$12, ccr
	or     #$34, ccr
	eor    #$56, ccr

AddSub Macro op
.\@	\op #123, d0
	\op #1234, a0
	\op d0, d1
	\op d2, a0
	\op d3, $12345
	\op #123, $12345
	\op a0, d3
	\op a0, a0
	\op 10(a0), d4
	\op d5, 10(a0)
	\op .\@(a0), d6
	\op .\@(pc,d7), d0
	\op $1234, d1
	\op $12345678, d2
	Endm

	rsset 10
Betty	rs 1

Logic Macro op
.\@
	\op #123, d0
	\op d1, d2
	\op Betty(a0), d3
	\op d4, Betty(a0)
	\op .\@(a0), d5
	\op .\@(pc,d6), d7
	\op (($1234)), d3
	\op ( ( ( $12345678 ) ) ) , d4
	Endm

_AddSub:
	AddSub add
	AddSub sub

	addx d0, d1
	subx d2, d3
	addx -(a1), -(a2)
	subx -(a3), -(a4)

_Logic:
	Logic and
	Logic or
	eor #123, d7
	eor d1, d2
	eor d3, 10(a0)
	eor d4, $1234
	eor d5, $12345678

	repeat 8
	and d?, d{7-?}
	or  d?, d{7-?}
	eor d?, d{7-?}
	endr

_Exg:
	repeat 8
	exg d?, d?
	exg a?, d?
	exg d?, a?
	exg a?, a?
	endr

_Bcc:
	bsr.s .L1
	bhi.s .L2
	bls.s .L3
	bcc.s .L4
	bcs.s .L5
	bne.s .L6
	beq.s .L7
	bvc.s .L8
	bvs.s .L9
	bpl.s .LA
	bmi.s .LB
	bge.s .LC
	blt.s .LD
	bgt.s .LE
	ble.s .LF
	bra F
.L1	bsr.w .L1
.L2	bhi.w .L2
.L3	bls.w .L3
.L4	bcc.w .L4
.L5	bcs.w .L5
.L6	bne.w .L6
.L7	beq.w .L7
.L8	bvc.w .L8
.L9	bvs.w .L9
.LA	bpl.w .LA
.LB	bmi.w .LB
.LC	bge.w .LC
.LD	blt.w .LD
.LE	bgt.w .LE
.LF	ble.w .LF
.LG	bra.w F
	bsr .L1
	bhi .L2
	bls .L3
	bcc .L4
	bcs .L5
	bne .L6
	beq .L7
	bvc .L8
	bvs .L9
	bpl .LA
	bmi .LB
	bge .LC
	blt .LD
	bgt .LE
	ble .LF
	bra F

_Dbcc:

.L0	dbt  d0, .L0
.L1	dbf  d1, .L1
.L2	dbhi d2, .L2
.L3	dbls d3, .L3
.L4	dbcc d4, .L4
.L5	dbcs d5, .L5
.L6	dbne d6, .L6
.L7	dbeq d7, .L7
.L8	dbvc d0, .L8
.L9	dbvs d1, .L9
.LA	dbpl d2, .LA
.LB	dbmi d3, .LB
.LC	dbge d4, .LC
.LD	dblt d5, .LD
.LE	dbgt d6, .LE
.LF	dble d7, .LF
.LG	dbra d7, F
	dbra d7, $8040
F:
	st  d0
	sf  (a0)
	shi (a0)+
	sls -(a0)
	scc 0(a0)
	scs 0(a0,d0)
	sne $1234
	seq $12345678
	svc d0
	svs (a0)
	spl (a0)+
	smi -(a0)
	sge 0(a0)
	slt 0(a0,d0)
	sgt $1234
	sle $12345678

	repeat 8
	swap d?
	ext.w d?
	ext.l d?
	endr

	repeat 8
	abcd d?, d{7-?}
	abcd -(a?), -(a{7-?})
	sbcd d{7-?}, d?
	sbcd -(a{7-?}), -(a?)
	endr

	repeat 8
	addq.b #?+1, d?
	addq.w #?+1, a?
	addq.l #?+1, (a?)
	addq #?+1, (a?)+
	addq #?+1, -(a?)
	addq #?+1, 0(a?)
	addq #?+1, 0(a?,d?)
	addq.b #?+1, $1234
	addq.w #?+1, $12345678
	subq.l #?+1, d?
	subq #?+1, a?
	subq #?+1, (a?)
	subq #?+1, (a?)+
	subq.b #?+1, -(a?)
	subq.w #?+1, 0(a?)
	subq.l #?+1, 0(a?,d?)
	subq #?+1, $1234
	subq #?+1, $12345678
	endr

_Nbcd:
	repeat 8
	nbcd d?
	nbcd (a?)
	nbcd (a?)+
	nbcd -(a?)
.L?	nbcd x(a?)
	nbcd y(a?,d?)
	nbcd $1234
	nbcd $12345678
	endr

_Tas:
	repeat 8
	tas d?
	tas (a?)
	tas (a?)+
	tas -(a?)
.L?	tas x(a?)
	tas y(a?,d?)
	tas $1234
	tas $12345678
	endr

_Jsr:
	repeat 8
	jsr (a?)
	jsr ?*2(a?)
.L?	jsr x(a?)
	jsr y(a?,d?)
	jsr .L4(pc,d?)
	jsr $1234
	jsr $12345678
	endr

_Jmp:
	repeat 8
	jmp (a?)
	jmp ?*2(a?)
.L?	jmp x(a?)
	jmp y(a?,d?)
	jmp .L4(pc,d?)
	jmp $1234
	jmp $12345678
	endr

_AmSize:

	repeat 8
	tst.b (a?)
	tst (a?)+
	tst.w -(a?)
	tst ?*2(a?)
	tst.l x(a?)
	tst y(a?,d?)
	tst $1234
	tst.l $12345678
	endr

	repeat 8
	negx.b (a?)
	negx (a?)+
	negx.w -(a?)
	negx ?*2(a?)
	negx.l x(a?)
	negx y(a?,d?)
	negx $1234
	negx.l $12345678
	endr

	repeat 8
	clr.b (a?)
	clr (a?)+
	clr.w -(a?)
	clr ?*2(a?)
	clr.l x(a?)
	clr y(a?,d?)
	clr $1234
	clr.l $12345678
	endr

	repeat 8
	neg.b (a?)
	neg (a?)+
	neg.w -(a?)
	neg ?*2(a?)
	neg.l x(a?)
	neg y(a?,d?)
	neg $1234
	neg.l $12345678
	endr

	repeat 8
	not.b (a?)
	not (a?)+
	not.w -(a?)
	not ?*2(a?)
	not.l x(a?)
	not y(a?,d?)
	not $1234
	not.l $12345678
	endr

_Pea:
	repeat 8
	pea (a?)
	pea 0(a?)
	pea _Pea+2(a?)
	pea ?(a?,d{7-?})
.L?	pea .L4(pc,d?)
	pea $????
	pea $????????
	endr

_Lea:
	repeat 8
	lea $1234, a?
	lea $12345678, a{7-?}
	lea (a{7-?}), a0
	lea.l _Lea(a4), a5
	lea x(a{7-?}), sp
	lea y(a{7-?}), a5
	lea 0(a?,d?), a{7-?}
.L?	lea .L?(pc,d{7-?}), a{7-?}
	endr

Rot	equ 0
	asl #8, d0
	lsl #2, d0
	roxl #3, d0
	rol #4, d0
	asr.l d0, d1
	lsr.b d2, d3
	roxr d4, d5
	ror d6, d7
	asl (a0)+
	lsl -(a1)
	roxl (a2)
	ror (a2)
	ror Rot(a2)
	ror x(a2)
	ror y(a2)
	ror xx(a2)
	asl -4567(a2)
	lsr $12345678

_Maths:
	repeat 8
.L?	mulu #?, d{7-?}
	mulu d?, d?
	mulu ?(a?,d?), d{7-?}
	muls ?(a?,d?), d{7-?}
	divu ?(a?,d?), d{7-?}
	divs .L?(pc,d?.l), d{7-?}
	mulu $80000000, d?
	chk ?(a?,d?), d{7-?}
	endr

_Link:
	repeat 8
	link a?, #?
	unlk a?
	endr

	repeat 8
	btst d?, d{7-?}
	bchg d?, d{7-?}
	bclr d?, d{7-?}
	bset d?, d{7-?}
	btst #?, d?
	bchg #?, d?
	bclr #?, d?
	btst #?, d?
	btst #?, ?(a?, d?)
	btst #?, ?(a?, d?.w)
	btst #?, ?(a?, d?.l)
	endr

	btst.b #1, (a0)
	btst   #1, (a0)
	btst.b d0, (a0)
	btst   d0, (a0)
	btst.l #1, d0
	btst   #1, d0
	btst.l d0, d1
	btst   d0, d1

	repeat 8
	movem d?/a?, @?????????
	movem.l d?-d{7-?}/d{?/2}/a{(?+1)&7}, -(sp)
	endr

	repeat 8
	moveq #?, d?
	endr

	repeat 8
	move a?, usp
	move.l usp, a?
	endr

	movep d7, xx(a1)
	movep (a2), d6
	movep.w d5, 22(a3)
	movep.w 18(a4), d4
	movep.l d3, 22(a5)
	movep.l 18(a6), d2

xx set 22

	nop
	rte
	rts
	rtr
	trapv
	reset
	illegal
	stop #$2700

	repeat 16
	trap #?
	endr

M1	macro reg
	repeat 16
	move #(_REPCNT - 8) * 4096, d\reg
	endr
	endm

	repeat 8
	M1 ?
	endr

	repeat 8
	move _REPCNT(a?), d?
	move _REPCNT(a?, d?), d?
	move _REPCNT(a?, d?.w), d?
	move _REPCNT(a?, d?.l), d?
	move _REPCNT, _REPCNT*16
	move _REPCNT.l, _REPCNT*16.w
	endr

	move  (a1),  (a2)
	move x(a1), x(a2)
x set 0
y set 2
	move  (a1),  (a2)
	move x(a1), x(a2)
	move x(pc), x(a3)

	move d0,  (a1)
	move d0, x(a1)
	move d0, y(a1)
	move d0, (x, a1)
	move d0, (y, a1)
	move  (a1), d0
	move x(a1), d0
	move y(a1), d0

M2	macro s
	move.\s (a?), d?
	move.\s (a?), (a?)
	move.\s -(a?), d?
	move.\s (a?)+, -(a?)
	move.\s -(a?), (a?)+
	move.\s d?, -(a?)
	move.\s d?, (a?)+
	endm

	repeat 8
	M2 b
	M2 w
	M2 l
	endr

	repeat 8
	move #?<<6, ccr
	move #?<<8, sr
	move sr, d?
	move ((? + ? * ?) << ? < (? / 2))(a?, d?), d?
	endr

	move.l #Dog, d0
Dog set 2
	move.l #Dog, d0

	add.b #1, d0
	add.w #1, d0
	add.l #1, d0
	addq.b #1, d0
	addq.w #1, d0
	addq.l #1, d0

	move.b #1, d0
	move.w #1, d0
	move.l #1, d0

	move.l #-129, d0
	move.l #-128, d0
	move.l #127, d0
	move.l #128, d0

	org $10000

abc:
	dc.b 25, 26, 27
	dc.w 25, 26, 27
	dc.l abc, def, $12345678

def:
	dcb.b 3, 123
	dcb.w 3, 123
	dcb.l 3, 123

sz	set 1 = 1
sz	set 1 = 2
sz	set "Fruit" = "Fruit"
sz	set "Fruit" = "Groost"
sz	set "Fruit" <> "Groost"
sz	set "Fruit" < "Groost"
sz	set "Fruit" > "Groost"
sz	set "Fruit" <= "Groost"
sz	set "Fruit" >= "Groost"

	if "goodbye" = "hello"
	nop
	endif

asc set ''
asc	set	'''?''''' ; '?''
asc set '"?""'    ; "?""
asc set '''AB?'   ; 'AB?
asc set 'A''?C'   ; A'?C
asc set 'A?''C'   ; A?'C
asc set 'ABC'''   ; ABC'

fr	set 'Frut'

	repeat 4
	move.l #'?', d? ; ?
	endr

	moveq.l #'''', d0
	moveq.l #'"', d0

	dc.b "He;loo" ; Test comment.
	dc.b 'Hel;oo' ; Test comment.

adsb macro
	if ("\0" <> ".b") and ("\0" <> ".w") and ("\0" <> ".l")
		nop
	else
		if \1 <> 0
			add\0 #1, d0
		else
			sub\0 #1, d0
		endif
	endif
	endm

	adsb.b 0
	adsb.l 1
	adsb.moon 2

	org 0

	else

; Error tests

	print "68000 Error test"

sz	set "Bat"
sz	set "Fruit" = 0

d0:
	add d0, sr
	add d0, usp
	add d0, ccr
	addx a0, a1
	addx (a0)+, (a1)+
	addq #10, d0
	asl #0, d0
	asl #9, d1
	asl (pc)
	asl d0
	bra d0
	bra nowhere
	bra.l 0
	btst.l #1, (a0)
	btst.l d0, (a0)
	btst.b #1, d0
	btst.b d0, d1
	cmpi d0, d0
	cmpa d0, d0
	cmpm d0, d0
	cmp -(a0), -(a0)
	ext (pc)
	jmp d0
	lea 0(a0), sr
	lea a0, d0
	lea No(a0), a0
	lea No(a0), a0
	link #1, a6
	link d7, #1
	lsr #10,d0
	move
	move =9, d0
	move 1000.b, d0
	move d0
	move d0, (pc)
	move #0/0, d0
	move.b #4, ccr
	move.b d0, a4
	move.p d0, d1
	movem.b d0-d7, -(sp)
	movep a0, d0
	moveq #1, a0
	moveq #1/0, d0
	moveq #1%0, d0
	moveq #1000, d0
	moveq #qwerty, d0
	moveq.b #0, d0
	negx (pc)
	pea d5
	rol.l a0, d0
	scc (pc)
	stop #100000
	stop #nothing
	stop d0
	subq #10, d0
	tas (pc)
	trap #10/0
	trap #1000
	trap #nothing
	unlk d6
ends:
	endif
