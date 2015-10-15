; ===========================================================================
LevelChange:
            dc.l Zone00         ;Green Hill
            dc.l Zone01         ;Labyrinth
            dc.l Zone02         ;Marble
            dc.l Zone03         ;Star Light
            dc.l Zone04         ;Scrap Yard
            dc.l Zone05         ;Scrap Brain
            dc.l Zone06         ;Ending
            dc.l Zone07         ;Hub
            dc.l Zone08         ;intro
            dc.l Zone09         ;Tropic
; ===========================================================================
; ---------------------------------------------------------------------------
; Green Hill Zone
; ---------------------------------------------------------------------------
Zone00:
            dc.l Act0000
            dc.l Act0001
            dc.l Act0002
            dc.l Act0003
; ===========================================================================
Act0000:
            dc.l @right
            dc.l @left
            dc.l @top
            dc.l @bottom
            
@right:
      ; exiting on Right side
            dc.w $0002          ; number of exits
         ; exit 1
            dc.w $0000, $1000   ; area you can transition in
            dc.w $0100          ; don't stop music flag
            dc.w $0002, $0000   ; x position, y offset
            dc.w $0300          ; set bottom of level to
                ;bg FE44  bg FE46  bg FE48  bg FE4A  bg FE4C  bg FE4E
            dc.w $0000,   $0000,   $0000,   $0000,   $0000,   $0000
            dc.w $0100          ; level routine to begin at
            dc.w $0001          ; level to jump to
         ; exit 2
            dc.w $0000, $1000   ; area you can transition in
            dc.w $0100          ; don't stop music flag
            dc.w $0002, $0000   ; x position, y offset
            dc.w $0300          ; set bottom of level to
                ;bg FE44  bg FE46  bg FE48  bg FE4A  bg FE4C  bg FE4E
            dc.w $0000,   $0000,   $0000,   $0000,   $0000,   $0000
            dc.w $0100          ; level routine to begin at
            dc.w $0002          ; level to jump to

@left:
      ; exiting on left side
            dc.b $0000          ; number of exits
         ; exit 1
            dc.w $0000, $1000   ; area you can transition in
            dc.w $00            ; don't stop music flag
            dc.w $0060, $0000   ; x position, y offset
            dc.w $0400          ; set bottom of level to
                ;bg FE44  bg FE46  bg FE48  bg FE4A  bg FE4C  bg FE4E
            dc.w $0000,   $0000,   $0000,   $0000,   $0000,   $0000
            dc.w $0000          ; level routine to begin at
            dc.w $0900          ; level to jump to

Act0001:
Act0002:
Act0003:
; ===========================================================================

Zone01:
            dc.l Act0100
            dc.l Act0101
            dc.l Act0102
            dc.l Act0103
; ===========================================================================
Act0100:
Act0101:
Act0102:
Act0103:
; ===========================================================================
Zone02:
            dc.l Act0200
            dc.l Act0201
            dc.l Act0202
            dc.l Act0203
; ===========================================================================
Act0200:
Act0201:
Act0202:
Act0203:
; ===========================================================================
Zone03:
            dc.l Act0300
            dc.l Act0301
            dc.l Act0302
            dc.l Act0303
; ===========================================================================
Act0300
Act0301
Act0302
Act0303
; ===========================================================================
Zone04:
            dc.l Act0400
            dc.l Act0401
            dc.l Act0402
            dc.l Act0403
; ===========================================================================
Act0400:
Act0401:
Act0402:
Act0403:
; ===========================================================================
Zone05:
            dc.l Act0500
            dc.l Act0501
            dc.l Act0502
            dc.l Act0503
; ===========================================================================
Act0500:
Act0501:
Act0502:
Act0503:
; ===========================================================================
Zone06:
            dc.l Act0600
            dc.l Act0601
            dc.l Act0602
            dc.l Act0603
; ===========================================================================
Act0600:
Act0601:
Act0602:
Act0603:
; ===========================================================================
Zone07:
            dc.l Act0700
            dc.l Act0701
            dc.l Act0702
            dc.l Act0703
; ===========================================================================
Act0700:
Act0701:
Act0702:
Act0703:
; ===========================================================================
Zone08:
            dc.l Act0800
            dc.l Act0801
            dc.l Act0802
            dc.l Act0803
; ===========================================================================
Act0800:
Act0801:
Act0802:
Act0803:
; ===========================================================================
Zone09:
            dc.l Act0900
            dc.l Act0901
            dc.l Act0902
            dc.l Act0903
; ===========================================================================
Act0900:
Act0901:
Act0902:
Act0903:
; ===========================================================================


