#include "Tile.hpp"
#include <iostream>
#include <stdexcept>

Tile::Tile(uint32_t x, uint32_t y){
    pos.x = x * 8;
    pos.y = y * 8;
    texturePos = sf::Vector2f{0, 0};
    updateRenderVertex();
}

Tile::Tile(uint32_t x, uint32_t y, uint32_t tile){
    pos.x = x * 8;
    pos.y = y * 8;
    texturePos = sf::Vector2f{0, (tile & 0x7F) << 3};
    updateRenderVertex();
}

Tile::Tile(uint32_t x, uint32_t y, uint32_t tile, bool hFlip, bool vFlip){
    pos.x = x * 8;
    pos.y = y * 8;
    texturePos = sf::Vector2f{0, (tile & 0x7F) << 3};
    _hFlip = hFlip;
    _vFlip = vFlip;
    updateRenderVertex();
}

void Tile::setFlip(bool hFlip, bool vFlip){
    _hFlip = hFlip;
    _vFlip = vFlip;
    updateRenderVertex();
}

void Tile::setTile(uint32_t tile){
    texturePos = sf::Vector2f{0, (tile & 0x7F) << 3};
    updateRenderVertex();
}

void Tile::updateRenderVertex(){
    renderVertex = sf::VertexArray(sf::TriangleFan);
    renderVertex.append(sf::Vertex(pos, texturePos+sf::Vector2f(_hFlip?8:0,_vFlip?8:0)));
    renderVertex.append(sf::Vertex(pos+sf::Vector2f(8,0), texturePos+sf::Vector2f(_hFlip?0:8,_vFlip?8:0)));
    renderVertex.append(sf::Vertex(pos+sf::Vector2f(8,8), texturePos+sf::Vector2f(_hFlip?0:8,_vFlip?0:8)));
    renderVertex.append(sf::Vertex(pos+sf::Vector2f(0,8), texturePos+sf::Vector2f(_hFlip?8:0,_vFlip?0:8)));
}

// Tile row shit

TileRow::TileRow(uint16_t length){
    _tiles = std::vector<uint32_t>(length);
    _tiles.assign(length, 0);
    _flip = std::vector<uint8_t>(length);
    _flip.assign(length, 0);
}

TileRow::TileRow(uint16_t length, uint32_t fillTile){
    _tiles = std::vector<uint32_t>(length);
    _tiles.assign(length, fillTile);
    _flip = std::vector<uint8_t>(length);
    _flip.assign(length, 0);
}

TileRow::TileRow(uint16_t length, uint32_t src[]){
    _tiles = std::vector<uint32_t>(length);
    for (uint16_t i = 0; i < _tiles.size(); i++){_tiles[i] = src[i];}
    _flip = std::vector<uint8_t>(length);
    _flip.assign(length, 0);
}

void TileRow::copy (uint32_t src[]){
    for (uint16_t i = 0; i < _tiles.size(); i++){_tiles[i] = src[i];}
}

void TileRow::copy (uint16_t offset, uint16_t length, uint32_t src[]){
    if (offset >= _tiles.size()) {throw std::invalid_argument("[TileRow::copy (uint16_t offset, uint16_t length, uint32_t src[])]: offset is out of bounds");}
    if (offset+length > _tiles.size()) {throw std::invalid_argument("[TileRow::copy (uint16_t offset, uint16_t length, uint32_t src[])]: offset+length is out of bounds");}
    for (uint16_t i = offset; i < offset+length; i++){_tiles[i] = src[i];}
}

TileMatrix::TileMatrix(uint16_t width, uint16_t height){
    _tiles = std::vector<TileRow>(height);
    _tiles.assign(height, TileRow(width));
    _height = height;
    _width = width;
}

TileMatrix::TileMatrix(uint16_t width, uint16_t height, TileRow tiles[]){
    _tiles = std::vector<TileRow>(height);
    for (uint16_t i = 0; i < height; i++) {_tiles[i] = tiles[i];}
    _height = height;
    _width = width;
}

TileMatrix::TileMatrix(uint16_t width, uint16_t height, uint32_t fillTile){
    _tiles = std::vector<TileRow>(height);
    _tiles.assign(height, TileRow(width, fillTile));
    _height = height;
    _width = width;
}

void TileMatrix::fill(uint32_t tile){
    for (uint16_t i = 0; i < _height; i++) {_tiles[i]._tiles.assign(_width, tile);}
}

void TileMatrix::fillRow(uint16_t row, uint32_t tile){
    if (row >= _height) {throw std::invalid_argument("[TileMatrix::fillRow(uint16_t row, uint32_t tile)]: row is out of bounds");}
    _tiles[row]._tiles.assign(_width, tile);
}

void TileMatrix::fillCol(uint16_t col, uint32_t tile){
    if (col >= _width) {throw std::invalid_argument("[TileMatrix::fillCol(uint16_t col, uint32_t tile)]: col is out of bounds");}
    for (uint16_t i = 0; i < _height; i++) {_tiles[i]._tiles[col] = tile;}
}

void TileMatrix::fillRect(uint16_t x, uint16_t y, uint16_t width, uint16_t height, uint32_t tile){
    if (x >= _width) {throw std::invalid_argument("[TileMatrix::fillRect(uint16_t x, uint16_t y, uint16_t width, uint16_t height, uint32_t tile)]: x is out of bounds");}
    if (y >= _height) {throw std::invalid_argument("[TileMatrix::fillRect(uint16_t x, uint16_t y, uint16_t width, uint16_t height, uint32_t tile)]: y is out of bounds");}
    if (width+x > _width) {throw std::invalid_argument("[TileMatrix::fillRect(uint16_t x, uint16_t y, uint16_t width, uint16_t height, uint32_t tile)]: width+x is out of bounds");}
    if (height+y > _height) {throw std::invalid_argument("[TileMatrix::fillRect(uint16_t x, uint16_t y, uint16_t width, uint16_t height, uint32_t tile)]: height+y is out of bounds");}
    for (uint16_t i = y; i < _height; i++) {
        for (uint16_t j = x; j < width; j++) {_tiles[i]._tiles[j] = tile;}
    }
}

void TileMatrix::setFlip(uint16_t x, uint16_t y, bool hFlip, bool vFlip){
    if (x >= _width) {throw std::invalid_argument("[TileMatrix::setFlip(uint16_t x, uint16_t y, bool hFlip, bool vFlip)]: x is out of bounds");}
    if (y >= _height) {throw std::invalid_argument("[TileMatrix::setFlip(uint16_t x, uint16_t y, bool hFlip, bool vFlip)]: y is out of bounds");}
    _tiles[y]._flip[x] = vFlip<<1|hFlip;
}

void TileMatrix::setFlipRect(uint16_t x, uint16_t y, uint16_t width, uint16_t height, bool hFlip, bool vFlip){
    if (x >= _width) {throw std::invalid_argument("[TileMatrix::setFlipRect(uint16_t x, uint16_t y, uint16_t width, uint16_t height, bool hFlip, bool vFlip)]: x is out of bounds");}
    if (y >= _height) {throw std::invalid_argument("[TileMatrix::setFlipRect(uint16_t x, uint16_t y, uint16_t width, uint16_t height, bool hFlip, bool vFlip)]: y is out of bounds");}
    if (width+x > _width) {throw std::invalid_argument("[TileMatrix::setFlipRect(uint16_t x, uint16_t y, uint16_t width, uint16_t height, bool hFlip, bool vFlip)]: width+x is out of bounds");}
    if (height+y > _height) {throw std::invalid_argument("[TileMatrix::setFlipRect(uint16_t x, uint16_t y, uint16_t width, uint16_t height, bool hFlip, bool vFlip)]: height+y is out of bounds");}
    for (uint16_t i = y; i < _height; i++) {
        for (uint16_t j = x; j < width; j++) {_tiles[i]._flip[j] =  vFlip<<1|hFlip;}
    }
}

void TileMatrix::copyRow(uint16_t row, uint32_t src[]){
    if (row >= _height) {throw std::invalid_argument("[TileMatrix::copyRow(uint16_t row, uint32_t src[])]: row is out of bounds");}
    for (uint16_t i = 0; i < _width; i++){_tiles[row]._tiles[i] = src[i];}
}

void TileMatrix::copyCol(uint16_t col, uint32_t src[]){
    if (col >= _width) {throw std::invalid_argument("[TileMatrix::copyCol(uint16_t col, uint32_t src[])]: col is out of bounds");}
    for (uint16_t i = 0; i < _height; i++){_tiles[i]._tiles[col] = src[i];}
}

void TileMatrix::copyRect(uint16_t x, uint16_t y, uint16_t width, uint16_t height, uint32_t src[]){
    if (x >= _width) {throw std::invalid_argument("[TileMatrix::copyRect(uint16_t x, uint16_t y, uint16_t width, uint16_t height, uint32_t src[])]: x is out of bounds");}
    if (y >= _height) {throw std::invalid_argument("[TileMatrix::copyRect(uint16_t x, uint16_t y, uint16_t width, uint16_t height, uint32_t src[])]: y is out of bounds");}
    if (width+x > _width) {throw std::invalid_argument("[TileMatrix::copyRect(uint16_t x, uint16_t y, uint16_t width, uint16_t height, uint32_t src[])]: width+x is out of bounds");}
    if (height+y > _height) {throw std::invalid_argument("[TileMatrix::copyRect(uint16_t x, uint16_t y, uint16_t width, uint16_t height, uint32_t src[])]: height+y is out of bounds");}
    uint32_t ptr = 0;
    for (uint16_t i = y; i < height+y; i++){
        for (uint16_t j = x; j < width+x; j++){
            _tiles[i]._tiles[j] = src[ptr++];
        }
    }
}




void TileMatrix::render(uint16_t x, uint16_t y, sf::RenderWindow *window, sf::Texture texture){
    sf::Vector2f texturePos {0, 0};
    for (uint16_t i = 0; i < _height && i*8+y < window->getSize().y; i++){
        for (uint16_t j = 0; j < _width && j*8+x < window->getSize().x; j++){
            texturePos.y = (_tiles[i]._tiles[j]) << 3;
            sf::Vertex vertices[4] = {
                sf::Vertex(sf::Vector2f(j*8, i*8), texturePos+sf::Vector2f(_tiles[i]._flip[j]&1?8:0,_tiles[i]._flip[j]&2?8:0)),
                sf::Vertex(sf::Vector2f(j*8+8, i*8), texturePos+sf::Vector2f(_tiles[i]._flip[j]&1?0:8,_tiles[i]._flip[j]&2?8:0)),
                sf::Vertex(sf::Vector2f(j*8+8, i*8+8), texturePos+sf::Vector2f(_tiles[i]._flip[j]&1?0:8,_tiles[i]._flip[j]&2?0:8)),
                sf::Vertex(sf::Vector2f(j*8, i*8+8), texturePos+sf::Vector2f(_tiles[i]._flip[j]&1?8:0,_tiles[i]._flip[j]&2?0:8))
            };
            window->draw(vertices, 4, sf::TriangleFan, sf::RenderStates(&texture));
        }
    }
}

sf::Texture TileMatrix::renderToTexture(sf::Texture texture){
    sf::Vector2f texturePos {0, 0};
    sf::RenderTexture target;
    target.create(_width*8, _height*8);
    for (uint16_t i = 0; i < _height; i++){
        for (uint16_t j = 0; j < _width; j++){
            texturePos.y = (_tiles[i]._tiles[j]) << 3;
            sf::Vertex vertices[4] = {
                sf::Vertex(sf::Vector2f(j*8, i*8+8), texturePos+sf::Vector2f(_tiles[i]._flip[j]&1?8:0,_tiles[i]._flip[j]&2?8:0)),
                sf::Vertex(sf::Vector2f(j*8+8, i*8+8), texturePos+sf::Vector2f(_tiles[i]._flip[j]&1?0:8,_tiles[i]._flip[j]&2?8:0)),
                sf::Vertex(sf::Vector2f(j*8+8, i*8), texturePos+sf::Vector2f(_tiles[i]._flip[j]&1?0:8,_tiles[i]._flip[j]&2?0:8)),
                sf::Vertex(sf::Vector2f(j*8, i*8), texturePos+sf::Vector2f(_tiles[i]._flip[j]&1?8:0,_tiles[i]._flip[j]&2?0:8))
            };
            target.draw(vertices, 4, sf::TriangleFan, sf::RenderStates(&texture));
        }
    }
    return target.getTexture();
}