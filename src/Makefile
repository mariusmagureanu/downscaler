.PHONY: zip all
export GO111MODULE=on
export GOARCH=amd64
export GOOS=linux
export CGO_ENABLED=0

all: zip

zip: build
	@zip -r ./scaler.zip ./main


build:
	@go build -ldflags "-s -w" -o main main.go

clean:
	@rm -f *.zip || true
	@rm -f main || true