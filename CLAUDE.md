# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal website for MrWilde built using Retype, a static site generator. The site includes:
- Personal blog posts (tech tutorials, equipment builds, conference talks)
- Learning documentation ("Always Be Learning" section for tracking courses, books, and skills)
- Personal brand and professional portfolio

## Architecture

- **Source content**: All markdown files are in the `retype/` directory
- **Configuration**: `retype.yml` contains site configuration, branding, and navigation
- **Static assets**: Images and resources stored in `retype/static/`
- **Generated output**: Retype builds to the `public/` directory
- **Content structure**:
  - `retype/README.md` - Homepage content
  - `retype/blog/` - Blog posts organized by year
  - `retype/Always Be Learning/` - Learning documentation
  - `retype/about.md` - About page

## Common Commands

Build the site:
```bash
retype build .
```

Start development server with live reload:
```bash
retype start .
```

Serve built site locally:
```bash
retype serve .
```

Clean output directory:
```bash
retype clean .
```

## Content Guidelines

- Blog posts use frontmatter with `layout: blog`, `category`, `tags`, and `date`
- Learning docs use `label` and `icon` in frontmatter
- Static assets reference paths like `/static/filename.ext`
- Site uses custom branding with skull logos and dark/light variants

## Site Configuration

The `retype.yml` file controls:
- Site URL (https://mrwilde.dev)
- Branding (title, logos)
- Navigation links (YouTube, GitHub, Twitter, etc.)
- Integrations (Crisp chat widget)
- Build input/output directories