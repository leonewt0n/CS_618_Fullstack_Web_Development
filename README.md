# React Fullstack Blog

CS 618 blog app in this folder. A Vite + React frontend lists and creates posts. An Express API stores them in MongoDB through Mongoose.

Local development runs Mongo, the API, and the Vite dev server as separate processes. Docker runs the same three pieces as `blog-database`, `blog-backend`, and `blog-frontend`.

## What has been built

Git history, newest work last:

| Date | Commit | What landed |
| --- | --- | --- |
| 2026-09-23 | `038c034` | Mongoose `Post` model (`title`, `author`, `contents`, `tags`, timestamps) and `backend/src/example.js` to save a sample post |
| 2026-09-27 | `184d13e`, `1cc341c` | Jest tests for create, list, filter, sort, update, and delete, using `mongodb-memory-server` |
| 2026-09-27 | `9922131` | `backend/.env` and `backend/src/index.js`, which connects to Mongo and starts Express |
| 2026-09-27 | `4f6ae21` | Nodemon so `npm start` restarts the API on file changes |
| 2026-09-28 | `e3a8957` | CORS, JSON body parsing, and `/api/v1/posts` routes |
| 2026-10-05 | `d075288` | Frontend fetch client pointed at `VITE_BACKEND_URL` |
| 2026-10-07 | `5c00e11` | TanStack Query, create-post form, author filter, and sort by `createdAt` / `updatedAt` |
| 2026-10-12 | `0884f67` | Backend and frontend Dockerfiles plus `compose.yaml` |
| 2026-10-12 | `b6f654f`, `8518577` | GitHub Actions on Node 20: backend lint and test, frontend lint and build |

`OLD_Single_MVC_backend_example/` is the earlier single-file Node examples (`helloworld.js`, `simpleweb.js`, `files.js`). The running app is `backend/src` plus `src/`.

### API

Base path: `/api/v1/posts`

| Method | Path | Behavior |
| --- | --- | --- |
| `GET` | `/api/v1/posts` | List posts. Query: `author` or `tag` (not both), `sortBy`, `sortOrder` (`ascending` or `descending`) |
| `GET` | `/api/v1/posts/:id` | One post, or 404 |
| `POST` | `/api/v1/posts` | Create `{ title, author, contents, tags }` |
| `PATCH` | `/api/v1/posts/:id` | Update those fields |
| `DELETE` | `/api/v1/posts/:id` | Delete, 204 on success |

`GET /` on the API returns a plain text hello response.

### Frontend

`src/App.jsx` wraps the page in a TanStack `QueryClientProvider`. `src/Blog.jsx` loads posts, and these components render the page:

- `CreatePost` submits a new post and refreshes the list
- `PostFilter` filters by author
- `PostSorting` sorts by `createdAt` or `updatedAt`
- `PostList` / `Post` render each post

The browser calls the API through `src/api/posts.js`. Vite reads env files from `src/` (`envDir` in `vite.config.js`).

### Ports

Local processes and containers do not share one port map.

| Process | Local dev | Docker Compose |
| --- | --- | --- |
| MongoDB | `localhost:27017` | `localhost:27017` (`blog-database`) |
| Express API | `localhost:3000` from `backend/.env` | `localhost:3001` |
| UI | Vite, default `http://localhost:5173` | nginx on `localhost:3000` |

`src/.env` points the dev UI at the local API:

```
VITE_BACKEND_URL="http://localhost:3000/api/v1"
```

The frontend image bakes a different URL at build time (`http://localhost:3001/api/v1`) so the nginx page talks to the Compose API port.

## Prerequisites

Node and the Mongo shell, from the installs in zsh history:

```bash
brew install node
brew install mongosh
```

Docker on this Mac uses Colima. The Docker client alone had no daemon until Colima was started:

```bash
brew install docker docker-compose colima
brew services start colima
docker run --rm hello-world
```

`../nixMERN` is an optional Apple Silicon dev shell (`nix develop`) that provides Node and starts MongoDB on `127.0.0.1:27017`. The commands below use the Docker Mongo container that was used with this app.

## Install dependencies

From this folder:

```bash
cd backend
npm install
cd ..
npm install
```

Packages added while the API was built, in `backend/`:

```bash
npm install mongoose
npm install express
npm install dotenv
npm install body-parser
npm install cors
npm install --save-dev jest
npm install --save-dev mongodb-memory-server
npm install --save-dev nodemon
npm install --save-dev eslint
npm install prettier
```

Packages added while the UI was built, in this folder:

```bash
npm create vite@latest
npm install
npm add prettier
npm install prop-types
npm install @tanstack/react-query
```

Prettier config in `.prettierrc.json`:

```json
{
  "trailingComma": "all",
  "tabWidth": 2,
  "printWidth": 80,
  "semi": false,
  "jsxSingleQuote": true,
  "singleQuote": true
}
```

## Run the app locally

Three terminals, in this order.

**1. MongoDB**

```bash
docker run -d --name dbserver -p 27017:27017 --restart unless-stopped mongo:6.0.4
mongosh mongodb://localhost:27017/blog
```

`backend/.env` is already set to that database:

```
PORT = 3000
DATABASE_URL = "mongodb://localhost:27017/blog"
```

If a container named `dbserver` already exists, start it instead of creating another one:

```bash
docker start dbserver
```

**2. API**

```bash
cd backend
npm start
```

`npm start` runs `nodemon src/index.js`. The process prints `express server running on localhost:3000` after Mongoose connects.

A one-off sample post, from `backend/`:

```bash
node src/example.js
```

Tests use an in-memory MongoDB and do not need the Docker database:

```bash
npm test
```

**3. Vite UI**

From this folder (`ReactFullStack/`), not `backend/`:

```bash
npm run dev
```

Open the URL Vite prints (default `http://localhost:5173`). The page loads posts from `http://localhost:3000/api/v1`.

## Build and run the Docker images

These are the commands that produced `blog-backend` and `blog-frontend` and put them on a shared network with Mongo. Run them from this folder, with Colima already running.

**Backend image**

```bash
docker buildx build -t blog-backend backend
docker images
```

**Mongo and API on one network**

```bash
docker network create blog-net
docker run -d --name mongodb --network blog-net mongo:6.0.4
docker run -it --name backend --network blog-net \
  -e PORT=3001 \
  -e DATABASE_URL=mongodb://mongodb:27017/blog \
  -p 3001:3001 \
  blog-backend
```

The API container listens on port 3001. Mongo is reached by the container name `mongodb`, not `localhost`.

**Frontend image**

The UI container is a static nginx server. The image is a Node 20 build stage (`npm run build`) copied into nginx. Host port 3000 maps to nginx port 80.

```bash
docker buildx build -t blog-frontend .
docker run -it -p 3000:80 blog-frontend
```

Open `http://localhost:3000`. That page calls the API at `http://localhost:3001/api/v1`.

Stop or remove the named containers before switching to Compose, or the next `docker run` will fail because the names are taken:

```bash
docker rm -f backend mongodb
```

## Bring everything up with Compose

`compose.yaml` builds both images and starts all three services:

- `blog-database`: `mongo`, published on `27017`
- `blog-backend`: built from `backend/`, `PORT=3001`, `DATABASE_URL=mongodb://blog-database:27017/blog`, published on `3001`
- `blog-frontend`: built from this folder with `VITE_BACKEND_URL=http://localhost:3001/api/v1`, published on `3000`

```bash
docker compose up
```

UI: `http://localhost:3000`. API: `http://localhost:3001`.

Compose builds the images itself, so the manual `docker buildx build` steps are not required for this path.

## Images pushed to Docker Hub

The tags that were built for `linux/amd64` and pushed:

```bash
docker login

docker buildx build --platform linux/amd64 -t blog-frontend .
docker tag blog-frontend leo253/blog-frontend
docker push leo253/blog-frontend

cd backend
docker buildx build --platform linux/amd64 -t blog-backend .
docker tag blog-backend leo253/blog-backend
docker push leo253/blog-backend
```

## Checks

```bash
# API
cd backend
npm run lint
npm test

# UI
cd ..
npm run lint
npm run build
```

GitHub Actions runs those on pushes and pull requests to `main` (`.github/workflows/backend-ci.yaml` and `frontend-ci.yaml`), on Node 20.
