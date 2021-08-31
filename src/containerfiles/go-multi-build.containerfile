# vim: ft=dockerfile
FROM docker.io/library/golang:1.16

WORKDIR /go/src/github.com/alexellis/href-counter/

RUN go get -d -v golang.org/x/net/html

COPY src/golang/app.go ./
COPY src/golang/go.mod ./

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

# Production Container
FROM docker.io/library/alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=0 /go/src/github.com/alexellis/href-counter/app ./

CMD ["./app"]
