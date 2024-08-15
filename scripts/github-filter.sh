#!/bin/bash

# Variables
USER="gperreymond"
TOKEN="your_github_token"
TOPIC="kubernetes"

# URL of the API to get the user's repositories
URL="https://api.github.com/users/$USER/repos"

# Make the request to the GitHub API
# response=$(curl -s -H "Authorization: token $TOKEN" "$URL")
response=$(curl -s "$URL")

# Check if the request was successful
if [ $? -ne 0 ]; then
  echo "Error making request to the GitHub API."
  exit 1
fi

# Parse the JSON response and list the names of repositories with the specific topic
echo "List of $USER's repositories with the topic '$TOPIC':"
echo "$response" | jq -r '.[] | select(.topics[]? == "'$TOPIC'") | .name'
