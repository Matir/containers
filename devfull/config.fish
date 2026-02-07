if status is-interactive
    # Commands to run in interactive sessions can go here
    if test -x /usr/local/bin/starship
        /usr/local/bin/starship init fish | source
    end
end

if test -x /usr/local/bin/mise
  /usr/local/bin/mise activate fish | source
end