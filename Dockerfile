# ----------- Frontend Build Stage -------------
FROM node:18-alpine AS frontend

WORKDIR /app

COPY frontend/package*.json ./frontend/
RUN cd frontend && npm install

COPY frontend ./frontend
RUN cd frontend && npm run build


# ----------- Backend Build Stage -------------
FROM golang:1.21 AS backend

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY ./backend ./backend

# ✅ Correct path from frontend build
COPY --from=frontend /app/frontend/build ./frontend/build

WORKDIR /app/backend

# Static build: no GLIBC required
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server ./cmd


# ----------- Final Minimal Stage -------------
FROM scratch

WORKDIR /app

COPY --from=backend /app/backend/server ./server
COPY --from=backend /app/frontend/build ./frontend/build

EXPOSE 8080

ENTRYPOINT ["/app/server"]
