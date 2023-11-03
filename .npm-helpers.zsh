#!/bin/zsh

#$ npm tailwind command aliases, you may ignore if you don't intend on using any of this
if (( $+commands[npm] )); then
    #? None of these will work if you don't have npm installed
    alias npm-tailwind-setup='npm install -D tailwindcss@npm:@tailwindcss/postcss7-compat postcss@^7 autoprefixer@^9'
    alias npm-tailwind-plugins='npm install @tailwindcss/forms @tailwindcss/typography @tailwindcss/aspect-ratio @tailwindcss/line-clamp'
    alias npm-frontend-setup='npm install @mui/material @mui/icons-material @emotion/react @heroicons/react'
fi
