{
 *  Copyright © Kemka Andrey aka Andru
 *  mail: dr.andru@gmail.com
 *  site: http://andru-kun.inf.ua
 *
 *  This file is part of ZenGL.
 *
 *  ZenGL is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as
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
  Windows,
  {$IFDEF USE_DIRECT3D8}
  DirectXGraphics,
  {$ENDIF}
  {$IFDEF USE_DIRECT3D9}
  Direct3D9,
  {$ENDIF}
  zgl_direct3d,
  zgl_direct3d_all,
  zgl_textures;

const
  RT_DEFAULT      = $00;
  RT_FULL_SCREEN  = $01;
  RT_USE_DEPTH    = $02;
  RT_CLEAR_COLOR  = $04;
  RT_CLEAR_DEPTH  = $08;
  RT_SAVE_CONTENT = $10;

type
  zglPD3DTarget = ^zglTD3DTarget;
  zglTD3DTarget = record
    Old   : zglPTexture;
    {$IFDEF USE_DIRECT3D8}
    Depth : IDirect3DSurface8;
    {$ENDIF}
    {$IFDEF USE_DIRECT3D9}
    Depth : IDirect3DSurface9;
    {$ENDIF}
  end;

type
  zglPRenderTarget = ^zglTRenderTarget;
  zglTRenderTarget = record
    _type   : Byte;
    Handle  : zglPD3DTarget;
    Surface : zglPTexture;
    Flags   : Byte;

    prev, next : zglPRenderTarget;
  end;

type
  zglPRenderTargetManager = ^zglTRenderTargetManager;
  zglTRenderTargetManager = record
    Count : DWORD;
    First : zglTRenderTarget;
  end;

type
  zglTRenderCallback = procedure( Data : Pointer );

function rtarget_Add( Surface : zglPTexture; Flags : Byte ) : zglPRenderTarget;
procedure rtarget_Del( var Target : zglPRenderTarget );
procedure rtarget_Set( Target : zglPRenderTarget );
procedure rtarget_DrawIn( Target : zglPRenderTarget; RenderCallback : zglTRenderCallback; Data : Pointer );

procedure rtarget_Save( Target : zglPTexture );
procedure rtarget_Restore( Target : zglPTexture );

var
  managerRTarget : zglTRenderTargetManager;
  lRTarget  : zglPRenderTarget;
  rtWidth  : Integer;
  rtHeight : Integer;

implementation
uses
  zgl_main,
  zgl_application,
  zgl_screen,
  zgl_sprite_2d,
  zgl_render_2d,
  zgl_camera_2d;

var
  lCanDraw : Boolean;
  lCam2D   : Boolean;
  lPCam2D  : zglTCamera2D;
  {$IFDEF USE_DIRECT3D8}
  lSurface : IDirect3DSurface8;
  {$ENDIF}
  {$IFDEF USE_DIRECT3D9}
  lSurface : IDirect3DSurface9;
  {$ENDIF}
  lGLW     : Integer;
  lGLH     : Integer;
  lClipW   : Integer;
  lClipH   : Integer;
  lResCX   : Single;
  lResCY   : Single;

procedure rtarget_Save( Target : zglPTexture );
  var
    s, d : TD3DSurface_Desc;
    {$IFDEF USE_DIRECT3D8}
    src, dst : IDirect3DSurface8;
    {$ENDIF}
    {$IFDEF USE_DIRECT3D9}
    src : IDirect3DSurface9;
    {$ENDIF}
begin
  d3d_resArray[ Target.ID ] := nil;
  {$IFDEF USE_DIRECT3D8}
  d3d_texArray[ Target.ID ].Texture.GetLevelDesc( 0, d );
  if Assigned( d3d_resArray[ Target.ID ] ) Then
    begin
      d3d_resArray[ Target.ID ].GetLevelDesc( 0, s );
      if ( s.Width < d.Width ) or ( s.Height < d.Height ) or ( s.Format <> d.Format ) Then
        d3d_resArray[ Target.ID ] := nil;
    end;
  if not Assigned( d3d_resArray[ Target.ID ] ) Then
    d3d_Device.CreateTexture( d.Width, d.Height, 1, 0, d.Format, D3DPOOL_MANAGED, d3d_resArray[ Target.ID ] );

  d3d_texArray[ Target.ID ].Texture.GetSurfaceLevel( 0, src );
  d3d_resArray[ Target.ID ].GetSurfaceLevel( 0, dst );
  d3d_Device.CopyRects( src, nil, 0, dst, nil );

  src := nil;
  dst := nil;
  {$ENDIF}
  {$IFDEF USE_DIRECT3D9}
  d3d_texArray[ Target.ID ].Texture.GetLevelDesc( 0, d );
  if Assigned( d3d_resArray[ Target.ID ] ) Then
    begin
      d3d_resArray[ Target.ID ].GetDesc( s );
      if ( s.Width < d.Width ) or ( s.Height < d.Height ) or ( s.Format <> d.Format ) Then
        d3d_resArray[ Target.ID ] := nil;
    end;
  if not Assigned( d3d_resArray[ Target.ID ] ) Then
    d3d_Device.CreateOffscreenPlainSurface( d.Width, d.Height, d.Format, D3DPOOL_SYSTEMMEM, d3d_resArray[ Target.ID ], 0 );

  d3d_texArray[ Target.ID ].Texture.GetSurfaceLevel( 0, src );
  d3d_Device.GetRenderTargetData( src, d3d_resArray[ Target.ID ] );

  src := nil;
  {$ENDIF}
end;

procedure rtarget_Restore( Target : zglPTexture );
  var
    {$IFDEF USE_DIRECT3D8}
    src, dst : IDirect3DSurface8;
    {$ENDIF}
    {$IFDEF USE_DIRECT3D9}
    dst : IDirect3DSurface9;
    {$ENDIF}
begin
  if not Assigned( d3d_resArray[ Target.ID ] ) Then exit;
  {$IFDEF USE_DIRECT3D8}
  d3d_texArray[ Target.ID ].Texture.GetSurfaceLevel( 0, dst );
  d3d_resArray[ Target.ID ].GetSurfaceLevel( 0, src );
  d3d_Device.CopyRects( src, nil, 0, dst, nil );

  src := nil;
  dst := nil;
  {$ENDIF}
  {$IFDEF USE_DIRECT3D9}
  d3d_texArray[ Target.ID ].Texture.GetSurfaceLevel( 0, dst );
  d3d_Device.UpdateSurface( d3d_resArray[ Target.ID ], nil, dst, nil );

  dst := nil;
  {$ENDIF}
end;

function rtarget_Add( Surface : zglPTexture; Flags : Byte ) : zglPRenderTarget;
begin
  Result := @managerRTarget.First;
  while Assigned( Result.Next ) do
    Result := Result.Next;

  zgl_GetMem( Pointer( Result.Next ), SizeOf( zglTRenderTarget ) );
  zgl_GetMem( Pointer( Result.Next.Handle ), SizeOf( zglTD3DTarget ) );

  rtarget_Save( Surface );
  d3d_texArray[ Surface.ID ].Texture := nil;
  {$IFDEF USE_DIRECT3D8}
  d3d_Device.CreateTexture( Round( Surface.Width / Surface.U ), Round( Surface.Height / Surface.V ), 1, D3DUSAGE_RENDERTARGET, D3DFMT_X8R8G8B8, D3DPOOL_DEFAULT,
                            d3d_texArray[ Surface.ID ].Texture );
  if Flags and RT_USE_DEPTH > 0 Then
    d3d_Device.CreateDepthStencilSurface( Round( Surface.Width / Surface.U ), Round( Surface.Height / Surface.V ), d3d_Params.AutoDepthStencilFormat,
                                          D3DMULTISAMPLE_NONE, Result.Next.Handle.Depth );
  {$ENDIF}
  {$IFDEF USE_DIRECT3D9}
  d3d_Device.CreateTexture( Round( Surface.Width / Surface.U ), Round( Surface.Height / Surface.V ), 1, D3DUSAGE_RENDERTARGET, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT,
                            d3d_texArray[ Surface.ID ].Texture, nil );
  if Flags and RT_USE_DEPTH > 0 Then
    d3d_Device.CreateDepthStencilSurface( Round( Surface.Width / Surface.U ), Round( Surface.Height / Surface.V ), d3d_Params.AutoDepthStencilFormat,
                                          D3DMULTISAMPLE_NONE, 0, TRUE, Result.Next.Handle.Depth, nil );
  {$ENDIF}
  rtarget_Restore( Surface );

  Result.next._type      := 0;
  Result.next.Handle.Old := Surface;
  Result.next.Surface    := Surface;
  Result.next.Flags      := Flags;
  Result.next.prev       := Result;
  Result.next.next       := nil;
  Result                 := Result.next;
  INC( managerRTarget.Count );
end;

procedure rtarget_Del( var Target : zglPRenderTarget );
begin
  if not Assigned( Target ) Then exit;

  tex_Del( Target.Surface );

  if Assigned( Target.prev ) Then
    Target.prev.next := Target.next;
  if Assigned( Target.Next ) Then
    Target.next.prev := Target.prev;

  Target.Handle.Depth := nil;
  FreeMemory( Target.Handle );
  FreeMemory( Target );
  Target := nil;

  DEC( managerRTarget.Count );
end;

procedure rtarget_Set( Target : zglPRenderTarget );
  var
    d : TD3DSurface_Desc;
begin
  batch2d_Flush();

  if Assigned( Target ) Then
    begin
      lCanDraw := d3d_CanDraw;
      d3d_BeginScene();
      lRTarget   := Target;
      lGLW       := ogl_Width;
      lGLH       := ogl_Height;
      lClipW     := ogl_ClipW;
      lClipH     := ogl_ClipH;
      lResCX     := scr_ResCX;
      lResCY     := scr_ResCY;
      ogl_Target := TARGET_TEXTURE;

      if Target.Surface <> Target.Handle.Old Then
        begin
          d3d_texArray[ Target.Surface.ID ].Texture.GetLevelDesc( 0, d );
          if d.Pool <> D3DPOOL_DEFAULT Then
            begin
              Target.Handle.Old := Target.Surface;
              rtarget_Save( Target.Surface );
              d3d_texArray[ Target.Surface.ID ].Texture := nil;
              Target.Handle.Depth := nil;
              {$IFDEF USE_DIRECT3D8}
              d3d_Device.CreateTexture( d.Width, d.Height, 1, D3DUSAGE_RENDERTARGET, d.Format, D3DPOOL_DEFAULT, d3d_texArray[ Target.Surface.ID ].Texture );
              if Target.Flags and RT_USE_DEPTH > 0 Then
                d3d_Device.CreateDepthStencilSurface( d.Width, d.Height, d3d_Params.AutoDepthStencilFormat, D3DMULTISAMPLE_NONE, Target.Handle.Depth );
              {$ENDIF}
              {$IFDEF USE_DIRECT3D9}
              d3d_Device.CreateTexture( d.Width, d.Height, 1, D3DUSAGE_RENDERTARGET, d.Format, D3DPOOL_DEFAULT, d3d_texArray[ Target.Surface.ID ].Texture,
                                        nil );
              if Target.Flags and RT_USE_DEPTH > 0 Then
                d3d_Device.CreateDepthStencilSurface( d.Width, d.Height, d3d_Params.AutoDepthStencilFormat, D3DMULTISAMPLE_NONE, 0, TRUE, Target.Handle.Depth,
                                                      nil );
              {$ENDIF}
              rtarget_Restore( Target.Surface );
            end;
        end;
      {$IFDEF USE_DIRECT3D8}
      d3d_Device.GetRenderTarget( d3d_Surface );
      d3d_Device.GetDepthStencilSurface( d3d_Stencil );
      d3d_texArray[ Target.Surface.ID ].Texture.GetSurfaceLevel( 0, lSurface );
      if Target.Flags and RT_USE_DEPTH > 0 Then
        d3d_Device.SetRenderTarget( lSurface, nil );
      else
        d3d_Device.SetRenderTarget( lSurface, Target.Handle.Depth );
      {$ENDIF}
      {$IFDEF USE_DIRECT3D9}
      d3d_Device.GetDepthStencilSurface( d3d_Stencil );
      d3d_Device.GetRenderTarget( 0, d3d_Surface );
      d3d_texArray[ Target.Surface.ID ].Texture.GetSurfaceLevel( 0, lSurface );
      d3d_Device.SetRenderTarget( 0, lSurface );
      if Target.Flags and RT_USE_DEPTH > 0 Then
        d3d_Device.SetDepthStencilSurface( Target.Handle.Depth );
      {$ENDIF}

      if cam2dApply Then
        glPopMatrix();

      if Target.Flags and RT_FULL_SCREEN > 0 Then
        begin
          if app_Flags and CORRECT_RESOLUTION > 0 Then
            begin
              ogl_Width  := scr_ResW;
              ogl_Height := scr_ResH;
            end;
        end else
          begin
            ogl_Width  := Target.Surface.Width;
            ogl_Height := Target.Surface.Height;
            ogl_ClipX  := 0;
            ogl_ClipY  := 0;
            ogl_ClipW  := ogl_Width;
            ogl_ClipH  := ogl_Height;
            scr_ResCX  := 1;
            scr_ResCY  := 1;
          end;
      SetCurrentMode();

      glScalef( 1, -1, 1 );
      glTranslatef( 0, -ogl_Height, 0 );
      glViewport( 0, 0, Target.Surface.Width, Target.Surface.Height );
      if cam2dApply Then
        begin
          lPCam2D := cam2DGlobal^;
          cam2d_Apply( @lPCam2D );
        end;

      if Target.Flags and RT_CLEAR_COLOR > 0 Then
        d3d_Device.Clear( 0, nil, D3DCLEAR_TARGET, D3DCOLOR_ARGB( 0, 0, 0, 0 ), 1, 0 );
      if Target.Flags and RT_CLEAR_DEPTH > 0 Then
        d3d_Device.Clear( 0, nil, D3DCLEAR_ZBUFFER, D3DCOLOR_ARGB( 0, 0, 0, 0 ), 1, 0 );
    end else
      if Assigned( lRTarget ) Then
        begin
          {$IFDEF USE_DIRECT3D8}
          d3d_Device.SetRenderTarget( d3d_Surface, d3d_Stencil );
          {$ENDIF}
          {$IFDEF USE_DIRECT3D9}
          d3d_Device.SetRenderTarget( 0, d3d_Surface );
          d3d_Device.SetDepthStencilSurface( d3d_Stencil );
          {$ENDIF}
          lSurface    := nil;
          d3d_Surface := nil;
          d3d_Stencil := nil;

          if lRTarget.Flags and RT_SAVE_CONTENT > 0 Then
            rtarget_Save( lRTarget.Surface );

          lCam2D   := cam2dApply;
          lPCam2D  := cam2DGlobal^;

          ogl_Target := TARGET_SCREEN;
          ogl_Width  := lGLW;
          ogl_Height := lGLH;
          if lRTarget.Flags and RT_FULL_SCREEN = 0 Then
            begin
              ogl_ClipW := lClipW;
              ogl_ClipH := lClipH;
              scr_ResCX := lResCX;
              scr_ResCY := lResCY;
            end;

          lRTarget := nil;
          SetCurrentMode();
          if lCam2D Then
            cam2d_Apply( @lPCam2D );
          if not lCanDraw then
            d3d_EndScene();
        end;
end;

procedure rtarget_DrawIn( Target : zglPRenderTarget; RenderCallback : zglTRenderCallback; Data : Pointer );
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
        batch2d_Flush;

        glBlendFunc( GL_ONE, GL_ONE_MINUS_SRC_ALPHA );
        glColorMask( GL_FALSE, GL_FALSE, GL_FALSE, GL_TRUE );
        RenderCallback( Data );
        batch2d_Flush;

        rtarget_Set( nil );

        glColorMask( GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE );
        glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
      end;
end;

end.
