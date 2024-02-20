import argparse
from fontTools.ttLib import TTFont, TTCollection
import os

def can_render(font_path, character):
    try:
        if font_path.lower().endswith('.ttc'):
            collection = TTCollection(font_path)
            for index, font in enumerate(collection.fonts):
                if is_char_in_font(font, character):
                    if index > 0:
                        print(f"The character can be rendered with: {font_path}, font number: {index}")
                    else:
                        print(f"The character can be rendered with: {font_path}")
                    return True
        else:
            font = TTFont(font_path)
            if is_char_in_font(font, character):
                print(f"The character can be rendered with: {font_path}")
                return True
    except Exception as e:
        print(f"Error processing font {font_path}: {e}")
    return False

def is_char_in_font(font, character):
    for cmap in font['cmap'].tables:
        if cmap.isUnicode():
            if ord(character) in cmap.cmap:
                return True
    return False

def main(character):
    font_paths = [font.split(':')[0] for font in os.popen('fc-list').read().split('\n')]

    for font_path in font_paths:
        if font_path:
            can_render(font_path, character)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Check if a character can be rendered by available fonts.')
    parser.add_argument('character', type=str, help='The character to check')
    args = parser.parse_args()

    main(args.character)
