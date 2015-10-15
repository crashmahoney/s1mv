; ---------------------------------------------------------------------------
; Sprite mappings - SCORE, TIME, RINGS
; ---------------------------------------------------------------------------
toptri = -20             ; default positions
lefttri = -19
righttri = 11


Map_HomingTarget:
                 	dc.w @Frame1-Map_HomingTarget
                 	dc.w @Frame2-Map_HomingTarget
                 	dc.w @Frame3-Map_HomingTarget
                 	dc.w @Frame4-Map_HomingTarget
                 	dc.w @Frame5-Map_HomingTarget
                 	dc.w @Frame6-Map_HomingTarget
                 	dc.w @Normal-Map_HomingTarget


@Frame1:	dc.b 5
                SpriteMap  -16, -16, 2, 4, 0, 0, 1, 0, 0x0000       ; Main Circle
                SpriteMap    0, -16, 2, 4, 1, 0, 1, 0, 0x0000       ; Main Circle
                SpriteMap   -4, toptri-27, 1, 1, 0, 0, 1, 0, 0x0008       ; top triangle
                SpriteMap  lefttri-27,   5, 1, 1, 0, 0, 1, 0, 0x0009       ; left triangle
                SpriteMap   righttri+27,   5, 1, 1, 1, 0, 1, 0, 0x0009       ; right triangle
                even

@Frame2:	dc.b 5
                SpriteMap  -16, -16, 2, 4, 0, 0, 1, 0, 0x0000       ; Main Circle
                SpriteMap    0, -16, 2, 4, 1, 0, 1, 0, 0x0000       ; Main Circle
                SpriteMap   -4, toptri-20, 1, 1, 0, 0, 1, 0, 0x0008       ; top triangle
                SpriteMap  lefttri-20,   5, 1, 1, 0, 0, 1, 0, 0x0009       ; left triangle
                SpriteMap   righttri+20,   5, 1, 1, 1, 0, 1, 0, 0x0009       ; right triangle
                even

@Frame3:	dc.b 5
                SpriteMap  -16, -16, 2, 4, 0, 0, 1, 0, 0x0000       ; Main Circle
                SpriteMap    0, -16, 2, 4, 1, 0, 1, 0, 0x0000       ; Main Circle
                SpriteMap   -4, toptri-14, 1, 1, 0, 0, 1, 0, 0x0008       ; top triangle
                SpriteMap  lefttri-14,   5, 1, 1, 0, 0, 1, 0, 0x0009       ; left triangle
                SpriteMap   righttri+14,   5, 1, 1, 1, 0, 1, 0, 0x0009       ; right triangle
                even

@Frame4:	dc.b 5
                SpriteMap  -16, -16, 2, 4, 0, 0, 1, 0, 0x0000       ; Main Circle
                SpriteMap    0, -16, 2, 4, 1, 0, 1, 0, 0x0000       ; Main Circle
                SpriteMap   -4, toptri-9, 1, 1, 0, 0, 1, 0, 0x0008       ; top triangle
                SpriteMap  lefttri-9,   5, 1, 1, 0, 0, 1, 0, 0x0009       ; left triangle
                SpriteMap   righttri+9,   5, 1, 1, 1, 0, 1, 0, 0x0009       ; right triangle
                even

@Frame5:	dc.b 5
                SpriteMap  -16, -16, 2, 4, 0, 0, 1, 0, 0x0000       ; Main Circle
                SpriteMap    0, -16, 2, 4, 1, 0, 1, 0, 0x0000       ; Main Circle
                SpriteMap   -4, toptri-5, 1, 1, 0, 0, 1, 0, 0x0008       ; top triangle
                SpriteMap  lefttri-5,   5, 1, 1, 0, 0, 1, 0, 0x0009       ; left triangle
                SpriteMap   righttri+5,   5, 1, 1, 1, 0, 1, 0, 0x0009       ; right triangle
                even

@Frame6:	dc.b 5
                SpriteMap  -16, -16, 2, 4, 0, 0, 1, 0, 0x0000       ; Main Circle
                SpriteMap    0, -16, 2, 4, 1, 0, 1, 0, 0x0000       ; Main Circle
                SpriteMap   -4, toptri-2, 1, 1, 0, 0, 1, 0, 0x0008       ; top triangle
                SpriteMap  lefttri-2,   5, 1, 1, 0, 0, 1, 0, 0x0009       ; left triangle
                SpriteMap   righttri=2,   5, 1, 1, 1, 0, 1, 0, 0x0009       ; right triangle
                even

@Normal:	dc.b 5
                SpriteMap  -16, -16, 2, 4, 0, 0, 1, 0, 0x0000       ; Main Circle
                SpriteMap    0, -16, 2, 4, 1, 0, 1, 0, 0x0000       ; Main Circle
                SpriteMap   -4, toptri, 1, 1, 0, 0, 1, 0, 0x0008       ; top triangle
                SpriteMap  lefttri,   5, 1, 1, 0, 0, 1, 0, 0x0009       ; left triangle
                SpriteMap   righttri,   5, 1, 1, 1, 0, 1, 0, 0x0009       ; right triangle
                even