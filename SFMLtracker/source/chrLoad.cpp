#include <fstream>
#include <cstdio>
#include <SFML/Graphics.hpp>

sf::Texture loadCharacter(uint32_t index){
    char buffer[16];
    uint8_t colorBuffer[8*8];
    sf::Uint8 pixels[8*8*4];
    const uint8_t tableRG[] = {0, 255, 160, 0};
    const uint8_t tableB[] = {0, 255, 176, 0};
    sf::Texture output;

    std::ifstream charFile("../graphics/tilesetUnicode.chr", std::ios::binary);
    if (!charFile.is_open()){
        printf("Could not open file");
        fflush(stdout);
        return output;
    }
    charFile.seekg(index*16);
    charFile.read(buffer, 16);
    for(int i = 0; i < 8; i++){
        colorBuffer[i*8] = (buffer[i<<1]>>7)&1 | (buffer[(i<<1)|1]>>6)&2;
        colorBuffer[i*8+1] = (buffer[i<<1]>>6)&1 | (buffer[(i<<1)|1]>>5)&2;
        colorBuffer[i*8+2] = (buffer[i<<1]>>5)&1 | (buffer[(i<<1)|1]>>4)&2;
        colorBuffer[i*8+3] = (buffer[i<<1]>>4)&1 | (buffer[(i<<1)|1]>>3)&2;
        colorBuffer[i*8+4] = (buffer[i<<1]>>3)&1 | (buffer[(i<<1)|1]>>2)&2;
        colorBuffer[i*8+5] = (buffer[i<<1]>>2)&1 | (buffer[(i<<1)|1]>>1)&2;
        colorBuffer[i*8+6] = (buffer[i<<1]>>1)&1 | buffer[(i<<1)|1]&2;
        colorBuffer[i*8+7] = buffer[i<<1]&1 | (buffer[(i<<1)|1]<<1)&2;
        printf("\n%02x: ", buffer[i<<1]);
        for (int j = 0; j < 8; j++){printf("%02x ", colorBuffer[i*8+j]); }
        fflush(stdout);
    }
    for (int i = 0; i < sizeof(colorBuffer); i++){
        pixels[i*4] = tableRG[colorBuffer[i]];
        pixels[i*4+1] = tableRG[colorBuffer[i]];
        pixels[i*4+2] = tableB[colorBuffer[i]];
        pixels[i*4+3] = colorBuffer[i] == 0 ? 0 : 255;
    }
    output.create(8,8);
    output.update(pixels, 8, 8, 0, 0);
    output.setSmooth(false);
    return output;
}

sf::Texture loadCharacters(uint32_t index, uint32_t amount){
    char buffer[16];
    uint8_t colorBuffer[8*8];
    sf::Uint8 pixels[8*8*4*amount];
    printf("Loading %d characters, which makes pixels %d bytes long\n", amount, sizeof(pixels));
    const uint8_t tableRG[] = {0, 255, 160, 0};
    const uint8_t tableB[] = {0, 255, 176, 0};
    sf::Texture output;

    std::ifstream charFile("../graphics/tilesetUnicode.chr", std::ios::binary);
    if (!charFile.is_open()){
        printf("Could not open file");
        fflush(stdout);
        return output;
    }
    charFile.seekg(index*16);
    for (int tile = 0; tile < amount; tile++) {
        charFile.read(buffer, 16);
        for(int i = 0; i < 8; i++){
            colorBuffer[i*8] = (buffer[i<<1]>>7)&1 | (buffer[(i<<1)|1]>>6)&2;
            colorBuffer[i*8+1] = (buffer[i<<1]>>6)&1 | (buffer[(i<<1)|1]>>5)&2;
            colorBuffer[i*8+2] = (buffer[i<<1]>>5)&1 | (buffer[(i<<1)|1]>>4)&2;
            colorBuffer[i*8+3] = (buffer[i<<1]>>4)&1 | (buffer[(i<<1)|1]>>3)&2;
            colorBuffer[i*8+4] = (buffer[i<<1]>>3)&1 | (buffer[(i<<1)|1]>>2)&2;
            colorBuffer[i*8+5] = (buffer[i<<1]>>2)&1 | (buffer[(i<<1)|1]>>1)&2;
            colorBuffer[i*8+6] = (buffer[i<<1]>>1)&1 | buffer[(i<<1)|1]&2;
            colorBuffer[i*8+7] = buffer[i<<1]&1 | (buffer[(i<<1)|1]<<1)&2;
        }
        for (int i = 0; i < sizeof(colorBuffer); i++){
            pixels[tile*256+i*4] = tableRG[colorBuffer[i]];
            pixels[tile*256+i*4+1] = tableRG[colorBuffer[i]];
            pixels[tile*256+i*4+2] = tableB[colorBuffer[i]];
            pixels[tile*256+i*4+3] = colorBuffer[i] == 0 ? 0 : 255;
        }
    }
    output.create(8,8*amount);
    output.update(pixels, 8, 8*amount, 0, 0);
    output.setSmooth(false);
    return output;
}