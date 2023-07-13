ASAR_URL = https://github.com/RPGHacker/asar/archive/refs/tags/v1.81.tar.gz
ASAR_DIR = tools/asar
current_dir = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

ifeq ($(OS),Windows_NT)
	ASAR_EXECUTABLE := asar.exe
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		ASAR_EXECUTABLE := asar-standalone
	endif
	ifeq ($(UNAME_S),Darwin)
		$(error You seem to be running MacOS. Please contact me on Discord (alexmush) and tell me the contents of $(ASAR_DIR)/asar so that i can make this available to compile on MacOS)
	endif	
endif

SYM_GUI=none
SYM_SND=none

debug: SYM_GUI=wla --symbols-path="bin/SNESFMTrackDAW.sym"
debug: SYM_SND=wla --symbols-path="bin/SNESFMTrackDAW.smp.sym"

build: asar SNESFM TDAW
debug: asar SNESFM TDAW

asar: ${ASAR_DIR}/asar/${ASAR_EXECUTABLE}
SNESFM: bin/SNESFM.bin
TDAW: bin/SNESFMTrackDAW.sfc
    
bin/SNESFM.bin: bin source/sound/* tables/lookuptables.bin tables/pitchtable.bin tables/quartersinetable.bin
	${ASAR_DIR}/asar/${ASAR_EXECUTABLE} -v --symbols=${SYM_SND} -I"tables" -I"source/sound" "source/sound/SNESFM.asm" "bin/SNESFM.bin"

bin/SNESFMTrackDAW.sfc: bin bin/SNESFM.bin source/gui/* graphics/palette.pal graphics/tilesetUnicode.chr tables/sinetable.bin
	${ASAR_DIR}/asar/${ASAR_EXECUTABLE} -v --symbols=${SYM_GUI} -I"bin" -I"graphics" -I"tables" --fix-checksum=on "source/gui/SNESFMTrackDAW.asm" "bin/SNESFMTrackDAW.sfc"

bin:
	mkdir -p bin

SFML:
	cd "SFMLtracker" && $(MAKE)

clean:
	rm -f -R bin

${ASAR_DIR}/src/asar/*:
	$(info Installing asar...)
	mkdir -p "${ASAR_DIR}"
	wget -c "${ASAR_URL}" -O - | tar -xz --strip-components=1 -C "${ASAR_DIR}"

${ASAR_DIR}/asar/${ASAR_EXECUTABLE}: ${ASAR_DIR}/src/asar/*
	cd "${ASAR_DIR}" && cmake src > /dev/null && $(MAKE) > /dev/null

.PHONY: SFML clean asar SNESFM TDAW build debug
.SILENT: build
