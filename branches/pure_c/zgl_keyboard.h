/*
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
 */

#ifndef ZGL_KEYBOARD_H
#define ZGL_KEYBOARD_H

#include <memory.h>

#include "zgl_types.h"

#define KA_DOWN      0x00
#define KA_UP        0x01

#define K_SYSRQ      0xB7
#define K_PAUSE      0xC5
#define K_ESCAPE     0x01
#define K_ENTER      0x1C
#define K_KP_ENTER   0x9C

#define K_UP         0xC8
#define K_DOWN       0xD0
#define K_LEFT       0xCB
#define K_RIGHT      0xCD

#define K_BACKSPACE  0x0E
#define K_SPACE      0x39
#define K_TAB        0x0F
#define K_TILDA      0x29

#define K_INSERT     0xD2
#define K_DELETE     0xD3
#define K_HOME       0xC7
#define K_END        0xCF
#define K_PAGEUP     0xC9
#define K_PAGEDOWN   0xD1

#define K_CTRL       0xFF - 0x01
#define K_CTRL_L     0x1D
#define K_CTRL_R     0x9D
#define K_ALT        0xFF - 0x02
#define K_ALT_L      0x38
#define K_ALT_R      0xB8
#define K_SHIFT      0xFF - 0x03
#define K_SHIFT_L    0x2A
#define K_SHIFT_R    0x36
#define K_SUPER_L    0xDB
#define K_SUPER_R    0xDC
#define K_APP_MENU   0xDD

#define K_CAPSLOCK   0x3A
#define K_NUMLOCK    0x45
#define K_SCROLL     0x46

#define K_BRACKET_L  0x1A /* [ { */
#define K_BRACKET_R  0x1B /* ] } */
#define K_BACKSLASH  0x2B /* \   */
#define K_SLASH      0x35 /* /   */
#define K_COMMA      0x33 /* ,   */
#define K_DECIMAL    0x34 /* .   */
#define K_SEMICOLON  0x27 /* :   */
#define K_APOSTROPHE 0x28 /* ' " */

#define K_0          0x0B
#define K_1          0x02
#define K_2          0x03
#define K_3          0x04
#define K_4          0x05
#define K_5          0x06
#define K_6          0x07
#define K_7          0x08
#define K_8          0x09
#define K_9          0x0A

#define K_MINUS      0x0C
#define K_EQUALS     0x0D

#define K_A          0x1E
#define K_B          0x30
#define K_C          0x2E
#define K_D          0x20
#define K_E          0x12
#define K_F          0x21
#define K_G          0x22
#define K_H          0x23
#define K_I          0x17
#define K_J          0x24
#define K_K          0x25
#define K_L          0x26
#define K_M          0x32
#define K_N          0x31
#define K_O          0x18
#define K_P          0x19
#define K_Q          0x10
#define K_R          0x13
#define K_S          0x1F
#define K_T          0x14
#define K_U          0x16
#define K_V          0x2F
#define K_W          0x11
#define K_X          0x2D
#define K_Y          0x15
#define K_Z          0x2C

#define K_KP_0       0x52
#define K_KP_1       0x4F
#define K_KP_2       0x50
#define K_KP_3       0x51
#define K_KP_4       0x4B
#define K_KP_5       0x4C
#define K_KP_6       0x4D
#define K_KP_7       0x47
#define K_KP_8       0x48
#define K_KP_9       0x49

#define K_KP_SUB     0x4A
#define K_KP_ADD     0x4E
#define K_KP_MUL     0x37
#define K_KP_DIV     0xB5
#define K_KP_DECIMAL 0x53

#define K_F1         0x3B
#define K_F2         0x3C
#define K_F3         0x3D
#define K_F4         0x3E
#define K_F5         0x3F
#define K_F6         0x40
#define K_F7         0x41
#define K_F8         0x42
#define K_F9         0x43
#define K_F10        0x44
#define K_F11        0x57
#define K_F12        0x58

extern bool  kDown[256];
extern bool  kUp[256];
extern bool  kPress[256];
extern bool  kCanPress[256];
extern char* kText;
extern int   kMax;
extern char  kLast[2];

extern bool key_Down( int KeyCode );
extern bool key_Up( int KeyCode );
extern bool key_Press( int KeyCode );
extern int  key_Last( int KeyAction );
extern void key_ClearState(void);

extern int  SCA( int KeyCode );
extern void DoKeyPress( int KeyCode );

#endif
