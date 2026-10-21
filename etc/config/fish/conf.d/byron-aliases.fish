function g --wraps=git --description 'alias g=git'
    git $argv
end

function ga --wraps='git add' --description 'alias ga=git add'
    git add $argv
end

function gc --wraps='git commit --verbose' --description 'alias gc=git commit --verbose'
    git commit --verbose $argv
end

function gca --wraps='git commit --verbose --all' --description 'alias gca=git commit --verbose --all'
    git commit --verbose --all $argv
end

function gcan! --wraps='git commit --verbose --all --no-edit --amend' --description 'alias gcan!=git commit --verbose --all --no-edit --amend'
    git commit --verbose --all --no-edit --amend $argv
end

function gcn! --wraps='git commit --verbose --no-edit --amend' --description 'alias gcn!=git commit --verbose --no-edit --amend'
    git commit --verbose --no-edit --amend $argv
end

function gco --wraps='git checkout' --description 'alias gco=git checkout'
    git checkout $argv
end

function gd --wraps='git diff' --description 'alias gd=git diff'
    git diff $argv
end

function gf --wraps='git fetch' --description 'alias gf=git fetch'
    git fetch $argv
end

function gl --wraps='git pull' --description 'alias gl=git pull'
    git pull $argv
end

function glf --wraps='git pull --ff-only' --description 'alias glf=git pull --ff-only'
    git pull --ff-only $argv
end

function glg --wraps='git log --stat' --description 'alias glg=git log --stat'
    git log --stat $argv
end

function glog --wraps='git log --oneline --decorate --graph' --description 'alias glog=git log --oneline --decorate --graph'
    git log --oneline --decorate --graph $argv
end

function glol --wraps='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"' --description 'alias glol=git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
    git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" $argv
end

function glola --wraps='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all' --description 'alias glola=git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'
    git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all $argv
end

function gp --wraps='git push' --description 'alias gp=git push'
    git push $argv
end

function gr --wraps='git remote' --description 'alias gr=git remote'
    git remote $argv
end

function grv --wraps='git remote --verbose' --description 'alias grv=git remote --verbose'
    git remote --verbose $argv
end

function gsr --wraps='git svn rebase' --description 'alias gsr=git svn rebase'
    git svn rebase $argv
end

function gss --wraps='git status --short' --description 'alias gss=git status --short'
    git status --short $argv
end

function gst --wraps='git status' --description 'alias gst=git status'
    git status $argv
end

function gsta --wraps='git stash push' --description 'alias gsta=git stash push'
    git stash push $argv
end

function gstl --wraps='git stash list' --description 'alias gstl=git stash list'
    git stash list $argv
end

function gstp --wraps='git stash pop' --description 'alias gstp=git stash pop'
    git stash pop $argv
end

function gsts --wraps='git stash show --patch' --description 'alias gsts=git stash show --patch'
    git stash show --patch $argv
end

function gts --wraps='git tag --sign' --description 'alias gts=git tag --sign'
    git tag --sign $argv
end

function gwt --wraps='git worktree' --description 'alias gwt=git worktree'
    git worktree $argv
end

function cdd --wraps=cd-repo --description 'alias cdd=cd-repo'
    cd-repo $argv
end

function wts --wraps='wt switch' --description 'alias wts=wt switch'
    wt switch $argv
end

function wtc --wraps='wt switch --new-branch' --description 'alias wtc=wt switch --new-branch'
    wt switch --new-branch $argv
end

function orc --wraps=cd-repo-corpus --description 'alias orc=cd-repo-corpus'
    cd-repo-corpus $argv
end

function l --wraps='eza -abgl' --description 'alias l=eza -abgl'
    eza -abgl $argv
end

function lla --wraps='eza -abgl' --description 'alias lla=eza -abgl'
    eza -abgl $argv
end

function cat --wraps=bat --description 'alias cat=bat'
    bat $argv
end

function tam --wraps='tix amend' --description 'alias tam=tix amend'
    tix amend $argv
end

function tig --wraps=tix --description 'alias tig=tix'
    tix $argv
end

function tigm --wraps='tig -x main -x master 2>/dev/null' --description 'alias tigm=tig -x main -x master 2>/dev/null'
    tig -x main -x master 2>/dev/null $argv
end
