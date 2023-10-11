FROM python:3.9-alpine3.13
LABEL maintainer=bhusalsanjeev23@gmail.com

# This environment variable is recommended to use when using python inside the docker container
ENV PYTHONBUFFERED 1 

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

# We have specified the entire command into a single RUN command. This will ensure that docker will only create a single layer while building this image.

# Creating virtual environment inside a docker container is kind of optional. But if there are some dependencies in the base python image then, it might conflict with your project's dependencies. Hence, creating virtual environment gives extra safety.

# We first upgrade pip to its latest version. Then we install all the dependencies from /tmp/requirements.txt file. Then we remove the file since it is no longer needed and we should keep our docker image as light as possible. It is a best practise to not use ROOT user inside the container since if the container gets compromised, the attacker will have root access. Hence we create a user called django-user. --disabled-password means we cannot log in to the container with the password. --no-create-home means we donot create the home directory for this new user. This is done to keep the image as light as possible. Then we update the path variable and set the user to be django-user. Before setting django-user all above commands were run by root user. 

ARG DEV=false

RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
      then /py/bin/pip install -r /tmp/requirements.dev.txt; \
    fi && \
    rm -rf /tmp && \
    adduser \
      --disabled-password \
      --no-create-home \
      django-user

ENV PATH="/py/bin:$PATH"

USER django-user



