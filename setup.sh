#!/bin/bash

# Step 1: Install Git, curl and other dependencies

if ! command -v git &> /dev/null; then
    echo "Git is not installed. Installing Git..."
    sudo apt-get update
    sudo apt-get install -y git
    echo "Git installed successfully."
else
    echo "Git is already installed."
fi

if ! command -v curl &> /dev/null; then
    echo "curl is not installed. Installing curl..."
    sudo apt-get install -y curl
    echo "curl installed successfully."
fi

if ! command -v wget &> /dev/null; then
    echo "wget is not installed. Installing wget..."
    sudo apt-get install -y wget
    echo "wget installed successfully."
fi



# Step 2: Install Node.js and npm
# I didn't use fnm because I didn't want to add another dependecy and keep it simple

if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
    echo "Node.js and npm are not installed. Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    echo "Node.js and npm installed successfully."
else
    echo "Node.js and npm are already installed."
fi


# Step 3: Install Docker

if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    echo "Docker installed successfully."
    # not sure about this warning
    echo "You must log out and log back in (or restart your system) for Docker to work without sudo."
else
    echo "Docker is already installed."
fi

# Step 4: Install Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installed successfully."
else
    echo "Docker Compose is already installed."
fi


# Step 5: Clone the repository (if not already cloned)

REPO_DIR="vuejs-docs-dockerized-hexo-and-nginx"  
if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning the repository..."
    
    if git clone https://github.com/pogiship/vuejs-docs-dockerized-hexo-and-nginx.git $REPO_DIR; then
        echo "Repository cloned successfully."
    else 
        echo "Error: Failed to clone the repository. Check your internet connection or repo URL."
        exit 1
    fi
else
    echo "Repository already exists."
fi

# step 6: npm install ve npm run build

cd $REPO_DIR || { echo "Error: Failed to change directory to $REPO_DIR"; exit 1; }

#  Install project dependencies

echo "Installing project dependencies..."
if npm install; then
    echo "Project dependencies installed successfully."
else
    echo "Error: npm install failed!"
    exit 1
fi

# Build the project

echo "Building the static files..."
if npm run build; then
    echo "Static files built successfully."
else
    echo "Error: Build process failed!"
    exit 1
fi

############################################################################################################
# Step 7: Build and start the Docker containers

echo "Starting Docker containers..."
if docker compose up -d; then
    echo "Docker containers started successfully."
else
    echo "Error: Failed to start Docker containers."
    exit 1
fi



# Step 8: Verify the setup

echo "Verifying the setup..."

# Wait for the containers to start
sleep 5  

if docker ps | grep -q "hexo-container"; then  # Replace with your container name
    echo "Setup is successful! The application is running."
else
    echo "Setup failed. Please check the logs."
fi

