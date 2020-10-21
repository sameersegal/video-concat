FROM golang
RUN apt-get update && apt-get install -y \
	git 
RUN go get github.com/prasmussen/gdrive	
RUN mkdir -p /root/.gdrive
COPY credentials.json /root/.gdrive/credentials.json
RUN apt-get update && apt-get install -y \
	curl \
	unzip && \
	rm -rf /var/lib/apt/lists/* 
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.0.30.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install && rm -rf aws*
COPY scripts/*.sh /root/
WORKDIR "/root"
ENTRYPOINT ["./download.sh"]