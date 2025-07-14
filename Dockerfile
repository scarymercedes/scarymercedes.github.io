FROM ruby:3.4-slim-bookworm

# We don't want to run as root so let's fix that

ARG USER=jekyll
ENV HOME /home/$USER

RUN apt update
# install sudo as root
RUN apt install -y sudo

# add new user
RUN adduser $USER \
        && echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
        && chmod 0440 /etc/sudoers.d/$USER

USER $USER

# Install Jekyll dependencies
RUN sudo apt install -y build-essential gcc cmake git

# Update the bundler and install Jekyll
RUN sudo gem update bundler 
RUN sudo gem install bundler jekyll