FROM jrottenberg/ffmpeg:4.1-nvidia
RUN apt-get update && apt-get install -y \
	curl \
	unzip && \
	rm -rf /var/lib/apt/lists/* 
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.0.30.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install && rm -rf aws*

COPY scripts/*.sh /tmp/workdir/

ENTRYPOINT ["./caller.sh"]
