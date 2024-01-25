from fontTools.ttLib import TTFont
import os

def can_render(font_path, character):
    try:
        font = TTFont(font_path)
        for cmap in font['cmap'].tables:
            if cmap.isUnicode():
                if ord(character) in cmap.cmap:
                    return True
        return False
    except Exception as e:
        #print(f"Error processing font {font_path}: {e}")
        return False

def main():
    unicode_character = '🖥️'
    unicode_character = '☰'
    font_paths = [font.split(':')[0] for font in os.popen('fc-list').read().split('\n')]

    for font_path in font_paths:
        if font_path and can_render(font_path, unicode_character):
            print(f"The character '{unicode_character}' can be rendered with: {font_path}")

if __name__ == "__main__":
    main()
