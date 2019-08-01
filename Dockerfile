# dep が解決してくれた依存関係を元にビルドします
FROM golang:1.11 AS builder
WORKDIR ${GOPATH}/src/github.com/kkomazakii/go-prom-instrumentation

COPY . .

# dep と protoc 入れて、 dep ensure, protoc, gobuild する
# https://github.com/golang/dep/blob/1f7c19e5f52f49ffb9f956f64c010be14683468b/docs/FAQ.md#how-do-i-use-dep-with-docker

RUN apt-get update
RUN apt-get install unzip
# intall protoc
RUN curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v3.8.0/protoc-3.8.0-linux-x86_64.zip
RUN unzip protoc-3.8.0-linux-x86_64.zip
RUN mv ./bin/protoc ${GOPATH}/bin/
# install protoc-gen-go plugin
RUN go get -u github.com/golang/protobuf/protoc-gen-go
# install dep
RUN curl -fsSL -o /usr/local/bin/dep https://github.com/golang/dep/releases/download/v0.5.4/dep-linux-amd64
RUN chmod +x /usr/local/bin/dep
RUN rm -rf pb
RUN mkdir pb
# let's build
RUN ${GOPATH}/bin/protoc --go_out=plugins=grpc:./pb ./app.proto
RUN CGO_ENABLED=0 GOOS=linux go build -o /artifact/server ./main.go

# うごかします
FROM alpine:latest
EXPOSE 50051
WORKDIR /app
COPY --from=builder /artifact/server .
CMD ["./server"]
