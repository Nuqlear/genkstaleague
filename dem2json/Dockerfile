FROM golang:1.10-stretch as builder

RUN ssh-keyscan -H -t rsa github.com
RUN go get github.com/golang/dep/cmd/dep
COPY src/dem2json/Gopkg.lock /go/src/dem2json/Gopkg.lock
COPY src/dem2json/Gopkg.toml /go/src/dem2json/Gopkg.toml
ENV GOPATH /go
WORKDIR /go/src/dem2json
RUN dep ensure --vendor-only


COPY src/dem2json/dem2json.go \
    src/dem2json/heroes.go \
    src/dem2json/matchdata.go \
    /go/src/dem2json/
# Go binary is looking for libraries on the OS its running in, but scratch is empty.
# => We should statically compile our app with all libraries built in.
RUN CGO_ENABLED=0 GOOS=linux go build

FROM scratch
COPY --from=builder /go/src/dem2json/dem2json /dem2json
