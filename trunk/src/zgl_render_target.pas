{
 *  Copyright © Kemka Andrey aka Andru
 *  mail: dr.andru@gmail.com
 *  site: http://andru-kun.inf.ua
 *
 *  This file is part of ZenGL.
 *
 *  ZenGL is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public Licens as
 *  published by the Free Software Foundation, either version 3 of
 *  the License, or (at your option) any later version.
 *
 *  ZenGL is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with ZenGL. If not, see http://www.gnu.org/licenses/
}
unit zgl_render_target;

{$I zgl_config.cfg}

interface
uses
  {$IFDEF LINUX}
  X, XLib, XUtil,
  {$ENDIF}
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  {$IFDEF DARWIN}
  MacOSAll,
  {$ENDIF}
  zgl_opengl,
  zgl_opengl_all,
  zgl_textures;

const
  RT_TYPE_SIMPLE  = 0;
  RT_TYPE_FBO     = 1;
  RT_TYPE_PBUFFER = 2;
  RT_FULL_SCREEN  = $01;
  RT_CLEAR_SCREEN = $02;

type
  zglPFBO = ^zglTFBO;
  zglTFBO = record
    FrameBuffer  : LongWord;
    RenderBuffer : LongWord;
end;

{$IFDEF LINUX}
type
  zglPPBuffer = ^zglTPBuffer;
  zglTPBuffer = record
    Handle  : Integer;
    Context : GLXContext;
    PBuffer : GLXPBuffer;
end;
{$ENDIF}
{$IFDEF WINDOWS}
type
  zglPPBuffer = ^zglTPBuffer;
  zglTPBuffer = record
    Handle : THandle;
    DC     : HDC;
    RC     : HGLRC;
end;
{$ENDIF}
{$IFDEF DARWIN}
type
  zglPPBuffer = ^zglTPBuffer;
  zglTPBuffer = record
    Context : TAGLContext;
    PBuffer : TAGLPbuffer;
end;
{$ENDIF}

type
  zglPRenderTarget = ^zglTRenderTarget;
  zglTRenderTarget = record
    _type      : Byte;
    Handle     : Pointer;
    Surface    : zglPTexture;
    Flags      : Byte;

    prev, next : zglPRenderTarget;
end;

type
  zglPRenderTargetManager = ^zglTRenderTargetManager;
  zglTRenderTargetManager = record
    Count : LongWord;
    First : zglTRenderTarget;
end;

type
  zglTRenderCallback = procedure( Data : Pointer );

function  rtarget_Add( _type : Byte; const Surface : zglPTexture; const Flags : Byte ) : zglPRenderTarget;
procedure rtarget_Del( var Target : zglPRenderTarget );
procedure rtarget_Set( const Target : zglPRenderTarget );
procedure rtarget_DrawIn( const Target : zglPRenderTarget; const RenderCallback : zglTRenderCallback; const Data : Pointer );

var
  managerRTarget : zglTRenderTargetManager;

implementation
uses
  zgl_application,
  zgl_main,
  zgl_window,
  zgl_screen,
  zgl_opengl_simple,
  zgl_render_2d,
  zgl_sprite_2d,
  zgl_log;

var
  lRTarget : zglPRenderTarget;
  lMode : Integer;

function rtarget_Add;
  var
    pFBO     : zglPFBO;
    pPBuffer : zglPPBuffer;
{$IFDEF LINUX}
    n            : Integer;
    fbconfig     : GLXFBConfig;
    visualinfo   : PXVisualInfo;
    pbufferiAttr : array[ 0..8 ] of Integer;
    fbconfigAttr : array[ 0..15 ] of Integer;
{$ENDIF}
{$IFDEF WINDOWS}
    pbufferiAttr : array[ 0..15 ] of Integer;
    pbufferfAttr : array[ 0..15 ] of Single;
    pixelFormat  : array[ 0..63 ] of Integer;
    nPixelFormat : LongWord;
{$ENDIF}
{$IFDEF DARWIN}
    i            : Integer;
    pbufferdAttr : array[ 0..31 ] of LongWord;
{$ENDIF}
begin
  Result := @managerRTarget.First;
  while Assigned( Result.next ) do
    Result := Result.next;

  zgl_GetMem( Pointer( Result.next ), SizeOf( zglTRenderTarget ) );

  if ( not ogl_CanFBO ) and ( _type = RT_TYPE_FBO ) Then
    if ogl_CanPBuffer Then
      _type := RT_TYPE_PBUFFER
    else
      _type := RT_TYPE_SIMPLE;

  if ( not ogl_CanPBuffer ) and ( _type = RT_TYPE_PBUFFER ) Then
    if ogl_CanFBO Then
      _type := RT_TYPE_FBO
    else
      _type := RT_TYPE_SIMPLE;

  case _type of
    RT_TYPE_SIMPLE: Result.next.Handle := nil;
    RT_TYPE_FBO:
      begin
        zgl_GetMem( Result.next.Handle, SizeOf( zglTFBO ) );
        pFBO := Result.next.Handle;

        glGenFramebuffersEXT( 1, @pFBO.FrameBuffer );
        glBindFramebufferEXT( GL_FRAMEBUFFER_EXT, pFBO.FrameBuffer );
        if glIsFrameBufferEXT( pFBO.FrameBuffer ) = GL_TRUE Then
          log_Add( 'FBO: Gen FrameBuffer - Success' )
        else
          begin
            log_Add( 'FBO: Gen FrameBuffer - Error' );
            exit;
          end;

        glGenRenderbuffersEXT( 1, @pFBO.RenderBuffer );
        glBindRenderbufferEXT( GL_RENDERBUFFER_EXT, pFBO.RenderBuffer );
        if glIsRenderBufferEXT( pFBO.RenderBuffer ) = GL_TRUE Then
          log_Add( 'FBO: Gen RenderBuffer - Success' )
        else
          begin
            log_Add( 'FBO: Gen RenderBuffer - Error' );
            exit;
          end;

        case ogl_zDepth of
          24: glRenderbufferStorageEXT( GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT24, Round( Surface.Width / Surface.U ), Round( Surface.Height / Surface.V ) );
          32: glRenderbufferStorageEXT( GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT32, Round( Surface.Width / Surface.U ), Round( Surface.Height / Surface.V ) );
        else
          glRenderbufferStorageEXT( GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT16, Round( Surface.Width / Surface.U ), Round( Surface.Height / Surface.V ) );
        end;
        glFramebufferRenderbufferEXT( GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, pFBO.RenderBuffer );
        glFramebufferTexture2DEXT( GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, 0, 0 );
        glBindFramebufferEXT( GL_FRAMEBUFFER_EXT, 0 );
      end;
    {$IFDEF LINUX}
    RT_TYPE_PBUFFER:
      begin
        zgl_GetMem( Result.next.Handle, SizeOf( zglTPBuffer ) );
        pPBuffer := Result.next.Handle;

        fbconfigAttr[ 0 ]  := GLX_DOUBLEBUFFER;
        fbconfigAttr[ 1 ]  := GL_FALSE;
        fbconfigAttr[ 2 ]  := GLX_ALPHA_SIZE;
        fbconfigAttr[ 3 ]  := 8 * Byte( Surface.Flags and TEX_RGB = 0 );
        fbconfigAttr[ 4 ]  := GLX_DEPTH_SIZE;
        fbconfigAttr[ 5 ]  := ogl_zDepth;
        fbconfigAttr[ 6 ]  := GLX_RENDER_TYPE;
        fbconfigAttr[ 7 ]  := GL_TRUE; //GLX_RGBA_BIT,
        fbconfigAttr[ 8 ]  := GLX_DRAWABLE_TYPE;
        fbconfigAttr[ 9 ]  := GLX_PBUFFER_BIT;
        fbconfigAttr[ 10 ] := None;

        fbconfig := glXChooseFBConfig( scr_Display, scr_Default, @fbconfigAttr[ 0 ], @n );
        if not Assigned( fbconfig ) Then
          begin
            log_Add( 'PBuffer: failed to choose GLXFBConfig' );
            ogl_CanPBuffer := FALSE;
            exit;
          end else
            pPBuffer.Handle := PInteger( fbconfig )^;

        case ogl_PBufferMode of
          1:
            begin
              pbufferiAttr[ 0 ] := GLX_PBUFFER_WIDTH;
              pbufferiAttr[ 1 ] := Round( Surface.Width / Surface.U );
              pbufferiAttr[ 2 ] := GLX_PBUFFER_HEIGHT;
              pbufferiAttr[ 3 ] := Round( Surface.Height / Surface.V );
              pbufferiAttr[ 4 ] := GLX_PRESERVED_CONTENTS;
              pbufferiAttr[ 5 ] := GL_TRUE;
              pbufferiAttr[ 6 ] := GLX_LARGEST_PBUFFER;
              pbufferiAttr[ 7 ] := GL_TRUE;
              pbufferiAttr[ 8 ] := None;

              pPBuffer.PBuffer := glXCreatePbuffer( scr_Display, pPBuffer.Handle, @pbufferiAttr[ 0 ] );
            end;
          2:
            begin
              pbufferiAttr[ 0 ] := GLX_PRESERVED_CONTENTS;
              pbufferiAttr[ 1 ] := GL_TRUE;
              pbufferiAttr[ 2 ] := GLX_LARGEST_PBUFFER;
              pbufferiAttr[ 3 ] := GL_TRUE;
              pbufferiAttr[ 4 ] := None;

              pPBuffer.PBuffer := glXCreateGLXPbufferSGIX( scr_Display, pPBuffer.Handle, Surface.Width, Surface.Height, @pbufferiAttr[ 0 ] );
            end;
        end;

        if pPBuffer.PBuffer = 0 Then
          begin
            log_Add( 'PBuffer: failed to create GLXPBuffer' );
            ogl_CanPBuffer := FALSE;
            exit;
          end;

        visualinfo := glXGetVisualFromFBConfig( scr_Display, pPBuffer.Handle );
        if not Assigned( visualinfo ) Then
          begin
            log_Add( 'PBuffer: failed to choose Visual' );
            ogl_CanPBuffer := FALSE;
            exit;
          end;

        pPBuffer.Context := glXCreateContext( scr_Display, visualinfo, ogl_Context, TRUE );
        XFree( fbconfig );
        XFree( visualinfo );
        if pPBuffer.Context = nil Then
          begin
            log_Add( 'PBuffer: failed to create GLXContext' );
            ogl_CanPBuffer := FALSE;
            exit;
          end;

        glXMakeCurrent( scr_Display, pPBuffer.PBuffer, pPBuffer.Context );
        gl_ResetState();
        Set2DMode();
        glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT );
        ssprite2d_Draw( Surface, 0, ogl_Height - Surface.Height, ogl_Width - ( ogl_Width - Surface.Width ), ogl_Height - ( ogl_Height - Surface.Height ), 0, 255 );
        glXMakeCurrent( scr_Display, wnd_Handle, ogl_Context );
      end;
    {$ENDIF}
    {$IFDEF WINDOWS}
    RT_TYPE_PBUFFER:
      begin
        zgl_GetMem( Result.next.Handle, SizeOf( zglTPBuffer ) );
        pPBuffer := Result.next.Handle;

        FillChar( pbufferiAttr[ 0 ], 16 * 4, 0 );
        FillChar( pbufferfAttr[ 0 ], 16 * 4, 0 );
        pbufferiAttr[ 0  ] := WGL_DRAW_TO_PBUFFER_ARB;
        pbufferiAttr[ 1  ] := GL_TRUE;
        pbufferiAttr[ 2  ] := WGL_DOUBLE_BUFFER_ARB;
        pbufferiAttr[ 3  ] := GL_FALSE;
        pbufferiAttr[ 4  ] := WGL_COLOR_BITS_ARB;
        pbufferiAttr[ 5  ] := scr_BPP;
        pbufferiAttr[ 6  ] := WGL_DEPTH_BITS_ARB;
        pbufferiAttr[ 7  ] := ogl_zDepth;
        pbufferiAttr[ 8  ] := WGL_STENCIL_BITS_ARB;
        pbufferiAttr[ 9  ] := ogl_Stencil;
        pbufferiAttr[ 10 ] := WGL_ALPHA_BITS_ARB;
        pbufferiAttr[ 11 ] := 8 * Byte( Surface.Flags and TEX_RGB = 0 );

        wglChoosePixelFormatARB( wnd_DC, @pbufferiAttr[ 0 ], @pbufferfAttr[ 0 ], 64, @pixelFormat, @nPixelFormat );

        pPBuffer.Handle := wglCreatePbufferARB( wnd_DC, PixelFormat[ 0 ], Round( Surface.Width / Surface.U ), Round( Surface.Height / Surface.V ), nil );
        if pPBuffer.Handle <> 0 Then
          begin
            pPBuffer.DC := wglGetPbufferDCARB( pPBuffer.Handle );
            pPBuffer.RC := wglCreateContext( pPBuffer.DC );
            if pPBuffer.RC = 0 Then
              begin
                log_Add( 'PBuffer: RC create - Error' );
                ogl_CanPBuffer := FALSE;
                exit;
              end;
            wglShareLists( ogl_Context, pPBuffer.RC );
          end else
            begin
              log_Add( 'PBuffer: wglCreatePbufferARB - failed' );
              ogl_CanPBuffer := FALSE;
              exit;
            end;
        wglMakeCurrent( pPBuffer.DC, pPBuffer.RC );
        gl_ResetState();
        Set2DMode();
        glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT );
        ssprite2d_Draw( Surface, 0, ogl_Height - Surface.Height, ogl_Width - ( ogl_Width - Surface.Width ), ogl_Height - ( ogl_Height - Surface.Height ), 0, 255 );
        wglMakeCurrent( wnd_DC, ogl_Context );
      end;
    {$ENDIF}
    {$IFDEF DARWIN}
    RT_TYPE_PBUFFER:
      begin
        zgl_GetMem( Result.next.Handle, SizeOf( zglTPBuffer ) );
        pPBuffer := Result.next.Handle;

        pbufferdAttr[ 0  ] := AGL_RGBA;
        pbufferdAttr[ 1  ] := GL_TRUE;
        pbufferdAttr[ 2  ] := AGL_RED_SIZE;
        pbufferdAttr[ 3  ] := 8;
        pbufferdAttr[ 4  ] := AGL_GREEN_SIZE;
        pbufferdAttr[ 5  ] := 8;
        pbufferdAttr[ 6  ] := AGL_BLUE_SIZE;
        pbufferdAttr[ 7  ] := 8;
        pbufferdAttr[ 8  ] := AGL_ALPHA_SIZE;
        pbufferdAttr[ 9  ] := 8;
        pbufferdAttr[ 10 ] := AGL_DEPTH_SIZE;
        pbufferdAttr[ 11 ] := ogl_zDepth;
        pbufferdAttr[ 12 ] := AGL_DOUBLEBUFFER;
        i := 13;
        if ogl_Stencil > 0 Then
          begin
            pbufferdAttr[ i     ] := AGL_STENCIL_SIZE;
            pbufferdAttr[ i + 1 ] := ogl_Stencil;
            INC( i, 2 );
          end;
        if ogl_FSAA > 0 Then
          begin
            pbufferdAttr[ i     ] := AGL_SAMPLE_BUFFERS_ARB;
            pbufferdAttr[ i + 1 ] := 1;
            pbufferdAttr[ i + 2 ] := AGL_SAMPLES_ARB;
            pbufferdAttr[ i + 3 ] := ogl_FSAA;
            INC( i, 4 );
          end;
        pbufferdAttr[ i ] := AGL_NONE;

        DMGetGDeviceByDisplayID( DisplayIDType( scr_Display ), ogl_Device, FALSE );
        ogl_Format := aglChoosePixelFormat( @ogl_Device, 1, @pbufferdAttr[ 0 ] );
        if not Assigned( ogl_Format ) Then
          begin
            log_Add( 'PBuffer: aglChoosePixelFormat - failed' );
            ogl_CanPBuffer := FALSE;
            exit;
          end;

        pPBuffer.Context := aglCreateContext( ogl_Format, ogl_Context );
        if not Assigned( pPBuffer.Context ) Then
          begin
            log_Add( 'PBuffer: aglCreateContext - failed' );
            ogl_CanPBuffer := FALSE;
            exit;
          end;
        aglDestroyPixelFormat( ogl_Format );

        if aglCreatePBuffer( Surface.Width, Surface.Height, GL_TEXTURE_2D, GL_RGBA, 0, @pPBuffer.PBuffer ) = GL_FALSE Then
          begin
            log_Add( 'PBuffer: aglCreatePBuffer - failed' );
            ogl_CanPBuffer := FALSE;
            exit;
          end;
      end;
    {$ENDIF}
  end;
  Result.next._type   := _type;
  Result.next.Surface := Surface;
  Result.next.Flags   := Flags;

  Result.next.prev := Result;
  Result.next.next := nil;
  Result := Result.next;
  INC( managerRTarget.Count );
end;

procedure rtarget_Del;
begin
  if not Assigned( Target ) Then exit;

  case Target._type of
    RT_TYPE_FBO:
      begin
        if glIsRenderBufferEXT( zglPFBO( Target.Handle ).RenderBuffer ) = GL_TRUE Then
          glDeleteRenderbuffersEXT( 1, @zglPFBO( Target.Handle ).RenderBuffer );
        if glIsRenderBufferEXT( zglPFBO( Target.Handle ).FrameBuffer ) = GL_TRUE Then
          glDeleteFramebuffersEXT( 1, @zglPFBO( Target.Handle ).FrameBuffer );
      end;
    RT_TYPE_PBUFFER:
      begin
        {$IFDEF LINUX}
        case ogl_PBufferMode of
          1: glXDestroyPbuffer( scr_Display, zglPPBuffer( Target.Handle ).PBuffer );
          2: glXDestroyGLXPbufferSGIX( scr_Display, zglPPBuffer( Target.Handle ).PBuffer );
        end;
        {$ENDIF}
        {$IFDEF WINDOWS}
        if zglPPBuffer( Target.Handle ).RC <> 0 Then
          wglDeleteContext( zglPPBuffer( Target.Handle ).RC );
        if zglPPBuffer( Target.Handle ).DC <> 0 Then
          wglReleasePbufferDCARB( zglPPBuffer( Target.Handle ).Handle, zglPPBuffer( Target.Handle ).DC );
        if zglPPBuffer( Target.Handle ).Handle <> 0 Then
          wglDestroyPbufferARB( zglPPBuffer( Target.Handle ).Handle );
        {$ENDIF}
        {$IFDEF DARWIN}
        aglDestroyContext( zglPPBuffer( Target.Handle ).Context );
        aglDestroyPBuffer( zglPPBuffer( Target.Handle ).PBuffer );
        {$ENDIF}
      end;
  end;

  if Assigned( Target.prev ) Then
    Target.prev.next := Target.next;
  if Assigned( Target.next ) Then
    Target.next.prev := Target.prev;

  if Assigned( Target.Handle ) Then
    FreeMemory( Target.Handle );
  FreeMemory( Target );
  Target := nil;

  DEC( managerRTarget.Count );
end;

procedure rtarget_Set;
begin
  batch2d_Flush();

  if Assigned( Target ) Then
    begin
      lRTarget := Target;
      lMode := ogl_Mode;

      case Target._type of
        RT_TYPE_SIMPLE:
          begin
          end;
        RT_TYPE_FBO:
          begin
            glBindFramebufferEXT( GL_FRAMEBUFFER_EXT, zglPFBO( Target.Handle ).FrameBuffer );
            glFramebufferTexture2DEXT( GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, Target.Surface.ID, 0 );
          end;
        RT_TYPE_PBUFFER:
          begin
            {$IFDEF LINUX}
            glXMakeCurrent( scr_Display, zglPPBuffer( Target.Handle ).PBuffer, zglPPBuffer( Target.Handle ).Context );
            {$ENDIF}
            {$IFDEF WINDOWS}
            wglMakeCurrent( zglPPBuffer( Target.Handle ).DC, zglPPBuffer( Target.Handle ).RC );
            {$ENDIF}
            {$IFDEF DARWIN}
            aglSetCurrentContext( zglPPBuffer( Target.Handle ).Context );
            aglSetPBuffer( zglPPBuffer( Target.Handle ).Context, zglPPBuffer( Target.Handle ).PBuffer, 0, 0, aglGetVirtualScreen( ogl_Context ) );
            SetCurrentMode;
            {$ENDIF}
          end;
      end;
      ogl_Mode := 1;

      if Target.Flags and RT_FULL_SCREEN > 0 Then
        glViewport( 0, 0, Target.Surface.Width, Target.Surface.Height )
      else
        glViewport( 0, -( ogl_Height - Target.Surface.Height - scr_AddCY - ( scr_SubCY - scr_AddCY ) ),
                    ogl_Width - scr_AddCX - ( scr_SubCX - scr_AddCX ), ogl_Height - scr_AddCY - ( scr_SubCY - scr_AddCY ) );

      if ( Target.Flags and RT_CLEAR_SCREEN > 0 ) Then
        glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT );
    end else
      begin
        case lRTarget._type of
          RT_TYPE_SIMPLE, RT_TYPE_PBUFFER:
            begin
              glEnable( GL_TEXTURE_2D );
              glBindTexture( GL_TEXTURE_2D, lRTarget.Surface.ID );
              glCopyTexSubImage2D( GL_TEXTURE_2D, 0, 0, 0, 0, 0,
                                   Round( lRTarget.Surface.Width / lRTarget.Surface.U ),
                                   Round( lRTarget.Surface.Height / lRTarget.Surface.V ) );
              glDisable( GL_TEXTURE_2D );
            end;
          RT_TYPE_FBO:
            begin
              glFramebufferTexture2DEXT( GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, 0, 0 );
              glBindFramebufferEXT( GL_FRAMEBUFFER_EXT, 0 );
            end;
        end;

        if lRTarget._type = RT_TYPE_PBUFFER Then
          begin
            {$IFDEF LINUX}
            glXMakeCurrent( scr_Display, wnd_Handle, ogl_Context );
            {$ENDIF}
            {$IFDEF WINDOWS}
            wglMakeCurrent( wnd_DC, ogl_Context );
            {$ENDIF}
            {$IFDEF DARWIN}
            aglSwapBuffers( zglPPBuffer( lRTarget.Handle ).Context );
            aglSetCurrentContext( ogl_Context );
            {$ENDIF}
          end;

        ogl_Mode := lMode;
        scr_SetViewPort();
        if ( lRTarget._type = RT_TYPE_SIMPLE ) and ( lRTarget.Flags and RT_CLEAR_SCREEN > 0 ) Then
          glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT );
      end;
end;

procedure rtarget_DrawIn;
begin
  if ogl_Separate Then
    begin
      rtarget_Set( Target );
      RenderCallback( Data );
      rtarget_Set( nil );
    end else
      begin
        rtarget_Set( Target );

        glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
        glColorMask( GL_TRUE, GL_TRUE, GL_TRUE, GL_FALSE );
        RenderCallback( Data );
        batch2d_Flush();

        glBlendFunc( GL_ONE, GL_ONE_MINUS_SRC_ALPHA );
        glColorMask( GL_FALSE, GL_FALSE, GL_FALSE, GL_TRUE );
        RenderCallback( Data );
        batch2d_Flush();

        rtarget_Set( nil );

        glColorMask( GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE );
        glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
      end;
end;

end.
