#!/bin/bash

# ==============================================================================
# Plymouth Theme Creator BY CTOR
# ==============================================================================
# MP4 INTO BOOT ANIMATION 🫨
#
# Prerequisites:
# - ffmpeg must be installed on your system. If using Arch Linux, the script
#   will prompt you to install it.
# ==============================================================================

if tput setaf 1 >/dev/null 2>&1; then
    # Standard Colors
    Color_Off="$(tput sgr0)"
    Black="$(tput setaf 0)"
    Red="$(tput setaf 1)"
    Green="$(tput setaf 2)"
    Yellow="$(tput setaf 3)"
    Blue="$(tput setaf 4)"
    Purple="$(tput setaf 5)"
    Cyan="$(tput setaf 6)"
    White="$(tput setaf 7)"

    # Bold Colors
    BBlack="$(tput bold; tput setaf 0)"
    BRed="$(tput bold; tput setaf 1)"
    BGreen="$(tput bold; tput setaf 2)"
    BYellow="$(tput bold; tput setaf 3)"
    BBlue="$(tput bold; tput setaf 4)"
    BPurple="$(tput bold; tput setaf 5)"
    BCyan="$(tput bold; tput setaf 6)"
    BWhite="$(tput bold; tput setaf 7)"

    # Bright Bold Colors
    BIBlack="$(tput bold; tput setaf 8)"
    BIRed="$(tput bold; tput setaf 9)"
    BIGreen="$(tput bold; tput setaf 10)"
    BIYellow="$(tput bold; tput setaf 11)"
    BIBlue="$(tput bold; tput setaf 12)"
    BIPurple="$(tput bold; tput setaf 13)"
    BICyan="$(tput bold; tput setaf 14)"
    BIWhite="$(tput bold; tput setaf 15)"
else
    # Fallback to hardcoded ANSI codes if tput is not available or supported
    Color_Off="\033[0m"
    Black="\033[0;30m"
    Red="\033[0;31m"
    Green="\033[0;32m"
    Yellow="\033[0;33m"
    Blue="\033[0;34m"
    Purple="\033[0;35m"
    Cyan="\033[0;36m"
    White="\033[0;37m"

    BBlack="\033[1;30m"
    BRed="\033[1;31m"
    BGreen="\033[1;32m"
    BYellow="\033[1;33m"
    BBlue="\033[1;34m"
    BPurple="\033[1;35m"
    BCyan="\033[1;36m"
    BWhite="\033[1;37m"
    
    BIBlack="\033[1;90m"
    BIRed="\033[1;91m"
    BIGreen="\033[1;92m"
    BIYellow="\033[1;93m"
    BIBlue="\033[1;94m"
    BIPurple="\033[1;95m"
    BICyan="\033[1;96m"
    BIWhite="\033[1;97m"
fi

echo -ne "
${BCyan}-------------------------------------------------------------------------
 ____  _      __ __  ___ ___  ______  __ __      ___ ___   ____  __  _    ___  __ 
|    \| T    |  T  T|   T   T|      T|  T  T    |   T   T /    T|  l/ ]  /  _]|  T
|  o  ) |    |  |  || _   _ ||      ||  l  |    | _   _ |Y  o  ||  ' /  /  [_ |  |
|   _/| l___ |  ~  ||  \_/  |l_j  l_j|  _  |    |  \_/  ||     ||    \ Y    _]|__j
|  |  |     Tl___, ||   |   |  |  |  |  |  |    |   |   ||  _  ||     Y|   [_  __ 
|  |  |     ||     !|   |   |  |  |  |  |  |    |   |   ||  |  ||  .  ||     T|  T
l__j  l_____jl____/ l___j___j  l__j  l__j__j    l___j___jl__j__jl__j\_jl_____jl__j
                                                                                   
-------------------------------------------------------------------------${Color_Off}
"
echo -e "
${BRed}------------------------------------------------------------------------
    NOTE!:MAKE SURE YOUR MP4 IS ON MP4 FOLDER ONLY 1 MP4.
------------------------------------------------------------------------${Color_Off}"
read -p "Enter a name for your new Plymouth theme: " THEME_NAME

if [ -z "$THEME_NAME" ]; then
    echo -e "${Red}Theme name cannot be empty. Exiting.${Color_Off}"
    exit 1
fi

echo -e "${Green}Theme name set to: ${Yellow}$THEME_NAME${Color_Off}"

PLYMOUTH_DIR="OUTPUT/$THEME_NAME"
MP4_DIR="MP4"
IMAGE_OUTPUT_DIR="$PLYMOUTH_DIR"
DEST_DIR="/usr/share/plymouth/themes"

if [ -d "$PLYMOUTH_DIR" ]; then
    echo -e "${Yellow}The directory '$PLYMOUTH_DIR' already exists.${Color_Off}"
    read -p "Do you want to overwrite it? (y/n): " -n 1 -r OVERWRITE
    echo
    if [[ ! $OVERWRITE =~ ^[Yy]$ ]]; then
        echo -e "${Cyan}Operation cancelled by user. Exiting.${Color_Off}"
        exit 1
    fi
    echo -e "${Yellow}Overwriting existing directory...${Color_Off}"
    rm -rf "$PLYMOUTH_DIR"
fi

echo -e "${Green}Creating theme directory: ${Yellow}$PLYMOUTH_DIR${Color_Off}"
mkdir -p "$PLYMOUTH_DIR"

echo -e "${Green}Searching for MP4 file in '$MP4_DIR' folder...${Color_Off}"

MP4_FILE=$(find "$MP4_DIR" -maxdepth 1 -type f -name "*.mp4" -print -quit)

if [ -z "$MP4_FILE" ]; then
    echo -e "${Red}No MP4 file found in '$MP4_DIR' folder. Exiting.${Color_Off}"
    exit 1
fi

echo -e "${Green}Found MP4 file: ${Yellow}$MP4_FILE${Color_Off}"

if ! command -v ffmpeg &> /dev/null; then
    echo -e "${Red}ffmpeg command not found.${Color_Off}"
    if [ -f /etc/arch-release ]; then
        echo -e "${Yellow}Detected Arch Linux. Attempting to install ffmpeg with pacman.${Color_Off}"
        read -p "Do you want to install ffmpeg? (y/n): " -n 1 -r INSTALL_FFMPEG
        echo
        if [[ $INSTALL_FFMPEG =~ ^[Yy]$ ]]; then
            sudo pacman -Syu ffmpeg --noconfirm
            if ! command -v ffmpeg &> /dev/null; then
                echo -e "${Red}Installation failed. Please install ffmpeg manually and try again.${Color_Off}"
                exit 1
            fi
        else
            echo -e "${Yellow}Installation cancelled. Cannot proceed without ffmpeg. Exiting.${Color_Off}"
            exit 1
        fi
    else
        echo -e "${Red}Please install ffmpeg manually and try again.${Color_Off}"
        exit 1
    fi
fi

echo -e "${Green}Converting MP4 to PNG images...${Color_Off}"
ffmpeg -i "$MP4_FILE" -vf "scale=iw:ih" -start_number 0 "$IMAGE_OUTPUT_DIR/progress-%d.png"

IMAGE_COUNT=$(ls -1 "$IMAGE_OUTPUT_DIR" | grep 'progress' | wc -l)
echo -e "${Green}Conversion complete. ${Yellow}$IMAGE_COUNT${Green} images created.${Color_Off}"

echo -e "${Green}Creating ${Yellow}$THEME_NAME.plymouth${Green} file...${Color_Off}"
cat << EOF > "$PLYMOUTH_DIR/$THEME_NAME.plymouth"
[Plymouth Theme]
Name=$THEME_NAME
Description=A plymouth theme created from an MP4 animation.
Comment=Created by CtorW
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/$THEME_NAME
ScriptFile=/usr/share/plymouth/themes/$THEME_NAME/$THEME_NAME.script
EOF

echo -e "${Green}Creating ${Yellow}$THEME_NAME.script${Green} file...${Color_Off}"
cat << EOF > "$PLYMOUTH_DIR/$THEME_NAME.script"
# ██████╗████████╗ ██████╗ ██████╗ ██╗     ██╗
#██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗██║     ██║
#██║        ██║   ██║   ██║██████╔╝██║ █╗  ██║
#██║        ██║   ██║   ██║██╔══██╗██║███╗██║
#╚██████╗   ██║   ╚██████╔╝██║  ██║╚███╔███╔╝
# ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝ ╚══╝╚══╝ 
# Made By:- CtorW
# follow on github:- https://github.com/CtorW

// Screen size
screen.w = Window.GetWidth(0);
screen.h = Window.GetHeight(0);
screen.half.w = Window.GetWidth(0) / 2;
screen.half.h = Window.GetHeight(0) / 2;

// Question prompt
question = null;
answer = null;

// Message
message = null;

// Password prompt
bullets = null;
prompt = null;
bullet.image = Image.Text("*", 1, 1, 1);

// Flow
state.status = "play";
state.time = 0.0;

//--------------------------------- Refresh (Logo animation) --------------------------

# cycle through all images
for (i = 0; i < ${IMAGE_COUNT}; i++)
  flyingman_image[i] = Image("progress-" + i + ".png");
flyingman_sprite = Sprite();

# set image position
flyingman_sprite.SetX(Window.GetX() + (Window.GetWidth(0) / 2 - flyingman_image[0].GetWidth() / 2)); # Place images in the center
flyingman_sprite.SetY(Window.GetY() + (Window.GetHeight(0) / 2 - flyingman_image[0].GetHeight() / 2));

progress = 0;

fun refresh_callback ()
  {
    flyingman_sprite.SetImage(flyingman_image[Math.Int(progress / 2) % ${IMAGE_COUNT}]);
    progress++;
  }
  
Plymouth.SetRefreshFunction (refresh_callback);

//------------------------------------- Password prompt -------------------------------
fun DisplayQuestionCallback(prompt, entry) {
    question = null;
    answer = null;

    if (entry == "")
        entry = "<answer>";

    question.image = Image.Text(prompt, 1, 1, 1);
    question.sprite = Sprite(question.image);
    question.sprite.SetX(screen.half.w - question.image.GetWidth() / 2);
    question.sprite.SetY(screen.h - 4 * question.image.GetHeight());

    answer.image = Image.Text(entry, 1, 1, 1);
    answer.sprite = Sprite(answer.image);
    answer.sprite.SetX(screen.half.w - answer.image.GetWidth() / 2);
    answer.sprite.SetY(screen.h - 2 * answer.image.GetHeight());
}
Plymouth.SetDisplayQuestionFunction(DisplayQuestionCallback);

//------------------------------------- Password prompt -------------------------------
fun DisplayPasswordCallback(nil, bulletCount) {
    state.status = "pause";
    totalWidth = bulletCount * bullet.image.GetWidth();
    startPos = screen.half.w - totalWidth / 2;

    prompt.image = Image.Text("Enter Password", 1, 1, 1);
    prompt.sprite = Sprite(prompt.image);
    prompt.sprite.SetX(screen.half.w - prompt.image.GetWidth() / 2);
    prompt.sprite.SetY(screen.h - 4 * prompt.image.GetHeight());

    // Clear all bullets (user might hit backspace)
    bullets = null;
    for (i = 0; i < bulletCount; i++) {
        bullets[i].sprite = Sprite(bullet.image);
        bullets[i].sprite.SetX(startPos + i * bullet.image.GetWidth());
        bullets[i].sprite.SetY(screen.h - 2 * bullet.image.GetHeight());
    }
}
Plymouth.SetDisplayPasswordFunction(DisplayPasswordCallback);

//--------------------------- Normal display (unset all text) ----------------------
fun DisplayNormalCallback() {
    state.status = "play";
    bullets = null;
    prompt = null;
    message = null;
    question = null;
    answer = null;
}
Plymouth.SetDisplayNormalFunction(DisplayNormalCallback);

//----------------------------------------- Message --------------------------------
fun MessageCallback(text) {
    message.image = Image.Text(text, 1, 1, 1);
    message.sprite = Sprite(message.image);
    message.sprite.SetPosition(screen.half.w - message.image.GetWidth() / 2, message.image.GetHeight());
}
Plymouth.SetMessageFunction(MessageCallback);

EOF

if [ -z "$DEST_DIR" ]; then
    echo -e "${Red}Error: DEST_DIR is not set. Cannot move theme folder.${Color_Off}"
    exit 1
fi

echo -e "${Green}Moving theme directory to system folder: ${Yellow}$DEST_DIR${Color_Off}"
sudo mv "$PLYMOUTH_DIR" "$DEST_DIR"

if [ $? -eq 0 ]; then
    echo -e "${Green}Theme '${Yellow}$THEME_NAME${Green}' successfully moved to ${Yellow}$DEST_DIR/${Color_Off}"
else
    echo -e "${Red}Failed to move the theme directory. Please check permissions.${Color_Off}"
    exit 1
fi

echo -ne "
${BGreen}-------------------------------------------------------------------------
  _______ ___ ___ _______ _______ _______ _______ _______ 
 |   _   |   Y   |   _   |   _   |   _   |   _   |   _   |
 |   1___|.  |   |.  1___|.  1___|.  1___|   1___|   1___|
 |____   |.  |   |.  |___|.  |___|.  __)_|____   |____   |
 |:  1   |:  1   |:  1   |:  1   |:  1   |:  1   |:  1   |
 |::.. . |::.. . |::.. . |::.. . |::.. . |::.. . |::.. . |
 `-------`-------`-------`-------`-------`-------`-------'
-------------------------------------------------------------------------${Color_Off}"                                                  
echo -e "${Cyan}=======================================${Color_Off}"
echo -e "${Green}          Script by CtorW  ${Color_Off}"
echo -e "${Green}Your Plymouth theme is ready!${Color_Off}"
echo -e "${Green}To activate it, run the following commands:${Color_Off}"
echo -e "${Yellow}sudo plymouth-set-default-theme -R $THEME_NAME${Color_Off}"
echo -e "${Cyan}=======================================${Color_Off}"
