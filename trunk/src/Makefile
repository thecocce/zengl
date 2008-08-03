VERSION = 0.0.22
FPC     = fpc
#FPC     = fpc.exe
FLAGS   = -O3 -XdsX -CX
#
INCLUDE = -Fuzgl_units \
-Fuzgl_units/system \
-Fuzgl_units/input \
-Fuzgl_units/textures \
-Fuzgl_units/sound \
-Fuzgl_units/collision \
-Fusys_units \
-Fusys_units/gl \
-Fusys_units/pasjpeg \
-Fusys_units/paszlib \
-Fusys_units/openal \
-Fusys_units/directsound
#
OUTPUT  = ./deb/usr/lib/
TMP     = -FUtmp
TARGET  = libZenGL.so
TARGETW = ZenGL.dll

all: clean
	$(FPC) zengl.pp $(INCLUDE) -FE$(OUTPUT) $(TMP) $(FLAGS) -o$(TARGET) -TLINUX
	strip $(OUTPUT)$(TARGET) --strip-unneeded -R .comment -R .note

deb: clean
	dpkg --build ./deb libzengl-$(VERSION)_i386.deb

rpm: clean
	rpmbuild -bb ./rpm/libzengl.spec --target i686

win32: clean
	$(FPC) zengl.pp $(INCLUDE) $(TMP) $(FLAGS) -o$(TARGETW) -TWIN32 -WG

#inwin32: cleanw
#	$(FPC) zengl.pp $(INCLUDE) $(TMP) $(FLAGS) -o$(TARGETW) -TWIN32 -WG

clean:
	rm -f *.*~
	rm -f ./tmp/*
	rm -f ./sys_units/*.*~
	rm -f ./zgl_units/*.*~
	rm -f ./zgl_units/system/*.*~
	rm -f ./zgl_units/input/*.*~
	rm -f ./zgl_units/textures/*.*~
	rm -f ./zgl_units/sound/*.*~
	rm -f ./zgl_units/collision/*.*~

install: uninstall
	install -m 644 $(OUTPUT)$(TARGET) /usr/lib

uninstall:
	rm -f /usr/lib/$(TARGET)
