# ----------- Frontend Build Stage -------------
FROM node:18-alpine AS frontend

WORKDIR /app

# Install and build React app
COPY frontend/package*.json ./frontend/
RUN cd frontend && npm install
COPY frontend ./frontend
RUN cd frontend && npm run build


# ----------- Backend Build Stage -------------
FROM golang:1.21 AS backend

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

# Copy backend source and frontend build
COPY ./backend ./backend
COPY --from=frontend /frontend/build ./frontend/build

# Static build: no GLIBC required
WORKDIR /app/backend
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server ./cmd


# ----------- Final Minimal Stage -------------
FROM scratch

WORKDIR /app

# Copy Go server binary
COPY --from=backend /app/backend/server ./server

# Copy frontend static files
COPY --from=backend /app/frontend/build ./frontend/build

# Expose port
EXPOSE 8080

# Run Go server
ENTRYPOINT ["/app/server"]
