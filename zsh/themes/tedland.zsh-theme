# Theme based on kiwi, jonathan, and mortalscumbag
# Kubectl info based on https://github.com/superbrothers/zsh-kubectl-prompt

function get_time() {
  echo $(date +%H:%M:%S)
}

# function pcf_info() {
#   setopt +o nomatch
#   if ls manifest*ml 1> /dev/null 2>&1; then
#     CF_ORG="$(cf target | grep -i org: | awk '{print $2}')"
#     CF_SPACE="$(cf target | grep -i space: | awk '{print $2}')"
#     echo "-[%{$reset_color%}%{$fg[white]%}pcf:%{$fg_bold[white]%}%{$fg_bold[yellow]%}${CF_ORG}:${CF_SPACE}%{$fg_bold[green]%}]"
#   fi
# }

autoload -U add-zsh-hook
setopt prompt_subst

function() {
    local account separator modified_time_fmt

    # Specify the separator between project and account
    zstyle -s ':zsh-gcloud-prompt:' separator separator
    if [[ -z "$separator" ]]; then
        zstyle ':zsh-gcloud-prompt:' separator '/'
    fi

    # Display the current account if `account` is true
    zstyle -s ':zsh-gcloud-prompt:' account account
    if [[ -z "$account" ]]; then
        zstyle ':zsh-gcloud-prompt:' account true
    fi

    # Check the stat command because it has a different syntax between GNU coreutils and FreeBSD.
    if stat --help >/dev/null 2>&1; then
        modified_time_fmt='-c%y' # GNU coreutils
    else
        modified_time_fmt='-f%m' # FreeBSD
    fi
    zstyle ':zsh-gcloud-prompt:' modified_time_fmt $modified_time_fmt
}

add-zsh-hook precmd _zsh_gcloud_prompt_precmd
function _zsh_gcloud_prompt_precmd() {
    local gcloud_home gcloud_config gcloud_active_config active_updated_at active_now 
    local config_updated_at config_now project account acct separator modified_time_fmt

    gcloud_home="$HOME/.config/gcloud"
    gcloud_active_config="$gcloud_home/active_config"
    gcloud_config="$gcloud_home/configurations/config_$(cat $gcloud_active_config)"

    zstyle -s ':zsh-gcloud-prompt:' modified_time_fmt modified_time_fmt

    # get the last time the profile changed
    if ! active_config_now="$(stat $modified_time_fmt "$gcloud_active_config" 2>/dev/null)"; then
        ZSH_GCLOUD_PROMPT="gcloud is not found"
        return 1
    fi

    # get the last time the active profile's configuration changed 
    if ! config_now="$(stat $modified_time_fmt "$gcloud_config" 2>/dev/null)"; then
        ZSH_GCLOUD_PROMPT="gcloud is not found"
        return 1
    fi

    zstyle -s ':zsh-gcloud-prompt:' active_updated_at active_updated_at
    zstyle -s ':zsh-gcloud-prompt:' config_updated_at config_updated_at
    if [[ "$active_updated_at" == "$active_now" && "$config_updated_at" == "$config_now"  ]]; then
        return 0
    fi
    zstyle ':zsh-gcloud-prompt:' active_updated_at "$active_now"
    zstyle ':zsh-gcloud-prompt:' config_updated_at "$config_now"

    if ! project="$(gcloud config get-value project 2>/dev/null)"; then
        ZSH_GCLOUD_PROMPT="gcloud project is not set"
        return 1
    fi

    zstyle -s ':zsh-gcloud-prompt:' account account
    if [[ "$account" != true ]]; then
        ZSH_GCLOUD_PROMPT="${project}"
        return 0
    fi

    acct="${$(gcloud config get-value account 2>/dev/null)%@*}"
    [[ -z "$acct" ]] && acct="nobody"

    zstyle -s ':zsh-gcloud-prompt:' separator separator
    ZSH_GCLOUD_PROMPT="G ${project}${separator}${acct}"

    return 0
}

function() {
    local namespace separator modified_time_fmt

    # Specify the separator between context and namespace
    zstyle -s ':zsh-kubectl-prompt:' separator separator
    if [[ -z "$separator" ]]; then
        zstyle ':zsh-kubectl-prompt:' separator '/'
    fi

    # Display the current namespace if `namespace` is true
    zstyle -s ':zsh-kubectl-prompt:' namespace namespace
    if [[ -z "$namespace" ]]; then
        zstyle ':zsh-kubectl-prompt:' namespace true
    fi

    # Check the stat command because it has a different syntax between GNU coreutils and FreeBSD.
    if stat --help >/dev/null 2>&1; then
        modified_time_fmt='-c%y' # GNU coreutils
    else
        modified_time_fmt='-f%m' # FreeBSD
    fi
    zstyle ':zsh-kubectl-prompt:' modified_time_fmt $modified_time_fmt
}

add-zsh-hook precmd _zsh_kubectl_prompt_precmd
function _zsh_kubectl_prompt_precmd() {
    local kubeconfig updated_at now context namespace ns separator modified_time_fmt

    kubeconfig="$HOME/.kube/config"
    if [[ -n "$KUBECONFIG" ]]; then
        kubeconfig="$KUBECONFIG"
    fi

    zstyle -s ':zsh-kubectl-prompt:' modified_time_fmt modified_time_fmt
    if ! now="$(stat $modified_time_fmt "$kubeconfig" 2>/dev/null)"; then
        ZSH_KUBECTL_PROMPT="kubeconfig is not found"
        return 1
    fi

    zstyle -s ':zsh-kubectl-prompt:' updated_at updated_at
    if [[ "$updated_at" == "$now" ]]; then
        return 0
    fi
    zstyle ':zsh-kubectl-prompt:' updated_at "$now"

    if ! context="$(kubectl config current-context 2>/dev/null)"; then
        ZSH_KUBECTL_PROMPT="current-context is not set"
        return 1
    fi

    if [ ${#context} -ge 24 ]; then
        context=$(echo $context | awk '{print substr($0,0,10) "..." substr($0,length($0)-9,10)}')
    fi

    zstyle -s ':zsh-kubectl-prompt:' namespace namespace
    if [[ "$namespace" != true ]]; then
        ZSH_KUBECTL_PROMPT="${context}"
        return 0
    fi

    ns="$(kubectl config view -o "jsonpath={.contexts[?(@.name==\"$context\")].context.namespace}")"
    [[ -z "$ns" ]] && ns="default"

    zstyle -s ':zsh-kubectl-prompt:' separator separator
    ZSH_KUBECTL_PROMPT="⎈ ${context}${separator}${ns}"

    return 0
}



function my_git_prompt() {
  tester=$(git rev-parse --git-dir 2> /dev/null) || return
  
  INDEX=$(git status --porcelain 2> /dev/null)
  STATUS=""

  # is branch ahead?
  if $(echo "$(git log origin/$(git_current_branch)..HEAD 2> /dev/null)" | grep '^commit' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi

  # is anything staged?
  if $(echo "$INDEX" | command grep -E -e '^(D[ M]|[MARC][ MD]) ' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STAGED"
  fi

  # is anything unstaged?
  if $(echo "$INDEX" | command grep -E -e '^[ MARC][MD] ' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED"
  fi

  # is anything untracked?
  if $(echo "$INDEX" | grep '^?? ' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED"
  fi

  # is anything unmerged?
  if $(echo "$INDEX" | command grep -E -e '^(A[AU]|D[DU]|U[ADU]) ' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED"
  fi

  if [[ -n $STATUS ]]; then
    STATUS=" $STATUS"
  fi

  echo "$ZSH_THEME_GIT_PROMPT_PREFIX$(my_current_branch)$STATUS$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

function my_current_branch() {
  echo $(git_current_branch || echo "(no branch)")
}

function ssh_connection() {
  if [[ -n $SSH_CONNECTION ]]; then
    echo "%{$fg_bold[red]%}(ssh) "
  fi
}

local ret_status="%(?:%{$fg_bold[green]%}:%{$fg_bold[red]%})%?%{$reset_color%}"

PROMPT='%{$fg_bold[green]%}┌[%{$fg_bold[cyan]%}%n@%m%{$fg_bold[green]%}]\
-(%{$fg_bold[white]%}%2~%{$fg_bold[green]%})\
$(my_git_prompt)$(svn_prompt_info)\
%{$fg_bold[green]%}[%{$fg_bold[yellow]%}$ZSH_GCLOUD_PROMPT%{$fg_bold[green]%}]%{$reset_color%}\
%{$fg_bold[green]%}(%{$fg_bold[cyan]%}$ZSH_KUBECTL_PROMPT%{$fg_bold[green]%})%{$reset_color%}
%{$fg_bold[green]%}└> % %{$reset_color%}'

RPROMPT='%{$fg_bold[green]%}$(get_time)%{$reset_color%}'

ZSH_THEME_PROMPT_RETURNCODE_PREFIX="%{$fg_bold[red]%}"
ZSH_THEME_GIT_PROMPT_PREFIX=" $fg[white]‹ %{$fg_bold[yellow]%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg_bold[magenta]%}↑"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}●"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[red]%}●"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[white]%}●"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[red]%}✕"
ZSH_THEME_GIT_PROMPT_SUFFIX=" $fg_bold[white]›%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_PREFIX="-[%{$reset_color%}%{$fg[white]%}git:%{$fg_bold[white]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg_bold[green]%}]"

autoload -U colors; colors
