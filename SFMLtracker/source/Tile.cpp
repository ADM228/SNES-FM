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
    if (offset >= _tiles.size()) {throw std::invalid_argument("Offset is out of bounds");}
    if (offset+length >= _tiles.size()) {throw std::invalid_argument("Offset+length is out of bounds");}
    for (uint16_t i = offset; i < offset+length; i++){_tiles[i] = src[i];}
}
