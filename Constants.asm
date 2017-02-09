; ---------------------------------------------------------------------------
; Constants
; ---------------------------------------------------------------------------
; VDP addressses
vdp_data_port:		equ $C00000
vdp_control_port:	equ $C00004
vdp_counter:		equ $C00008
psg_input:		equ $C00011

; VRAM data
vram_fg:	equ $C000	; foreground namespace
vram_bg:	equ $E000	; background namespace
vram_sonic:	equ $F000	; Sonic graphics
vram_sprites:	equ $F800	; sprite table
vram_hscroll:	equ $FC00	; horizontal scroll table

; Game modes
id_Sega:	equ ptr_GM_Sega-GameModeArray	; $00
id_Title:	equ ptr_GM_Title-GameModeArray	; $04
id_Demo:	equ ptr_GM_Demo-GameModeArray	; $08
id_Level:	equ ptr_GM_Level-GameModeArray	; $0C
id_Special:	equ ptr_GM_Special-GameModeArray; $10
id_Continue:	equ ptr_GM_Cont-GameModeArray	; $14
id_Ending:	equ ptr_GM_Ending-GameModeArray	; $18
id_Credits:	equ ptr_GM_Credits-GameModeArray; $1C
id_SSRG:	equ ptr_GM_SSRG-GameModeArray   ; $20

; Levels
id_GHZ:		equ 0
id_LZ:		equ 1
id_MZ:		equ 2
id_SLZ:		equ 3
id_SYZ:		equ 4
id_SBZ:		equ 5
id_EndZ:	equ 6
id_HUBZ:        equ 7
id_Intro:       equ 8
id_Tropic:      equ 9

; Colours
cBlack:		equ $000		; colour black
cWhite:		equ $EEE		; colour white
cBlue:		equ $E00		; colour blue
cGreen:		equ $0E0		; colour green
cRed:		equ $00E		; colour red
cYellow:	equ cGreen+cRed		; colour yellow
cAqua:		equ cGreen+cBlue	; colour aqua
cMagenta:	equ cBlue+cRed		; colour magenta

; Joypad input
btnStart:	equ %10000000 ; Start button	($80)
btnA:		equ %01000000 ; A		($40)
btnB:		equ %00010000 ; B		($10)
btnC:		equ %00100000 ; C		($20)
btnR:		equ %00001000 ; Right		($08)
btnL:		equ %00000100 ; Left		($04)
btnDn:		equ %00000010 ; Down		($02)
btnUp:		equ %00000001 ; Up		($01)
btnDir:		equ %00001111 ; Any direction	($0F)
btnABC:		equ %01110000 ; A, B or C	($70)
btnAB:          equ %01010000 ; +++ A or B
btnAC:          equ %01100000 ; +++ A or C
btnNone:        equ %00000000 ; +++ nothing
btnABCStart     equ %11110000 ; +++ A B C or start
bitStart:	equ 7
bitA:		equ 6
bitC:		equ 5
bitB:		equ 4
bitR:		equ 3
bitL:		equ 2
bitDn:		equ 1
bitUp:		equ 0


	rsset 0
JbU		rs.b 1	; bit Up
JbD		rs.b 1	; bit Down
JbL		rs.b 1	; bit Left
JbR		rs.b 1	; bit Right
JbB		rs.b 1	; bit B
JbC		rs.b 1	; bit C
JbA		rs.b 1	; bit A
JbS		rs.b 1	; bit Start
JbZ		rs.b 1	; bit Z
JbY		rs.b 1	; bit Y
JbX		rs.b 1	; bit X
JbM		rs.b 1	; bit Mode

J_U =	(1<<JbU)	; Up
J_D =	(1<<JbD)	; Down
J_L =	(1<<JbL)	; Left
J_R =	(1<<JbR)	; Right
J_P =	J_U|J_D|J_L|J_R	; UDLR
J_B =	(1<<JbB)	; B
J_C =	(1<<JbC)	; C
J_A =	(1<<JbA)	; A
J_ABC =	J_A|J_B|J_C	; ABC
J_S =	(1<<JbS)	; Start
J_Z =	(1<<JbZ)	; Z
J_Y =	(1<<JbY)	; Y
J_X =	(1<<JbX)	; X
J_XYZ =	J_X|J_Y|J_Z	; XYZ
J_M =	(1<<JbM)	; Mode

CTRLbTH =	6		; TH pin bit
CTRLbTR =	5		; TR pin bit
CTRLbTL =	4		; TL pin bit
CTRL_TH =	1<<CTRLbTH	; TH pin
CTRL_TR =	1<<CTRLbTR	; TR pin
CTRL_TL =	1<<CTRLbTL	; TL pin

; Object variables
obRender:	equ 1	; bitfield for x/y flip, display mode
obGfx:		equ 2	; palette line & VRAM setting (2 bytes)
obMap:		equ 4	; mappings address (4 bytes)
obX:		equ 8	; x-axis position (2-4 bytes)
obScreenY:	equ $A	; y-axis position for screen-fixed items (2 bytes)
obY:		equ $C	; y-axis position (2-4 bytes)
obVelX:		equ $10	; x-axis velocity (2 bytes)
obVelY:		equ $12	; y-axis velocity (2 bytes)
obRespawnNo:	equ $14	; respawn list index number (2 bytes)   (was $23)
obWidth:	equ $16	; width/2
obHeight:	equ $17	; height/2
obPriority:	equ $18	; sprite stack priority -- 0 is front  (2 bytes(was 1 originally))
obFrame:	equ $1A	; current frame displayed
obAniFrame:	equ $1B	; current frame in animation script
obAnim:		equ $1C	; current animation
obNextAni:	equ $1D	; next animation
obTimeFrame:	equ $1E	; time to next frame
obDelayAni:	equ $1F	; time to delay animation
obInertia:	equ $20	; potential speed (2 bytes) (was $14, only used by Sonic)
obColType:	equ $20	; collision response type   (not used by Sonic)
obColProp:	equ $21	; collision extra property      "       "
obStatus:	equ $22	; orientation or mode
obActWid:	equ $23	; action width		(was $19)
obRoutine:	equ $24	; routine number
ob2ndRout:	equ $25	; secondary routine number
obAngle:	equ $26	; angle
obSubtype:	equ $28	; object subtype
obSolid:	equ ob2ndRout ; solid status flag


; ---------------------------------------------------------------------------
; when childsprites are activated (i.e. bit #6 of render_flags set)
mainspr_mapframe	= $B
mainspr_width		= $E
mainspr_childsprites 	= $F	; amount of child sprites
mainspr_height		= $14
sub2_x_pos		= $10	;x_vel
sub2_y_pos		= $12	;y_vel
sub2_mapframe		= $15
sub3_x_pos		= $16	;y_radius
sub3_y_pos		= $18	;priority
sub3_mapframe		= $1B	;anim_frame
sub4_x_pos		= $1C	;anim
sub4_y_pos		= $1E	;anim_frame_duration
sub4_mapframe		= $21	;collision_property
sub5_x_pos		= $22	;status
sub5_y_pos		= $24	;routine
sub5_mapframe		= $27
sub6_x_pos		= $28	;subtype
sub6_y_pos		= $2A
sub6_mapframe		= $2D
sub7_x_pos		= $2E
sub7_y_pos		= $30
sub7_mapframe		= $33
sub8_x_pos		= $34
sub8_y_pos		= $36
sub8_mapframe		= $39
sub9_x_pos		= $3A
sub9_y_pos		= $3C
sub9_mapframe		= $3F
next_subspr		= $6


; unknown object offsets
objoff_28	= $28
objoff_2b	= $2B
objoff_2C	= $2C
objoff_2E	= $2E
objoff_2F	= $2F
objoff_30	= $30
objoff_32	= $32
objoff_33	= $33
objoff_34	= $34
objoff_36	= $36
objoff_38	= $38
objoff_3a	= $3A
objoff_3b	= $3B
objoff_3C	= $3C
objoff_3E	= $3E
objoff_3f	= $3F


; Animation flags
afEnd:		equ $FF	; return to beginning of animation
afBack:		equ $FE	; go back (specified number) bytes
afChange:	equ $FD	; run specified animation
afRoutine:	equ $FC	; increment routine counter
afReset:	equ $FB	; reset animation and 2nd object routine counter
af2ndRoutine:	equ $FA	; increment 2nd routine counter


      if z80SoundDriver=0
; Background music
bgm_GHZ:	equ ((ptr_mus81-MusicIndex)/4)+$81
bgm_LZ:		equ ((ptr_mus82-MusicIndex)/4)+$81
bgm_MZ:		equ ((ptr_mus83-MusicIndex)/4)+$81
bgm_SLZ:	equ ((ptr_mus84-MusicIndex)/4)+$81
bgm_SYZ:	equ ((ptr_mus85-MusicIndex)/4)+$81
bgm_SBZ:	equ ((ptr_mus86-MusicIndex)/4)+$81
bgm_HUBZ:	equ ((ptr_mus82-MusicIndex)/4)+$81
bgm_IntroZ:	equ ((ptr_mus83-MusicIndex)/4)+$81
bgm_Tropic:	equ ((ptr_mus81-MusicIndex)/4)+$81
bgm_Invincible:	equ ((ptr_mus87-MusicIndex)/4)+$81
bgm_ExtraLife:	equ ((ptr_mus88-MusicIndex)/4)+$81
bgm_SS:		equ ((ptr_mus89-MusicIndex)/4)+$81
bgm_Title:	equ ((ptr_mus8A-MusicIndex)/4)+$81
bgm_Ending:	equ ((ptr_mus8B-MusicIndex)/4)+$81
bgm_Boss:	equ ((ptr_mus8C-MusicIndex)/4)+$81
bgm_FZ:		equ ((ptr_mus8D-MusicIndex)/4)+$81
bgm_GotThrough:	equ ((ptr_mus8E-MusicIndex)/4)+$81
bgm_GameOver:	equ ((ptr_mus8F-MusicIndex)/4)+$81
bgm_Continue:	equ ((ptr_mus90-MusicIndex)/4)+$81
bgm_Credits:	equ ((ptr_mus91-MusicIndex)/4)+$81
bgm_Drowning:	equ ((ptr_mus92-MusicIndex)/4)+$81
bgm_Emerald:	equ ((ptr_mus93-MusicIndex)/4)+$81
bgm_LevelSelect:equ ((ptr_musE6-MusicIndex_E5plus)/4)+$E5
bgm_SuperSonic:	equ ((ptr_musEF-MusicIndex_E5plus)/4)+$E5

; Sound effects
sfx_Jump:	equ ((ptr_sndA0-SoundIndex)/4)+$A0
sfx_Lamppost:	equ ((ptr_sndA1-SoundIndex)/4)+$A0
sfx_A2:		equ ((ptr_sndA2-SoundIndex)/4)+$A0
sfx_Death:	equ ((ptr_sndA3-SoundIndex)/4)+$A0
sfx_Skid:	equ ((ptr_sndA4-SoundIndex)/4)+$A0
sfx_A5:		equ ((ptr_sndA5-SoundIndex)/4)+$A0
sfx_HitSpikes:	equ ((ptr_sndA6-SoundIndex)/4)+$A0
sfx_Push:	equ ((ptr_sndA7-SoundIndex)/4)+$A0
sfx_SSGoal:	equ ((ptr_sndA8-SoundIndex)/4)+$A0
sfx_SSItem:	equ ((ptr_sndA9-SoundIndex)/4)+$A0
sfx_Splash:	equ ((ptr_sndAA-SoundIndex)/4)+$A0
sfx_AB:		equ ((ptr_sndAB-SoundIndex)/4)+$A0
sfx_HitBoss:	equ ((ptr_sndAC-SoundIndex)/4)+$A0
sfx_Bubble:	equ ((ptr_sndAD-SoundIndex)/4)+$A0
sfx_Fireball:	equ ((ptr_sndAE-SoundIndex)/4)+$A0
sfx_Shield:	equ ((ptr_sndAF-SoundIndex)/4)+$A0
sfx_Saw:	equ ((ptr_sndB0-SoundIndex)/4)+$A0
sfx_Electric:	equ ((ptr_sndB1-SoundIndex)/4)+$A0
sfx_Drown:	equ ((ptr_sndB2-SoundIndex)/4)+$A0
sfx_Flamethrower:equ ((ptr_sndB3-SoundIndex)/4)+$A0
sfx_Bumper:	equ ((ptr_sndB4-SoundIndex)/4)+$A0
sfx_Ring:	equ ((ptr_sndB5-SoundIndex)/4)+$A0
sfx_SpikesMove:	equ ((ptr_sndB6-SoundIndex)/4)+$A0
sfx_Rumbling:	equ ((ptr_sndB7-SoundIndex)/4)+$A0
sfx_B8:		equ ((ptr_sndB8-SoundIndex)/4)+$A0
sfx_Collapse:	equ ((ptr_sndB9-SoundIndex)/4)+$A0
sfx_SSGlass:	equ ((ptr_sndBA-SoundIndex)/4)+$A0
sfx_Door:	equ ((ptr_sndBB-SoundIndex)/4)+$A0
sfx_Teleport:	equ ((ptr_sndBC-SoundIndex)/4)+$A0
sfx_ChainStomp:	equ ((ptr_sndBD-SoundIndex)/4)+$A0
sfx_Roll:	equ ((ptr_sndBE-SoundIndex)/4)+$A0
sfx_Continue:	equ ((ptr_sndBF-SoundIndex)/4)+$A0
sfx_Basaran:	equ ((ptr_sndC0-SoundIndex)/4)+$A0
sfx_BreakItem:	equ ((ptr_sndC1-SoundIndex)/4)+$A0
sfx_Warning:	equ ((ptr_sndC2-SoundIndex)/4)+$A0
sfx_GiantRing:	equ ((ptr_sndC3-SoundIndex)/4)+$A0
sfx_Bomb:	equ ((ptr_sndC4-SoundIndex)/4)+$A0
sfx_Cash:	equ ((ptr_sndC5-SoundIndex)/4)+$A0
sfx_RingLoss:	equ ((ptr_sndC6-SoundIndex)/4)+$A0
sfx_ChainRise:	equ ((ptr_sndC7-SoundIndex)/4)+$A0
sfx_Burning:	equ ((ptr_sndC8-SoundIndex)/4)+$A0
sfx_Bonus:	equ ((ptr_sndC9-SoundIndex)/4)+$A0
sfx_EnterSS:	equ ((ptr_sndCA-SoundIndex)/4)+$A0
sfx_WallSmash:	equ ((ptr_sndCB-SoundIndex)/4)+$A0
sfx_Spring:	equ ((ptr_sndCC-SoundIndex)/4)+$A0
sfx_Switch:	equ ((ptr_sndCD-SoundIndex)/4)+$A0
sfx_RingLeft:	equ ((ptr_sndCE-SoundIndex)/4)+$A0
sfx_Signpost:	equ ((ptr_sndCF-SoundIndex)/4)+$A0
sfx_Waterfall:	equ ((ptr_sndD0-SoundIndex)/4)+$A0
sfx_SpinDash:	equ $D2 ;((ptr_sndD1-SoundIndex)/4)+$A0
sfx_WaterRunning:	equ $D3
sfx_Dash        equ $BC
sfx_LightDash        equ $BC
sfx_SpeedBoost	equ $4E


; Special Sounds
musFadeOut      equ $E0
musStop         equ $E4
musSegaSound    equ $E1

         else

; Background music
bgm_GHZ:	equ $01
bgm_LZ:		equ $20
bgm_MZ:		equ $02
bgm_SLZ:	equ $23
bgm_SYZ:	equ $03
bgm_SBZ:	equ $17
bgm_HUBZ:	equ $21
bgm_IntroZ:	equ $25
bgm_Tropic:	equ $30
bgm_Invincible:	equ $2C
bgm_ExtraLife:	equ $2A
bgm_SS:		equ $1C
bgm_Title:	equ $25
bgm_Ending:	equ $32
bgm_Boss:	equ $19
bgm_FZ:		equ $1A
bgm_GotThrough:	equ $29
bgm_GameOver:	equ $27
bgm_Continue:	equ $28
bgm_Credits:	equ $26
bgm_Drowning:	equ $31
bgm_Emerald:	equ $2B
bgm_LevelSelect:equ $2F
bgm_SuperSonic:	equ $2C

; Sound effects
sfx_Jump:	equ $62
sfx_Lamppost:	equ $63
sfx_A2:		equ $A2
sfx_Death:	equ $35
sfx_Skid:	equ $36
sfx_A5:		equ $A5                              ;A5
sfx_HitSpikes:	equ $37
sfx_Push:	equ $69
sfx_SSGoal:	equ $6A
sfx_SSItem:	equ $6B
sfx_Splash:	equ $39                              ;AA
sfx_AB:		equ $AB
sfx_HitBoss:	equ $6E
sfx_Bubble:	equ $38
sfx_Fireball:	equ $70
sfx_Shield:	equ $3A
sfx_Saw:	equ $D8                              ;B0
sfx_Electric:	equ $79
sfx_Drown:	equ $3B
sfx_Flamethrower:equ $48
sfx_Bumper:	equ $AA
sfx_Ring:	equ $33
sfx_SpikesMove:	equ $52
sfx_Rumbling:	equ $6F
sfx_B8:		equ $35
sfx_Collapse:	equ $59
sfx_SSGlass:	equ $B5
sfx_Door:	equ $58
sfx_Teleport:	equ $73
sfx_ChainStomp:	equ $5F
sfx_Roll:	equ $3C                              ;BE
sfx_Continue:	equ $AC
sfx_Basaran:	equ $A6
sfx_BreakItem:	equ $3D
sfx_Warning:	equ $A9
sfx_GiantRing:	equ $B3
sfx_Bomb:	equ $5F
sfx_Cash:	equ $B0
sfx_RingLoss:	equ $B9
sfx_ChainRise:	equ $55
sfx_Burning:	equ $43
sfx_Bonus:	equ $35
sfx_EnterSS:	equ $AF
sfx_WallSmash:	equ $59
sfx_Spring:	equ $B1
sfx_Switch:	equ $5B
sfx_RingLeft:	equ $34
sfx_Signpost:	equ $35
sfx_Waterfall:	equ $BC
sfx_LightDash   equ $4E
sfx_SpinDash:	equ $AB ;((ptr_sndD1-SoundIndex)/4)+$A0
sfx_WaterRunning:	equ $BC
sfx_Dash        equ $B6
sfx_SpeedBoost	equ $4E
sfx_Leaf		equ $52 ; 8D
sfx_GrabOn		equ $4A
sfx_ThrownOff	equ $8C

; Special Sounds
musFadeOut      equ $E1
musStop         equ $E0
musSegaSound    equ $FF

          endif


; Pause Menu Constants
Level_Select_PauseMenu_snd   equ $0081
;Emerald_Snd     equ $0093
;Ring_Snd        equ $00B5
;Volume_Down     equ $00E0
;Stop_Sound      equ $00E4
FontLocation    equ  $0000 ;$0560

; Offsets of data within each inventory item
InvNameOffset   equ $4
InvSIconOffset   equ $14
InvDescOffset   equ $18
InvEffeOffset   equ $A7
InvCodeOffset   equ $B0

; Effects
eInvincibility  equ $1
eMaxSpeed       equ $2
eAcceleration   equ $3
eJumpHeight     equ $4

; Abilities
aNoAbility      equ ((ptr_noability-EquipAbilitiesList)/4)
aDoubleJump2    equ ((ptr_djump2-EquipAbilitiesList)/4)
aDoubleJump1    equ ((ptr_djump1-EquipAbilitiesList)/4)
aJumpDash       equ ((ptr_jdash-EquipAbilitiesList)/4)
aHoming         equ ((ptr_homing-EquipAbilitiesList)/4)
aLightDash      equ ((ptr_ldash-EquipAbilitiesList)/4)
aInstaShield    equ ((ptr_insta-EquipAbilitiesList)/4)
aDownAttack     equ ((ptr_dattack-EquipAbilitiesList)/4)


; Inventory items
; shoes
sDefault        equ ((ptr_default-EquipShoesList)/4)
sRunners        equ ((ptr_runners-EquipShoesList)/4)
sSpring         equ ((ptr_springsh-EquipShoesList)/4)
sSpike          equ ((ptr_spikeproof-EquipShoesList)/4)

; items
iNoItem         equ ((ptr_noitem-EquipItemsList)/4)
iGoggles        equ ((ptr_goggles-EquipItemsList)/4)
iItemSaver      equ ((ptr_itemsaver-EquipItemsList)/4)
iSpdBracelet    equ ((ptr_spdbracelet-EquipItemsList)/4)

; emeralds
eDefault        equ $0

; SMPS

; Per Channel
sPlaybackControl equ 0 ; playback control bitfield
bitAtRest       equ 1  ; track is at rest
bitSFXOverride  equ 2  ; SFX is overriding this track
bitModulation   equ 3  ; Modulation turned on
bitNoAttack     equ 4  ; do not attack next note
bitIsPlaying    equ 7  ; ($80) track is playing

sVoiceControl   equ 1  ; voice control bitfield; handles hardware assignment of sound channel for FM/PSG
bitFM1		equ 2  ; Assigned to FM1 (Channels 4-6) vs FM) (Channels 1-3)
bitIsPSGTrack	equ 7  ; ($80) This track uses the PSG


sTimingDivisor  equ 2  ; Divides tempo by this amount (i.e. 1 = normal, 2 = half, 3 = third...)
sTrackPos	equ 4  ; Byte position in track (relative to start of playback memory) (4 bytes)
sTranspose      equ 8  ; Key offset (from coord flag E9) (1 byte signed)
sChannelVolume  equ 9  ; channel volume (NOTE for FM: only applied at voice changes or if CF_CHANGEVOLUME is used)
sPan            equ $A ; Panning / AMS / FMS settings; see Sega Tech Doc (or a YM2612 manual I guess)
sCurrentVoice   equ $B ; Current voice in use OR current PSG tone
sPSGFlutter     equ $C ; PSG flutter (dynamically effects PSG volume for decay/special effects)
sReturnLocation equ $D ; "Gosub" stack position offset (starts at end of this track, and each CF_JUMP decrements by 2)
sCurrentNotefill equ $E	; Currently set note fill; counts down to zero and then cuts off note
sLastNotefill   equ $F	; Reset value for current note fill
sFrequency	equ $10	; Frequency value of FM / PSG (was also DAC patch/rate on Z80) (2 bytes)
sCurrentDuration equ $12 ; current duration timeout; counting down to zero
sLastDuration   equ $13 ; last set duration (if a note follows a note, this is reapplied to current_duration)
sModWait        equ $14 ; Wait period of time before modulation starts  (set data)
sModSpeed       equ $15 ; Modulation Speed                              (set data)
sModDelta       equ $16 ; Modulation change per Mod. Step               (set data)
sModSteps       equ $17 ; Number of steps in modulation (divided by 2)  (set data)
sModWaitWork    equ $18 ; Wait period of time before modulation starts  (working data)
sModSpeedWork   equ $19 ; Modulation Speed                              (working data)
sModDeltaWork   equ $1A ; Modulation change per Mod. Step               (working data)
sModStepsWork   equ $1B ; Number of steps in modulation (divided by 2)  (working data)

sFreqAdjust     equ $1E ; Set by "alter notes" coord flag E1; used to add directly to FM/PSG frequency
sPSGNoise	equ $1F ; PSG noise setting

;	u8  TL_mask;			// Bitfield of which FM TL values are to be set to adjust volume (see VolTLMasks)




; CONSTANTS (Mercury)
; ================================================================================

; Sonic Status Bits
staFacing:	equ 0
staAir:		equ 1
staSpin:	equ 2
staOnObj:	equ 3
staRollJump:	equ 4
staPush:	equ 5
staWater:	equ 6

; obStatus2
staSpinDash:	equ 0
staDash:	equ 1   ; Peelout
staBoost:	equ 2	; boost mode

; Sonic OST Bytes

flip_angle =		$27 ; angle about the x axis (360 degrees = 256) (twist/tumble)
flip_turned =		$29 ; 0 for normal, 1 to invert flipping (it's a 180 degree rotation about the axis of Sonic's spine, so he stays in the same position but looks turned around)
flip_speed =		$2A ; number of flip revolutions per frame / 256
flips_remaining =	$2C ; number of flip revolutions remaining

obWallJump:	equ $2C	; Wall Jump flag
obBoostTimer:	equ $2D		; boost timer	
obInvuln:	equ $30	; Invulnerable (blinking) timer
			; $31 reserved as well
obInvinc:	equ $32	; Invincibility timer
			; $33 reserved as well
obShoes:	equ $34	; Speed Shoes timer
			; $35 reserved as well
			
obFrontAngle:	equ $36
obRearAngle:	equ $37
			
obOnWheel:	equ $38	; on convex wheel flag

obStatus2:	equ $39	; status for abilities such as Spin Dash
SpinDashFlag    = $39
SpinDashCount   = $3A
obRevSpeed:	equ $3A	; rev speed for Spin Dash or Dash
			; $3B reserved as well

obRestartTimer:	equ $3A ; level restart timer
obJumping:	equ $3C	; jumping flag
obPlatformID:	equ $3D	; ost slot of the object Sonic's on top of
obLRLock:	equ $3E	; flag for preventing left and right input



; ================================================================================
;Object Vram Locations
; ================================================================================
; ---------------------------------------------------------------------------
; Pattern load cues - Green Hill Zone
; ---------------------------------------------------------------------------
VRAMloc_Splats		=	$6D60
VRAMloc_Island		=	$7000	; BG islands
VRAMloc_SpringPole	=	$7260
VRAMloc_Swing 		=	$7400	; swinging platform
VRAMloc_Bridge 		=	$75C0	; bridge
VRAMloc_GHZplatform =	$7700	; new platform
VRAMloc_Springboard	=	$7900
VRAMloc_PplRock 	=	$7C00	; purple rock
VRAMloc_Leaves 		=	$7F00	; floating leaves
VRAMloc_Turtroll	=	$8000
VRAMloc_Buzz		=	$8880
VRAMloc_Chopper		=	$8F60
VRAMloc_Newtron		=	$9360
VRAMloc_Motobug		=	$9E00
VRAMloc_Spikes		=	$A360
VRAMloc_HSpring		=	$A460
VRAMloc_VSpring		=	$A5C0
VRAMloc_DSpring		=	$A720
VRAMloc_GhzWall1 	=	$A1E0	; breakable wall
VRAMloc_MonitorSpinDash =	$D400 ; +++ spin dash icon, overwrites goggles icon
VRAMloc_Teleporter	=	$B000

; ---------------------------------------------------------------------------
; Pattern load cues - Marble Zone
; ---------------------------------------------------------------------------
VRAMloc_StompBlock		=	$71C0

; ---------------------------------------------------------------------------
; Pattern load cues - Metropolis Zone Boss
; ---------------------------------------------------------------------------
VRAMloc_MTZBoss	=	$8000
VRAMloc_EggpodS2=	$9000
VRAMloc_EggpodJetsS2=	$9C00

; ---------------------------------------------------------------------------
; Pattern load cues - Wing Fortress Zone Boss
; ---------------------------------------------------------------------------
VRAMloc_WFZBoss	=	$8000