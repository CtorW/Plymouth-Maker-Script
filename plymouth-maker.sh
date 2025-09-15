#!/bin/bash

# ==============================================================================
# Plymouth Theme Creator BY CTOR
# ==============================================================================
# MP4 INTO BOOT ANIMATION 🫨
#
# Prerequisites:
# - ffmpeg must be installed on your system.
# ==============================================================================

# --- Setup Terminal Colors ---
# Check if tput is available and can set colors
if tput setaf 1 >/dev/null 2>&1; then
    Color_Off="$(tput sgr0)"
    # Standard
    Red="$(tput setaf 1)"
    Green="$(tput setaf 2)"
    Yellow="$(tput setaf 3)"
    Blue="$(tput setaf 4)"
    Cyan="$(tput setaf 6)"
    White="$(tput setaf 7)"
    # Bold
    BRed="$(tput bold; tput setaf 1)"
    BGreen="$(tput bold; tput setaf 2)"
    BYellow="$(tput bold; tput setaf 3)"
    BBlue="$(tput bold; tput setaf 4)"
    BCyan="$(tput bold; tput setaf 6)"
else
    Color_Off="\033[0m"
    Red="\033[0;31m"
    Green="\033[0;32m"
    Yellow="\033[0;33m"
    Blue="\033[0;34m"
    Cyan="\033[0;36m"
    White="\033[0;37m"
    BRed="\033[1;31m"
    BGreen="\033[1;32m"
    BYellow="\033[1;33m"
    BBlue="\033[1;34m"
    BCyan="\033[1;36m"
fi

msg() {
    local type="$1"
    shift
    local message="$@"
    local color
    local prefix

    case "$type" in
        INFO)    color="$BCyan"   ; prefix="[INFO]"    ;;
        SUCCESS) color="$BGreen"  ; prefix="[SUCCESS]" ;;
        WARN)    color="$BYellow" ; prefix="[WARN]"    ;;
        ERROR)   color="$BRed"    ; prefix="[ERROR]"   ;;
        *)       color="$White"   ; prefix="[MSG]"     ;;
    esac

    printf "%s %s%s\n" "${color}${prefix}${Color_Off}" "$message"
}

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
msg "WARN" "Make sure you have only ONE MP4 file in the 'MP4' folder."

read -p "$(echo -e "${BBlue}[ACTION]${Color_Off} Enter a name for your new Plymouth theme: ")" THEME_NAME

if [ -z "$THEME_NAME" ]; then
    msg "ERROR" "Theme name cannot be empty. Exiting."
    exit 1
fi
msg "SUCCESS" "Theme name set to: $THEME_NAME"

PLYMOUTH_DIR="OUTPUT/$THEME_NAME"
MP4_DIR="MP4"
IMAGE_OUTPUT_DIR="$PLYMOUTH_DIR"
DEST_DIR="/usr/share/plymouth/themes"

if [ -d "$PLYMOUTH_DIR" ]; then
    msg "WARN" "The directory '$PLYMOUTH_DIR' already exists."
    read -p "$(echo -e "${BBlue}[ACTION]${Color_Off} Do you want to overwrite it? (y/n): ")" -n 1 -r OVERWRITE
    echo
    if [[ ! $OVERWRITE =~ ^[Yy]$ ]]; then
        msg "INFO" "Operation cancelled by user. Exiting."
        exit 1
    fi
    msg "WARN" "Overwriting existing directory..."
    rm -rf "$PLYMOUTH_DIR"
fi

msg "INFO" "Creating theme directory: $PLYMOUTH_DIR"
mkdir -p "$PLYMOUTH_DIR"

msg "INFO" "Searching for MP4 file in '$MP4_DIR' folder..."
MP4_FILE=$(find "$MP4_DIR" -maxdepth 1 -type f -name "*.mp4" -print -quit)

if [ -z "$MP4_FILE" ]; then
    msg "ERROR" "No MP4 file found in '$MP4_DIR' folder. Exiting."
    exit 1
fi
msg "SUCCESS" "Found MP4 file: $MP4_FILE"

if ! command -v plymouth &> /dev/null; then
    msg "ERROR" "plymouth command not found."
    if [ -f /etc/arch-release ]; then
        msg "WARN" "Detected Arch Linux. Attempting to install plymouth."
        read -p "$(echo -e "${BBlue}[ACTION]${Color_Off} Do you want to install plymouth? (y/n): ")" -n 1 -r INSTALL_PLYMOUTH
        echo
        if [[ $INSTALL_PLYMOUTH =~ ^[Yy]$ ]]; then
            sudo pacman -Syu plymouth --noconfirm
            if ! command -v plymouth &> /dev/null; then
                msg "ERROR" "Installation failed. Please install plymout manually and try again."
                exit 1
            fi
        else
            msg "ERROR" "Installation cancelled. Cannot proceed without plymouth. Exiting."
            exit 1
        fi
    else
        msg "ERROR" "Please install plymouth manually and try again."
        exit 1
    fi
fi

if ! command -v ffmpeg &> /dev/null; then
    msg "ERROR" "ffmpeg command not found."
    if [ -f /etc/arch-release ]; then
        msg "WARN" "Detected Arch Linux. Attempting to install ffmpeg."
        read -p "$(echo -e "${BBlue}[ACTION]${Color_Off} Do you want to install ffmpeg? (y/n): ")" -n 1 -r INSTALL_FFMPEG
        echo
        if [[ $INSTALL_FFMPEG =~ ^[Yy]$ ]]; then
            sudo pacman -Syu ffmpeg --noconfirm
            if ! command -v ffmpeg &> /dev/null; then
                msg "ERROR" "Installation failed. Please install ffmpeg manually and try again."
                exit 1
            fi
        else
            msg "ERROR" "Installation cancelled. Cannot proceed without ffmpeg. Exiting."
            exit 1
        fi
    else
        msg "ERROR" "Please install ffmpeg manually and try again."
        exit 1
    fi
fi

msg "INFO" "Converting MP4 to PNG images. This may take a moment..."
ffmpeg -loglevel error -i "$MP4_FILE" -vf "scale=iw:ih" -start_number 0 "$IMAGE_OUTPUT_DIR/progress-%d.png"

IMAGE_COUNT=$(ls -1 "$IMAGE_OUTPUT_DIR" | grep 'progress' | wc -l)
msg "SUCCESS" "Conversion complete. $IMAGE_COUNT images created."

msg "INFO" "Creating $THEME_NAME.plymouth file..."
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

msg "INFO" "Creating $THEME_NAME.script file..."
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
    msg "ERROR" "Destination directory DEST_DIR is not set. Cannot move theme."
    exit 1
fi

msg "INFO" "Moving theme to system folder: $DEST_DIR"
sudo mv "$PLYMOUTH_DIR" "$DEST_DIR"

if [ $? -eq 0 ]; then
    msg "SUCCESS" "Theme '$THEME_NAME' successfully installed."
else
    msg "ERROR" "Failed to move the theme directory. Please check permissions or run as root."
    exit 1
fi

echo
echo -e "${BGreen}--------------------------------------------------${Color_Off}"
echo -e "${BGreen}  ___ _  _  ___ ___ ___ ___ ___ _                ${Color_Off}"
echo -e "${BGreen} / __| | | |/ __/ __| __/ __/ __| |               ${Color_Off}"
echo -e "${BGreen} \__ \ |_| | (_| (__| _|\__ \__ \_|               ${Color_Off}"
echo -e "${BGreen} |___/\___/ \___\___|___|___/___(_)               ${Color_Off}"
echo -e "${BGreen}--------------------------------------------------${Color_Off}"
msg "SUCCESS" "Your Plymouth theme is ready!"
msg "INFO" "To activate it, run the following command:"
echo -e "${BYellow}sudo plymouth-set-default-theme -R $THEME_NAME${Color_Off}"
echo