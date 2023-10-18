#!/bin/bash

# Create a temporary file to store the updated lines
temp_file="/home/ec2-user/scaper_server/dates_temp.txt"

# Read and process each line in the dates.txt file
while IFS="|" read -r name start_date end_date container_id is_done
do
  # Check if the line ends with "DONE"
  if [[ ! "$is_done" == *"DONE" ]]; then

    # Create a Dockerfile with the updated values
cat > Dockerfile <<EOF
FROM python:3.9-slim

COPY pyproject.toml /tmp/camply/pyproject.toml
COPY README.md /tmp/camply/README.md
COPY camply/ /tmp/camply/camply/

COPY .camply /home/camply/.camply

COPY requirements/requirements-prod.txt /tmp/camply/requirements.txt

RUN python -m pip install -r /tmp/camply/requirements.txt && \
    python -m pip install /tmp/camply --no-dependencies

ENV HOME=/home/camply
ENV USER="$name"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
CMD ["camply", "campsites", "--campground", "232447", "--campground", "232450", "--campground", "232449", "--start-date", "$start_date", "--end-date", "$end_date", "--search-forever", "--notifications", "telegram", "--notifications", "silent", "--polling-interval", "5"]
EOF

  # Run the "scrape" command
  docker build -t matt-camp-image . 
  container_id=$(docker run -d --restart=no matt-camp-image)
  # Add "DONE" to the end of the line
    line="$name|$start_date|$end_date|$container_id|DONE"

  else
    # If the line already ends with "DONE," keep it as is
    line="$name|$start_date|$end_date|$container_id|DONE"
  fi

  # Append the updated line to the temporary file
  echo "$line" >> "$temp_file"

    # You can replace "scrape" with the actual command you want to run.
done < /home/ec2-user/scaper_server/dates.txt

# Replace the original dates.txt with the temporary file
mv "$temp_file" /home/ec2-user/scaper_server/dates.txt
