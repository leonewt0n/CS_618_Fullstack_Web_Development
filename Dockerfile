FROM node:20 AS build
ARG VITE_BACKEND_URL=http://localhost:3001/api/v1
ENV VITE_BACKEND_URL=$VITE_BACKEND_URL
WORKDIR /build
COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts
COPY . .
RUN npm run build

FROM nginx:1.27-alpine AS final
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /build/dist /usr/share/nginx/html
EXPOSE 80
