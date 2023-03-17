#!/bin/bash

verbose=false
skip=false
install_go=false
host_type=linux
arch=x86_64

# Check if any of the parameters are -v
if [[ $# -gt 0 && "$1" == "-v" || "$2" == "-v" || "$3" == "-v" ||  "$4" == "-v" ]]; then
    verbose=true
fi

# Check if any of the parameters are -s
if [[ $# -gt 0 && "$1" == "-s" || "$2" == "-s" || "$3" == "-s" ||  "$4" == "-s" ]]; then
    skip=true
fi


#check if any of the parameters are --install-go
if [[ $# -gt 0 && "$1" == "--install-go" || "$2" == "--install-go" || "$3" == "--install-go" ||  "$4" == "--install-go" ]]; then
    install_go=true
fi


# Check if any of the parameters are -h
if [[ $# -gt 0 && "$1" == "-h" || "$2" == "-h" || "$3" == "-h" ||  "$4" == "-h" ]]; then
    echo "Usage: ./reFresh.sh [-v] [-h]"
    echo "[-v] Verbose output"
    echo "[-s] Skip prerequisites installation (go & python3)"
    echo "[--install-go] Install latest go version (backs up your previous $HOME/go directory)"
    echo "[-h] Help"
    exit 1
fi




# Init banner!
echo -e "


██████╗░███████╗███████╗██████╗░███████╗░██████╗██╗░░██╗
██╔══██╗██╔════╝██╔════╝██╔══██╗██╔════╝██╔════╝██║░░██║
██████╔╝█████╗░░█████╗░░██████╔╝█████╗░░╚█████╗░███████║
██╔══██╗██╔══╝░░██╔══╝░░██╔══██╗██╔══╝░░░╚═══██╗██╔══██║
██║░░██║███████╗██║░░░░░██║░░██║███████╗██████╔╝██║░░██║
╚═╝░░╚═╝╚══════╝╚═╝░░░░░╚═╝░░╚═╝╚══════╝╚═════╝░╚═╝░░╚═╝
"
echo "[-] reFresh - Essential BugBounty Toolkit Installer"
echo "[-] Author: @retkoussa"
echo "[-] Version: 1.0.0"
echo "----------------------------------------------------------------------------------------"
read -p "[+] Enter the path to install tools that require git clone (ex: /home/dev/tools): " path



# Check if directory $path exists, if not, create it
if [ ! -d "$path" ]; then
    echo "[-] Creating directory $path"
    sudo mkdir -p $path
fi

# Define all functions responsible for installing tools
check_prerequisites(){
    
    
    # Check if the host is running macOS or Linux
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "[+] The host is running macOS."
        host_type="darwin"

        # Check arch
        if [[ $(arch) == "arm64" ]]; then
            echo "[!]The host is running on an Apple Silicon chip."
            arch="arm64"
        else
            echo "[!] The host is running on an Intel chip."
            arch="x86_64"
        fi

    elif [[ "$(uname)" == "Linux" ]]; then
        echo "[+] The host is running Linux."
        host_type="linux"

        # Check arch
        if [[ $(arch) == "x86_64" ]]; then
            echo "[!] The host is running on an x86_64 chip."
            arch="x86_64"
        else
            echo "[!] The host is running on an x86 chip."
            arch="x86"
        fi
    else
        echo "[!] The host is running an unsupported operating system."
    fi


    # Check if python3 is installed
    if ! command -v python3
    then
        echo "[-] Installing python3"
        sudo apt-get update
        sudo apt install python3 -y
    fi



   # check if install_go is true
    if [[ $install_go == true ]]; then
         # Install go 1.19
        echo "[-] Installing go"
        sudo apt remove --autoremove golang -y
        sudo apt remove --autoremove golang-go -y
        sudo rm -rf /usr/local/go
        sudo rm -rf /usr/local/bin/go
        mv $HOME/go $HOME/go_backup
        source ~/.bashrc

        # Download latest go
        # Check if host_type variable is linux or darwin and if the arch is x86_64, amd64, or i686
        # Linux x86_64
        # Linux i686
        # Darwin x86_64
        # Darwin arm64
        if [[ $host_type == "linux" && $arch == "x86_64" ]]; then
            wget -O $path/golang.tar.gz https://go.dev/dl/go1.20.2.linux-amd64.tar.gz 
        elif [[ $host_type == "linux" && $arch == "i686" ]]; then
            wget -O $path/golang.tar.gz https://go.dev/dl/go1.20.2.linux-386.tar.gz
        elif [[ $host_type == "darwin" && $arch == "x86_64" ]]; then
            wget -O $path/golang.tar.gz https://go.dev/dl/go1.20.2.darwin-amd64.tar.gz
        elif [[ $host_type == "darwin" && $arch == "arm64" ]]; then
            wget -O $path/golang.tar.gz https://go.dev/dl/go1.20.2.darwin-arm64.pkg
        fi

        # Unzip and set the paths
        current_user=$(whoami)
        # tar -C /usr/local -xzf $path/golang.tar.gz
        # check if current user is root
        if [[ $current_user == "root" ]]; then

            #check if file ~/.zshrc exists
            if [ -f ~/.zshrc ]; then
                tar -C /home/ -xzf /home/golang.tar.gz
                sh -c 'echo "export GOPATH=/home/go" >> ~/.zshrc'
                sh -c 'echo "export PATH=$PATH:/home/go/bin:$GOPATH/bin" >> ~/.zshrc'
                sh -c 'echo "export GOCACHE=/home/.cache/go-build" >> ~/.zshrc'
                sudo rm /home/golang.tar.gz
                source ~/.zshrc
                echo "[-] Installed go version: "
                sh -c "go version"
            else
                tar -C /home/ -xzf /home/golang.tar.gz
                sh -c 'echo "export GOPATH=/home/go" >> ~/.bashrc'
                sh -c 'echo "export PATH=$PATH:/home/go/bin:$GOPATH/bin" >> ~/.bashrc'
                sh -c 'echo "export GOCACHE=/home/.cache/go-build" >> ~/.bashrc'
                sudo rm /home/golang.tar.gz
                source ~/.bashrc
                echo "[-] Installed go version: "
                sh -c "go version"
            fi
           
        else
            tar -C /home/$current_user -xzf golang.tar.gz
            sh -c 'echo "export GOPATH=/home/`whoami`/go" >> ~/.bashrc'
            sh -c 'echo "export PATH=$PATH:/home/`whoami`/home/go/bin:$GOPATH/bin" >> ~/.bashrc'
            sh -c 'echo "export GOCACHE=/home/`whoami`/.cache/go-build" >> ~/.bashrc'
            sudo rm $path/golang.tar.gz
            sudo chmod -R 777 /home/$(whoami)/go/bin
            source ~/.bashrc
            echo "[-] Installed go version: "
            sh -c "go version"
        fi
        
    fi
}

xnl-h4ck3r(){
    echo "[-] Installing xnLinkFinder"
    cd $path
    git clone https://github.com/xnl-h4ck3r/xnLinkFinder.git
    cd xnLinkFinder
    sudo python3 setup.py install

    echo "[-] Installing waymore"
    cd $path
    git clone https://github.com/xnl-h4ck3r/waymore.git
    cd $path/waymore
    sudo python3 setup.py install

    # Just in case
    pip install -r $path/waymore/requirements.txt
}

tomnomnom(){
    # install tomnomnom tools with go install -v
    echo "[-] Installing assetfinder"
    go install -v github.com/tomnomnom/assetfinder@latest
    echo "[-] Installing httprobe"
    go install -v github.com/tomnomnom/httprobe@latest
    echo "[-] Installing waybackurls"
    go install -v github.com/tomnomnom/waybackurls@latest
    echo "[-] Installing unfurl"
    go install -v github.com/tomnomnom/unfurl@latest
    echo "[-] Installing qsreplace"
    go install -v github.com/tomnomnom/qsreplace@latest
    echo "[-] Installing gf"
    go install -v github.com/tomnomnom/gf@latest
    echo "[-] Installing meg"
    go install -v github.com/tomnomnom/meg@latest
    echo "[-] Installing fff"
    go install -v github.com/tomnomnom/fff@latest
    echo "[-] Installing html-tool"
    go install -v github.com/tomnomnom/hacks/html-tool@latest
    echo "[-] Installing anti-burl"
    go install -v github.com/tomnomnom/hacks/anti-burl@latest
    echo "[-] Installing filter-resolved"
    go install -v github.com/tomnomnom/hacks/filter-resolved@latest
    echo "[-] Installing anew"
    go install -v github.com/tomnomnom/anew@latest
}

gf_patterns(){
    echo "[-] Installing gf patterns"
    # install gf patterns
    cd $path
    git clone https://github.com/1ndianl33t/Gf-Patterns
    #check if the $HOME/.gf dir exists
    if [ ! -d "$HOME/.gf" ]; then
        echo "[-] Creating directory $HOME/.gf"
        mkdir -p $HOME/.gf
    else
        echo "[!] Directory $HOME/.gf already exists"
    fi

    mv $path/Gf-Patterns/*.json $HOME/.gf
    rm -rf $path/Gf-Patterns
}

hakluke(){
    # install hakluke tools with go install -v
    echo "[-] Installing hakluke tools"
    go install -v github.com/hakluke/hakrawler@latest
    go install -v github.com/hakluke/hakrevdns@latest
    go install -v github.com/hakluke/hakcheckurl@latest

}

1ndianl33t(){
    # install 1ndianl33t tools with go install -v
    echo "[-] Installing 1ndianl33t tools"
    go install -v github.com/1ndianl33t/Gf-Patterns@latest
    go install -v github.com/1ndianl33t/Gf-Patterns/assets@latest
}

install_gospider(){
    # install jaeles-project tools with go install -v
    echo "[-] Installing gospider"
    go install -v github.com/jaeles-project/gospider@latest
}

project_discovery(){
    # install projectdiscovery tools with go install -v  
    echo "[-] Installing projectdiscovery tools"
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

}

install_paramspider(){
    cd $path
    git clone https://github.com/devanshbatham/ParamSpider
    cd ParamSpider
    pip3 install -r requirements.txt
}

install_lc(){
    echo "[-] Installing lc tools"
    go install -v github.com/lc/gau@latest
}

update-install-templates(){

    # install nuclei templates
    echo "[-] Installing nuclei templates"
    nuclei -update-templates
    
    # Set a trap to catch errors and handle them
    trap 'echo "An error occurred"; exit 1' ERR
    set -e

}

# Run the script based on user input
# AKA - Verbosity and Skipping Pre-requisites
if $verbose; then
    echo "[-] Installing tools with verbose output"
    if $skip ; then
        echo "[!] Skipping prerequisites"
    else
        echo "[-] Setting up prerequisites"
        check_prerequisites
    fi
    xnl-h4ck3r
    tomnomnom
    gf_patterns
    hakluke
    1ndianl33t
    install_gospider
    project_discovery
    install_paramspider
    install_lc
    update-install-templates
else
    echo "[-] Installing tools without verbose output"
    echo "[-] This may take a while, please be patient"
    if $skip ; then
        echo "[!] Skipping prerequisites"
    else
        echo "[-] Setting up prerequisites"
        check_prerequisites &> /dev/null
    fi
    echo "[-] Installing xnl-h4ck3r tools"
    xnl-h4ck3r &> /dev/null
    echo "[-] Installing tomnomnom tools"
    tomnomnom &> /dev/null
    echo "[-] Installing gf patterns"
    gf_patterns &> /dev/null
    echo "[-] Installing hakluke tools"
    hakluke &> /dev/null
    echo "[-] Installing 1ndianl33t tools"
    1ndianl33t &> /dev/null
    echo "[-] Installing gospider"
    install_gospider &> /dev/null
    echo "[-] Installing projectdiscovery tools"
    project_discovery &> /dev/null
    echo "[-] Installing lc tools"
    install_lc &> /dev/null
    echo "[-] Installing ParamSpider"
    install_paramspider &> /dev/null
    echo "[-] Updating and installing templates"
    update-install-templates &> /dev/null
fi

echo "[+] Done Installing Bug Bounty Suite, Enjoy!"