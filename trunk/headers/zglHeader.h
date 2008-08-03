/*-------------------------------*/
/*-----------= ZenGL =-----------*/
/*-------------------------------*/
/* build: 21                     */
/* date:  24.07.08               */
/*-------------------------------*/
/* by:   Andru ( Kemka Andrey )  */
/* mail: dr.andru@gmail.com      */
/* ICQ:  496-929-849             */
/* site: http://andru.2x4.ru     */
/*-------------------------------*/
/*                      (C) 2008 */
/*-------------------------------*/
#ifndef _ZGLHEADER_
#define _ZGLHEADER_

typedef unsigned short WORD;
typedef unsigned int DWORD;
typedef unsigned char byte;
#ifndef __CPP__
typedef unsigned char bool;
#endif

#ifdef win32
  typedef DWORD HANDLE;
  typedef DWORD HDC;
  typedef DWORD HGLRC;
#endif

#ifdef __CPP__
  #define ZGLIMPORT extern "C"
#else
  #define ZGLIMPORT extern
#endif

ZGLIMPORT void zgl_Init( byte FSAA, byte StencilBits );
ZGLIMPORT void zgl_Exit(void);
  
#define SYS_LOAD             0x000001
#define SYS_DRAW             0x000002
#define SYS_EXIT             0x000003
#define TEX_FORMAT_EXTENSION 0x000010
#define TEX_FORMAT_LOADER    0x000011
#define SND_FORMAT_EXTENSION 0x000020
#define SND_FORMAT_LOADER    0x000021

ZGLIMPORT void zgl_Reg( WORD What, void* UserData );
  
#define SYS_FPS      0x0000001
#define LOG_FILENAME 0x0000002

ZGLIMPORT DWORD zgl_Get( DWORD What );
ZGLIMPORT void  zgl_GetMem( void** Ptr, DWORD Size );

#define COLOR_BUFFER_CLEAR 0x000001
#define DEPTH_BUFFER       0x000002
#define DEPTH_BUFFER_CLEAR 0x000004
#define CORRECT_RESOLUTION 0x000008
#define APP_USE_AUTOPAUSE  0x000010
#define SND_CAN_PLAY       0x000020
#define SND_CAN_PLAY_FILE  0x000040

ZGLIMPORT void zgl_Enable( DWORD What );
ZGLIMPORT void zgl_Disable( DWORD What );

/* LOG */
ZGLIMPORT void log_Add( const char* Message, bool Timings );
  
/* WINDOW */
ZGLIMPORT void wnd_SetCaption( const char* NewCaption );
ZGLIMPORT void wnd_SetSize( WORD Width, WORD Height );
ZGLIMPORT void wnd_SetPos( WORD X, WORD Y );
ZGLIMPORT void wnd_SetOnTop( bool OnTop );
ZGLIMPORT void wnd_ShowCursor( bool Show );
  
/* SCREEN */
#define REFRESH_MAXIMUM 0
#define REFRESH_DEFAULT 1

ZGLIMPORT void scr_Clear(void);
ZGLIMPORT void scr_Flush(void);
ZGLIMPORT void scr_SetVSync( bool VSync );
/* ВНИМАНИЕ: Функция уничтожает контекст OpenGL, что потребует перезагрузку ресурсов */
ZGLIMPORT void scr_SetFSAA( byte FSAA );
ZGLIMPORT void scr_SetOptions( WORD Width, WORD Height, WORD BPP, WORD Refresh, bool FullScreen, bool VSync );
ZGLIMPORT void scr_CorrectResolution( WORD Width, WORD Height );

/* INI */
ZGLIMPORT void  ini_LoadFromFile( const char* FileName );
ZGLIMPORT void  ini_SaveToFile( const char* FileName );
ZGLIMPORT void  ini_Add( const char* Section, const char* Key );
ZGLIMPORT char* ini_ReadKeyStr( const char* Section, const char* Key );
ZGLIMPORT int   ini_ReadKeyInt( const char* Section, const char* Key );
ZGLIMPORT bool  ini_WriteKeyStr( const char* Section, const char* Key, const char* Value );
ZGLIMPORT bool  ini_WriteKeyInt( const char* Section, const char* Key, int Value );
  
/* TIMERS */
typedef struct
{
  bool   Active;
  DWORD  Interval;
  double LastTick;
  void*  OnTimer;

  void*  Prev;
  void*  Next;
} zglTTimer, *zglPTimer;

ZGLIMPORT zglPTimer timer_Add( void* OnTimer, DWORD Interval );
ZGLIMPORT void      timer_Del( zglPTimer Timer );
ZGLIMPORT double    timer_GetTicks(void);
  
/* KEYBOARD */
#define K_BACKSPACE 8
#define K_TAB       9
#define K_ENTER     13
#define K_SHIFT     16
#define K_SHIFT_L   160
#define K_SHIFT_R   161
#define K_CTRL      17
#define K_CTRL_L    162
#define K_CTRL_R    163
#define K_ALT       18
#define K_ALT_L     164
#define K_ALT_R     165
#define K_PAUSE     19
#define K_ESCAPE    27
#define K_SPACE     32

#define K_PAGEUP    33
#define K_PAGEDOWN  34
#define K_END       35
#define K_HOME      36
#define K_SNAPSHOT  44
#define K_INSERT    45
#define K_DELETE    46

#define K_LEFT      37
#define K_UP        38
#define K_RIGHT     39
#define K_DOWN      40

#define K_0         48
#define K_1         49
#define K_2         50
#define K_3         51
#define K_4         52
#define K_5         53
#define K_6         54
#define K_7         55
#define K_8         56
#define K_9         57

#define K_NUMPAD0   96
#define K_NUMPAD1   97
#define K_NUMPAD2   98
#define K_NUMPAD3   99
#define K_NUMPAD4   100
#define K_NUMPAD5   101
#define K_NUMPAD6   102
#define K_NUMPAD7   103
#define K_NUMPAD8   104
#define K_NUMPAD9   105

#define K_MULTIPLY  106
#define K_ADD       107
#define K_SEPARATOR 108
#define K_SUBTRACT  109
#define K_DECIMAL   110
#define K_DIVIDE    111

#define K_A         65
#define K_B         66
#define K_C         67
#define K_D         68
#define K_E         69
#define K_F         70
#define K_G         71
#define K_H         72
#define K_I         73
#define K_J         74
#define K_K         75
#define K_L         76
#define K_M         77
#define K_N         78
#define K_O         79
#define K_P         80
#define K_Q         81
#define K_R         82
#define K_S         83
#define K_T         84
#define K_U         85
#define K_V         86
#define K_W         87
#define K_X         88
#define K_Y         89
#define K_Z         90

#define K_F1        112
#define K_F2        113
#define K_F3        114
#define K_F4        115
#define K_F5        116
#define K_F6        117
#define K_F7        118
#define K_F8        119
#define K_F9        120
#define K_F10       121
#define K_F11       122
#define K_F12       123
ZGLIMPORT bool  key_Down( byte KeyCode );
ZGLIMPORT bool  key_Up( byte KeyCode );
ZGLIMPORT void  key_BeginReadText( const char* Text, WORD MaxSymbols );
ZGLIMPORT char* key_EndReadText(void);
ZGLIMPORT void  key_ClearState(void);
  
/* MOUSE */
#define M_BLEFT  0
#define M_BMIDLE 1
#define M_BRIGHT 2
#define M_WUP    0
#define M_WDOWN  1

ZGLIMPORT WORD mouse_X(void);
ZGLIMPORT WORD mouse_Y(void);
ZGLIMPORT int  mouse_DX(void);
ZGLIMPORT int  mouse_DY(void);
ZGLIMPORT bool mouse_Down( byte Button );
ZGLIMPORT bool mouse_Up( byte Button );
ZGLIMPORT bool mouse_Click( byte Button );
ZGLIMPORT bool mouse_Wheel( byte Axis );
ZGLIMPORT void mouse_ClearState(void);
ZGLIMPORT void mouse_Lock(void);
  
/* GL */
ZGLIMPORT void Set2DMode(void);
ZGLIMPORT void Set3DMode( float FOVY );
  
/* TEXTURES */
typedef struct
{
  DWORD  ID;
  WORD   Width;
  WORD   Height;
  float  U;
  float  V;
  WORD   FramesX;
  WORD   FramesY;
  DWORD  Flags;

  void*  Prev;
  void*  Next;
} zglTTexture, *zglPTexture;

#define TEX_MIPMAP            0x000001
#define TEX_CLAMP             0x000002
#define TEX_REPEAT            0x000004
#define TEX_COMPRESS          0x000008
#define TEX_CONVERT_TO_POT    0x000010

#define TEX_GRAYSCALE         0x000020
#define TEX_INVERT            0x000040
#define TEX_USEMASK           0x000080

#define TEX_FILTER_NEAREST    0x000100
#define TEX_FILTER_LINEAR     0x000200
#define TEX_FILTER_BILINEAR   0x000400
#define TEX_FILTER_TRILINEAR  0x000800
#define TEX_FILTER_ANISOTROPY 0x001000

#define TEX_RGB               0x002000

#define TEX_QUALITY_LOW       0x400000
#define TEX_QUALITY_MEDIUM    0x800000

#define TEX_DEFAULT_2D        TEX_CLAMP | TEX_CONVERT_TO_POT | TEX_FILTER_LINEAR

ZGLIMPORT zglPTexture tex_Add(void);
ZGLIMPORT void        tex_Del( zglPTexture Texture );
ZGLIMPORT void        tex_Create( zglTTexture *Texture, void* pData );
ZGLIMPORT zglPTexture tex_CreateZero( WORD Width, WORD Height, DWORD Color, DWORD Flags );
ZGLIMPORT zglPTexture tex_LoadFromFile( const char* FileName, DWORD TransparentColor, DWORD Flags );
ZGLIMPORT void        tex_SetFrameSize( zglPTexture Texture, WORD FrameWidth, WORD FrameHeight );
ZGLIMPORT void        tex_Filter( zglPTexture Texture, DWORD Flags );
ZGLIMPORT void        tex_SetAnisotropy( byte Level );

/* RENDER TARGETS */
typedef struct
{
  DWORD FrameBuffer;
  DWORD RenderBuffer;
} zglTFBO, *zglPFBO;

#ifdef win32
typedef struct
{
  HANDLE Handle;
  HDC    DC;
  HGLRC  RC;
} zglTPBuffer, *zglPPBuffer;
#endif

typedef struct
{
  byte        rtType;
  void*       Handle;
  zglPTexture Surface;
  byte        Flags;

  void*       Prev;
  void*       Next;
} zglTRenderTarget, *zglPRenderTarget;

#define RT_TYPE_SIMPLE  0
#define RT_TYPE_FBO     1
#define RT_TYPE_PBUFFER 2
#define RT_FULL_SCREEN  0x01
#define RT_CLEAR_SCREEN 0x02

ZGLIMPORT zglPRenderTarget rtarget_Add( byte rtType, zglPTexture Surface, byte Flags );
ZGLIMPORT void             rtarget_Del( zglPRenderTarget Target );
ZGLIMPORT void             rtarget_Set( zglPRenderTarget Target );
  
/* 2D */
typedef struct zglTPoint2D
{
  float X;
  float Y;
} zglTPoint2D, *zglPPoint2D;

typedef struct
{
  float x0;
  float y0;
  float x1;
  float y1;
} zglTLine, *zglPLine;

typedef struct
{
  float x;
  float y;
  float w;
  float h;
} zglTRect, *zglPRect;

typedef struct
{
  float cX;
  float cY;
  float radius;
} zglTCircle, *zglPCircle;

typedef struct
{
  DWORD Count;
  float cX;
  float cY;
  zglTPoint2D *Points;
} zglTPolyLine, *zglPPolyLine;

/* FX */
#define FX_BLEND_NORMAL 0x00
#define FX_BLEND_ADD    0x01
#define FX_BLEND_MULT   0x02
#define FX_BLEND_BLACK  0x03
#define FX_BLEND_WHITE  0x04
#define FX_BLEND_MASK   0x05

ZGLIMPORT void fx_SetBlendMode( byte Mode );
  
/* FX 2D */
#define FX2D_FLIPX    0x000001
#define FX2D_FLIPY    0x000002
#define FX2D_COLORMIX 0x000004
#define FX2D_VCA      0x000008
#define FX2D_VCHANGE  0x000010
#define FX2D_SCALE    0x000020

#define FX_BLEND      0x000040

ZGLIMPORT void fx2d_SetColorMix( DWORD Color );
ZGLIMPORT void fx2d_SetVCA( DWORD c1, DWORD c2, DWORD c3, DWORD c4, byte a1, byte a2, byte a3, byte a4 );
ZGLIMPORT void fx2d_SetVertexes( float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4 );
ZGLIMPORT void fx2d_SetScale( float scaleX, float scaleY );
  
/* Camera 2D */
typedef struct
{
  float X;
  float Y;
  float Angle;
} zglTCamera2D, *zglPCamera2D;

ZGLIMPORT void cam2d_Set( zglPCamera2D Camera );
  
/* Primitives 2D */
#define PR2D_FILL   0x000001
#define PR2D_SMOOTH 0x000002

ZGLIMPORT void pr2d_Pixel( float X, float Y, DWORD Color, byte Alpha );
ZGLIMPORT void pr2d_Line( float X1, float Y1, float X2, float Y2, DWORD Color, byte Alpha, DWORD FX );
ZGLIMPORT void pr2d_Rect( float X, float Y, float W, float H, DWORD Color, byte Alpha, DWORD FX );
ZGLIMPORT void pr2d_Circle( float X, float Y, float Radius, DWORD Color, byte Alpha, WORD Quality, DWORD FX );
ZGLIMPORT void pr2d_Ellipse( float X, float Y, float xRadius, float yRadius, DWORD Color, byte Alpha, WORD Quality, DWORD FX );
  
/* Sprites 2D */
ZGLIMPORT void ssprite2d_Draw( zglPTexture Texture, float X, float Y, float W, float H, float Angle, byte Alpha, DWORD FX );
ZGLIMPORT void asprite2d_Draw( zglPTexture Texture, float X, float Y, float W, float H, float Angle, WORD Frame, byte Alpha, DWORD FX );
ZGLIMPORT void csprite2d_Draw( zglPTexture Texture, float X, float Y, float W, float H, float Angle, zglTRect CutRect, byte Alpha, DWORD FX );
  
/* Text */
typedef struct
{
  zglPTexture Texture;
  byte        Height;
  byte        Width[256];
  zglTPoint2D TexCoords[256][4];

  void*       Prev;
  void*       Next;
} zglTFont, *zglPFont;

ZGLIMPORT zglPFont font_Add(void);
ZGLIMPORT void     font_Del( zglPFont Font );
ZGLIMPORT zglPFont font_LoadFromFile( const char* Texture, const char* FontInfo );
ZGLIMPORT void     text_Draw( zglPFont Font, float X, float Y, const char* Text, byte Alpha, DWORD Color, float Step, float Scale );
ZGLIMPORT float    text_GetWidth( zglPFont Font, const char* Text, float Step, float Scale );

/* Sound */
typedef struct
{
  DWORD Buffer;
  DWORD sCount;
  int*  Source;

  void* Data;
  DWORD Size;
  DWORD Frequency;

  void* Prev;
  void* Next;
} zglTSound, *zglPSound;

typedef struct
{
  DWORD _File;
  void* CodecRead; /* DWORD func( void* Buffer, DWORD Count ) : DWORD */
  void* CodecLoop; /* void func(void) */
  DWORD Rate;
  DWORD Channels;
  void* Buffer;
  DWORD BufferSize;
  bool  Loop;
  bool  Played;
} zglTSoundFile, *zglPSoundFile;

ZGLIMPORT bool      snd_Init(void);
ZGLIMPORT void      snd_Free(void);
ZGLIMPORT zglPSound snd_Add( int BufferCount, int SourceCount );
ZGLIMPORT void      snd_Del( zglPSound Sound );
ZGLIMPORT zglPSound snd_LoadFromFile( char* FileName, int SourceCount );
ZGLIMPORT int       snd_Play( zglPSound Sound, float X, float Y, float Z, bool Loop );
ZGLIMPORT void      snd_Stop( zglPSound Sound, int Source );
ZGLIMPORT void      snd_SetVolume( byte Volume );
ZGLIMPORT void      snd_PlayFile( zglPSoundFile SoundFile );
ZGLIMPORT void      snd_StopFile(void);
ZGLIMPORT void      snd_RestoreFile(void);

/* 3D */
typedef struct
{
  float X;
  float Y;
  float Z;
} zglTPoint3D, *zglPPoint3D;

typedef zglTPoint3D *zglTMatrix3f;
typedef zglTMatrix3f *zglPMatrix3f;
  
typedef float zglTMatrix4f[3][3];
typedef zglTMatrix4f *zglPMatrix4f;
  
typedef struct
{
  DWORD vIndex[3];
  DWORD tIndex[3];
} zglTFace, *zglPFace;

typedef struct
{
  DWORD FCount;
  DWORD IFace;
  void* Indices;
} zglTGroup, *zglPGroup;

typedef struct
{
  zglTPoint3D *Vertices;
  zglTPoint3D *Normals;
} zglTFrame, *zglPFrame;

typedef struct
{
  zglTPoint3D p1;
  zglTPoint3D p2;
} zglTLine3D, *zglPLine3D;

typedef struct
{
  zglTPoint3D Points[3];
  float       D;
  zglTPoint3D Normal;
} zglTPlane, *zglPPlane;

typedef struct
{
  zglTPoint3D Position;
  zglTPoint3D Size;
} zglTAABB, *zglPAABB;

typedef struct
{
  zglTPoint3D  Position;
  zglTPoint3D  Size;
  zglTMatrix3f Matrix;
} zglTOBB, *zglPOBB;

typedef struct
{
  zglTPoint3D Position;
  float       Radius;
} zglTSphere, *zglPSphere;
  
/* Z BUFFER */
ZGLIMPORT void zbuffer_SetDepth( float zNear, float zFar );
ZGLIMPORT void zbuffer_Clear(void);
  
/* SCISSOR */
ZGLIMPORT void scissor_Begin( WORD X, WORD Y, WORD Width, WORD Height );
ZGLIMPORT void scissor_End(void);
  
/* OBJECT 3D */
#define OBJ3D_TEXTURING     0x0000001
#define OBJ3D_MTEXTURING    0x0000002
#define OBJ3D_BLEND         0x0000004
#define OBJ3D_ALPHA_TEST    0x0000008
#define OBJ3D_WIRE_FRAME    0x0000010
#define OBJ3D_CULL_FACE     0x0000020
#define OBJ3D_LIGHTING      0x0000040

#define MAT_DIFFUSE         0x01
#define MAT_AMBIENT         0x02
#define MAT_SPECULAR        0x03
#define MAT_SHININESS       0x04
#define MAT_EMISSION        0x05

#define SIDE_FRONT          0x01
#define SIDE_BACK           0x02
#define SIDE_FRONT_AND_BACK 0x03
  
ZGLIMPORT void obj3d_Begin( DWORD Flags );
ZGLIMPORT void obj3d_End(void);
ZGLIMPORT void obj3d_Enable( DWORD Flags );
ZGLIMPORT void obj3d_Disable( DWORD Flags );
ZGLIMPORT void obj3d_SetColor( DWORD Color, byte Alpha );
ZGLIMPORT void obj3d_BindTexture( zglPTexture Texture, byte Level );
ZGLIMPORT void obj3d_SetMaterial( byte Material, byte Side, DWORD Color, byte Alpha );
ZGLIMPORT void obj3d_Scale( float ScaleX, float ScaleY, float ScaleZ );
ZGLIMPORT void obj3d_Move( float X, float Y, float Z );
  
#define AX 0x01
#define AY 0x02
#define AZ 0x04

ZGLIMPORT void obj3d_Rotate( float Angle, byte Axis );

/* CAMERA 3D */
typedef struct
{
  zglTPoint3D  Position;
  zglTPoint3D  Rotation;
  zglTMatrix4f Matrix;
} zglTCamera3D, *zglPCamera3D;

ZGLIMPORT void cam3d_Set( zglPCamera3D Camera );
ZGLIMPORT void cam3d_Fly( zglPCamera3D Camera, float Speed );
ZGLIMPORT void cam3d_Strafe( zglPCamera3D Camera, float Speed );
  
/* STATIC MESH */
typedef struct
{
  DWORD Flags;

  DWORD VCount;
  DWORD TCount;
  DWORD FCount;
  DWORD GCount;

  zglTPoint3D *Vertices;
  zglTPoint3D *Normals;
  zglTPoint2D *TexCoords;
  zglTPoint2D *MultiTexCoords;
  zglTFace    *Faces;
  void*       Indices;
  zglTGroup   *Groups;
} zglTSMesh, *zglPSMesh;

ZGLIMPORT bool smesh_LoadFromFile( char* FileName, zglPSMesh Mesh );
ZGLIMPORT void smesh_Draw( zglPSMesh Mesh );
ZGLIMPORT void smesh_DrawGroup( zglPSMesh Mesh, DWORD Group );
  
/* VBO */
#define VBO_USE_NORMALS   0x01
#define VBO_USE_TEXTURE   0x02
#define VBO_USE_MULTITEX1 0x04
#define VBO_USE_MULTITEX2 0x08
#define VBO_USE_MULTITEX3 0x10
#define VBO_CLEARDATA     0x20
  
ZGLIMPORT void vbo_Build( DWORD *IBuffer, DWORD *VBuffer, DWORD VCount, DWORD ICount, void* Indices, void* Vertices, void* Normals, void* TexCoords, void* MultiTexCoords, DWORD *Flags );
ZGLIMPORT void vbo_Free( DWORD *IBuffer, DWORD *VBuffer, DWORD VCount, DWORD ICount, void* Indices, void* Vertices );

/* FRUSTUM */
typedef float zglTFrustum[6][4];
typedef zglTFrustum *zglPFrustum;
  
ZGLIMPORT void frustum_Calc( zglPFrustum f );
ZGLIMPORT bool frustum_PointIn( zglPFrustum f, float x, float y, float z );
ZGLIMPORT bool frustum_PPointIn( zglPFrustum f, zglPPoint3D Vertex );
ZGLIMPORT bool frustum_TriangleIn( zglPFrustum f, zglTPoint3D v1, zglTPoint3D v2, zglTPoint3D v3 );
ZGLIMPORT bool frustum_SphereIn( zglPFrustum f, float x, float y, float z, float r );
ZGLIMPORT bool frustum_BoxIn( zglPFrustum f, float x, float y, float z, float bx, float by, float bz );
ZGLIMPORT bool frustum_CubeIn( zglPFrustum f, float x, float y, float z, float size );
  
/* OCTREE */
typedef struct
{
  DWORD Texture;
  DWORD ICount;
  void* Indices;
  DWORD IBuffer;
  DWORD IBType;
} zglTRenderData, *zglPRenderData;

typedef struct
{
  zglTAABB Cube;

  DWORD          RDSize;
  zglTRenderData *RenderData;
  DWORD          DFCount;
  DWORD          *DFaces;
  DWORD          PCount;
  DWORD          *Planes;

  bool           NInside;
  void*          SubNodes[8];
} zglTNode, *zglPNode;

typedef struct
{
  DWORD Flags;
  DWORD VBOFlags;

  DWORD IBuffer;
  DWORD VBuffer;

  zglPNode MainNode;

  DWORD VCount;
  DWORD TCount;
  DWORD FCount;
  DWORD ICount;

  zglTPoint3D *Vertices;
  zglTPoint3D *TexCoords;
  zglTPoint2D *MultiTexCoords;
  zglTPoint3D *Normals;
  zglTFace    *Faces;
  void*       Indices;
  DWORD       *Textures;
  zglTPlane   *Planes;

  DWORD MaxDFaces;
  DWORD *DFaces;

  DWORD *r_DFacesAlready;
  DWORD r_DFacesCount;
  DWORD r_DFacesACount ;

  DWORD r_NodeACount;
} zglTOctree, *zglPOctree;

#define OCTREE_USE_TEXTURE     0x001
#define OCTREE_USE_MULTITEX1   0x002
#define OCTREE_USE_MULTITEX2   0x004
#define OCTREE_USE_MULTITEX3   0x008
#define OCTREE_USE_NORMALS     0x010
#define OCTREE_BUILD_FNORMALS  0x020
#define OCTREE_BUILD_SNORMALS  0x040 /* пока нету :) */
#define OCTREE_BUILD_VBO       0x080
#define OCTREE_BUILD_PLANES    0x100

ZGLIMPORT void octree_Build( zglPOctree Octree, DWORD MaxFacesPerNode, DWORD Flags );
ZGLIMPORT void octree_Free( zglPOctree Octree );
ZGLIMPORT void octree_Draw( zglPOctree Octree, zglPFrustum Frustum );
ZGLIMPORT void octree_DrawDebug( zglPOctree Octree, zglPFrustum Frustum );
ZGLIMPORT void octree_DrawNode( zglPOctree Octree, zglPNode Node, zglPFrustum Frustum );
  
/*/ LIGHT */
ZGLIMPORT void light_Enable( byte ID );
ZGLIMPORT void light_Disable( byte ID );
ZGLIMPORT void light_SetPosition( byte ID, float X, float Y, float Z );
ZGLIMPORT void light_SetMaterial( byte ID, byte Material, DWORD Color, byte Alpha );

  
/* FOG */
ZGLIMPORT void fog_Enable();
ZGLIMPORT void fog_Disable();

#define FOG_MODE_EXP    0
#define FOG_MODE_EXP2   1
#define FOG_MODE_LINEAR 2

ZGLIMPORT void fog_SetMode( byte Mode );
ZGLIMPORT void fog_SetColor( DWORD Color );
ZGLIMPORT void fog_SetDensity( float Density );
ZGLIMPORT void fog_SetBeginEnd( float fBegin, float fEnd );
  
/* SKYBOX */
ZGLIMPORT void skybox_Init( zglPTexture Top, zglPTexture Bottom, zglPTexture Left, zglPTexture Right, zglPTexture Front, zglPTexture Back );
ZGLIMPORT void skybox_Draw();
  
/* SHADERS */
#define SHADER_ARB          0
#define SHADER_GLSL         1
#define SHADER_VERTEX_ARB   0x8620
#define SHADER_FRAGMENT_ARB 0x8804
#define SHADER_VERTEX       0x8B31
#define SHADER_FRAGMENT     0x8B30

/* ARBfp/ARBvp */
ZGLIMPORT bool  shader_InitARB();
ZGLIMPORT DWORD shader_LoadFromFileARB( const char* FileName, DWORD ShaderType );
ZGLIMPORT void  shader_BeginARB( DWORD Shader, DWORD ShaderType );
ZGLIMPORT void  shader_EndARB( DWORD ShaderType );
ZGLIMPORT void  shader_FreeARB( DWORD Shader );

/* GLSL */
ZGLIMPORT bool  shader_InitGLSL();
ZGLIMPORT DWORD shader_LoadFromFile( const char* FileName, int ShaderType, bool Link );
ZGLIMPORT void  shader_Attach( DWORD Attach );
ZGLIMPORT void  shader_BeginLink();
ZGLIMPORT DWORD shader_EndLink();
ZGLIMPORT void  shader_Begin( DWORD Shader );
ZGLIMPORT void  shader_End();
ZGLIMPORT void  shader_Free( DWORD Shader );
ZGLIMPORT int   shader_GetUniform( DWORD Shader, const char* UniformName );
ZGLIMPORT void  shader_SetUniform1f( int Uniform, float v1 );
ZGLIMPORT void  shader_SetUniform1i( int Uniform, int v1 );
ZGLIMPORT void  shader_SetUniform2f( int Uniform, float v1, float v2 );
ZGLIMPORT void  shader_SetUniform3f( int Uniform, float v1, float v2, float v3 );
ZGLIMPORT void  shader_SetUniform4f( int Uniform, float v1, float v2, float v3, float v4 );
ZGLIMPORT int   shader_GetAttrib( DWORD Shader, const char* AttribName );
/* glVertexAttrib* GLSL/ARB */
ZGLIMPORT void shader_SetAttrib1f( int Attrib, float v1 );
ZGLIMPORT void shader_SetAttrib2f( int Attrib, float v1, float v2 );
ZGLIMPORT void shader_SetAttrib3f( int Attrib, float v1, float v2, float v3 );
ZGLIMPORT void shader_SetAttrib4f( int Attrib, float v1, float v2, float v3, float v4 );
ZGLIMPORT void shader_SetAttribPf( int Attrib, void* v, bool Normalized );
ZGLIMPORT void shader_SetParameter4f( DWORD ShaderType, int Parameterm, float v1, float v2, float v3, float v4 );
  
/* MATH */
ZGLIMPORT int   m_Round( float value );
ZGLIMPORT float m_Cos( int Angle );
ZGLIMPORT float m_Sin( int Angle );
ZGLIMPORT float m_Distance( float x1, float y1, float x2, float y2 );
ZGLIMPORT float m_FDistance( float x1, float y1, float x2, float y2 );
  /* vectros */
ZGLIMPORT zglTPoint3D vector_Get( float x, float y, float z );
ZGLIMPORT zglTPoint3D vector_Add( zglTPoint3D Vector1, zglTPoint3D Vector2 );
ZGLIMPORT zglTPoint3D vector_Sub( zglTPoint3D Vector1, zglTPoint3D Vector2 );
ZGLIMPORT zglTPoint3D vector_Mul( zglTPoint3D Vector1, zglTPoint3D Vector2 );
ZGLIMPORT zglTPoint3D vector_Div( zglTPoint3D Vector1, zglTPoint3D Vector2 );
ZGLIMPORT zglTPoint3D vector_AddV( zglTPoint3D Vector, float Value );
ZGLIMPORT zglTPoint3D vector_SubV( zglTPoint3D Vector, float Value );
ZGLIMPORT zglTPoint3D vector_MulV( zglTPoint3D Vector, float Value );
ZGLIMPORT zglTPoint3D vector_DivV( zglTPoint3D Vector, float Value );
ZGLIMPORT zglTPoint3D vector_MulM3f( zglTPoint3D Vector, zglPMatrix3f Matrix );
ZGLIMPORT zglTPoint3D vector_Negate( zglTPoint3D Vector );
ZGLIMPORT zglTPoint3D vector_Normalize( zglTPoint3D Vector );
ZGLIMPORT float       vector_Angle( zglTPoint3D Vector1, zglTPoint3D Vector2 );
ZGLIMPORT zglTPoint3D vector_Cross( zglTPoint3D Vector1, zglTPoint3D Vector2 );
ZGLIMPORT float       vector_Dot( zglTPoint3D Vector1, zglTPoint3D Vector2 );
ZGLIMPORT float       vector_Distance( zglTPoint3D Vector1, zglTPoint3D Vector2 );
ZGLIMPORT float       vector_FDistance( zglTPoint3D Vector1, zglTPoint3D Vector2 );
ZGLIMPORT float       vector_Length( zglTPoint3D Vector );
  /* matrix */
ZGLIMPORT zglTMatrix3f matrix3f_Get( zglTPoint3D v1, zglTPoint3D v2, zglTPoint3D v3 );
ZGLIMPORT void         matrix3f_Identity( zglPMatrix3f Matrix );
ZGLIMPORT void         matrix3f_OrthoNormalize( zglPMatrix3f Matrix );
ZGLIMPORT void         matrix3f_Transpose( zglPMatrix3f Matrix );
ZGLIMPORT void         matrix3f_RotateRad( zglPMatrix3f Matrix, float aX, float aY, float aZ );
ZGLIMPORT void         matrix3f_RotateDeg( zglPMatrix3f Matrix, float aX, float aY, float aZ );
ZGLIMPORT void         matrix3f_Add( zglPMatrix3f Matrix1, zglPMatrix3f Matrix2 );
ZGLIMPORT void         matrix3f_Mul( zglPMatrix3f Matrix1, zglPMatrix3f Matrix2 );
  /* line 3d */
ZGLIMPORT zglTPoint3D line3d_ClosestPoint( zglTPoint3D A, zglTPoint3D B, zglTPoint3D Point );
  /* plane */
ZGLIMPORT zglTPlane plane_Get( zglTPoint3D A, zglTPoint3D B, zglTPoint3D C );
ZGLIMPORT float     plane_Distance( zglTPlane Plane, zglTPoint3D Point );
  /* triangle */
ZGLIMPORT zglTPoint3D tri_GetNormal( zglTPoint3D A, zglTPoint3D B, zglTPoint3D C );

/* COLLISION 2D */
  /* point */
ZGLIMPORT bool col2d_PointInRect( float X, float Y, zglPRect Rect );
ZGLIMPORT bool col2d_PointInCircle( float X, float Y, zglPCircle Circ );
ZGLIMPORT bool col2d_PointInPolyLine( float X, float Y, zglPPolyLine PL );
  /* line 2d */
ZGLIMPORT bool col2d_Line( zglPLine A, zglPLine B );
ZGLIMPORT bool col2d_LineVsRect( zglPLine A, zglPRect Rect );
ZGLIMPORT bool col2d_LineVsCircle( zglPLine L, zglPCircle Circ );
ZGLIMPORT bool col2d_LineVsCircleXY( zglPLine L, zglPCircle Circ, byte Precision );
ZGLIMPORT bool col2d_LineVsPolyLine( zglPLine A, zglPPolyLine PL );
  /* polyline */
ZGLIMPORT bool col2d_PolyLine( zglPPolyLine A, zglPPolyLine B );
ZGLIMPORT bool col2d_PolyLineVsRect( zglPPolyLine A, zglPRect Rect );
ZGLIMPORT bool col2d_PolyLineVsCircle( zglPPolyLine A, zglPCircle Circ );
ZGLIMPORT bool col2d_PolyLineVsCircleXY( zglPPolyLine A, zglPCircle Circ, int Precision );
  /* rect */
ZGLIMPORT bool col2d_Rect( zglPRect Rect1, zglPRect Rect2 );
ZGLIMPORT bool col2d_RectInRect( zglPRect Rect1, zglPRect Rect2 );
ZGLIMPORT bool col2d_RectInCircle( zglPRect Rect, zglPCircle Circ );
ZGLIMPORT bool col2d_RectVsCircle( zglPRect Rect, zglPCircle Circ );
  /* circle */
ZGLIMPORT bool col2d_Circle( zglPCircle Circ1, zglPCircle Circ2 );
ZGLIMPORT bool col2d_CircleInCircle( zglPCircle Circ1, zglPCircle Circ2 );
ZGLIMPORT bool col2d_CircleInRect( zglPCircle Circ, zglPRect Rect );
  /* extended */
float col2dEx_LastX(void);
float col2dEx_LastY(void);
int   col2dEx_LastLineA(void);
int   col2dEx_LastLineB(void);
  /* polyline transformations */
ZGLIMPORT void col2dEx_PolyRotate( zglPPolyLine A, zglPPolyLine B, float Angle );
ZGLIMPORT void col2dEx_PolyScale( zglPPolyLine A, float ScaleX, float ScaleY );
ZGLIMPORT void col2dEx_PolyMove( zglPPolyLine A, zglPPolyLine B, float X, float Y );
ZGLIMPORT void col2dEx_PolyCenter( zglPPolyLine A );
ZGLIMPORT void col2dEx_PolyRect( zglPPolyLine A, zglPRect Rect );
  /* line */
ZGLIMPORT void col2dEx_CalcLineCross( zglPLine A, zglPLine B );
  
/* COLLISION 3D */
/*typedef void func( zglPPoint3D Offset ) zglTCol3DCallback;
typedef zglTCol3DCallback *zglPCol3DCallback;*/
  
  /* point 3D */
ZGLIMPORT bool col3d_PointInTri( zglPPoint3D Point, zglPPoint3D A, zglPPoint3D B, zglPPoint3D C );
ZGLIMPORT bool col3d_PointInAABB( zglPPoint3D Point, zglPAABB AABB );
ZGLIMPORT bool col3d_PointInOBB( zglPPoint3D Point, zglPOBB OBB );
ZGLIMPORT bool col3d_PointInSphere( zglPPoint3D Point, zglPSphere Sphere );
  /* line3D */
ZGLIMPORT bool col3d_LineVsAABB( zglPLine3D Line, zglPAABB AABB );
ZGLIMPORT bool col3d_LineVsOBB( zglPLine3D Line, zglPOBB OBB );
ZGLIMPORT bool col3d_LineVsSphere( zglPLine3D Line, zglPSphere Sphere );
  /* plane 3d */
ZGLIMPORT bool col3d_PlaneVsSphere( zglPPlane Plane, zglPSphere Sphere, void* Callback );
  /* aabb */
ZGLIMPORT bool col3d_AABBVsAABB( zglPAABB AABB1, zglPAABB AABB2 );
ZGLIMPORT bool col3d_AABBVsOBB( zglPAABB AABB, zglPOBB OBB );
ZGLIMPORT bool col3d_AABBVsSphere( zglPAABB AABB, zglPSphere Sphere );
  /* obb */
ZGLIMPORT bool col3d_OBBVsOBB( zglPOBB OBB1, zglPOBB OBB2 );
ZGLIMPORT bool col3d_OBBVsSphere( zglPOBB OBB, zglPSphere Sphere );
  /* sphere */
ZGLIMPORT bool col3d_SphereVsSphere( zglPSphere Sphere1, zglPSphere Sphere );
ZGLIMPORT bool col3d_SphereVsNode( zglPSphere Sphere, zglPOctree Octree, zglPNode Node, void* Callback );

typedef DWORD zglTFile;
/* Open Mode */
#define FOM_CREATE 0x01 /* Create */
#define FOM_OPENR  0x02 /* Read */
#define FOM_OPENRW 0x03 /* Read&Write */
  
/* Seek Mode */
#define FSM_SET 0x01
#define FSM_CUR 0x02
#define FSM_END 0x03

ZGLIMPORT void  file_Open( zglTFile *FileHandle, const char* FileName, byte Mode );
ZGLIMPORT bool  file_Exists( const char* FileName );
ZGLIMPORT DWORD file_Seek( zglTFile FileHandle, DWORD Offset, byte Mode );
ZGLIMPORT DWORD file_GetPos( zglTFile FileHandle );
ZGLIMPORT DWORD file_Read( zglTFile FileHandle, int *buffer, DWORD count );
ZGLIMPORT DWORD file_Write( zglTFile FileHandle, int *buffer, DWORD count );
ZGLIMPORT void  file_Trunc( zglTFile FileHandle, DWORD count );
ZGLIMPORT DWORD file_GetSize( zglTFile FileHandle );
ZGLIMPORT void  file_Flush( zglTFile FileHandle );
ZGLIMPORT void  file_Close( zglTFile FileHandle );

typedef struct
{
  void* Memory;
  DWORD Size;
  DWORD Position;
} zglTMemory, *zglPMemory;

ZGLIMPORT void  mem_LoadFromFile( zglTMemory *Memory, const char* FileName );
ZGLIMPORT void  mem_SaveToFile( zglTMemory *Memory, const char* FileName );
ZGLIMPORT DWORD mem_Seek( zglTMemory *Memory, DWORD Offset, byte Mode );
ZGLIMPORT DWORD mem_Read( zglTMemory *Memory, int *buffer, DWORD count );
ZGLIMPORT DWORD mem_Write( zglTMemory *Memory, int *buffer, DWORD count );
ZGLIMPORT void  mem_SetSize( zglTMemory *Memory, DWORD Size );
ZGLIMPORT void  mem_Free( zglTMemory *Memory );

#endif
