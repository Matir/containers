if status is-interactive
    abbr --add ll 'eza -la --group-directories-first'
    abbr --add lt 'eza --tree'
    abbr --add cat 'batcat --paging=never'
    abbr --add fd 'fdfind'
    abbr --add gs 'git status'
    abbr --add gd 'git diff'
    abbr --add gl 'git log --oneline --graph --decorate'

    if test -x /usr/local/bin/starship
        /usr/local/bin/starship init fish | source
    end
end

if test -x /usr/local/bin/mise
    /usr/local/bin/mise activate fish | source
end

command -v zoxide >/dev/null 2>&1 && zoxide init fish | source
command -v direnv >/dev/null 2>&1 && direnv hook fish | source
