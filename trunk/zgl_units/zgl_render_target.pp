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
unit zgl_render_target;

{$I define.inc}

interface

uses
  GL, GLExt,
  {$IFDEF WIN32}
  Windows,
  {$ENDIF}
  zgl_global_var,
  zgl_types,
  zgl_log,
  zgl_textures,
  Utils;

const
  RT_TYPE_SIMPLE  = 0;
  RT_TYPE_FBO     = 1;
  RT_TYPE_PBUFFER = 2;
  RT_FULL_SCREEN  = $01;
  RT_CLEAR_SCREEN = $02;
function  rtarget_Add( rtType : Byte; Surface : zglPTexture; Flags : Byte ) : zglPRenderTarget; extdecl;
procedure rtarget_Del( Target : zglPRenderTarget ); extdecl;
procedure rtarget_Set( Target : zglPRenderTarget ); extdecl;

implementation

var
  lRTarget : zglPRenderTarget;

function rtarget_Add;
  var
    pFBO : zglPFBO;
{$IFDEF WIN32}
    pPBuffer     : zglPPBuffer;
    PBufferAttr  : array[ 0..8 ] of Integer;
    PixelFormat  : Integer;
    nPixelFormat : DWORD;
{$ENDIF}
begin
  Result := @managerRTarget.First;
  while Assigned( Result.Next ) do
    Result := Result.Next;

  Result.Next := AllocMem( SizeOf( zglTRenderTarget ) );
  FillChar( Result.Next^, SizeOf( zglTRenderTarget ), 0 );
  
  if ( not ogl_CanFBO ) and ( rtType = RT_TYPE_FBO ) Then
    {$IFDEF WIN32}
    if ogl_CanPBuffer Then
      rtType := RT_TYPE_PBUFFER
    else
    {$ENDIF}
      rtType := RT_TYPE_SIMPLE;

  if ( not ogl_CanPBuffer ) and ( rtType = RT_TYPE_PBUFFER ) Then
    if ogl_CanFBO Then
      rtType := RT_TYPE_FBO
    else
      rtType := RT_TYPE_SIMPLE;
      
  case rtType of
    RT_TYPE_SIMPLE: Result.Next.Handle := nil;
    RT_TYPE_FBO:
      begin
        Result.Next.Handle := AllocMem( SizeOf( zglTFBO ) );
        pFBO := Result.Next.Handle;
        
        glGenFramebuffersEXT( 1, @pFBO.FrameBuffer );
        glBindFramebufferEXT( GL_FRAMEBUFFER_EXT, pFBO.FrameBuffer );
        if glIsFrameBufferEXT( pFBO.FrameBuffer ) = GL_TRUE Then
          log_Add( 'FBO: Gen FrameBuffer - Success' )
        else
          log_Add( 'FBO: Gen FrameBuffer - Error' );

        glGenRenderbuffersEXT( 1, @pFBO.RenderBuffer );
        glBindRenderbufferEXT( GL_RENDERBUFFER_EXT, pFBO.RenderBuffer );
        if glIsRenderBufferEXT( pFBO.RenderBuffer ) = GL_TRUE Then
          log_Add( 'FBO: Gen RenderBuffer - Success' )
        else
          log_Add( 'FBO: Gen RenderBuffer - Error' );

        case ogl_zDepth of
          16: glRenderbufferStorageEXT( GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT16, Surface.Width, Surface.Height );
          24: glRenderbufferStorageEXT( GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT24, Surface.Width, Surface.Height );
          32: glRenderbufferStorageEXT( GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT32, Surface.Width, Surface.Height );
        end;
        glFramebufferRenderbufferEXT( GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, pFBO.RenderBuffer );
        glFramebufferTexture2DEXT( GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, 0, 0 );
        glBindFramebufferEXT( GL_FRAMEBUFFER_EXT, 0 );
      end;
    {$IFDEF WIN32}
    RT_TYPE_PBUFFER:
      begin
        Result.Next.Handle := AllocMem( SizeOf( zglTPBuffer ) );
        pPBuffer := Result.Next.Handle;
        
        PBufferAttr[ 0 ] := WGL_DRAW_TO_PBUFFER_ARB;
        PBufferAttr[ 1 ] := GL_TRUE;
        PBufferAttr[ 2 ] := WGL_COLOR_BITS_ARB;
        PBufferAttr[ 3 ] := scr_BPP;
        PBufferAttr[ 4 ] := WGL_ALPHA_BITS_ARB;
        PBufferAttr[ 5 ] := 8;
        PBufferAttr[ 6 ] := WGL_DEPTH_BITS_ARB;
        PBufferAttr[ 7 ] := ogl_zDepth;
        PBufferAttr[ 8 ] := 0;

        wglChoosePixelFormatARB( wnd_DC, @PBufferAttr, nil, 1, @PixelFormat, @nPixelFormat );
        pPBuffer.Handle := wglCreatePbufferARB( wnd_DC, PixelFormat, ogl_Width, ogl_Height, nil );

        pPBuffer.DC := wglGetPbufferDCARB( pPBuffer.Handle );
        pPBuffer.RC := wglCreateContext( pPBuffer.DC );

        wglShareLists( wnd_DC, pPBuffer.RC );

        if pPBuffer.RC = 0 Then
          begin
            log_Add( 'PBuffer: RC create - Error' );
            ogl_CanPBuffer := FALSE;
            exit;
          end else
            log_Add( 'PBuffer: RC create - Success' );
      end;
    {$ENDIF}
  end;
  Result.Next.rtType  := rtType;
  Result.Next.Surface := Surface;
  Result.Next.Flags   := Flags;

  Result.Next.Prev := Result;
  Result := Result.Next;
  INC( managerRTarget.Count );
end;

procedure rtarget_Del;
begin
  Target.Prev.Next := Target.Next;
  case Target.rtType of
    RT_TYPE_FBO:
      begin
        if glIsRenderBufferEXT( zglPFBO( Target.Handle ).RenderBuffer ) = GL_TRUE Then
          glDeleteRenderbuffersEXT( 1, @zglPFBO( Target.Handle ).RenderBuffer );
        if glIsRenderBufferEXT( zglPFBO( Target.Handle ).FrameBuffer ) = GL_TRUE Then
          glDeleteFramebuffersEXT( 1, @zglPFBO( Target.Handle ).FrameBuffer );
      end;
  {$IFDEF WIN32}
    RT_TYPE_PBUFFER:
      begin
        if zglPPBuffer( Target.Handle ).RC <> 0 Then
          wglDeleteContext( zglPPBuffer( Target.Handle ).RC );
        if zglPPBuffer( Target.Handle ).DC <> 0 Then
          wglReleasePbufferDCARB( zglPPBuffer( Target.Handle ).Handle, zglPPBuffer( Target.Handle ).DC );
        if zglPPBuffer( Target.Handle ).Handle <> 0 Then
          wglDestroyPbufferARB( zglPPBuffer( Target.Handle ).Handle );
      end;
  {$ENDIF}
  end;
  if Assigned( Target.Handle ) Then
    Freememory( Target.Handle );
  Freememory( Target );
  DEC( managerRTarget.Count );
end;

procedure rtarget_Set;
begin
  if Assigned( Target ) Then
    begin
      lRTarget := Target;
      
      case Target.rtType of
        RT_TYPE_SIMPLE:
          begin
          end;
        RT_TYPE_FBO:
          begin
            glBindFramebufferEXT( GL_FRAMEBUFFER_EXT, zglPFBO( Target.Handle ).FrameBuffer );
            glFramebufferTexture2DEXT( GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, Target.Surface.ID, 0 );
          end;
        {$IFDEF WIN32}
        RT_TYPE_PBUFFER:
          begin
            wglMakeCurrent( zglPPBuffer( Target.Handle ).Handle, zglPPBuffer( Target.Handle ).RC );
          end;
        {$ENDIF}
      end;
      
      if Target.Flags and RT_FULL_SCREEN > 0 Then
        glViewport( 0, 0, Target.Surface.Width, Target.Surface.Height )
      else
        glViewport( 0, -( ogl_Height - Target.Surface.Height ), ogl_Width, ogl_Height );
        
      if Target.rtType = RT_TYPE_FBO Then
        if Target.Flags and RT_CLEAR_SCREEN > 0 Then
          glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT );
    end else
      begin
        case lRTarget.rtType of
          RT_TYPE_SIMPLE:
            begin
              glEnable( GL_TEXTURE_2D );
              glBindTexture( GL_TEXTURE_2D, lRTarget.Surface.ID );

              glCopyTexSubImage2D( GL_TEXTURE_2D, 0, 0, 0, 0, 0, lRTarget.Surface.Width, lRTarget.Surface.Height );

              glDisable( GL_TEXTURE_2D );
            end;
          RT_TYPE_FBO:
            begin
              glFramebufferTexture2DEXT( GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, 0, 0 );
              glBindFramebufferEXT( GL_FRAMEBUFFER_EXT, 0 );
            end;
          {$IFDEF WIN32}
          RT_TYPE_PBUFFER:
            begin
              glEnable( GL_TEXTURE_2D );
              glBindTexture( GL_TEXTURE_2D, lRTarget.Surface.ID );

              glCopyTexSubImage2D( GL_TEXTURE_2D, 0, 0, 0, 0, 0, lRTarget.Surface.Width, lRTarget.Surface.Height );

              glDisable( GL_TEXTURE_2D );
              wglMakeCurrent( wnd_DC, ogl_Context );
            end;
          {$ENDIF}
        end;
        glViewPort( 0, 0, ogl_Width, ogl_Height );
        if ( lRTarget.rtType = RT_TYPE_SIMPLE ) or ( lRTarget.rtType = RT_TYPE_PBUFFER ) Then
          if lRTarget.Flags and RT_CLEAR_SCREEN > 0 Then
            glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT );
      end;
end;

end.
