NASM=nasm 
LINK=link

# Check if DEBUG is defined
!IFNDEF DEBUG
DEBUG=1
!ENDIF

# NASM FLAGS for Debug and Release
!IF $(DEBUG)
NASMFLAGS=-f win64 -g -F cv8
!ELSE
NASMFLAGS=-f win64
!ENDIF

# LINK FLAGS for Debug and Release
LINKFLAGS=/subsystem:windows /entry:main /nologo 

!IF $(DEBUG)
LINKFLAGS=$(LINKFLAGS) /debug
!ENDIF

LIBS=kernel32.lib user32.lib gdi32.lib

OBJDIR=obj
BINDIR=bin

!IF ![IF NOT EXIST $(OBJDIR) mkdir $(OBJDIR)]
!ENDIF

!IF ![IF NOT EXIST $(BINDIR) mkdir $(BINDIR)]
!ENDIF

PROGRAMS=$(BINDIR)\x64_msgbox.exe \
				 $(BINDIR)\x64_window.exe \
				 $(BINDIR)\x64_window_game.exe

all: $(PROGRAMS)

$(BINDIR)\x64_msgbox.exe: $(OBJDIR)\x64_msgbox.obj
	$(LINK) $(LINKFLAGS) /out:$@ $** $(LIBS)

$(BINDIR)\x64_window.exe: $(OBJDIR)\x64_window.obj
	$(LINK) $(LINKFLAGS) /out:$@ $** $(LIBS)

$(BINDIR)\x64_window_game.exe: $(OBJDIR)\x64_window_game.obj
	$(LINK) $(LINKFLAGS) /out:$@ $** $(LIBS)


$(OBJDIR)\x64_msgbox.obj: src/x64_msgbox.asm
	$(NASM) $(NASMFLAGS) -o $@ $**

$(OBJDIR)\x64_window.obj: src/x64_window.asm
	$(NASM) $(NASMFLAGS) -o $@ $**

$(OBJDIR)\x64_window_game.obj: src/x64_window_game.asm
	$(NASM) $(NASMFLAGS) -o $@ $**

clean:
	IF EXIST $(OBJDIR) rmdir /s /q $(OBJDIR)
	IF EXIST $(BINDIR) rmdir /s /q $(BINDIR)
