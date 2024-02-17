ASAR_URL = https://github.com/RPGHacker/asar/archive/refs/tags/v1.90RC1.tar.gz
ASAR_DIR = tools/asar
current_dir = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

ifeq ($(OS),Windows_NT)
	ASAR_EXECUTABLE := asar.exe
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		ASAR_EXECUTABLE := asar
	endif
	ifeq ($(UNAME_S),Darwin)
		$(error You seem to be running MacOS. Please contact me on Discord (alexmush) and tell me the contents of $(ASAR_DIR)/asar so that i can make this available to compile on MacOS)
	endif	
endif

SYM_GUI=none
SYM_SND=none

debug: SYM_GUI=wla --symbols-path="bin/SNESFMDemo.sym"
debug: SYM_SND=wla --symbols-path="bin/SNESFMDemo.smp.sym"

force_update_asar: rem_asar asar
build: asar SNESFM Demo
debug: asar SNESFM Demo

asar: ${ASAR_DIR}/asar/bin/${ASAR_EXECUTABLE}
SNESFM: bin/SNESFM.bin
Demo: bin/SNESFMDemo.sfc
    
rem_asar: ${ASAR_DIR}
	rm -rf ${ASAR_DIR}

bin/SNESFM.bin: asar bin source/sound/* tables/multTables.bin tables/pitch*.bin tables/quartersinetable.bin
	${ASAR_DIR}/asar/bin/${ASAR_EXECUTABLE} -v --symbols=${SYM_SND} -I"tables" -I"source/sound" "source/sound/demoConfig.asm" "bin/SNESFM.bin"

bin/SNESFMDemo.sfc: asar bin SNESFM source/gui/* graphics/palette.pal graphics/tilesetUnicode.chr tables/sinetable.bin
	${ASAR_DIR}/asar/bin/${ASAR_EXECUTABLE} -v --symbols=${SYM_GUI} -I"bin" -I"graphics" -I"tables" --fix-checksum=on "source/gui/SNESFMDemo.asm" "bin/SNESFMDemo.sfc"

bin:
	mkdir -p bin

clean:
	rm -f -R bin

${ASAR_DIR}/src/asar/*:
	$(info Installing asar...)
	mkdir -p "${ASAR_DIR}"
	wget -c "${ASAR_URL}" -O - | tar -xz --strip-components=1 -C "${ASAR_DIR}"

${ASAR_DIR}/asar/${ASAR_EXECUTABLE}: ${ASAR_DIR}/src/asar/*
	cd "${ASAR_DIR}" && cmake src > /dev/null && $(MAKE) > /dev/null

.PHONY: clean asar SNESFM Demo build debug rem_asar force_update_asar
.SILENT: build
