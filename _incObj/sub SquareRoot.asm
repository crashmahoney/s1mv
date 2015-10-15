; (c) 2007 - Gerard Michon
;
; SQRT takes a 31-bit integer (z) from register D3
; and returns the square root (y) and remainder (x)
; in D1 and D0 respectively.  Upon exit, x+y^2 = z :
; D0: 0000 XXXX = Remainder (x)
; D1: 0000 YYYY = Square root (y)
; D2: FFFF FFFF = -1
; D3: ZZZZ ZZZZ = Argument (z) unchanged
;
; BSR SQRT = 752 cycles + twice the count of '1' bits in y.
; Min=752, Max=784 (with 18 cycles for BSR instruction).
;
;                        Time: (in clock cycles)
;

SquareRoot:

        MOVEQ  #0,D0     ;4: Clear x
        MOVEQ  #0,D1     ;4: Clear y
        MOVEQ  #0,D2     ;4: Two 16-bit counters

@AGAIN:  ADDQ.W #7,D2     ;4: Branch 7 times, for 8 loops
        SWAP   D3        ;4: Deal with upper 16 bits first
        MOVE.W D3,D0     ;4: Fetch 16-bit slice

@LOOP:  ROL.L  #2,D0    ;12: Get 2 more radicand bits
        ADD.W  D1,D1     ;4: Shift root one bit
        CMP.W  D1,D0     ;4: OK to set root's new bit?
        BLE    @SKIP     ;10: No, leave 0 bit as is
        ADDQ.W #1,D1     ;2: Time = 4-2 (branch not taken)
@SKIP    DBRA   D2,@LOOP  ;10: Decrement counter (8 times)
                         ;4:
        SWAP   D2        ;4:
        TST.W  D2        ;4: Already been here?
        BEQ    @AGAIN    ;10: No, do second half
        RTS             ;14: Time = 16-2 (branch not taken)
