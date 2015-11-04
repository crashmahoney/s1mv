; ---------------------------------------------------------------------------
; Animation script - Sonic
; ---------------------------------------------------------------------------
Ani_Sonic:

ptr_Walk:	dc.w SonAni_Walk-Ani_Sonic
ptr_Run:	dc.w SonAni_Run-Ani_Sonic
ptr_Roll:	dc.w SonAni_Roll-Ani_Sonic
ptr_Roll2:	dc.w SonAni_Roll2-Ani_Sonic
ptr_Push:	dc.w SonAni_Push-Ani_Sonic
ptr_Wait:	dc.w SonAni_Wait-Ani_Sonic
ptr_Balance:	dc.w SonAni_Balance-Ani_Sonic
ptr_LookUp:	dc.w SonAni_LookUp-Ani_Sonic
ptr_Duck:	dc.w SonAni_Duck-Ani_Sonic
ptr_Warp1:	dc.w SonAni_Warp1-Ani_Sonic
ptr_Warp2:	dc.w SonAni_Warp2-Ani_Sonic
ptr_Warp3:	dc.w SonAni_Warp3-Ani_Sonic
ptr_Warp4:	dc.w SonAni_Warp4-Ani_Sonic
ptr_Stop:	dc.w SonAni_Stop-Ani_Sonic
ptr_Float1:	dc.w SonAni_Float1-Ani_Sonic
ptr_Float2:	dc.w SonAni_Float2-Ani_Sonic
ptr_Spring:	dc.w SonAni_Spring-Ani_Sonic
ptr_Hang:	dc.w SonAni_Hang-Ani_Sonic
ptr_Leap1:	dc.w SonAni_Leap1-Ani_Sonic
ptr_Leap2:	dc.w SonAni_Leap2-Ani_Sonic
ptr_Surf:	dc.w SonAni_Surf-Ani_Sonic
ptr_GetAir:	dc.w SonAni_GetAir-Ani_Sonic
ptr_Burnt:	dc.w SonAni_Burnt-Ani_Sonic
ptr_Drown:	dc.w SonAni_Drown-Ani_Sonic
ptr_Death:	dc.w SonAni_Death-Ani_Sonic
ptr_Shrink:	dc.w SonAni_Shrink-Ani_Sonic
ptr_Hurt:	dc.w SonAni_Hurt-Ani_Sonic
ptr_WaterSlide:	dc.w SonAni_WaterSlide-Ani_Sonic
ptr_Null:	dc.w SonAni_Null-Ani_Sonic
ptr_Float3:	dc.w SonAni_Float3-Ani_Sonic
ptr_Float4:	dc.w SonAni_Float4-Ani_Sonic

ptr_WallJump:	dc.w SonAni_WallJump-Ani_Sonic
ptr_SpinDash:	dc.w SonAni_SpinDash-Ani_Sonic
ptr_Dash:	dc.w SonAni_Dash-Ani_Sonic
ptr_DashCharge:	dc.w SonAni_DashCharge-Ani_Sonic

ptr_Transform:  dc.w Sonani_Transform-Ani_Sonic
ptr_SupStand:   dc.w Sonani_SupStand-Ani_Sonic
ptr_SupWalk:    dc.w Sonani_SupWalk-Ani_Sonic
ptr_SupRun:     dc.w Sonani_SupRun-Ani_Sonic
ptr_SupPush:    dc.w Sonani_SupPush-Ani_Sonic
ptr_SupDuck:    dc.w Sonani_SupDuck-Ani_Sonic
ptr_SupBalance: dc.w Sonani_SupBalance-Ani_Sonic
ptr_BalanceBack:	dc.w SonAni_BalanceBack-Ani_Sonic
ptr_BalanceFar:	dc.w SonAni_BalanceFar-Ani_Sonic
ptr_Hang3:	dc.w SonAni_Hang3-Ani_Sonic
ptr_Wait2:	dc.w SonAni_Wait2-Ani_Sonic


SonAni_Walk:	dc.b $FF, fr_walk13, fr_walk14,	fr_walk15, fr_walk16, fr_walk11, fr_walk12, afEnd, afEnd, afEnd
		even
SonAni_Run:	dc.b $FF,  fr_run11,  fr_run12,  fr_run13,  fr_run14,     afEnd,     afEnd, afEnd, afEnd, afEnd
		even
SonAni_Roll:	dc.b $FE,  fr_Roll1,  fr_Roll2,  fr_Roll3,  fr_Roll4,  fr_Roll5,     afEnd, afEnd, afEnd, afEnd
		even
SonAni_Roll2:	dc.b $FE,  fr_Roll1,  fr_Roll2,  fr_Roll5,  fr_Roll3,  fr_Roll4,  fr_Roll5, afEnd, afEnd, afEnd
		even
SonAni_Push:	dc.b $FD,  fr_push1,  fr_push2,  fr_push3,  fr_push4,     afEnd,     afEnd, afEnd, afEnd, afEnd
		even
SonAni_Wait:	dc.b $17, fr_stand, fr_stand, fr_stand, fr_stand, fr_stand, fr_stand, fr_stand, fr_stand, fr_stand
		dc.b fr_stand, fr_stand, fr_stand, fr_wait2, fr_wait1, fr_wait1, fr_wait1, fr_wait2, fr_wait3, afBack, 2
		even
SonAni_Wait2:	dc.b $5			; speed
		dc.b fr_stand, fr_stand, fr_stand, fr_stand, fr_stand, fr_stand, fr_stand, fr_stand, fr_stand, fr_stand     ; stand still
		dc.b fr_stand, fr_stand, fr_stand, fr_stand, fr_stand, fr_stand, fr_stand, fr_stand, fr_stand, fr_stand		; stand still
		dc.b fr_stand, fr_stand, fr_stand, fr_stand, fr_stand, fr_stand, fr_stand, fr_stand, fr_stand, fr_stand		; stand still
		dc.b fr_wait21,fr_wait1, fr_wait1, fr_wait1, fr_wait1, fr_wait1												; turn + bulge eyes
		dc.b fr_wait2, fr_wait2, fr_wait2, fr_wait3, fr_wait3, fr_wait3, fr_wait3									; tap
		dc.b fr_wait2, fr_wait2, fr_wait2, fr_wait3, fr_wait3, fr_wait3, fr_wait3									; tap
		dc.b fr_wait2, fr_wait2, fr_wait2, fr_wait3, fr_wait3, fr_wait3, fr_wait3									; tap
		dc.b fr_wait22,fr_wait22,fr_wait22,fr_wait22,fr_wait22,fr_wait22,fr_wait22,fr_wait22,fr_wait22,fr_wait22	; look at watch
		dc.b fr_wait2, fr_wait2, fr_wait2, fr_wait3, fr_wait3, fr_wait3, fr_wait3									; tap
		dc.b fr_wait2, fr_wait2, fr_wait2, fr_wait3, fr_wait3, fr_wait3, fr_wait3									; tap
		dc.b fr_wait2, fr_wait2, fr_wait2, fr_wait3, fr_wait3, fr_wait3, fr_wait3									; tap
		dc.b fr_wait22,fr_wait22,fr_wait22,fr_wait22,fr_wait22,fr_wait22,fr_wait22,fr_wait22,fr_wait22,fr_wait22	; look at watch
		dc.b fr_wait2, fr_wait2, fr_wait2, fr_wait3, fr_wait3, fr_wait3, fr_wait3									; tap
		dc.b fr_wait2, fr_wait2, fr_wait2, fr_wait3, fr_wait3, fr_wait3, fr_wait3									; tap
		dc.b fr_wait2, fr_wait2, fr_wait2, fr_wait3, fr_wait3, fr_wait3, fr_wait3									; tap
		dc.b fr_wait22,fr_wait22,fr_wait22,fr_wait22,fr_wait22,fr_wait22,fr_wait22,fr_wait22,fr_wait22,fr_wait21	; look at watch
		dc.b fr_wait23,fr_wait24,fr_wait24,fr_wait24,fr_wait25,fr_wait25,fr_wait25									; sit down
		dc.b afBack, 6			; loop last 6 frames
		even
SonAni_Balance:	dc.b $1F, fr_balance1, fr_balance2, afEnd
		even
SonAni_BalanceBack:	dc.b $F, fr_BalanceBack1, fr_BalanceBack2, fr_BalanceBack3,fr_BalanceBack4, afEnd
		even
SonAni_BalanceFar:	dc.b $3, fr_BalanceFar1, fr_BalanceFar2, fr_BalanceFar3,fr_BalanceFar4, afEnd
		even
SonAni_LookUp:	dc.b $3F, fr_lookup, afEnd
		even
SonAni_Duck:	dc.b $3F, fr_duck, afEnd
		even
SonAni_Warp1:	dc.b $3F, fr_warp1, afEnd
		even
SonAni_Warp2:	dc.b $3F, fr_warp2, afEnd
		even
SonAni_Warp3:	dc.b $3F, fr_warp3, afEnd
		even
SonAni_Warp4:	dc.b $3F, fr_warp4, afEnd
		even
SonAni_Stop:	dc.b 7,	fr_stop1, fr_stop2, afEnd
		even
SonAni_Float1:	dc.b 7,	fr_float1, fr_float4, afEnd
		even
SonAni_Float2:	dc.b 7,	fr_float1, fr_float2, fr_float5, fr_float3, fr_float6, afEnd
		even
SonAni_Spring:	dc.b $2F, fr_spring, afChange, id_Walk
		even
SonAni_Hang:	dc.b 4,	fr_hang1, fr_hang2, afEnd
		even
SonAni_Hang3:	dc.b $13,fr_Hang3,fr_Hang4,afEnd

SonAni_Leap1:	dc.b $F, fr_leap1, fr_leap1, fr_leap1,	afBack, 1
		even
SonAni_Leap2:	dc.b $F, fr_leap1, fr_leap2, afBack, 1
		even
SonAni_Surf:	dc.b $3F, fr_surf, afEnd
		even
SonAni_GetAir:	dc.b $B, fr_getair, fr_getair, fr_walk15, fr_walk16, afChange, id_Walk
		even
SonAni_Burnt:	dc.b $20, fr_burnt, afEnd
		even
SonAni_Drown:	dc.b $2F, fr_drown, afEnd
		even
SonAni_Death:	dc.b 3,	fr_death, afEnd
		even
SonAni_Shrink:	dc.b 3,	fr_shrink1, fr_shrink2, fr_shrink3, fr_shrink4, fr_shrink5, fr_null, afBack, 1
		even
SonAni_Hurt:	dc.b 3,	fr_injury, afEnd
		even
SonAni_WaterSlide:
		dc.b 7, fr_injury, fr_waterslide, afEnd
		even
SonAni_Null:	dc.b $77, fr_null, afChange, id_Walk
		even
SonAni_Float3:	dc.b 3,	fr_float1, fr_float2, fr_float5, fr_float3, fr_float6, afEnd
		even
SonAni_Float4:	dc.b 3,	fr_float1, afChange, id_Walk
SonAni_WallJump: dc.b 3, fr_WallJump, afEnd
                even
SonAni_SpinDash:	dc.b 0, fr_SpinDash1, fr_SpinDash2, fr_SpinDash1, fr_SpinDash3, fr_SpinDash1, fr_SpinDash4, fr_SpinDash1, fr_SpinDash5, fr_SpinDash1, fr_SpinDash6, afEnd
		even
SonAni_Dash:	dc.b $FF,  fr_dash11,  fr_dash12,  fr_dash13,  fr_dash14,     afEnd,     afEnd, afEnd, afEnd, afEnd
		even
SonAni_DashCharge:	dc.b 0,  fr_walk13, fr_walk13, fr_walk13, fr_walk13, fr_walk13, fr_walk13, fr_walk13, fr_walk13
		dc.b	fr_walk14, fr_walk14, fr_walk14, fr_walk14, fr_walk15, fr_walk15, fr_run14, fr_run14
		dc.b	fr_Run11,  fr_Run12,  fr_Run13,  fr_Run14, fr_Run11,  fr_Run12,  fr_Run13,  fr_Run14
		dc.b	fr_dash11,  fr_dash12,  fr_dash13,  fr_dash14, afBack, 4
		even

SonAni_Transform:       dc.b   2, fr_Transform1, fr_Transform1, fr_Transform2, fr_Transform2, fr_Transform3, fr_Transform4
                        dc.b   fr_Transform5, fr_Transform4, fr_Transform5, fr_Transform4, fr_Transform5, fr_Transform4, fr_Transform5, afChange, id_Walk
                even
SonAni_SupStand:        dc.b   7, fr_stand1, fr_stand2, fr_stand3, fr_stand2, afEnd
                even
SonAni_SupWalk:	        dc.b $FF, fr_SWalk13, fr_Swalk14, fr_Swalk15, fr_Swalk16, fr_Swalk17, fr_Swalk18, fr_Swalk11, fr_Swalk12, afEnd
                even
SonAni_SupRun:		dc.b $FF, fr_SRun1, fr_SRunAlt1, afEnd, afEnd, afEnd, afEnd, afEnd, afEnd, afEnd, afEnd
                even
SonAni_SupPush:		dc.b $FD, fr_SPush1, fr_SPush2, fr_SPush3, fr_SPush4, afEnd, afEnd, afEnd, afEnd, afEnd
                even
SonAni_SupDuck:		dc.b   5, fr_SDuck, afEnd
                even
SonAni_SupBalance:	dc.b   9, fr_SBalance1, fr_SBalance2, fr_SBalance3, fr_SBalance2, fr_SBalance4, fr_SBalance5, fr_SBalance6, fr_SBalance5, afEnd
                even

id_Walk:	equ (ptr_Walk-Ani_Sonic)/2	; 0
id_Run:		equ (ptr_Run-Ani_Sonic)/2	; 1
id_Roll:	equ (ptr_Roll-Ani_Sonic)/2	; 2
id_Roll2:	equ (ptr_Roll2-Ani_Sonic)/2	; 3
id_Push:	equ (ptr_Push-Ani_Sonic)/2	; 4
id_Wait:	equ (ptr_Wait-Ani_Sonic)/2	; 5
id_BalanceForward:	equ (ptr_Balance-Ani_Sonic)/2	; 6
id_LookUp:	equ (ptr_LookUp-Ani_Sonic)/2	; 7
id_Duck:	equ (ptr_Duck-Ani_Sonic)/2	; 8
id_Warp1:	equ (ptr_Warp1-Ani_Sonic)/2	; 9
id_Warp2:	equ (ptr_Warp2-Ani_Sonic)/2	; $A
id_Warp3:	equ (ptr_Warp3-Ani_Sonic)/2	; $B
id_Warp4:	equ (ptr_Warp4-Ani_Sonic)/2	; $C
id_Stop:	equ (ptr_Stop-Ani_Sonic)/2	; $D
id_Float1:	equ (ptr_Float1-Ani_Sonic)/2	; $E
id_Float2:	equ (ptr_Float2-Ani_Sonic)/2	; $F
id_Spring:	equ (ptr_Spring-Ani_Sonic)/2	; $10
id_Hang:	equ (ptr_Hang-Ani_Sonic)/2	; $11
id_Leap1:	equ (ptr_Leap1-Ani_Sonic)/2	; $12
id_Leap2:	equ (ptr_Leap2-Ani_Sonic)/2	; $13
id_Surf:	equ (ptr_Surf-Ani_Sonic)/2	; $14
id_GetAir:	equ (ptr_GetAir-Ani_Sonic)/2	; $15
id_Burnt:	equ (ptr_Burnt-Ani_Sonic)/2	; $16
id_Drown:	equ (ptr_Drown-Ani_Sonic)/2	; $17
id_Death:	equ (ptr_Death-Ani_Sonic)/2	; $18
id_Shrink:	equ (ptr_Shrink-Ani_Sonic)/2	; $19
id_Hurt:	equ (ptr_Hurt-Ani_Sonic)/2	; $1A
id_WaterSlide:	equ (ptr_WaterSlide-Ani_Sonic)/2; $1B
id_Null:	equ (ptr_Null-Ani_Sonic)/2	; $1C
id_Float3:	equ (ptr_Float3-Ani_Sonic)/2	; $1D
id_Float4:	equ (ptr_Float4-Ani_Sonic)/2	; $1E
id_WallJump:	equ (ptr_WallJump-Ani_Sonic)/2  ; $1F
id_SpinDash:	equ (ptr_SpinDash-Ani_Sonic)/2	; $20
id_Dash:	equ (ptr_Dash-Ani_Sonic)/2      ; $21
id_DashCharge:	equ (ptr_DashCharge-Ani_Sonic)/2; $22
id_Transform:	equ (ptr_Transform-Ani_Sonic)/2 ; $23
id_SupStand:	equ (ptr_SupStand-Ani_Sonic)/2  ; $24
id_SupWalk:	equ (ptr_SupWalk-Ani_Sonic)/2   ; $25
id_SupRun:	equ (ptr_SupRun-Ani_Sonic)/2    ; $26
id_SupPush:	equ (ptr_SupPush-Ani_Sonic)/2   ; $27
id_SupDuck:	equ (ptr_SupDuck-Ani_Sonic)/2   ; $28
id_SupBalance:	equ (ptr_SupBalance-Ani_Sonic)/2; $29
id_BalanceBack:	equ (ptr_BalanceBack-Ani_Sonic)/2;$2A
id_BalanceFar:	equ (ptr_BalanceFar-Ani_Sonic)/2 ;$2B
id_Hang3:		equ (ptr_Hang3-Ani_Sonic)/2 ;$2C
id_Wait2:	equ (ptr_Wait2-Ani_Sonic)/2	; 2D
; ===========================================================================
; Super Sonic Animation Set
; ===========================================================================

Ani_SuperSonic:

	dc.w SonAni_SupWalk-Ani_SuperSonic
	dc.w SonAni_SupRun-Ani_SuperSonic
	dc.w SonAni_Roll-Ani_SuperSonic
	dc.w SonAni_Roll2-Ani_SuperSonic
        dc.w Sonani_SupPush-Ani_SuperSonic
	dc.w SonAni_SupStand-Ani_SuperSonic
	dc.w SonAni_SupBalance-Ani_SuperSonic
	dc.w SonAni_LookUp-Ani_SuperSonic
	dc.w SonAni_SupDuck-Ani_SuperSonic
	dc.w SonAni_Warp1-Ani_SuperSonic
	dc.w SonAni_Warp2-Ani_SuperSonic
	dc.w SonAni_Warp3-Ani_SuperSonic
	dc.w SonAni_Warp4-Ani_SuperSonic
	dc.w SonAni_Stop-Ani_SuperSonic
	dc.w SonAni_Float1-Ani_SuperSonic
	dc.w SonAni_Float2-Ani_SuperSonic
	dc.w SonAni_Spring-Ani_SuperSonic
	dc.w SonAni_Hang-Ani_SuperSonic
	dc.w SonAni_Leap1-Ani_SuperSonic
	dc.w SonAni_Leap2-Ani_SuperSonic
	dc.w SonAni_Surf-Ani_SuperSonic
	dc.w SonAni_GetAir-Ani_SuperSonic
	dc.w SonAni_Burnt-Ani_SuperSonic
	dc.w SonAni_Drown-Ani_SuperSonic
	dc.w SonAni_Death-Ani_SuperSonic
	dc.w SonAni_Shrink-Ani_SuperSonic
	dc.w SonAni_Hurt-Ani_SuperSonic
	dc.w SonAni_WaterSlide-Ani_SuperSonic
	dc.w SonAni_Null-Ani_SuperSonic
	dc.w SonAni_Float3-Ani_SuperSonic
	dc.w SonAni_Float4-Ani_SuperSonic

	dc.w SonAni_WallJump-Ani_SuperSonic
	dc.w SonAni_SpinDash-Ani_SuperSonic
	dc.w SonAni_Dash-Ani_SuperSonic
	dc.w SonAni_DashCharge-Ani_SuperSonic

        dc.w Sonani_Transform-Ani_SuperSonic
        dc.w Sonani_SupStand-Ani_SuperSonic
        dc.w Sonani_SupWalk-Ani_SuperSonic
        dc.w Sonani_SupRun-Ani_SuperSonic
        dc.w Sonani_SupPush-Ani_SuperSonic
        dc.w Sonani_SupDuck-Ani_SuperSonic
        dc.w Sonani_SupBalance-Ani_SuperSonic
	dc.w Sonani_SupBalance-Ani_Sonic
        dc.w Sonani_SupBalance-Ani_Sonic
	dc.w SonAni_Hang3-Ani_Sonic
	dc.w SonAni_SupStand-Ani_SuperSonic
