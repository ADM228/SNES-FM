#include <SFML/Graphics.hpp>
#include "chrLoad.cpp"
#include "Tile.cpp"

int main()
{
    sf::RenderWindow window(sf::VideoMode(200, 200), "SNESFM Tracker");
    sf::View InstrumentView(sf::FloatRect(0.f, 0.f, 200.f, 200.f));
    sf::View TrackerView(sf::FloatRect(0.f,0.f,200.f,200.f));
    sf::Texture font[0x64];
    font[0x00] = loadCharacters(0x0000, 0x80);
    font[0x01] = loadCharacters(0x0080, 0x80);
    font[0x07] = loadCharacters(0x0100, 0x80);
    font[0x08] = loadCharacters(0x0180, 0x80);
    font[0x09] = loadCharacters(0x0200, 0x80);
    font[0x60] = loadCharacters(0x0280, 0x80);
    font[0x61] = loadCharacters(0x0300, 0x80);
    sf::Sprite sprite0;
    sf::Sprite sprite7;
    int instPage = 0;
    uint8_t scale = 5;
    uint8_t mode = 0;

    

    window.setView(TrackerView);

    sprite0.setTexture(font[0x00]);
    sprite0.setScale(sf::Vector2f((float)scale, (float)scale));
    sprite0.setTextureRect(sf::IntRect(0, 8*0x30, 8, 8));

    sprite7.setTexture(font[0x00]);
    sprite7.setScale(sf::Vector2f((float)scale, (float)scale));
    sprite7.setTextureRect(sf::IntRect(0, 8*0x37, 8, 8));

    // renderText(font, "Test SNESFM сука");
    // sf::VertexArray tile = createTile(sf::Vector2i(0, 0), 1);
    // Tile tile (0, 0, 1);
    // Tile tile1 (1, 0, 2);
    // Tile tile2 (0, 1, 3, true, false);
    // Tile tile3 (1, 1, 0x46);
    uint32_t tilesd[] = {0,1,2,2};
    TileRow tile(4, tilesd);

    while (window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                window.close();
            else if (event.type == sf::Event::Resized){
                //TrackerView.reset(sf::FloatRect(0, 0, 32, 32));
                //TrackerView.setViewport(sf::FloatRect(0.f, 0.f, 32.f/event.size.width, 32.f/event.size.height));
                InstrumentView.reset(sf::FloatRect(instPage*scale*8*16, 0, event.size.width, 64));
                InstrumentView.setViewport(sf::FloatRect(0, 0, scale, 64.f/event.size.height*scale));
            } else if (event.type == sf::Event::KeyPressed){
                if (event.key.code == sf::Keyboard::Left){
                    instPage++;
                    InstrumentView.reset(sf::FloatRect(instPage*scale*8*16, 0, 64, 64));
                }
            }
        }

        window.clear(sf::Color(255,255,0,0));
        window.setView(InstrumentView);
        // window.draw(sprite7);
        for (int i = 0; i < tile._tiles.size(); i++){
            sf::Vector2f texturePos {0, (tile._tiles[i] & 0x7F) << 3};
            sf::Vertex vertices[] {
                sf::Vertex(sf::Vector2f(i*8, 0), texturePos+sf::Vector2f(tile._flip[i]&1?8:0,tile._flip[i]&2?8:0)),
                sf::Vertex(sf::Vector2f(i*8+8, 0), texturePos+sf::Vector2f(tile._flip[i]&1?0:8,tile._flip[i]&2?8:0)),
                sf::Vertex(sf::Vector2f(i*8+8, 8), texturePos+sf::Vector2f(tile._flip[i]&1?0:8,tile._flip[i]&2?0:8)),
                sf::Vertex(sf::Vector2f(i*8, 8), texturePos+sf::Vector2f(tile._flip[i]&1?8:0,tile._flip[i]&2?0:8))
            };
            window.draw(vertices, 4, sf::TriangleFan, sf::RenderStates(&font[0]));
        }
        // window.draw(tile.renderVertex, sf::RenderStates(&font[0]));
        // window.draw(tile1.renderVertex, sf::RenderStates(&font[0]));
        // window.draw(tile2.renderVertex, sf::RenderStates(&font[0]));
        // window.draw(tile3.renderVertex, sf::RenderStates(&font[0]));
        // window.setView(TrackerView);
        
        window.display();
    }

    return 0;
}