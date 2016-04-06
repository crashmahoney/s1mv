; ===============================================================
; ---------------------------------------------------------------
; Error handling module
; ---------------------------------------------------------------
 
BusError:   jsr ErrorHandler(pc)
        dc.b    "BUS ERROR",0           ; text
        dc.b    1               ; extended stack frame
        even
 
AddressError:   jsr ErrorHandler(pc)
        dc.b    "ADDRESS ERROR",0       ; text
        dc.b    1               ; extended stack frame
        even
 
IllegalInstr:   jsr ErrorHandler(pc)
        dc.b    "ILLEGAL INSTRUCTION",0     ; text
        dc.b    0               ; extended stack frame
        even
 
ZeroDivide: jsr ErrorHandler(pc)
        dc.b    "ZERO DIVIDE",0         ; text
        dc.b    0               ; extended stack frame
        even
 
ChkInstr:   jsr ErrorHandler(pc)
        dc.b    "CHK INSTRUCTION",0         ; text
        dc.b    0               ; extended stack frame
        even
 
TrapvInstr: jsr ErrorHandler(pc)
        dc.b    "TRAPV INSTRUCTION",0       ; text
        dc.b    0               ; extended stack frame
        even
 
PrivilegeViol:  jsr ErrorHandler(pc)
        dc.b    "PRIVILEGE VIOLATION",0     ; text
        dc.b    0               ; extended stack frame
        even
 
Trace:      jsr ErrorHandler(pc)
        dc.b    "TRACE",0           ; text
        dc.b    0               ; extended stack frame
        even
 
Line1010Emu:    jsr ErrorHandler(pc)
        dc.b    "LINE 1010 EMULATOR",0      ; text
        dc.b    0               ; extended stack frame
        even
 
Line1111Emu:    jsr ErrorHandler(pc)
        dc.b    "LINE 1111 EMULATOR",0      ; text
        dc.b    0               ; extended stack frame
        even
 
ErrorExcept:    jsr ErrorHandler(pc)
        dc.b    "ERROR EXCEPTION",0         ; text
        dc.b    0               ; extended stack frame
        even
 
ErrorHandler:   incbin  "_debug_vlad\ErrorHandler.bin"