#!/bin/bash

# Verifica se o script está sendo executado como root
if [ "$(id -u)" != "0" ]; then
   echo "Este script deve ser executado como root. Use sudo."
   exit 1
fi

echo "Baixando o histórico padrão para o Zsh..."
curl -o ~/.zsh_history https://raw.githubusercontent.com/guckesh/guckesh/refs/heads/master/profile/.zsh_history || {
    echo "Erro ao baixar o histórico Zsh. Saindo..."
    exit 1
}

echo "Atualizando o sistema..."
sudo pacman -Syu --noconfirm || { 
    echo "Erro ao atualizar o sistema. Saindo..."; 
    exit 1; 
}

echo "Instalando pacotes necessários..."
sudo pacman -S --needed --noconfirm base-devel git jdk-openjdk wget unzip repo python python2 ncurses zlib zip gperf clang lld ninja flex bison zsh openssh neofetch gufw || {
    echo "Erro ao instalar pacotes. Saindo..."
    exit 1
}

echo "Instalando pacotes AUR necessários (necessita yay)..."
if ! command -v yay &> /dev/null; then
    echo "O gerenciador de pacotes yay não está instalado. Instalando agora..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -si --noconfirm && cd ~ || {
        echo "Erro ao instalar o yay. Saindo..."
        exit 1
    }
fi

yay -S --noconfirm lib32-ncurses lib32-zlib lib32-gcc-libs lib32-llvm lib32-clang google-chrome pikaur || {
    echo "Erro ao instalar pacotes AUR. Saindo..."
    exit 1
}

echo "Configurando variáveis de ambiente no .zshrc..."
cat <<EOF >>~/.zshrc

# Variáveis para compilação Android
export USE_CCACHE=1
export CCACHE_DIR=~/.ccache
export ANDROID_HOME=~/Android/Sdk
export PATH=\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/tools:\$PATH
EOF

echo "Baixando e configurando a ferramenta repo..."
mkdir -p ~/bin
if [ ! -f ~/bin/repo ]; then
    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo || {
        echo "Erro ao baixar a ferramenta repo. Saindo..."
        exit 1
    }
    chmod a+x ~/bin/repo
    export PATH=~/bin:\$PATH
fi

echo "Instalando Oh My Zsh..."
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || {
    echo "Erro ao instalar Oh My Zsh. Saindo..."
    exit 1
}

echo "Configurando tema 'bira' no Oh My Zsh..."
sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="bira"/' ~/.zshrc || {
    echo "Erro ao configurar o tema 'bira'."
}

echo "Trocando shell padrão para Zsh..."
chsh -s $(which zsh) || {
    echo "Erro ao trocar para Zsh."
}

echo "Preparando diretório para código-fonte Android..."
mkdir -p ~/Android15 || {
    echo "Erro ao criar diretório para código-fonte."
    exit 1
}

cd ~/Android15

echo "Gerando chave SSH para o Git..."
if [ ! -f ~/.ssh/id_rsa ]; then
    read -p "Digite o email para configurar sua chave SSH: " user_email
    ssh-keygen -t rsa -b 4096 -C "$user_email" -N "" -f ~/.ssh/id_rsa || {
        echo "Erro ao gerar a chave SSH."
        exit 1
    }
    echo "Chave SSH gerada:"
    cat ~/.ssh/id_rsa.pub

    echo "Adicionando a chave SSH ao agente..."
    eval "$(ssh-agent -s)" || echo "Erro ao iniciar o agente SSH."
    ssh-add ~/.ssh/id_rsa || {
        echo "Erro ao adicionar chave ao agente SSH."
    }

    echo "Por favor, adicione a seguinte chave pública ao seu repositório Git (GitHub, GitLab, etc.):"
    echo "--------------------------------------"
    cat ~/.ssh/id_rsa.pub
    echo "--------------------------------------"

    echo "Abrindo a página de configuração de chaves SSH do GitHub..."
    xdg-open "https://github.com/settings/keys" 2>/dev/null || echo "Abra https://github.com/settings/keys manualmente."
else
    echo "Chave SSH já existe. Pule esta etapa."
fi

echo "Configurando Git..."
git config --global user.email "mezaquegit@gmail.com"
git config --global user.name "Mezaque Silver"
echo "Configuração do Git concluída: email 'mezaquegit@gmail.com', nome 'Mezaque Silver'."

echo "Clonando o repositório do Themix-GUI..."
cd ~
git clone git@github.com:themix-project/themix-gui Themix && cd Themix || {
    echo "Erro ao clonar o repositório do Themix-GUI. Saindo..."
    exit 1
}

echo "Instalando o Themix-GUI com pikaur..."
pikaur -S themix-full-git --noconfirm || {
    echo "Erro ao instalar o Themix-GUI. Saindo..."
    exit 1
}

echo "Script concluído com sucesso. Reinicie o terminal para aplicar as mudanças."

