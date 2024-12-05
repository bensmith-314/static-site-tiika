from pathlib import Path
import markdown

def count_files_in_directory(directory_path):
    return len([file for file in Path(directory_path).iterdir() if file.is_file()])


def find_file_by_prefix(directory_path, prefix):
    for file in Path(directory_path).iterdir():
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

directory_path = '../../tiika/everydays_small'
page_path = '../../tiika/p/everyday.html'


# WRITING HTML ===========================================

f = open("../../tiika/p/everyday.html", 'w')
f.write("""<!DOCTYPE html>
<html lang="en">""")

# Write header
head = open('../html_snippets/head.txt', 'r')
for each in head:
    f.write(each)
head.close()

f.write("<body>")

# Write Navigation
nav = open('../html_snippets/nav.txt', 'r')
for each in nav:
    f.write(each)
nav.close()

# Write Article Text
with open('../markdown/everyday.md', 'r') as text:
    markdown_content = text.read()
f.write(markdown.markdown(markdown_content))
text.close()

# Open Image Grid Tag
f.write('<div class="image-grid">\n')

# Generate each image and link
for x in range(count_files_in_directory(directory_path), 0, -1):
    f.write(f'\t\t\t<a href="/i/{prepend_zeros(x)}.html" title="Day {transform_filename(find_file_by_prefix('../everydays_small', prepend_zeros(x)))}">\n')
    f.write(f'\t\t\t\t<img src="/../everydays_small/{find_file_by_prefix('../everydays_small', prepend_zeros(x))}" alt="Day {transform_filename(find_file_by_prefix('../everydays_small', prepend_zeros(x)))}">\n')
    f.write('\t\t\t</a>\n')

# Finish Document

f.write("""</div>
    <script src="/js/menu.js"></script>
</body>
</html>""")

f.close()