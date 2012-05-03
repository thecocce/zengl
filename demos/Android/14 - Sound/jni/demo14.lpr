library demo14;

{$I zglCustomConfig.cfg}

uses
  zgl_application,
  zgl_main,
  zgl_file,
  zgl_memory,
  zgl_screen,
  zgl_window,
  zgl_timers,
  zgl_touch,
  zgl_render_2d,
  zgl_fx,
  zgl_textures,
  zgl_textures_png,
  zgl_font,
  zgl_text,
  zgl_sprite_2d,
  zgl_sound,
  zgl_sound_wav,
  zgl_sound_ogg,
  zgl_math_2d,
  zgl_collision_2d,
  zgl_utils
  ;

const
  SCREEN_WIDTH  = 800;
  SCREEN_HEIGHT = 600;

var
  dirRes  : UTF8String = 'assets/';
  fntMain : zglPFont;
  icon    : array[ 0..1 ] of zglPTexture;
  sound   : zglPSound;
  audio   : Integer;
  state   : Integer;

  musicMem : zglTMemory;

// RU: Т.к. звуковая подсистема нацелена на 3D, для позиционирования звуков в 2D нужны некоторые ухищрения.
// EN: Because sound subsystem using 3D, there is some tricky way to calculate sound position in 2D.
function CalcX2D( const X : Single ) : Single;
begin
  Result := ( X - SCREEN_WIDTH / 2 ) * ( 1 / SCREEN_WIDTH / 2 );
end;

function CalcY2D( const Y : Single ) : Single;
begin
  Result := ( Y - SCREEN_HEIGHT / 2 ) * ( 1 / SCREEN_HEIGHT / 2 );
end;

procedure Init;
  var
    i : Integer;
begin
  zgl_Enable( CORRECT_RESOLUTION );
  scr_CorrectResolution( 800, 600 );

  // RU: Инициализируем звуковую подсистему. Для Windows можно сделать выбор между DirectSound и OpenAL отредактировав файл zgl_config.cfg.
  // EN: Initializing sound subsystem. For Windows can be used DirectSound or OpenAL, see zgl_config.cfg.
  snd_Init();

  file_OpenArchive( PAnsiChar( zgl_Get( DIRECTORY_APPLICATION ) ) );

  // RU: Загружаем звуковой файл и устанавливаем для него максимальноe количество проигрываемых источников в 2.
  // EN: Load the sound file and set maximum count of sources that can be played to 2.
  sound := snd_LoadFromFile( dirRes + 'click.wav', 2 );

  // RU: Загружаем текстуры, которые будут индикаторами.
  // EN: Load the textures, that will be indicators.
  icon[ 0 ] := tex_LoadFromFile( dirRes + 'audio-stop.png' );
  icon[ 1 ] := tex_LoadFromFile( dirRes + 'audio-play.png' );

  fntMain := font_LoadFromFile( dirRes + 'font.zfi' );

  // RU: Загружаем аудио-файл в память, т.к. читать его напрямую из архива потребует некоторых ухищрений.
  // EN: Load audio-file into memory, because reading it from archive will need some tricks.
  mem_LoadFromFile( musicMem, dirRes + 'music.ogg' );

  file_CloseArchive();
end;

procedure Draw;
  var
    r : zglTRect;
begin
  ssprite2d_Draw( icon[ state ], ( SCREEN_WIDTH - 128 ) / 2, ( SCREEN_HEIGHT - 128 ) / 2, 128, 128, 0 );
  text_Draw( fntMain, SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 + 64, 'Skillet - Comatose - Whispers In The Dark', TEXT_HALIGN_CENTER );

  r.X := ( SCREEN_WIDTH - 128 ) / 2;
  r.Y := ( SCREEN_HEIGHT - 128 ) / 2;
  r.W := 128;
  r.H := 128;
  if col2d_PointInRect( touch_X( 0 ), touch_Y( 0 ), r ) Then
    begin
      fx_SetBlendMode( FX_BLEND_ADD );
      ssprite2d_Draw( icon[ state ], ( SCREEN_WIDTH - 132 ) / 2, ( SCREEN_HEIGHT - 132 ) / 2, 132, 132, 0, 155 );
      fx_SetBlendMode( FX_BLEND_NORMAL );
    end;
end;

procedure Proc;
  var
    r : zglTRect;
    p : Integer;
begin
  // RU: Проверяем играет ли музыка(1 - играет, 0 - не играет). Так же можно проверить и звуки - подставив zglPSound и ID вот так:
  //     snd_Get( Sound, ID...
  //     ID возвращается функцией snd_Play
  //
  // EN: Check if music playing(1 - playing, 0 - not playing). Sounds also can be checked this way - just use zglPSound and ID:
  //     snd_Get( Sound, ID...
  //     ID returns by function snd_Play.
  state := snd_Get( SND_STREAM, audio, SND_STATE_PLAYING );
  if state = 0 Then
    audio := 0;

  if touch_Tap( 0 ) Then
    begin
      // RU: В данном случаи мы начинаем воспроизводить звук сразу в указанных координатах, но их можно менять и в процессе используя процедуру snd_SetPos.
      //     Важно: Для OpenAL можно позиционировать только mono-звуки
      //
      // EN: In this case, we begin to play the sound directly in these coordinates, but they can be changed later using procedure snd_SetPos.
      //     Important: OpenAL can position only mono-sounds.
      snd_Play( sound, FALSE, CalcX2D( touch_X( 0 ) ), CalcY2D( touch_Y( 0 ) ) );

      r.X := ( SCREEN_WIDTH - 128 ) / 2;
      r.Y := ( SCREEN_HEIGHT - 128 ) / 2;
      r.W := 128;
      r.H := 128;
      if col2d_PointInRect( touch_X( 0 ), touch_Y( 0 ), r ) and ( audio = 0 ) Then
        audio := snd_PlayMemory( musicMem, 'OGG' );
    end;

  // RU: Получаем в процентах позицию проигрывания аудиопотока и ставим громкость для плавных переходов.
  // EN: Get position in percent's for audio stream and set volume for smooth playing.
  p := snd_Get( SND_STREAM, audio, SND_STATE_PERCENT );
  if ( p >= 0 ) and ( p < 25 ) Then
    snd_SetVolume( SND_STREAM, audio, ( 1 / 24 ) * p );
  if ( p >= 75 ) and ( p < 100 ) Then
    snd_SetVolume( SND_STREAM, audio, 1 - ( 1 / 24 ) * ( p - 75 ) );

  touch_ClearState();
end;

procedure Java_zengl_android_ZenGL_Main( var env; var thiz ); cdecl;
begin
  randomize();

  timer_Add( @Proc, 16 );

  zgl_Reg( SYS_LOAD, @Init );
  zgl_Reg( SYS_DRAW, @Draw );

  scr_SetOptions( SCREEN_WIDTH, SCREEN_HEIGHT, REFRESH_MAXIMUM, TRUE, TRUE );
end;

exports
  Java_zengl_android_ZenGL_Main,
  {$I android_export.inc}

Begin
End.
