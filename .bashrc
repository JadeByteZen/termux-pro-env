#!/data/data/com.termux/files/usr/bin/bash
#MIT License

#Copyright (c) 2025 Web_LDix

#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute,sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.
if [[ ! -d "/data/data/com.termux/files" ]]; then
   echo -e "\033[1;31m错误: 此配置仅适用于 Termux 环境\033[0m"
   return 1
fi
[[ $- != *i* ]] && return
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL="erasedups:ignoreboth"
export HISTIGNORE="&:ls:ll:la:l:cd:pwd:exit:clear:history"
export HISTTIMEFORMAT="%F %T "
shopt -s histappend
shopt -s cmdhist
shopt -s checkwinsize
shopt -s autocd
shopt -s cdspell
shopt -s direxpand
shopt -s globstar
export TERMUX_HOME="/data/data/com.termux/files"
export TERMUX_PREFIX="$TERMUX_HOME/usr"
export PATH="$TERMUX_PREFIX/bin:$TERMUX_PREFIX/bin/applets:$PATH"
export EDITOR="micro"
export VISUAL="$EDITOR"
export PAGER="less"
export MANPAGER="less -R"
export LESS="-R -X -F"
if [[ -d "/storage/emulated/0" ]]; then
   export ANDROID_STORAGE="/storage/emulated/0"
elif [[ -d "/sdcard" ]]; then
   export ANDROID_STORAGE="/sdcard"
fi
__ps1() {
   local EXIT_CODE="$?"
   local RED="\e[1;31m"
   local GREEN="\e[1;32m"
   local YELLOW="\e[1;33m"
   local BLUE="\e[1;34m"
   local PURPLE="\e[1;35m"
   local CYAN="\e[1;36m"
   local RESET="\e[0m"
   local BOLD="\e[1m"
   local git_branch=""
   if command -v git &>/dev/null; then
       git_branch=$(git branch 2>/dev/null | grep '^*' | colrm 1 2)
       if [[ -n "$git_branch" ]]; then
           local git_status=$(git status --porcelain 2>/dev/null)
           if [[ -n "$git_status" ]]; then
               git_branch=" ⎇ ${git_branch} ●"
           else
               git_branch=" ⎇ ${git_branch}"
           fi
       fi
   fi
   PS1="${PURPLE}⌚ \t ${BOLD}${GREEN}➜ ${CYAN}\u@\h${RESET}"
   local current_path="\w"
   [[ "$PWD" == "$HOME" ]] && current_path="~"
   PS1+=" ${BLUE}📁 ${current_path}${RESET}"
   [[ -n "$git_branch" ]] && PS1+="${YELLOW}${git_branch}${RESET}"
   if [[ "$EXIT_CODE" != 0 ]]; then
       PS1+=" ${RED}✘${EXIT_CODE}${RESET}"
   else
       PS1+=" ${GREEN}✓${RESET}"
   fi
   PS1+="\n${BOLD}${GREEN}❯${RESET} "
}
PROMPT_COMMAND=__ps1
if [ -f "$TERMUX_PREFIX/share/bash-completion/bash_completion" ]; then
   . "$TERMUX_PREFIX/share/bash-completion/bash_completion"
elif [ -f "$TERMUX_PREFIX/etc/profile.d/bash_completion.sh" ]; then
   . "$TERMUX_PREFIX/etc/profile.d/bash_completion.sh"
fi
command -v pkg &>/dev/null && complete -o default -F _pkg pkg
mkcd() {
   if [[ $# -eq 0 ]]; then
       echo "用法: mkcd <目录名>"
       return 1
   fi
   mkdir -p "$@" && cd "${@: -1}" || {
       echo -e "\033[1;31m错误: 无法创建目录 '$@'\033[0m"
       return 1
   }
}
search() {
   if [[ $# -eq 0 ]]; then
       echo "用法:"
       echo "  search [模式] - 搜索文件名"
       echo "  search [内容] [文件模式] - 搜索文件内容"
       echo "示例:"
       echo "  search '*.sh'"
       echo "  search 'function' *.sh"
       return 1
   fi
   if [[ $# -eq 1 ]]; then
       echo -e "\033[1;34m🔍 搜索文件名匹配 '$1' 的文件:\033[0m"
       find . -type f -iname "$1" 2>/dev/null
   else
       local pattern="$1"
       shift
       echo -e "\033[1;34m🔍 在 ${@} 中搜索内容 '$pattern':\033[0m"
       grep --color=auto -rnw "$@" -e "$pattern" 2>/dev/null
   fi
}
pkg-up() {
   echo -e "\033[1;36m🔄 更新软件包列表...\033[0m"
   apt update -y &>/dev/null || {
       echo -e "\033[1;31m错误: 更新失败\033[0m"
       return 1
   }
   
   echo -e "\033[1;36m⚡ 升级所有软件包...\033[0m"
   apt upgrade -y &>/dev/null || {
       echo -e "\033[1;31m警告: 部分包升级失败\033[0m"
   }
   
   echo -e "\033[1;36m🧹 清理无用包...\033[0m"
   apt autoremove -y &>/dev/null
   apt autoclean -y &>/dev/null
   
   echo -e "\033[1;32m✅ 系统更新完成!\033[0m"
   echo -e "\033[1;33m已安装包: $(dpkg -l | wc -l)\033[0m"
}
sysinfo() {
   echo -e "\n\033[1;36m🖥️  系统信息\033[0m"
   echo "----------------------------------"
   echo -e "\033[1;33m💻 设备型号: \033[0m$(getprop ro.product.model)"
   echo -e "\033[1;33m📱 Android 版本: \033[0m$(getprop ro.build.version.release)"
   echo -e "\033[1;33m🔄 Termux 版本: \033[0m$(pkg show termux-api | grep Version | awk '{print $2}')"
   echo -e "\033[1;33m🐧 内核版本: \033[0m$(uname -r)"
   echo -e "\033[1;33m⏳ 运行时间: \033[0m$(uptime -p | sed 's/up //')"
   echo -e "\033[1;33m💾 存储空间: \033[0m$(df -h $PWD | awk 'NR==2 {print $4}') 可用"
   echo -e "\033[1;33m🧠 内存使用: \033[0m$(free -m | awk 'NR==2 {printf "%.1f%% of %dMB", $3*100/$2, $2}')"
   echo "----------------------------------"
}
alias refresh="source ~/.bashrc"
alias bashrc="$EDITOR ~/.bashrc"
alias reload="exec bash"
alias ls="ls -F --color=auto"
alias ll="ls -lh --color=auto"
alias la="ls -lha --color=auto"
alias lt="ls -lhtr --color=auto"
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"
alias pkg-in="pkg install"
alias pkg-rm="pkg uninstall"
alias pkg-list="pkg list-installed"
alias perm="stat -c '%a %n'"
alias 755="chmod 755 -v"
alias 644="chmod 644 -v"
alias logcat="logcat -d -v time"
helpme() {
   echo -e "\033[1;36m🛠️  Termux 专业配置帮助\033[0m"
   echo "----------------------------------"
   echo -e "\033[1;33m系统命令:\033[0m"
   echo "  refresh  - 刷新配置"
   echo "  bashrc   - 编辑配置文件"
   echo "  sysinfo  - 显示系统信息"
   echo "  pkg-up   - 更新所有软件包"
   echo -e "\n\033[1;33m文件管理:\033[0m"
   echo "  ls, ll, la, lt - 增强的文件列表"
   echo "  mkcd <dir>     - 创建并进入目录"
   echo "  search <模式>  - 搜索文件或内容"
   echo -e "\n\033[1;33m开发工具:\033[0m"
   echo "  perm <文件> - 查看权限"
   echo "  755/644 <文件> - 设置权限"
   echo "----------------------------------"
   echo -e "输入 \033[1;32mman <命令>\033[0m 获取详细帮助"
}
clear
if command -v figlet &>/dev/null; then
   echo -e "\033[1;36m$(figlet -f slant Termux)\033[0m"
else
   echo -e "\033[1;36mTermux 专业环境\033[0m"
fi
echo -e "\033[1;32m✨ 您的移动端 Linux 专业环境已就绪！\033[0m"
echo -e "\033[1;33m🖥️  主机: \033[0m$(hostname)"
echo -e "\033[1;33m🐧 系统: \033[0m$(uname -srm)"
echo -e "\033[1;33m📅 日期: \033[0m$(date +'%Y-%m-%d %H:%M:%S')"
echo -e "\033[1;33m📦 软件包: \033[0m$(dpkg -l | wc -l) 个已安装"
echo -e "\033[1;33m💾 存储: \033[0m$(df -h $PWD | awk 'NR==2 {print $4}') 可用"
echo -e "\n\033[1;35m💡 提示: 输入 \033[1;36mhelpme\033[1;35m 查看快捷命令\033[0m"
echo -e "\033[1;31m⚠ 警告: 请勿滥用 root 权限\033[0m"
