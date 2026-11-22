# 显式调用：nman ls / nman 3 printf / nman printf(3)
nman() { nvim -c "hide Man $*"; }
