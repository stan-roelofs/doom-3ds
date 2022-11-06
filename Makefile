#---------------------------------------------------------------------------------
.SUFFIXES:
#---------------------------------------------------------------------------------

ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

TOPDIR ?= $(CURDIR)
include $(DEVKITARM)/3ds_rules

#---------------------------------------------------------------------------------
# TARGET is the name of the output
# BUILD is the directory where object files & intermediate files will be placed
# SOURCES is a list of directories containing source code
# DATA is a list of directories containing data files
# INCLUDES is a list of directories containing header files
# GRAPHICS is a list of directories containing graphics files
# GFXBUILD is the directory where converted graphics files will be placed
#   If set to $(BUILD), it will statically link in the converted
#   files as if they were data files.
#
# NO_SMDH: if set to anything, no SMDH file is generated.
# ROMFS is the directory which contains the RomFS, relative to the Makefile (Optional)
# APP_TITLE is the name of the app stored in the SMDH file (Optional)
# APP_DESCRIPTION is the description of the app stored in the SMDH file (Optional)
# APP_AUTHOR is the author of the app stored in the SMDH file (Optional)
# ICON is the filename of the icon (.png), relative to the project folder.
#   If not set, it attempts to use one of the following (in this order):
#     - <Project name>.png
#     - icon.png
#     - <libctru folder>/default_icon.png
#---------------------------------------------------------------------------------
TARGET		:=	$(notdir $(CURDIR))
BUILD		:=	build
SOURCES		:=	src src/doom
DATA		:=	data
INCLUDES	:=	$(CURDIR)/include $(CURDIR/src/doom) $(CURDIR)/src $(CURDIR)/textscreen $(DEVKITPRO)/portlibs/3ds/include/SDL $(DEVKITPRO)/portlibs/3ds/include $(CTRULIB)/include
LIBDIRS	:= $(CTRULIB)/lib $(DEVKITPRO)/portlibs/3ds/lib
GRAPHICS	:=	gfx
GFXBUILD	:=	$(BUILD)
ROMFS		:=	romfs
#GFXBUILD	:=	$(ROMFS)/gfx

$(info $(INCLUDES))
#---------------------------------------------------------------------------------
# options for code generation
#---------------------------------------------------------------------------------
ARCH	:=	-march=armv6k -mtune=mpcore -mfloat-abi=hard -mtp=soft

CFLAGS	:=	-g -Wall -O2 -mword-relocations \
			-ffunction-sections \
			$(ARCH)

CFLAGS	+=	$(INCLUDE) -D__3DS__

CXXFLAGS	:= $(CFLAGS) -fno-rtti -fno-exceptions -std=gnu++11

ASFLAGS	:=	-g $(ARCH)
LDFLAGS	=	-specs=3dsx.specs -g $(ARCH) -Wl,-Map,$(notdir $*.map)

LIBS	:= -lSDL_mixer -lmpg123 -lmodplug -lvorbisidec -logg -lopusfile -lopus -lmikmod -lmad -lSDL -lm -lstdc++ -lcitro2d -lcitro3d -lctru -lm

#---------------------------------------------------------------------------------
# no real need to edit anything past this point unless you need to add additional
# rules for different file extensions
#---------------------------------------------------------------------------------
ifneq ($(BUILD),$(notdir $(CURDIR)))
#---------------------------------------------------------------------------------

export OUTPUT	:=	$(CURDIR)/$(TARGET)
export TOPDIR	:=	$(CURDIR)

export VPATH	:=	$(foreach dir,$(SOURCES),$(CURDIR)/$(dir)) \
			$(foreach dir,$(GRAPHICS),$(CURDIR)/$(dir)) \
			$(foreach dir,$(DATA),$(CURDIR)/$(dir))

export DEPSDIR	:=	$(CURDIR)/$(BUILD)

COMMON_SOURCE_FILES := \
i_main.c                                   \
i_system.c           i_system.h            \
m_argv.c             m_argv.h              \
m_misc.c             m_misc.h

GAME_SOURCE_FILES=\
d_event.c            d_event.h             \
                     doomkeys.h            \
                     doomfeatures.h        \
                     doomtype.h            \
d_iwad.c             d_iwad.h              \
d_loop.c             d_loop.h              \
d_mode.c             d_mode.h              \
                     d_ticcmd.h            \
deh_str.c            deh_str.h             \
i_cdmus.c            i_cdmus.h             \
i_endoom.c           i_endoom.h            \
i_joystick.c         i_joystick.h          \
i_scale.c            i_scale.h             \
                     i_swap.h              \
i_sound.c            i_sound.h             \
i_timer.c            i_timer.h             \
i_video.c            i_video.h             \
i_videohr.c          i_videohr.h           \
m_bbox.c             m_bbox.h              \
m_cheat.c            m_cheat.h             \
m_config.c           m_config.h            \
m_controls.c         m_controls.h          \
m_fixed.c            m_fixed.h             \
sha1.c               sha1.h                \
memio.c              memio.h               \
tables.c             tables.h              \
v_diskicon.c         v_diskicon.h          \
v_video.c            v_video.h             \
                     v_patch.h             \
w_checksum.c         w_checksum.h          \
w_main.c             w_main.h              \
w_wad.c              w_wad.h               \
w_file.c             w_file.h              \
w_file_stdc.c                              \
w_file_posix.c                             \
w_file_win32.c                             \
z_zone.c             z_zone.h

FEATURE_DEHACKED_SOURCE_FILES :=            \
deh_defs.h                                 \
deh_io.c             deh_io.h              \
deh_main.c           deh_main.h            \
deh_mapping.c        deh_mapping.h         \
deh_text.c

FEATURE_MULTIPLAYER_SOURCE_FILES=          \
aes_prng.c           aes_prng.h            \
net_client.c         net_client.h          \
net_common.c         net_common.h          \
net_dedicated.c      net_dedicated.h       \
net_defs.h                                 \
net_gui.c            net_gui.h             \
net_io.c             net_io.h              \
net_loop.c           net_loop.h            \
net_packet.c         net_packet.h          \
net_query.c          net_query.h           \
net_sdl.c            net_sdl.h             \
net_server.c         net_server.h          \
net_structrw.c       net_structrw.h

FEATURE_WAD_MERGE_SOURCE_FILES =           \
w_merge.c            w_merge.h

FEATURE_SOUND_SOURCE_FILES =               \
gusconf.c            gusconf.h             \
i_pcsound.c                                \
i_sdlsound.c                               \
i_sdlmusic.c                               \
i_oplmusic.c                               \
midifile.c           midifile.h            \
mus2mid.c            mus2mid.h

DOOM_SOURCE_FILES :=                   \
am_map.c           am_map.h     \
                   d_englsh.h   \
d_items.c          d_items.h    \
d_main.c           d_main.h     \
d_net.c                         \
                   doomdata.h   \
doomdef.c          doomdef.h    \
doomstat.c         doomstat.h   \
                   d_player.h   \
dstrings.c         dstrings.h   \
                   d_textur.h   \
                   d_think.h    \
f_finale.c         f_finale.h   \
f_wipe.c           f_wipe.h     \
g_game.c           g_game.h     \
hu_lib.c           hu_lib.h     \
hu_stuff.c         hu_stuff.h   \
info.c             info.h       \
m_menu.c           m_menu.h     \
m_random.c         m_random.h   \
p_ceilng.c                      \
p_doors.c                       \
p_enemy.c                       \
p_floor.c                       \
p_inter.c          p_inter.h    \
p_lights.c                      \
                   p_local.h    \
p_map.c                         \
p_maputl.c                      \
p_mobj.c           p_mobj.h     \
p_plats.c                       \
p_pspr.c           p_pspr.h     \
p_saveg.c          p_saveg.h    \
p_setup.c          p_setup.h    \
p_sight.c                       \
p_spec.c           p_spec.h     \
p_switch.c                      \
p_telept.c                      \
p_tick.c           p_tick.h     \
p_user.c                        \
r_bsp.c            r_bsp.h      \
r_data.c           r_data.h     \
                   r_defs.h     \
r_draw.c           r_draw.h     \
                   r_local.h    \
r_main.c           r_main.h     \
r_plane.c          r_plane.h    \
r_segs.c           r_segs.h     \
r_sky.c            r_sky.h      \
                   r_state.h    \
r_things.c         r_things.h   \
s_sound.c          s_sound.h    \
sounds.c           sounds.h     \
statdump.c         statdump.h   \
st_lib.c           st_lib.h     \
st_stuff.c         st_stuff.h   \
wi_stuff.c         wi_stuff.h

FEATURE_DOOM_DEHACKED_SOURCE_FILES :=            \
deh_ammo.c                                 \
deh_bexstr.c                               \
deh_cheat.c                                \
deh_doom.c                                 \
deh_frame.c                                \
deh_misc.c           deh_misc.h            \
deh_ptr.c                                  \
deh_sound.c                                \
deh_thing.c                                \
deh_weapon.c

OPL_SOURCES :=                                \
                            opl_internal.h        \
        opl.c               opl.h                 \
        opl_linux.c                               \
        opl_obsd.c                                \
        opl_queue.c         opl_queue.h           \
        opl_sdl.c                                 \
        opl_timer.c         opl_timer.h           \
        opl_win32.c                               \
        ioperm_sys.c        ioperm_sys.h          \
        opl3.c              opl3.h

SOURCE_FILES := $(COMMON_SOURCE_FILES) \
				$(GAME_SOURCE_FILES) \
				$(FEATURE_DEHACKED_SOURCE_FILES) \
				$(FEATURE_MULTIPLAYER_SOURCE_FILES) \
				$(FEATURE_WAD_MERGE_SOURCE_FILES) \
				$(FEATURE_SOUND_SOURCE_FILES) \
				$(foreach file,$(DOOM_SOURCE_FILES),doom/$(file)) \
				$(foreach file,$(FEATURE_DOOM_DEHACKED_SOURCE_FILES),doom/$(file)) \
				$(OPL_SOURCES)
# TODO not sure the doom/*.* files are handled correctly

CFILES		:=	$(filter %.c,$(SOURCE_FILES))
CPPFILES	:=	$(filter %.cpp,$(SOURCE_FILES))

$(info SOURCE_FILES=$(SOURCE_FILES))


SFILES		:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.s)))
PICAFILES	:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.v.pica)))
SHLISTFILES	:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.shlist)))
GFXFILES	:=	$(foreach dir,$(GRAPHICS),$(notdir $(wildcard $(dir)/*.t3s)))
BINFILES	:=	$(foreach dir,$(DATA),$(notdir $(wildcard $(dir)/*.*)))

#---------------------------------------------------------------------------------
# use CXX for linking C++ projects, CC for standard C
#---------------------------------------------------------------------------------
ifeq ($(strip $(CPPFILES)),)
#---------------------------------------------------------------------------------
	export LD	:=	$(CC)
#---------------------------------------------------------------------------------
else
#---------------------------------------------------------------------------------
	export LD	:=	$(CXX)
#---------------------------------------------------------------------------------
endif
#---------------------------------------------------------------------------------

#---------------------------------------------------------------------------------
ifeq ($(GFXBUILD),$(BUILD))
#---------------------------------------------------------------------------------
export T3XFILES :=  $(GFXFILES:.t3s=.t3x)
#---------------------------------------------------------------------------------
else
#---------------------------------------------------------------------------------
export ROMFS_T3XFILES	:=	$(patsubst %.t3s, $(GFXBUILD)/%.t3x, $(GFXFILES))
export T3XHFILES		:=	$(patsubst %.t3s, $(BUILD)/%.h, $(GFXFILES))
#---------------------------------------------------------------------------------
endif
#---------------------------------------------------------------------------------

export OFILES_SOURCES 	:=	$(CPPFILES:.cpp=.o) $(CFILES:.c=.o) $(SFILES:.s=.o)

export OFILES_BIN	:=	$(addsuffix .o,$(BINFILES)) \
			$(PICAFILES:.v.pica=.shbin.o) $(SHLISTFILES:.shlist=.shbin.o) \
			$(addsuffix .o,$(T3XFILES))

export OFILES := $(OFILES_BIN) $(OFILES_SOURCES)

export HFILES	:=	$(PICAFILES:.v.pica=_shbin.h) $(SHLISTFILES:.shlist=_shbin.h) \
			$(addsuffix .h,$(subst .,_,$(BINFILES))) \
			$(GFXFILES:.t3s=.h)

export INCLUDE	:=	$(foreach dir,$(INCLUDES),-I$(dir)) \
			-I$(CURDIR)/$(BUILD)

export LIBPATHS	:=	$(foreach dir,$(LIBDIRS),-L$(dir))

export _3DSXDEPS	:=	$(if $(NO_SMDH),,$(OUTPUT).smdh)

ifeq ($(strip $(ICON)),)
	icons := $(wildcard *.png)
	ifneq (,$(findstring $(TARGET).png,$(icons)))
		export APP_ICON := $(TOPDIR)/$(TARGET).png
	else
		ifneq (,$(findstring icon.png,$(icons)))
			export APP_ICON := $(TOPDIR)/icon.png
		endif
	endif
else
	export APP_ICON := $(TOPDIR)/$(ICON)
endif

ifeq ($(strip $(NO_SMDH)),)
	export _3DSXFLAGS += --smdh=$(CURDIR)/$(TARGET).smdh
endif

ifneq ($(ROMFS),)
	export _3DSXFLAGS += --romfs=$(CURDIR)/$(ROMFS)
endif

.PHONY: all clean

#---------------------------------------------------------------------------------
all: $(BUILD) $(GFXBUILD) $(DEPSDIR) $(ROMFS_T3XFILES) $(T3XHFILES)
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile

$(BUILD):
	@mkdir -p $@

ifneq ($(GFXBUILD),$(BUILD))
$(GFXBUILD):
	@mkdir -p $@
endif

ifneq ($(DEPSDIR),$(BUILD))
$(DEPSDIR):
	@mkdir -p $@
endif

#---------------------------------------------------------------------------------
clean:
	@echo clean ...
	@rm -fr $(BUILD) $(TARGET).3dsx $(OUTPUT).smdh $(TARGET).elf $(GFXBUILD)

#---------------------------------------------------------------------------------
$(GFXBUILD)/%.t3x	$(BUILD)/%.h	:	%.t3s
#---------------------------------------------------------------------------------
	@echo $(notdir $<)
	@tex3ds -i $< -H $(BUILD)/$*.h -d $(DEPSDIR)/$*.d -o $(GFXBUILD)/$*.t3x

#---------------------------------------------------------------------------------
else

#---------------------------------------------------------------------------------
# main targets
#---------------------------------------------------------------------------------
$(OUTPUT).3dsx	:	$(OUTPUT).elf $(_3DSXDEPS)

$(OFILES_SOURCES) : $(HFILES)

$(OUTPUT).elf	:	$(OFILES)

#---------------------------------------------------------------------------------
# you need a rule like this for each extension you use as binary data
#---------------------------------------------------------------------------------
%.bin.o	%_bin.h :	%.bin
#---------------------------------------------------------------------------------
	@echo $(notdir $<)
	@$(bin2o)

#---------------------------------------------------------------------------------
.PRECIOUS	:	%.t3x
#---------------------------------------------------------------------------------
%.t3x.o	%_t3x.h :	%.t3x
#---------------------------------------------------------------------------------
	@echo $(notdir $<)
	@$(bin2o)

#---------------------------------------------------------------------------------
# rules for assembling GPU shaders
#---------------------------------------------------------------------------------
define shader-as
	$(eval CURBIN := $*.shbin)
	$(eval DEPSFILE := $(DEPSDIR)/$*.shbin.d)
	echo "$(CURBIN).o: $< $1" > $(DEPSFILE)
	echo "extern const u8" `(echo $(CURBIN) | sed -e 's/^\([0-9]\)/_\1/' | tr . _)`"_end[];" > `(echo $(CURBIN) | tr . _)`.h
	echo "extern const u8" `(echo $(CURBIN) | sed -e 's/^\([0-9]\)/_\1/' | tr . _)`"[];" >> `(echo $(CURBIN) | tr . _)`.h
	echo "extern const u32" `(echo $(CURBIN) | sed -e 's/^\([0-9]\)/_\1/' | tr . _)`_size";" >> `(echo $(CURBIN) | tr . _)`.h
	picasso -o $(CURBIN) $1
	bin2s $(CURBIN) | $(AS) -o $*.shbin.o
endef

%.shbin.o %_shbin.h : %.v.pica %.g.pica
	@echo $(notdir $^)
	@$(call shader-as,$^)

%.shbin.o %_shbin.h : %.v.pica
	@echo $(notdir $<)
	@$(call shader-as,$<)

%.shbin.o %_shbin.h : %.shlist
	@echo $(notdir $<)
	@$(call shader-as,$(foreach file,$(shell cat $<),$(dir $<)$(file)))

#---------------------------------------------------------------------------------
%.t3x	%.h	:	%.t3s
#---------------------------------------------------------------------------------
	@echo $(notdir $<)
	@tex3ds -i $< -H $*.h -d $*.d -o $*.t3x

-include $(DEPSDIR)/*.d

#---------------------------------------------------------------------------------------
endif
#---------------------------------------------------------------------------------------
