{
 * Copyright © Kemka Andrey aka Andru
 * mail: dr.andru@gmail.com
 * site: http://andru-kun.inf.ua
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
unit zgl_application;

{$I zgl_config.cfg}

interface
uses
  {$IFDEF LINUX}
  X, XLib,
  {$ENDIF}
  {$IFDEF WIN32}
  Windows,
  Messages,
  {$ENDIF}
  {$IFDEF DARWIN}
  MacOSAll,
  {$ENDIF}
  zgl_const,
  zgl_types;

procedure zero;
procedure zerou( dt : Double );

procedure app_MainLoop;
{$IFDEF LINUX}
function app_ProcessMessages : DWORD;
{$ENDIF}
{$IFDEF WIN32}
function app_ProcessMessages( hWnd : HWND; Msg : UINT; wParam : WPARAM; lParam : LPARAM ) : LRESULT; stdcall;
{$ENDIF}
{$IFDEF DARWIN}
function app_ProcessMessages( inHandlerCallRef: EventHandlerCallRef; inEvent: EventRef; inUserData: UnivPtr ): OSStatus; cdecl;
{$ENDIF}
procedure app_CalcFPS;

var
  app_Initialized  : Boolean;
  app_GetSysDirs   : Boolean;
  app_Work         : Boolean;
  app_WorkTime     : DWORD;
  app_Pause        : Boolean;
  app_AutoPause    : Boolean = TRUE;
  app_Focus        : Boolean = TRUE;
  app_Log          : Boolean;
  app_InitToHandle : Boolean;
  app_WorkDir      : AnsiString;
  app_UsrHomeDir   : AnsiString;

  // call-back
  app_PLoad   : procedure = zero;
  app_PDraw   : procedure = zero;
  app_PExit   : procedure = zero;
  app_PUpdate : procedure( dt : Double ) = zerou;

  {$IFDEF LINUX}
  app_Cursor : TCursor = None;
  app_XIM    : PXIM;
  app_XIC    : PXIC;
  {$ENDIF}
  app_ShowCursor : Boolean;

  app_dt : Double;

  app_FPS      : DWORD;
  app_FPSCount : DWORD;
  app_FPSAll   : DWORD;

  app_Flags : DWORD = WND_USE_AUTOCENTER or APP_USE_LOG or COLOR_BUFFER_CLEAR or DEPTH_BUFFER or DEPTH_BUFFER_CLEAR or CROP_INVISIBLE;

implementation
uses
  zgl_screen,
  zgl_window,
  zgl_opengl,
  zgl_log,
  zgl_keyboard,
  zgl_mouse,
  zgl_timers,
  zgl_sound,
  zgl_utils;

procedure zero;
begin
end;
procedure zerou;
begin
end;

procedure OSProcess;
  {$IFDEF WIN32}
  var
    Mess : tagMsg;
  {$ENDIF}
  {$IFDEF DARWIN}
  var
    Event    : EventRecord;
    Window   : WindowRef;
    PartCode : WindowPartCode;
  {$ENDIF}
begin
{$IFDEF LINUX}
  app_ProcessMessages;
  keysRepeat := 0;
{$ENDIF}
{$IFDEF WIN32}
  while PeekMessage( Mess, 0{wnd_Handle}, 0, 0, PM_REMOVE ) do
    begin
      TranslateMessage( Mess );
      DispatchMessage( Mess );
    end;
{$ENDIF}
{$IFDEF DARWIN}
  while GetNextEvent( everyEvent, Event ) do;
{$ENDIF}
end;

procedure app_Draw;
begin
  scr_Clear;
  app_PDraw;
  scr_Flush;
  if not app_Pause Then
    INC( app_FPSCount );
end;

procedure app_MainLoop;
  var
    i, z : Integer;
    j    : Double;
    currTimer : zglPTimer;
    {$IFDEF WIN32}
    SysInfo : _SYSTEM_INFO;
    {$ENDIF}
begin
  {$IFDEF WIN32}
  // Багнутое MS-поделко требует патча :)
  // Вешаем все на одно ядро
  GetSystemInfo( SysInfo );
  SetProcessAffinityMask( GetCurrentProcess, SysInfo.dwActiveProcessorMask );
  {$ENDIF}

  scr_Clear;
  app_PLoad;
  scr_Flush;

  app_dt := timer_GetTicks;
  timer_Reset;
  timer_Add( @app_CalcFPS, 1000 );
  while app_Work do
    begin
      OSProcess;

      CanKillTimers := FALSE;
      {$IFDEF LINUX_OR_DARWIN}
      // При переходе в полноэкранный режим происходит чего-то странное, и в событиях не значится получение фокуса 8)
      if wnd_FullScreen Then
        begin
          app_Focus := TRUE;
          app_Pause := FALSE;
        end;
      {$ENDIF}
      if app_Focus Then
        begin
          if sndAutoPaused Then
            begin
              sndAutoPaused := FALSE;
              snd_ResumeFile;
            end;
        end else
          if Assigned( sfStream ) and ( sfStream.Played ) Then
            begin
              sndAutoPaused := TRUE;
              snd_StopFile;
            end;

      if not app_Pause Then
        begin
          currTimer := @managerTimer.First;
          if currTimer <> nil Then
            for z := 0 to managerTimer.Count do
              begin
                j := timer_GetTicks;
                if currTimer^.Active then
                  begin
                    if j > currTimer^.LastTick + currTimer^.Interval Then
                      begin
                        currTimer^.LastTick := currTimer^.LastTick + currTimer^.Interval;
                        currTimer^.OnTimer;
                      end;
                  end else currTimer^.LastTick := timer_GetTicks;

                currTimer := currTimer^.Next;
              end;
        end else
          begin
            timer_Reset;
            u_Sleep( 10 );
          end;

      CanKillTimers := TRUE;
      for i := 1 to TimersToKill do
        timer_Del( aTimersToKill[ i ] );
      TimersToKill  := 0;

      if app_Pause Then
        begin
          app_dt := timer_GetTicks;
          continue;
        end;
      app_PUpdate( timer_GetTicks - app_dt );
      app_dt := timer_GetTicks;
      app_Draw;
    end;
end;

function app_ProcessMessages;
  var
  {$IFDEF LINUX}
    Event  : TXEvent;
    Keysym : TKeySym;
    Status : TStatus;
  {$ENDIF}
  {$IFDEF DARWIN}
    eClass  : UInt32;
    eKind   : UInt32;
    mPos    : HIPoint;
    mButton : EventMouseButton;
    mWheel  : Integer;
    bounds  : HIRect;
    where   : Point;
    SCAKey  : DWORD;
  {$ENDIF}
    i   : Integer;
    len : Integer;
    c   : array[ 0..5 ] of AnsiChar;
    str : AnsiString;
    Key : DWORD;
begin
{$IFDEF LINUX}
  Result := 0;
  while XPending( scr_Display ) <> 0 do
    begin
      XNextEvent( scr_Display, @Event );

      case Event._type of
        ClientMessage:
          if ( Event.xclient.message_type = wnd_Protocols ) and ( Event.xclient.data.l[ 0 ] = wnd_DestroyAtom ) Then app_Work := FALSE;

        Expose:
          if app_Work Then
            begin
              app_Draw;
            end;
        FocusIn:
          begin
            app_Focus := TRUE;
            app_Pause := FALSE;
            FillChar( keysDown[ 0 ], 256, 0 );
            key_ClearState;
            FillChar( mouseDown[ 0 ], 3, 0 );
            mouse_ClearState;
          end;
        FocusOut:
          begin
            app_Focus := FALSE;
            if app_AutoPause Then app_Pause := TRUE;
          end;

        MotionNotify:
          begin
            if not mouseLock Then
              begin
                mouseX := Event.xmotion.X;
                mouseY := Event.xmotion.Y;
              end else
                begin
                  mouseX := Event.xmotion.X - wnd_Width  div 2;
                  mouseY := Event.xmotion.Y - wnd_Height div 2;
                end;
          end;
        ButtonPress:
          begin
            case Event.xbutton.button of
              1: // Left
                begin
                  mouseDown[ M_BLEFT ]  := TRUE;
                  if mouseCanClick[ M_BLEFT ] Then
                    begin
                      mouseClick[ M_BLEFT ] := TRUE;
                      mouseCanClick[ M_BLEFT ] := FALSE;
                    end;
                end;
              2: // Midle
                begin
                  mouseDown[ M_BMIDLE ] := TRUE;
                  if mouseCanClick[ M_BMIDLE ] Then
                    begin
                      mouseClick[ M_BMIDLE ] := TRUE;
                      mouseCanClick[ M_BMIDLE ] := FALSE;
                    end;
                end;
              3: // Right
                begin
                  mouseDown[ M_BRIGHT ] := TRUE;
                  if mouseCanClick[ M_BRIGHT ] Then
                    begin
                      mouseClick[ M_BRIGHT ] := TRUE;
                      mouseCanClick[ M_BRIGHT ] := FALSE;
                    end;
                end;
            end;
          end;
        ButtonRelease:
          begin
            case Event.xbutton.button of
              1: // Left
                begin
                  mouseDown[ M_BLEFT ]  := FALSE;
                  mouseUp  [ M_BLEFT ]  := TRUE;
                  mouseCanClick[ M_BLEFT ] := TRUE;
                end;
              2: // Midle
                begin
                  mouseDown[ M_BMIDLE ] := FALSE;
                  mouseUp  [ M_BMIDLE ] := TRUE;
                  mouseCanClick[ M_BMIDLE ] := TRUE;
                end;
              3: // Right
                begin
                  mouseDown[ M_BRIGHT ] := FALSE;
                  mouseUp  [ M_BRIGHT ] := TRUE;
                  mouseCanClick[ M_BRIGHT ] := TRUE;
                end;
              4: // Up Wheel
                begin
                  mouseWheel[ M_WUP ] := TRUE;
                end;
              5: // Down Wheel
                begin
                  mouseWheel[ M_WDOWN ] := TRUE;
                end;
            end;
          end;

        KeyPress:
          begin
            INC( keysRepeat );
            Key := xkey_to_scancode( XLookupKeysym( @Event.xkey, 0 ), Event.xkey.keycode );
            keysDown[ Key ] := TRUE;
            keysUp  [ Key ] := FALSE;
            keysLast[ KA_DOWN ] := Key;
            DoKeyPress( Key );

            Key := SCA( Key );
            keysDown[ Key ] := TRUE;
            keysUp  [ Key ] := FALSE;
            DoKeyPress( Key );

            case Key of
              K_SYSRQ, K_PAUSE,
              K_ESCAPE, K_ENTER, K_KP_ENTER,
              K_UP, K_DOWN, K_LEFT, K_RIGHT,
              K_INSERT, K_DELETE, K_HOME, K_END,
              K_PAGEUP, K_PAGEDOWN,
              K_CTRL_L, K_CTRL_R,
              K_ALT_L, K_ALT_R,
              K_SHIFT_L, K_SHIFT_R,
              K_SUPER_L, K_SUPER_R,
              K_APP_MENU,
              K_CAPSLOCK, K_NUMLOCK, K_SCROLL:;
              K_BACKSPACE: u_Backspace( keysText );
              K_TAB:       key_InputText( '  ' );
            else
              len := Xutf8LookupString( app_XIC, @Event, @c[ 0 ], 6, @Keysym, @Status );
              str := '';
              for i := 0 to len - 1 do
                str := str + c[ i ];
              if str <> '' Then
                key_InputText( str );
            end;
          end;
        KeyRelease:
          begin
            INC( keysRepeat );
            Key := xkey_to_scancode( XLookupKeysym( @Event.xkey, 0 ), Event.xkey.keycode );
            keysDown[ Key ]  := FALSE;
            keysUp  [ Key ]  := TRUE;
            keysLast[ KA_UP ] := Key;

            Key := SCA( Key );
            keysDown[ Key ] := FALSE;
            keysUp  [ Key ] := TRUE;
          end;
      end
    end;
{$ENDIF}
{$IFDEF WIN32}
  Result := 0;
  if not app_Work Then
    begin
      Result := DefWindowProc( hWnd, Msg, wParam, lParam );
      exit;
    end;
  case Msg of
    WM_CLOSE, WM_DESTROY, WM_QUIT:
      app_Work := FALSE;

    WM_PAINT:
      begin
        app_Draw;
        ValidateRect( wnd_Handle, nil );
      end;
    WM_DISPLAYCHANGE:
      begin
        wnd_Update;
      end;
    WM_KILLFOCUS:
      begin
        app_Focus := FALSE;
        if app_AutoPause Then app_Pause := TRUE;
        if ( wnd_FullScreen ) and ( not wnd_First ) Then
          begin
            scr_Reset;
            wnd_Update;
          end;
      end;
    WM_SETFOCUS:
      begin
        app_Focus := TRUE;
        app_Pause := FALSE;
        FillChar( keysDown[ 0 ], 256, 0 );
        key_ClearState;
        FillChar( mouseDown[ 0 ], 3, 0 );
        mouse_ClearState;
        if ( wnd_FullScreen ) and ( not wnd_First ) Then
          scr_SetOptions( scr_Width, scr_Height, scr_BPP, scr_Refresh, wnd_FullScreen, scr_VSync );
      end;
    WM_NCHITTEST:
      begin
        Result := DefWindowProc( hWnd, Msg, wParam, lParam );
        if ( not app_Focus ) and ( Result = HTCAPTION ) Then
          Result := HTCLIENT;
      end;
    WM_MOVING:
      begin
        wnd_X := PRect( lParam ).Left;
        wnd_Y := PRect( lParam ).Top;
      end;
    WM_SETCURSOR:
      begin
        if ( not app_Pause ) and ( LOWORD ( lparam ) = HTCLIENT ) and ( not app_ShowCursor ) Then
          SetCursor( 0 )
        else
          SetCursor( LoadCursor( 0, IDC_ARROW ) );
      end;

    WM_LBUTTONDOWN, WM_LBUTTONDBLCLK:
      begin
        mouseDown[ M_BLEFT ]  := TRUE;
        if mouseCanClick[ M_BLEFT ] Then
          begin
            mouseClick[ M_BLEFT ] := TRUE;
            mouseCanClick[ M_BLEFT ] := FALSE;
          end;
      end;
    WM_MBUTTONDOWN, WM_MBUTTONDBLCLK:
      begin
        mouseDown[ M_BMIDLE ] := TRUE;
        if mouseCanClick[ M_BMIDLE ] Then
          begin
            mouseClick[ M_BMIDLE ] := TRUE;
            mouseCanClick[ M_BMIDLE ] := FALSE;
          end;
      end;
    WM_RBUTTONDOWN, WM_RBUTTONDBLCLK:
      begin
        mouseDown[ M_BRIGHT ] := TRUE;
        if mouseCanClick[ M_BRIGHT ] Then
          begin
            mouseClick[ M_BRIGHT ] := TRUE;
            mouseCanClick[ M_BRIGHT ] := FALSE;
          end;
      end;
    WM_LBUTTONUP:
      begin
        mouseDown[ M_BLEFT ]  := FALSE;
        mouseUp  [ M_BLEFT ]  := TRUE;
        mouseCanClick[ M_BLEFT ] := TRUE;
      end;
    WM_MBUTTONUP:
      begin
        mouseDown[ M_BMIDLE ] := FALSE;
        mouseUp  [ M_BMIDLE ] := TRUE;
        mouseCanClick[ M_BMIDLE ] := TRUE;
      end;
    WM_RBUTTONUP:
      begin
        mouseDown[ M_BRIGHT ] := FALSE;
        mouseUp  [ M_BRIGHT ] := TRUE;
        mouseCanClick[ M_BRIGHT ] := TRUE;
      end;
    WM_MOUSEWHEEL:
      begin
        if wParam > 0 Then
          begin
            mouseWheel[ M_WUP   ] := TRUE;
            mouseWheel[ M_WDOWN ] := FALSE;
          end else
            begin
              mouseWheel[ M_WUP   ] := FALSE;
              mouseWheel[ M_WDOWN ] := TRUE;
            end;
      end;

    WM_KEYDOWN, WM_SYSKEYDOWN:
      begin
        Key := winkey_to_scancode( wParam );
        keysDown[ Key ] := TRUE;
        keysUp  [ Key ] := FALSE;
        keysLast[ KA_DOWN ] := Key;
        DoKeyPress( Key );

        Key := SCA( Key );
        keysDown[ Key ] := TRUE;
        keysUp  [ Key ] := FALSE;
        DoKeyPress( Key );

        if Msg = WM_SYSKEYDOWN Then
          if Key = K_F4 Then
            app_Work := FALSE;
      end;
    WM_KEYUP, WM_SYSKEYUP:
      begin
        Key := winkey_to_scancode( wParam );
        keysDown[ Key ] := FALSE;
        keysUp  [ Key ] := TRUE;
        keysLast[ KA_UP ] := Key;

        Key := SCA( Key );
        keysDown[ Key ] := FALSE;
        keysUp  [ Key ] := TRUE;
      end;
    WM_CHAR:
      begin
        case winkey_to_scancode( wParam ) of
          K_BACKSPACE: u_Backspace( keysText );
          K_TAB:       key_InputText( '  ' );
        else
          if wParam > 32 Then
            begin
              if app_Flags and APP_USE_UTF8 > 0 Then
                key_InputText( AnsiToUtf8( Char( wParam ) ) )
              else
                key_InputText( AnsiChar( wParam ) );
            end;
        end;
      end;
  else
    Result := DefWindowProc( hWnd, Msg, wParam, lParam );
  end;
{$ENDIF}
{$IFDEF DARWIN}
  eClass := GetEventClass( inEvent );
  eKind  := GetEventKind( inEvent );

  Result := CallNextEventHandler( inHandlerCallRef, inEvent );

  case eClass of
    kEventClassWindow:
      case eKind of
        kEventWindowDrawContent:
          begin
            app_Draw;
          end;
        kEventWindowActivated:
          begin
            app_Focus := TRUE;
            app_Pause := FALSE;
            FillChar( keysDown[ 0 ], 256, 0 );
            key_ClearState;
            FillChar( mouseDown[ 0 ], 3, 0 );
            mouse_ClearState;
          end;
        kEventWindowDeactivated:
          begin
            if wnd_FullScreen Then exit;
            app_Focus := FALSE;
            if app_AutoPause Then app_Pause := TRUE;
          end;
        kEventWindowCollapsed:
          begin
            app_Focus := FALSE;
            app_Pause := TRUE;
          end;
        kEventWindowClosed:
          begin
            wnd_Handle := nil;
            app_Work   := FALSE;
          end;
        kEventWindowBoundsChanged:
          begin
            if not wnd_FullScreen Then
              begin
                GetEventParameter( inEvent, kEventParamCurrentBounds, typeHIRect, nil, SizeOf( bounds ), nil, @bounds );
                wnd_X := Round( bounds.origin.x );
                wnd_Y := Round( bounds.origin.y );
              end else
                begin
                  wnd_X := 0;
                  wnd_Y := 0;
                end;
          end;
      end;

    kEventClassKeyboard:
      begin
        GetEventParameter( inEvent, kEventParamKeyCode, typeUInt32, nil, 4, nil, @Key );

        case eKind of
          kEventRawKeyModifiersChanged:
            begin
              GetEventParameter( inEvent, kEventParamKeyModifiers, typeUInt32, nil, 4, nil, @SCAKey );
              for i := 0 to 2 do
                if SCAKey and Modifier[ i ].bit > 0 Then
                  begin
                    if not keysDown[ Modifier[ i ].key ] Then
                      DoKeyPress( Modifier[ i ].key );
                    keysDown[ Modifier[ i ].key ] := TRUE;
                    keysUp  [ Modifier[ i ].key ] := FALSE;
                    keysLast[ KA_DOWN ]           := Modifier[ i ].key;
                  end else
                    begin
                      if keysDown[ Modifier[ i ].key ] Then
                        begin
                          keysUp[ Modifier[ i ].key ] := TRUE;
                          keysLast[ KA_UP ]           := Modifier[ i ].key;
                        end;
                      keysDown[ Modifier[ i ].key ] := FALSE;
                    end;
            end;
          kEventRawKeyDown, kEventRawKeyRepeat:
            begin
              Key := mackey_to_scancode( Key );
              keysDown[ Key ] := TRUE;
              keysUp  [ Key ] := FALSE;
              keysLast[ KA_DOWN ] := Key;
              if eKind <> kEventRawKeyRepeat Then
                DoKeyPress( Key );

              Key := SCA( Key );
              keysDown[ Key ] := TRUE;
              keysUp  [ Key ] := FALSE;
              if eKind <> kEventRawKeyRepeat Then
                DoKeyPress( Key );

              case Key of
                K_SYSRQ, K_PAUSE,
                K_ESCAPE, K_ENTER, K_KP_ENTER,
                K_UP, K_DOWN, K_LEFT, K_RIGHT,
                K_INSERT, K_DELETE, K_HOME, K_END,
                K_PAGEUP, K_PAGEDOWN,
                K_CTRL_L, K_CTRL_R,
                K_ALT_L, K_ALT_R,
                K_SHIFT_L, K_SHIFT_R,
                K_SUPER_L, K_SUPER_R,
                K_APP_MENU,
                K_CAPSLOCK, K_NUMLOCK, K_SCROLL:;
                K_BACKSPACE: u_Backspace( keysText );
                K_TAB:       key_InputText( '  ' );
              else
                GetEventParameter( inEvent, kEventParamKeyUnicodes, typeUTF8Text, nil, 6, @len, @c[ 0 ] );
                str := '';
                for i := 0 to len - 1 do
                  str := str + c[ i ];
                if str <> '' Then
                  key_InputText( str );
              end;
            end;
          kEventRawKeyUp:
            begin
              Key := mackey_to_scancode( Key );
              keysDown[ Key ] := FALSE;
              keysUp  [ Key ] := TRUE;
              keysLast[ KA_UP ] := Key;

              Key := SCA( Key );
              keysDown[ Key ] := FALSE;
              keysUp  [ Key ] := TRUE;
            end;
        end;
      end;

    kEventClassMouse:
      case eKind of
        kEventMouseMoved, kEventMouseDragged:
          begin
            GetEventParameter( inEvent, kEventParamMouseLocation, typeHIPoint, nil, SizeOf( HIPoint ), nil, @mPos );

            if not mouseLock Then
              begin
                mouseX := Round( mPos.X ) - wnd_X;
                mouseY := Round( mPos.Y ) - wnd_Y;
              end else
                begin
                  mouseX := Round( mPos.X - wnd_Width  / 2 );
                  mouseY := Round( mPos.Y - wnd_Height / 2 );
                end;

            wnd_MouseIn := ( mPos.X > wnd_X ) and ( mPos.X < wnd_X + wnd_Width ) and
                           ( mPos.Y > wnd_Y ) and ( mPos.Y < wnd_Y + wnd_Height );
            if wnd_MouseIn Then
              begin
                if ( not app_ShowCursor ) and ( CGCursorIsVisible = 1 ) Then
                  CGDisplayHideCursor( scr_Display );
                if ( app_ShowCursor ) and ( CGCursorIsVisible = 0 ) Then
                  CGDisplayShowCursor( scr_Display );
              end else
              if CGCursorIsVisible = 0 Then
                CGDisplayShowCursor( scr_Display );
          end;
        kEventMouseDown:
          begin
            GetEventParameter( inEvent, kEventParamMouseButton, typeMouseButton, nil, SizeOf( EventMouseButton ), nil, @mButton );

            case mButton of
              kEventMouseButtonPrimary: // Left
                begin
                  mouseDown[ M_BLEFT ]  := TRUE;
                  if mouseCanClick[ M_BLEFT ] Then
                    begin
                      mouseClick[ M_BLEFT ] := TRUE;
                      mouseCanClick[ M_BLEFT ] := FALSE;
                    end;
                end;
              kEventMouseButtonTertiary: // Midle
                begin
                  mouseDown[ M_BMIDLE ] := TRUE;
                  if mouseCanClick[ M_BMIDLE ] Then
                    begin
                      mouseClick[ M_BMIDLE ] := TRUE;
                      mouseCanClick[ M_BMIDLE ] := FALSE;
                    end;
                end;
              kEventMouseButtonSecondary: // Right
                begin
                  mouseDown[ M_BRIGHT ] := TRUE;
                  if mouseCanClick[ M_BRIGHT ] Then
                    begin
                      mouseClick[ M_BRIGHT ] := TRUE;
                      mouseCanClick[ M_BRIGHT ] := FALSE;
                    end;
                end;
            end;
          end;
        kEventMouseUp:
          begin
            GetEventParameter( inEvent, kEventParamMouseButton, typeMouseButton, nil, SizeOf( EventMouseButton ), nil, @mButton );

            case mButton of
              kEventMouseButtonPrimary: // Left
                begin
                  mouseDown[ M_BLEFT ]  := FALSE;
                  mouseUp  [ M_BLEFT ]  := TRUE;
                  mouseCanClick[ M_BLEFT ] := TRUE;
                end;
              kEventMouseButtonTertiary: // Midle
                begin
                  mouseDown[ M_BMIDLE ] := FALSE;
                  mouseUp  [ M_BMIDLE ] := TRUE;
                  mouseCanClick[ M_BMIDLE ] := TRUE;
                end;
              kEventMouseButtonSecondary: // Right
                begin
                  mouseDown[ M_BRIGHT ] := FALSE;
                  mouseUp  [ M_BRIGHT ] := TRUE;
                  mouseCanClick[ M_BRIGHT ] := TRUE;
                end;
            end;
          end;
        kEventMouseWheelMoved:
          begin
            GetEventParameter( inEvent, kEventParamMouseWheelDelta, typeSInt32, nil, 4, nil, @mWheel );

            if mWheel > 0 then
              mouseWheel[ M_WUP ] := TRUE
            else
              mouseWheel[ M_WDOWN ] := TRUE;
          end;
      end;
  end;
{$ENDIF}
end;

procedure app_CalcFPS;
begin
  app_FPS      := app_FPSCount;
  app_FPSAll   := app_FPSAll + app_FPSCount;
  app_FPSCount := 0;
  INC( app_WorkTime );
end;

end.
