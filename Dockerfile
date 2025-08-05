# ----------- Frontend Build -------------
FROM node:18-alpine AS frontend

WORKDIR /app
COPY frontend/package*.json ./frontend/
RUN cd frontend && npm install
COPY frontend ./frontend
RUN cd frontend && npm run build


# ----------- Backend Build with CGo + SQLite -------------
FROM golang:1.21 AS backend

# Install required libs for SQLite
RUN apt-get update && apt-get install -y gcc libsqlite3-dev

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY ./backend ./backend
COPY ./backend/database ./backend/database
COPY --from=frontend /app/frontend/build ./frontend/build

WORKDIR /app/backend

# ✅ Enable CGO
ENV CGO_ENABLED=1
RUN go build -o server ./cmd


# ----------- Final Runtime Stage -------------
FROM debian:bookworm-slim

# Install only runtime dependency for SQLite
RUN apt-get update && apt-get install -y libsqlite3-0 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=backend /app/backend/server ./server
COPY --from=backend /app/frontend/build ./frontend/build
COPY --from=backend /app/backend/database ./backend/database

EXPOSE 8080

CMD ["./server"]
