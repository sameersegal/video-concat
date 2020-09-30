FROM golang
RUN apt-get update && apt-get install -y \
	git 
RUN go get github.com/prasmussen/gdrive	
FROM jrottenberg/ffmpeg:4.1
COPY --from=0 /go/bin/gdrive /usr/local/bin/gdrive
RUN mkdir -p /root/.gdrive
COPY credentials.json /root/.gdrive/credentials.json
COPY generate_video.sh . 
RUN chmod +x generate_video.sh
ENTRYPOINT ["./generate_video.sh"]
