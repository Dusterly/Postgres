FROM swift:4.1.3
RUN apt -y update
RUN apt install -y libpq-dev
