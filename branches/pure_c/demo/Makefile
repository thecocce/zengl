CC     = gcc
FLAGS  = -Wall -O3 -march=i686 -mtune=i686
TARGET = demo
LINK   = -lX11 -lGL -lXxf86vm
SRC    = ../zgl_main.c \
         ../zgl_application.c \
				 ../zgl_opengl.c \
				 ../zgl_mouse.c \
				 ../zgl_keyboard.c \
         ../zgl_log.c \
				 ../zgl_utils.c
LINUX  = ../linux/zgl_application.c \
         ../linux/zgl_screen.c \
         ../linux/zgl_window.c \
         ../linux/zgl_opengl.c \
				 ../linux/zgl_utils.c
WIN32  = ../win32/zgl_application.c \
         ../win32/zgl_screen.c \
         ../win32/zgl_window.c \
         ../win32/zgl_opengl.c \
				 ../win32/zgl_utils.c

all:
	$(CC) demo.c $(SRC) $(LINUX) $(LINK) $(FLAGS) -o $(TARGET)

clean:
	rm demo
	rm log.txt
