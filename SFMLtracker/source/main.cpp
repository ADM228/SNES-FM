#include <SFML/Graphics.hpp>
#include "chrLoad.cpp"

int main()
{
    sf::RenderWindow window(sf::VideoMode(200, 200), "SFML works!");
    sf::CircleShape shape(100.f);
    sf::Texture texture = loadCharacters(0x00, 0x100);
    sf::Sprite sprite;
    sprite.setTexture(texture);
    sprite.setScale(sf::Vector2f(8.f, 8.f));
    sprite.setTextureRect(sf::IntRect(0, 8*0x30, 8, 8));

    while (window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                window.close();
        }

        window.clear();
        window.draw(sprite);
        window.display();
    }

    return 0;
}