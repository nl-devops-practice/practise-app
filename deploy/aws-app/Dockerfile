# Use an official Python runtime as a parent image
FROM python:3.7-stretch

# Copy the current directory contents into the container at /app
COPY . /

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt

RUN pip install --upgrade werkzeug==0.14.1

EXPOSE 5000

# Run app.py when the container launches
CMD ["python", "app.py"]