# ----- Frontend Build -----
FROM node:16-alpine AS frontend

WORKDIR /app/frontend

COPY frontend/package*.json ./
RUN npm install

COPY frontend/ .
RUN npm run build

# ----- Backend Build -----
FROM golang:1.21 AS backend

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY ./backend ./backend
COPY --from=frontend /app/frontend/build ./frontend/build

WORKDIR /app/backend
RUN go build -o server ./cmd

# ----- Final Stage -----
FROM debian:bullseye-slim

WORKDIR /app
COPY --from=backend /app/backend/server ./server
COPY --from=backend /app/frontend/build ./frontend/build

EXPOSE 8080

CMD ["./server"]
