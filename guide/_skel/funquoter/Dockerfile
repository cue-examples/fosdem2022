FROM golang:1.17.6-alpine3.15 AS stage1
RUN mkdir /app
ADD . /app
WORKDIR /app
RUN go build -o main ./funquoter

FROM alpine:3.15.0

RUN mkdir /app
ENTRYPOINT ["/app/main"]

COPY --from=stage1 /app/main /app
