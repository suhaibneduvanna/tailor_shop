# PowerShell script to convert PNG to ICO for Inno Setup
param(
    [string]$InputFile = "assets\icons\app_icon.png",
    [string]$OutputFile = "assets\icons\app_icon.ico"
)

Write-Host "Converting PNG to ICO for installer..." -ForegroundColor Yellow

# Check if input file exists
if (-not (Test-Path $InputFile)) {
    Write-Host "Error: Input file not found: $InputFile" -ForegroundColor Red
    exit 1
}

try {
    # Load required assemblies
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName System.Windows.Forms

    # Load the PNG image
    $image = [System.Drawing.Image]::FromFile((Resolve-Path $InputFile).Path)
    
    # Create multiple sizes for ICO file (16x16, 32x32, 48x48, 256x256)
    $sizes = @(16, 32, 48, 256)
    $iconImages = @()
    
    foreach ($size in $sizes) {
        $resized = New-Object System.Drawing.Bitmap($size, $size)
        $graphics = [System.Drawing.Graphics]::FromImage($resized)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($image, 0, 0, $size, $size)
        $graphics.Dispose()
        $iconImages += $resized
    }
    
    # Create icon file
    $iconStream = New-Object System.IO.FileStream($OutputFile, [System.IO.FileMode]::Create)
    
    # Write ICO header
    $iconStream.Write([byte[]]@(0, 0, 1, 0), 0, 4)  # ICO signature
    $iconStream.Write([System.BitConverter]::GetBytes([uint16]$iconImages.Count), 0, 2)  # Number of images
    
    $offset = 6 + ($iconImages.Count * 16)  # Header size + directory entries
    
    # Write directory entries
    foreach ($iconImage in $iconImages) {
        $iconStream.WriteByte($iconImage.Width -band 0xFF)
        $iconStream.WriteByte($iconImage.Height -band 0xFF)
        $iconStream.WriteByte(0)  # Color count (0 for true color)
        $iconStream.WriteByte(0)  # Reserved
        $iconStream.Write([System.BitConverter]::GetBytes([uint16]1), 0, 2)  # Color planes
        $iconStream.Write([System.BitConverter]::GetBytes([uint16]32), 0, 2)  # Bits per pixel
        
        # Calculate image size
        $memStream = New-Object System.IO.MemoryStream
        $iconImage.Save($memStream, [System.Drawing.Imaging.ImageFormat]::Png)
        $imageSize = $memStream.Length
        $memStream.Close()
        
        $iconStream.Write([System.BitConverter]::GetBytes([uint32]$imageSize), 0, 4)  # Image size
        $iconStream.Write([System.BitConverter]::GetBytes([uint32]$offset), 0, 4)  # Image offset
        
        $offset += $imageSize
    }
    
    # Write image data
    foreach ($iconImage in $iconImages) {
        $memStream = New-Object System.IO.MemoryStream
        $iconImage.Save($memStream, [System.Drawing.Imaging.ImageFormat]::Png)
        $iconStream.Write($memStream.ToArray(), 0, $memStream.Length)
        $memStream.Close()
        $iconImage.Dispose()
    }
    
    $iconStream.Close()
    $image.Dispose()
    
    Write-Host "✅ ICO file created successfully: $OutputFile" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Error converting PNG to ICO: $($_.Exception.Message)" -ForegroundColor Red
    
    # Fallback: copy PNG as ICO (some tools accept this)
    Write-Host "Falling back to copying PNG as ICO..." -ForegroundColor Yellow
    Copy-Item $InputFile $OutputFile
    Write-Host "✅ Fallback ICO created: $OutputFile" -ForegroundColor Green
}
