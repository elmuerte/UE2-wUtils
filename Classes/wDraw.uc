class wDraw extends Object exportstructs;

struct MaterialRegion 
{
    var Material Tex;
    var IntBox TexCoords;   // absolute material coordinates
    var FloatBox ScreenCoords;  // relative screen coordinates
    var Actor.ERenderStyle RenderStyle;
    var Color DrawColor;
};

// scale keeps the MaterialRegion's center at the same location
static final function DrawMaterialRegion(Canvas C, MaterialRegion M,
        optional float ScaleX, optional float ScaleY, optional bool bClipped)
{
    local byte OldStyle;
    local Color OldColor;
    local float X, Y, W, H, CenterX, CenterY;
   
    if ( ScaleX == 0 )
        ScaleX = 1.0;
   
    if ( ScaleY == 0 )
        ScaleY = ScaleX;
   
    X = M.ScreenCoords.X1 * C.SizeX;
    Y = M.ScreenCoords.Y1 * C.SizeY;
    W = (M.ScreenCoords.X2 - M.ScreenCoords.X1) * C.SizeX;
    H = (M.ScreenCoords.Y2 - M.ScreenCoords.Y1) * C.SizeY;
    CenterX = (M.ScreenCoords.X1 + M.ScreenCoords.X2) * 0.5 * C.SizeX;
    CenterY = (M.ScreenCoords.Y1 + M.ScreenCoords.Y2) * 0.5 * C.SizeY;
   
    W *= ScaleX;
    H *= ScaleY;
    X = CenterX - 0.5 * W;
    Y = CenterY - 0.5 * H;
   
    OldStyle = C.Style;
    OldColor = C.DrawColor;
   
    C.Style = M.RenderStyle;
    C.DrawColor = M.DrawColor;
    C.SetPos(X, Y);
    if ( !bClipped )
        C.DrawTile(M.Tex, W, H, M.TexCoords.X1, M.TexCoords.Y1,
                M.TexCoords.X2 - M.TexCoords.X1, M.TexCoords.Y2 - M.TexCoords.Y1);
    else
        C.DrawTileClipped(M.Tex, W, H, M.TexCoords.X1, M.TexCoords.Y1,
                M.TexCoords.X2 - M.TexCoords.X1, M.TexCoords.Y2 - M.TexCoords.Y1);
    
    C.Style = OldStyle;
    C.DrawColor = OldColor;
}

// draws a float value with the decimal point at about the specified coordinates
static final function DrawDecimalNumberAt(Canvas C, float Value, float X, float Y, optional bool bClipped)
{
    local float IntPart, FloatPart;
    local float XL, YL;
    local string IntString, FloatString;
   
    IntPart = Ceil(Value);
    FloatPart = Abs(Value) - Abs(IntPart);
    IntString = string(int(IntPart));
    FloatString = Mid(string(FloatPart), Instr(string(FloatPart), "."));
    C.TextSize(IntString, XL, YL);
    C.SetPos(X - XL, Y);
    if ( !bClipped )
        C.DrawText(IntString);
    else
        C.DrawTextClipped(IntString);
    C.SetPos(X, Y);
    if ( !bClipped )
        C.DrawText(FloatString);
    else
        C.DrawTextClipped(FloatString);
}

// Calculates a box around an actor in relative screen coordinates. 
static final function FloatBox GetActorBox(Canvas C, Actor A)
{
    local float Left, Right;
    local vector CamLoc, X, Y, Z;
    local rotator CamRot;
    local array<float> Height;
    local FloatBox box;
    
    if ( A == None )
        return box;
    
    C.GetCameraLocation(CamLoc, CamRot);
    GetAxes(CamRot, X, Y, Z);
    Right = C.WorldToScreen(A.Location + Y * A.CollisionRadius).X;
    Left = C.WorldToScreen(A.Location - Y * A.CollisionRadius).X;
    X = Normal(X * vect(1,1,0)) * A.CollisionRadius;
    Z = vect(0,0,1) * A.CollisionHeight;
    Height[0] = C.WorldToScreen(A.Location + X + Z).Y;
    Height[1] = C.WorldToScreen(A.Location - X + Z).Y;
    Height[2] = C.WorldToScreen(A.Location + X - Z).Y;
    Height[3] = C.WorldToScreen(A.Location - X - Z).Y;
    
    box.X1 = Left / C.SizeX;
    box.X2 = Right / C.SizeX;
    box.Y1 = class'wArray'.static.MinF(Height) / C.SizeY;
    box.Y2 = class'wArray'.static.MaxF(Height) / C.SizeY;
    
    return box;
}

// Sets the canvas' clipping region. Can use a FloatBox like it is returned by the GetActorBox method.
static final function SetClipRegion(Canvas C, FloatBox ClipRegion)
{
    C.SetOrigin(ClipRegion.X1 * C.SizeX, ClipRegion.Y1 * C.SizeY);
    C.SetClip((ClipRegion.X2 - ClipRegion.X1) * C.SizeX, (ClipRegion.Y2 - ClipRegion.Y1) * C.SizeY);
}

// Resets the canvas' clipping region.
static final function ResetClipRegion(Canvas C)
{
    C.SetOrigin(C.Default.OrgX, C.Default.OrgY);
    C.SetClip(C.Default.ClipX, C.Default.ClipY);
}