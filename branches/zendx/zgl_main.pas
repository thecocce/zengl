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
unit zgl_main;

{$I zgl_config.cfg}

interface
uses
  Windows,
  zgl_types;

const
  cs_ZenGL = 'ZenDX 0.2 RC3';

  // zgl_Reg
  SYS_APP_INIT           = $000001;
  SYS_APP_LOOP           = $000002;
  SYS_LOAD               = $000003;
  SYS_DRAW               = $000004;
  SYS_UPDATE             = $000005;
  SYS_EXIT               = $000006;
  SYS_ACTIVATE           = $000007;
  TEX_FORMAT_EXTENSION   = $000010;
  TEX_FORMAT_FILE_LOADER = $000011;
  TEX_FORMAT_MEM_LOADER  = $000012;
  TEX_CURRENT_EFFECT     = $000013;
  SND_FORMAT_EXTENSION   = $000020;
  SND_FORMAT_FILE_LOADER = $000021;
  SND_FORMAT_MEM_LOADER  = $000022;
  SND_FORMAT_DECODER     = $000023;
  WIDGET_TYPE_ID         = $000030;
  WIDGET_FILL_DESC       = $000031;
  WIDGET_ONDRAW          = $000032;
  WIDGET_ONPROC          = $000033;
  WIDGET_ONFREEDESC      = $000034;
  WIDGET_ONFREEDATA      = $000035;

  // zgl_Get
  SYS_FPS         = 1;
  APP_PAUSED      = 2;
  APP_DIRECTORY   = 3;
  USR_HOMEDIR     = 4;
  LOG_FILENAME    = 5;
  ZGL_VERSION     = 6;
  SCR_ADD_X       = 7;
  SCR_ADD_Y       = 8;
  DESKTOP_WIDTH   = 9;
  DESKTOP_HEIGHT  = 10;
  RESOLUTION_LIST = 11;
  MANAGER_TIMER   = 12;
  MANAGER_TEXTURE = 13;
  MANAGER_ATLAS   = 14;
  MANAGER_FONT    = 15;
  MANAGER_RTARGET = 16;
  MANAGER_SOUND   = 17;
  MANAGER_GUI     = 18;

  // zgl_Enable/zgl_Disable
  COLOR_BUFFER_CLEAR    = $000001;
  DEPTH_BUFFER          = $000002;
  DEPTH_BUFFER_CLEAR    = $000004;
  DEPTH_MASK            = $000008;
  STENCIL_BUFFER_CLEAR  = $000010;
  CORRECT_RESOLUTION    = $000020;
  CORRECT_WIDTH         = $000040;
  CORRECT_HEIGHT        = $000080;
  APP_USE_AUTOPAUSE     = $000100;
  APP_USE_LOG           = $000200;
  APP_USE_ENGLISH_INPUT = $000400;
  APP_USE_UTF8          = $000800;
  WND_USE_AUTOCENTER    = $001000;
  SND_CAN_PLAY          = $002000;
  SND_CAN_PLAY_FILE     = $004000;
  CLIP_INVISIBLE        = $008000;

procedure zgl_Init( const FSAA : Byte = 0; const StencilBits : Byte = 0 );
procedure zgl_InitToHandle( const Handle : LongWord; const FSAA : Byte = 0; const StencilBits : Byte = 0 );
procedure zgl_Destroy;
procedure zgl_Exit;
procedure zgl_Reg( const What : LongWord; const UserData : Pointer );
function  zgl_Get( const What : LongWord ) : Ptr;
procedure zgl_GetSysDir;
procedure zgl_GetMem( var Mem : Pointer; const Size : LongWord );
procedure zgl_FreeMem( var Mem : Pointer );
procedure zgl_FreeStr( var Str : String );
procedure zgl_Enable( const What : LongWord );
procedure zgl_Disable( const What : LongWord );

implementation
uses
  zgl_application,
  zgl_screen,
  zgl_window,
  zgl_direct3d,
  zgl_direct3d_all,
  zgl_timers,
  zgl_log,
  zgl_textures,
  zgl_render_target,
  zgl_font,
  {$IFDEF USE_GUI}
  zgl_gui_main,
  {$ENDIF}
  {$IFDEF USE_SOUND}
  zgl_sound,
  {$ENDIF}
  zgl_utils;

procedure zgl_GetSysDir;
var
  buffer : PAnsiChar;
  fn, fp : PAnsiChar;
  s      : AnsiString;
  t      : array[ 0..MAX_PATH - 1 ] of AnsiChar;
begin
  wnd_INST := GetModuleHandle( nil );
  GetMem( buffer, 65535 );
  GetMem( fn, 65535 );
  GetModuleFileNameA( wnd_INST, fn, 65535 );
  GetFullPathNameA( fn, 65535, buffer, fp );
  s := copy( AnsiString( buffer ), 1, length( buffer ) - length( fp ) );
  app_WorkDir := PAnsiChar( s );

  GetEnvironmentVariableA( 'APPDATA', t, MAX_PATH );
  app_UsrHomeDir := t;
  app_UsrHomeDir := app_UsrHomeDir + '\';

  FreeMem( buffer );
  FreeMem( fn );
  app_GetSysDirs := TRUE;
end;

procedure zgl_Init;
begin
  zgl_GetSysDir();
  log_Init();

  ogl_FSAA    := FSAA;
  ogl_Stencil := StencilBits;
  if not scr_Create() Then exit;

  app_Initialized := TRUE;
  if wnd_Height >= zgl_Get( DESKTOP_HEIGHT ) Then
    wnd_FullScreen := TRUE;

  if not wnd_Create( wnd_Width, wnd_Height ) Then exit;
  if not d3d_Create() Then exit;
  wnd_SetCaption( wnd_Caption );
  app_Work := TRUE;

  Set2DMode();
  wnd_ShowCursor( app_ShowCursor );

  app_PInit();
  app_PLoop();
  zgl_Destroy();
end;

procedure zgl_InitToHandle;
begin
  zgl_GetSysDir();
  log_Init();

  ogl_FSAA    := FSAA;
  ogl_Stencil := StencilBits;

  if not scr_Create() Then exit;
  app_InitToHandle := TRUE;
  wnd_Handle := Handle;
  wnd_DC := GetDC( wnd_Handle );
  if not d3d_Create() Then exit;
  wnd_SetCaption( wnd_Caption );
  app_Work := TRUE;

  Set2DMode();
  wnd_ShowCursor( app_ShowCursor );

  app_PInit();
  app_PLoop();
  zgl_Destroy();
end;

procedure zgl_Destroy;
  var
    i : Integer;
    p : Pointer;
begin
  scr_Destroy();

  log_Add( 'Timers to free: ' + u_IntToStr( managerTimer.Count ) );
  while managerTimer.Count > 0 do
    begin
      p := managerTimer.First.next;
      timer_Del( zglPTimer( p ) );
    end;

  log_Add( 'Render Targets to free: ' + u_IntToStr( managerRTarget.Count ) );
  while managerRTarget.Count > 0 do
    begin
      p := managerRTarget.First.next;
      rtarget_Del( zglPRenderTarget( p ) );
    end;

  log_Add( 'Textures to free: ' + u_IntToStr( managerTexture.Count.Items ) );
  while managerTexture.Count.Items > 0 do
    begin
      p := managerTexture.First.next;
      tex_Del( zglPTexture( p ) );
    end;

  log_Add( 'Fonts to free: ' + u_IntToStr( managerFont.Count ) );
  while managerFont.Count > 0 do
    begin
      p := managerFont.First.next;
      font_Del( zglPFont( p ) );
    end;

  {$IFDEF USE_SOUND}
  log_Add( 'Sounds to free: ' + u_IntToStr( managerSound.Count.Items ) );
  while managerSound.Count.Items > 0 do
    begin
      p := managerSound.First.next;
      snd_Del( zglPSound( p ) );
    end;

  for i := 1 to SND_MAX do
    snd_StopFile( i );
  snd_Free();
  {$ENDIF}

  if app_WorkTime <> 0 Then
    log_Add( 'Average FPS: ' + u_IntToStr( Round( app_FPSAll / app_WorkTime ) ) );

  if not app_InitToHandle Then wnd_Destroy();

  app_PExit();
  d3d_Destroy();
  log_Add( 'End' );
  log_Close();
end;

procedure zgl_Exit;
begin
  app_Work := FALSE;
end;

procedure zgl_Reg;
  var
    i : Integer;
begin
  case What of
    // Callback
    SYS_APP_INIT:
      begin
        app_PInit := UserData;
        if not Assigned( UserData ) Then app_PInit := app_Init;
      end;
    SYS_APP_LOOP:
      begin
        app_PLoop := UserData;
        if not Assigned( UserData ) Then app_PLoop := app_MainLoop;
      end;
    SYS_LOAD:
      begin
        app_PLoad := UserData;
        if not Assigned( UserData ) Then app_PLoad := zero;
      end;
    SYS_DRAW:
      begin
        app_PDraw := UserData;
        if not Assigned( UserData ) Then app_PDraw := zero;
      end;
    SYS_UPDATE:
      begin
        app_PUpdate := UserData;
        if not Assigned( UserData ) Then app_PUpdate := zerou;
      end;
    SYS_EXIT:
      begin
        app_PExit := UserData;
        if not Assigned( UserData ) Then app_PExit := zero;
      end;
    SYS_ACTIVATE:
      begin
        app_PActivate := UserData;
        if not Assigned( UserData ) Then app_PActivate := zeroa;
      end;
    // Textures
    TEX_FORMAT_EXTENSION:
      begin
        SetLength( managerTexture.Formats, managerTexture.Count.Formats + 1 );
        managerTexture.Formats[ managerTexture.Count.Formats ].Extension := u_StrUp( String( PChar( UserData ) ) );
      end;
    TEX_FORMAT_FILE_LOADER:
      begin
        managerTexture.Formats[ managerTexture.Count.Formats ].FileLoader := UserData;
      end;
    TEX_FORMAT_MEM_LOADER:
      begin
        managerTexture.Formats[ managerTexture.Count.Formats ].MemLoader := UserData;
        INC( managerTexture.Count.Formats );
      end;
    TEX_CURRENT_EFFECT:
      begin
        tex_CalcCustomEffect := UserData;
        if not Assigned( tex_CalcCustomEffect ) Then tex_CalcCustomEffect := zeroce;
      end;
    // Sound
    {$IFDEF USE_SOUND}
    SND_FORMAT_EXTENSION:
      begin
        SetLength( managerSound.Formats, managerSound.Count.Formats + 1 );
        managerSound.Formats[ managerSound.Count.Formats ].Extension := u_StrUp( String( PChar( UserData ) ) );
        managerSound.Formats[ managerSound.Count.Formats ].Decoder   := nil;
      end;
    SND_FORMAT_FILE_LOADER:
      begin
        managerSound.Formats[ managerSound.Count.Formats ].FileLoader := UserData;
      end;
    SND_FORMAT_MEM_LOADER:
      begin
        managerSound.Formats[  managerSound.Count.Formats ].MemLoader := UserData;
        INC( managerSound.Count.Formats );
      end;
    SND_FORMAT_DECODER:
      begin
        for i := 0 to managerSound.Count.Formats - 1 do
          if managerSound.Formats[ i ].Extension = zglPSoundDecoder( UserData ).Ext Then
            managerSound.Formats[ i ].Decoder := UserData;
      end;
    {$ENDIF}
    // GUI
    {$IFDEF USE_GUI}
    WIDGET_TYPE_ID:
      begin
        if LongWord( UserData ) > length( managerGUI.Types ) Then
          begin
            SetLength( managerGUI.Types, length( managerGUI.Types ) + 1 );
            managerGUI.Types[ length( managerGUI.Types ) - 1 ]._type := LongWord( UserData );
            widgetTLast := length( managerGUI.Types ) - 1;
          end else
            widgetTLast := LongWord( UserData );
      end;
    WIDGET_FILL_DESC:
      begin
        managerGUI.Types[ widgetTLast ].FillDesc := UserData;
      end;
    WIDGET_ONDRAW:
      begin
        managerGUI.Types[ widgetTLast ].OnDraw := UserData;
      end;
    WIDGET_ONPROC:
      begin
        managerGUI.Types[ widgetTLast ].OnProc := UserData;
      end;
    WIDGET_ONFREEDESC:
      begin
        managerGUI.Types[ widgetTLast ].OnFreeDesc := UserData;
      end;
    WIDGET_ONFREEDATA:
      begin
        managerGUI.Types[ widgetTLast ].OnFreeData := UserData;
      end;
    {$ENDIF}
  end;
end;

function zgl_Get;
begin
  if ( What = APP_DIRECTORY ) or ( What = USR_HOMEDIR ) Then
    if not app_GetSysDirs Then zgl_GetSysDir();

  if ( What = DESKTOP_WIDTH ) or ( What = DESKTOP_HEIGHT ) Then
    if not scr_Initialized Then scr_Init();

  case What of
    SYS_FPS: Result := app_FPS;
    APP_PAUSED: Result := Byte( app_Pause );
    APP_DIRECTORY: Result := Ptr( PAnsiChar( app_WorkDir ) );
    USR_HOMEDIR: Result := Ptr( PAnsiChar( app_UsrHomeDir ) );
    LOG_FILENAME: Result := Ptr( @logfile );
    //ZGL_VERSION: Result := cv_version;
    SCR_ADD_X: Result := scr_AddCX;
    SCR_ADD_Y: Result := scr_AddCY;
    DESKTOP_WIDTH:
      Result := scr_Desktop.dmPelsWidth;
    DESKTOP_HEIGHT:
      Result := scr_Desktop.dmPelsHeight;
    RESOLUTION_LIST: Result := Ptr( @scr_ResList );

    // Managers
    MANAGER_TIMER:   Result := Ptr( @managerTimer );
    MANAGER_TEXTURE: Result := Ptr( @managerTexture );
    MANAGER_FONT:    Result := Ptr( @managerFont );
    MANAGER_RTARGET: Result := Ptr( @managerRTarget );
    {$IFDEF USE_SOUND}
    MANAGER_SOUND:   Result := Ptr( @managerSound );
    {$ENDIF}
    {$IFDEF USE_GUI}
    MANAGER_GUI:     Result := Ptr( @managerGUI );
    {$ENDIF}
  end;
end;

procedure zgl_GetMem;
begin
  if Size > 0 Then
    begin
      GetMem( Mem, Size );
      FillChar( Mem^, Size, 0 );
    end else
      Mem := nil;
end;

procedure zgl_FreeMem;
begin
  FreeMem( Mem );
  Mem := nil;
end;

procedure zgl_FreeStr;
begin
  Str := '';
end;

procedure zgl_Enable;
begin
  app_Flags := app_Flags or What;

  if What and DEPTH_BUFFER > 0 Then
    glEnable( GL_DEPTH_TEST );

  {if What and DEPTH_MASK > 0 Then
    glDepthMask( GL_TRUE );}

  if What and CORRECT_RESOLUTION > 0 Then
    app_Flags := app_Flags or CORRECT_WIDTH or CORRECT_HEIGHT;

  if What and APP_USE_AUTOPAUSE > 0 Then
    app_AutoPause := TRUE;

  if What and APP_USE_LOG > 0 Then
    app_Log := TRUE;

  if What and APP_USE_UTF8 > 0 Then
    begin
      if SizeOf( Char ) = 1 Then
        font_GetCID := font_GetUTF8ID
      {$IFNDEF FPC}
      else
        font_GetCID := font_GetUTF16ID;
      {$ENDIF}
    end;

  {$IFDEF USE_SOUND}
  if What and SND_CAN_PLAY > 0 Then
    sndCanPlay := TRUE;

  if What and SND_CAN_PLAY_FILE > 0 Then
    sndCanPlayFile := TRUE;
  {$ENDIF}
end;

procedure zgl_Disable;
begin
  if app_Flags and What > 0 Then
    app_Flags := app_Flags xor What;

  if What and DEPTH_BUFFER > 0 Then
    glDisable( GL_DEPTH_TEST );

  {if What and DEPTH_MASK > 0 Then
    glDepthMask( GL_FALSE );}

  if What and CORRECT_RESOLUTION > 0 Then
    begin
      scr_ResCX := 1;
      scr_ResCY := 1;
      scr_AddCX := 0;
      scr_AddCY := 0;
      scr_SubCX := 0;
      scr_SubCY := 0;
    end;

  if What and APP_USE_AUTOPAUSE > 0 Then
    app_AutoPause := FALSE;

  if What and APP_USE_LOG > 0 Then
    app_Log := FALSE;

  if What and APP_USE_UTF8 > 0 Then
    font_GetCID := font_GetCP1251ID;

  {$IFDEF USE_SOUND}
  if What and SND_CAN_PLAY > 0 Then
    sndCanPlay := FALSE;

  if What and SND_CAN_PLAY_FILE > 0 Then
    sndCanPlayFile := FALSE;
  {$ENDIF}
end;

end.
