FROM golang:1.23  as builder
WORKDIR /app

COPY ./app .
RUN go mod download

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main .

FROM gcr.io/distroless/static-debian12

COPY --from=builder /app/main /main
EXPOSE 80
CMD ["/main"]
