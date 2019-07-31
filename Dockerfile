FROM instrumentisto/dep AS dep

FROM golang:1.11 AS builder
WORKDIR /artifact

# RUN CGO_ENABLED=0 GOOS=linux go build -o /artifact/server /go/src/google.golang.org/grpc/examples/helloworld/greeter_server/main.go

FROM alpine:latest
EXPOSE 50051
WORKDIR /app
COPY --from=builder /artifact/server .
CMD ["./server"]
