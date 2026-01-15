# Stage 1: Builder to compile Go app
FROM golang:1.25-alpine3.21 AS builder

# Set working directory
WORKDIR /app

# Create non-root user for security
RUN adduser -D nonroot -u 1000

# Copy go.mod and go.sum from Server/MuchToDo/ for caching
COPY Server/MuchToDo/go.mod Server/MuchToDo/go.sum ./

# Download dependencies (cached if unchanged)
RUN go mod download

# Copy the source code from Server/MuchToDo/
COPY Server/MuchToDo/ .

# Build the binary from cmd/api where main.go is located
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o main ./cmd/api

# Stage 2: Minimal distroless image (no OS vulnerabilities)
FROM gcr.io/distroless/static:nonroot

# Set working directory
WORKDIR /app

# Copy built binary
COPY --from=builder /app/main .

# Use non-root user (65532 is the nonroot user in distroless)
USER 65532:65532

# Expose port
EXPOSE 8080

# Distroless has no shell, so no HEALTHCHECK CMD - use Kubernetes probes instead

# Run the app
ENTRYPOINT ["./main"]