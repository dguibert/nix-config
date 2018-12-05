# nix-env -f ~/.nixpkgs/my-packages.nix -ir
# nix-env -f ~/.nixpkgs/my-packages.nix -ir -I nixpkgs=$HOME/code/nixpkgs/
with import <nixpkgs> {};
[
nix  
gitAndTools.git-annex
gitAndTools.hub
gitAndTools.git-crypt
gitFull #guiSupport is harmless since we also installl xpra
subversion
tig
direnv
jq
lsof
xpra
htop
tree

# testing (removed 20171122)
#Mitos
#MemAxes
python3

editorconfig-core-c
]