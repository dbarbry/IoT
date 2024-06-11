BBLU		=	\033[1;34m
BGREEN		=	\033[1;32m
BRED		=	\033[1;31m
BLU			=	\033[0;34m
GRN			=	\033[0;32m
RED			=	\033[0;31m
RST			=	\033[0m

NAME		=	p3

all: print_header up
.PHONY: all

print_header:
	@echo "$(BBLU)===================================================="
	@echo "$(BBLU)"
	@echo "$(BBLU)\033[17G██╗░█████╗░████████╗"
	@echo "$(BBLU)\033[17G██║██╔══██╗╚══██╔══╝"
	@echo "$(BBLU)\033[17G██║██║░░██║░░░██║░░░"
	@echo "$(BBLU)\033[17G██║██║░░██║░░░██║░░░"
	@echo "$(BBLU)\033[17G██║╚█████╔╝░░░██║░░░"
	@echo "$(BBLU)\033[17G╚═╝░╚════╝░░░░╚═╝░░░"
	@echo "$(BBLU)"
	@echo "$(BBLU)=======================> p3 <======================="
	@echo "$(RST)"
.PHONY: print_header

up:
	@echo "${YELLOW}Running scripts on Linux ...${END}"
	@sudo ./scripts/checks.sh && ./scripts/prerequisities.sh && sudo ./scripts/k3d.sh && sudo ./scripts/argocd.sh && sudo ./scripts/dev.sh

clean:
	${RM} ./confs/kubectl
	${RM} ./confs/kubectl.sha256 
	echo "$(RED)[CLEAN]  :$(RST) Deleting objects...$(BGREEN)\033[47G[✔]$(RST)"
.PHONY: clean

.SILENT: