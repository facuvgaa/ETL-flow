#!/usr/bin/env bash
set -e

# --- Colors ---
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

echo -e "${YELLOW}>>> Verificando dependencias...${NC}"

# --- Docker ---
if ! command -v docker &> /dev/null
then
    echo -e "${YELLOW}>>> Instalando Docker...${NC}"
    sudo apt-get update -y
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # Agregar clave GPG y repo oficial
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    echo -e "${GREEN}✔ Docker instalado${NC}"
else
    echo -e "${GREEN}✔ Docker ya está instalado${NC}"
fi

# --- Docker Compose ---
if ! docker compose version &> /dev/null
then
    echo -e "${YELLOW}>>> Instalando Docker Compose...${NC}"
    DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
    mkdir -p $DOCKER_CONFIG/cli-plugins
    curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) \
        -o $DOCKER_CONFIG/cli-plugins/docker-compose
    chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
    echo -e "${GREEN}✔ Docker Compose instalado${NC}"
else
    echo -e "${GREEN}✔ Docker Compose ya está instalado${NC}"
fi

# --- Make ---
if ! command -v make &> /dev/null
then
    echo -e "${YELLOW}>>> Instalando Make...${NC}"
    sudo apt-get update -y
    sudo apt-get install -y make
    echo -e "${GREEN}✔ Make instalado${NC}"
else
    echo -e "${GREEN}✔ Make ya está instalado${NC}"
fi

echo -e "${GREEN}>>> Todo listo!${NC}"
