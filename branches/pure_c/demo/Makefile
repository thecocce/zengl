CC     = gcc
FLAGS  = -Wall
TARGET = demo
LINK   = -lX11 -lGL -lXxf86vm
SRC    = ../zgl_main.c \
         ../zgl_application.c \
				 ../zgl_mouse.c \
				 ../zgl_keyboard.c \
         ../zgl_log.c \
         ../linux/zgl_application.c \
         ../linux/zgl_screen.c \
         ../linux/zgl_window.c \
         ../linux/zgl_opengl.c

all:
	$(CC) demo.c $(SRC) $(LINK) $(FLAGS) -o $(TARGET)
