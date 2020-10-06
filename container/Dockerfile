FROM golang
RUN apt-get update && apt-get install -y \
	git 
RUN go get github.com/prasmussen/gdrive	
FROM jrottenberg/ffmpeg:4.1
COPY --from=0 /go/bin/gdrive /usr/local/bin/gdrive
RUN mkdir -p /root/.gdrive
COPY credentials.json /root/.gdrive/credentials.json
RUN apt-get update && apt-get install -y \
	curl \
	unzip 
	# xz-utils \
	# python3 
	# \
	# build-essential installed
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.0.30.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install && rm -rf aws*
# RUN curl "https://nodejs.org/dist/v10.22.1/node-v10.22.1-linux-x64.tar.xz" -o "node-v10.22.1-linux-x64.tar.xz" && mkdir -p /usr/local/lib/nodejs && tar -xJvf node-v10.22.1-linux-x64.tar.xz -C /usr/local/lib/nodejs && rm -rf node*
# ENV PATH /usr/local/lib/nodejs/node-v10.22.1-linux-x64/bin:$PATH
# RUN . ~/.bashrc

# COPY js/index.js js/package.json /tmp/workdir/
# RUN npm install -g node-gyp
# RUN npm install -g ffmpeg-concat

COPY scripts/*.sh /tmp/workdir/

ENTRYPOINT ["./caller.sh"]
