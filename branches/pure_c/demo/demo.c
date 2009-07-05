#include <stdio.h>

#include "../zgl_types.h"
#include "../zgl_main.h"
#include "../zgl_screen.h"
#include "../zgl_mouse.h"
#include "../zgl_keyboard.h"

bool fs;
int  w = 1024;
int  h = 768;

void Init()
{
  wnd_SetCaption( "ZenGL GCC" );
}

void Draw()
{
  gl_Set2DMode();

  glColor3f( 0.8, 0.8, 0.8 );
  glBegin(GL_QUADS);
    glVertex2f( 0, 0 );
    glVertex2f( w, 0 );
    glVertex2f( w, h );
    glVertex2f( 0, h );
  glEnd();
  glColor3f( 1, 1, 1 );
  glBegin(GL_QUADS);
    glVertex2f( 10,     10 );
    glVertex2f( w - 10, 10 );
    glVertex2f( w - 10, h - 10 );
    glVertex2f( 10,     h - 10 );
  glEnd();

  if ( key_Down( K_ALT ) && key_Press( K_ENTER ) ) {
    fs = !fs;
    scr_SetOptions( w, h, 32, 0, fs, 1 );
  }
  if ( key_Press( K_ESCAPE ) ) zgl_Exit();
  mouse_ClearState();
  key_ClearState();
}

int main(void)
{
  zgl_Reg( SYS_INIT, (void*)Init );
  zgl_Reg( SYS_DRAW, (void*)Draw );

  wnd_SetCaption( "ZenGL Pure C" );

  scr_SetOptions( 1024, 768, 32, 0, 0, 1 );

  wnd_ShowCursor( 1 );

  zgl_Init( 4, 0 );

  return 0;
}
