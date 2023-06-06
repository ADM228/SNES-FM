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
		$(error You seem to be running MacOS. Please contact me on Discord (alexmush#7063) and tell me the contents of $(ASAR_DIR)/asar so that i can make this available to compile on MacOS)
	endif	
endif


debug:
	"${ASAR_DIR}"/asar/"${ASAR_EXECUTABLE}" -v --symbols=wla --symbols-path="${current_dir}/SNESFMTrackDAW.sym" -I"${current_dir}/graphics" -I"${current_dir}/tables" -I"${current_dir}/source/sound" --fix-checksum=on "${current_dir}/source/gui/SNESFMTrackDAW.asm" "${current_dir}/SNESFMTrackDAW.sfc"
build: 
	"${ASAR_DIR}"/asar/"${ASAR_EXECUTABLE}" -v --symbols=none --fix-checksum=on -I"${current_dir}/graphics" -I"${current_dir}/tables" -I"${current_dir}/source/sound" "${current_dir}/source/gui/SNESFMTrackDAW.asm" "${current_dir}/SNESFMTrackDAW.sfc"
SFML:
	cd "SFMLtracker" && $(MAKE)

get_dependencies:
	$(info Installing asar...)
	mkdir -p "${ASAR_DIR}"
	curl -L "${ASAR_URL}" | tar -xz --strip-components=1 -C "${ASAR_DIR}"
	cd "${ASAR_DIR}" && cmake src && $(MAKE)

.PHONY: build