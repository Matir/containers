FROM ruby:3.2-slim

# Install build dependencies for the gem
RUN apt-get update && apt-get install -y build-essential

# Install the gem
RUN gem install asmrepl

# Run the REPL by default
CMD ["asmrepl"]
