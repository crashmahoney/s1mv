; ---------------------------------------------------------------------------
; Pattern load cues
; ---------------------------------------------------------------------------
ArtLoadCues:

ptr_PLC_Main:		dc.w PLC_Main-ArtLoadCues
ptr_PLC_Main2:		dc.w PLC_Main2-ArtLoadCues
ptr_PLC_Explode:	dc.w PLC_Explode-ArtLoadCues
ptr_PLC_GameOver:	dc.w PLC_GameOver-ArtLoadCues
ptr_PLC_GHZ:		dc.w PLC_GHZ-ArtLoadCues
ptr_PLC_GHZ2:		dc.w PLC_GHZ2-ArtLoadCues
ptr_PLC_LZ:		dc.w PLC_LZ-ArtLoadCues
ptr_PLC_LZ2:		dc.w PLC_LZ2-ArtLoadCues
ptr_PLC_MZ:		dc.w PLC_MZ-ArtLoadCues
ptr_PLC_MZ2:		dc.w PLC_MZ2-ArtLoadCues
ptr_PLC_SLZ:		dc.w PLC_SLZ-ArtLoadCues
ptr_PLC_SLZ2:		dc.w PLC_SLZ2-ArtLoadCues
ptr_PLC_SYZ:		dc.w PLC_SYZ-ArtLoadCues
ptr_PLC_SYZ2:		dc.w PLC_SYZ2-ArtLoadCues
ptr_PLC_SBZ:		dc.w PLC_SBZ-ArtLoadCues
ptr_PLC_SBZ2:		dc.w PLC_SBZ2-ArtLoadCues
ptr_PLC_HUBZ:		dc.w PLC_HUBZ-ArtLoadCues
ptr_PLC_HUBZ2:		dc.w PLC_HUBZ2-ArtLoadCues
ptr_PLC_IntroZ:		dc.w PLC_IntroZ-ArtLoadCues
ptr_PLC_IntroZ2:	dc.w PLC_IntroZ2-ArtLoadCues
ptr_PLC_Tropic:		dc.w PLC_Tropic-ArtLoadCues
ptr_PLC_Tropic2:	dc.w PLC_Tropic2-ArtLoadCues
ptr_PLC_TitleCard:	dc.w PLC_TitleCard-ArtLoadCues
ptr_PLC_Boss:		dc.w PLC_Boss-ArtLoadCues
ptr_PLC_Signpost:	dc.w PLC_Signpost-ArtLoadCues
ptr_PLC_Warp:		dc.w PLC_Warp-ArtLoadCues
ptr_PLC_SpecialStage:	dc.w PLC_SpecialStage-ArtLoadCues
ptr_PLC_GHZAnimals:	dc.w PLC_GHZAnimals-ArtLoadCues
ptr_PLC_LZAnimals:	dc.w PLC_LZAnimals-ArtLoadCues
ptr_PLC_MZAnimals:	dc.w PLC_MZAnimals-ArtLoadCues
ptr_PLC_SLZAnimals:	dc.w PLC_SLZAnimals-ArtLoadCues
ptr_PLC_SYZAnimals:	dc.w PLC_SYZAnimals-ArtLoadCues
ptr_PLC_SBZAnimals:	dc.w PLC_SBZAnimals-ArtLoadCues
ptr_PLC_HUBZAnimals:	dc.w PLC_HUBZAnimals-ArtLoadCues
ptr_PLC_IntroZAnimals:	dc.w PLC_IntroZAnimals-ArtLoadCues
ptr_PLC_TropicAnimals:	dc.w PLC_TropicAnimals-ArtLoadCues
ptr_PLC_SSResult:	dc.w PLC_SSResult-ArtLoadCues
ptr_PLC_Ending:		dc.w PLC_Ending-ArtLoadCues
ptr_PLC_TryAgain:	dc.w PLC_TryAgain-ArtLoadCues
ptr_PLC_EggmanSBZ2:	dc.w PLC_EggmanSBZ2-ArtLoadCues
ptr_PLC_FZBoss:		dc.w PLC_FZBoss-ArtLoadCues
ptr_PLC_MTZBoss:	dc.w PLC_MTZBoss-ArtLoadCues
ptr_PLC_WFZBoss:	dc.w PLC_WFZBoss-ArtLoadCues

plcm:	macro gfx,vram
	dc.l gfx
	dc.w vram
	endm

; ---------------------------------------------------------------------------
; Pattern load cues - standard block 1
; ---------------------------------------------------------------------------

PLC_Main:	dc.w ((PLC_Mainend-PLC_Main-2)/6)-1
		plcm	Nem_Hud_BG, $AE00	; hud popup text backer
		plcm	Nem_Lamp, $D800		; lamppost    +++ moved from #F400 to make room for spindash dust $D880
		plcm	Nem_Hud, $D9C0		; HUD
		plcm	Nem_Homing, $DD40	; homing target
		plcm	Nem_Ring, $F640 	; rings
		plcm	Nem_Points, $F2E0	; points from enemy
	PLC_Mainend:
; ---------------------------------------------------------------------------
; Pattern load cues - standard block 2
; ---------------------------------------------------------------------------
PLC_Main2:	dc.w ((PLC_Main2end-PLC_Main2-2)/6)-1
		plcm	Nem_Monitors, $D000	; monitors
	PLC_Main2end:
; ---------------------------------------------------------------------------
; Pattern load cues - explosion
; ---------------------------------------------------------------------------
PLC_Explode:	dc.w ((PLC_Explodeend-PLC_Explode-2)/6)-1
		plcm	Nem_Explode, $B400	; explosion
	PLC_Explodeend:
; ---------------------------------------------------------------------------
; Pattern load cues - game/time	over
; ---------------------------------------------------------------------------
PLC_GameOver:	dc.w ((PLC_GameOverend-PLC_GameOver-2)/6)-1
		plcm	Nem_GameOver, $ABC0	; game/time over
	PLC_GameOverend:
; ---------------------------------------------------------------------------
; Pattern load cues - Green Hill
; ---------------------------------------------------------------------------

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


PLC_GHZ:	dc.w ((PLC_GHZ2-PLC_GHZ-2)/6)-1
		plcm	Nem_GHZ_1st, 0		; GHZ main patterns
		plcm	Nem_Island, VRAMloc_Island	; springboard
		plcm	Nem_Springboard, VRAMloc_Springboard	; springboard
		plcm	Nem_Turtroll, 	VRAMloc_Turtroll	; turtroll enemy
		plcm	Nem_Buzz, 		VRAMloc_Buzz	; buzz bomber enemy
		plcm	Nem_Chopper, 	VRAMloc_Chopper	; chopper enemy
		plcm	Nem_Newtron, 	VRAMloc_Newtron	; newtron enemy
		plcm	Nem_Motobug, 	VRAMloc_Motobug	; motobug enemy
		plcm	Nem_Spikes, 	VRAMloc_Spikes	; spikes
		plcm	Nem_HSpring, 	VRAMloc_HSpring	; horizontal spring
		plcm	Nem_VSpring, 	VRAMloc_VSpring	; vertical spring
		plcm    Nem_DSpring, 	VRAMloc_DSpring	; diagonal spring
		plcm	Nem_GhzWall1, 	VRAMloc_GhzWall1	; breakable wall

PLC_GHZ2:	dc.w ((PLC_GHZ2end-PLC_GHZ2-2)/6)-1
		plcm	Nem_Swing, 		VRAMloc_Swing	; swinging platform
		plcm	Nem_Bridge, 	VRAMloc_Bridge	; bridge
		plcm	Nem_GHZplatform, VRAMloc_GHZplatform	; new platform
		plcm	Nem_PplRock, 	VRAMloc_PplRock	; purple rock
		plcm	Nem_Leaves, 	VRAMloc_Leaves		; floating leaves
		plcm	Nem_SpringPole, 	VRAMloc_SpringPole	
;		plcm	Nem_GhzWall2, 	VRAMloc_GhzWall2	; normal wall
		plcm    Nem_MonitorSpinDash, VRAMloc_MonitorSpinDash ; +++ spin dash icon, overwrites goggles icon
	PLC_GHZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Labyrinth
; ---------------------------------------------------------------------------
PLC_LZ:		dc.w ((PLC_LZ2-PLC_LZ-2)/6)-1
		plcm	Nem_LZ,0		; LZ main patterns
		plcm	Nem_LzBlock1, $3C00	; block
		plcm	Nem_LzBlock2, $3E00	; blocks
		plcm	Nem_Splash, $4B20	; waterfalls and splash
		plcm	Nem_Water, $6000	; water	surface
		plcm	Nem_LzSpikeBall, $6200	; spiked ball
		plcm	Nem_FlapDoor, $6500	; flapping door
		plcm	Nem_Bubbles, $6900	; bubbles and numbers
		plcm	Nem_LzBlock3, $7780	; block
		plcm	Nem_LzDoor1, $7880	; vertical door
		plcm	Nem_Harpoon, $7980	; harpoon
		plcm	Nem_Burrobot, $94C0	; burrobot enemy

PLC_LZ2:	dc.w ((PLC_LZ2end-PLC_LZ2-2)/6)-1
		plcm	Nem_LzPole, $7BC0	; pole that breaks
		plcm	Nem_LzDoor2, $7CC0	; large	horizontal door
		plcm	Nem_LzWheel, $7EC0	; wheel
		plcm	Nem_Gargoyle, $5D20	; gargoyle head
		if Revision=0
		plcm	Nem_LzSonic, $8800	; Sonic	holding	his breath
		else
		endc
		plcm	Nem_LzPlatfm, $89E0	; rising platform
		plcm	Nem_Orbinaut, $8CE0	; orbinaut enemy
		plcm	Nem_Jaws, $90C0		; jaws enemy
		plcm	Nem_LzSwitch, $A1E0	; switch
		plcm	Nem_Cork, $A000		; cork block
		plcm	Nem_Spikes, $A360	; spikes
		plcm	Nem_HSpring, $A460	; horizontal spring
		plcm	Nem_VSpring, $A660	; vertical spring

	PLC_LZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Marble
; ---------------------------------------------------------------------------
PLC_MZ:		dc.w ((PLC_MZ2-PLC_MZ-2)/6)-1
		plcm	Nem_MZ,0		; MZ main patterns
		plcm	Nem_MzMetal, $6000	; metal	blocks
		plcm	Nem_MzFire, $68A0	; fireballs
		plcm	Nem_Swing, $7000	; swinging platform
		plcm	Nem_MzGlass, $71C0	; green	glassy block
;		plcm	Nem_Lava, $7500		; lava
		plcm	Nem_SpeedBooster, $7500		; speedbooster
		plcm	Nem_Torch, $7580	; decorative torch
		plcm	Nem_Buzz, $8880		; buzz bomber enemy
		plcm	Nem_Yadrin, $8F60	; yadrin enemy
		plcm	Nem_Basaran, $9700	; basaran enemy
		plcm	Nem_Cater, $9FE0	; caterkiller enemy

PLC_MZ2:	dc.w ((PLC_MZ2end-PLC_MZ2-2)/6)-1
		plcm	Nem_MzSwitch, $A260	; switch
		plcm	Nem_Spikes, $A360	; spikes
		plcm	Nem_HSpring, $A460	; horizontal spring
		plcm	Nem_VSpring, $A660	; vertical spring
		plcm	Nem_MzBlock, $5700	; green	stone block
		plcm    Nem_MonitorDJump, $D400 ; +++ double jump icon, overwrites goggles icon
	PLC_MZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Star Light
; ---------------------------------------------------------------------------
PLC_SLZ:	dc.w ((PLC_SLZ2-PLC_SLZ-2)/6)-1
		plcm	Nem_SLZ,0		; SLZ main patterns
		plcm	Nem_Bomb, $8000		; bomb enemy
		plcm	Nem_Orbinaut, $8520	; orbinaut enemy
		plcm	Nem_MzFire, $9000	; fireballs
		plcm	Nem_SlzBlock, $9C00	; block
		plcm	Nem_SlzWall, $A260	; breakable wall
		plcm	Nem_Spikes, $A360	; spikes
		plcm	Nem_HSpring, $A460	; horizontal spring
		plcm	Nem_VSpring, $A660	; vertical spring

PLC_SLZ2:	dc.w ((PLC_SLZ2end-PLC_SLZ2-2)/6)-1
		plcm	Nem_Seesaw, $6E80	; seesaw
		plcm	Nem_Fan, $7400		; fan
		plcm	Nem_Pylon, $7980	; foreground pylon
		plcm	Nem_SlzSwing, $7B80	; swinging platform
		plcm	Nem_SlzCannon, $9B00	; fireball launcher
		plcm	Nem_SlzSpike, $9E00	; spikeball
	PLC_SLZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Spring Yard
; ---------------------------------------------------------------------------
PLC_SYZ:	dc.w ((PLC_SYZ2-PLC_SYZ-2)/6)-1
		plcm	Nem_SYZ,0		; SYZ main patterns
		plcm	Nem_Crabmeat, $8000	; crabmeat enemy
		plcm	Nem_Buzz, $8880		; buzz bomber enemy
		plcm	Nem_Yadrin, $8F60	; yadrin enemy
		plcm	Nem_Roller, $9700	; roller enemy

PLC_SYZ2:	dc.w ((PLC_SYZ2end-PLC_SYZ2-2)/6)-1
		plcm	Nem_Bumper, $7000	; bumper
		plcm	Nem_SyzSpike1, $72C0	; large	spikeball
		plcm	Nem_SyzSpike2, $7740	; small	spikeball
		plcm	Nem_Cater, $9FE0	; caterkiller enemy
		plcm	Nem_LzSwitch, $A1E0	; switch
		plcm	Nem_Spikes, $A360	; spikes
		plcm	Nem_HSpring, $A460	; horizontal spring
		plcm	Nem_VSpring, $A660	; vertical spring
	PLC_SYZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Scrap Brain
; ---------------------------------------------------------------------------
PLC_SBZ:	dc.w ((PLC_SBZ2-PLC_SBZ-2)/6)-1
		plcm	Nem_SBZ,0		; SBZ main patterns
		plcm	Nem_Stomper, $5800	; moving platform and stomper
		plcm	Nem_SbzDoor1, $5D00	; door
		plcm	Nem_Girder, $5E00	; girder
		plcm	Nem_BallHog, $6040	; ball hog enemy
		plcm	Nem_SbzWheel1, $6880	; spot on large	wheel
		plcm	Nem_SbzWheel2, $6900	; wheel	that grabs Sonic
		plcm	Nem_SyzSpike1, $7220	; large	spikeball
		plcm	Nem_Cutter, $76A0	; pizza	cutter
		plcm	Nem_FlamePipe, $7B20	; flaming pipe
		plcm	Nem_SbzFloor, $7EA0	; collapsing floor
		plcm	Nem_SbzBlock, $9860	; vanishing block

PLC_SBZ2:	dc.w ((PLC_SBZ2end-PLC_SBZ2-2)/6)-1
		plcm	Nem_Cater, $5600	; caterkiller enemy
		plcm	Nem_Bomb, $8000		; bomb enemy
		plcm	Nem_Orbinaut, $8520	; orbinaut enemy
		plcm	Nem_SlideFloor, $8C00	; floor	that slides away
		plcm	Nem_SbzDoor2, $8DE0	; horizontal door
		plcm	Nem_Electric, $8FC0	; electric orb
		plcm	Nem_TrapDoor, $9240	; trapdoor
		plcm	Nem_SbzFloor, $7F20	; collapsing floor
		plcm	Nem_SpinPform, $9BE0	; small	spinning platform
		plcm	Nem_LzSwitch, $A1E0	; switch
		plcm	Nem_Spikes, $A360	; spikes
		plcm	Nem_HSpring, $A460	; horizontal spring
		plcm	Nem_VSpring, $A660	; vertical spring
	PLC_SBZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - title card
; ---------------------------------------------------------------------------
PLC_TitleCard:	dc.w ((PLC_TitleCardend-PLC_TitleCard-2)/6)-1
		plcm	Nem_TitleCard, $B000
	PLC_TitleCardend:
; ---------------------------------------------------------------------------
; Pattern load cues - act 3 boss
; ---------------------------------------------------------------------------
PLC_Boss:	dc.w ((PLC_Bossend-PLC_Boss-2)/6)-1
		plcm	Nem_Eggman, $8000	; Eggman main patterns
		plcm	Nem_Weapons, $8D80	; Eggman's weapons
		plcm	Nem_Prison, $93A0	; prison capsule
		plcm	Nem_Bomb, $A300		; bomb enemy ((gets overwritten)
		plcm	Nem_SlzSpike, $A300	; spikeball ((SLZ boss)
		plcm	Nem_Exhaust, $A540	; exhaust flame
	PLC_Bossend:
; ---------------------------------------------------------------------------
; Pattern load cues - act 1/2 signpost
; ---------------------------------------------------------------------------
PLC_Signpost:	dc.w ((PLC_Signpostend-PLC_Signpost-2)/6)-1
		plcm	Nem_SignPost, $D000	; signpost
		plcm	Nem_Bonus, $96C0	; hidden bonus points
		plcm	Nem_BigFlash, $8C40	; giant	ring flash effect
	PLC_Signpostend:
; ---------------------------------------------------------------------------
; Pattern load cues - special stage warp effect
; ---------------------------------------------------------------------------
PLC_Warp:
		dc.w ((PLC_Warpend-PLC_Warp-2)/6)-1
		plcm	Nem_BigFlash, $B400	; giant	ring flash effect
; 		if Revision=0                   ; old beta warp effect
; 		dc.w ((PLC_Warpend-PLC_Warp-2)/6)-1
; 		plcm	Nem_Warp, $A820
; 		else
; 		endc
	PLC_Warpend:
; ---------------------------------------------------------------------------
; Pattern load cues - special stage
; ---------------------------------------------------------------------------
PLC_SpecialStage:	dc.w ((PLC_SpeStageend-PLC_SpecialStage-2)/6)-1
		plcm	Nem_SSBgCloud, 0	; bubble and cloud background
		plcm	Nem_SSBgFish, $A20	; bird and fish	background
		plcm	Nem_SSWalls, $2840	; walls
		plcm	Nem_Bumper, $4760	; bumper
		plcm	Nem_SSGOAL, $4A20	; GOAL block
		plcm	Nem_SSUpDown, $4C60	; UP and DOWN blocks
		plcm	Nem_SSRBlock, $5E00	; R block
		plcm	Nem_SS1UpBlock, $6E00	; 1UP block
		plcm	Nem_SSEmStars, $7E00	; emerald collection stars
		plcm	Nem_SSRedWhite, $8E00	; red and white	block
		plcm	Nem_SSGhost, $9E00	; ghost	block
		plcm	Nem_SSWBlock, $AE00	; W block
		plcm	Nem_SSGlass, $BE00	; glass	block
		plcm	Nem_SSEmerald, $EE00	; emeralds
		plcm	Nem_SSZone1, $F2E0	; ZONE 1 block
		plcm	Nem_SSZone2, $F400	; ZONE 2 block
		plcm	Nem_SSZone3, $F520	; ZONE 3 block
	PLC_SpeStageend:
		plcm	Nem_SSZone4, $F2E0	; ZONE 4 block
		plcm	Nem_SSZone5, $F400	; ZONE 5 block
		plcm	Nem_SSZone6, $F520	; ZONE 6 block
; ---------------------------------------------------------------------------
; Pattern load cues - GHZ animals
; ---------------------------------------------------------------------------
PLC_GHZAnimals:	dc.w ((PLC_GHZAnimalsend-PLC_GHZAnimals-2)/6)-1
		plcm	Nem_Rabbit, $B000	; rabbit
		plcm	Nem_Flicky, $B240	; flicky
	PLC_GHZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - LZ animals
; ---------------------------------------------------------------------------
PLC_LZAnimals:	dc.w ((PLC_LZAnimalsend-PLC_LZAnimals-2)/6)-1
		plcm	Nem_BlackBird, $B000	; blackbird
		plcm	Nem_Seal, $B240		; seal
	PLC_LZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - MZ animals
; ---------------------------------------------------------------------------
PLC_MZAnimals:	dc.w ((PLC_MZAnimalsend-PLC_MZAnimals-2)/6)-1
		plcm	Nem_Squirrel, $B000	; squirrel
		plcm	Nem_Seal, $B240		; seal
	PLC_MZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - SLZ animals
; ---------------------------------------------------------------------------
PLC_SLZAnimals:	dc.w ((PLC_SLZAnimalsend-PLC_SLZAnimals-2)/6)-1
		plcm	Nem_Pig, $B000		; pig
		plcm	Nem_Flicky, $B240	; flicky
	PLC_SLZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - SYZ animals
; ---------------------------------------------------------------------------
PLC_SYZAnimals:	dc.w ((PLC_SYZAnimalsend-PLC_SYZAnimals-2)/6)-1
		plcm	Nem_Pig, $B000		; pig
		plcm	Nem_Chicken, $B240	; chicken
	PLC_SYZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - SBZ animals
; ---------------------------------------------------------------------------
PLC_SBZAnimals:	dc.w ((PLC_SBZAnimalsend-PLC_SBZAnimals-2)/6)-1
		plcm	Nem_Rabbit, $B000		; rabbit
		plcm	Nem_Chicken, $B240	; chicken
	PLC_SBZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - special stage results screen
; ---------------------------------------------------------------------------
PLC_SSResult:dc.w ((PLC_SpeStResultend-PLC_SSResult-2)/6)-1
		plcm	Nem_ResultEm, $A820	; emeralds
		plcm	Nem_MiniSonic, $AA20	; mini Sonic
	PLC_SpeStResultend:

; ---------------------------------------------------------------------------
; Pattern load cues - ending sequence
; ---------------------------------------------------------------------------
PLC_Ending:	dc.w ((PLC_Endingend-PLC_Ending-2)/6)-1
		plcm	Nem_GHZ_1st,0		; GHZ main patterns
;		plcm	Nem_GHZ_2nd, $39A0	; GHZ secondary	patterns
		plcm	Nem_Stalk, $6B00	; flower stalk
		plcm	Nem_EndFlower, $7400	; flowers
		plcm	Nem_EndEm, $78A0	; emeralds
		plcm	Nem_EndSonic, $7C20	; Sonic
		if Revision=0
		plcm	Nem_EndEggman, $A480	; Eggman's death ((unused)
		else
		endc
		plcm	Nem_Rabbit, $AA60	; rabbit
		plcm	Nem_Chicken, $ACA0	; chicken
		plcm	Nem_BlackBird, $AE60	; blackbird
		plcm	Nem_Seal, $B0A0		; seal
		plcm	Nem_Pig, $B260		; pig
		plcm	Nem_Flicky, $B4A0	; flicky
		plcm	Nem_Squirrel, $B660	; squirrel
		plcm	Nem_EndStH, $B8A0	; "SONIC THE HEDGEHOG"
	PLC_Endingend:
; ---------------------------------------------------------------------------
; Pattern load cues - "TRY AGAIN" and "END" screens
; ---------------------------------------------------------------------------
PLC_TryAgain:	dc.w ((PLC_TryAgainend-PLC_TryAgain-2)/6)-1
		plcm	Nem_EndEm, $78A0	; emeralds
		plcm	Nem_TryAgain, $7C20	; Eggman
		plcm	Nem_CreditText, $B400	; credits alphabet
	PLC_TryAgainend:
; ---------------------------------------------------------------------------
; Pattern load cues - Eggman on SBZ 2
; ---------------------------------------------------------------------------
PLC_EggmanSBZ2:	dc.w ((PLC_EggmanSBZ2end-PLC_EggmanSBZ2-2)/6)-1
		plcm	Nem_SbzBlock, $A300	; block
		plcm	Nem_Sbz2Eggman, $8000	; Eggman
		plcm	Nem_LzSwitch, $9400	; switch
	PLC_EggmanSBZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - final boss
; ---------------------------------------------------------------------------
PLC_FZBoss:	dc.w ((PLC_FZBossend-PLC_FZBoss-2)/6)-1
		plcm	Nem_FzEggman, $7400	; Eggman after boss
		plcm	Nem_FzBoss, $6000	; FZ boss
		plcm	Nem_Eggman, $8000	; Eggman main patterns
		plcm	Nem_Sbz2Eggman, $8E00	; Eggman without ship
		plcm	Nem_Exhaust, $A540	; exhaust flame
	PLC_FZBossend:
		even
; ---------------------------------------------------------------------------
; Pattern load cues - Metropolis Zone Boss
; ---------------------------------------------------------------------------
PLC_MTZBoss:	dc.w ((PLC_MTZBossend-PLC_MTZBoss-2)/6)-1
		plcm	Nem_EggpodS2, $400*$20  ; Sonic 2 Eggman pod graphics   ($60 tiles, $C00 bytes)
		plcm	Nem_MTZBoss, $380*$20   ; Metropolis Boss Specific Graphics ($7C tiles, $F80 bytes)
		plcm	Nem_EggpodJetsS2, $460*$20  ; Sonic 2 exhaust flame         ($8 tiles, $100 bytes)
; 		plcm	Nem_Prison, $49D*$20    ; prison capsule
		plcm	Nem_BossExplode, $B400	; boss explosion
	PLC_MTZBossend:
		even
; ---------------------------------------------------------------------------
; Pattern load cues - Wing Fortress Zone Boss
; ---------------------------------------------------------------------------
PLC_WFZBoss:	dc.w ((PLC_WFZBossend-PLC_WFZBoss-2)/6)-1
		plcm	Nem_WFZBoss, $0379*$20
		plcm	Nem_BossExplode, $B400	; boss explosion
	PLC_WFZBossend:
		even
; ---------------------------------------------------------------------------
; Pattern load cues - Hub
; ---------------------------------------------------------------------------
PLC_HUBZ:	dc.w ((PLC_HUBZ2-PLC_HUBZ-2)/6)-1
		plcm	Nem_HUBZ,0		; MZ main patterns
		plcm	Nem_MzMetal, $6000	; metal	blocks
		plcm	Nem_MzFire, $68A0	; fireballs
		plcm	Nem_Swing, $7000	; swinging platform
		plcm	Nem_MzGlass, $71C0	; green	glassy block
		plcm	Nem_Lava, $7500		; lava
		plcm	Nem_Buzz, $8880		; buzz bomber enemy
		plcm	Nem_Yadrin, $8F60	; yadrin enemy
		plcm	Nem_Basaran, $9700	; basaran enemy
		plcm	Nem_Cater, $9FE0	; caterkiller enemy

PLC_HUBZ2:	dc.w ((PLC_HUBZ2end-PLC_HUBZ2-2)/6)-1
		plcm	Nem_MzSwitch, $A260	; switch
		plcm	Nem_Spikes, $A360	; spikes
		plcm	Nem_HSpring, $A460	; horizontal spring
		plcm	Nem_VSpring, $A660	; vertical spring
		plcm	Nem_MzBlock, $5700	; green	stone block
;		plcm    Nem_MonitorDJump, $D400 ; +++ double jump icon, overwrites goggles icon
	PLC_HUBZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - HUBZ animals
; ---------------------------------------------------------------------------
PLC_HUBZAnimals:	dc.w ((PLC_HUBZAnimalsend-PLC_HUBZAnimals-2)/6)-1
		plcm	Nem_Pig, $B000		; pig
		plcm	Nem_Flicky, $B240	; flicky
	PLC_HUBZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - IntroZ animals
; ---------------------------------------------------------------------------
PLC_IntroZAnimals:	dc.w ((PLC_IntroZAnimalsend-PLC_IntroZAnimals-2)/6)-1
		plcm	Nem_BlackBird, $B000	; blackbird
		plcm	Nem_Seal, $B240		; seal
	PLC_IntroZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - Tropic animals
; ---------------------------------------------------------------------------
PLC_TropicAnimals:	dc.w ((PLC_TropicAnimalsend-PLC_TropicAnimals-2)/6)-1
		plcm	Nem_Rabbit, $B000	; rabbit
		plcm	Nem_Flicky, $B240	; flicky
	PLC_TropicAnimalsend:

; ---------------------------------------------------------------------------
; Pattern load cues - Intro
; ---------------------------------------------------------------------------
PLC_IntroZ:	dc.w ((PLC_IntroZ2-PLC_IntroZ-2)/6)-1
		plcm	Nem_IntroZ,0		; MZ main patterns
		plcm	Nem_MzMetal, $6000	; metal	blocks
		plcm	Nem_MzFire, $68A0	; fireballs
		plcm	Nem_Swing, $7000	; swinging platform
		plcm	Nem_MzGlass, $71C0	; green	glassy block
		plcm	Nem_Lava, $7500		; lava
		plcm	Nem_Buzz, $8880		; buzz bomber enemy
		plcm	Nem_Yadrin, $8F60	; yadrin enemy
		plcm	Nem_Basaran, $9700	; basaran enemy
		plcm	Nem_Cater, $9FE0	; caterkiller enemy

PLC_IntroZ2:	dc.w ((PLC_IntroZ2end-PLC_IntroZ2-2)/6)-1
		plcm	Nem_MzSwitch, $A260	; switch
		plcm	Nem_Spikes, $A360	; spikes
		plcm	Nem_HSpring, $A460	; horizontal spring
		plcm	Nem_VSpring, $A660	; vertical spring
		plcm	Nem_MzBlock, $5700	; green	stone block
;		plcm    Nem_MonitorDJump, $D400 ; +++ double jump icon, overwrites goggles icon
	PLC_IntroZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Tropical
; ---------------------------------------------------------------------------
PLC_Tropic:	dc.w ((PLC_Tropic2-PLC_Tropic-2)/6)-1
		plcm	Nem_Tropic, 0		; Tropic main patterns
;		plcm	Nem_GHZ_2nd, $39A0	; GHZ secondary	patterns
		plcm	Nem_Stalk, $6B00	; flower stalk
		plcm	Nem_PplRock, $7A00	; purple rock
		plcm	Nem_Crabmeat, $8000	; crabmeat enemy
		plcm	Nem_Buzz, $8880		; buzz bomber enemy
		plcm	Nem_Chopper, $8F60	; chopper enemy
		plcm	Nem_Newtron, $9360	; newtron enemy
		plcm	Nem_Motobug, $9E00	; motobug enemy
		plcm	Nem_Spikes, $A360	; spikes
		plcm	Nem_HSpring, $A460	; horizontal spring
		plcm	Nem_VSpring, $A660	; vertical spring

PLC_Tropic2:	dc.w ((PLC_Tropic2end-PLC_Tropic2-2)/6)-1
		plcm	Nem_Swing, $7000	; swinging platform
		plcm	Nem_Bridge, $71C0	; bridge
		plcm	Nem_SpikePole, $7300	; spiked pole
		plcm	Nem_Ball, $7540		; giant	ball
		plcm	Nem_GhzWall1, $A1E0	; breakable wall
		plcm	Nem_GhzWall2, $6980	; normal wall
		plcm    Nem_MonitorSpinDash, $D400 ; +++ spin dash icon, overwrites goggles icon
	PLC_Tropic2end:

; ---------------------------------------------------------------------------
; Pattern load cue IDs
; ---------------------------------------------------------------------------
plcid_Main:		equ (ptr_PLC_Main-ArtLoadCues)/2	; 0
plcid_Main2:		equ (ptr_PLC_Main2-ArtLoadCues)/2	; 1
plcid_Explode:		equ (ptr_PLC_Explode-ArtLoadCues)/2	; 2
plcid_GameOver:		equ (ptr_PLC_GameOver-ArtLoadCues)/2	; 3
plcid_GHZ:		equ (ptr_PLC_GHZ-ArtLoadCues)/2		; 4
plcid_GHZ2:		equ (ptr_PLC_GHZ2-ArtLoadCues)/2	; 5
plcid_LZ:		equ (ptr_PLC_LZ-ArtLoadCues)/2		; 6
plcid_LZ2:		equ (ptr_PLC_LZ2-ArtLoadCues)/2		; 7
plcid_MZ:		equ (ptr_PLC_MZ-ArtLoadCues)/2		; 8
plcid_MZ2:		equ (ptr_PLC_MZ2-ArtLoadCues)/2		; 9
plcid_SLZ:		equ (ptr_PLC_SLZ-ArtLoadCues)/2		; $A
plcid_SLZ2:		equ (ptr_PLC_SLZ2-ArtLoadCues)/2	; $B
plcid_SYZ:		equ (ptr_PLC_SYZ-ArtLoadCues)/2		; $C
plcid_SYZ2:		equ (ptr_PLC_SYZ2-ArtLoadCues)/2	; $D
plcid_SBZ:		equ (ptr_PLC_SBZ-ArtLoadCues)/2		; $E
plcid_SBZ2:		equ (ptr_PLC_SBZ2-ArtLoadCues)/2	; $F
plcid_HUBZ:		equ (ptr_PLC_HUBZ-ArtLoadCues)/2	; $20
plcid_HUBZ2:		equ (ptr_PLC_HUBZ2-ArtLoadCues)/2	; $21
plcid_IntroZ:		equ (ptr_PLC_IntroZ-ArtLoadCues)/2	; $25
plcid_IntroZ2:		equ (ptr_PLC_IntroZ2-ArtLoadCues)/2	; $26
plcid_Tropic:		equ (ptr_PLC_Tropic-ArtLoadCues)/2	; $27
plcid_Tropic2:		equ (ptr_PLC_Tropic2-ArtLoadCues)/2	; $28
plcid_TitleCard:	equ (ptr_PLC_TitleCard-ArtLoadCues)/2	; $10
plcid_Boss:		equ (ptr_PLC_Boss-ArtLoadCues)/2	; $11
plcid_Signpost:		equ (ptr_PLC_Signpost-ArtLoadCues)/2	; $12
plcid_Warp:		equ (ptr_PLC_Warp-ArtLoadCues)/2	; $13
plcid_SpecialStage:	equ (ptr_PLC_SpecialStage-ArtLoadCues)/2 ; $14
plcid_GHZAnimals:	equ (ptr_PLC_GHZAnimals-ArtLoadCues)/2	; $15
plcid_LZAnimals:	equ (ptr_PLC_LZAnimals-ArtLoadCues)/2	; $16
plcid_MZAnimals:	equ (ptr_PLC_MZAnimals-ArtLoadCues)/2	; $17
plcid_SLZAnimals:	equ (ptr_PLC_SLZAnimals-ArtLoadCues)/2	; $18
plcid_SYZAnimals:	equ (ptr_PLC_SYZAnimals-ArtLoadCues)/2	; $19
plcid_SBZAnimals:	equ (ptr_PLC_SBZAnimals-ArtLoadCues)/2	; $1A
plcid_HUBZAnimals:	equ (ptr_PLC_HUBZAnimals-ArtLoadCues)/2	; $22
plcid_IntroZAnimals:	equ (ptr_PLC_IntroZAnimals-ArtLoadCues)/2 ; $23
plcid_TropicAnimals:	equ (ptr_PLC_TropicAnimals-ArtLoadCues)/2 ; $24
plcid_SSResult:		equ (ptr_PLC_SSResult-ArtLoadCues)/2	; $1B
plcid_Ending:		equ (ptr_PLC_Ending-ArtLoadCues)/2	; $1C
plcid_TryAgain:		equ (ptr_PLC_TryAgain-ArtLoadCues)/2	; $1D
plcid_EggmanSBZ2:	equ (ptr_PLC_EggmanSBZ2-ArtLoadCues)/2	; $1E
plcid_FZBoss:		equ (ptr_PLC_FZBoss-ArtLoadCues)/2	; $1F
plcid_MTZBoss:		equ (ptr_PLC_MTZBoss-ArtLoadCues)/2	; $20
plcid_WFZBoss:		equ (ptr_PLC_WFZBoss-ArtLoadCues)/2	; $21
