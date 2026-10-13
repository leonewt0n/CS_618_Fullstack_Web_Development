# React + Vite

This template provides a minimal setup to get React working in Vite with HMR and some ESLint rules.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react/README.md) uses [Babel](https://babeljs.io/) for Fast Refresh
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react-swc) uses [SWC](https://swc.rs/) for Fast Refresh


# Commands Used
```
npm create vite@5.0.0 .
npm install
# run dev server
npm run dev
# formats code to a defined style
# save-dev only saves to depends  to dev version not main deployed
npm install --save-dev prettier@3.1.0 \
# analyzes code and enforces best practices
eslint@8.54.0 \
eslint-plugin-react@7.33.2 \
#disables ESlint code style so prettier is used instead
eslint-config-prettier@9.0.0 \
# allows Eslint to check for accesability issues
eslint-plugin-jsx-a11y@6.8.0

```
# .prettierrc.json
```
{
    "trailingComma": "all",
    "tabWidth": 2,
    "printWidth": 80,
    "semi": false,
    "jsxSingleQuote": true,
    "singleQuote": true
}
```