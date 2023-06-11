#include <fstream>
#include <string>
#include <cstdio>
#include <iomanip>
#include <locale>

#include <SFML/Graphics.hpp>

// utility wrapper to adapt locale-bound facets for wstring/wbuffer convert
template<class Facet>
struct deletable_facet : Facet
{
    template<class... Args>
    deletable_facet(Args&&... args) : Facet(std::forward<Args>(args)...) {}
    ~deletable_facet() {}
};

std::u32string To_UTF32(const std::string &s)
{
    std::wstring_convert<deletable_facet<std::codecvt<char32_t, char, std::mbstate_t>>, char32_t> conv;
    return conv.from_bytes(s);
}

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
    printf("Loading %d characters, which makes pixels %ld bytes long\n", amount, sizeof(pixels));
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

// sf::Texture renderText(sf::Texture font[], std::string string){
//     sf::Texture output;
//     std::u32string text = To_UTF32(string);
//     uint8_t bank;

//     output.create(text.length()*8, 8);

//     for (uint32_t i = 0; i < text.length(); i++){
//         bank = (text[i]&0xFF80)>>7;
//         // if (font[bank].getSize().x != 8){
//         //     output.
//         // }
//     }
//     return output;
// }

sf::VertexArray createTile(sf::Vector2i position, uint32_t tile){
    sf::VertexArray output (sf::TriangleFan);
    output.append(sf::Vertex(sf::Vector2f(position.x, position.y), sf::Vector2f(0, tile*8)));
    output.append(sf::Vertex(sf::Vector2f(position.x+8, position.y), sf::Vector2f(8, tile*8)));
    output.append(sf::Vertex(sf::Vector2f(position.x+8, position.y+8), sf::Vector2f(8, tile*8+8)));
    output.append(sf::Vertex(sf::Vector2f(position.x, position.y+8), sf::Vector2f(0, tile*8+8)));

    return output;
}