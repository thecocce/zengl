{
 * Copyright © Kemka Andrey aka Andru
 * mail: dr.andru@gmail.com
 * site: http://andru.2x4.ru
 *
 * This library is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
}
unit zgl_types;

{$I define.inc}

interface
uses 
  {$IFDEF LINUX}
  openal
  {$ENDIF}
  {$IFDEF WIN32}
  Windows,
  DirectSound
  {$ENDIF}
  ;

type
  Ptr32  = DWORD;
  Ptr64  = QWORD;
  Ptr    = {$IFDEF CPU64}Ptr64{$ELSE}Ptr32{$ENDIF};
  PPtr   = ^Ptr;
  
{------------------------------------------------------------------------------}
{--------------------------------- zgl_ini.pp ---------------------------------}
{------------------------------------------------------------------------------}
  
type
  zglPINIKey = ^zglTINIKey;
  zglTINIKey = record
    Name  : String;
    Value : String;
end;

type
  zglPINISection = ^zglTINISection;
  zglTINISection = record
    Name : String;
    Keys : DWORD;
    Key  : array of zglTINIKey;
end;

type
  zglPINI = ^zglTINI;
  zglTINI = record
    FileName : String;
    Sections : DWORD;
    Section  : array of zglTINISection;
end;

{------------------------------------------------------------------------------}
{------------------------------- zgl_timers.pp --------------------------------}
{------------------------------------------------------------------------------}
type
  zglPTimer = ^zglTTimer;
  zglTTimer = record
    Active     : Boolean;
    Interval   : DWORD;
    LastTick   : Double;
    OnTimer    : procedure;
    
    Prev, Next : zglPTimer;
end;

type
  zglPTimerManager = ^zglTTimerManager;
  zglTTimerManager = record
    Count : DWORD;
    First : zglTTimer;
end;

{------------------------------------------------------------------------------}
{------------------------------ zgl_textures.pp -------------------------------}
{------------------------------------------------------------------------------}
type
  zglPTexture = ^zglTTexture;
  zglTTexture = record
    ID            : DWORD;
    Width, Height : WORD;
    U, V          : Single;
    FramesX       : WORD;
    FramesY       : WORD;
    Flags         : DWORD;
    
    Prev, Next    : zglPTexture;
end;

type
  zglPTextureManager = ^zglTTextureManager;
  zglTTextureManager = record
    Count : DWORD;
    First : zglTTexture;
end;

type
  zglPTextureFormat = ^zglTTextureFormat;
  zglTTextureFormat = record
    Extension : String;
    Loader    : procedure( FileName : PChar{String}; var pData : Pointer; var W, H : WORD ); extdecl;
end;

{------------------------------------------------------------------------------}
{--------------------------- zgl_render_target.pp -----------------------------}
{------------------------------------------------------------------------------}
type
  zglPFBO = ^zglTFBO;
  zglTFBO = record
    FrameBuffer  : DWORD;
    RenderBuffer : DWORD;
end;

{$IFDEF WIN32}
type
  zglPPBuffer = ^zglTPBuffer;
  zglTPBuffer = record
    Handle : HANDLE;
    DC     : HDC;
    RC     : HGLRC;
end;
{$ENDIF}

type
  zglPRenderTarget = ^zglTRenderTarget;
  zglTRenderTarget = record
    rtType     : Byte;
    Handle     : Pointer;
    Surface    : zglPTexture;
    Flags      : Byte;
    
    Prev, Next : zglPRenderTarget;
end;

type
  zglPRenderTargetManager = ^zglTRenderTargetManager;
  zglTRenderTargetManager = record
    Count : DWORD;
    First : zglTRenderTarget;
end;

{------------------------------------------------------------------------------}
{-------------------------------- zgl_sound.pp --------------------------------}
{------------------------------------------------------------------------------}

{$IFDEF LINUX}
type
  zglPSound = ^zglTSound;
  zglTSound = record
    Buffer     : DWORD;
    sCount     : DWORD;
    Source     : array of DWORD;

    Data       : Pointer;
    Size       : DWORD;
    Frequency  : DWORD;

    Prev, Next : zglPSound;
end;
{$ENDIF}
{$IFDEF WIN32}
type
  zglPSound = ^zglTSound;
  zglTSound = record
    Buffer     : DWORD; // unused
    sCount     : DWORD;
    Source     : array of IDirectSoundBuffer;

    Data       : Pointer;
    Size       : DWORD;
    Frequency  : DWORD;

    Prev, Next : zglPSound;
end;
{$ENDIF}

type
  zglPSoundFile = ^zglTSoundFile;
  zglTSoundFile = record
    _File      : DWORD;
    CodecRead  : function( Buffer : Pointer; Count : DWORD ) : DWORD; extdecl;
    CodecLoop  : procedure; extdecl;
    Rate       : DWORD;
    Channels   : DWORD;
    Buffer     : Pointer;
    BufferSize : DWORD;
    Loop       : Boolean;
    Played     : Boolean;
end;

type
  zglPSoundManager = ^zglTSoundManager;
  zglTSoundManager = record
    Count : DWORD;
    First : zglTSound;
end;

type
  zglPSoundFormat = ^zglTSoundFormat;
  zglTSoundFormat = record
    Extension : String;
    Loader    : procedure( FileName : PChar; var Data : Pointer; var Size, Format, Frequency : Integer ); extdecl;
end;  

{------------------------------------------------------------------------------}
{------------------------------------ 2D --------------------------------------}
{------------------------------------------------------------------------------}
type
  zglPPoint2D = ^zglTPoint2D;
  zglTPoint2D = record
    x, y : Single;
end;

type
  zglPLine = ^zglTLine;
  zglTLine = record
    x0, y0 : Single;
    x1, y1 : Single;
end;

type
  zglPRect = ^zglTRect;
  zglTRect = record
    x, y, w, h : Single;
end;

type
  zglPCircle = ^zglTCircle;
  zglTCircle = record
    cX, cY : Single;
    radius : Single;
end;

type
  zglPPolyLine = ^zglTPolyLine;
  zglTPolyLine = record
    Count  : DWORD;
    cX, cY : Single;
    Points : array of zglTPoint2D;
end;

type
  zglPSprite2D = ^zglTSprite2D;
  zglTSprite2D = record
    X, Y, W, H : Single;
    Angle      : Single;
    Alpha      : Byte;
end;

type
  zglPCamera2D = ^zglTCamera2D;
  zglTCamera2D = record
    X, Y  : Single;
    Angle : Single;
end;

{------------------------------------------------------------------------------}
{-------------------------------- zgl_text.pp ---------------------------------}
{------------------------------------------------------------------------------}
type
  zglPFont = ^zglTFont;
  zglTFont = record
    Texture    : zglPTexture;
    Height     : Byte;
    Width      : array[ 0..255 ] of Byte;
    TexCoords  : array[ 0..255 ] of array[ 0..3 ] of zglTPoint2D;

    Prev, Next : zglPFont;
end;

type
  zglPFontManager = ^zglTFontManager;
  zglTFontManager = record
    Count : DWORD;
    First : zglTFont;
end;

{------------------------------------------------------------------------------}
{------------------------------------ 3D --------------------------------------}
{------------------------------------------------------------------------------}
type
  zglPPoint3D = ^zglTPoint3D;
  zglTPoint3D = record
    case Byte of
    1: ( x, y, z : Single );
    2: ( point : array[ 0..2 ] of Single );
end;

type
  zglPMatrix3f = ^zglTMatrix3f;
  zglTMatrix3f = array[ 0..2 ] of zglTPoint3D;
  
  zglPMatrix4f = ^zglTMatrix4f;
  zglTMatrix4f = array[ 0..3, 0..3 ] of Single;
  
type
  zglPLine3D = ^zglTLine3D;
  zglTLine3D = record
    p1, p2 : zglTPoint3D;
end;

type
  zglPPlane = ^zglTPlane;
  zglTPlane = record
    Points : array[ 0..2 ] of zglTPoint3D;
    D      : Single;
    Normal : zglTPoint3D;
end;
  
type
  zglPAABB = ^zglTAABB;
  zglTAABB = record
    Position : zglTPoint3D;
    Size     : zglTPoint3D;
end;

type
  zglPOBB = ^zglTOBB;
  zglTOBB = record
    Position : zglTPoint3D;
    Size     : zglTPoint3D;
    Matrix   : zglTMatrix3f;
end;

type
  zglPSphere = ^zglTSphere;
  zglTSphere = record
    Position : zglTPoint3D;
    Radius   : Single;
end;

type
  zglPFace = ^zglTFace;
  zglTFace = record
    vIndex : array[ 0..2 ] of DWORD;
    tIndex : array[ 0..2 ] of DWORD;
end;

type
  zglPGroup = ^zglTGroup;
  zglTGroup = record
    FCount  : DWORD;
    IFace   : DWORD;
    Indices : Pointer;
end;

type
  zglPFrame = ^zglTFrame;
  zglTFrame = record
    Vertices : array of zglTPoint3D;
    Normals  : array of zglTPoint3D;
end;

{------------------------------------------------------------------------------}
{----------------------------- zgl_camera_3d.pp -------------------------------}
{------------------------------------------------------------------------------}
type
  zglPCamera3D = ^zglTCamera3D;
  zglTCamera3D = record
    Position : zglTPoint3D;
    Rotation : zglTPoint3D;
    Matrix   : zglTMatrix4f;
end;

{------------------------------------------------------------------------------}
{---------------------------- zgl_static_mesh.pp ------------------------------}
{------------------------------------------------------------------------------}
type
  zglPSMesh = ^zglTSMesh;
  zglTSMesh = record
    Flags          : DWORD;
    
    VCount         : DWORD;
    TCount         : DWORD;
    FCount         : DWORD;
    GCount         : DWORD;
    
    Vertices       : array of zglTPoint3D;
    Normals        : array of zglTPoint3D;
    TexCoords      : array of zglTPoint2D;
    MultiTexCoords : array of zglTPoint2D;
    Faces          : array of zglTFace;
    Indices        : Pointer;
    Groups         : array of zglTGroup;
end;

{------------------------------------------------------------------------------}
{------------------------------ zgl_frustum.pp --------------------------------}
{------------------------------------------------------------------------------}
type
  zglPFrustum = ^zglTFrustum;
  zglTFrustum = array [ 0..5 ] of array[ 0..3 ] of Single;
  
{------------------------------------------------------------------------------}
{------------------------------- zgl_octree.pp --------------------------------}
{------------------------------------------------------------------------------}
type
  zglPRenderData = ^zglTRenderData;
  zglTRenderData = record
    Texture   : DWORD;
    ICount    : DWORD;
    Indices   : Pointer;
    IBType    : DWORD;
end;

type
  zglPNode = ^zglTNode;
  zglTNode = record
    Cube       : zglTAABB;

    RDSize     : DWORD;
    RenderData : array of zglTRenderData;
    DFCount    : DWORD;
    DFaces     : array of DWORD;
    PCount     : DWORD;
    Planes     : array of DWORD;

    NInside    : Boolean;
    SubNodes   : array[ 0..7 ] of zglPNode;
end;

type
  zglPOctree = ^zglTOctree;
  zglTOctree  = record
    Flags           : DWORD;
    VBOFlags        : DWORD;

    IBuffer         : DWORD;
    VBuffer         : DWORD;
    
    MainNode        : zglPNode;

    VCount          : DWORD;
    TCount          : DWORD;
    FCount          : DWORD;
    ICount          : DWORD;

    Vertices        : array of zglTPoint3D;
    TexCoords       : array of zglTPoint2D;
    MultiTexCoords  : array of zglTPoint2D;
    Normals         : array of zglTPoint3D;
    Faces           : array of zglTFace;
    Indices         : Pointer;
    Textures        : array of DWORD;
    Planes          : array of zglTPlane;
    
    MaxDFaces       : DWORD;
    DFaces          : array of DWORD;

    r_DFacesAlready : array of DWORD;
    r_DFacesCount   : DWORD;
    r_DFacesACount  : DWORD;

    r_NodeACount    : DWORD;
end;

procedure BuildTexCoords( FCount : DWORD; var Faces : array of zglTFace; VCount : DWORD; var TexCoords : array of zglTPoint2D );
procedure BuildIndices( FCount : DWORD; var Faces : array of zglTFace; Indices : Pointer; Size : Byte );

implementation

procedure BuildTexCoords;
  var
    i, j : DWORD;
    TC   : array of zglTPoint2D;
begin
  SetLength( TC, VCount );

  for i := 0 to FCount - 1 do
    for j := 0 to 2 do
      TC[ Faces[ i ].vIndex[ j ] ] := TexCoords[ Faces[ i ].tIndex[ j ] ];

  Move( TC[ 0 ], TexCoords[ 0 ], VCount * SizeOf( zglTPoint2D ) );
  SetLength( TC, 0 );
end;

procedure BuildIndices;
  var
    i, j : DWORD;
begin
  if Size = 2 Then
    begin
      for i := 0 to FCount - 1 do
        for j := 0 to 2 do
          PDWORD( Indices + ( i * 3 ) * Size + j * Size )^ := Faces[ i ].vIndex[ j ];
    end else
      if Size = 4 Then
        begin
          for i := 0 to FCount - 1 do
            for j := 0 to 2 do
              PDWORD( Indices + ( i * 3 ) * Size + j * Size )^ := Faces[ i ].vIndex[ j ];
        end;
end;

end.
