{
 * Copyright © Kemka Andrey aka Andru
 * mail: dr.andru@gmail.com
 * site: http://andru-kun.ru
 *
 * This file is part of ZenGL
 *
 * ZenGL is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * ZenGL is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
}
unit zgl_render_target;

{$I zgl_config.cfg}

interface
uses
  Windows,
  DirectXGraphics,
  zgl_direct3d8,
  zgl_direct3d8_all,
  zgl_textures;

const
  RT_TYPE_SIMPLE  = 0;
  RT_TYPE_FBO     = 1;
  RT_TYPE_PBUFFER = 2;
  RT_FULL_SCREEN  = $01;
  RT_CLEAR_SCREEN = $02;

  TEX_RESTORE     = $200000;

type
  zglPRenderTarget = ^zglTRenderTarget;
  zglTRenderTarget = record
    rtType     : Byte;
    Handle     : zglPTexture;
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

function  rtarget_Add( rtType : Byte; const Surface : zglPTexture; const Flags : Byte ) : zglPRenderTarget;
procedure rtarget_Del( var Target : zglPRenderTarget );
procedure rtarget_Set( const Target : zglPRenderTarget );

var
  managerRTarget : zglTRenderTargetManager;
  rt_ScaleW : Single;
  rt_ScaleH : Single;

implementation
uses
  zgl_const,
  zgl_main,
  zgl_application,
  zgl_screen;

var
  lRTarget : zglPRenderTarget;
  lMode : Integer;
  lSurface : IDirect3DSurface8;
  lTexture : zglPTexture;

function rtarget_Add;
  var
    fmt : TD3DFormat;
begin
  Result := @managerRTarget.First;
  while Assigned( Result.Next ) do
    Result := Result.Next;

  zgl_GetMem( Pointer( Result.Next ), SizeOf( zglTRenderTarget ) );

  case rtType of
    RT_TYPE_SIMPLE, RT_TYPE_FBO, RT_TYPE_PBUFFER:
      begin
        if Surface.Flags and TEX_RGB > 0 Then
          fmt := D3DFMT_X8R8G8B8
        else
          fmt := D3DFMT_A8R8G8B8;

        Result.Next.Handle := tex_Add;
        Result.Next.Handle.Width   := Surface.Width;
        Result.Next.Handle.Height  := Surface.Height;
        Result.Next.Handle.U       := Surface.U;
        Result.Next.Handle.V       := Surface.V;
        Result.Next.Handle.FramesX := Surface.FramesX;
        Result.Next.Handle.FramesY := Surface.FramesY;
        Result.Next.Handle.Flags   := Surface.Flags;
        glGenTextures( 1, @Result.Next.Handle.ID );
        d3d8_Device.CreateTexture( Surface.Width, Surface.Height, 1,
                                   D3DUSAGE_RENDERTARGET, fmt, D3DPOOL_DEFAULT,
                                   d3d8_texArray[ Result.Next.Handle.ID ].Texture );
      end;
  end;
  Result.Next.rtType  := rtType;
  Result.Next.Surface := Surface;
  Result.Next.Flags   := Flags;

  Result.Next.Prev := Result;
  Result.Next.Next := nil;
  Result := Result.Next;
  INC( managerRTarget.Count );

  rtarget_Set( Result );
  rtarget_Set( nil );
end;

procedure rtarget_Del;
begin
  if not Assigned( Target ) Then exit;

  tex_Del( Target.Handle );

  if Assigned( Target.Prev ) Then
    Target.Prev.Next := Target.Next;
  if Assigned( Target.Next ) Then
    Target.Next.Prev := Target.Prev;

  FreeMemory( Target );
  DEC( managerRTarget.Count );

  Target := nil;
end;

procedure rtarget_Set;
  var
    src, dst : IDirect3DSurface8;
begin
  if Assigned( Target ) Then
    begin
      if not d3d8_CanDraw Then
        d3d8_Device.BeginScene;
      lRTarget := Target;
      lMode := ogl_Mode;
      ogl_Mode := 1;

      case Target.rtType of
        RT_TYPE_SIMPLE, RT_TYPE_FBO, RT_TYPE_PBUFFER:
          begin
            if Target.Handle.Flags and TEX_RESTORE > 0 Then
              begin
                Target.Handle.Flags := Target.Handle.Flags xor TEX_RESTORE;
                d3d8_texArray[ Target.Handle.ID ].Texture.GetSurfaceLevel( 0, src );
                d3d8_texArray[ Target.Surface.ID ].Texture.GetSurfaceLevel( 0, dst );
                d3d8_Device.CopyRects( dst, nil, 0, src, nil );

                src := nil;
                dst := nil;
              end;

            d3d8_Device.GetRenderTarget( d3d8_Surface );
            d3d8_Device.GetDepthStencilSurface( d3d8_Stencil );
            d3d8_texArray[ Target.Handle.ID ].Texture.GetSurfaceLevel( 0, lSurface );
            lTexture := Target.Surface;
            d3d8_Device.SetRenderTarget( lSurface, nil );
          end;
      end;

      if app_Flags and CORRECT_RESOLUTION = 0 Then
        begin
          scr_ResW := ogl_Width;
          scr_ResH := ogl_Height;
        end;
      if Target.Flags and RT_FULL_SCREEN = 0 Then
        begin
          rt_ScaleW := scr_ResW / Target.Surface.Width;
          rt_ScaleH := scr_ResH / Target.Surface.Height;
        end else
          begin
            rt_ScaleW := 1;
            rt_ScaleH := 1;
          end;

      case lMode of
        2: Set2DMode;
        3: Set3DMode;
      end;

      if Target.Flags and RT_CLEAR_SCREEN > 0 Then
        d3d8_Device.Clear( 0, nil, D3DCLEAR_TARGET, D3DCOLOR_ARGB( 0, 0, 0, 0 ), 1, 0 );
    end else
      begin
        case lRTarget.rtType of
          RT_TYPE_SIMPLE, RT_TYPE_FBO, RT_TYPE_PBUFFER:
            begin
              d3d8_Device.SetRenderTarget( d3d8_Surface, d3d8_Stencil );
              lSurface := nil;
              d3d8_Surface := nil;
              d3d8_Stencil := nil;

              d3d8_texArray[ lRTarget.Handle.ID ].Texture.GetSurfaceLevel( 0, src );
              d3d8_texArray[ lTexture.ID ].Texture.GetSurfaceLevel( 0, dst );
              d3d8_Device.CopyRects( src, nil, 0, dst, nil );

              src := nil;
              dst := nil;
            end;
        end;

        ogl_Mode := lMode;
        SetCurrentMode;
        scr_SetViewPort;
        if not d3d8_CanDraw Then
          d3d8_Device.EndScene;
      end;
end;

end.
