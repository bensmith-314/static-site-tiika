from pathlib import Path
import shutil
import os

def count_files_in_directory(staging_everydays_directory_path):
    return len([file for file in Path(staging_everydays_directory_path).iterdir() if file.is_file()])


def find_file_by_prefix(staging_everydays_directory_path, prefix):
    for file in Path(staging_everydays_directory_path).iterdir():
        if file.is_file() and file.name.startswith(prefix):
            return file.name
    return None

def transform_filename(filename):
    if not filename:  # Check if filename is None or empty
        return None

    # Split the filename and remove the extension
    name_without_extension = filename.rsplit('.', 1)[0]
    
    # Replace the first hyphen with a colon and a space
    name_with_colon = name_without_extension.replace('-', ': ', 1)
    
    # Replace the remaining hyphens with spaces
    final_name = name_with_colon.replace('-', ' ')
    
    return final_name

def prepend_zeros(number):
    if  number < 10:
        number = f'000{number}'
    elif number < 100:
        number = f'00{number}'
    elif number < 1000:
        number = f'0{number}'
    else:
        number = str(number)
    return number

# Staging
staging_everydays_directory_path = '../everydays'

# Site
site_everydays_directory_path = '../../tiika/everydays'

# Move Everydays images from staging to site
for filename in os.listdir(staging_everydays_directory_path ):
    source_file = os.path.join(staging_everydays_directory_path , filename)
    destination_file = os.path.join(site_everydays_directory_path, filename)

for x in range(1, count_files_in_directory(staging_everydays_directory_path)):

    staging_everydays_directory_path = '../everydays'

    # Determines the next art piece and if it is the final one
    nextPiece = x + 1
    if nextPiece > (count_files_in_directory(staging_everydays_directory_path) + 1):
        finalPiece = True
    else: 
        finalPiece = False
    prepend_zeros(nextPiece)

    # Determines the previous art piece and if it is the initial one
    previousPiece = x - 1
    if previousPiece == 0:
        firstPiece = True
    else: 
        firstPiece = False
    prepend_zeros(previousPiece)


    print(f"{x} {staging_everydays_directory_path} {prepend_zeros(x)}")
    fileName = find_file_by_prefix(staging_everydays_directory_path, prepend_zeros(x))
    artName = transform_filename(fileName)
    
    previousPiece = x - 1
    f = open(f"../../tiika/i/{prepend_zeros(x)}.html", 'w')
    f.write("""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Artwork Gallery</title>
    <link rel="stylesheet" href="/css/styles.css">
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;700&display=swap" rel="stylesheet">
</head>
<body>
        <main>
        <nav>
        <ul class="desktop-menu">
                <li style="margin-right: 0px;">
                    <a href="/p/index.html" style="padding-top: 6px; padding-bottom: 6px; padding-right: 15px; padding-left: 15px;">
                        <img src="/icons/bs-logo.svg" alt="Ben Smith Logo" style="width: 35px; margin: 0px; padding-left: 0px;">
                    </a>
                </li>
                <li><a href="/p/blog.html" class="navlink">Blog</a></li>
                <li><a href="/p/everyday.html" class="navlink">Everydays</a></li>
                <li><a href="https://hachyderm.io/@bensmith" class="navlink" target="_blank">Mastodon</a></li>
                <li class="hamburger-menu" style="margin-right: 0px;">
                    <a href="javascript:void(0);" onclick="showMobileMenu()">
                        ☰
                    </a>
                </li> 
            </ul>
            <ul class="mobile-menu" id="mobile-links">
                <li><a href="/p/blog.html" class="mobile-menu-link">Blog</a></li>
                <li><a href="/p/everyday.html" class="mobile-menu-link">Everydays</a></li>
                <li><a href="https://hachyderm.io/@bensmith" class="mobile-menu-link">Mastodon</a></li>
            </ul>
        </nav>
""")
    f.write(f"<h1>Day {artName}</h1>")
    f.write("""
<hr>
        <div class="everyday-image-container">""")
    f.write(f"<img src=\"/everydays/{fileName}\" class=\"everyday-image\">")
    f.write("""
                <div class="image-navigation">
            <ul>
                <li>
            """)
    if not finalPiece:
        f.write(f"<a href=\"{prepend_zeros(nextPiece)}.html\">Next</a>")
    f.write("""
                </li>
                <li>
                    <a href="#" id="randomArtPiece">Random</a>
                </li>
                <li>
            
    """)
    if not firstPiece:
        f.write(f"<a href=\"{prepend_zeros(previousPiece)}.html\">Previous</a>")
    f.write("""

                </li>
            </ul>
        </div>

        <script src="/js/menu.js"></script>
        <script src="/js/randomArt.js"></script>
    </main>
<footer>
    <p>&copy; 2025 Ben Smith</p>
</footer>
</body>
</html>
            """)
    f.close()

