#include <SFML/Graphics.hpp>
#include <vector>

#ifndef __TILE_INCLUDED__
#define __TILE_INCLUDED__

class Tile {
    public:
        Tile(uint32_t x, uint32_t y);
        Tile(uint32_t x, uint32_t y, uint32_t tile);
        Tile(uint32_t x, uint32_t y, uint32_t tile, bool hFlip, bool vFlip);
        void setTile(uint32_t tile);
        void setFlip(bool hFlip, bool vFlip);
        bool getFlip() {return new bool[2] {_hFlip, _vFlip}; };
        sf::VertexArray renderVertex;
    private:
        void updateRenderVertex();
        sf::Vector2f pos;
        sf::Vector2f texturePos;
        bool _hFlip = false;
        bool _vFlip = false;
};

class TileRow {
    public:
        TileRow() {};
        TileRow(uint16_t length);
        TileRow(uint16_t length, uint32_t src[]);
        TileRow(uint16_t length, uint32_t fillTile);

        void setTile(uint16_t offset, uint32_t tile) {_tiles[offset] = tile;};
        void fill(uint32_t tile) {_tiles.assign(_tiles.size(), tile);};
        void fillSome(uint16_t offset, uint16_t length, uint32_t tile) {_tiles.assign(length, tile);};

        void setFlip(uint16_t offset, bool hFlip, bool vFlip) {_flip[offset] = vFlip << 1 | hFlip;};
        void fillFlip(uint16_t offset, uint16_t length, bool hFlip, bool vFlip) {_flip.assign (length, vFlip << 1 | hFlip);};

        void copy(uint32_t src[]);
        void copy(uint16_t offset, uint16_t length, uint32_t src[]);

        std::vector <uint32_t> _tiles;
        std::vector <uint8_t> _flip;

};

class TileMatrix {
    public:
        TileMatrix(uint16_t width, uint16_t height);
        TileMatrix(uint16_t width, uint16_t height, TileRow tiles[]);
        TileMatrix(uint16_t width, uint16_t height, uint32_t fillTile);

        void fill(uint32_t tile);
        void fillRow(uint16_t row, uint32_t tile);
        void fillCol(uint16_t col, uint32_t tile);
        void fillRect(uint16_t x, uint16_t y, uint16_t width, uint16_t height, uint32_t tile);

        void setFlip(uint16_t x, uint16_t y, bool hFlip, bool vFlip);
        void setFlipRect(uint16_t x, uint16_t y, uint16_t width, uint16_t height, bool hFlip, bool vFlip);

        void copyRow(uint16_t row, uint32_t src[]);
        void copyCol(uint16_t col, uint32_t src[]);
        void copyRect(uint16_t x, uint16_t y, uint16_t width, uint16_t height, uint32_t src[]);
        void copyRect(uint16_t x, uint16_t y, uint16_t width, uint16_t height, TileRow src[]);

        void render(uint16_t x, uint16_t y, sf::RenderWindow *window, sf::Texture texture);
        sf::Texture renderToTexture(sf::Texture texture);

        uint16_t getWidth (){ return _width; };
        uint16_t getHeight (){ return _height; };

    private:

        uint16_t _width, _height;
        std::vector<TileRow> _tiles;

};

#endif