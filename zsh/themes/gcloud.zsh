# Based on https://github.com/superbrothers/zsh-kubectl-prompt
setopt prompt_subst
autoload -U add-zsh-hook

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
    local gcloud_home gcloud_config gcloud_active_config active_updated_at active_now config_updated_at config_now project account acct separator modified_time_fmt

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
    ZSH_GCLOUD_PROMPT="${project}${separator}${acct}"

    return 0
}

