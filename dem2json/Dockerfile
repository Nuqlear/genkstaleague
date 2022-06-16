FROM golang:1.18-stretch as builder

RUN ssh-keyscan -H -t rsa github.com
ENV GOPATH /go
WORKDIR /go/src/dem2json

COPY src/dem2json/ /go/src/dem2json/

RUN go install

# Go binary is looking for libraries on the OS its running in, but scratch is empty.
# => We should statically compile our app with all libraries built in.
RUN CGO_ENABLED=0 GOOS=linux go build

FROM scratch
COPY --from=builder /go/src/dem2json/dem2json /dem2json
