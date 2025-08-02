"""
Icon Generator for Libasu Thaqva
Converts SVG to PNG and ICO formats for Windows installer
"""

import os
import subprocess
import sys
from pathlib import Path

def check_dependencies():
    """Check if required dependencies are installed"""
    try:
        import cairosvg
        from PIL import Image
        return True
    except ImportError:
        return False

def install_dependencies():
    """Install required dependencies"""
    print("Installing required dependencies...")
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "cairosvg", "Pillow"])
        print("Dependencies installed successfully!")
        return True
    except subprocess.CalledProcessError:
        print("Failed to install dependencies. Please install manually:")
        print("pip install cairosvg Pillow")
        return False

def convert_svg_to_png(svg_path, png_path, size=256):
    """Convert SVG to PNG"""
    try:
        import cairosvg
        cairosvg.svg2png(url=svg_path, write_to=png_path, output_width=size, output_height=size)
        print(f"Created PNG icon: {png_path}")
        return True
    except Exception as e:
        print(f"Error converting SVG to PNG: {e}")
        return False

def convert_png_to_ico(png_path, ico_path):
    """Convert PNG to ICO"""
    try:
        from PIL import Image
        img = Image.open(png_path)
        # Create multiple sizes for ICO
        sizes = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
        img.save(ico_path, format='ICO', sizes=sizes)
        print(f"Created ICO icon: {ico_path}")
        return True
    except Exception as e:
        print(f"Error converting PNG to ICO: {e}")
        return False

def main():
    # Get the current directory
    current_dir = Path(__file__).parent
    svg_path = current_dir / "app_icon.svg"
    png_path = current_dir / "app_icon.png"
    ico_path = current_dir / "app_icon.ico"
    
    print("Libasu Thaqva - Icon Generator")
    print("=" * 50)
    
    # Check if SVG file exists
    if not svg_path.exists():
        print(f"Error: SVG file not found at {svg_path}")
        return False
    
    # Check dependencies
    if not check_dependencies():
        print("Required dependencies not found.")
        if input("Install dependencies? (y/n): ").lower() == 'y':
            if not install_dependencies():
                return False
        else:
            print("Cannot proceed without dependencies.")
            return False
    
    # Convert SVG to PNG
    print(f"Converting {svg_path} to PNG...")
    if not convert_svg_to_png(str(svg_path), str(png_path)):
        return False
    
    # Convert PNG to ICO
    print(f"Converting {png_path} to ICO...")
    if not convert_png_to_ico(str(png_path), str(ico_path)):
        return False
    
    print("\n" + "=" * 50)
    print("Icon generation completed successfully!")
    print(f"Generated files:")
    print(f"  - {png_path}")
    print(f"  - {ico_path}")
    print("\nYou can now use these icons for your Windows installer.")
    
    return True

if __name__ == "__main__":
    try:
        success = main()
        if not success:
            input("Press Enter to exit...")
            sys.exit(1)
    except KeyboardInterrupt:
        print("\nOperation cancelled by user.")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        input("Press Enter to exit...")
        sys.exit(1)
