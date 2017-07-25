FROM debian:stretch

RUN apt-get update && \
    apt-get install --no-install-recommends -y -q \
    curl ruby make

RUN gem install bundler rake rubocop rspec

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /bin/kubectl
