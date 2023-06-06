
build: compile link
compile:
	mkdir -p bin
	g++ -o bin/main.o -c source/main.cpp
link: compile 
	g++ bin/main.o -o bin/tracker -lsfml-graphics -lsfml-window -lsfml-system

run: compile link
	bin/tracker

.PHONY: build