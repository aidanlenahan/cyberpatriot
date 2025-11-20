# CyberPatriot Web Documentation

This directory contains professionally styled HTML/CSS files that provide web-based versions of the README documentation from each branch.

## Files Included

- **main.html** - Web version of the main branch README
- **win-server.html** - Web version of the win-server branch README
- **windows.html** - Web version of the windows branch README (detailed guide)
- **linux.html** - Web version of the linux branch README
- **styles.css** - Shared stylesheet with professional, simplistic design

## Design Features

- Clean, professional layout with gradient header
- Responsive design that works on all screen sizes
- Color-coded sections for easy navigation
- Syntax highlighting for code blocks
- Mobile-friendly interface

## Usage

Simply open any of the HTML files in a web browser to view the formatted documentation.

## Branch Information

A "web" branch has been created locally in this repository with all the HTML/CSS files. 

### To Create the Web Branch on GitHub:

The web branch exists locally but needs to be pushed to GitHub. You can do this by running:

```bash
# Option 1: Push using the helper script
./push-web-branch.sh

# Option 2: Push manually
git push origin web:web
```

This will create the "web" branch on GitHub at: `https://github.com/aidanlenahan/cyberpatriot/tree/web`

### What's in the Web Branch?

The web branch contains the exact same HTML/CSS files that are in this PR, minus the documentation files (WEB_README.md and push-web-branch.sh). It's a clean branch with just the web content.

## Preview

The HTML files have been tested and render beautifully with:
- Professional gradient header
- Color-coded sections (blue for intro, purple for tasks, yellow for notes, green for license)
- Responsive design that adapts to different screen sizes
- Clean typography and spacing
- Hover effects on interactive elements
